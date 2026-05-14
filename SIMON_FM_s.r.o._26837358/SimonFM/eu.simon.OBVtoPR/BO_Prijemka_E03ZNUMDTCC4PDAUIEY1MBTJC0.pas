

{
Vyvolává se po změně každé položky. A to pouze, pokud k této změně nedochází díky načítání objektu z databáze nebo díky vytváření kopie.

procedure AfterSetFieldValue_Hook(Self: TNxCustomBusinessObject; AFieldCode: Integer; AValue: TNxParameter; AOriginalValue: TNxParameter);
begin
   if AFieldCode=self.GetFieldCode('Firm_ID') then self.SetFieldValueAsBoolean('ActualizeSuppliers',true);
  if (AFieldCode=self.GetFieldCode('DocQueue_ID')) and (AValue<>AOriginalValue) and (self.GetFieldValueAsString('DocQueue_ID')='2J10000101')
  and not(self.GetFieldValueAsBoolean('U_SearchOrder')) then begin
    if NxMessageBox('Dotaz', 'Přejete si automaticky dohledávat řádky objednávky?', mdConfirm, mdbYesNo, 0, 0, False, Nil)=mrYes then begin
      self.SetFieldValueAsBoolean('U_SearchOrder',true);
    end;
  end;
end;   }




begin
end.

begin
end.