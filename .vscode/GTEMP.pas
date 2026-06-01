procedure InitSite_Hook(Self: TSiteForm);
var
  mAction: TBasicAction;
begin
  mAction := Self.GetNewAction;
  mAction.ShowControl := True;
  mAction.ShowMenuItem := True;
  mAction.Name := 'actGenOVMP';
  mAction.Caption := '##Vygeneruje OVMP##';
  mAction.Hint := 'Vytvoří objendávku OVMP z OV1';
  mAction.Category := 'tabList';
  mAction.OnExecute := @GenOVMP;
end;

Procedure GenOVMP(Sender:TComponent);
var
 mSite:TSiteForm;
 mRows, mNewRows, mInputs:TNxCustomBusinessMonikerCollection;
 i, mProductCount, j, k, mFoundIdx:integer;
 mOS:TNxCustomObjectSpace;
 mBO, mRowBO, mNewBO, mNewRowBO,mNewOrderBO, mNewOrderRowBO, mUserXLink, mInputBO:TNxCustomBusinessObject;
 mNotFoundList:TStringList;
 mProductCard_ID, mMessage, mXLink_ID, aWar, aErr, mStoreCardID, mExistingEntry:string;
 mCompleteBatches:Boolean;
 mBatchQuantity, mQuantity, mNewQuantity, mExistingQuantity:Extended;
 mPOZKList, mOVKD, mOVKM:tstringlist;
 mPOZBO, mVYPBO:TNxCustomBusinessObject;
