uses
  'REST_SkladTerm.U_Func',
  'REST_SkladTerm.U_FuncJSON',
  'REST_SkladTerm.U_LogStoreDocument',
  'REST_SkladTerm.U_Queue',
  'REST_SkladTerm.U_Requests',
  'REST_SkladTerm.U_SQLQueries',
  'REST_SkladTerm.U_TemporaryStorage',
  'REST_SkladTerm.U_Translation',
  'REST_SkladTerm_Special.U_Const',
  'REST_SkladTerm_Special.U_StandardHooks',
  'StandardUnits.U_DataSet',
  'StandardUnits.U_Relation';

////////////////////////////////////////////////////////////////////////////////
procedure getAuxField(Self: TNxWebServicesHelper; ARequest: TNxHTTPRequest;
  AResponse: TNxHTTPResponse; slPath: TStringList);
var
  mModule: String;
  mAuxFieldReadOnly: Boolean;
begin
  mModule := getHeaderValue(ARequest, 'ModuleCode');
  HTTPResponse(AResponse, HTTP_SC_OK, ContentType_JSON, PlainResponse(StoreDocumentAuxTextField(mModule, mAuxFieldReadOnly)));
end;

////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
procedure putTransferWithoutDocStopPicking(Self: TNxWebServicesHelper; ARequest: TNxHTTPRequest;
  AResponse: TNxHTTPResponse; slPath: TStringList);
var
  mJSON_Root: TJSONSuperObject;
  jsonSerNums: TJSONSuperObjectArray;
  mPreV, mPreP, mStoreBatch, mRow, mDocRowBatch: TNxCustomBusinessObject;
  mRows, mDocRowBatches: TNxCustomBusinessMonikerCollection;
  i: Integer;
  jsonCustomFields: TJSONSuperObjectArray;
  mTemporaryStorageID: Integer;
  mOS: TNxCustomObjectSpace;
  dtJSONRows, dtDocumentQuantity: TMemTable;
  mDIM: TNxDocumentImportManager;
  mParams: TNxParameters;
  mPreV_ID, mPreP_ID, mLSDIn_ID, mLSDOut_ID, mUser_ID, mAuxField, mModule, mDocType, mPersonField, mSerNum_ID, mStoreBatch_ID: String;
  mRequestID: String;
  mAuxReadOnly: Boolean;

  procedure fillCustomFields;
  var
    j: Integer;
  begin
    // kontrola, zda jsou nejaka pole definovana
    if((mJSON_Root.A['rows'].O[dtJSONRows.FieldByName('jsonIndex').AsInteger].N['customFields'].DataType = jtNull)
        or (mJSON_Root.A['rows'].O[dtJSONRows.FieldByName('jsonIndex').AsInteger].N['customFields'].DataType = -1)) then
      exit;

    jsonCustomFields := mJSON_Root.A['rows'].O[dtJSONRows.FieldByName('jsonIndex').AsInteger].A['customFields'];

    for j := 0 to jsonCustomFields.Length - 1 do
    begin
      if(jsonCustomFields.O[j].S['type'] = 'text') then
      begin
        mRow.SetFieldValueAsString(jsonCustomFields.O[j].S['field'], jsonCustomFields.O[j].S['textValue']);
      end
      else if(jsonCustomFields.O[j].S['type'] = 'number') then
      begin
        mRow.SetFieldValueAsInteger(jsonCustomFields.O[j].S['field'], jsonCustomFields.O[j].I['numberValue']);
      end;
    end;
  end;

  // vrati radu dokladu
  function GetDocQueueForDocument(AOS: TNxCustomObjectSpace; AModule, ADocType, AUser_ID, ADefaultDocQueue_ID: String; ASourceDocType: String = '';
    ADocument: TNxCustomBusinessObject = nil; AStore_ID: String = ''): String;
  var
    mDocQueue_ID: String;
  begin
    Result := '';

    mDocQueue_ID := GetDocQueue_ID(AOS, AModule, ADocType, AUser_ID, ASourceDocType, ADocument);
    if not CFxOID.IsEmpty(mDocQueue_ID) then
      Result := mDocQueue_ID
    else
      Result := ADefaultDocQueue_ID;
  end;
