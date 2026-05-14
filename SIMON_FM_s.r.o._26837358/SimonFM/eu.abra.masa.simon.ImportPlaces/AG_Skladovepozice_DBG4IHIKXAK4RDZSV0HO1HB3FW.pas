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
         mName:= NxTrapStr(mTempStr, ';');
         mString1:= NxTrapStrTrim(mTempStr, ';');
         mStore_ID:= '4P00000101';
         if not(NxIsEmptyOID(mStore_ID)) then begin
          //if NxIsBlank(mString3) then mCode:=mString1+'-'+mString2 else mCode:=mString1+'-'+AnsiRightStr('0'+mString2,2)+'-'+AnsiRightStr('0'+mString3,2);
          mBO:=mOS.CreateObject(Class_LogStorePosition);
          mBO.New;
          mBO.Prefill;
          mBO.SetFieldValueAsString('Store_ID', mStore_ID);
          mBO.SetFieldValueAsString('Name','Pozice '+mName);
          mBo.SetFieldValueAsString('Code',mName);
          mBO.SetFieldValueAsFloat('Depth',1);
          mBO.SetFieldValueAsFloat('Height',1);
          mBO.SetFieldValueAsFloat('Width',1);
          //if NxIBStrToFloat(mString1)>0 then mBO.SetFieldValueAsFloat('MaxWeight',NxIBStrToFloat(mString1)) else
          mBO.SetFieldValueAsFloat('MaxWeight',500);
          mBO.SetFieldValueAsString('BarCode',mName);
          mbo.save;
          mBO.Free;
         end;
         WaitWin.ChangeText(IntToStr(i) + ' / ' + IntToStr(mList.Count));
         WaitWin.StepIt;
      end;
     WaitWin.Stop;
     NxShowSimpleMessage('Nahráno '+IntToStr(mlist.count)+' firem.',mSite);
    end;
   end;
end;




begin
end.