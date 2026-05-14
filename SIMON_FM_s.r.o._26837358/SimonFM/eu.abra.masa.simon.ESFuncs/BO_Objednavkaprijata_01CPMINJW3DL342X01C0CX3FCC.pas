{
Vyvolává se před fyzickým uložením vlastních dat objektu do databáze.
}
procedure BeforeSave_Hook(Self: TNxCustomBusinessObject);
begin
  if self.GetFieldValueAsString('PMState_ID') in ['9010000101','1070000101'] then self.SetFieldValueAsBoolean('Closed',true);
end;

begin
end.