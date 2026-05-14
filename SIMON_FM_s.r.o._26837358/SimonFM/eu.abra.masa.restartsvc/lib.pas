procedure Restart (OS: TNxCustomObjectSpace;
  var Success: Boolean; var LogInfoStr: String);
begin
  NxShellOpenFile('d:\abra_tools\abra.bat');
  Sleep(2000);
  NxShellOpenFile('d:\abra_tools\fb_sweep.bat');
  Success := True;
  LogInfoStr := '';
end;

begin
end.