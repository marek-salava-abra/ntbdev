(*

uses
  'eu.abra.PostProviders.uLicence',
  'eu.abra.PostProviders.uConst',
  'eu.abra.PostProviders.uSQLFunc',
  'eu.abra.PostProviders.uBalikobotFunc';

{
Umožňuje ovlivnit validaci.
}

procedure Validate_Hook(Self: TNxCustomBusinessObject; var AResult: Boolean);
const
  cSQL = 'select count(id) from PDMPostProviders where X_PD_IsLicensed = ''A'' and ID <> %s';
  cSQL2 = 'select count(id) from PDMPostProviders where X_PD_IsLicensed = ''A'' and X_PD_Driver = %s and ID <> %s';
var
  mCount, mCountLicence: integer;
begin
  //pocet licencovanych
  if AResult and Self.GetFieldValueAsBoolean('X_PD_IsLicensed') then begin
    if ((Self.GetFieldValueAsInteger('X_PD_Driver')  = cDriverBalikobot) xor(StrToIntDef(GetFirstRecordFromSQL(Self.ObjectSpace, format(cSQL2, [ IntToStr(cDriverBalikobot),QuotedStr(Self.OID)])), 0) > 0) ) then begin
      mCount := StrToIntDef(GetFirstRecordFromSQL(Self.ObjectSpace, format(cSQL, [QuotedStr(Self.OID)])), 0);
      mCountLicence := GetValueLicence();
      if mCountLicence = 0 then
        mCountLicence := 1;
      AResult := ((mCountLicence > 0) and ((mCount+1) <= mCountLicence));
      if not AResult then
        Self.AddValidateError(Self.GetFieldCode('X_PD_IsLicensed'), 'Počet licencovaných poskytovatelů poštovních služeb byl překročen.');
    end;
  end;
  //jakmile je zašktrnuto že je licencováno tak je potřeba mít vybraný driver
  if AResult and Self.GetFieldValueAsBoolean('X_PD_IsLicensed') then begin
    AResult := not ((Self.GetFieldValueAsBoolean('X_PD_IsLicensed')) and (Self.GetFieldValueAsInteger('X_PD_Driver') = cDriverNone));
    if not AResult then
      Self.AddValidateError(Self.GetFieldCode('X_PD_Driver'), 'Prosím vyberte driver poskytovatele.');
  end;
  //jakmile je zašktrnuto že je licencováno tak je potřeba mít driver jen jednou
  if AResult and Self.GetFieldValueAsBoolean('X_PD_IsLicensed') then begin
    if not (Self.GetFieldValueAsInteger('X_PD_Driver') in [cDriverNone,cDriverBalikobot]) then begin
      mCount := StrToIntDef(GetFirstRecordFromSQL(Self.ObjectSpace, format(cSQL2, [IntToStr(Self.GetFieldValueAsInteger('X_PD_Driver')), QuotedStr(Self.OID)])), 0);
      AResult := not (mCount > 0);
      if not AResult then
        Self.AddValidateError(Self.GetFieldCode('X_PD_Driver'), 'Prosím vyberte jiný driver poskytovatele.');
    end;
  end;
end;


{
Vyvolává se před fyzickým uložením vlastních dat objektu do databáze.
}
procedure BeforeSave_Hook(Self: TNxCustomBusinessObject);
begin
  if not Self.GetFieldValueAsBoolean('X_PD_IsLicensed') then
    Self.SetFieldValueAsInteger('X_PD_Driver', cDriverNone);
  BeforeSave_SettingTransfere(Self)
end;

  *)


//GeforeSaveHook


begin
end.