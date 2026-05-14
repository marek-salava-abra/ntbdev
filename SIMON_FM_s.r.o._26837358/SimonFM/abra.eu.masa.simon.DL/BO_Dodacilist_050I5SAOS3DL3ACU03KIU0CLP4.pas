
{
Vyvolává se po změně každé položky. A to pouze, pokud k této změně nedochází díky načítání objektu z databáze nebo díky vytváření kopie.
}
procedure AfterSetFieldValue_Hook(Self: TNxCustomBusinessObject; AFieldCode: Integer; AValue: TNxParameter; AOriginalValue: TNxParameter);
begin
  if (AFieldCode=self.getfieldcode('Docqueue_id')) and (self.GetFieldValueAsString('DocQueue_ID')='2I10000101') then
  self.SetFieldValueAsBoolean('Finished',true);
end;

begin
end.