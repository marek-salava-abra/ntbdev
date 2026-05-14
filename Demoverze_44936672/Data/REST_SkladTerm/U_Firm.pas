uses
  'REST_SkladTerm.U_Func',
  'REST_SkladTerm.U_FuncJSON',
  'REST_SkladTerm.U_Translation',
  'REST_SkladTerm_Special.U_StandardHooks';

///////////////////////////////////////////////////////////////////////////////
// pro volani z funkci
procedure FirmInfo(AOS: TNxCustomObjectSpace; AResult: TMemTable; AModule, ADocType, AUser_ID, ABarcode: String);
var
  mSql: String;
begin
  // hlavicka firmy
  LogWriteSectionStart('FirmInfo');
  mSql :=
    'select' + nxCrLf +
    '  F.ID as "ID",' + nxCrLf +
    '  F.Code as "Code",' + nxCrLf +
    '  ' + get_FirmInfo_NameField(AOS, AModule, ADocType, AUser_ID) + ' as "Name"' + nxCrLf +
    'from Firms F' + nxCrLf +
    'where' + nxCrLf +
    '  F.ID = ' + QuotedStr(ABarcode);

  AOS.SQLSelect2(mSql, AResult);
  LogWriteSectionEnd;
end;
///////////////////////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////////////////////
procedure get_FirmInfo(Self: TNxWebServicesHelper; ARequest: TNxHTTPRequest;
  AResponse: TNxHTTPResponse; slPath: TStringList);
var
  mFirm_ID, mUser_Id, mModule, mDocType, mSql, mAuxFieldsSelect: String;
  dtHeader, mAuxFieldsDataset: TMemTable;
  json, jsonAuxFields: TJSONSuperObject;
begin
  LogWriteSectionStart('get_FirmInfo');
  try
    json := nil;
    jsonAuxFields := nil;
    if (slPath.Count = 2) then
    begin
      mFirm_ID := slPath.Strings[1]; //ocekavam firmu
    end else
    begin
      ErrREST(ARequest, AResponse, HTTP_SC_BadRequest, getString('error_wrong_parameters_count'));
      exit;
    end;

    mUser_Id := getHeaderValue(ARequest, 'UserID');
    mModule := getHeaderValue(ARequest,'ModuleCode');
    mDocType := getHeaderValue(ARequest, 'DocumentType');

    dtHeader := TMemTable.Create(nil);
    try
      // hlavicka firmy
      FirmInfo(Self.ObjectSpace, dtHeader, mModule, mDocType, mUser_ID, mFirm_ID);

      if dtHeader.Active then
      begin
        dtHeader.First;
        LogWriteSectionStart('JSON');
        json := REST_jsonCreate_FromDataSetRow(dtHeader, nil, nil);
        LogWriteSectionEnd;

        LogWriteSectionStart('get_FirmInfo_AuxFields');
        mAuxFieldsDataset := TMemTable.Create(nil);
        try
          mAuxFieldsSelect := get_FirmInfo_AuxFields(Self.ObjectSpace, mModule, mDocType, mUser_Id);
          if mAuxFieldsSelect <> '' then
          begin
            mSql :=
              'select' + nxCrLf +
              '  ' + mAuxFieldsSelect + nxCrLf +
              'from Firms F' + nxCrLf +
              'where' + nxCrLf +
              '  F.ID = ' + QuotedStr(mFirm_ID);
            Self.ObjectSpace.SQLSelect2(mSql, mAuxFieldsDataset);
            jsonAuxFields := REST_jsonCreate_FromDataSetRow(mAuxFieldsDataset, nil, nil);
            json.O['auxFields'] := jsonAuxFields;
          end;
        finally
          mAuxFieldsDataset.Free;
          LogWriteSectionEnd;
        end;

        HTTPResponse(AResponse, HTTP_SC_OK, ContentType_JSON, json.AsJson(false, true));
      end
      else begin
        ErrREST(ARequest, AResponse, HTTP_SC_NotFound, Format(getString('firm_not_found'), [mFirm_ID]));
      end;
    finally
      dtHeader.Free;
      if Assigned(json) then
        json.Free;
      if Assigned(jsonAuxFields) then
        jsonAuxFields.Free;
    end;
  finally
    LogWriteSectionEnd;
  end;
end;
///////////////////////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////////////////////
procedure listFirms(Self: TNxWebServicesHelper; ARequest: TNxHTTPRequest;
  AResponse: TNxHTTPResponse; slPath: TStringList);
var
  mSearchStr, mUser_Id, mModule, mDocType: String;
  dtRows: TMemTable;
  mSql: String;
  json: TJSONSuperObject;
begin
  LogWriteSectionStart('listFirms');
  try
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
    mModule := getHeaderValue(ARequest,'ModuleCode');
    mDocType := getHeaderValue(ARequest, 'DocumentType');

    dtRows := TMemTable.Create(nil);
    try
      mSql :=
        'select ' + FIRST_TOP(100) + NxCrLf +
        '  F.ID as "ID",' + NxCrLf +
        '  F.Code as "Code",' + NxCrLf +
        '  ' + listFirms_NameField(Self.ObjectSpace, mModule, mDocType, mUser_ID) + ' as "Name"' + NxCrLf +
        'from Firms F' + NxCrLf +
        'where' + NxCrLf +
        '  F.Hidden = ''N''' + NxCrLf +
        '  and Firm_ID is null' + NxCrLf;

      mSql := mSql +
        listFirms_Search(Self.ObjectSpace, mModule, mDocType, mUser_ID, mSearchStr);

      mSql := mSql + ' order by F.Code ';
      mSql := mSql + ' ' + FIRST_TOP_ORACLE(100);
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
      dtRows.Free;
      if Assigned(json) then
        json.Free;
    end;
  finally
    LogWriteSectionEnd;
  end;
end;
///////////////////////////////////////////////////////////////////////////////

begin
end.