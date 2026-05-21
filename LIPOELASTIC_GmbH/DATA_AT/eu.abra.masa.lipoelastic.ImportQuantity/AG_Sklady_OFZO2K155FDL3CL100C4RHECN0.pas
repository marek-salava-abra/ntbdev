uses '.API';

procedure InitSite_Hook(Self: TSiteForm);
var
  mAction:TAction;
begin
  mAction := Self.GetNewAction;
  mAction.ShowControl := True;
  mAction.ShowMenuItem := True;
  mAction.Name := 'actImpQ';
  mAction.Caption := '##Import Quantity##';
  mAction.Hint := 'Naimportuje množství z CSV';
  mAction.Category := 'tabList';
  mAction.OnExecute := @ImportQuantity;
end;

Procedure ImportQuantity(Sender:TComponent);
var
 mSite:TSiteForm;
 mList,mList2:TStringList;
 mOpenDlg:TOpenDialog;
 i:Integer;
 mBO:TNxCustomBusinessObject;
 mRCBO, mRCRowBO, mDRBBO:TNxCustomBusinessObject;
 mRows, mDocRowBatches:TNxCustomBusinessMonikerCollection;
 mOS:TNxCustomObjectSpace;
 mStoreCard_ID, mStoreBatch_ID,mTempStr, mEan, mBatchCode, mExpiry, mQuantity, mVersion:string;
 mInputJSON, mOutputJSON:TJSONSuperObject;
 mDate, mUnitPrice:extended;
begin
 mSite:=TComponent(Sender).BusRollSite;
 mBO:=TBusRollSiteForm(mSite).CurrentObject;
 if Assigned(mBO) then begin
   mOS:=msite.BaseObjectSpace;
   mOpenDlg:=TOpenDialog.Create(sender);
   mOpenDlg.Title := 'Import CSV';
   mOpenDlg.Filter := 'Soubory CSV (*.csv)| *.csv';
   if mOpenDlg.Execute then begin
      mList2:=TStringList.create;
      mList:=TStringList.Create;
      mList.LoadFromFile(mOpenDlg.FileName);
      if mlist.Count>1 then begin
        WaitWin.StartProgress('Please, wait ...', '', mlist.Count);
        try
         mRCBO:=mOS.CreateObject(Class_ReceiptCard);
         mRCBO.new;
         mRCBO.prefill;
         mRCBO.SetFieldValueAsString('Firm_ID','AAA1000000');
         mRCBO.SetFieldValueAsDateTime('DocDate$Date',StrToDate('30.9.2025'));
         mRCBO.SetFieldValueAsString('Description',AnsiLeftStr(mbo.DisplayName,40));
         mRows:=mRCBO.GetLoadedCollectionMonikerForFieldCode(mRCBO.GetFieldCode('Rows'));
         for i:=1 to mList.count-1 do begin
           mTempStr:=mList.strings[i];
           mEan:=NxTrapStrTrim(mTempStr,';');
           mBatchCode:=NxTrapStrTrim(mTempStr,';');
           mExpiry:=NxTrapStrTrim(mTempStr,';');
           mQuantity:=NxTrapStrTrim(mTempStr,';');
           if NxIBStrToFloat(mQuantity)>0 then begin
               mDate:=Date;
               mVersion:='';
               mStoreCard_ID:=GetOrCreateStoreCard(mOS, mEAN, '');
               if not(NxIsBlank(mBatchCode)) then begin
                 mInputJSON:=TJSONSuperObject.Create;
                 mInputJSON.S['ean']:=mEAN;
                 mInputJSON.S['batchCode']:=mBatchCode;
                 mOutputJSON:=API_POST(mInputJSON,'GetDataFromBatch',true);
                 if mOutputJSON.N['status'].DataType<>jtNull then begin
                   if mOutputJSON.S['status']='ok' then begin
                     mDate:=mOutputJSON.DT8601['expirationDate'];
                     mVersion:=mOutputJSON.S['version'];
                   end;
                 end;
                 mStoreBatch_ID:=GetBatch_ID(mOS, mStoreCard_ID, mBatchCode, mDate, mVersion);
               end;
               mRCRowBO:=mRows.AddNewObject;
               mRCRowBO.Prefill;
               mRCRowBO.SetFieldValueAsString('Store_ID',mBO.OID);
               mRCRowBO.SetFieldValueAsString('StoreCard_ID',mStoreCard_ID);
               mRCRowBO.SetFieldValueAsFloat('Quantity',NxIBStrToFloat(mQuantity));
               mRCRowBO.SetFieldValueAsString('Division_ID','1000000101');
               mUnitPrice:=mOS.SQLSelectFirstAsExtended('Select Purchaseprice from suppliers where storecard_id='+Quotedstr(mStoreCard_ID)+' and Firm_id='+QuotedStr('~0000005LQ'),0);
               mRCRowBO.SetFieldValueAsFloat('UnitPrice',mUnitPrice);
               if not(NxIsEmptyOID(mStoreBatch_ID)) then begin
                 mDocRowBatches:=mRCRowBO.GetLoadedCollectionMonikerForFieldCode(mRCRowBO.GetFieldCode('DocRowBatches'));
                 mDRBBO:=mDocRowBatches.AddNewObject;
                 mDRBBO.SetFieldValueAsString('StoreBatch_ID',mStoreBatch_ID);
               end;
           end;
           //mList2.Add(IntToStr(i)+'  '+mEan+'  '+mStoreCard_ID+' '+mQuantity+' '+DateTimeToStr(mOutputJSON.DT8601['expirationDate']));
           WaitWin.ChangeText(IntToStr(i) + ' / ' + IntToStr(mlist.Count));
           WaitWin.StepIt;
         end;
         mRCBO.save;
        WaitWin.stop;
       except
          WaitWin.stop;
          NxShowSimpleMessage('Something happens:'+nxCrLf+ExceptionMessage,mSite);
       end;
       NxShowSimpleMessage('Done',msite);
      end;
   end;
 end;
