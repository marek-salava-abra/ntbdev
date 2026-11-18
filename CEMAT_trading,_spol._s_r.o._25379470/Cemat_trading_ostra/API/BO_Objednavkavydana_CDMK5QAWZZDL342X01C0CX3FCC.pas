uses '.lib';

procedure AfterSave_Hook(Self: TNxCustomBusinessObject);
var
mList: TStringList;
mFileName:String;
mBody, mURL: string;
mContext:TNxContext;
begin
 if not(self.GetFieldValueAsBoolean('U_confirmed')) and (self.GetFieldValueAsFloat('LocalAmountWithoutVAT')>300000) then begin
    mURL:=NxSearchReplace(cURL3,'#DOCUMENTID#',self.OID,[srAll]);
    mBody:=NxSearchReplace(cMailBody,'#CISLO#',self.DisplayName,[srall]);
    mBody:=NxSearchReplace(mBody,'#DOKLAD#','Objednávka vydaná ',[srall]);
    mBody:=NxSearchReplace(mBody,'#URL#',mURL,[srall]);
    mlist:=TStringList.Create;
    mFilename:=self.oid+'.pdf';
    mlist.add(self.OID);
    mContext:=NxCreateContext_1(self);
    CFxReportManager.PrintByIDs(mContext,mlist,'W0NZQGROZZDL342X01C0CX3FCC', '2E00000101', rtoFile, pekpdf, NxGetTempDir, mfilename);
    SendInternalMail(self.ObjectSpace,'dzupin@cemat.cz','hlavni.ucetni@cemat.cz','kracmar@cemat.cz',
                         'Čemat trading s.r.o. objednávka číslo : '+self.DisplayName,mBody,
                         NxGetTempDir+'\'+mFileName,self.GetFieldValueAsString('Firm_ID'),self.GetLoadedCollectionMonikerForFieldCode(self.GetFieldCode('Rows')).BusinessObject[0].GetFieldValueAsString('Division_ID'),self.GetLoadedCollectionMonikerForFieldCode(self.GetFieldCode('Rows')).BusinessObject[0].GetFieldValueAsString('BusTransaction_ID'));
    mContext.free;
  end;
end;

begin
end.