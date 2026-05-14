

{
Vyvolává se při předvyplňování hodnot daného objektu.
}
procedure Prefill_Hook(Self: TNxCustomBusinessObject);
begin
  Self.SetFieldValueAsDateTime('U_Date', date());
end;

begin
end.