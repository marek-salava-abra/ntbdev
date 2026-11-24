{
Vyvolává se po provedení inicializace agendy/formuláře. V tento okamžik je již na formuláři dostupný SiteContext.
}
procedure InitSite_Hook(Self: TSiteForm);
var
  mAction: TBasicAction;
begin
  mAction:= Self.GetNewAction;
  mAction.Name:= 'cActSetClosed';
  mAction.Caption:= '##Mark as executed##';
  mAction.Category:='tabList';
  mAction.OnExecute:= @IssuedOrder_Set_Closed;
end;

procedure IssuedOrder_Set_Closed(Sender: TComponent);
var
  mSite: TSiteForm;
  mOS: TNxCustomObjectSpace;
  mBO: TNxCustomBusinessObject;
begin
  mSite:= Sender.Site;
  mOS:= mSite.BaseObjectSpace;

  mBO:= TDynSiteForm(mSite).CurrentObject;
  try
    if NxRegExMatch(mBO.GetFieldValueAsString('X_ExternalDocument'), '^[A-Za-z0-9]+-[0-9]+/[0-9]{4}$') then
    begin
      if NxMessageBox(
        'Set as executed',
        'Do you wish to set order '+mBO.DisplayName+' as executed?',
        mdConfirm, mdbYesNo, mrNo, nil, false, mSite) = mrNo then
        exit;

      mBO.SetFieldValueAsBoolean('Closed', True);
      mBO.Save;
    end;
  finally
    mBO.Free;
  end;
end;


begin
end.