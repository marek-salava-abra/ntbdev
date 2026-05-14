uses
  'eu.abra.PostProviders.uConst',
  'eu.abra.PostProviders.uXML',
  'eu.abra.PostProviders.uBalikobotFunc';

procedure InitSite_Hook(Self: TSiteForm);
begin
  AddActionSyncManupulationUnits(Self);
end;


begin
end.