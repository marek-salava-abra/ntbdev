uses
  'REST_SkladTerm.U_Func',
  'REST_SkladTerm.U_FuncJSON',
  'REST_SkladTerm.U_SQLQueries',
  'REST_SkladTerm.U_Translation',
  'REST_SkladTerm_Special.U_Const',
  'REST_SkladTerm_Special.U_StandardHooks',
  'StandardUnits.U_GetId';

///////////////////////////////////////////////////////////////////////////////
procedure get_StorePositionInfo(Self: TNxWebServicesHelper; ARequest: TNxHTTPRequest;
  AResponse: TNxHTTPResponse; slPath: TStringList);
var
  mStorePosition_ID, mStoreCard_ID, mStoreBatch_ID, mUser_ID, mDocType, mModule: String;
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

  if (slPath.Count >= 2) or (slPath.Count <= 5) then
  begin
    mStorePosition_ID := slPath.Strings[1]; //ocekavam pozici
    mExtendedInfo := False;
    if slPath.Count >= 3 then
      mExtendedInfo := slPath.Strings[2] = 'true';
    if slPath.Count >= 4 then
      mStoreCard_ID := slPath.Strings[3];
    if slPath.Count >= 5 then
      mStoreBatch_ID := slPath.Strings[4];
  end else
  begin
    ErrREST(ARequest, AResponse, HTTP_SC_BadRequest, getString('wrong_parameters_count'));
    exit;
  end;

  mUser_ID := getHeaderValue(ARequest, 'UserID');
  mDocType := getHeaderValue(ARequest, 'DocumentType');
  mModule := getHeaderValue(ARequest, 'ModuleCode');

  dtHeader := TMemTable.Create(nil);
  dtRows := TMemTable.Create(nil);
  dtStoreBatches := TMemTable.Create(nil);
  mSL := TStringList.Create;
  try
    // hlavicka pozice
    LogWriteSectionStart('StorePositionInfo');

    mSql := getStorePositionInfoSql(Self.ObjectSpace, mStorePosition_ID);
    Self.ObjectSpace.SQLSelect2(mSql, dtHeader);

    // doplneni preferovane sarze
    if dtHeader.Active and not CFxOID.IsEmpty(mStoreCard_ID) then
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
      Self.ObjectSpace.SQLSelect2(mSql, dtStoreBatches);

      // pokud je na pozici prave jedna sarze s dispozici, vratime ji jako preferovanou pro predvyplneni
      if dtStoreBatches.Active and (dtStoreBatches.RecordCount = 1) then
      begin
        dtHeader.First;
        dtHeader.Edit;
        dtStoreBatches.First;
        dtHeader.FieldByName('PreferredStoreBatch_ID').AsString := dtStoreBatches.FieldByName('ID').AsString;
        dtHeader.FieldByName('PreferredStoreBatchName').AsString := dtStoreBatches.FieldByName('Name').AsString;
        dtHeader.Post;
      end;
    end;

    if dtHeader.Active and mExtendedInfo then
    begin
      // dispozice artiklu na pozici
      mSql :=
        'select' + nxCrLf +
        '  max(LSC.ID) as "ID",' + nxCrLf +
        '  max(LSC.Parent_ID) as "XX_Parent_ID",' + nxCrLf +
        '  max(SC.ID) as "StoreCard_ID", ' + nxCrLf +
        '  max(SC.' + cStoreCardInfoCodeField + ') as "StoreCardCode",' + nxCrLf +
        '  max(SC.' + cStoreCardInfoNameField + ') as "StoreCardName",' + nxCrLf;

      if AvailableInStockActivity_Position_ShowBatches(Self.ObjectSpace, mModule, mDocType, mUser_ID) then
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
        'where LSC.Parent_ID = ' + QuotedStr(mStorePosition_ID) + nxCrLf;

      if AvailableInStockActivity_Position_ShowBatches(Self.ObjectSpace, mModule, mDocType, mUser_ID) then
        mSql := mSql +
          'group by LSC.StoreCard_ID, LSC.StoreBatch_ID' + nxCrLf
      else
        mSql := mSql +
          'group by LSC.StoreCard_ID' + nxCrLf;

      mSql := mSql +
        'having sum(LSC.Quantity) <> 0 ' + nxCrLf;

      if AvailableInStockActivity_Position_ShowBatches(Self.ObjectSpace, mModule, mDocType, mUser_ID) then
        mSql := mSql +
          'order by max(SC.' + cStoreCardInfoCodeField + '), max(SB.Name)'
      else
        mSql := mSql +
          'order by max(SC.' + cStoreCardInfoCodeField + ')';

      Self.ObjectSpace.SQLSelect2(mSql, dtRows);
      if dtRows.Active then
      begin
        dtRows.AddIndex('id', REST_XX_Parent_ID+';StoreCardCode;StoreCard_ID;StoreBatchName;StoreBatch_ID', [ixUnique]);
        dtRows.IndexName:= 'id';
        mSL.AddObject('rows=', dtRows);
      end;
    end
    // pokud je aktivni okamzita kontrola dispozice, tak zkontroluju
    else if dtHeader.Active and StorePosition_CheckAvailableQuantityImmediately(Self.ObjectSpace, mModule, mDocType, mUser_ID, mStoreCard_ID, mStorePosition_ID) then
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

        mAvailableQuantity := SQLSelectFloat(Self.ObjectSpace, mSql);

        dtHeader.Edit;
        dtHeader.FieldByName('AvailableQuantity').AsFloat := mAvailableQuantity;
        dtHeader.Post;
      end;
    end;
    LogWriteSectionEnd;

    if dtHeader.Active then
    begin
      dtHeader.First;
      LogWriteSectionStart('JSON');
      json := REST_jsonCreate_FromDataSetRow(dtHeader, nil, mSL);
      LogWriteSectionEnd;

      HTTPResponse(AResponse, HTTP_SC_OK, ContentType_JSON, json.AsJson(false, true));
    end
    else begin
      ErrREST(ARequest, AResponse, HTTP_SC_NotFound, Format(getString('position_not_found'), [mStorePosition_ID]));
    end;
  finally
    dtHeader.Free;
    dtRows.Free;
    dtStoreBatches.Free;
    mSL.Free;
    if Assigned(json) then
      json.Free;
  end;
