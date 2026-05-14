procedure InitSite_Hook(Self: TSiteForm);
var
  mMAction: TMultiAction;

  i: integer;
  mUser : TNxCustomBusinessObject;
begin
  if not Assigned(Self.BaseObjectSpace) then
    exit;


  mMAction := Self.GetNewMultiAction;
  mMAction.ShowControl := True;
  mMAction.ShowMenuItem := True;
  mMAction.Hint := 'Vytvoř z nedodaných';
  mMAction.Caption := 'Vytvoř z nedodaných';
  mMAction.Items.Add('Vytvoř z nedodaných');
  mMAction.Category := 'tabList';
  mMAction.OnExecuteItem := @CreateNew;

end;

Procedure CreateNew(sender:TComponent);
var
 mSite:TSiteForm;
 mBO, mNewBO:TNxCustomBusinessObject;
 mRows, mNewRows:TNxCustomBusinessMonikerCollection;
 i,j: integer;
 mRowBO, mNewRowBO:TNxCustomBusinessObject;
begin
 mSite:=TComponent(sender).DynSite;
 mBO:=TDynSiteForm(mSite).CurrentObject;
 if assigned(mBO) then begin
   mNewBO:=msite.BaseObjectSpace.CreateObject(Class_IssuedOrder);
   mNewBO.new;
   mnewbo.prefill;
   mnewbo.SetFieldValueAsString('DocQueue_ID',mBO.GetFieldValueAsString('DocQueue_ID'));
   mnewbo.SetFieldValueAsString('Firm_ID',mBO.GetFieldValueAsString('Firm_ID'));
   mNewBO.SetFieldValueAsInteger('TradeType',mbo.GetFieldValueAsInteger('TradeType'));
   mNewBO.SetFieldValueAsString('Currency_ID',mbo.GetFieldValueAsString('Currency_ID'));
   mNewBo.SetFieldValueAsString('Country_ID',mbo.GetFieldValueAsString('Country_ID'));
   mNewBo.SetFieldValueAsString('Description',mbo.GetFieldValueAsString('Description'));
   mNewBO.SetFieldValueAsBoolean('WithPrices',mbo.GetFieldValueAsBoolean('WithPrices'));
   mNewBo.SetFieldValueAsString('IntrastatDeliveryTerm_ID',mBo.GetFieldValueAsString('IntrastatDeliveryTerm_ID'));
   mNewBo.SetFieldValueAsString('IntrastatTransactionType_ID',mBo.GetFieldValueAsString('IntrastatTransactionType_ID'));
   mNewBo.SetFieldValueAsString('IntrastatTransportationType_ID',mBo.GetFieldValueAsString('IntrastatTransportationType_ID'));
   mRows:=mbo.GetLoadedCollectionMonikerForFieldCode(mbo.GetFieldCode('Rows'));
   mNewRows:=mNewBO.GetLoadedCollectionMonikerForFieldCode(mNewBO.GetFieldCode('Rows'));
   for i:=0 to mRows.count-1 do begin
     mRowBO:=mRows.BusinessObject[i];
     if mrowbo.GetFieldValueAsFloat('DeliveredQuantity')<mRowBO.GetFieldValueAsFloat('Quantity') then begin
        mNewRowBO:=mNewRows.AddNewObject;
        mNewRowBO.prefill;
        mNewRowBO.SetFieldValueAsInteger('RowType',mRowBo.GetFieldValueAsInteger('RowType'));
        mNewRowBo.SetFieldValueAsString('Store_ID',mrowbo.GetFieldValueAsString('Store_ID'));
        mNewRowBo.SetFieldValueAsString('StoreCard_ID',mrowbo.GetFieldValueAsString('StoreCard_ID'));
        mNewRowBO.SetFieldValueAsFloat('Quantity',mRowBO.GetFieldValueAsFloat('Quantity')-mRowBO.GetFieldValueAsFloat('DeliveredQuantity'));
        mNewRowBO.SetFieldValueAsFloat('UnitPrice',mRowBO.GetFieldValueAsFloat('UnitPrice'));
        mNewRowBo.SetFieldValueAsString('Division_ID',mrowbo.GetFieldValueAsString('Division_ID'));
        mNewRowBo.SetFieldValueAsString('BusOrder_ID',mrowbo.GetFieldValueAsString('BusOrder_ID'));
        mNewRowBo.SetFieldValueAsString('BusTransaction_ID',mrowbo.GetFieldValueAsString('BusTransaction_ID'));


     end;
   end;
   if mNewRows.CountOfNotDeleted>0 then begin
    mBO.SetFieldValueAsBoolean('Closed',true);
    mbo.save;
    mNewBo.save;
    try
      TDynSiteForm(mSite).RefreshData;
      TDynSiteForm(mSite).ActiveDataSet.SeekID(mNewBO.oid);
    finally
    end;
   end;
 end;
end;


begin
end.