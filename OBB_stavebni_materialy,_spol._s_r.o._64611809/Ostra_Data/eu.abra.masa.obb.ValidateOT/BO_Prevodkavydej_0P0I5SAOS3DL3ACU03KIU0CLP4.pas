{
Umožňuje ovlivnit validaci.
}
procedure Validate_Hook(Self: TNxCustomBusinessObject; var AResult: Boolean);
begin
  if CFxNxRuntime.NxGetEnvironmentType=reRuntimeExe then begin
    if not(self.GetFieldValueAsString('Firm_ID.OrgIdentNumber')='64611809') then begin
      self.AddValidateError(self.GetFieldCode('Firm_ID'),'Převodku výdej lze vystavit pouze na OBB');
      AResult:=False;
    end;
  end;
end;

begin
end.