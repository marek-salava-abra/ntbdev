{
Vyvolává se při předvyplňování hodnot daného objektu.
}
procedure Prefill_Hook(Self: TNxCustomBusinessObject);
begin
  self.SetFieldValueAsInteger('SynergyRate',1);
end;

begin
end.