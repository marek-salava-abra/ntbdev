procedure InitSite_Hook(Self: TSiteForm);
var
  mAction: TBasicAction;
  mMAction: TMultiAction;
begin
  mAction := Self.GetNewAction;
  mAction.ShowControl := True;
  mAction.ShowMenuItem := True;
  mAction.Caption := '###BATCH###';
  mAction.Hint := 'Šarže';
  mAction.Category := 'tabList';
  mAction.OnExecute := @Batch;
end;

Procedure Batch(sender:tcomponent);
var
 mSite:TSiteForm;
 mList:tstringlist;
 mBO, mStoreBatchBO, mStoreSubBatchBO:TNxCustomBusinessObject;
 mDRB:TNxCustomBusinessMonikerCollection;
 i:integer;
 mStoreBatch_ID, mStoreSubBatch_ID:string;
begin
 mSite:=TComponent(sender).dynsite;
 mList:=tstringlist.create;
 TDynSiteForm(mSite).list.GetSelectedId(mlist);
 for i:=0 to mlist.count-1 do begin
   try
   mBO:=msite.BaseObjectSpace.CreateObject(Class_RefundedBillOfDeliveryRow);
   mBO.Load(mlist.strings[i],nil);
   mDRB:=mbo.GetLoadedCollectionMonikerForFieldCode(mBO.GetFieldCode('DocRowBatches'));
   mStoreBatchBO:=mDRB.AddNewObject;
   mStoreBatchBO.SetFieldValueAsBoolean('NewBatch',false);
   mStoreBatch_ID:=msite.BaseObjectSpace.SQLSelectFirstAsString(format('Select id from storebatches where storecard_id=''%s'' and name=''%s'' and hidden=''N'' ',
       [mbo.GetFieldValueAsString('StoreCard_ID'),mBO.GetFieldValueAsString('X_BName')]));
   mSToreBAtchBO.SetFieldValueAsString('StoreBatch_ID',mStoreBatch_ID);
   mStoreBatchbo.SetFieldValueAsFloat('Quantity',mbo.GetFieldValueAsFloat('X_Quantity'));
   mbo.save;
   mStoreBatch_ID:=msite.BaseObjectSpace.SQLSelectFirstAsString(format('Select id from storesubbatches where storebatch_id=''%s'' and Store_ID=''%s'' ',[mStoreBatch_ID,mbo.GetFieldValueAsString('Store_ID')]));
   mStoreSubBatchBO:=mSite.BaseObjectSpace.CreateObject(Class_StoreSubBatch);
   mStoreSubBatchBO.Load(mStoreBatch_ID,nil);
   mStoreSubBatchBO.SetFieldValueAsFloat('Quantity',mbo.GetFieldValueAsFloat('X_Quantity'));
   mStoreSubBatchBO.save;
   mStoreSubBatchBO.free;
   except
   end;
 end;
end;

begin
end.