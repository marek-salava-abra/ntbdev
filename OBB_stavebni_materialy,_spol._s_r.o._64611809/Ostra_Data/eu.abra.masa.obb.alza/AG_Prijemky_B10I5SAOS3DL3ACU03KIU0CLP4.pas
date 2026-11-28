uses '.const';

procedure InitSite_Hook(Self: TSiteForm);
var
  mAction: TAction;
  mUser:TNxCustomBusinessObject;
begin
  mUser:=Self.BaseObjectSpace.CreateObject(Class_SecurityUser);
  mUser.load(NxGetActualUserID(self.BaseObjectSpace),nil);
  if mUser.GetFieldValueAsBoolean('X_Alza') then begin
    mAction := Self.GetNewAction;
    mAction.ShowControl := True;
    mAction.ShowMenuItem := True;
    mAction.Caption := 'Import Alza';
    mAction.Hint := 'Naimportuje Alza kupóny';
    mAction.Category := 'tabDetail';
    mAction.OnExecute := @ImportAlza;
  end;
end;

Procedure ImportAlza(Sender:TComponent);
var
 mSite:TSiteForm;
 mOS:TNxCustomObjectSpace;
 mOpenDlg:TOpenDialog;
 mList, mNotFoundList:TStringList;
 i, mIndex:integer;
 mBO, mRowBO, mDRBBO, mStoreBatchBO :TNxCustomBusinessObject;
 mRows, mDocRowBatches:TNxCustomBusinessMonikerCollection;
 mControl: TControl;
 mDataset: TNxRowsObjectDataSet;
 mStoreCard_ID, mTempStr, mMessage, mStoreBatch_ID:string;
 mEvCis, mCastka, mMena, mStav, mPlatnyOd, mPlatnyDo, mAlzaCode, mStoreCardCode:string;
