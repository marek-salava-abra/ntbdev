uses '.dataset';

function AddTabSheet(const AParent: TPageControl; const ACaption, AName: string): TTabSheet;
var
  BaseName, FinalName: string;
  N: Integer;
begin
  if AParent = nil then exit;

  Result := TTabSheet.Create(AParent);   // Owner = AParent (správa životnosti)
  Result.PageControl := AParent;
  Result.Caption := ACaption;

  // Name: použij zadaný, nebo vygeneruj
  BaseName := AName;
  if BaseName = '' then
    BaseName := Format('%s_Tab', [AParent.Name]);

  FinalName := BaseName;
  N := 1;

  // zajisti unikátnost Name v rámci Ownera (AParent)
  while AParent.FindComponent(FinalName) <> nil do
  begin
    Inc(N);
    FinalName := Format('%s_%d', [BaseName, N]);
  end;

  Result.Name := FinalName;
end;


function AddNestedPageControl(const ATab: TTabSheet; const AName: string): TPageControl;
begin
  if ATab = nil then exit;

  Result := TPageControl.Create(ATab);
  Result.Parent := ATab;
  Result.Align := alClient;
  Result.Name := AName;
end;


function AddTopPanel(const ATab: TTabSheet; const AName: string; AHeight: Integer = 30):TPanel;
begin
  if ATab = nil then exit;

  Result := TPanel.Create(ATab);
  Result.Parent := ATab;
  Result.Align := alTop;
  Result.Height := AHeight;
  Result.Name := AName;
  Result.Caption:= '';
end;

function AddFirmLabel(const APanel: TPanel; const AName: string): TLabel;
begin
  if APanel = nil then exit;

  Result := TLabel.Create(APanel);
  Result.Parent := APanel;
  Result.top := 5;
  Result.Left:= 5;
  //Result.Height := 40;
  Result.Name := AName;
  Result.Caption:= '';
  Result.Font.Style:= [fsBold];
end;



procedure AddTextCol(AGrid: TMultiGrid; const ACaption, AField, AName: string; AWidth, AOrder: Integer; AVisible: Boolean = True; AElastic: Boolean = False);
var
  Col: TNxMultiGridCustomColumn;
begin
  Col := TNxMultiGridCustomColumn.Create(AGrid);
  Col.Caption := ACaption;
  Col.FieldName := AField;
  Col.Name := AName;
  Col.Width := AWidth;
  Col.Order := AOrder;
  Col.Visible := AVisible;
  Col.Elastic := AElastic;
  Col.Kind:= ckUser;
  AGrid.AddColumn(Col);
end;

procedure AddFloatCol(AGrid: TMultiGrid; const ACaption, AField, AName: string; AWidth, AOrder: Integer; AVisible: Boolean = True; AElastic: Boolean = False);
var
  Col: TNxMultiGridColumn;
begin
  Col := TNxMultiGridColumn.Create(AGrid);
  Col.Caption := ACaption;
  Col.FieldName := AField;
  Col.Name := AName;
  Col.Width := AWidth;
  Col.Order := AOrder;
  //Col.Visible := AVisible;
  //Col.Elastic := AElastic;
  //Col.Kind:= ckUser;
  AGrid.AddColumn(Col);
end;



procedure AddBoolCol(AGrid: TMultiGrid; const ACaption, AField, AName: string; AWidth, AOrder: Integer);
var
  Col: TNxMultiGridBooleanColumn;
begin
  Col := TNxMultiGridBooleanColumn.Create(AGrid);
  Col.Caption := ACaption;
  Col.FieldName := AField;
  Col.Name := AName;
  Col.Width := AWidth;
  Col.Order := AOrder;
  AGrid.AddColumn(Col);
end;

procedure AddDateCol(AGrid: TMultiGrid; const ACaption, AField, AName: string; AWidth, AOrder: Integer; AElastic: Boolean = False);
var
  Col: TNxMultiGridDateColumn;
begin
  Col := TNxMultiGridDateColumn.Create(AGrid);
  Col.Caption := ACaption;
  Col.FieldName := AField;
  Col.Name := AName;
  Col.Width := AWidth;
  Col.Order := AOrder;
  Col.Elastic := AElastic;
  AGrid.AddColumn(Col);
end;





//______________________________________________________________________________

function EnsureTabSheet(AParent: TPageControl; const ACaption, AName: string): TTabSheet;
begin
  Result := nil;
  if AParent = nil then exit;

  Result := TTabSheet(AParent.FindComponent(AName));
  if Assigned(Result) then
  begin
    Result.Caption := ACaption;
    exit;
  end;

  Result := TTabSheet.Create(AParent);
  Result.PageControl := AParent;
  Result.Name := AName;
  Result.Caption := ACaption;