end;
///////////////////////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////////////////////
procedure get_AuxStorePositionInfo(Self: TNxWebServicesHelper; ARequest: TNxHTTPRequest;
  AResponse: TNxHTTPResponse; slPath: TStringList);
var
  mStore_ID: String;
  dtHeader: TMemTable;
  mSL: TStringList;
  mSql: String;
  json: TJSONSuperObject;
begin
  json := nil;
  if (slPath.Count = 2) then
  begin
    mStore_ID := slPath.Strings[1]; //ocekavam pozici
  end else
  begin
    ErrREST(ARequest, AResponse, HTTP_SC_BadRequest, getString('wrong_parameters_count'));
    exit;
  end;

  dtHeader := TMemTable.Create(nil);
  mSL := TStringList.Create;
  try
    // hlavicka pozice
    LogWriteSectionStart('AuxStorePositionInfo');

    mSql := 'select ' + FIRST_TOP(1) +
      '  LSP.ID as "ID", ' +  // kvuli navazani polozkoveho datasetu
      '  LSP.ID as "StorePosition_ID", ' +
      '  LSP.Code as "StorePositionCode", ' +
      '  LSP.Name as "StorePositionName", ' +
      '  LSP.PositionType as "StorePositionType", ' +
      '  S.ID as "Store_ID", ' +
      '  S.Code as "StoreCode", ' +
      '  S.IsLogistic as "StoreIsLogistic$BOOL", ' +
      '  cast('''' as varchar(40)) as "PreferredStoreBatch_ID", ' +
      '  cast('''' as varchar(40)) as "PreferredStoreBatchName" ' +
      'from LogStorePositions LSP ' +
      'join Stores S on S.ID = LSP.Store_ID ' +
      'where S.ID = ' + QuotedStr(mStore_ID) +
      '  and LSP.X_IsAux = ''A''' +
      FIRST_TOP_ORACLE(1);

    Self.ObjectSpace.SQLSelect2(mSql, dtHeader);
    if dtHeader.Active then
    begin
      dtHeader.First;
      LogWriteSectionStart('JSON');
      json := REST_jsonCreate_FromDataSetRow(dtHeader, nil, mSL);
      LogWriteSectionEnd;

      HTTPResponse(AResponse, HTTP_SC_OK, ContentType_JSON, json.AsJson(false, true));
    end
    else begin
      ErrREST(ARequest, AResponse, HTTP_SC_NotFound, Format(getString('aux_position_not_found'), [mStore_ID]));
    end;
  finally
    dtHeader.Free;
    mSL.Free;
    if Assigned(json) then
      json.Free;
  end;
