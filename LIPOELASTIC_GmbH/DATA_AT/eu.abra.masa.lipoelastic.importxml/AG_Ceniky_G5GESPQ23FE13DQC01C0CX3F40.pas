uses '.fce';


procedure InitSite_Hook(Self: TSiteForm);
var
  mAction:TAction;
begin
  {mAction := Self.GetNewAction;
  mAction.ShowControl := True;
  mAction.ShowMenuItem := True;
  mAction.Name := 'actChangeVATPrice';
  mAction.Caption := '##Zmena ceny o DPH##';
  mAction.Hint := '';
  mAction.Category := 'tabList';
  mAction.OnExecute := @ChP;

  mAction := Self.GetNewAction;
  mAction.ShowControl := True;
  mAction.ShowMenuItem := True;
  mAction.Name := 'actImpCSV2';
  mAction.Caption := '##B2C CSV##';
  mAction.Hint := 'Naimportuje CSV data';
  mAction.Category := 'tabList';
  mAction.OnExecute := @ImportCSV2; }

  mAction := Self.GetNewAction;
  mAction.ShowControl := True;
  mAction.ShowMenuItem := True;
  mAction.Name := 'actImp2025';
  mAction.Caption := '##Import 2025##';
  mAction.Hint := 'Naimportuje CSV data';
  mAction.Category := 'tabList';
  mAction.OnExecute := @Import2025;
end;

Procedure ChP(Sender:TComponent);
var
 mSite:TSiteForm;
 mPriceListBO, mStorePriceBO, mPriceRowBO:TNxCustomBusinessObject;
 mRows:TNxCustomBusinessMonikerCollection;
 mList:TStringList;
 mOS:TNxCustomObjectSpace;
 i,j:integer;
begin
 mSite:=TComponent(Sender).BusRollSite;
 mOS:=mSite.BaseObjectSpace;
 mPriceListBO:=TBusRollSiteForm(mSite).CurrentObject;
 if Assigned(mPriceListBO) then begin
   mList:=TStringList.Create;
   mOS.SQLSelect('Select id from storeprices where pricelist_id='+QuotedStr(mPriceListBO.OID),mList);
   if mlist.Count>0 then begin
     for i:=0 to mlist.Count-1 do begin
       mStorePriceBO:=mOS.CreateObject(Class_StorePrice);
       mStorePriceBO.Load(mlist.strings[i],nil);
       if AnsiLeftStr(mStorePriceBO.GetFieldValueAsString('StoreCard_ID.EAN'),3) in ['859'] then begin
        // NxShowSimpleMessage(mStorePriceBO.GetFieldValueAsString('StoreCard_ID.EAN'),mSite);
         mRows:=mStorePriceBO.GetLoadedCollectionMonikerForFieldCode(mStorePriceBO.GetFieldCode('PriceRows'));
         for j:=0 to mRows.count-1 do begin
           if mRows.BusinessObject[j].GetFieldValueAsString('Price_ID')='~000000001'
                  then mRows.BusinessObject[j].SetFieldValueAsFloat('Amount',
                       mRows.BusinessObject[j].GetFieldValueAsFloat('Amount')/1.2);
         end;
       end;
       if mStorePriceBO.NeedSave then mStorePriceBO.Save;
       mStorePriceBO.free;
     end;
   end;
 end;
 // jen EAN začínající 843 a 859 ponížit o DPH na kartě, zaokrouhlit na 2 desetiny
end;

Procedure Import2025(Sender:TComponent);
var
 mSite:TSiteForm;
 mOpenDlg: TOpenDialog;
 mOS:TNxCustomObjectSpace;
 mErrList, mList:TStringList;
 i,j,k, mCount:integer;
 mPriceList_ID,mStoreCard_ID:string;
 mCode, mPrice, mFName, mTempStr, mUnit, mStorePrice_ID, mName, mLog:string;
 mPriceListBO, mStorePriceBO, mPriceRowBO:TNxCustomBusinessObject;
 mRows:TNxCustomBusinessMonikerCollection;
