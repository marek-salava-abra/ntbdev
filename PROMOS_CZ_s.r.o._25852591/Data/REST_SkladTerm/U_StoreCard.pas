uses
  'REST_SkladTerm.U_CommonFunctionality',
  'REST_SkladTerm.U_Const',
  'REST_SkladTerm.U_Func',
  'REST_SkladTerm.U_FuncJSON',
  'REST_SkladTerm.U_SQLQueries',
  'REST_SkladTerm.U_StoreBatch',
  'REST_SkladTerm.U_StorePosition',
  'REST_SkladTerm_Special.U_Const',
  'REST_SkladTerm_Special.U_StandardHooks',
  'StandardUnits.U_DataSet',
  'StandardUnits.U_Func',
  'StandardUnits.U_GetId';

procedure get_StoreCardInfo(AOS: TNxCustomObjectSpace; APath, AQueryParams, AResponse: TStringList);
var
  mBarcode, mBarcode_Orig, mFirm_ID, mStore_ID, mStoreUnit_ID, mExtendedInfoStore_ID, mAdditionalValues: String;
  mExtendedInfo, mWithUnits, mIsId, mWithStoreUnit, mIsNewRow: Boolean;
  dtHeader, mRowDialogValues: TMemTable;
  dtRows, dtUnits, dtEANs: TMemTable;
  mSL, mStoreCardIds: TStringList;
  mSql: String;
  json, eanJson, eanJsonArray: TJSONSuperObject;
  i, j: Integer;
begin
  json := nil;
  if (APath.Count = 7) then
  begin
    mIsId := APath.Strings[1] = 'true';
    mFirm_ID := APath.Strings[2];
    mStore_ID := APath.Strings[3];
    mWithUnits := APath.Strings[4] = 'true';
    mExtendedInfo := APath.Strings[5] = 'true';
    mExtendedInfoStore_ID := APath.Strings[6];
  end else
  begin
    SetPlainResponse(AResponse, getString('wrong_parameters_count'), HTTP_SC_BadRequest);
    exit;
  end;

  mStoreCardIds := TStringList.Create;
  try
    mBarcode := AQueryParams.Values('barcode');
    mIsNewRow := AQueryParams.Values('isNewRow') = 'true';

    // v pripade artiklu nemusi prijit primo jeho ID, ale treba nejaky jiny identifikator (EAN apod.)
    // zde tedy zjistime nejprve jeho ID
    mWithStoreUnit := False;
    mStoreUnit_ID := '';
    mBarcode_Orig := mBarcode;
    GetStoreCard_ID(AOS, mBarcode, mIsId, mWithStoreUnit, mStoreCardIds);

    if mStoreCardIds.Count = 0 then
    begin
      SetPlainResponse(AResponse, Format(getString('article_not_found'), [mBarcode_Orig]), HTTP_SC_NotFound);
      exit;
    end;

    dtHeader := TMemTable.Create(nil);
    dtRows := TMemTable.Create(nil);
    dtUnits := TMemTable.Create(nil);
    dtEANs := TMemTable.Create(nil);
    mRowDialogValues := TMemTable.Create(nil);
    mSL := TStringList.Create;
    try
      // hlavicka artiklu
      LogWriteSectionStart('StoreCardInfo');

      mAdditionalValues := GetInputDialogValuesFields(AOS, gSkladTermModule, gSkladTermDocType, gSkladTermUser_ID, 'getStoreCardInfoSql', mRowDialogValues);

      mSql := getStoreCardInfoSql(AOS, gSkladTermModule, gSkladTermDocType, gSkladTermUser_ID, mStoreCardIds, mFirm_ID, mStore_ID, '', mAdditionalValues,
        mIsNewRow);
      AOS.SQLSelect2(mSql, dtHeader);

      if dtHeader.Active then
      begin
        // projdu si dataset a odstranim z nej informace o pripadne jednotce, protoze uz je nepotrebuju
        for i := 0 to mStoreCardIds.Count - 1 do
        begin
          mStoreCardIds.Strings(i) := Copy(mStoreCardIds.Strings(i), 1, 10);
        end;

        SetInputDialogValuesString(mRowDialogValues, dtHeader);

        GetStoreCardDetailInfo(AOS, mStoreCardIds, mExtendedInfoStore_ID, mExtendedInfo, mWithUnits, mSL, dtRows, dtUnits, dtEANs);

        dtHeader.First;
        // TODO muzu odstranit az se bude vzdy volat jako pole
        BeforeJSONCreate(AOS, gSkladTermModule, gSkladTermDocType, gSkladTermUser_ID, dtHeader);
        json := REST_jsonCreate_FromDataSet(dtHeader, nil, mSL);
        LogWriteSectionEnd;

        BeforeJSONSend(AOS, gSkladTermModule, gSkladTermDocType, gSkladTermUser_ID, json);
        SetResponse(AResponse, json.AsJson(false, true));
      end
      else begin
        SetPlainResponse(AResponse, Format(getString('article_not_found'), [mBarcode_Orig]), HTTP_SC_NotFound);
      end;
    finally
      dtHeader.Free;
      dtRows.Free;
      dtUnits.Free;
      dtEANs.Free;
      mRowDialogValues.Free;
      mSL.Free;
      if Assigned(json) then
        json.Free;
    end;
  finally
    mStoreCardIds.Free;
  end;
end;

procedure get_StoreCardInfoPositions(AOS: TNxCustomObjectSpace; APath, AQueryParams, AResponse: TStringList);
var
  mStoreCard_ID, mStoreBatch_ID, mStore_ID, mStoreCard_ID_Orig, mUnitCode: String;
  dtHeader: TMemTable;
  dtRows: TMemTable;
  mSL, mStoreCardIds: TStringList;
  mSql: String;
  json: TJSONSuperObject;
  mIsId, mOnlyAvailable: Boolean;
