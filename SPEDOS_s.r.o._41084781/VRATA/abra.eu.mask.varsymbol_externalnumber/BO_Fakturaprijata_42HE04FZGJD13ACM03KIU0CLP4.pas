procedure AfterSetFieldValue_Hook(Self: TNxCustomBusinessObject; AFieldCode: Integer; AValue: TNxParameter; AOriginalValue: TNxParameter);
var
  mCode: integer;
begin
  // Zjistime kod polozky Nazev
  mCode := Self.GetFieldCode('varsymbol');
  // Pokud se meni polozka Nazev
  if AFieldCode = mCode then begin
    if NxIsBlank(Self.GetFieldValueAsString('Externalnumber')) then
       Self.SetFieldValueAsString('Externalnumber', AValue.AsString);
  end;
end;

begin
end.