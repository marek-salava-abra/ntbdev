{
Vyvolává se při předvyplňování hodnot daného objektu.
}
procedure Prefill_Hook(Self: TNxCustomBusinessObject);
begin
  self.SetFieldValueAsDateTime('ValidTill$DATE',Date+14); //2000000101
  self.SetFieldValueAsDateTime('SentDate$DATE',Date);
  self.SetFieldValueAsDateTime('DeadLineToSend$DATE',Date);
  Self.SetFieldValueAsString('ResponsibleRole_ID','2000000101');
  Self.SetFieldValueAsString('ActualSolverRole_ID','2000000101');
end;

begin
end.