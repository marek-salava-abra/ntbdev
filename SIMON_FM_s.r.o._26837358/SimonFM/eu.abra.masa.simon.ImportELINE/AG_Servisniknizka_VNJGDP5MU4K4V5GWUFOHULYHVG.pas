procedure InitSite_Hook(Self: TSiteForm);
var
  mAction, mAction2: TBasicAction;
begin
  mAction := Self.GetNewAction;
  mAction.ShowControl := True;
  mAction.ShowMenuItem := True;
  mAction.Name := 'actImport2';
  mAction.Caption := 'Import ELINE';
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
 mCisSklad, mName, mCollA, mStoreCard_ID, mVazba_ID, mParam_ID, mPosindex, mPCode: String;
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
         mStoreCard_ID:=mOS.SQLSelectFirstAsString('Select id from storecards where hidden=''N'' and X_elineID='+QuotedStr(mCollB));
         mName:=NxSearchReplace(mCollE,'"','',[srAll]);
         if not(NxIsEmptyOID(mStoreCard_ID)) and not(NxIsBlank(mName)) then begin
           mParam_ID:=mOS.SQLSelectFirstAsString('Select id from defrolldata where hidden=''N'' and clsid=''KCAWICC3H2O4DG0YEDMLO4X0PK'' and name='+QuotedStr(mName));
           if NxIsEmptyOID(mParam_ID) then begin
             mParamBO:=mOS.CreateObject('KCAWICC3H2O4DG0YEDMLO4X0PK');
             mParamBO.new;
             mParamBO.Prefill;
             mPCode:=mos.SQLSelectFirstAsString('Select max(code) from defrolldata where code like ''P___'' and clsid=''KCAWICC3H2O4DG0YEDMLO4X0PK'' ');
             mParamBO.SetFieldValueAsString('Code', 'P'+AnsiRightStr('000'+(IntToStr(StrToInt(AnsiRightStr(mPCode,3))+1)),3));
             mParamBO.SetFieldValueAsString('Name',mName);
             mParamBO.save;
             mParam_ID:=mParamBO.OID;
             mParamBO.free;
           end;
           mVazba_ID:=mOS.SQLSelectFirstAsString('Select id from defrolldata where clsid=''2TIIQXNXIXK4B5CZUIZ20K2W10'' and X_Rel_Def=''03'' and X_Parameter_ID='+QuotedStr(mParam_ID)+' and X_Value_ID='+QuotedStr(mStoreCard_ID));
           if NxIsEmptyOID(mVazba_ID) and not NxIsEmptyOID(mParam_ID) and not NxIsEmptyOID(mStoreCard_ID) then begin
            mNewBO:=mos.CreateObject('2TIIQXNXIXK4B5CZUIZ20K2W10');
            mNewBO.New;
            mNewBO.Prefill;
            mNewBO.SetFieldValueAsString('X_Value_ID',mStoreCard_ID);
            mNewBO.SetFieldValueAsString('X_Parameter_ID',mParam_ID);
            mNewBO.SetFieldValueAsString('X_ParamValue',NxSearchReplace(mCollF,'"','',[srAll]));
            mNewBO.SetFieldValueAsString('X_Rel_Def','03');
            mPosIndex:=mOS.SQLSelectFirstAsString('Select max(X_posindex) from defrolldata where clsid=''2TIIQXNXIXK4B5CZUIZ20K2W10'' and X_Rel_Def=''03'' and X_Value_ID='+QuotedStr(mStoreCard_ID));
            if Length(mPosIndex)=0 then mNewBO.SetFieldValueAsString('X_Posindex','01') else
            mNewBO.SetFieldValueAsString('X_Posindex',AnsiRightStr('0'+IntToStr(StrToInt(mPosIndex)+1),2));
            mNewBO.save;
            mNewBO.free;
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