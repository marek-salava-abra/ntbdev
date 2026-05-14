uses
  'REST_SkladTerm.U_CommonFunctionality',
  'REST_SkladTerm.U_Func',
  'REST_SkladTerm.U_FuncJSON',
  'REST_SkladTerm.U_LogStoreDocument',
  'REST_SkladTerm.U_Requests',
  'REST_SkladTerm.U_SQLQueries',
  'REST_SkladTerm.U_TemporaryStorage',
  'REST_SkladTerm.U_TransferBetweenPositions',
  'REST_SkladTerm.U_Translation',
  'REST_SkladTerm_Special.U_Const',
  'REST_SkladTerm_Special.U_StandardHooks',
  'StandardUnits.U_DataSet',
  'StandardUnits.U_GetId',
  'StandardUnits.U_Relation';

procedure putTransferWithoutDocStopPicking(AOS: TNxCustomObjectSpace; APath: TStringList; ABody: String; AResponse: TStringList);
var
  mJSON_Root: TJSONSuperObject;
  jsonSerNums: TJSONSuperObjectArray;
  mPreV, mPreP, mRow, mDocRowBatch: TNxCustomBusinessObject;
  mRows, mDocRowBatches: TNxCustomBusinessMonikerCollection;
  i: Integer;
  jsonCustomFields: TJSONSuperObjectArray;
  mTemporaryStorageID: Integer;
  dtJSONRows, dtDocumentQuantity: TMemTable;
  mDIM: TNxDocumentImportManager;
  mParams: TNxParameters;
  mPreV_ID, mPreP_ID, mLSDIn_ID, mLSDOut_ID, mAuxField, mPersonField, mSerNum_ID, mStoreBatch_ID, mDocQueue_ID: String;
  mRequestID: String;
  mAuxReadOnly, mBusTransactionMandatory, mBusProjectMandatory: Boolean;
