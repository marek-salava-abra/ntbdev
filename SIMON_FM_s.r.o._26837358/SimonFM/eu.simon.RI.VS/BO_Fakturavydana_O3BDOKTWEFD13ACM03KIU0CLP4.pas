{
Vyvolává se po změně každé položky. A to pouze, pokud k této změně nedochází díky načítání objektu z databáze nebo díky vytváření kopie.
}
procedure AfterSetFieldValue_Hook(Self: TNxCustomBusinessObject; AFieldCode: Integer; AValue: TNxParameter; AOriginalValue: TNxParameter);
begin
  if (AFieldCode=self.GetFieldCode('PaymentType_ID')) and not(AValue.AsString=AOriginalValue.AsString) then self.SetFieldValueAsBoolean('IsRowDiscount',true);
end;

begin
end.