begin
 mSite:=TComponent(Sender).BusRollSite;
 mOS:=mSite.BaseObjectSpace;

 mLog:= '';

 mOpenDlg:=TOpenDialog.Create(sender);
 mOpenDlg.Title := 'Import z CSV';
 mOpenDlg.Filter := 'Soubory CSV (*.csv)| *.csv';
 mErrList:=tstringlist.Create;
 mPriceList_ID:=TBusRollSiteForm(mSite).CurrentObject.OID;
 if mOpenDlg.Execute then begin
  try
    mList:=TStringList.Create;
    mList.LoadFromFile(mOpenDlg.FileName);
    mCount:=mList.Count;
    WaitWin.StartProgress('Čekejte, prosím ...', '', mCount);
    try
      for j:= 1 to mList.Count -1 do
      begin
        mTempStr:= mList[j];
        mCode:= NxTrapStrTrim(mTempStr,';');
        mName:= NxTrapStrTrim(mTempStr,';');
        mPrice:= NxTrapStrTrim(mTempStr,';');
        munit:= NxTrapStrTrim(mTempStr,';');
        mStoreCard_ID:= GetStoreCard(mOS, mCode, mName);
        if NxIsEmptyOID(mStoreCard_ID) then
        begin
          mLog:= mLog + Format('Row %s - %s - %s - not found.', [IntToStr(j), mCode, mName]) + nxCrLf;
        end;
      end;

      if not NxIsBlank(mLog) then
      begin
        NxShowEditorSite(mSite.SiteContext, mLog, True);
        exit;
      end;

      for j:=1 to mlist.count-1 do begin
          mTempStr:=mList.strings[j];
          mCode:=NxTrapStrTrim(mTempStr,';');
          mName:=NxTrapStrTrim(mTempStr,';');
          mPrice:=NxTrapStrTrim(mTempStr,';');
          munit:=NxTrapStrTrim(mTempStr,';');
          mStoreCard_ID:= GetStoreCard(mOS, mCode, mName);
          if NxIsEmptyOID(mStoreCard_ID) then
          begin
            NxShowSimpleMessage('Stock card not found. Process has ended!', mSite);
            exit;
          end;
          if (NxIBStrToFloat(mPrice)>0) and not(NxIsEmptyOID(mStoreCard_ID)) then begin

             mStorePrice_ID:=mOS.SQLSelectFirstAsString('Select id from storeprices where pricelist_id='+QuotedStr(mPriceList_ID)+' and storecard_id='+QuotedStr(mStoreCard_ID),'');
             if NxIsEmptyOID(mStorePrice_ID) then begin
               mStorePriceBO:=mOS.CreateObject(Class_StorePrice);
               mStorePriceBO.new;
               mStorePriceBO.prefill;
               mstorepriceBO.SetFieldValueAsString('PriceList_ID',mPriceList_ID);
               mStorePriceBO.SetFieldValueAsString('StoreCard_ID',mStoreCard_ID);
               mRows:=mStorePriceBO.GetLoadedCollectionMonikerForFieldCode(mStorePriceBO.GetFieldCode('PriceRows'));
               mPriceRowBO:=mRows.AddNewObject;
               mPriceRowBO.SetFieldValueAsString('Price_ID','~000000001');
               mPriceRowBO.SetFieldValueAsFloat('Amount',NxIBStrToFloat(mPrice));
               mPriceRowBO.SetFieldValueAsString('Qunit',mStorePriceBO.GetFieldValueAsString('StoreCard_ID.MainUnitCode'));
               mstorepricebo.save;
             end else begin
               mStorePriceBO:=mOS.CreateObject(Class_StorePrice);
               mStorePriceBO.Load(mStorePrice_ID,nil);
               mRows:=mStorePriceBO.GetLoadedCollectionMonikerForFieldCode(mStorePriceBO.GetFieldCode('PriceRows'));
               for k:=0 to mRows.count-1 do begin
                 if mRows.BusinessObject[k].GetFieldValueAsString('Price_ID')='~000000001'
                  then mRows.BusinessObject[k].SetFieldValueAsFloat('Amount',(NxIBStrToFloat(mPrice)/1));  //pokud cena s daní jinak dělit 1
               end;
               mStorePriceBO.save;
             end;
          end;
         WaitWin.ChangeText(IntToStr(j+1) + ' / ' + IntToStr(mCount));
        WaitWin.StepIt;
      end;
    finally
      WaitWin.Stop;
    end;
  except
      WaitWin.Stop;
      NxShowSimpleMessage(ExceptionMessage,mSite);
  end;
 end;
end;

Procedure ImportCSV(Sender:TComponent);
var
 mSite:TSiteForm;
 mOpenDlg: TOpenDialog;
 mOS:TNxCustomObjectSpace;
 mErrList, mList:TStringList;
 i,j, mCount:integer;
 mPriceList_ID,mStoreCard_ID:string;
 mCode, mPrice, mFName, mTempStr, mUnit, mStorePrice_ID:string;
 mPriceListBO, mStorePriceBO, mPriceRowBO:TNxCustomBusinessObject;
 mRows:TNxCustomBusinessMonikerCollection;
