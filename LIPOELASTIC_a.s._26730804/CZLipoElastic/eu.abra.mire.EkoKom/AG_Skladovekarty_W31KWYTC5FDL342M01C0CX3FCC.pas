uses
  'eu.abra.mire.EkoKom.TabEkoKom',
  'eu.abra.mire.EkoKom.uLicence';

{
  Zobrazení záložky detail
}
procedure _PageChange_Hook(Self: TRollSiteForm);
var
  mControl: TControl;
  pgcDetail: TPageControl;
begin
  mControl := Self.FindChildControl('pgcDetail');
  if Assigned(mControl) and (mControl is TPageControl) then
  begin
    pgcDetail := TPageControl(mControl);
    if pgcDetail.Focused then
    begin
      RefreshContainers(TBusRollSiteForm(Self));
    end;
  end;
end;

{
  Zahájení editace
}
procedure _StartEdit_PostHook(Self: TBusRollSiteForm);
var
  mListBox: TListBox;
  mComponent: TComponent;
  s: string;
begin
  if not TestLicence(cIsNotVisual, s) then exit;
  mComponent:= Self.FindComponent('lbxComponents');
  if mComponent = nil then exit;

  mListBox:= TListBox(mComponent);

  SetEKOKOMEnabled(TWinControl(mListBox.Items.Objects(mListBox.Items.IndexOf('tabEKOKOM'))), True);
end;

{
  Ukončení editace
}
procedure _StopEdit_PostHook(Self: TBusRollSiteForm);
var
  mListBox: TListBox;
  mComponent: TComponent;
  s: string;
begin
  if not TestLicence(cIsNotVisual, s) then exit;
  OutputDebugString(' ********************************* _StopEdit_PostHook');
  mComponent:= Self.FindComponent('lbxComponents');
  if mComponent = nil then exit;

  mListBox:= TListBox(mComponent);

  try
    SetEKOKOMEnabled(TWinControl(mListBox.Items.Objects(mListBox.Items.IndexOf('tabEKOKOM'))), False);
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
procedure _AfterEditRec_Hook(Self: TRollSiteForm);
begin
  RefreshContainers(Self);
end;

procedure _AfterSave_PostHook(Self: TBusRollSiteForm);
var
  s: string;
begin
  if not TestLicence(cIsNotVisual, s) then exit;
  OutputDebugString(' ********************************* _AfterSave_PostHook');
  SaveEKOKOMRelations(Self, Self.CurrentObject.OID);
end;

{
  Vyvolá se po pohybu na hlavním datasetu ale jen v případě, že je zobrazena záložka EKOKOM.
}
procedure _MainDatasetAfterScroll_Hook(Self: TBusRollSiteForm);
var
  mTabSheet : TTabSheet;

begin
  if Self.CurrentObject <> nil then
  begin
    mTabSheet := TTabSheet(NxFindChildControl(Self.GetSiteAppForm, 'tabEKOKOM'));
    if Assigned(mTabSheet) then
    begin
      if mTabSheet.Showing then
      begin
        RefreshContainers(Self);
      end;
    end;
  end;
end;

{
Vyvolává se po provedení inicializace agendy/formuláře. V tento okamžik je již na formuláři dostupný SiteContext.
}
procedure InitSite_Hook(Self: TBusRollSiteForm);
var
  mControl: TControl;
  s: string;
begin
  if not TestLicence(cIsNotVisual, s) then exit;
  mControl:= Self.FindChildControl('pgcDetail');
  if mControl <> nil then
  begin
    AddEKOKOMTabSheet(TPageControl(mControl));
  end;
end;


begin
end.