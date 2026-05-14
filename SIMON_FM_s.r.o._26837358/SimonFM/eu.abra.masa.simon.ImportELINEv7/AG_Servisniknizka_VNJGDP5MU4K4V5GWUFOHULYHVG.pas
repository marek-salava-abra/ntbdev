procedure InitSite_Hook(Self: TSiteForm);
var
  mAction, mAction2: TBasicAction;
begin
  mAction := Self.GetNewAction;
  mAction.ShowControl := True;
  mAction.ShowMenuItem := True;
  mAction.Name := 'actImport7';
  mAction.Caption := 'nahrani heureka';
  mAction.Hint := 'Naimportuje ID data z CSV';
  mAction.Category := 'tabList';
  mAction.OnExecute := @ImportData;
end;

Procedure ImportData(sender:TComponent);
var
 mSite:TSiteForm;
 mOS:TNxCustomObjectSpace;
 mList:TStringList;
 mBO, mNewBO, mParamBO:TNxCustomBusinessObject;
 mPictures:TNxCustomBusinessMonikerCollection;
 i,j:integer;
 mOpenDlg:TOpenDialog;
 mMemory:TMemoryStream;
 mBytes:TBytes;
 mTempStr, mCode, mElineID, mStoreCard_ID, mImageFile, mProdTempstr, mTempCode,mTempID, mPosindex, mVazba_ID:String;
 mid, mvyrobce, mprislusenstvi_id, mabra_id, mnovinka, makce, mdoporucujeme, mdoprodej, mdoprava_zdarma:string;
 mdoprava_a_platba_zdarma, mproductno, mextramessage, mextramessage2, mextramessage3, mheureka_extended_warranty, mextended_warranty, mfree_delivery, mfree_store_pickup, mfree_gift, mnazev_zbozi, mproduct, mna_uvod, myoutube_video :string;
begin

  mSite:=TComponent(sender).DynSite;
  mOS:=mSite.BaseObjectSpace;
  mList:=tstringlist.create;
  mOpenDlg := TOpenDialog.Create(Sender);
  mOpenDlg.Filter:= 'Import z CSV|*.csv';
  mOpenDlg.FilterIndex:= 0;
  if mOpenDlg.Execute then begin
   mMemory:= TMemoryStream.Create;
                    mMemory.LoadFromFile(mOpenDlg.FileName);
                    mBytes:=mMemory.GetBytes;
                    mList.Text := TEncoding.UTF8.GetString(mBytes);
   //mList.LoadFromFile(mOpenDlg.FileName);
    if mList.Count>0 then begin
     WaitWin.StartProgress('Čekejte, prosím ...', '', mList.Count);
      for i:=1 to mlist.count-1 do begin
         mTempStr:=mlist.Strings[i];
          mid:=NxTrimR(NxTrimL(Trim(NxTrapStr(mTempStr, ',')),'"'),'"');
          mvyrobce:=NxTrimR(NxTrimL(Trim(NxTrapStr(mTempStr, ',')),'"'),'"');
          mvyrobce:=AnsiLeftStr(NxSearchReplace(mvyrobce,'""','"',[srAll]),100);
          mextramessage:=NxTrimR(NxTrimL(Trim(NxTrapStr(mTempStr, ',')),'"'),'"');
          mextramessage2:=NxTrimR(NxTrimL(Trim(NxTrapStr(mTempStr, ',')),'"'),'"');
          mextramessage3:=NxTrimR(NxTrimL(Trim(NxTrapStr(mTempStr, ',')),'"'),'"');
          if mextramessage3='1' then begin
              mElineID:=mid;
              mStoreCard_ID:=mOS.SQLSelectFirstAsString('Select id from storecards where X_ESCard=''A'' and X_elineID='+QuotedStr(mextramessage2),'');
             if not(NxIsEmptyOID(mStoreCard_ID)) then begin
              if not(NxIsBlank(mvyrobce)) then begin
               mos.SQLExecute('update storecards set X_zar_list_filename='+QuotedStr(mvyrobce)+' where id='+QuotedStr(mStoreCard_ID));
               mos.SQLExecute('update storecards set X_zar_list_name='+QuotedStr(mextramessage)+' where id='+QuotedStr(mStoreCard_ID));
              end;
             end;
          end;
         WaitWin.ChangeText(IntToStr(i) + ' / ' + IntToStr(mList.Count));
         WaitWin.StepIt;
      end;
     WaitWin.Stop;
     NxShowSimpleMessage('Nahráno '+IntToStr(mlist.count)+' karet.',mSite);
    end;
   end;
end;



begin
end.