begin
 mSite:=TComponent(Sender).BusRollSite;
 mOS:=mSite.BaseObjectSpace;
 mOpenDlg:=TOpenDialog.Create(sender);
 mOpenDlg.Title := 'Import z CSV';
 mOpenDlg.Filter := 'Soubory CSV (*.csv)| *.csv';
 mOpenDlg.Options := [ofAllowMultiSelect];
 mErrList:=tstringlist.Create;
 if mOpenDlg.Execute then begin
  try
    mCount:=mOpenDlg.Files.Count;
    WaitWin.StartProgress('Čekejte, prosím ...', '', mCount);
      for i:=0 to mOpenDlg.Files.Count-1 do begin
        mList:=TStringList.Create;
        mList.LoadFromFile(mOpenDlg.Files[i]);
         mFName:=ChangeFileExt(ExtractFileName(mOpenDlg.files[i]),'');
         mPriceList_ID:=mOS.SQLSelectFirstAsString('Select id from pricelists where Name='+QuotedStr(mFName)+' and hidden=''N'' ','');
         if NxIsEmptyOID(mPriceList_ID) then begin
          mPriceListBO:=mOS.CreateObject(Class_PriceList);
          mPriceListBO.new;
          mPriceListBO.SetFieldValueAsString('Name',mFName);
          mPriceListBO.SetFieldValueAsString('Code',AnsiLeftStr(mFName,10));
          mPriceListBO.save;
          mPriceList_ID:=mPriceListBO.OID;
          mpricelistbo.free;
         end;
        for j:=1 to mlist.count-1 do begin
          mTempStr:=mList.strings[j];
          mCode:=NxSearchReplace(NxTrapStrTrim(mTempStr,Chr(9)),'"','',[srAll]);
          mUnit:=NxSearchReplace(NxTrapStrTrim(mTempStr,Chr(9)),'"','',[srAll]);
          mPrice:=NxSearchReplace(NxTrapStrTrim(mTempStr,Chr(9)),'"','',[srAll]);
          mStoreCard_ID:=GetStoreCard(mOS, mCode, '');
          if (NxIBStrToFloat(mPrice)>0) and not(NxIsEmptyOID(mStoreCard_ID)) then begin
             mStorePrice_ID:=mOS.SQLSelectFirstAsString('Select id from storeprices where pricelist_id='+QuotedStr(mPriceList_ID)+' and storecard_id='+QuotedStr(mStoreCard_ID),'');
             if NxIsEmptyOID(mStorePrice_ID) then begin
               mStorePriceBO:=mOS.CreateObject(Class_StorePrice);
               mStorePriceBO.new;
               mStorePriceBO.prefill;
               mstorepriceBO.SetFieldValueAsString('PriceList_ID',mPriceList_ID);
               mStorePriceBO.SetFieldValueAsString('StoreCard_ID',mStoreCard_ID);
               mRows:=mStorePriceBO.GetLoadedCollectionMonikerForFieldCode(mStorePriceBO.GetFieldCode('PriceRows'));
               mPriceRowBO:=mRows.AddNewObject;
               mPriceRowBO.SetFieldValueAsString('Price_ID','~000000001');
               mPriceRowBO.SetFieldValueAsFloat('Amount',NxIBStrToFloat(mPrice));
               mPriceRowBO.SetFieldValueAsString('Qunit',mStorePriceBO.GetFieldValueAsString('StoreCard_ID.MainUnitCode'));
               mstorepricebo.save;
             end;
          end;
        end;
        WaitWin.ChangeText(IntToStr(i+1) + ' / ' + IntToStr(mCount));
        WaitWin.StepIt;
      end;
      WaitWin.Stop;
  except
      WaitWin.Stop;
      NxShowSimpleMessage(ExceptionMessage,mSite);
  end;
 end;
end;

Procedure ImportCSV2(Sender:TComponent);
var
 mSite:TSiteForm;
 mOpenDlg: TOpenDialog;
 mOS:TNxCustomObjectSpace;
 mErrList, mList:TStringList;
 i,j, mCount:integer;
 mPriceList_ID,mStoreCard_ID:string;
 mCode, mPrice, mFName, mTempStr, mUnit, mStorePrice_ID, mBCode, mASCode:string;
 mPriceListBO, mStorePriceBO, mPriceRowBO:TNxCustomBusinessObject;
 mRows:TNxCustomBusinessMonikerCollection;