begin
  if (slPath.Count = 1) then
  begin
    //mDocType := slPath.Strings[1];
  end else
  begin
    ErrREST(ARequest, AResponse, HTTP_SC_BadRequest, getString('wrong_parameters_count'));
    exit;
  end;

  mOS := Self.ObjectSpace;
  LogWriteSectionStart('putTransferWithoutDocStopPicking');

  mUser_ID := getHeaderValue(ARequest, 'UserID');
  mModule := getHeaderValue(ARequest,'ModuleCode');
  mDocType := getHeaderValue(ARequest, 'DocumentType');

  mPreV_ID := '';
  mPreP_ID := '';

  dtJSONRows := TMemTable.Create(nil);
  dtDocumentQuantity := TMemTable.Create(nil);
  mJSON_Root := TJSONSuperObject.ParseString(GetStringFromBytes(ARequest.Content.Content, TEncoding.UTF8), True);
  try
    mRequestID := REST_getJSONStr(mJSON_Root, 'saveRequestID');
    // pred transakci overime, jestli uz tento request nebezi nebo neni dokonce dokonceny. Pokud ne, tak ho zalozime.
    case Request_Start(mOS, mRequestID, 'putTransferWithoutDocStopPicking') of
      1: begin
        ErrREST(ARequest, AResponse, HTTP_SC_ExpectationFailed, getString('request_in_process'));
        exit;
      end;
      2: begin
        HTTPResponse(AResponse, HTTP_SC_OK, ContentType_JSON, PlainResponse(''));
        exit;
      end;
    end;

    mOS.StartTransaction(taReadCommited);
    try
      mPreV := mOS.CreateObject(Class_OutgoingTransfer);
      try
        mTemporaryStorageID := REST_getJSONInt(mJSON_Root, 'tempID');
        mPreV.ExplicitTransaction := True;

        // dataset, do ktereho si preplnime polozky z JSONu
        DataSet_CreataHeader(dtJSONRows, 'jsonIndex=I,StoreDocument2_ID=S10,StoreDocument2Provide_ID=S10,StoreDocument2ProvideRow_ID=S10,' +
          'DocRowBatch_ID=S10,LogStoreDocument2_ID=S10,StoreFrom_ID=S10,StoreTo_ID=S10,StoreCard_ID=S10,StorePositionFrom_ID=S10,' +
          'StoreBatch_ID=S10,StorePositionTo_ID=S10,Processed=B,UnitQuantity=F,UnitRate=F,UnitCode=S10,Division_ID=S10');
        dtJSONRows.AddIndex('ByJsonIndex', 'jsonIndex', [ixUnique]);
        dtJSONRows.IndexName := 'ByJsonIndex';
        //dtJSONRows.AddIndex('ByStoreDocument2_ID', 'StoreDocument2_ID;jsonIndex', [ixUnique]);
        //dtJSONRows.AddIndex('BySD2_IDBatch_ID', 'StoreDocument2_ID;StoreBatch_ID;jsonIndex', [ixUnique]);
        dtJSONRows.Open;
        REST_JsonToDataSet(mJSON_Root.A['rows'], dtJSONRows);
        dtJSONRows.First;

        // dataset pro funkci Create_LogStoreDocument
        DataSet_CreataHeader(dtDocumentQuantity, 'Store_ID=S10,StoreCard_ID=S10,StoreBatch_ID=S10,StorePosition_ID=S10,Quantity=F');
        dtDocumentQuantity.AddIndex('I0', 'Store_ID;StoreCard_ID;StoreBatch_ID;StorePosition_ID', [ixUnique]);
        dtDocumentQuantity.IndexName:= 'I0';
        dtDocumentQuantity.Open;

        // nejdriv vytvorime prevodku vydej
        mPreV.New;
        mPreV.Prefill;
        mPreV.SetFieldValueAsString('Firm_ID', FIRM_OWN);

        if EnterPerson(Self.ObjectSpace, mModule, mDocType, mUser_ID, mPersonField) then
          mPreV.SetFieldValueAsString(mPersonField, REST_getJSONStr(mJSON_Root, 'Person_ID'));

        if EnterDocQueue(Self.ObjectSpace, mModule, mDocType, mUser_ID) then
          mPreV.SetFieldValueAsString('DocQueue_ID', REST_getJSONStr(mJSON_Root, 'DocQueue_ID'))
        else
          mPreV.SetFieldValueAsString('DocQueue_ID', GetDocQueueForDocument(Self.ObjectSpace, mModule, mDocType, mUser_ID, RADA_PREVYDEJ));

        if EnterTransportationType(Self.ObjectSpace, mModule, mDocType, mUser_ID) then
          mPreV.SetFieldValueAsString('TransportationType_ID', REST_getJSONStr(mJSON_Root, 'TransportationType_ID'));

        if EnterFirmOffice(Self.ObjectSpace, mModule, mDocType, mUser_ID) then
          mPreV.SetFieldValueAsString('FirmOffice_ID', REST_getJSONStr(mJSON_Root, 'FirmOffice_ID'));

        // nastavim AuxText
        mAuxField := StoreDocumentAuxTextField(mModule, mAuxReadOnly);
        if (mAuxField <> '') then
        begin
          mPreV.SetFieldValueAsString(mAuxField, mJSON_Root.S['AuxText']);
        end;

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

          if EnterBusOrder(Self.ObjectSpace, mModule, mDocType, mUser_ID) then
            mRow.SetFieldValueAsString('BusOrder_ID', REST_getJSONStr(mJSON_Root, 'BusOrder_ID'));

          if EnterDivision(Self.ObjectSpace, mModule, mDocType, mUser_ID) then
            mRow.SetFieldValueAsString('Division_ID', REST_getJSONStr(mJSON_Root, 'Division_ID'))
          else
            mRow.SetFieldValueAsString('Division_ID', STREDISKO_HLAVNI);

          fillCustomFields;

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
                    mSerNum_ID := SQLSelectStr(Self.ObjectSpace, 'select ID from StoreBatches where Name = ' + QuotedStr(jsonSerNums.O[i].S['SerNumName'])
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
                    mStoreBatch := Self.ObjectSpace.CreateObject(Class_StoreBatch);
                    try
                      mStoreBatch.New;
                      mStoreBatch.Prefill;
                      mStoreBatch.SetFieldValueAsString('StoreCard_ID', mRow.GetFieldValueAsString('StoreCard_ID'));
                      mStoreBatch.SetFieldValueAsBoolean('SerialNumber', True);
                      mStoreBatch.SetFieldValueAsString('Name', jsonSerNums.O[i].S['SerNumName']);
                      mStoreBatch.SetFieldValueAsString('Specification', jsonSerNums.O[i].S['AuxText']);
                      mStoreBatch.Save;
                      mStoreBatch_ID := mStoreBatch.OID;
                    finally
                      mStoreBatch.Free;
                    end;

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
          dtJSONRows.Next;
        end;

        mPreV_ID := mPreV.OID;
        mPreV.Save;

        afterSaveHook(Self.ObjectSpace, mModule, mUser_Id, mPreV, 0, mJSON_Root, dtJSONRows);

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
                  dtJSONRows.FieldByName('UnitRate').AsFloat
                );
            end
            else
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

        // vytvorime polohovak k PreVyd
        if dtDocumentQuantity.RecordCount > 0 then
          if CreateLogStoreDocument(Self.ObjectSpace, mModule, mDocType, mUser_Id, '', mPreV, mJSON_Root, dtJSONRows, dtDocumentQuantity) then
            mLSDOut_ID := REST_Create_LogStoreDocument(mOS, mPreV, '',
              Class_LogStoreOutput,
              GetDocQueueForDocument(Self.ObjectSpace, mModule, DOC_LogStoreOutput, mUser_ID, LogStoreOutput_DocQueue_ID, mDocType, mPreV),
              LogStoreOutput_StoreGateway_ID, dtDocumentQuantity, mUser_Id,
              False, gLog);

        // pak z ni importnim manazerem vytvorime prevodku prijem
        NxSleep(1000);  // pockam, aby nemela stejny cas jako prevodka vydej
        mParams := TNxParameters.Create;
        mDIM := NxCreateDocumentImportManager(mOS, Class_OutgoingTransfer, Class_IncomingTransfer);
        try
          mDIM.AddInputDocument(mPreV.OID);
          mDIM.SelectedHeader := mPreV;
          mDIM.SaveParams(mParams);
          // tento sklad je jen pomocny, sklad v polozkach se nasledne prepise podle JSONu
          mParams.GetOrCreateParam(dtString, 'Store_ID').AsString := SKLAD_HLAVNI;
          mParams.GetOrCreateParam(dtString, 'DocQueue_ID').AsString :=
              GetDocQueueForDocument(Self.ObjectSpace, mModule, DOC_IncomingTransfer, mUser_ID, RADA_PREPRIJEM, mDocType, mPreV);
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
                dtJSONRows.FieldByName('UnitRate').AsFloat
              );
            end;
            dtJSONRows.Next;
          end;

          // vytvorime polohovak k PrePri
          if dtDocumentQuantity.RecordCount > 0 then
            mLSDIn_ID := REST_Create_LogStoreDocument(mOS, mPreP, '',
              Class_LogStoreInput,
              GetDocQueueForDocument(Self.ObjectSpace, mModule, DOC_LogStoreInput, mUser_ID, LogStoreInput_DocQueue_ID, DOC_IncomingTransfer, mPreP),
              LogStoreInput_StoreGateway_ID, dtDocumentQuantity, mUser_Id,
              False, gLog);
        finally
          mDIM.Free;
          mParams.free;
        end;
      finally
        mPreV.Free;
      end;

      // zmeny stavu
      // zmena PRV, pokud se ma menit
      if not CFxOID.IsEmpty(mPreV_ID)
       and not CFxOID.IsEmpty(PRECHOD_VYTVORENI(DOC_OutgoingTransfer, mModule)) then
      begin
        mPreV := Self.ObjectSpace.CreateObject(Class_OutgoingTransfer);
        try
          mPreV.ExplicitTransaction := True;
          mPreV.Load(mPreV_ID, nil);

          glog.WriteEvent(logDebug, 'mPreV.ChangeStatusBySwitchRule - begin - ' + mPreV.OID + ' - ' + PRECHOD_VYTVORENI(DOC_OutgoingTransfer, mModule));
          ChangeStatusByRule(mPreV, PRECHOD_VYTVORENI(DOC_OutgoingTransfer, mModule));
          glog.WriteEvent(logDebug, 'mPreV.ChangeStatusBySwitchRule - end - ' + mPreV.OID);
        finally
          mPreV.Free;
        end;
      end;

      // zmena PRP, pokud se ma menit
      if not CFxOID.IsEmpty(mPreP_ID)
       and not CFxOID.IsEmpty(PRECHOD_VYTVORENI(DOC_IncomingTransfer, mModule)) then
      begin
        mPreP := Self.ObjectSpace.CreateObject(Class_IncomingTransfer);
        try
          mPreP.ExplicitTransaction := True;
          mPreP.Load(mPreP_ID, nil);

          glog.WriteEvent(logDebug, 'mPreP.ChangeStatusBySwitchRule - begin - ' + mPreP.OID + ' - ' + PRECHOD_VYTVORENI(DOC_IncomingTransfer, mModule));
          ChangeStatusByRule(mPreP, PRECHOD_VYTVORENI(DOC_IncomingTransfer, mModule));
          glog.WriteEvent(logDebug, 'mPreP.ChangeStatusBySwitchRule - end - ' + mPreP.OID);
        finally
          mPreP.Free;
        end;
      end;

      // vymaz z TemporaryStorage jeste v transakci
      TemporaryStorage_Delete(mOS, mTemporaryStorageID);

      Request_Finish(mOS, mRequestID);

      mOS.Commit;

      HTTPResponse(AResponse, HTTP_SC_OK, ContentType_JSON, PlainResponse(''));
    except
      mOS.RollBack;
      ErrREST(ARequest, AResponse, HTTP_SC_InternalServerError, getString('error_saving_free_transfer') + ExceptionMessage);
      Request_Cancel(mOS, mRequestID);
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
  ConfirmLSD(mOS, Class_LogStoreOutput, mLSDOut_ID, 'putTransferWithoutDocStopPicking', glog);
  ConfirmLSD(mOS, Class_LogStoreInput, mLSDIn_ID, 'putTransferWithoutDocStopPicking', glog);
