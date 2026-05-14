{uses
  'REST_SkladTerm.U_Func',
  'REST_SkladTerm.U_FuncJSON',
  'REST_SkladTerm.U_TemporaryStorage',
  'REST_SkladTerm_Special.U_Const',
  'REST_SkladTerm.U_LogStoreDocument',
  'StandardUnits.U_DataSet',
  'StandardUnits.U_GetId',
  'REST_SkladTerm.U_Requests';

const
  cRadaOBP = 'I700000101';
  cRadaVYD = 'P600000101';
  cRadaFAV = '5600000101';
  cRadaPP  = '7600000101';
  cStavOBP = 'G200000001';
  cStavFAV = 'M200000001';
  cStavPP  = 'HB00000001';
  cPokladnaCZK = '2200000101';
  cStredisko_ID = STREDISKO_HLAVNI;
  //cObchPripad_ID = '2300000101';
  cConstSymbol = '0000008000';

procedure putRokaBillOfDeliveryWithoutDocStopPicking(Self: TNxWebServicesHelper; ARequest: TNxHTTPRequest;
  AResponse: TNxHTTPResponse; slPath: TStringList);
var
  mSql, mUser_Id, mSD_ID, mFirm_ID: String;
  mRO, mRORow, mSD, mSDRow, mIO, mDocRowBatch: TNxCustomBusinessObject;
  json: TJSONSuperObject;
  jsonSerNums: TJSONSuperObjectArray;
  mRORows, mSDRows, mDocRowBatches: TNxCustomBusinessMonikerCollection;
  i, j: Integer;
  dtJSONRows: TMemTable;
  mTemporaryStorageID: Integer;
  mOS: TNxCustomObjectSpace;
  mNoCheckPlan: Boolean;
  mDIM, mDIM2: TNxDocumentImportManager;
  mParams, mParams2: TNxParameters;
  mRequestID, mSwitchRule: String;
begin
  json := nil;
  if (slPath.Count <> 1) then
  begin
    ErrREST(ARequest, AResponse, HTTP_SC_BadRequest, 'Nesprávný počet parametrů.');
    exit;
  end;

  LogWriteSectionStart('putRokaBillOfDeliveryWithoutDocStopPicking');

  mOS := Self.ObjectSpace;
  mUser_Id := getHeaderValue(ARequest, 'UserID');
  json := TJSONSuperObject.ParseString(REST_ByteUTF82String(ARequest.Content.Content), True);
  mTemporaryStorageID := getJSONInt(json, 'tempID');
  mFirm_ID := getJSONStr(json, 'Firm_ID');
  mRO := mOS.CreateObject(Class_ReceivedOrder);
  dtJSONRows := TMemTable.Create(nil);
  try
    mRequestID := getJSONStr(json, 'saveRequestID');
    // pred transakci overime, jestli uz tento request nebezi nebo neni dokonce dokonceny. Pokud ne, tak ho zalozime.
    case Request_Start(mOS, mRequestID, 'putRokaBillOfDeliveryWithoutDocStopPicking') of
      1: begin
        ErrREST(ARequest, AResponse, HTTP_SC_ExpectationFailed, 'Předchozí pokus o uložení stále probíhá. Zkuste to za chvíli.');
        exit;
      end;
      2: begin
        HTTPResponse(AResponse, HTTP_SC_OK, ContentType_JSON, PlainResponse(''));
        exit;
      end;
    end;

    mOS.StartTransaction(taReadCommited);
    try
      mRO.ExplicitTransaction := True;

      // dataset, do ktereho si preplnime polozky z JSONu
      DataSet_CreataHeader(dtJSONRows, 'jsonIndex=I,StoreDocument2_ID=S10,StoreDocument2Provide_ID=S10,StoreDocument2ProvideRow_ID=S10,' +
        'DocRowBatch_ID=S10,LogStoreDocument2_ID=S10,StoreFrom_ID=S10,StoreTo_ID=S10,StoreCard_ID=S10,StorePositionFrom_ID=S10,' +
        'StoreBatch_ID=S10,StorePositionTo_ID=S10,Processed=B,UnitQuantity=F,UnitQuantityErr=F,UnitRate=F,UnitCode=S10,Division_ID=S10,StoreCardCode=S40');
      dtJSONRows.AddIndex('ByJsonIndex', 'jsonIndex', [ixUnique]);
      dtJSONRows.Open;
      JsonToDataSet(json.A['rows'], dtJSONRows);

      // vytvorim OBP
      mRO.New;
      mRO.Prefill;
      mRO.SetFieldValueAsString('DocQueue_ID', cRadaOBP);
      mRO.SetFieldValueAsString('Firm_ID', mFirm_ID);
      mRO.SetFieldValueAsString('Status_ID', cStavOBP);
      mRORows := mRO.GetCollectionMonikerForFieldCode(mRO.GetFieldCode('Rows'));

      // pruchod napipanymi polozkami
      dtJSONRows.First;
      while not dtJSONRows.EOF do
      begin
        mRORow := mRORows.AddNewObject;
        mRORow.SetFieldValueAsInteger('RowType', 3);
        mRORow.SetFieldValueAsString('Store_ID', dtJSONRows.FieldByName('StoreFrom_ID').AsString);
        mRORow.SetFieldValueAsString('StoreCard_ID', dtJSONRows.FieldByName('StoreCard_ID').AsString);
        mRORow.SetFieldValueAsFloat('Quantity', dtJSONRows.FieldByName('UnitQuantity').AsFloat);
        mRORow.SetFieldValueAsString('Division_ID', cStredisko_ID);
        //mRORow.SetFieldValueAsString('BusTransaction_ID', cObchPripad_ID);

        dtJSONRows.Next;
      end;

      mRO.Save;

      //vytvoreni vydejky z objednavky
      mParams := TNxParameters.Create;
      mDIM := NxCreateDocumentImportManager(mOS, Class_ReceivedOrder, Class_BillOfDelivery);
      try
        mDIM.AddInputDocument(mRO.OID);
        mDIM.SaveParams(mParams);
        mParams.GetOrCreateParam(dtString,'DocQueue_ID').AsString := cRadaVYD;
        mDIM.LoadParams(mParams);
        mDIM.Execute;

        mSD := mDIM.OutputDocument;
        mSD.SetFieldValueAsString('Firm_ID', mFirm_ID);
        mSD.SetFieldValueAsString('Status_ID', STAV_VYRIZENO(DOC_VYD));
        mSDRows := mSD.GetCollectionMonikerForFieldCode(mSD.GetFieldCode('Rows'));

        //projdu znovu JSON a kde bude potreba, tak doplnim sarze
        //spoleham na to, ze radky jsou ve stejnem poradi
        dtJSONRows.First;
        i := 0;
        while not dtJSONRows.EOF do
        begin
          mSDRow := mSDRows.BusinessObject(i);

          //doplnim radku sarze
          if (mSDRow.GetFieldValueAsInteger('StoreCard_ID.Category') = 2) then
          begin
            mDocRowBatches := mSDRow.GetLoadedCollectionMonikerForFieldCode(mSDRow.GetFieldCode('DocRowBatches'));
            mDocRowBatch := mDocRowBatches.AddNewObject;
            mDocRowBatch.SetFieldValueAsString('StoreBatch_ID', dtJSONRows.FieldByName('StoreBatch_ID').AsString);
            mDocRowBatch.SetFieldValueAsString('QUnit', mSDRow.GetFieldValueAsString('QUnit'));
            mDocRowBatch.SetFieldValueAsFloat('Quantity', dtJSONRows.FieldByName('UnitQuantity').AsFloat);
          end;

          //doplnim radku ser. cisla
          if (mSDRow.GetFieldValueAsInteger('StoreCard_ID.Category') = 1) then
          begin
            mDocRowBatches := mSDRow.GetLoadedCollectionMonikerForFieldCode(mSDRow.GetFieldCode('DocRowBatches'));
            // musime do jsonu pro kolekci sernums
            jsonSerNums := json.A['rows'].O[dtJSONRows.FieldByName('jsonIndex').AsInteger].A['sernums'];
            for j := 0 to jsonSerNums.Length - 1 do
            begin
              mDocRowBatch := mDocRowBatches.AddNewObject;
              mDocRowBatch.SetFieldValueAsString('StoreBatch_ID', jsonSerNums.O[j].S['SerNum_ID']);
              mDocRowBatch.SetFieldValueAsString('QUnit', mSDRow.GetFieldValueAsString('QUnit'));
              mDocRowBatch.SetFieldValueAsFloat('UnitQuantity', 1);
            end;
          end;
          dtJSONRows.Next;
          i := i + 1;
        end;
        mSD.Save;
        mSD_ID := mSD.OID;
      finally
        mDIM.Free;
        mParams.free;
      end;

      // tisk reportu
      //PrintReportToPrinterByID(Self.Context, mSD.OID, '', REPORT_VYSKLADNENI(DOC_VYD), TISKARNA_SKLAD, 1);

      // vymaz z TemporaryStorage jeste v transakci
      TemporaryStorage_Delete(mOS, mTemporaryStorageID);

      Request_Finish(mOS, mRequestID);

      mOS.Commit;

      HTTPResponse(AResponse, HTTP_SC_OK, ContentType_JSON, PlainResponse(mSD_ID));

    except
      mOS.RollBack;
      HTTPResponse(AResponse, HTTP_SC_OK, ContentType_JSON, PlainResponse('Chyba při ukončení výdeje: ' + ExceptionMessage));
      Request_Cancel(mOS, mRequestID);
      glog.WriteEvent(logError, 'putRokaBillOfDeliveryWithoutDocStopPicking - error - '+ExceptionMessage);
      LogWriteSectionEnd;
      exit;
    end;
  finally
    mRO.Free;
    json.Free;
    dtJSONRows.Free;
  end;

  LogWriteSectionEnd;
end;
///////////////////////////////////////////////////////////////////////////////

procedure putRokaCreateFAVOrPP(Self: TNxWebServicesHelper; ARequest: TNxHTTPRequest;
  AResponse: TNxHTTPResponse; slPath: TStringList);
var
  mSql, SD_ID, mOutputDocument_ID, firm_ID: String;
  createFav: Boolean;
  mOutputDocument: TNxCustomBusinessObject;
  json: TJSONSuperObject;
  mOS: TNxCustomObjectSpace;
  mDIM: TNxDocumentImportManager;
  mParams: TNxParameters;
begin
  json := nil;
  if (slPath.Count = 4) then
  begin
    SD_ID := slPath.Strings[1];
    firm_ID := slPath.Strings[2];
    createFav := StrToBool(slPath.Strings[3]);
  end else
  begin
    ErrREST(ARequest, AResponse, HTTP_SC_BadRequest, 'Nesprávný počet parametrů.');
    exit;
  end;

  LogWriteSectionStart('putRokaCreateFAVOrPP');

  mOS := Self.ObjectSpace;
  json := TJSONSuperObject.ParseString(REST_ByteUTF82String(ARequest.Content.Content), True);
  try
    mOS.StartTransaction(taReadCommited);
    try
      // vytvorim fakturu nebo pokladni prijem
      if createFav then
      begin
        mOutputDocument := mOS.CreateObject(Class_IssuedInvoice);
        try
          //vytvorim fakturu z vydejky
          mParams := TNxParameters.Create;
          mDIM := NxCreateDocumentImportManager(mOS, Class_BillOfDelivery, Class_IssuedInvoice);
          try
            mDIM.AddInputDocument(SD_ID);
            mDIM.SaveParams(mParams);
            mParams.GetOrCreateParam(dtString,'DocQueue_ID').AsString := cRadaFAV;
            mDIM.LoadParams(mParams);
            mDIM.Execute;

            mOutputDocument := mDIM.OutputDocument;
            mOutputDocument_ID := mOutputDocument.OID;

            mOutputDocument.SetFieldValueAsString('Firm_ID', firm_ID);
            mOutputDocument.SetFieldValueAsString('Status_ID', cStavFAV);
            mOutputDocument.SetFieldValueAsString('ConstSymbol_ID', cConstSymbol);
            mOutputDocument.Save;
          finally
            mDIM.Free;
            mParams.Free;
          end;
        finally
          mOutputDocument.Free;
        end;
        // tisk reportu
        //PrintReportToPrinterByID(Self.Context, mOutputDocument.OID, '', rokaReport('FAV'), TISKARNA_SKLAD, 1);
      end
      else
      begin
       mOutputDocument := mOS.CreateObject(Class_CashReceived);
        try
          //vytvorim pokladni prijem z vydejky
          mParams := TNxParameters.Create;
          mDIM := NxCreateDocumentImportManager(mOS, Class_BillOfDelivery, Class_CashReceived);
          try
            mDIM.AddInputDocument(SD_ID);
            mDIM.SaveParams(mParams);
            mParams.GetOrCreateParam(dtString,'CashDesk_ID').AsString := cPokladnaCZK;
            mParams.GetOrCreateParam(dtString,'DocQueue_ID').AsString := cRadaPP;
            mDIM.LoadParams(mParams);
            mDIM.Execute;

            mOutputDocument := mDIM.OutputDocument;
            mOutputDocument_ID := mOutputDocument.OID;

            mOutputDocument.SetFieldValueAsString('Firm_ID', firm_ID);
            mOutputDocument.SetFieldValueAsString('Status_ID', cStavPP);
            mOutputDocument.Save;
          finally
            mDIM.Free;
            mParams.Free;
          end;
        finally
          mOutputDocument.Free;
        end;
        // tisk reportu
        //PrintReportToPrinterByID(Self.Context, mOutputDocument.OID, '', rokaReport('PP'), TISKARNA_SKLAD, 1);
      end;

      mOS.Commit;

      HTTPResponse(AResponse, HTTP_SC_OK, ContentType_JSON, PlainResponse(''));

    except
      mOS.RollBack;
      HTTPResponse(AResponse, HTTP_SC_OK, ContentType_JSON, PlainResponse('Chyba při vytváření FAV/PP: ' + ExceptionMessage));
      glog.WriteEvent(logError, 'putRokaCreateFAVOrPP - error - ' + ExceptionMessage);
      LogWriteSectionEnd;
      exit;
    end;
  finally
    json.Free;
  end;

  LogWriteSectionEnd;
end;

function rokaReport(document: String): String;
begin
  if document = 'FAV' then
    Result := 'W400000001';
  if document = 'PP' then
    Result := 'X400000001';
end;
}
begin
end.