procedure InitSite_Hook(Self: TSiteForm);
var
  lmAction: TBasicAction;
begin
  lmAction := Self.GetNewAction;
  lmAction.ShowControl := True;
  lmAction.ShowMenuItem := True;
  lmAction.Caption := 'Stažení dokladů';
  lmAction.Hint := 'Stáhne data z DigiToo';
  lmAction.Category := 'tabList, tabDetail';
  lmAction.Name := 'actDownloadFromDigiToo';
  lmAction.OnExecute := @DownloadFromDigiToo_Click;

  lmAction := Self.GetNewAction;
  lmAction.ShowControl := True;
  lmAction.ShowMenuItem := True;
  lmAction.Caption := 'Otevření v Digitoo';
  lmAction.Hint := 'Otevře doklad v DigiToo';
  lmAction.Category := 'tabList, tabDetail';
  lmAction.Name := 'actOpenInDigiToo';
  lmAction.OnExecute := @OpenInDigiToo_Click;
end;

procedure DownloadFromDigiToo_Click(Sender : TBasicAction);
begin
  CFxScriptingEngine.CallScript('Tanaka.DigiToo.Main.RunTask',[Sender.Site,'DownloadDocs',0,0]);
end;

procedure OpenInDigiToo_Click(Sender : TBasicAction);
begin
  CFxScriptingEngine.CallScript('Tanaka.DigiToo.Main.OpenInDigitoo',[Sender.Site]);
end;

begin
end.