{do verze 21.1
procedure InFilter_Hook(Self: TNxBusinessRoll; AParams: TNxParameters; ARowCookie: integer; var AResult: Boolean);
var mStorecardTypeID: String;
begin
  if GlobParams.ParamExist('ParStoreCardType_ID') then
    mStorecardTypeID := GlobParams.ParamByName('ParStoreCardType_ID').AsString;
  if (mStorecardTypeID <> '') and (mStorecardTypeID<>'0000000000') then
    AResult := Self.Package.GetMoniker(ARowCookie).BusinessObject.GetFieldValueAsString('X_StorecardType_ID')=mStorecardTypeID
  else
    AResult := true;
end;
}

//Zde odkomentovat v případě, že klient má svázaný parametr s typem karty

{
Pomocí tohoto háčku je možné filtrovat data číselníku - vyvolá se před načtením stránky a umožňuje přidat podmínky do SQL použitého pro načtení dat.
Parametr AParams zpřístupňuje parametry číselníku. AParams je jen pro čtení, případné změny se v kódu nijak nepoužijí.
Parametr ADSQL umožňuje deklarovat podmínky, které se přidají do SQL.
}
{
procedure OnSelectSQL_Hook(Self: TNxBusinessRoll; AParams: TNxParameters; ADSQL: TRollDynamicSQL; AKind: TRollOnSelectSQLKind);
var mStorecardTypeID: String;
begin
  if GlobParams.ParamExist('ParStoreCardType_ID') then
    mStorecardTypeID := GlobParams.ParamByName('ParStoreCardType_ID').AsString;
  if (mStorecardTypeID <> '') and (mStorecardTypeID<>'0000000000') then
    ADSQL.Where.Add(Format('X_StorecardType_ID=%s',[QuotedStr(mStorecardTypeID)]))
end;
}

begin
end.