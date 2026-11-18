const
  cVALIDATE_COUNTRYCODE_MESSAGE = 'Položka "kód země" v adrese sídla neobsahuje platný kód z číselníku zemí';
{
Umožňuje ovlivnit validaci.
}
procedure Validate_Hook(Self: TNxCustomBusinessObject; var AResult: Boolean);
var
  mCountryCode, mCountryName: string;
begin
  if not (osNew in Self.State) then
    exit;

  mCountryCode:= Self.GetFieldValueAsString('ResidenceAddress_ID.CountryCode');

  if NxIsBlank(mCountryCode) then exit;

  mCountryName:= Self.ObjectSpace.SQLSelectFirstAsString(
    ' SELECT Name FROM Countries WHERE Code = '+
    QuotedStr(Self.GetFieldValueAsString('ResidenceAddress_ID.CountryCode')), '');

  if NxIsBlank(mCountryName) then
  begin
    Self.AddValidateError(Self.GetFieldCode('ResidenceAddress_ID.CountryCode'), cVALIDATE_COUNTRYCODE_MESSAGE);
    AResult:= false;
    exit;
  end else
  begin
    Self.SetFieldValueAsString('ResidenceAddress_ID.CountryCode', UpperCase(mCountryCode));
    Self.SetFieldValueAsString('ResidenceAddress_ID.Country', mCountryName);
  end;
end;

begin
end.