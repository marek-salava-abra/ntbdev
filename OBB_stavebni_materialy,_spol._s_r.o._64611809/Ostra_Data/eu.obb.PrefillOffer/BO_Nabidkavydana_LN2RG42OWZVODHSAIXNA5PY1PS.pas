{
Vyvolává se při předvyplňování hodnot daného objektu.
}
procedure Prefill_Hook(Self: TNxCustomBusinessObject);
var
 mRole_ID:String;
 mUser:TNxCustomBusinessObject;
begin
  mUser:=self.ObjectSpace.CreateObject(Class_SecurityUser);
  mUser.Load(NxGetActualUserID_1(self),nil);
  mRole_ID:=mUser.GetFieldValueAsString('U_role_ID');

  self.SetFieldValueAsDateTime('DeadLineToSend$DATE',Date);
  self.SetFieldValueAsDateTime('ValidTill$DATE',Date+14);
  //self.SetFieldValueAsBoolean('IsRowDiscount',True);
  self.SetFieldValueAsString('ResponsibleRole_ID', mRole_ID);
  self.SetFieldValueAsString('ActualSolverRole_ID', mRole_ID);
end;

begin
end.