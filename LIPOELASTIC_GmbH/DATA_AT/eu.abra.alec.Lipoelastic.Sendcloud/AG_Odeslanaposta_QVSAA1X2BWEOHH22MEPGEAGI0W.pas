uses '.lib';
{
Vyvolává se po provedení inicializace agendy/formuláře. V tento okamžik je již na formuláři dostupný SiteContext.
}
procedure InitSite_Hook(Self: TSiteForm);
var
  mAction: TMultiAction;
begin
  mAction:= Self.GetNewMultiAction;
  mAction.Name:= 'actPostToSendcloud';
  mAction.Items.Add('## SendCloud - POST ##');
  //mAction.Items.Add('Show PDM Issued documents');
  mAction.Caption:= '## SendCloud - POST ##';
  mAction.Category:= 'tabList';
  mAction.OnExecuteItem:= @PostToSendcloud;
end;

procedure PostToSendcloud(Sender: TComponent);
var
  mSite: TSiteForm;
  mOS: TNxCustomObjectSpace;
  mSuccess: Boolean;
  mLog: string;
begin
  mSite:= Sender.Site;
  mOS:= mSite.BaseObjectSpace;

  mLog:= '';
  mSuccess:= True;

  SendPreparedPDMDocsToSendcloud(mOS, mSuccess, mLog);
end;

begin
end.