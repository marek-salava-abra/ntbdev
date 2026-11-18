uses '.const', '.API', '.receivedOrder';

procedure AfterSave_Hook(Self: TNxCustomBusinessObject);
var
 mJSON, mResJSON, mDocPost, mDocResult:TJSONSuperObject;
 mTargetInstanceKey, mOriginalPMState_ID:string;
begin
  if (osNew in self.State) and (self.GetFieldValueAsString('DocQueue_ID')=cRO_DocQueue_ID_OPDS) then begin
     mJSON:=TJSONSuperObject.Create;
     mJSON.S['IssuedOrder_ID']:=Self.GetFieldValueAsString('X_MQ_External_ID');
     mTargetInstanceKey:=AnsiLeftStr(self.GetFieldValueAsString('Firm_ID.VATIdentNumber'),2);
     mResJSON:=API_POST(self.ObjectSpace, mTargetInstanceKey, mJSON, 'script/eu.abra.Lipoelastic.MessageQueue/API/RecievedOrdersToIssuedOrders', false);
     if not(NxIsEmptyOID(mResJSON.S['ReceivedOrder_ID'])) then begin
       mDocPost:=TJSONSuperObject.Create;
       mDocPost.S['source_instance']:=mTargetInstanceKey;
       mDocPost.S['source_doc_id']:=mResJSON.S['ReceivedOrder_ID'];
       mDocPost.S['target_doc_id']:=self.oid;
       mDocPost.S['event_type']:='order.created';
       mDocResult:=HUB_API_POST(self.ObjectSpace, mDocPost);

       CFxLog.SaveLog(NxCreateContext(self.ObjectSpace),'LA','Save '+self.DisplayName,mDocPost.AsString+NxCrlf+Nxcrlf+mDocResult.AsString,ltScripting,Now);
     end;
  end;

  Self.GetOriginalValue('PMState_ID', mOriginalPMState_ID);
  if (mOriginalPMState_ID <> Self.GetFieldValueAsString('PMState_ID')) and
     (Self.GetFieldValueAsString('PMState_ID') = cMQ_RO_PMState_ID_ZPRACOVAVA_SE) then
    Sync_ReceivedOrder_ProcessingToSource(Self);
end;


begin
end.