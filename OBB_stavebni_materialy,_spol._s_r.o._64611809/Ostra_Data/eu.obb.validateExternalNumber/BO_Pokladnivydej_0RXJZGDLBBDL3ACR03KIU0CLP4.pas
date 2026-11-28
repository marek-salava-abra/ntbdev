{
Umožňuje ovlivnit validaci.
}
procedure Validate_Hook(Self: TNxCustomBusinessObject; var AResult: Boolean);
begin
 if self.GetFieldValueAsBoolean('VatDocument') then begin
  if (self.GetFieldValueAsFloat('LocalAmount')>10000) and NxIsBlank(Self.GetFieldValueAsString('ExternalNumber')) then begin
       self.AddValidateError(self.GetFieldCode('ExternalNumber'),'Není vyplněno externí číslo');
   AResult:=False;
  end;
 end;
end;

begin
end.