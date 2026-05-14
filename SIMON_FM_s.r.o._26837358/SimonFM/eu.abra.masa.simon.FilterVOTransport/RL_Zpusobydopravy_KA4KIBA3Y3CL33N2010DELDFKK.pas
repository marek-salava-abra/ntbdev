{
Pomocí tohoto háčku je možné filtrovat data číselníku - vyvolá se před načtením stránky a umožňuje přidat podmínky do SQL použitého pro načtení dat.
Parametr AParams zpřístupňuje parametry číselníku. AParams je jen pro čtení, případné změny se v kódu nijak nepoužijí.
Parametr ADSQL umožňuje deklarovat podmínky, které se přidají do SQL.
}
procedure OnSelectSQL_Hook(Self: TNxBusinessRoll; AParams: TNxParameters; ADSQL: TRollDynamicSQL; AKind: TRollOnSelectSQLKind);
begin
   if NxGetActualUserID(self.ObjectSpace) in ['B000000101','1O00000101','3E40000101','C000000101','A000000101'] then
    ADSQL.Where.Add('A.code like ''VO_'' ');

end;

begin
end.