end;

function EnsurePanel(AOwner: TComponent; AParent: TWinControl; const AName: string; AAlign: TAlign; AHeight: Integer = 0): TPanel;
begin
  Result := nil;
  if (AOwner = nil) or (AParent = nil) then exit;

  Result := TPanel(AOwner.FindComponent(AName));
  if not Assigned(Result) then
  begin
    Result := TPanel.Create(AOwner);
    Result.Name := AName;
    Result.Parent := AParent;
    Result.Caption := '';
  end;

  Result.Align := AAlign;
  if (AAlign = alTop) and (AHeight > 0) then
    Result.Height := AHeight;
end;

function EnsureLabel(AOwner: TComponent; AParent: TWinControl; const AName: string): TLabel;
begin
  Result := nil;
  if (AOwner = nil) or (AParent = nil) then exit;

  Result := TLabel(AOwner.FindComponent(AName));
  if not Assigned(Result) then
  begin
    Result := TLabel.Create(AOwner);
    Result.Name := AName;
    Result.Parent := AParent;
    Result.Left := 5;
    Result.Top := 5;
    Result.Font.Style := [fsBold];
    Result.Caption := '';
  end;
end;

function EnsurePageControl(AOwner: TComponent; AParent: TWinControl; const AName: string): TPageControl;
begin
  Result := nil;
  if (AOwner = nil) or (AParent = nil) then exit;

  Result := TPageControl(AOwner.FindComponent(AName));
  if not Assigned(Result) then
  begin
    Result := TPageControl.Create(AOwner);
    Result.Name := AName;
    Result.Parent := AParent;
  end;

  Result.Align := alClient;
end;

function EnsureMemoryDataSet(AOwner: TComponent; const AName: string): TMemoryDataset;
begin
  Result := nil;
  if AOwner = nil then exit;

  Result := TMemoryDataset(AOwner.FindComponent(AName));
  if not Assigned(Result) then
  begin
    Result := TMemoryDataset.Create(AOwner);
    Result.Name := AName;
  end;
end;

function EnsureMultiGrid(AOwner: TComponent; AParent: TWinControl; const AName: string; ADataSet: TDataSet): TMultiGrid;
var
  DS: TDataSource;
begin
  Result := nil;
  if (AOwner = nil) or (AParent = nil) then exit;

  Result := TMultiGrid(AOwner.FindComponent(AName));
  if not Assigned(Result) then
  begin
    Result := TMultiGrid.Create(AOwner);
    Result.Name := AName;
    Result.Parent := AParent;
    Result.Align := alClient;
    Result.ReadOnly := True;
    Result.Options:= [goHeaders, goGap, goFixRowLines, goFixColLines, goRowLines, goColLines, goAllowEdit];

    DS := TDataSource.Create(Result);     // owner grid
    DS.DataSet := ADataSet;
    Result.DataSource := DS;

    Result.OnDblClick:= @My_OnDoubleClick;
    Result.OnGetBackgroundColor:= @My_OnGetBackgroudColor;
  end
  else
  begin
    // když grid existuje, jen přebinduj dataset, kdyby byl jiný
    if Assigned(Result.DataSource) then
      Result.DataSource.DataSet := ADataSet;
  end;
end;


procedure My_OnDoubleClick(Sender: TObject);
var
  mDataSet: TDataSet;
  mSelectedField : TField;
  mLabel: TLabel;
begin
  mDataSet := TMultiGrid(Sender).DataSource.DataSet;
  if (mDataSet = nil) or mDataSet.IsEmpty then Exit;

  mSelectedField := mDataSet.FieldByName('Selected');
  if mSelectedField = nil then Exit;

  mDataSet.Edit;
  mDataSet.FieldByName('Selected').ReadOnly:= false;


  mSelectedField.AsBoolean := not mSelectedField.AsBoolean;
  {
  if mSelectedField.AsBoolean then
  begin
    //mDataSet.FieldByName('PaidAmount').ReadOnly:= false;
    mDataSet.FieldByName('PaidAmount').AsFloat:= mDataSet.FieldByName('Amount').AsFloat;
  end else
  begin
    mDataSet.FieldByName('PaidAmount').AsFloat:= 0;
    //mDataSet.FieldByName('PaidAmount').ReadOnly:= True;
  end;
  }
  mDataSet.FieldByName('Selected').ReadOnly:= True;

  mDataSet.Post;

  TMultiGrid(Sender).Invalidate;

  //mLabel := TLabel(TMultiGrid(Sender).Owner.FindComponent('lblSummary'));
  //if mLabel <> nil then
    //UpdateSelectionSummary(mDataSet);