begin
  json := nil;
  if (APath.Count = 6) then
  begin
    mStoreCard_ID := APath.Strings[1];
    mStoreBatch_ID  := APath.Strings[2];
    mIsId := APath.Strings[3] = 'true';
    mStore_ID := APath.Strings[4];
    mOnlyAvailable := APath.Strings[5] = 'true';
  end else
  begin
    SetPlainResponse(AResponse, getString('wrong_parameters_count'), HTTP_SC_BadRequest);
    exit;
  end;

  mUnitCode := AQueryParams.Values('unitCode');

  mStoreCardIds := TStringList.Create;
  try
    // v pripade artiklu nemusi prijit primo jeho ID, ale treba nejaky jiny identifikator (EAN apod.)
    // zde tedy zjistime nejprve jeho ID
    mStoreCard_ID_Orig := mStoreCard_ID;
    GetStoreCard_ID(AOS, mStoreCard_ID, mIsId, False, mStoreCardIds);

    if mStoreCardIds.Count = 0 then
    begin
      SetPlainResponse(AResponse, Format(getString('article_not_found'), [mStoreCard_ID_Orig]), HTTP_SC_NotFound);
      exit;
    end;

    mStoreCard_ID := mStoreCardIds.Strings(0);
  finally
    mStoreCardIds.Free;
  end;

  dtHeader := TMemTable.Create(nil);
  dtRows := TMemTable.Create(nil);
  mSL := TStringList.Create;
  try
    // hlavicka artiklu
    LogWriteSectionStart('StoreCardInfoPositions');
    mSql :=
      'select' + nxCrLf +
      '  SC.ID as "ID",' +  // kvuli navazani polozkoveho datasetu
      '  SC.ID as "StoreCard_ID",' + nxCrLf +
      '  SC.' + cStoreCardInfoCodeField + ' as "StoreCardCode",' + nxCrLf +
      '  SC.' + cStoreCardInfoNameField + ' as "StoreCardName",' + nxCrLf +
      '  SC.Category as "StoreCardCategory",' + nxCrLf;
    if ABRA then
      mSql := mSql +
        '  case' + nxCrLf +
        '    when SC.NonStockType = ''A''' + nxCrLf +
        '    then ''N''' + nxCrLf +
        '    else ''A''' + nxCrLf +
        '  end as "StoreCardIsStockType$BOOL",' + nxCrLf
    else
      mSql := mSql +
        '  SC.IsStockType as "StoreCardIsStockType$BOOL",' + nxCrLf;

    mSql := mSql +
      '  SC.MainUnitCode as "MainUnitCode",' + nxCrLf +
      '  SU.UnitRate as "MainUnitRate"' + nxCrLf +
      'from StoreCards SC' + nxCrLf +
      'join StoreUnits SU on SU.Parent_ID = SC.ID and SU.Code = SC.MainUnitCode' + nxCrLf +
      'where SC.ID = ' + QuotedStr(mStoreCard_ID);
    AOS.SQLSelect2(mSql, dtHeader);

    if dtHeader.Active then
    begin
      dtHeader.First;

      // seznam dispozic na pozicich vybraneho skladu pro vybrany artikl
      mSql :=
        'select' + nxCrLf +
        '  max(LSC.StoreCard_ID) as "XX_Parent_ID",' + nxCrLf +
        '  max(LSP.ID) as "StorePosition_ID",' + nxCrLf +
        '  max(LSP.Code) as "StorePositionCode",' + nxCrLf +
        '  sum((LSC.Quantity - LSC.QuantityReserved) / SU.UnitRate) as "Available",' + nxCrLf +
        '  sum(LSC.QuantityReserved / SU.UnitRate) as "Booked"' + nxCrLf +
        'from LogStorePositions LSP' + nxCrLf +
        'join LogStoreContents LSC on LSC.Parent_ID = LSP.ID' + nxCrLf +
        'join StoreCards SC on SC.ID = LSC.StoreCard_ID' + nxCrLf;

      if mUnitCode <> '' then
        mSql := mSql +
          'join StoreUnits SU on SU.Parent_ID = SC.ID and SU.Code = ' + QuotedStr(mUnitCode) + nxCrLf
      else
        mSql := mSql +
          'join StoreUnits SU on SU.Parent_ID = SC.ID and SU.Code = SC.MainUnitCode' + nxCrLf;

      mSql := mSql +
        'where' + nxCrLf +
        '  LSP.Store_ID = ' + QuotedStr(mStore_ID) + nxCrLf +
        '  and SC.ID = ' + QuotedStr(mStoreCard_ID) + nxCrLf;
      // pokud je sarze tak ji omezim
      if not NxIsEmptyOID(mStoreBatch_ID) then
        mSql := mSql + '  and LSC.StoreBatch_ID = ' + QuotedStr(mStoreBatch_ID) + nxCrLf;

      mSql := mSql +
        'group by' + nxCrLf +
        '  LSP.ID' + nxCrLf;

      if mOnlyAvailable then
        mSql := mSql +
          'having' + nxCrLf +
          '  sum(LSC.Quantity - LSC.QuantityReserved) <> 0' + nxCrLf
      else
        mSql := mSql +
          'having' + nxCrLf +
          '  sum(LSC.Quantity) <> 0' + nxCrLf;

      mSql := mSql +
        'order by' + nxCrLf +
        '  max(LSP.Code)';
      AOS.SQLSelect2(mSql, dtRows);
      if dtRows.Active then
      begin
        dtRows.AddIndex('id', REST_XX_Parent_ID+';StorePositionCode', [ixUnique]);
        dtRows.IndexName:= 'id';
        mSL.AddObject('rows=', dtRows);
      end;
    end;
    LogWriteSectionEnd;

    if dtHeader.Active then
    begin
      LogWriteSectionStart('JSON');
      json := REST_jsonCreate_FromDataSetRow(dtHeader, nil, mSL);
      LogWriteSectionEnd;

      SetResponse(AResponse, json.AsJson(false, true));
    end
    else
      SetPlainResponse(AResponse, Format(getString('article_not_found'), [mStoreCard_ID_Orig]), HTTP_SC_NotFound);
  finally
    dtHeader.Free;
    dtRows.Free;
    mSL.Free;
    if Assigned(json) then
      json.Free;
  end;
end;

procedure get_StoreCardInfoBatchesOnPosition(AOS: TNxCustomObjectSpace; APath, AQueryParams, AResponse: TStringList);
var
  mStoreCard_ID, mStorePosition_ID, mStore_ID, mUnitCode: String;
  dtHeader: TMemTable;
  dtRows: TMemTable;
  mSL: TStringList;
  mSql: String;
  json: TJSONSuperObject;
  mIsId: Boolean;
begin
  json := nil;
  if (APath.Count = 4) then
  begin
    mStoreCard_ID := APath.Strings[1]; //ocekavam artikl
    mStorePosition_ID  := APath.Strings[2];
    mStore_ID := APath.Strings[3]; //ocekavam sklad
  end else
  begin
    SetPlainResponse(AResponse, getString('wrong_parameters_count'), HTTP_SC_BadRequest);
    exit;
  end;

  mUnitCode := AQueryParams.Values('unitCode');

  dtHeader := TMemTable.Create(nil);
  dtRows := TMemTable.Create(nil);
  mSL := TStringList.Create;
  try
    // hlavicka artiklu
    LogWriteSectionStart('StoreCardInfoPositions');
    mSql :=
      'select' + nxCrLf +
      '  SC.ID as "ID",' + nxCrLf +  // kvuli navazani polozkoveho datasetu
      '  SC.ID as "StoreCard_ID",' + nxCrLf +
      '  SC.' + cStoreCardInfoCodeField + ' as "StoreCardCode",' + nxCrLf +
      '  SC.' + cStoreCardInfoNameField + ' as "StoreCardName",' + nxCrLf +
      '  SC.Category as "StoreCardCategory",' + nxCrLf;
    if ABRA then
      mSql := mSql +
        '  case' + nxCrLf +
        '    when SC.NonStockType = ''A''' + nxCrLf +
        '    then ''N''' + nxCrLf +
        '    else ''A''' + nxCrLf +
        '  end as "StoreCardIsStockType$BOOL",' + nxCrLf
    else
      mSql := mSql +
        '  SC.IsStockType as "StoreCardIsStockType$BOOL",' + nxCrLf;

    mSql := mSql +
      '  SC.MainUnitCode as "MainUnitCode",' + nxCrLf +
      '  SU.UnitRate as "MainUnitRate"' + nxCrLf +
      'from StoreCards SC' + nxCrLf +
      'join StoreUnits SU on SU.Parent_ID = SC.ID and SU.Code = SC.MainUnitCode' + nxCrLf +
      'where' + nxCrLf +
      '  SC.ID = ' + QuotedStr(mStoreCard_ID);
    AOS.SQLSelect2(mSql, dtHeader);

    if dtHeader.Active then
    begin
      dtHeader.First;

      // seznam sarzi na pozicich vybraneho skladu pro vybrany artikl
      mSql :=
        'select' + nxCrLf +
        '  max(LSC.StoreCard_ID) as "XX_Parent_ID",' + nxCrLf +
        '  SB.ID as "StorePosition_ID",' + nxCrLf +
        '  max(SB.Name) as "StorePositionCode",' + nxCrLf +
        '  sum((LSC.Quantity - LSC.QuantityReserved) / SU.UnitRate) as "Available",' + nxCrLf +
        '  sum(LSC.QuantityReserved / SU.UnitRate) as "Booked"' + nxCrLf +
        'from LogStoreContents LSC' + nxCrLf +
        'join StoreBatches SB on SB.ID = LSC.StoreBatch_ID' + nxCrLf +
        'join StoreCards SC on SC.ID = LSC.StoreCard_ID' + nxCrLf;

      if mUnitCode <> '' then
        mSql := mSql +
          'join StoreUnits SU on SU.Parent_ID = SC.ID and SU.Code = ' + QuotedStr(mUnitCode) + nxCrLf
      else
        mSql := mSql +
          'join StoreUnits SU on SU.Parent_ID = SC.ID and SU.Code = SC.MainUnitCode' + nxCrLf;

      mSql := mSql +
        'where' + nxCrLf +
        '  SC.ID = ' + QuotedStr(mStoreCard_ID) + nxCrLf +
        '  and LSC.Parent_ID = ' + QuotedStr(mStorePosition_ID) + nxCrLf +
        'group by' + nxCrLf +
        '  SB.ID' + nxCrLf +
        'having' + nxCrLf +
        '  sum(LSC.Quantity) <> 0' + nxCrLf +
        'order by' + nxCrLf +
        '  max(SB.Name)';
      AOS.SQLSelect2(mSql, dtRows);
      if dtRows.Active then
      begin
        dtRows.AddIndex('id', REST_XX_Parent_ID+';StorePositionCode', [ixUnique]);
        dtRows.IndexName:= 'id';
        mSL.AddObject('rows=', dtRows);
      end;
    end;
    LogWriteSectionEnd;

    if dtHeader.Active then
    begin
      LogWriteSectionStart('JSON');
      json := REST_jsonCreate_FromDataSetRow(dtHeader, nil, mSL);
      LogWriteSectionEnd;

      SetResponse(AResponse, json.AsJson(false, true));
    end
    else
      SetPlainResponse(AResponse, Format(getString('position_not_found'), [mStorePosition_ID]), HTTP_SC_NotFound);
  finally
    dtHeader.Free;
    dtRows.Free;
    mSL.Free;
    if Assigned(json) then
      json.Free;
  end;
