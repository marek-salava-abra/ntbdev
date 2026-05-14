uses
  'eu.simon.pujcovna.TabPujcovna';

{
  Zahájení editace
}
procedure _StartEdit_PostHook(Self: TDynSiteForm);
var
  mListBox: TListBox;
  mComponent: TComponent;
  s: string;
begin
  mComponent:= Self.FindComponent('lbxComponents');
  if mComponent = nil then exit;

  mListBox:= TListBox(mComponent);

  SetPujcovnaEnabled(TWinControl(mListBox.Items.Objects(mListBox.Items.IndexOf('tabPujcovna'))), True);
end;

{
  Ukončení editace
}
procedure _StopEdit_PostHook(Self: TDynSiteForm);
var
  mListBox: TListBox;
  mComponent: TComponent;
  s: string;
begin
  OutputDebugString(' ********************************* _StopEdit_PostHook');
  mComponent:= Self.FindComponent('lbxComponents');
  if mComponent = nil then exit;

  mListBox:= TListBox(mComponent);

  try
    SetPujcovnaEnabled(TWinControl(mListBox.Items.Objects(mListBox.Items.IndexOf('tabPujcovna'))), False);
  except
  end;

  try
    OutputDebugString('Refresh tab');

    if Self.CurrentObject <> nil then
      RefreshContainers(Self);

    OutputDebugString('Refresh tab done');
  except
  end;
end;

{
  Uložení objektu
}
procedure _AfterFilterChange_PreHook(Self: TDynSiteForm);
begin

end;

procedure _AfterSave_PostHook(Self: TDynSiteForm);
var
  s: string;
begin
  OutputDebugString(' ********************************* _AfterSave_PostHook');
  SavePujcovnaRelations(Self, Self.CurrentObject.OID, self.CurrentObject);
  //self.CurrentObject.Refresh;
  //PrintDocs(self.CurrentObject);
end;

{
  Vyvolá se po pohybu na hlavním datasetu.
}
procedure _LoadingProperties_PreHook(Self: TSiteForm; AParams: TNxParameters);
begin

end;

procedure _FormClose_PostHook(Self: TSiteForm);
begin

end;

procedure _MainDatasetAfterScroll_Hook(Self: TDynSiteForm);
begin
  if Self.CurrentObject <> nil then
    RefreshContainers(Self);
end;

{
Vyvolává se po provedení inicializace agendy/formuláře. V tento okamžik je již na formuláři dostupný SiteContext.
}
procedure InitSite_Hook(Self: TBusRollSiteForm);
var
  mControl: TControl;
  s: string;
begin
  mControl:= Self.FindChildControl('pgcDetail');
  if mControl <> nil then
  begin
    AddPujcovnaTabSheet(TPageControl(mControl));
  end;
end;




begin
end.