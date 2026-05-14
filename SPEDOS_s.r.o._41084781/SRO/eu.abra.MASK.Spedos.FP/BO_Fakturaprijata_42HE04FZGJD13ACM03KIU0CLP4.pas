procedure AfterSetFieldValue_Hook(Self: TNxCustomBusinessObject; AFieldCode: Integer; AValue: TNxParameter; AOriginalValue: TNxParameter);
var
  mCode: integer;
begin
  // Zjistime kod polozky Nazev
  mCode := Self.GetFieldCode('VATAdmitDate$DATE');
  // Pokud se meni polozka Nazev
  if AFieldCode = mCode then begin
    // A pokud v polozce Poznamka totez co bylo puvodne v polozce Nazev
    // zmenime polozku Poznamka
    if not (AOriginalValue.AsString=AValue.AsString) then
       Self.SetFieldValueAsDateTime('VATDate$DATE', Self.getFieldValueAsDateTime('VATDate$DATE'));
       Self.SetFieldValueAsDateTime('DocDate$DATE', Self.getFieldValueAsDateTime('DocDate$DATE'));
  end;
end;

begin
end.