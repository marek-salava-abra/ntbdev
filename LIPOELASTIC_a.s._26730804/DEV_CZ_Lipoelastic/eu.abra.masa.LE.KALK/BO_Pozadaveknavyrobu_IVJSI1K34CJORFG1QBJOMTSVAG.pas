{
Umožňuje ovlivnit validaci.
}
procedure Validate_Hook(Self: TNxCustomBusinessObject; var AResult: Boolean);
begin
  if self.GetFieldValueAsString('DocQueue_ID.Code')='KALK' then begin
     if self.GetFieldValueAsFloat('CorrectedQuantity')=0 then self.SetFieldValueAsFloat('CorrectedQuantity',self.GetFieldValueAsFloat('Quantity'));
  end;
end;

begin
end.