end;

procedure Post_AvailableQuantity(AOS: TNxCustomObjectSpace; APath, AArguments: TStringList; ABody: String; AResponse: TStringList);
var
  mStore_ID, mStoreCard_ID, mStoreDocument2_ID, mStoreBatch_ID, mStorePosition_ID, mStorePositionTo_ID, mSerialNumbersSt, mDialogTitle, mDialogText,
    mDialogSql: String;
  mQuantityDifference, mDialogType: Integer;
  mEnteredQuantity: Double;
  dtHeader, mSerialNumbers, mSerialNumbersAvailableQuantity: TMemTable;
  mSL: TStringList;
  mSql: String;
  mIsEditing: Boolean;
  json, jsonSerialNumbers: TJSONSuperObject;
begin
  LogWriteSectionStart('Post_AvailableQuantity');
  CFxProfiler.EnterProc(REST_LogName, 'Post_AvailableQuantity');
  try
    json := nil;
    if (APath.Count = 9) then
    begin
      mStore_ID := APath.Strings[1];
      mStoreCard_ID := APath.Strings[2];
      mStoreDocument2_ID := APath.Strings[3];
      mQuantityDifference := StrToInt(APath.Strings[4]);
      mEnteredQuantity := NxIBStrToFloat(ReplaceStr(APath.Strings[5], '.', ','));
      mStoreBatch_ID := APath.Strings[6];
      mStorePosition_ID := APath.Strings[7];
      mStorePositionTo_ID := APath.Strings[8];
    end else
    begin
      SetPlainResponse(AResponse, getString('wrong_parameters_count'), HTTP_SC_BadRequest);
      exit;
    end;

    mIsEditing := AArguments.Values('isEditing') = 'true';

    dtHeader := TMemTable.Create(nil);
    mSerialNumbers := TMemTable.Create(nil);
    mSerialNumbersAvailableQuantity := TMemTable.Create(nil);
    mSL := TStringList.Create;
    try
      json := TJSONSuperObject.ParseString(ABody, True);
      try
        DataSet_CreataHeader(mSerialNumbers, 'jsonIndex=I,SerNum_ID=S10,isProcessed=B');
        mSerialNumbers.AddIndex('ByJsonIndex', 'jsonIndex', [ixUnique]);
        mSerialNumbers.Open;
        REST_JsonToDataSet(json.AsArray, mSerialNumbers);
      finally
        json.Free;
        json := nil;
      end;

      mSerialNumbersSt := '';
      mSerialNumbers.First;
      while not mSerialNumbers.Eof do
      begin
        if mSerialNumbers.FieldByName('SerNum_ID').AsString <> '' then
          mSerialNumbersSt := mSerialNumbersSt + QuotedStr(mSerialNumbers.FieldByName('SerNum_ID').AsString) + ', ';

        mSerialNumbers.Next;
      end;

      if mSerialNumbersSt <> '' then
      begin
        mSerialNumbersSt := copy(mSerialNumbersSt, 1, Length(mSerialNumbersSt) - 2);

        if CFxOID.IsEmpty(mStorePosition_ID) then
        begin
          mSql :=
            'select' + nxCrLf +
            '  SSB.StoreBatch_ID as "id",' + nxCrLf +
            '  SSB.Quantity - SSB.BookedQuantity as "available"' + nxCrLf +
            'from StoreSubBatches SSB' + nxCrLf +
            'where' + nxCrLf +
            '  SSB.Store_ID = ' + QuotedStr(mStore_ID) + nxCrLf +
            '  and SSB.StoreCard_ID = ' + QuotedStr(mStoreCard_ID) + nxCrLf +
            '  and SSB.StoreBatch_ID in (' + mSerialNumbersSt + ')';
        end
        else
        begin
          if checkReservedQuantityInPositions then
            mSql :=
              'select' + nxCrLf +
              '  LSC.StoreBatch_ID as "id",' + nxCrLf +
              '  LSC.Quantity - LSC.QuantityReserved as "available"' + nxCrLf
          else
            mSql :=
              'select' + nxCrLf +
              '  LSC.StoreBatch_ID as "id",' + nxCrLf +
              '  LSC.Quantity as "available"' + nxCrLf;

          mSql := mSql +
            'from LogStoreContents LSC' + nxCrLf +
            'where' + nxCrLf +
            '  LSC.Parent_ID = ' + QuotedStr(mStorePosition_ID) + nxCrLf +
            '  and LSC.StoreCard_ID = ' + QuotedStr(mStoreCard_ID) + nxCrLf +
            '  and LSC.StoreBatch_ID in (' + mSerialNumbersSt + ')';
        end;

        AOS.SQLSelect2(mSql, mSerialNumbersAvailableQuantity);

        if not mSerialNumbersAvailableQuantity.Active then
        begin
          DataSet_CreataHeader(mSerialNumbersAvailableQuantity, 'id=S10,available=F');
          mSerialNumbersAvailableQuantity.Open;
        end;
      end
      else
      begin
        // pokud nejsou seriova cisla, tak si vytvorim prazdny dataset
        DataSet_CreataHeader(mSerialNumbersAvailableQuantity, 'id=S10,available=F');
        mSerialNumbersAvailableQuantity.Open;
      end;

      mDialogSql :=
        '  cast('''' as varchar(50)) as "dialog.title",' + nxCrLf +
        '  cast('''' as varchar(500)) as "dialog.text",' + nxCrLf +
        '  ''0'' as "dialog.type"';

      if CFxOID.IsEmpty(mStorePosition_ID) then
      begin
        // pokud neni zadana Pozice
        if CFxOID.IsEmpty(mStoreBatch_ID) then
        begin
          // a neni zadana sarze, zjistuju dostupne mnozstvi z StoreSubCards
          mSql :=
            'select' + nxCrLf +
            '  SSC.Quantity - SSC.BookedQuantity as "Available",' + nxCrLf +
            mDialogSql + nxCrLf +
            'from StoreSubCards SSC' + nxCrLf +
            'where' + nxCrLf +
            '  SSC.Store_ID = ' + QuotedStr(mStore_ID) + nxCrLf +
            '  and SSC.StoreCard_ID = ' + QuotedStr(mStoreCard_ID);
        end
        else begin
          // a je zadana sarze, zjistuju dostupne mnozstvi z StoreSubBatches
          mSql :=
            'select' + nxCrLf +
            '  SSB.Quantity - SSB.BookedQuantity as "Available",' + nxCrLf +
            mDialogSql + nxCrLf +
            'from StoreSubBatches SSB' + nxCrLf +
            'where' + nxCrLf +
            '  SSB.Store_ID = ' + QuotedStr(mStore_ID) + nxCrLf +
            '  and SSB.StoreCard_ID = ' + QuotedStr(mStoreCard_ID) + nxCrLf +
            '  and SSB.StoreBatch_ID = ' + QuotedStr(mStoreBatch_ID);
        end;
      end
      else begin
        // pokud je zadana Pozice, zjistuju dostupne mnozstvi z LogStoreContents
        if checkReservedQuantityInPositions then
          mSql :=
            'select' + nxCrLf +
            '  sum(LSC.Quantity - LSC.QuantityReserved) as "Available",' + nxCrLf +
            mDialogSql + nxCrLf
        else
          mSql :=
            'select' + nxCrLf +
            '  sum(LSC.Quantity) as "Available",' + nxCrLf +
            mDialogSql + nxCrLf;

        mSql := mSql +
            'from LogStoreContents LSC' + nxCrLf +
            'where' + nxCrLf +
            '  LSC.Parent_ID = ' + QuotedStr(mStorePosition_ID) + nxCrLf +
            '  and LSC.StoreCard_ID = ' + QuotedStr(mStoreCard_ID);
        if not CFxOID.IsEmpty(mStoreBatch_ID) then
          mSql := mSql + nxCrLf +
            '  and LSC.StoreBatch_ID = ' + QuotedStr(mStoreBatch_ID);
      end;

      AOS.SQLSelect2(mSql, dtHeader);

      if not dtHeader.Active then
      begin
        DataSet_CreataHeader(dtHeader, 'Available=F,dialog.title=S50,dialog.text=S500,dialog.type=S1');
        dtHeader.Open;
        dtHeader.Append;
        dtHeader.FieldByName('Available').AsFloat := 0;
        dtHeader.Post;
      end;

      mDialogTitle := '';
      mDialogText := '';
      mDialogType := 0;
      DialogOnRowSave(AOS, gSkladTermModule, gSkladTermDocType, gSkladTermUser_ID, mStoreDocument2_ID, mStoreCard_ID, mStoreBatch_ID, mStore_ID,
        mStorePosition_ID, mEnteredQuantity, mIsEditing, mDialogTitle, mDialogText, mDialogType);

      dtHeader.Edit;
      dtHeader.FieldByName('dialog.title').AsString := mDialogTitle;
      dtHeader.FieldByName('dialog.text').AsString := mDialogText;
      dtHeader.FieldByName('dialog.type').AsString := IntToStr(mDialogType);
      dtHeader.Post;

      dtHeader.First;

      try
        //hacek ve kterem lze ovlivnit mnozstvi povolene pro radek dokladu
        LogWriteSectionStart('get_AvailableQuantityHook');
        get_AvailableQuantityHook(AOS, gSkladTermModule, gSkladTermDocType, gSkladTermUser_ID, mStore_ID, mStorePosition_ID, mStorePositionTo_ID,
          mStoreCard_ID, mStoreBatch_ID, mStoreDocument2_ID, mSerialNumbers, mSerialNumbersAvailableQuantity, dtHeader, mQuantityDifference, mEnteredQuantity);
        LogWriteSectionEnd;

        LogWriteSectionStart('JSON');
        json := REST_jsonCreate_FromDataSetRow(dtHeader, nil, mSL);

        // vytvorim mapu, abych ve ctecce mohl jednoduse hledat, zda je na sklade, nebo neni
        jsonSerialNumbers := json.CreateJSON;
        mSerialNumbersAvailableQuantity.First;
        while not mSerialNumbersAvailableQuantity.Eof do
        begin
          jsonSerialNumbers.D[mSerialNumbersAvailableQuantity.FieldByName('id').AsString] :=
            mSerialNumbersAvailableQuantity.FieldByName('available').AsFloat;
          mSerialNumbersAvailableQuantity.Next;
        end;
        json.O['serialNumbers'] := jsonSerialNumbers;
        LogWriteSectionEnd;

        SetResponse(AResponse, json.AsJson(false, true));
      except
        SetPlainResponse(AResponse, ExceptionMessage, HTTP_SC_ExpectationFailed);
      end;
    finally
      dtHeader.Free;
      mSerialNumbers.Free;
      mSerialNumbersAvailableQuantity.Free;
      mSL.Free;
      if Assigned(json) then
        json.Free;
    end;
  finally
    CFxProfiler.ExitProc(REST_LogName, 'Post_AvailableQuantity');
    LogWriteSectionEnd;
  end;
