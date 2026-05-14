procedure AfterSetFieldValue_Hook(Self: TNxCustomBusinessObject; AFieldCode: Integer; AValue: TNxParameter; AOriginalValue: TNxParameter);
var
  mCode, mCode1: integer;
begin
  mCode := Self.GetFieldCode('Docqueue_ID');
  if AFieldCode = mCode then begin

    if (AValue.AsString = '1300000101') or
       (AValue.AsString = '2300000101') or
       (AValue.AsString = '3300000101') or
       (AValue.AsString = '4300000101') or
       (AValue.AsString = '5300000101') or
       (AValue.AsString = '6300000101') or
       (AValue.AsString = '1M00000101') or
       (AValue.AsString = '7300000101') or
       (AValue.AsString = '8300000101') or
       (AValue.AsString = '9300000101') then
       Self.SetFieldValueAsString('Firm_ID', 'AG21000101');
  end;

 mCode1 := Self.GetFieldCode('Description');
  if AFieldCode = mCode1 then begin
    if nxisblank(self.GetFieldValueAsString('Externalnumber')) then self.setFieldValueAsString('Externalnumber',AValue.AsString);
  end;




end;

begin
end.