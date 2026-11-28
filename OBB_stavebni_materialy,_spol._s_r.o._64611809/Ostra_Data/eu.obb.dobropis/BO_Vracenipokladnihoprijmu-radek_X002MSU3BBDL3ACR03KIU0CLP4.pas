{
Umožňuje ovlivnit validaci.
}
procedure Validate_Hook(Self: TNxCustomBusinessObject; var AResult: Boolean);
begin
 if self.GetFieldValueAsInteger('RowType')=3 then begin
  if (self.GetFieldValueAsFloat('UnitPrice'))>(0.5+(self.GetFieldValueAsFloat('RSource_ID.TAmountWithoutVAT')/self.GetFieldValueAsFloat('RSource_ID.Quantity')*self.GetFieldValueAsFloat('RSource_ID.UnitRate'))) then begin
    self.AddValidateError(self.GetFieldCode('UnitPrice'),'Můžete dobropisovat maximálně celkovou částku ve výši '+FloatToStr(self.GetFieldValueAsFloat('Quantity')*(self.GetFieldValueAsFloat('RSource_ID.TAmountWithoutVAT')/self.GetFieldValueAsFloat('RSource_ID.Quantity'))));
    AResult:=False;
  end;
  end;
end;

begin
end.