procedure InsertRow(Sender : TButton);
var
  mSite: TSiteForm;
  mControl: TControl;
  mDataset: TNxRowsObjectDataSet;
  mRow: TNxCustomBusinessObject;
  mGRows : TMultiGrid;
begin
  try
    mSite := TComponent(Sender).Site;
    mControl:= mSite.FindChildControl('tabRows.grdRows');
    mGRows:=TMultiGrid(mControl);
    mDataset := TNxRowsObjectDataSet(TMultiGrid(mControl).DataSource.DataSet);
    if Assigned(mDataset) then
    begin
      mDataSet.DisableControls;
      mRow := mDataSet.CreateBusinessObject;
      mRow.Prefill;
      mRow.SetFieldValueAsInteger('RowType',3);
      mRow.SetFieldValueAsString('Store_Id','2100000101');
      mRow.SetFieldValueAsString('Division_ID','2100000101');
      mRow.SetFieldValueAsString('Storecard_Id','2100000101');
      mRow.SetFieldValueAsFloat('Quantity', 1);
    end;
  finally
    TDynSiteForm(mSite).ActiveDataSet.UpdateFields; //Aby se o změně dozvěděl hlavičkový dataset
    mDataset.RefreshAndRestoreLastSelectedItem;
    mDataSet.EnableControls;
  end;
end;

{
Vyvolává se po vytvoření instance formuláře.
}
procedure FormCreate_Hook(Self: TSiteForm);
var
  mAction: TBasicAction;
  mMAction: TMultiAction;
begin
  // Vytorime novou jednoduchou akci
  mAction := Self.GetNewAction;
  mAction.ShowControl := True;
  mAction.ShowMenuItem := True;
  mAction.Caption := 'Přidání řádku';
  mAction.Hint := 'Přidání řádku a aktualizace datasetu';
  mAction.Category := 'tabDetail';
  mAction.OnExecute := @InsertRow;
end;

begin
end.