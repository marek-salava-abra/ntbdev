uses
  'eu.abra.PostProviders.uForm',
  'eu.abra.PostProviders.uCustomScript',
  'eu.abra.PostProviders.uImportPackages';

var
  fFirstEnter: Boolean;

{
Vyvolává se po provedení inicializace agendy/formuláře. V tento okamžik je již na formuláři dostupný SiteContext.
}
procedure InitSite_Hook(Self: TSiteForm);
var
  mControl: TControl;
  mMainPanel: TPanel;
  pgcMain: TPageControl;
  i: Integer;
  mActionList: TActionList;
  mSiteII: TSiteForm;
begin
  mActionList := Self.GetMainActionList;
  for i := 0 to mActionList.ActionCount- 1 do
    mActionList.Actions[i].Category := 'DISABLE';

  mControl := Self.FindChildControl('pnFunc');
  if Assigned(mControl) then begin
    mControl.Visible := false;
    mControl.Enabled := false;
  end;

  fFirstEnter:= false;

  mControl := Self.FindChildControl('pgcDataViews');
  if Assigned(mControl) and (mControl is TPageControl) then begin
    pgcMain := TPageControl(mControl);
    pgcMain.Visible := False;

    mMainPanel := TPanel.Create(pgcMain.Owner);
    mMainPanel.Parent := pgcMain.Parent;
    mMainPanel.Name := 'pnNewDoc';
    mMainPanel.Align := alClient;
    mMainPanel.Caption := '';
    mMainPanel.BevelOuter := bvNone;
    mMainPanel.BevelInner := bvNone;
    CreateForm(Self, mMainPanel);
  end;
  PrefillHeaderDataSet(TDataSource(Self.FindComponent(cdsHeaderData)).DataSet, Self.BaseObjectSpace);
  SetHeaderEvents(TDataSource(Self.FindComponent(cdsHeaderData)).DataSet);


end;

{
Vyvolává se po provedení metody Show na dané agendě. Tato událost se volá i při přepínání agend.
}
procedure FormShow_Hook(Self: TSiteForm);
var
  mControl: TWinControl;
  mDataSet: TDataSet;
  mHeaderDataset: TMemoryDataset;
  mGrid: TMultiGrid;
begin
  if not fFirstEnter then begin
    mControl := TWinControl(Self.FindChildControl(cedPDMUser));
    if Assigned(mControl) then begin
      mControl.SetFocus;
    end;
    fFirstEnter:= true;
    mDataSet := TDataSource(Self.FindComponent(cdsPackagesData)).DataSet;
    if (mDataSet.RecordCount = 0) then
      GetData(Self);
    mHeaderDataset := TMemoryDataset(TDataSource(Self.FindComponent(cdsHeaderData)).DataSet);
    mGrid := TMultiGrid(Self.FindChildControl(cgrdPackagesData));
    CFxProfiler.EnterProc('postprovider', 'HideColumn');
    //HideColumn(mGrid, mHeaderDataSet.FieldByName(cFDPDMProviderDriver).AsInteger);
    CFxProfiler.ExitProc('postprovider', 'HideColumn');
    CFxProfiler.EnterProc('postprovider', 'RunScript');
    //Proč je to tady
    RunScript(Self.BaseObjectSpace, mDataSet, mHeaderDataSet, TMemoryDataset(IntToObj(mDataSet.Tag)), cScriptAfterGetData);
    CFxProfiler.ExitProc('postprovider', 'RunScript');
  end;
end;

procedure _InitParams_Hook(Self: TRollSiteForm; AParams: TNxParameters);
begin
  if Assigned(TRollSiteForm(Self).SiteParams) then
    GetData(Self);
end;

begin
end.