{
Vyvolává se po uložení vlastních dat objektu do databáze.
}
procedure AfterSave_Hook(Self: TNxCustomBusinessObject);
var
 mOrigDate:Extended;
 mTO, mBody:string;
begin
  if (NxGetActualUserID_1(self)='1EE0000101') and not(nxisblank(self.GetFieldValueAsString('U_vyrobni_cislo'))) then begin
    self.GetOriginalValue_1('ScheduledAt$DATE',mOrigDate);
    if not(mOrigDate=self.GetFieldValueAsDateTime('ScheduledAt$DATE')) then begin
      mBody:='';
      mTO:=self.GetFieldValueAsString('BusTransaction_ID.X_mailop');
      if not(NxIsValidEMail(mTO,false)) then begin
        mTO:='maler@spedos.cz';
        mBody:='Není vyplněn email na obchodním případu '+self.GetFieldValueAsString('BusTransaction_ID.Code')+' '+self.GetFieldValueAsString('BusTransaction_ID.Name');
      end;
      SendInternalMail(self.ObjectSpace, mTO,'',
                               'Změna termínu pro výrobní číslo '+self.GetFieldValueAsString('U_vyrobni_cislo')+' na výrobním příkaze '+self.DisplayName,mBody,
                               '',self.GetFieldValueAsString('Firm_ID'),self.GetFieldValueAsString('Division_ID'),Self.GetFieldValueAsString('BusOrder_ID'), '');
    end;
  end;
end;

procedure SendInternalMail(AOS:TNxCustomObjectSpace; ATo:String; ACC:String; ASubject:String; ABody:String; AAtachement:String; AFirm_ID:String;
  ADivision_ID:String; ABusOrder_ID:String; AReplyTo:string;);
Var
  mMailBO:TNxCustomBusinessObject;
  mMRecipients:TNxCustomBusinessMonikerCollection;
  mMailRecipient:TNxCustomBusinessObject;
begin
  if not(ato='') then begin
     mMailBO:=AOS.CreateObject('5C1HWDQDR3J4NAAYZRO5PWHLWK');
     mMailBO.New;
     mMailBO.Prefill;
     mMailBO.SetFieldValueAsString('EmailAccount_ID','2100000101');
     mMailBO.SetFieldValueAsString('Subject',ASubject);
     mMailbo.SetFieldValueAsInteger('SentState',1);
     mMailBO.SetFieldValueAsInteger('BodySavedAs',1);
     mMailBO.SetFieldValueAsString('Body',ABody);
     mMailBO.SetFieldValueAsString('Firm_ID',AFirm_ID);
     mMailBO.SetFieldValueAsString('Division_ID',ADivision_ID);
     mMailBO.SetFieldValueAsString('BusOrder_ID',ABusOrder_ID);
     mMailBO.SetFieldValueAsString('ReplyTo',AReplyTo);
     mMRecipients:=mMailBO.GetLoadedCollectionMonikerForFieldCode(mMailBO.GetFieldCode('Recipients'));

     mMailRecipient:=mMRecipients.AddNewObject;
     mMailRecipient.SetFieldValueAsString('Email',ATo);
     mMailRecipient.SetFieldValueAsInteger('EmailType',0);
     if not(acc='') then begin
     mMailRecipient:=mMRecipients.AddNewObject;
     mMailRecipient.SetFieldValueAsString('Email',ACC);
     mMailRecipient.SetFieldValueAsInteger('EmailType',1);
     end;
     if not(AAtachement='') then begin
      if FileExists(AAtachement) then TNxEmailSent(mMailBO).AttachFile(AAtachement);

     end;
     mMailBO.Save;
     mMailBO.free;

  end;
end;

begin
end.