end;//putTransferWithoutDocStopPicking
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
procedure putWithoutDocStartPicking(Self: TNxWebServicesHelper; ARequest: TNxHTTPRequest;
  AResponse: TNxHTTPResponse; slPath: TStringList);
var
  mUser_ID, mModule, mDocType, mSql, mAuxField: String;
  json, dialogJSON: TJSONSuperObject;
  tempId: Integer;
  dtHeader, mDialogValues: TMemTable;
  mSL: TStringList;
  mAuxReadOnly: Boolean;
begin
  json := nil;

  LogWriteSectionStart('putWithoutDocStartPicking');
  try
    mUser_ID := getHeaderValue(ARequest, 'UserID');
    mModule := getHeaderValue(ARequest,'ModuleCode');
    mDocType := getHeaderValue(ARequest, 'DocumentType');

    Self.ObjectSpace.StartTransaction(taReadCommited);
    try
      dtHeader := TMemTable.Create(nil);
      mDialogValues := TMemTable.Create(nil);
      mSL := TStringList.Create;
      try
        mSql := 'select' + nxCrLf;

        mAuxField := StoreDocumentAuxTextField(mModule, mAuxReadOnly);
        if mAuxField <> '' then
        begin
          mSql := mSql +
            '  ' + QuotedStr('') + ' as "AuxText",' + nxCrLf +
            '  ' + QuotedStr(NxBoolToString(mAuxReadOnly)) + ' as "AuxReadOnly",' + nxCrLf;
        end;

        mSql := mSql +
          GetSQLDocHeaderParameters(Self.ObjectSpace, mDocType, mModule, mUser_ID, '') +
          FROM_1_RECORD;

        Self.ObjectSpace.SQLSelect2(mSql, dtHeader);
        json := REST_jsonCreate_FromDataSetRow(dtHeader, nil, mSL);

        // dialog
        DataSet_CreataHeader(mDialogValues, REST_DialogValuesDatasetHeader);
        mDialogValues.Open;
        dialogJSON := json.CreateJSON;
        dialogJSON.S['text'] := DialogOnDocSave(Self.ObjectSpace, mDocType, mModule, mUser_ID, '', mDialogValues);
        dialogJSON.O['values'] := REST_jsonCreate_FromDataSet(mDialogValues, nil);
        json.O['Dialog'] := dialogJSON;

        // rovnou ulozime do TemporaryStorage
        tempId := TemporaryStorage_Create(Self.ObjectSpace, json.AsJson(false, true), mModule, mUser_Id, '');
        json.I['tempID'] := tempId;

        HTTPResponse(AResponse, HTTP_SC_OK, ContentType_JSON, json.AsJson(false, true));

        Self.ObjectSpace.Commit;
      finally
        dtHeader.Free;
        mSL.Free;
        mDialogValues.Free;
      end;
    except
      Self.ObjectSpace.RollBack;
      ErrREST(ARequest, AResponse, HTTP_SC_ExpectationFailed, ExceptionMessage);
    end;
  finally
    LogWriteSectionEnd;
  end;
