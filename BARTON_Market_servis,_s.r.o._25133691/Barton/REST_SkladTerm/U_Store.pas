uses
  'REST_SkladTerm.U_Func',
  'REST_SkladTerm.U_FuncJSON',
  'REST_SkladTerm.U_SQLQueries',
  'REST_SkladTerm_Special.U_StandardHooks';

procedure get_StoreInfo(AOS: TNxCustomObjectSpace; APath, AResponse: TStringList);
var
  mStore_ID: String;
  dtHeader: TMemTable;
  dtRows: TMemTable;
  mSL: TStringList;
  mSql: String;
  json: TJSONSuperObject;
begin
  json := nil;
  if APath.Count = 2 then
  begin
    mStore_ID := APath.Strings[1];
  end else
  begin
    SetPlainResponse(AResponse, getString('wrong_parameters_count'), HTTP_SC_BadRequest);
    exit;
  end;

  dtHeader := TMemTable.Create(nil);
  dtRows := TMemTable.Create(nil);
  mSL := TStringList.Create;
  try
    // hlavicka skladu
    LogWriteSectionStart('StoreInfo');
    mSql := getStoreInfoSql(AOS, gSkladTermModule, gSkladTermDocType, gSkladTermUser_ID, mStore_ID);
    AOS.SQLSelect2(mSql, dtHeader);
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
      SetPlainResponse(AResponse, Format(getString('store_not_found'), [mStore_ID]), HTTP_SC_NotFound);
  finally
    dtHeader.Free;
    dtRows.Free;
    mSL.Free;
    if Assigned(json) then
      json.Free;
  end;
end;

function listStores(AOS: TNxCustomObjectSpace; ASearch: String; AOnlyLogistic: Boolean): String;
var
  mSql: String;
  mSL: TStringList;
begin
  LogWriteSectionStart('listStores');
  mSL := TStringList.Create;
  try
    mSL.Delimiter := ',';

    mSql :=
      'select' + FIRST_TOP(100) + NxCrLf +
      '  S.ID as "ID",' + NxCrLf +
      '  S.Code as "Code",' + NxCrLf +
      '  S.Name as "Name"' + NxCrLf +
      'from Stores S' + NxCrLf +
      'where' +  NxCrLf +
      '  S.Hidden = ''N''' + NxCrLf;

    if AOnlyLogistic then
      mSql := mSql +
        '  and S.IsLogistic = ''A''' + NxCrLf;

    if trim(ASearch) <> '' then
      mSql := mSql + 'and (S.Code' + COLLATION_AI + 'like ''%' + ASearch + '%'' ' +
        '  or S.Name' + COLLATION_AI + 'like ''%' + ASearch + '%'')' + nxCrLf;
    if filterStoresForUser(AOS, gSkladTermModule, gSkladTermDocType, gSkladTermUser_ID, mSL) then
      mSql := mSql + '  and S.ID in (''' + ReplaceText(mSL.DelimitedText, ',', ''', ''') + ''')' + nxCrLf;
    mSql := mSql +
      ' order by S.Code ' + nxCrLf +
      FIRST_TOP_ORACLE(100);

    Result := mSql;
  finally
    mSL.Free;
    LogWriteSectionEnd;
  end;
end;

begin
end.