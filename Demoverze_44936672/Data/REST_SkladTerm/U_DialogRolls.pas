uses
  'REST_SkladTerm.U_FuncJSON',
  'REST_SkladTerm_Special.U_DialogRolls',
  'StandardUnits.U_DataSet';

procedure listDialogSelection(Self: TNxWebServicesHelper; ARequest: TNxHTTPRequest;
  AResponse: TNxHTTPResponse; slPath: TStringList);
var
  mModule, mUser_ID, mSearchStr, mRollName, mDocumentType: String;
  dtRows, dtDialogValues: TMemTable;
  mSql: String;
  json, jsonDialog: TJSONSuperObject;
begin
  json := nil;
  jsonDialog := nil;
  mSearchStr := '';
  if (slPath.Count = 2) or (slPath.Count = 3) then
  begin
    mRollName := slPath.Strings[1];
    if slPath.Count = 3 then
      mSearchStr := CFxInternet.URLDecode(ReplaceStr(slPath.Strings[2], '+', ' '));
  end else
  begin
    ErrREST(ARequest, AResponse, HTTP_SC_BadRequest, getString('wrong_parameters_count'));
    exit;
  end;

  mModule := getHeaderValue(ARequest, 'ModuleCode');
  mUser_ID := getHeaderValue(ARequest, 'UserID');
  mDocumentType := getHeaderValue(ARequest, 'DocumentType');

  dtRows := TMemTable.Create(nil);
  dtDialogValues := TMemTable.Create(nil);
  jsonDialog := TJSONSuperObject.ParseString(REST_ByteUTF82String(ARequest.Content.Content), True);
  try
    LogWriteSectionStart(Format('listDialogSelection: %s', [mRollName]));

    DataSet_CreataHeader(dtDialogValues, REST_DialogValuesDatasetHeader);
    dtDialogValues.Open;
    REST_JsonToDataSet(jsonDialog.A['values'], dtDialogValues);

    listSelection(Self.ObjectSpace, mModule, mDocumentType, mUser_ID, mSearchStr, mRollName, dtDialogValues, dtRows);

    if dtRows.Active then
    begin
      json := REST_jsonCreate_FromDataSet(dtRows, nil, nil);
    end
    else begin
      json := TJSONSuperObject.CreateByDataType(jtArray);
    end;

    HTTPResponse(AResponse, HTTP_SC_OK, ContentType_JSON, json.AsJson(false, true));
  finally
    dtRows.Free;
    dtDialogValues.Free;
    if Assigned(json) then
      json.Free;
    if Assigned(jsonDialog) then
      jsonDialog.Free;
    LogWriteSectionEnd;
  end;
end;

begin
end.