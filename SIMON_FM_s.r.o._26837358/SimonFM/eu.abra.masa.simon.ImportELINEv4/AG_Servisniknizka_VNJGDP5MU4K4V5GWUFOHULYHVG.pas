procedure InitSite_Hook(Self: TSiteForm);
var
  mAction, mAction2: TBasicAction;
begin
  mAction := Self.GetNewAction;
  mAction.ShowControl := True;
  mAction.ShowMenuItem := True;
  mAction.Name := 'actImport44';
  mAction.Caption := 'smazání obrázků';
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
 mTempStr, mCode, mElineID, mNextSC_ID:String;
 mCisSklad, mName, mCollA, mStoreCard_ID, mVazba_ID, mParam_ID, mPosindex, mPCode, mParamGroup_ID: String;
 mCollB, mCollC,mCollD,mCollE,mCollF,mCollG,mCollH,mCollI,mCollJ,mCollK,mCollL,mCollM,mCollN,mCollO,mCollP,mCollQ,mCollR,mCollS,mCollT,mCollU,mCollV:string;
 mCollA1, mCollB1, mCollC1, mCollD1:string;
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
      for i:=1 to mlist.count-1 do begin
         mTempStr:=mlist.Strings[i];
         mCollA:= Trim(NxTrapStr(mTempStr, ','));
         mCollB:= Trim(NxTrapStr(mTempStr, ','));
         mCollC:= Trim(NxTrapStr(mTempStr, ','));
         mCollD:= Trim(NxTrapStr(mTempStr, ','));
         mElineID:=mCollB;
         mStoreCard_ID:=mOS.SQLSelectFirstAsString('Select id from storecards where X_elineID='+QuotedStr(mElineID),'');
         if not(NxIsEmptyOID(mStoreCard_ID)) then begin
           mbo:=mOS.CreateObject(Class_StoreCard);
           mBO.Load(mStoreCard_ID,nil);
           mPictures:=mBO.GetLoadedCollectionMonikerForFieldCode(mBO.GetFieldCode('Pictures'));
           if mPictures.Count>0 then begin
             for j:=0 to mPictures.count-1 do begin
                mPictures.BusinessObject[j].MarkForDelete;
             end;
             mbo.save;
           end;
           mbo.free;
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