{
Vyvolává se při předvyplňování hodnot daného objektu.
}
procedure Prefill_Hook(Self: TNxCustomBusinessObject);
begin
  if (NxGetActualUserID_1(self)='7000000101') then Self.SetFieldValueAsString('EmailAccount_ID','7200000101');
  if (NxGetActualUserID_1(self)='SUPER00000') then Self.SetFieldValueAsString('EmailAccount_ID','3000000101');
end;

begin
end.