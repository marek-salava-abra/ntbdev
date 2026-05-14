{
Vyvolává se před fyzickým uložením vlastních dat objektu do databáze.
}
procedure BeforeSave_Hook(Self: TNxCustomBusinessObject);
begin
  if NxIsEmptyOID(self.GetFieldValueAsString('X_STORE_ID')) then self.SetFieldValueAsString('X_STORE_ID',self.getFieldValueAsString('U_STORE_ID'));

end;

begin
end.