const
 cBody = '<!DOCTYPE html><html lang="cs"><head><meta charset="UTF-8"><meta name="viewport" content="width=device-width, initial-scale=1.0">'+
         '<title>Potvrzení dokladu #CISLO#</title><style>'+
         ' body { margin: 0; padding: 0; font-family: sans-serif; display: flex; flex-direction: column; '+
         ' justify-content: center; align-items: center; height: 100vh; background-color: #f7f7f7; text-align: center; '+
         '     }'+
         ' .message-box {font-size: 1.5em; color: #333; padding: 20px; border: 2px solid #4caf50; border-radius: 10px; background-color: #e8f5e9; '+
         '   box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1); } '+
         ' .thank-you { margin-top: 40px; font-size: 1.1em; color: #555; } '+
         '</style></head><body><div class="message-box">'+
         ' Doklad <strong>#CISLO#</strong> byl potvrzen '+
         ' </div><div class="thank-you"> #INFO# </div> </body></html>';
 cMailBody = '<!DOCTYPE html><html lang="cs"><head><meta charset="UTF-8"><meta name="viewport" content="width=device-width, initial-scale=1.0">'+
             '<title>Potvrzení dokladu #CISLO#</title><style> '+
             ' body {margin: 0; padding: 0; font-family: sans-serif; display: flex; justify-content: center; align-items: center;'+
             ' height: 100vh; background-color: #f0f0f0; } '+
             ' .container {text-align: center;} '+
             ' .message {font-size: 1.4em; margin-bottom: 20px; color: #333;} '+
             ' .button {background-color: #4caf50; color: white; padding: 15px 30px; font-size: 1.2em;'+
             '  border: none; border-radius: 8px; text-decoration: none; display: inline-block; box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1); '+
             '  transition: background-color 0.2s ease-in-out; } '+
             ' .button:hover {background-color: #45a049; } '+
             '</style></head><body><div class="container"><br><br><div class="message">#DOKLAD# <strong>#CISLO#</strong> potvrdíte kliknutím na následující odkaz</div>'+
             '<a class="button" href="#URL#">Potvrdit</a></div></body></html>';
  cURL = 'https://mail.cemat.cz:8088/Cemat_trading_ostra/script/API/lib/receivedorder?order_id=#DOCUMENTID#&Auth=V2ViQVBJOmE';
  cURL2 = 'https://mail.cemat.cz:8088/Cemat_trading_ostra/script/API/lib/IssuedCreditNote?creditnote_id=#DOCUMENTID#&Auth=V2ViQVBJOmE';
  cURL3 = 'https://mail.cemat.cz:8088/Cemat_trading_ostra/script/API/lib/Issuedorder?order_id=#DOCUMENTID#&Auth=V2ViQVBJOmE';
{GET_ReceivedOrder}

procedure GET_ReceivedOrder(AContext:TNxContext; ARequest: TAPIRequest; AResponse: TAPIResponse);
var
  mHeaders: TStringList;
  i: Integer;
  mOrder_ID, mResBody, mTO:string;
  mOrderBO:TNxCustomBusinessObject;
begin
  mHeaders := TStringList.Create;
  try
    mOrder_ID:=ARequest.GetQueryParamValue('order_id');
    if not(NxIsEmptyOID(mOrder_ID)) then begin
      mOrderBO:=AContext.GetObjectSpace.CreateObject(Class_ReceivedOrder);
      mOrderBO.Load(mOrder_ID,nil);
      mResBody:=NxSearchReplace(cBody,'#CISLO#',mOrderBO.DisplayName,[srall]);
      mOrderBO.SetFieldValueAsBoolean('U_Confirmed',true);
      mOrderBO.save;
      mTO:=mOrderBO.GetFieldValueAsString('CreatedBy_ID.Address_ID.Email');
      if NxIsValidEMail(mTO,false) then begin
       mResBody:=NxSearchReplace(mResBody,'#INFO#','Email byl odeslán na adresu '+mTO,[srall]);
       SendInternalMail(AContext.GetObjectSpace,mTo,'','',
                         'Objednávka přijatá číslo '+mOrderBO.DisplayName+' byla potvrzena','Doklad byl potvrzen',
                         '',mOrderBO.GetFieldValueAsString('Firm_ID'),mOrderBO.GetLoadedCollectionMonikerForFieldCode(mOrderBO.GetFieldCode('Rows')).BusinessObject[0].GetFieldValueAsString('Division_ID'),
                            mOrderBO.GetLoadedCollectionMonikerForFieldCode(mOrderBO.GetFieldCode('Rows')).BusinessObject[0].GetFieldValueAsString('BusTransaction_ID'));

      end else begin
       mResBody:=NxSearchReplace(mResBody,'#INFO#','',[srall]);
      end;
      mOrderBO.free;
    end;
    AResponse.Body := mResBody;
    AResponse.SetHeader('Content-Type','text/html');
    AResponse.Status := 200;
  finally
    mHeaders.Free;
  end;
end;

