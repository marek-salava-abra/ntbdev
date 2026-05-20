uses
  'REST_SkladTerm.U_Func',
  'REST_SkladTerm.U_FuncJSON',
  'REST_SkladTerm.U_Inventorization',
  'REST_SkladTerm.U_LogStoreDocument',
  'REST_SkladTerm.U_Requests',
  'REST_SkladTerm.U_SQLQueries',
  'REST_SkladTerm.U_StoreCard',
  'REST_SkladTerm.U_TemporaryStorage',
  'REST_SkladTerm.U_Translation',
  'REST_SkladTerm_Special.U_Const',
  'REST_SkladTerm_Special.U_StandardHooks',
  'StandardUnits.U_DataSet',
  'StandardUnits.U_GetId';

procedure defaultSearchString(AOS: TNxCustomObjectSpace; APath, AResponse: TStringList);
var
  mResult, mDocTypesString: String;
  mDocTypes: TStringList;
begin
  if APath.Count = 2 then
    mDocTypesString := APath.Strings[1]
  else
  begin
    SetPlainResponse(AResponse, getString('wrong_parameters_count'), HTTP_SC_BadRequest);
    exit;
  end;

  mDocTypes := TStringList.Create;
  try
    LogWriteSectionStart('defaultSearchString ' + mDocTypesString);

    // odstranim hranate zavorky
    mDocTypesString := ReplaceStr(mDocTypesString, '["', '');
    mDocTypesString := ReplaceStr(mDocTypesString, '"]', '');
    mDocTypesString := ReplaceStr(mDocTypesString, '","', ',');

    mDocTypes.Delimiter := ',';
    mDocTypes.DelimitedText := mDocTypesString;

    mResult := defaultSearchString_Prefill(AOS, gSkladTermModule, gSkladTermUser_ID, mDocTypes);
  finally
    LogWriteSectionEnd;
    mDocTypes.Free;
  end;

  SetResponse(AResponse, PlainResponse(Trim(mResult)));
end;

procedure listDocQueue(AOS: TNxCustomObjectSpace; APath, AResponse: TStringList);
var
  dtRows: TMemTable;
  mSql, mSearchStr, mDocTypesString: String;
  json: TJSONSuperObject;
  i: Integer;
  mDocTypes: TStringList;
  mTable: String;
  mWithDefaultSearchBoolean: Boolean;
begin
  json := nil;
  mSearchStr := '';
  if ((APath.Count >= 3) and (APath.Count <= 4)) then
  begin
    mDocTypesString := APath.Strings[1];
    mWithDefaultSearchBoolean := APath.Strings[2] = 'true';
    if APath.Count = 4 then
      mSearchStr := APath.Strings[3];
  end else
  begin
    SetPlainResponse(AResponse, getString('wrong_parameters_count'), HTTP_SC_BadRequest);
    exit;
  end;

  dtRows := TMemTable.Create(nil);
  mDocTypes := TStringList.Create;
  json := TJSONSuperObject.CreateByDataType(jtObject);
  try
    LogWriteSectionStart('ListDocQueue ' + mDocTypesString);

    // odstranim hranate zavorky
    mDocTypesString := ReplaceStr(mDocTypesString, '["', '');
    mDocTypesString := ReplaceStr(mDocTypesString, '"]', '');
    mDocTypesString := ReplaceStr(mDocTypesString, '","', ',');

    mDocTypes.Delimiter := ',';
    mDocTypes.DelimitedText := mDocTypesString;

    if pos('[', mDocTypesString) = 1 then
      mDocTypesString := copy(mDocTypesString, 2, Length(mDocTypes) - 2);

    json.S['defaultSearchString'] := defaultSearchString_Prefill(AOS, gSkladTermModule, gSkladTermUser_ID, mDocTypes);

    if mWithDefaultSearchBoolean then
      mSearchStr := defaultSearchString_Prefill(AOS, gSkladTermModule, gSkladTermUser_ID, mDocTypes);

    if mDocTypesString = DOC_PartialInvProtocol then
      mSql := GetListPartialInvProtocolsSql(AOS, gSkladTermModule, gSkladTermDocType, gSkladTermUser_ID, mSearchStr)
    else if mDocTypesString = DOC_MainInvProtocol then
      mSql := GetListMainInvProtocolsSql(AOS, gSkladTermModule, gSkladTermDocType, gSkladTermUser_ID, mSearchStr)
    else
      mSql := GetListDocQueueSql(AOS, gSkladTermModule, gSkladTermUser_ID, mSearchStr, mDocTypes);

    AOS.SQLSelect2(mSql, dtRows);

    LogWriteSectionStart('JSON');
    if dtRows.Active then
    begin
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
    mDocTypes.Free;
    if Assigned(json) then
      json.Free;
  end;
end;

procedure putQueueDocDetailStartPicking(AContext: TNxContext; APath, AResponse: TStringList);
var
  mSql, mDocTypeB, mDoc_ID, mAuxField, mPerson_ID, mDocType,
    mChangeableFields, mWhere, mTable, mStatusField, jsonString, mReport_ID, mWorkingUserName: string;
  mBO, mBO2_BoD, mBO2_OutT, mRow: TNxCustomBusinessObject;
  json, dialogJSON: TJSONSuperObject;
  mRows: TNxCustomBusinessMonikerCollection;
  i, mTempId: Integer;
  dtHeader, dtStoreDocuments: TMemTable;
  dtRows, mDialog, mDialogValues: TMemTable;
  mSL: TStringList;
  mAuxReadOnly: boolean;
  mOS: TNxCustomObjectSpace;
begin
  json := nil;
  if (APath.Count = 2) then
  begin
    mDoc_ID := APath.Strings[1];
  end else
  begin
    SetPlainResponse(AResponse, getString('wrong_parameters_count'), HTTP_SC_BadRequest);
    exit;
  end;

  LogWriteSectionStart('putQueueDocDetailStartPicking');

  mOS := AContext.GetObjectSpace;

  mReport_ID := '';

  mDocType := gSkladTermDocType;
  mDocTypeB := mDocType;
  if (mDocType = DOC_RefundedBillOfDelivery) and useBillOfDeliveryForRefunding then
    mDocType := DOC_BillOfDelivery;

  // ulozim jeste pred transakci, aby nikdo nemohl zacit pracovat na stejnem doklade (hlavne kvuli DOC_LogStoreTransfer)
  try
    mTempId := -1;
    mTempId := TemporaryStorage_Create(mOS, gSkladTermModule, gSkladTermUser_ID, mDoc_ID);
  except
    SetPlainResponse(AResponse, ExceptionMessage, HTTP_SC_ExpectationFailed);
    exit;
  end;

  mOS.StartTransaction(taReadCommited);
  try
    // TODO tohle neni uplne nej zpusob
    mBO := GetStoreDocBO(mOS, mDocType);
    dtHeader := TMemTable.Create(nil);
    dtStoreDocuments := TMemTable.Create(nil);
    dtRows := TMemTable.Create(nil);
    mDialog := TMemTable.Create(nil);
    mDialogValues := TMemTable.Create(nil);
    mSL := TStringList.Create;
    try
      if not Assigned(mBO) then
        RaiseException(getString('not_valid_id'));

      mBO.ExplicitTransaction := True;
      mBO.Load(mDoc_ID, nil);

      mTable := GetTable(mDocType);
      mStatusField := GetStatusField;

      // vratim typ zpet, pokud jsem ho zmenil
      mDocType := mDocTypeB;

      // zmena stavu BO
      // pokud jde o presun mezi pozicemi, tak tam zadne stavy nejsou - musime to resit pres tabulku rozpracovanosti
      if mDocType = DOC_LogStoreTransfer then
      begin
        // kontrola, ze na dokladu jeste nikdo nepracuje
        mSql :=
          'select' + FIRST_TOP(1) + nxCrLf +
          '  SU.Name' + nxCrLf +
          'from ' + REST_TABLE_TemporaryStorage + ' RTS' + nxCrLf +
          'join SecurityUsers SU on SU.ID = RTS.User_ID' + nxCrLf +
          'where' + nxCrLf +
          '  RTS.DataType = ' + QuotedStr(gSkladTermModule) + nxCrLf +
          '  and Document_ID = ' + QuotedStr(mDoc_ID) + nxCrLf +
          '  and ((Status = ' + IntToStr(TempStorageStatus_OPEN) +
          '      and User_ID <> ' + QuotedStr(gSkladTermUser_ID) + ')' + nxCrLf +
          '    or (Status = ' + IntToStr(TempStorageStatus_PAUSED);

        if NoncancelableWorkOnlyOneUser then
          mSql := mSql + nxCrLf +
            '     and User_ID <> ' + QuotedStr(gSkladTermUser_ID) + '))' + nxCrLf
        else
          mSql := mSql +
            '))' + nxCrLf;

        mSql := mSql +
          FIRST_TOP_ORACLE(1);
        mWorkingUserName := SQLSelectStr(mOS, mSql);

        if mWorkingUserName <> '' then
          RaiseException(Format(getString('error_another_user_working'), [mWorkingUserName]));

        // pro FLORES muzu vyplnit osobu skladnika
        if not ABRA then
        begin
          mPerson_ID := SQLSelectStr(mOS, 'select Person_ID from SecurityUsers where ID = ' + QuotedStr(gSkladTermUser_ID));
          if not CFxOID.IsEmpty(mPerson_ID) then
          begin
           mBO.SetFieldValueAsString('StoreMan_ID', gSkladTermUser_ID);
           mBO.Save;
          end;
        end;
      end
      else
      begin
        if pos(mBO.GetFieldValueAsString(mStatusField), STAV_K_VYSKLADNENI(mDocType, gSkladTermModule)) <= 0 then
          RaiseException(getString('issuance_another_user'));

        ChangeStatusByRule(mBO, PRECHOD_ZAHAJENI(mDocType, gSkladTermModule), '0000000000', gSkladTermUser_ID);

        // pokud jde o vyskl. nebo exp. listy, tak musim zmenit stav i podrizenym dokladum
        if mDocType in [DOC_ShippingList, DOC_RemovalList] then
        begin
          mBO2_BoD := mOS.CreateObject(Class_BillOfDelivery);
          mBO2_OutT := mOS.CreateObject(Class_OutgoingTransfer);
          try
            mBO2_BoD.ExplicitTransaction := True;
            mBO2_OutT.ExplicitTransaction := True;

            mSql :=
              'select distinct ' + nxCrLf +
              '  A2.Provide_ID "Provide_ID", ' + nxCrLf +
              '  SD.' + mStatusField + ' "Status_ID", ' + nxCrLf +
              '  SD.DocumentType "DocumentType" ' + nxCrLf +
              'from ' + mTable + '2 A2 ' + nxCrLf +
              'join StoreDocuments SD on SD.id = A2.Provide_ID ' + nxCrLf +
              'where ' + nxCrLf +
              '  A2.Parent_ID = ' + QuotedStr(mDoc_ID);
            mOS.SQLSelect2(mSql, dtStoreDocuments);

            if dtStoreDocuments.Active then
            begin
              dtStoreDocuments.First;
              while not dtStoreDocuments.Eof do
              begin
                if dtStoreDocuments.FieldByName('DocumentType').AsString = DOC_BillOfDelivery then
                begin
                  mBO2_BoD.Load(dtStoreDocuments.FieldByName('Provide_ID').AsString, nil);

                  if mBO2_BoD.GetFieldValueAsString(mStatusField) <> STAV_K_VYSKLADNENI(DOC_BillOfDelivery, gSkladTermModule) then
                    RaiseException(Format(getString('bod_wrong_status'), [mBO2_BoD.GetFieldValueAsString('DisplayName')]));

                  ChangeStatusByRule(mBO2_BoD, PRECHOD_ZAHAJENI(DOC_BillOfDelivery, gSkladTermModule), '0000000000', gSkladTermUser_ID);
                end
                else if dtStoreDocuments.FieldByName('DocumentType').AsString = DOC_OutgoingTransfer then
                begin
                  mBO2_OutT.Load(dtStoreDocuments.FieldByName('Provide_ID').AsString, nil);

                  if mBO2_OutT.GetFieldValueAsString(mStatusField) <> STAV_K_VYSKLADNENI(DOC_OutgoingTransfer, gSkladTermModule) then
                    RaiseException(Format(getString('outtransfer_wrong_status'), [mBO2_OutT.GetFieldValueAsString('DisplayName')]));

                  ChangeStatusByRule(mBO2_OutT, PRECHOD_ZAHAJENI(DOC_OutgoingTransfer, gSkladTermModule), '0000000000', gSkladTermUser_ID);
                end
                else
                  RaiseException(getString('wrong_document_type'));

                dtStoreDocuments.Next;
              end;
            end;
          finally
            mBO2_BoD.Free;
            mBO2_OutT.Free;
          end;
        end;
      end;

      mAuxField := StoreDocumentAuxTextField(gSkladTermModule, mAuxReadOnly);
      mChangeableFields := putQueueDocDetailStartPicking_ChangeableFields(gSkladTermModule);

      mSql := getHeaderSql(mOS, gSkladTermModule, gSkladTermUser_ID, mDoc_ID, mDocType, mAuxField, mAuxReadOnly, mChangeableFields);

      mOS.SQLSelect2(mSql, dtHeader);

      // TODO - predavat si ze ctecky info, jestli se maji vrace polozky. Napr. prijem dle dokladu v Dobrovskem polozky nechce.
      if dtHeader.Active then
      begin
        dtHeader.First;

        if mDocType in [DOC_ShippingList, DOC_RemovalList] then
          mWhere := 'A2.Parent_ID = ' + QuotedStr(mDoc_ID) + nxCrLf
        else
          mWhere := 'SD2.Parent_ID = ' + QuotedStr(mDoc_ID) + nxCrLf;

        // presun mezi pozicemi nema zadne typy radku
        if mDocType = DOC_IssuedOrder then
          mWhere := mWhere +
            '  and ((SD2.Quantity - SD2.DeliveredQuantity) / SD2.UnitRate) > 0' + nxCrLf
        else if mDocType <> DOC_LogStoreTransfer then
        begin
          if ABRA then
            mWhere := mWhere +
              '  and SD2.RowType = 3' + nxCrLf +
              '  and SC.NonStockType = ''N''' + nxCrLf
          else
            mWhere := mWhere +
              '  and SD2.RowType = 3' + nxCrLf +
              '  and SC.IsStockType = ''A''' + nxCrLf;
        end
        {else
          mWhere := mWhere +
            '  and SD2.RowType = 3' + nxCrLf +
            '  and SC.NonStockType = ''N''' + nxCrLf};


        mSql := getRowsSql(mOS, gSkladTermModule, gSkladTermUser_ID, mDocType, mWhere);
        mOS.SQLSelect2(mSql, dtRows);
        if dtRows.Active then
        begin
          dtRows.AddIndex('id', REST_XX_Parent_ID+';OrderForIndex', [ixPrimary]);
          dtRows.IndexName:= 'id';
          mSL.AddObject('rows=', dtRows);

          BeforeJSONCreate(mOS, gSkladTermModule, mDocType, gSkladTermUser_ID, dtRows);
        end;
      end;

      json := REST_jsonCreate_FromDataSetRow(dtHeader, nil, mSL);

      // dialog
      DataSet_CreataHeader(mDialogValues, REST_DialogValuesDatasetHeader);
      mDialogValues.Open;
      dialogJSON := json.CreateJSON;
      dialogJSON.S['text'] := DialogOnDocSave(mOS, mDocType, gSkladTermModule, gSkladTermUser_ID, mDoc_ID, mDialogValues);
      dialogJSON.O['values'] := REST_jsonCreate_FromDataSet(mDialogValues, nil);
      json.O['Dialog'] := dialogJSON;
      TemporaryStorage_Update(mOS, mTempId, json.AsJson(false, true));
      json.I['tempID'] := mTempId;

      BeforeJSONSend(mOS, gSkladTermModule, mDocType, gSkladTermUser_ID, json);
      jsonString := json.AsJson(false, true);

      // tisk
      mReport_ID := REPORT_VYSKLADNENI(mDocType, gSkladTermModule);
      if mReport_ID <> '' then
        PrintReportToPrinterByIDToQueue(AContext, mDoc_ID, '', mReport_ID, '', TISKARNA_SKLAD, gSkladTermUser_ID, 1);

      SetResponse(AResponse, jsonString);

      mOS.Commit;
    finally
      mBO.Free;
      mDialog.Free;
      mDialogValues.Free;
      dtHeader.Free;
      dtStoreDocuments.Free;
      dtRows.Free;
      mSL.Free;
      if Assigned(json) then
        json.Free;
    end;
  except
    mOS.RollBack;
    TemporaryStorage_Delete(mOS, mTempId);
    SetPlainResponse(AResponse, ExceptionMessage, HTTP_SC_ExpectationFailed);
  end;
  LogWriteSectionEnd;
end;

procedure putQueueDocDetailCancelPicking(AOS: TNxCustomObjectSpace; APath, AResponse: TStringList);
var
  mSql, mDoc_ID: string;
  mBO: TNxCustomBusinessObject;
  mTemporaryStorageID: Integer;
begin
  if (APath.Count = 3) then
  begin
    mDoc_ID := APath.Strings[1];
    mTemporaryStorageID := StrToIntDef(APath.Strings[2], 0);
  end else
  begin
    SetPlainResponse(AResponse, getString('wrong_parameters_count'), HTTP_SC_BadRequest);
    exit;
  end;

  LogWriteSectionStart('putQueueDocDetailCancelPicking');

  AOS.StartTransaction(taReadCommited);
  try
    //ukoncim dle typu
    if gSkladTermDocType = DOC_PartialInvProtocol then
      cancelInventorizationByDIP(gSkladTermUser_ID, mDoc_ID, mTemporaryStorageID, AOS)
    else if gSkladTermDocType = DOC_MainInvProtocol then
      cancelInventorizationFree(mTemporaryStorageID, AOS)
    else
      cancelQueue(mDoc_ID, gSkladTermModule, gSkladTermDocType, mTemporaryStorageID, AOS);

    SetResponse(AResponse, PlainResponse(''));
    AOS.Commit;
  except
    AOS.RollBack;
    SetPlainResponse(AResponse, Format(getString('error_canceling_issuance'), [ExceptionMessage]), HTTP_SC_BadRequest);
  end;

  LogWriteSectionEnd;
end;
////////////////////////////////////////////////////////////////////////////////

