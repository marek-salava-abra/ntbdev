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
  Pokud neexistuje záznam nastavení, vytvoří nový a nastavý výchozí hodnotu EKOKOM-ID
}
procedure InitSettings(space : TNxCustomObjectSpace);
var
  mBO : TNxCustomBusinessObject;
begin

  if not NxIsEmptyOID(GetSettingsID(space)) then
    Exit;

  mBO := space.CreateObject(Class_EKOKOM);

  try
    mBO.New();
    mBO.Prefill();
    mBO.SetFieldValueAsString('Code', cSettingsCode);
    mBO.SetFieldValueAsString('Name', 'A00000000');
    
    mBO.Save();
  finally
    mBO.Free();
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

begin
end.