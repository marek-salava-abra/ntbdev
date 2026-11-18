{
Vyvolává se při předvyplňování hodnot daného objektu.
}
procedure Prefill_Hook(Self: TNxCustomBusinessObject);
var
 mString:String;
 mList:TStringList;
begin
 mList:=Tstringlist.Create;
 self.ObjectSpace.SQLSelect('Select max(code) from defrolldata where clsid=''DK4IQ0V3L5EORHQYMUBJLYHF0O'' and code like ''STR-___'' and hidden=''N'' ',mList);
 mString:='STR-'+AnsiRightStr('00'+IntToStr(StrToInt(AnsiRightStr(mlist.strings[0],3))+1),3);
 self.SetFieldValueAsString('Code',mString);
end;

begin
end.