end;

Function GetBatch_ID(var aOS:TNxCustomObjectSpace;var aStoreCard_ID, aBatchCode:string;var aDate:Extended;var aVersion:string):string;
var
 mBO:TNxCustomBusinessObject;
 mStoreBatch_ID:string;
begin
 Result:='';
 mStoreBatch_ID:=aOS.SQLSelectFirstAsString('Select id from storebatches where storecard_id='+QuotedStr(aStoreCard_ID)+' and name='+QuotedStr(aBatchCode),'');
 if not(NxIsEmptyOID(mStoreBatch_ID)) then begin
    mBO:=aOS.CreateObject(Class_StoreBatch);
    mBO.Load(mStoreBatch_ID,nil);
    mBO.SetFieldValueAsDateTime('ExpirationDate$DATE',aDate);
    mBO.SetFieldValueAsString('X_Verze',aVersion);
    mBO.save;
    mbo.free;
 end else begin
    mBO:=aOS.CreateObject(Class_StoreBatch);
    mBO.New;
    mBO.prefill;
    mBO.SetFieldValueAsString('StoreCard_ID',aStoreCard_ID);
    mBO.SetFieldValueAsString('Name',aBatchCode);
    mBO.SetFieldValueAsDateTime('ExpirationDate$DATE',aDate);
    mBO.SetFieldValueAsString('X_Verze',aVersion);
    mBO.save;
    mStoreBatch_ID:=mBO.OID;
    mbo.free;
 end;
 Result:=mStoreBatch_ID;
end;

Function GetOrCreateStoreCard(var aOS:TNxCustomObjectSpace; var aCode, aName:string;):string;
var
 mBO, mVATrateBO:TNxCustomBusinessObject;
 mStoreCard_ID:string;
 mUnits, mVATRates:TNxCustomBusinessMonikerCollection;
begin
 if NxIsNumeric(aCode) and (Length(aCode)=13) then begin
   mStoreCard_ID:=aOS.SQLSelectFirstAsString('SELECT  A.id FROM StoreCards A WHERE (((A.EAN LIKE N'+QuotedStr(aCode)+' ESCAPE '+QuotedStr('~')+') OR '+
                                             '(A.ID IN (SELECT SU.Parent_ID FROM StoreEANs SE JOIN StoreUnits SU ON SE.Parent_Id = SU.Id '+
                                             'WHERE SU.Parent_ID = A.ID AND SE.Ean LIKE N'+QuotedStr(aCode)+' ESCAPE '+QuotedStr('~')+')))) AND A.Hidden = '+Quotedstr('N'),'');
 end
  else mStoreCard_ID:=aOS.SQLSelectFirstAsString('Select id from storecards where code='+QuotedStr(aCode)+' and name like N'+QuotedStr(aName)+' and hidden='+QuotedStr('N'),'');
 if NxIsEmptyOID(mStoreCard_ID) then begin
   mBO:=aOS.CreateObject(Class_StoreCard);
   mbo.new;
   mbo.prefill;
   mBO.SetFieldValueAsString('Code',aCode);
   mBO.SetFieldValueAsString('Name',aName);
   mBO.SetFieldValueAsString('Specification','IMPORT_XML');
   mBO.SetFieldValueAsString('StoreCardCategory_ID','6000000101');
   mBO.SetFieldValueAsString('VATRate_ID', '02000XAT00');
   mUnits:=mBO.GetLoadedCollectionMonikerForFieldCode(mbo.GetFieldCode('StoreUnits'));
   mVATRates:=mBO.GetLoadedCollectionMonikerForFieldCode(mBO.GetFieldCode('VATRates'));
   mUnits.BusinessObject[0].SetFieldValueAsString('Code','stk');
   if NxIsNumeric(aCode) and (Length(aCode)=13) then begin
    mBO.SetFieldValueAsInteger('Category',2);
    mUnits.BusinessObject[0].SetFieldValueAsString('EAN',aCode);
   end;
   mBO.SetFieldValueAsString('MainUnitcode','stk');
   mVATrateBO:=mVATRates.AddNewObject;
   mVATrateBO.prefill;
   mvatratebo.SetFieldValueAsString('Country_ID','00000DE000');
   mVATrateBO.SetFieldValueAsString('VatRate_ID','01900XDE00');
   mbo.save;
   mStoreCard_ID:=mBO.OID;
   mbo.free;
 end;
 Result:=mStoreCard_ID;
end;

begin
end.