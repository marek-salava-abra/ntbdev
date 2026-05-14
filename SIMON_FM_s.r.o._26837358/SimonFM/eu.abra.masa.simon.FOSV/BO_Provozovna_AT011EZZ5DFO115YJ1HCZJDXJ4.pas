{
Vyvolává se po změně každé položky. A to pouze, pokud k této změně nedochází díky načítání objektu z databáze nebo díky vytváření kopie.
}
procedure AfterSetFieldValue_Hook(Self: TNxCustomBusinessObject; AFieldCode: Integer; AValue: TNxParameter; AOriginalValue: TNxParameter);
begin
  if AFieldCode=self.GetFieldCode('X_CommercialsAgreement') then begin
   if self.GetFieldValueAsBoolean('X_CommercialsAgreement') then
    self.SetFieldValueAsDateTime('X_AgreementFrom$Date',Now) else
    self.SetFieldValueAsDateTime('X_AgreementFrom$Date',0);
  end;
end;

begin
end.