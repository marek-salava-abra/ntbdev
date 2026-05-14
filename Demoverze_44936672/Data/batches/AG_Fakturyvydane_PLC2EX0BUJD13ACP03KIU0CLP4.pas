procedure _AfterNewRec_Hook(Self: TDynSiteForm);
var
mRows, mDocRowBatches:TNxCustomBusinessMonikerCollection;
mBO, mBillOfDeliveryRow:TNxCustomBusinessObject;
mControl, mControlDRB: TControl;
mDataset, mDataSetDRB: TNxRowsObjectDataSet;
mDocRowBatch: TNxCustomBusinessObject;
mStoreBatch_ID:String;
mOS:TNxCustomObjectSpace;
mQuantity, mExpDays:Extended;
begin
  mBO:=TDynSiteForm(Self).CurrentObject;
  if Assigned(mBO) then begin
    mOS:=mBO.ObjectSpace;
    mRows:=mBO.GetLoadedCollectionMonikerForFieldCode(mBO.GetFieldCode('Rows'));
    if mRows.Count>0 then begin
      mControl:= TDynSiteForm(Self).FindChildControl('tabRows.grdRows');
      mDataset := TNxRowsObjectDataSet(TMultiGrid(mControl).DataSource.DataSet);
      mDataSet.DisableControls;
      TDataSet(mDataset).First;
      while not(TDataSet(mDataset).Eof) do begin
        if (mDataset.CurrentObject.GetFieldValueAsInteger('StoreCard_ID.Category')=2) then begin
               mQuantity:=mDataset.CurrentObject.GetFieldValueAsFloat('Quantity');
               mStoreBatch_ID:=mOS.SQLSelectFirstAsString('Select sb.id from storebatches sb left join storesubbatches ssb on sb.id=ssb.storebatch_id '+
                                                          ' where sb.storecard_id='+QuotedStr(mDataset.CurrentObject.GetFieldValueAsString('StoreCard_ID'))+
                                                          ' and ssb.store_id='+QuotedStr(mDataset.CurrentObject.GetFieldValueAsString('Store_ID'))+
                                                          ' and ssb.quantity>='+NxFloatToIBStr(mQuantity)+
                                                          ' order by sb.ExpirationDate$Date','');
               if not(NxIsEmptyOID(mStoreBatch_ID)) then begin
                mControlDRB:= TDynSiteForm(Self).FindChildControl('tabDocRowBatch.grdDocRowBatch');
                mDatasetDRB := TNxRowsObjectDataSet(TMultiGrid(mControlDRB).DataSource.DataSet);
                mDataSetDRB.DisableControls;
                mDocRowBatch:=mDataSetDRB.CreateBusinessObject;
                mDocRowBatch.SetFieldValueAsBoolean('NewBatch',false);
                mDocRowBatch.SetFieldValueAsString('StoreBatch_ID',mStoreBatch_ID);
                mDocRowBatch.SetFieldValueAsFloat('Quantity',mQuantity);
                mDataSetDRB.EnableControls;
               end;
        end;
        TDataSet(mDataset).Next;
      end;
      TDynSiteForm(Self).ActiveDataSet.UpdateFields; //Aby se o změně dozvěděl hlavičkový dataset
      mDataset.RefreshAndRestoreLastSelectedItem;
      mDataSet.EnableControls;
    end;
  end;
end;


begin
end.