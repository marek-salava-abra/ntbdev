uses 'eu.spedos.importExternalCode.fce';

procedure FormCreate_Hook(Self: TSiteForm);
var
  mAction: TBasicAction;
begin
  mAction := Self.GetNewAction;
  mAction.ShowControl := True;
  mAction.ShowMenuItem := True;
  mAction.Caption := '## Import Ext ##';
  mAction.Hint := 'Naimportuje externí kódy a ceny, import z CSV';
  mAction.Category := 'tabList';
  mAction.OnExecute := @ImportExternalCode;
  mAction := Self.GetNewAction;
  mAction.ShowControl := True;
  mAction.ShowMenuItem := True;
  mAction.Caption := '## Import spodního limitu ##';
  mAction.Hint := 'Naimportuje spodní limit, import z CSV';
  mAction.Category := 'tabList';
  mAction.OnExecute := @ImportLowLimit;

end;

Procedure ImportLowLimit(sender:TComponent);
var
 mSite:TSiteForm;
 mOS:TNxCustomObjectSpace;
 mOpenDlg:TOpenDialog;
 mList:TStringList;
 i,j:integer;
 mTempStr, mStoreCardCode, mStoreCode, mStoreSubCard_ID:string;
 mLowLimit:Extended;
 mSSCBO:TNxCustomBusinessObject;
begin
 mSite:=TComponent(sender).BusRollSite;
 mOS:=mSite.BaseObjectSpace;
 mOpenDlg := TOpenDialog.Create(Sender);
 mOpenDlg.Filter:='CSV soubor|*.csv';
 if mOpenDlg.Execute then begin
    mList:=TStringList.Create;
    mlist.LoadFromFile(mOpenDlg.FileName);
    ProgressInit(mSite, 'importuji spodní limit...', mlist.Count);
    for i:=1 to mList.count-1 do begin
      mTempStr:=mlist.Strings[i];
      mStoreCardCode:=NxTrapStr(mTempStr,';');
      mStoreCode:=NxTrapStr(mTempStr,';');
      mLowLimit:=NxIBStrToFloat(NxTrapStr(mTempStr,';'));
      mStoreSubCard_ID:=GetStoreSubCard_ID(mOs, mStoreCardCode,mStoreCode);
      if not(NxIsEmptyOID(mStoreSubCard_ID)) then begin
        mSSCBO:=mOS.CreateObject(Class_StoreSubCard);
        mSSCBO.Load(mStoreSubCard_ID,nil);
        mSSCBO.SetFieldValueAsFloat('LowLimitQuantity',mLowLimit);
        msscbo.Save;
        mSSCBO.free;
      end;
      ProgressSetPos(i+1);
    end;
    ProgressDispose();
 end;
end;


Procedure ImportExternalCode(sender:TComponent);
var
 mSite:TSiteForm;
 mOS:TNxCustomObjectSpace;
 mOpenDlg:TOpenDialog;
 mList:TStringList;
 i,j:integer;
 mVcode, mSCode, mSKCode, mSPrice, mSKPrice, mStoreCode, mTyp, mQunit:string;
 mServisFirm_ID, mSKFirm_ID, mTempStr, mStoreCard_ID, mSubscriber_ID, mStorePrice_ID, mPrice_ID, mPriceList_ID, mDny:string;
 mSubscriberBO, mPriceBO, mStoreCardBO,mStorePriceBO:TNxCustomBusinessObject;
 mPricesM:TNxCustomBusinessMonikerCollection;