end;

function listStoreCards(AOS: TNxCustomObjectSpace; ASearch, AStore_ID, AStorePosition_ID: String; AAllowedIds: String): String;
var
  mSql, mAuxText, mAvailableField, mAvailableJoin, mSelect, mFrom, mWhere, mJoin, mGroupBy, mOrderBy: String;
  mParameters: TStringList;
begin
  LogWriteSectionStart('listStoreCards');
  CFxProfiler.EnterProc(REST_LogName, 'listStoreCards');
  mParameters := TStringList.Create;
  try
    mSelect := '';
    mFrom := '';
    mWhere := '';
    mJoin := '';
    mOrderBy := '';

    mAuxText := StoreCardListAuxText(AOS, gSkladTermModule, gSkladTermDocType, gSkladTermUser_ID);

    if not CFxOID.IsEmpty(AStorePosition_ID) then
    begin
      mAvailableField := '  sum(coalesce((LSC.Quantity - LSC.QuantityReserved) / SU.UnitRate, 0)) as "Available"';
      mAvailableJoin := 'left join LogStoreContents LSC on LSC.StoreCard_ID = SC.ID and LSC.Parent_ID = ' + QuotedStr(AStorePosition_ID) + nxCrLf;
    end
    else if not CFxOID.IsEmpty(AStore_ID) then
    begin
      mAvailableField := '  sum(coalesce((SSC.Quantity - SSC.BookedQuantity) / SU.UnitRate, 0)) as "Available"';
      mAvailableJoin := 'left join StoreSubCards SSC on SSC.StoreCard_ID = SC.ID and SSC.Store_ID = ' + QuotedStr(AStore_ID) + nxCrLf;
    end
    else
    begin
      mAvailableField := '0.0 as "Available"';
      mAvailableJoin := '';
    end;

    mSelect :=
      '  SC.ID as "ID",' + nxCrLf +
      '  SC.' + cStoreCardInfoCodeField + ' as "Code",' + nxCrLf +
      '  SC.' + cStoreCardInfoNameField + ' as "Name",' + nxCrLf +
      '  ' + StoreCardListAuxText(AOS, gSkladTermModule, gSkladTermDocType, gSkladTermUser_ID) + ' as "auxText",' + nxCrLf +
      mAvailableField;

    mFrom :=
      'StoreCards SC';

    mJoin :=
      'left join StoreUnits SU on SU.Parent_ID = SC.ID and SU.Code = SC.MainUnitCode' + nxCrLf +
      mAvailableJoin;

    mWhere :=
      '  SC.Hidden = ''N''';

    if AAllowedIds <> '' then
      mWhere := mWhere + nxCrLf +
        '  and SC.ID in (''' + ReplaceText(AAllowedIds, ',', ''',''') + ''')';

    //pridam omezeni, pokud je nastaveno
    mWhere := mWhere +
      ListStoreCards_Search(AOS, gSkladTermModule, gSkladTermDocType, gSkladTermUser_ID, ASearch);

    mGroupBy :=
      '  SC.ID,' + nxCrLf +
      '  SC.' + cStoreCardInfoCodeField + ',' + nxCrLf +
      '  SC.' + cStoreCardInfoNameField;

    if mAuxText <> QuotedStr('') then
      mGroupBy := mGroupBy + ', ' + nxCrLf +
        mAuxText;

    mOrderBy :=
      '  SC.' + cStoreCardInfoCodeField;

    mParameters.Values('storePosition_id') := AStorePosition_ID;
    mParameters.Values('store_id') := AStore_ID;
    mParameters.Values('allowedIds') := AAllowedIds;

    mParameters.Values('select') := mSelect;
    mParameters.Values('from') := mFrom;
    mParameters.Values('join') := mJoin;
    mParameters.Values('where') := mWhere;
    mParameters.Values('groupby') := mGroupBy;
    mParameters.Values('orderby') := mOrderBy;

    FilterList(AOS, gSkladTermModule, gSkladTermDocType, gSkladTermUser_ID, 'listStoreCards', mParameters);

    mSql :=
      'select' + FIRST_TOP(100) + nxCrLf +
      mParameters.Values('select') + nxCrLf +
      'from ' +
      mParameters.Values('from') + nxCrLf;

    if mParameters.Values('join') <> '' then
      mSql := mSql + nxCrLf +
        mParameters.Values('join') + nxCrLf;

    if mParameters.Values('where') <> '' then
      mSql := mSql + nxCrLf +
        'where' + nxCrLf +
        mParameters.Values('where');

    if mParameters.Values('groupby') <> '' then
      mSql := mSql + nxCrLf +
        'group by' + nxCrLf +
        mParameters.Values('groupby');

    if mParameters.Values('orderby') <> '' then
      mSql := mSql + nxCrLf +
        'order by' + nxCrLf +
        mParameters.Values('orderby');

    mSql := mSql + nxCrLf +
      FIRST_TOP_ORACLE(100);

    Result := mSql;
  finally
    CFxProfiler.ExitProc(REST_LogName, 'listStoreCards');
    LogWriteSectionEnd;
  end;
end;

procedure get_StoreCardPicture(AOS: TNxCustomObjectSpace; APath, AResponse: TStringList);
var
  mStoreCard_ID, mFilePath, mSql: String;
  json, jsonPicture: TJSONSuperObject;
  mPicture: TNxCustomBusinessObject;
  mMS: TMemoryStream;
  mPicturesIds: TStringList;
  mImage: TImage;
  i: Integer;
begin
  json := nil;
  if (APath.Count = 2) then
  begin
    mStoreCard_ID := APath.Strings[1];
  end
  else
  begin
    SetPlainResponse(AResponse, getString('wrong_parameters_count'), HTTP_SC_BadRequest);
    exit;
  end;

  LogWriteSectionStart('StoreCardPicture');

  mPicture := AOS.CreateObject(Class_Picture);
  json := TJSONSuperObject.CreateByDataType(jtArray);
  mMS := TMemoryStream.Create;
  mImage := TImage.Create(nil);
  mPicturesIds := TStringList.Create;
  try
    mSql :=
      'select' + nxCrLf +
      '  Picture_ID' + nxCrLf +
      'from StoreCardPictures' + nxCrLf +
      'where' + nxCrLf +
      '  Parent_ID = ' + QuotedStr(mStoreCard_ID) + nxCrLf +
      'order by' + nxCrLf +
      '  PosIndex';
    AOS.SQLSelect(mSql, mPicturesIds);

    if mPicturesIds.Count = 0 then
      SetPlainResponse(AResponse, Format(getString('storecard_image_not_found'), [mStoreCard_ID]), HTTP_SC_NotFound)
    else
    begin
      for i := 0 to mPicturesIds.Count - 1 do
      begin
        mPicture.Load(mPicturesIds.Strings(i), nil);

        jsonPicture := TJSONSuperObject.CreateByDataType(jtObject);
        try
          jsonPicture.S['Picture_ID'] := mPicturesIds.Strings(i);
          jsonPicture.I['PosIndex'] := i;
          jsonPicture.S['Title'] := mPicture.GetFieldValueAsString('PictureTitle');

          // obrazek je bud v DB nebo externi
          if mPicture.GetFieldValueAsBoolean('ExternalFile') then
          begin
            mFilePath := mPicture.GetFieldValueAsString('PathAndFileName');
            mFilePath := get_StoreCardPicture_customPath(AOS, gSkladTermModule, mFilePath);
            if FileExists(mFilePath) then
            begin
              mMS.LoadFromFile(mFilePath);
              jsonPicture.S['Data'] := EncodeBase64(mMS.GetBytes);
            end;
          end
          else
          begin
            mMS.SetBytes(mPicture.GetFieldValueAsBytes('BlobData'));
            NxMultiFormatImageLoadFromStream(mMS, mImage.Picture);
            mMS.Clear;
            mImage.Picture.Graphic.SaveToStream(mMS);
            jsonPicture.S['Data'] := EncodeBase64(mMS.GetBytes);
          end;

          json.AsArray.Add(jsonPicture);
        finally
          jsonPicture.Free;
        end;
      end;
      SetResponse(AResponse, json.AsJson(false, true));
    end;
  finally
    mImage.Free;
    mMS.Free;
    mPicture.Free;
    json.Free;
    mPicturesIds.Free;
  end;

  LogWriteSectionEnd;
end;

procedure put_ProcessBarcode(AOS: TNxCustomObjectSpace; APath, AQueryParams: TStringList; ABody: String; AResponse: TStringList);
var
  mBarcode, mStoreCardNew_ID, mStoreBatchNew_ID, mSql, mNextStoreCardBarcode, mLastStoreCard_ID, mStoreBatchAux, mDocument_ID, mRow_ID, mAuxJson,
    mStorePositionFromNew_ID, mStorePositionToNew_ID, mDialogText, mStoreFromNew_ID, mFirm_ID, mUnitCodeNew, mStoreToNew_ID, mStoreCardNewNew_ID,
    mStoreBatchNewNew_ID: String;
  mUnitQuantityNew, mStoreBatchExpirationDateNew, mUnitRateNew: Double;
  mDialogType, index, mEmptyCount: Integer;
  json, jsonRoot, jsonSB, jsonSFrom, jsonSTo, jsonSPFrom, jsonSPTo, jsonSerialNumbers, inputJson, jsonSCNew, jsonSBNew: TJSONSuperObject;
  dtHeader, dtRows, dtStoreBatch, dtStorePositionFrom, dtSerialNumbers, dtUnits, dtEANs, mCurrentSerialNumbers, mInputValues, mOutputValues: TMemTable;
  mRowsList, mStoreCardIds, mQueryParams: TStringList;
  mExtendedInfo, mWithUnits, mSaveRow, mShowUnitConversion: Boolean;
begin
  LogWriteSectionStart('put_ProcessBarcode');
  CFxProfiler.EnterProc(REST_LogName, 'put_ProcessBarcode');
  try
    json := nil;
    jsonRoot := nil;
    jsonSB := nil;
    jsonSFrom := nil;
    jsonSTo := nil;
    jsonSPFrom := nil;
    jsonSPTo := nil;
    jsonSerialNumbers := nil;
    jsonSCNew := nil;
    jsonSBNew := nil;

    if APath.Count = 6 then
    begin
      mDocument_ID := APath.Strings[1];
      mRow_ID := APath.Strings[2];
      mFirm_ID := APath.Strings[3];
      mExtendedInfo := APath.Strings[4] = 'true';
      mWithUnits := APath.Strings[5] = 'true';
    end else
    begin
      SetPlainResponse(AResponse, getString('wrong_parameters_count'), HTTP_SC_BadRequest);
      exit;
    end;

    try
      mStoreCardNew_ID := '';
      mStoreBatchNew_ID := '';
      mStoreCardNewNew_ID := '';
      mStoreBatchNewNew_ID := '';
      mStoreBatchAux := '';
      mStorePositionFromNew_ID := '';
      mStorePositionToNew_ID := '';
      mUnitCodeNew:= '';
      mUnitQuantityNew := -1;
      mDialogText := '';
      mDialogType := 0;
      mStoreBatchExpirationDateNew := 0;
      mStoreFromNew_ID := '';
      mStoreToNew_ID := '';
      mUnitRateNew := 0;
      mNextStoreCardBarcode := '';

      dtStoreBatch := TMemTable.Create(nil);
      dtStorePositionFrom := TMemTable.Create(nil);
      dtSerialNumbers := TMemTable.Create(nil);
      mCurrentSerialNumbers := TMemTable.Create(nil);
      inputJson := TJSONSuperObject.ParseString(ABody, True);
      mInputValues := TMemTable.Create(nil);
      mOutputValues := TMemTable.Create(nil);
      mStoreCardIds := TStringList.Create;
      mQueryParams := TStringList.Create;
      try
        DataSet_CreataHeader(dtStoreBatch, 'ID=S10,StoreBatch_ID=S10,StoreBatchName=S40,StoreCard_ID=S10,StoreCardCode=S40,StoreCardName=S100,StoreCardCategory=I');
        DataSet_CreataHeader(dtStorePositionFrom, 'id=S10,code=S30,name=S50,type=I,'
          + 'storeId=S10,storeCode=S5,storeIsLogistic=B,preferredStoreBatchId=S40,preferredStoreBatchName=S40');
        DataSet_CreataHeader(dtSerialNumbers, 'SerNum_ID=S10,SerNumName=S40,AuxText=S30');
        DataSet_CreataHeader(mCurrentSerialNumbers, 'SerNum_ID=S10,SerNumName=S40,AuxText=S30');
        DataSet_CreataHeader(mInputValues, REST_ParseBarcodeInputValuesHeader);
        DataSet_CreataHeader(mOutputValues, REST_ParseBarcodeOutputValuesHeader);
        mOutputValues.AddIndex('storeCardId', 'StoreCard_ID', [ixPrimary]);
        mOutputValues.IndexName := 'storeCardId';

        mInputValues.Edit;
        mInputValues.FieldByName('Document_ID').AsString := mDocument_ID;
        mInputValues.FieldByName('Row_ID').AsString := mRow_ID;
        mInputValues.FieldByName('Firm_ID').AsString := mFirm_ID;
        mInputValues.FieldByName('StoreCard_ID').AsString := REST_getJSONStr(inputJson, 'StoreCard_ID');
        mInputValues.FieldByName('StoreCardNew_ID').AsString := REST_getJSONStr(inputJson, 'storeCardNew_ID');
        mInputValues.FieldByName('StoreFrom_ID').AsString := REST_getJSONStr(inputJson, 'StoreFrom_ID');
        mInputValues.FieldByName('StorePositionFrom_ID').AsString := REST_getJSONStr(inputJson, 'StorePositionFrom_ID');
        mInputValues.FieldByName('StoreTo_ID').AsString := REST_getJSONStr(inputJson, 'StoreTo_ID');
        mInputValues.FieldByName('StorePositionTo_ID').AsString := REST_getJSONStr(inputJson, 'StorePositionTo_ID');
        mInputValues.FieldByName('StoreBatch_ID').AsString := REST_getJSONStr(inputJson, 'StoreBatch_ID');
        mInputValues.FieldByName('StoreBatchNew_ID').AsString := REST_getJSONStr(inputJson, 'storeBatchNew_ID');
        mInputValues.FieldByName('UnitCode').AsString := REST_getJSONStr(inputJson, 'UnitCode');
        mInputValues.FieldByName('UnitQuantityOriginal').AsFloat := REST_getJSONDouble(inputJson, 'UnitQuantityOrig');
        mInputValues.FieldByName('UnitQuantityActual').AsFloat := REST_getJSONDouble(inputJson, 'UnitQuantity');
        mInputValues.Post;

        mBarcode := REST_getJSONStr(inputJson, 'StoreCardCode');

        REST_JsonToDataSet(inputJson.A['sernums'], mCurrentSerialNumbers);

        mOutputValues.Edit;
        mOutputValues.FieldByName('UnitQuantity').AsFloat := mUnitQuantityNew;

        parseBarcodeForRowSpecial(AOS, gSkladTermModule, gSkladTermDocType, gSkladTermUser_ID, mBarcode, mInputValues, mCurrentSerialNumbers,
        mOutputValues, dtStoreBatch, dtStorePositionFrom, dtSerialNumbers);
        if mOutputValues.Modified then
          mOutputValues.Post
        else
          mOutputValues.Cancel;

        mEmptyCount := 0;
        mLastStoreCard_ID := 'X';
        mOutputValues.First;
        while not mOutputValues.Eof do
        begin
          if mOutputValues.FieldByName('StoreCard_ID').AsString = mLastStoreCard_ID then
            RaiseException(getString('error_storecard_duplicate'));

          if CFxOID.IsEmpty(mOutputValues.FieldByName('StoreCard_ID').AsString) then
            mEmptyCount := mEmptyCount + 1;

          mStoreCardIds.Add(mOutputValues.FieldByName('StoreCard_ID').AsString);
          mLastStoreCard_ID := mOutputValues.FieldByName('StoreCard_ID').AsString;
          mOutputValues.Next;
        end;

        if mEmptyCount > 1 then
          RaiseException(getString('error_too_many_empty_storecard_ids'));

        dtHeader := TMemTable.Create(nil);
        dtRows := TMemTable.Create(nil);
        dtUnits := TMemTable.Create(nil);
        dtEANs := TMemTable.Create(nil);
        mRowsList := TStringList.Create;
        try
          // pokud jde o drobny majetek, potrebuju ziskat ID karty z jine tabulky
          if gSkladTermDocType = DOC_SmallAssetCard then
          begin
            if mStoreCardIds.Count = 0 then
              RaiseException(getString('error_no_storecard_id'));
            mSql := GetSmallAssetCardInfoSql(AOS, mStoreCardIds.Strings(0), True);
            mExtendedInfo := False;
          end
          else
            mSql := getStoreCardInfoSql(AOS, gSkladTermModule, gSkladTermDocType, gSkladTermUser_ID, mStoreCardIds, mFirm_ID,
              mInputValues.FieldByName('StoreFrom_ID').AsString, '', '', False);

          if mSql <> '' then
            AOS.SQLSelect2(mSql, dtHeader);

          if dtHeader.Active then
          begin
            GetStoreCardDetailInfo(AOS, mStoreCardIds, '', mExtendedInfo, mWithUnits, mRowsList, dtRows, dtUnits, dtEANs);

            dtHeader.First;
            jsonRoot := REST_jsonCreate_FromDataSet(dtHeader, nil, mRowsList);
          end
          else
          begin
            jsonRoot := TJSONSuperObject.CreateByDataType(jtArray);
            jsonRoot.AsArray.Add(TJSONSuperObject.CreateByDataType(jtObject));
          end;
        finally
          dtHeader.Free;
          dtRows.Free;
          dtUnits.Free;
          dtEANs.Free;
          mRowsList.Free;
        end;

        mOutputValues.First;
        index := 0;
        while not mOutputValues.Eof do
        begin
          mStoreCardNew_ID := mOutputValues.FieldByName('StoreCard_ID').AsString;
          mStoreBatchNew_ID := mOutputValues.FieldByName('StoreBatch_ID').AsString;
          mStoreCardNewNew_ID := mOutputValues.FieldByName('StoreCardNew_ID').AsString;
          mStoreBatchNewNew_ID := mOutputValues.FieldByName('StoreBatchNew_ID').AsString;
          mStoreBatchAux := mOutputValues.FieldByName('StoreBatchAux').AsString;
          mStoreBatchExpirationDateNew := mOutputValues.FieldByName('StoreBatchExpirationDate').AsDateTime;
          mStoreFromNew_ID := mOutputValues.FieldByName('StoreFrom_ID').AsString;
          mStoreToNew_ID := mOutputValues.FieldByName('StoreTo_ID').AsString;
          mStorePositionFromNew_ID := mOutputValues.FieldByName('StorePositionFrom_ID').AsString;
          mStorePositionToNew_ID := mOutputValues.FieldByName('StorePositionTo_ID').AsString;
          mUnitCodeNew :=  mOutputValues.FieldByName('UnitCode').AsString;
          mUnitQuantityNew := mOutputValues.FieldByName('UnitQuantity').AsFloat;
          mDialogText := mOutputValues.FieldByName('DialogText').AsString;
          mDialogType := mOutputValues.FieldByName('DialogType').AsInteger;
          mNextStoreCardBarcode := mOutputValues.FieldByName('NextStoreCardBarcode').AsString;
          mAuxJson := mOutputValues.FieldByName('AuxJson').AsString;
          mSaveRow := mOutputValues.FieldByName('SaveRow').AsBoolean;
          mShowUnitConversion := mOutputValues.FieldByName('ShowUnitConversion').AsBoolean;

          json := jsonRoot.AsArray.O[index];

          if mNextStoreCardBarcode <> '' then
            json.S['nextStoreCardBarcode'] := mNextStoreCardBarcode;

          if mOutputValues.FieldByName('AuxJson').AsString <> '' then
            json.S['json'] := mAuxJson;

          json.B['saveRow'] := mSaveRow;

          if not CFxOID.IsEmpty(mStoreCardNewNew_ID) then
          begin
            dtHeader := TMemTable.Create(nil);
            mRowsList := TStringList.Create;
            try
              mRowsList.Add(mStoreCardNewNew_ID);
              mSql := getStoreCardInfoSql(AOS, gSkladTermModule, gSkladTermDocType, gSkladTermUser_ID, mRowsList, mFirm_ID,
                  mInputValues.FieldByName('StoreTo_ID').AsString, '', '', False);
              AOS.SQLSelect2(mSql, dtHeader);

              jsonSCNew := REST_jsonCreate_FromDataSetRow(dtHeader, nil, nil);
            finally
              dtHeader.Free;
              mRowsList.Free;
            end;
            json.O['storeCardNew'] := jsonSCNew;
          end;

          // pokud mam sarzi, pridam ji
          if not CFxOID.IsEmpty(mStoreBatchNew_ID)then
          begin
            dtHeader := TMemTable.Create(nil);
            dtRows := TMemTable.Create(nil);
            mRowsList := TStringList.Create;
            try
              mSql := getStoreBatchInfoSql(AOS, gSkladTermModule, gSkladTermDocType, gSkladTermUser_ID, mStoreBatchNew_ID, '');
              AOS.SQLSelect2(mSql, dtHeader);

              if dtHeader.Active then
              begin
                GetStoreBatchDetailInfo(AOS, mStoreBatchNew_ID, mExtendedInfo, mRowsList, dtRows);
              end;

              jsonSB := REST_jsonCreate_FromDataSetRow(dtHeader, nil, mRowsList);
            finally
              dtHeader.Free;
              dtRows.Free;
              mRowsList.Free;
            end;

            json.O['StoreBatch'] := jsonSB;
            json.O['StoreBatch'].S['StoreBatchSpecification'] := mStoreBatchAux;
            if mStoreBatchExpirationDateNew > 0 then
              json.O['StoreBatch'].S['StoreBatchExpirationDate'] := REST_json_DateTime(mStoreBatchExpirationDateNew);
          end
          else if dtStoreBatch.RecordCount > 0 then
          begin
            dtStoreBatch.First;
            jsonSB := REST_jsonCreate_FromDataSetRow(dtStoreBatch, nil);
            json.O['StoreBatch'] := jsonSB;
            json.O['StoreBatch'].S['StoreBatchSpecification'] := mStoreBatchAux;
          end;


          if not CFxOID.IsEmpty(mStoreBatchNewNew_ID) then
          begin
            dtHeader := TMemTable.Create(nil);
            try
              mSql := getStoreBatchInfoSql(AOS, gSkladTermModule, gSkladTermDocType, gSkladTermUser_ID, mStoreBatchNewNew_ID, '');
              AOS.SQLSelect2(mSql, dtHeader);

              jsonSBNew := REST_jsonCreate_FromDataSetRow(dtHeader, nil, nil);
            finally
              dtHeader.Free;
            end;
            json.O['storeBatchNew'] := jsonSBNew;
          end;

          // pridam pripadne sklad z
          if not CFxOID.IsEmpty(mStoreFromNew_ID) then
          begin
            dtHeader := TMemTable.Create(nil);
            try
              mSql := getStoreInfoSql(AOS, gSkladTermModule, gSkladTermDocType, gSkladTermUser_ID, mStoreFromNew_ID);
              AOS.SQLSelect2(mSql, dtHeader);

              jsonSFrom := REST_jsonCreate_FromDataSetRow(dtHeader, nil);
            finally
              dtHeader.Free;
            end;
            json.O['StoreFrom'] := jsonSFrom;
          end;

          if mStoreToNew_ID <> '' then
          begin
            // pokud neni prazdne, ale neni to ID, tak poslu prazdny objekt, aby aplikace udaj smazala
            if CFxOID.IsEmpty(mStoreToNew_ID) then
              json.O['storeTo'] := json.CreateJSON
            else
            begin
              dtHeader := TMemTable.Create(nil);
              try
                mSql := getStoreInfoSql(AOS, gSkladTermModule, gSkladTermDocType, gSkladTermUser_ID, mStoreToNew_ID);
                AOS.SQLSelect2(mSql, dtHeader);

                jsonSTo := REST_jsonCreate_FromDataSetRow(dtHeader, nil);
              finally
                dtHeader.Free;
              end;
              json.O['storeTo'] := jsonSTo;
            end;
          end;

          // pridam pripadne pozici z
          if not CFxOID.IsEmpty(mStorePositionFromNew_ID) then
          begin
            dtHeader := TMemTable.Create(nil);
            dtRows := TMemTable.Create(nil);
            mRowsList := TStringList.Create;
            try
              mSql := getStorePositionInfoSql(AOS, gSkladTermModule, gSkladTermDocType, gSkladTermUser_ID, mStorePositionFromNew_ID, mQueryParams);
              AOS.SQLSelect2(mSql, dtHeader);

              if dtHeader.Active then
                GetStorePositionDetailInfo(AOS, mStorePositionFromNew_ID, mExtendedInfo, mRowsList, dtRows);

              jsonSPFrom := REST_jsonCreate_FromDataSetRow(dtHeader, nil, mRowsList);
            finally
              dtHeader.Free;
              dtRows.Free;
              mRowsList.Free;
            end;
            json.O['StorePositionFrom'] := jsonSPFrom;
          end
          else if dtStorePositionFrom.RecordCount > 0 then
          begin
            dtStorePositionFrom.First;
            jsonSPFrom := REST_jsonCreate_FromDataSetRow(dtStorePositionFrom, nil);
            json.O['StorePositionFrom'] := jsonSPFrom;
          end;

          if not CFxOID.IsEmpty(mStorePositionToNew_ID) then
          begin
            dtHeader := TMemTable.Create(nil);
            try
              mSql := getStorePositionInfoSql(AOS, gSkladTermModule, gSkladTermDocType, gSkladTermUser_ID, mStorePositionToNew_ID, mQueryParams);
              AOS.SQLSelect2(mSql, dtHeader);

              jsonSPTo := REST_jsonCreate_FromDataSetRow(dtHeader, nil);
            finally
              dtHeader.Free;
            end;
            json.O['StorePositionTo'] := jsonSPTo;
          end;

          if mUnitCodeNew <> '' then
          begin
            mSql :=
              'select' + nxCrLf +
              '  SU.UnitRate' + nxCrLf +
              'from StoreUnits SU' + nxCrLf +
              'where' + nxCrLf +
              '  SU.Parent_ID = ' + QuotedStr(mStoreCardNew_ID) + nxCrLf +
              '  and SU.Code = ' + QuotedStr(mUnitCodeNew);
            mUnitRateNew := SQLSelectFloat(AOS, mSql);

            if CFxFloat.GreaterThan6(mUnitRateNew, 0) then
            begin
              json.S['SelectedUnitCode'] := mUnitCodeNew;
              json.D['SelectedUnitRate'] := mUnitRateNew;
            end;
            json.B['showUnitConversion'] := mShowUnitConversion;
          end;

          json.D['UnitQuantity'] := mUnitQuantityNew;

          if mDialogText <> '' then
          begin
            json.S['DialogText'] := mDialogText;
            json.I['DialogType'] := mDialogType;
          end;

          if dtSerialNumbers.RecordCount > 0 then
          begin
            dtSerialNumbers.First;
            jsonSerialNumbers := REST_jsonCreate_FromDataSet(dtSerialNumbers, nil);
            json.O['SerialNumbers'] := jsonSerialNumbers;
          end;

          index := index + 1;
          mOutputValues.Next;
        end;

        SetResponse(AResponse, jsonRoot.AsJson(false, true));
      finally
        mInputValues.Free;
        mQueryParams.Free;
        mOutputValues.Free;
        dtStoreBatch.Free;
        dtStorePositionFrom.Free;
        dtSerialNumbers.Free;
        mStoreCardIds.Free;
        mCurrentSerialNumbers.Free;
        inputJson.Free;
        if Assigned(jsonRoot) then
          jsonRoot.Free;
        if Assigned(jsonSB) then
          jsonSB.Free;
        if Assigned(jsonSFrom) then
          jsonSFrom.Free;
        if Assigned(jsonSTo) then
          jsonSTo.Free;
        if Assigned(jsonSPFrom) then
          jsonSPFrom.Free;
        if Assigned(jsonSPTo) then
          jsonSPTo.Free;
        if Assigned(jsonSerialNumbers) then
          jsonSerialNumbers.Free;
        if Assigned(jsonSCNew) then
          jsonSCNew.Free;
        if Assigned(jsonSBNew) then
          jsonSBNew.Free;
      end;
    except
      SetPlainResponse(AResponse, getExceptionMessage, HTTP_SC_ExpectationFailed);
    end;
  finally
    CFxProfiler.ExitProc(REST_LogName, 'put_ProcessBarcode');
    LogWriteSectionEnd;
  end;
end;

function listStoreUnits(ASearch, AStoreCard_ID: String): String;
var
  mSql, mStoreCard_ID: String;
begin
  LogWriteSectionStart('listStoreUnits');
  try
    mSql :=
      'select ' + FIRST_TOP(100) + NxCrLf +
      '  SU.ID as "ID",' + NxCrLf +
      '  SU.Code as "Code",' + NxCrLf +
      '  SU.Description as "Name"' + NxCrLf +
      'from StoreUnits SU' + NxCrLf +
      'where' + NxCrLf +
      '  SU.Parent_ID = ' + QuotedStr(AStoreCard_ID) + NxCrLf;
    if trim(ASearch) <> '' then
      mSql := mSql + 'and (SU.Code' + COLLATION_AI + 'like ''%' + ASearch + '%'' ' +
        '  or SU.Description' + COLLATION_AI + 'like ''%' + ASearch + '%'') ';
    mSql := mSql +
      ' order by SU.Code' +
      FIRST_TOP_ORACLE(100);

    Result := mSql;
  finally
    LogWriteSectionEnd;
  end;
end;

procedure get_StoreUnitInfo(AOS: TNxCustomObjectSpace; APath, AResponse: TStringList);
var
  mStoreUnit_ID: String;
  dtHeader: TMemTable;
  dtRows: TMemTable;
  mSL: TStringList;
  mSql: String;
  json: TJSONSuperObject;
begin
  json := nil;
  if (APath.Count = 2) then
  begin
    mStoreUnit_ID := APath.Strings[1];
  end else
  begin
    SetPlainResponse(AResponse, getString('wrong_parameters_count'), HTTP_SC_BadRequest);
    exit;
  end;

  dtHeader := TMemTable.Create(nil);
  try
    // hlavicka skladu
    LogWriteSectionStart('get_StoreUnitInfo');
    mSql :=
      'select' + nxCrLf +
      '  SU.ID as "StoreUnit_ID",' + nxCrLf +
      '  SU.Code as "StoreUnitCode",' + nxCrLf +
      '  SU.Description as "StoreUnitDescription",' + nxCrLf +
      '  SU.UnitRate as "StoreUnitRate",' + nxCrLf +
      '  case' + nxCrLf +
      '    when SC.MainUnitCode = SU.Code' + nxCrLf +
      '    then ''A''' + nxCrLf +
      '    else ''N''' + nxCrLf +
      '  end "IsMainUnit$BOOL"' + nxCrLf +
      'from StoreUnits SU' + nxCrLf +
      'join StoreCards SC on SC.ID = SU.Parent_ID' + nxCrLf +
      'where' + nxCrLf +
      '  SU.ID = ' + QuotedStr(mStoreUnit_ID);
    AOS.SQLSelect2(mSql, dtHeader);

    LogWriteSectionEnd;

    if dtHeader.Active then
    begin
      dtHeader.First;
      LogWriteSectionStart('JSON');
      json := REST_jsonCreate_FromDataSetRow(dtHeader, nil, nil);
      LogWriteSectionEnd;

      SetResponse(AResponse, json.AsJson(false, true));
    end
    else
      SetPlainResponse(AResponse, Format(getString('storeunit_not_found'), [mStoreUnit_ID]), HTTP_SC_NotFound);
  finally
    dtHeader.Free;
    if Assigned(json) then
      json.Free;
  end;
