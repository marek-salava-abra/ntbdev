{
Triggered after the modification of each item. Only if the modification is not caused by loading the object from the database or creating a copy.
}
procedure AfterSetFieldValue_Hook(Self: TNxCustomBusinessObject; AFieldCode: Integer; AValue: TNxParameter; AOriginalValue: TNxParameter);
begin
  if (osNew in Self.State) and (AFieldCode = Self.GetFieldCode('Firm_ID')) and (AOriginalValue.AsString <> AValue.AsString) then
  begin
    Self.SetFieldValueAsBoolean('PricesWithVAT', False);
    if (not(Self.GetFieldValueAsBoolean('Firm_ID.X_B2B'))) then
      Self.SetFieldValueAsBoolean('PricesWithVAT', True);

    Self.SetFieldValueAsString('X_PackagingMethod_ID', Self.GetFieldValueAsString('Firm_ID.X_PackagingMethod_ID'));
  end;
end;

procedure BeforeSave_Hook(Self: TNxCustomBusinessObject);
var
  mBusTransaction_ID: string;
  mRows: TNxCustomBusinessMonikerCollection;
  mRow: TNxCustomBusinessObject;
  i: Integer;
begin
  mBusTransaction_ID := Self.GetFieldValueAsString('Firm_ID.X_SalesRep_ID');
  if NxIsEmptyOID(mBusTransaction_ID) then
    Exit;

  mRows := Self.GetLoadedCollectionMonikerForFieldCode(Self.GetFieldCode('Rows'));
  for i := 0 to mRows.Count - 1 do
  begin
    mRow := mRows.BusinessObject[i];
    if mRow.GetFieldValueAsString('BusTransaction_ID') <> mBusTransaction_ID then
      mRow.SetFieldValueAsString('BusTransaction_ID', mBusTransaction_ID);
  end;
end;

begin
end.
