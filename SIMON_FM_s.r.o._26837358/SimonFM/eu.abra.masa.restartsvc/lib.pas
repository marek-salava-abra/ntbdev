procedure Restart (OS: TNxCustomObjectSpace; var Success: Boolean; var LogInfoStr: String);
var
  mCommand, mFile, mParams, mPath: string;
  mResult: Boolean;
begin
  NxShellOpenFile('d:\abra_tools\abra.bat');
  Sleep(2000);
  NxShellOpenFile('d:\abra_tools\fb_sweep.bat');
  Sleep(2000);
  mCommand := 'open';
  mFile := 'forfiles.exe';
  mParams := '/p "d:\wamp\www\kontrola_opes" /d -28 /c "cmd /c del @file"';
  mPath := '';
  mResult := ShellAPI.Execute(mCommand, mFile, mParams, mPath);
  Success := True;
  LogInfoStr := ''+NxCrLF+mParams;
end;

begin
end.



begin

end;