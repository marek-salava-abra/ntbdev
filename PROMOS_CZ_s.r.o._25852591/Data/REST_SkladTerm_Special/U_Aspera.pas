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
  cStoreCard_Field_NoCheckPlan = 'X_DoNotCheckPlan';   // nazev pole "nekontrolovat na plan"

///////////////////////////////////////////////////////////////////////////////
procedure getAsperaAvailableQuantityInFirmPlan(Self: TNxWebServicesHelper; ARequest: TNxHTTPRequest;
  AResponse: TNxHTTPResponse; slPath: TStringList);
var
  mFirm_ID, mStoreCard_ID: String;
  dtHeader: TMemTable;
  mSL: TStringList;
  mSql: String;
  json: TJSONSuperObject;
  mNoCheckPlan: Boolean;
begin
  json := nil;
  if (slPath.Count = 3) then
  begin
    mFirm_ID := slPath.Strings[1]; //ocekavam firmu
    mStoreCard_ID := slPath.Strings[2]; //ocekavam artikl
  end else
  begin
    ErrREST(ARequest, AResponse, HTTP_SC_BadRequest, 'Nesprávný počet parametrů.');
    exit;
  end;

  LogWriteSectionStart('getAsperaAvailableQuantityInFirmPlan');

  dtHeader := TMemTable.Create(nil);
  mSL := TStringList.Create;
  try
    // zjistuju sumu nevydaneho mnozstvi predaneho artiklu na nevyrizenych OBP s predanou firmou
    mSql := 'select sum(RO2.Quantity - RO2.DeliveredQuantity) as "Available" ' +
        'from ReceivedOrders RO ' +
        'join UserStatuses US on US.ID = RO.Status_ID ' +
        'join ReceivedOrders2 RO2 on RO2.Parent_ID = RO.ID ' +
        'where RO.Firm_ID in (select F.ID from Firms F where F.ID = ' + QuotedStr(mFirm_ID) +' or F.Firm_ID = ' + QuotedStr(mFirm_ID) + ')' +
        '  and US.InternalStatus = 4 ' +
        '  and RO2.StoreCard_ID = ' + QuotedStr(mStoreCard_ID);

    Self.ObjectSpace.SQLSelect2(mSql, dtHeader);

    if not dtHeader.Active then
    begin
      DataSet_CreataHeader(dtHeader, 'Available=F');
      dtHeader.Open;
      dtHeader.Append;
      dtHeader.FieldByName('Available').AsFloat := 0;
      dtHeader.Post;
    end;

    mNoCheckPlan := SQLSelectStr(Self.ObjectSpace,
      'select SC.' + cStoreCard_Field_NoCheckPlan + ' ' +
      'from StoreCards SC ' +
      'where SC.ID = ' + QuotedStr(mStoreCard_ID)
      ) = 'A';

    if mNoCheckPlan then
    begin
      dtHeader.Edit;
      dtHeader.FieldByName('Available').AsFloat := 99999999;
      dtHeader.Post;
    end;

    dtHeader.First;
    LogWriteSectionStart('JSON');
    json := jsonCreate_FromDataSetRow(dtHeader, nil, mSL);
    LogWriteSectionEnd;

    HTTPResponse(AResponse, HTTP_SC_OK, ContentType_JSON, json.AsJson(false, true));
  finally
    dtHeader.Free;
    mSL.Free;
    if Assigned(json) then
      json.Free;
  end;

  LogWriteSectionEnd;
end;
///////////////////////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////////////////////
procedure putAsperaBillOfDeliveryWithoutDocStopPicking(Self: TNxWebServicesHelper; ARequest: TNxHTTPRequest;
  AResponse: TNxHTTPResponse; slPath: TStringList);
