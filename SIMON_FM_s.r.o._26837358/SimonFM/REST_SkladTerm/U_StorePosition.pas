uses
  'REST_SkladTerm.U_Func',
  'REST_SkladTerm.U_FuncJSON',
  'REST_SkladTerm.U_SQLQueries',
  'REST_SkladTerm.U_Translation',
  'REST_SkladTerm_Special.U_Const',
  'REST_SkladTerm_Special.U_StandardHooks',
  'StandardUnits.U_GetId';

procedure get_StorePositionInfo(AOS: TNxCustomObjectSpace; APath, AQueryParams, AResponse: TStringList);
var
  mStorePosition_ID, mStoreCard_ID, mStoreBatch_ID: String;
  mAvailableQuantity: Double;
  mExtendedInfo: Boolean;
  dtHeader: TMemTable;
  dtRows, dtStoreBatches: TMemTable;
  mSL: TStringList;
  mSql: String;
  json: TJSONSuperObject;
begin
  json := nil;

  mStoreCard_ID := '';
  mStoreBatch_ID := '';

  if (APath.Count >= 2) or (APath.Count <= 5) then
  begin
    mStorePosition_ID := APath.Strings[1];
    mExtendedInfo := False;
    if APath.Count >= 3 then
      mExtendedInfo := APath.Strings[2] = 'true';
    if APath.Count >= 4 then
      mStoreCard_ID := APath.Strings[3];
    if APath.Count >= 5 then
      mStoreBatch_ID := APath.Strings[4];
  end else
  begin
    SetPlainResponse(AResponse, getString('wrong_parameters_count'), HTTP_SC_BadRequest);
    exit;
  end;

  dtHeader := TMemTable.Create(nil);
  dtRows := TMemTable.Create(nil);
  dtStoreBatches := TMemTable.Create(nil);
  mSL := TStringList.Create;
  try
    // hlavicka pozice
    LogWriteSectionStart('StorePositionInfo');

    mSql := getStorePositionInfoSql(AOS, gSkladTermModule, gSkladTermDocType, gSkladTermUser_ID, mStorePosition_ID, AQueryParams);
    AOS.SQLSelect2(mSql, dtHeader);

    // doplneni preferovane sarze
    if dtHeader.Active then
    begin
      if not CFxOID.IsEmpty(mStoreCard_ID) then
      begin
        mSql :=
          'select' + nxCrLf +
          '  SB.ID, SB.Name' + nxCrLf +
          'from LogStoreContents LSC' + nxCrLf +
          'join StoreBatches SB on SB.ID = LSC.StoreBatch_ID' + nxCrLf +
          'where' + nxCrLf +
          '  LSC.Parent_ID = ' + QuotedStr(mStorePosition_ID) + nxCrLf +
          '  and LSC.StoreCard_ID = ' + QuotedStr(mStoreCard_ID) + nxCrLf +
          '  and LSC.Quantity - LSC.QuantityReserved > 0 ';
        AOS.SQLSelect2(mSql, dtStoreBatches);

        // pokud je na pozici prave jedna sarze s dispozici, vratime ji jako preferovanou pro predvyplneni
        if dtStoreBatches.Active and (dtStoreBatches.RecordCount = 1) then
        begin
          dtHeader.First;
          dtHeader.Edit;
          dtStoreBatches.First;
          dtHeader.FieldByName('preferredStoreBatchId').AsString := dtStoreBatches.FieldByName('ID').AsString;
          dtHeader.FieldByName('preferredStoreBatchName').AsString := dtStoreBatches.FieldByName('Name').AsString;
          dtHeader.Post;
        end;
      end;

      GetStorePositionDetailInfo(AOS, mStorePosition_ID, mExtendedInfo, mSL, dtRows);

      if not mExtendedInfo and StorePosition_CheckAvailableQuantityImmediately(AOS, gSkladTermModule, gSkladTermDocType, gSkladTermUser_ID, mStoreCard_ID, mStorePosition_ID) then
      begin
        if CFxOID.IsEmpty(mStoreCard_ID) then
          gLog.WriteEvent(logWarning, getString('warning_storecard_not_passed'))
        else
        begin
          mSql :=
            'select' + nxCrLf +
            '  sum(LSC.Quantity - LSC.QuantityReserved) as "Available"' + nxCrLf;

          mSql := mSql +
            'from LogStoreContents LSC' + nxCrLf +
            'join LogStorePositions LSP on LSP.ID = LSC.Parent_ID' + nxCrLf +
            'where' + nxCrLf +
            '  LSC.Parent_ID = ' + QuotedStr(mStorePosition_ID) + nxCrLf;

          if not CFxOID.IsEmpty(mStoreCard_ID) then
            mSql := mSql + '  and LSC.StoreCard_ID = ' + QuotedStr(mStoreCard_ID) + nxCrLf;

          if not CFxOID.IsEmpty(mStoreBatch_ID) then
            mSql := mSql + '  and LSC.StoreBatch_ID = ' + QuotedStr(mStoreBatch_ID) + nxCrLf;

          mAvailableQuantity := SQLSelectFloat(AOS, mSql);

          dtHeader.Edit;
          dtHeader.FieldByName('availableQuantity').AsFloat := mAvailableQuantity;
          dtHeader.Post;
        end;
      end;
    end;
    LogWriteSectionEnd;

    if dtHeader.Active then
    begin
      dtHeader.First;
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
    dtStoreBatches.Free;
    mSL.Free;
    if Assigned(json) then
      json.Free;
  end;
