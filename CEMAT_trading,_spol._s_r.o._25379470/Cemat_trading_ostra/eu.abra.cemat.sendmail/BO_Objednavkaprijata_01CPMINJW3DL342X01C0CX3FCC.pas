uses 'eu.abra.cemat.sendmail.fce';

Const
 cInternalAddress='http://192.168.1.194:81/confirm/post.php?order_id=';
 cExternalAddress='http://mail.cemat.cz:81/confirm/post.php?order_id=';
 
procedure AfterSave_Hook(Self: TNxCustomBusinessObject);
var
mList: TStringList;
mFileName, mTempDir:String;
mBody: string;
mContext:TNxContext;
begin
 if not(self.GetFieldValueAsBoolean('U_confirmed')) and (self.GetFieldValueAsFloat('LocalAmountWithoutVAT')>200000) then begin
    mBody:='VP potvrdíte kliknutím na následující odkaz'+chr(13)+chr(10)+chr(13)+chr(10)+
           've firmě '+cInternalAddress+self.OID
           +chr(13)+chr(10)+chr(13)+chr(10)+
           'mimo firmu '+cExternalAddress+self.OID;
    mlist:=TStringList.Create;
    mFilename:=self.oid+'.pdf';
    mlist.add(self.OID);
    mContext:=NxCreateContext_1(self);
    //mContext.LogOn('Supervisor','ropamasa');
   { mTempDir:=NxGetTempDir;
    if not(DirectoryExists('C:\temp')) then begin
      NxCreateDir('C:\temp');
      mTempDir:='C:\temp';
    end;
    if DirectoryExists('C:\temp') then mTempDir:='C:\temp'; }
    CFxReportManager.PrintByIDs(mContext,mlist,'40V53DORW3DL342X01C0CX3FCC', '1V10000101', rtoFile, pekpdf, NxGetTempDir, mfilename);
    //NxPrintByIDs(NxCreateContext_1(self),mlist,'40V53DORW3DL342X01C0CX3FCC', '1V10000101', rtoFile, pekpdf, mTempDir, '#'+mfilename);
    SendInternalMail(self.ObjectSpace, 'dzupin@cemat.cz','hlavni.ucetni@cemat.cz','kracmar@cemat.cz',
                         'Čemat trading s.r.o. objednávka přijatá číslo : '+self.DisplayName,mBody,
                         NxGetTempDir+mFileName,self.GetFieldValueAsString('Firm_ID'),
                         self.GetLoadedCollectionMonikerForFieldCode(self.GetFieldCode('Rows')).BusinessObject[0].GetFieldValueAsString('Division_ID'),
                         self.GetLoadedCollectionMonikerForFieldCode(self.GetFieldCode('Rows')).BusinessObject[0].GetFieldValueAsString('BusTransaction_ID'));
    //CFxInternet.SMTPSendMailWithMoreFiles(csOpenSSL,'cemat@mailcity.cz','csarmady184','mail.poda.cz',25,'abra@cemat.cz',
    //'dzupin@cemat.cz;','','','Čemat trading s.r.o. objednávka číslo : '+self.DisplayName,mBody,commAsText,NxGetTempDir+'\'+mfilename);
    //CFxInternet.SMTPSendMailWithMoreFiles(True,'cemat@mailcity.cz','csarmady184','mail.poda.cz',25,'abra@cemat.cz','dzupin@cemat.cz;fojtu@cemat.cz',self.DisplayName,mBody,NxGetTempDir+'\'+mfilename,'');
    mContext.free;
  end;
end;
begin
end.