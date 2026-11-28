{
Umožňuje ovlivnit validaci.
}
procedure Validate_Hook(Self: TNxCustomBusinessObject; var AResult: Boolean);
begin
  if osNew in self.state then self.SetFieldValueAsBoolean('X_TrisExported',false);
end;

begin
end.