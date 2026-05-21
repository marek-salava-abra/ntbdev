

{
Umožňuje ovlivnit validaci.
}
procedure Validate_Hook(Self: TNxCustomBusinessObject; var AResult: Boolean);
begin
  if CFxNxRuntime.NxGetEnvironmentType=reRuntimeExe then begin
   if Length(self.GetFieldValueAsString('ExternalNumber'))>50 then begin
    AResult:=False;
    self.AddValidateError(self.GetFieldCode('ExternalNumber'), 'Maximal length of ExternalNumber is 50 chars.');
   end;
  end;
end;

begin
end.