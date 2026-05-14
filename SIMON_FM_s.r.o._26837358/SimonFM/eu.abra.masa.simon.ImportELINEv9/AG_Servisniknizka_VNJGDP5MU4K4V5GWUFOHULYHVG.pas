procedure InitSite_Hook(Self: TSiteForm);
var
  mAction, mAction2: TBasicAction;
begin
  mAction := Self.GetNewAction;
  mAction.ShowControl := True;
  mAction.ShowMenuItem := True;
  mAction.Name := 'actImport9';
  mAction.Caption := 'Import menu img';
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
 mFirmOffices:TNxCustomBusinessMonikerCollection;
 i,j:integer;
 mOpenDlg:TOpenDialog;
 mTempStr, mCode, mElineID:String;
 mCisSklad, mName, mCollA, mStoreCard_ID, mVazba_ID, mParam_ID, mPosindex, mPCode, mParamGroup_ID: String;
 mCollB, mCollC,mCollD,mCollE,mCollF,mCollG,mCollH,mCollI,mCollJ,mCollK,mCollL,mCollM,mCollN,mCollO,mCollP,mCollQ,mCollR,mCollS,mCollT,mCollU,mCollV:string;
begin
  mSite:=TComponent(sender).DynSite;
  mOS:=mSite.BaseObjectSpace;
  mList:=tstringlist.create;
  mOpenDlg := TOpenDialog.Create(Sender);
  mOpenDlg.Filter:= 'Import z CSV|*.csv';
  mOpenDlg.FilterIndex:= 0;
  if mOpenDlg.Execute then begin
   mList.LoadFromFile(mOpenDlg.FileName);
    if mList.Count>0 then begin
     WaitWin.StartProgress('Čekejte, prosím ...', '', mList.Count);
      for i:=0 to mlist.count-1 do begin
         mTempStr:=mlist.Strings[i];
         mCollA:= Trim(NxTrapStr(mTempStr, ';'));
         mCollB:= Trim(NxTrapStr(mTempStr, ';'));
         mStoreCard_ID:=mCollB;
         if not(NxIsBlank(mCollB)) then
           mOS.SQLExecute('update storecards set X_ESPicture='+Quotedstr(mCollB)+' where id='+QuotedStr(mCollA));

         WaitWin.ChangeText(IntToStr(i) + ' / ' + IntToStr(mList.Count));
         WaitWin.StepIt;
      end;
     WaitWin.Stop;
     NxShowSimpleMessage('Nahráno '+IntToStr(mlist.count)+' parametrů.',mSite);
    end;
   end;
end;




begin
end.