procedure Validate_Hook(Self: TNxCustomBusinessObject; var AResult: Boolean);
var
  S : String;
  N : integer;
begin
  S := UpperCase(Trim(Self.GetFieldValueAsString('Code')));
//  Ak se jedná se o požadavek zákazníckého portálu, čas nekontrolujeme
  if S='PROMOTEST' then
    if not TryStrToInt(Trim(Self.GetFieldValueAsString('Name')),N) then begin
      AResult := False;
      Self.AddValidateError(Self.GetFieldCode('Name'), 'Hodnota může být pouze celé číslo!');
    end;

end;

begin
end.