procedure SendInternalMail(AOS:TNxCustomObjectSpace; ATo:String; ACC:String; ABCC:String;
                           ASubject:String; ABody:String; AAtachement, AAtachement2:String; AFirm_ID:String; ADivision_ID:String; ABusTransaction_ID:String; aAccount_ID:string; aOrder_ID:string);
Var
  mMailBO,mUserXLink, mOrderBO:TNxCustomBusinessObject;
  mMRecipients:TNxCustomBusinessMonikerCollection;
  mMailRecipient:TNxCustomBusinessObject;
begin
  if not(ato='') then begin
     mMailBO:=AOS.CreateObject('5C1HWDQDR3J4NAAYZRO5PWHLWK');
     mMailBO.New;
     mMailBO.Prefill;
     mMailBO.SetFieldValueAsString('EmailAccount_ID',aAccount_ID);
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

     if not(AAtachement2='') then begin
      TNxEmailSent(mMailBO).AttachFile(AAtachement2);

     end;
     if not(NxIsEmptyOID(aOrder_ID)) then begin
        mOrderBO:=aos.CreateObject(Class_ReceivedOrder);
        mOrderBO.load(aOrder_ID,nil);
        if mOrderBO.GetFieldValueAsString('U_OrderState_ID')='8C92000101' then begin
          if FileExists('d:\AbraGen\dokumenty\reklamacni-rad-simon-eshop.pdf') then
            TNxEmailSent(mMailBO).AttachFile('d:\AbraGen\dokumenty\reklamacni-rad-simon-eshop.pdf');
          if FileExists('d:\AbraGen\dokumenty\op-e-shop-simon-k-25.2.2026.pdf') then
            TNxEmailSent(mMailBO).AttachFile('d:\AbraGen\dokumenty\op-e-shop-simon-k-25.2.2026.pdf');
        end;
        mOrderBO.free;
     end;
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

function GetZLV_ID(AOS : TNxCustomObjectSpace; aOrder_ID: string) : string;
const
  cSQL = 'SELECT ID FROM IssuedDInvoices WHERE ReceivedOrder_ID=''%s'' ';
var
  mList : TStringList;
begin
  mList := TStringList.Create;
  try
    AOS.SQLSelect(Format(cSQL, [aOrder_ID]), mList);
    if mList.Count > 0 then
      Result := mList.Strings[0]
      else Result:=''
  finally
    mList.Free;
  end;
end;

function GetRO_ID(AOS : TNxCustomObjectSpace; aOrder_ID: string) : string;
const
  cSQL = 'SELECT ID FROM ReceivedOrders WHERE ExternalNumber=''%s'' and docqueue_id=''1W10000101'' ';
var
  mList : TStringList;
begin
  mList := TStringList.Create;
  try
    AOS.SQLSelect(Format(cSQL, [aOrder_ID]), mList);
    if mList.Count > 0 then
      Result := mList.Strings[0]
      else Result:=''
  finally
    mList.Free;
  end;
end;

function GetDZV_ID(AOS : TNxCustomObjectSpace; aZLV_ID: string) : string;
const
  cSQL = 'SELECT PDocument_ID FROM issueddeposITUSAGES WHERE DepositDocument_ID=''%s'' and PDocumentType=''62'' ';
var
  mList : TStringList;
begin
  mList := TStringList.Create;
  try
    AOS.SQLSelect(Format(cSQL, [aZLV_ID]), mList);
    if mList.Count > 0 then
      Result := mList.Strings[0]
      else Result:=''
  finally
    mList.Free;
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

begin
end.