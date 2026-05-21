procedure InitSite_Hook(Self: TSiteForm);
var
  mAction:TAction;
begin
 { mAction := Self.GetNewAction;
  mAction.ShowControl := True;
  mAction.ShowMenuItem := True;
  mAction.Name := 'actImpXML';
  mAction.Caption := '##Import XML##';
  mAction.Hint := 'Naimportuje XML data';
  mAction.Category := 'tabList';
  mAction.OnExecute := @ImportXML;

  mAction := Self.GetNewAction;
  mAction.ShowControl := True;
  mAction.ShowMenuItem := True;
  mAction.Name := 'actAddDQ';
  mAction.Caption := '##Add DocQueues##';
  mAction.Hint := 'Doplní řady';
  mAction.Category := 'tabList';
  mAction.OnExecute := @AddDQ;

    mAction := Self.GetNewAction;
  mAction.ShowControl := True;
  mAction.ShowMenuItem := True;
  mAction.Name := 'actAddLim';
  mAction.Caption := '##Import Limits##';
  mAction.Hint := 'Limits';
  mAction.Category := 'tabList';
  mAction.OnExecute := @AddLim; }
end;

Procedure AddLim(Sender:TComponent);
var
 mSite:TSiteForm;
 mOpenDlg: TOpenDialog;
 mOS:TNxCustomObjectSpace;
 mList:TStringList;
 i:integer;
 mBO:TNxCustomBusinessObject;
mTempStr, mEAN, mName, mLow, mHigh, mStore,mStoreCard_ID, mSSC_ID:string;
begin
 mSite:=TComponent(Sender).BusRollSite;
 mOS:=mSite.BaseObjectSpace;
 mOpenDlg:=TOpenDialog.Create(sender);
 mOpenDlg.Title := 'Import z CSV';
 mOpenDlg.Filter := 'Soubory CSV (*.csv)| *.csv';
 if mOpenDlg.Execute then begin
  try
   mList:=TStringList.Create;
   mList.LoadFromFile(mOpenDlg.FileName);
   WaitWin.StartProgress('Čekejte, prosím ...', '', mList.Count);
   for i:=1 to mlist.Count-1 do begin
     mTempStr:=mList.Strings[i];
     mEAN:=NxTrapStrTrim(mTempStr,';');
     mName:=NxTrapStrTrim(mTempStr,';');
     mLow:=NxTrapStrTrim(mTempStr,';');
     mHigh:=NxTrapStrTrim(mTempStr,';');
     mStoreCard_ID:=GetStoreCard(mOS,mEAN,mName);
     if not(NxIsEmptyOID(mStoreCard_ID)) then begin
       mSSC_ID:=mOS.SQLSelectFirstAsString('Select id from storesubcards where store_id=''~00000011Y'' and storecard_id='+QuotedStr(mStoreCard_ID),'');
       mBO:=mOS.CreateObject(Class_StoreSubCard);
       if NxIsEmptyOID(mSSC_ID) then begin
         mBO.new;
         mbo.Prefill;
         mBO.SetFieldValueAsString('StoreCard_ID',mStoreCard_ID);
         mBO.SetFieldValueAsString('Store_ID','~00000011Y');
       end else begin
         mBO.load(mSSC_ID,nil);
       end;
       mbo.SetFieldValueAsFloat('LowLimitQuantity',NxIBStrToFloat(mLow));
       mbo.SetFieldValueAsFloat('HighLimitQuantity',NxIBStrToFloat(mHigh));
       mbo.save;
       mbo.free;
     end;
     WaitWin.ChangeText(IntToStr(i+1) + ' / ' + IntToStr(mList.Count));
     WaitWin.StepIt;
   end;
   WaitWin.Stop;
  except
   NxShowSimpleMessage(ExceptionMessage,mSite);
   WaitWin.Stop;
  end;
 end;
end;

Procedure AddDQ(sender:TComponent);
var
 mSite:TSiteForm;
 mOS:TNxCustomObjectSpace;
 mList, mDQList:TStringList;
 i,j:integer;
 mBO:TNxCustomBusinessObject;
