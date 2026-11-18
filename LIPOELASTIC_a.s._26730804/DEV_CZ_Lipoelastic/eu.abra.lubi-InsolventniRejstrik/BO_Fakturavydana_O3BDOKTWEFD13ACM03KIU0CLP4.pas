uses 'eu.abra.lubi-InsolventniRejstrik.commons';

procedure BeforeSoftValidate_Hook(Self: TNxCustomBusinessObject);
begin
  ExBeforeSoftValidate_Hook(Self);
end;

{
Vyvolává se po uložení vlastních dat objektu do databáze.
}
procedure AfterSave_Hook(Self: TNxCustomBusinessObject);
var
  mS, mSQL, mIC: string;
  mMails: TStringList;
  cEmailSubject, cSMTPLogin, cSMTPPassword, cSMTPServer, cSendEmail: string;
  cSMTPPort, i: Integer;
  cText: string;
begin
  try
    mSQL:= 'Select ID from DefRollData where CLSID = ''%s'' and X_OrgIdentNumber = ''%s'' and Hidden=''N'' and Code=''A'' ';
    mSQL:= Format(mSQL, [cCLSIDInsolventIndexBussinesObject, Self.GetMonikerForFieldCode(Self.GetFieldCode('Firm_ID')).BusinessObject.GetFieldValueAsString('OrgIdentNumber')]);
    mS:= GetFirstRecordFromSQL(Self.ObjectSpace, mSQL);
    if mS <> '' then
    begin
      mMails:= TStringList.Create;
      try
        cEmailSubject:= GetPropertis(Self.ObjectSpace, 'Subject');// 'Insolvenční rejstřík';
        cSMTPLogin:= GetPropertis(Self.ObjectSpace, 'SMTPLogin');// 'trialabra@abra.eu';
        cSMTPPassword:= GetPropertis(Self.ObjectSpace, 'SMTPPass');// 'trial';
        cSMTPServer:= GetPropertis(Self.ObjectSpace, 'SMTPServer');// 'mail.abra.eu';
        try
          cSMTPPort:= StrToInt(GetPropertis(Self.ObjectSpace, 'SMTPPort'));// 25;
        except
          cSMTPPort:= 25;
        end;
        cSendEmail:= GetPropertis(Self.ObjectSpace, 'SMTPSender');// 'noreply@abra.eu';
        cText:= GetPropertis(Self.ObjectSpace, 'NewFVBody');// 'Byla zadána nová faktura %s na firmu %s která je v insolvenčním rejstříku.';
        cText:= Format(cText, [Self.DisplayName, Self.GetMonikerForFieldCode(Self.GetFieldCode('Firm_ID')).BusinessObject.GetFieldValueAsString('Name')]);
        GetEmails(Self.ObjectSpace, mMails);
        if (mMails.Count > 0) and (cSMTPServer <> '') then
        begin
          for i:= 0 to mMails.Count - 1 do begin
             ShowDebugMessage('Sending email from FV!!!! to: ' + mMails[i]);
             try
               CFxInternet.SMTPSendMailWithMoreFiles(csNone, cSMTPLogin, cSMTPPassword, cSMTPServer, cSMTPPort, cSendEmail, mMails[i], '', '', cEmailSubject, cText, commAsText, '');
             except
               ShowDebugMessage('Chyba - SMTPSendMailWithMoreFiles');
             end;
          end;
        end;
      finally
        mMails.Free;
      end;
    end;
  except
  end;
end;

begin
end.