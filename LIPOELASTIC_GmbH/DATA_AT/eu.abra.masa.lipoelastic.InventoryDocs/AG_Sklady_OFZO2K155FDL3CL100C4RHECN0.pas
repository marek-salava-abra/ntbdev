uses '.fce';

procedure InitSite_Hook(Self: TSiteForm);
var
  mAction:TAction;
begin
  mAction := Self.GetNewAction;
  mAction.ShowControl := True;
  mAction.ShowMenuItem := True;
  mAction.Name := 'actInventory';
  mAction.Caption := '## Import XLS Data##';
  mAction.Hint := 'Import Data to Generate Transformations';
  mAction.Category := 'tabList';
  mAction.OnExecute := @CreateStoreDocs;
end;



Procedure CreateStoreDocs(Sender:TComponent);
var
 mSite:TSiteForm;
 mOpenDlg: TOpenDialog;
 mOS:TNxCustomObjectSpace;
 i,j,k,l,m,mCount:integer;
 mErrList, mStateOfDateList, mList, mFinalStateOfDateList, mBatchList, mExcelList, mMissingList:TStringList;
 mExcel, mWB, mSheet: Variant;
 mBO:TNxCustomBusinessObject;
 mQuantity:Extended;
 mDateTo:String;
 mStoreCard_ID, mStoreBatch_ID:string;
 mSeldef,mSQL, mTempStr, mTempStr2, mStoreCardEAN, mStoreBatchName, mBatchName:string;
 mCategory:Integer;
 mQuantityStr, mBatchQuantityStr, mBillOfDelivery_ID, mInventoryOverPlus_ID,mInventoryShortFall_ID:string;
 mMyDate:Extended;
 mBODList, mRCList:TStringList;
