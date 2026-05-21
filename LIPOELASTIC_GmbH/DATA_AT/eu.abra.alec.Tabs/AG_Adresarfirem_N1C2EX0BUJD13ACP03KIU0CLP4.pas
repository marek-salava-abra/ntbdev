uses '.IssuedInvoices', '.CreditNotes', '.OrdersIn', '.BankStatements';

{
Vyvolává se po provedení inicializace agendy/formuláře. V tento okamžik je již na formuláři dostupný SiteContext.
}
procedure InitSite_Hook(Self: TSiteForm);
var
  MainPC, SubPC: TPageControl;
  MainTab: TTabSheet;
  TopPanel: TPanel;
  FirmLabel: TLabel;
begin
  MainPC := TPageControl(Self.FindChildControl('pgcDataViews'));
  if not Assigned(MainPC) then exit;

  MainTab := EnsureTabSheet(MainPC, 'Overview', 'tsOverview');

  TopPanel := EnsurePanel(MainTab, MainTab, 'ovwTopPanel', alTop, 30);
  FirmLabel := EnsureLabel(TopPanel, TopPanel, 'ovwFirmLabel');

  SubPC := EnsurePageControl(MainTab, MainTab, 'pgcOverview');

  // sub tabs
  EnsureDocSubTab(SubPC, 'Invoices', 'Invoices', 'tsInvoices');
  EnsureDocSubTab(SubPC, 'CreditNotes', 'Credit notes', 'tsCreditNotes');
  EnsureDocSubTab(SubPC, 'OrdersIn', 'Orders - In', 'tsOrdersIn');
  EnsureDocSubTab(SubPC, 'BankStatements', 'Bank statements', 'tsBankStatements');
end;

procedure RefreshByKind(AOS: TNxCustomObjectSpace; const AKind: string; ADS: TMemoryDataset; AParams: TNxParameters);
begin
  if AKind = 'Invoices' then
    Refresh_Invoices(AOS, ADS, AParams)
  else if AKind = 'CreditNotes' then
    Refresh_CreditNotes(AOS, ADS, AParams)
  else if AKind = 'OrdersIn' then
    Refresh_OrdersIn(AOS, ADS, AParams)
  else if AKind = 'BankStatements' then
    Refresh_BankStatements(AOS, ADS, AParams);
end;

procedure RefreshOverview(ASite: TSiteForm);
var
  BO: TNxCustomBusinessObject;
  MainTab: TTabSheet;
  TopPanel, mFilterPanel: TPanel;
  FirmLabel: TLabel;
  SubPC, MainPC: TPageControl;
  ActiveTab: TTabSheet;
  DS: TMemoryDataset;
  Kind: string;
  mParams: TNxParameters;
begin
  BO := TBusRollSiteForm(ASite).CurrentObject;

  if not Assigned(BO) then exit;
  try
    MainPC:= TPageControl(ASite.FindChildControl('pgcDataViews'));
    if not Assigned(MainPC) then exit;
    MainPC.OnChange:= @pgcDataViewsChange;

    MainTab := TTabSheet(MainPC.FindComponent('tsOverview'));
    if not Assigned(MainTab) then exit;

    TopPanel := TPanel(MainTab.FindComponent('ovwTopPanel'));
    FirmLabel := TLabel(TopPanel.FindComponent('ovwFirmLabel'));

    if not Assigned(FirmLabel) then exit;

    FirmLabel.Caption := BO.DisplayName;

    SubPC := TPageControl(MainTab.FindComponent('pgcOverview'));
    if not Assigned(SubPC) then exit;
    SubPC.OnChange:= @pgcDataViewsChange;

    // refresh jen aktivní subtab = rychlé, bez zbytečných dotazů
    ActiveTab := SubPC.ActivePage;
    if not Assigned(ActiveTab) then exit;

    DS := TMemoryDataset(ActiveTab.FindComponent(ActiveTab.Name + '_DS'));
    if not Assigned(DS) then exit;

    // Kind si můžeš určit mapou podle názvu tabu
    if ActiveTab.Name = 'tsInvoices' then Kind := 'Invoices'
    else if ActiveTab.Name = 'tsCreditNotes' then Kind := 'CreditNotes'
    else if ActiveTab.Name = 'tsOrdersIn' then Kind := 'OrdersIn'
    else if ActiveTab.Name = 'tsBankStatements' then Kind := 'BankStatements'
    else exit;

    mFilterPanel := TPanel(ActiveTab.FindComponent(ActiveTab.Name + '_Filter'));

    mParams := TNxParameters.Create;
    try
      mParams.GetOrCreateParam(dtString, 'FirmID').AsString := BO.OID;
      FillDateFilterParams(mFilterPanel, mParams);

      RefreshByKind(ASite.BaseObjectSpace, Kind, DS, mParams);
    finally
      mParams.Free;
    end;

    //RefreshByKind(ASite.BaseObjectSpace, Kind, DS, BO.OID);
  finally
    BO.Free;
  end;