begin
  if (APath.Count = 1) then
  begin
    //mDocType := slPath.Strings[1];
  end else
  begin
    SetPlainResponse(AResponse, getString('wrong_parameters_count'), HTTP_SC_BadRequest);
    exit;
  end;

  LogWriteSectionStart('putTransferWithoutDocStopPicking');

  mPreV_ID := '';
  mPreP_ID := '';

  dtJSONRows := TMemTable.Create(nil);
  dtDocumentQuantity := TMemTable.Create(nil);
  mJSON_Root := TJSONSuperObject.ParseString(ABody, True);
  try
    mRequestID := REST_getJSONStr(mJSON_Root, 'saveRequestID');
    // pred transakci overime, jestli uz tento request nebezi nebo neni dokonce dokonceny. Pokud ne, tak ho zalozime.
    case Request_Start(AOS, mRequestID, 'putTransferWithoutDocStopPicking') of
      1: begin
        SetPlainResponse(AResponse, getString('request_in_process'), HTTP_SC_ExpectationFailed);
        exit;
      end;
      2: begin
        SetResponse(AResponse, PlainResponse(''));
        exit;
      end;
    end;

    AOS.StartTransaction(taReadCommited);
    try
      mPreV := AOS.CreateObject(Class_OutgoingTransfer);
      try
        mTemporaryStorageID := REST_getJSONInt(mJSON_Root, 'tempID');
        mPreV.ExplicitTransaction := True;

        // dataset, do ktereho si preplnime polozky z JSONu
        DataSet_CreataHeader(dtJSONRows, 'jsonIndex=I,StoreDocument2_ID=S10,StoreDocument2Provide_ID=S10,StoreDocument2ProvideRow_ID=S10,' +
          'DocRowBatch_ID=S10,LogStoreDocument2_ID=S10,StoreFrom_ID=S10,StoreTo_ID=S10,StoreCard_ID=S10,StorePositionFrom_ID=S10,' +
          'StoreBatch_ID=S10,StorePositionTo_ID=S10,Processed=B,UnitQuantity=F,UnitRate=F,UnitCode=S10,Division_ID=S10,ContentUnit=S5');
        dtJSONRows.AddIndex('ByJsonIndex', 'jsonIndex', [ixUnique]);
        dtJSONRows.IndexName := 'ByJsonIndex';
        //dtJSONRows.AddIndex('ByStoreDocument2_ID', 'StoreDocument2_ID;jsonIndex', [ixUnique]);
        //dtJSONRows.AddIndex('BySD2_IDBatch_ID', 'StoreDocument2_ID;StoreBatch_ID;jsonIndex', [ixUnique]);
        dtJSONRows.Open;
        REST_JsonToDataSet(mJSON_Root.A['rows'], dtJSONRows);
        dtJSONRows.First;

        // dataset pro funkci Create_LogStoreDocument
        DataSet_CreataHeader(dtDocumentQuantity, 'Store_ID=S10,StoreCard_ID=S10,StoreBatch_ID=S10,StorePosition_ID=S10,Quantity=F,ContentUnit=S5');
        dtDocumentQuantity.AddIndex('I0', 'Store_ID;StoreCard_ID;StoreBatch_ID;StorePosition_ID;ContentUnit', [ixUnique]);
        dtDocumentQuantity.IndexName:= 'I0';
        dtDocumentQuantity.Open;

        // nejdriv vytvorime prevodku vydej
        mPreV.New;
        mPreV.Prefill;
        mPreV.SetFieldValueAsString('Firm_ID', FIRM_OWN);

        if EnterPerson(AOS, gSkladTermModule, gSkladTermDocType, gSkladTermUser_ID, mPersonField) then
          mPreV.SetFieldValueAsString(mPersonField, REST_getJSONStr(mJSON_Root, 'Person_ID'));

        if EnterDocQueue(AOS, gSkladTermModule, gSkladTermDocType, gSkladTermUser_ID) then
          mPreV.SetFieldValueAsString('DocQueue_ID', REST_getJSONStr(mJSON_Root, 'docQueue.id'))
        else
        begin
          mDocQueue_ID := GetDocQueue_ID(AOS, gSkladTermModule, gSkladTermDocType, gSkladTermUser_ID, mJSON_Root);
          mPreV.SetFieldValueAsString('DocQueue_ID', GetValueOrDefault(mDocQueue_ID, GetDefaultDocQueue_ID(gSkladTermDocType)));
        end;

        if EnterTransportationType(AOS, gSkladTermModule, gSkladTermDocType, gSkladTermUser_ID) then
          mPreV.SetFieldValueAsString('TransportationType_ID', REST_getJSONStr(mJSON_Root, 'TransportationType_ID'));

        if EnterFirmOffice(AOS, gSkladTermModule, gSkladTermDocType, gSkladTermUser_ID) then
          mPreV.SetFieldValueAsString('FirmOffice_ID', REST_getJSONStr(mJSON_Root, 'FirmOffice_ID'));

        // nastavim AuxText
        mAuxField := StoreDocumentAuxTextField(gSkladTermModule, mAuxReadOnly);
        if (mAuxField <> '') then
        begin
          mPreV.SetFieldValueAsString(mAuxField, mJSON_Root.S['AuxText']);
        end;

        SaveDialogValues(mPreV, mJSON_Root.O['Dialog'].A['values']);

        mRows := mPreV.GetCollectionMonikerForFieldCode(mPreV.GetFieldCode('Rows'));
        dtJSONRows.First;
        while not dtJSONRows.EOF do
        begin
          mRow := mRows.AddNewObject;
          mRow.Prefill;
          mRow.SetFieldValueAsString('Store_ID', dtJSONRows.FieldByName('StoreFrom_ID').AsString);
          mRow.SetFieldValueAsString('StoreCard_ID', dtJSONRows.FieldByName('StoreCard_ID').AsString);
          mRow.SetFieldValueAsString('QUnit', dtJSONRows.FieldByName('UnitCode').AsString);
          mRow.SetFieldValueAsFloat('UnitQuantity', dtJSONRows.FieldByName('UnitQuantity').AsFloat);
          // poznacime si ID radku PreV
          dtJSONRows.Edit;
          dtJSONRows.FieldByName('StoreDocument2_ID').AsString := mRow.OID;
          dtJSONRows.Post;

          if EnterBusOrder(AOS, gSkladTermModule, gSkladTermDocType, gSkladTermUser_ID) then
            mRow.SetFieldValueAsString('BusOrder_ID', REST_getJSONStr(mJSON_Root, 'busOrder.id'));

          mBusTransactionMandatory := False;
          if EnterBusTransaction(AOS, gSkladTermModule, gSkladTermDocType, gSkladTermUser_ID, mBusTransactionMandatory) then
            if REST_getJSONStr(mJSON_Root, 'busTransaction.id') <> '' then
              mRow.SetFieldValueAsString('BusTransaction_ID', REST_getJSONStr(mJSON_Root, 'busTransaction.id'));

          mBusProjectMandatory := False;
          if EnterBusProject(AOS, gSkladTermModule, gSkladTermDocType, gSkladTermUser_ID, mBusProjectMandatory) then
            if REST_getJSONStr(mJSON_Root, 'busProject.id') <> '' then
              mRow.SetFieldValueAsString('BusProject_ID', REST_getJSONStr(mJSON_Root, 'busProject.id'));

          if EnterDivision(AOS, gSkladTermModule, gSkladTermDocType, gSkladTermUser_ID) then
            mRow.SetFieldValueAsString('Division_ID', REST_getJSONStr(mJSON_Root, 'division.id'))
          else
            mRow.SetFieldValueAsString('Division_ID',
              GetValueOrDefault(GetDivision_ID(AOS, gSkladTermModule, gSkladTermDocType, gSkladTermUser_ID, mPreV), STREDISKO_HLAVNI));

          SaveDialogValues(mRow, mJSON_Root.A['rows'].O[dtJSONRows.FieldByName('jsonIndex').AsInteger].O['dialog'].A['values']);
          FillCustomFields(mRow, dtJSONRows, mJSON_Root);

          // pokud je zadana sarze, vyplnime ji
          if not CFxOID.IsEmpty(dtJSONRows.FieldByName('StoreBatch_ID').AsString) then
          begin
            mDocRowBatches := mRow.GetLoadedCollectionMonikerForFieldCode(mRow.GetFieldCode('DocRowBatches'));
            mDocRowBatch := mDocRowBatches.AddNewObject;
            mDocRowBatch.SetFieldValueAsString('StoreBatch_ID', dtJSONRows.FieldByName('StoreBatch_ID').AsString);
            mDocRowBatch.SetFieldValueAsFloat('UnitQuantity', dtJSONRows.FieldByName('UnitQuantity').AsFloat);
          end;

          // ser. cisla
          if (mRow.GetFieldValueAsInteger('StoreCard_ID.Category') = 1) then
            begin
              mDocRowBatches := mRow.GetLoadedCollectionMonikerForFieldCode(mRow.GetFieldCode('DocRowBatches'));
              // musime do jsonu pro kolekci sernums
              jsonSerNums := mJSON_Root.A['rows'].O[dtJSONRows.FieldByName('jsonIndex').AsInteger].A['sernums'];
              for i := 0 to jsonSerNums.Length - 1 do
              begin
                mDocRowBatch := mDocRowBatches.AddNewObject;

                // pokud neni vyplnene ID, tak ho muzim zjistit nebo cislo vytvorit
                if CFxOID.IsEmpty(jsonSerNums.O[i].S['SerNum_ID']) then
                begin
                  // dohledam existujici ser. cislo
                  mSerNum_ID := '';
                  if IsUsingExistingSerNumberAllowed then
                  begin
                    // zkusim sarzi ser. cislo
                    mSerNum_ID := SQLSelectStr(AOS, 'select ID from StoreBatches where Name = ' + QuotedStr(jsonSerNums.O[i].S['SerNumName'])
                      + ' and StoreCard_ID = ' + QuotedStr(mRow.GetFieldValueAsString('StoreCard_ID')) + 'and Hidden = ''N''');
                  end;

                  if mSerNum_ID <> '' then
                  begin
                    mDocRowBatch.SetFieldValueAsString('StoreBatch_ID', mSerNum_ID);
                    // ulozim si ser. cislo do JSONu, protoze ho budu potrebovat pri polohovani
                    jsonSerNums.O[i].S['SerNum_ID'] := mSerNum_ID;
                  end
                  else
                  begin
                    mStoreBatch_ID := CreateSerialNumber(AOS, mRow.GetFieldValueAsString('StoreCard_ID'), jsonSerNums.O[i].S['SerNumName'],
                      jsonSerNums.O[i].S['AuxText']);

                    // nenasel jsem, takze vytvarim nove
                    mDocRowBatch.SetFieldValueAsBoolean('NewBatch', False);
                    mDocRowBatch.SetFieldValueAsString('StoreBatch_ID', mStoreBatch_ID);
                    // ulozim si ser. cislo do JSONu, protoze ho budu potrebovat pri polohovani
                    jsonSerNums.O[i].S['SerNum_ID'] := mStoreBatch_ID;
                  end;
                end
                else
                begin
                  mDocRowBatch.SetFieldValueAsString('StoreBatch_ID', jsonSerNums.O[i].S['SerNum_ID']);
                end;
                mDocRowBatch.SetFieldValueAsString('QUnit', mRow.GetFieldValueAsString('QUnit'));
                mDocRowBatch.SetFieldValueAsFloat('UnitQuantity', 1);
              end;
            end;

          putWithoutDocStopPicking_beforeRowSave(gSkladTermModule, AOS, mRow, dtJSONRows, mJSON_Root);
          dtJSONRows.Next;
        end;

        beforeSaveHook(AOS, gSkladTermModule, gSkladTermDocType, gSkladTermUser_ID, mPreV, 0, mJSON_Root, dtJSONRows);

        mPreV_ID := mPreV.OID;
        mPreV.Save;

        afterSaveHook(AOS, gSkladTermModule, gSkladTermDocType, gSkladTermUser_ID, mPreV, 0, mJSON_Root, dtJSONRows);

        // naplnime pomocny dataset pro vytvoreni polohovaku k PreVyd
        dtDocumentQuantity.EmptyTable;
        dtJSONRows.First;
        while not dtJSONRows.EOF do
        begin
          if not CFxOID.IsEmpty(dtJSONRows.FieldByName('StorePositionFrom_ID').AsString) then
          begin
            jsonSerNums := mJSON_Root.A['rows'].O[dtJSONRows.FieldByName('jsonIndex').AsInteger].A['sernums'];

            // Pokud ma radek seriova cisla, tak ho musim rozpadnout po nich
            if jsonSerNums.Length > 0 then
            begin
              for i := 0 to jsonSerNums.Length - 1 do
                AddTodtDocumentQuantity(dtDocumentQuantity,
                  dtJSONRows.FieldByName('StoreFrom_ID').AsString,
                  dtJSONRows.FieldByName('StoreCard_ID').AsString,
                  jsonSerNums.O[i].S['SerNum_ID'],
                  dtJSONRows.FieldByName('StorePositionFrom_ID').AsString,
                  1,
                  dtJSONRows.FieldByName('UnitRate').AsFloat,
                  dtJSONRows.FieldByName('ContentUnit').AsString
                );
            end
            else
              AddTodtDocumentQuantity(dtDocumentQuantity,
                dtJSONRows.FieldByName('StoreFrom_ID').AsString,
                dtJSONRows.FieldByName('StoreCard_ID').AsString,
                NxIIfStr(CFxOID.IsEmpty(dtJSONRows.FieldByName('StoreBatch_ID').AsString), 'ZZZZZZZZZZ', dtJSONRows.FieldByName('StoreBatch_ID').AsString),
                dtJSONRows.FieldByName('StorePositionFrom_ID').AsString,
                dtJSONRows.FieldByName('UnitQuantity').AsFloat,
                dtJSONRows.FieldByName('UnitRate').AsFloat,
                dtJSONRows.FieldByName('ContentUnit').AsString
              );
          end;
          dtJSONRows.Next;
        end;

        // vytvorime polohovak k PreVyd
        if dtDocumentQuantity.RecordCount > 0 then
          if CreateLogStoreDocument(AOS, gSkladTermModule, gSkladTermDocType, gSkladTermUser_ID, '', mPreV, mJSON_Root, dtJSONRows, dtDocumentQuantity) then
          begin
            mDocQueue_ID := GetDocQueue_ID(AOS, gSkladTermModule, DOC_LogStoreOutput, gSkladTermUser_ID, mJSON_Root, gSkladTermDocType, mPreV);
            mLSDOut_ID := REST_Create_LogStoreDocument(AOS, mPreV, '',
              Class_LogStoreOutput,
              GetValueOrDefault(mDocQueue_ID, GetDefaultDocQueue_ID(DOC_LogStoreOutput)),
              LogStoreOutput_StoreGateway_ID, dtDocumentQuantity, gSkladTermUser_ID,
              False);
          end;

        if mJSON_Root.B['CreateTransferIn'] then
        begin
          // pak z ni importnim manazerem vytvorime prevodku prijem
          NxSleep(1000);  // pockam, aby nemela stejny cas jako prevodka vydej
          mParams := TNxParameters.Create;
          mDIM := NxCreateDocumentImportManager(AOS, Class_OutgoingTransfer, Class_IncomingTransfer);
          try
            mDIM.AddInputDocument(mPreV.OID);
            mDIM.SelectedHeader := mPreV;
            mDIM.SaveParams(mParams);
            // tento sklad je jen pomocny, sklad v polozkach se nasledne prepise podle JSONu
            mParams.GetOrCreateParam(dtString, 'Store_ID').AsString := SKLAD_HLAVNI;

            mDocQueue_ID := GetDocQueue_ID(AOS, gSkladTermModule, DOC_IncomingTransfer, gSkladTermUser_ID, mJSON_Root, gSkladTermDocType, mPreV);
            mParams.GetOrCreateParam(dtString, 'DocQueue_ID').AsString :=
              GetValueOrDefault(mDocQueue_ID, GetDefaultDocQueue_ID(DOC_IncomingTransfer));

            mDIM.LoadParams(mParams);
            mDIM.Execute;
            mPreP := mDIM.OutputDocument;
            mPreP_ID := mPreP.OID;
            mPreP.ExplicitTransaction := True;
            // na polozkach PrePri musime prenastavit sklad
            mRows := mPreP.GetLoadedCollectionMonikerForFieldCode(mPreP.GetFieldCode('Rows'));
            for i := 0 to mRows.Count - 1 do
            begin
              mRow := mRows.BusinessObject[i];
              dtJSONRows.First;
              while not dtJSONRows.EOF do
              begin
                if (dtJSONRows.FieldByName('StoreDocument2_ID').AsString = mRow.GetFieldValueAsString('ProvideRow_ID')) then
                begin
                  mRow.SetFieldValueAsString('Store_ID', dtJSONRows.FieldByName('StoreTo_ID').AsString);
                  break;
                end;
                dtJSONRows.Next;
              end;
            end;

            mPreP.Save;

            // naplnime pomocny dataset pro vytvoreni polohovaku k PrePri
            dtDocumentQuantity.EmptyTable;
            dtJSONRows.First;
            while not dtJSONRows.EOF do
            begin
              if not CFxOID.IsEmpty(dtJSONRows.FieldByName('StorePositionTo_ID').AsString) then
              begin
                AddTodtDocumentQuantity(dtDocumentQuantity,
                  dtJSONRows.FieldByName('StoreTo_ID').AsString,
                  dtJSONRows.FieldByName('StoreCard_ID').AsString,
                  NxIIfStr(CFxOID.IsEmpty(dtJSONRows.FieldByName('StoreBatch_ID').AsString), 'ZZZZZZZZZZ', dtJSONRows.FieldByName('StoreBatch_ID').AsString),
                  dtJSONRows.FieldByName('StorePositionTo_ID').AsString,
                  dtJSONRows.FieldByName('UnitQuantity').AsFloat,
                  dtJSONRows.FieldByName('UnitRate').AsFloat,
                  dtJSONRows.FieldByName('ContentUnit').AsString
                );
              end;
              dtJSONRows.Next;
            end;

            // vytvorime polohovak k PrePri
            if dtDocumentQuantity.RecordCount > 0 then
            begin
              mDocQueue_ID := GetDocQueue_ID(AOS, gSkladTermModule, DOC_LogStoreInput, gSkladTermUser_ID, mJSON_Root, DOC_IncomingTransfer, mPreP);
              mLSDIn_ID := REST_Create_LogStoreDocument(AOS, mPreP, '',
                Class_LogStoreInput,
                GetValueOrDefault(mDocQueue_ID, GetDefaultDocQueue_ID(DOC_LogStoreInput)),
                LogStoreInput_StoreGateway_ID, dtDocumentQuantity, gSkladTermUser_ID,
                False);
            end;
          finally
            mDIM.Free;
            mParams.free;
          end;
        end;
      finally
        mPreV.Free;
      end;

      // zmeny stavu
      // zmena PRV, pokud se ma menit
      if not CFxOID.IsEmpty(mPreV_ID)
       and not CFxOID.IsEmpty(PRECHOD_VYTVORENI(DOC_OutgoingTransfer, gSkladTermModule)) then
      begin
        mPreV := AOS.CreateObject(Class_OutgoingTransfer);
        try
          mPreV.ExplicitTransaction := True;
          mPreV.Load(mPreV_ID, nil);

          if putQueueDocDetailStopPicking_changeSDStatus(AOS, gSkladTermModule, DOC_OutgoingTransfer, gSkladTermUser_ID, mPreP_ID, 0, mPreV, mPreP) then
          begin
            LogWriteEvent(Format('Changing status. DocumentType: %s, ID: %s, Rule: %s',
              [DOC_OutgoingTransfer, mPreV.OID, PRECHOD_VYTVORENI(DOC_OutgoingTransfer, gSkladTermModule)]));
            ChangeStatusByRule(mPreV, PRECHOD_VYTVORENI(DOC_OutgoingTransfer, gSkladTermModule));
          end;
        finally
          mPreV.Free;
        end;
      end;

      // zmena PRP, pokud se ma menit
      if not CFxOID.IsEmpty(mPreP_ID)
       and not CFxOID.IsEmpty(PRECHOD_VYTVORENI(DOC_IncomingTransfer, gSkladTermModule)) then
      begin
        mPreP := AOS.CreateObject(Class_IncomingTransfer);
        try
          mPreP.ExplicitTransaction := True;
          mPreP.Load(mPreP_ID, nil);

          if putQueueDocDetailStopPicking_changeSDStatus(AOS, gSkladTermModule, DOC_IncomingTransfer, gSkladTermUser_ID, mPreP_ID, 1, mPreV, mPreP) then
          begin
            LogWriteEvent(Format('Changing status. DocumentType: %s, ID: %s, Rule: %s',
              [DOC_IncomingTransfer, mPreP.OID, PRECHOD_VYTVORENI(DOC_IncomingTransfer, gSkladTermModule)]));
            ChangeStatusByRule(mPreP, PRECHOD_VYTVORENI(DOC_IncomingTransfer, gSkladTermModule));
          end;
        finally
          mPreP.Free;
        end;
      end;

      // vymaz z TemporaryStorage jeste v transakci
      TemporaryStorage_Finish(AOS, mTemporaryStorageID);

      Request_Finish(AOS, mRequestID);

      AOS.Commit;

      SetResponse(AResponse, PlainResponse(''));
    except
      AOS.RollBack;
      SetPlainResponse(AResponse, getString('error_saving_free_transfer') + ExceptionMessage, HTTP_SC_InternalServerError);
      Request_Cancel(AOS, mRequestID);
      LogWriteSectionEnd;
      exit;
    end;
  finally
    mJSON_Root.Free;
    dtJSONRows.Free;
    dtDocumentQuantity.Free;
  end;
  LogWriteSectionEnd;

  // polohovaky potvrdime az mimo hlavni transakci
  if MakeExecuteLogStoreDocument(AOS, gSkladTermModule, DOC_LogStoreOutput, gSkladTermUser_ID, mLSDOut_ID) then
    ConfirmLSD(AOS, Class_LogStoreOutput, mLSDOut_ID, 'putTransferWithoutDocStopPicking');
  if MakeExecuteLogStoreDocument(AOS, gSkladTermModule, DOC_LogStoreInput, gSkladTermUser_ID, mLSDIn_ID) then
    ConfirmLSD(AOS, Class_LogStoreInput, mLSDIn_ID, 'putTransferWithoutDocStopPicking');
