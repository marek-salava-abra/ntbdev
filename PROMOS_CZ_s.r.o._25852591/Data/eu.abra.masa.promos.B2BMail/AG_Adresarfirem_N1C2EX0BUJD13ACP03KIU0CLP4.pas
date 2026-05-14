procedure InitSite_Hook(Self: TSiteForm);
var
  mAction, mAction2: TBasicAction;
begin
  mAction := Self.GetNewAction;
  mAction.ShowControl := True;
  mAction.ShowMenuItem := True;
  mAction.Name := 'actB2BMail';
  mAction.Caption := 'B2B mail';
  mAction.Hint := 'B2B odešle mail';
  mAction.Category := 'tabDetail';
  mAction.OnExecute := @B2BMail;
end;

Procedure B2BMail(Sender:Tcomponent);
var
 mSite:TSiteForm;
 mCurrBO, mTextBO, mRowObject:TNxCustomBusinessObject;
 mEmail:string;
begin
  mSite:=TComponent(Sender).BusRollSite;
  mEmail:=InputBox('email','email','',msite);
  mTextBO:= TBusRollSiteForm(msite).BaseObjectSpace.CreateObject('DCHDUXZ0S3RO1DVWDVB0PD51U0');
  mTextBO.Load('M3U0000101', nil);
  SendInternalMail(mSite.BaseObjectSpace, meMail, '', '', mTextBO.GetFieldValueAsString('X_subject'), mTextBO.GetFieldValueAsString('X_note'),
                      '', TBusRollSiteForm(msite).CurrentObject.OID, '1000000101', '', '');
end;


function SendInternalMail(mObjectSpace: TNxCustomObjectSpace; mTo: String; mCC: String; mBCC: String; mSubject: String; mBody: String; mAtachement: String; mFirm_ID: String; mDivision_ID: String; mBusOrder_ID: String; mReplyTo: string): string;

  var
    mMailBO: TNxCustomBusinessObject;
    mMRecipients: TNxCustomBusinessMonikerCollection;
    mMailRecipient: TNxCustomBusinessObject;

  begin
    if not(mTo = '') then
      begin
        mMailBO:= mObjectSpace.CreateObject('5C1HWDQDR3J4NAAYZRO5PWHLWK');
        mMailBO.New();
        mMailBO.Prefill();
        mMailBO.SetFieldValueAsString('EmailAccount_ID', '1200000101');
        mMailBO.SetFieldValueAsString('Subject', mSubject);
        mMailbo.SetFieldValueAsInteger('SentState', 1);
        mMailBO.SetFieldValueAsInteger('BodySavedAs', 1);
        mMailBO.SetFieldValueAsString('Body', mBody);
        mMailBO.SetFieldValueAsString('Firm_ID', mFirm_ID);
        mMailBO.SetFieldValueAsString('Division_ID', mDivision_ID);
        mMailBO.SetFieldValueAsString('BusOrder_ID', mBusOrder_ID);
        mMailBO.SetFieldValueAsString('ReplyTo', mReplyTo);
        mMRecipients:= mMailBO.GetCollectionMonikerForFieldCode(mMailBO.GetFieldCode('Recipients'));

        mMailRecipient:= mMRecipients.AddNewObject();
        mMailRecipient.SetFieldValueAsString('Email', mTo);
        mMailRecipient.SetFieldValueAsInteger('EmailType', 0);

        if not(mCC = '') then
          begin
            mMailRecipient:= mMRecipients.AddNewObject();
            mMailRecipient.SetFieldValueAsString('Email', mCC);
            mMailRecipient.SetFieldValueAsInteger('EmailType', 1);
          end;

        if not(mBCC = '') then
          begin
            mMailRecipient:= mMRecipients.AddNewObject();
            mMailRecipient.SetFieldValueAsString('Email', mBCC);
            mMailRecipient.SetFieldValueAsInteger('EmailType', 2);
          end;

        if not(mAtachement = '') then
          begin
            if FileExists(mAtachement) then
              begin
                TNxEmailSent(mMailBO).AttachFile(mAtachement);
              end;
          end;

        mMailBO.Save();
        TNxEmailSent(mMailBO).SendMail();

        Result:= mMailBO.OID;
        mMailBO.free;
      end;
  end;

begin
end.