var
  mSql, mLSD_ID, mSD_ID, mUser_Id, mFirm_ID: String;
  mSD, mSDRow, {mLSD,}{ mOrder, mDocRowBatch, mConnectedRow: TNxCustomBusinessObject;
  json: TJSONSuperObject;
  mSDRows, mLSDRows, mDocRowBatches, mConnectedRows: TNxCustomBusinessMonikerCollection;
  i, j: Integer;
  mNeededQuantity, mAppliedQuantity, mQuantityInPlan: Double;
  mProvideRowUnitQuantity: Double;
  dtJSONRows, dtDocumentQuantity, dtRORows: TMemTable;
  mTemporaryStorageID: Integer;
  mOS: TNxCustomObjectSpace;
  mNoCheckPlan: Boolean;
  mDIM: TNxDocumentImportManager;
  mParams: TNxParameters;
  mRequestID, mSwitchRule: String;
begin
  json := nil;
  if (slPath.Count = 1) then
  begin
    //mDoc_ID := slPath.Strings[1];
  end else
  begin
    ErrREST(ARequest, AResponse, HTTP_SC_BadRequest, 'Nesprávný počet parametrů.');
    exit;
  end;

  LogWriteSectionStart('putAsperaBillOfDeliveryWithoutDocStopPicking');

  mOS := Self.ObjectSpace;
  mUser_Id := getHeaderValue(ARequest, 'UserID');
  json := TJSONSuperObject.ParseString(REST_ByteUTF82String(ARequest.Content.Content), True);
  mTemporaryStorageID := getJSONInt(json, 'tempID');
  mFirm_ID := getJSONStr(json, 'Firm_ID');
  mSD := mOS.CreateObject(Class_BillOfDelivery);
  dtJSONRows := TMemTable.Create(nil);
  dtDocumentQuantity := TMemTable.Create(nil);
  dtRORows := TMemTable.Create(nil);
  //mOrder := mOS.CreateObject(Class_IssuedOrder);
  try
    mRequestID := getJSONStr(json, 'saveRequestID');
    // pred transakci overime, jestli uz tento request nebezi nebo neni dokonce dokonceny. Pokud ne, tak ho zalozime.
    case Request_Start(mOS, mRequestID, 'putAsperaBillOfDeliveryWithoutDocStopPicking') of
      1: begin
        ErrREST(ARequest, AResponse, HTTP_SC_ExpectationFailed, cRequestRunningMessage);
        exit;
      end;
      2: begin
        HTTPResponse(AResponse, HTTP_SC_OK, ContentType_JSON, PlainResponse(''));
        exit;
      end;
    end;

    mLSD_ID := '';

    mOS.StartTransaction(taReadCommited);
    try
      mSD.ExplicitTransaction := True;

      // dataset, do ktereho si preplnime polozky z JSONu
      DataSet_CreataHeader(dtJSONRows, 'jsonIndex=I,StoreDocument2_ID=S10,StoreDocument2Provide_ID=S10,StoreDocument2ProvideRow_ID=S10,' +
        'DocRowBatch_ID=S10,LogStoreDocument2_ID=S10,StoreFrom_ID=S10,StoreTo_ID=S10,StoreCard_ID=S10,StorePositionFrom_ID=S10,' +
        'StoreBatch_ID=S10,StorePositionTo_ID=S10,Processed=B,UnitQuantity=F,UnitQuantityErr=F,UnitRate=F,UnitCode=S10,Division_ID=S10,StoreCardCode=S40');
      dtJSONRows.AddIndex('ByJsonIndex', 'jsonIndex', [ixUnique]);
      //dtJSONRows.AddIndex('ByStoreDocument2_ID', 'StoreDocument2_ID;jsonIndex', [ixUnique]);
      //dtJSONRows.AddIndex('ByStoreCard_ID', 'StoreCard_ID;jsonIndex', [ixUnique]);
      dtJSONRows.Open;
      JsonToDataSet(json.A['rows'], dtJSONRows);

      // dataset pro funkci Create_LogStoreDocument
      DataSet_CreataHeader(dtDocumentQuantity, 'Store_ID=S10,StoreCard_ID=S10,StoreBatch_ID=S10,StorePosition_ID=S10,Quantity=F');
      dtDocumentQuantity.AddIndex('I0', 'Store_ID;StoreCard_ID;StoreBatch_ID;StorePosition_ID', [ixUnique]);
      dtDocumentQuantity.IndexName:= 'I0';
      dtDocumentQuantity.Open;

      // POSTUP
      // - zalozim novou prazdnou vydejku
      // - vyjedu si vsechny polozky nevyrizenych OBP na danou firmu, na ktere budu chtit parovat, s nevyskladnenym mnozstvim a prazdnym polem
      //   na vyuzite mnozstvi pri parovani, vyjedu si taky Parent_ID a ID polozek pro pouziti v importnim manazeru
      // - prochazim napipane polozky, pro kazdou si najdu vhodne polozky z OBP, na ktere by se dalo naparovat, pomoci importniho manazera
      //   je naimportuju do VYD, nasledne jim pripadne upravim mnozstvi, nastavim sarzi. Do pomocneho seznamu polozek OBP si poznacim mnozstvi, ktere
      //   uz jsem z ni vyuzil.
      // - pokracuji na dalsi napipanou polozku
      // - artikly s priznakem "nekontrolovat na plan" se nesnazime hledat na OBP, rovnou je dame na vydejku jako volne polozky
      // - na zaver vytvorim k vydejce polohovak

      // pomocny dataset pro polozky OBP
      mSql := 'select RO2.StoreCard_ID as "StoreCard_ID", RO2.Parent_ID as "Parent_ID", RO2.ID as "ID", ' +
        '  RO2.Quantity - RO2.DeliveredQuantity as "Quantity", RO2.DeliveryDate$DATE as "DeliveryDate" ' +
        'from ReceivedOrders RO ' +
        'join UserStatuses US on US.ID = RO.Status_ID ' +
        'join ReceivedOrders2 RO2 on RO2.Parent_ID = RO.ID ' +
        'where RO.Firm_ID in (select F.ID from Firms F where F.ID = ' + QuotedStr(mFirm_ID) +' or F.Firm_ID = ' + QuotedStr(mFirm_ID) + ')' +
        '  and US.InternalStatus = 4 ' +
        '  and RO2.Quantity - RO2.DeliveredQuantity > 0 ';
      mOS.SQLSelect2(mSql, dtRORows);
      if not dtRORows.Active then
      begin
        DataSet_CreataHeader(dtRORows, 'StoreCard_ID=S10,Parent_ID=S10,ID=S10,Quantity=F,DeliveryDate=F');
        dtRORows.Open;
      end;
      dtRORows.AddIndex('I0', 'StoreCard_ID;DeliveryDate;ID', [ixUnique]);
      dtRORows.IndexName:= 'I0';
      dtRORows.Open;

      mSD.New;
      mSD.Prefill;
      mSD.SetFieldValueAsString('DocQueue_ID', RADA_VYDEJKA);
      mSD.SetFieldValueAsString('Firm_ID', mFirm_ID);
      mSDRows := mSD.GetLoadedCollectionMonikerForFieldCode(mSD.GetFieldCode('Rows'));

      // pruchod napipanymi polozkami
      dtJSONRows.First;
      while not dtJSONRows.EOF do
      begin
        // musime pokryt cele napipane mnozstvi
        mNeededQuantity := dtJSONRows.FieldByName('UnitQuantity').AsFloat;

        mNoCheckPlan := SQLSelectStr(mOS,
          'select SC.' + cStoreCard_Field_NoCheckPlan + ' ' +
          'from StoreCards SC ' +
          'where SC.ID = ' + QuotedStr(dtJSONRows.FieldByName('StoreCard_ID').AsString)
          ) = 'A';

        // pokud ma artikl priznak "nekontrolovat plan", pridame jako volnou polozku
        if mNoCheckPlan then
        begin
          mSDRow := mSDRows.AddNewObject;
          mSDRow.SetFieldValueAsInteger('RowType', 3);
          mSDRow.SetFieldValueAsString('Store_ID', dtJSONRows.FieldByName('StoreFrom_ID').AsString);
          mSDRow.SetFieldValueAsString('StoreCard_ID', dtJSONRows.FieldByName('StoreCard_ID').AsString);
          mSDRow.SetFieldValueAsString('Division_ID', STREDISKO_HLAVNI);
          mSDRow.SetFieldValueAsFloat('Quantity', mNeededQuantity);

          // nastavime sarzi
          if not CFxOID.IsEmpty(dtJSONRows.FieldByName('StoreBatch_ID').AsString) then
          begin
            mDocRowBatches := mSDRow.GetLoadedCollectionMonikerForFieldCode(mSDRow.GetFieldCode('DocRowBatches'));
            mDocRowBatch := mDocRowBatches.AddNewObject;
            mDocRowBatch.SetFieldValueAsString('StoreBatch_ID', dtJSONRows.FieldByName('StoreBatch_ID').AsString);
            mDocRowBatch.SetFieldValueAsString('QUnit', mSDRow.GetFieldValueAsString('QUnit'));
            mDocRowBatch.SetFieldValueAsFloat('Quantity', mNeededQuantity);
          end;

          mNeededQuantity := 0;
        end
        else begin
          // hledame nevyuzite polozky OBP vhodne pro vykryti teto napipane polozky
          dtRORows.FindNearest([dtJSONRows.FieldByName('StoreCard_ID').AsString, 0, '']);
          while not dtRORows.EOF and (dtRORows.FieldByName('StoreCard_ID').AsString = dtJSONRows.FieldByName('StoreCard_ID').AsString) do
          begin
            // hledame jeste nevyuzite polozky OBP
            if not CFxFloat.IsZero6(dtRORows.FieldByName('Quantity').AsFloat) then
            begin
              // naimportujeme polozku
              mParams := TNxParameters.Create;
              mDIM := NxCreateDocumentImportManager(mOS, Class_ReceivedOrder, Class_BillOfDelivery);
              try
                mDIM.AddInputDocument(dtRORows.FieldByName('Parent_ID').AsString);
                mDIM.SaveParams(mParams);
                mParams.GetOrCreateParam(dtString,'Store_ID').AsString := dtJSONRows.FieldByName('StoreFrom_ID').AsString;
                mParams.GetOrCreateParam(dtString,'DocQueue_ID').AsString := mSD.GetFieldValueAsString('DocQueue_ID');
                mParams.GetOrCreateParam(dtString,'SelectedRows').AsString := dtRORows.FieldByName('ID').AsString;
                mDIM.LoadParams(mParams);
                mDIM.OutputDocument := mSD;
                mDIM.Execute;
              finally
                mDIM.Free;
                mParams.free;
              end;

              // dohledame naimportovanou polozku
              for i := mSDRows.Count - 1 downto 0 do
              begin
                mSDRow := mSDRows.BusinessObject[i];
                if mSDRow.GetFieldValueAsString('ProvideRow_ID') = dtRORows.FieldByName('ID').AsString then
                begin
                  mSDRow.SetFieldValueAsString('Store_ID', dtJSONRows.FieldByName('StoreFrom_ID').AsString);
                  // nastavime mnozstvi a upravime nevyuzite mnozstvi polozky OBP
                  if CFxFloat.Compare6(dtRORows.FieldByName('Quantity').AsFloat, mNeededQuantity) >= 0 then
                  begin
                    mAppliedQuantity := mNeededQuantity;
                    mNeededQuantity := 0;
                    dtRORows.Edit;
                    dtRORows.FieldByName('Quantity').AsFloat := dtRORows.FieldByName('Quantity').AsFloat - mAppliedQuantity;
                    dtRORows.Post;
                  end
                  else begin
                    mAppliedQuantity := dtRORows.FieldByName('Quantity').AsFloat;
                    mNeededQuantity := mNeededQuantity - mAppliedQuantity;
                    dtRORows.Edit;
                    dtRORows.FieldByName('Quantity').AsFloat := 0;
                    dtRORows.Post;
                  end;
                  mSDRow.SetFieldValueAsFloat('Quantity', mAppliedQuantity);

                  // nastavime sarzi
                  if not CFxOID.IsEmpty(dtJSONRows.FieldByName('StoreBatch_ID').AsString) then
                  begin
                    mDocRowBatches := mSDRow.GetLoadedCollectionMonikerForFieldCode(mSDRow.GetFieldCode('DocRowBatches'));
                    mDocRowBatch := mDocRowBatches.AddNewObject;
                    mDocRowBatch.SetFieldValueAsString('StoreBatch_ID', dtJSONRows.FieldByName('StoreBatch_ID').AsString);
                    mDocRowBatch.SetFieldValueAsString('QUnit', mSDRow.GetFieldValueAsString('QUnit'));
                    mDocRowBatch.SetFieldValueAsFloat('Quantity', mAppliedQuantity);
                  end;
                  break;
                end;
              end;
            end;

            if CFxFloat.IsZero6(mNeededQuantity) then
              break;

            dtRORows.Next;
          end;
        end;

        if not CFxFloat.IsZero6(mNeededQuantity) then
        begin
          mQuantityInPlan := SQLSelectFloat(mOS, 'select sum(RO2.Quantity - RO2.DeliveredQuantity) as "Available" ' +
            'from ReceivedOrders RO ' +
            'join UserStatuses US on US.ID = RO.Status_ID ' +
            'join ReceivedOrders2 RO2 on RO2.Parent_ID = RO.ID ' +
            'where RO.Firm_ID in (select F.ID from Firms F where F.ID = ' + QuotedStr(mFirm_ID) +' or F.Firm_ID = ' + QuotedStr(mFirm_ID) + ')' +
            '  and US.InternalStatus = 4 ' +
            '  and RO2.StoreCard_ID = ' + QuotedStr(dtJSONRows.FieldByName('StoreCard_ID').AsString));

          RaiseException('V plánu zákazníka nebylo nalezeno dostatečné množství pro artikl: ' + dtJSONRows.FieldByName('StoreCardCode').AsString +
            #13#10 + 'Množství v plánu: ' + FormatFloat('0.00,', mQuantityInPlan));
        end;

        dtJSONRows.Next;
      end;

      mSwitchRule := GetSwitchRuleForStatusFromAndStatusTo(mOS, mSD.GetFieldValueAsString('Status_ID'), STAV_VYRIZENO(DOC_VYD));
      mSD.ChangeStatusBySwitchRule(mSwitchRule);

      // protoze FLORES vazby mezi polozkami OBP a VYD nepodporuji vytvoreni nekolika polozek VYD z jedne polozky OBP v jednom kroku, doplnime je ted rucne
      mSD.Refresh;
      mSDRows := mSD.GetLoadedCollectionMonikerForFieldCode(mSD.GetFieldCode('Rows'));
      for i := 0 to mSDRows.Count - 1 do
      begin
        mSDRow := mSDRows.BusinessObject[i];
        mConnectedRows := mSDRow.GetLoadedCollectionMonikerForFieldCode(mSDRow.GetFieldCode('ConnectedRows'));
        if (mConnectedRows.Count = 0) and not CFxOID.IsEmpty(mSDRow.GetFieldValueAsString('ProvideRow_ID')) then
        begin
          mConnectedRow := mConnectedRows.AddNewObject;
          mConnectedRow.SetFieldValueAsInteger('TypeConnection', 100);
          mConnectedRow.SetFieldValueAsString('Order_ID', mSDRow.GetFieldValueAsString('Provide_ID'));
          mConnectedRow.SetFieldValueAsString('OrderRow_ID', mSDRow.GetFieldValueAsString('ProvideRow_ID'));
          mConnectedRow.SetFieldValueAsString('StoreDocument_ID', mSDRow.GetFieldValueAsString('Parent_ID'));
          mConnectedRow.SetFieldValueAsString('StoreDocumentRow_ID', mSDRow.OID);
          mConnectedRow.SetFieldValueAsFloat('Quantity', mSDRow.GetFieldValueAsFloat('Quantity'));
        end;
      end;
      if mSD.NeedSave then
        mSD.Save;

      // naplnime pomocny dataset pro vytvoreni polohovaku
      dtDocumentQuantity.EmptyTable;
      dtJSONRows.First;
      while not dtJSONRows.EOF do
      begin
        if not CFxOID.IsEmpty(dtJSONRows.FieldByName('StorePositionFrom_ID').AsString) then
        begin
          AddTodtDocumentQuantity(dtDocumentQuantity,
            dtJSONRows.FieldByName('StoreFrom_ID').AsString,
            dtJSONRows.FieldByName('StoreCard_ID').AsString,
            NxIIfStr(CFxOID.IsEmpty(dtJSONRows.FieldByName('StoreBatch_ID').AsString), 'ZZZZZZZZZZ', dtJSONRows.FieldByName('StoreBatch_ID').AsString),
            dtJSONRows.FieldByName('StorePositionFrom_ID').AsString,
            dtJSONRows.FieldByName('UnitQuantity').AsFloat,
            dtJSONRows.FieldByName('UnitRate').AsFloat
          );
        end;
        dtJSONRows.Next;
      end;

      // vytvorime polohovak
      if dtDocumentQuantity.RecordCount > 0 then
        mLSD_ID := Create_LogStoreDocument(mOS, mSD, '',
          Class_LogStoreOutput,
          LogStoreOutput_DocQueue_ID,
          LogStoreOutput_StoreGateway_ID, dtDocumentQuantity, mUser_Id,
          False, gLog);

      // tisk reportu
      PrintReportToPrinterByIDToQueue(Self.Context, mSD.OID, '', REPORT_VYSKLADNENI(DOC_VYD), TISKARNA_SKLAD, mUser_ID, 3);

      // vymaz z TemporaryStorage jeste v transakci
      TemporaryStorage_Delete(mOS, mTemporaryStorageID);

      Request_Finish(mOS, mRequestID);

      mOS.Commit;

      HTTPResponse(AResponse, HTTP_SC_OK, ContentType_JSON, PlainResponse(''));

    except
      mOS.RollBack;
      HTTPResponse(AResponse, HTTP_SC_OK, ContentType_JSON, PlainResponse('Chyba při ukončení výdeje: ' + ExceptionMessage));
      Request_Cancel(mOS, mRequestID);
      glog.WriteEvent(logError, 'putAsperaBillOfDeliveryWithoutDocStopPicking - error - '+ExceptionMessage);
      LogWriteSectionEnd;
      exit;
    end;
  finally
    mSD.Free;
    //mLSD.Free;
    mOrder.Free;
    json.Free;
    dtJSONRows.Free;
    dtDocumentQuantity.Free;
    dtRORows.Free;
  end;

  // provedeni polohovaku udelame ve zvlastni transakci, protoze to casto pada na deadlock
  // pokud se to nepodari, aspon je vse ostatni vytvorene
  ConfirmLSD(mOS, Class_LogStoreOutput, mLSD_ID, 'putAsperaBillOfDeliveryWithoutDocStopPicking', glog);

  LogWriteSectionEnd;
end;
///////////////////////////////////////////////////////////////////////////////
    }
begin
end.