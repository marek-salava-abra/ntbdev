{
Umožňuje ovlivnit validaci.
}
procedure Validate_Hook(Self: TNxCustomBusinessObject; var AResult: Boolean);
var
  S : String;
  N : integer;
begin
  S := Trim(Self.GetFieldValueAsString('Code'));
//  Ak se jedná se o požadavek zákazníckého portálu, čas nekontrolujeme
  if (not TryStrToInt(S,N))  or (S ='') then begin
      AResult := False;
      Self.AddValidateError(Self.GetFieldCode('Code'), 'Hodnota může být pouze celé číslo!');
    end;

end;

begin
end.