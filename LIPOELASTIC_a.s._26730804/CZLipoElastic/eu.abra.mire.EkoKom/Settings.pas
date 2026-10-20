uses
  'eu.abra.mire.EkoKom.Lib';

{
  Vrátí objekt nastavení.
}
function GetSettingsObject(space : TNxCustomObjectSpace) : TNxCustomBusinessObject;
var
  mBO : TNxCustomBusinessObject;
  mID : string;
begin

  mID := GetSettingsID(space);

  if NxIsEmptyOID(mID) then
    RaiseException('Chyba inicializace nastavení. Restartujte program ABRA a zkuste znovu.');

  mBO := space.CreateObject(Class_EKOKOM);
  mBO.Load(mID, nil);

  Result := mBO;

end;

{
  Pokud neexistuje záznam nastavení, vytvoří nový a nastavý výchozí hodnotu EKOKOM-ID a EKOKOM-OBAL_Z_HLAVNI_JEDNOTKY
}
procedure InitSettings(space : TNxCustomObjectSpace);
var
  mBO : TNxCustomBusinessObject;
begin
  if (NxIsEmptyOID(GetSettingsID(space))) or (NxIsEmptyOID(GetSettingsID2(space))) then
  begin
    mBO := space.CreateObject(Class_EKOKOM);
    try
      //Přidání nastavení EkoKom ID
      if NxIsEmptyOID(GetSettingsID(space)) then
      begin
        mBO.New();
        mBO.Prefill();
        mBO.SetFieldValueAsString('Code', cSettingsCode);
        mBO.SetFieldValueAsString('Name', 'A00000000');
        mBO.Save();
      end;

      //Přidání nastavení EKOKOM-OBAL_Z_HLAVNI_JEDNOTKY
      if NxIsEmptyOID(GetSettingsID2(space)) then
      begin
        mBO.New();
        mBO.Prefill();
        mBO.SetFieldValueAsString('Code', cSettings2Code);
        mBO.SetFieldValueAsString('Name', 'A');
        mBO.Save();
      end;
    finally
      mBO.Free();
    end;
  end;
end;

{
  Vrátí ID záznamu nastavení
}
function GetSettingsID(space : TNxCustomObjectSpace) : string;
begin

  Result := GetDataScalar(space,
    Format('SELECT ID FROM DefRollData WHERE CLSID = %s AND Code = %s',
    [QuotedStr(Class_EKOKOM), QuotedStr(cSettingsCode)]));

end;

{
  Vrátí ID záznamu nastavení z EKOKOM-OBAL_Z_HLAVNI_JEDNOTKY
}
function GetSettingsID2(space : TNxCustomObjectSpace) : string;
begin

  Result := GetDataScalar(space,
    Format('SELECT ID FROM DefRollData WHERE CLSID = %s AND Code = %s',
    [QuotedStr(Class_EKOKOM), QuotedStr(cSettings2Code)]));

end;

begin
end.