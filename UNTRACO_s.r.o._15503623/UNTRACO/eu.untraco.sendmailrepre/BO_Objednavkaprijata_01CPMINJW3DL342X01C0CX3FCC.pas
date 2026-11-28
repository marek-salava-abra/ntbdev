uses 'eu.untraco.sendmailrepre.mail';

{
Umožňuje ovlivnit validaci.
}


{
Vyvolává se po uložení vlastních dat objektu do databáze.
}
procedure AfterSave_Hook(Self: TNxCustomBusinessObject);
var
 mList:TStringList;
 mFileName:String;
begin
 { if osNew in self.State then begin
    if NxIsValidEMail(self.GetFieldValueAsString('Firm_ID.U_email_repre'),False) then begin
      mList:=TStringList.Create;
      mlist.Add(self.OID);
      mFileName:=NxSearchReplace(self.DisplayName,'/','-',[srAll]);
      CFxReportManager.PrintByIDs(NxCreateContext_1(self), mList, '40V53DORW3DL342X01C0CX3FCC', 'UM10000101', rtoFile, pekPDF, NxGetTempDir, mFileName + '.pdf');
       SendInternalMail(self.ObjectSpace, self.GetFieldValueAsString('Firm_ID.U_email_repre'),'','',
                         'Objednávka : '+self.GetFieldValueAsString('Firm_ID.Name')+' '+self.DisplayName,'',
                         NxGetTempDir+'\'+ mFileName + '.pdf',self.GetFieldValueAsString('Firm_ID'),
                         Self.GetLoadedCollectionMonikerForFieldCode(self.GetFieldCode('Rows')).BusinessObject[0].GetFieldValueAsString('Division_ID'),
                         self.GetLoadedCollectionMonikerForFieldCode(self.GetFieldCode('Rows')).BusinessObject[0].GetFieldValueAsString('BusTransaction_ID'));
      DeleteFile(NxGetTempDir+'\'+ mFileName + '.pdf');
      mlist.Free;
    end;
  end; }
end;

begin
end.