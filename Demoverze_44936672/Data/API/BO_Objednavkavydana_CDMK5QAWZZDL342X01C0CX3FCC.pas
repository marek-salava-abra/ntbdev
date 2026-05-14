uses '.lib', '.const';

procedure AfterSave_Hook(Self: TNxCustomBusinessObject);
var
 mList: TStringList;
 mFileName,mBody, mURL, mEmail_ID: string;
 mOS:TNxCustomObjectSpace;
begin
 mOS:=self.ObjectSpace;
 mEmail_ID:=mOS.SQLSelectFirstAsString('Select Source_ID from userxlinks where destination_id='+QuotedStr(self.OID)+' and sourceclsid='+QuotedStr(Class_EmailSent)+
                                       ' and destinationclsid='+QuotedStr(Class_IssuedOrder),'');
 if not(self.GetFieldValueAsBoolean('U_confirmed')) and (self.GetFieldValueAsFloat('LocalAmountWithoutVAT')>30) then begin
    mURL:=NxSearchReplace(cURL,'#DOCUMENTID#',self.OID,[srAll]);
    mBody:=NxSearchReplace(cMailBody,'#CISLO#',self.DisplayName,[srall]);
    mBody:=NxSearchReplace(mBody,'#DOKLAD#','Objednávka vydaná ',[srall]);
    mBody:=NxSearchReplace(mBody,'#URL#',mURL,[srall]);
    mlist:=TStringList.Create;
    mFilename:=self.oid+'.pdf';
    mlist.add(self.OID);
    CFxReportManager.PrintByIDs(NxCreateContext(mOS),mlist,GetDynSource(mOS,cIOForm_ID), cIOForm_ID, rtoFile, pekpdf, NxGetTempDir, mfilename);
    SendInternalMail(mOS,'marek.salava@abra.eu','','',
                         'Demodata s.r.o. - objednávka číslo : '+self.DisplayName,mBody,
                         NxGetTempDir+'\'+mFileName,self.GetFieldValueAsString('Firm_ID'),
                         self.GetLoadedCollectionMonikerForFieldCode(self.GetFieldCode('Rows')).BusinessObject[0].GetFieldValueAsString('Division_ID'),
                         self.GetLoadedCollectionMonikerForFieldCode(self.GetFieldCode('Rows')).BusinessObject[0].GetFieldValueAsString('BusTransaction_ID'),
                         self.oid,1);
    mList.free;
  end;
end;

begin
end.

begin
end.