begin
 mSite:=TComponent(Sender).BusRollSite;
 mOS:=mSite.BaseObjectSpace;
 mOpenDlg:=TOpenDialog.Create(sender);
 mOpenDlg.Title := 'Import z CSV';
 mOpenDlg.Filter := 'Soubory CSV (*.csv)| *.csv';
 mOpenDlg.Options := [ofAllowMultiSelect];
 mErrList:=tstringlist.Create;
 if mOpenDlg.Execute then begin
  try
    mCount:=mOpenDlg.Files.Count;
    WaitWin.StartProgress('Čekejte, prosím ...', '', mCount);
      for i:=0 to mOpenDlg.Files.Count-1 do begin
        mList:=TStringList.Create;
        mList.LoadFromFile(mOpenDlg.Files[i]);
         mFName:=ChangeFileExt(ExtractFileName(mOpenDlg.files[i]),'');
         mPriceList_ID:=mOS.SQLSelectFirstAsString('Select id from pricelists where Name='+QuotedStr(mFName)+' and hidden=''N'' ','');
         if NxIsEmptyOID(mPriceList_ID) then begin
          mPriceListBO:=mOS.CreateObject(Class_PriceList);
          mPriceListBO.new;
          mPriceListBO.SetFieldValueAsString('Name',mFName);
          mPriceListBO.SetFieldValueAsString('Code',AnsiLeftStr(mFName,10));
          mPriceListBO.save;
          mPriceList_ID:=mPriceListBO.OID;
          mpricelistbo.free;
         end;
        for j:=1 to mlist.count-1 do begin
          mTempStr:=mList.strings[j];
          mCode:=NxSearchReplace(NxTrapStrTrim(mTempStr,';'),'"','',[srAll]);
          mBCode:=NxSearchReplace(NxTrapStrTrim(mTempStr,';'),'"','',[srAll]);
          mASCode:=NxSearchReplace(NxTrapStrTrim(mTempStr,';'),'"','',[srAll]);
          mPrice:=NxSearchReplace(NxTrapStrTrim(mTempStr,';'),'"','',[srAll]);
          mStoreCard_ID:=GetStoreCard(mOS, mCode, '');
          if NxIsEmptyOID(mStoreCard_ID) then mStoreCard_ID:=GetStoreCard(mOS, mBCode, '');
          if NxIsEmptyOID(mStoreCard_ID) then mStoreCard_ID:=GetStoreCard(mOS, mASCode, '');
          if (NxIBStrToFloat(mPrice)>0) and not(NxIsEmptyOID(mStoreCard_ID)) then begin
             mStorePrice_ID:=mOS.SQLSelectFirstAsString('Select id from storeprices where pricelist_id='+QuotedStr(mPriceList_ID)+' and storecard_id='+QuotedStr(mStoreCard_ID),'');
             if NxIsEmptyOID(mStorePrice_ID) then begin
               mStorePriceBO:=mOS.CreateObject(Class_StorePrice);
               mStorePriceBO.new;
               mStorePriceBO.prefill;
               mstorepriceBO.SetFieldValueAsString('PriceList_ID',mPriceList_ID);
               mStorePriceBO.SetFieldValueAsString('StoreCard_ID',mStoreCard_ID);
               mRows:=mStorePriceBO.GetLoadedCollectionMonikerForFieldCode(mStorePriceBO.GetFieldCode('PriceRows'));
               mPriceRowBO:=mRows.AddNewObject;
               mPriceRowBO.SetFieldValueAsString('Price_ID','~000000001');
               mPriceRowBO.SetFieldValueAsFloat('Amount',NxIBStrToFloat(mPrice));
               mPriceRowBO.SetFieldValueAsString('Qunit',mStorePriceBO.GetFieldValueAsString('StoreCard_ID.MainUnitCode'));
               mstorepricebo.save;
             end;
          end;
        end;
        WaitWin.ChangeText(IntToStr(i+1) + ' / ' + IntToStr(mCount));
        WaitWin.StepIt;
      end;
      WaitWin.Stop;
  except
      WaitWin.Stop;
      NxShowSimpleMessage(ExceptionMessage,mSite);
  end;
 end;
end;

Function GetStoreCard(var aOS:TNxCustomObjectSpace; var aCode, aName:string;):string;
var
 mBO, mVATrateBO:TNxCustomBusinessObject;
 mStoreCard_ID:string;
 mUnits, mVATRates:TNxCustomBusinessMonikerCollection;
begin
 Result:='';
 if NxIsNumeric(aCode) and (Length(aCode)=13) then begin
   mStoreCard_ID:=aOS.SQLSelectFirstAsString('SELECT  A.id FROM StoreCards A WHERE (((A.EAN LIKE N'+QuotedStr(aCode)+' ESCAPE '+QuotedStr('~')+') OR '+
                                             '(A.ID IN (SELECT SU.Parent_ID FROM StoreEANs SE JOIN StoreUnits SU ON SE.Parent_Id = SU.Id '+
                                             'WHERE SU.Parent_ID = A.ID AND SE.Ean LIKE N'+QuotedStr(aCode)+' ESCAPE '+QuotedStr('~')+')))) AND A.Hidden = '+Quotedstr('N'),'');
 end
  else mStoreCard_ID:=aOS.SQLSelectFirstAsString('Select id from storecards where code='+QuotedStr(aCode)+' and name like N'+QuotedStr(aName)+' and hidden='+QuotedStr('N'),'');
 if not(NxIsEmptyOID(mStoreCard_ID)) then Result:=mStoreCard_ID;
end;

begin
end.