end;

procedure putWithoutDocStartPicking(AOS: TNxCustomObjectSpace; AResponse: TStringList);
var
  mSql, mAuxField: String;
  json, dialogJSON: TJSONSuperObject;
  mTempId: Integer;
  dtHeader, mDialogValues: TMemTable;
  mSL: TStringList;
  mAuxReadOnly: Boolean;
begin
  json := nil;

  LogWriteSectionStart('putWithoutDocStartPicking');
  try
    AOS.StartTransaction(taReadCommited);
    try
      dtHeader := TMemTable.Create(nil);
      mDialogValues := TMemTable.Create(nil);
      mSL := TStringList.Create;
      try
        mSql := 'select' + nxCrLf;

        mAuxField := StoreDocumentAuxTextField(gSkladTermModule, mAuxReadOnly);
        if mAuxField <> '' then
        begin
          mSql := mSql +
            '  ' + QuotedStr('') + ' as "AuxText",' + nxCrLf +
            '  ' + QuotedStr(NxBoolToStr(mAuxReadOnly)) + ' as "AuxReadOnly$BOOL",' + nxCrLf;
        end;

        mSql := mSql +
          GetSQLDocHeaderParameters(AOS, gSkladTermDocType, gSkladTermModule, gSkladTermUser_ID, '') +
          FROM_1_RECORD;

        AOS.SQLSelect2(mSql, dtHeader);
        json := REST_jsonCreate_FromDataSetRow(dtHeader, nil, mSL);

        // dialog
        DataSet_CreataHeader(mDialogValues, REST_DialogValuesDatasetHeader);
        mDialogValues.Open;
        dialogJSON := json.CreateJSON;
        dialogJSON.S['text'] := DialogOnDocSave(AOS, gSkladTermDocType, gSkladTermModule, gSkladTermUser_ID, '', mDialogValues);
        dialogJSON.O['values'] := REST_jsonCreate_FromDataSet(mDialogValues, nil);
        json.O['Dialog'] := dialogJSON;

        // rovnou ulozime do TemporaryStorage
        mTempId := TemporaryStorage_Create(AOS, gSkladTermModule, gSkladTermUser_ID, '');
        TemporaryStorage_Update(AOS, mTempId, json.AsJson(false, true));
        json.I['tempID'] := mTempId;

        SetResponse(AResponse, json.AsJson(false, true));

        AOS.Commit;
      finally
        dtHeader.Free;
        mSL.Free;
        mDialogValues.Free;
      end;
    except
      AOS.RollBack;
      SetPlainResponse(AResponse, ExceptionMessage, HTTP_SC_ExpectationFailed);
    end;
  finally
    LogWriteSectionEnd;
  end;
