uses
  'REST_SkladTerm.U_Func',
  'REST_SkladTerm.U_SQLQueries',
  'REST_SkladTerm.U_FuncJSON',
  'REST_SkladTerm_Special.U_StandardHooks';

procedure get_StoreBatchInfo(AOS: TNxCustomObjectSpace; APath, AResponse: TStringList);
var
  mStoreBatch_ID, mStoreCard_ID: String;
  mWithStoreCardInfo, mExtendedInfo: Boolean;
  dtHeader, dtRows, dtStoreRows: TMemTable;
  mSL, mStoreCardsId: TStringList;
  mSql, mSqlCondition: String;
  json: TJSONSuperObject;
begin
  json := nil;
  if (APath.Count >= 3) and (APath.Count <= 5) then
  begin
    // bud prijde jen prvni parametr a pak je to ID sarze
    mStoreBatch_ID := APath.Strings[1];
    mWithStoreCardInfo := StrToBool(APath.Strings[2]);
    // nebo prijde i druhy parametr nenulovy (StoreCard_ID) a v te chvili bereme prvni parametr za nazev sarze/serioveho cisla
    mStoreCard_ID := '';
    if APath.Count = 4 then
      mStoreCard_ID := APath.Strings[3];
    if APath.Count = 5 then
      mExtendedInfo := StrToBool(APath.Strings[4]);
  end else
  begin
    SetPlainResponse(AResponse, getString('wrong_parameters_count'), HTTP_SC_BadRequest);
    exit;
  end;

  dtHeader := TMemTable.Create(nil);
  mSL := TStringList.Create;
  try
    // hlavicka skladu
    LogWriteSectionStart('StoreBatchInfo');

    mSql := getStoreBatchInfoSql(AOS, gSkladTermModule, gSkladTermDocType, gSkladTermUser_ID, mStoreBatch_ID, mStoreCard_ID);

    // vlastni ziskani sarze
    mSql := get_StoreBatchInfo_customSql(mSql, mStoreCard_ID, mStoreBatch_ID);
    AOS.SQLSelect2(mSql, dtHeader);

    if dtHeader.Active then
    begin
      dtRows := TMemTable.Create(nil);
      dtStoreRows := TMemTable.Create(nil);
      mStoreCardsId := TStringList.Create;
      try
      // informace o artiklu
        if mWithStoreCardInfo then
        begin
          dtHeader.First;
          mStoreCardsId.Add(dtHeader.FieldByName('StoreCard_ID').AsString);
          mSql := getStoreCardInfoSql(AOS, gSkladTermModule, gSkladTermDocType, gSkladTermUser_ID, mStoreCardsId, '', '', mStoreBatch_ID);
          AOS.SQLSelect2(mSql, dtRows);
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
            '  cast((SSB.BookedQuantity / SU.UnitRate) as varchar(30)) as "CustomValue"' + nxCrLf +
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
          AOS.SQLSelect2(mSql, dtStoreRows);
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
        mStoreCardsId.Free;
      end;

     SetResponse(AResponse, json.AsJson(false, true));
    end
    else begin
      SetPlainResponse(AResponse, Format(getString('storebatch_not_found'), [mStoreBatch_ID]), HTTP_SC_NotFound);
    end;
  finally
    dtHeader.Free;
    mSL.Free;
    if Assigned(json) then
      json.Free;
  end;
end;

function get_ListStoreBatches(AOS: TNxCustomObjectSpace; ASearch, AStoreCard_ID, AStore_ID, AStorePosition_ID: String;
  AOnlyAvailable: Boolean): String;
var
  mSqlAvailable, mSelect, mFrom, mWhere, mJoin, mOrderBy: String;
  mSql: String;
  mParameters: TStringList;
