procedure InitSite_Hook(Self: TSiteForm);
var
  mAction, mAction2: TBasicAction;
begin
  mAction := Self.GetNewAction;
  mAction.ShowControl := True;
  mAction.ShowMenuItem := True;
  mAction.Name := 'actImport3';
  mAction.Caption := 'Import ELINEv2';
  mAction.Hint := 'Naimportuje data z CSV';
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
 mTempStr, mCode:String;
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
         mCollC:= Trim(NxTrapStr(mTempStr, ';'));
         mCollD:= Trim(NxTrapStr(mTempStr, ';'));
         mCollE:= Trim(NxTrapStr(mTempStr, ';'));
         mCollF:= Trim(NxTrapStr(mTempStr, ';'));
         //NxShowSimpleMessage(mTempStr,mSite);
         mStoreCard_ID:=mOS.SQLSelectFirstAsString('Select id from storecards where hidden=''N'' and X_elineID='+QuotedStr(mCollA));
         mCode:=NxSearchReplace(mCollB,'"','',[srAll]);
         if not(NxIsEmptyOID(mStoreCard_ID)) and not(NxIsBlank(mCode)) then begin
          mParamGroup_ID:=mOS.SQLSelectFirstAsString('Select id from defrolldata where clsid=''OD4JP4GMMNRO5DTOIFTDVCLISC'' and X_Rel_def='''' and code='+Quotedstr(AnsiRightStr('00'+mCode,3)));
          if not(NxIsEmptyOID(mParamGroup_ID)) then begin
            mOS.SQLExecute('update storecards set X_ParamGroup_ID='+Quotedstr(mParamGroup_ID)+' where id='+QuotedStr(mStoreCard_ID));
          end;
         end;
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