end;
///////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////////////////////
///
/// Vrátí pozici, pokud je na DIPu.
///
//////////////////////////////////////////////////////////////////////////////////////////////
procedure get_StorePositionInfo2(Self: TNxWebServicesHelper; ARequest: TNxHTTPRequest;
  AResponse: TNxHTTPResponse; slPath: TStringList);
var
  mStorePosition_ID, sDip_ID: String;
  dtHeader: TMemTable;
  dtPos: TMemTable;
  mSL: TStringList;
  mSql: String;
  json: TJSONSuperObject;
begin
  json := nil;
  if (slPath.Count = 3) then
  begin
    mStorePosition_ID := slPath.Strings[1]; //ocekavam pozici
    sDip_ID := slPath.Strings[2];
  end else
  begin
    ErrREST(ARequest, AResponse, HTTP_SC_BadRequest, getString('wrong_parameters_count'));
    exit;
  end;

  dtHeader := TMemTable.Create(nil);
  mSL := TStringList.Create;
  try
    // hlavicka pozice
    LogWriteSectionStart('StorePositionInfo2');
    mSql := 'select ' +
      '  LSP.ID as "ID", ' +  // kvuli navazani polozkoveho datasetu
      '  LSP.ID as "StorePosition_ID", ' +
      '  LSP.Code as "StorePositionCode", ' +
      '  LSP.Name as "StorePositionName", ' +
      '  LSP.PositionType as "StorePositionType", ' +
      '  S.ID as "Store_ID", ' +
      '  S.Code as "StoreCode", ' +
      '  S.IsLogistic as "StoreIsLogistic$BOOL" ' +
      'from LogStorePositions LSP ' +
      'join Stores S on S.ID = LSP.Store_ID ' +
      'join MainInvProtocolPositions MIPP on MIPP.StorePosition_ID = LSP.id ' +
      'join PartialInvProtocolPositions PIPP on PIPP.MIPPosition_ID = MIPP.id ' +
      'where ' +
      '  LSP.ID = ' + QuotedStr(mStorePosition_ID) +
      '  and PIPP.Parent_ID = ' + QuotedStr(sDip_ID);
    Self.ObjectSpace.SQLSelect2(mSql, dtHeader);

    LogWriteSectionEnd;

    if dtHeader.Active then
    begin
      dtHeader.First;
      LogWriteSectionStart('JSON');
      json := REST_jsonCreate_FromDataSetRow(dtHeader, nil, mSL);
      LogWriteSectionEnd;

      HTTPResponse(AResponse, HTTP_SC_OK, ContentType_JSON, json.AsJson(false, true));
    end
    else begin
      ErrREST(ARequest, AResponse, HTTP_SC_NotFound, Format(getString('position_not_found_or_entered'), [mStorePosition_ID]));
    end;
  finally
    dtHeader.Free;
    mSL.Free;
    if Assigned(json) then
      json.Free;
  end;
end;

///////////////////////////////////////////////////////////////////////////////
procedure listStorePositions(Self: TNxWebServicesHelper; ARequest: TNxHTTPRequest;
  AResponse: TNxHTTPResponse; slPath: TStringList);
var
  mSearchStr, mStore_ID, mStoreCard_ID, mStoreBatch_ID, mUser_Id, mModule, mDocType,
    mQuantityString, mQuantityReservedString: String;
  dtRows: TMemTable;
  mSql, mSqlAvailable: String;
  json: TJSONSuperObject;
  mOnlyAvailable, mInPositionFirst: Boolean;
