{
Umožňuje ovlivnit validaci.
}
procedure Validate_Hook(Self: TNxCustomBusinessObject; var AResult: Boolean);
var
 mList:TStringList;
begin
  if not(NxIsBlank(self.GetFieldValueAsString('Description'))) then begin
   mList:=TStringList.Create;
   self.ObjectSpace.SQLSelect(format('Select id from storedocuments where not(id=''%s'') and description=''%s'' and documenttype=''20'' ',[self.OID,self.GetFieldValueAsString('Description')]),mList);
   if mlist.Count>0 then begin
     self.AddValidateError(self.GetFieldCode('description'),'POZOR, se stejným popisem již faktura v evidenci existuje. Počet '+IntToStr(mList.count)+ 'doklad(ů).');
     AResult:=false;
   end;
  end;
end;

begin
end.