end;

procedure get_AuxStorePositionInfo(AOS: TNxCustomObjectSpace; APath, AResponse: TStringList);
var
  mStore_ID: String;
  dtHeader: TMemTable;
  mSL: TStringList;
  mSql: String;
  json: TJSONSuperObject;
begin
  json := nil;
  if (APath.Count = 2) then
  begin
    mStore_ID := APath.Strings[1]; //ocekavam pozici
  end else
  begin
    SetPlainResponse(AResponse, getString('wrong_parameters_count'), HTTP_SC_BadRequest);
    exit;
  end;

  dtHeader := TMemTable.Create(nil);
  mSL := TStringList.Create;
  try
    // hlavicka pozice
    LogWriteSectionStart('AuxStorePositionInfo');

    mSql := 'select ' + FIRST_TOP(1) +
      '  LSP.ID as "id", ' +
      '  LSP.Code as "code", ' +
      '  LSP.Name as "name", ' +
      '  LSP.PositionType as "type", ' +
      '  S.ID as "storeId", ' +
      '  S.Code as "storeCode", ' +
      '  S.IsLogistic as "storeIsLogistic$BOOL", ' +
      '  cast('''' as varchar(40)) as "preferredStoreBatchId", ' +
      '  cast('''' as varchar(40)) as "preferredStoreBatchName" ' +
      'from LogStorePositions LSP ' +
      'join Stores S on S.ID = LSP.Store_ID ' +
      'where S.ID = ' + QuotedStr(mStore_ID) +
      '  and LSP.X_IsAux = ''A''' +
      FIRST_TOP_ORACLE(1);

    AOS.SQLSelect2(mSql, dtHeader);
    if dtHeader.Active then
    begin
      dtHeader.First;
      LogWriteSectionStart('JSON');
      json := REST_jsonCreate_FromDataSetRow(dtHeader, nil, mSL);
      LogWriteSectionEnd;

      SetResponse(AResponse, json.AsJson(false, true));
    end
    else
      SetPlainResponse(AResponse, Format(getString('aux_position_not_found'), [mStore_ID]), HTTP_SC_NotFound);
  finally
    dtHeader.Free;
    mSL.Free;
    if Assigned(json) then
      json.Free;
  end;
end;

// Vrátí pozici, pokud je na DIPu.
procedure get_StorePositionInfo2(AOS: TNxCustomObjectSpace; APath, AResponse: TStringList);
var
  mStorePosition_ID, sDip_ID: String;
  dtHeader: TMemTable;
  dtPos: TMemTable;
  mSL: TStringList;
  mSql: String;
  json: TJSONSuperObject;
begin
  json := nil;
  if (APath.Count = 3) then
  begin
    mStorePosition_ID := APath.Strings[1];
    sDip_ID := APath.Strings[2];
  end else
  begin
    SetPlainResponse(AResponse, getString('wrong_parameters_count'), HTTP_SC_BadRequest);
    exit;
  end;

  dtHeader := TMemTable.Create(nil);
  mSL := TStringList.Create;
  try
    // hlavicka pozice
    LogWriteSectionStart('get_StorePositionInfo2');
    mSql :=
      'select' + nxCrLf +
      '  LSP.ID as "id",' + nxCrLf +
      '  LSP.Code as "code",' + nxCrLf +
      '  LSP.Name as "name",' + nxCrLf +
      '  LSP.PositionType as "type",' + nxCrLf +
      '  S.ID as "storeId",' + nxCrLf +
      '  S.Code as "storeCode",' + nxCrLf +
      '  S.IsLogistic as "storeIsLogistic$BOOL"' + nxCrLf +
      'from LogStorePositions LSP' + nxCrLf +
      'join Stores S on S.ID = LSP.Store_ID' + nxCrLf +
      'join MainInvProtocolPositions MIPP on MIPP.StorePosition_ID = LSP.id' + nxCrLf +
      'join PartialInvProtocolPositions PIPP on PIPP.MIPPosition_ID = MIPP.id' + nxCrLf +
      'where' + nxCrLf +
      '  LSP.ID = ' + QuotedStr(mStorePosition_ID) + nxCrLf +
      '  and PIPP.Parent_ID = ' + QuotedStr(sDip_ID);
    AOS.SQLSelect2(mSql, dtHeader);

    LogWriteSectionEnd;

    if dtHeader.Active then
    begin
      dtHeader.First;
      LogWriteSectionStart('JSON');
      json := REST_jsonCreate_FromDataSetRow(dtHeader, nil, mSL);
      LogWriteSectionEnd;

      PlainResponse(json.AsJson(false, true));
    end
    else
      SetPlainResponse(AResponse, Format(getString('position_not_found_or_entered'), [mStorePosition_ID]), HTTP_SC_NotFound);
  finally
    dtHeader.Free;
    mSL.Free;
    if Assigned(json) then
      json.Free;
  end;
