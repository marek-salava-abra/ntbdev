{
Vyvolává se před fyzickým uložením vlastních dat objektu do databáze.
}
procedure BeforeSave_Hook(Self: TNxCustomBusinessObject);
begin
  self.SetFieldValueAsDateTime('X_DateOfChange',Now);
end;

begin
end.