{
Umožňuje ovlivnit validaci.
}
procedure Validate_Hook(Self: TNxCustomBusinessObject; var AResult: Boolean);
begin
  if osNew in self.State then self.SetFieldValueAsDateTime('X_CreatedAt',Now);
end;

begin
end.