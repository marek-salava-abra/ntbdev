{
Umožňuje ovlivnit validaci.
}
procedure Validate_Hook(Self: TNxCustomBusinessObject; var AResult: Boolean);
begin
  if self.GetFieldValueAsBoolean('Closed') then self.SetFieldValueAsBoolean('Confirmed',True);
end;

begin
end.