procedure InitSite_Hook(Self: TSiteForm);
  var
  mAction: TBasicAction;
begin
  mAction := Self.GetNewAction;
  mAction.Name := 'actImportSablon';
  mAction.Category := 'tabList';
  mAction.Caption := 'Import šablon';
  mAction.ShowMenuItem := True;
  mAction.ShowControl := True;
  mAction.OnExecute := @ImportData;
end;

Procedure ImportData (sender:TComponent);
var
 mSite:TSiteForm;
 mOS:TNxCustomObjectSpace;
 mList:TStringList;
 mOpenDlg:TOpenDialog;
 i,j:Integer;
 mTempStr, mCollA, mCollB, mCollC, mVazba_ID, mCode, mPCode, mParam_ID, mPosIndex:string;
 mBO, mNewBO, mParamBO:TNxCustomBusinessObject;
begin
  mSite:=TComponent(sender).BusRollSite;
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
         mCollA:= Trim(NxTrapStr(mTempStr, ';'));
         mCollB:= Trim(NxTrapStr(mTempStr, ';'));
         mCollC:= Trim(NxTrapStr(mTempStr, ';'));
         //NxShowSimpleMessage(mTempStr,mSite);
         mBO:=mOS.CreateObject('OD4JP4GMMNRO5DTOIFTDVCLISC');
         mBO.New;
         mBO.SetFieldValueAsString('Code',AnsiRightStr('00'+mCollA,3));
         mbo.SetFieldValueAsString('Name',mCollB);
         mBO.Save;
         for j:=0 to NxCharCount('|',mCollC) do begin
           mCode:=NxTrapStr(mCollC,'|');
           //NxShowSimpleMessage(mCode,mSite);
           mParam_ID:=mOS.SQLSelectFirstAsString('Select id from defrolldata where hidden=''N'' and clsid=''KCAWICC3H2O4DG0YEDMLO4X0PK'' and name='+QuotedStr(mCode));
           if NxIsEmptyOID(mParam_ID) then begin
             mParamBO:=mOS.CreateObject('KCAWICC3H2O4DG0YEDMLO4X0PK');
             mParamBO.new;
             mParamBO.Prefill;
             mPCode:=mos.SQLSelectFirstAsString('Select max(code) from defrolldata where code like ''P___'' and clsid=''KCAWICC3H2O4DG0YEDMLO4X0PK'' ');
             mParamBO.SetFieldValueAsString('Code', 'P'+AnsiRightStr('000'+(IntToStr(StrToInt(AnsiRightStr(mPCode,3))+1)),3));
             mParamBO.SetFieldValueAsString('Name',mCode);
             mParamBO.save;
             mParam_ID:=mParamBO.OID;
             mParamBO.free;
           end;
           mVazba_ID:=mOS.SQLSelectFirstAsString('Select id from defrolldata where clsid=''2TIIQXNXIXK4B5CZUIZ20K2W10'' and X_Rel_Def=''01'' and X_Parameter_ID='+QuotedStr(mParam_ID)+' and X_Value_ID='+QuotedStr(mbo.OID));
           if NxIsEmptyOID(mVazba_ID) and not NxIsEmptyOID(mParam_ID) then begin
            mNewBO:=mos.CreateObject('2TIIQXNXIXK4B5CZUIZ20K2W10');
            mNewBO.New;
            mNewBO.Prefill;
            mNewBO.SetFieldValueAsString('X_Value_ID',mbo.OID);
            mNewBO.SetFieldValueAsString('X_Parameter_ID',mParam_ID);
            mNewBO.SetFieldValueAsString('X_Rel_Def','01');
            mPosIndex:=mOS.SQLSelectFirstAsString('Select max(X_posindex) from defrolldata where clsid=''2TIIQXNXIXK4B5CZUIZ20K2W10'' and X_Rel_Def=''01'' and X_Value_ID='+QuotedStr(mBO.OID));
            if Length(mPosIndex)=0 then mNewBO.SetFieldValueAsString('X_Posindex','01') else
            mNewBO.SetFieldValueAsString('X_Posindex',AnsiRightStr('0'+IntToStr(StrToInt(mPosIndex)+1),2));
            //NxShowSimpleMessage('#'+mPosIndex+'# '+FloatToStr(Length(mPosIndex)),mSite);
            mNewBO.save;
            mNewBO.free;
           end;
         end;
         mBO.free;
         WaitWin.ChangeText(IntToStr(i) + ' / ' + IntToStr(mList.Count));
         WaitWin.StepIt;
      end;
     WaitWin.Stop;
     NxShowSimpleMessage('Nahráno '+IntToStr(mlist.count)+' skupin.',mSite);
    end;
   end;
end;

begin
end.