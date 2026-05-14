procedure InitSite_Hook(Self: TSiteForm);
var
  mAction, mAction2: TBasicAction;
begin
  mAction := Self.GetNewAction;
  mAction.ShowControl := True;
  mAction.ShowMenuItem := True;
  mAction.Name := 'actImportLLQ';
  mAction.Caption := 'Import limitu';
  mAction.Hint := 'Naimportuje spodní limit struktura csv '+#13#10+'import očekává hlavičkový řádek!'+#13#10+'kód;sklad;limit';
  mAction.Category := 'tabList';
  mAction.OnExecute := @ImportData;
end;

Procedure ImportData(sender:TComponent);
var
 mSite:TSiteForm;
 mOS:TNxCustomObjectSpace;
 mList:TStringList;
 mSSCBO:TNxCustomBusinessObject;
 i,j,k,l,m,n,o:integer;
 mOpenDlg:TOpenDialog;
 mCode, mStore, mQuatity, mTempStr, mStoreCard_ID, mStore_ID, mStoreSubCard_ID:String;
begin
  mSite:=TComponent(sender).DynSite;
  mOS:=mSite.BaseObjectSpace;
  if True then begin
    mOpenDlg := TOpenDialog.Create(Sender);
    mOpenDlg.Title := 'Import z CSV';
    mOpenDlg.Filter := 'Soubory aplikace Excel (*.csv)| *.csv';
      if mOpenDlg.Execute then begin
        try
          mList:=TStringList.create;
          mList.LoadFromFile(mOpenDlg.FileName);
          n:=mList.Count;
           WaitWin.StartProgress('Čekejte, prosím ...', '',  n);
                 for i:=0 to mlist.count-1 do begin
                    mTempStr:=mList.Strings[i];
                    mCode:=NxTrapStr(mTempStr,';');
                    mStore:=NxTrapStr(mTempStr,';');
                    mQuatity:=NxTrapStr(mTempStr,';');
                    mStoreCard_ID:=mOS.SQLSelectFirstAsString('Select id from storecards where code='+QuotedStr(mCode)+' and hidden='+QuotedStr('N'),'');
                    mStore_ID:=mOS.SQLSelectFirstAsString('Select id from stores where code='+QuotedStr(mStore)+' and hidden='+QuotedStr('N'),'');
                    if not(NxIsEmptyOID(mStoreCard_ID)) and not(NxIsEmptyOID(mStore_ID)) then begin
                       OutputDebugString('skladová karta: '+mStoreCard_ID+' sklad: '+mStore_ID);
                       mStoreSubCard_ID:=mOS.SQLSelectFirstAsString('Select id from storesubcards where storecard_id='+QuotedStr(mStoreCard_ID)+' and store_id='+QuotedStr(mStore_ID),'');
                       mSSCBO:=mOS.CreateObject(Class_StoreSubCard);
                       if NxIsEmptyOID(mStoreSubCard_ID) then begin
                         mSSCBO.new;
                         mSSCBO.Prefill;
                         mSSCBO.SetFieldValueAsString('Store_ID',mStore_ID);
                         mSSCBO.SetFieldValueAsString('StoreCard_ID',mStoreCard_ID);
                       end else begin
                         mSSCBO.Load(mStoreSubCard_ID,nil);
                       end;
                       OutputDebugString('skladová karta: '+mStoreCard_ID+' sklad: '+mStore_ID+' dílčí karta '+mSSCBO.DisplayName+' množství '+mQuatity);
                       mSSCBO.SetFieldValueAsFloat('LowLimitQuantity',NxIBStrToFloat(mQuatity));
                       msscbo.save;
                       msscbo.free;
                    end;
                    WaitWin.ChangeText(IntToStr(i) + ' / ' + IntToStr(n));
                    WaitWin.StepIt;

                   end;

        finally
         WaitWin.Stop;
        end;

       NxShowSimpleMessage('Nahráno '+IntToStr(n)+' záznamů.',mSite);
      end;
  end;
end;

begin
end.