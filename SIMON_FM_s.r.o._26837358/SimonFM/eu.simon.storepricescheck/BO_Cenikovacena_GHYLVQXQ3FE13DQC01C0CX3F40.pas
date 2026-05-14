{
Umožňuje ovlivnit validaci.
}
{
Vyvolává se před fyzickým uložením vlastních dat objektu do databáze.
}
procedure BeforeSave_Hook(Self: TNxCustomBusinessObject);
begin
  self.SetFieldValueAsDateTime('X_date_of_change',Now);
end;


begin
end.