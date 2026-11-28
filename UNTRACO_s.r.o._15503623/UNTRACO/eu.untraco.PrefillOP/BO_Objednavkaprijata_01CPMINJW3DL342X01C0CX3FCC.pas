{
Vyvolává se při předvyplňování hodnot daného objektu.
}
procedure Prefill_Hook(Self: TNxCustomBusinessObject);
begin
  if NxGetActualUserID_1(Self) in ['1000000101','5400000101','1P00000101','3S00000101','1Y50000101'] then self.SetFieldValueAsInteger('TotalRounding',0);
  if NxGetActualUserID_1(Self) in ['SUPER00000','1I00000101','1W00000101'] then self.SetFieldValueAsInteger('TotalRounding',257);
end;

begin
end.