end;


procedure My_OnGetBackgroudColor(Sender : TObject; AColumn: TNxMultiGridCustomColumn; const AIndex: Integer; const AMultiSelect: Boolean; const
ASelectedActiveRow: Boolean; var ABckColor: TColor);
var
  mDataSet: TDataset;
begin
  if Sender is TMultiGrid then begin
    mDataSet := TMultiGrid(Sender).DataSource.DataSet;
    if mDataSet.RecordCount > 0 then begin
      if mDataSet.FieldByName('Selected').AsBoolean = True then
        ABckColor :=  StringToColor('#de4b9a');    //#fc2192    #a9e394
    end;
  end;
end;


procedure EnsureFilterControls(APanel: TPanel);
var
  Lbl, SortLbl: TLabel;
  mDateEditFrom, mDateEditTo: TDateTimeEdit;
  mSearchEdit: TEdit;
  Btn, SortBtn: TButton;
  SortCmb: TComboBox;
begin
  // Date from
  Lbl := TLabel(APanel.FindChildControl(APanel.Name + '_LblDateFrom'));
  if not Assigned(Lbl) then
  begin
    Lbl := TLabel.Create(APanel);
    Lbl.Parent := APanel;
    Lbl.Name := APanel.Name + '_LblDateFrom';
    Lbl.Left := 8;
    Lbl.Top := 16;
    Lbl.Caption := 'Date from';
  end;

  mDateEditFrom := TDateTimeEdit(APanel.FindChildControl(APanel.Name + '_DateFrom'));
  if not Assigned(mDateEditFrom) then
  begin
    mDateEditFrom := TDateTimeEdit.Create(APanel);
    mDateEditFrom.Parent := APanel;
    mDateEditFrom.Name := APanel.Name + '_DateFrom';
    mDateEditFrom.Left := 75;
    mDateEditFrom.Top := 12;
    mDateEditFrom.Width := 90;
    mDateEditFrom.DateTime := Date - 90;
  end;

  // Date to
  Lbl := TLabel(APanel.FindChildControl(APanel.Name + '_LblDateTo'));
  if not Assigned(Lbl) then
  begin
    Lbl := TLabel.Create(APanel);
    Lbl.Parent := APanel;
    Lbl.Name := APanel.Name + '_LblDateTo';
    Lbl.Left := 180;
    Lbl.Top := 16;
    Lbl.Caption := 'Date to';
  end;

  mDateEditTo := TDateTimeEdit(APanel.FindChildControl(APanel.Name + '_DateTo'));
  if not Assigned(mDateEditTo) then
  begin
    mDateEditTo := TDateTimeEdit.Create(APanel);
    mDateEditTo.Parent := APanel;
    mDateEditTo.Name := APanel.Name + '_DateTo';
    mDateEditTo.Left := 235;
    mDateEditTo.Top := 12;
    mDateEditTo.Width := 90;
    mDateEditTo.DateTime := Date;
  end;

  // Fulltext label
  Lbl := TLabel(APanel.FindChildControl(APanel.Name + '_LblSearchText'));
  if not Assigned(Lbl) then
  begin
    Lbl := TLabel.Create(APanel);
    Lbl.Parent := APanel;
    Lbl.Name := APanel.Name + '_LblSearchText';
    Lbl.Left := 340;
    Lbl.Top := 16;
    Lbl.Caption := 'Search';
  end;

  // Fulltext edit
  mSearchEdit := TEdit(APanel.FindChildControl(APanel.Name + '_Fulltext'));
  if not Assigned(mSearchEdit) then
  begin
    mSearchEdit := TEdit.Create(APanel);
    mSearchEdit.Parent := APanel;
    mSearchEdit.Name := APanel.Name + '_Fulltext';
    mSearchEdit.Left := 390;
    mSearchEdit.Top := 12;
    mSearchEdit.Width := 180;
    mSearchEdit.EditText:= '';
  end;

  // Filter button
  Btn := TButton(APanel.FindChildControl(APanel.Name + '_BtnFilter'));
  if not Assigned(Btn) then
  begin
    Btn := TButton.Create(APanel);
    Btn.Parent := APanel;
    Btn.Name := APanel.Name + '_BtnFilter';
    Btn.Left := 580;
    Btn.Top := 10;
    Btn.Width := 75;
    Btn.Caption := 'Filter';
    Btn.Default := True;
    Btn.OnClick := @FilterButtonClick;
  end;

  SortLbl := TLabel(APanel.FindChildControl(APanel.Name + '_SortLbl'));
  if not Assigned(SortLbl) then
  begin
    SortLbl := TLabel.Create(APanel);
    SortLbl.Parent := APanel;
    SortLbl.Name := APanel.Name + '_SortLbl';
    SortLbl.Caption := 'Sort:';
    SortLbl.Left := 800;
    SortLbl.Top := 16;
  end;

  SortCmb := TComboBox(APanel.FindChildControl(APanel.Name + '_SortField'));
  if not Assigned(SortCmb) then
  begin
    SortCmb := TComboBox.Create(APanel);
    SortCmb.Parent := APanel;
    SortCmb.Name := APanel.Name + '_SortField';
    SortCmb.Left := 850;
    SortCmb.Top := 12;
    SortCmb.Width := 170;
    SortCmb.OnChange := @SortFieldChange;
  end;

  SortBtn := TButton(APanel.FindChildControl(APanel.Name + '_SortDir'));
  if not Assigned(SortBtn) then
  begin
    SortBtn := TButton.Create(APanel);
    SortBtn.Parent := APanel;
    SortBtn.Name := APanel.Name + '_SortDir';
    SortBtn.Left := 1020;
    SortBtn.Top := 10;
    SortBtn.Width := 30;
    SortBtn.Caption := '↓';
    SortBtn.OnClick := @SortDirClick;
  end;
