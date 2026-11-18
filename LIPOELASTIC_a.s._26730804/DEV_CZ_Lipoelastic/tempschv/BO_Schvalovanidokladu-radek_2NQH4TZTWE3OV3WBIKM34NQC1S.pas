{
Vyvolává se po uložení vlastních dat objektu do databáze.
}
procedure AfterSave_Hook(Self: TNxCustomBusinessObject);
begin
  NxShowSimpleMessage(self.oid,nil);
end;

begin
end.