uses
  'REST_SkladTerm.U_Func',
  'REST_SkladTerm.U_FuncJSON',
  'REST_SkladTerm.U_SQLQueries',
  'REST_SkladTerm_Special.U_StandardHooks';

///////////////////////////////////////////////////////////////////////////////
procedure get_StoreInfo(Self: TNxWebServicesHelper; ARequest: TNxHTTPRequest;
  AResponse: TNxHTTPResponse; slPath: TStringList);
var
  mStore_ID, mModule, mUser_ID, mDocumentType: String;
  dtHeader: TMemTable;
  dtRows: TMemTable;
  mSL: TStringList;
  mSql: String;
  json: TJSONSuperObject;
begin
  json := nil;
  if slPath.Count = 2 then
  begin
    mStore_ID := slPath.Strings[1];
  end else
  begin
    ErrREST(ARequest, AResponse, HTTP_SC_BadRequest, getString('wrong_parameters_count'));
    exit;
  end;

  mModule := getHeaderValue(ARequest, 'ModuleCode');
  mUser_ID := getHeaderValue(ARequest, 'UserID');
  mDocumentType := getHeaderValue(ARequest, 'DocumentType');

  dtHeader := TMemTable.Create(nil);
  dtRows := TMemTable.Create(nil);
  mSL := TStringList.Create;
  try
    // hlavicka skladu
    LogWriteSectionStart('StoreInfo');
    mSql := getStoreInfoSql(Self.ObjectSpace, mModule, mDocumentType, mUser_ID, mStore_ID);
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
      ErrREST(ARequest, AResponse, HTTP_SC_NotFound, Format(getString('store_not_found'), [mStore_ID]));
    end;
  finally
    dtHeader.Free;
    dtRows.Free;
    mSL.Free;
    if Assigned(json) then
      json.Free;
  end;
end;
///////////////////////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////////////////////
procedure listStores(Self: TNxWebServicesHelper; ARequest: TNxHTTPRequest;
  AResponse: TNxHTTPResponse; slPath: TStringList);
var
  mSearchStr, mUser_Id, mModule, mDocType: String;
  dtRows: TMemTable;
  mSql: String;
  json: TJSONSuperObject;
  mSL: TStringList;
begin
  mSearchStr := '';
  json := nil;
  if ((slPath.Count = 1) or (slPath.Count = 2)) then
  begin
    if slPath.Count = 2 then
      mSearchStr := CFxInternet.URLDecode(ReplaceStr(slPath.Strings[1], '+', ' '));
  end else
  begin
    ErrREST(ARequest, AResponse, HTTP_SC_BadRequest, getString('wrong_parameters_count'));
    exit;
  end;

  mUser_Id := getHeaderValue(ARequest, 'UserID');
  mModule := getHeaderValue(ARequest, 'ModuleCode');
  mDocType := getHeaderValue(ARequest, 'DocumentType');

  mSL := TStringList.Create;
  dtRows := TMemTable.Create(nil);
  try
    LogWriteSectionStart('ListStores');
    mSL.Delimiter := ',';

    mSql :=
      'select' + FIRST_TOP(100) + NxCrLf +
      '  S.ID as "ID",' + NxCrLf +
      '  S.Code as "Code",' + NxCrLf +
      '  S.Name as "Name"' + NxCrLf +
      'from Stores S' + NxCrLf +
      'where' +  NxCrLf +
      '  S.Hidden = ''N''' + NxCrLf;
    if trim(mSearchStr) <> '' then
      mSql := mSql + 'and (S.Code' + COLLATION_AI + 'like ''%' + mSearchStr + '%'' ' +
        '  or S.Name' + COLLATION_AI + 'like ''%' + mSearchStr + '%'')' + nxCrLf;
    if filterStoresForUser(Self.ObjectSpace, mModule, mDocType, mUser_Id, mSL) then
      mSql := mSql + '  and S.ID in (''' + ReplaceText(mSL.DelimitedText, ',', ''', ''') + ''')' + nxCrLf;
    mSql := mSql +
      ' order by S.Code ' + nxCrLf +
      FIRST_TOP_ORACLE(100);
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
    mSL.Free;
  end;
end;
///////////////////////////////////////////////////////////////////////////////

begin
end.