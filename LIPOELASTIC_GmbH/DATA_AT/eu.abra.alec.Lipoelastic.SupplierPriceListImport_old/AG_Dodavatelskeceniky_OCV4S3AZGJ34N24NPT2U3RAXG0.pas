uses '.form';

procedure InitSite_Hook(Self: TSiteForm);
var
  mAction: TMultiAction;
begin
  mAction := Self.GetNewMultiAction;
  mAction.ShowControl := True;
  mAction.ShowMenuItem := True;
  mAction.Caption := '## Import pricelist (XLSX) ##';
  mAction.Items.Add('Import pricelist (XLSX)');
  //mAction.Items.Add('EKO-KOM - Obaly');
  mAction.Category := 'tabList';
  mAction.OnExecute := @actShowForm;
end;

procedure actShowForm(Sender: TComponent);
Var
  mSite: TSiteForm;
begin
  mSite:= Sender.Site;
  ShowForm(mSite);
end;

begin
end.