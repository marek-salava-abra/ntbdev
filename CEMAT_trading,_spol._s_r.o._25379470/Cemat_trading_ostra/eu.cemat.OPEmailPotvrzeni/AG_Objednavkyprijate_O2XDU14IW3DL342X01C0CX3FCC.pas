procedure InitSite_Hook(Self: TSiteForm);
var
  mBut, mBut2: TBasicAction;
  mUser:TNxCustomBusinessObject;
begin
  if not Assigned(Self.BaseObjectSpace) then
    exit;
mBut:= Self.GetNewAction;
mBut.ShowControl := True;
mBut.ShowMenuItem := True;
mBut.Caption := 'Potvrzení OP';
mBut.Category := 'tabList';
mBut.OnExecute := @ConfirmOP;

end;


Procedure ConfirmOP(sender:TComponent);
var
 mBO:TNxCustomBusinessObject;
 mList:tstringlist;
 mfilename, mTempDir:string;
 mSite:TSiteForm;
begin
 mSite:=TComponent(sender).DynSite;
  mBO:=TDynSiteForm(mSite).CurrentObject;
    if NxMessageBox('Dotaz','Přejete si odeslat '+mbo.DisplayName+' jako potvrzení?' , mdConfirm, mdbYesNo, 0, 0, False, msite)= mrYes then begin
      mList:=tstringlist.Create;
      mlist.Add(mbo.OID);
      mFileName:=NxSearchReplace(mBO.DisplayName,'/','-',[srAll]);
      mTempDir:=NxGetTempDir;
      CFxReportManager.PrintByIDs(NxCreateContext_1(mBO), mList, '40V53DORW3DL342X01C0CX3FCC', '1O30000101', rtoEmail, pekPDF, '', mFileName + '.pdf');
      DeleteFile(mTempDir+'\'+mFileName+'.pdf');
    end;

end;

{
Vyvolává se po uložení vlastních dat objektu do databáze.
}
procedure _AfterSave_PostHook(Self: TDynSiteForm);
var
 mBO:TNxCustomBusinessObject;
 mList:tstringlist;
 mfilename, mTempDir:string;

begin
  mBO:=TDynSiteForm(self).CurrentObject;
   if mbo.GetFieldValueAsInteger('ObjVersion')=1 then begin
    if NxMessageBox('Dotaz','Přejete si odeslat '+mbo.DisplayName+' jako potvrzení?' , mdConfirm, mdbYesNo, 0, 0, False, self)= mrYes then begin
      mList:=tstringlist.Create;
      mlist.Add(mbo.OID);
      mFileName:=NxSearchReplace(mBO.DisplayName,'/','-',[srAll]);
      mTempDir:=NxGetTempDir;
      CFxReportManager.PrintByIDs(NxCreateContext_1(mBO), mList, '40V53DORW3DL342X01C0CX3FCC', '1O30000101', rtoEmail, pekPDF, '', mFileName + '.pdf');
      DeleteFile(mTempDir+'\'+mFileName+'.pdf');
    end;
  end;
end;


begin
end.