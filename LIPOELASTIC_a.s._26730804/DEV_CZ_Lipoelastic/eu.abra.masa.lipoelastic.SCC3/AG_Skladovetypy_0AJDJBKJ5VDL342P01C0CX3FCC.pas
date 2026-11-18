procedure InitSite_Hook(Self: TSiteForm);
var
  mAction: TBasicAction;
begin
  mAction := Self.GetNewAction;
  mAction.ShowControl := True;
  mAction.ShowMenuItem := True;
  mAction.Caption := '###Import sklad###';
  mAction.Hint := 'Naimportuje záložku Skladové účtování';
  mAction.Category := 'tabList';
  mAction.OnExecute := @ImportStore;
  mAction := Self.GetNewAction;
  mAction.ShowControl := True;
  mAction.ShowMenuItem := True;
  mAction.Caption := '###Import NV###';
  mAction.Hint := 'Naimportuje záložku náklady a výnosy';
  mAction.Category := 'tabList';
  mAction.OnExecute := @ImportCG;
end;

Procedure ImportStore(Sender:TComponent);
var
 mSite:TSiteForm;
 mOS:TNxCustomObjectSpace;
 mBO:TNxCustomBusinessObject;
 i,j:integer;
 mList:TStringList;
 mOpenDlg:TOpenDialog;
 mTempString, mCategory, mStore, mStoreAccount, mCategory_ID, mStore_ID, mStoreAccount_ID, mPosIndex :string;
begin
 mSite:=TComponent(Sender).BusRollSite;
 mOS:=mSite.BaseObjectSpace;
 mOpenDlg := TOpenDialog.Create(TComponent(Sender));
 mOpenDlg.Options:=[ofAllowMultiSelect];
 mOpenDlg.DefaultExt:='csv';
  if mOpenDlg.Execute then begin
    mList:=TStringList.create;
    mList.LoadFromFile(mOpenDlg.FileName);
    WaitWin.StartProgress('Čekejte, prosím ...', '', mList.Count);
    for i:=0 to mList.count-1 do begin
     mTempString:=mList.strings[i];
     mCategory:=NxTrapStrTrim(mTempString,';');
     mStore:=NxTrapStrTrim(mTempString,';');
     mStoreAccount:=NxTrapStrTrim(mTempString,';');
     mCategory_ID:=mOS.SQLSelectFirstAsString('Select id from storecardcategories where hidden='+QuotedStr('N')+'and code='+QuotedStr(mCategory),nil);
     mStore_ID:=mOS.SQLSelectFirstAsString('Select id from Stores where hidden='+QuotedStr('N')+'and code='+QuotedStr(mStore),nil);
     mStoreAccount_ID:=mOS.SQLSelectFirstAsString('Select id from Accounts where hidden='+QuotedStr('N')+'and code='+QuotedStr(mStoreAccount),nil);
     if not(NxIsEmptyOID(mCategory_ID)) and not(NxIsEmptyOID(mStore_ID)) and not(NxIsEmptyOID(mStoreAccount_ID)) then begin
       j:=mOS.SQLSelectFirstAsInteger('select count(id) from defrolldata where clsid='+QuotedStr('2TIIQXNXIXK4B5CZUIZ20K2W10')+' and X_parent_id='+QuotedStr(mCategory_ID)+' and X_Rel_def='+QuotedStr('01'));
       mPosIndex:=AnsiRightStr('0'+IntToStr(j+1),2);
       mBO:=mOS.CreateObject('2TIIQXNXIXK4B5CZUIZ20K2W10');
       mBO.New;
       mBo.SetFieldValueAsString('X_parent_ID',mCategory_ID);
       mBO.SetFieldValueAsString('X_Store_ID',mStore_ID);
       mBO.SetFieldValueAsString('X_StoreAccount_ID',mStoreAccount_ID);
       mBO.SetFieldValueAsString('X_rel_def','01');
       mBO.SetFieldValueAsString('X_posindex',mPosindex);
       mbo.save;
       mbo.free;
     end;
     WaitWin.ChangeText(IntToStr(i+1) + ' / ' + IntToStr(mList.Count));
     WaitWin.StepIt;
    end;
   WaitWin.Stop;
  end;
