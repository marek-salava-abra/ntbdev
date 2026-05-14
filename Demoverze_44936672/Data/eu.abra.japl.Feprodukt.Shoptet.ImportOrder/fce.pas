function scrGetCountry_ID(AOS : TNxCustomObjectSpace; AFieldName : string; AValue : string) : string;
const
  cSQL = 'SELECT ID FROM Countries WHERE %s like ''%s'' and Hidden=''N'' ';
var
  mList : TStringList;
begin
  mList := TStringList.Create;
  try
    Result:='';
    AOS.SQLSelect(Format(cSQL, [AFieldName, AValue]), mList);
    if mList.Count > 0 then
      Result := mList.Strings[0]
  finally
    mList.Free;
  end;
end;

function ElementExists(mXMLHead : TNxScriptingXMLWrapper; AName: string): Boolean;

begin
  try
    if mXMLHead.getElementAsString(AName)<>'' then Result:= True;
  except
    //ShowMessage('Neexistuje element '+ AName);
    //ShowMessage(ExceptionMessage);
    Result:= False;
  end;
end;

function scrTransportationType_ID(AOS : TNxCustomObjectSpace; AFieldName : string; AValue : string) : string;
const
  cSQL = 'SELECT ID FROM TransportationTypes WHERE %s = ''%s'' ';
var
  mList : TStringList;
begin
  mList := TStringList.Create;
  try
    AOS.SQLSelect(Format(cSQL, [AFieldName, AValue]), mList);
    Result:='';
    if mList.Count > 0 then
      Result := mList.Strings[0]
  finally
    mList.Free;
  end;
end;

function scrPaymentType_ID(AOS : TNxCustomObjectSpace; AFieldName : string; AValue : string) : string;
const
  cSQL = 'SELECT ID FROM PaymentTypes WHERE %s = ''%s'' ';
var
  mList : TStringList;
begin
  mList := TStringList.Create;
  try
    AOS.SQLSelect(Format(cSQL, [AFieldName, AValue]), mList);
    Result:='';
    if mList.Count > 0 then
      Result := mList.Strings[0]
  finally
    mList.Free;
  end;
end;


function scrGetPeriod_ID(AOS : TNxCustomObjectSpace;  AValue : Extended) : string;
const
  cSQL = 'SELECT ID FROM Periods WHERE (datefrom$date<= %d) and (dateto$date> %d) ';
var
  mList : TStringList;
begin
  mList := TStringList.Create;
  try
    Result:='';
    //Showmessage(Format(cSQL, [AValue,AValue]));
    AOS.SQLSelect(Format(cSQL, [AValue,AValue]), mList);
    //AOS.SQLSelect('SELECT ID FROM PERIODS WHERE datefrom$date<='+strtodate(AVALUE)+' and dateto$date>='+floattostr(strtodate(AVALUE)), mList);

    if mList.Count > 0 then
      Result := mList.Strings[0]
  finally
    mList.Free;
  end;
end;

function scrCurrency_ID(AOS : TNxCustomObjectSpace; AFieldName : string; AValue : string) : string;
const
  cSQL = 'SELECT ID FROM Currencies WHERE %s like ''%s'' and Hidden=''N''';
var
  mList : TStringList;
begin
  mList := TStringList.Create;
  try
    AOS.SQLSelect(Format(cSQL, [AFieldName, AValue]), mList);
    Result:='';
    if mList.Count > 0 then
      Result := mList.Strings[0]
  finally
    mList.Free;
  end;
end;


function scrStoreCard_ID(AOS : TNxCustomObjectSpace; AFieldName : string; AValue : string) : string;
const
  cSQL = 'SELECT ID FROM StoreCards WHERE %s = ''%s'' and Hidden=''N'' ';
var
  mList : TStringList;
begin
  mList := TStringList.Create;
  try
    AOS.SQLSelect(Format(cSQL, [AFieldName, AValue]), mList);
    Result:='';
    if mList.Count > 0 then
      Result := mList.Strings[0]
  finally
    mList.Free;
  end;
end;

function scrFirm_ID(AOS : TNxCustomObjectSpace; AFieldName : string; AValue : string) : string;
const
  cSQL = 'SELECT ID FROM Firms WHERE %s like ''%s'' and Hidden=''N'' and Firm_ID is null';
var
  mList : TStringList;
begin
  mList := TStringList.Create;
  try
    AOS.SQLSelect(Format(cSQL, [AFieldName, AValue]), mList);
    Result:='';
    if mList.Count > 0 then
      Result := mList.Strings[0]
  finally
    mList.Free;
  end;
end;

function scrDocQueue_ID(AOS : TNxCustomObjectSpace; AFieldName : string; AValue : string) : string;
const
  cSQL = 'SELECT ID FROM DocQueues WHERE %s like ''%s'' and Hidden=''N''';
var
  mList : TStringList;
begin
  mList := TStringList.Create;
  try
    AOS.SQLSelect(Format(cSQL, [AFieldName, AValue]), mList);
    Result:='';
    if mList.Count > 0 then
      Result := mList.Strings[0]
  finally
    mList.Free;
  end;
end;

function scrOrder_ID(AOS : TNxCustomObjectSpace; AFieldName : string; AValue : string; AValue2: string) : string;
const
  cSQL = 'SELECT ID FROM ReceivedOrders WHERE %s like ''%s'' and DocQueue_ID=''%s'' ';
var
  mList : TStringList;
begin
  mList := TStringList.Create;
  try
    AOS.SQLSelect(Format(cSQL, [AFieldName, AValue,AValue2]), mList);
    Result:='0000000000';
    if mList.Count > 0 then
      Result := mList.Strings[0]
  finally
    mList.Free;
  end;
end;

function VatRate_ID(AOS : TNxCustomObjectSpace; AValue,AValue2 : string) : string;
const
  cSQL = 'SELECT ID FROM VatRates WHERE Country_ID = ''%s'' and tariff=''%s'' and Hidden = ''N'' ';
var
  mList : TStringList;
begin
  mList := TStringList.Create;
  try
    AOS.SQLSelect(Format(cSQL, [AValue,AValue2]), mList);
    Result:='';
    if mList.Count > 0 then
      Result := mList.Strings[0]
  finally
    mList.Free;
  end;
end;

function GetDeposit_inv(AOS : TNxCustomObjectSpace; aCode : string) : string;
const
  cSQL = 'SELECT ID FROM IssuedDInvoices WHERE Amount > UsedAmount and ReceivedOrder_ID=''%s'' ';
var
  mList : TStringList;
begin
  mList := TStringList.Create;
  try
    AOS.SQLSelect(Format(cSQL, [aCode]), mList);
    if mList.Count > 0 then
      Result := mList.Strings[0]
      else Result:='0000000000'
  finally
    mList.Free;
  end;
end;

begin
end.