function ConfirmRO(Self: TNxWebServicesHelper;Order_ID: String):String;
var
 mBO:TNxCustomBusinessObject;
 mUserBO:TNxCustomBusinessObject;
 mAddress:TNxCustomBusinessObject;
 mTo:String;
begin
   if not(NxIsEmptyOID(Order_ID)) then begin
   mbo:=self.ObjectSpace.CreateObject(Class_ReceivedOrder);
   mbo.Load(Order_ID,nil);
   mbo.SetFieldValueAsBoolean('U_Confirmed',true);
   mUserBO:=mbo.GetMonikerForFieldCode(mbo.GetFieldCode('CreatedBy_ID')).BusinessObject;
   mAddress:=mUserBO.GetMonikerForFieldCode(mUserBO.GetFieldCode('Address_ID')).BusinessObject;
   mto:=mAddress.GetFieldValueAsString('Email');
   if not(NxIsBlank(mTo)) then CFxInternet.SMTPSendMailWithMoreFiles(csOpenSSL,'cemat@mailcity.cz','csarmady184','mail.poda.cz',25,'abra@cemat.cz',mto,'','',mBO.DisplayName,mbo.DisplayName+' byla potvrzena',commAsText,'');
   mbo.Save;
   result:=mbo.DisplayName+' Email byl odeslan na: '+mTo;

   end;
end;

function ConfirmIO(Self: TNxWebServicesHelper;Order_ID: String):String; 
var
 mBO:TNxCustomBusinessObject;
 mUserBO:TNxCustomBusinessObject;
 mAddress:TNxCustomBusinessObject;
 mTo:String;
begin
   if not(NxIsEmptyOID(Order_ID)) then begin
   mbo:=self.ObjectSpace.CreateObject(Class_IssuedOrder);
   mbo.Load(Order_ID,nil);
   mbo.SetFieldValueAsBoolean('U_Confirmed',true);
   mUserBO:=mbo.GetMonikerForFieldCode(mbo.GetFieldCode('CreatedBy_ID')).BusinessObject;
   mAddress:=mUserBO.GetMonikerForFieldCode(mUserBO.GetFieldCode('Address_ID')).BusinessObject;
   mto:=mAddress.GetFieldValueAsString('Email');
   if not(NxIsBlank(mTo)) then
   CFxInternet.SMTPSendMailWithMoreFiles(csOpenSSL,'cemat@mailcity.cz','csarmady184','mail.poda.cz',25,'abra@cemat.cz',mto,'','',mBO.DisplayName,mbo.DisplayName+' byla potvrzena',commAsText,'');
   mbo.Save;
   result:=mbo.DisplayName+' Email byl odeslan na: '+mTo;

   end;
end;

function ConfirmDV(Self: TNxWebServicesHelper;Order_ID: String):String;
var
 mBO:TNxCustomBusinessObject;
 mUserBO:TNxCustomBusinessObject;
 mAddress:TNxCustomBusinessObject;
 mTo:String;
begin
   if not(NxIsEmptyOID(Order_ID)) then begin
   mbo:=self.ObjectSpace.CreateObject(Class_IssuedCreditNote);
   mbo.Load(Order_ID,nil);
   mbo.SetFieldValueAsBoolean('U_Confirmed',true);
   mUserBO:=mbo.GetMonikerForFieldCode(mbo.GetFieldCode('CreatedBy_ID')).BusinessObject;
   mAddress:=mUserBO.GetMonikerForFieldCode(mUserBO.GetFieldCode('Address_ID')).BusinessObject;
   mto:=mAddress.GetFieldValueAsString('Email');
   if not(NxIsBlank(mTo)) then
   CFxInternet.SMTPSendMailWithMoreFiles(csOpenSSL,'cemat@mailcity.cz','csarmady184','mail.poda.cz',25,'abra@cemat.cz',mto,'','',mBO.DisplayName,mbo.DisplayName+' byl potvrzen',commAsText,'');
   mbo.Save;
   result:=mbo.DisplayName+' Email byl odeslan na: '+mTo;

   end;
end;

begin
end.