end;
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
// Obsluhuje prijem a vydej
////////////////////////////////////////////////////////////////////////////////
procedure putWithoutDocStopPicking(AOS: TNxCustomObjectSpace; APath: TStringList; ABody: String; AResponse: TStringList);
var
  mJSON_Root: TJSONSuperObject;
  mSD, mSDRow: TNxCustomBusinessObject;
  mRows: TNxCustomBusinessMonikerCollection;
  i: Integer;
  mTemporaryStorageID: Integer;
  jsonCustomFields: TJSONSuperObjectArray;
  dtJSONRows, dtDocumentQuantity: TMemTable;
  mLSD_ID, mLogStoreDocumentClass, mLogStoreDocument_DocQueue_ID, mLogStoreDocument_StoreGateway_ID, mStoreBatchExpirationField,
    mStoreField, mStorePositionField, mStoreDocumentClass, mRequestID, mDocQueue_ID, mAuxField, mSDNew_ID,
    mPersonField, mLogStoreDocumentDocType, mSD_ID, mStoreCardField, mStoreBatchField, mStoreCardCategoryField,
    mSerialNumbersField, mStoreDocumentNewClass, mSDNewDocType, mLSDNew_ID: String;
  mAuxReadOnly: Boolean;

  procedure fillClassAndIdVariables;
  begin
    mStoreCardField := 'StoreCard_ID';
    mStoreBatchField := 'StoreBatch_ID';
    mStoreCardCategoryField := 'StoreCardCategory';
    mSerialNumbersField := 'sernums';
    if gSkladTermDocType = DOC_ReceiptCard then
    begin
      mStoreDocumentClass := Class_ReceiptCard;
      mLogStoreDocumentClass := Class_LogStoreInput;
      mLogStoreDocumentDocType := DOC_LogStoreInput;
      mLogStoreDocument_DocQueue_ID := LogStoreInput_DocQueue_ID;
      mLogStoreDocument_StoreGateway_ID := LogStoreInput_StoreGateway_ID;
      mDocQueue_ID := RADA_PRIJEMKA;
      mStoreField := 'StoreFrom_ID';
      mStorePositionField := 'StorePositionFrom_ID';
    end
    else if gSkladTermDocType = DOC_ReceivedOrder then
    begin
      // u OBP staci nastavit jen tridu, radu a pole se skladem
      mStoreDocumentClass := Class_ReceivedOrder;
      mDocQueue_ID := RADA_OBP;
      mStoreField := 'StoreFrom_ID';
    end
    else if gSkladTermDocType = DOC_OutgoingTransformation then
    begin
      mStoreDocumentClass := Class_OutgoingTransformation;
      mStoreDocumentNewClass := Class_IncomingTransformation;
      mSDNewDocType := DOC_IncomingTransformation;
      mLogStoreDocumentClass := Class_LogStoreOutput;
      mLogStoreDocumentDocType := DOC_LogStoreOutput;
      mLogStoreDocument_DocQueue_ID := LogStoreOutput_DocQueue_ID;
      mLogStoreDocument_StoreGateway_ID := LogStoreOutput_StoreGateway_ID;
      mDocQueue_ID := RADA_OutgoingTransformation;
      mStoreField := 'StoreFrom_ID';
      mStorePositionField := 'StorePositionFrom_ID';
    end
    else if gSkladTermDocType = DOC_OutgoingSubstitution then
    begin
      mStoreDocumentClass := Class_OutgoingSubstitution;
      mStoreDocumentNewClass := Class_IncomingSubstitution;
      mSDNewDocType := DOC_IncomingSubstitution;
      mLogStoreDocumentClass := Class_LogStoreOutput;
      mLogStoreDocumentDocType := DOC_LogStoreOutput;
      mLogStoreDocument_DocQueue_ID := LogStoreOutput_DocQueue_ID;
      mLogStoreDocument_StoreGateway_ID := LogStoreOutput_StoreGateway_ID;
      mDocQueue_ID := RADA_OutgoingSubstitution;
      mStoreField := 'StoreFrom_ID';
      mStorePositionField := 'StorePositionFrom_ID';
    end
    else
    begin
      mStoreDocumentClass := Class_BillOfDelivery;
      mLogStoreDocumentClass := Class_LogStoreOutput;
      mLogStoreDocumentDocType := DOC_LogStoreOutput;
      mLogStoreDocument_DocQueue_ID := LogStoreOutput_DocQueue_ID;
      mLogStoreDocument_StoreGateway_ID := LogStoreOutput_StoreGateway_ID;
      mDocQueue_ID := RADA_VYDEJKA;
      mStoreField := 'StoreFrom_ID';
      mStorePositionField := 'StorePositionFrom_ID';
    end;
  end;

  function AddRow(ARows: TNxCustomBusinessMonikerCollection): TNxCustomBusinessObject;
  var
    mRow: TNxCustomBusinessObject;
    mBusTransactionMandatory, mBusProjectMandatory: Boolean;
  begin
    LogWriteSectionStart('AddRow');
    try
      mRow := ARows.AddNewObject;
      mRow.Prefill;
      mRow.SetFieldValueAsInteger('RowType', 3);
      mRow.SetFieldValueAsString('Store_ID', dtJSONRows.FieldByName(mStoreField).AsString);
      mRow.SetFieldValueAsString('StoreCard_ID', dtJSONRows.FieldByName(mStoreCardField).AsString);
      mRow.SetFieldValueAsString('QUnit', dtJSONRows.FieldByName('UnitCode').AsString);
      mRow.SetFieldValueAsFloat('UnitQuantity', dtJSONRows.FieldByName('UnitQuantity').AsFloat);

      if EnterBusOrder(AOS, gSkladTermModule, gSkladTermDocType, gSkladTermUser_ID) then
        mRow.SetFieldValueAsString('BusOrder_ID', REST_getJSONStr(mJSON_Root, 'busOrder.id'));

      if EnterBusTransaction(AOS, gSkladTermModule, gSkladTermDocType, gSkladTermUser_ID, mBusTransactionMandatory) then
        if REST_getJSONStr(mJSON_Root, 'busTransaction.id') <> '' then
          mRow.SetFieldValueAsString('BusTransaction_ID', REST_getJSONStr(mJSON_Root, 'busTransaction.id'));

      if EnterBusProject(AOS, gSkladTermModule, gSkladTermDocType, gSkladTermUser_ID, mBusProjectMandatory) then
        if REST_getJSONStr(mJSON_Root, 'busProject.id') <> '' then
          mRow.SetFieldValueAsString('BusProject_ID', REST_getJSONStr(mJSON_Root, 'busProject.id'));

      if EnterDivision(AOS, gSkladTermModule, gSkladTermDocType, gSkladTermUser_ID) then
        mRow.SetFieldValueAsString('Division_ID', REST_getJSONStr(mJSON_Root, 'division.id'))
      else
        mRow.SetFieldValueAsString('Division_ID',
          GetValueOrDefault(GetDivision_ID(AOS, gSkladTermModule, gSkladTermDocType, gSkladTermUser_ID, mSD), STREDISKO_HLAVNI));

      SaveDialogValues(mRow, mJSON_Root.A['rows'].O[dtJSONRows.FieldByName('jsonIndex').AsInteger].O['dialog'].A['values']);
      FillCustomFields(mRow, dtJSONRows, mJSON_Root);

      dtJSONRows.Edit;
      dtJSONRows.FieldByName('StoreDocument2_ID').AsString := mRow.OID;
      dtJSONRows.Post;

      Result := mRow;
    finally
      LogWriteSectionEnd;
    end;
  end;

  procedure FillStoreBatches(ASD, ARow: TNxCustomBusinessObject);
  var
    mDocRowBatches: TNxCustomBusinessMonikerCollection;
    mStoreBatch, mDocRowBatch: TNxCustomBusinessObject;
    mStoreBatch_ID, mStoreBatchNoteField: String;
  begin
    if (ARow.GetFieldValueAsInteger('StoreCard_ID.Category') = 2)
        and (dtJSONRows.FieldByName(mStoreCardCategoryField).AsInteger = 2) then
    begin
      mDocRowBatches := ARow.GetLoadedCollectionMonikerForFieldCode(ARow.GetFieldCode('DocRowBatches'));

      // pokud mame ID, tak pridame k radku
      if not CFxOID.IsEmpty(dtJSONRows.FieldByName(mStoreBatchField).AsString) then
      begin
        mDocRowBatch := mDocRowBatches.AddNewObject;
        mDocRowBatch.SetFieldValueAsString('StoreBatch_ID', dtJSONRows.FieldByName(mStoreBatchField).AsString);
        mDocRowBatch.SetFieldValueAsString('QUnit', dtJSONRows.FieldByName('UnitCode').AsString);
        mDocRowBatch.SetFieldValueAsFloat('UnitQuantity', dtJSONRows.FieldByName('UnitQuantity').AsFloat);

        if dtJSONRows.FieldByName('EnterStoreBatchExpirationDate').AsBoolean
          or (dtJSONRows.FieldByName('StoreBatchNoteVisibility').AsString in ['2', '3']) then
        begin
          mStoreBatch := AOS.CreateObject(Class_StoreBatch);
          try
            mStoreBatch.Load(mDocRowBatch.GetFieldValueAsString('StoreBatch_ID'), nil);
            mStoreBatch.ExplicitTransaction := True;

            if dtJSONRows.FieldByName('EnterStoreBatchExpirationDate').AsBoolean
              and (dtJSONRows.FieldByName('StoreBatchExpirationDate').AsString <> '') then
            begin
              if CompareDateTime(CFxDateTime.ISO8601ToDateTime(dtJSONRows.FieldByName('StoreBatchExpirationDate').AsString), EncodeDate(1900, 1, 1))
                > 0 then
              begin
                mStoreBatchExpirationField := 'ExpirationDate$DATE';
                EnterStoreBatchExpirationDate(AOS, gSkladTermModule, gSkladTermDocType, gSkladTermUser_ID, 0, mStoreBatchExpirationField);

                mStoreBatch.SetFieldValueAsDateTime(mStoreBatchExpirationField,
                  CFxDateTime.ISO8601ToDateTime(dtJSONRows.FieldByName('StoreBatchExpirationDate').AsString));
              end;
            end;

            if dtJSONRows.FieldByName('StoreBatchNoteVisibility').AsString in ['2', '3'] then
            begin
              mStoreBatchNoteField := '';
              StoreBatchNoteVisibility(AOS, gSkladTermModule, gSkladTermDocType, gSkladTermUser_ID, '', mStoreBatchNoteField);

              mStoreBatch.SetFieldValueAsString(mStoreBatchNoteField, dtJSONRows.FieldByName('StoreBatchNote').AsString);
            end;

            mStoreBatch.Save;
          finally
            mStoreBatch.Free;
          end;
        end;

        afterDocRowBatchFill(AOS, gSkladTermModule, mDocRowBatch, ARow, ASD, dtJSONRows);
      end
      else // pokud ID NEmame, tak sarzi vytvorim (v tomhle pripade by mela karta mit nastavenou strukturu novych sarzi)
      begin
        // vytvorim sarzi
        mStoreBatch := AOS.CreateObject(Class_StoreBatch);
        try
          mStoreBatch.New;
          mStoreBatch.Prefill;
          mStoreBatch.SetFieldValueAsString('StoreCard_ID', dtJSONRows.FieldByName(mStoreCardField).AsString);

          if dtJSONRows.FieldByName('EnterStoreBatchExpirationDate').AsBoolean
            and (dtJSONRows.FieldByName('StoreBatchExpirationDate').AsString <> '') then
          begin
            if CompareDateTime(CFxDateTime.ISO8601ToDateTime(dtJSONRows.FieldByName('StoreBatchExpirationDate').AsString), EncodeDate(1900, 1, 1))
              > 0 then
            begin
              mStoreBatchExpirationField := 'ExpirationDate$DATE';
              EnterStoreBatchExpirationDate(AOS, gSkladTermModule, gSkladTermDocType, gSkladTermUser_ID, 0, mStoreBatchExpirationField);

              mStoreBatch.SetFieldValueAsDateTime(mStoreBatchExpirationField,
                CFxDateTime.ISO8601ToDateTime(dtJSONRows.FieldByName('StoreBatchExpirationDate').AsString));
            end;
          end;

          mStoreBatch.Save;
          mStoreBatch_ID := mStoreBatch.OID;
        finally
          mStoreBatch.Free;
        end;
        mDocRowBatch := mDocRowBatches.AddNewObject;
        mDocRowBatch.SetFieldValueAsString('StoreBatch_ID', mStoreBatch_ID);
        mDocRowBatch.SetFieldValueAsString('QUnit', dtJSONRows.FieldByName('UnitCode').AsString);
        mDocRowBatch.SetFieldValueAsFloat('UnitQuantity', dtJSONRows.FieldByName('UnitQuantity').AsFloat);

        // do datasetu ulozim ID nove sarze, abych mohl polohovat
        dtJSONRows.Edit;
        dtJSONRows.FieldByName(mStoreBatchField).AsString := mStoreBatch_ID;
        dtJSONRows.Post;
      end;

      if dtJSONRows.FieldByName('StoreBatchNoteVisibility').AsString in ['2', '3'] then
      begin
        mStoreBatch := AOS.CreateObject(Class_StoreBatch);
        try
          mStoreBatch.Load(mDocRowBatch.GetFieldValueAsString('StoreBatch_ID'), nil);
          mStoreBatch.ExplicitTransaction := True;

          mStoreBatchNoteField := '';
          StoreBatchNoteVisibility(AOS, gSkladTermModule, gSkladTermDocType, gSkladTermUser_ID, '', mStoreBatchNoteField);
          mStoreBatch.SetFieldValueAsString(mStoreBatchNoteField, dtJSONRows.FieldByName('StoreBatchNote').AsString);

          mStoreBatch.Save;
        finally
          mStoreBatch.Free;
        end;
      end;
    end;
  end;

  procedure FillSerialNumbers(ARow: TNxCustomBusinessObject);
  var
    mDocRowBatches: TNxCustomBusinessMonikerCollection;
    mDocRowBatch: TNxCustomBusinessObject;
    mSerNum_ID, mStoreBatch_ID: String;
    jsonSerNums: TJSONSuperObjectArray;
  begin
    if (ARow.GetFieldValueAsInteger('StoreCard_ID.Category') = 1) then
    begin
      mDocRowBatches := ARow.GetLoadedCollectionMonikerForFieldCode(ARow.GetFieldCode('DocRowBatches'));
      // musime do jsonu pro kolekci sernums
      jsonSerNums := mJSON_Root.A['rows'].O[dtJSONRows.FieldByName('jsonIndex').AsInteger].A[mSerialNumbersField];
      for i := 0 to jsonSerNums.Length - 1 do
      begin
        mDocRowBatch := mDocRowBatches.AddNewObject;

        // pokud neni vyplnene ID, tak ho muzim zjistit nebo cislo vytvorit
        if CFxOID.IsEmpty(jsonSerNums.O[i].S['SerNum_ID']) then
        begin
          // dohledam existujici ser. cislo
          mSerNum_ID := '';
          if IsUsingExistingSerNumberAllowed then
          begin
            // zkusim sarzi ser. cislo
            mSerNum_ID := SQLSelectStr(AOS, 'select ID from StoreBatches where Name = ' + QuotedStr(jsonSerNums.O[i].S['SerNumName'])
              + ' and StoreCard_ID = ' + QuotedStr(ARow.GetFieldValueAsString('StoreCard_ID')) + 'and Hidden = ''N''');
          end;

          if mSerNum_ID <> '' then
          begin
            mDocRowBatch.SetFieldValueAsString('StoreBatch_ID', mSerNum_ID);
            // ulozim si ser. cislo do JSONu, protoze ho budu potrebovat pri polohovani
            jsonSerNums.O[i].S['SerNum_ID'] := mSerNum_ID;
          end
          else
          begin
            mStoreBatch_ID := CreateSerialNumber(AOS, ARow.GetFieldValueAsString('StoreCard_ID'), jsonSerNums.O[i].S['SerNumName'],
              jsonSerNums.O[i].S['AuxText']);

            // nenasel jsem, takze vytvarim nove
            mDocRowBatch.SetFieldValueAsBoolean('NewBatch', False);
            mDocRowBatch.SetFieldValueAsString('StoreBatch_ID', mStoreBatch_ID);
            // ulozim si ser. cislo do JSONu, protoze ho budu potrebovat pri polohovani
            jsonSerNums.O[i].S['SerNum_ID'] := mStoreBatch_ID;
          end;
        end
        else
        begin
          mDocRowBatch.SetFieldValueAsString('StoreBatch_ID', jsonSerNums.O[i].S['SerNum_ID']);
        end;
        mDocRowBatch.SetFieldValueAsString('QUnit', ARow.GetFieldValueAsString('QUnit'));
        mDocRowBatch.SetFieldValueAsFloat('UnitQuantity', 1);
      end;
    end;
  end;

  function CreateOutputDocument: String;
  var
    mParams: TNxParameters;
    mDIM: TNxDocumentImportManager;
    mSDNew: TNxCustomBusinessObject;
    mRows: TNxCustomBusinessMonikerCollection;
    mOutputDocumentType, mRowFilter: String;
  begin
    NxSleep(1000);
    mParams := TNxParameters.Create;
    mDIM := NxCreateDocumentImportManager(AOS, mStoreDocumentClass, mStoreDocumentNewClass);
    try
      mDIM.AddInputDocument(mSD.OID);
      mDIM.SelectedHeader := mSD;
      mDIM.SaveParams(mParams);
      // tento sklad je jen pomocny, sklad v polozkach se nasledne prepise podle JSONu
      mParams.GetOrCreateParam(dtString, 'Store_ID').AsString := SKLAD_HLAVNI;

      mDocQueue_ID := GetDocQueue_ID(AOS, gSkladTermModule, mSDNewDocType, gSkladTermUser_ID, mJSON_Root, gSkladTermDocType, mSD);
      mParams.GetOrCreateParam(dtString, 'DocQueue_ID').AsString :=
        GetValueOrDefault(mDocQueue_ID, GetDefaultDocQueue_ID(mSDNewDocType));

      mDIM.LoadParams(mParams);
      mDIM.Execute;
      mSDNew := mDIM.OutputDocument;
      Result := mSDNew.OID;
      mSDNew.ExplicitTransaction := True;

      mRows := mSDNew.GetLoadedCollectionMonikerForFieldCode(mSDNew.GetFieldCode('Rows'));

      if gSkladTermDocType = DOC_OutgoingTransformation then
      begin
        mOutputDocumentType := DOC_IncomingTransformation;
        mRowFilter := 'rowType=1';
        ProcessIncomingTransformationRows(mSDNew, mRows);
      end
      else if gSkladTermDocType = DOC_OutgoingSubstitution then
      begin
        mOutputDocumentType := DOC_IncomingSubstitution;
        ProcessIncomingSubstitutionRows(mSDNew, mRows);
        mRowFilter := '';
      end;

      beforeSaveHook(AOS, gSkladTermModule, gSkladTermDocType, gSkladTermUser_ID, mSDNew, 1, mJSON_Root, dtJSONRows);
      mSDNew.Save;
      afterSaveHook(AOS, gSkladTermModule, gSkladTermDocType, gSkladTermUser_ID, mSDNew, 1, mJSON_Root, dtJSONRows);

      FillLogStoreDocumentDataset(dtJSONRows, dtDocumentQuantity, mJSON_Root, mRowFilter, mStoreField, mStorePositionField, mStoreCardField,
        mStoreBatchField, mSerialNumbersField);

      // vytvorime polohovak
      if dtDocumentQuantity.RecordCount > 0 then
        if CreateLogStoreDocument(AOS, gSkladTermModule, mOutputDocumentType, gSkladTermUser_ID, '', mSDNew, mJSON_Root, dtJSONRows, dtDocumentQuantity) then
        begin
          mDocQueue_ID := GetDocQueue_ID(AOS, gSkladTermModule, DOC_LogStoreInput, gSkladTermUser_ID, mJSON_Root, mOutputDocumentType, mSDNew);
          mLSDNew_ID := REST_Create_LogStoreDocument(AOS, mSDNew, '',
            Class_LogStoreInput,
            GetValueOrDefault(mDocQueue_ID, GetDefaultDocQueue_ID(DOC_LogStoreInput)),
            mLogStoreDocument_StoreGateway_ID, dtDocumentQuantity, gSkladTermUser_ID,
            False);
        end;
    finally
      mParams.Free;
      mDIM.Free;
    end;
  end;

  procedure ProcessIncomingTransformationRows(ASD: TNxCustomBusinessObject; ARows: TNxCustomBusinessMonikerCollection);
  var
    mRow: TNxCustomBusinessObject;
  begin
    dtJSONRows.First;
    while not dtJSONRows.EOF do
    begin
      if dtJSONRows.FieldByName('rowType').AsInteger = 1 then
      begin
        mRow := AddRow(ARows);
        FillStoreBatches(ASD, mRow);
        FillSerialNumbers(mRow);
      end;
      dtJSONRows.Next;
    end;
  end;

  procedure ProcessIncomingSubstitutionRows(ASD: TNxCustomBusinessObject; ARows: TNxCustomBusinessMonikerCollection);
  var
    mRow: TNxCustomBusinessObject;
    mRows: TNxCustomBusinessMonikerCollection;
  begin
    mStoreField := 'StoreTo_ID';
    mStorePositionField := 'StorePositionTo_ID';
    mStoreCardField := 'storeCardNew_ID';
    mStoreBatchField := 'storeBatchNew_ID';
    mSerialNumbersField := 'sernumsNew';

    mRows := ASD.GetLoadedCollectionMonikerForFieldCode(ASD.GetFieldCode('Rows'));
    for i := 0 to mRows.Count - 1 do
    begin
      mRow := ARows.BusinessObject(i);
      dtJSONRows.First;
      while not dtJSONRows.EOF do
      begin
        if (dtJSONRows.FieldByName('StoreDocument2_ID').AsString = mRow.GetFieldValueAsString('ProvideRow_ID')) then
        begin
          mRow.SetFieldValueAsString('Store_ID', dtJSONRows.FieldByName(mStoreField).AsString);
          mRow.SetFieldValueAsString('StoreCard_ID', dtJSONRows.FieldByName(mStoreCardField).AsString);
          mRow.SetFieldValueAsString('QUnit', dtJSONRows.FieldByName('unitCodeNew').AsString);
          mRow.SetFieldValueAsFloat('UnitQuantity', dtJSONRows.FieldByName('UnitQuantity').AsFloat);
          FillStoreBatches(ASD, mRow);
          FillSerialNumbers(mRow);
          break;
        end;
        dtJSONRows.Next;
      end;
    end;
  end;
