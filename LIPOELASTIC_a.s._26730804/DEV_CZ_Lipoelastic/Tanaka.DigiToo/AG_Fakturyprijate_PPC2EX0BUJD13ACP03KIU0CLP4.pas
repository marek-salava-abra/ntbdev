{uses
  'Tanaka.DigiToo.Main';}

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
{//test párování FP na PR
var
  laList: TStringList;
begin
  laList:= TStringList.Create;
  try
    laList.Add('B0X1000101;EXT_CODE;EXT_NAME;10;ks;200;2000');
    laList.Add('6032000101;CODE;;20;pár;300;3000');
    PairPR(Sender.site.SiteContext.GetObjectSpace, laList, 'F0Z1000101', '1000000101', '0000EUR000', 'L000000101;1060000101', 10);
  finally
    laList.Free;
  end;}
begin
  CFxScriptingEngine.CallScript('Tanaka.DigiToo.Main.OpenInDigitoo',[Sender.Site]);
end;

begin
end.