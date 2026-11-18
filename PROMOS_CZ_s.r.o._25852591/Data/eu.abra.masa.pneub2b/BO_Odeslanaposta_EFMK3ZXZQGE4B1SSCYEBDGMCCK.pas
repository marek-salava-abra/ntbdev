uses '.const';

procedure AfterSave_Hook(Self: TNxCustomBusinessObject);
var
 mXMLResponse, mXMLPostResponse:TNxScriptingXMLWrapper;
 mReceivedOrderBO:TNxCustomBusinessObject;
 i:integer;
 mReceivedOrder_ID:string;
begin
  if not(NxIsBlank(self.GetFieldValueAsString('X_LP_Tracking_URL'))) and (self.GetFieldValueAsString('X_LP_SourceCLSID')=Class_BillOfDelivery) then begin
   mReceivedOrder_ID:=self.ObjectSpace.SQLSelectFirstAsString('Select ro.id from ReceivedOrders ro join storedocuments2 sd2 on ro.id=sd2.provide_id where ro.docqueue_id='+
                                                             QuotedStr(cRO_DocQueue_ID)+' and sd2.FlowType='+QuotedStr('21')+
                                                             ' and sd2.parent_id='+QuotedStr(self.GetFieldValueAsString('X_LP_Source_ID')),'');
   if not(NxIsEmptyOID(mReceivedOrder_ID)) then begin
     mReceivedOrderBO:=self.ObjectSpace.CreateObject(Class_ReceivedOrder);
     mReceivedOrderBO.Load(mReceivedOrder_ID,nil);
     try
      mXMLResponse:=TNxScriptingXMLWrapper.Create;
      mXMLResponse.CreateEmpty('Transport');
      mXMLResponse.setAttributeValue('Transport','xmlns','http://pneub2b.eu/SupplierOrdersTransport.xsd');
      mXMLResponse.AddElement('TransportItem');
      mXMLResponse.setAttributeValue('TransportItem[' + IntToStr(0) + ']','OrderNumber', mReceivedOrderBO.GetFieldValueAsString('X_B2BNumber'));
      mXMLResponse.setAttributeValue('TransportItem[' + IntToStr(0) + ']','TnTUrl', self.GetFieldValueAsString('X_LP_Tracking_URL'));
      mXMLResponse.setAttributeValue('TransportItem[' + IntToStr(0) + ']','TnTNumber', self.GetFieldValueAsString('X_LP_Barcode'));
      mXMLResponse.setAttributeValue('TransportItem[' + IntToStr(0) + ']','TransportCompany', self.GetFieldValueAsString('PostProvider_ID.Name'));
      mXMLResponse.saveToFile('C:\Users\abraadmin\Documents\ABRA_EXPORT\xml\'+FormatDateTime('YYYYMMDDhhnnss',Now)+'_TnT_'+self.oid+'.xml');
      mXMLPostResponse:=API_POST(cURL+'orders_transport_info',mReceivedOrderBO.GetFieldValueAsString('X_B2BOrigin'),'KingTonyDodavatel.',mXMLResponse, self.ObjectSpace);
      mXMLPostResponse.saveToFile('C:\Users\abraadmin\Documents\ABRA_EXPORT\xml\'+FormatDateTime('YYYYMMDDhhnnss',Now)+'_postresponse_TnT_'+self.oid+'.xml');
     except

     end;
     mReceivedOrderBO.free;
   end;
  end;
end;

begin
end.