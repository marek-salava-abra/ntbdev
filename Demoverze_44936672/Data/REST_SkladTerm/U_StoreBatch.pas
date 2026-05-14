uses
  'REST_SkladTerm.U_Func',
  'REST_SkladTerm.U_SQLQueries',
  'REST_SkladTerm.U_FuncJSON',
  'REST_SkladTerm_Special.U_StandardHooks';

///////////////////////////////////////////////////////////////////////////////
procedure get_StoreBatchInfo(Self: TNxWebServicesHelper; ARequest: TNxHTTPRequest;
  AResponse: TNxHTTPResponse; slPath: TStringList);
var
  mStoreBatch_ID, mStoreCard_ID, mUser_Id, mModule, mDocType: String;
  mWithStoreCardInfo, mExtendedInfo: Boolean;
  dtHeader, dtRows, dtStoreRows: TMemTable;
  mSL: TStringList;
  mSql, mSqlCondition: String;
  json: TJSONSuperObject;
begin
  json := nil;
  if (slPath.Count >= 3) and (slPath.Count <= 5) then
  begin
    // bud prijde jen prvni parametr a pak je to ID sarze
    mStoreBatch_ID := slPath.Strings[1]; //ocekavam sarzi
    mWithStoreCardInfo := StrToBool(slPath.Strings[2]);
    // nebo prijde i druhy parametr nenulovy (StoreCard_ID) a v te chvili bereme prvni parametr za nazev sarze/serioveho cisla
    mStoreCard_ID := '';
    if slPath.Count = 4 then
      mStoreCard_ID := slPath.Strings[3];
    if slPath.Count = 5 then
      mExtendedInfo := StrToBool(slPath.Strings[4]);
  end else
  begin
    ErrREST(ARequest, AResponse, HTTP_SC_BadRequest, getString('wrong_parameters_count'));
    exit;
  end;

  mUser_Id := getHeaderValue(ARequest, 'UserID');
  mModule := getHeaderValue(ARequest, 'ModuleCode');
  mDocType := getHeaderValue(ARequest, 'DocumentType');

  dtHeader := TMemTable.Create(nil);
  mSL := TStringList.Create;
  try
    // hlavicka skladu
    LogWriteSectionStart('StoreBatchInfo');

    mSql := getStoreBatchInfoSql(Self.ObjectSpace, mModule, mDocType, mUser_ID, mStoreBatch_ID, mStoreCard_ID);

    // vlastni ziskani sarze
    mSql := get_StoreBatchInfo_customSql(mSql, mStoreCard_ID, mStoreBatch_ID);
    Self.ObjectSpace.SQLSelect2(mSql, dtHeader);

    if dtHeader.Active then
    begin
      dtRows := TMemTable.Create(nil);
      dtStoreRows := TMemTable.Create(nil);
      try
      // informace o artiklu
        if mWithStoreCardInfo then
        begin
          dtHeader.First;
          mSql := getStoreCardInfoSql(Self.ObjectSpace, mModule, mDocType, mUser_Id, dtHeader.FieldByName('StoreCard_ID').AsString, '', '', '', mStoreBatch_ID);
          Self.ObjectSpace.SQLSelect2(mSql, dtRows);
          if dtRows.Active then
          begin
            dtRows.AddIndex('id', REST_XX_Parent_ID, [ixUnique]);
            dtRows.IndexName := 'id';
            mSL.AddObject('rows=', dtRows);
          end;
        end;

        // informace o dostupnosti na sklade
        if mExtendedInfo then
        begin
          // dispozice po skladech
          mSql :=
            'select' + nxCrLf +
            '  SSB.StoreBatch_ID as "XX_Parent_ID",' + nxCrLf +
            '	 S.ID as "Store_ID",' + nxCrLf +
            '	 S.Code as "StoreCode",' + nxCrLf +
            '  (SSB.Quantity - SSB.BookedQuantity) / SU.UnitRate as "Available",' + nxCrLf +
            '  (SSB.BookedQuantity / SU.UnitRate) as "CustomValue"' + nxCrLf +
            'from StoreSubBatches SSB' + nxCrLf +
            'join Stores S on S.ID = SSB.Store_ID' + nxCrLf +
            'join StoreBatches SB on SB.ID = SSB.StoreBatch_ID' + nxCrLf +
            'join StoreCards SC on SC.ID = SB.StoreCard_ID' + nxCrLf +
            'join StoreUnits SU on SU.Parent_ID = SC.ID and SU.Code = SC.MainUnitCode' + nxCrLf +
            'where' + nxCrLf +
            '  SSB.StoreBatch_ID = ' + QuotedStr(mStoreBatch_ID) + nxCrLf +
            '  and SSB.Quantity <> 0' + nxCrLf +
            'order by' + nxCrLf +
            '  S.Code' + nxCrLf;
          Self.ObjectSpace.SQLSelect2(mSql, dtStoreRows);
          if dtStoreRows.Active then
          begin
            dtStoreRows.AddIndex('id', REST_XX_Parent_ID+';StoreCode', [ixUnique]);
            dtStoreRows.IndexName:= 'id';
            mSL.AddObject('storeRows=', dtStoreRows);
          end;
        end;
        LogWriteSectionEnd;

        dtHeader.First;
        LogWriteSectionStart('JSON');
        json := REST_jsonCreate_FromDataSetRow(dtHeader, nil, mSL);
        LogWriteSectionEnd;
      finally
        dtRows.Free;
        dtStoreRows.Free;
      end;

      HTTPResponse(AResponse, HTTP_SC_OK, ContentType_JSON, json.AsJson(false, true));
    end
    else begin
      ErrREST(ARequest, AResponse, HTTP_SC_NotFound, Format(getString('storebatch_not_found'), [mStoreBatch_ID]));
    end;
  finally
    dtHeader.Free;
    mSL.Free;
    if Assigned(json) then
      json.Free;
  end;