end;
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
// Obsluhuje prijem a vydej
////////////////////////////////////////////////////////////////////////////////
procedure putWithoutDocStopPicking(Self: TNxWebServicesHelper; ARequest: TNxHTTPRequest;
  AResponse: TNxHTTPResponse; slPath: TStringList);
var
  mJSON_Root: TJSONSuperObject;
  mSD, mSDRow, mDocRowBatch, mStoreBatch: TNxCustomBusinessObject;
  mRows, mDocRowBatches: TNxCustomBusinessMonikerCollection;
  i, mRelNumber: Integer;
  mTemporaryStorageID: Integer;
  mOS: TNxCustomObjectSpace;
  jsonSerNums, jsonDocuments, jsonCustomFields: TJSONSuperObjectArray;
  dtJSONRows, dtDocumentQuantity: TMemTable;
  mDIM: TNxDocumentImportManager;
  mParams: TNxParameters;
  mLSD_ID, mUser_ID, mDocType,
    mLogStoreDocumentClass, mLogStoreDocument_DocQueue_ID, mLogStoreDocument_StoreGateway_ID,
    mStoreField, mStorePositionField, mStoreDocumentClass, mRequestID, mDocQueue_ID, mAuxField,
    mModule, mStoreBatch_ID, mPersonField, mSerNum_ID, mLogStoreDocumentDocType, mSD_ID, mStoreBatchNoteField: String;
  mAuxReadOnly: Boolean;

  procedure fillClassAndIdVariables;
  begin
    if mDocType = DOC_ReceiptCard then
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
    else if mDocType = DOC_ReceivedOrder then
    begin
      // u OBP staci nastavit jen tridu, radu a pole se skladem
      mStoreDocumentClass := Class_ReceivedOrder;
      mDocQueue_ID := RADA_OBP;
      mStoreField := 'StoreFrom_ID';
    end
    else begin
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

  procedure fillCustomFields;
  var
    j: Integer;
  begin
    // kontrola, zda jsou nejaka pole definovana
    if((mJSON_Root.A['rows'].O[dtJSONRows.FieldByName('jsonIndex').AsInteger].N['customFields'].DataType = jtNull)
        or (mJSON_Root.A['rows'].O[dtJSONRows.FieldByName('jsonIndex').AsInteger].N['customFields'].DataType = -1)) then
      exit;

    jsonCustomFields := mJSON_Root.A['rows'].O[dtJSONRows.FieldByName('jsonIndex').AsInteger].A['customFields'];

    for j := 0 to jsonCustomFields.Length - 1 do
    begin
      if(jsonCustomFields.O[j].S['type'] = 'text') then
      begin
        mSDRow.SetFieldValueAsString(jsonCustomFields.O[j].S['field'], jsonCustomFields.O[j].S['textValue']);
      end
      else if(jsonCustomFields.O[j].S['type'] = 'number') then
      begin
        mSDRow.SetFieldValueAsInteger(jsonCustomFields.O[j].S['field'], jsonCustomFields.O[j].I['numberValue']);
      end;
    end;
  end;

  procedure SaveDialogValues(ABO: TNxCustomBusinessObject);
  var
    mDialogValues: TMemTable;
    mDialogType: Integer;
    mDialogField: String;
  begin
    mDialogValues := TMemTable.Create(nil);
    try
      DataSet_CreataHeader(mDialogValues, REST_DialogValuesDatasetHeader);
      mDialogValues.Open;
      REST_JsonToDataSet(mJSON_Root.O['Dialog'].A['values'], mDialogValues);

      mDialogValues.First;
      while not mDialogValues.Eof do
      begin
        if(mDialogValues.FieldByName('type').AsString = 'number') then
          ABO.SetFieldValueAsInteger(mDialogValues.FieldByName('field').AsString, mDialogValues.FieldByName('intValue').AsInteger)
        else if(mDialogValues.FieldByName('type').AsString = 'text') then
          ABO.SetFieldValueAsString(mDialogValues.FieldByName('field').AsString, mDialogValues.FieldByName('stringValue').AsString)
        else if(mDialogValues.FieldByName('type').AsString = 'roll') then
          ABO.SetFieldValueAsString(mDialogValues.FieldByName('field').AsString, mDialogValues.FieldByName('rollValueId').AsString);
        mDialogValues.Next;
      end;
    finally
      mDialogValues.Free;
    end;
  end;

  // vrati radu dokladu
  function GetDocQueueForDocument(AOS: TNxCustomObjectSpace; AModule, ADocType, AUser_ID, ADefaultDocQueue_ID: String; ASourceDocType: String = '';
    ADocument: TNxCustomBusinessObject = nil; AStore_ID: String = ''): String;
  var
    mDocQueue_ID: String;
  begin
    Result := '';

    mDocQueue_ID := GetDocQueue_ID(AOS, AModule, ADocType, AUser_ID, ASourceDocType, ADocument);
    if not CFxOID.IsEmpty(mDocQueue_ID) then
      Result := mDocQueue_ID
    else
      Result := ADefaultDocQueue_ID;
  end;
