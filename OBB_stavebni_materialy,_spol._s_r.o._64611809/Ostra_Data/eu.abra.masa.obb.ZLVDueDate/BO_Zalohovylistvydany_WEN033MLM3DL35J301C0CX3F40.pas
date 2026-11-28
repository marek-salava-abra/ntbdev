{
Umožňuje ovlivnit validaci.
}
{
Vyvolává se po změně každé položky. A to pouze, pokud k této změně nedochází díky načítání objektu z databáze nebo díky vytváření kopie.
}
procedure AfterSetFieldValue_Hook(Self: TNxCustomBusinessObject; AFieldCode: Integer; AValue: TNxParameter; AOriginalValue: TNxParameter);
begin
  if not(AValue.AsString=AOriginalValue.AsString) and (AFieldCode=self.GetFieldCode('Firm_ID'))
   then self.SetFieldValueAsDateTime('DueDate$Date',self.GetFieldValueAsDateTime('DocDate$Date')+10);
  if not(AValue.AsString=AOriginalValue.AsString) and (AFieldCode=self.GetFieldCode('DocDate$Date'))
   then self.SetFieldValueAsDateTime('DueDate$Date',self.GetFieldValueAsDateTime('DocDate$Date')+10);
end;




begin
end.