procedure Validate_Hook(Self: TNxCustomBusinessObject; var AResult: Boolean);
begin
  if osNew in self.state then begin
    self.SetFieldValueAsBoolean('X_TariffMaterial',self.GetFieldValueAsBoolean('InputItem_ID.X_TariffMaterial'));
  end;
end;


begin
end.