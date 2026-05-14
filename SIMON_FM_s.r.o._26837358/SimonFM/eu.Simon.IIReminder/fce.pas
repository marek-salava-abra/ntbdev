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
        mMailBO.SetFieldValueAsString('EmailAccount_ID', '2300000101');
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

function GetDynSource (AOS : TNxCustomObjectSpace; AValue : string) : String;

const
  cSQL = 'SELECT DataSource FROM Reports WHERE ID=''%s'' ';
var
  mList : TStringList;
begin
  mList := TStringList.Create;
  try
    Result:='';
    AOS.SQLSelect(Format(cSQL, [ AValue]), mList);
    if mList.Count > 0 then
      Result := (mList.Strings[0]);
  finally
    mList.Free;
  end;
end;

function scrEmail(AOS : TNxCustomObjectSpace) : String;
const
  cSQL = 'SELECT ud.stringfieldvalue from userdata ud where ud.clsid=''54UQK50OEKGOJBINOV1U5OYSGK'' and ud.fieldcode=2000014 and ud.id=''1W10000101'' ';
var
  mList : TStringList;
  mEmail: string;
begin
  mList := TStringList.Create;
  try
    AOS.SQLSelect(cSQL, mList);
    Result:='';
    if mList.Count > 0 then
      mEmail:= (mList.Strings[0]);
      if NxIsValidEMail(mEmail,true) then Result:=mEmail;

  finally
    mList.Free;
  end;
end;

function scrText(var AOS : TNxCustomObjectSpace;var AValue:String) : String;
const
  cSQL = 'SELECT id from defrolldata  where clsid=''DCHDUXZ0S3RO1DVWDVB0PD51U0'' and code=''%s'' and hidden=''N'' ';
var
  mList : TStringList;
begin
  mList := TStringList.Create;
  try
    AOS.SQLSelect(format(cSQL,[AValue]), mList);
    Result:='';
    if mList.Count > 0 then
      Result:= (mList.Strings[0]);

  finally
    mList.Free;
  end;
end;

begin
end.