{
Umožňuje ovlivnit validaci.
}
procedure Validate_Hook(Self: TNxCustomBusinessObject; var AResult: Boolean);
begin
  if self.GetFieldValueAsDateTime('X_DocDate$Date')=0 then self.SetFieldValueAsDateTime('X_DocDate$Date',trunc(self.GetFieldValueAsDateTime('BeginDate$DATE')));
end;

begin
end.