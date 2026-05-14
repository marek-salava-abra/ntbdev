const
  cSQL_X_Aktivni = ' AND X_Aktivni = ''A'' ';

procedure InitSite_Hook(Self: TSiteForm);
var
  mAction, mAction2: TBasicAction;
begin
  mAction := Self.GetNewAction;
  mAction.ShowControl := True;
  mAction.ShowMenuItem := True;
  mAction.Name := 'actImportComGate';
  mAction.Caption := 'Import CSV';
  mAction.Hint := 'Naimportuje data z CSV';
  mAction.Category := 'tabDetail';
  mAction.OnExecute := @ImportData;
end;

Procedure ImportData(Sender:TComponent);
Var
 mSite:TSiteForm;
 mOS:TNxCustomObjectSpace;
 mList:TStringList;
 i:integer;
 mOpenDlg:TOpenDialog;
 mRow, mStoreCardBO:TNxCustomBusinessObject;
 mTempStr:string;
 mStoreCard_ID, mStoreCardcategory_ID,mStoreCardCategoryCode, mStoreCardCode:string;
begin
  mSite:=TComponent(sender).BusRollSite;
  mOS:=mSite.BaseObjectSpace;
  mList:=tstringlist.create;
  mOpenDlg := TOpenDialog.Create(Sender);
  if mOpenDlg.Execute then begin
    mList.LoadFromFile(mOpenDlg.FileName);
    if mList.Count>0 then begin
          WaitWin.StartProgress('Čekejte, prosím ...', '', mList.Count);
           for i:=0 to mlist.count-1 do begin
           mTempStr:=mlist.Strings[i];
           mStoreCardCode:=NxTrim(NxTrapStr(mTempStr,';'),'"');
           mStoreCardCategoryCode:=NxTrim(NxTrapStr(mTempStr,';'),'"');
           mStoreCard_ID:=mOS.SQLSelectFirstAsString('Select id from storecards where hidden=''N'' '+cSQL_X_Aktivni+' and code='+QuotedStr(mStoreCardCode),'');
           mStoreCardcategory_ID:=mOS.SQLSelectFirstAsString('Select id from storecardcategories where hidden=''N'' and code='+QuotedStr(mStoreCardCategoryCode),'');
           if not(NxIsEmptyOID(mStoreCard_ID)) and not(NxIsEmptyOID(mStoreCardcategory_ID)) then begin
               mStoreCardBO:=mOS.CreateObject(class_storecard);
               mStorecardBO.Load(mStoreCard_ID,nil);
               mStoreCardBO.SetFieldValueAsString('StoreCardCategory_ID',mStoreCardcategory_ID);
               mStoreCardBO.save;
               mStoreCardBO.free;
           end;
           WaitWin.ChangeText(IntToStr(1+i) + ' / ' + IntToStr(mList.Count));
           WaitWin.StepIt;
           end;
           WaitWin.Stop;

          end;
       NxShowSimpleMessage('Nahráno '+IntToStr(mlist.count-1)+' řádků.',mSite);
      end;
end;

begin
end.