begin
 mSite:=TComponent(Sender).BusRollSite;
 mOS:=mSite.BaseObjectSpace;
 mBO:=TBusRollSiteForm(mSite).CurrentObject;
 if Assigned(mBO) then begin
    {if NxIsEmptyOID(mBO.GetFieldValueAsString('X_Firm_ID')) then begin
     NxShowSimpleMessage('Store without company, exiting.', mSite);
     exit;
    end;  }
    mMyDate:=Date;
    if GetDate(mSite, mMyDate) then begin
      mStateOfDateList:=TStringList.Create;
      mDateTo:=NxFloatToIBStr(mMyDate+1);
      mList:=TStringList.Create;
      mList.add(mbo.OID);
      mSeldef:= Copy(IntToStr(Round(Frac(Now)*100000))+NxGetComputerName,1,10);
      StringsToSelDat(mOS,mSeldef,mList);
      mSQL:='select storecard_id,BegQuantity+Quantity from StoreFlowsByDates(-1, '+mDateTo+', '+QuotedStr(mSeldef)+', '''', '''', '''', '''', '''', '''', ''0'', ''0'', ''0'', ''0'', '''', '''')  A WHERE (NOT (  A.BegQuantity + A.quantity = 0 )) ';
      mStateOfDateList:=TStringList.create;
      mFinalStateOfDateList:=TStringList.create;
      mOS.SQLSelect(mSQL, mStateOfDateList);
      if mStateOfDateList.count>0 then begin
         mFinalStateOfDateList:=TStringList.create;
         for i:=0 to mStateOfDateList.count-1 do begin
           mTempStr:=mStateOfDateList.strings[i];
           mStoreCard_ID:=NxTrapStrTrim(mTempStr,';');
           mQuantityStr:=NxTrapStrTrim(mTempStr,';');
           mCategory:=mOS.SQLSelectFirstAsInteger('Select category from storecards where id='+QuotedStr(mStoreCard_ID),99);
           if mCategory in [1,2] then begin
             mBatchList:=TStringList.Create;
             mSQL:='select StoreBatch_ID,BegQuantity+Quantity from StoreBatchesFlowsByDates(-1, '+mDateTo+', '+
                   QuotedStr('')+', '''', '''', '''', '''', '''', '''', '''', ''0'', ''0'', ''0'', ''0'', '+QuotedStr(mBO.OID)+','+
                   QuotedStr(mStoreCard_ID)+', '''')  A WHERE (NOT (  A.BegQuantity + A.quantity = 0 )) ';
             mOS.SQLSelect(mSQL,mBatchList);
              if mBatchList.count>0 then begin
                for j:=0 to mBatchList.count-1 do begin
                  mTempStr2:=mBatchList.Strings[j];
                  mStoreBatch_ID:=NxTrapStrTrim(mTempStr2,';');
                  mBatchQuantityStr:=NxTrapStrTrim(mTempStr2,';');
                  mBatchName:=mOS.SQLSelectFirstAsString('Select name from storebatches where id='+QuotedStr(mStoreBatch_ID),'');
                  mFinalStateOfDateList.Add(mStoreCard_ID+';'+mStoreBatch_ID+';'+mBatchQuantityStr+';'+mBatchName);
                end;
              end;
             mBatchList.free;
           end else begin
             mFinalStateOfDateList.Add(mStoreCard_ID+';;'+mQuantityStr+';');
           end;
         end;
       end;
       mOpenDlg:=TOpenDialog.Create(sender);
       mOpenDlg.Title := 'Import XLS';
       mOpenDlg.Filter := 'Excel files (*.xls, *.xlsx)| *.xls;*.xlsx';
       mErrList:=tstringlist.Create;
       if mOpenDlg.Execute then begin
        try
                mExcel := CreateOleObject('Excel.Application');
                mWB := mExcel.Workbooks.Open(mOpenDlg.FileName);
                mSheet := mWB.Sheets[1];
                i:=2;
                j:=mSheet.UsedRange.Rows.Count+1;
                mExcelList:=TStringList.Create;
                mErrList:=TStringList.Create;
                WaitWin.StartProgress('Please, wait ...', '', j);
                while i<j  do begin
                  WaitWin.ChangeText(IntToStr(i) + ' / ' + IntToStr(j));
                  mStoreCard_ID:='';
                  mStoreBatch_ID:='';
                  mQuantity:=0;
                  mStoreBatchName:='';
                  mStoreCardEAN:=AnsiLeftStr(VarToStr(mSheet.Cells[i, 1]),13);
                  mStoreBatchName:=NxTrim(VarToStr(mSheet.Cells[i, 2]),' ');
                  mQuantityStr:=VarToStr(mSheet.Cells[i, 3]);
                  mStoreCard_ID:=mOS.SQLSelectFirstAsString('SELECT  A.id FROM StoreCards A WHERE (((A.EAN LIKE N'+QuotedStr(mStoreCardEAN)+' ESCAPE '+QuotedStr('~')+') OR '+
                                             '(A.ID IN (SELECT SU.Parent_ID FROM StoreEANs SE JOIN StoreUnits SU ON SE.Parent_Id = SU.Id '+
                                             'WHERE SU.Parent_ID = A.ID AND SE.Ean LIKE N'+QuotedStr(mStoreCardEAN)+' ESCAPE '+QuotedStr('~')+')))) AND A.Hidden = '+Quotedstr('N'),'');
                  mStoreBatch_ID:=mOS.SQLSelectFirstAsString('SELECT  id from storebatches where storecard_id='+QuotedStr(mStoreCard_ID)+' and name='+QuotedStr(mStoreBatchName)+' and hidden=''N'' ','');
                  if NxIsEmptyOID(mStoreCard_ID) then mErrList.add('EAN not found: #'+mStoreCardEAN+'#');
                  mCategory:=mOS.SQLSelectFirstAsInteger('Select category from storecards where id='+QuotedStr(mStoreCard_ID),99);
                  if NxIsEmptyOID(mStoreBatch_ID) and (mCategory in [1,2]) then mErrList.add('Batch not found: '+mStoreBatchName);
                  mExcelList.Add(mStoreCard_ID+';'+mStoreBatch_ID+';'+mQuantityStr+';'+mStoreBatchName);
                  inc(i);
                 WaitWin.StepIt;
                end;
               WaitWin.Stop;
               mWB.close;

           except
            WaitWin.Stop;
            mWB.close;
            NxShowSimpleMessage(ExceptionMessage,msite);
        end;
       end;
       //NxShowSimpleMessage(mFinalStateOfDateList.text,mSite);
       //NxShowSimpleMessage(mExcelList.text,mSite);
       mFinalStateOfDateList.SaveToFile('c:\AbraGen\inventura\finalstate.csv');
       mExcelList.SaveToFile('c:\AbraGen\inventura\excel.csv');
       mBODList:=TStringList.Create;
       mRCList:=TStringList.Create;
       FindStoreNotInExcelOrDiffQty(mFinalStateOfDateList,mExcelList, mBODList);
       FindExcelMoreThanStore(mFinalStateOfDateList,mExcelList, mRCList);
       if mBODList.Count>0 then begin
         //NxShowSimpleMessage('DL'+NxCrLf+mBODList.text, mSite);
           mBODList.SaveToFile('c:\AbraGen\inventura\manko.csv');
           mInventoryShortFall_ID:=CreateInventoryShortFall(mOS, mBODList, mBO.OID,mMyDate);
           if not(NxIsEmptyOID(mInventoryShortFall_ID)) then
             mSite.ShowSite(Site_InventoryShortFalls,true,'QueryByUserDynSQLCondition;A.ID ='+QuotedStr(mInventoryShortFall_ID)+';New docs');
       end;
       if mRCList.Count>0 then begin
         //NxShowSimpleMessage('PR'+NxCrLf+mRCList.text, mSite);
           mRCList.SaveToFile('c:\AbraGen\inventura\prebytek.csv');
           mInventoryOverPlus_ID:=CreateInventoryOverPlus(mOS, mRCList, mBO.OID,mMyDate);
           if not(NxIsEmptyOID(mInventoryOverPlus_ID)) then
             mSite.ShowSite(Site_InventoryOverpluses,true,'QueryByUserDynSQLCondition;A.ID ='+QuotedStr(mInventoryOverPlus_ID)+';New docs');
       end;
       if mErrList.Count>0 then begin
         //NxShowSimpleMessage('error'+NxCrLf+mErrList.text, mSite);
       end;

       //mErrList.SaveToFile('C:\AbraDE\'+FormatDateTime('YYYYMMDDHHNNSS',Now)+'_DIP_error.txt');
    end else begin
     NxShowSimpleMessage('Data can only be imported into an existing store.', mSite);
   end;
 end;
end;



begin
end.