begin
  if (slPath.Count = 2) then
  begin
    mDocType := slPath.Strings[1];
  end else
  begin
    ErrREST(ARequest, AResponse, HTTP_SC_BadRequest, getString('wrong_parameters_count'));
    exit;
  end;

  mOS := Self.ObjectSpace;
  LogWriteSectionStart('putWithoutDocStopPicking');

  fillClassAndIdVariables;

  mUser_ID := getHeaderValue(ARequest, 'UserID');
  mModule := getHeaderValue(ARequest, 'ModuleCode');
  mDocType := getHeaderValue(ARequest, 'DocumentType');

  mSD_ID := '';

  dtJSONRows := TMemTable.Create(nil);
  dtDocumentQuantity := TMemTable.Create(nil);
  mJSON_Root := TJSONSuperObject.ParseString(GetStringFromBytes(ARequest.Content.Content, TEncoding.UTF8), True);
  try
    mRequestID := REST_getJSONStr(mJSON_Root, 'saveRequestID');
    // pred transakci overime, jestli uz tento request nebezi nebo neni dokonce dokonceny. Pokud ne, tak ho zalozime.
    case Request_Start(mOS, mRequestID, 'putWithoutDocStopPicking') of
      1: begin
        ErrREST(ARequest, AResponse, HTTP_SC_ExpectationFailed, getString('request_in_process'));
        exit;
      end;
      2: begin
        HTTPResponse(AResponse, HTTP_SC_OK, ContentType_JSON, PlainResponse(''));
        exit;
      end;
    end;

    mOS.StartTransaction(taReadCommited);
    try
      mSD := mOS.CreateObject(mStoreDocumentClass);
      try
        mTemporaryStorageID := REST_getJSONInt(mJSON_Root, 'tempID');
        mSD.ExplicitTransaction := True;

        // dataset, do ktereho si preplnime polozky z JSONu
        DataSet_CreataHeader(dtJSONRows, 'jsonIndex=I,StoreDocument2_ID=S10,StoreDocument2Provide_ID=S10,StoreDocument2ProvideRow_ID=S10,' +
          'DocRowBatch_ID=S10,LogStoreDocument2_ID=S10,StoreFrom_ID=S10,StoreTo_ID=S10,StoreCard_ID=S10,StorePositionFrom_ID=S10,' +
          'StoreBatch_ID=S10,StorePositionTo_ID=S10,Processed=B,UnitQuantity=F,UnitRate=F,UnitCode=S10,Division_ID=S10,AuxText2=S100' +
          ',AuxText3=S100,AuxText4=S100,StoreCardCategory=I,StoreBatchNoteVisibility=S1,StoreBatchNote=S100');
        dtJSONRows.AddIndex('ByJsonIndex', 'jsonIndex', [ixUnique]);
        dtJSONRows.IndexName := 'ByJsonIndex';
        dtJSONRows.Open;
        REST_JsonToDataSet(mJSON_Root.A['rows'], dtJSONRows);

        // dataset pro funkci Create_LogStoreDocument
        DataSet_CreataHeader(dtDocumentQuantity, 'Store_ID=S10,StoreCard_ID=S10,StoreBatch_ID=S10,StorePosition_ID=S10,Quantity=F');
        dtDocumentQuantity.AddIndex('I0', 'Store_ID;StoreCard_ID;StoreBatch_ID;StorePosition_ID', [ixUnique]);
        dtDocumentQuantity.IndexName:= 'I0';
        dtDocumentQuantity.Open;

        // nejdriv vytvorime doklad
        mSD.New;
        mSD.Prefill;
        mSD.SetFieldValueAsString('Firm_ID', REST_getJSONStr(mJSON_Root, 'Firm_ID'));

        if EnterPerson(Self.ObjectSpace, mModule, mDocType, mUser_ID, mPersonField) then
          mSD.SetFieldValueAsString(mPersonField, REST_getJSONStr(mJSON_Root, 'Person_ID'));

        if EnterDocQueue(Self.ObjectSpace, mModule, mDocType, mUser_ID) then
          mDocQueue_ID := REST_getJSONStr(mJSON_Root, 'DocQueue_ID')
        else
          mDocQueue_ID := GetDocQueueForDocument(Self.ObjectSpace, mModule, mDocType, mUser_ID, mDocQueue_ID);

        mSD.SetFieldValueAsString('DocQueue_ID', mDocQueue_ID);

        if EnterTransportationType(Self.ObjectSpace, mModule, mDocType, mUser_ID) then
          mSD.SetFieldValueAsString('TransportationType_ID', REST_getJSONStr(mJSON_Root, 'TransportationType_ID'));

        if EnterFirmOffice(Self.ObjectSpace, mModule, mDocType, mUser_ID) then
          mSD.SetFieldValueAsString('FirmOffice_ID', REST_getJSONStr(mJSON_Root, 'FirmOffice_ID'));

        // nastavim AuxText
        mAuxField := StoreDocumentAuxTextField(mModule, mAuxReadOnly);
        if (mAuxField <> '') then
        begin
          mSD.SetFieldValueAsString(mAuxField, mJSON_Root.S['AuxText']);
        end;

        // ulozim hodnotu z dialogu
        SaveDialogValues(mSD);

        mRows := mSD.GetCollectionMonikerForFieldCode(mSD.GetFieldCode('Rows'));
        dtJSONRows.First;
        while not dtJSONRows.EOF do
        begin
          mSDRow := mRows.AddNewObject;
          mSDRow.Prefill;
          mSDRow.SetFieldValueAsInteger('RowType', 3);
          mSDRow.SetFieldValueAsString('Store_ID', dtJSONRows.FieldByName(mStoreField).AsString);
          mSDRow.SetFieldValueAsString('StoreCard_ID', dtJSONRows.FieldByName('StoreCard_ID').AsString);
          mSDRow.SetFieldValueAsString('QUnit', dtJSONRows.FieldByName('UnitCode').AsString);
          mSDRow.SetFieldValueAsFloat('UnitQuantity', dtJSONRows.FieldByName('UnitQuantity').AsFloat);

          if EnterBusOrder(Self.ObjectSpace, mModule, mDocType, mUser_ID) then
            mSDRow.SetFieldValueAsString('BusOrder_ID', REST_getJSONStr(mJSON_Root, 'BusOrder_ID'));

          if EnterDivision(Self.ObjectSpace, mModule, mDocType, mUser_ID) then
            mSDRow.SetFieldValueAsString('Division_ID', REST_getJSONStr(mJSON_Root, 'Division_ID'))
          else
            mSDRow.SetFieldValueAsString('Division_ID', STREDISKO_HLAVNI);

          fillCustomFields;

          // u objednavek nevyplnujeme sarze ani ser. cisla
          if mDocType <> DOC_RECEIVEDORDER then
          begin
            // sarze
            if (mSDRow.GetFieldValueAsInteger('StoreCard_ID.Category') = 2)
                and (dtJSONRows.FieldByName('StoreCardCategory').AsInteger = 2) then
            begin
              mDocRowBatches := mSDRow.GetLoadedCollectionMonikerForFieldCode(mSDRow.GetFieldCode('DocRowBatches'));

              // pokud mame ID, tak pridame k radku
              if not CFxOID.IsEmpty(dtJSONRows.FieldByName('StoreBatch_ID').AsString) then
              begin
                mDocRowBatch := mDocRowBatches.AddNewObject;
                mDocRowBatch.SetFieldValueAsString('StoreBatch_ID', dtJSONRows.FieldByName('StoreBatch_ID').AsString);
                mDocRowBatch.SetFieldValueAsString('QUnit', dtJSONRows.FieldByName('UnitCode').AsString);
                mDocRowBatch.SetFieldValueAsFloat('UnitQuantity', dtJSONRows.FieldByName('UnitQuantity').AsFloat);

                afterDocRowBatchFill(Self.ObjectSpace, mModule, mDocRowBatch, mSDRow, mSD, dtJSONRows);
              end
              else // pokud ID NEmame, tak sarzi vytvorim (v tomhle pripade by mela karta mit nastavenou strukturu novych sarzi)
              begin
                // vytvorim sarzi
                mStoreBatch := Self.ObjectSpace.CreateObject(Class_StoreBatch);
                try
                  mStoreBatch.New;
                  mStoreBatch.Prefill;
                  mStoreBatch.SetFieldValueAsString('StoreCard_ID', dtJSONRows.FieldByName('StoreCard_ID').AsString);
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
                dtJSONRows.FieldByName('StoreBatch_ID').AsString := mStoreBatch_ID;
                dtJSONRows.Post;
              end;

              if dtJSONRows.FieldByName('StoreBatchNoteVisibility').AsString in ['2', '3'] then
              begin
                mStoreBatch := Self.ObjectSpace.CreateObject(Class_StoreBatch);
                try
                  mStoreBatch.Load(mDocRowBatch.GetFieldValueAsString('StoreBatch_ID'), nil);
                  mStoreBatch.ExplicitTransaction := True;

                  mStoreBatchNoteField := '';
                  StoreBatchNoteVisibility(Self.ObjectSpace, mModule, mDocType, mUser_ID, '', mStoreBatchNoteField);
                  mStoreBatch.SetFieldValueAsString(mStoreBatchNoteField, dtJSONRows.FieldByName('StoreBatchNote').AsString);

                  mStoreBatch.Save;
                finally
                  mStoreBatch.Free;
                end;
              end;
            end;

            // ser. cisla
            if (mSDRow.GetFieldValueAsInteger('StoreCard_ID.Category') = 1) then
            begin
              mDocRowBatches := mSDRow.GetLoadedCollectionMonikerForFieldCode(mSDRow.GetFieldCode('DocRowBatches'));
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
                    mSerNum_ID := SQLSelectStr(Self.ObjectSpace, 'select ID from StoreBatches where Name = ' + QuotedStr(jsonSerNums.O[i].S['SerNumName'])
                      + ' and StoreCard_ID = ' + QuotedStr(mSDRow.GetFieldValueAsString('StoreCard_ID')) + 'and Hidden = ''N''');
                  end;

                  if mSerNum_ID <> '' then
                  begin
                    mDocRowBatch.SetFieldValueAsString('StoreBatch_ID', mSerNum_ID);
                    // ulozim si ser. cislo do JSONu, protoze ho budu potrebovat pri polohovani
                    jsonSerNums.O[i].S['SerNum_ID'] := mSerNum_ID;
                  end
                  else
                  begin
                    mStoreBatch := Self.ObjectSpace.CreateObject(Class_StoreBatch);
                    try
                      mStoreBatch.New;
                      mStoreBatch.Prefill;
                      mStoreBatch.SetFieldValueAsString('StoreCard_ID', mSDRow.GetFieldValueAsString('StoreCard_ID'));
                      mStoreBatch.SetFieldValueAsBoolean('SerialNumber', True);
                      mStoreBatch.SetFieldValueAsString('Name', jsonSerNums.O[i].S['SerNumName']);
                      mStoreBatch.SetFieldValueAsString('Specification', jsonSerNums.O[i].S['AuxText']);
                      mStoreBatch.Save;
                      mStoreBatch_ID := mStoreBatch.OID;
                    finally
                      mStoreBatch.Free;
                    end;

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
                mDocRowBatch.SetFieldValueAsString('QUnit', mSDRow.GetFieldValueAsString('QUnit'));
                mDocRowBatch.SetFieldValueAsFloat('UnitQuantity', 1);
              end;
            end;
          end;

          putWithoutDocStopPicking_beforeRowSave(mModule, Self.ObjectSpace, mSDRow, dtJSONRows, mJSON_Root);

          dtJSONRows.Next;
        end;

        beforeSaveHook(Self.ObjectSpace, mModule, mSD, 0, mJSON_Root, dtJSONRows);

        mSD_ID := mSD.OID;
        mSD.Save;

        afterSaveHook(Self.ObjectSpace, mModule, mUser_Id, mSD, 0, mJSON_Root, dtJSONRows);

        // k dokladu pripojim vsechny vytvorene dokumenty
        if REST_getJSONBool(mJSON_Root, 'CanTakePhotos') then
        begin
          mRelNumber := GetRelationWithDocument(mDocType);
          jsonDocuments := mJSON_Root.A['documents'];
          for i := 0 to jsonDocuments.Length - 1 do
          begin
            Relation_CreateAndSave(mOS, mRelNumber, mSD_ID, jsonDocuments.S[i], 1);
          end;
        end;

        // naplnime pomocny dataset pro vytvoreni polohovaku
        if(mDocType <> DOC_RECEIVEDORDER) then
        begin
          dtDocumentQuantity.EmptyTable;
          dtJSONRows.First;
          while not dtJSONRows.EOF do
          begin
            if not CFxOID.IsEmpty(dtJSONRows.FieldByName(mStorePositionField).AsString) then
            begin
              jsonSerNums := mJSON_Root.A['rows'].O[dtJSONRows.FieldByName('jsonIndex').AsInteger].A['sernums'];

              // Pokud ma radek seriova cisla, tak ho musim rozpadnout po nich
              if jsonSerNums.Length > 0 then
              begin
                for i := 0 to jsonSerNums.Length - 1 do
                  AddTodtDocumentQuantity(dtDocumentQuantity,
                    dtJSONRows.FieldByName(mStoreField).AsString,
                    dtJSONRows.FieldByName('StoreCard_ID').AsString,
                    jsonSerNums.O[i].S['SerNum_ID'],
                    dtJSONRows.FieldByName(mStorePositionField).AsString,
                    1,
                    dtJSONRows.FieldByName('UnitRate').AsFloat
                    );
              end
              else
                AddTodtDocumentQuantity(dtDocumentQuantity,
                  dtJSONRows.FieldByName(mStoreField).AsString,
                  dtJSONRows.FieldByName('StoreCard_ID').AsString,
                  NxIIfStr(CFxOID.IsEmpty(dtJSONRows.FieldByName('StoreBatch_ID').AsString), 'ZZZZZZZZZZ', dtJSONRows.FieldByName('StoreBatch_ID').AsString),
                  dtJSONRows.FieldByName(mStorePositionField).AsString,
                  dtJSONRows.FieldByName('UnitQuantity').AsFloat,
                  dtJSONRows.FieldByName('UnitRate').AsFloat
                );
            end;
            dtJSONRows.Next;
          end;

          // vytvorime polohovak
          if dtDocumentQuantity.RecordCount > 0 then
            if CreateLogStoreDocument(Self.ObjectSpace, mModule, mDocType, mUser_Id, '', mSD, mJSON_Root, dtJSONRows, dtDocumentQuantity) then
              mLSD_ID := REST_Create_LogStoreDocument(mOS, mSD, '',
                mLogStoreDocumentClass,
                GetDocQueueForDocument(Self.ObjectSpace, mModule, mLogStoreDocumentDocType, mUser_ID, mLogStoreDocument_DocQueue_ID, mDocType, mSD),
                mLogStoreDocument_StoreGateway_ID, dtDocumentQuantity, mUser_Id,
                False, gLog);
        end;
      finally
        mSD.Free;
      end;

      // zmeny stavu
      // zmena PRV, pokud se ma menit
      if (mDocType <> DOC_RECEIVEDORDER)
        and not CFxOID.IsEmpty(mSD_ID)
        and not CFxOID.IsEmpty(PRECHOD_VYTVORENI(mDocType, mModule)) then
      begin
        mSD := Self.ObjectSpace.CreateObject(mStoreDocumentClass);
        try
          mSD.ExplicitTransaction := True;
          mSD.Load(mSD_ID, nil);

          glog.WriteEvent(logDebug, 'mPreV.ChangeStatusBySwitchRule - begin - ' + mSD.OID + ' - ' + PRECHOD_VYTVORENI(mDocType, mModule));
          ChangeStatusByRule(mSD, PRECHOD_VYTVORENI(mDocType, mModule));
          glog.WriteEvent(logDebug, 'mPreV.ChangeStatusBySwitchRule - end - ' + mSD.OID);
        finally
          mSD.Free;
        end;
      end;

      // vymaz z TemporaryStorage jeste v transakci
      TemporaryStorage_Delete(mOS, mTemporaryStorageID);

      Request_Finish(mOS, mRequestID);

      mOS.Commit;

      HTTPResponse(AResponse, HTTP_SC_OK, ContentType_JSON, PlainResponse(''));
    except
      mOS.RollBack;
      ErrREST(ARequest, AResponse, HTTP_SC_InternalServerError, getString('error_saving') + ExceptionMessage);
      Request_Cancel(mOS, mRequestID);
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
  ConfirmLSD(mOS, mLogStoreDocumentClass, mLSD_ID, 'putWithoutDocStopPicking', glog);
