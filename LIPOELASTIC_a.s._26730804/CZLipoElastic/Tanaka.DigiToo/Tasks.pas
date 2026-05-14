procedure DownloadDocs_Task (OS: TNxCustomObjectSpace;var Success: Boolean; var LogInfoStr: String);
var
  logs: TStringList;
begin
  Success:=True;
  LogInfoStr:='';
  logs:=TStringList.Create;
  try
    Success:=CFxScriptingEngine.CallScript('Tanaka.DigiToo.Main.DownloadDocs',[OS,logs]);
  finally
    LogInfoStr:=trim(logs.Text);
    logs.Free;
  end;
end;

procedure MassExport_Task (OS: TNxCustomObjectSpace;var Success: Boolean; var LogInfoStr: String);
var
  logs: TStringList;
begin
  Success:=True;
  LogInfoStr:='';
  logs:=TStringList.Create;
  try
    Success:=CFxScriptingEngine.CallScript('Tanaka.DigiToo.Main.MassExport',[OS,logs]);
  finally
    LogInfoStr:=trim(logs.Text);
    logs.Free;
  end;
end;

begin
end.