begin
  if (APath.Count <> 1) then
  begin
    SetPlainResponse(AResponse, getString('wrong_parameters_count'), HTTP_SC_BadRequest);
    exit;
  end;

  fillClassAndIdVariables;

  mSD_ID := '';
  mSDNew_ID := '';

  dtJSONRows := TMemTable.Create(nil);
  dtDocumentQuantity := TMemTable.Create(nil);
  mJSON_Root := TJSONSuperObject.ParseString(ABody, True);
  LogWriteSectionStart('putWithoutDocStopPicking');
  try
    mRequestID := REST_getJSONStr(mJSON_Root, 'saveRequestID');
    // pred transakci overime, jestli uz tento request nebezi nebo neni dokonce dokonceny. Pokud ne, tak ho zalozime.
    case Request_Start(AOS, mRequestID, 'putWithoutDocStopPicking') of
      1: begin
        SetPlainResponse(AResponse, getString('request_in_process'), HTTP_SC_ExpectationFailed);
        exit;
      end;
      2: begin
        SetResponse(AResponse, PlainResponse(''));
        exit;
      end;
    end;

    AOS.StartTransaction(taReadCommited);
    try
      mSD := AOS.CreateObject(mStoreDocumentClass);
      try
        mTemporaryStorageID := REST_getJSONInt(mJSON_Root, 'tempID');
        mSD.ExplicitTransaction := True;

        // dataset, do ktereho si preplnime polozky z JSONu
        DataSet_CreataHeader(dtJSONRows, 'jsonIndex=I,StoreDocument2_ID=S10,StoreDocument2Provide_ID=S10,StoreDocument2ProvideRow_ID=S10,' +
          'DocRowBatch_ID=S10,LogStoreDocument2_ID=S10,StoreFrom_ID=S10,StoreTo_ID=S10,StoreCard_ID=S10,StorePositionFrom_ID=S10,' +
          'StoreBatch_ID=S10,StorePositionTo_ID=S10,Processed=B,UnitQuantity=F,UnitRate=F,UnitCode=S10,Division_ID=S10,AuxText2=S100' +
          ',AuxText3=S100,AuxText4=S100,StoreCardCategory=I,StoreBatchNoteVisibility=S1,StoreBatchNote=S100,rowType=I,storeCardNew_ID=S10' +
          ',storeBatchNew_ID=S10,StoreCardNewCategory=I,ContentUnit=S5,EnterStoreBatchExpirationDate=B,StoreBatchExpirationDate=S16,unitCodeNew=S10'
          + rowsDatasetFields(AOS, gSkladTermModule, gSkladTermDocType, gSkladTermUser_ID));
        dtJSONRows.AddIndex('ByJsonIndex', 'jsonIndex', [ixUnique]);
        dtJSONRows.IndexName := 'ByJsonIndex';
        dtJSONRows.Open;
        REST_JsonToDataSet(mJSON_Root.A['rows'], dtJSONRows);

        // dataset pro funkci Create_LogStoreDocument
        DataSet_CreataHeader(dtDocumentQuantity, 'Store_ID=S10,StoreCard_ID=S10,StoreBatch_ID=S10,StorePosition_ID=S10,Quantity=F,ContentUnit=S5');
        dtDocumentQuantity.AddIndex('I0', 'Store_ID;StoreCard_ID;StoreBatch_ID;StorePosition_ID;ContentUnit', [ixUnique]);
        dtDocumentQuantity.IndexName:= 'I0';
        dtDocumentQuantity.Open;

        // nejdriv vytvorime doklad
        mSD.New;
        mSD.Prefill;
        mSD.SetFieldValueAsString('Firm_ID', REST_getJSONStr(mJSON_Root, 'Firm_ID'));

        LogWriteEvent('Entering header values');
        if EnterPerson(AOS, gSkladTermModule, gSkladTermDocType, gSkladTermUser_ID, mPersonField) then
          mSD.SetFieldValueAsString(mPersonField, REST_getJSONStr(mJSON_Root, 'Person_ID'));

        if EnterDocQueue(AOS, gSkladTermModule, gSkladTermDocType, gSkladTermUser_ID) then
          mSD.SetFieldValueAsString('DocQueue_ID', REST_getJSONStr(mJSON_Root, 'docQueue.id'))
        else
        begin
          mDocQueue_ID := GetDocQueue_ID(AOS, gSkladTermModule, gSkladTermDocType, gSkladTermUser_ID, mJSON_Root, gSkladTermDocType, mSD);
          mSD.SetFieldValueAsString('DocQueue_ID', GetValueOrDefault(mDocQueue_ID, GetDefaultDocQueue_ID(gSkladTermDocType)));
        end;

        if EnterTransportationType(AOS, gSkladTermModule, gSkladTermDocType, gSkladTermUser_ID) then
          mSD.SetFieldValueAsString('TransportationType_ID', REST_getJSONStr(mJSON_Root, 'TransportationType_ID'));

        if EnterFirmOffice(AOS, gSkladTermModule, gSkladTermDocType, gSkladTermUser_ID) then
          mSD.SetFieldValueAsString('FirmOffice_ID', REST_getJSONStr(mJSON_Root, 'FirmOffice_ID'));

        // nastavim AuxText
        mAuxField := StoreDocumentAuxTextField(gSkladTermModule, mAuxReadOnly);
        if (mAuxField <> '') then
        begin
          mSD.SetFieldValueAsString(mAuxField, mJSON_Root.S['AuxText']);
        end;

        // ulozim hodnotu z dialogu
        SaveDialogValues(mSD, mJSON_Root.O['Dialog'].A['values']);

        LogWriteEvent('Starting processing rows');
        mRows := mSD.GetCollectionMonikerForFieldCode(mSD.GetFieldCode('Rows'));
        dtJSONRows.First;
        while not dtJSONRows.EOF do
        begin
          // prochazim pouze zdrojove radky (ma vyznam hlavne u premen a zamen)
          if dtJSONRows.FieldByName('rowType').AsInteger <> 0 then
          begin
            dtJSONRows.Next;
            continue;
          end;

          mSDRow := AddRow(mRows);

          // u objednavek nevyplnujeme sarze ani ser. cisla
          if gSkladTermDocType <> DOC_RECEIVEDORDER then
          begin
            // sarze
            FillStoreBatches(mSD, mSDRow);

            // ser. cisla
            FillSerialNumbers(mSDRow);
          end;

          putWithoutDocStopPicking_beforeRowSave(gSkladTermModule, AOS, mSDRow, dtJSONRows, mJSON_Root);

          dtJSONRows.Next;
        end;
        LogWriteEvent('Rows processed');

        LogWriteEvent('Calling beforeSaveHook');
        beforeSaveHook(AOS, gSkladTermModule, gSkladTermDocType, gSkladTermUser_ID, mSD, 0, mJSON_Root, dtJSONRows);

        mSD_ID := mSD.OID;

        LogWriteEvent(Format('Saving document: %s', [mSD_ID]));
        mSD.Save;

        LogWriteEvent('Calling afterSaveHook');
        afterSaveHook(AOS, gSkladTermModule, gSkladTermDocType, gSkladTermUser_ID, mSD, 0, mJSON_Root, dtJSONRows);

        LogWriteEvent('Checking CanTakePhotos');
        if REST_getJSONBool(mJSON_Root, 'CanTakePhotos') then
        begin
          AddPhotos(AOS, gSkladTermDocType, mSD_ID, mJSON_Root.A['documents']);
        end;

        // naplnime pomocny dataset pro vytvoreni polohovaku
        if(gSkladTermDocType <> DOC_RECEIVEDORDER) then
        begin
          LogWriteEvent('Creating log store document');
          FillLogStoreDocumentDataset(dtJSONRows, dtDocumentQuantity, mJSON_Root, 'rowType=0', mStoreField, mStorePositionField);

          // vytvorime polohovak
          if dtDocumentQuantity.RecordCount > 0 then
            if CreateLogStoreDocument(AOS, gSkladTermModule, gSkladTermDocType, gSkladTermUser_ID, '', mSD, mJSON_Root, dtJSONRows, dtDocumentQuantity) then
            begin
              mDocQueue_ID := GetDocQueue_ID(AOS, gSkladTermModule, mLogStoreDocumentDocType, gSkladTermUser_ID, mJSON_Root, gSkladTermDocType, mSD);
              mLSD_ID := REST_Create_LogStoreDocument(AOS, mSD, '',
                mLogStoreDocumentClass,
                GetValueOrDefault(mDocQueue_ID, GetDefaultDocQueue_ID(mLogStoreDocumentDocType)),
                mLogStoreDocument_StoreGateway_ID, dtDocumentQuantity, gSkladTermUser_ID,
                False);
            end;
        end;

        if gSkladTermDocType in [DOC_OutgoingTransformation, DOC_OutgoingSubstitution] then
          mSDNew_ID := CreateOutputDocument;
      finally
        mSD.Free;
      end;

      // zmeny stavu
      if (gSkladTermDocType <> DOC_RECEIVEDORDER)
        and not CFxOID.IsEmpty(mSD_ID)
        and not CFxOID.IsEmpty(PRECHOD_VYTVORENI(gSkladTermDocType, gSkladTermModule)) then
      begin
        mSD := AOS.CreateObject(mStoreDocumentClass);
        try
          mSD.ExplicitTransaction := True;
          mSD.Load(mSD_ID, nil);
          ChangeStatusByRule(mSD, PRECHOD_VYTVORENI(gSkladTermDocType, gSkladTermModule));
        finally
          mSD.Free;
        end;
      end;

      if not CFxOID.IsEmpty(mSDNew_ID)
        and not CFxOID.IsEmpty(PRECHOD_VYTVORENI(mSDNewDocType, gSkladTermModule)) then
      begin
        mSD := AOS.CreateObject(mStoreDocumentNewClass);
        try
          mSD.ExplicitTransaction := True;
          mSD.Load(mSDNew_ID, nil);
          ChangeStatusByRule(mSD, PRECHOD_VYTVORENI(mSDNewDocType, gSkladTermModule));
        finally
          mSD.Free;
        end;
      end;

      // vymaz z TemporaryStorage jeste v transakci
      TemporaryStorage_Finish(AOS, mTemporaryStorageID);

      Request_Finish(AOS, mRequestID);

      AOS.Commit;

      SetResponse(AResponse, PlainResponse(''));
    except
      AOS.RollBack;
      SetPlainResponse(AResponse, getString('error_saving') + ExceptionMessage, HTTP_SC_InternalServerError);
      Request_Cancel(AOS, mRequestID);
      LogWriteSectionEnd;
      exit;
    end;
  finally
    mJSON_Root.Free;
    dtJSONRows.Free;
    dtDocumentQuantity.Free;
    LogWriteSectionEnd;
  end;

  // polohovaky potvrdime az mimo hlavni transakci
  if MakeExecuteLogStoreDocument(AOS, gSkladTermModule, mLogStoreDocumentDocType, gSkladTermUser_ID, mLSD_ID) then
    ConfirmLSD(AOS, mLogStoreDocumentClass, mLSD_ID, 'putWithoutDocStopPicking');
  if MakeExecuteLogStoreDocument(AOS, gSkladTermModule, mLogStoreDocumentDocType, gSkladTermUser_ID, mLSDNew_ID) then
    ConfirmLSD(AOS, Class_LogStoreInput, mLSDNew_ID, 'putWithoutDocStopPicking');