end;

procedure Put_SaveStoreCardUnit(AOS: TNxCustomObjectSpace; APath: TStringList; ABody: String; AResponse: TStringList);
var
  mStoreCard_ID, mStoreUnit_ID: String;
  mSql: String;
  dtEANs: TMemTable;
  json: TJSONSuperObject;
  i: integer;
  mStoreUnit, mStoreCard, mEAN: TNxCustomBusinessObject;
  mStoreUnits, mEans: TNxCustomBusinessMonikerCollection;
begin
  if (APath.Count = 2) then
  begin
    mStoreCard_ID := APath.Strings[1];
  end else
  begin
    SetPlainResponse(AResponse, getString('wrong_parameters_count'), HTTP_SC_BadRequest);
    exit;
  end;

  LogWriteSectionStart('put_SaveStoreCardUnit');

  json := TJSONSuperObject.ParseString(ABody, True);
  dtEANs := TMemTable.Create(nil);
  mStoreCard := AOS.CreateObject(Class_StoreCard);
  try
    // dataset, do ktereho si preplnime EANy
    DataSet_CreataHeader(dtEANs, 'StoreEAN_ID=S10,StoreEAN=S60');
    dtEANs.Open;

    AOS.StartTransaction(taReadCommited);
    try
      mStoreCard.ExplicitTransaction := True;
      mStoreCard.Load(mStoreCard_ID, nil);

      mStoreUnits := mStoreCard.GetLoadedCollectionMonikerForFieldCode(mStoreCard.GetFieldCode('StoreUnits'));

      for i := 0 to mStoreUnits.Count - 1 do
      begin
        mStoreUnit := mStoreUnits.BusinessObject(i);
        mStoreUnit_ID := mStoreUnit.OID;

        if mStoreUnit_ID = json.O['StoreUnit_ID'].AsString then
        begin
          // upravim EANy
          mEans := mStoreUnit.GetLoadedCollectionMonikerForFieldCode(mStoreUnit.GetFieldCode('StoreEANs'));
          REST_JsonToDataSet(json.A['eans'], dtEANs);
          if(dtEANs.Active)then
          begin
            dtEANs.First;
            while(not dtEANs.Eof)do
            begin
              if dtEANs.FieldByName('StoreEAN_ID').AsString = '' then
              begin
                mEAN := mEans.AddNewObject;
                mEAN.Prefill;
                mEAN.SetFieldValueAsString('EAN', dtEANs.FieldByName('StoreEAN').AsString);
              end;
              dtEANs.Next;
            end;
          end;

          break;
        end;
      end;

      if mStoreCard.NeedSave then
        mStoreCard.Save;

      AOS.Commit;

      SetResponse(AResponse, PlainResponse(''));
    except
      AOS.RollBack;
      SetPlainResponse(AResponse, ExceptionMessage, HTTP_SC_ExpectationFailed);
      gLog.WriteEvent(logError, 'put_SaveStoreCardUnit - error - ' + ExceptionMessage);
    end;
  finally
    mStoreCard.Free;
    json.Free;
    dtEANs.Free;
    LogWriteSectionEnd;
  end;
