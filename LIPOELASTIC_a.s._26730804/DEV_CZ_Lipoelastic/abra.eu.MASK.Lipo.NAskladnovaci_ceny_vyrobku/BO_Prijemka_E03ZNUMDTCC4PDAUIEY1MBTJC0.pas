{
Vyvolává se před fyzickým uložením vlastních dat objektu do databáze.
}
procedure BeforeSave_Hook(Self: TNxCustomBusinessObject);
begin
  if NxIsEmptyOID(self.GetFieldValueAsString('Firm_ID')) then self.setFieldValueAsString('Firm_ID','17V3000101') ;
end;

begin
end.