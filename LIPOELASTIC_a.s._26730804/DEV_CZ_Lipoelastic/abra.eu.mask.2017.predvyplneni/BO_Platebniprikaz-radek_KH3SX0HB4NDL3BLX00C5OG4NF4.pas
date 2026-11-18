{
Vyvolává se při předvyplňování hodnot daného objektu.
}
procedure Prefill_Hook(Self: TNxCustomBusinessObject);
begin
  self.SetFieldValueAsInteger('ForeignIssue',2);
end;

begin
end.