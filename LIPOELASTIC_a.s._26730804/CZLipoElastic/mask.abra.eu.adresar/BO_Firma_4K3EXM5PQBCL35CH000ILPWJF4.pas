uses 'EU.Aabra.Mask.Validace.lib';
{
Umožňuje ovlivnit validaci.
}
{
Vyvolává se bezprostředně před provedením softvalidace objektu.
}
procedure BeforeSoftValidate_Hook(Self: TNxCustomBusinessObject);
begin
if NxIsEmptyOID(self.GetFieldValueAsString('X_BankAcount')) then self.SetFieldValueAsString('X_BankAcount','3JN0000101') ;
end;


procedure Validate_Hook(Self: TNxCustomBusinessObject; var AResult: Boolean);
begin
  AResult := (Self.GetFieldValueAsString('ResidenceAddress_ID.CountryCode') <> '');
  if Not AResult then
    Self.AddValidateError(Self.GetFieldCode('ResidenceAddress_ID.CountryCode'), 'Položka Kód (v adrese) musí být vyplněna.');
end;





procedure AfterSetFieldValue_Hook(Self: TNxCustomBusinessObject; AFieldCode: Integer; AValue: TNxParameter; AOriginalValue: TNxParameter);
var
  mCode: integer;
begin
  // Zjistime kod polozky Nazev
  mCode := Self.GetFieldCode('Firm_ID');
  // Pokud se meni polozka Nazev
  if AFieldCode = mCode then begin
    // A pokud v polozce Poznamka totez co bylo puvodne v polozce Nazev
    // zmenime polozku Poznamka
    if (AOriginalValue.AsString <> AValue.AsString) and (AValue.AsString<>'') then
       self.SetFieldValueAsDateTime('X_Zas_opr_date',now());
  end;
end;

begin
end.