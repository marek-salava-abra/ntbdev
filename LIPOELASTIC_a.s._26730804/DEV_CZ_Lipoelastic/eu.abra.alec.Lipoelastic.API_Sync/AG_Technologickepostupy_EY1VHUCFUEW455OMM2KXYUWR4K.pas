uses '.lib';
{
Vyvolává se po provedení inicializace agendy/formuláře. V tento okamžik je již na formuláři dostupný SiteContext.
}
procedure InitSite_Hook(Self: TSiteForm);
var
  mAction: TBasicAction;
begin
  mAction:= Self.GetNewAction;
  mAction.Name:= 'CreateObjectJSON';
  mAction.Caption:= '## Synchronizovat s SK ##';
  mAction.Category:= 'tabList';
  mAction.OnExecute:= @CreateObjectJSON;
end;

begin
end.