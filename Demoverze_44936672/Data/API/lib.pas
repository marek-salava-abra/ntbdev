uses '.const';


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


procedure GET_IssuedOrder(AContext:TNxContext; ARequest: TAPIRequest; AResponse: TAPIResponse);
var
  mHeaders: TStringList;
  i: Integer;
  mOrder_ID, mResBody, mTO:string;
  mBO:TNxCustomBusinessObject;
begin
  mHeaders := TStringList.Create;
  try
    mOrder_ID:=ARequest.GetQueryParamValue('order_id');
    if not(NxIsEmptyOID(mOrder_ID)) then begin
      mBO:=AContext.GetObjectSpace.CreateObject(Class_IssuedOrder);
      mBO.Load(mOrder_ID,nil);
      mResBody:=NxSearchReplace(cBody,'#CISLO#',mBO.DisplayName,[srall]);
      mbo.SetFieldValueAsBoolean('U_Confirmed',true);
      mBO.save;
      mTO:=mbo.GetFieldValueAsString('CreatedBy_ID.Address_ID.Email');
      if NxIsValidEMail(mTO,false) then begin
       mResBody:=NxSearchReplace(mResBody,'#INFO#','Email byl odeslán na adresu '+mTO,[srall]);
       SendInternalMail(AContext.GetObjectSpace,mTo,'','',
                         'Objednávka vydaná číslo '+mbo.DisplayName+' byl potvrzen','Doklad byl potvrzen',
                         '',mBO.GetFieldValueAsString('Firm_ID'),mbo.GetLoadedCollectionMonikerForFieldCode(mBO.GetFieldCode('Rows')).BusinessObject[0].GetFieldValueAsString('Division_ID'),
                            mbo.GetLoadedCollectionMonikerForFieldCode(mbo.GetFieldCode('Rows')).BusinessObject[0].GetFieldValueAsString('BusTransaction_ID'), mBO.OID,2);

      end else begin
       mResBody:=NxSearchReplace(mResBody,'#INFO#','',[srall]);
      end;
      mBO.free;
    end;
    AResponse.Body := mResBody;
    AResponse.SetHeader('Content-Type','text/html');
    AResponse.Status := 200;
  finally
    mHeaders.Free;
  end;
end;



procedure SendInternalMail(AOS:TNxCustomObjectSpace; ATo, ACC, ABCC, ASubject, ABody, AAtachement, AFirm_ID, ADivision_ID, ABusTransaction_ID, aDocument_ID:String; aEmailType:Integer);
Var
  mMailBO, mMailRecipient:TNxCustomBusinessObject;
  mMRecipients:TNxCustomBusinessMonikerCollection;
  mUserXLink:TNxCustomBusinessObject;
begin
  if not(ato='') then begin
     mMailBO:=AOS.CreateObject('5C1HWDQDR3J4NAAYZRO5PWHLWK');
     mMailBO.New;
     mMailBO.Prefill;
     mMailBO.SetFieldValueAsString('EmailAccount_ID',cEmailAccount_ID);
     mMailBO.SetFieldValueAsString('Subject',ASubject);
     mMailBO.SetFieldValueAsBoolean('AddSentIdent',False);
     mMailbo.SetFieldValueAsInteger('SentState',1);
     mmailbo.SetFieldValueAsInteger('BodySavedAs',1);
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
      if FileExists(AAtachement) then TNxEmailSent(mMailBO).AttachFile(AAtachement);

     end;
     mMailBO.Save;
      if aEmailType=1 then begin
          mUserXLink:=AOS.CreateObject(Class_UserXLink);
          try
            mUserXLink.new;
            mUserXLink.prefill;
            mUserXLink.SetFieldValueAsString('Source_ID', mMailBO.OID);
            mUserXLink.SetFieldValueAsString('SourceCLSID',Class_EmailSent);
            mUserXLink.SetFieldValueAsString('Destination_ID',aDocument_ID);
            mUserXLink.SetFieldValueAsString('DestinationCLSID',Class_IssuedOrder);
            mUserXLink.SetFieldValueAsBoolean('DisplayAsSystem',True);
            mUserXLink.save;
          finally
           mUserXLink.free;
          end;
      end;
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