uses
  'eu.abra.PostProviders.uBalikobotFunc';

{
Vyvolává se po provedení inicializace agendy/formuláře. V tento okamžik je již na formuláři dostupný SiteContext.
}
procedure InitSite_Hook(Self: TSiteForm);
begin
    AddActionSyncServices(Self);
end;

begin
end.