end;


{
Vyvolá se po pohybu na hlavním datasetu.
}
procedure _MainDatasetAfterScroll_Hook(Self: TBusRollSiteForm);
begin
  RefreshOverview(TSiteForm(Self));
end;

procedure pgcDataViewsChange(Sender: TPageControl);
begin
  RefreshOverview(NxFindSiteForm(Sender));
end;

procedure FilterButtonClick(Sender: TObject);
begin
  RefreshOverview(NxFindSiteForm(TControl(Sender)));
end;


procedure ApplyLayoutByKind(const AKind: string; AGrid: TMultiGrid);
begin
  // pokud tvá verze umí mazat sloupce, udělej to, jinak si hlídej, že layout stavíš jen jednou
  // AGrid.Columns.Clear;

  if AKind = 'Invoices' then
    BuildLayout_Invoices(AGrid)
  else if AKind = 'CreditNotes' then
    BuildLayout_CreditNotes(AGrid)
  else if AKind = 'OrdersIn' then
    BuildLayout_OrdersIn(AGrid)
  else if AKind = 'BankStatements' then
    BuildLayout_BankStatements(AGrid);
end;


procedure PrepareDataSetByKind(const AKind: string; ADS: TMemoryDataset; var ALog: string);
begin
  if AKind = 'Invoices' then
    PrepareDataSet_Invoices(ADS, ALog)
  else if AKind = 'CreditNotes' then
    PrepareDataSet_CreditNotes(ADS, ALog)
  else if AKind = 'OrdersIn' then
    PrepareDataSet_OrdersIn(ADS, ALog)
  else if AKind = 'BankStatements' then
    PrepareDataSet_BankStatements(ADS, ALog);
end;


procedure FillSortComboByKind(const AKind: string; AFilterPanel: TPanel);
var
  Cmb: TComboBox;
begin
  Cmb := TComboBox(AFilterPanel.FindComponent(AFilterPanel.Name + '_SortField'));
  if not Assigned(Cmb) then Exit;

  if Cmb.Items.Count > 0 then Exit;

  if AKind = 'Invoices' then
    FillSortCombo_Invoices(Cmb)
  else if AKind = 'CreditNotes' then
    FillSortCombo_CreditNotes(Cmb)
  else if AKind = 'OrdersIn' then
    FillSortCombo_OrdersIn(Cmb)
  else if AKind = 'BankStatements' then
    FillSortCombo_BankStatements(Cmb);

end;


procedure EnsureDocSubTab(ASubPage: TPageControl; const AKind, ACaption, ATabName: string);
var
  Tab: TTabSheet;
  FilterPanel, GridHost: TPanel;
  DS: TMemoryDataset;
  Grid: TMultiGrid;
  Log: string;
begin
  Log := '';

  Tab := EnsureTabSheet(ASubPage, ACaption, ATabName);

  // filter top
  FilterPanel := EnsurePanel(Tab, Tab, ATabName + '_Filter', alTop, 100);
  EnsureFilterControls(FilterPanel);
  FillSortComboByKind(AKind, FilterPanel);

  // grid host client
  GridHost := EnsurePanel(Tab, Tab, ATabName + '_GridHost', alClient);

  // dataset owned by tab
  DS := EnsureMemoryDataSet(Tab, ATabName + '_DS');
  if DS.FieldCount = 0 then
    PrepareDataSetByKind(AKind, DS, Log);

  Grid := EnsureMultiGrid(Tab, GridHost, ATabName + '_Grid', DS);

  // layout stav jen při prvním vytvoření (nebo po Columns.Clear)
  if Grid.ColumnCount = 0 then
    ApplyLayoutByKind(AKind, Grid);
end;




begin
end.