procedure InitSite_Hook(Self: TSiteForm);
var
  mAction, mAction2: TBasicAction;
begin
  mAction := Self.GetNewAction;
  mAction.ShowControl := True;
  mAction.ShowMenuItem := True;
  mAction.Name := 'actImport2';
  mAction.Caption := 'Import DIP';
  mAction.Hint := 'Naimportuje data z CSV';
  mAction.Category := 'tabList';
  mAction.OnExecute := @ImportData;
end;

Procedure ImportData(sender:TComponent);
var
mSite:TSiteForm;
mOS:TNxCustomObjectSpace;
mList:TStringList;
mBO, mRowBO:TNxCustomBusinessObject;
mRows:TNxCustomBusinessMonikerCollection;
i, j:integer;
mOpenDlg:TOpenDialog;
mTempStr, mCode:String;
mrowtxt, mStoreCard_ID, mStoreBatch_ID, mParent_ID, mMIPRow_ID,mQunit,mtempDate: String;
mQuantity:Extended;
begin
  j:=0;
  mSite:=TComponent(sender).DynSite;
  mOS:=mSite.BaseObjectSpace;
  mList:=tstringlist.create;
  mOpenDlg := TOpenDialog.Create(Sender);
  mOpenDlg.Filter:= 'Import z CSV|*.csv';
  mOpenDlg.FilterIndex:= 0;
  //mBO:=TDynSiteForm(mSite).CurrentObject;
  if mOpenDlg.Execute then begin
   mList.LoadFromFile(mOpenDlg.FileName);
    if mList.Count>0 then begin
     WaitWin.StartProgress('Čekejte, prosím ...', '', mList.Count);
      for i:=0 to mlist.count-1 do begin
        try
          mRowTxt := mlist.strings[i];
          mStoreCard_id:= NxTrapStr(mRowTxt, ';');
          mQuantity := NxIBStrToFloat(NxTrapStr(mRowTxt, ';'));
          mTempDate:=NxTrapStr(mRowTxt, ';');
          mQunit:=NxTrapStr(mRowTxt, ';');
          mParent_ID:=NxTrapStr(mRowTxt, ';');
          mMIPRow_ID:=NxTrapStr(mRowTxt, ';');
          if  not(NxIsEmptyOID(mStoreCard_ID))then begin
              mRowBO := mOS.CreateObject(Class_PartialInvProtocolRow);
              mRowBO.new;
              mRowBO.prefill;
              mRowBO.SetFieldValueAsString('Parent_ID',mParent_ID);
              mRowBO.SetFieldValueAsString('MIPRow_ID',mMIPRow_ID);
              mRowBO.SetFieldValueAsString('QUnit',mQunit);
              mRowBO.SetFieldValueAsFloat('UnitRealQuantity',mQuantity);
              mRowBO.SetFieldValueAsDateTime('TimeStamp$DATE',NxIBStrToFloat(mtempDate));
              mRowBO.save;
              mrowbo.free;

          end;
        Except
           NxShowSimpleMessage(ExceptionMessage,mSite);
        end;
        WaitWin.ChangeText(IntToStr(i) + ' / ' + IntToStr(mList.Count));
        WaitWin.StepIt;
      end;
     WaitWin.Stop;
     NxShowSimpleMessage('Nahráno '+IntToStr(mlist.count)+' položek.',mSite);
    end;
   end;
end;

begin
end.
