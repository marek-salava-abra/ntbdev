uses 'eu.simon.eshop.mail';

procedure AfterSave_Hook(Self: TNxCustomBusinessObject);
var
 mFileName:String;
 mList:TStringList;
begin
  {if osNew in self.state then begin
     if self.GetFieldValueAsString('DocQueue_ID')='1W10000101' then begin
       if not(NxIsBlank(self.GetFieldValueAsString('Firm_id.U_bustransaction_ID.U_emailOP'))) then begin
        mList:=TStringList.Create;
        mlist.add(self.OID);
        mFileName:=NxSearchReplace(self.DisplayName,'/','-',[srAll])+'.pdf';
        CFxReportManager.PrintByIDs(NxCreateContext_1(self),mList,'40V53DORW3DL342X01C0CX3FCC','1550000101',rtoFile,pekPDF,NxGetTempDir,mFileName);
        SendInternalMail(self.ObjectSpace,self.GetFieldValueAsString('Firm_id.U_bustransaction_ID.U_emailOP'),
        self.GetFieldValueAsString('Firm_id.U_bustransaction_ID.U_emailAS'),'', 'Nová objednávka '+self.DisplayName,
        'Přišla nová objednávka',NxGetTempDir+'\'+mFileName, self.GetFieldValueAsString('Firm_ID'),
                   '1400000101','1000000101');
        DeleteFile(NxGetTempDir+mFileName);
       end;
     end;
  end; }
end;

begin
end.