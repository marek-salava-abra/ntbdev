{
Umožňuje ovlivnit validaci.
}
procedure Validate_Hook(Self: TNxCustomBusinessObject; var AResult: Boolean);
begin
  if not(osNew in self.State) and NxIsEmptyOID(self.GetFieldValueAsString('X_CorrectedBy_ID')) then begin
    self.SetFieldValueAsString('X_CorrectedBy_ID',NxGetActualUserID_1(Self));
    self.SetFieldValueAsDateTime('X_FirstCorrectedAt$Date',Now);

  end;
end;

begin
end.