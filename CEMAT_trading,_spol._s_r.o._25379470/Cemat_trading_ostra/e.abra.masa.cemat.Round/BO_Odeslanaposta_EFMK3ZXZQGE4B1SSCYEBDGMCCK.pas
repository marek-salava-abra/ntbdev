{
Umožňuje ovlivnit validaci.
}
procedure Validate_Hook(Self: TNxCustomBusinessObject; var AResult: Boolean);
begin
  if self.GetFieldValueAsString('PostProvider_ID')='2200000101' then self.SetFieldValueAsFloat('Weight', NxRoundByValue(self.GetFieldValueAsFloat('Weight'),ctArithmetic,1));
end;

begin
end.