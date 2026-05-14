procedure InitSite_Hook(Self: TSiteForm);
var
  mAction: TBasicAction;
begin
  mAction := Self.GetNewAction;
  mAction.ShowControl := True;
  mAction.ShowMenuItem := True;
  mAction.Caption := 'Export FV SK';
  mAction.Hint := 'Vyexportuje data na SK';
  mAction.Category := 'tabList';
  mAction.OnExecute := @ExportFV;
end;

Procedure ExportFV(Sender:TComponent);
var
 mList:TStringList;
 mBO:TNxCustomBusinessObject;
 i:integer;
 mPrintList:TStringList;
 mDir,mFileName:string;
 mSite:TSiteForm;
begin
  mSite:=TComponent(Sender).DynSite;
  mList:=TStringList.Create;
  TDynSiteForm(mSite).List.GetSelectedId(mList);
  if mlist.Count>0 then begin
    mDir:='\\192.168.0.80\abradata\exchange\Slovensko\';
    if NxMessageBox('Dotaz','Přejete si vyexportovat '+IntToStr(mlist.Count)+' faktur?' , mdConfirm, mdbYesNo, 0, 0, False, msite)= mrYes then begin
       WaitWin.StartProgress('Čekejte, prosím ...', '', mList.Count);
        for i:=0 to mList.Count-1 do begin
          mBO:=msite.BaseObjectSpace.CreateObject(Class_IssuedInvoice);
          mBO.Load(mlist.Strings[i],nil);
          mFileName:=mbo.GetFieldValueAsString('VarSymbol')+'_'+mbo.GetFieldValueAsString('DocQueue_ID.Code')+'_'+IntToStr(mbo.GetFieldValueAsInteger('OrdNumber'))+'_'+mbo.GetFieldValueAsString('Period_ID.Code')+'.xml';
          mPrintList:=TStringList.Create;
          mPrintList.Add(mBO.OID);
          //NxShowSimpleMessage(NxGetTempDir+mFileName,mSite);
          CFxReportManager.ExportByIDs(NxCreateContext_1(mBO),mPrintList,'TZ4RII41UQA4TASN2ZO1ZY40AS','1100000101',0,'',NxGetTempDir+mFileName);
          NxCopyFile(NxGetTempDir+mFileName,mDir+mFileName);
          mPrintList.Free;
          mBO.Free;
          WaitWin.ChangeText(IntToStr(i+1) + ' / ' + IntToStr(mList.Count));
          WaitWin.StepIt;
        end;
       WaitWin.Stop;
       NxShowSimpleMessage('Vyexportováno '+IntToStr(mlist.count)+' faktur.',mSite);
    end;
  end;
end;

begin
end.