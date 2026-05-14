procedure InitSite_Hook(Self: TSiteForm);
var
  mAction, mAction2: TBasicAction;
begin
  mAction := Self.GetNewAction;
  mAction.ShowControl := True;
  mAction.ShowMenuItem := True;
  mAction.Name := 'actImport2';
  mAction.Caption := 'Import Zboží.cz';
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
 mName, mDescription, mParentCode, mVnor: String;
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
         mCode:= NxTrapStrTrim(mTempStr, ';');
         mName:= NxTrapStrTrim(mTempStr, ';');
         mDescription:=NxTrapStrTrim(mTempStr, ';');
         mParentCode:=NxTrapStrTrim(mTempStr, ';');
         mVnor:=NxTrapStrTrim(mTempStr, ';');
          mBO:=mOS.CreateObject(Class_CategoriesZboziCZ);
          mBO.New;
          mBO.Prefill;
          mBO.SetFieldValueAsString('Code',mCode);
          mBO.SetFieldValueAsString('Name',AnsiLeftStr(mName,100));
          mBO.SetFieldValueAsString('X_ZboziDescription',mDescription);
          if Length(mParentCode)>2 then mBO.SetFieldValueAsString('X_ZboziParent_ID',mOS.SQLSelectFirstAsString('Select id from defrolldata where clsid='+QuotedStr(Class_CategoriesZboziCZ)+' and code='+QuotedStr(mParentCode),''));
          mbo.SetFieldValueAsFloat('X_FloatValue1',NxIBStrToFloat(mVnor));
          mbo.save;
          mBO.Free;
         WaitWin.ChangeText(IntToStr(i) + ' / ' + IntToStr(mList.Count));
         WaitWin.StepIt;
      end;
     WaitWin.Stop;
     NxShowSimpleMessage('Nahráno '+IntToStr(mlist.count)+' záznamů.',mSite);
    end;
   end;
end;




begin
end.