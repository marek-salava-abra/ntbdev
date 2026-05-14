procedure InitSite_Hook(Self: TSiteForm);
var
 mAction:TAction;
begin
  mAction := Self.GetNewAction;
  mAction.ShowControl := True;
  mAction.ShowMenuItem := True;
  mAction.Caption := '## OBSAH ##';
  mAction.ShortCut := TextToShortCut('Ctrl+K'); //16450;
  mAction.Hint := 'ukáže obsah skladové pozice';
  mAction.Category := 'tabList';
  mAction.OnExecute := @ShowContent;
end;

Procedure ShowContent(Sender:TComponent);
var
 mSite:TSiteForm;
 mBO:TNxCustomBusinessObject;
begin
 mSite:=TComponent(sender).BusRollSite;
 mBO:=TBusRollSiteForm(mSite).CurrentObject;
 if Assigned(mBO) then begin
   msite.ShowSite(Site_LogStoreContents,true,'QueryByUserDynSQLCondition;a.StoreCard_ID='+QuotedStr(mbo.oid)+';Moje omezení');
 end;
end;

begin
end.