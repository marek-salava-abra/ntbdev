uses 'eu.untraco.sendmailrepre.mail';

procedure _SaveChanges_PostHook(Self: TDynSiteForm);
var
 mBO:TNxCustomBusinessObject;
 mList:TStringList;
 mFileName:String;
begin
 if Assigned(TDynSiteForm(Self).CurrentObject) then begin
   mbo:=TDynSiteForm(Self).CurrentObject;
  if Assigned(mbo) then begin
   //NxShowSimpleMessage(mbo.GetFieldValueAsString('Firm_id.U_email_repre'),self);
    if NxIsValidEMail(mbo.GetFieldValueAsString('Firm_ID.U_email_repre'),False) then begin
      if NxMessageBox('Dotaz', 'Přejete si odeslat email reprezentantovi?', mdConfirm, mdbYesNo, 0, 0, False, Self)=mrYes then begin
      mList:=TStringList.Create;
      mlist.Add(mbo.OID);
      mFileName:=NxSearchReplace(mbo.DisplayName,'/','-',[srAll]);
      CFxReportManager.PrintByIDs(NxCreateContext_1(mBO), mList, '40V53DORW3DL342X01C0CX3FCC', 'S020000101', rtoFile, pekPDF, NxGetTempDir, mFileName + '.pdf');
       try
       SendInternalMail(mbo.ObjectSpace, mbo.GetFieldValueAsString('Firm_ID.U_email_repre'),'','',
                         'Objednávka : '+mbo.GetFieldValueAsString('Firm_ID.Name')+' '+mbo.DisplayName,'',
                         NxGetTempDir+'\'+ mFileName + '.pdf',mbo.GetFieldValueAsString('Firm_ID'),
                         mbo.GetLoadedCollectionMonikerForFieldCode(mbo.GetFieldCode('Rows')).BusinessObject[0].GetFieldValueAsString('Division_ID'),
                         mbo.GetLoadedCollectionMonikerForFieldCode(mbo.GetFieldCode('Rows')).BusinessObject[0].GetFieldValueAsString('BusTransaction_ID'));
       Except
        NxShowSimpleMessage('Nezdařilo se odeslat email',self);
       end;
      DeleteFile(NxGetTempDir+'\'+ mFileName + '.pdf');
      mlist.Free;
    end;
    end;
    end;
 end;
end;

begin
end.