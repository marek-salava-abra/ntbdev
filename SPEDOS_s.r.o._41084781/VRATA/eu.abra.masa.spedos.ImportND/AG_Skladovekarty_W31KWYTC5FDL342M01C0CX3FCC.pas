uses 'eu.abra.masa.spedos.ImportND.fce';

procedure InitSite_Hook(Self: TSiteForm);
var
  mAction: TBasicAction;
begin
  mAction := Self.GetNewAction;
  mAction.ShowControl := True;
  mAction.ShowMenuItem := True;
  mAction.Caption := 'Import kódů ND';
  mAction.Hint := 'Naimportuje z CSV data pro import ND do odběratelů';
  mAction.Category := 'tabList';
  mAction.OnExecute := @ImportND;
end;

Procedure ImportND(sender:tcomponent);
var
 mSite:TSiteForm;
 mStoreCard_ID, mSubscriber_ID, mPrice_ID, mFirm_ID:string;
 i,j:integer;
 mList:TStringList;
 mCodeCZ, mCodeServis, mPriceServis, mCodeSK, mPriceSK, mTempStr:string;
 mOpenDlg:TOpenDialog;
 mOS:TNxCustomObjectSpace;
 mSubscriberBO,mSMBO,mStorePrice:TNxCustomBusinessObject;
 mStorePrice_ID:string;
 mStorePrices:TNxCustomBusinessMonikerCollection;
