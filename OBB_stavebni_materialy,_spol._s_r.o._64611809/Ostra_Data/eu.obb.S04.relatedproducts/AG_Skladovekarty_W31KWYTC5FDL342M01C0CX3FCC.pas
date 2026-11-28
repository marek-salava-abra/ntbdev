uses
  'eu.obb.S04.relatedproducts.TabRP';

{
  Zahájení editace

procedure _StartEdit_PostHook(Self: TBusRollSiteForm);
var
  mListBox: TListBox;
  mComponent: TComponent;
  s: string;
begin
  mComponent:= Self.FindComponent('lbxComponents');
  if mComponent = nil then exit;

  mListBox:= TListBox(mComponent);

  SetNahradyEnabled(TWinControl(mListBox.Items.Objects(mListBox.Items.IndexOf('tabRP'))), True);
end;  }

{
  Ukončení editace

procedure _StopEdit_PostHook(Self: TBusRollSiteForm);
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
    SetNahradyEnabled(TWinControl(mListBox.Items.Objects(mListBox.Items.IndexOf('tabRP'))), False);
  except
  end;

  try
    OutputDebugString('Refresh tab');

    if Self.CurrentObject <> nil then
      RefreshContainers(Self);

    OutputDebugString('Refresh tab done');
  except
  end;
end;  }

{
  Uložení objektu

procedure _AfterSave_PostHook(Self: TBusRollSiteForm);
var
  s: string;
begin
  OutputDebugString(' ********************************* _AfterSave_PostHook');
  SaveNahradyRelations(Self, Self.CurrentObject.OID, self.CurrentObject);
end;}

{
  Vyvolá se po pohybu na hlavním datasetu.

procedure _MainDatasetAfterScroll_Hook(Self: TBusRollSiteForm);
begin
  if Self.CurrentObject <> nil then
    RefreshContainers(Self);
end; }

{
Vyvolává se po provedení inicializace agendy/formuláře. V tento okamžik je již na formuláři dostupný SiteContext.

procedure InitSite_Hook(Self: TBusRollSiteForm);
var
  mControl: TControl;
  s: string;
begin
  mControl:= Self.FindChildControl('pgcDetail');
  if mControl <> nil then
  begin
    AddNahradyTabSheet(TPageControl(mControl));
  end;
end;  }




begin
end.