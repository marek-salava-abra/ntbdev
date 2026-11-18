{
Vyvolává se po fyzickém vymazání vlastního objektu z databáze.
}
procedure AfterDelete_Hook(Self: TNxCustomBusinessObject);
var
 mList:TStringList;
 i:integer;
 mBO:TNxCustomBusinessObject;
begin
  mList:=TStringList.create;
  self.ObjectSpace.SQLSelect('Select id from defrolldata where clsid=''2TIIQXNXIXK4B5CZUIZ20K2W10'' and X_Rel_Def=''11'' and X_Value_ID='+QuotedStr(self.OID),mList);
  if mlist.Count>0 then begin
    for i:=0 to mlist.count-1 do begin
      mBO:=self.ObjectSpace.CreateObject('2TIIQXNXIXK4B5CZUIZ20K2W10');
      mBO.load(mlist.Strings[i],nil);
      mBO.delete;
    end;
  end;
end;



{
Vyvolává se při předvyplňování hodnot daného objektu.
}
procedure Prefill_Hook(Self: TNxCustomBusinessObject);
var
  mLastCode: string;
begin
  mLastCode:= Self.ObjectSpace.SQLSelectFirstAsString('SELECT MAX(Code) FROM DefRollData WHERE CLSID ='+QuotedStr(Self.CLSID));
  if NxIsBlank(mLastCode) then
    mLastCode := 'S001'
  else
    mLastCode:= 'S' + NxPadL(IntToStr(StrToInt(NxRight(mLastCode, 3)) + 1), 3, '0');
  Self.SetFieldValueAsString('Code', mLastCode);
end;

begin
end.