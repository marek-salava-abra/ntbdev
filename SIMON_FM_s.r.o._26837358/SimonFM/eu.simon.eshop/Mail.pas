procedure SendInternalMail2(AOS:TNxCustomObjectSpace; ATo:String; ACC:String; ABCC:String;
                           ASubject:String; ABody:String; AAtachement:String; AFirm_ID:String; ADivision_ID:String; ABusTransaction_ID:String; aOrder_ID:string);
Var
  mMailBO,mUserXLink:TNxCustomBusinessObject;
  mMRecipients:TNxCustomBusinessMonikerCollection;
  mMailRecipient:TNxCustomBusinessObject;
begin
  if not(ato='') then begin
     mMailBO:=AOS.CreateObject('5C1HWDQDR3J4NAAYZRO5PWHLWK');
     mMailBO.New;
     mMailBO.Prefill;
     mMailBO.SetFieldValueAsString('EmailAccount_ID','2300000101');
     mMailBO.SetFieldValueAsString('Subject',ASubject);
     mMailBO.SetFieldValueAsString('BodySavedAs','1');
     mMailbo.SetFieldValueAsInteger('SentState',1);
     mMailBO.SetFieldValueAsString('Body',ABody);
     mMailBO.SetFieldValueAsString('Firm_ID',AFirm_ID);
     mMailBO.SetFieldValueAsString('Division_ID',ADivision_ID);
     mMailBO.SetFieldValueAsString('BusTransaction_ID',ABusTransaction_ID);
     mMRecipients:=mMailBO.GetCollectionMonikerForFieldCode(mMailBO.GetFieldCode('Recipients'));

     mMailRecipient:=mMRecipients.AddNewObject;
     mMailRecipient.SetFieldValueAsString('Email',ATo);
     mMailRecipient.SetFieldValueAsInteger('EmailType',0);
     if not(acc='') then begin
     mMailRecipient:=mMRecipients.AddNewObject;
     mMailRecipient.SetFieldValueAsString('Email',ACC);
     mMailRecipient.SetFieldValueAsInteger('EmailType',1);
     end;
     if not(ABCC='') then begin
     mMailRecipient:=mMRecipients.AddNewObject;
     mMailRecipient.SetFieldValueAsString('Email',ABCC);
     mMailRecipient.SetFieldValueAsInteger('EmailType',2);
     end;

     if not(AAtachement='') then begin
      TNxEmailSent(mMailBO).AttachFile(AAtachement);

     end;



     mMailBO.SetFieldValueAsString('EmailAccount_ID','2300000101');
     mMailBO.Save;
     if not(NxIsEmptyOID(aOrder_ID)) then begin
     mUserXLink := aOS.CreateObject(Class_UserXLink);
      try
        mUserXLink.New;
        mUserXLink.Prefill;
        mUserXLink.SetFieldValueAsString('SourceCLSID', Class_ReceivedOrder);
        mUserXLink.SetFieldValueAsString('Source_ID', aOrder_ID);
        mUserXLink.SetFieldValueAsString('DestinationCLSID', Class_EmailSent);
        mUserXLink.SetFieldValueAsString('Destination_ID', mMailBO.OID);
        mUserXLink.SetFieldValueAsBoolean('DisplayAsSystem', True);
        mUserXLink.SetFieldValueAsString('Description',ASubject);
        mUserXLink.Save;
      finally
        mUserXLink.Free;
      end;
     end;
     mMailBO.free;

  end;
end;

begin
end.