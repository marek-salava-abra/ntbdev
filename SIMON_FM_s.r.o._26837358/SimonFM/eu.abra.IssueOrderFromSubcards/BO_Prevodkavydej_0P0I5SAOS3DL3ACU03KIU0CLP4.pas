{
Umožňuje ovlivnit validaci.
}
procedure Validate_Hook(Self: TNxCustomBusinessObject; var AResult: Boolean);
begin
  if (self.GetFieldValueAsString('DocQueue_ID')='R200000101') and (UpperCase(NxLeft(self.GetFieldValueAsString('Description'),4))='DROB') and
  (self.GetFieldValueAsInteger('X_month')=0) then begin
    self.SetFieldValueAsInteger('X_month',NxExtractMonth(self.GetFieldValueAsDateTime('DocDate$date')));
  end;
end;

begin
end.