end;//putWithoutDocStopPicking
////////////////////////////////////////////////////////////////////////////////

procedure listWithoutDocQueue(Self: TNxWebServicesHelper; ARequest: TNxHTTPRequest;
  AResponse: TNxHTTPResponse; slPath: TStringList);
var
  mDocType, mModule, mUser_ID: String;
  dtRows: TMemTable;
  mSql, mSearchStr: String;
  json, rowJson, rowJsonData: TJSONSuperObject;
begin
  json := nil;
  mSearchStr := '';
  if ((slPath.Count >= 1) and (slPath.Count <= 2)) then
  begin
    if slPath.Count = 2 then
      mSearchStr := slPath.Strings[1];
  end else
  begin
    ErrREST(ARequest, AResponse, HTTP_SC_BadRequest, getString('wrong_parameters_count'));
    exit;
  end;

  mModule := getHeaderValue(ARequest, 'ModuleCode');
  mUser_ID := getHeaderValue(ARequest, 'UserID');
  mDocType := getHeaderValue(ARequest, 'DocumentType');

  dtRows := TMemTable.Create(nil);
  try
    LogWriteSectionStart('listWithoutDocQueue: ' + mModule);

    mSql := GetListWithoutDocQueueSql(Self.ObjectSpace, mModule, mDocType, mUser_ID, mSearchStr);

    Self.ObjectSpace.SQLSelect2(mSql, dtRows);
    LogWriteSectionEnd;

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

      json := REST_jsonCreate_FromDataSet(dtRows, nil, nil);
    end
    else begin
      json := TJSONSuperObject.CreateByDataType(jtArray);
    end;
    LogWriteSectionEnd;

    HTTPResponse(AResponse, HTTP_SC_OK, ContentType_JSON, json.AsJson(false, true));
  finally
    dtRows.Free;
    if Assigned(json) then
      json.Free;
  end;
