uses 'EU.Aabra.Mask.Validace.lib';

{procedure Validate_Hook(Self: TNxCustomBusinessObject; var AResult: Boolean);
begin
  AResult := (Self.GetFieldValueAsString('CountryCode') <> '');
  if Not AResult then
    Self.AddValidateError(Self.GetFieldCode('CountryCode'), 'Položka Kód (v adrese) musí být vyplněna.');
end;  }


begin
end.