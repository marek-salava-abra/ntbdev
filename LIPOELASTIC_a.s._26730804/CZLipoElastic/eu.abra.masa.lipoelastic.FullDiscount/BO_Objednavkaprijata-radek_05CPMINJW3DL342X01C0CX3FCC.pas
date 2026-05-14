





procedure AfterSetFieldValue_Hook(Self: TNxCustomBusinessObject; AFieldCode: Integer; AValue: TNxParameter; AOriginalValue: TNxParameter);
begin
  if (AFieldCode=self.GetFieldCode('RowType')) and not(AValue.AsInteger=AOriginalValue.AsInteger) then begin
    if self.GetFieldValueAsBoolean('Parent_ID.IsRowDiscount') and (self.GetFieldValueAsInteger('RowType')>0)
     and (self.GetFieldValueAsString('Parent_ID.Docqueue_ID.Code') in ['OPVZ','OPEM'] ) then
     self.SetFieldValueAsFloat('RowDiscount',100);
  end;
end;


procedure Prefill_Hook(Self: TNxCustomBusinessObject);
begin
  if self.GetFieldValueAsBoolean('Parent_ID.IsRowDiscount') and (self.GetFieldValueAsInteger('RowType')>0) and
  (self.GetFieldValueAsString('Parent_ID.Docqueue_ID.Code') in ['OPVZ','OPEM'] ) then
     self.SetFieldValueAsFloat('RowDiscount',100);
end;



{
Umožňuje ovlivnit validaci.
}
procedure Validate_Hook(Self: TNxCustomBusinessObject; var AResult: Boolean);
begin
  if self.GetFieldValueAsBoolean('Parent_ID.IsRowDiscount') and (self.GetFieldValueAsInteger('RowType')>0) and
  (self.GetFieldValueAsString('Parent_ID.Docqueue_ID.Code') in ['OPVZ','OPEM'] )  and (self.GetFieldValueAsFloat('RowDiscount')=0) then
     self.SetFieldValueAsFloat('RowDiscount',100);
end;

begin
end.