end;

procedure listWithoutDocQueue(AOS: TNxCustomObjectSpace; APath, AQueryParams, AResponse: TStringList);
var
  dtRows: TMemTable;
  mSql, mSearchStr: String;
  json, rowJson, rowJsonData: TJSONSuperObject;
begin
  json := nil;
  if APath.Count <> 1 then
  begin
    SetPlainResponse(AResponse, getString('wrong_parameters_count'), HTTP_SC_BadRequest);
    exit;
  end;

  dtRows := TMemTable.Create(nil);
  json := TJSONSuperObject.CreateByDataType(jtObject);
  try
    LogWriteSectionStart('listWithoutDocQueue: ' + gSkladTermModule);

    mSearchStr := AQueryParams.Values('search');
    mSql := GetListWithoutDocQueueSql(AOS, gSkladTermModule, gSkladTermDocType, gSkladTermUser_ID, mSearchStr);

    AOS.SQLSelect2(mSql, dtRows);

    LogWriteSectionStart('JSON');
    if dtRows.Active then
    begin
      dtRows.First;
      // v dotazu se vratil i JSON, abych ho mohl zkusit zpracovat a ziskat z nej nektere informace pro zobrazeni
      while not dtRows.Eof do
      begin
        rowJson := TJSONSuperObject.ParseString(dtRows.FieldByName('Data').AsString, False);
        try
          rowJsonData := TJSONSuperObject.ParseString(rowJson.S['data'], False);
          try
            dtRows.Edit;
            dtRows.FieldByName('FirmName').AsString := Trim(rowJsonData.S['FirmName']);
            dtRows.FieldByName('AuxText').AsString := Trim(rowJsonData.S['AuxText']);
            // prenaset JSON s daty nepotrebuju, takze ho smazu
            dtRows.FieldByName('Data').AsString := '';
            dtRows.Post;
          finally
            rowJsonData.Free;
          end;
        finally
          rowJson.Free;
        end;
        dtRows.Next;
      end;

      json.O['documents'] := REST_jsonCreate_FromDataSet(dtRows, nil, nil);
    end
    else begin
      json.O['documents'] := TJSONSuperObject.CreateByDataType(jtArray);
    end;
    LogWriteSectionEnd;

    SetResponse(AResponse, json.AsJson(false, true));
  finally
    LogWriteSectionEnd;
    dtRows.Free;
    if Assigned(json) then
      json.Free;
  end;
end;

procedure put_SaveSmallAssetCards(AOS: TNxCustomObjectSpace; APath: TStringList; ABody: String; AResponse: TStringList);
var
  mRequestID, mLastSmallAssetCard_ID: String;
  mJSON: TJSONSuperObject;
  dtJSONRows: TMemTable;
  mTemporaryStorageID: Integer;
  mSmallAssetCard, mSmallAssetCardRow: TNxCustomBusinessObject;
  mSmallAssetCardRows: TNxCustomBusinessMonikerCollection;
  mQuantity: Double;
begin
  dtJSONRows := TMemTable.Create(nil);
  mJSON := TJSONSuperObject.ParseString(ABody, True);
  LogWriteSectionStart('put_SaveSmallAssetCards');
  try
    mRequestID := REST_getJSONStr(mJSON, 'saveRequestID');
    // pred transakci overime, jestli uz tento request nebezi nebo neni dokonce dokonceny. Pokud ne, tak ho zalozime.
    case Request_Start(AOS, mRequestID, gSkladTermModule) of
      1: begin
        SetPlainResponse(AResponse, getString('request_in_process'), HTTP_SC_ExpectationFailed);
        exit;
      end;
      2: begin
        SetResponse(AResponse, PlainResponse(''));
        exit;
      end;
    end;

    AOS.StartTransaction(taReadCommited);
    try
      // dataset, do ktereho si preplnime polozky z JSONu
      DataSet_CreataHeader(dtJSONRows, 'jsonIndex=I,StoreDocument2_ID=S10,StoreDocument2Provide_ID=S10,StoreDocument2ProvideRow_ID=S10,' +
        'DocRowBatch_ID=S10,LogStoreDocument2_ID=S10,StoreFrom_ID=S10,StoreTo_ID=S10,StoreCard_ID=S10,StorePositionFrom_ID=S10,' +
        'StoreBatch_ID=S10,StorePositionTo_ID=S10,Processed=B,UnitQuantity=F,UnitRate=F,UnitCode=S10,Division_ID=S10,AuxText2=S100' +
        ',AuxText3=S100,AuxText4=S100,StoreCardCategory=I'
        + rowsDatasetFields(AOS, gSkladTermModule, gSkladTermDocType, gSkladTermUser_ID));
      dtJSONRows.AddIndex('ByJsonIndex', 'jsonIndex', [ixUnique]);
      dtJSONRows.AddIndex('ByStoreCard_ID', 'StoreCard_ID;jsonIndex', [ixUnique]);
      dtJSONRows.IndexName := 'ByStoreCard_ID';
      dtJSONRows.Open;
      REST_JsonToDataSet(mJSON.A['rows'], dtJSONRows);

      mTemporaryStorageID := REST_getJSONInt(mJSON, 'tempID');

      // prochazim radky - pro kazdou kartu nascitam vsechno mnozstvi a jakmile se dostanu k dalsi karte tak soucet ulozim
      mQuantity := 0;
      dtJSONRows.First;
      mLastSmallAssetCard_ID := dtJSONRows.FieldByName('StoreCard_ID').AsString;
      while not dtJSONRows.Eof do
      begin
        mQuantity := mQuantity + dtJSONRows.FieldByName('UnitQuantity').AsFloat;

        dtJSONRows.Next;

        if (mLastSmallAssetCard_ID <> dtJSONRows.FieldByName('StoreCard_ID').AsString)
          or dtJSONRows.Eof then
        begin
          mSmallAssetCard := AOS.CreateObject(Class_SmallAssetCard);
          try
            mSmallAssetCard.Load(mLastSmallAssetCard_ID, nil);
            mSmallAssetCard.ExplicitTransaction := True;

            mSmallAssetCard.SetFieldValueAsString('AssetLocation_ID', REST_getJSONStr(mJSON, 'Store_ID'));
            mSmallAssetCard.SetFieldValueAsString('Responsible_ID', REST_getJSONStr(mJSON, 'Firm_ID'));
            mSmallAssetCard.SetFieldValueAsFloat('Quantity', mQuantity);

            mSmallAssetCardRows := mSmallAssetCard.GetLoadedCollectionMonikerForFieldCode(mSmallAssetCard.GetFieldCode('Rows'));
            if mSmallAssetCardRows.Count > 1 then
            begin
              RaiseException(Format(getString('error_saving_breakdown_has_too_many_rows'), [mSmallAssetCard.GetFieldValueAsString('Name')]));
            end;

            // vzdycky by mel byt alespon jeden zaznam, ale radeji udelam kontrolu
            if mSmallAssetCardRows.Count > 0 then
            begin
              mSmallAssetCardRow := mSmallAssetCardRows.BusinessObject(0);
              mSmallAssetCardRow.SetFieldValueAsString('Responsible_ID', REST_getJSONStr(mJSON, 'Firm_ID'));
              mSmallAssetCardRow.SetFieldValueAsFloat('Quantity', mQuantity);
            end;

            beforeSaveHook(AOS, gSkladTermModule, gSkladTermDocType, gSkladTermUser_ID, mSmallAssetCard, 0, mJSON, dtJSONRows);
            mSmallAssetCard.Save;
            afterSaveHook(AOS, gSkladTermModule, gSkladTermDocType, gSkladTermUser_ID, mSmallAssetCard, 0, mJSON, dtJSONRows);
          finally;
            mSmallAssetCard.Free;
          end;

          mLastSmallAssetCard_ID := dtJSONRows.FieldByName('StoreCard_ID').AsString;
          mQuantity := 0;
        end;
      end;

      // vymaz z TemporaryStorage jeste v transakci
      TemporaryStorage_Finish(AOS, mTemporaryStorageID);

      Request_Finish(AOS, mRequestID);

      AOS.Commit;

      SetResponse(AResponse, PlainResponse(''));
    except
      AOS.RollBack;
      SetPlainResponse(AResponse, ExceptionMessage, HTTP_SC_InternalServerError);
      Request_Cancel(AOS, mRequestID);
    end;
  finally
    mJSON.Free;
    dtJSONRows.Free;
    LogWriteSectionEnd;
  end;
end;

procedure put_CustomCall(AOS: TNxCustomObjectSpace; APath: TStringList; ABody: String; AResponse: TStringList);
var
  mBody, mResponse: String;
begin
  mBody := ABody;
  // vypada to, ze se barcode posle z aplikace v uvozovkach, takze je odstranim
  if pos('"', mBody) = 1 then
    mBody := copy(mBody, 2, Length(mBody) - 2);

  mResponse := CustomCall(AOS, gSkladTermModule, gSkladTermDocType, gSkladTermUser_ID, mBody);
  SetResponse(AResponse, PlainResponse(mResponse))
end;

procedure put_SaveLogStoreDocumentWithoutDoc(AOS: TNxCustomObjectSpace; ABody: String; AResponse: TStringList);
var
  mJson: TJSONSuperObject;
  jsonSerNums: TJSONSuperObjectArray;
  mBO, mRow: TNxCustomBusinessObject;
  mRows: TNxCustomBusinessMonikerCollection;
  i: Integer;
  mTemporaryStorageID: Integer;
  mRequestID, mSql, mUnblockPositions, mForbiddenPositions, mLogStoreDocument_DocQueue_ID, mLogStoreDocument_StoreGateway_ID,
    mAuxField, mDocQueue_ID, mBO_ID, mSerNum_ID, mStoreBatch_ID: String;
  mUnblockPosition, mBlockedFirst, mAuxReadOnly: Boolean;
  mLSD2ToUnblockPosition, mAvailableQuantities, dtJSONRows: TMemTable;
  mMessage: String;
  mQuantity: Double;

  // vrati mnozstvi, ktere je potreba navic k volnemu mnozsti odblokovat
  function GetNeedToUnblockQuantity(AAvailableQuantities: TMemTable; AStoreCard_ID, AStoreBatch_ID, AStorePosition_ID: String; AQuantity: Double): Double;
  var
    mAvailableQuantity: Double;
  begin
    if AAvailableQuantities.FindKey([AStoreCard_ID, AStoreBatch_ID, AStorePosition_ID]) then
    begin
      AAvailableQuantities.Edit;
      if AQuantity > AAvailableQuantities.FieldByName('Quantity').AsFloat then
      begin
        AQuantity := AQuantity - AAvailableQuantities.FieldByName('Quantity').AsFloat;
        AAvailableQuantities.FieldByName('Quantity').AsFloat := 0;
      end
      else
      begin
        AAvailableQuantities.FieldByName('Quantity').AsFloat := AAvailableQuantities.FieldByName('Quantity').AsFloat - AQuantity;
        AQuantity := 0;
      end;
      AAvailableQuantities.Post;
    end
    else
    begin
      mSql :=
        'select' + nxCrLf +
        '  Quantity - QuantityReserved' + nxCrLf +
        'from LogStoreContents' + nxCrLf +
        'where' + nxCrLf +
        '  StoreCard_ID = ' + QuotedStr(AStoreCard_ID) + nxCrLf +
        '  and Parent_ID = ' + QuotedStr(AStorePosition_ID) + nxCrLf;

      if not CFxOID.IsEmpty(AStoreBatch_ID) then
        mSql := mSql +
          ' and StoreBatch_ID = ' + QuotedStr(AStoreBatch_ID);

      mAvailableQuantity := SQLSelectFloat(AOS, mSql);

      // pokud potrebuju vic nez je dostupny, tak budu muset brat i blokovane,
      AAvailableQuantities.Edit;
      AAvailableQuantities.FieldByName('StoreCard_ID').AsString := AStoreCard_ID;
      AAvailableQuantities.FieldByName('StoreBatch_ID').AsString := AStoreBatch_ID;
      AAvailableQuantities.FieldByName('StorePosition_ID').AsString := AStorePosition_ID;

      if AQuantity > mAvailableQuantity then
      begin
        AQuantity := AQuantity - mAvailableQuantity;
        AAvailableQuantities.FieldByName('Quantity').AsFloat := 0;
      end
      else
      begin
        AAvailableQuantities.FieldByName('Quantity').AsFloat := AAvailableQuantities.FieldByName('Quantity').AsFloat - AQuantity;
        AQuantity := 0;
      end;
      AAvailableQuantities.Post;
    end;

    Result := AQuantity;
  end;

  procedure fillClassAndIdVariables(ADocType: String);
  begin
    if gSkladTermDocType = DOC_LogStoreInput then
    begin
      mLogStoreDocument_DocQueue_ID := LogStoreInput_DocQueue_ID;
      mLogStoreDocument_StoreGateway_ID := LogStoreInput_StoreGateway_ID;
      //mLogStoreDocumentClass := Class_LogStoreInput;
      //mLogStoreDocumentDocType := DOC_LogStoreInput;
    end
    else
    begin
      mLogStoreDocument_DocQueue_ID := LogStoreTransfer_DocQueue_ID;
      mLogStoreDocument_StoreGateway_ID := '';
    end;
  end;
