uses '.lib';

procedure InitSite_Hook(Self: TSiteForm);
var
  mAction: TBasicAction;
begin
  mAction := Self.GetNewAction;
  mAction.ShowControl := True;
  mAction.ShowMenuItem := True;
  mAction.Caption := '## Zpracovat záznam ##';
  mAction.Hint := 'Nahraje fakturu z JSON';
  mAction.Category := 'tabList';
  mAction.OnExecute := @CreateInvoice;

  {mAction := Self.GetNewAction;
  mAction.ShowControl := True;
  mAction.ShowMenuItem := True;
  mAction.Caption := '## Zpracovat soubor ##';
  mAction.Hint := 'Nahraje fakturu z JSON';
  mAction.Category := 'tabList';
  mAction.OnExecute := @ProcessFilebutton; }
end;

procedure CreateInvoice(Sender:tcomponent);
var
 mSite:TSiteForm;
 mBO:TNxCustomBusinessObject;
begin
  mSite:=TComponent(Sender).BusRollSite;
  mBO:=TBusRollSiteForm(mSite).CurrentObject;
  if Assigned(mBO) then begin
    ProcessJSONData(mBO,'');
  end;
end;


procedure ProcessFilebutton(Sender:tcomponent);
var
 mSite:TSiteForm;
 mBO:TNxCustomBusinessObject;
 aMessage:string;
begin
  mSite:=TComponent(Sender).BusRollSite;
   ProcessFile(msite.BaseObjectSpace, aMessage);
   NxShowSimpleMessage(aMessage,msite);
end;




begin
end.