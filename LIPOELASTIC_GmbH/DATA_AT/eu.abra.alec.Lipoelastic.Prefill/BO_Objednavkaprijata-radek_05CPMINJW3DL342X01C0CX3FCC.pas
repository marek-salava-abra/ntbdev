procedure FillBusTransaction(ARow: TNxCustomBusinessObject);
var
  mBusTransaction_ID: string;
begin
  mBusTransaction_ID := ARow.GetFieldValueAsString('Parent_ID.Firm_ID.X_SalesRep_ID');
  if NxIsEmptyOID(mBusTransaction_ID) then
    Exit;

  if ARow.GetFieldValueAsString('BusTransaction_ID') <> mBusTransaction_ID then
    ARow.SetFieldValueAsString('BusTransaction_ID', mBusTransaction_ID);
end;

procedure Prefill_Hook(Self: TNxCustomBusinessObject);
begin
  FillBusTransaction(Self);
end;

procedure BeforeSave_Hook(Self: TNxCustomBusinessObject);
begin
  FillBusTransaction(Self);
end;

begin
end.