begin
  LogWriteSectionStart('get_ListStoreBatches');
  mParameters := TStringList.Create;
  try
    mSelect := '';
    mFrom := '';
    mWhere := '';
    mJoin := '';
    mOrderBy := '';

    if not CFxOID.IsEmpty(AStorePosition_ID) then
      mSqlAvailable :=
        '  (select sum((LSC.Quantity - LSC.QuantityReserved) / SU.UnitRate)' + nxCrLf +
        '    from LogStoreContents LSC' + nxCrLf +
        '    join StoreCards SC on SC.ID = LSC.StoreCard_ID' + nxCrLf +
        '    join StoreUnits SU on SU.Parent_ID = SC.ID and SU.Code = SC.MainUnitCode' + nxCrLf +
        '    where' + nxCrLf +
        '      LSC.StoreCard_ID = ' + QuotedStr(AStoreCard_ID) + nxCrLf +
        '      and LSC.StoreBatch_ID = SB.ID and LSC.Parent_ID = ' + QuotedStr(AStorePosition_ID) + ')'
    else
    begin
      mSqlAvailable :=
      '  (select sum((SSB.Quantity - SSB.BookedQuantity) / SU.UnitRate) from StoreSubBatches SSB '  + nxCrLf +
        '    join StoreCards SC on SC.ID = SSB.StoreCard_ID' + nxCrLf +
        '    join StoreUnits SU on SU.Parent_ID = SC.ID and SU.Code = SC.MainUnitCode' + nxCrLf +
        '    where SSB.StoreBatch_ID = SB.ID';

      if not CFxOID.IsEmpty(AStore_ID) then
        mSqlAvailable := mSqlAvailable +
          ' and SSB.Store_ID = ' + QuotedStr(AStore_ID) + ')' + nxCrLf
      else
        mSqlAvailable := mSqlAvailable +
          ')' + nxCrLf;
    end;


    mSelect :=
      '  SB.ID as "ID", ' + nxCrLf +
      '  SB.Name as "Code", ' + nxCrLf +
      '  ' + listStoreBatches_SpecificationField(AOS, gSkladTermModule, gSkladTermDocType, gSkladTermUser_ID) + ' as "Name",' + nxCrLf +
      '  ' + mSqlAvailable + ' as "Available"' + nxCrLf;

    mFrom :=
      'StoreBatches SB';

    mWhere :=
      '  SB.Hidden = ''N''' + nxCrLf +
      '  and SB.StoreCard_ID = ' + QuotedStr(AStoreCard_ID);

    // kontrola na dispozici na sklade a pripadne pozici
    if AOnlyAvailable then
    begin
        mWhere := mWhere + nxCrLf +
          '  and ' + mSqlAvailable + ' > 0';
    end;

    // pripadne hledani
    if Trim(ASearch) <> '' then
      mWhere := mWhere + nxCrLf
        + '  and (SB.Name' + COLLATION_AI + 'like ''%' + ASearch + '%'')' + nxCrLf;

    mOrderBy :=
      '  SB.Name';

    mParameters.Values('storeCard_id') := AStoreCard_ID;
    mParameters.Values('storePosition_id') := AStorePosition_ID;
    mParameters.Values('store_id') := AStore_ID;
    mParameters.Values('onlyAvailable') := BoolToStr(AOnlyAvailable);

    mParameters.Values('select') := mSelect;
    mParameters.Values('from') := mFrom;
    mParameters.Values('join') := mJoin;
    mParameters.Values('where') := mWhere;
    mParameters.Values('orderby') := mOrderBy;

    FilterList(AOS, gSkladTermModule, gSkladTermDocType, gSkladTermUser_ID, 'get_ListStoreBatches', mParameters);

    mSql :=
      'select' + FIRST_TOP(100) + nxCrLf +
      mParameters.Values('select') + nxCrLf +
      'from ' +
      mParameters.Values('from') + nxCrLf;

    if mParameters.Values('join') <> '' then
      mParameters.Values('join');

    if mParameters.Values('where') <> '' then
      mSql := mSql + nxCrLf +
        'where' + nxCrLf +
        mParameters.Values('where');

    if mParameters.Values('orderby') <> '' then
      mSql := mSql + nxCrLf +
        'order by' + nxCrLf +
        mParameters.Values('orderby');

    mSql := mSql + nxCrLf +
      FIRST_TOP_ORACLE(100);

    Result := mSql;
  finally
    LogWriteSectionEnd;
  end;
end;

procedure put_FormatExpirationDate(AOS: TNxCustomObjectSpace; APath: TStringList; ABody: String; AResponse: TStringList);
var
  mText, mDateString: String;
  mDate: TDateTime;
  mSql: String;
  json: TJSONSuperObject;
begin
  json := nil;
  if APath.Count <> 1 then
  begin
    SetPlainResponse(AResponse, getString('wrong_parameters_count'), HTTP_SC_BadRequest);
    exit;
  end;

  try
    json := TJSONSuperObject.ParseString(ABody, True);
    try
      mText := json.S['message'];
      mDate := nil;
      mDate := FormatExpirationDate(AOS, gSkladTermModule, gSkladTermDocType, gSkladTermUser_ID, mText);

      if Assigned(mDate) then
        mDateString := REST_json_DateTime(mDate)
      else
        RaiseException(getString('expiration_date_not_parsed'));

      SetResponse(AResponse, PlainResponse(mDateString));
    finally
      json.Free;
    end;
  except
    SetPlainResponse(AResponse, ExceptionMessage, HTTP_SC_ExpectationFailed);
  end;
end;

begin
end.