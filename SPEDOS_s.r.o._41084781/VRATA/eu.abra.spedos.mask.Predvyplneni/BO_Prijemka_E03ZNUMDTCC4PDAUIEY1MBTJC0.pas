procedure AfterSetFieldValue_Hook(Self: TNxCustomBusinessObject; AFieldCode: Integer; AValue: TNxParameter; AOriginalValue: TNxParameter);
var
  mCode: integer;
begin
  // Zjistime kod polozky Nazev
  mCode := Self.GetFieldCode('DocQueue_ID');
  if AFieldCode = mCode then begin
       if AValue.AsString='U100000101' then begin
          Self.SetFieldValueAsString('Firm_ID', 'AG21000101');
       end;
  end;
end;

begin
end.