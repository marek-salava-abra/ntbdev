
{
Vyvolává se při předvyplňování hodnot daného objektu.
}
procedure Prefill_Hook(Self: TNxCustomBusinessObject);
begin
  self.SetFieldValueAsDateTime('X_CreatedAt$Date',Now);
end;

begin
end.