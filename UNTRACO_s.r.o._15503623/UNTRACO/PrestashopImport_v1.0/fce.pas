{
  Funkce pro dohledání skladové karty
}
function scrGetParam(AOS : TNxCustomObjectSpace; AFieldName : string) : string;
const
  cSQL = 'SELECT %s FROM DefRollData WHERE Code=1 ';
var
  mList : TStringList;
begin
  mList := TStringList.create;
  try
    Result:='';
    AOS.SQLSelect(Format(cSQL, [AFieldName]), mList);
    if mList.Count > 0 then
      Result := mList.Strings[0]
  finally
    mList.Free;
  end;
end;

function scrOrder_ID(AOS : TNxCustomObjectSpace; AFieldName : string; AValue : string; ADocQueue : string) : string;
const
  cSQL = 'SELECT ID FROM ReceivedOrders WHERE %s like ''%s'' and DocQueue_ID=''%s''';
var
  mList : TStringList;
begin
  mList := TStringList.create;
  try
    AOS.SQLSelect(Format(cSQL, [AFieldName, AValue, ADocQueue]), mList);
    Result:='';
    if mList.Count > 0 then
      Result := mList.Strings[0]
  finally
    mList.Free;
  end;
end;

function scrStoreCard_ID(AOS : TNxCustomObjectSpace; AFieldName : string; AValue : string) : string;
const
  cSQL = 'SELECT ID FROM StoreCards WHERE %s=''%s'' and Hidden=''N''';
var
  mList : TStringList;
begin
  mList := TStringList.create;
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
  cSQL = 'SELECT ID FROM Firms WHERE %s like ''%s'' and Hidden=''N''';
var
  mList : TStringList;
begin
  mList := TStringList.create;
  try
    AOS.SQLSelect(Format(cSQL, [AFieldName, AValue]), mList);
    Result:='';
    if mList.Count > 0 then
      Result := mList.Strings[0]
  finally
    mList.Free;
  end;
end;

function scrTransportationType_ID(AOS : TNxCustomObjectSpace; AFieldName : string; AValue : string) : string;
const
  cSQL = 'SELECT ID FROM TransportationTypes WHERE %s like ''%s'' ';
var
  mList : TStringList;
begin
  mList := TStringList.create;
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
  cSQL = 'SELECT ID FROM PaymentTypes WHERE %s like ''%s'' ';
var
  mList : TStringList;
begin
  mList := TStringList.create;
  try
    AOS.SQLSelect(Format(cSQL, [AFieldName, AValue]), mList);
    Result:='';
    if mList.Count > 0 then
      Result := mList.Strings[0]
  finally
    mList.Free;
  end;
end;
begin
end.