uses 'eu.cemat.mail.mail';




{
Vyvolává se před fyzickým uložením vlastních dat objektu do databáze.
}
procedure BeforeSave_Hook(Self: TNxCustomBusinessObject);
var
 mBody:String;
 mUser:TNxCustomBusinessObject;
begin
  if not(self.GetFieldValueAsBoolean('U_neodesilat')) then begin

   if NxIsValidEMail(self.GetFieldValueAsString('Person_ID.Address_ID.email'),False) then begin
    mUser:=self.ObjectSpace.CreateObject(Class_SecurityUser);
    mUser.load(NxGetActualUserID_1(self),nil);
    mbody:='Vážený pane/paní,' +#10#13+#10#13+
           'Tímto Vám potvrzujeme přijetí Vaší objednávky č. '+self.GetFieldValueAsString('ExternalNumber')+ '.'+#13#10+
           'Dne '+FormatDateTime('d.m.yyyy',self.GetFieldValueAsDateTime('DocDate$Date'))+ ' jsme ji zaevidovali pod naším číslem objednávky '+Self.DisplayName+ '.'+#13#10+
           'V případě nesrovnalosti, připomínek či dotazů nás kontaktujte na následujících kontaktech:'+#13#10+#13#10+
           mUser.GetFieldValueAsString('LoginName')+#13#10+
           mUser.GetFieldValueAsString('Address_ID.PhoneNumber2')+#13#10+
           mUser.GetFieldValueAsString('Address_ID.Email')+#13#10+#13#10+
           'Děkujeme za Váši objednávku.';


   SendInternalMail(self.ObjectSpace,self.GetFieldValueAsString('Person_ID.Address_ID.email'),
        '','',
        'Evidence objednávky',mBody,'', self.GetFieldValueAsString('Firm_ID'),
                   '1000000101','');
   end;
   self.SetFieldValueAsBoolean('U_neodesilat',true);
  end;
end;

begin
end.