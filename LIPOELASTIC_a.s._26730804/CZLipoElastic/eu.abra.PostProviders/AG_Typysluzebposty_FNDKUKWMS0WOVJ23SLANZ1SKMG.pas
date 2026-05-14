uses
  'eu.abra.PostProviders.uConst',
  'eu.abra.PostProviders.uXML',
  'eu.abra.PostProviders.uBalikobotFunc';

{
Vyvolává se po provedení inicializace agendy/formuláře. V tento okamžik je již na formuláři dostupný SiteContext.
}
procedure InitSite_Hook(Self: TSiteForm);
begin
  if cDebug then
    ExInitSiteImport_Hook(Self, cOnlyShowXML);
    AddActionSyncBranches(Self);
end;

begin
end.