end;



procedure FillDateFilterParams(AFilterPanel: TPanel; AParams: TNxParameters);
var
  DtFrom, DtTo: TDateTimeEdit;
  SearchEdit: TEdit;
  S: string;
begin
  if not Assigned(AFilterPanel) then
    exit;

  DtFrom := TDateTimeEdit(AFilterPanel.FindChildControl(AFilterPanel.Name + '_DateFrom'));
  DtTo := TDateTimeEdit(AFilterPanel.FindChildControl(AFilterPanel.Name + '_DateTo'));
  SearchEdit := TEdit(AFilterPanel.FindChildControl(AFilterPanel.Name + '_Fulltext'));

  if Assigned(DtFrom) then
    AParams.GetOrCreateParam(dtDateTime, 'DateFrom').AsDateTime := Trunc(DtFrom.DateTime);

  if Assigned(DtTo) then
    AParams.GetOrCreateParam(dtDateTime, 'DateTo').AsDateTime := Trunc(DtTo.DateTime);

  if Assigned(SearchEdit) then
  begin
    S := UpperCase(Trim(SearchEdit.Text));
    if S <> '' then
      AParams.GetOrCreateParam(dtString, 'Fulltext').AsString := S;
  end;
end;


procedure SortFieldChange(Sender: TObject);
begin
  ApplySortForSender(Sender);
end;


procedure SortDirClick(Sender: TObject);
var
  Btn: TButton;
begin
  Btn := TButton(Sender);

  if Btn.Caption = '↓' then
    Btn.Caption := '↑'
  else
    Btn.Caption := '↓';

  ApplySortForSender(Sender);
end;

procedure ApplySortForSender(Sender: TObject);
var
  Ctrl: TControl;
  FilterPanel: TPanel;
  Tab: TTabSheet;
  DS: TMemoryDataset;
begin
  if not (Sender is TControl) then Exit;

  Ctrl := TControl(Sender);
  FilterPanel := TPanel(Ctrl.Parent);
  if not Assigned(FilterPanel) then Exit;

  Tab := TTabSheet(FilterPanel.Parent);
  if not Assigned(Tab) then Exit;

  DS := TMemoryDataset(Tab.FindComponent(Tab.Name + '_DS'));
  if not Assigned(DS) then Exit;

  ApplySortFromFilterPanel(FilterPanel, DS);
end;

procedure ApplySortFromFilterPanel(AFilterPanel: TPanel; ADS: TMemoryDataset);
var
  Cmb: TComboBox;
  Btn: TButton;
  FieldName: string;
  Desc: Boolean;
begin
  if not Assigned(AFilterPanel) then Exit;
  if not Assigned(ADS) then Exit;
  if not ADS.Active then Exit;

  Cmb := TComboBox(AFilterPanel.FindChildControl(AFilterPanel.Name + '_SortField'));
  Btn := TButton(AFilterPanel.FindChildControl(AFilterPanel.Name + '_SortDir'));

  if not Assigned(Cmb) then Exit;

  FieldName := Cmb.Items[Cmb.ItemIndex];
  if FieldName = '' then Exit;

  Desc := Assigned(Btn) and (Btn.Caption = '↓');

  ADS.DisableControls;
  try
    ADS.SortOnFields(FieldName, True, Desc);
    ADS.First;
  finally
    ADS.EnableControls;
  end;
end;





begin
end.