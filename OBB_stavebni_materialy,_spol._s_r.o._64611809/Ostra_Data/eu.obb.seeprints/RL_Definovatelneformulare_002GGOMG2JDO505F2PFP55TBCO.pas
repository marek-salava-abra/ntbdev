

{
Pomocí tohoto háčku je možné filtrovat data číselníku - vyvolá se před načtením stránky a umožňuje přidat podmínky do SQL použitého pro načtení dat.
Parametr AParams zpřístupňuje parametry číselníku. AParams je jen pro čtení, případné změny se v kódu nijak nepoužijí.
Parametr ADSQL umožňuje deklarovat podmínky, které se přidají do SQL.
}
procedure OnSelectSQL_Hook(Self: TNxBusinessRoll; AParams: TNxParameters; ADSQL: TRollDynamicSQL; AKind: TRollOnSelectSQLKind);
var
  I: Integer;
  mCLSID: string;
  mUser:TNxCustomBusinessObject;
begin

    for i := 0 to AParams.Count - 1 do begin
      if AnsiUpperCase(AParams.Params[I].Name) = '@CLSID' then mCLSID:=AParams.Params[i].AsString;
    end;
    if mCLSID='C3V5QDVZ5BDL342M01C0CX3FCC' then begin
      mUser:=Self.ObjectSpace.CreateObject(Class_SecurityUser);
      mUser.Load(NxGetActualUserID(Self.ObjectSpace),nil);
      if mUser.GetFieldValueAsInteger('U_SCformStatus')=1 then ADSQL.Where.Add('A.ID='+QuotedStr(''));
      if mUser.GetFieldValueAsInteger('U_SCformStatus')=2 then ADSQL.Where.Add('A.ID='+QuotedStr('~000000402'));
      if mUser.GetFieldValueAsInteger('U_SCformStatus')=3 then ADSQL.Where.Add('A.ID='+QuotedStr('~000000403'));
      if mUser.GetFieldValueAsInteger('U_SCformStatus')=4 then ADSQL.Where.Add('A.ID='+QuotedStr('~000000404'));
      if mUser.GetFieldValueAsInteger('U_SCformStatus')=5 then ADSQL.Where.Add('A.ID='+QuotedStr('~000000405'));
      mUser.free;
    end;
    if mCLSID='01CPMINJW3DL342X01C0CX3FCC' then begin
      mUser:=Self.ObjectSpace.CreateObject(Class_SecurityUser);
      mUser.Load(NxGetActualUserID(Self.ObjectSpace),nil);
      if mUser.GetFieldValueAsInteger('U_OPformStatus')=1 then ADSQL.Where.Add('A.ID='+QuotedStr(''));
      if mUser.GetFieldValueAsInteger('U_OPformStatus')=2 then ADSQL.Where.Add('A.ID='+QuotedStr('~000000407'));
      if mUser.GetFieldValueAsInteger('U_OPformStatus')=3 then ADSQL.Where.Add('A.ID='+QuotedStr('~000000408'));
      if mUser.GetFieldValueAsInteger('U_OPformStatus')=4 then ADSQL.Where.Add('A.ID='+QuotedStr('~000000409'));
      mUser.free;
    end;
end;

begin
end.