begin
  mSite:=TComponent(sender).BusRollSite;
  mOS:=mSite.BaseObjectSpace;
  mList:=TStringList.Create;
    mOpenDlg:=TOpenDialog.Create(sender);
    mOpenDlg.Title := 'Import z CSV';
    mOpenDlg.Filter := 'Soubory CSV (*.csv)| *.csv';
    if mOpenDlg.Execute then begin
      try
           mList.LoadFromFile(mOpenDlg.FileName);
           WaitWin.StartProgress('Čekejte, prosím ...', '', mList.Count);
            for i:=0 to mList.Count-1 do begin
              mTempStr:=mList.strings[i];
              mCodeCZ:=NxTrapStr(mTempStr,';');
              mCodeServis:=NxTrapStr(mTempStr,';');
              mPriceServis:=NxTrapStr(mTempStr,';');
              mCodeSK:=NxTrapStr(mTempStr,';');
              mPriceSK:=NxTrapStr(mTempStr,';');
              mStoreCard_ID:=GetStoreCard_ID(mOS, mCodeCZ);
              if not(NxIsEmptyOID(mStoreCard_ID)) then begin
                 mFirm_ID:=GetFirm_ID(mOS,'05665817');
                 mSubscriber_ID:=GetSubscriber_ID(mos,mstorecard_id,mFirm_ID);
                 if NxIsEmptyOID(mSubscriber_ID) then begin
                   mSubscriberBO:=mOS.CreateObject(Class_Subscriber);
                   mSubscriberBO.new;
                   mSubscriberBO.SetFieldValueAsString('Firm_ID',mFirm_ID);
                   mSubscriberBO.SetFieldValueAsString('StoreCard_ID', mStoreCard_ID);
                   mSubscriberBO.SetFieldValueAsString('ExternalNumber',mCodeServis);
                   mSubscriberBO.save;
                 end else begin
                   mSubscriberBO:=mOS.CreateObject(Class_Subscriber);
                   mSubscriberBO.Load(mSubscriber_ID,nil);
                   mSubscriberBO.SetFieldValueAsString('ExternalNumber',mCodeServis);
                   mSubscriberBO.save;
                 end;
                 mFirm_ID:=GetFirm_ID(mOS,'31708587');
                 mSubscriber_ID:=GetSubscriber_ID(mos,mstorecard_id,mFirm_ID);
                 if NxIsEmptyOID(mSubscriber_ID) then begin
                   mSubscriberBO:=mOS.CreateObject(Class_Subscriber);
                   mSubscriberBO.new;
                   mSubscriberBO.SetFieldValueAsString('Firm_ID',mFirm_ID);
                   mSubscriberBO.SetFieldValueAsString('StoreCard_ID', mStoreCard_ID);
                   mSubscriberBO.SetFieldValueAsString('ExternalNumber',mCodeSK);
                   mSubscriberBO.save;
                 end else begin
                   mSubscriberBO:=mOS.CreateObject(Class_Subscriber);
                   mSubscriberBO.Load(mSubscriber_ID,nil);
                   mSubscriberBO.SetFieldValueAsString('ExternalNumber',mCodeSK);
                   mSubscriberBO.save;
                 end;
                  if not(NxIsEmptyOID(mStoreCard_ID)) then begin
                   mStorePrice_ID:=GetStorePrice_ID(mOS,mStoreCard_ID, '1200000101');
                   if (NxIBStrToFloat(mPriceServis)>0) and (NxIsEmptyOID(mStorePrice_ID)) then begin
                       mSMBO:=mOS.CreateObject(Class_StorePrice);
                       mSMBO.New;
                       mSMBO.SetFieldValueAsString('StoreCard_id',mStoreCard_ID);
                       msmbo.SetFieldValueAsString('PriceList_ID','1200000101');
                       mStorePrices:=mSMBO.GetLoadedCollectionMonikerForFieldCode(mSMBO.GetFieldCode('PriceRows'));
                       if NxIBStrToFloat(mPriceServis)>0 then begin
                         mStorePrice:=mStorePrices.AddNewObject;
                         mStorePrice.SetFieldValueAsString('Price_ID','3000000101');
                         mStorePrice.SetFieldValueAsString('Qunit', mSMBO.GetFieldValueAsString('StoreCard_id.MainUnitCode'));
                         mStorePrice.SetFieldValueAsFloat('UnitRate',1);
                         mStorePrice.SetFieldValueAsFloat('Amount',NxIBStrToFloat(mPriceServis));
                       end;
                       if NxIBStrToFloat(mPriceSK)>0 then begin
                         mStorePrice:=mStorePrices.AddNewObject;
                         mStorePrice.SetFieldValueAsString('Price_ID','4000000101');
                         mStorePrice.SetFieldValueAsString('Qunit', mSMBO.GetFieldValueAsString('StoreCard_id.MainUnitCode'));
                         mStorePrice.SetFieldValueAsFloat('UnitRate',1);
                         mStorePrice.SetFieldValueAsFloat('Amount',NxIBStrToFloat(mPriceSK));
                       end;
                       msmbo.save;
                       mSMBO.Free;

                   end;
                   if (NxIBStrToFloat(mPriceServis)>0) and not(NxIsEmptyOID(mStorePrice_ID)) then begin
                       mSMBO:=mOS.CreateObject(Class_StorePrice);
                       mSMBO.load(mStorePrice_ID,nil);
                       mStorePrices:=mSMBO.GetLoadedCollectionMonikerForFieldCode(mSMBO.GetFieldCode('PriceRows'));
                       for j:=0 to mStorePrices.count-1 do begin
                         mStorePrice:=mStorePrices.BusinessObject[j];
                         if mStorePrice.GetFieldValueAsString('Price_ID')='3000000101' then  mStorePrice.SetFieldValueAsFloat('Amount',NxIBStrToFloat(mPriceServis));
                         if mStorePrice.GetFieldValueAsString('Price_ID')='4000000101' then  mStorePrice.SetFieldValueAsFloat('Amount',NxIBStrToFloat(mPriceSK));
                       end;
                       msmbo.save;
                       mSMBO.Free;

                   end;
                  end;


              end;
              WaitWin.ChangeText(IntToStr(i+1) + ' / ' + IntToStr(mList.Count));
              WaitWin.StepIt;
            end;
           WaitWin.Stop;

      finally
        TBusRollSiteForm(mSite).RefreshData;
        NxShowSimpleMessage('Nahráno/upraveno '+IntToStr(mlist.count)+' položek.',mSite);
      end;
    end;
end;

begin
end.