uses
  'REST_SkladTerm.U_Func',
  'REST_SkladTerm_Special.U_StandardHooks',
  'StandardUnits.U_DataSet';

function GetInputDialogValuesFields(AOS: TNxCustomObjectSpace; AModule, ADocType, AUserId, ACalledFrom: String; ADialogValues: TMemTable): String;
var
  mAdditionalValues: String;
begin
  mAdditionalValues := '';
  DataSet_CreataHeader(ADialogValues, REST_DialogValuesDatasetHeader);
  ADialogValues.Open;
  ADialogValues.Edit;
  RowDialog(AOS, AModule, ADocType, AUserId, ACalledFrom, ADialogValues);
  if ADialogValues.Modified then
    ADialogValues.Post
  else
    ADialogValues.Cancel;
  ADialogValues.First;
  while not ADialogValues.Eof do
  begin
    if (ADialogValues.FieldByName('dbValue').AsString <> '') then
      mAdditionalValues := mAdditionalValues +
        '  ' + ADialogValues.FieldByName('dbValue').AsString + ' as "dv.X_' +
          ReplaceStr(ADialogValues.FieldByName('dbValue').AsString, '.', '__') + '",' + nxCrLf;

    ADialogValues.Next;
  end;
  Result := mAdditionalValues;
end;

function SetInputDialogValuesString(ADialogValues, ADataset: TMemTable): String;
var
  mJson, rowDialogJson: TJSONSuperObject;
  mField: TField;
begin
  mJson := TJSONSuperObject.CreateByDataType(jtObject);
  try
    ADataset.First;
    while not ADataset.Eof do
    begin
      ADialogValues.First;
      while not ADialogValues.Eof do
      begin
        if (ADialogValues.FieldByName('type').AsString = 'roll')
          or (ADialogValues.FieldByName('dbValue').AsString = '') then
        begin
          ADialogValues.Next;
          continue;
        end;

        mField := ADataset.FieldByName('dv.X_' + ReplaceStr(ADialogValues.FieldByName('dbValue').AsString, '.', '__'));

        ADialogValues.Edit;
        case VarType(mField.Value) of
          varInteger, varInt64, varShortInt: begin
            ADialogValues.FieldByName('intValue').AsInteger := mField.Value;
          end;
          varCurrency, varDouble: begin
            ADialogValues.FieldByName('doubleValue').AsFloat := mField.Value;
          end;
          varString, varUString: begin
            ADialogValues.FieldByName('stringValue').AsString := mField.Value;
          end;
        end;
        ADialogValues.Post;

        ADialogValues.Next;
      end;

      rowDialogJson := mJson.CreateJSON;
      rowDialogJson.S['text'] := '';
      rowDialogJson.O['values'] := REST_jsonCreate_FromDataSet(ADialogValues, nil);
      ADataset.Edit;
      ADataset.FieldByName('dialogString').AsString := rowDialogJson.AsJson;
      ADataset.Post;

      ADataset.Next;
    end;
  finally
    mJson.Free;
  end;
end;

procedure SaveDialogValues(ABO: TNxCustomBusinessObject; ADialogValues: TJSONSuperObjectArray);
var
  mDialogValues: TMemTable;
  mDialogType: Integer;
  mDialogField: String;
begin
  mDialogValues := TMemTable.Create(nil);
  try
    DataSet_CreataHeader(mDialogValues, REST_DialogValuesDatasetHeader);
    mDialogValues.Open;
    REST_JsonToDataSet(ADialogValues, mDialogValues);

    mDialogValues.First;
    while not mDialogValues.Eof do
    begin
      if(mDialogValues.FieldByName('type').AsString = 'number') then
        ABO.SetFieldValueAsInteger(mDialogValues.FieldByName('field').AsString, mDialogValues.FieldByName('intValue').AsInteger)
      else if(mDialogValues.FieldByName('type').AsString = 'decimalNumber') then
        ABO.SetFieldValueAsFloat(mDialogValues.FieldByName('field').AsString, mDialogValues.FieldByName('doubleValue').AsFloat)
      else if(mDialogValues.FieldByName('type').AsString = 'text') then
        ABO.SetFieldValueAsString(mDialogValues.FieldByName('field').AsString, mDialogValues.FieldByName('stringValue').AsString)
      else if(mDialogValues.FieldByName('type').AsString = 'roll') then
        ABO.SetFieldValueAsString(mDialogValues.FieldByName('field').AsString, mDialogValues.FieldByName('rollValueId').AsString);
      mDialogValues.Next;
    end;
  finally
    mDialogValues.Free;
  end;
