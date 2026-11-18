
{
Umožňuje ovlivnit validaci.
}
procedure Validate_Hook(Self: TNxCustomBusinessObject; var AResult: Boolean);
begin
    self.SetFieldValueAsInteger('SynergyRate',1);
end;

begin
end.