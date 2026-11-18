

procedure AfterSetFieldValue_Hook(Self: TNxCustomBusinessObject; AFieldCode: Integer; AValue: TNxParameter; AOriginalValue: TNxParameter);
begin
  if (AFieldCode=self.GetFieldCode('DocQueue_ID')) and not(AValue.AsString=AOriginalValue.AsString) then begin
    if self.GetFieldValueAsString('DocQueue_ID.Code') in ['OPVZ','OPEM'] then
     self.SetFieldValueAsBoolean('IsRowDiscount',True) else  self.SetFieldValueAsBoolean('IsRowDiscount',False);
  end;
end;



begin
end.