begin
 mSite:=TComponent(sender).BusRollSite;
 mOS:=mSite.BaseObjectSpace;
 mOpenDlg := TOpenDialog.Create(Sender);
 mOpenDlg.Filter:='CSV soubor|*.csv';
 mServisFirm_ID:=GetFirm_ID(mOS,'05665817');
 mSKFirm_ID:=GetFirm_ID(mOS,'31708587');
 if mOpenDlg.Execute then begin
    mList:=TStringList.Create;
    mlist.LoadFromFile(mOpenDlg.FileName);
    for i:=1 to mList.count-1 do begin
      mTempStr:=mlist.Strings[i];
      mVcode:=NxTrapStr(mTempStr,';');
      mSCode:=NxTrapStr(mTempStr,';');
      mSPrice:=NxTrapStr(mTempStr,';');
      mSKCode:=NxTrapStr(mTempStr,';');
      mSKPrice:=NxTrapStr(mTempStr,';');
      mQunit:=NxTrapStr(mTempStr,';');
      mStoreCode:=NxTrapStr(mTempStr,';');
      mTyp:=NxTrapStr(mTempStr,';');
      mDny:=NxTrapStr(mTempStr,';');
      mStoreCard_ID:=GetStoreCard_ID(mOS,mVcode);
        if not(NxIsEmptyOID(mStoreCard_ID)) then begin
          mStoreCardBO:=mOs.CreateObject(Class_StoreCard);
          mStoreCardBO.Load(mStoreCard_ID,nil);
          mStoreCardBO.SetFieldValueAsString('X_Store_ID',GetStore_ID(mOS,mStoreCode));
          if NxIBStrToFloat(mDny)>0 then mStoreCardBO.SetFieldValueAsInteger('X_UsuallTerm',Trunc(NxIBStrToFloat(mDny)));
          mStoreCardBo.Save;
          mStoreCardBO.free;
          if not(NxIsBlank(mSCode)) then begin
            mSubscriber_ID:=GetSubscriber_ID(mos,mStoreCard_ID,mServisFirm_ID);
            if NxIsEmptyOID(mSubscriber_ID) then begin
              mSubscriberBO:=mOS.CreateObject(Class_Subscriber);
              mSubscriberBO.new;
              mSubscriberBO.SetFieldValueAsString('Firm_ID',mServisFirm_ID);
              mSubscriberBO.SetFieldValueAsString('StoreCard_ID',mStoreCard_ID);
              mSubscriberBO.SetFieldValueAsString('ExternalNumber',mSCode);
              mSubscriberBO.save;
              mSubscriberBO.free;
            end;
            if not(NxIsEmptyOID(mSubscriber_ID)) then begin
              mSubscriberBO:=mOS.CreateObject(Class_Subscriber);
              mSubscriberBO.Load(mSubscriber_ID,nil);
              mSubscriberBO.SetFieldValueAsString('ExternalNumber',mSCode);
              mSubscriberBO.save;
              mSubscriberBO.free;
            end;
          end;
          if not(NxIsBlank(mSKCode)) then begin
            mSubscriber_ID:=GetSubscriber_ID(mos,mStoreCard_ID,mSKFirm_ID);
            if NxIsEmptyOID(mSubscriber_ID) then begin
              mSubscriberBO:=mOS.CreateObject(Class_Subscriber);
              mSubscriberBO.new;
              mSubscriberBO.SetFieldValueAsString('Firm_ID',mSKFirm_ID);
              mSubscriberBO.SetFieldValueAsString('StoreCard_ID',mStoreCard_ID);
              mSubscriberBO.SetFieldValueAsString('ExternalNumber',mSKCode);
              mSubscriberBO.save;
              mSubscriberBO.free;
            end;
            if not(NxIsEmptyOID(mSubscriber_ID)) then begin
              mSubscriberBO:=mOS.CreateObject(Class_Subscriber);
              mSubscriberBO.Load(mSubscriber_ID,nil);
              mSubscriberBO.SetFieldValueAsString('ExternalNumber',mSKCode);
              mSubscriberBO.save;
              mSubscriberBO.free;
            end;
          end;
        end;

        if (NxIBStrToFloat(mSPrice)>0) and not(NxIsEmptyOID(mStoreCard_ID))  then begin
                   mStoreCardBO:=mOS.CreateObject(Class_StoreCard);
                   mStoreCardBO.Load(mStoreCard_ID,nil);
                   mPrice_ID:='3000000101';
                   mPriceList_ID:='3200000101';
                   mStorePrice_ID:=GetStorePrice_ID(mOS, mPriceList_ID, mStoreCard_ID);
                   if not(NxIsEmptyOID(mStorePrice_id)) then begin
                    mStorePriceBO:=mOS.CreateObject(Class_StorePrice);
                    mStorePriceBO.Load(mStorePrice_ID,nil);
                    mPricesM:=mStorePriceBO.GetLoadedCollectionMonikerForFieldCode(mStorePriceBO.GetFieldCode('PriceRows'));
                     for j:=0 to mPricesM.Count-1 do begin
                      mPriceBO:=mPricesM.BusinessObject[j];
                      if mPriceBO.GetFieldValueAsString('Price_ID')=mPrice_ID then mPriceBO.SetFieldValueAsFloat('Amount',NxIBStrToFloat(mSPrice));
                     end;
                    mStorePriceBO.save;
                   end;
                   if (NxIsEmptyOID(mStorePrice_id)) then begin
                     mStorePriceBO:=mOS.CreateObject(Class_StorePrice);
                     mStorePriceBO.New;
                     mStorePriceBO.SetFieldValueAsString('PriceList_ID',mPriceList_ID);
                     mStorePriceBO.SetFieldValueAsString('StoreCard_ID',mStoreCard_ID);

                     mPricesM:=mStorePriceBO.GetLoadedCollectionMonikerForFieldCode(mStorePriceBO.GetFieldCode('PriceRows'));
                     mPriceBO:=mPricesM.AddNewObject;
                     mpriceBO.SetFieldValueAsFloat('Amount',NxIBStrToFloat(mSPrice));
                     mpricebo.SetFieldValueAsString('Qunit',mStoreCardBO.GetFieldValueAsString('MainUnitCode'));
                     mpricebo.SetFieldValueAsString('Price_ID',mPrice_ID);
                     mStorePriceBO.save;
                   end;
                  mStoreCardBO.free;
        end;
        if (NxIBStrToFloat(mSKPrice)>0) and not(NxIsEmptyOID(mStoreCard_ID))  then begin
                   mStoreCardBO:=mOS.CreateObject(Class_StoreCard);
                   mStoreCardBO.Load(mStoreCard_ID,nil);
                   mPrice_ID:='4000000101';
                   mPriceList_ID:='2200000101';
                   mStorePrice_ID:=GetStorePrice_ID(mOS, mPriceList_ID, mStoreCard_ID);
                   if not(NxIsEmptyOID(mStorePrice_id)) then begin
                    mStorePriceBO:=mOS.CreateObject(Class_StorePrice);
                    mStorePriceBO.Load(mStorePrice_ID,nil);
                    mPricesM:=mStorePriceBO.GetLoadedCollectionMonikerForFieldCode(mStorePriceBO.GetFieldCode('PriceRows'));
                     for j:=0 to mPricesM.Count-1 do begin
                      mPriceBO:=mPricesM.BusinessObject[j];
                      if mPriceBO.GetFieldValueAsString('Price_ID')=mPrice_ID then mPriceBO.SetFieldValueAsFloat('Amount',NxIBStrToFloat(mSKPrice));
                     end;
                    mStorePriceBO.save;
                   end;
                   if (NxIsEmptyOID(mStorePrice_id)) then begin
                     mStorePriceBO:=mOS.CreateObject(Class_StorePrice);
                     mStorePriceBO.New;
                     mStorePriceBO.SetFieldValueAsString('PriceList_ID',mPriceList_ID);
                     mStorePriceBO.SetFieldValueAsString('StoreCard_ID',mStoreCard_ID);

                     mPricesM:=mStorePriceBO.GetLoadedCollectionMonikerForFieldCode(mStorePriceBO.GetFieldCode('PriceRows'));
                     mPriceBO:=mPricesM.AddNewObject;
                     mpriceBO.SetFieldValueAsFloat('Amount',NxIBStrToFloat(mSKPrice));
                     mpricebo.SetFieldValueAsString('Qunit',mStoreCardbo.GetFieldValueAsString('MainUnitCode'));
                     mpricebo.SetFieldValueAsString('Price_ID',mPrice_ID);
                     mStorePriceBO.save;
                   end;
                   mStoreCardBO.free;

        end;
    end;
    mlist.Free;
 end;
end;

begin
end.