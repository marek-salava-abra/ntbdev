uses '.API';

{
Vyvolává se po provedení inicializace agendy/formuláře. V tento okamžik je již na formuláři dostupný SiteContext.
}
procedure InitSite_Hook(Self: TSiteForm);
var
  mAction: TBasicAction;
begin
  mAction:= Self.GetNewAction;
  mAction.Name:= 'actSynchronizeStates';
  mAction.Caption:= '## Sync Sendcloud states ##';
  mAction.Category:= 'tabList';
  mAction.OnExecute:= @SynchronizeSendCloudStates;
end;


procedure SynchronizeSendCloudStates(Sender: TComponent);
var
  mJSON: TJSONSuperObject;
  mSite: TSiteForm;
  mOS: TNxCustomObjectSpace;
  mStatusCode, mLog, mCode, mName: string;
  i: integer;
begin
  mSite:= Sender.Site;
  mOS:= mSite.BaseObjectSpace;

  mStatusCode:= '';
  mLog:= '';

  mJSON:= TJSONSuperObject.Create;
  try
    mJSON:= CallAPI(mOS, 'GET', 'parcels/statuses', mStatusCode, mLog);

    if mStatusCode <> '200' then
    begin
      NxShowSimpleMessage('Error occured while synchronizing. Status: '+mStatusCode+' Log: '+mLog, mSite);
      exit;
    end;

    for i:= 0 to mJSON.AsArray.Length -1 do
    begin
      mCode:= mJSON.AsArray.O[i].S['id'];
      mName:= mJSON.AsArray.O[i].S['message'];

      if NxIsEmptyOID(GetOrCreateSendcloudState(mOS, mCode, mName)) then
      begin
        NxShowSimpleMessage('Failed to create Sendcloud state. Synchronization stopped. ', mSite);
        exit;
      end;
    end;

    NxShowSimpleMessage('Synchronization complete.', mSite);

  finally
    mJSON.Free;
  end ;
end;

function GetOrCreateSendcloudState(AOS: TNxCustomObjectSpace; const ACode, AName: string): string;
var
  mBO: TNxCustomBusinessObject;
  mSendcloudState_ID: string;
begin
  Result:= '';

  mSendcloudState_ID:= AOS.SQLSelectFirstAsString(Format('SELECT ID FROM DefRollData WHERE CLSID = ''%s'' AND Code = ''%s''', [Class_BO_Sendcloud_ParcelStates, ACode]));
  if NxIsEmptyOID(mSendcloudState_ID) then
    mSendcloudState_ID:= AOS.SQLSelectFirstAsString(Format('SELECT ID FROM DefRollData WHERE CLSID = ''%s'' AND Name = ''%s''', [Class_BO_Sendcloud_ParcelStates, AName]));

  if NxIsEmptyOID(mSendcloudState_ID) then
  begin
    mBO:= AOS.CreateObject(Class_BO_Sendcloud_ParcelStates);
    try
      mBO.New;
      mBO.SetFieldValueAsString('Code', NxLeft(ACode, 40));
      mBO.SetFieldValueAsString('Name', NxLeft(AName, 100));

      mBO.Save;

      mSendcloudState_ID:= mBO.OID;
    finally
      mBO.Free;
    end;
  end;
  Result:= mSendcloudState_ID;
end;

begin
end.