end;

Procedure ImportCG(Sender:TComponent);
var
 mSite:TSiteForm;
 mOS:TNxCustomObjectSpace;
 mBO:TNxCustomBusinessObject;
 i,j:integer;
 mList:TStringList;
 mOpenDlg:TOpenDialog;
 mTempString, mCategory, mStore, mCostAccount, mGainAccount, mGainAccount_ID, mCategory_ID, mAccRegion_ID, mCostAccount_ID, mPosIndex :string;
begin
 mSite:=TComponent(Sender).BusRollSite;
 mOS:=mSite.BaseObjectSpace;
 mOpenDlg := TOpenDialog.Create(TComponent(Sender));
 mOpenDlg.Options:=[ofAllowMultiSelect];
 mOpenDlg.DefaultExt:='csv';
  if mOpenDlg.Execute then begin
    mList:=TStringList.create;
    mList.LoadFromFile(mOpenDlg.FileName);
    WaitWin.StartProgress('Čekejte, prosím ...', '', mList.Count);
    for i:=1 to mList.count-1 do begin
     mTempString:=mList.strings[i];
     mCategory:=NxTrapStrTrim(mTempString,';');
     mStore:=NxTrapStrTrim(mTempString,';');
     mCostAccount:=NxTrapStrTrim(mTempString,';');
     mGainAccount:=NxTrapStrTrim(mTempString,';');
     mCategory_ID:=mOS.SQLSelectFirstAsString('Select id from storecardcategories where hidden='+QuotedStr('N')+'and code='+QuotedStr(mCategory),nil);
     mAccRegion_ID:=mOS.SQLSelectFirstAsString('Select id from defrolldata where clsid=''3ALUAMFUYQI411CNBR5XTGAUES'' and hidden='+QuotedStr('N')+'and code='+QuotedStr(mStore),nil);
     mCostAccount_ID:=mOS.SQLSelectFirstAsString('Select id from Accounts where hidden='+QuotedStr('N')+'and code='+QuotedStr(mCostAccount),nil);
     mGainAccount_ID:=mOS.SQLSelectFirstAsString('Select id from Accounts where hidden='+QuotedStr('N')+'and code='+QuotedStr(mGainAccount),nil);
     if not(NxIsEmptyOID(mCategory_ID)) and not(NxIsEmptyOID(mAccRegion_ID)) then begin
       j:=mOS.SQLSelectFirstAsInteger('select count(id) from defrolldata where clsid='+QuotedStr('2TIIQXNXIXK4B5CZUIZ20K2W10')+' and X_parent_id='+QuotedStr(mCategory_ID)+' and X_Rel_def='+QuotedStr('02'));
       mPosIndex:=AnsiRightStr('0'+IntToStr(j+1),2);
       try
       mBO:=mOS.CreateObject('2TIIQXNXIXK4B5CZUIZ20K2W10');
       mBO.New;
       mbo.SetFieldValueAsString('Code',mCategory);
       mbo.SetFieldValueAsString('Name',mStore);
       mBo.SetFieldValueAsString('X_parent_ID',mCategory_ID);
       mBO.SetFieldValueAsString('X_AccRegion_ID',mAccRegion_ID);
       mBO.SetFieldValueAsString('X_CostAccount_ID',mCostAccount_ID);
       mBO.SetFieldValueAsString('X_GainAccount_ID',mGainAccount_ID);
       mBO.SetFieldValueAsString('X_rel_def','02');
       mBO.SetFieldValueAsString('X_posindex',mPosindex);
       mbo.save;
       mbo.free;
       except

       end;
     end;
     WaitWin.ChangeText(IntToStr(i+1) + ' / ' + IntToStr(mList.Count));
     WaitWin.StepIt;
    end;
   WaitWin.Stop;
  end;
end;

begin
end.