{
Umožňuje ovlivnit validaci.

procedure Validate_Hook(Self: TNxCustomBusinessObject; var AResult: Boolean);
begin
  if self.GetFieldValueAsBoolean('X_B2B') and
   NxIsBlank(self.GetFieldValueAsString('ResidenceAddress_ID.Email')) then begin
     self.AddValidateError(self.GetFieldCode('OrgIdentNumber'),'Neplatný email');
     AResult:=False;
   end;
end;}

begin
end.