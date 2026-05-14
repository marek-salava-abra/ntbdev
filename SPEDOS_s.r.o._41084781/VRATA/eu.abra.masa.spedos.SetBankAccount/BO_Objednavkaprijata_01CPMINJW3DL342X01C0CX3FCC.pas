{
Vyvolává se po změně každé položky. A to pouze, pokud k této změně nedochází díky načítání objektu z databáze nebo díky vytváření kopie.
}
procedure AfterSetFieldValue_Hook(Self: TNxCustomBusinessObject; AFieldCode: Integer; AValue: TNxParameter; AOriginalValue: TNxParameter);
begin
  if (AFieldCode=self.GetFieldCode('Currency_ID')) and not(AValue.AsString=AOriginalValue.AsString) then begin
     if self.GetFieldValueAsString('Currency_id.Code')='EUR' then self.SetFieldValueAsString('BankAccount_ID','4100000101') else
      self.SetFieldValueAsString('BankAccount_ID','3100000101');
  end;
end;

begin
end.