begin
  mDQList:=TStringList.Create;
  mDQList.Add('K200000101');
  mDQList.Add('N200000101');
  mDQList.Add('1200000101');
  mDQList.Add('9000000101');
  mDQList.Add('3200000101');
  mDQList.Add('4300000101');
  mDQList.Add('L000000101');
  mDQList.Add('3300000101');
  mDQList.Add('Z100000101');
  mDQList.Add('W100000101');
  mDQList.Add('0200000101');
  mDQList.Add('M000000101');
  mDQList.Add('P200000101');
  mDQList.Add('X100000101');
  mDQList.Add('O200000101');
  mSite:=TComponent(sender).BusRollSite;
  mList:=TStringList.create;
  mOS:=TBusRollSiteForm(mSite).BaseObjectSpace;
  TBusRollSiteForm(mSite).List.GetSelectedId(mList);
  for i:=0 to mList.count-1 do begin
    for j:=0 to mDQList.count-1 do begin
      mBO:=mOS.CreateObject(Class_StoresDocQueue);
      mbo.new;
      mbo.prefill;
      mbo.SetFieldValueAsString('Store_ID',mlist.Strings[i]);
      mbo.SetFieldValueAsString('DocQueue_ID',mDQList.strings[j]);
      mbo.save;
    end;
  end;
end;

Procedure ImportXML(Sender:TComponent);
var
 mSite:TSiteForm;
 mOpenDlg: TOpenDialog;
 mOS:TNxCustomObjectSpace;
 i,j, k, mCount, maxCount: Integer;
 mXML, EntryNode, currNode, mCurrElement: Variant;
 mCode, mName, mfileName, mStreet:string;
 mBO:TNxCustomBusinessObject;
begin
  j:=0;
  maxCount:=2000000;
  mSite := TComponent(Sender).Site;
  mOS:=msite.BaseObjectSpace;
  mOpenDlg:=TOpenDialog.Create(sender);
  mOpenDlg.Title := 'Import z XML';
  mOpenDlg.Filter := 'Soubory XML (*.xml)| *.xml';
  if mOpenDlg.Execute then begin
     mfileName:=mOpenDlg.FileName;
     mXML := CreateOleObject('Msxml2.DOMDocument.6.0');
     try
      mXML.async := false;
      mXML.load(mFileName);
      EntryNode := mXML.getElementsByTagName('Warehouse');
      mCount := min(maxCount,EntryNode.Length);
      WaitWin.StartProgress('Čekejte, prosím ...', '', mCount);
      for i := 0 to  mCount-1 do begin
        currNode := EntryNode.Item(i);
        mCode:= currNode.attributes.getNamedItem('code').Text;
        mName:= currNode.selectSingleNode('Description').text;
        //mStreet:=mCurrElement.selectSingleNode('AddressLine1').Text;
        mBO:=mOS.CreateObject(Class_Store);
        mBO.New;
        mBO.Prefill;
        mBO.SetFieldValueAsString('Code', AnsiLeftStr(mCode,5));
        mBO.SetFieldValueAsString('Name', AnsiLeftStr(mName,30));
        mBO.SetFieldValueAsString('Account_ID','6A00000101');
        mBo.SetFieldValueAsString('FirstOpenPeriod_ID','1000000101');
        mBO.save;
        mBO.free;
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
 if NxIsNumeric(aCode) and (Length(aCode)=13) then begin
   mStoreCard_ID:=aOS.SQLSelectFirstAsString('SELECT  A.id FROM StoreCards A WHERE (((A.EAN LIKE N'+QuotedStr(aCode)+' ESCAPE '+QuotedStr('~')+') OR '+
                                             '(A.ID IN (SELECT SU.Parent_ID FROM StoreEANs SE JOIN StoreUnits SU ON SE.Parent_Id = SU.Id '+
                                             'WHERE SU.Parent_ID = A.ID AND SE.Ean LIKE N'+QuotedStr(aCode)+' ESCAPE '+QuotedStr('~')+')))) AND A.Hidden = '+Quotedstr('N'),'');
 end
  else mStoreCard_ID:=aOS.SQLSelectFirstAsString('Select id from storecards where code='+QuotedStr(aCode)+' and name like N'+QuotedStr(aName)+' and hidden='+QuotedStr('N'),'');

 Result:=mStoreCard_ID;
end;

begin
end.