procedure cancelQueue(mDoc_ID, AModule, ADocType: string; mTemporaryStorageID: integer; os: TNxCustomObjectSpace);
var
  mBO, mBO2_BoD, mBO2_OutT: TNxCustomBusinessObject;
  mSql, mTable, mStatusField, mDocType: String;
  dtStoreDocuments: TMemTable;
begin
  // pokud jde o vratky s frontou vydejek, tak musim volat spravne stavy
  if (ADocType = DOC_RefundedBillOfDelivery) and useBillOfDeliveryForRefunding then
    mDocType := DOC_BillOfDelivery
  else
    mDocType := ADocType;

  mBO := GetStoreDocBO(os, mDocType);
  dtStoreDocuments := TMemTable.Create(nil);
  try
    // pokud jde o presun mezi pozicemi, tak tam zadne stavy nejsou - staci tedy smazat zaznam o rozpracovanosti
    // u ostatnich dokladu menime taky stav
    if mDocType = DOC_LogStoreTransfer then
    begin
        // aktualne pada na nejaky assert failure
        //mBO.SetFieldValueAsString('StoreMan_ID', '');
        //mBO.Save;
    end
    else
    begin
      mTable := GetTable(ADocType);
      mStatusField := GetStatusField;
      mDocType := ADocType;

      mBO.ExplicitTransaction := True;
      mBO.Load(mDoc_ID, nil);
      ChangeStatusByRule(mBO, PRECHOD_PRERUSENI(mDocType, AModule));

      // pokud jde o vyskl. nebo exp. listy, tak musim zmenit stav i podrizenym dokladum
      if mDocType in [DOC_ShippingList, DOC_RemovalList] then
      begin
        mBO2_BoD := os.CreateObject(Class_BillOfDelivery);
        mBO2_OutT := os.CreateObject(Class_OutgoingTransfer);
        try
          mBO2_BoD.ExplicitTransaction := True;
          mBO2_OutT.ExplicitTransaction := True;

          mSql :=
            'select distinct ' + nxCrLf +
            '  A2.Provide_ID "Provide_ID", ' + nxCrLf +
            '  SD.' + mStatusField + ' "Status_ID", ' + nxCrLf +
            '  SD.DocumentType "DocumentType" ' + nxCrLf +
            'from ' + mTable + '2 A2 ' + nxCrLf +
            'join StoreDocuments SD on SD.id = A2.Provide_ID ' + nxCrLf +
            'where ' + nxCrLf +
            '  A2.Parent_ID = ' + QuotedStr(mDoc_ID);
          os.SQLSelect2(mSql, dtStoreDocuments);

          if dtStoreDocuments.Active then
          begin
            dtStoreDocuments.First;
            while not dtStoreDocuments.Eof do
            begin
              if dtStoreDocuments.FieldByName('DocumentType').AsString = DOC_BillOfDelivery then
              begin
                mBO2_BoD.Load(dtStoreDocuments.FieldByName('Provide_ID').AsString, nil);

                ChangeStatusByRule(mBO2_BoD, PRECHOD_PRERUSENI(DOC_BillOfDelivery, AModule));
              end
              else if dtStoreDocuments.FieldByName('DocumentType').AsString = DOC_OutgoingTransfer then
              begin
                mBO2_OutT.Load(dtStoreDocuments.FieldByName('Provide_ID').AsString, nil);

                ChangeStatusByRule(mBO2_OutT, PRECHOD_PRERUSENI(DOC_OutgoingTransfer, AModule));
              end
              else
                RaiseException(getString('wrong_document_type'));

              dtStoreDocuments.Next;
            end;
          end;
        finally
          mBO2_BoD.Free;
          mBO2_OutT.Free;
        end;
      end;
    end;

    TemporaryStorage_Delete(os, mTemporaryStorageID);
  finally
    mBO.Free;
    dtStoreDocuments.Free;
  end;
end;