begin
 mSite:=TComponent(Sender).DynSite;
 mBO:=TDynSiteForm(mSite).CurrentObject;
 if Assigned(mBO) then begin
   mOS:=mBO.ObjectSpace;
   if (mBO.GetFieldValueAsString('DocQueue_ID.Code') in ['OV1','OV2','OV4', 'OVI','OVKO']) then begin
    if mbo.GetFieldValueAsString('DocQueue_ID.Code') in ['OV1','OV2','OV4'] then begin
     if NxMessageBox('Potvrzení', 'Vygenerovat OVMP z objednávky '+mbo.DisplayName+'?', mdConfirm, mdbYesNo, 1, nil, False, msite) = mrYes then begin
       mCompleteBatches:=True;
       mRows:=mBO.GetLoadedCollectionMonikerForFieldCode(mBO.GetFieldCode('Rows'));
       //kontrola na kompletní existenci šarží (agenda pohyby šarží na OV
         for i:=0 to mRows.count-1 do begin
           mRowBO:=mRows.BusinessObject[i];
           if mRowBO.GetFieldValueAsInteger('RowType')=3 then begin
             if mRowBO.GetFieldValueAsInteger('StoreCard_ID.Category')=2 then begin
               if mCompleteBatches then begin
                 mBatchQuantity:=mOS.SQLSelectFirstAsExtended('Select sum(X_Quantity) from defrolldata where clsid='+
                                                              QuotedStr('EC2R2HSFK5UOZ5MYVJWJOHUC4S')+' and  X_Parent_ID='+QuotedStr(mRowBO.OID),0);
                 if not(mBatchQuantity = (mRowBO.GetFieldValueAsFloat('Quantity')/mRowBO.GetFieldValueAsFloat('UnitRate'))) then
                  mCompleteBatches:=False;
               end;
             end;
           end;
         end;
        if not(mCompleteBatches) then begin
          NxShowSimpleMessage('Doklad '+mBO.DisplayName+' nemá kompletně vygenerované šarže, nemohu pokračovat.', mSite);
          exit;
        end;
       //konec kontroly
       //kontrola na existenci x-vazby
         mXLink_ID:=mOS.SQLSelectFirstAsString('Select id from userxlinks where SourceCLSID='+QuotedStr(Class_IssuedOrder)+
                                               ' and Source_id='+QuotedStr(mBO.OID)+' and DestinationCLSID='+QuotedStr(Class_IssuedOrder),'');
         if not(NxIsEmptyOID(mXLink_ID)) then begin
           NxShowSimpleMessage('Doklad '+mBO.DisplayName+' již má svou OVMP', mSite);
           exit;
         end;
       //konec kontroly x-vazby
       //kontrola na kusovník s právě jednou výrobkovou kartou
       mNotFoundList:=TStringList.Create;
       mNotFoundList.Clear;
       mMessage:='Nenalezené položky s kusovníkem o jedné výrobkové kartě:'+#13#10;
       for i:=0 to mRows.count-1 do begin
         mRowBO:=mRows.BusinessObject[i];
         if mRowBO.GetFieldValueAsInteger('RowType')=3 then begin
           if i=0 then
           mProductCount:=mOS.SQLSelectFirstAsInteger('Select count(plm2.id) from plmpiecelists plm left join plmpiecelists2 plm2 on plm.id=plm2.parent_id '+
                                                      'left join storecards sc on sc.id=plm2.storecard_id where sc.IsProduct=''A'' and plm2.X_DoNotProduce=''N'' '+
                                                      'and plm.storecard_id='+QuotedStr(mRowBO.GetFieldValueAsString('StoreCard_ID')),0);
           if not(mProductCount=1) then mNotFoundList.Add(mRowBO.GetFieldValueAsString('StoreCard_ID.Code')+'  '+
                                                          mRowBO.GetFieldValueAsString('StoreCard_ID.Name'));
         end;
       end;
       if mNotFoundList.count>0 then begin
         for i:=0 to mNotFoundList.count-1 do mMessage:=mMessage+#13#10+mNotFoundList.Strings[i];
         NxShowSimpleMessage(mMessage,mSite);
         // zapsat log, odeslat email na informatika@lipoelastic.com
           CFxLog.SaveLog(NxCreateContext(mOS),'LA','chyba OVx',mMessage,2,Now);
         // konec logu
         exit;
       end;
       //konec kontroly kusovníku
       //tvorba OVPM
        try
           mNewBO:=mOS.CreateObject(Class_IssuedOrder);
           mNewBO.New;
           mNewBO.Prefill;
           mNewBO.SetFieldValueAsString('DocQueue_ID','~000000804');
           mNewBO.SetFieldValueAsString('Firm_ID',mOS.SQLSelectFirstAsString('Select id from firms where firm_id is null and hidden=''N'' and OrgIdentNumber=''53578341'' ',''));
           mNewBO.SetFieldValueAsBoolean('Confirmed',True);
           mNewBO.SetFieldValueAsInteger('TradeType',6);
           mNewBO.SetFieldValueAsString('IntrastatDeliveryTerm_ID',mNewBO.GetFieldValueAsString('Firm_ID.X_IntrastatDeliveryTerm_ID'));
           mNewBO.SetFieldValueAsString('IntrastatTransportationType_ID',mNewBO.GetFieldValueAsString('Firm_ID.X_IntrastatTransportationType_'));
           mNewBO.SetFieldValueAsString('IntrastatTransactionType_ID',mNewBO.GetFieldValueAsString('Firm_ID.X_IntrastatTransactionType_ID'));
           mNewBO.SetFieldValueAsString('Country_ID',mOS.SQLSelectFirstAsString('Select id from countries where code='+QuotedStr(mNewBO.GetFieldValueAsString('Firm_ID.ResidenceAddress_ID.CountryCode')),''));
           mNewRows:=mNewBO.GetLoadedCollectionMonikerForFieldCode(mNewBO.GetFieldCode('Rows'));
           mRows:=mBO.GetLoadedCollectionMonikerForFieldCode(mBO.GetFieldCode('Rows'));
           for i:=0 to mRows.count-1 do begin
             mRowBO:=mRows.BusinessObject[i];
             mProductCard_ID:=mOS.SQLSelectFirstAsString('Select sc.id from plmpiecelists plm left join plmpiecelists2 plm2 on plm.id=plm2.parent_id '+
                                                      'left join storecards sc on sc.id=plm2.storecard_id where sc.IsProduct=''A''  and plm2.X_DoNotProduce=''N'' '+
                                                      'and plm.storecard_id='+QuotedStr(mRowBO.GetFieldValueAsString('StoreCard_ID')),'');
             mNewRowBO:=mNewRows.AddNewObject;
             mNewRowBO.SetFieldValueAsInteger('RowType',3);
             mNewRowBO.SetFieldValueAsString('Store_ID','~000000401');
             mNewRowBO.SetFieldValueAsString('StoreCard_ID',mProductCard_ID);
             mNewRowBO.SetFieldValueAsFloat('Quantity',mRowBO.GetFieldValueAsFloat('Quantity'));
             mNewRowBO.SetFieldValueAsString('Division_ID',mRowBO.GetFieldValueAsString('Division_ID'));
             mNewRowBO.SetFieldValueAsString('BusOrder_ID',mRowBO.GetFieldValueAsString('BusOrder_ID'));
             mNewRowBO.SetFieldValueAsString('BusTransaction_ID',mRowBO.GetFieldValueAsString('BusTransaction_ID'));
             mNewRowBO.SetFieldValueAsString('BusProject_ID',mRowBO.GetFieldValueAsString('BusProject_ID'));
             mNewRowBO.SetFieldValueAsDateTime('DeliveryDate$Date',mRowBO.GetFieldValueAsDateTime('DeliveryDate$Date'));
             mNewRowBO.SetFieldValueAsString('X_Origin_ID',mRowBO.OID);
           end;
           if mNewBO.NeedSave then mNewBO.save;
             try
              mUserXLink:=mOS.CreateObject(Class_UserXLink);
              mUserXLink.New;
              mUserXLink.Prefill;
              mUserXLink.SetFieldValueAsString('SourceCLSID', Class_IssuedOrder);
              mUserXLink.SetFieldValueAsString('Source_ID', mBO.OID);
              mUserXLink.SetFieldValueAsString('DestinationCLSID', Class_IssuedOrder);
              mUserXLink.SetFieldValueAsString('Destination_ID', mNewBO.OID);
              mUserXLink.SetFieldValueAsBoolean('DisplayAsSystem', True);
              mUserXLink.SetFieldValueAsString('Description','Vazba');
              mUserXLink.Save;
            finally
              mUserXLink.Free;
            end;
           TDynSiteForm(mSite).ShowSite(Site_IssuedOrders,true,'QueryByUserDynSQLCondition;A.ID='+QuotedStr(mNewBO.OID));
        except
           NxShowSimpleMessage('Něco se nepovedlo při generování OVMP, kontaktovat IT'+#13#10+ExceptionMessage,msite);
           CFxLog.SaveLog(NxCreateContext(mOS),'LA','chyba OVx OVMP',ExceptionMessage+#13#10+NxGetUserName,2,Now);
        end;
       //konec tvorby OVMP
      end;
     end;
   if mbo.GetFieldValueAsString('DocQueue_ID.Code')='OVI' then begin
     if NxMessageBox('Potvrzení', 'Vygenerovat OVMPI z objednávky '+mbo.DisplayName+'?', mdConfirm, mdbYesNo, 1, nil, False, msite) = mrYes then begin
       mCompleteBatches:=True;
       mRows:=mBO.GetLoadedCollectionMonikerForFieldCode(mBO.GetFieldCode('Rows'));
       //kontrola na kompletní existenci šarží (agenda pohyby šarží na OV
         for i:=0 to mRows.count-1 do begin
           mRowBO:=mRows.BusinessObject[i];
           if mRowBO.GetFieldValueAsInteger('RowType')=3 then begin
             if mRowBO.GetFieldValueAsInteger('StoreCard_ID.Category')=2 then begin
               if mCompleteBatches then begin
                 mBatchQuantity:=mOS.SQLSelectFirstAsExtended('Select sum(X_Quantity) from defrolldata where clsid='+
                                                              QuotedStr('EC2R2HSFK5UOZ5MYVJWJOHUC4S')+' and  X_Parent_ID='+QuotedStr(mRowBO.OID),0);
                 if not(mBatchQuantity = (mRowBO.GetFieldValueAsFloat('Quantity')/mRowBO.GetFieldValueAsFloat('UnitRate'))) then
                  mCompleteBatches:=False;
               end;
             end;
           end;
         end;
        if not(mCompleteBatches) then begin
          NxShowSimpleMessage('Doklad '+mBO.DisplayName+' nemá kompletně vygenerované šarže, nemohu pokračovat.', mSite);
          exit;
        end;
       //konec kontroly
       //kontrola na existenci x-vazby
         mXLink_ID:=mOS.SQLSelectFirstAsString('Select id from userxlinks where SourceCLSID='+QuotedStr(Class_IssuedOrder)+
                                               ' and Source_id='+QuotedStr(mBO.OID)+' and DestinationCLSID='+QuotedStr(Class_IssuedOrder),'');
         if not(NxIsEmptyOID(mXLink_ID)) then begin
           NxShowSimpleMessage('Doklad '+mBO.DisplayName+' již má svou OVMPI', mSite);
           exit;
         end;
       //konec kontroly x-vazby
       //kontrola na kusovník s právě jednou výrobkovou kartou
       mNotFoundList:=TStringList.Create;
       mNotFoundList.Clear;
       mMessage:='Nenalezené položky s kusovníkem o jedné výrobkové kartě:'+#13#10;
       for i:=0 to mRows.count-1 do begin
         mRowBO:=mRows.BusinessObject[i];
         if mRowBO.GetFieldValueAsInteger('RowType')=3 then begin
           if i=0 then
           mProductCount:=mOS.SQLSelectFirstAsInteger('Select count(plm2.id) from plmpiecelists plm left join plmpiecelists2 plm2 on plm.id=plm2.parent_id '+
                                                      'left join storecards sc on sc.id=plm2.storecard_id where sc.IsProduct=''A'' '+
                                                      'and plm.storecard_id='+QuotedStr(mRowBO.GetFieldValueAsString('StoreCard_ID')),0);
           if not(mProductCount=1) then mNotFoundList.Add(mRowBO.GetFieldValueAsString('StoreCard_ID.Code')+'  '+
                                                          mRowBO.GetFieldValueAsString('StoreCard_ID.Name'));
         end;
       end;
       if mNotFoundList.count>0 then begin
         for i:=0 to mNotFoundList.count-1 do mMessage:=mMessage+#13#10+mNotFoundList.Strings[i];
         NxShowSimpleMessage(mMessage,mSite);
         // zapsat log, odeslat email na informatika@lipoelastic.com
           CFxLog.SaveLog(NxCreateContext(mOS),'LA','chyba OVx',mMessage,2,Now);
         // konec logu
         exit;
       end;
       //konec kontroly kusovníku
       //tvorba OVPM
        try
           mNewBO:=mOS.CreateObject(Class_IssuedOrder);
           mNewBO.New;
           mNewBO.Prefill;
           mNewBO.SetFieldValueAsString('DocQueue_ID',mOS.SQLSelectFirstAsString('Select id from docqueues where hidden=''N'' and code=''OVMPI'' ',''));
           mNewBO.SetFieldValueAsString('Firm_ID',mOS.SQLSelectFirstAsString('Select id from firms where firm_id is null and hidden=''N'' and OrgIdentNumber=''53578341'' ',''));
           mNewBO.SetFieldValueAsBoolean('Confirmed',True);
           mNewBO.SetFieldValueAsInteger('TradeType',6);
           mNewBO.SetFieldValueAsString('Description',mbo.GetFieldValueAsString('Description'));
           mNewBO.SetFieldValueAsString('IntrastatDeliveryTerm_ID',mNewBO.GetFieldValueAsString('Firm_ID.X_IntrastatDeliveryTerm_ID'));
           mNewBO.SetFieldValueAsString('IntrastatTransportationType_ID',mNewBO.GetFieldValueAsString('Firm_ID.X_IntrastatTransportationType_'));
           mNewBO.SetFieldValueAsString('IntrastatTransactionType_ID',mNewBO.GetFieldValueAsString('Firm_ID.X_IntrastatTransactionType_ID'));
           mNewBO.SetFieldValueAsString('Country_ID',mOS.SQLSelectFirstAsString('Select id from countries where code='+QuotedStr(mNewBO.GetFieldValueAsString('Firm_ID.ResidenceAddress_ID.CountryCode')),''));
           mNewRows:=mNewBO.GetLoadedCollectionMonikerForFieldCode(mNewBO.GetFieldCode('Rows'));
           mRows:=mBO.GetLoadedCollectionMonikerForFieldCode(mBO.GetFieldCode('Rows'));
           for i:=0 to mRows.count-1 do begin
             mRowBO:=mRows.BusinessObject[i];
             mProductCard_ID:=mOS.SQLSelectFirstAsString('Select sc.id from plmpiecelists plm left join plmpiecelists2 plm2 on plm.id=plm2.parent_id '+
                                                      'left join storecards sc on sc.id=plm2.storecard_id where sc.IsProduct=''A'' '+
                                                      'and plm.storecard_id='+QuotedStr(mRowBO.GetFieldValueAsString('StoreCard_ID')),'');
             mNewRowBO:=mNewRows.AddNewObject;
             mNewRowBO.SetFieldValueAsInteger('RowType',3);
             mNewRowBO.SetFieldValueAsString('Store_ID','~000000401');
             mNewRowBO.SetFieldValueAsString('StoreCard_ID',mProductCard_ID);
             mNewRowBO.SetFieldValueAsFloat('Quantity',mRowBO.GetFieldValueAsFloat('Quantity'));
             mNewRowBO.SetFieldValueAsString('Division_ID',mRowBO.GetFieldValueAsString('Division_ID'));
             mNewRowBO.SetFieldValueAsString('BusOrder_ID',mRowBO.GetFieldValueAsString('BusOrder_ID'));
             mNewRowBO.SetFieldValueAsString('BusTransaction_ID',mRowBO.GetFieldValueAsString('BusTransaction_ID'));
             mNewRowBO.SetFieldValueAsString('BusProject_ID',mRowBO.GetFieldValueAsString('BusProject_ID'));
             mNewRowBO.SetFieldValueAsDateTime('DeliveryDate$Date',mRowBO.GetFieldValueAsDateTime('DeliveryDate$Date'));
             mNewRowBO.SetFieldValueAsString('X_PL_StoreCard_ID',mRowBO.GetFieldValueAsString('X_PL_StoreCard_ID'));
             mNewRowBO.SetFieldValueAsString('X_Origin_ID',mRowBO.OID);
           end;
           if mNewBO.NeedSave then mNewBO.save;
             try
              mUserXLink:=mOS.CreateObject(Class_UserXLink);
              mUserXLink.New;
              mUserXLink.Prefill;
              mUserXLink.SetFieldValueAsString('SourceCLSID', Class_IssuedOrder);
              mUserXLink.SetFieldValueAsString('Source_ID', mBO.OID);
              mUserXLink.SetFieldValueAsString('DestinationCLSID', Class_IssuedOrder);
              mUserXLink.SetFieldValueAsString('Destination_ID', mNewBO.OID);
              mUserXLink.SetFieldValueAsBoolean('DisplayAsSystem', True);
              mUserXLink.SetFieldValueAsString('Description','Vazba');
              mUserXLink.Save;
            finally
              mUserXLink.Free;
            end;
           TDynSiteForm(mSite).ShowSite(Site_IssuedOrders,true,'QueryByUserDynSQLCondition;A.ID='+QuotedStr(mNewBO.OID));
        except
           NxShowSimpleMessage('Něco se nepovedlo při generování OVMPI, kontaktovat IT'+#13#10+ExceptionMessage,msite);
           CFxLog.SaveLog(NxCreateContext(mOS),'LA','chyba OVx OVMPI',ExceptionMessage+#13#10+NxGetUserName,2,Now);
        end;
       //konec tvorby OVMP
      end;
     end;
     if mbo.GetFieldValueAsString('DocQueue_ID.Code')='OVKO' then begin
     if NxMessageBox('Potvrzení', 'Vygenerovat OVKP z objednávky '+mbo.DisplayName+'?', mdConfirm, mdbYesNo, 1, nil, False, msite) = mrYes then begin
       mCompleteBatches:=True;
       mRows:=mBO.GetLoadedCollectionMonikerForFieldCode(mBO.GetFieldCode('Rows'));
       //kontrola na kompletní existenci šarží (agenda pohyby šarží na OV
         for i:=0 to mRows.count-1 do begin
           mRowBO:=mRows.BusinessObject[i];
           if mRowBO.GetFieldValueAsInteger('RowType')=3 then begin
             if mRowBO.GetFieldValueAsInteger('StoreCard_ID.Category')=2 then begin
               if mCompleteBatches then begin
                 mBatchQuantity:=mOS.SQLSelectFirstAsExtended('Select sum(X_Quantity) from defrolldata where clsid='+
                                                              QuotedStr('EC2R2HSFK5UOZ5MYVJWJOHUC4S')+' and  X_Parent_ID='+QuotedStr(mRowBO.OID),0);
                 if not(mBatchQuantity = (mRowBO.GetFieldValueAsFloat('Quantity')/mRowBO.GetFieldValueAsFloat('UnitRate'))) then
                  mCompleteBatches:=False;
               end;
             end;
           end;
         end;
        if not(mCompleteBatches) then begin
          NxShowSimpleMessage('Doklad '+mBO.DisplayName+' nemá kompletně vygenerované šarže, nemohu pokračovat.', mSite);
          exit;
        end;
       //konec kontroly
       //kontrola na existenci x-vazby
         mXLink_ID:=mOS.SQLSelectFirstAsString('Select id from userxlinks where SourceCLSID='+QuotedStr(Class_IssuedOrder)+
                                               ' and Source_id='+QuotedStr(mBO.OID)+' and DestinationCLSID='+QuotedStr(Class_IssuedOrder),'');
         if not(NxIsEmptyOID(mXLink_ID)) then begin
           NxShowSimpleMessage('Doklad '+mBO.DisplayName+' již má svou OVKO', mSite);
           exit;
         end;
       //konec kontroly x-vazby
       //kontrola na kusovník s právě jednou výrobkovou kartou
       mNotFoundList:=TStringList.Create;
       mNotFoundList.Clear;
       mMessage:='Nenalezené položky s kusovníkem o jedné výrobkové kartě:'+#13#10;
       for i:=0 to mRows.count-1 do begin
         mRowBO:=mRows.BusinessObject[i];
         if mRowBO.GetFieldValueAsInteger('RowType')=3 then begin
           //if i=0 then
           mProductCount:=mOS.SQLSelectFirstAsInteger('Select count(plm2.id) from plmpiecelists plm left join plmpiecelists2 plm2 on plm.id=plm2.parent_id '+
                                                      'left join storecards sc on sc.id=plm2.storecard_id where sc.IsProduct=''A'' '+
                                                      'and plm.storecard_id='+QuotedStr(mRowBO.GetFieldValueAsString('StoreCard_ID')),0);
           if not(mProductCount=1) then mNotFoundList.Add(mRowBO.GetFieldValueAsString('StoreCard_ID.Code')+'  '+
                                                          mRowBO.GetFieldValueAsString('StoreCard_ID.Name'));
         end;
       end;
       if mNotFoundList.count>0 then begin
         for i:=0 to mNotFoundList.count-1 do mMessage:=mMessage+#13#10+mNotFoundList.Strings[i];
         NxShowSimpleMessage(mMessage,mSite);
         // zapsat log, odeslat email na informatika@lipoelastic.com
           CFxLog.SaveLog(NxCreateContext(mOS),'LA','chyba OVKO',mMessage,2,Now);
         // konec logu
         exit;
       end;
       //konec kontroly kusovníku
       //tvorba OVKP
        try
           mPozklist:=tstringlist.Create;
           mPOZKList.Clear;
           mNewBO:=mOS.CreateObject(Class_IssuedOrder);
           mNewBO.New;
           mNewBO.Prefill;
           mNewBO.SetFieldValueAsString('DocQueue_ID',mOS.SQLSelectFirstAsString('Select id from docqueues where hidden=''N'' and code=''OVKP'' ',''));
           mNewBO.SetFieldValueAsString('Firm_ID',mOS.SQLSelectFirstAsString('Select id from firms where firm_id is null and hidden=''N'' and OrgIdentNumber=''53578341'' ',''));
           mNewBO.SetFieldValueAsBoolean('Confirmed',True);
           mNewBO.SetFieldValueAsString('Description',mbo.GetFieldValueAsString('Description'));
           //mNewBO.SetFieldValueAsString('IntrastatDeliveryTerm_ID',mNewBO.GetFieldValueAsString('Firm_ID.X_IntrastatDeliveryTerm_ID'));
           //mNewBO.SetFieldValueAsString('IntrastatTransportationType_ID',mNewBO.GetFieldValueAsString('Firm_ID.X_IntrastatTransportationType_'));
           //mNewBO.SetFieldValueAsString('IntrastatTransactionType_ID',mNewBO.GetFieldValueAsString('Firm_ID.X_IntrastatTransactionType_ID'));
           //mNewBO.SetFieldValueAsString('Country_ID',mOS.SQLSelectFirstAsString('Select id from countries where code='+QuotedStr(mNewBO.GetFieldValueAsString('Firm_ID.ResidenceAddress_ID.CountryCode')),''));
           mNewRows:=mNewBO.GetLoadedCollectionMonikerForFieldCode(mNewBO.GetFieldCode('Rows'));
           mRows:=mBO.GetLoadedCollectionMonikerForFieldCode(mBO.GetFieldCode('Rows'));
           for i:=0 to mRows.count-1 do begin
             mRowBO:=mRows.BusinessObject[i];
             mProductCard_ID:=mOS.SQLSelectFirstAsString('Select sc.id from plmpiecelists plm left join plmpiecelists2 plm2 on plm.id=plm2.parent_id '+
                                                      'left join storecards sc on sc.id=plm2.storecard_id where sc.IsProduct=''A'' '+
                                                      'and plm.storecard_id='+QuotedStr(mRowBO.GetFieldValueAsString('StoreCard_ID')),'');
             mNewRowBO:=mNewRows.AddNewObject;
             mNewRowBO.SetFieldValueAsInteger('RowType',3);
             mNewRowBO.SetFieldValueAsString('Store_ID','~000000E02');
             mNewRowBO.SetFieldValueAsString('StoreCard_ID',mProductCard_ID);
             mNewRowBO.SetFieldValueAsFloat('Quantity',mRowBO.GetFieldValueAsFloat('Quantity'));
             mNewRowBO.SetFieldValueAsString('Division_ID',mRowBO.GetFieldValueAsString('Division_ID'));
             mNewRowBO.SetFieldValueAsString('BusOrder_ID',mRowBO.GetFieldValueAsString('BusOrder_ID'));
             mNewRowBO.SetFieldValueAsString('BusTransaction_ID',mRowBO.GetFieldValueAsString('BusTransaction_ID'));
             mNewRowBO.SetFieldValueAsString('BusProject_ID',mRowBO.GetFieldValueAsString('BusProject_ID'));
             mNewRowBO.SetFieldValueAsDateTime('DeliveryDate$Date',mRowBO.GetFieldValueAsDateTime('DeliveryDate$Date'));
             mNewRowBO.SetFieldValueAsString('X_PL_StoreCard_ID',mRowBO.GetFieldValueAsString('X_PL_StoreCard_ID'));
             mNewRowBO.SetFieldValueAsString('X_Origin_ID',mRowBO.OID);
             mPozklist.Add(mproductCard_ID+';'+NxFloatToIBStr(mRowBO.GetFieldValueAsFloat('Quantity')));
           end;
           if mNewBO.NeedSave then mNewBO.save;
             try
              mUserXLink:=mOS.CreateObject(Class_UserXLink);
              mUserXLink.New;
              mUserXLink.Prefill;
              mUserXLink.SetFieldValueAsString('SourceCLSID', Class_IssuedOrder);
              mUserXLink.SetFieldValueAsString('Source_ID', mBO.OID);
              mUserXLink.SetFieldValueAsString('DestinationCLSID', Class_IssuedOrder);
              mUserXLink.SetFieldValueAsString('Destination_ID', mNewBO.OID);
              mUserXLink.SetFieldValueAsBoolean('DisplayAsSystem', True);
              mUserXLink.SetFieldValueAsString('Description','Vazba');
              mUserXLink.Save;
            finally
              mUserXLink.Free;
            end;
           TDynSiteForm(mSite).ShowSite(Site_IssuedOrders,true,'QueryByUserDynSQLCondition;A.ID='+QuotedStr(mNewBO.OID));
        except
           NxShowSimpleMessage('Něco se nepovedlo při generování OVKP, kontaktovat IT'+#13#10+ExceptionMessage,msite);
           CFxLog.SaveLog(NxCreateContext(mOS),'LA','chyba OVx OVKP',ExceptionMessage+#13#10+NxGetUserName,2,Now);
        end;
       //konec tvorby OVKP
       //doplnit generování POZK, a OVKM
       if mpozklist.count>0 then begin
          mOVKM:=TStringList.create;
          mOVKD:=TStringList.Create;
          for i:=0 to mPozkList.count-1 do begin
            mProductCard_ID:=NxTrapStrTrim(mPOZKList.Strings[i],';');
            mQuantity:=NxIBStrToFloat(NxTrapStrTrim(mPOZKList.Strings[i],';'));
            mPoZBO:=mOS.CreateObject(Class_PLMProduceRequest);
            mPoZBO.New;
            mPoZBO.Prefill;
            mPOZBO.SetFieldValueAsString('DocQueue_ID','~000000O02');
            mPoZBO.SetFieldValueAsString('StoreCard_ID',mProductCard_ID);
            mPoZBO.SetFieldValueAsFloat('Quantity',mQuantity);
            mPoZBO.SetFieldValueAsFloat('CorrectedQuantity',mQuantity);
            mPOZBO.SetfieldvalueAsString('Firm_ID',mNewBO.GetFieldValueAsString('Firm_ID'));
            mPozBO.SetFieldvalueasstring('Store_ID','~000000E02');
            mPOZBO.SetFieldValueAsString('Division_ID','~000000501');
            mPoZBO.Save;
            TNxPLMProduceRequest(mPoZBO).GenerateJobOrder('~000000O03' ,mPOZBO.GetFieldValueAsString('Period_ID'),'1000000101','1P30000101','1007000000',aWar,aErr);
            try
              mUserXLink:=mOS.CreateObject(Class_UserXLink);
              mUserXLink.New;
              mUserXLink.Prefill;
              mUserXLink.SetFieldValueAsString('SourceCLSID', Class_IssuedOrder);
              mUserXLink.SetFieldValueAsString('Source_ID', mNewBO.OID);
              mUserXLink.SetFieldValueAsString('DestinationCLSID', Class_PLMProduceRequest);
              mUserXLink.SetFieldValueAsString('Destination_ID', mPoZBO.OID);
              mUserXLink.SetFieldValueAsBoolean('DisplayAsSystem', True);
              mUserXLink.SetFieldValueAsString('Description','Vazba');
              mUserXLink.Save;
            finally
              mUserXLink.Free;
            end;
            mInputs:=mPOZBO.GetLoadedCollectionMonikerForFieldCode(mPOZBO.GetFieldCode('Inputs'));
            for j:=0 to mInputs.count-1 do begin
              mInputBO:=mInputs.BusinessObject[j];
              if Copy(mInputBO.GetFieldValueAsString('RealStoreCard_ID.Code'), 1, 2) = 'D-' then begin
                mStoreCardID := mInputBO.GetFieldValueAsString('RealStoreCard_ID');
                mNewQuantity := mInputBO.GetFieldValueAsFloat('Quantity') * mPOZBO.GetFieldValueAsFloat('Quantity');
                mFoundIdx := -1;
                
                // Hledat, zda karta již existuje v seznamu
                for k := 0 to mOVKD.Count - 1 do begin
                  if Copy(mOVKD.Strings[k], 1, Pos(';', mOVKD.Strings[k]) - 1) = mStoreCardID then begin
                    mFoundIdx := k;
                    Break;
                  end;
                end;
                
                if mFoundIdx >= 0 then begin
                  // Karta existuje, sečíst množství
                  mExistingEntry := mOVKD.Strings[mFoundIdx];
                  mExistingQuantity := NxIBStrToFloat(NxTrapStrTrim(mExistingEntry, ';'));
                  mOVKD.Strings[mFoundIdx] := mStoreCardID + ';' + FloatToStr(mExistingQuantity + mNewQuantity);
                end else begin
                  // Nová karta, přidat do seznamu
                  mOVKD.Add(mStoreCardID + ';' + FloatToStr(mNewQuantity));
                end;
              end else begin
                // Karta, která NEZAČÍNÁ s 'D-' - přidat do mOVKM
               if not(minputbo.GetFieldValueAsString('RealStoreCard_ID')=mPozBO.Getfieldvalueasstring('storecard_ID')) then begin
                    mStoreCardID := mInputBO.GetFieldValueAsString('RealStoreCard_ID');
                    mNewQuantity := mInputBO.GetFieldValueAsFloat('Quantity') * mPOZBO.GetFieldValueAsFloat('Quantity');
                    mFoundIdx := -1;
                    
                    // Hledat, zda karta již existuje v seznamu
                    for k := 0 to mOVKM.Count - 1 do begin
                      if Copy(mOVKM.Strings[k], 1, Pos(';', mOVKM.Strings[k]) - 1) = mStoreCardID then begin
                        mFoundIdx := k;
                        Break;
                      end;
                    end;
                    
                    if mFoundIdx >= 0 then begin
                      // Karta existuje, sečíst množství
                      mExistingEntry := mOVKM.Strings[mFoundIdx];
                      mExistingQuantity := NxIBStrToFloat(NxTrapStrTrim(mExistingEntry, ';'));
                      mOVKM.Strings[mFoundIdx] := mStoreCardID + ';' + FloatToStr(mExistingQuantity + mNewQuantity);
                    end else begin
                      // Nová karta, přidat do seznamu
                      mOVKM.Add(mStoreCardID + ';' + FloatToStr(mNewQuantity));
                    end;
                 end; 
              end;
            end;
            mPOZBO.free;

          end;
          
          // Vytvoření objednávek z mOVKD listu (karty začínající D-)
          if mOVKD.count > 0 then begin
              
              mNewOrderBO := mOS.CreateObject(Class_IssuedOrder);
              mNewOrderBO.New;
              mNewOrderBO.Prefill;
              mNewOrderBO.SetFieldValueAsString('DocQueue_ID', '~000000O01');
              mNewOrderBO.SetFieldValueAsString('Firm_ID', '7F26300101');
              mRows := mNewOrderBO.GetLoadedCollectionMonikerForFieldCode(mNewOrderBO.GetFieldCode('Rows'));
              for i:=0 to movkd.count-1 do begin
                mProductCard_ID := NxTrapStrTrim(mOVKD.Strings[i], ';');
                mQuantity := NxIBStrToFloat(NxTrapStrTrim(mOVKD.Strings[i], ';'));
                mNewOrderRowBO := mRows.AddNewObject;
                mNewOrderRowBO.SetFieldValueAsInteger('RowType', 3);
                mNewOrderRowBO.SetFieldValueAsString('Store_ID', '41Y0000101');
                mNewOrderRowBO.SetFieldValueAsString('StoreCard_ID', mProductCard_ID);
                mNewOrderRowBO.SetFieldValueAsFloat('Quantity', mQuantity);
                mNewOrderRowBO.SetFieldValueAsString('Division_ID', '~000000501');
              end;
              if mNewOrderBO.NeedSave then mNewOrderBO.Save;
              try
                mUserXLink := mOS.CreateObject(Class_UserXLink);
                mUserXLink.New;
                mUserXLink.Prefill;
                mUserXLink.SetFieldValueAsString('SourceCLSID', Class_IssuedOrder);
                mUserXLink.SetFieldValueAsString('Source_ID', mNewBO.OID);
                mUserXLink.SetFieldValueAsString('DestinationCLSID', Class_issuedorder);
                mUserXLink.SetFieldValueAsString('Destination_ID', mNewOrderBO.OID);
                mUserXLink.SetFieldValueAsBoolean('DisplayAsSystem', True);
                mUserXLink.SetFieldValueAsString('Description', 'Vazba');
                mUserXLink.Save;
              finally
                mUserXLink.Free;
              end;
              mNewOrderBO.free;
          end; 
          
          // Vytvoření objednávek z mOVKM listu (ostatní karty)
          if mOVKM.count > 0 then begin
              // je to materiál udělat nový doklad typu Objednávka přijatá, aby se následně dala vytvořit převodka výdej
              mNewOrderBO := mOS.CreateObject(Class_IssuedOrder);
              mNewOrderBO.New;
              mNewOrderBO.Prefill;
              mNewOrderBO.SetFieldValueAsString('DocQueue_ID', '~000000O06');
              mNewOrderBO.SetFieldValueAsString('Firm_ID', '7F26300101');
              mRows := mNewOrderBO.GetLoadedCollectionMonikerForFieldCode(mNewOrderBO.GetFieldCode('Rows'));
              for i:=0 to mOVKM.count-1 do begin
                mProductCard_ID := NxTrapStrTrim(mOVKM.Strings[i], ';');
                mQuantity := NxIBStrToFloat(NxTrapStrTrim(mOVKM.Strings[i], ';'));
                mNewOrderRowBO := mRows.AddNewObject;
                mNewOrderRowBO.SetFieldValueAsInteger('RowType', 3);
                mNewOrderRowBO.SetFieldValueAsString('Store_ID', '3000000101');
                mNewOrderRowBO.SetFieldValueAsString('StoreCard_ID', mProductCard_ID);
                mNewOrderRowBO.SetFieldValueAsFloat('Quantity', mQuantity);
                mNewOrderRowBO.SetFieldValueAsString('Division_ID', '~000000501');
              end;
              if mNewOrderBO.NeedSave then mNewOrderBO.Save;
              try
                mUserXLink := mOS.CreateObject(Class_UserXLink);
                mUserXLink.New;
                mUserXLink.Prefill;
                mUserXLink.SetFieldValueAsString('SourceCLSID', Class_IssuedOrder);
                mUserXLink.SetFieldValueAsString('Source_ID', mNewBO.OID);
                mUserXLink.SetFieldValueAsString('DestinationCLSID', Class_issuedorder);
                mUserXLink.SetFieldValueAsString('Destination_ID', mNewOrderBO.OID);
                mUserXLink.SetFieldValueAsBoolean('DisplayAsSystem', True);
                mUserXLink.SetFieldValueAsString('Description', 'Vazba');
                mUserXLink.Save;
              finally
                mUserXLink.Free;
              end;
              mNewOrderBO.free;
          end; 

       end;
      end;
     end;
   end else begin
     NxShowSimpleMessage('Tlačítko funguje jen pro řadu OV1, OV2, OV4, OVKO nebo OVI.',mSite);
   end;
 end;
end;

begin
end.