{
Vyvolává se při předvyplňování hodnot daného objektu.
}
procedure Prefill_Hook(Self: TNxCustomBusinessObject);
var
 mName:string;
begin
  mName:=self.ObjectSpace.SQLSelectFirstAsString('SELECT max(name) FROM PLMPictures WHERE lEN(name)=5 and LEFT(name, 5) NOT LIKE '+Quotedstr('%[^0-9]%'),'');
  if NxIBStrToFloat(mName)=0 then mName:='10000' else mName:=IntToStr(StrToInt(mName)+1);
  self.SetFieldValueAsString('name',mName);
end;

begin
end.