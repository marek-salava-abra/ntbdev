procedure AfterSetFieldValue_Hook(Self: TNxCustomBusinessObject; AFieldCode: Integer; AValue: TNxParameter; AOriginalValue: TNxParameter);
Var
 mCountry_ID:string;
begin
  if (CFxNxRuntime.NxGetEnvironmentType=reRuntimeExe) and (osNew in self.State) then begin
    if (AFieldCode=self.GetFieldCode('Firm_ID')) and not(AValue.AsString=AOriginalValue.AsString) then begin
      if not(NxIsEmptyOID(self.GetFieldValueAsString('Firm_ID'))) then begin
        mCountry_ID:=self.ObjectSpace.SQLSelectFirstAsString('Select id from countries where code='+QuotedStr(self.GetFieldValueAsString('Firm_ID.ResidenceAddress_ID.CountryCode')),'');
        if not(NxIsEmptyOID(mCountry_ID))then begin
         self.SetFieldValueAsString('Country_ID',mCountry_ID);
        end else begin
         self.SetFieldValueAsString('Country_ID','00000CZ000');
        end;
      end;
    end;
  end;
end;

begin
end.