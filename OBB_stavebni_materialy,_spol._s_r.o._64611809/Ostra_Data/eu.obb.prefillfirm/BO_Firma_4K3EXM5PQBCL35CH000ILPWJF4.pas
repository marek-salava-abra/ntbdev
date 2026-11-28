{
Vyvolává se při předvyplňování hodnot daného objektu.
}
procedure Prefill_Hook(Self: TNxCustomBusinessObject);
begin
  self.SetFieldValueAsBoolean('AfterDueTermEnabled',true);
  self.SetFieldValueAsInteger('AfterDueTerm',30);
  {self.SetFieldValueAsBoolean('CheckCredit',true); }
end;

begin
end.