begin
  mBlockedFirst := False;
  LogWriteSectionStart('saveTransferBetweenPositions');
  mJson := TJSONSuperObject.ParseString(ABody, True);
  dtJSONRows := TMemTable.Create(nil);
  try
    mRequestID := REST_getJSONStr(mJson, 'saveRequestID');
    // pred transakci overime, jestli uz tento request nebezi nebo neni dokonce dokonceny. Pokud ne, tak ho zalozime.
    case Request_Start(AOS, mRequestID, 'saveTransferBetweenPositions') of
      1: begin
        SetResponse(AResponse, getString('request_in_process'), ContentType_PlainText, HTTP_SC_ExpectationFailed);
        exit;
      end;
      2: begin
        SetResponse(AResponse, PlainResponse(''));
        exit;
      end;
    end;

    AOS.StartTransaction(taReadCommited);
    try
      mTemporaryStorageID := REST_getJSONInt(mJson, 'tempID');

      // dataset, do ktereho si preplnime polozky z JSONu
      DataSet_CreataHeader(dtJSONRows, 'jsonIndex=I,StoreDocument2_ID=S10,StoreDocument2Provide_ID=S10,StoreDocument2ProvideRow_ID=S10,' +
        'DocRowBatch_ID=S10,LogStoreDocument2_ID=S10,StoreFrom_ID=S10,StoreTo_ID=S10,StoreCard_ID=S10,StorePositionFrom_ID=S10,' +
        'StoreBatch_ID=S10,StorePositionTo_ID=S10,Processed=B,UnitQuantity=F,UnitRate=F,UnitCode=S10,Division_ID=S10,AuxText2=S100' +
        ',AuxText3=S100,AuxText4=S100,StoreCardCategory=I,StoreBatchNoteVisibility=S1,StoreBatchNote=S100,ContentUnit=S5'
        + rowsDatasetFields(AOS, gSkladTermModule, gSkladTermDocType, gSkladTermUser_ID));
      dtJSONRows.AddIndex('ByJsonIndex', 'jsonIndex', [ixUnique]);
      dtJSONRows.IndexName := 'ByJsonIndex';
      dtJSONRows.Open;
      REST_JsonToDataSet(mJson.A['rows'], dtJSONRows);

      //Pokud jsou definovany stav pro presun cele pozice,
      //znamena to, ze budeme pracovat v rezimu odblokovani pozice pro presun
      //a po ulozeni prevodu opetovnem zablokovani na nove pozici

      mUnblockPosition := False;
      if gSkladTermDocType = DOC_LogStoreTransfer then
      begin
        mUnblockPositions := POVOLENE_STAVY_PRESUN_CELE_POZICE(AOS, gSkladTermModule, gSkladTermDocType, gSkladTermUser_ID, mJson, mBlockedFirst);
        mUnblockPosition := mUnblockPositions <> '';
        mForbiddenPositions := ZAKAZANE_POZICE_PRESUN_CELE_POZICE(AOS, gSkladTermModule, gSkladTermDocType, gSkladTermUser_ID, mJson, mBlockedFirst);

        if mUnblockPosition then
        begin
          //kontrola celeho dokladu jeste jednou pred ulozenim... Kontroluje se jen v pripade nutnosti odblokovani
          if not isTransferBetweenPositionsAllowedWholeDoc(AOS, mJson, dtJSONRows, mForbiddenPositions, mUnblockPositions, mMessage) then
            RaiseException(mMessage);
        end;
      end;

      //Potrebujeme dataset, ktere pozice bude treba odblokovat.
      //Odblokovani probehne ve dvou krocich, nejprve se z polohovacich dokladu
      //odmazou blokujici radky, pak se provede presun a nakonec se blokujici radky
      //znovu vlozi na polohovaci doklady...
      //To co se ma odmazat z blokujicich dokladu se v prubehu vkladani radku ulozi do mLSD2ToUnblockPosition
      mLSD2ToUnblockPosition := TMemTable.Create(nil);
      DataSet_CreataHeader(mLSD2ToUnblockPosition, 'DOCTYPE=S10,LSD_ID=S10,LSD2_ID=S10,SP_ID=S10,SPTO_ID=S10,SC_ID=S10,SB_ID=S10,QUnit=S10,UnitRate=F,Quantity=F,SD_ID=S10,SD2_ID=S10');
      mAvailableQuantities := TMemTable.Create(nil);
      mLSD2ToUnblockPosition.AddIndex(_c_SD2TTKeyName,'LSD2_ID',[ixUnique]);
      try
        DataSet_CreataHeader(mAvailableQuantities, 'StoreCard_ID=S10,StoreBatch_ID=10,StorePosition_ID=S10,Quantity=F');
        mAvailableQuantities.AddIndex('index', 'StoreCard_ID;StoreBatch_ID;StorePosition_ID', [ixUnique]);
        mAvailableQuantities.IndexName := 'index';

        fillClassAndIdVariables(gSkladTermDocType);

        mBO := GetStoreDocBO(AOS, gSkladTermDocType);
        try
          mBO.ExplicitTransaction := True;
          mBO.New;
          mBO.Prefill;

          if EnterDocQueue(AOS, gSkladTermModule, gSkladTermDocType, gSkladTermUser_ID) then
            mBO.SetFieldValueAsString('DocQueue_ID', REST_getJSONStr(mJson, 'docQueue.id'))
          else
          begin
            mDocQueue_ID := GetDocQueue_ID(AOS, gSkladTermModule, gSkladTermDocType, gSkladTermUser_ID, mJson, '', nil, mJson.S['Store_ID']);
            mBO.SetFieldValueAsString('DocQueue_ID', GetValueOrDefault(mDocQueue_ID, GetDefaultDocQueue_ID(gSkladTermDocType)));
          end;

          // nastavim AuxText
          mAuxField := StoreDocumentAuxTextField(gSkladTermModule, mAuxReadOnly);
          if (mAuxField <> '') then
          begin
            mBO.SetFieldValueAsString(mAuxField, mJson.S['AuxText']);
          end;

          mBO.SetFieldValueAsString('Firm_ID', REST_getJSONStr(mJson, 'Firm_ID'));
          mBO.SetFieldValueAsString('StoreGateway_ID', mLogStoreDocument_StoreGateway_ID);

          if not ABRA and (gSkladTermUser_ID <> '') then
            mBO.SetFieldValueAsString('StoreMan_ID',
              SQLSelectStr(AOS,
                'Select Person_ID from SecurityUsers where ID = ' + QuotedStr(gSkladTermUser_ID)));

          SaveDialogValues(mBO, mJson.O['Dialog'].A['values']);

          mRows := mBO.GetCollectionMonikerForFieldCode(mBO.GetFieldCode('Rows'));

          dtJSONRows.First;
          while not dtJSONRows.Eof do
          begin
            // pokud jsou zadana seriova cisla, jedeme podle nich
            if dtJSONRows.FieldByName('StoreCardCategory').AsInteger = 1 then
            begin
              jsonSerNums := mJson.A['rows'].O[dtJSONRows.FieldByName('jsonIndex').AsInteger].A['sernums'];
              for i := 0 to jsonSerNums.Length - 1 do
              begin
                mRow := mRows.AddNewObject;
                mRow.Prefill;
                mRow.SetFieldValueAsString('Store_ID', dtJSONRows.FieldByName('StoreFrom_ID').AsString);
                mRow.SetFieldValueAsString('StoreCard_ID', dtJSONRows.FieldByName('StoreCard_ID').AsString);
                mRow.SetFieldValueAsString('StorePosition_ID', dtJSONRows.FieldByName('StorePositionFrom_ID').AsString);

                if not CFxOID.IsEmpty(dtJSONRows.FieldByName('StorePositionTo_ID').AsString) then
                  mRow.SetFieldValueAsString('IncomingStorePosition_ID', dtJSONRows.FieldByName('StorePositionTo_ID').AsString);

                if CFxOID.IsEmpty(jsonSerNums.O[i].S['SerNum_ID']) then
                begin
                  // dohledam existujici ser. cislo
                  mSerNum_ID := '';
                  if IsUsingExistingSerNumberAllowed then
                  begin
                    // zkusim sarzi ser. cislo
                    mSerNum_ID := SQLSelectStr(AOS, 'select ID from StoreBatches where Name = ' + QuotedStr(jsonSerNums.O[i].S['SerNumName'])
                      + ' and StoreCard_ID = ' + QuotedStr(mRow.GetFieldValueAsString('StoreCard_ID')) + 'and Hidden = ''N''');
                  end;

                  if mSerNum_ID <> '' then
                  begin
                    mRow.SetFieldValueAsString('StoreBatch_ID', mSerNum_ID);
                  end
                  else
                  begin
                    mStoreBatch_ID := CreateSerialNumber(AOS, mRow.GetFieldValueAsString('StoreCard_ID'), jsonSerNums.O[i].S['SerNumName'],
                      jsonSerNums.O[i].S['AuxText']);

                    // nenasel jsem, takze vytvarim nove
                    mRow.SetFieldValueAsString('StoreBatch_ID', mStoreBatch_ID);
                  end;
                end
                else
                  mRow.SetFieldValueAsString('StoreBatch_ID', jsonSerNums.O[i].S['SerNum_ID']);

                mRow.SetFieldValueAsString('QUnit', dtJSONRows.FieldByName('UnitCode').AsString);
                mRow.SetFieldValueAsFloat('Quantity', 1);

                SaveDialogValues(mRow, mJson.A['rows'].O[dtJSONRows.FieldByName('jsonIndex').AsInteger].O['dialog'].A['values']);

                // pokud se presouva nejdriv volne mnozstvi, tak musim zjistit kolik volneho vlastne mam
                // takze si do datasetu ulozim k artiklu volne mnozstvi a od nej pak odecitam.
                // pozadovane blokovane mnozstvi pak beru jen kdyz dojde volne
                // TODO tahle cast neni otestovana
                if gSkladTermDocType = DOC_LogStoreTransfer then
                begin
                  mQuantity := 1;
                  if not mBlockedFirst and (pos(dtJSONRows.FieldByName('StorePositionTo_ID').AsString, mForbiddenPositions) = 0) then
                  begin
                    mQuantity := GetNeedToUnblockQuantity(mAvailableQuantities, dtJSONRows.FieldByName('StoreCard_ID').AsString, dtJSONRows.FieldByName('StoreBatch_ID').AsString,
                      dtJSONRows.FieldByName('StorePositionFrom_ID').AsString, mQuantity);
                  end;

                  if mUnblockPosition and (pos(dtJSONRows.FieldByName('StorePositionTo_ID').AsString, mForbiddenPositions) = 0) then
                    GetBlockingRows(AOS
                                    ,dtJSONRows.FieldByName('StoreCard_ID').AsString
                                    ,jsonSerNums.O[i].S['SerNum_ID']
                                    ,dtJSONRows.FieldByName('StorePositionFrom_ID').AsString
                                    ,dtJSONRows.FieldByName('StorePositionTo_ID').AsString
                                    ,mUnblockPositions
                                    ,mQuantity
                                    ,mLSD2ToUnblockPosition);
                end;
              end;
            end
            else begin
              mRow := mRows.AddNewObject;
              mRow.Prefill;
              mRow.SetFieldValueAsString('Store_ID', dtJSONRows.FieldByName('StoreFrom_ID').AsString);
              mRow.SetFieldValueAsString('StoreCard_ID', dtJSONRows.FieldByName('StoreCard_ID').AsString);
              mRow.SetFieldValueAsString('StorePosition_ID', dtJSONRows.FieldByName('StorePositionFrom_ID').AsString);

              if not CFxOID.IsEmpty(dtJSONRows.FieldByName('StorePositionTo_ID').AsString) then
                mRow.SetFieldValueAsString('IncomingStorePosition_ID', dtJSONRows.FieldByName('StorePositionTo_ID').AsString);

              mRow.SetFieldValueAsString('StoreBatch_ID', dtJSONRows.FieldByName('StoreBatch_ID').AsString);
              mRow.SetFieldValueAsString('QUnit', dtJSONRows.FieldByName('UnitCode').AsString);
              if dtJSONRows.FieldByName('UnitRate').AsFloat > 0 then
                mRow.SetFieldValueAsFloat('Quantity', dtJSONRows.FieldByName('UnitQuantity').AsFloat * dtJSONRows.FieldByName('UnitRate').AsFloat)
              else
                mRow.SetFieldValueAsFloat('Quantity', dtJSONRows.FieldByName('UnitQuantity').AsFloat);

              // pokud se presouva nejdriv volne mnozstvi, tak musim zjistit kolik volneho vlastne mam
              // takze si do datasetu ulozim k artiklu volne mnozstvi a od nej pak odecitam.
              // pozadovane blokovane mnozstvi pak beru jen kdyz dojde volne
              if gSkladTermDocType = DOC_LogStoreTransfer then
              begin
                if not mBlockedFirst and (pos(dtJSONRows.FieldByName('StorePositionTo_ID').AsString, mForbiddenPositions) = 0) then
                begin
                  dtJSONRows.Edit;
                  dtJSONRows.FieldByName('UnitQuantity').AsFloat := GetNeedToUnblockQuantity(mAvailableQuantities, dtJSONRows.FieldByName('StoreCard_ID').AsString,
                    dtJSONRows.FieldByName('StoreBatch_ID').AsString, dtJSONRows.FieldByName('StorePositionFrom_ID').AsString, dtJSONRows.FieldByName('UnitQuantity').AsFloat);
                  dtJSONRows.Post;
                end;

                if mUnblockPosition and (pos(dtJSONRows.FieldByName('StorePositionTo_ID').AsString, mForbiddenPositions) = 0) then
                  GetBlockingRows(AOS
                                  ,dtJSONRows.FieldByName('StoreCard_ID').AsString
                                  ,dtJSONRows.FieldByName('StoreBatch_ID').AsString
                                  ,dtJSONRows.FieldByName('StorePositionFrom_ID').AsString
                                  ,dtJSONRows.FieldByName('StorePositionTo_ID').AsString
                                  ,mUnblockPositions
                                  ,dtJSONRows.FieldByName('UnitQuantity').AsFloat
                                  ,mLSD2ToUnblockPosition);
              end;
            end;

            putWithoutDocStopPicking_beforeRowSave(gSkladTermModule, AOS, mRow, dtJSONRows, mJson);

            dtJSONRows.Next;
          end;

          //Odblokujeme
          if mUnblockPosition then
            if mLSD2ToUnblockPosition.Active then
              UnblockPosition(AOS, mLSD2ToUnblockPosition);

          beforeSaveHook(AOS, gSkladTermModule, gSkladTermDocType, gSkladTermUser_ID, mBO, 0, mJson, dtJSONRows);
          mBO.Save;
          mBO_ID := mBO.OID;
          afterSaveHook(AOS, gSkladTermModule, gSkladTermDocType, gSkladTermUser_ID, mBO, 0, mJson, dtJSONRows);

          LogWriteEvent('Checking CanTakePhotos');
          if REST_getJSONBool(mJson, 'CanTakePhotos') then
          begin
            AddPhotos(AOS, gSkladTermDocType, mBO_ID, mJson.A['documents']);
          end;

          if MakeExecuteLogStoreDocument(AOS, gSkladTermModule, gSkladTermDocType, gSkladTermUser_ID, mBO_ID) then
            ConfirmLSD(AOS, mBO.CLSID, mBO_ID, 'put_SaveLogStoreDocumentWithoutDoc', not AOS.InTransaction);

          //Zablokujeme
          if mUnblockPosition then
            if mLSD2ToUnblockPosition.Active then
              BlockPosition(AOS, mLSD2ToUnblockPosition);
        finally
          mBO.Free;
        end;
      finally
        mLSD2ToUnblockPosition.Free;
        mAvailableQuantities.Free;
      end;

      // vymaz z TemporaryStorage jeste v transakci
      TemporaryStorage_Finish(AOS, mTemporaryStorageID);

      Request_Finish(AOS, mRequestID);

      AOS.Commit;

      SetResponse(AResponse, PlainResponse(''));
    except
      AOS.RollBack;
      SetResponse(AResponse, getString('error_saving_transfer_position') + ExceptionMessage, ContentType_PlainText, HTTP_SC_InternalServerError);
      Request_Cancel(AOS, mRequestID);
      LogWriteSectionEnd;
      exit;
    end;
  finally
    mJson.Free;
    dtJSONRows.Free;
  end;
  LogWriteSectionEnd;
