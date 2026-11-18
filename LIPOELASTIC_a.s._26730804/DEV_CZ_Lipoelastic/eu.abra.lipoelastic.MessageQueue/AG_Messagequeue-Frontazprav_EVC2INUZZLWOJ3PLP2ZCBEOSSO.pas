uses '.receivedOrder';


procedure InitSite_Hook(Self: TSiteForm);
var
  mAction: TBasicAction;
begin
  mAction := Self.GetNewAction;
  mAction.ShowControl := True;
  mAction.ShowMenuItem := True;
  mAction.Name := 'ProcessRecord';
  mAction.Caption := '## Zpracovat záznam ##';
  mAction.Category := 'tabList';
  mAction.OnExecute := @ProcessRecord;
end;


procedure ProcessRecord(Sender: TComponent);
var
  mSite: TSiteForm;
  mOS: TNxCustomObjectSpace;
  mMessageQueueBO: TNxCustomBusinessObject;
  mResult: String;
begin
  mSite := Sender.Site;
  mOS := mSite.BaseObjectSpace;
  mMessageQueueBO := nil;
  mResult := '';
  try
    try
      mMessageQueueBO := TBusRollSiteForm(mSite).CurrentObject;
      if not Assigned(mMessageQueueBO) then begin
        RaiseException('Neni vybran zadny zaznam MessageQueue.');
      end;

      if mMessageQueueBO.GetFieldValueAsString('X_MQ_DocumentType') <> 'RO' then begin
        RaiseException('Nepodporovany typ dokumentu: ' + mMessageQueueBO.GetFieldValueAsString('X_MQ_DocumentType'));
      end;

      CreateOrder(mOS, mMessageQueueBO);
      mResult :=
        'code=' + mMessageQueueBO.GetFieldValueAsString('Code') + NxCrLf +
        'document_type=' + mMessageQueueBO.GetFieldValueAsString('X_MQ_DocumentType') + NxCrLf +
        'state=' + IntToStr(mMessageQueueBO.GetFieldValueAsInteger('X_MQ_State')) + NxCrLf +
        'result=' + mMessageQueueBO.GetFieldValueAsString('X_MQ_ResultMessage');
    except
      mResult := 'processing.error ' + ExceptionMessage;
    end;
  finally
    if Assigned(mMessageQueueBO) then
      mMessageQueueBO.Free;
  end;

  TBusRollSiteForm(mSite).RefreshData;
  NxShowEditorSite(mSite.SiteContext, mResult, False);
end;


begin
end.
