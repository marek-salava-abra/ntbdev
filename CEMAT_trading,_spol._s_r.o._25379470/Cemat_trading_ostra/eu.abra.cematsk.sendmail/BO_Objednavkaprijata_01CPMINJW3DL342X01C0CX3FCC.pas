uses 'eu.abra.cematsk.sendmail.fce';

procedure AfterSave_Hook(Self: TNxCustomBusinessObject);
var
mList: TStringList;
mFileName:String;
mBody: string;
begin
 if (osNew in self.State) and (self.GetFieldValueAsFloat('LocalAmountWithoutVAT')>10000) then begin
    mBody:='nová objednávka prijatá';
    mlist:=TStringList.Create;
    mFilename:=self.oid+'.pdf';
    mlist.add(self.OID);
    CFxReportManager.PrintByIDs(NxCreateContext_1(self),mlist,'40V53DORW3DL342X01C0CX3FCC', '1200000101', rtoFile, pekpdf, NxGetTempDir, mfilename);

    SendInternalMail(self.ObjectSpace, 'martiniak@cemat.sk','smykova@cemat.sk;vajdelova@cemat.sk','',
                         'Čemat, s.r.o. objednávka prijatá číslo : '+self.DisplayName,mBody,
                         NxGetTempDir+'\'+mFileName,self.GetFieldValueAsString('Firm_ID'),self.GetLoadedCollectionMonikerForFieldCode(self.GetFieldCode('Rows')).BusinessObject[0].GetFieldValueAsString('Division_ID'),self.GetLoadedCollectionMonikerForFieldCode(self.GetFieldCode('Rows')).BusinessObject[0].GetFieldValueAsString('BusTransaction_ID'));

  end;
end;
begin
end.