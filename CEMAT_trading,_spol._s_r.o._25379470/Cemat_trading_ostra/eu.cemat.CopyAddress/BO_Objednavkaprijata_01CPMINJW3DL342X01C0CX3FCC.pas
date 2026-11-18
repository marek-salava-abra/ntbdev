{
Vyvolává se po změně každé položky. A to pouze, pokud k této změně nedochází díky načítání objektu z databáze nebo díky vytváření kopie.
}
procedure AfterSetFieldValue_Hook(Self: TNxCustomBusinessObject; AFieldCode: Integer; AValue: TNxParameter; AOriginalValue: TNxParameter);
var
 mBO:TNxCustomBusinessObject;
begin
  {if AFieldCode=self.GetFieldCode('U_CopyAddress') then begin
    if self.GetFieldValueAsBoolean('U_CopyAddress') then begin
      NxShowSimpleMessage(self.GetFieldValueAsString('X_firmoffice_ID'),nil);
      self.SetFieldValueAsString('X_Firm_ID',self.GetFieldValueAsString('Firm_ID'));
      self.SetFieldValueAsString('U_Name',self.GetFieldValueAsString('Firm_ID.Name'));
      self.SetFieldValueAsString('U_street',self.GetFieldValueAsString('Firm_ID.ResidenceAddress_ID.Street'));
      self.SetFieldValueAsString('U_city_postcode',self.GetFieldValueAsString('Firm_ID.ResidenceAddress_ID.City'));
      self.SetFieldValueAsString('U_postcode',self.GetFieldValueAsString('Firm_ID.ResidenceAddress_ID.Postcode'));
      //self.SetFieldValueAsString('U_street',self.GetFieldValueAsString('ResidenceAddress_ID.Street'));
    end;
    if not(self.GetFieldValueAsBoolean('U_CopyAddress')) then begin
      self.SetFieldValueAsString('X_Firm_ID','');
      self.SetFieldValueAsString('U_Name','');
      self.SetFieldValueAsString('U_street','');
      self.SetFieldValueAsString('U_city_postcode','');
      self.SetFieldValueAsString('U_postcode','');
      //self.SetFieldValueAsString('U_street',self.GetFieldValueAsString('ResidenceAddress_ID.Street'));
    end;
  end;}
end;

begin
end.