end;

procedure Post_CheckEanExistence(AOS: TNxCustomObjectSpace; ABody: String; APath, AResponse: TStringList);
var
  mSql, mEan, mEanFounded_ID: String;
begin
  if APath.Count <> 1 then
  begin
    SetPlainResponse(AResponse, getString('wrong_parameters_count'), HTTP_SC_BadRequest);
    exit;
  end;

  LogWriteSectionStart('Post_CheckEanExistence');
  try
    mEan := ABody;
    // vypada to, ze se barcode posle z aplikace v uvozovkach, takze je odstranim
    if pos('"', mEan) = 1 then
      mEan := copy(mEan, 2, Length(mEan) - 2);

    mSql :=
      'select ID from StoreEANS where EAN = ' + QuotedStr(mEan);

    mEanFounded_ID := SQLSelectStr(AOS, mSql);

    if mEanFounded_ID = '' then
      SetResponse(AResponse, PlainResponse(''))
    else
      SetPlainResponse(AResponse, Format(getString('error_ean_already_exists'), [mEan]), HTTP_SC_ExpectationFailed);
  except
    SetPlainResponse(AResponse, ExceptionMessage, HTTP_SC_ExpectationFailed);
    LogWriteSectionEnd;
  end;

  LogWriteSectionEnd;
end;

begin
end.