end;

function listStorePositions(AOS: TNxCustomObjectSpace; ASearch, AStore_ID, AStoreCard_ID, AStoreBatch_ID: String;
  mOnlyAvailable, mInPositionFirst: Boolean): String;
var
  mQuantityString, mQuantityReservedString: String;
  dtRows: TMemTable;
  mSql, mSqlAvailable: String;
  json: TJSONSuperObject;
begin
  LogWriteSectionStart('listStorePositions');
  try
    if listStorePositions_IncludeReservedQuantity(AOS, gSkladTermModule, gSkladTermDocType, gSkladTermUser_ID) then
      mQuantityString := 'LSC.Quantity / SU.UnitRate'
    else
      mQuantityString := '(LSC.Quantity - LSC.QuantityReserved) / SU.UnitRate';

    mQuantityReservedString := 'LSC.QuantityReserved / SU.UnitRate';

    // pokud se zobrazuje vse (mOnlyAvailable = false), tak jde o prijem a chci v dispozici videt jen soucet za vybrany artikl
    // jinak jde nejspis o vydej a tam to chci omezene za vsechny vybrane udaje (napr. sarzi)
    if not mOnlyAvailable then
    begin
      if not CFxOID.IsEmpty(AStoreCard_ID) then
      begin
        mQuantityString := 'case when LSC.StoreCard_ID = ' + QuotedStr(AStoreCard_ID) + ' then ' + mQuantityString + ' end';
        mQuantityReservedString := 'case when LSC.StoreCard_ID = ' + QuotedStr(AStoreCard_ID) + ' then ' + mQuantityReservedString + ' end';
      end;
    end;

    mSql :=
      'select' + FIRST_TOP(100) + nxCrLf +
      '  LSP.ID as "ID",' + nxCrLf +
      '  LSP.Code as "Code",' + nxCrLf +
      '  ' + listStorePositions_SelectName(AOS) + ' as "Name",' + nxCrLf +
      '  coalesce(sum(' + mQuantityString + '), 0) as "Available",' + nxCrLf +
      '  coalesce(sum(' + mQuantityReservedString + '), 0) as "Reserved"' + nxCrLf +
      'from LogStorePositions LSP' + nxCrLf +
      'left join LogStoreContents LSC on LSC.Parent_ID = LSP.ID';

    // k joinu automaticky pripojim podminky na pripadny artikl nebo sarzi
    if mOnlyAvailable then
    begin
      if not CFxOID.IsEmpty(AStoreCard_ID) then
        mSql := mSql + ' and LSC.StoreCard_ID = ' + QuotedStr(AStoreCard_ID);

      if not CFxOID.IsEmpty(AStoreBatch_ID) then
        mSql := mSql + ' and LSC.StoreBatch_ID = ' + QuotedStr(AStoreBatch_ID);
    end;

    mSql := mSql + nxCrLf +
      'left join StoreCards SC on SC.ID = LSC.StoreCard_ID' + nxCrLf +
      'left join StoreUnits SU on SU.Parent_ID = SC.ID and SU.Code = SC.MainUnitCode' + nxCrLf;

    mSql := mSql + nxCrLf +
      listStorePositions_Join(AOS) + nxCrLf +
      'where' + nxCrLf +
      '  LSP.Hidden = ''N''' + nxCrLf;

    if not CFxOID.IsEmpty(AStore_ID) then
      mSql := mSql + '  and LSP.Store_ID = ' + QuotedStr(AStore_ID) + nxCrLf;

    mSql := mSql + listStorePositions_Search(AOS, gSkladTermModule, gSkladTermDocType, gSkladTermUser_ID, AStore_ID,
      AStoreCard_ID, AStoreBatch_ID) + nxCrLf;

    // pripadne hledani
    if trim(ASearch) <> '' then
    begin
      // muze se stat, ze nekdo do hledaciho okynka naskenuje carovy kod pozice ve tvaru SPXXXXXXXXXX
      if (length(ASearch) = 12) and (copy(ASearch, 1, 2) = 'SP') then
        ASearch := copy(ASearch, 3, 10);
      mSql := mSql +
        '  and (LSP.Code' + COLLATION_AI + 'like ''%' + ASearch + '%''' + nxCrLf +
        '    or LSP.Name' + COLLATION_AI + 'like ''%' + ASearch + '%''' + nxCrLf +
        '    or LSP.ID = ' + QuotedStr(ASearch) + ')' + nxCrLf;
    end;

    mSql := mSql +
      'group by' + nxCrLf +
      '  LSP.ID,' + nxCrLf +
      '  LSP.Code,' + nxCrLf +
      '  LSP.Name' + nxCrLf;

    if mOnlyAvailable then
      mSql := mSql +
        'having' + nxCrLf +
        '   sum(' + mQuantityString + ') > 0' + nxCrLf;

    // razeni bud podle kodu, nebo pujdou prvni pozice, kde uz zbozi je
    if mInPositionFirst then
      mSql := mSql +
        'order by' + nxCrLf +
        '  case when sum(' + mQuantityString + ') > 0 then 0 else 1 end, LSP.Code'
    else
      mSql := mSql +
        'order by' + nxCrLf +
        '  LSP.Code';

    mSql := mSql + FIRST_TOP_ORACLE(100);

    Result := mSql;
  finally
    LogWriteSectionEnd;
  end;
