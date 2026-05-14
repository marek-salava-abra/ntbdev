

{
Vyvolává se po provedení inicializace agendy/formuláře. V tento okamžik je již na formuláři dostupný SiteContext.
}
procedure InitSite_Hook(Self: TSiteForm);
var
 mAction:TAction;
begin
  mAction := Self.GetNewAction;
  mAction.ShowControl := True;
  mAction.ShowMenuItem := True;
  mAction.Caption := '## EMAIL ##';
  mAction.ShortCut := TextToShortCut('Ctrl+Q'); //16450;
  mAction.Hint := 'Vygeneruje email';
  mAction.Category := 'tabList';
  mAction.OnExecute := @CreateMail;
end;

procedure CreateMail(sender:TComponent);
var
 mPrintList:TStringList;
 mBO:TNxCustomBusinessObject;
 mSite:TSiteForm;
 mReportName, mMailAdr:string;
begin
 mSite:=TComponent(sender).DynSite;
 mBO:=TDynSiteForm(mSite).CurrentObject;
 if Assigned(mBO) then begin
   mPrintList:=TStringList.create;
   mPrintList.add(mbo.OID);
   mReportName := mBO.GetFieldValueAsString('DisplayName') + '.pdf';
   mReportName := StringReplace(mReportName,'/','-',[rfReplaceAll]);
   mMailAdr:=mbo.GetFieldValueAsString('FirmOffice_ID.Address_ID.Email');
   if mMailAdr='' then mMailAdr:=mbo.GetFieldValueAsString('Firm_ID.ResidenceAddress_ID.Email');
   CFxReportManager.PrintByIDs(NxCreateContext_1(mBO),mPrintList,'40V53DORW3DL342X01C0CX3FCC','4VD0000101',rtoEmail, pekPDF,mMailAdr,mReportName);
   mPrintList.Free;
 end;
end;

begin
end.