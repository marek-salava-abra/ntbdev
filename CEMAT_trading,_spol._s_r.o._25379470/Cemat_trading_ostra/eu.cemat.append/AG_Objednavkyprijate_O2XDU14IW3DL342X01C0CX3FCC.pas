procedure _InitSelf_PostHook(Self: TSiteForm);
var
  mODS: TNxObjectDataSet;
  mGrdRows: TMultiGrid;
begin
  mGrdRows := TMultiGrid(TWinControl(self.FindChildControl('tabRows')).FindChildControl('grdRows'));
  mODS := TNxObjectDataSet(mGrdRows.DataSource.DataSet);
  mODS.AfterPost := @MyAfterPost;
end;

procedure MyAfterPost(DataSet: TDataSet);
var
  mODS: TNxObjectDataSet;
  mStore, mStoreCard: string;
  mQuantity: Extended;
  mStoreCardBO:TNxCustomBusinessObject;
begin

    mODS := TNxObjectDataSet(DataSet);
    if not(nxisemptyoid(mODS.FieldByName('StoreCard_ID').AsString)) and (mODS.FieldByName('Division_ID').AsString='1500000101') then begin
      mStoreCardBO:=mODS.CurrentObject.ObjectSpace.CreateObject(Class_StoreCard);
      mStoreCardBO.Load(mODS.FieldByName('StoreCard_ID').AsString,nil);
      if not(NxIsEmptyOID(mStoreCardBO.GetFieldValueAsString('U_StoreCard_ID'))) then begin
        mStore:=mODS.FieldByName('Store_ID').AsString;
        mQuantity:=mODS.CurrentObject.GetFieldValueAsFloat('Quantity');
        mODS.AppendWithCarry;
        mODS.Edit;
        mODS.FieldByName('RowType').AsInteger := 3;
        mODS.FieldByName('Store_ID').AsString := mStore;
        mODS.FieldByName('StoreCard_ID').AsString :=mStoreCardBO.GetFieldValueAsString('U_StoreCard_ID');
        mODS.CurrentObject.SetFieldValueAsFloat('Quantity',mQuantity);
        mODS.Post;
      end;
    end;
end;

begin
end.
