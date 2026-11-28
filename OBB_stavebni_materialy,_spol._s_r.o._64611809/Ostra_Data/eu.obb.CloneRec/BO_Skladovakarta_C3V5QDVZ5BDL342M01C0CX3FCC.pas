

{
Vyvolává se po uložení vlastních dat objektu do databáze.
}
procedure AfterSave_Hook(Self: TNxCustomBusinessObject);
var
 mList:TStringList;
 mBO:TNxCustomBusinessObject;
 i:integer;
begin
  if osNew in self.state then begin
      mList:=TStringList.Create;
      self.ObjectSpace.SQLSelect(Format('select id from suppliers where storecard_id=''%s'' ',[self.OID]),mList);
      if mList.Count>0 then begin
        for i:=0 to mList.count-1 do begin
          mbo:=self.ObjectSpace.CreateObject(Class_Supplier);
          mBO.load(mlist.strings[i],nil);
          mBO.delete;


        end;
      end;
      mList.Free;
  end;
end;

begin
end.