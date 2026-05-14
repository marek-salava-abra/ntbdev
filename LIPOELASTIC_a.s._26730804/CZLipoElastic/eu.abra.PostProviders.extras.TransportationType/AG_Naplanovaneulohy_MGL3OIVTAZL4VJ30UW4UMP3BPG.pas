uses
  'eu.abra.PostProviders.extras.TransportationType.uImportManager';


procedure InitSite_Hook(Self: TSiteForm);
var
  mMultiAction: TMultiAction;
  s: String;
begin
  mMultiAction := Self.GetNewMultiAction;
  if Assigned(mMultiAction) then begin
    //mMultiAction.Name := 'actActualizeTrackingStatus';
    mMultiAction.ShowControl := True;
    mMultiAction.ShowMenuItem := True;
    mMultiAction.Category := 'tabList';
    mMultiAction.Caption := 'Zpracovat frontu BB, WMS';
    mMultiAction.Hint := 'Fronata dokladu ke zpracování BB, z WMS (eu.abra.PostProviders.extras....)';
    mMultiAction.OnExecuteItem := @actAutoSend;
  end;
end;


//  Aktualizace stavu sledování zásilek z agendy odeslané pošty
procedure actAutoSend(Sender: TControl; Index: integer);
var
  s: string;
  mOS: TNxCustomObjectSpace;
  mSuccess:Boolean;
begin
  mOS := Sender.Site.BaseObjectSpace;
  Auto_ImportManagerStoreDocument_ByPMState(mOS,mSuccess,s);
  if mSuccess then
    ShowMessage('Konec: '+s)
  else
    ShowMessage('Konec s chybou: '+s)
end;


begin
end.