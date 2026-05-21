{
Triggered when prefilling object values.
}
procedure Prefill_Hook(Self: TNxCustomBusinessObject);
begin
  Self.SetFieldValueAsString('ActualSolverRole_ID', 'SUPER00000');
  Self.SetFieldValueAsDateTime('DeadLineToSend$DATE', Date);
  Self.SetFieldValueAsDateTime('ValidTill$DATE', Date +14);
end;

begin
end.