end;
///////////////////////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////////////////////
procedure listStoreBatches(Self: TNxWebServicesHelper; ARequest: TNxHTTPRequest;
  AResponse: TNxHTTPResponse; slPath: TStringList);
var
  mSearchStr, mStore_ID, mStorePosition_ID, mStoreCard_ID, mSqlAvailable, mUser_Id, mModule, mDocType: String;
  mOnlyAvailable: Boolean;
  dtRows: TMemTable;
  mSql: String;
  json: TJSONSuperObject;
begin
  json := nil;
  mSearchStr := '';
  if ((slPath.Count >= 5) and (slPath.Count <=6)) then
  begin
    mStoreCard_ID := slPath.Strings[1];
    mStore_ID := slPath.Strings[2];
    mStorePosition_ID := slPath.Strings[3];
    mOnlyAvailable := slPath.Strings[4] = 'true';
    if slPath.Count = 6 then
      mSearchStr := CFxInternet.URLDecode(ReplaceStr(slPath.Strings[5], '+', ' '));
  end else
  begin
    ErrREST(ARequest, AResponse, HTTP_SC_BadRequest, getString('wrong_parameters_count'));
    exit;
  end;

  mUser_Id := getHeaderValue(ARequest, 'UserID');
  mModule := getHeaderValue(ARequest, 'ModuleCode');
  mDocType := getHeaderValue(ARequest, 'DocumentType');

  if not CFxOID.IsEmpty(mStorePosition_ID) then
    mSqlAvailable :=
      '  (select sum((LSC.Quantity - LSC.QuantityReserved) / SU.UnitRate)' + nxCrLf +
      '    from LogStoreContents LSC' + nxCrLf +
      '    join StoreCards SC on SC.ID = LSC.StoreCard_ID' + nxCrLf +
      '    join StoreUnits SU on SU.Parent_ID = SC.ID and SU.Code = SC.MainUnitCode' + nxCrLf +
      '    where' + nxCrLf +
      '      LSC.StoreCard_ID = ' + QuotedStr(mStoreCard_ID) + nxCrLf +
      '      and LSC.StoreBatch_ID = SB.ID and LSC.Parent_ID = ' + QuotedStr(mStorePosition_ID) + ')'
  else
    mSqlAvailable := '0.0';

  dtRows := TMemTable.Create(nil);
  try
    LogWriteSectionStart('ListStoreBatches');

    mSql :=
      'select ' + FIRST_TOP(100) + nxCrLf +
      '  SB.ID as "ID", ' + nxCrLf +
      '  SB.Name as "Code", ' + nxCrLf +
      '  ' + listStoreBatches_SpecificationField(Self.ObjectSpace, mModule, mDocType, mUser_Id) + ' as "Name",' + nxCrLf +
      '  ' + mSqlAvailable + ' as "Available"' + nxCrLf +
      'from StoreBatches SB' + nxCrLf +
      listStoreBatches_Join(Self.ObjectSpace, mModule, mDocType, mUser_Id) + nxCrLf +
      'where' + nxCrLf +
      '  SB.Hidden = ''N'' and SB.StoreCard_ID = ' + QuotedStr(mStoreCard_ID) + nxCrLf;

    // kontrola na dispozici na sklade a pripadne pozici
    if mOnlyAvailable then
    begin
      if not CFxOID.IsEmpty(mStore_ID) then
        mSql := mSql +
          '  and (select sum(SSB.Quantity - SSB.BookedQuantity) from StoreSubBatches SSB '  + nxCrLf +
          '    where SSB.StoreBatch_ID = SB.ID and SSB.Store_ID = ' + QuotedStr(mStore_ID) + ') > 0 ' + nxCrLf;

      if not CFxOID.IsEmpty(mStorePosition_ID) then
        mSql := mSql +
          '  and ' + mSqlAvailable + ' > 0' + nxCrLf;
    end;

    // pripadne hledani
    if trim(mSearchStr) <> '' then
      mSql := mSql + '  and (SB.Name' + COLLATION_AI + 'like ''%' + mSearchStr + '%'')' + nxCrLf;

    mSql := mSql +
      ' order by SB.Name' + nxCrLf +
      FIRST_TOP_ORACLE(100);
    Self.ObjectSpace.SQLSelect2(mSql, dtRows);

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
    LogWriteSectionEnd;
    dtRows.Free;
    if Assigned(json) then
      json.Free;
  end;
