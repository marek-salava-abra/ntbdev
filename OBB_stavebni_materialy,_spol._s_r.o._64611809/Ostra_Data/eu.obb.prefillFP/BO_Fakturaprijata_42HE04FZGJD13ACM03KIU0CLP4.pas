{
Vyvolává se po změně každé položky. A to pouze, pokud k této změně nedochází díky načítání objektu z databáze nebo díky vytváření kopie.
}
procedure AfterSetFieldValue_Hook(Self: TNxCustomBusinessObject; AFieldCode: Integer; AValue: TNxParameter; AOriginalValue: TNxParameter);
begin

  if (AFieldCode=self.GetFieldCode('Firm_ID')) and not(NxIsEmptyOID(self.GetFieldValueAsString('Firm_ID.U_paymenttype_ID')))
    then self.SetFieldValueAsString('Paymenttype_ID',self.GetFieldValueAsString('Firm_ID.U_paymenttype_ID'));
end;

begin
end.