procedure GET_IssuedCreditNote(AContext:TNxContext; ARequest: TAPIRequest; AResponse: TAPIResponse);
var
  mHeaders: TStringList;
  i: Integer;
  mCreditNote_ID, mResBody, mTO:string;
  mBO:TNxCustomBusinessObject;
begin
  mHeaders := TStringList.Create;
  try
    mCreditNote_ID:=ARequest.GetQueryParamValue('creditnote_id');
    if not(NxIsEmptyOID(mCreditNote_ID)) then begin
      mBO:=AContext.GetObjectSpace.CreateObject(Class_IssuedCreditNote);
      mBO.Load(mCreditNote_ID,nil);
      mResBody:=NxSearchReplace(cBody,'#CISLO#',mBO.DisplayName,[srall]);
      mbo.SetFieldValueAsBoolean('U_Confirmed',true);
      mBO.save;
      mTO:=mbo.GetFieldValueAsString('CreatedBy_ID.Address_ID.Email');
      if NxIsValidEMail(mTO,false) then begin
       mResBody:=NxSearchReplace(mResBody,'#INFO#','Email byl odeslán na adresu '+mTO,[srall]);
       SendInternalMail(AContext.GetObjectSpace,mTo,'','',
                         'Dobropis číslo '+mbo.DisplayName+' byl potvrzen','Doklad byl potvrzen',
                         '',mBO.GetFieldValueAsString('Firm_ID'),mbo.GetLoadedCollectionMonikerForFieldCode(mBO.GetFieldCode('Rows')).BusinessObject[0].GetFieldValueAsString('Division_ID'),
                            mbo.GetLoadedCollectionMonikerForFieldCode(mbo.GetFieldCode('Rows')).BusinessObject[0].GetFieldValueAsString('BusTransaction_ID'));

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
                            mbo.GetLoadedCollectionMonikerForFieldCode(mbo.GetFieldCode('Rows')).BusinessObject[0].GetFieldValueAsString('BusTransaction_ID'));

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

function POST_Quantity(AContext: TNXContext; AInput: TJSONSuperObject; APath: String): TJSONSuperObject;
var
 mBO, mSSCBO:TNxCustomBusinessObject;
 i:integer;
 mList:TStringList;
 mCode, mEan, mStoreCard_ID:string;
 mJSON:TJSONSuperObject;
begin
  Result:=TJSONSuperObject.create;
  try
    mCode:=AInput.S['code'];
    mEan:=AInput.S['ean'];
    mStoreCard_ID:=AContext.SQLSelectFirstAsString('Select id from storecards where hidden=''N'' and code='+QuotedStr(mCode),'');
    if NxIsEmptyOID(mStoreCard_ID) then mStoreCard_ID:=AContext.SQLSelectFirstAsString('Select id from storecards where hidden=''N'' and ean='+QuotedStr(mEan),'');
    if not(NxIsEmptyOID(mStoreCard_ID)) then begin
     mList:=TStringList.Create;
     AContext.SQLSelect('Select ssc.id from storesubcards ssc left join stores s on s.id=ssc.store_id where ssc.storecard_id='+QuotedStr(mStoreCard_ID)+' and s.X_XMLFeed=''A'' ',mList);

     Result.O['quantities'] := Result.CreateJSONArray;
        for i:=0 to mList.Count -1 do begin
          mJSON:=TJSONSuperObject.Create;
          mSSCBO:=AContext.GetObjectSpace.CreateObject(Class_StoreSubCard);
          mSSCBO.load(mlist.Strings[i],nil);
          mJSON.D['quantity']:=mSSCBO.GetFieldValueAsFloat('quantity');
          mJSON.S['storecode']:=mSSCBO.GetFieldValueAsString('Store_ID.Code');
          mJSON.S['storename']:=mSSCBO.GetFieldValueAsString('Store_ID.name');
          mSSCBO.Free;
          Result.A['quantities'].Add(mJSON);
        end;
      Result.S['code']:=mCode;
      Result.S['ean']:=mEan;
      Result.S['result']:='OK';
      Result.S['message']:='';
    end else begin
      Result.S['code']:=mCode;
      Result.S['ean']:=mEan;
      Result.S['result']:='Error';
      Result.S['message']:='Not found';
    end;
  except
   Result.S['result']:='Error';
   Result.S['message']:=ExceptionMessage;
  end;
end;


procedure SendInternalMail(AOS:TNxCustomObjectSpace; ATo:String; ACC:String; ABCC:String; ASubject:String; ABody:String; AAtachement:String; AFirm_ID:String; ADivision_ID:String; ABusTransaction_ID:String);
Var
  mMailBO:TNxCustomBusinessObject;
  mMRecipients:TNxCustomBusinessMonikerCollection;
  mMailRecipient:TNxCustomBusinessObject;
begin
  if not(ato='') then begin
     mMailBO:=AOS.CreateObject('5C1HWDQDR3J4NAAYZRO5PWHLWK');
     mMailBO.New;
     mMailBO.Prefill;
     mMailBO.SetFieldValueAsString('EmailAccount_ID','1000000101');
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