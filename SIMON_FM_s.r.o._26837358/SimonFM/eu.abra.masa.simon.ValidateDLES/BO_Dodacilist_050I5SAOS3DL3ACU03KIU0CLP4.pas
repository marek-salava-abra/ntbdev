{
Umožňuje ovlivnit validaci.
}
procedure Validate_Hook(Self: TNxCustomBusinessObject; var AResult: Boolean);
begin
  if (self.GetFieldValueAsString('DocQueue_ID.Code')='DLES') and (osNew in self.State) then self.SetFieldValueAsString('Description',self.GetFieldValueAsString('TransportationType_ID.Name'));
end;

begin
end.