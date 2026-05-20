uses
  'REST_SkladTerm.U_Func',
  'REST_SkladTerm.U_FuncJSON',
  'REST_SkladTerm_Special.U_DialogRolls',
  'StandardUnits.U_DataSet';

procedure listDialogSelection(AOS: TNxCustomObjectSpace; APath: TStringList; ABody: String; AResponse: TStringList);
var
  mSearchStr, mRollName: String;
  dtRows, dtDialogValues: TMemTable;
  mSql: String;
  json, jsonDialog: TJSONSuperObject;
begin
  json := nil;
  jsonDialog := nil;
  mSearchStr := '';
  if (APath.Count = 2) or (APath.Count = 3) then
  begin
    mRollName := APath.Strings[1];
    if APath.Count = 3 then
      mSearchStr := CFxInternet.URLDecode(ReplaceStr(APath.Strings[2], '+', ' '));
  end else
  begin
    SetPlainResponse(AResponse, getString('wrong_parameters_count'), HTTP_SC_BadRequest);
    exit;
  end;

  dtRows := TMemTable.Create(nil);
  dtDialogValues := TMemTable.Create(nil);
  jsonDialog := TJSONSuperObject.ParseString(ABody, True);
  try
    LogWriteSectionStart(Format('listDialogSelection: %s', [mRollName]));

    DataSet_CreataHeader(dtDialogValues, REST_DialogValuesDatasetHeader);
    dtDialogValues.Open;
    REST_JsonToDataSet(jsonDialog.A['values'], dtDialogValues);

    listSelection(AOS, gSkladTermModule, gSkladTermDocType, gSkladTermUser_ID, mSearchStr, mRollName, dtDialogValues, dtRows);

    if dtRows.Active then
    begin
      json := REST_jsonCreate_FromDataSet(dtRows, nil, nil);
    end
    else begin
      json := TJSONSuperObject.CreateByDataType(jtArray);
    end;

    SetResponse(AResponse, json.AsJson(false, true));
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