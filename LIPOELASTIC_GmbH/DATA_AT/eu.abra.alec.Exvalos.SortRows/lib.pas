{
Vyvolává se po provedení inicializace agendy/formuláře. V tento okamžik je již na formuláři dostupný SiteContext.
}
procedure InitSite_Hook(Self: TSiteForm);
var
  mAction: TBasicAction;
begin
  mAction := Self.GetNewAction;
  mAction.Name:= 'actSortRows';
  mAction.ShowControl := True;
  mAction.ShowMenuItem := True;
  mAction.Caption := '## Sort rows ##';
  mAction.Hint := 'Function to sort rows by code, name or EAN';
  mAction.Category := 'tabDetail';
  mAction.OnExecute := @SortDocumentRows_OnExecute;
  mAction.OnUpdate := @SortDocumentRows_OnUpdate;
end;

procedure SortDocumentRows_OnUpdate(Sender: TControl);
var
  mSite: TSiteForm;
begin
  mSite := NxFindSiteForm(Sender);
  if Assigned(mSite) then begin
    if mSite is TDynSiteForm then begin
      TBasicAction(Sender).Enabled := TDynSiteForm(mSite).Edit;
    end;
  end;
end;


procedure SortDocumentRows_OnExecute(Sender: TComponent);
var
  mDynSiteForm: TDynSiteForm;
  mForm: TForm;
  mRowsControl: TControl;
  mRowsDataSource: TDataSource;
  mRows: TNxCustomBusinessMonikerCollection;
  mBO, mRow: TNxCustomBusinessObject;
  i, mOption: Integer;
  mCodeIDList: TStringList;
  mTempString, mSearchValue: string;
begin
  mDynSiteForm := TDynSiteForm(Sender.Site);
  if not Assigned(mDynSiteForm) then exit;

  // přístup k datasetu řádků - aby se nakonec dal udělat jejich Refresh
  mForm := NxGetSiteAppForm(mDynSiteForm);
  mRowsControl := NxFindChildControl(mForm, 'grdRows');
  mRowsDataSource := TMultiGrid(mRowsControl).DataSource;

  mCodeIDList:= TStringList.Create;
  mBO:= mDynSiteForm.CurrentObject;
  try
    GetDataFromForm(mDynSiteForm, mOption);
    if mOption = -1 then exit;

    mRows:= mBO.GetLoadedCollectionMonikerForFieldCode(mBO.GetFieldCode('Rows'));
    for i:= 0 to mRows.Count -1 do
    begin
      mRow:= mRows.BusinessObject[i];
      mTempString:= GetSortKey(mRow, mOption);
      mCodeIDList.Add(mTempString+'='+mRow.OID);
    end;

    //sortuje lexiko-graficky
    mCodeIDList.Sort;

    for i:= 0 to mRows.Count -1 do
    begin
      mRow:= mRows.BusinessObject[i];
      mTempString:= GetSortKey(mRow, mOption);
      mRow.SetFieldValueAsInteger('PosIndex', mCodeIDList.IndexOf(mTempString+'='+mRow.OID) + 1);
    end;

    // refresh GUI
    mRowsDataSource.DataSet.Refresh;
  finally
    mBO.Free;
    mCodeIDList.Free;
  end;
end;


function GetSortKey(ARow: TNxCustomBusinessObject; AOption: Integer): string;
var
  mPrefix: string;
begin
  mPrefix:= '';
  if ARow.CLSID = Class_PickingListRow then
    mPrefix:= 'ProvideRow_ID.';

  case AOption of
    0:
      if NxIsEmptyOID(ARow.GetFieldValueAsString(mPrefix+'StoreCard_ID')) then
        Result := UpperCase(ARow.GetFieldValueAsString(mPrefix+'Text'))
      else
        Result := UpperCase(ARow.GetFieldValueAsString(mPrefix+'StoreCard_ID.Code'));
    1:
      if NxIsEmptyOID(ARow.GetFieldValueAsString(mPrefix+'StoreCard_ID')) then
        Result := UpperCase(ARow.GetFieldValueAsString(mPrefix+'Text'))
      else
        Result := UpperCase(ARow.GetFieldValueAsString(mPrefix+'StoreCard_ID.Name'));
    2:
      Result := UpperCase(ARow.GetFieldValueAsString(mPrefix+'StoreCard_ID.EAN'));
    3:
      Result := UpperCase(ARow.GetFieldValueAsString(mPrefix+'StoreCard_ID.Specification'));
  else
    Result := '';
  end;
end;



procedure GetDataFromForm(ASite: TDynSiteForm; var AOption: integer);
var
  mForm: TForm;
  ComboBox: TComboBox;
  BtnOK, BtnCancel: TButton;
begin
  mForm := TForm.Create(ASite);
  try
    mForm.Caption := 'Choose sorting:';
    mForm.Width := 300;
    mForm.Height := 150;
    mForm.Position := poScreenCenter;

    ComboBox := TComboBox.Create(mForm);
    ComboBox.Parent := mForm;
    ComboBox.Items.Add('Code');
    ComboBox.Items.Add('Name');
    ComboBox.Items.Add('EAN');
    ComboBox.Items.Add('Specification');
    ComboBox.ItemIndex := 0;
    ComboBox.Left := 20;
    ComboBox.Top := 20;
    ComboBox.Width := 250;

    BtnOK := TButton.Create(mForm);
    BtnOK.Parent := mForm;
    BtnOK.Caption := 'OK';
    BtnOK.ModalResult := mrOk;
    BtnOK.Left := 60;
    BtnOK.Top := 70;
    BtnOK.Width := 75;

    BtnCancel := TButton.Create(mForm);
    BtnCancel.Parent := mForm;
    BtnCancel.Caption := 'Cancel';
    BtnCancel.ModalResult := mrCancel;
    BtnCancel.Left := 150;
    BtnCancel.Top := 70;
    BtnCancel.Width := 75;

    if mForm.ShowModal(ASite) = mrOk then
    AOption := ComboBox.ItemIndex
    else
    AOption := -1;
  finally
    mForm.Free;
  end;
end;


begin
end.