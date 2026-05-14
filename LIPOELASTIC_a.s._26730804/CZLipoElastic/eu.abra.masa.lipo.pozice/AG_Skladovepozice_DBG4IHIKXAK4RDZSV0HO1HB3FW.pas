
procedure InitSite_Hook(Self: TSiteForm);
var
  mAction, mAction2: TBasicAction;
begin
  mAction := Self.GetNewAction;
  mAction.ShowControl := True;
  mAction.ShowMenuItem := True;
  mAction.Name := 'actImport2';
  mAction.Caption := 'Import pozic';
  mAction.Hint := 'Naimportuje data z CSV';
  mAction.Category := 'tabList';
  mAction.OnExecute := @ImportData;
end;

Procedure ImportData(sender:TComponent);
var
 mSite:TSiteForm;
 mOS:TNxCustomObjectSpace;
 mList:TStringList;
 mBO, mFirmOfficeBO:TNxCustomBusinessObject;
 mFirmOffices:TNxCustomBusinessMonikerCollection;
 i:integer;
 mOpenDlg:TOpenDialog;
 mTempStr, mCode:String;
 mCisSklad, mName, mString1, mString2, mString3, mStore_ID: String;
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
      for i:=0 to mlist.count-1 do begin
         mTempStr:=mlist.Strings[i];
         //mCisSklad:= NxTrapStr(mTempStr, ';');
         mName:= NxTrapStr(mTempStr, ';');
         //mString1:= Trim(NxTrapStr(mTempStr, ';'));
         //mString2:= trim(NxTrapStr(mTempStr, ';'));
         //mString3:= trim(NxTrapStr(mTempStr, ';'));
         mStore_ID:='51F1000101';// mOS.SQLSelectFirstAsString('Select id from stores where hidden='+quotedstr('N')+' and code='+QuotedStr(mCisSklad),'');
         if not(NxIsEmptyOID(mStore_ID)) then begin
          //if NxIsBlank(mString3) then mCode:=mString1+'-'+mString2 else mCode:=mString1+'-'+AnsiRightStr('0'+mString2,2)+'-'+AnsiRightStr('0'+mString3,2);
          mBO:=mOS.CreateObject(Class_LogStorePosition);
          mBO.New;
          mBO.Prefill;
          mBO.SetFieldValueAsString('Store_ID', mStore_ID);
          mBO.SetFieldValueAsString('Name',mName);
          mBo.SetFieldValueAsString('Code',mName);
          mBO.SetFieldValueAsFloat('Depth',1);
          mBO.SetFieldValueAsFloat('Height',1);
          mBO.SetFieldValueAsFloat('Width',1);
          mBO.SetFieldValueAsFloat('MaxWeight',1000);
          mBO.SetFieldValueAsString('BarCode',mName);
          mbo.save;
          mBO.Free;
         end;
         WaitWin.ChangeText(IntToStr(i) + ' / ' + IntToStr(mList.Count));
         WaitWin.StepIt;
      end;
     WaitWin.Stop;
     NxShowSimpleMessage('Nahráno '+IntToStr(mlist.count)+' pozic.',mSite);
    end;
   end;
end;




begin
end.