////////////////////////////////////////////////////////////////////////////////
procedure putQueueDocDetailStopPicking(AOS: TNxCustomObjectSpace; APath: TStringList; ABody: String; AResponse: TStringList);
var
  mSql, mUser_Id, mDocType, mListDocType, mLSD_ID, mDoc_ID, mLastStoreDocument2_ID, mLastStoreBatch_ID, mStoreBatchExpirationField,
    mLSDPrePri_ID, mPrePri_ID, mSDNew_ID, mStore_ID, mStoreCard_ID, mStoreBatch_ID, mStorePosition_ID, mTable, mLastStoreDocument_ID, mStatusField,
    mDocTypeB, mRowId, mSDNewDamaged_ID, mSDClassID, mLSDNotProcessed_ID, mDocQueue_ID, mSDNewRows_ID: String;
  PLMContainerMater_ID: String;
  mSD, mSD2, mBO, mBONew, mSDRow, mBORow, mDocRowBatch, mLSD, mLSDRow, mPrePri, mPrePriRow, mRO, mSDNew, mSDNewRow, mStoreBatch, mJO: TNxCustomBusinessObject;
  json: TJSONSuperObject;
  jsonDataType: TJSONDataType;
  jsonSerNums, jsonCustomFields: TJSONSuperObjectArray;
  mSDRows, mBORows, mDocRowBatches, mLSDRows, mPrePriRows, mSDNewRows: TNxCustomBusinessMonikerCollection;
  i, j, k, l: Integer;
  mSDNewFree, mPrePriFree, mFound, mDamagedFound: Boolean;
  mDifference, mToSubtract, mRowUnitQuantityProcessed, mProvideRowUnitQuantity: Double;
  slMsgId: TStringList;
  dtJSONRows, dtDocumentQuantity, dtStoreDocuments: TMemTable;
  mDIM: TNxDocumentImportManager;
  mParams: TNxParameters;
  mSLROs, mSLRORows, mJOs, mCMs, mProcessedBatches, mStoreDocRows, mNewSDs, mNewLSDs, mNewLSDPrevPs,
    mDamagedDocs, mDamagedRowsDocs: TStringList;
  mTemporaryStorageID: Integer;
  mRequestID, mModule, mWasSelectedByBarcodeFieldName, mAuxField, mAuxFieldTextOld, mStoreField, mStorePositionField,
    mProvideRowField: String;
  mAllSelectedByBarcode, mAuxReadOnly: Boolean;
  mLogStoreDocumentClass, mLogStoreDocumentDocType, mLogStoreDocument_DocQueue_ID, mLogStoreDocument_StoreGateway_ID, mOrderClass: String;
  mLogStoreDocument: TNxLogStoreDocument;

  function containRowWithField(ADataSet: TDataSet; AField, AFieldValue: String): Boolean;
  var
    mBM: TBookmark;
  begin
    Result := false;
    mBM := ADataSet.GetBookmark;
    //ADataSet.Filtered = True;
    ADataSet.First;
    while not ADataSet.EOF do
    begin
      if (ADataSet.FieldByName(AField).AsString = AFieldValue) then
      begin
        Result := True;
        break;
      end;
      ADataSet.Next;
    end;
    //ADataSet.Filtered = False;
    ADataSet.GotoBookmark(mBM);
  end;

  function getSumUnitQuantityForPRFContainerMat_ID(ADataSet: TDataSet; ProvideRow_ID: String; AProcessed, ADamaged: Boolean): Double;
  var
    mBM: TBookmark;
  begin
    Result := 0;
    mBM := ADataSet.GetBookmark;
    ADataSet.First;
    while not ADataSet.EOF do
    begin
      if (ADataSet.FieldByName('Processed').AsBoolean = AProcessed) and (ADataSet.FieldByName('IsDamaged').AsBoolean = ADamaged)
          and (ADataSet.FieldByName('PRFContainerMater_ID').AsString = ProvideRow_ID) then
        Result := Result + ADataSet.FieldByName('UnitQuantity').AsFloat;
      ADataSet.Next;
    end;
    ADataSet.GotoBookmark(mBM);
  end;

  // Pokud je nastaveno pouzivani poznamky a datum expirace na sarzi, tak je vyplni
  // Vyplni bud primo na predanou sarzi, nebo ji loadne dle predaneho ID
  // Pokud je predany objekt, tak ho neukladam
  procedure fillStoreBatchNoteAndExpirationDate(AStoreBatch: TNxCustomBusinessObject; AStoreBatch_ID: String = '');
  var
    mStoreBatchNoteField: String;
    mStoreBatch: TNxCustomBusinessObject;
  begin
    if dtJSONRows.FieldByName('EnterBatchExpirationDate').AsBoolean
      or (dtJSONRows.FieldByName('StoreBatchNoteVisibility').AsString in ['2', '3']) then
    begin
      if not CFxOID.IsEmpty(AStoreBatch_ID) then
        mStoreBatch := AOS.CreateObject(Class_StoreBatch);

      try
        if not CFxOID.IsEmpty(AStoreBatch_ID) then
        begin
          mStoreBatch.Load(AStoreBatch_ID, nil);
          mStoreBatch.ExplicitTransaction := True;
        end
        else
          mStoreBatch := AStoreBatch;

        if dtJSONRows.FieldByName('EnterBatchExpirationDate').AsBoolean
          and (dtJSONRows.FieldByName('StoreBatchExpirationDate').AsString <> '') then
        begin
          if CompareDateTime(CFxDateTime.ISO8601ToDateTime(dtJSONRows.FieldByName('StoreBatchExpirationDate').AsString), EncodeDate(1900, 1, 1))
            > 0 then
          begin
            mStoreBatchExpirationField := 'ExpirationDate$DATE&apos';
            EnterStoreBatchExpirationDate(AOS, mModule, mDocType, mUser_ID, 0, mStoreBatchExpirationField);

            mStoreBatch.SetFieldValueAsDateTime(mStoreBatchExpirationField,
              CFxDateTime.ISO8601ToDateTime(dtJSONRows.FieldByName('StoreBatchExpirationDate').AsString));
          end;
        end;

        if dtJSONRows.FieldByName('StoreBatchNoteVisibility').AsString in ['2', '3'] then
        begin
          mStoreBatchNoteField := '';
          StoreBatchNoteVisibility(AOS, mModule, mDocType, mUser_ID, '', mStoreBatchNoteField);

          mStoreBatch.SetFieldValueAsString(mStoreBatchNoteField, dtJSONRows.FieldByName('StoreBatchNote').AsString);
        end;

        if not CFxOID.IsEmpty(AStoreBatch_ID) then
          mStoreBatch.Save;
      finally
        if not CFxOID.IsEmpty(AStoreBatch_ID) then
        begin
          mStoreBatch.Free;
          mStoreBatch := nil;
        end;
      end;
    end;
  end;

  procedure FillStoreBatches(ARow: TNxCustomBusinessObject);
  var
    mStoreBatch: TNxCustomBusinessObject;
    mStoreBatch_ID, mStoreBatchNoteField: String;
    mQuantity: Double;
    mDocRowBatches: TNxCustomBusinessMonikerCollection;
  begin
    mDocRowBatches := ARow.GetLoadedCollectionMonikerForFieldCode(ARow.GetFieldCode('DocRowBatches'));

    // u PRP sarze nepridavam, jen upravuji mnozstvi
    // TODO potreba upravit na typ dokladu
    if (mModule = 'STD_TransferInQueue') or (mDocType in [DOC_RefundedBillOfDelivery, DOC_RefundedReceiptCard]) then
    begin
      for j := 0 to mDocRowBatches.Count - 1 do
      begin
        mDocRowBatch := mDocRowBatches.BusinessObject(j);

        if mDocRowBatch.GetFieldValueAsString('StoreBatch_ID') <> dtJSONRows.FieldByName('StoreBatch_ID').AsString then
          Continue;

        if Pos(dtJSONRows.FieldByName('StoreBatch_ID').AsString, mProcessedBatches.Text) > 0 then
          exit;

        // vezmu si mnozstvi pro tuto sarzi ze vsech radku s ni
        mQuantity := getSumUnitQuantityForSD2_IDAndBatch_ID(dtJSONRows, mRowId, dtJSONRows.FieldByName('StoreBatch_ID').AsString, True, False,
          mDocRowBatch.GetFieldValueAsFloat('UnitRate'));
        // ulozim si id sarze, abych vedel, ze uz jsem ji zpracoval a dalsi radek s ni preskocil
        mProcessedBatches.Append(dtJSONRows.FieldByName('StoreBatch_ID').AsString);
        mDocRowBatch.SetFieldValueAsFloat('UnitQuantity', mQuantity);

        if CFxFloat.IsZero6(mQuantity) then
          mDocRowBatch.MarkForDelete;
      end;
    end
    else
    begin
      // pokud mame ID, tak pridame k radku
      if not CFxOID.IsEmpty(dtJSONRows.FieldByName('StoreBatch_ID').AsString) then
      begin
        if Pos(dtJSONRows.FieldByName('StoreBatch_ID').AsString, mProcessedBatches.Text) > 0 then
          exit;

        // pridame sarze podle napipane skutecnosti
        mDocRowBatch := mDocRowBatches.AddNewObject;
        // tento Prefill se nam nehodi, Kuba napr. v Dworkinu v hacku v Prefillu vzdy nastavuje NewBatch := True
        //mDocRowBatch.Prefill;

        // vezmu si mnozstvi pro tuto sarzi ze vsech radku s ni
        // ulozim si id sarze, abych vedel, ze uz jsem ji zpracoval a dalsi radek s ni preskocil
        mQuantity := getSumUnitQuantityForSD2_IDAndBatch_ID(dtJSONRows, ARow.OID, dtJSONRows.FieldByName('StoreBatch_ID').AsString, True, False,
          mDocRowBatch.GetFieldValueAsFloat('UnitRate'));
        mProcessedBatches.Append(dtJSONRows.FieldByName('StoreBatch_ID').AsString);
        mDocRowBatch.SetFieldValueAsString('StoreBatch_ID', dtJSONRows.FieldByName('StoreBatch_ID').AsString);
        mDocRowBatch.SetFieldValueAsString('QUnit', mSDRow.GetFieldValueAsString('QUnit'));

        fillStoreBatchNoteAndExpirationDate(nil, dtJSONRows.FieldByName('StoreBatch_ID').AsString);

        if useMainUnits(AOS, mModule, mDocType, mUser_ID) then
          mDocRowBatch.SetFieldValueAsFloat('UnitQuantity', CFxFloat.DivideDef6(mQuantity, ARow.GetFieldValueAsFloat('UnitRate'), 0))
        else
          mDocRowBatch.SetFieldValueAsFloat('UnitQuantity', mQuantity);

        afterDocRowBatchFill(AOS, mModule, mDocRowBatch, mSDRow, mSD, dtJSONRows);
      end
      else // pokud ID NEmame, tak sarzi vytvorim dle generatoru. Pokud generator neni, tak se sarze proste nevytvori
      begin
        GenerateAndFillStoreBatch(ARow);
      end;
    end;
  end;

  procedure GenerateAndFillStoreBatch(ARow: TNxCustomBusinessObject);
  var
    mDocRowBatches: TNxCustomBusinessMonikerCollection;
    mStoreBatch, mDocRowBatch: TNxCustomBusinessObject;
    mStoreBatch_ID: String;
  begin
    mDocRowBatches := ARow.GetLoadedCollectionMonikerForFieldCode(ARow.GetFieldCode('DocRowBatches'));

    // ABRA ma i pri nenastavene strukture vyplnenou hodnout. Vyplneni se pozna podle posledniho znaku A/N
    // FLORES pri nenastavene stukture hodnotu proste uplne smaze, takze lze kontrolovat pouze na prazdny udaj
    if ((ABRA
          and (copy(ARow.GetFieldValueAsString('StoreCard_ID.SerialNumberStructure'), Length(ARow.GetFieldValueAsString('StoreCard_ID.SerialNumberStructure')),
            1) <> 'N'))
      or (not ABRA and (ARow.GetFieldValueAsString('StoreCard_ID.SerialNumberStructure') <> '')))
      or not NxIsEmptyOID(ARow.GetFieldValueAsString('StoreCard_ID.StoreBatchStructure_ID')) then
    begin
      // vytvorim sarzi
      mStoreBatch := AOS.CreateObject(Class_StoreBatch);
      try
        mStoreBatch.New;
        mStoreBatch.Prefill;
        mStoreBatch.SetFieldValueAsString('StoreCard_ID', dtJSONRows.FieldByName('StoreCard_ID').AsString);

        FillStoreBatchNoteAndExpirationDate(mStoreBatch);

        mStoreBatch.Save;
        mStoreBatch_ID := mStoreBatch.OID;
      finally
        mStoreBatch.Free;
      end;

      mDocRowBatch := mDocRowBatches.AddNewObject;
      mDocRowBatch.Prefill;
      mDocRowBatch.SetFieldValueAsBoolean('NewBatch', False);
      mDocRowBatch.SetFieldValueAsString('StoreBatch_ID', mStoreBatch_ID);
      mDocRowBatch.SetFieldValueAsString('QUnit', ARow.GetFieldValueAsString('QUnit'));
      if useMainUnits(AOS, mModule, mDocType, mUser_ID) then
        mDocRowBatch.SetFieldValueAsFloat('UnitQuantity', CFxFloat.DivideDef6(dtJSONRows.FieldByName('UnitQuantity').AsFloat, ARow.GetFieldValueAsFloat('UnitRate'), 0))
      else
        mDocRowBatch.SetFieldValueAsFloat('UnitQuantity', dtJSONRows.FieldByName('UnitQuantity').AsFloat);
    end;
  end;

  procedure fillSerialNumbers;
  var
    mSerNum_ID: String;
    mFound: Boolean;
    mStoreBatch: TNxCustomBusinessObject;
  begin
    // musime do jsonu pro kolekci sernums
    jsonSerNums := json.A['rows'].O[dtJSONRows.FieldByName('jsonIndex').AsInteger].A['sernums'];

    // pokud neni aktivni vlastni ukladani ser. cisel, tak udelam standardne
    if not putQueueDocDetailStopPicking_FillSerialNumbers(AOS, mModule, jsonSerNums, mSDRow, mDocRowBatches) then
    begin
      if (mSDRow.GetFieldValueAsInteger('StoreCard_ID.Category') = 1) then
      begin
        // u PRP musim smazat ser. cisla, ktera se mohla z radku smazat
        // TODO potreba upravit na typ dokladu
        if (mModule = 'STD_TransferInQueue') or (mDocType = DOC_RefundedBillOfDelivery) then
        begin
          // u ser. cisel nechci prochazet nezpracovane radky
          if not dtJSONRows.FieldByName('Processed').AsBoolean then
            exit;

          for j := 0 to mDocRowBatches.Count - 1 do
          begin
            mDocRowBatch := mDocRowBatches.BusinessObject(j);
            mFound := False;

            for k := 0 to jsonSerNums.Length - 1 do
            begin
              if mDocRowBatch.GetFieldValueAsString('StoreBatch_ID') = jsonSerNums.O[k].S['SerNum_ID'] then
              begin
                mFound := True;
                break;
              end;
            end;

            // pokud jsem ser. cislo nenasel, tak ho smazu
            if not mFound then
              mDocRowBatch.MarkForDelete;
          end;
        end
        else
        begin
          for j := 0 to jsonSerNums.Length - 1 do
          begin
            mDocRowBatch := mDocRowBatches.AddNewObject;
            //mDocRowBatch.Prefill;
            if CFxOID.IsEmpty(jsonSerNums.O[j].S['SerNum_ID']) then
            begin
              mSerNum_ID := '';
              if isUsingExistingSerNumberAllowed then
              begin
                // zkusim sarzi ser. cislo
                mSerNum_ID := SQLSelectStr(AOS, 'select ID from StoreBatches where Name = ' + QuotedStr(jsonSerNums.O[j].S['SerNumName'])
                  + ' and StoreCard_ID = ' + QuotedStr(mSDRow.GetFieldValueAsString('StoreCard_ID')) + 'and Hidden = ''N''');
              end;

              // pokud jsem ser. cislo nasel, tak ho vyplnim
              if mSerNum_ID <> '' then
              begin
                mDocRowBatch.SetFieldValueAsString('StoreBatch_ID', mSerNum_ID);
                // ulozim si ser. cislo do JSONu, protoze ho budu potrebovat pri polohovani
                jsonSerNums.O[j].S['SerNum_ID'] := mSerNum_ID;

                // doplnim aux text do specifikace
                mStoreBatch := AOS.CreateObject(Class_StoreBatch);
                try
                  mStoreBatch.ExplicitTransaction := True;
                  mStoreBatch.Load(mSerNum_ID, nil);
                  mStoreBatch.SetFieldValueAsString('Specification', jsonSerNums.O[j].S['AuxText']);
                  mStoreBatch.Save;
                finally
                  mStoreBatch.Free;
                end;
              end
              else
              begin
                mStoreBatch := AOS.CreateObject(Class_StoreBatch);
                try
                  mStoreBatch.ExplicitTransaction := True;
                  mStoreBatch.New;
                  mStoreBatch.Prefill;
                  mStoreBatch.SetFieldValueAsString('StoreCard_ID', mSDRow.GetFieldValueAsString('StoreCard_ID'));
                  mStoreBatch.SetFieldValueAsBoolean('SerialNumber', True);
                  mStoreBatch.SetFieldValueAsString('Name', jsonSerNums.O[j].S['SerNumName']);
                  mStoreBatch.SetFieldValueAsString('Specification', jsonSerNums.O[j].S['AuxText']);
                  mStoreBatch.Save;
                  mStoreBatch_ID := mStoreBatch.OID;
                finally
                  mStoreBatch.Free;
                end;

                // nenasel jsem, takze vytvarim nove
                mDocRowBatch.SetFieldValueAsBoolean('NewBatch', False);
                mDocRowBatch.SetFieldValueAsString('StoreBatch_ID', mStoreBatch_ID);
                // ulozim si ser. cislo do JSONu, protoze ho budu potrebovat pri polohovani
                jsonSerNums.O[j].S['SerNum_ID'] := mStoreBatch_ID;
              end;
            end
            else
            begin
              mDocRowBatch.SetFieldValueAsString('StoreBatch_ID', jsonSerNums.O[j].S['SerNum_ID']);
            end;
            mDocRowBatch.SetFieldValueAsString('QUnit', mSDRow.GetFieldValueAsString('QUnit'));
            mDocRowBatch.SetFieldValueAsFloat('UnitQuantity', 1);
          end;
        end;
      end;
    end;
  end;

  procedure fillCustomFields;
  var
    j: Integer;
  begin
    // kontrola, zda jsou nejaka pole definovana
    if((json.A['rows'].O[dtJSONRows.FieldByName('jsonIndex').AsInteger].N['customFields'].DataType = jtNull)
        or (json.A['rows'].O[dtJSONRows.FieldByName('jsonIndex').AsInteger].N['customFields'].DataType = -1)) then
      exit;

    jsonCustomFields := json.A['rows'].O[dtJSONRows.FieldByName('jsonIndex').AsInteger].A['customFields'];

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

  procedure fillClassAndIdVariables(ADocType: String);
  begin
    if ADocType in [DOC_ReceiptCard, DOC_ProductReception, DOC_RefundedBillOfDelivery,
      DOC_IncomingTransfer, DOC_IncomingSubstitution, DOC_IncomingTransformation,
      DOC_RefundedMaterialDistribution, DOC_IssuedOrder] then
    begin
      mLogStoreDocumentClass := Class_LogStoreInput;
      mLogStoreDocument_DocQueue_ID := LogStoreInput_DocQueue_ID;
      mLogStoreDocumentDocType := DOC_LogStoreInput;
      mLogStoreDocument_StoreGateway_ID := LogStoreInput_StoreGateway_ID;

      if ADocType in [DOC_ReceiptCard, DOC_ProductReception, DOC_IssuedOrder] then
      begin
        mProvideRowField := 'ProvideRow_ID';
        mOrderClass := Class_IssuedOrder;
      end
      else if ADocType in [DOC_RefundedBillOfDelivery, DOC_RefundedMaterialDistribution] then
      begin
        mProvideRowField := 'RDocumentRow_ID';

        if ADocType = DOC_RefundedBillOfDelivery then
          mOrderClass := Class_BillOfDelivery
        else
          mOrderClass := Class_MaterialDistribution;
      end
      else if ADocType in [DOC_IncomingTransfer, DOC_IncomingSubstitution, DOC_IncomingTransformation] then
      begin
        mProvideRowField := 'ProvideRow_ID';

        if ADocType = DOC_IncomingTransfer then
          mOrderClass := Class_OutgoingTransfer
        else if ADocType = DOC_IncomingSubstitution then
          mOrderClass := Class_OutgoingSubstitution
        else if ADocType = DOC_IncomingTransformation then
          mOrderClass := Class_OutgoingTransformation
      end;
    end
    else
    begin
      mLogStoreDocumentClass := Class_LogStoreOutput;
      mLogStoreDocument_DocQueue_ID := LogStoreOutput_DocQueue_ID;
      mLogStoreDocumentDocType := DOC_LogStoreOutput;
      mLogStoreDocument_StoreGateway_ID := LogStoreOutput_StoreGateway_ID;

      if ADocType = DOC_RefundedReceiptCard then
        mProvideRowField := 'RDocumentRow_ID'
      else
        mProvideRowField := 'ProvideRow_ID';

      if ADocType = DOC_MaterialDistribution then
        mOrderClass := Class_MaterialDistribution
      else if ADocType = DOC_RefundedReceiptCard then
        mOrderClass := Class_ReceiptCard
      else
        mOrderClass := Class_ReceivedOrder;
    end;
  end;

  procedure CreateNewDocumentFromJO(ADamaged: Boolean);
  begin
    // pokud mame VP, vytvorim novy skl. doklad pomoci importniho manazera
    mDIM.SaveParams(mParams);

    mJO.Load(mJOs.Strings[0], nil);
    for i := 0 to mJOs.Count - 1 do
      mDIM.AddInputDocument(mJOs.Strings[i]);
    mDIM.SelectedHeader := mJO;

    mParams.GetOrCreateParam(dtString, 'DocQueue_ID').AsString := mSD.GetFieldValueAsString('DocQueue_ID');
    mParams.GetOrCreateParam(dtString, 'Store_ID').AsString := SKLAD_HLAVNI;

    mDIM.LoadParams(mParams);
    mDIM.Execute;
    mSDNew := mDIM.OutputDocument;
    mSDNew.ExplicitTransaction := True;

    // podle JSONu ponizime mnozstvi, pripadne nektere polozky odmazeme
    // protoze ne vsechny polozky a v plnem mnozstvi musely byt na puvodnim skl. dokladu
    mSDNewRows := mSDNew.GetLoadedCollectionMonikerForFieldCode(mSDNew.GetFieldCode('Rows'));
    for i := 0 to mSDNewRows.Count - 1 do
    begin
      mSDNewRow := mSDNewRows.BusinessObject[i];

      if ABRA then
      begin
        //PLMContainerMater_ID := SQLSelectStr(AOS, 'select Parent_ID from PLMMIPLMaterialDistrib where StoreDocument2_ID = ' + QuotedStr(mSDNewRow.OID));
        PLMContainerMater_ID := mSDNewRow.GetFieldValueAsString('Text');
        mProvideRowUnitQuantity := getSumUnitQuantityForPRFContainerMat_ID(dtJSONRows, PLMContainerMater_ID, False, ADamaged);
      end
      else
        mProvideRowUnitQuantity := getSumUnitQuantityForPRFContainerMat_ID(dtJSONRows, mSDNewRow.GetFieldValueAsString('PRFContainerMater_ID'), False, ADamaged);

      if CFxFloat.IsZero6(mProvideRowUnitQuantity) then
      begin
        mSDNewRow.MarkForDelete;
      end
      else begin
        mSDNewRow.SetFieldValueAsFloat('UnitQuantity', mProvideRowUnitQuantity);
        // vyplnim sklad podle toho, co byl puvodne
        if ABRA then
          mSDNewRow.SetFieldValueAsString('Store_ID', getStringFieldByProvideRow_ID(dtJSONRows, 'PRFContainerMater_ID', PLMContainerMater_ID, 'StoreFrom_ID', False))
        else
          mSDNewRow.SetFieldValueAsString('Store_ID', getStringFieldByProvideRow_ID(dtJSONRows, 'PRFContainerMater_ID', mSDNewRow.GetFieldValueAsString('PRFContainerMater_ID'), 'StoreFrom_ID', False));
      end;
    end;
  end;

  procedure CreateNewStoreDocument(ADocs, ARows: TStringList; AProcessed, ADamaged: Boolean);
  var
    mDocQueue_ID: String;
  begin
    // pokud mame OBP, vytvorim novy skl. doklad pomoci importniho manazera
    mDIM.SaveParams(mParams);

    // pokud nejde o objednavku, tak zatim budeme v source document predavat puvodni prijemku (je to asi lepsi nez predavat OV)
    if mDocType = DOC_IssuedOrder then
    begin
      mDocQueue_ID := GetDocQueue_ID(AOS, mModule, DOC_ReceiptCard, mUser_Id, mDocType, mSD);
      mDocQueue_ID := GetValueOrDefault(mDocQueue_ID, GetDefaultDocQueue_ID(DOC_ReceiptCard));
    end
    else
    begin
      mDocQueue_ID := GetDocQueue_ID(AOS, mModule, mDocType, mUser_Id, mDocType, mSD);
      mDocQueue_ID := GetValueOrDefault(mDocQueue_ID, mSD.GetFieldValueAsString('DocQueue_ID'));
    end;

    mRO.Load(ADocs.Strings[0], nil);
    for i := 0 to ADocs.Count - 1 do
      mDIM.AddInputDocument(ADocs.Strings[i]);
    mDIM.SelectedHeader := mRO;

    mParams.GetOrCreateParam(dtString, 'DocQueue_ID').AsString := mDocQueue_ID;
    // pokud jde o PRV -> PRP, tak musim vyplnit sklad
    if mModule = 'STD_TransferInQueue' then
    begin
      // vyplnuji jen pokud je prazdny a nastavim ho zatim na hlavni sklad, pozdeji ho prepisu dle radku
      if ((mParams.GetOrCreateParam(dtString, 'Store_ID').AsString = '')
        or (NxIsEmptyOID(mParams.GetOrCreateParam(dtString, 'Store_ID').AsString))) then
        mParams.GetOrCreateParam(dtString, 'Store_ID').AsString := SKLAD_HLAVNI;
    end;
    // nastavime parametr s ID polozek OBP, ktere chceme importovat
    mParams.GetOrCreateParam(dtString,'SelectedRows').AsString := ARows.Text;
    mDIM.LoadParams(mParams);
    mDIM.Execute;
    mSDNew := mDIM.OutputDocument;
    mSDNew.ExplicitTransaction := True;

    // ABRA Neumi prenest radu imp. managerem??
    if ABRA then
      mSDNew.SetFieldValueAsString('DocQueue_ID', mDocQueue_ID);

    // pokud slo o objednavku, tak musime provest nektere akce, ktere se jinak deji nad skladovymi doklady
    // napr. ulozit hodnoty z dialogu, nastavit AuxText apod.
    if mDocType = DOC_IssuedOrder then
    begin
      // nastavim novy AuxText
      mAuxField := StoreDocumentAuxTextField(mModule, mAuxReadOnly);
      if (mAuxField <> '') and ((not mAuxReadOnly)) then
      begin
        mSDNew.SetFieldValueAsString(mAuxField, json.S['AuxText']);
      end;

      // ukladam hodnoty z dialogu
      SaveDialogValues(mSDNew);

      if EnterTransportationType(AOS, mModule, mDocType, mUser_ID) then
        mSDNew.SetFieldValueAsString('TransportationType_ID', REST_getJSONStr(json, 'TransportationType_ID'));

      // TODO doplneni, zda byl radek vybran nactenim
      // TODO doplneni Aux textu k seriovym cislum
    end;

    // podle JSONu ponizime mnozstvi, pripadne nektere polozky odmazeme
    // protoze ne vsechny polozky a v plnem mnozstvi musely byt na puvodnim skl. dokladu
    mSDNewRows := mSDNew.GetLoadedCollectionMonikerForFieldCode(mSDNew.GetFieldCode('Rows'));
    for i := 0 to mSDNewRows.Count - 1 do
    begin
      mSDNewRow := mSDNewRows.BusinessObject[i];
      mProvideRowUnitQuantity := getSumUnitQuantityForProvideRow_ID(dtJSONRows, mSDNewRow.GetFieldValueAsString(mProvideRowField), AProcessed, ADamaged,
        mSDNewRow.GetFieldValueAsFloat('UnitRate'));
      if CFxFloat.IsZero6(mProvideRowUnitQuantity) then
      begin
        mSDNewRow.MarkForDelete;
      end
      else begin
        // pokud byla ve skl. dokladu jina jednotka nez na OBP, musela by se tady prenastavit, zatim zanedbame
        //mSDNewRow.SetFieldValueAsFloat('QUnit', dtJSONRows.FieldByName('UnitCode').AsString);
        mSDNewRow.SetFieldValueAsFloat('UnitQuantity', mProvideRowUnitQuantity);
        // vyplnim sklad podle toho, co byl puvodne
        mSDNewRow.SetFieldValueAsString('Store_ID',
          getStringFieldByProvideRow_ID(dtJSONRows, 'StoreDocument2ProvideRow_ID', mSDNewRow.GetFieldValueAsString(mProvideRowField), 'StoreFrom_ID', AProcessed));
      end;
    end;
  end;

  procedure ProcessNewStoreDocument(AProcessed, ADamaged: Boolean);
  var
    mOriginSDField: String;
    mStoreBatchNoteField: String;
  begin
    // zkopirujeme popis dokladu, aby jej slo pouzit k opetovnemu vyhledani
    // u prijemky vytvarene z objednavek (Prijem dle OV) neni potreba
    if mDocType <> DOC_IssuedOrder then
    begin
      mSDNew.SetFieldValueAsString('Description', mSD.GetFieldValueAsString('Description'));
      if not ABRA then
        mSDNew.SetFieldValueAsString('PlannedReverseDocumentStore_ID', mSD.GetFieldValueAsString('PlannedReverseDocumentStore_ID'));
    end;

    if (mAuxField <> '') and ((not mAuxReadOnly)) then
    begin
      mSDNew.SetFieldValueAsString(mAuxField, mAuxFieldTextOld);
    end;

    putQueueDocDetailStopPicking_afterSDNewCreateHook(AOS, mModule, mSD, mSDNew, json, dtJSONRows);

    // naplnime polozky skl. dokladu
    mSDNewRows := mSDNew.GetLoadedCollectionMonikerForFieldCode(mSDNew.GetFieldCode('Rows'));
    // jdeme po nezpracovanych polozkach setridenych podle StoreDocument2_ID a StoreBatch_ID
    // pro kazdou skupinku StoreDocument2_ID zalozime polozku, pro kazdou skupinku sarzi vlozime sarzi
    mLastStoreDocument2_ID := '';
    mLastStoreBatch_ID := '';
    dtJSONRows.IndexName := 'BySD2_IDBatch_ID';
    dtJSONRows.First;
    while not dtJSONRows.EOF do
    begin
      if (dtJSONRows.FieldByName('Processed').AsBoolean = AProcessed)
        and (dtJSONRows.FieldByName('IsDamaged').AsBoolean = ADamaged) then
      begin
        // pokud je naplnene StoreDocument2ProvideRow_ID, dohledavame importovanou polozku
        if not CFxOID.IsEmpty(dtJSONRows.FieldByName('StoreDocument2ProvideRow_ID').AsString) then
        begin
          for i := 0 to mSDNewRows.Count - 1 do
          begin
            mSDNewRow := mSDNewRows.BusinessObject[i];
            if mSDNewRow.GetFieldValueAsString('ProvideRow_ID') = dtJSONRows.FieldByName('StoreDocument2ProvideRow_ID').AsString then
            begin
              mSDNewRow.SetFieldValueAsString('BusProject_ID', dtJSONRows.FieldByName('BusProject_ID').AsString);
              mSDNewRow.SetFieldValueAsString('BusOrder_ID', dtJSONRows.FieldByName('BusOrder_ID').AsString);
              mSDNewRow.SetFieldValueAsString('BusTransaction_ID', dtJSONRows.FieldByName('BusTransaction_ID').AsString);
              mDocRowBatches := mSDNewRow.GetLoadedCollectionMonikerForFieldCode(mSDNewRow.GetFieldCode('DocRowBatches'));

              if dtJSONRows.FieldByName('StoreCardCategory').AsInteger = 2 then
              begin
                // pokud je v JSONu zadana sarze, vyplnime ji, jinak nic
                if not CFxOID.IsEmpty(dtJSONRows.FieldByName('StoreBatch_ID').AsString) then
                begin
                  // pokud PRP tak jen upravuji mnozstvi
                  if(mModule = 'STD_TransferInQueue') then
                  begin
                    // najdu spravnou sarzi a upravim mnozstvi
                    for j := 0 to mDocRowBatches.Count - 1 do
                    begin
                      mDocRowBatch := mDocRowBatches.BusinessObject(j);
                      if mDocRowBatch.OID = dtJSONRows.FieldByName('StoreBatch_ID').AsString then
                      begin
                        mDocRowBatch.SetFieldValueAsFloat('UnitQuantity', dtJSONRows.FieldByName('UnitQuantity').AsFloat);
                      end;
                    end;
                  end
                  else
                  begin
                    // muze se stat, ze je jedna sarze rozdelena polohovakem na vice radku, proto ji nesmim pridavat vicekrat
                    if dtJSONRows.FieldByName('StoreBatch_ID').AsString <> mLastStoreBatch_ID then
                    begin
                      mLastStoreBatch_ID := dtJSONRows.FieldByName('StoreBatch_ID').AsString;
                      mDocRowBatch := mDocRowBatches.AddNewObject;
                      mDocRowBatch.SetFieldValueAsString('StoreBatch_ID', dtJSONRows.FieldByName('StoreBatch_ID').AsString);
                      mDocRowBatch.SetFieldValueAsString('QUnit', mSDNewRow.GetFieldValueAsString('QUnit'));
                      mDocRowBatch.SetFieldValueAsFloat('UnitQuantity',
                        getSumUnitQuantityForSD2_IDAndBatch_ID(dtJSONRows,
                          dtJSONRows.FieldByName('StoreDocument2_ID').AsString, dtJSONRows.FieldByName('StoreBatch_ID').AsString, AProcessed, ADamaged,
                          mDocRowBatch.GetFieldValueAsFloat('UnitRate'))
                      );

                      // upravovat sarzi budu jen pokud jde o OV - jinak totiz delam oddeleny doklad a tam se na sarzi sahnout nesmi
                      if mDocType = DOC_IssuedOrder then
                      begin
                        fillStoreBatchNoteAndExpirationDate(nil, dtJSONRows.FieldByName('StoreBatch_ID').AsString);
                      end;
                    end;
                  end;
                end
                else
                  GenerateAndFillStoreBatch(mSDNewRow);
              end;

              // pridame pripadna ser. cisla
              jsonSerNums := json.A['rows'].O[dtJSONRows.FieldByName('jsonIndex').AsInteger].A['sernums'];
              for j := 0 to jsonSerNums.Length - 1 do
              begin
                mDocRowBatch := mDocRowBatches.AddNewObject;
                // pokud se jedna o prijem, musime vytvaret nova seriova cisla
                if ((mDocType = DOC_ReceiptCard) and (CFxOID.IsEmpty(jsonSerNums.O[j].S['SerNum_ID']))) then
                begin
                  mDocRowBatch.SetFieldValueAsBoolean('NewBatch', True);
                  mDocRowBatch.SetFieldValueAsString('NewBatchName', jsonSerNums.O[j].S['SerNumName']);
                  mDocRowBatch.SetFieldValueAsString('NewBatchSpecification', jsonSerNums.O[j].S['AuxText']);
                end
                else begin
                  mDocRowBatch.SetFieldValueAsString('StoreBatch_ID', jsonSerNums.O[j].S['SerNum_ID']);
                end;
                mDocRowBatch.SetFieldValueAsString('QUnit', mSDNewRow.GetFieldValueAsString('QUnit'));
                mDocRowBatch.SetFieldValueAsFloat('UnitQuantity', 1);
              end;

              break;
            end;
          end;
        end
        else if not CFxOID.IsEmpty(dtJSONRows.FieldByName('PRFContainerMater_ID').AsString) then
        begin
          for i := 0 to mSDNewRows.Count - 1 do
          begin
            mSDNewRow := mSDNewRows.BusinessObject[i];

            if ABRA then
              PLMContainerMater_ID := SQLSelectStr(AOS, 'select Parent_ID from PLMMIPLMaterialDistrib where StoreDocument2_ID = ' + QuotedStr(mSDNewRow.OID))
            else
              PLMContainerMater_ID := mSDNewRow.GetFieldValueAsString('PRFContainerMater_ID');

            if PLMContainerMater_ID = dtJSONRows.FieldByName('PRFContainerMater_ID').AsString then
            begin
              mSDNewRow.SetFieldValueAsString('BusProject_ID', dtJSONRows.FieldByName('BusProject_ID').AsString);
              mSDNewRow.SetFieldValueAsString('BusOrder_ID', dtJSONRows.FieldByName('BusOrder_ID').AsString);
              mSDNewRow.SetFieldValueAsString('BusTransaction_ID', dtJSONRows.FieldByName('BusTransaction_ID').AsString);

              // pokud je v JSONu zadana sarze, vyplnime ji, jinak nic
              if not CFxOID.IsEmpty(dtJSONRows.FieldByName('StoreBatch_ID').AsString) then
              begin
                mDocRowBatches := mSDNewRow.GetLoadedCollectionMonikerForFieldCode(mSDNewRow.GetFieldCode('DocRowBatches'));
                mDocRowBatch := mDocRowBatches.AddNewObject;
                mDocRowBatch.SetFieldValueAsString('StoreBatch_ID', dtJSONRows.FieldByName('StoreBatch_ID').AsString);
                mDocRowBatch.SetFieldValueAsString('QUnit', mSDNewRow.GetFieldValueAsString('QUnit'));
                mDocRowBatch.SetFieldValueAsFloat('UnitQuantity', dtJSONRows.FieldByName('UnitQuantity').AsFloat);
              end;
              break;
            end;
          end;
        end
        // pokud StoreDocument2ProvideRow_ID naplnene neni, znamena to, ze to je volna polozka a tim padem ji musime pridat
        else begin
          // zaznamy mame serazene podle puvodniho StoreDocument2_ID a StoreBatch_ID
          // novou polozku zakladame jen pokud se StoreDocument2_ID zmenilo
          if dtJSONRows.FieldByName('StoreDocument2_ID').AsString <> mLastStoreDocument2_ID then
          begin
            mLastStoreDocument2_ID := dtJSONRows.FieldByName('StoreDocument2_ID').AsString;
            mLastStoreBatch_ID := '';
            mSDNewRow := mSDNewRows.AddNewObject;
            mSDNewRow.SetFieldValueAsInteger('RowType', 3);
            mSDNewRow.SetFieldValueAsString('Store_ID', dtJSONRows.FieldByName('StoreFrom_ID').AsString);
            mSDNewRow.SetFieldValueAsString('StoreCard_ID', dtJSONRows.FieldByName('StoreCard_ID').AsString);
            mSDNewRow.SetFieldValueAsString('QUnit', dtJSONRows.FieldByName('UnitCode').AsString);
            mSDNewRow.SetFieldValueAsString('Division_ID', dtJSONRows.FieldByName('Division_ID').AsString);
            mSDNewRow.SetFieldValueAsString('BusProject_ID', dtJSONRows.FieldByName('BusProject_ID').AsString);
            mSDNewRow.SetFieldValueAsString('BusOrder_ID', dtJSONRows.FieldByName('BusOrder_ID').AsString);
            mSDNewRow.SetFieldValueAsString('BusTransaction_ID', dtJSONRows.FieldByName('BusTransaction_ID').AsString);
            mSDNewRow.SetFieldValueAsFloat('UnitQuantity', getSumUnitQuantityForSD2_ID(dtJSONRows,
              dtJSONRows.FieldByName('StoreDocument2_ID').AsString, AProcessed, ADamaged, mAllSelectedByBarcode,
              mSDNewRow.GetFieldValueAsFloat('UnitRate')));

            mDocRowBatches := mSDNewRow.GetLoadedCollectionMonikerForFieldCode(mSDNewRow.GetFieldCode('DocRowBatches'));
            // pridame pripadna ser. cisla
            jsonSerNums := json.A['rows'].O[dtJSONRows.FieldByName('jsonIndex').AsInteger].A['sernums'];
            for j := 0 to jsonSerNums.Length - 1 do
            begin
              mDocRowBatch := mDocRowBatches.AddNewObject;
              // pokud se jedna o prijem, musime vytvaret nova seriova cisla
              if ((mDocType = DOC_ReceiptCard) and (CFxOID.IsEmpty(jsonSerNums.O[j].S['SerNum_ID']))) then
              begin
                mDocRowBatch.SetFieldValueAsBoolean('NewBatch', True);
                mDocRowBatch.SetFieldValueAsString('NewBatchName', jsonSerNums.O[j].S['SerNumName']);
                mDocRowBatch.SetFieldValueAsString('NewBatchSpecification', jsonSerNums.O[j].S['AuxText']);
              end
              else begin
                mDocRowBatch.SetFieldValueAsString('StoreBatch_ID', jsonSerNums.O[j].S['SerNum_ID']);
              end;
              mDocRowBatch.SetFieldValueAsString('QUnit', mSDNewRow.GetFieldValueAsString('QUnit'));
              mDocRowBatch.SetFieldValueAsFloat('UnitQuantity', 1);
            end;
          end;

          if dtJSONRows.FieldByName('StoreBatch_ID').AsString <> mLastStoreBatch_ID then
          begin
            mLastStoreBatch_ID := dtJSONRows.FieldByName('StoreBatch_ID').AsString;
            // pokud je v JSONu zadana sarze, vyplnime ji, jinak nic
            if not CFxOID.IsEmpty(dtJSONRows.FieldByName('StoreBatch_ID').AsString) then
            begin
              mDocRowBatches := mSDNewRow.GetLoadedCollectionMonikerForFieldCode(mSDNewRow.GetFieldCode('DocRowBatches'));
              mDocRowBatch := mDocRowBatches.AddNewObject;
              mDocRowBatch.SetFieldValueAsString('StoreBatch_ID', dtJSONRows.FieldByName('StoreBatch_ID').AsString);
              mDocRowBatch.SetFieldValueAsString('QUnit', mSDNewRow.GetFieldValueAsString('QUnit'));
              mDocRowBatch.SetFieldValueAsFloat('UnitQuantity',
                getSumUnitQuantityForSD2_IDAndBatch_ID(dtJSONRows,
                dtJSONRows.FieldByName('StoreDocument2_ID').AsString, dtJSONRows.FieldByName('StoreBatch_ID').AsString, AProcessed, ADamaged,
                mDocRowBatch.GetFieldValueAsFloat('UnitRate'))
              );
            end;
          end;
        end;
      end;

      dtJSONRows.Next;
    end;

    if mDocType = DOC_IssuedOrder then
      mSDNewRows_ID := AddNewRows(mSDNew, mSDNewRows);

    // doplnim ID puvodniho dokladu
    mOriginSDField := putQueueDocDetailStopPicking_OriginStoreDocumentField(AOS, mModule, mDocType, mUser_Id);
    if (mOriginSDField <> '') and mSDNew.HasField(mOriginSDField) then
      mSDNew.SetFieldValueAsString(mOriginSDField, mSD.OID);

    if mSDNewRows.Count > 0 then
    begin
      gLog.WriteEvent(logDebug, 'Before beforeSaveHook');
      beforeSaveHook(AOS, mModule, mDocType, mUser_Id, mSDNew, 1, json, dtJSONRows);
      gLog.WriteEvent(logDebug, 'After beforeSaveHook');

      mSDNew.Save;

      gLog.WriteEvent(logDebug, 'Before afterSaveHook');
      afterSaveHook(AOS, mModule, mDocType, mUser_Id, mSDNew, 1, json, dtJSONRows);
      gLog.WriteEvent(logDebug, 'After afterSaveHook');

      //mSDNewIsCreated := True;
      if ADamaged then
        mSDNewDamaged_ID := mSDNew.OID
      else
      begin
        mSDNew_ID := mSDNew.OID;
        mNewSDs.Add(mSDNew_ID);
      end;

      // naplnime pomocny dataset pro vytvoreni polohovaku k SDNew
      dtDocumentQuantity.EmptyTable;
      dtJSONRows.First;
      while not dtJSONRows.EOF do
      begin
        if (dtJSONRows.FieldByName('Processed').AsBoolean = AProcessed) and (dtJSONRows.FieldByName('IsDamaged').AsBoolean = ADamaged)
          and not CFxOID.IsEmpty(dtJSONRows.FieldByName('StorePositionFrom_ID').AsString)
        then begin
          AddTodtDocumentQuantity(
            dtDocumentQuantity,
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

      // vytvorime polohovak k SDNew
      if (dtDocumentQuantity.RecordCount > 0)
        and (putQueueDocDetailStopPicking_CreateLogStoreDocumentForNotPickedRows(AOS, mModule, mDocType, mUser_Id)
          or (mDocType = DOC_IssuedOrder))
      then
      begin
        mDocQueue_ID := GetDocQueue_ID(AOS, mModule, mLogStoreDocumentDocType, mUser_ID, mDocType, mSDNew);
        mLSDNotProcessed_ID := REST_Create_LogStoreDocument(AOS, mSDNew, '',
          mLogStoreDocumentClass,
          GetValueOrDefault(mDocQueue_ID, GetDefaultDocQueue_ID(mLogStoreDocumentDocType)),
          mLogStoreDocument_StoreGateway_ID, dtDocumentQuantity, mUser_Id,
          False);

        // pokud vytvarim prijemku z objednavky, tak budu chtit doklad i potvrdit
        if mDocType = DOC_IssuedOrder then
          mNewLSDs.Add(mLSDNotProcessed_ID);
      end;
    end;
  end;

  // prida na doklad nove radky (v JSON oznaceny "IsNew": true). Pokud kvuli tomu vznikne novy doklad, tak se vrati jeho ID
  function AddNewRows(ADocument: TNxCustomBusinessObject; ARows: TNxCustomBusinessMonikerCollection;): String;
  var
    mMySD, mMySDRow, mMyDocRowBatch: TNxCustomBusinessObject;
    mMySDRows, mMyDocRowBatches: TNxCustomBusinessMonikerCollection;
    mMySD_ID, mStoreBatchNoteField: String;
    mSerNum: TJsonSuperObject;
    jsonSerNums: TJSONSuperObjectArray;
    i: Integer;
  begin
    Result := '';
    try
      mMySD := nil;
      mMySD_ID := '';
      // pokud se nove radky oddeli, tak musim vytvorit novy doklad
      if putQueueDocDetailStopPicking_NewRowsToSeperateDoc(AOS, mModule, mDocType) then
      begin
        // pokud neni OBP, zalozime volny doklad
        mMySD := AOS.CreateObject(mSDClassID);
        mMySD.ExplicitTransaction := True;
        mMySD.New;
        mMySD.Prefill;
        mMySD.SetFieldValueAsString('DocQueue_ID', ADocument.GetFieldValueAsString('DocQueue_ID'));
        mMySD.SetFieldValueAsString('Firm_ID', ADocument.GetFieldValueAsString('Firm_ID'));
        mMySDRows := mMySD.GetLoadedCollectionMonikerForFieldCode(mMySD.GetFieldCode('Rows'));
        mMySD_ID := mMySD.OID;
        // odkaz na puvodni OBV
        if cNewRowsDOcIssuedOrderField <> '' then
          mMySD.SetFieldValueAsString(cNewRowsDOcIssuedOrderField, SQLSelectStr(AOS,
              'select ' + FIRST_TOP(1) + ' Provide_ID from StoreDocuments2 where Parent_ID = ' + QuotedStr(ADocument.OID) + ' ' + FIRST_TOP_ORACLE(1)));
      end
      else
      begin
        mMySD := ADocument;
        mMySDRows := ARows;
      end;

      dtJSONRows.Filter := 'IsNew=true';
      dtJSONRows.Filtered := true;
      dtJSONRows.First;
      while not dtJSONRows.EOF do
      begin
        mMySDRow := mMySDRows.AddNewObject;
        mMySDRow.Prefill;

        //do datasetu doplnim ID - kvuli pozdejsimu vytvareni PrePri
        dtJSONRows.Edit;
        dtJSONRows.FieldByName('StoreDocument2_ID').AsString := mMySDRow.OID;
        dtJSONRows.Post;

        mMySDRow.SetFieldValueAsInteger('RowType', 3);
        mMySDRow.SetFieldValueAsString('StoreCard_ID', dtJSONRows.FieldByName('StoreCard_ID').AsString);
        mMySDRow.SetFieldValueAsString('Store_ID', dtJSONRows.FieldByName('StoreFrom_ID').AsString);
        mMySDRow.SetFieldValueAsString('QUnit', dtJSONRows.FieldByName('UnitCode').AsString);
        mMySDRow.SetFieldValueAsFloat('UnitQuantity', dtJSONRows.FieldByName('UnitQuantity').AsFloat);
        mMySDRow.SetFieldValueAsString('Division_ID',
          GetValueOrDefault(GetDivision_ID(AOS, gSkladTermModule, gSkladTermDocType, gSkladTermUser_ID, mMySD), STREDISKO_HLAVNI));

        fillCustomFields;

        //nastavim sarze a ser. cisla
        mMyDocRowBatches := mMySDRow.GetLoadedCollectionMonikerForFieldCode(mMySDRow.GetFieldCode('DocRowBatches'));
        if (mMySDRow.GetFieldValueAsInteger('StoreCard_ID.Category') = 2) then
        begin
          if not CFxOID.IsEmpty(dtJSONRows.FieldByName('StoreBatch_ID').AsString) then
          begin
            // pridame sarze podle napipane skutecnosti
            // u sarzi zatim nepodporujeme vytvareni novych pri prijmu
            mMyDocRowBatch := mMyDocRowBatches.AddNewObject;
            // tento Prefill se nam nehodi, Kuba napr. v Dworkinu v hacku v Prefillu vzdy nastavuje NewBatch := True
            //mDocRowBatch.Prefill;
            mMyDocRowBatch.SetFieldValueAsString('StoreBatch_ID', dtJSONRows.FieldByName('StoreBatch_ID').AsString);
            mMyDocRowBatch.SetFieldValueAsString('QUnit', mMySDRow.GetFieldValueAsString('QUnit'));
            mMyDocRowBatch.SetFieldValueAsFloat('UnitQuantity', dtJSONRows.FieldByName('UnitQuantity').AsFloat);

            fillStoreBatchNoteAndExpirationDate(nil, dtJSONRows.FieldByName('StoreBatch_ID').AsString);
          end
          else
            GenerateAndFillStoreBatch(mMySDRow);
        end;

        if (mMySDRow.GetFieldValueAsInteger('StoreCard_ID.Category') = 1) then
        begin
          // musime do jsonu pro kolekci sernums
          jsonSerNums := json.A['rows'].O[dtJSONRows.FieldByName('jsonIndex').AsInteger].A['sernums'];
          for i := 0 to jsonSerNums.Length - 1 do
          begin
            mMyDocRowBatch := mMyDocRowBatches.AddNewObject;
            mSerNum := jsonSerNums.O[i];
            //mDocRowBatch.Prefill;
            // pokud se jedna o prijem, musime vytvaret nova seriova cisla
            if ((mDocType = DOC_ReceiptCard) and (CFxOID.IsEmpty(mSerNum.S['SerNum_ID']))) then
            begin
              mMyDocRowBatch.SetFieldValueAsBoolean('NewBatch', True);
              mMyDocRowBatch.SetFieldValueAsString('NewBatchName', mSerNum.S['SerNumName']);
              mMyDocRowBatch.SetFieldValueAsString('NewBatchSpecification', mSerNum.S['AuxText']);
            end
            else begin
              mMyDocRowBatch.SetFieldValueAsString('StoreBatch_ID', mSerNum.S['SerNum_ID']);
            end;
            mMyDocRowBatch.SetFieldValueAsString('QUnit', mMySDRow.GetFieldValueAsString('QUnit'));
            mMyDocRowBatch.SetFieldValueAsFloat('UnitQuantity', 1);
          end;
        end;

        putQueueDocDetailStopPicking_afterNewRowFill(AOS, mModule, mDocType, mUser_ID, mMySDRow, mMySD, mMySDRows, dtJSONRows);

        dtJSONRows.Next;
      end;
      dtJSONRows.Filtered := false;

      // pokud jsem delal novy doklad, tak ho ulozim a pak zmenim stav
      if not CFxOID.IsEmpty(mMySD_ID) and (mMySDRows.Count > 0) then
      begin
        mMySD.Save;
      end
      else
        mMySD_ID := '';
    finally
      if Assigned(mMySD) and (mMySD_ID <> '') then
        mMySD.Free;
    end;

    Result := mMySD_ID;
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
      REST_JsonToDataSet(json.O['Dialog'].A['values'], mDialogValues);

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

  procedure findProvideIDs(var AOrders, AOrdersRows, AOrdersDamaged, AOrdersDamagedRows, AJOs, ACMs: TStringList;
    ADamagedFound: Boolean);
  var
    mProvideRow_ID, mProvide_ID: String;
  begin
    ADamagedFound := False;

    mSLROs.Sorted := True;
    mSLRORows.Sorted := True;
    mDamagedDocs.Sorted := True;
    mDamagedRowsDocs.Sorted := True;
    mJOs.Sorted := True;
    mCMs.Sorted := True;
    dtJSONRows.First;
    while not dtJSONRows.EOF do
    begin
      // bereme nezpracovane polozky ze ctecky, hledame v nich odkaz na OBP a polozku OBP
      // pri praci nad OV hledam zpracovane radky, jinak hledame nezpracovane (a pripadne poskozene)
      if(((mDocType = DOC_IssuedOrder) and dtJSONRows.FieldByName('Processed').AsBoolean)
        or ((mDocType <> DOC_IssuedOrder) and (not dtJSONRows.FieldByName('Processed').AsBoolean)
          or (dtJSONRows.FieldByName('IsDamaged').AsBoolean and dtJSONRows.FieldByName('Processed').AsBoolean))) then
      begin
        mProvideRow_ID := dtJSONRows.FieldByName('StoreDocument2ProvideRow_ID').AsString;
        mProvide_ID := dtJSONRows.FieldByName('StoreDocument2Provide_ID').AsString;
        if not CFxOID.IsEmpty(mProvideRow_ID) then
        begin
          // poskozene radky chceme zvlast
          if dtJSONRows.FieldByName('IsDamaged').AsBoolean then
          begin
            ADamagedFound := True;
            // zapamatujeme si vsechny zdrojove OBP (pokud tam nejake jsou)
            if AOrdersDamaged.IndexOf(mProvide_ID) < 0 then
              AOrdersDamaged.Append(mProvide_ID);
            // do SL si sbirame seznam ID polozek OBP, abychom je mohli predat do importniho manazera OBP -> Skl. dokl.
            if AOrdersDamagedRows.IndexOf(mProvideRow_ID) < 0 then
              AOrdersDamagedRows.Append(mProvideRow_ID);
          end
          else
          begin
            // zapamatujeme si vsechny zdrojove OBP (pokud tam nejake jsou)
            if AOrders.IndexOf(mProvide_ID) < 0 then
              AOrders.Append(mProvide_ID);
            // do SL si sbirame seznam ID polozek OBP, abychom je mohli predat do importniho manazera OBP -> Skl. dokl.
            if AOrdersRows.IndexOf(mProvideRow_ID) < 0 then
              AOrdersRows.Append(mProvideRow_ID);
          end;
        end;

        // zkontrolujeme zda nevznikly polozky z VP
        mProvideRow_ID := dtJSONRows.FieldByName('PRFContainerMater_ID').AsString;
        mProvide_ID := dtJSONRows.FieldByName('AccJobOrder_ID').AsString;
        if not CFxOID.IsEmpty(mProvideRow_ID) then
        begin
          // zapamatujeme si vsechny zdrojove VP (pokud tam nejake jsou)
          if AJOs.IndexOf(mProvide_ID) < 0 then
            AJOs.Append(mProvide_ID);
          if ACMs.IndexOf(mProvideRow_ID) < 0 then
            ACMs.Append(mProvideRow_ID);
        end;
      end;
      dtJSONRows.Next;
    end;
  end;

  procedure PreprocessDataset(ADataset: TMemTable);
  begin
    // pokud je povoleny zadavani 0, tak upravim radek - prepnu ho do nezpracovano a nastavim puvodni mnozstvi
    ADataset.First;
    while not ADataset.Eof do
    begin
      if ADataset.FieldByName('EnableZeroQuantity').AsBoolean then
      begin
        if ADataset.FieldByName('Processed').AsBoolean and CFxFloat.IsZero6(ADataset.FieldByName('UnitQuantity').AsFloat) then
        begin
          ADataset.Edit;
          ADataset.FieldByName('Processed').AsBoolean := False;
          ADataset.FieldByName('UnitQuantity').AsFloat := ADataset.FieldByName('UnitQuantityOrig').AsFloat;
          ADataset.Post;
        end;
      end;
      ADataset.Next;
    end;
  end;

  procedure FinishSaving;
  begin
    TemporaryStorage_Finish(AOS, mTemporaryStorageID);
    Request_Finish(AOS, mRequestID);
    AOS.Commit;
    SetResponse(AResponse, PlainResponse(''));
  end;

begin
  json := nil;
  if (APath.Count = 2) then
  begin
    mDoc_ID := APath.Strings[1]; //ocekavam ID dokladu
  end else
  begin
    SetPlainResponse(AResponse, getString('wrong_parameters_count'), HTTP_SC_BadRequest);
    exit;
  end;

  LogWriteSectionStart('putQueueDocDetailStopPicking');

  mUser_Id := gSkladTermUser_ID;
  mModule := gSkladTermModule;
  mDocType := gSkladTermDocType;

  json := TJSONSuperObject.ParseString(ABody, True);
  mTemporaryStorageID := REST_getJSONInt(json, 'tempID');
  mBO := GetStoreDocBO(AOS, mDocType);
  dtJSONRows := TMemTable.Create(nil);
  dtDocumentQuantity := TMemTable.Create(nil);
  dtStoreDocuments := TMemTable.Create(nil);
  mNewSDs := TStringList.Create;
  mNewLSDs := TStringList.Create;
  mNewLSDPrevPs := TStringList.Create;
  mProcessedBatches := TStringList.Create;
  try
    mRequestID := REST_getJSONStr(json, 'saveRequestID');
    // pred transakci overime, jestli uz tento request nebezi nebo neni dokonce dokonceny. Pokud ne, tak ho zalozime.
    case Request_Start(AOS, mRequestID, 'putQueueDocDetailStopPicking') of
      1: begin
        SetPlainResponse(AResponse, getString('request_in_process'), HTTP_SC_ExpectationFailed);
        exit;
      end;
      2: begin
        SetResponse(AResponse, PlainResponse(''));
        exit;
      end;
    end;

    mTable := GetTable(mDocType);
    mStatusField := GetStatusField;

    mListDocType := '';

    glog.WriteEvent(logDebug, 'Doklad - ' + mDocType + ' - ' + REST_getJSONStr(json, 'DisplayName'));

    AOS.StartTransaction(taReadCommited);
    try
      // umoznime pouziti vlastni ukladacky
      if not putQueueDocDetailStopPicking_beforeSaveStart(AOS, mModule, mDocType, mUser_ID, mDoc_ID, json) then
      begin
        FinishSaving;
        exit;
      end;

      // vyskl., exp. list
      if mDocType in [DOC_ShippingList, DOC_RemovalList] then
      begin
        mBO.ExplicitTransaction := True;
        mBO.Load(mDoc_ID, nil);

        // ulozim hodnotu z dialogu
        SaveDialogValues(mBO);

        mBORows := mBO.GetLoadedCollectionMonikerForFieldCode(mBO.GetFieldCode('Rows'));

        // nactu ID vydejek
        mSql :=
          'select distinct ' + nxCrLf +
          '  A2.Provide_ID "Provide_ID", ' + nxCrLf +
          '  SD.' + mStatusField + ' "Status_ID", ' + nxCrLf +
          '  SD.DocumentType "DocumentType" ' + nxCrLf +
          'from ' + mTable + '2 A2 ' + nxCrLf +
          'join StoreDocuments SD on SD.id = A2.Provide_ID ' + nxCrLf +
          'where ' + nxCrLf +
          '  A2.Parent_ID = ' + QuotedStr(mDoc_ID);
        AOS.SQLSelect2(mSql, dtStoreDocuments);

        if not dtStoreDocuments.Active then
          RaiseException(getString('storedocuments_not_found'));
      end
      else
      begin
        // doplnim ID toho jednoho konkretniho skl. dokladu
        DataSet_CreataHeader(dtStoreDocuments, 'Provide_ID=S10,Status_ID=S10,DocumentType=S2');
        dtStoreDocuments.Open;
        dtStoreDocuments.Edit;
        dtStoreDocuments.FieldByName('Provide_ID').AsString := mDoc_ID;
        dtStoreDocuments.Post;
      end;
      dtStoreDocuments.AddIndex('ByProvideID', 'Provide_ID', [ixPrimary]);
      dtStoreDocuments.First;

      // dataset, do ktereho si preplnime polozky z JSONu
      DataSet_CreataHeader(dtJSONRows, 'jsonIndex=I,StoreDocument_ID=S10,StoreDocument2_ID=S10,StoreDocument2Provide_ID=S10,StoreDocument2ProvideRow_ID=S10,' +
        'DocRowBatch_ID=S10,LogStoreDocument2_ID=S10,StoreFrom_ID=S10,StoreTo_ID=S10,StoreCard_ID=S10,StorePositionFrom_ID=S10,IsDamaged=B,' +
        'StoreBatch_ID=S10,StorePositionTo_ID=S10,Processed=B,UnitQuantity=F,UnitRate=F,UnitCode=S10,Division_ID=S10,WasSelectedByBarcode=B,' +
        'IsNew=B,AccJobOrder_ID=S10,PRFContainerMater_ID=S10,BusProject_ID=S10,BusOrder_ID=S10,BusTransaction_ID=S10,EnterBatchExpirationDate=B,' +
        'StoreBatchNoteVisibility=S1,StoreBatchNote=S100,StoreBatchExpirationDate=S16,StoreCardCategory=I,AuxText2=S100,AuxText3=S100,AuxText4=S100,' +
        'UnitQuantityOrig=F,EnableZeroQuantity=B,ContentUnit=S5'
        + RowsDatasetFields(AOS, mModule, mDocType, mUser_Id));
      dtJSONRows.AddIndex('ByJsonIndex', 'jsonIndex', [ixUnique]);
      dtJSONRows.AddIndex('ByStoreDocument2_ID', 'StoreDocument_ID;StoreDocument2_ID;jsonIndex', [ixUnique]);
      dtJSONRows.AddIndex('BySD2_IDBatch_ID', 'StoreDocument_ID;StoreDocument2_ID;StoreBatch_ID;jsonIndex', [ixUnique]);
      dtJSONRows.Open;
      REST_JsonToDataSet(json.A['rows'], dtJSONRows);

      PreprocessDataset(dtJSONRows);

      // dataset pro funkci Create_LogStoreDocument
      DataSet_CreataHeader(dtDocumentQuantity, 'Store_ID=S10,StoreCard_ID=S10,StoreBatch_ID=S10,StorePosition_ID=S10,Quantity=F,ContentUnit=S5');
      dtDocumentQuantity.AddIndex('I0', 'Store_ID;StoreCard_ID;StoreBatch_ID;StorePosition_ID;ContentUnit', [ixUnique]);
      dtDocumentQuantity.IndexName:= 'I0';
      dtDocumentQuantity.Open;

      dtJSONRows.Filter := 'StoreDocument_ID=' + QuotedStr(dtStoreDocuments.FieldByName('Provide_ID').AsString);
      dtJSONRows.Filtered := True;
      while not dtStoreDocuments.Eof do
      begin
        mLSDPrePri_ID := '';
        mPrePriFree := False;
        mPrePri_ID := '';
        mSDNewFree := False;
        mSDNew_ID := '';
        mSDNewRows_ID := '';

        mStoreDocRows := TStringList.Create;
        try
          // v pripade vratek, kde se vychazi z vydejek, musim vytvorit tu novou vratku
          if (mDocType = DOC_RefundedBillOfDelivery) and useBillOfDeliveryForRefunding then
          begin
            mParams := TNxParameters.Create;
            mDIM := NxCreateDocumentImportManager(AOS, Class_BillOfDelivery, Class_RefundedBillOfDelivery);
            try
              mDIM.AddInputDocument(mDoc_ID);
              //vytvorim pomoci importniho manazera
              mDIM.SaveParams(mParams);

              // poresim radu
              mDocQueue_ID := GetDocQueue_ID(AOS, mModule, mDocType, mUser_ID, DOC_BillOfDelivery);
              mParams.GetOrCreateParam(dtString, 'DocQueue_ID').AsString :=
                GetValueOrDefault(mDocQueue_ID, GetDefaultDocQueue_ID(DOC_RefundedBillOfDelivery));

              mDIM.LoadParams(mParams);
              mDIM.Execute;
              mSD2 := mDIM.OutputDocument;

              if ABRA then
                mSD2.SetFieldValueAsString('DocQueue_ID', GetValueOrDefault(mDocQueue_ID, GetDefaultDocQueue_ID(DOC_RefundedBillOfDelivery)));

              mSD2.Save;

              dtStoreDocuments.Edit;
              dtStoreDocuments.FieldByName('Provide_ID').AsString := mSD2.OID;
              dtStoreDocuments.Post;
            finally
              mParams.Free;
              mDIM.Free
            end;
          end;

          fillClassAndIdVariables(mDocType);

          // pokud delam s listy, tak si ulozim jejich typ dokladu a upravim ten se kterym budu dale pracovat
          if mDocType in [DOC_RemovalList, DOC_ShippingList] then
          begin
            mListDocType := mDocType;
            mSD := GetStoreDocBOID(dtStoreDocuments.FieldByName('Provide_ID').AsString, AOS, mDocType);
          end
          else
            mSD := GetStoreDocBO(AOS, mDocType);
          try
            mSD.ExplicitTransaction := True;
            // vydejky, prijemky, ...
            mSD.Load(dtStoreDocuments.FieldByName('Provide_ID').AsString, nil);

            // ulozim si ClassID, protoze u prace nad OV potrebuju ClassID vytvarene prijemky
            if mDocType = DOC_IssuedOrder then
              mSDClassID := Class_ReceiptCard
            else
              mSDClassID := mSD.GetFieldValueAsString('ClassID');

            glog.WriteEvent(logDebug, 'Doklad - ' + mDocType + ' - ' + mSD.GetFieldValueAsString('DisplayName'));

            // pokud jde o OV, tak uplne preskakuju jeji upravu, budu az vytvaret novou prijemku (oddeleny doklad)
            if mDocType <> DOC_IssuedOrder then
            begin
              // pokud jsem v rezimu listu, tak potrebuju nacist ID konkretnich radku, abych nemazal z vydejky radky, ktere jsou
              // k jinemu listu
              // TODO mozna bych mohl ziskat primo z datasetu radku
              if mListDocType in [DOC_ShippingList, DOC_RemovalList] then
              begin
                mSql :=
                  'select ' + nxCrLf +
                  '  A2.ProvideRow_ID "ProvideRow_ID" ' + nxCrLf +
                  'from ' + mTable + '2 A2 ' + nxCrLf +
                  'where ' + nxCrLf +
                  '  A2.Parent_ID = ' + QuotedStr(mDoc_ID);
                AOS.SQLSelect(mSql, mStoreDocRows);
              end;

              // POSTUP
              // zjistime, jestli k tomuto skl. dokladu existuje polohovak
              // budeme predpokladat, ze k jednomu skl. dokladu je jen jedno Vyskladneni z pozic
              mLSD_ID := SQLSelectStr(AOS,
                'select ' + FIRST_TOP(1) + ' LSD2.Parent_ID ' +
                'from StoreDocuments2 SD2 ' +
                'join LogStoreDocuments2 LSD2 on SD2.ID = LSD2.StoreDocRow_ID ' +
                'where SD2.Parent_ID = ' + QuotedStr(dtStoreDocuments.FieldByName('Provide_ID').AsString) +
                FIRST_TOP_ORACLE(1)
              );
              glog.WriteEvent(logDebug, 'LSD find - ' + mLSD_ID);

              // vycistime tento polohovak
              if not NxIsBlank(mLSD_ID) then
              begin
                mLSD := AOS.CreateObject(mLogStoreDocumentClass);
                try
                  mLSD.ExplicitTransaction := True;
                  mLSD.Load(mLSD_ID, nil);

                  // pretypuju a udelam Cancel executed
                  mLogStoreDocument := TNxLogStoreDocument(mLSD);
                  if mLogStoreDocument.GetFieldValueAsBoolean('Executed') then
                  begin
                    if not mLogStoreDocument.CancelExecuted then
                      RaiseException('logstoredocument_cannot_be_canceled');
                  end;

                  glog.WriteEvent(logDebug, 'LSD empty - begin - ' + mLSD.OID + ' - ' + mLSD.DisplayName);
                  mLSDRows := mLSD.GetLoadedCollectionMonikerForFieldCode(mLSD.GetFieldCode('Rows'));
                  // u listu mazu jen konkretni radky, jinak vsechny
                  if mStoreDocRows.Count > 0 then
                  begin
                    for i := 0 to mLSDRows.Count - 1 do
                    begin
                      mLSDRow := mLSDRows.BusinessObject(i);
                      if pos(mLSDRow.GetFieldValueAsString('StoreDocRow_ID'), mStoreDocRows.Text) > 0 then
                        mLSDRow.MarkForDelete;
                    end;
                    glog.WriteEvent(logDebug, 'LSD empty - end - ' + mLSD.OID + ' - ' + mLSD.DisplayName);
                  end
                  else
                  begin
                    mLSDRows.MarkForDeleteAll;
                    glog.WriteEvent(logDebug, 'LSD empty - end - ' + mLSD.OID + ' - ' + mLSD.DisplayName);
                  end;
                  mLSD.Save;
                  mSD.Refresh;
                finally
                  mLSD.Free;
                end;
              end;

              // pokud jde o PRV tak zjistime, jestli existuje PRP a pripadne ji smazeme (vcetne polohovaciho dokladu)
              if mDocType = DOC_OutgoingTransfer then
              begin
                mPrePri_ID := SQLSelectStr(AOS,
                  'select ' + FIRST_TOP(1) + NxCrLf +
           	      '  SD2.Parent_ID ' + NxCrLf +
                  'from StoreDocuments2 SD2 ' + NxCrLf +
                  'join StoreDocuments SD on SD.ID = SD2.Parent_ID' + NxCrLf +
                  'where ' + NxCrLf +
               	  '  SD2.Provide_ID = ' + QuotedStr(mDoc_ID) + NxCrLf +
                  '  and SD.DocumentType = ' + DOC_IncomingTransfer + NxCrLf +
                  FIRST_TOP_ORACLE(1)
                );

                if not NxIsEmptyOID(mPrePri_ID) then
                begin
                  // proverim, jestli existuje pol. doklad k PRP
                  mLSDPrePri_ID := SQLSelectStr(AOS,
                    'select ' + FIRST_TOP(1) + ' LSD2.Parent_ID ' +
                    'from StoreDocuments2 SD2 ' +
                    'join LogStoreDocuments2 LSD2 on SD2.ID = LSD2.StoreDocRow_ID ' +
                    'where SD2.Parent_ID = ' + QuotedStr(mPrePri_ID) +
                    FIRST_TOP_ORACLE(1)
                  );

                  if not NxIsEmptyOID(mLSDPrePri_ID) then
                  begin
                    mLSD := AOS.CreateObject(Class_LogStoreInput);
                    try
                      mLSD.ExplicitTransaction := True;
                      mLSD.Load(mLSDPrePri_ID, nil);

                      // pretypuju a udelam Cancel executed
                      if mLSD.GetFieldValueAsBoolean('Executed') then
                      begin
                        if not TNxLogStoreDocument(mLSD).CancelExecuted then
                          RaiseException('logstoredocument_cannot_be_canceled');
                      end;

                      glog.WriteEvent(logDebug, 'PRP - LSD empty - begin - ' + mLSD.OID + ' - ' + mLSD.DisplayName);
                      mLSDRows := mLSD.GetLoadedCollectionMonikerForFieldCode(mLSD.GetFieldCode('Rows'));
                      mLSDRows.MarkForDeleteAll;
                      glog.WriteEvent(logDebug, 'PRP - LSD empty - end - ' + mLSD.OID + ' - ' + mLSD.DisplayName);

                      mLSD.Save;
                      mSD.Refresh;
                    finally
                      FreeAndNil(mLSD);
                    end;
                  end;

                  mPrePri := AOS.CreateObject(Class_IncomingTransfer);
                  try
                    mPrePri.ExplicitTransaction := True;
                    mPrePri.Load(mPrePri_ID, nil);
                    mPrePriRows := mPrePri.GetLoadedCollectionMonikerForFieldCode(mPrePri.GetFieldCode('Rows'));
                    mPrePriRows.MarkForDeleteAll;
                    mPrePri.Save;
                    mSD.Refresh;
                  finally
                    FreeAndNil(mPrePri);
                  end;
                end;
              end;

              if EnterTransportationType(AOS, mModule, mDocType, mUser_ID) then
                mSD.SetFieldValueAsString('TransportationType_ID', REST_getJSONStr(json, 'TransportationType_ID'));

              // schovam si puvodni hodnotu a nastavim novy AuxText
              mAuxField := StoreDocumentAuxTextField(mModule, mAuxReadOnly);
              if (mAuxField <> '') and ((not mAuxReadOnly)) then
              begin
                mAuxFieldTextOld := mSD.GetFieldValueAsString(mAuxField);
                mSD.SetFieldValueAsString(mAuxField, json.S['AuxText']);
              end;

              // pokud nepracuju v rezimu listu, tak ukladam hodnoty z dialogu
              if mListDocType = '' then
                 SaveDialogValues(mSD);

              // vycistime sarze na radcich tohoto skl. dokladu
              // vymazeme z tohoto skl. dokladu polozky, ktere nejsou zpracovane ve ctecce,
              // pripadne snizime mnozstvi
              // nastavime sarze do polozek, ktere zustaly
              mSDRows := mSD.GetLoadedCollectionMonikerForFieldCode(mSD.GetFieldCode('Rows'));
              for i := 0 to mSDRows.Count - 1 do
              begin
                mSDRow := mSDRows.BusinessObject[i];

                // pokud delam vratku z vydejky, tak potrebju kontroloval RDocumentRow_ID
                if (mDocType = DOC_RefundedBillOfDelivery) and useBillOfDeliveryForRefunding then
                  mRowId := mSDRow.GetFieldValueAsString('RDocumentRow_ID')
                else
                  mRowId := mSDRow.OID;

                // pokud jdu pres listy, tak musim zkontrolovat, ze tenhle radek skl. dokladu patri ke zpracovavanemu listu
                // AKTUALNE NEPODPORUJEME VICE VYSKL. LISTU K JEDNE VYDEJCE, ALE NECHAM TO TU
                if mStoreDocRows.Count > 0 then
                begin
                  if pos(mSDRow.OID, mStoreDocRows.Text) = 0 then
                    continue;
                end;

                // pokud nejde o radek typu 3 nebo o skladovy typ, tak radek preskocim
                if mSDRow.GetFieldValueAsInteger('RowType') <> 3 then
                  continue;

                if (ABRA and (mSDRow.GetFieldValueAsBoolean('StoreCard_ID.NonStockType')))
                    or (not ABRA and not mSDRow.GetFieldValueAsBoolean('StoreCard_ID.IsStockType')) then
                  continue;

                // moznost preskocit konkretni radky
                if putQueueDocDetailStopPicking_IgnoreRow(AOS, mModule, mSDRow) then
                  continue;

                // pokud jde o PRP, tak si nechci mazat sarze, protoze bych ztratil vazbu
                mDocRowBatches := mSDRow.GetLoadedCollectionMonikerForFieldCode(mSDRow.GetFieldCode('DocRowBatches'));
                if (mModule <> 'STD_TransferInQueue') and not (mDocType in [DOC_RefundedBillOfDelivery, DOC_RefundedReceiptCard]) then
                begin
                  mDocRowBatches.MarkForDeleteAll;
                end;

                // vycistim zpracovane sarze pro tento radek
                mProcessedBatches.Clear;

                // zjistime sumu zpracovaneho mnozstvi na tuto polozku
                mRowUnitQuantityProcessed := getSumUnitQuantityForSD2_ID(dtJSONRows, mRowId, True, False, mAllSelectedByBarcode,
                  mSDRow.GetFieldValueAsFloat('UnitRate'));

                // pokud neni zpracovano z teto polozky nic, smazeme ji
                if CFxFloat.IsZero6(mRowUnitQuantityProcessed) then
                begin
                  mSDRow.MarkForDelete;

                  // pokud jdu pres listy, tak mazu i z listu
                  for j := 0 to mBORows.Count - 1 do
                  begin
                    mBORow := mBORows.BusinessObject(j);
                    if mBORow.GetFieldValueAsString('ProvideRow_ID') = mSDRow.OID then
                    begin
                      mBORow.MarkForDelete;
                      break;
                    end;
                  end;
                end
                // jinak nastavime zpracovane mnozstvi
                else begin
                  if useMainUnits(AOS, mModule, mDocType, mUser_ID) then
                    mSDRow.SetFieldValueAsFloat('UnitQuantity', CFxFloat.DivideDef6(mRowUnitQuantityProcessed, mSDRow.GetFieldValueAsFloat('UnitRate'), 0))
                  else
                    mSDRow.SetFieldValueAsFloat('UnitQuantity', mRowUnitQuantityProcessed);

                  // pro jistotu overim, ze opravdu muzu menit sklad a pripadne ho zmenim
                  if (Pos('StoreFrom', putQueueDocDetailStartPicking_ChangeableFields(mModule)) > 0) then
                    mSDRow.SetFieldValueAsString('Store_ID', dtJSONRows.FieldByName('StoreFrom_ID').AsString);

                  // pokud je nadefinovane pole, do ktereho se ma ukladat informace, zda byla polozka vyhledana nactenim caroveho kodu,
                  // ulozime do nej tuto infomaci
                  mWasSelectedByBarcodeFieldName := putQueueDocDetailStopPicking_FieldForWasSelectedByBarcodeInfo(AOS);
                  if not NxIsBlank(mWasSelectedByBarcodeFieldName) then
                    mSDRow.SetFieldValueAsBoolean(mWasSelectedByBarcodeFieldName, mAllSelectedByBarcode);
                  // projdeme vsechny radky JSONu odpovidajici tomuto radku SD2 a naplnime podle nich sarze (pouze pokud nejde o PRP)
                  dtJSONRows.IndexName := 'ByStoreDocument2_ID';
                  //dtJSONRows.FindNearest([mDoc_ID, mRowId, 0]);
                  dtJSONRows.First;
                  //while not dtJSONRows.EOF and (dtJSONRows.FieldByName('StoreDocument2_ID').AsString = mRowId) do
                  while not dtJSONRows.EOF do
                  begin
                    if (dtJSONRows.FieldByName('StoreDocument2_ID').AsString <> mRowId) then
                    begin
                      dtJSONRows.Next;
                      continue;
                    end;

                    // pokud radek neni zpracovany tak ho muzu preskocit
                    // vyjimkou je jen PVP a vratky, kde chci i projit i ty nezpracovane
                    if ((not dtJSONRows.FieldByName('Processed').AsBoolean)
                      and ((mModule <> 'STD_TransferInQueue') and not (mDocType in [DOC_RefundedBillOfDelivery, DOC_RefundedReceiptCard])))
                      or (dtJSONRows.FieldByName('Processed').AsBoolean and dtJSONRows.FieldByName('IsDamaged').AsBoolean) then
                    begin
                      dtJSONRows.Next;
                      continue;
                    end;

                    // pokud je artikl s evidenci sarzi a nejde o PRP
                    if (mSDRow.GetFieldValueAsInteger('StoreCard_ID.Category') = 2) then
                    begin
                      fillStoreBatches(mSDRow);
                    end;
                    // vyplnim ser. cisla
                    fillSerialNumbers;

                    // vyplnim custom fieldy
                    fillCustomFields;

                    dtJSONRows.Next;
                  end;
                end;
              end;

              //pridame nove radky
              if json.B['CanAddItems'] and (mDocType <> DOC_IssuedOrder) then
              begin
                mSDNewRows_ID := AddNewRows(mSD, mSDRows);
              end;

              // ulozime stary skl. doklad
              // hacek pred ulozeni dokladu
              glog.WriteEvent(logDebug, 'Before beforeSaveHook');
              beforeSaveHook(AOS, mModule, mDocType, mUser_Id, mSD, 0, json, dtJSONRows);
              glog.WriteEvent(logDebug, 'After beforeSaveHook');

              if not (CFxOID.IsEmpty(mBO.OID)) and mBO.NeedSave then
              begin
                mBO.Save;
                // po ulozeni musim prenacist radky
                mBORows := mBO.GetLoadedCollectionMonikerForFieldCode(mBO.GetFieldCode('Rows'));
              end;

              // vypneme hacek _AfterSave_PostHook na PreVyd, protoze se v nem vytvari PrePri a potvrzuje polohovak, coz tady nechceme
              //AOS.EnableHooks(False, skBusinessObject, Class_OutgoingTransfer, '_AfterSave_PostHook');
              //try
                if mSD.NeedSave then
                  mSD.Save;
              //finally
              //  AOS.EnableHooks(True, skBusinessObject, Class_OutgoingTransfer);
              //end;
              glog.WriteEvent(logDebug, 'After mSD.Save');

              // hacek po ulozeni dokladu
              glog.WriteEvent(logDebug, 'Before afterSaveHook');
              afterSaveHook(AOS, mModule, mDocType, mUser_Id, mSD, 0, json, dtJSONRows);
              glog.WriteEvent(logDebug, 'After afterSaveHook');

              // v ramci ulozeni prijemky mozna vznikla seriova cisla
              // pokud se zadava pomocny text (napr. IMEI), zatim jsme si ho ulozili do Specification
              // ted je potreba ho preplnit do pole, kam skutecne patri
              // TODO mozna by slo smazat a doplnovat rovnou pri vyplnovani sarzi (fillSerialNumbers)???
              if mDocType = DOC_ReceiptCard then
              begin
                mSDRows := mSD.GetLoadedCollectionMonikerForFieldCode(mSD.GetFieldCode('Rows'));
                for i := 0 to mSDRows.Count - 1 do
                begin
                  mSDRow := mSDRows.BusinessObject[i];
                  if mSDRow.GetFieldValueAsInteger('StoreCard_ID.Category') <> 1 then
                    continue;
                  mDocRowBatches := mSDRow.GetLoadedCollectionMonikerForFieldCode(mSDRow.GetFieldCode('DocRowBatches'));
                  for j := 0 to mDocRowBatches.Count - 1 do
                  begin
                    mDocRowBatch := mDocRowBatches.BusinessObject[j];
                    mStoreBatch := AOS.CreateObject(Class_StoreBatch);
                    try
                      mStoreBatch.ExplicitTransaction := True;
                      mStoreBatch.Load(mDocRowBatch.GetFieldValueAsString('StoreBatch_ID'), nil);
                      if not NxIsBlank(mStoreBatch.GetFieldValueAsString('Specification'))
                        and not NxIsBlank(putQueueDocDetailStopPicking_AuxInfoForSerNumField(AOS)) then
                      begin
                        mStoreBatch.SetFieldValueAsString(putQueueDocDetailStopPicking_AuxInfoForSerNumField(AOS),
                          mStoreBatch.GetFieldValueAsString('Specification'));
                        mStoreBatch.Save;
                      end;
                    finally
                      mStoreBatch.Free;
                    end;
                  end;
                end;
              end;

              // naplnime dataset pro funkci Create_LogStoreDocument z JSONu
              dtDocumentQuantity.EmptyTable;
              dtJSONRows.First;
              while not dtJSONRows.EOF do
              begin
                if dtJSONRows.FieldByName('Processed').AsBoolean
                  and not dtJSONRows.FieldByName('IsDamaged').AsBoolean
                  and not CFxOID.IsEmpty(dtJSONRows.FieldByName('StorePositionFrom_ID').AsString) then
                begin
                  // preskocime nove radky, pokud se oddeluji
                  if (putQueueDocDetailStopPicking_NewRowsToSeperateDoc(AOS, mModule, mDocType) and dtJSONRows.FieldByName('IsNew').AsBoolean) then
                  begin
                    dtJSONRows.Next;
                    continue;
                  end;

                  jsonSerNums := json.A['rows'].O[dtJSONRows.FieldByName('jsonIndex').AsInteger].A['sernums'];

                  // Pokud ma radek seriova cisla, tak ho musim rozpadnout po nich
                  if jsonSerNums.Length > 0 then
                  begin
                    for i := 0 to jsonSerNums.Length - 1 do
                      AddTodtDocumentQuantity(
                        dtDocumentQuantity,
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
                    AddTodtDocumentQuantity(
                      dtDocumentQuantity,
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

              // vytvorime polohovak
              if dtDocumentQuantity.RecordCount > 0 then
                if CreateLogStoreDocument(AOS, mModule, mDocType, mUser_Id, mLSD_ID, mSD, json, dtJSONRows, dtDocumentQuantity) then
                begin
                  mDocQueue_ID := GetDocQueue_ID(AOS, mModule, mLogStoreDocumentDocType, mUser_ID, mDocType, mSD);
                  mLSD_ID := REST_Create_LogStoreDocument(AOS, mSD, mLSD_ID,
                    mLogStoreDocumentClass,
                    GetValueOrDefault(mDocQueue_ID, GetDefaultDocQueue_ID(mLogStoreDocumentDocType)),
                    mLogStoreDocument_StoreGateway_ID, dtDocumentQuantity, mUser_Id,
                    False);
                  mNewLSDs.Add(mLSD_ID);
                end;
              glog.WriteEvent(logDebug, 'After mSD Create_LogStoreDocument');

              // v pripade prevodu vytvorime prevodku prijem a polohovak k ni
              if (mDocType = DOC_OutgoingTransfer)
                and json.B['CreateTransferIn'] then
              begin
                // pokud prevodka prijem existuje, tak si ji nactu,
                // abych do ni mohl naimportovat
                if not NxIsEmptyOID(mPrePri_ID) then
                begin
                  mPrePri := AOS.CreateObject(Class_IncomingTransfer);
                  mPrePriFree := True;
                end;
                mParams := TNxParameters.Create;
                mDIM := NxCreateDocumentImportManager(AOS, Class_OutgoingTransfer, Class_IncomingTransfer);
                try
                  mDIM.AddInputDocument(mSD.OID);
                  mDIM.SelectedHeader := mSD;
                  // pokud prevodka prijem existovala, tak importuju do ni
                  if not NxIsEmptyOID(mPrePri_ID) then
                  begin
                    mPrePri.ExplicitTransaction := True;
                    mPrePri.Load(mPrePri_ID, nil);
                    mDIM.OutputDocument := mPrePri;
                  end;
                  //vytvorim pomoci importniho manazera
                  mDIM.SaveParams(mParams);
                  // pokud nemam vyplneny sklad tak ho doplnim (pozdeji se na radkach prepise podle JSONu)
                  if ((mParams.GetOrCreateParam(dtstring,'Store_ID').AsString = '')
                    or (NxIsEmptyOID(mParams.GetOrCreateParam(dtString, 'Store_ID').AsString))) then
                    mParams.GetOrCreateParam(dtString, 'Store_ID').AsString := SKLAD_HLAVNI;

                  mDocQueue_ID := GetDocQueue_ID(AOS, mModule, DOC_IncomingTransfer, mUser_ID, mDocType, mSD);
                  mParams.GetOrCreateParam(dtString, 'DocQueue_ID').AsString :=
                    GetValueOrDefault(mDocQueue_ID, GetDefaultDocQueue_ID(DOC_IncomingTransfer));

                  mDIM.LoadParams(mParams);
                  mDIM.Execute;
                  // pokud prevodka prijem existovala, tak tohle muzu preskocit
                  if NxIsEmptyOID(mPrePri_ID) then
                  begin
                    mPrePri := mDIM.OutputDocument;
                    mPrePri_ID := mPrePri.OID;
                    mPrePri.ExplicitTransaction := AOS.InTransaction;
                  end;
                  // na polozkach PrePri musime prenastavit sklad
                  mPrePriRows := mPrePri.GetLoadedCollectionMonikerForFieldCode(mPrePri.GetFieldCode('Rows'));
                  // zanedbavame moznost, ze by se jedna polozka PreVyd mela prevest na vice ruznych skladu
                  // jinak by se muselo v cyklu snizovat mnozstvi, ulozit PrePri, importnim manazerem doimportovat zbytek a tak dokola
                  for i := 0 to mPrePriRows.Count - 1 do
                  begin
                    mPrePriRow := mPrePriRows.BusinessObject[i];
                    dtJSONRows.First;
                    while not dtJSONRows.EOF do
                    begin
                      if dtJSONRows.FieldByName('Processed').AsBoolean and not dtJSONRows.FieldByName('IsDamaged').AsBoolean
                        and (dtJSONRows.FieldByName('StoreDocument2_ID').AsString = mPrePriRow.GetFieldValueAsString('ProvideRow_ID'))
                      then begin
                        mPrePriRow.SetFieldValueAsString('Store_ID', dtJSONRows.FieldByName('StoreTo_ID').AsString);
                        break;
                      end;
                      dtJSONRows.Next;
                    end;
                  end;
                  beforeSaveHook(AOS, mModule, DOC_IncomingTransfer, mUser_Id, mPrePri, 1, json, dtJSONRows);
                  mPrePri.Save;
                  afterSaveHook(AOS, mModule, DOC_IncomingTransfer, mUser_Id, mPrePri, 1, json, dtJSONRows);

                  // naplnime pomocny dataset pro vytvoreni polohovaku k PrePri
                  dtDocumentQuantity.EmptyTable;
                  dtJSONRows.First;
                  while not dtJSONRows.EOF do
                  begin
                    if dtJSONRows.FieldByName('Processed').AsBoolean and not dtJSONRows.FieldByName('IsDamaged').AsBoolean
                      and not CFxOID.IsEmpty(dtJSONRows.FieldByName('StorePositionTo_ID').AsString) then
                    begin
                      jsonSerNums := json.A['rows'].O[dtJSONRows.FieldByName('jsonIndex').AsInteger].A['sernums'];

                      // Pokud ma radek seriova cisla, tak ho musim rozpadnout po nich
                      if jsonSerNums.Length > 0 then
                      begin
                        for i := 0 to jsonSerNums.Length - 1 do
                          AddTodtDocumentQuantity(
                            dtDocumentQuantity,
                            dtJSONRows.FieldByName('StoreTo_ID').AsString,
                            dtJSONRows.FieldByName('StoreCard_ID').AsString,
                            jsonSerNums.O[i].S['SerNum_ID'],
                            dtJSONRows.FieldByName('StorePositionTo_ID').AsString,
                            1,
                            dtJSONRows.FieldByName('UnitRate').AsFloat,
                            dtJSONRows.FieldByName('ContentUnit').AsString
                          );
                      end
                      else
                        AddTodtDocumentQuantity(
                          dtDocumentQuantity,
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
                    mDocQueue_ID := GetDocQueue_ID(AOS, mModule, DOC_LogStoreInput, mUser_ID, DOC_IncomingTransfer, mPrePri);
                    mLSDPrePri_ID := REST_Create_LogStoreDocument(AOS, mPrePri, mLSDPrePri_ID,
                      Class_LogStoreInput,
                      GetValueOrDefault(mDocQueue_ID, GetDefaultDocQueue_ID(DOC_LogStoreInput)),
                      LogStoreInput_StoreGateway_ID, dtDocumentQuantity, mUser_Id,
                      False);
                    mNewLSDPrevPs.Add(mLSDPrePri_ID);
                  end;
                finally
                  mDIM.Free;
                  mParams.free;
                  if mPrePriFree then
                    FreeAndNil(mPrePri);
                end;
              end;
            end;

            // Vytvorit novy doklad na nezpracovane polozky (nebo rovnou prijemku z OV)
            // Pokud jsem se uzivatele ptal, tak odpoved dle nej, jinak vychozi
            if ((askForNewDocumentCreation(mModule) and json.B['AskForNewDocumentCreation'])
              or (not askForNewDocumentCreation(mModule) and createNewDocument(mModule))
              or (mDocType = DOC_IssuedOrder))
              and not ((mDocType = DOC_RefundedBillOfDelivery) and useBillOfDeliveryForRefunding) then
            begin
              mSLROs := TStringList.Create;
              mSLRORows := TStringList.Create;
              mDamagedDocs := TStringList.Create;
              mDamagedRowsDocs := TStringList.Create;
              mJOs := TStringList.Create;
              mCMs := TStringList.Create;
              try
                // vytvorime novou vydejku/prevodku na zbytky nezpracovane ve ctecce, nastavime na ni sarze
                // pokud byly polozky v puvodnim skl. dokladu importovane z OBP, musime je opet naimportovat z OBP - techto OBP muze byt i vice
                // stejne tak pro VP

                // sesbiram vazby na puvodni doklad (napr. objednavka)
                findProvideIDs(mSLROs, mSLRORows, mDamagedDocs, mDamagedRowsDocs, mJOs, mCMs, mDamagedFound);

                // nyni neumim vytvorit doklad, pokud ma vazbu na OBP i na VP
                // pokud jsou vazby jen na VP, tak vytvarim imp. manager z nej, jinak z OBV
                if (mSLROs.Count > 0) and (mJOs.Count > 0) then
                  RaiseException('error_order_and_joborder_relation')
                else if mJOs.Count > 0 then
                  mDIM := NxCreateDocumentImportManager(AOS, Class_PRFJobOrder, mSDClassID)
                else if mSLROs.Count > 0 then
                  mDIM := NxCreateDocumentImportManager(AOS, mOrderClass, mSDClassID)
                else
                  // kdyz nejsou zadne vazby, tak udelam jen defaultniho manazera, abych ho pak korektne uvolnil
                  mDIM := NxCreateDocumentImportManager(AOS, Class_ReceivedOrder, Class_BillOfDelivery);

                // klasicke nezpracovane radky oddelime do zvlastniho dokladu
                mParams := TNxParameters.Create;
                mRO := AOS.CreateObject(mOrderClass);
                mJO := AOS.CreateObject(Class_PRFJobOrder);
                try
                  mSDNewFree := False;
                  // pokud jsme nasbirali nejake odkazy na polozky OBP, vytvorime oddeleny skl. doklad importnim manazerem
                  if (mSLROs.Count > 0) and (mSLRORows.Count > 0) then
                  begin
                    // u objednavek chceme vytvaret prijemku z potvrzenych radku
                    // jinak vytvarime doklad na nepotvrzene
                    if mDocType = DOC_IssuedOrder then
                      CreateNewStoreDocument(mSLROs, mSLRORows, True, False)
                    else
                      CreateNewStoreDocument(mSLROs, mSLRORows, False, False);
                  end
                  else if mJOs.Count > 0 then
                  begin
                    CreateNewDocumentFromJO(False);
                  end
                  else begin
                    // pokud neni OBP, zalozime volny doklad
                    mSDNew := AOS.CreateObject(mSDClassID);
                    mSDNew.ExplicitTransaction := True;
                    mSDNew.New;
                    mSDNew.Prefill;
                    mSDNew.SetFieldValueAsString('DocQueue_ID', mSD.GetFieldValueAsString('DocQueue_ID'));
                    mSDNew.SetFieldValueAsString('Firm_ID', mSD.GetFieldValueAsString('Firm_ID'));
                    mSDNewFree := True;
                  end;
                  // u objednavek zpracovavame potvrzene radky
                  // jinak nepotvrzene
                  if mDocType = DOC_IssuedOrder then
                    ProcessNewStoreDocument(True, False)
                  else
                    ProcessNewStoreDocument(False, False);
                finally
                  mDIM.Free;
                  if mSDNewFree then
                    mSDNew.Free;
                  mParams.Free;
                  mRO.Free;
                  mJO.Free;
                end;

                // pokud jsem nalezel alespoň jeden poskozeny, tak budu vytvaret oddeleny doklad
                if mDamagedFound then
                begin
                  if (mDamagedDocs.Count > 0) and (mDamagedRowsDocs.Count > 0) then
                    mDIM := NxCreateDocumentImportManager(AOS, mOrderClass, mSDClassID)
                  else
                    // kdyz nejsou zadne vazby, tak udelam jen defaultniho manazera, abych ho pak korektne uvolnil
                    mDIM := NxCreateDocumentImportManager(AOS, Class_ReceivedOrder, Class_BillOfDelivery);

                  // radky s rozbitym mnozstvim oddelim do jineho dokladu
                  mParams := TNxParameters.Create;
                  mRO := AOS.CreateObject(mOrderClass);
                  try
                    mSDNewFree := False;
                    // pokud jsme nasbirali nejake odkazy na polozky OBP, vytvorime oddeleny skl. doklad importnim manazerem
                    if (mDamagedDocs.Count > 0) and (mDamagedRowsDocs.Count > 0) then
                    begin
                      CreateNewStoreDocument(mDamagedDocs, mDamagedRowsDocs, True, True);
                    end
                    else begin
                      // pokud neni OBP, zalozime volny doklad
                      mSDNew := AOS.CreateObject(mSDClassID);
                      mSDNew.ExplicitTransaction := True;
                      mSDNew.New;
                      mSDNew.Prefill;
                      mSDNew.SetFieldValueAsString('DocQueue_ID', mSD.GetFieldValueAsString('DocQueue_ID'));
                      mSDNew.SetFieldValueAsString('Firm_ID', mSD.GetFieldValueAsString('Firm_ID'));
                      mSDNewFree := True;
                    end;
                    ProcessNewStoreDocument(True, True);
                  finally
                    mDIM.Free;
                    if mSDNewFree then
                      mSDNew.Free;
                    mParams.Free;
                    mRO.Free;
                  end;
                end;
              finally
                mSLROs.Free;
                mSLRORows.Free;
                mDamagedDocs.Free;
                mDamagedRowsDocs.Free;
                mJOs.Free;
                mCMs.Free;
              end;
            end;
          finally
            mSD.Free;
          end;

          //mDocType := mDocTypeB;
          mSD := GetStoreDocBO(AOS, mDocType);
          try
            mSD.ExplicitTransaction := True;
            mSD.Load(dtStoreDocuments.FieldByName('Provide_ID').AsString, nil);

            LogWriteSectionStart('CHANGESTATUS');
            glog.WriteEvent(logDebug, 'mSD.ChangeStatusBySwitchRule - begin - ' + mSD.OID + ' - ' + PRECHOD_UKONCENI(mDocType, mModule));

            if putQueueDocDetailStopPicking_changeSDStatus(AOS, mModule, mDocType, mUser_ID, mSDNew_ID, 0, mSD, mSDNew) then
            begin
              ChangeStatusByRule(mSD, PRECHOD_UKONCENI(mDocType, mModule));
            end;
            glog.WriteEvent(logDebug, 'mSD.ChangeStatusBySwitchRule - end - ' + mSD.OID);

            // pokud se pri vratkach vydejek vychazi z vydejky, tak ji taky konci zmenim stav
            if (mDocType = DOC_RefundedBillOfDelivery) and useBillOfDeliveryForRefunding then
            begin
              mSD2 := AOS.CreateObject(Class_BillOfDelivery);
              try
                mSD2.Load(mDoc_ID, nil);
                ChangeStatusByRule(mSD2, PRECHOD_UKONCENI2(DOC_BillOfDelivery, mModule));
              finally
                mSD2.Free;
              end;
            end;

            if not CFxOID.IsEmpty(mPrePri_ID)
              and not CFxOID.IsEmpty(PRECHOD_UKONCENI2(DOC_IncomingTransfer, mModule)) then
            begin
              mPrePri := AOS.CreateObject(Class_IncomingTransfer);
              try
                mPrePri.ExplicitTransaction := True;
                mPrePri.Load(mPrePri_ID, nil);

                glog.WriteEvent(logDebug, 'mPrePri.ChangeStatusBySwitchRule - begin - ' + mSD.OID + ' - ' + PRECHOD_UKONCENI2(DOC_IncomingTransfer, mModule));
                ChangeStatusByRule(mPrePri, PRECHOD_UKONCENI2(DOC_IncomingTransfer, mModule));
                glog.WriteEvent(logDebug, 'mPrePri.ChangeStatusBySwitchRule - end - ' + mSD.OID);
              finally
                mPrePri.Free;
              end;
            end;

            if not CFxOID.IsEmpty(mSDNewRows_ID) then
            begin
              mSDNew := AOS.CreateObject(mSDClassID);
              try
                mSDNew.ExplicitTransaction := True;
                mSDNew.Load(mSDNewRows_ID, nil);

                if (mSDNew.GetFieldValueAsString(mStatusField) <> STAV_PO_ODDELENI_NOVE(mDocType, mModule))
                  or (mSDNew.GetFieldValueAsString('ResponsibleRole_ID') <> ROLE_PO_ODDELENI_NOVE(mDocType, mModule)) then
                begin
                  ChangeStatus(mSDNew, STAV_PO_ODDELENI_NOVE(mDocType, mModule), ROLE_PO_ODDELENI_NOVE(mDocType, mModule));
                end;
              finally
                mSDNew.Free;
              end;
            end;

            if not CFxOID.IsEmpty(mSDNew_ID) then
            begin
              mSDNew := AOS.CreateObject(mSDClassID);
              try
                mSDNew.ExplicitTransaction := True;
                mSDNew.Load(mSDNew_ID, nil);

                glog.WriteEvent(logDebug, 'mSDNew.ChangeStatusBySwitchRule - begin - ' + mSDNew.OID + ' - ' + PRECHOD_ODDELENI(mDocType, mModule));
                if putQueueDocDetailStopPicking_changeSDStatus(AOS, mModule, mDocType, mUser_ID, mSDNew_ID, 1, mSD, mSDNew) then
                begin
                  if not CFxOID.IsEmpty(PRECHOD_ODDELENI(mDocType, mModule)) then
                  begin
                    ChangeStatusByRule(mSDNew, PRECHOD_ODDELENI(mDocType, mModule));
                  end;
                end;
                glog.WriteEvent(logDebug, 'mSDNew.ChangeStatusBySwitchRule - end - ' + mSDNew.OID);
              finally
                mSDNew.Free;
              end;
            end;

            if not CFxOID.IsEmpty(mSDNewDamaged_ID) then
            begin
              mSDNew := AOS.CreateObject(mSDClassID);
              try
                mSDNew.ExplicitTransaction := True;
                mSDNew.Load(mSDNewDamaged_ID, nil);

                if (mSDNew.GetFieldValueAsString(mStatusField) <> STAV_PO_ODDELENI_POSKOZENE(mDocType, mModule))
                  or (mSDNew.GetFieldValueAsString('ResponsibleRole_ID') <> ROLE_PO_ODDELENI_POSKOZENE(mDocType, mModule)) then
                begin
                  glog.WriteEvent(logDebug, 'mSDNew_POSKOZENE.ChangeStatus - begin - ' + mSDNew.OID + ' - ' + STAV_PO_ODDELENI_POSKOZENE(mDocType, mModule));
                  ChangeStatus(mSDNew, STAV_PO_ODDELENI_POSKOZENE(mDocType, mModule), ROLE_PO_ODDELENI_POSKOZENE(mDocType, mModule));
                  glog.WriteEvent(logDebug, 'mSDNew_POSKOZENE.ChangeStatus - end - ' + mSDNew.OID);
                end;
              finally
                mSDNew.Free;
              end;
            end;
            LogWriteSectionEnd;
          finally
            mSD.Free;
          end;
        finally
          mStoreDocRows.Free;
        end;
        dtStoreDocuments.Next;

        // prefiltruju na dalsi doklad
        if not dtStoreDocuments.Eof then
        begin
          dtJSONRows.IndexName := 'ByStoreDocument2_ID';
          dtJSONRows.Filtered := False;
          dtJSONRows.Filter := 'StoreDocument_ID=' + QuotedStr(dtStoreDocuments.FieldByName('Provide_ID').AsString);
          dtJSONRows.Filtered := True;
          dtJSONRows.First;
        end;
      end;

      // zmenim pripadne stav listu
      if not CFxOID.IsEmpty(mBO.OID) then
      begin
        glog.WriteEvent(logDebug, 'mBO.ChangeStatusBySwitchRule - begin - ' + mBO.OID + ' - ' + PRECHOD_UKONCENI(mListDocType, mModule));
        mBO.Refresh;
        ChangeStatusByRule(mBO, PRECHOD_UKONCENI(mListDocType, mModule));
        glog.WriteEvent(logDebug, 'mBO.ChangeStatusBySwitchRule - end - ' + mBO.OID);

        // vytvorim novy list na nezpracovane polozky
        if mNewSDs.Count > 0 then
        begin
          mDIM := NxCreateDocumentImportManager(AOS, GetStoreDocClass(mDocType), GetStoreDocClass(mListDocType));
          mSDNew := AOS.CreateObject(GetStoreDocClass(mDocType));
          try
            mParams := TNxParameters.Create;
            try
              mSDNew.Load(mNewSDs.Strings(0), nil);
              mDIM.AddInputDocuments(mNewSDs);
              mDIM.SelectedHeader := mSDNew;
              //vytvorim pomoci importniho manazera
              mDIM.SaveParams(mParams);
              // pokud nemam vyplneny sklad tak ho doplnim (pozdeji se na radkach prepise podle JSONu)
              {if ((mParams.GetOrCreateParam(dtstring,'Store_ID').AsString = '')
                or (NxIsEmptyOID(mParams.GetOrCreateParam(dtstring,'Store_ID').AsString))) then
                mParams.GetOrCreateParam(dtstring,'Store_ID').AsString := SKLAD_HLAVNI;}
              mParams.GetOrCreateParam(dtString,'DocQueue_ID').AsString := mBO.GetFieldValueAsString('DocQueue_ID');
              mDIM.LoadParams(mParams);
              mDIM.Execute;
              mBONew := mDIM.OutputDocument;
              mBONew.ExplicitTransaction := AOS.InTransaction;
              mBONew.Save;

              if not CFxOID.IsEmpty(PRECHOD_ODDELENI(mListDocType, mModule)) then
                ChangeStatusByRule(mBONew, PRECHOD_ODDELENI(mListDocType, mModule));
            finally
              mParams.Free;
            end;
          finally
            mDIM.Free;
            mSDNew.Free;
          end;
        end;
      end;

      FinishSaving;
    except
      AOS.RollBack;
      SetPlainResponse(AResponse, Format(getString('error_stopping_docqueue'), [ExceptionMessage]), HTTP_SC_InternalServerError);
      Request_Cancel(AOS, mRequestID);
      exit;
    end;

    LogWriteSectionStart('MakeExecuted');
    // provedeni polohovaku udelame ve zvlastni transakci, protoze to casto pada na deadlock
    // pokud se to nepodari, aspon je vse ostatni vytvorene
    //if not CFxOID.IsEmpty(mLSD_ID) then
    for i := 0 to mNewLSDs.Count - 1 do
    begin
      mLSD_ID := mNewLSDs.Strings(i);
      if CFxOID.IsEmpty(mLSD_ID) then
        continue;
      mLSD := AOS.CreateObject(mLogStoreDocumentClass);
      mLSD.ExplicitTransaction := True;
      mLSD.Load(mLSD_ID, nil);
      if not mLSD.GetFieldValueAsBoolean('Executed') then
      begin
        AOS.StartTransaction(taReadCommited);
        try
          TNxLogStoreDocument(mLSD).MakeExecuted;
          AOS.Commit;
        except
          glog.WriteEvent(logError, 'mLSD_ID MakeExecuted - error - ' + mLSD_ID + ' - ' + ExceptionMessage);
          AOS.RollBack;
        end;
      end;
    end;

    //if not CFxOID.IsEmpty(mLSDPrePri_ID) then
    for i := 0 to mNewLSDPrevPs.Count - 1 do
    begin
      mLSDPrePri_ID := mNewLSDPrevPs.Strings(i);
      if CFxOID.IsEmpty(mLSDPrePri_ID) then
        continue;
      mLSD := AOS.CreateObject(Class_LogStoreInput);
      mLSD.ExplicitTransaction := True;
      mLSD.Load(mLSDPrePri_ID, nil);
      if not mLSD.GetFieldValueAsBoolean('Executed') then
      begin
        AOS.StartTransaction(taReadCommited);
        try
          TNxLogStoreDocument(mLSD).MakeExecuted;
          AOS.Commit;
        except
          glog.WriteEvent(logError, 'mLSDPrePri_ID MakeExecuted - error - ' + mLSDPrePri_ID + ' - ' + ExceptionMessage);
          AOS.RollBack;
        end;
      end;
    end;
    LogWriteSectionEnd;
  finally
    mBO.Free;
    json.Free;
    dtJSONRows.Free;
    dtDocumentQuantity.Free;
    dtStoreDocuments.Free;
    mNewSDs.Free;
    mNewLSDs.Free;
    mNewLSDPrevPs.Free;
    mProcessedBatches.Free;
  end;

  LogWriteSectionEnd;
end;

procedure get_SumQuantityForStoreCardAndStoreDocument(AOS: TNxCustomObjectSpace; APath, AResponse: TStringList);
var
  mStoreCard_ID, mStoreDocument_ID: String;
  dtHeader: TMemTable;
  mSL: TStringList;
  mSql: String;
  json: TJSONSuperObject;
begin
  json := nil;
  if (APath.Count = 3) then
  begin
    mStoreCard_ID := APath.Strings[1];
    mStoreDocument_ID := APath.Strings[2];
  end else
  begin
    SetPlainResponse(AResponse, getString('wrong_parameters_count'), HTTP_SC_BadRequest);
    exit;
  end;

  dtHeader := TMemTable.Create(nil);
  mSL := TStringList.Create;
  try
    LogWriteSectionStart('SumQuantityForStoreCardAndStoreDocument');

    mSql := 'select sum(SD2.Quantity) as "Available" ' +
      'from StoreDocuments2 SD2 ' +
      'where SD2.StoreCard_ID = ' + QuotedStr(mStoreCard_ID) +
      '  and SD2.Parent_ID = ' + QuotedStr(mStoreDocument_ID);

    AOS.SQLSelect2(mSql, dtHeader);
    LogWriteSectionEnd;

    if not dtHeader.Active then
    begin
      DataSet_CreataHeader(dtHeader, 'Available=F');
      dtHeader.Open;
      dtHeader.Append;
      dtHeader.FieldByName('Available').AsFloat := 0;
      dtHeader.Post;
    end;

    dtHeader.First;
    LogWriteSectionStart('JSON');
    json := REST_jsonCreate_FromDataSetRow(dtHeader, nil, mSL);
    LogWriteSectionEnd;

    SetResponse(AResponse, json.AsJson(false, true));
  finally
    dtHeader.Free;
    mSL.Free;
    if Assigned(json) then
      json.Free;
  end;
end;

procedure getStoreDocumentRow(AOS: TNxCustomObjectSpace; APath, AResponse: TStringList);
var
  mStoreDocument2_ID, mSql, mWhere: String;
  dtRow: TMemTable;
  mSL : TStringList;
  json: TJSONSuperObject;
begin
  if (APath.Count = 2) then
  begin
    mStoreDocument2_ID := APath.Strings[1];
  end else
  begin
    SetPlainResponse(AResponse, getString('wrong_parameters_count'), HTTP_SC_BadRequest);
    exit;
  end;

  LogWriteSectionStart('getStoreDocumentRow');

  dtRow := TMemTable.Create(nil);
  mSL := TStringList.Create;
  try
    mWhere :=
      'SD2.ID = ' + QuotedStr(mStoreDocument2_ID) + nxCrLf;

    if ABRA then
      mWhere := mWhere +
        '  and SD2.RowType = 3 and SC.NonStockType = ''N'''
    else
      mWhere := mWhere +
        '  and SD2.RowType = 3 and SC.IsStockType = ''A''';

    mSql := getRowsSql(AOS, gSkladTermModule, gSkladTermUser_ID, gSkladTermDocType, mWhere);
    AOS.SQLSelect2(mSql, dtRow);

    if dtRow.Active then
    begin
      json := REST_jsonCreate_FromDataSet(dtRow, nil, nil);

      SetResponse(AResponse, json.AsJson(false, true));
    end
    else
      SetPlainResponse(AResponse, Format(getString('error_row_not_found'), [mStoreDocument2_ID]), HTTP_SC_NotFound);
  finally
    dtRow.Free;
    mSL.Free;
    LogWriteSectionEnd;
  end;
end;

function ModifyVisibleModulesString(AOS: TNxCustomObjectSpace; AStore_ID, AUser_ID: String): String;
var
  mFullSql, mSql, mDocumentType, mModule: String;
  i, mDashPosition: Integer;
  mModules, mModuleParameters, mDocumentTypes: TStringList;
  mFirst: Boolean;
  mResultModules, mCustomerModules: TMemTable;
begin
  LogWriteSectionStart('ModifyVisibleModulesString');

  Result := '';

  mModules := TStringList.Create;
  mModuleParameters := TStringList.Create;
  mCustomerModules := TMemTable.Create(nil);
  mResultModules := TMemTable.Create(nil);
  mDocumentTypes := TStringList.Create;
  try
    // pokud je zobrazovani vypnuto, tak pocty dokladu pridavat nebudu
    if not showDocumentQueueCount then
    begin
      Result := CLIENT_VISIBLE_MODULES(AOS, AStore_ID, AUser_ID);
      exit;
    end;

    mModules.Delimiter := ';';
    mModules.StrictDelimiter := True;
    mModules.DelimitedText := CLIENT_VISIBLE_MODULES(AOS, AStore_ID, AUser_ID);
    mModuleParameters.Delimiter := ':';
    mModuleParameters.StrictDelimiter := True;
    mDocumentTypes.Delimiter := ',';
    mDocumentTypes.StrictDelimiter := True;
    mFullSql := '';
    mFirst := True;
    for i := 0 to mModules.Count - 1 do
    begin
      mModule := mModules.Strings[i];

      mModuleParameters.Clear;
      mModuleParameters.DelimitedText := mModule;

      mDocumentTypes.Clear;

      // muze byt X parametru, nyni:
      // kod modulu, nazev modulu, typ dokladu, vlastni kod modulu
      if mModuleParameters.Count > 1 then
        mModule := mModuleParameters.Strings[0];
      if mModuleParameters.Count > 2 then
        mDocumentTypes.DelimitedText := mModuleParameters.Strings[2];
      if mModuleParameters.Count > 3 then
        mModule := mModuleParameters.Strings[3];

      // tohle se muze casem hodit az se bude resit, ze scenare s parametrem maji mit pocet dokladu ve fronte
      // muze se stat, ze jsou nastaveny parametry - v tom pripade je musim odstrihnout
      {if pos(':', mModules.Strings[i]) > 0 then
        mModule := copy(mModules.Strings[i], 1, pos(':', mModules.Strings[i]) - 1)
      else
        mModule := mModules.Strings[i];}

      // nastaveni typu dokladu
      if mDocumentTypes.Count = 0 then
      begin
        mDocumentType := '';
        case mModule of
         'STD_ReceiptCardQueue':              mDocumentType := DOC_ReceiptCard;
         'STD_ReceiptCardFastQueue':          mDocumentType := DOC_ReceiptCard;
         'STD_BillOfDeliveryQueue':           mDocumentType := DOC_BillOfDelivery;
         'STD_BillOfDeliveryFastQueue':       mDocumentType := DOC_BillOfDelivery;
         'STD_RemovalListsQueue':             mDocumentType := DOC_RemovalList;
         'STD_RemovalListsFastQueue':         mDocumentType := DOC_RemovalList;
         'STD_ShippingListsQueue':            mDocumentType := DOC_ShippingList;
         'STD_ShippingListsFastQueue':        mDocumentType := DOC_ShippingList;
         'STD_TransferQueue':                 mDocumentType := DOC_OutgoingTransfer;
         'STD_TransferInQueue':               mDocumentType := DOC_IncomingTransfer;
         'STD_RefundedBillOfDeliveryQueue':   mDocumentType := DOC_RefundedBillOfDelivery;
         'STD_RefundedReceiptCardQueue':      mDocumentType := DOC_RefundedReceiptCard;
         'STD_JobOrderQueue':                 mDocumentType := DOC_JobOrder;
         'STD_InventorizationByDIP':          mDocumentType := DOC_PartialInvProtocol;
         'STD_InventorizationByDIPFast':      mDocumentType := DOC_PartialInvProtocol;
         'STD_InventorizationFree':           mDocumentType := DOC_MainInvProtocol;
         'STD_InventorizationFreeFast':       mDocumentType := DOC_MainInvProtocol;
         'STD_OutgoingSubstitutionQueue':     mDocumentType := DOC_OutgoingSubstitution;
         'STD_IncomingSubstitutionQueue':     mDocumentType := DOC_IncomingSubstitution;
         'STD_OutgoingTransformationQueue':   mDocumentType := DOC_OutgoingTransformation;
         'STD_IncomingTransformationQueue':   mDocumentType := DOC_IncomingTransformation;
         'STD_TransferBetweenPositionsQueue': mDocumentType := DOC_LogStoreTransfer;
         'STD_ReceiptCardFromIOQueue':        mDocumentType := DOC_IssuedOrder;
         else mDocumentType := '';
        end;
        mDocumentTypes.Add(mDocumentType);
      end;

      // mastaveni SQL dotazu
      mSql := '';
      if mModule in ['STD_ReceiptCardQueue', 'STD_ReceiptCardFastQueue', 'STD_BillOfDeliveryQueue', 'STD_BillOfDeliveryFastQueue', 'STD_RemovalListsQueue',
          'STD_RemovalListsFastQueue', 'STD_ShippingListsQueue', 'STD_ShippingListsFastQueue', 'STD_TransferQueue', 'STD_TransferInQueue',
          'STD_RefundedBillOfDeliveryQueue', 'STD_JobOrderQueue', 'STD_OutgoingSubstitutionQueue', 'STD_IncomingSubstitutionQueue', 'STD_RefundedReceiptCardQueue',
          'STD_OutgoingTransformationQueue', 'STD_IncomingTransformationQueue', 'STD_TransferBetweenPositionsQueue', 'STD_ReceiptCardFromIOQueue'] then
        mSql := GetListDocQueueSql(AOS, mModule, AUser_ID, defaultSearchString_Prefill(AOS, mModule, AUser_ID, mDocumentTypes), mDocumentTypes, True)
      else if mModule in ['STD_InventorizationByDIP', 'STD_InventorizationByDIPFast'] then
        mSql := GetListPartialInvProtocolsSql(AOS, mModule, mDocumentType, AUser_ID,
          defaultSearchString_Prefill(AOS, mModule, AUser_ID, mDocumentTypes), True)
      else if mModule in ['STD_InventorizationFree', 'STD_InventorizationFreeFast'] then
        mSql := GetListMainInvProtocolsSql(AOS, mModule, mDocumentType, AUser_ID,
          defaultSearchString_Prefill(AOS, mModule, AUser_ID, mDocumentTypes), True);

      if mSql <> '' then
      begin
        if not mFirst then
          mFullSql := mFullSql + nxCrLf + ' union all ' + nxCrLf;
        mFirst := False;

        mFullSql := mFullSql + 'select ' + QuotedStr(mModuleParameters.DelimitedText) + ' as "Module", count("ID") as "Count" from (' + nxCrLf
          + mSql + ') X' + nxCrLf;
      end
      else
      begin
        if not mFirst then
          mFullSql := mFullSql + nxCrLf + ' union all ' + nxCrLf;
        mFirst := False;

        mFullSql := mFullSql + 'select ' + QuotedStr(mModule) + ' as "Module", -1 "Count"' + FROM_1_RECORD;
      end;
    end;

    AOS.SQLSelect2(mFullSql, mResultModules);

    // dotaz vratil moduly - musim je prevyplnit do vysledneho stringu
    // dohledam, zda tam modul je a pokud ano, tak k nemu doplnim cislo
    if mResultModules.Active then
    begin
      for i := 0 to mModules.Count - 1 do
      begin
        mModule := mModules.Strings[i];

        // hodim si do stringlistu, aby se mi odstranili uvozvoky kolem nazvu
        mModuleParameters.DelimitedText := mModule;

        // muze se stat, ze jsou nastaveny parametry - v tom pripade je musim odstrihnout
        {if pos(':', mModule) > 0 then
          mModule := copy(mModule, 1, pos(':', mModule) - 1);}

        mResultModules.First;
        while not mResultModules.Eof do
        begin
          if (trim(mModuleParameters.DelimitedText) = trim(mResultModules.FieldByName('Module').AsString))
            and (mResultModules.FieldByName('Count').AsInteger >= 0) then
          begin
            mModules.Strings[i] := Format('%s-%d', [mModuleParameters.DelimitedText, mResultModules.FieldByName('Count').AsInteger]);
          end;
          mResultModules.Next;
        end;
      end;
    end;

    // kontrola na zakaznicke fronty
    VisibleModulesDocumentCount(AOS, AUser_ID, mCustomerModules);
    if mCustomerModules.Active then
    begin
      for i := 0 to mModules.Count - 1 do
      begin
        mModule := mModules.Strings[i];

        // muze se stat, ze jsou nastaveny parametry - v tom pripade je musim odstrihnout
        {if pos(':', mModules.Strings[i]) > 0 then
          mModule := copy(mModules.Strings[i], 1, pos(':', mModules.Strings[i]) - 1)
        else
          mModule := mModules.Strings[i];}

        // pokud uz ma modul pridany pocet dokladu, tak ho odriznu
        mDashPosition := pos('-', mModule);
        if mDashPosition > 0 then
          mModule := copy(mModule, 1, mDashPosition - 1);

        mCustomerModules.First;
        while not mCustomerModules.Eof do
        begin
          if (trim(mModule) = trim(mCustomerModules.FieldByName('Module').AsString))
            and (mCustomerModules.FieldByName('Count').AsInteger >= 0) then
          begin
            mModules.Strings[i] := Format('%s-%d', [mModule, mCustomerModules.FieldByName('Count').AsInteger]);
          end;
          mCustomerModules.Next;
        end;
      end;
    end;

    Result := mModules.DelimitedText;
  finally
    mModules.Free;
    mModuleParameters.Free;
    mCustomerModules.Free;
    mResultModules.Free;
    mDocumentTypes.Free;
    LogWriteSectionEnd;
  end;
end;

procedure GetMainMenuButtons(AOS: TNxCustomObjectSpace; APath, AResponse: TStringList);
var
  mModules,: String;
begin
  if (APath.Count <> 1) then
  begin
    SetPlainResponse(AResponse, getString('wrong_parameters_count'), HTTP_SC_BadRequest);
    exit;
  end;

  LogWriteSectionStart('GetMainMenuButtons');
  try
    mModules := ModifyVisibleModulesString(AOS, getStoreForUser(AOS, gSkladTermUser_ID), gSkladTermUser_ID);
    SetResponse(AResponse, PlainResponse(mModules));
  finally
    LogWriteSectionEnd;
  end;
end;

procedure put_CodeResult(AOS: TNxCustomObjectSpace; APath: TStringList; ABody: String; AResponse: TStringList);
var
 mBarcode, mStoreDocument_ID: String;
begin
  if (APath.Count <> 1) then
  begin
    SetPlainResponse(AResponse, getString('wrong_parameters_count'), HTTP_SC_BadRequest);
    exit;
  end;

  LogWriteSectionStart('put_CodeResult');
  try
    mBarcode := ABody;
    // vypada to, ze se barcode posle z aplikace v uvozovkach, takze je odstranim
    if pos('"', mBarcode) = 1 then
      mBarcode := copy(mBarcode, 2, Length(mBarcode) - 2);

    parseBarcodeForRowSpecial(AOS, gSkladTermModule, gSkladTermDocType, gSkladTermUser_ID, mBarcode, '', '', '', '', '', '', '',
      '', '', '' , -1, -1,
      mStoreDocument_ID, '', '', '', '', '', '', '',
      -1, -1,
      '', -1, nil, nil, nil, nil);
    SetResponse(AResponse, PlainResponse(mStoreDocument_ID));
  finally
    LogWriteSectionEnd;
  end;
end;

begin
end.
