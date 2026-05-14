{
Vyvolá se po úspěšném zadání skladové karty na řádku dokladu uživatelem.
}
{procedure _AfterAddStoreCards_Hook(Self: TDynSiteForm);
var
  mBO, mRow, mPredBO: TNxCustomBusinessObject;
  i: Integer;
  mBusProject_ID, mDivision_ID, mPredvyplneni_ID:String;
  mControl: TControl;
  mDataset: TNxRowsObjectDataSet;
begin
  try
    if Assigned(Self.CurrentObject) then
      mBO := Self.CurrentObject;
  except
  end;

  if Assigned(mBO) then
  begin
    mControl:= Self.FindChildControl('tabRows.grdRows');
    mDataset := TNxRowsObjectDataSet(TMultiGrid(mControl).DataSource.DataSet);
    if Assigned(mDataset) then begin
           mDataSet.DisableControls;
           TDataSet(mDataset).First;
           while not TDataSet(mDataset).Eof do begin
            mRow:=mDataset.CurrentObject;
            if
              (osNew in mRow.State) and
              (mRow.GetFieldValueAsInteger('RowType') = 3) and
              (not NxIsEmptyOID(mRow.GetFieldValueAsString('StoreCard_ID')))
            then
            begin
              mPredvyplneni_ID:=mBO.ObjectSpace.SQLSelectFirstAsString('Select id from defrolldata where hidden=''N'' and clsid='+QuotedStr(Class_Predvyplnovani)+' and '+
                                                                       'X_Firm_ID='+QuotedStr(mbo.GetFieldValueAsString('Firm_ID'))+' and '+
                                                                       'X_Bustransaction_ID='+QuotedStr(mRow.GetFieldValueAsString('StoreCard_ID.X_Bustransaction_ID')),'');
              if not(NxIsEmptyOID(mPredvyplneni_ID)) then begin
                mPredBO:=mbo.ObjectSpace.CreateObject(Class_Predvyplnovani);
                mPredBO.load(mPredvyplneni_ID,nil);
                mRow.SetFieldValueAsString('BusProject_ID',mPredBO.GetFieldValueAsString('X_BusProject_ID'));
                mRow.SetFieldValueAsString('Division_ID',mPredBO.GetFieldValueAsString('X_BusProject_ID.Division_ID'));
                mPredBO.free;
              end else begin
                if not(NxIsEmptyOID(mRow.GetFieldValueAsString('Parent_ID.Firm_ID'))) then begin
                 mBusProject_ID:=mRow.GetFieldValueAsString('Parent_ID.Firm_ID.X_BusProject_ID');
                 if not(NxIsEmptyOID(mBusProject_ID)) then begin
                  mDivision_ID:=mRow.GetFieldValueAsString('Parent_ID.Firm_ID.X_BusProject_ID.Division_ID');
                 end;
                 if not(NxIsEmptyOID(mBusProject_ID)) then mRow.SetFieldValueAsString('BusProject_ID',mBusProject_ID);
                 if not(NxIsEmptyOID(mDivision_ID)) then mRow.SetFieldValueAsString('Division_ID',mDivision_ID);
                end;
              end;
            end;
            TDataSet(mDataset).Next;
           end;
           TDynSiteForm(self).ActiveDataSet.UpdateFields; //Aby se o změně dozvěděl hlavičkový dataset
           mDataset.RefreshAndRestoreLastSelectedItem;
           mDataSet.EnableControls;
    end;
  end;
end;    }


begin
end.