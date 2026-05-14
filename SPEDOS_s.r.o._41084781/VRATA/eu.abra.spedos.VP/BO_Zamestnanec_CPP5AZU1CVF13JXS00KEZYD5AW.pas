{
Umožňuje ovlivnit validaci.
}
procedure Validate_Hook(Self: TNxCustomBusinessObject; var AResult: Boolean);
begin
  if CFxNxRuntime.NxGetEnvironmentType=reRuntimeExe then begin
    if NxIsValidEMail(self.GetFieldValueAsString('X_Email_paska'),False) and NxIsBlank(self.GetFieldValueAsString('X_Heslo')) then begin
       AResult:=False;
       self.AddValidateError(self.GetFieldCode('X_Heslo'),'Heslo pro výplatní pásku nesmí být prázdné.');
    end;
  end;
end;

begin
end.