end;

procedure put_SaveSmallAssetCards(Self: TNxWebServicesHelper; ARequest: TNxHTTPRequest;
  AResponse: TNxHTTPResponse; slPath: TStringList);
var
  mDocType, mModule, mUser_ID, mRequestID, mLastSmallAssetCard_ID: String;
  mOS: TNxCustomObjectSpace;
  mJSON: TJSONSuperObject;
  dtJSONRows: TMemTable;
  mTemporaryStorageID: Integer;
  mSmallAssetCard, mSmallAssetCardRow: TNxCustomBusinessObject;
  mSmallAssetCardRows: TNxCustomBusinessMonikerCollection;
  mQuantity: Double;
begin
  mOS := Self.ObjectSpace;

  mModule := getHeaderValue(ARequest, 'ModuleCode');
  mUser_ID := getHeaderValue(ARequest, 'UserID');
  mDocType := getHeaderValue(ARequest, 'DocumentType');

  dtJSONRows := TMemTable.Create(nil);
  mJSON := TJSONSuperObject.ParseString(GetStringFromBytes(ARequest.Content.Content, TEncoding.UTF8), True);
  LogWriteSectionStart('put_SaveSmallAssetCards');
  try
    mRequestID := REST_getJSONStr(mJSON, 'saveRequestID');
    // pred transakci overime, jestli uz tento request nebezi nebo neni dokonce dokonceny. Pokud ne, tak ho zalozime.
    case Request_Start(mOS, mRequestID, mModule) of
      1: begin
        ErrREST(ARequest, AResponse, HTTP_SC_ExpectationFailed, getString('request_in_process'));
        exit;
      end;
      2: begin
        HTTPResponse(AResponse, HTTP_SC_OK, ContentType_JSON, PlainResponse(''));
        exit;
      end;
    end;

    mOS.StartTransaction(taReadCommited);
    try
      // dataset, do ktereho si preplnime polozky z JSONu
      DataSet_CreataHeader(dtJSONRows, 'jsonIndex=I,StoreDocument2_ID=S10,StoreDocument2Provide_ID=S10,StoreDocument2ProvideRow_ID=S10,' +
        'DocRowBatch_ID=S10,LogStoreDocument2_ID=S10,StoreFrom_ID=S10,StoreTo_ID=S10,StoreCard_ID=S10,StorePositionFrom_ID=S10,' +
        'StoreBatch_ID=S10,StorePositionTo_ID=S10,Processed=B,UnitQuantity=F,UnitRate=F,UnitCode=S10,Division_ID=S10,AuxText2=S100' +
        ',AuxText3=S100,AuxText4=S100,StoreCardCategory=I'
        + putQueueDocDetailStopPicking_rowsDatasetFields(Self.ObjectSpace, mModule));
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
          mSmallAssetCard := mOS.CreateObject(Class_SmallAssetCard);
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

            beforeSaveHook(mOS, mModule, mSmallAssetCard, 0, mJSON, dtJSONRows);
            mSmallAssetCard.Save;
            afterSaveHook(mOS, mModule, mUser_ID, mSmallAssetCard, 0, mJSON, dtJSONRows);
          finally;
            mSmallAssetCard.Free;
          end;

          mLastSmallAssetCard_ID := dtJSONRows.FieldByName('StoreCard_ID').AsString;
          mQuantity := 0;
        end;
      end;

      // vymaz z TemporaryStorage jeste v transakci
      TemporaryStorage_Delete(mOS, mTemporaryStorageID);

      Request_Finish(mOS, mRequestID);

      mOS.Commit;

      HTTPResponse(AResponse, HTTP_SC_OK, ContentType_JSON, PlainResponse(''));
    except
      mOS.RollBack;
      ErrREST(ARequest, AResponse, HTTP_SC_InternalServerError, ExceptionMessage);
      Request_Cancel(mOS, mRequestID);
      exit;
    end;
  finally
    mJSON.Free;
    dtJSONRows.Free;
    LogWriteSectionEnd;
  end;
end;

begin
end.