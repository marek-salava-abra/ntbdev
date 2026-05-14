procedure InitSite_Hook(Self: TSiteForm);
var
  mAction, mAction2: TBasicAction;
begin
  mAction := Self.GetNewAction;
  mAction.ShowControl := True;
  mAction.ShowMenuItem := True;
  mAction.Name := 'actImport2';
  mAction.Caption := 'Import Heureka';
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
 mName, mDescription, mID, mVnor: String;
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
         mID:= NxTrapStrTrim(mTempStr, ';');
         mCode:= NxTrapStrTrim(mTempStr, ';');
         mName:= NxTrapStrTrim(mTempStr, ';');
         mDescription:=NxTrapStrTrim(mTempStr, ';');
         if NxIBStrToFloat(mCode)>0 then begin
          mBO:=mOS.CreateObject(Class_CategoriesHeurekaCZ);
          mBO.New;
          mBO.Prefill;
          mBO.SetFieldValueAsString('X_HeurekaID',mID);
          mBO.SetFieldValueAsString('Code',mCode);
          mBO.SetFieldValueAsString('Name',AnsiLeftStr(mName,100));
          mBO.SetFieldValueAsString('X_ZboziDescription',mDescription);
          mbo.save;
          mBO.Free;
         end;
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