end;

procedure PutOrdersGenerationWithoutDocStopPicking(AOS: TNxCustomObjectSpace; APath: TStringList; ABody: String; AResponse: TStringList);
const
  FUNCTION_NAME = 'PutOrdersGenerationWithoutDocStopPicking';
var
  mJson: TJSONSuperObject;
  mBO: TNxCustomBusinessObject;
  mTemporaryStorageID: Integer;
  mDatasetRows: TMemTable;
  mRequestID, mPersonField, mAuxField, mBO_ID: String;
  mAuxReadOnly, mBusTransactionMandatory, mBusProjectMandatory: Boolean;

  procedure PrepareDatasets(ADataset: TMemTable; AJson: TJSONSuperObject);
  begin
    DataSet_CreataHeader(ADataset, 'jsonIndex=I,StoreFrom_ID=S10,StoreCard_ID=S10,UnitQuantity=F,UnitCode=S10');
    ADataset.AddIndex('ByJsonIndex', 'jsonIndex', [ixUnique]);
    ADataset.IndexName := 'ByJsonIndex';
    ADataset.Open;
    REST_JsonToDataSet(AJson.A['rows'], ADataset);
  end;
begin
  LogWriteSectionStart(FUNCTION_NAME);
  CFxProfiler.EnterProc(REST_LogName, FUNCTION_NAME);
  try
    if (APath.Count <> 1) then
    begin
      SetPlainResponse(AResponse, getString('wrong_parameters_count'), HTTP_SC_BadRequest);
      exit;
    end;

    mJson := TJSONSuperObject.ParseString(ABody, True);
    mBO := AOS.CreateObject(Class_OrdersGeneration);
    mDatasetRows := TMemTable.Create(nil);
    try
      mRequestID := REST_getJSONStr(mJson, 'saveRequestID');
      case Request_Start(AOS, mRequestID, FUNCTION_NAME) of
        1: begin
          SetPlainResponse(AResponse, getString('request_in_process'), HTTP_SC_ExpectationFailed);
          exit;
        end;
        2: begin
          SetResponse(AResponse, PlainResponse(''));
          exit;
        end;
      end;

      PrepareDatasets(mDatasetRows, mJson);

      AOS.StartTransaction(taReadCommited);
      try
        mBO.ExplicitTransaction := True;

        mDatasetRows.First;
        while not mDatasetRows.EOF do
        begin
          mBO.New;
          mBO.Prefill;

          if EnterPerson(AOS, gSkladTermModule, gSkladTermDocType, gSkladTermUser_ID, mPersonField) then
            mBO.SetFieldValueAsString(mPersonField, REST_getJSONStr(mJson, 'Person_ID'));

          // nastavim AuxText
          mAuxField := StoreDocumentAuxTextField(gSkladTermModule, mAuxReadOnly);
          if (mAuxField <> '') then
          begin
            mBO.SetFieldValueAsString(mAuxField, mJson.S['AuxText']);
          end;

          // ulozim hodnotu z dialogu
          SaveDialogValues(mBO, mJson.O['Dialog'].A['values']);

          mBO.SetFieldValueAsString('Firm_ID', REST_getJSONStr(mJson, 'Firm_ID'));
          mBO.SetFieldValueAsString('Store_ID', mDatasetRows.FieldByName('StoreFrom_ID').AsString);
          mBO.SetFieldValueAsString('StoreCard_ID', mDatasetRows.FieldByName('StoreCard_ID').AsString);
          mBO.SetFieldValueAsString('QUnit', mDatasetRows.FieldByName('UnitCode').AsString);
          mBO.SetFieldValueAsFloat('UnitQuantity', mDatasetRows.FieldByName('UnitQuantity').AsFloat);

          if EnterBusOrder(AOS, gSkladTermModule, gSkladTermDocType, gSkladTermUser_ID) then
            mBO.SetFieldValueAsString('BusOrder_ID', REST_getJSONStr(mJson, 'busOrder.id'));

          if EnterBusTransaction(AOS, gSkladTermModule, gSkladTermDocType, gSkladTermUser_ID, mBusTransactionMandatory) then
            if REST_getJSONStr(mJson, 'busTransaction.id') <> '' then
              mBO.SetFieldValueAsString('BusTransaction_ID', REST_getJSONStr(mJson, 'busTransaction.id'));

          if EnterBusProject(AOS, gSkladTermModule, gSkladTermDocType, gSkladTermUser_ID, mBusProjectMandatory) then
            if REST_getJSONStr(mJson, 'busProject.id') <> '' then
              mBO.SetFieldValueAsString('BusProject_ID', REST_getJSONStr(mJson, 'busProject.id'));

          LogWriteEvent('Calling beforeSaveHook');
          beforeSaveHook(AOS, gSkladTermModule, gSkladTermDocType, gSkladTermUser_ID, mBO, 0, mJson, mDatasetRows);

          mBO_ID := mBO.OID;

          LogWriteEvent(Format('Saving document: %s', [mBO_ID]));
          mBO.Save;

          LogWriteEvent('Calling afterSaveHook');
          afterSaveHook(AOS, gSkladTermModule, gSkladTermDocType, gSkladTermUser_ID, mBO, 0, mJson, mDatasetRows);

          mDatasetRows.Next;
        end;

        mTemporaryStorageID := REST_getJSONInt(mJson, 'tempID');
        TemporaryStorage_Delete(AOS, mTemporaryStorageID);

        Request_Finish(AOS, mRequestID);

        AOS.Commit;

        SetResponse(AResponse, PlainResponse(''));
      except
        AOS.RollBack;
        SetResponse(AResponse, ExceptionMessage, ContentType_PlainText, HTTP_SC_InternalServerError);
        Request_Cancel(AOS, mRequestID);
      end;
    finally
      mJson.Free;
      mBO.Free;
      mDatasetRows.Free;
    end;
  finally
    CFxProfiler.ExitProc(REST_LogName, FUNCTION_NAME);
    LogWriteSectionEnd;
  end;
end;

begin
end.