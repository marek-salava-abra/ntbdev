uses
  'Tanaka.DigiToo.Common';

procedure InitSite_Hook(Self: TSiteForm);
var
  lmAction: TBasicAction;
begin
  lmAction := Self.GetNewAction;
  lmAction.ShowControl := True;
  lmAction.ShowMenuItem := True;
  lmAction.Caption := 'Export číselníků';
  lmAction.Hint := 'Přenese data do DigiToo';
  lmAction.Category := 'tabList, tabDetail';
  lmAction.Name := 'actExportDigiToo';
  lmAction.OnExecute := @ExportDigiToo;

  lmAction := Self.GetNewAction;
  lmAction.ShowControl := True;
  lmAction.ShowMenuItem := True;
  lmAction.Caption := 'Stažení dokladů';
  lmAction.Hint := 'Stáhne data z DigiToo';
  lmAction.Category := 'tabList, tabDetail';
  lmAction.Name := 'actDownloadFromDigiToo';
  lmAction.OnExecute := @DownloadFromDigiToo;

  lmAction := Self.GetNewAction;
  lmAction.ShowControl := True;
  lmAction.ShowMenuItem := True;
  lmAction.Caption := 'Doimport příloh';
  lmAction.Hint := 'Doimportuje chybějící přílohy z DigiToo';
  lmAction.Category := 'tabList, tabDetail';
  lmAction.Name := 'actDownloadAttachmentsFromDigiToo';
  lmAction.OnExecute := @DownloadAttachmentsFromDigiToo;

  lmAction := Self.GetNewAction;
  lmAction.ShowControl := True;
  lmAction.ShowMenuItem := True;
  lmAction.Caption := 'Doimport časových razítek';
  lmAction.Hint := 'Doimportuje chybějící časová razítka z DigiToo';
  lmAction.Category := 'tabList, tabDetail';
  lmAction.Name := 'actDownloadTimestampsFromDigiToo';
  lmAction.OnExecute := @DownloadTimeStampsFromDigiToo;
end;

procedure DownloadTimeStampsFromDigiToo(Sender : TBasicAction);
begin
  CFxScriptingEngine.CallScript('Tanaka.DigiToo.DoimportCasovychRazitek.DoimportCasovychRazitek',[Sender.Site]);
end;

procedure DownloadAttachmentsFromDigiToo(Sender : TBasicAction);
begin
  CFxScriptingEngine.CallScript('Tanaka.DigiToo.DoimportPriloh.DoimportPriloh',[Sender.Site]);
end;

procedure DownloadFromDigiToo(Sender : TBasicAction);
begin
  CFxScriptingEngine.CallScript('Tanaka.DigiToo.Main.RunTask',[Sender.Site,'DownloadDocs',0,-1]);
end;

procedure ExportDigiToo(Sender : TBasicAction);
begin
  CFxScriptingEngine.CallScript('Tanaka.DigiToo.Main.RunTask',[Sender.Site,'MassExport',0,-1]);
end;

begin
end.