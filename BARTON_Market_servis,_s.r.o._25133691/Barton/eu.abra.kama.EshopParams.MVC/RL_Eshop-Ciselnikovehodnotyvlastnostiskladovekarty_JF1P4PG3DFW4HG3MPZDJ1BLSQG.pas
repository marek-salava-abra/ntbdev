{do verze 21.1
procedure InFilter_Hook(Self: TNxBusinessRoll; AParams: TNxParameters; ARowCookie: integer; var AResult: Boolean);
var mPropertyID: String;
begin
  if GlobParams.ParamExist('ParProperty_ID') then
    mPropertyID := GlobParams.ParamByName('ParProperty_ID').AsString;
  if (mPropertyID <> '') and (mPropertyID<>'0000000000') then
    AResult := Self.Package.GetMoniker(ARowCookie).BusinessObject.GetFieldValueAsString('X_PROPERTY_ID')=mPropertyID
  else
    AResult := true;
end;
}


{
Pomocí tohoto háčku je možné filtrovat data číselníku - vyvolá se před načtením stránky a umožňuje přidat podmínky do SQL použitého pro načtení dat.
Parametr AParams zpřístupňuje parametry číselníku. AParams je jen pro čtení, případné změny se v kódu nijak nepoužijí.
Parametr ADSQL umožňuje deklarovat podmínky, které se přidají do SQL.
}
procedure OnSelectSQL_Hook(Self: TNxBusinessRoll; AParams: TNxParameters; ADSQL: TRollDynamicSQL; AKind: TRollOnSelectSQLKind);
var mPropertyID: String;
begin
  if GlobParams.ParamExist('ParProperty_ID') then
    mPropertyID := GlobParams.ParamByName('ParProperty_ID').AsString;
  if (mPropertyID <> '') and (mPropertyID<>'0000000000') then
    ADSQL.Where.Add(Format('X_PROPERTY_ID=%s',[QuotedStr(mPropertyID)]));
end;

begin
end.