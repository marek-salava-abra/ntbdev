procedure MyValidate_HookRO(ARow: TNxCustomBusinessObject);
var
  mID_SB: string;
  mCollDRB: TNxCustomBusinessMonikerCollection; // DocRowBatch
  i: integer;
begin
  if NxCheckBit(ARow.State, osNew) then begin
    mID_SB := scrGetStoreBatchRO_ID(ARow.ObjectSpace,arow.GetFieldValueAsString('ProvideRow_ID'));
    if not NxIsEmptyOID(mID_SB) then begin
      mCollDRB := ARow.GetCollectionMonikerForFieldCode(ARow.GetFieldCode('DocRowBatches'));
      if mCollDRB.Count = 0 then // pouze když není připojena žádná šarže
        with mCollDRB.AddNewObject do begin
          SetFieldValueAsBoolean('NewBatch', False);
          SetFieldValueAsString('StoreBatch_ID', mID_SB);
          SetFieldValueAsFloat('Quantity', ARow.GetFieldValueAsFloat('Quantity'));
          SetFieldValueAsString('QUnit', ARow.GetFieldValueAsString('QUnit'));
        end;
    end;
  end;
end;

procedure MyValidate_HookIO(ARow: TNxCustomBusinessObject);
var
  mID_SB: string;
  mCollDRB: TNxCustomBusinessMonikerCollection; // DocRowBatch
  i: integer;
begin
  if NxCheckBit(ARow.State, osNew) then begin
    mID_SB := scrGetStoreBatchIO_ID(ARow.ObjectSpace,arow.GetFieldValueAsString('ProvideRow_ID'));
    if not NxIsEmptyOID(mID_SB) then begin
      mCollDRB := ARow.GetCollectionMonikerForFieldCode(ARow.GetFieldCode('DocRowBatches'));
      if mCollDRB.Count = 0 then // pouze když není připojena žádná šarže
        with mCollDRB.AddNewObject do begin
          SetFieldValueAsBoolean('NewBatch', False);
          SetFieldValueAsString('StoreBatch_ID', mID_SB);
          SetFieldValueAsFloat('Quantity', ARow.GetFieldValueAsFloat('Quantity'));
          SetFieldValueAsString('QUnit', ARow.GetFieldValueAsString('QUnit'));
        end;
    end;
  end;
end;

procedure ComplementAfterImportIO(AHeader: TNxHeaderBusinessObject);
var
  i: Integer;
begin
  for i:=0 to AHeader.Rows.Count-1 do
    MyValidate_HookIO(AHeader.Rows.BusinessObject[i]);
end;

procedure ComplementAfterImportRO(AHeader: TNxHeaderBusinessObject);
var
  i: Integer;
begin
  for i:=0 to AHeader.Rows.Count-1 do
    MyValidate_HookRO(AHeader.Rows.BusinessObject[i]);
end;

function scrGetStoreBatchRO_ID(AOS : TNxCustomObjectSpace; AValue : string) : string;
const
  cSQL = 'SELECT X_storebatch_ID FROM ReceivedOrders2 WHERE id like ''%s'' ';
var
  mList : TStringList;
begin
  mList := TStringList.create;
  try
    AOS.SQLSelect(Format(cSQL, [AValue]), mList);
    Result:='';
    if mList.Count > 0 then
      Result := mList.Strings[0]
  finally
    mList.Free;
  end;
end;

function scrGetStoreBatchIO_ID(AOS : TNxCustomObjectSpace; AValue : string) : string;
const
  cSQL = 'SELECT X_storebatch_ID FROM IssuedOrders2 WHERE id like ''%s'' ';
var
  mList : TStringList;
begin
  mList := TStringList.create;
  try
    AOS.SQLSelect(Format(cSQL, [AValue]), mList);
    Result:='';
    if mList.Count > 0 then
      Result := mList.Strings[0]
  finally
    mList.Free;
  end;
end;

begin
end.