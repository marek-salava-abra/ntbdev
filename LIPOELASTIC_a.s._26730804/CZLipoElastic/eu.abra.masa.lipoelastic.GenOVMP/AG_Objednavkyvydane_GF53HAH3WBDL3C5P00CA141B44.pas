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
 mRows, mNewRows:TNxCustomBusinessMonikerCollection;
 i,mProductCount:integer;
 mOS:TNxCustomObjectSpace;
 mBO, mRowBO, mNewBO, mNewRowBO, mUserXLink:TNxCustomBusinessObject;
 mNotFoundList:TStringList;
 mProductCard_ID, mMessage, mXLink_ID:string;
 mCompleteBatches:Boolean;
 mBatchQuantity:Extended;
begin
 mSite:=TComponent(Sender).DynSite;
 mBO:=TDynSiteForm(mSite).CurrentObject;
 if Assigned(mBO) then begin
   mOS:=mBO.ObjectSpace;
   if (mBO.GetFieldValueAsString('DocQueue_ID.Code') in ['OV1','OV2','OV4', 'OVI']) then begin
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
   end else begin
     NxShowSimpleMessage('Tlačítko funguje jen pro řadu OV1, OV2 nebo OVI.',mSite);
   end;
 end;
end;

begin
end.