function GetOrderedQuantity(AOS : TNxCustomObjectSpace; aStoreCard_ID, ARow_ID, aStore_ID : string; ADate: Extended) : Extended;
const
  DecimalSeparator= '.';
  cSQL = 'SELECT SUM(Quantity-deliveredQuantity) FROM ReceivedOrders2 RO2 LEFT JOIN ReceivedOrders RO ON RO.ID = RO2.Parent_ID '+
          'WHERE RO.Confirmed = ''A'' and RO.Closed = ''N'' and RO2.StoreCard_ID = ''%s'' and RO2.ID <> ''%s'' and RO2.Store_ID = ''%s'' and CreatedAt$Date < %s  ';
var
  mList : TStringList;
begin
  mList := TStringList.Create;
  try
    AOS.SQLSelect(Format(cSQL, [aStoreCard_ID, ARow_ID, aStore_ID ,NxFloatToIBStr(ADate)]), mList);
    if mList.Count > 0 then
      Result := NxIBStrToFloat(mList.Strings[0])
      else Result:=0;
  finally
    mList.Free;
  end;
end;

function GetAvailableQuantity(AOS : TNxCustomObjectSpace; aStore_ID, aStoreCard_ID : string) : Extended;
const
  cSQL = 'SELECT Sum(Quantity-Bookedquantity) FROM StoreSubCards WHERE Store_ID=''%s'' and StoreCard_ID=''%s'' ';
var
  mList : TStringList;
begin
  mList := TStringList.Create;
  try
    AOS.SQLSelect(Format(cSQL, [aStore_ID, aStoreCard_ID]), mList);
    if mList.Count > 0 then
      Result := NxIBStrToFloat(mList.Strings[0])
      else Result:=0;
  finally
    mList.Free;
  end;
end;

function GetStorePrice(AOS : TNxCustomObjectSpace; aStore_ID, aStoreCard_ID : string) : Extended;
const
  cSQL = 'SELECT AverageStorePrice FROM StoreSubCards WHERE Store_ID=''%s'' and StoreCard_ID=''%s'' ';
var
  mList : TStringList;
begin
  mList := TStringList.Create;
  try
    AOS.SQLSelect(Format(cSQL, [aStore_ID, aStoreCard_ID]), mList);
    if mList.Count > 0 then
      Result := NxIBStrToFloat(mList.Strings[0])
      else Result:=0;
  finally
    mList.Free;
  end;
end;

function GetValidCZPhoneNumber(var aPhoneNumber:string):Boolean;
var
 mString:String;
begin
  Result:=False;
  mString:=APhoneNumber;
  mString:=NxSearchReplace(mString,' ','',[srAll]);
  mString:=AnsiLeftStr(AnsiRightStr(mString,9),1);
  if mString in ['6','7'] then Result:=True;
end;

function GetValidSKPostCode(var aPhoneNumber:string):Boolean;
var
 mString:String;
begin
  Result:=False;
  mString:=APhoneNumber;
  mString:=NxSearchReplace(mString,' ','',[srAll]);
  mString:=AnsiLeftStr(AnsiRightStr(mString,5),1);
  if mString in ['8','9','0'] then Result:=True;
end;

procedure SendInternalMail(AOS:TNxCustomObjectSpace; ATo:String; ACC:String; ABCC:String;
                           ASubject:String; ABody:String; AAtachement,AAtachement2:String; AFirm_ID:String; ADivision_ID:String; ABusTransaction_ID:String; aAccount_ID, aOrder_ID, aOrderState_ID:string);
Var
  mMailBO,mUserXLink:TNxCustomBusinessObject;
  mMRecipients:TNxCustomBusinessMonikerCollection;
  mMailRecipient:TNxCustomBusinessObject;
begin
  if not(ato='') then begin
     mMailBO:=AOS.CreateObject('5C1HWDQDR3J4NAAYZRO5PWHLWK');
     mMailBO.New;
     mMailBO.Prefill;
     mMailBO.SetFieldValueAsString('EmailAccount_ID',aAccount_ID);
     mMailBO.SetFieldValueAsString('Subject',ASubject);
     mMailBO.SetFieldValueAsInteger('BodySavedAs',1);
     mMailbo.SetFieldValueAsInteger('SentState',1);
     mMailBO.SetFieldValueAsString('Body',ABody);
     mMailBO.SetFieldValueAsString('Firm_ID',AFirm_ID);
     mMailBO.SetFieldValueAsString('Division_ID',ADivision_ID);
     mMailBO.SetFieldValueAsString('BusTransaction_ID',ABusTransaction_ID);
     mMailBO.SetFieldValueAsString('X_ReceivedOrderID',aOrder_ID);
     mMailBO.SetFieldValueAsString('X_OrderState_ID',aOrderState_ID);
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
     mMailBO.Save;
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
     mMailBO.free;

  end;
end;

begin
end.