uses 'eu.abra.cematsk.sendmail.fce';



procedure AfterSave_Hook(Self: TNxCustomBusinessObject);
var
mList: TStringList;
mFileName:String;
mBody: string;
begin
 if (osNew in self.State) and  (self.GetFieldValueAsFloat('LocalAmountWithoutVAT')>10000) then begin
    mBody:='Nová objednávka';
    mlist:=TStringList.Create;
    mFilename:=self.oid+'.pdf';
    mlist.add(self.OID);
    CFxReportManager.PrintByIDs(NxCreateContext_1(self),mlist,'W0NZQGROZZDL342X01C0CX3FCC', 'A700000001', rtoFile, pekpdf, NxGetTempDir, mfilename);
     SendInternalMail(self.ObjectSpace, 'martiniak@cemat.sk','smykova@cemat.sk;vajdelova@cemat.sk','',
                         'Čemat, s.r.o. objednávka číslo : '+self.DisplayName,mBody,
                         NxGetTempDir+'\'+mFileName,self.GetFieldValueAsString('Firm_ID'),self.GetLoadedCollectionMonikerForFieldCode(self.GetFieldCode('Rows')).BusinessObject[0].GetFieldValueAsString('Division_ID'),self.GetLoadedCollectionMonikerForFieldCode(self.GetFieldCode('Rows')).BusinessObject[0].GetFieldValueAsString('BusTransaction_ID'));


    //CFxInternet.SMTPSendMailWithMoreFiles(csOpenSSL,'cemat@mailcity.cz','csarmady184','mail.poda.cz',25,'abra@cemat.cz','dzupin@cemat.cz;rihova@cemat.cz','','','Čemat Trading s.r.o. objednávka číslo'+self.DisplayName,mBody,commAsText,NxGetTempDir+'\'+mfilename);
    //CFxInternet.SMTPSendMailWithMoreFiles(True,'cemat@mailcity.cz','csarmady184','mail.poda.cz',25,'abra@cemat.cz','dzupin@cemat.cz;fojtu@cemat.cz',self.DisplayName,mBody,NxGetTempDir+'\'+mfilename,'');

  end;
end;

begin
end.