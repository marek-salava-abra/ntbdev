uses '.lib';

procedure AfterSave_Hook(Self: TNxCustomBusinessObject);
var
mList: TStringList;
mFileName:String;
mBody, mURL: string;
mContext:TNxContext;
begin
 if not(self.GetFieldValueAsBoolean('U_confirmed')) then begin
    mURL:=NxSearchReplace(cURL2,'#DOCUMENTID#',self.OID,[srAll]);
    mBody:=NxSearchReplace(cMailBody,'#CISLO#',self.DisplayName,[srall]);
    mBody:=NxSearchReplace(mBody,'#DOKLAD#','Dobropis',[srall]);
    mBody:=NxSearchReplace(mBody,'#URL#',mURL,[srall]);
    {mBody:='Dobropis potvrdíte kliknutím na následující odkaz'+chr(13)+chr(10)+chr(13)+chr(10)+
           've firmě '+cInternalAddress+self.OID
           +chr(13)+chr(10)+chr(13)+chr(10)+
           'mimo firmu '+cExternalAddress+self.OID;}
    mlist:=TStringList.Create;
    mFilename:=self.oid+'.pdf';
    mlist.add(self.OID);
    mContext:=NxCreateContext_1(self);
    CFxReportManager.PrintByIDs(mContext,mlist,'KLFAXNODG3DL3ACT03KIU0CLP4', '3900000101', rtoFile, pekpdf, NxGetTempDir, mfilename);
    SendInternalMail(self.ObjectSpace,'hlavni.ucetni@cemat.cz','postrzednikova@cemat.cz','',
                         'Čemat trading s.r.o. dobropis číslo : '+self.DisplayName,mBody,
                         NxGetTempDir+'\'+mFileName,self.GetFieldValueAsString('Firm_ID'),
                         self.GetLoadedCollectionMonikerForFieldCode(self.GetFieldCode('Rows')).BusinessObject[0].GetFieldValueAsString('Division_ID'),
                         self.GetLoadedCollectionMonikerForFieldCode(self.GetFieldCode('Rows')).BusinessObject[0].GetFieldValueAsString('BusTransaction_ID'));
    mContext.free;
  end;
end;

begin
end.