begin
  json := nil;
  mSearchStr := '';
  if ((slPath.Count >= 6) and (slPath.Count <= 7)) then
  begin
    mStore_ID := slPath.Strings[1];
    mStoreCard_ID := slPath.Strings[2];
    mStoreBatch_ID := slPath.Strings[3];
    mOnlyAvailable := slPath.Strings[4] = 'true';
    mInPositionFirst := slPath.Strings[5] = 'true';
    if slPath.Count = 7 then
      mSearchStr := CFxInternet.URLDecode(ReplaceStr(slPath.Strings[6], '+', ' '));
  end else
  begin
    ErrREST(ARequest, AResponse, HTTP_SC_BadRequest, getString('wrong_parameters_count'));
    exit;
  end;

  mUser_Id := getHeaderValue(ARequest, 'UserID');
  mModule := getHeaderValue(ARequest,'ModuleCode');
  mDocType := getHeaderValue(ARequest, 'DocumentType');

  dtRows := TMemTable.Create(nil);
  try
    LogWriteSectionStart('listStorePositions');

    if listStorePositions_IncludeReservedQuantity(Self.ObjectSpace, mModule, mDocType, mUser_ID) then
      mQuantityString := 'LSC.Quantity / SU.UnitRate'
    else
      mQuantityString := '(LSC.Quantity - LSC.QuantityReserved) / SU.UnitRate';

    mQuantityReservedString := 'LSC.QuantityReserved / SU.UnitRate';

    // pokud se zobrazuje vse (mOnlyAvailable = false), tak jde o prijem a chci v dispozici videt jen soucet za vybrany artikl
    // jinak jde nejspis o vydej a tam to chci omezene za vsechny vybrane udaje (napr. sarzi)
    if not mOnlyAvailable then
    begin
      mQuantityString := 'case when LSC.StoreCard_ID = ' + QuotedStr(mStoreCard_ID) + ' then ' + mQuantityString + ' end';
      mQuantityReservedString := 'case when LSC.StoreCard_ID = ' + QuotedStr(mStoreCard_ID) + ' then ' + mQuantityReservedString + ' end';
    end;

    mSql :=
      'select' + FIRST_TOP(100) + nxCrLf +
      '  LSP.ID as "ID",' + nxCrLf +
      '  LSP.Code as "Code",' + nxCrLf +
      '  ' + listStorePositions_SelectName(Self.ObjectSpace) + ' as "Name",' + nxCrLf +
      '  coalesce(sum(' + mQuantityString + '), 0) as "Available",' + nxCrLf +
      '  coalesce(sum(' + mQuantityReservedString + '), 0) as "Reserved"' + nxCrLf +
      'from LogStorePositions LSP' + nxCrLf +
      'left join LogStoreContents LSC on LSC.Parent_ID = LSP.ID';

    // k joinu automaticky pripojim podminky na pripadny artikl nebo sarzi
    if mOnlyAvailable then
    begin
      if not CFxOID.IsEmpty(mStoreCard_ID) then
        mSql := mSql + ' and LSC.StoreCard_ID = ' + QuotedStr(mStoreCard_ID);

      if not CFxOID.IsEmpty(mStoreBatch_ID) then
        mSql := mSql + ' and LSC.StoreBatch_ID = ' + QuotedStr(mStoreBatch_ID);
    end;

    mSql := mSql + nxCrLf +
      'left join StoreCards SC on SC.ID = LSC.StoreCard_ID' + nxCrLf +
      'left join StoreUnits SU on SU.Parent_ID = SC.ID and SU.Code = SC.MainUnitCode' + nxCrLf;

    mSql := mSql + nxCrLf +
      listStorePositions_Join(Self.ObjectSpace) + nxCrLf +
      'where' + nxCrLf +
      '  LSP.Hidden = ''N''' + nxCrLf;

    // pokud prislo XXXXXXXXXX tak zobrazim pozice ze vsech skladu
    if mStore_ID <> 'XXXXXXXXXX' then
      mSql := mSql + '  and LSP.Store_ID = ' + QuotedStr(mStore_ID) + nxCrLf;

    mSql := mSql + listStorePositions_Search(Self.ObjectSpace, mModule, mDocType, mUser_Id, mStore_ID,
      mStoreCard_ID, mStoreBatch_ID) + nxCrLf;

    // pripadne hledani
    if trim(mSearchStr) <> '' then
    begin
      // muze se stat, ze nekdo do hledaciho okynka naskenuje carovy kod pozice ve tvaru SPXXXXXXXXXX
      if (length(mSearchStr) = 12) and (copy(mSearchStr, 1, 2) = 'SP') then
        mSearchStr := copy(mSearchStr, 3, 10);
      mSql := mSql +
        '  and (LSP.Code' + COLLATION_AI + 'like ''%' + mSearchStr + '%''' + nxCrLf +
        '    or LSP.Name' + COLLATION_AI + 'like ''%' + mSearchStr + '%''' + nxCrLf +
        '    or LSP.ID = ' + QuotedStr(mSearchStr) + ')' + nxCrLf;
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
    Self.ObjectSpace.SQLSelect2(mSql, dtRows);
    LogWriteSectionEnd;

    LogWriteSectionStart('JSON');
    if dtRows.Active then
    begin
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
///////////////////////////////////////////////////////////////////////////////

begin
end.