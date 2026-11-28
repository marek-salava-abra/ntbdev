{
Vyvolává se po změně každé položky. A to pouze, pokud k této změně nedochází díky načítání objektu z databáze nebo díky vytváření kopie.
}
procedure AfterSetFieldValue_Hook(Self: TNxCustomBusinessObject; AFieldCode: Integer; AValue: TNxParameter; AOriginalValue: TNxParameter);
begin
  if (AFieldCode=self.GetFieldCode('U_Address_ID')) and not(avalue.AsString=AOriginalValue.AsString) then begin
    if not(NxIsEmptyOID(self.GetFieldValueAsString('U_Address_ID'))) then begin
       self.SetFieldValueAsString('U_Street', self.GetFieldValueAsString('U_address_ID.U_Street'));
       self.SetFieldValueAsString('U_City', self.GetFieldValueAsString('U_address_ID.U_City'));
       self.SetFieldValueAsString('U_PostCode', self.GetFieldValueAsString('U_address_ID.U_PostCode'));
       self.SetFieldValueAsString('U_contact', self.GetFieldValueAsString('U_address_ID.U_Contact'));
    end;
    if (NxIsEmptyOID(self.GetFieldValueAsString('U_Address_ID'))) then begin
       self.SetFieldValueAsString('U_Street', '');
       self.SetFieldValueAsString('U_City', '');
       self.SetFieldValueAsString('U_PostCode', '');
       self.SetFieldValueAsString('U_contact', '');
    end;
  end;
end;

begin
end.