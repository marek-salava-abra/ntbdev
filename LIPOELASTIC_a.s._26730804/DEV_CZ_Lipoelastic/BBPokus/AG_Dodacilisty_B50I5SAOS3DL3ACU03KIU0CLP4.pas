uses 'eu.abra.PostProviders.uImportManager';

procedure InitSite_Hook(Self: TSiteForm);
var
  mAction: TBasicAction;
begin
  mAction := Self.GetNewAction;
  mAction.ShowControl := True;
  mAction.ShowMenuItem := True;
  mAction.Name := 'actBBMasa';
  mAction.Caption := '## BB ##';
  mAction.Category := 'tabList';
  mAction.OnExecute := @CreateNonVisualBB;
end;

Procedure CreateNonVisualBB(Sender:tcomponent);
var
 mSite:TSiteForm;
 mList, aLog:TStringList;
 mBO:TNxCustomBusinessObject;
begin
 mSite:=TComponent(sender).DynSite;
 mList:=TStringList.Create;
 mBO:=TDynSiteForm(mSite).CurrentObject;
 mList.Add(mBO.OID);
 aLog:=TStringList.Create;
 StartAutoCreatePackageNonVisual(msite.BaseObjectSpace,mlist, mBO, mBO.CLSID,'','',aLog);
 NxShowSimpleMessage(aLog.Text,mSite);
end;

begin
end.