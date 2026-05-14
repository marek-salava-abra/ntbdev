

{
Vyvolává se po změně každé položky. A to pouze, pokud k této změně nedochází díky načítání objektu z databáze nebo díky vytváření kopie.
}
procedure AfterSetFieldValue_Hook(Self: TNxCustomBusinessObject; AFieldCode: Integer; AValue: TNxParameter; AOriginalValue: TNxParameter);
begin
  if (afieldcode=self.getfieldcode('DocQueue_ID')) and not(AValue.AsString=AOriginalValue.AsString) then begin
    if self.GetFieldValueAsString('DocQueue_ID.Code')='FVZ' then self.SetFieldValueAsString('BankAccount_ID','1100000101');


  end;
end;

begin
end.