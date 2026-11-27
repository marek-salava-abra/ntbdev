procedure AfterSetFieldValue_Hook(Self: TNxCustomBusinessObject; ACode: Integer; AValue: TNxParameter; AOriginalValue: TNxParameter);
begin
  if CFxNxRuntime.NxGetEnvironmentType=reRuntimeExe then begin
    if (aCode=self.GetFieldCode('Firm_ID')) and not(AValue.AsString=AOriginalValue.AsString) then begin
      if NxIsBlank(self.GetFieldValueAsString('X_TargetEmail')) and not(NxIsEmptyOID(self.GetFieldValueAsString('Firm_ID'))) then
       self.SetFieldValueAsString('X_TargetEmail', self.GetFieldValueAsString('Firm_ID.ElectronicAddress_ID.Email'));
    end;
  end;
end;



begin
end.