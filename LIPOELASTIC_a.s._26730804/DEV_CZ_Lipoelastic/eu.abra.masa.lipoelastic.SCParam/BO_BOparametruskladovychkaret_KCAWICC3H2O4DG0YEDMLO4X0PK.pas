{
Vyvolává se při předvyplňování hodnot daného objektu.
}
procedure Prefill_Hook(Self: TNxCustomBusinessObject);
var
  mLastCode: string;
begin
  mLastCode:= Self.ObjectSpace.SQLSelectFirstAsString('SELECT MAX(Code) FROM DefRollData WHERE CLSID ='+QuotedStr(Self.CLSID));
  if NxIsBlank(mLastCode) then
    mLastCode := 'P001'
  else
    mLastCode:= 'P' + NxPadL(IntToStr(StrToInt(NxRight(mLastCode, 3)) + 1), 3, '0');
  Self.SetFieldValueAsString('Code', mLastCode);
end;

begin
end.