begin
 mSite:=TComponent(sender).DynSite;
 mOS:=TDynSiteForm(mSite).BaseObjectSpace;
 if not(TDynSiteForm(mSite).Edit) then begin
  NxShowSimpleMessage('Nejste ve stavu editace, soubor nepůjde naimportovat.',mSite);
  exit;
 end;
 mMessage:='';
 mOpenDlg := TOpenDialog.Create(Sender);
 mOpenDlg.Title := 'Import dat od Alza';
 mOpenDlg.Filter := 'Soubory CSV (*.csv)| *.csv';
 if mOpenDlg.Execute then begin
    mList:=TStringList.Create;
    mList.LoadFromFile(mOpenDlg.FileName);
    if mList.Count>0 then begin
      //kontrola obsahu, jestli poznám všechny skladové karty
       mNotFoundList:=TStringList.Create;
       WaitWin.StartProgress('Čekejte, prosím ...', '', mList.Count);
       for i:=1 to mlist.Count-1 do begin
         mTempStr:=mlist.Strings[i];
         mEvCis:=NxTrapStrTrim(mTempStr,';');
         mCastka:=NxTrapStrTrim(mTempStr,';');
         mMena:=NxTrapStrTrim(mTempStr,';');
         mStav:=NxTrapStrTrim(mTempStr,';');
         mPlatnyOd:=NxTrapStrTrim(mTempStr,';');
         mPlatnyDo:=NxTrapStrTrim(mTempStr,';');
         //NxShowSimpleMessage(DateToStr(StrToDate(AnsiLeftStr(mPlatnyDo,10))),mSite);
         mAlzaCode:=NxTrapStrTrim(mTempStr,';');
         mStoreCardCode:='ALZA'+IntToStr(trunc(NxIBStrToFloat(mCastka)));
         mStoreCard_ID:=mOS.SQLSelectFirstAsString('Select id from storecards where code='+QuotedStr(mStoreCardCode)+' and hidden=''N'' and storecardcategory_id='+QuotedStr(cStoreCardCategory_ID),'');
         if NxIsEmptyOID(mStoreCard_ID) then begin
            mIndex:=mNotFoundList.IndexOf(mStoreCardCode);
            if mIndex<0 then mNotFoundList.Add(mStoreCardCode);
         end;
         WaitWin.ChangeText(IntToStr(i) + ' / ' + IntToStr(mList.Count));
         WaitWin.StepIt;
       end;
       WaitWin.Stop;
       if mNotFoundList.count>0 then begin
         for i:=0 to mNotFoundList.count-1 do begin
           mMessage:=mMessage+#13#10+mNotFoundList.strings[i];
         end;
         NxShowSimpleMessage('Nenalezeny kódy karet:'+mMessage+#13#10+#13#10+'Ukončuji.',mSite);
         exit;
       end;
      //konec kontroly obsahu
      mBO:=TDynSiteForm(mSite).CurrentObject;
      mRows:=mBO.GetLoadedCollectionMonikerForFieldCode(mbo.GetFieldCode('Rows'));
      for i:=0 to mRows.count-1 do begin
       mRows.BusinessObject[i].MarkForDelete;
      end;
      mControl:= mSite.FindChildControl('tabRows.grdRows');
      mDataset := TNxRowsObjectDataSet(TMultiGrid(mControl).DataSource.DataSet);
      if Assigned(mDataset) then begin
        mDataSet.DisableControls;
        WaitWin.StartProgress('Čekejte, prosím ...', '', mList.Count);
        for i:=1 to mlist.Count-1 do begin
            try
             mTempStr:=mlist.Strings[i];
             mEvCis:=NxTrapStrTrim(mTempStr,';');
             mCastka:=NxTrapStrTrim(mTempStr,';');
             mMena:=NxTrapStrTrim(mTempStr,';');
             mStav:=NxTrapStrTrim(mTempStr,';');
             mPlatnyOd:=NxTrapStrTrim(mTempStr,';');
             mPlatnyDo:=NxTrapStrTrim(mTempStr,';');
             mAlzaCode:=NxTrapStrTrim(mTempStr,';');
             mStoreCardCode:='ALZA'+IntToStr(trunc(NxIBStrToFloat(mCastka)));
             //NxShowSimpleMessage(mEvCis,mSite);
             mStoreCard_ID:=mOS.SQLSelectFirstAsString('Select id from storecards where code='+QuotedStr(mStoreCardCode)+' and hidden=''N'' and storecardcategory_id='+QuotedStr(cStoreCardCategory_ID),'');
             if not(NxIsEmptyOID(mStoreCard_ID)) then begin
                 mRowBO:=mDataset.CreateBusinessObject;
                 mRowBO.Prefill;
                 mRowBO.SetFieldValueAsString('Store_ID',cStore_ID);
                 mRowBo.SetFieldValueAsString('StoreCard_ID', mStoreCard_ID);
                 mRowBO.SetFieldValueAsFloat('Quantity',1);
                 mRowBO.SetFieldValueAsFloat('UnitPrice',NxIBStrToFloat(mCastka));
                 mRowBO.SetFieldValueAsString('Division_ID',cDivision_ID);
                 mStoreBatch_ID:=mOS.SQLSelectFirstAsString('Select id from StoreBatches where name='+QuotedStr(mEvCis)+' and storecard_id='+QuotedStr(mStoreCard_ID)+' and hidden=''N'' ','');
                 if NxIsEmptyOID(mStoreBatch_ID) then begin
                   mStoreBatchBO:=mOS.CreateObject(Class_StoreBatch);
                   mStoreBatchBO.New;
                   mStoreBatchBO.SetFieldValueAsString('StoreCard_ID',mStoreCard_ID);
                   mStoreBatchBO.SetFieldValueAsString('Name', mEvCis);
                   mStoreBatchBO.SetFieldValueAsString('Specification', mEvCis);
                   mStoreBatchBO.SetFieldValueAsDateTime('ExpirationDate$DATE',StrToDate(AnsiLeftStr(mPlatnyDo,10)));
                   mStoreBatchBO.SetFieldValueAsString('U_AlzaCode',mAlzaCode);
                   mStoreBatchBO.save;
                   mStoreBatch_ID:=mStoreBatchBO.OID;
                   mStoreBatchBO.free;
                 end;
                 mDocRowBatches:=mRowBO.GetLoadedCollectionMonikerForFieldCode(mRowBO.GetFieldCode('DocRowBatches'));
                 mDRBBO:=mDocRowBatches.AddNewObject;
                 mDRBBO.SetFieldValueAsBoolean('NewBatch',False);
                 mDRBBO.SetFieldValueAsString('StoreBatch_ID',mStoreBatch_ID);
                 //mDRBBO.SetFieldValueAsDateTime('NewBatchExpirationDate$DATE',NxStrToDate(mPlatnyDo));
             end;
            except
             NxShowSimpleMessage('Nepovedlo se to'+#13#10+ExceptionMessage,mSite);
             WaitWin.Stop;
            end;
            WaitWin.ChangeText(IntToStr(i) + ' / ' + IntToStr(mList.Count));
            WaitWin.StepIt;
          end;
         WaitWin.Stop;
      end;
      TDynSiteForm(mSite).ActiveDataSet.UpdateFields; //Aby se o změně dozvěděl hlavičkový dataset
      mDataset.RefreshAndRestoreLastSelectedItem;
      mDataSet.EnableControls;
    end;
 end;
end;

begin
end.