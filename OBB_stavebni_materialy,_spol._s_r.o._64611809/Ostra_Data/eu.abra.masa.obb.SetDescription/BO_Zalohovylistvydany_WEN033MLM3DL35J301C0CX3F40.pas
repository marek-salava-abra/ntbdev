{
Vyvolává se po změně každé položky. A to pouze, pokud k této změně nedochází díky načítání objektu z databáze nebo díky vytváření kopie.
}
procedure AfterSetFieldValue_Hook(Self: TNxCustomBusinessObject; AFieldCode: Integer; AValue: TNxParameter; AOriginalValue: TNxParameter);
begin
  if (AFieldCode=self.GetFieldCode('X_Vazniky')) and not(AValue.AsBoolean=AOriginalValue.AsBoolean) then begin
   if AnsiLeftStr(self.GetFieldValueAsString('Firm_ID.VATIdentNumber'),2)='CZ' then begin
    if self.GetFieldValueAsBoolean('X_Vazniky') then self.SetFieldValueAsString('description','RPDP');
    if not(self.GetFieldValueAsBoolean('X_Vazniky')) then self.SetFieldValueAsString('description','');
   end;
  end;
end;

begin
end.