end;

procedure FillCustomFields(ARow: TNxCustomBusinessObject; ARowsDataset: TMemTable; AJson: TJSONSuperObject);
var
  i: Integer;
  jsonCustomFields: TJSONSuperObjectArray;
begin
  LogWriteSectionStart('FillCustomFields');
  // kontrola, zda jsou nejaka pole definovana
  if((AJson.A['rows'].O[ARowsDataset.FieldByName('jsonIndex').AsInteger].N['customFields'].DataType = jtNull)
      or (AJson.A['rows'].O[ARowsDataset.FieldByName('jsonIndex').AsInteger].N['customFields'].DataType = -1)) then
  begin
    LogWriteEvent('customFields not found in input json. Exiting...');
    exit;
  end;

  jsonCustomFields := AJson.A['rows'].O[ARowsDataset.FieldByName('jsonIndex').AsInteger].A['customFields'];

  for i := 0 to jsonCustomFields.Length - 1 do
  begin
    if(jsonCustomFields.O[i].S['type'] = 'text') then
    begin
      LogWriteEvent(Format('Writing text value. Field: %s, text: %s', [jsonCustomFields.O[i].S['field'], jsonCustomFields.O[i].S['textValue']]));
      ARow.SetFieldValueAsString(jsonCustomFields.O[i].S['field'], jsonCustomFields.O[i].S['textValue']);
      LogWriteEvent(Format('text value written: %s', [ARow.GetFieldValueAsString(jsonCustomFields.O[i].S['field'])]));
    end
    else if(jsonCustomFields.O[i].S['type'] = 'number') then
    begin
      LogWriteEvent(Format('Writing number value. Field: %s, number: %d', [jsonCustomFields.O[i].S['field'], jsonCustomFields.O[i].I['numberValue']]));
      ARow.SetFieldValueAsInteger(jsonCustomFields.O[i].S['field'], jsonCustomFields.O[i].I['numberValue']);
      LogWriteEvent(Format('Number value written: %d', [ARow.GetFieldValueAsInteger(jsonCustomFields.O[i].S['field'])]));
    end;
  end;
  LogWriteSectionEnd;
end;

function CreateSerialNumber(AOS: TNxCustomObjectSpace; AStoreCard_ID, AName, AAuxText: String): String;
var
  mStoreBatch: TNxCustomBusinessObject;
begin
  Result := '';
  mStoreBatch := AOS.CreateObject(Class_StoreBatch);
  try
    mStoreBatch.New;
    mStoreBatch.Prefill;
    mStoreBatch.SetFieldValueAsString('StoreCard_ID', AStoreCard_ID);
    mStoreBatch.SetFieldValueAsBoolean('SerialNumber', True);
    mStoreBatch.SetFieldValueAsString('Name', AName);
    mStoreBatch.SetFieldValueAsString('Specification', AAuxText);
    mStoreBatch.Save;
    Result := mStoreBatch.OID;
  finally
    mStoreBatch.Free;
  end;
end;

procedure AddPhotos(AOS: TNxCustomObjectSpace; ADocumentType, ADocumentId: String; ADocumentsJson: TJSONSuperObjectArray);
var
  mRelNumber, i: Integer;
begin
  LogWriteSectionStart('AddPhotos');
  try
    mRelNumber := GetRelationWithDocument(ADocumentType);
    for i := 0 to ADocumentsJson.Length - 1 do
    begin
      Relation_CreateAndSave(AOS, mRelNumber, ADocumentId, ADocumentsJson.S[i], 1);
    end;
  finally
    LogWriteSectionEnd;
  end;
end;

begin
end.