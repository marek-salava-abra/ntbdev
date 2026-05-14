const
  cLicGuid = '{D6AA8ADF-4EC6-42DA-845B-0090A41AB813}';
  cIsVisual = true;
  cIsNotVisual = false;

function TestLicence(const mVisual:boolean; var LogInfoStr: string): boolean;
var
  mDate : TDateTime;
  mCountDay : integer;
begin
 // LogInfoStr := '';
 { if CFxNxRuntime.NxCheckRequiredMinimumABRAVersion(13, 1, 9) then begin
    Result := true;
    mDate := CFxCustomLicence.GetDate(cLicGuid);
    if Result and (mDate = 0) then Exit; // neomezená licence
    //20 dnu před vypršením testovací budu upozorňovat
    if Result and ((mDate >= Date) and (mDate < (Date + 20))) then begin
      mCountDay := Round(mDate-Date);
      if mVisual then
        ShowMessage('Testovací licence vyprší: ' + DateToStr(mDate) + ', to je za ' + IntToStr(mCountDay) + ' dní.')
      else
        LogInfoStr := 'Testovací licence vyprší: ' + DateToStr(mDate) + ', to je za ' + IntToStr(mCountDay) + ' dní.';
      Exit;
    end;
    //po vypršení testovací budu upozorňovat
    if (mDate < (Date + 1)) and (mDate > 0) then begin
      if mVisual then
        ShowMessage('Testovací licence vypršela: ' + DateToStr(mDate))
      else
        LogInfoStr := 'Testovací licence vypršela: ' + DateToStr(mDate);
      Result := true;
      Exit;
    end;
    if not Result then begin
      if mVisual then
        ShowMessage('Nebyl nalezen licenční klíč nebo je neplatný')
      else
        LogInfoStr := 'Nebyl nalezen licenční klíč nebo je neplatný';
      Exit;
    end;
  end else begin   }
    Result := true;
 // end;
end;


begin
end.