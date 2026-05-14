procedure SendInternalMail(AOS:TNxCustomObjectSpace; ATo:String; ACC:String; ASubject:String; ABody:String; AAtachement:String; AFirm_ID:String; ADivision_ID:String; ABusOrder_ID:String; AReplyTo:string;);
Var
  mMailBO:TNxCustomBusinessObject;
  mMRecipients:TNxCustomBusinessMonikerCollection;
  mMailRecipient:TNxCustomBusinessObject;
begin
  if not(ato='') then begin
     mMailBO:=AOS.CreateObject('5C1HWDQDR3J4NAAYZRO5PWHLWK');
     mMailBO.New;
     mMailBO.Prefill;
     mMailBO.SetFieldValueAsString('EmailAccount_ID','1100000101');
     mMailBO.SetFieldValueAsString('Subject',ASubject);
     mMailbo.SetFieldValueAsInteger('SentState',1);
     mMailBO.SetFieldValueAsInteger('BodySavedAs',1);
     mMailBO.SetFieldValueAsString('Body',ABody);
     mMailBO.SetFieldValueAsString('Firm_ID',AFirm_ID);
     mMailBO.SetFieldValueAsString('Division_ID',ADivision_ID);
     mMailBO.SetFieldValueAsString('BusOrder_ID',ABusOrder_ID);
     mMailBO.SetFieldValueAsString('ReplyTo',AReplyTo);
     mMRecipients:=mMailBO.GetCollectionMonikerForFieldCode(mMailBO.GetFieldCode('Recipients'));

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