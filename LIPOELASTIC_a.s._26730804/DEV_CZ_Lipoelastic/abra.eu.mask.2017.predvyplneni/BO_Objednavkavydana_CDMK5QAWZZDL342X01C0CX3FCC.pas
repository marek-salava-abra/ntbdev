

{
Vyvolává se před fyzickým uložením vlastních dat objektu do databáze.
}
procedure BeforeSave_Hook(Self: TNxCustomBusinessObject);
begin
      if self.GetFieldValueAsString('CreatedBy_ID')='1Y10000101' then begin
           self.SetFieldValueAsBoolean('Confirmed',True);
      end;


end;

begin
end.