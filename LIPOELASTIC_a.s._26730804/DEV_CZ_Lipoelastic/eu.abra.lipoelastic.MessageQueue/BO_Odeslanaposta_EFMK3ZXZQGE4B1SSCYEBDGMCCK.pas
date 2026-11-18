uses '.const', '.API';

procedure AfterSave_Hook(Self: TNxCustomBusinessObject);
var
 mJSON, mResJSON, mDocPost, mDocResult:TJSONSuperObject;
 mTargetInstanceKey, mReceivedOrder_ID:string;
 mReceivedOrderBO:TNxCustomBusinessObject;
begin
 if not(NxIsEmptyOID(self.GetFieldValueAsString('X_PD_SourceDocID')))
   and (NxDocTypeToGUID(self.GetFieldValueAsString('X_PD_SourceDocType'))=Class_BillOfDelivery) and not(NxIsBlank(self.GetFieldValueAsString('X_PD_Track_URL'))) then begin
  mReceivedOrder_ID:=self.ObjectSpace.SQLSelectFirstAsString('Select ro.id from ReceivedOrders ro join storedocuments2 sd2 on ro.id=sd2.provide_id where ro.docqueue_id='+
                                                             QuotedStr(cRO_DocQueue_ID_OPDS)+' and sd2.FlowType='+QuotedStr('21')+
                                                             ' and sd2.parent_id='+QuotedStr(self.GetFieldValueAsString('X_PD_SourceDocID')),'');
  if not(NxIsEmptyOID(mReceivedOrder_ID)) then begin
    mReceivedOrderBO:=self.ObjectSpace.CreateObject(Class_ReceivedOrder);
    mReceivedOrderBO.Load(mReceivedOrder_ID,nil);
       mJSON:=TJSONSuperObject.Create;
       mJSON.S['IssuedOrder_ID']:=mReceivedOrderBO.GetFieldValueAsString('X_MQ_External_ID');
       mTargetInstanceKey:=AnsiLeftStr(mReceivedOrderBO.GetFieldValueAsString('Firm_ID.VATIdentNumber'),2);
       mResJSON:=API_POST(self.ObjectSpace, mTargetInstanceKey, mJSON, 'script/eu.abra.Lipoelastic.MessageQueue/API/RecievedOrdersToIssuedOrders', false);
         mDocPost:=TJSONSuperObject.Create;
         mDocPost.S['instance']:='CZ';
         mDocPost.S['source_doc_id']:=mResJSON.S['ReceivedOrder_ID'];
         mDocPost.S['order_doc_id']:=mReceivedOrderBO.oid;
         mDocPost.S['doc_id']:=self.oid;
         mDocPost.S['tracking_number']:=self.GetFieldValueAsString('X_PD_LongPostNumber');
         mDocPost.S['tracking_url']:=self.GetFieldValueAsString('X_PD_Track_URL');
         mDocPost.S['event_type']:='shipment.tracked';
         mDocResult:=HUB_API_POST(self.ObjectSpace, mDocPost);

         CFxLog.SaveLog(NxCreateContext(self.ObjectSpace),'LA','Save '+self.DisplayName,mDocPost.AsString+NxCrlf+Nxcrlf+mDocResult.AsString,ltScripting,Now);
    end;
 end;
end;

begin
end.