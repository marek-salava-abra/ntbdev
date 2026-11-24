{
Vyvolává se při předvyplňování hodnot daného objektu.
}
procedure Prefill_Hook(Self: TNxCustomBusinessObject);
begin
  Self.SetFieldValueAsString('Division_ID', '1000000101');
end;

begin
end.