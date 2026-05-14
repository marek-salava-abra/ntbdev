uses
  'REST_SkladTerm.U_Func',
  'REST_SkladTerm.U_FuncJSON',
  'REST_SkladTerm_Special.U_DialogRolls',
  'StandardUnits.U_DataSet';

procedure listDialogSelection(AOS: TNxCustomObjectSpace; APath, AQueryParams: TStringList; ABody: String; AResponse: TStringList);
var
  mSearchStr, mRollName: String;
  dtRows, dtDialogValues: TMemTable;
  mSql: String;
  json: TJSONSuperObject;
  jsonDialogValues: TJSONSuperObjectArray;
begin
  json := nil;
  jsonDialogValues := nil;
  if APath.Count = 2 then
  begin
    mRollName := APath.Strings[1];
  end else
  begin
    SetPlainResponse(AResponse, getString('wrong_parameters_count'), HTTP_SC_BadRequest);
    exit;
  end;

  dtRows := TMemTable.Create(nil);
  dtDialogValues := TMemTable.Create(nil);
  jsonDialogValues := TJSONSuperObject.ParseString(ABody, True).AsArray;
  try
    LogWriteSectionStart(Format('listDialogSelection: %s', [mRollName]));
    mSearchStr := AQueryParams.Values('search');

    DataSet_CreataHeader(dtDialogValues, REST_DialogValuesDatasetHeader);
    dtDialogValues.Open;
    REST_JsonToDataSet(jsonDialogValues, dtDialogValues);

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
    if Assigned(jsonDialogValues) then
      jsonDialogValues.Free;
    LogWriteSectionEnd;
  end;
end;

begin
end.