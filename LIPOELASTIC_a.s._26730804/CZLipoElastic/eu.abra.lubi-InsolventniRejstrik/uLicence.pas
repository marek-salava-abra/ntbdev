const
  //U_Licence_ident z firemní G4
  cLicGuid = '{00A3D809-52C5-40B8-A716-C2F366170379}';
  cPackageName = 'Import dat z insolvenčního rejstříku'+#13#10;
  cIsVisual = true;
  cIsNotVisual = false;

function TestLicence(const mVisual:boolean; var LogInfoStr: string): boolean;
var
  mDate : TDateTime;
  mCountDay : integer;
  mName: string;
begin
  mName := Format(' pro doplněk %s ', [cPackageName]);
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
        ShowMessage('Nebyl nalezen licenční klíč'+mName+'nebo je neplatný')
      else
        LogInfoStr := 'Nebyl nalezen licenční klíč'+mName+'nebo je neplatný';
      Exit;
    end;
  end else begin
    Result := true;
  end;
end;

begin
end.