end;

procedure GetStorePositionDetailInfo(AOS: TNxCustomObjectSpace; AStorePosition_ID: String; AWithExtendedInfo: Boolean;
  OOutput: TStringList; AExtendedInfo: TMemTable);
var
  mSql: String;
begin
  if AWithExtendedInfo then
  begin
    mSql :=
      'select' + nxCrLf +
      '  max(LSC.ID) as "ID",' + nxCrLf +
      '  max(LSC.Parent_ID) as "XX_Parent_ID",' + nxCrLf +
      '  max(SC.ID) as "StoreCard_ID", ' + nxCrLf +
      '  max(SC.' + cStoreCardInfoCodeField + ') as "StoreCardCode",' + nxCrLf +
      '  max(SC.' + cStoreCardInfoNameField + ') as "StoreCardName",' + nxCrLf;

    if AvailableInStockActivity_Position_ShowBatches(AOS, gSkladTermModule, gSkladTermDocType, gSkladTermUser_ID) then
      mSql := mSql +
        '  max(SB.ID) as "StoreBatch_ID",' + nxCrLf +
        '  max(SB.Name) as "StoreBatchName",' + nxCrLf
    else
      mSql := mSql +
        '  '''' as "StoreBatch_ID",' + nxCrLf +
        '  '''' as "StoreBatchName",' + nxCrLf;

    mSql := mSql +
      '  max(SC.MainUnitCode) as "MainUnitCode",' + nxCrLf +
      '  sum(LSC.Quantity - LSC.QuantityReserved) as "Available",' + nxCrLf +
      '  sum(LSC.QuantityReserved) as "Booked"' + nxCrLf +
      'from LogStoreContents LSC' + nxCrLf +
      'join StoreCards SC on SC.ID = LSC.StoreCard_ID' + nxCrLf +
      'left join StoreBatches SB on SB.ID = LSC.StoreBatch_ID' + nxCrLf +
      'where LSC.Parent_ID = ' + QuotedStr(AStorePosition_ID) + nxCrLf;

    if AvailableInStockActivity_Position_ShowBatches(AOS, gSkladTermModule, gSkladTermDocType, gSkladTermUser_ID) then
      mSql := mSql +
        'group by LSC.StoreCard_ID, LSC.StoreBatch_ID' + nxCrLf
    else
      mSql := mSql +
        'group by LSC.StoreCard_ID' + nxCrLf;

    mSql := mSql +
      'having sum(LSC.Quantity) <> 0 ' + nxCrLf;

    if AvailableInStockActivity_Position_ShowBatches(AOS, gSkladTermModule, gSkladTermDocType, gSkladTermUser_ID) then
      mSql := mSql +
        'order by max(SC.' + cStoreCardInfoCodeField + '), max(SB.Name)'
    else
      mSql := mSql +
        'order by max(SC.' + cStoreCardInfoCodeField + ')';

    AOS.SQLSelect2(mSql, AExtendedInfo);
    if AExtendedInfo.Active then
    begin
      AExtendedInfo.AddIndex('id', REST_XX_Parent_ID + ';StoreCardCode;StoreCard_ID;StoreBatchName;StoreBatch_ID', [ixUnique]);
      AExtendedInfo.IndexName := 'id';
      OOutput.AddObject('rows=', AExtendedInfo);
    end;
  end;
end;

begin
end.