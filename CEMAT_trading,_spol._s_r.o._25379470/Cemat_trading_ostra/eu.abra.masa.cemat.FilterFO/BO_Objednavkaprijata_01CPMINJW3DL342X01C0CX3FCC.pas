

{
Vyvolává se po změně každé položky. A to pouze, pokud k této změně nedochází díky načítání objektu z databáze nebo díky vytváření kopie.
}
{
Vyvolává se po změně každé položky. A to vždy.
}
procedure AfterSetFieldValue_Hook(Self: TNxCustomBusinessObject; AFieldCode: Integer; AValue: TNxParameter; AOriginalValue: TNxParameter);
begin
  if (AFieldCode=self.GetFieldCode('X_FirmOffice_ID')) and not(AValue.AsString=AOriginalValue.AsString) then begin
    if not(NxIsEmptyOID(AValue.AsString)) then begin
      //if NxIsBlank(self.getFieldValueAsString('U_name')) then begin
       self.SetFieldValueAsString('U_name',self.GetFieldValueAsString('X_FirmOffice_ID.Parent_ID.Name'));
       self.SetFieldValueAsString('U_Street',self.GetFieldValueAsString('X_FirmOffice_ID.Address_ID.Street'));
       self.SetFieldValueAsString('U_City_postcode',self.GetFieldValueAsString('X_FirmOffice_ID.Address_ID.City'));
       self.SetFieldValueAsString('U_postcode',self.GetFieldValueAsString('X_FirmOffice_ID.Address_ID.PostCode'));
      //end;
    end else begin
       self.SetFieldValueAsString('U_name','');
       self.SetFieldValueAsString('U_Street','');
       self.SetFieldValueAsString('U_City_postcode','');
       self.SetFieldValueAsString('U_postcode','');
    end;
  end;
end;


{procedure AfterSetFieldValue_Hook(Self: TNxCustomBusinessObject; AFieldCode: Integer; AValue: TNxParameter; AOriginalValue: TNxParameter);
begin
  if (AFieldCode=self.GetFieldCode('X_FirmOffice_ID')) and not(AValue.AsString=AOriginalValue.AsString) then begin
    if not(NxIsEmptyOID(self.GetFieldValueAsString('X_FirmOffice_ID'))) then begin
       self.SetFieldValueAsString('U_name',self.GetFieldValueAsString('X_FirmOffice_ID.Parent_ID.Name'));
       self.SetFieldValueAsString('U_Street',self.GetFieldValueAsString('X_FirmOffice_ID.Address_ID.Street'));
       self.SetFieldValueAsString('U_City_postcode',self.GetFieldValueAsString('X_FirmOffice_ID.Address_ID.City'));
       self.SetFieldValueAsString('U_postcode',self.GetFieldValueAsString('X_FirmOffice_ID.Address_ID.PostCode'));
    end else begin
       self.SetFieldValueAsString('U_name','');
       self.SetFieldValueAsString('U_Street','');
       self.SetFieldValueAsString('U_City_postcode','');
       self.SetFieldValueAsString('U_postcode','');
    end;
  end;
end; }



procedure CompleteRollValidateParams_Hook(Self: TNxCustomBusinessObject; AFieldCode: integer; AParams: TNxParameters);
begin
  if AFieldCode = Self.GetFieldCode('X_FirmOffice_ID') then begin
   if not(NxIsEmptyOID(self.GetFieldValueAsString('X_Firm_ID'))) then
    AParams.NewFromDataType(dtString, '_Firm_ID').AsString := self.GetFieldValueAsString('X_Firm_ID');
  end;
end;



begin
end.