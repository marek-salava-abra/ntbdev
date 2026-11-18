uses 'eu.abra.cemat.sendmail.fce';

Const
 cInternalAddress='http://192.168.1.194:81/confirm/post3.php?order_id=';
 cExternalAddress='http://mail.cemat.cz:81/confirm/post3.php?order_id=';

procedure AfterSave_Hook(Self: TNxCustomBusinessObject);
var
mList: TStringList;
mFileName:String;
mBody: string;
mContext:TNxContext;
begin
 if not(self.GetFieldValueAsBoolean('U_confirmed')) then begin
    mBody:='Dobropis potvrdíte kliknutím na následující odkaz'+chr(13)+chr(10)+chr(13)+chr(10)+
           've firmě '+cInternalAddress+self.OID
           +chr(13)+chr(10)+chr(13)+chr(10)+
           'mimo firmu '+cExternalAddress+self.OID;
    mlist:=TStringList.Create;
    mFilename:=self.oid+'.pdf';
    mlist.add(self.OID);
    mContext:=NxCreateContext_1(self);
    //mContext.LogOn('Supervisor','ropamasa');
    CFxReportManager.PrintByIDs(mContext,mlist,'KLFAXNODG3DL3ACT03KIU0CLP4', '3900000101', rtoFile, pekpdf, NxGetTempDir, mfilename);
     SendInternalMail(self.ObjectSpace, 'hlavni.ucetni@cemat.cz','postrzednikova@cemat.cz','',
                         'Čemat trading s.r.o. dobropis číslo : '+self.DisplayName,mBody,
                         NxGetTempDir+'\'+mFileName,self.GetFieldValueAsString('Firm_ID'),self.GetLoadedCollectionMonikerForFieldCode(self.GetFieldCode('Rows')).BusinessObject[0].GetFieldValueAsString('Division_ID'),self.GetLoadedCollectionMonikerForFieldCode(self.GetFieldCode('Rows')).BusinessObject[0].GetFieldValueAsString('BusTransaction_ID'));


    //CFxInternet.SMTPSendMailWithMoreFiles(csOpenSSL,'cemat@mailcity.cz','csarmady184','mail.poda.cz',25,'abra@cemat.cz','dzupin@cemat.cz;rihova@cemat.cz','','','Čemat Trading s.r.o. objednávka číslo'+self.DisplayName,mBody,commAsText,NxGetTempDir+'\'+mfilename);
    //CFxInternet.SMTPSendMailWithMoreFiles(True,'cemat@mailcity.cz','csarmady184','mail.poda.cz',25,'abra@cemat.cz','dzupin@cemat.cz;fojtu@cemat.cz',self.DisplayName,mBody,NxGetTempDir+'\'+mfilename,'');
    mContext.free;
  end;
end;

begin
end.