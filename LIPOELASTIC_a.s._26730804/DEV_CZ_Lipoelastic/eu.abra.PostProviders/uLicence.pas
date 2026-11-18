uses 'eu.abra.PostProviders.uLanguage';

const
  //U_Licence_ident z firemní G4
  cLicGuid = '{8D6511B8-DE50-451E-B5DA-29302CCCB029}';
  cPackageName = 'Expedice balíků'+#13#10;
  cIsVisual = true;
  cIsNotVisual = false;
  //Pouze nouzové řešení vždy vrátit!!.
  cIgnorLicence = true;

{
  Zkontroluje zda je platná licence.
}
procedure CheckLicence(self: TNxWebServicesHelper);
var
  s: string;
begin
  if not cIgnorLicence then
    if not TestLicence(cIsNotVisual, s) then
      RaiseException(lng_msg_LicenceStatus+#13#10+s);
end;

function TestLicence(const mVisual:boolean; var LogInfoStr: string): boolean;
var
  mDate : TDateTime;
  mCountDay : integer;
  mName: string;
begin
  Result := true;
  mName := Format(lng_msg_LicenceName, [cPackageName]);
  LogInfoStr := '';
  if CFxNxRuntime.NxCheckRequiredMinimumABRAVersion(13, 1, 9) then begin
    Result := CFxCustomLicence.IsValid(cLicGuid);
    mDate := CFxCustomLicence.GetDate(cLicGuid);
    if Result and (mDate = 0) then Exit; // neomezená licence
    //20 dnu před vypršením testovací budu upozorňovat
    if Result and ((mDate >= Date) and (mDate < (Date + 20))) then begin
      mCountDay := Round(mDate-Date);
      if mVisual then
        ShowMessage('Testovací licence'+mName+'vyprší: ' + DateToStr(mDate) + ', to je za ' + IntToStr(mCountDay) + ' dní.')
      else
        LogInfoStr := 'Testovací licence'+mName+'vyprší: ' + DateToStr(mDate) + ', to je za ' + IntToStr(mCountDay) + ' dní.';
      Exit;
    end;
    //po vypršení testovací budu upozorňovat
    if (mDate < (Date + 1)) and (mDate > 0) then begin
      if mVisual then
        ShowMessage('Testovací licence'+mName+'vypršela: ' + DateToStr(mDate))
      else
        LogInfoStr := 'Testovací licence'+mName+'vypršela: ' + DateToStr(mDate);
      Result := false;
      Exit;
    end;
    if not Result then begin
      if mVisual then
        ShowMessage( Format(lng_msg_LicenceError,[mName]) )
      else
        LogInfoStr := Format(lng_msg_LicenceError,[mName]);
      Exit;
    end;
  end else begin
    Result := true;
  end;
end;

function GetValueLicence(): integer;
var
  mS: string;
begin
  Result := 0;
  if TestLicence(cIsNotVisual, mS) then
    Result := CFxCustomLicence.GetValue(cLicGuid);
end;

begin
end.