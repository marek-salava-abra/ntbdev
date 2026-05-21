{
Umožňuje ovlivnit validaci.
}
procedure Validate_Hook(Self: TNxCustomBusinessObject; var AResult: Boolean);
begin
  if (osNew in self.state) and not(CFxNxRuntime.NxGetEnvironmentType=reRuntimeExe) then begin
    if NxIsEmptyOID(self.GetFieldValueAsString('PaymentType_ID')) then begin
      if not(NxIsEmptyOID(self.GetFieldValueAsString('Firm_ID'))) then begin
        if not(NxIsEmptyOID(self.GetFieldValueAsString('Firm_ID.PaymentType_ID'))) then
         self.SetFieldValueAsString('PaymentType_ID',self.GetFieldValueAsString('Firm_ID.PaymentType_ID'));
      end;
    end;
  end;
end;

begin
end.