end;
///////////////////////////////////////////////////////////////////////////////

procedure put_FormatExpirationDate(Self: TNxWebServicesHelper; ARequest: TNxHTTPRequest;
  AResponse: TNxHTTPResponse; slPath: TStringList);
var
  mUser_ID, mModule, mDocType, mText, mDateString: String;
  mDate: TDateTime;
  mSql: String;
  json: TJSONSuperObject;
begin
  json := nil;
  if slPath.Count <> 1 then
  begin
    ErrREST(ARequest, AResponse, HTTP_SC_BadRequest, getString('wrong_parameters_count'));
    exit;
  end;

  mUser_ID := getHeaderValue(ARequest, 'UserID');
  mModule := getHeaderValue(ARequest, 'ModuleCode');
  mDocType := getHeaderValue(ARequest, 'DocumentType');

  try
    json := TJSONSuperObject.ParseString(REST_ByteUTF82String(ARequest.Content.Content), True);
    try
      mText := json.S['message'];
      mDate := nil;
      mDate := FormatExpirationDate(Self.ObjectSpace, mModule, mDocType, mUser_ID, mText);

      if Assigned(mDate) then
        mDateString := REST_json_DateTime(mDate)
      else
        RaiseException(getString('expiration_date_not_parsed'));

      HTTPResponse(AResponse, HTTP_SC_OK, ContentType_JSON, PlainResponse(mDateString));
    finally
      json.Free;
    end;
  except
    ErrREST(ARequest, AResponse, HTTP_SC_ExpectationFailed, ExceptionMessage);
  end;
end;

begin
end.