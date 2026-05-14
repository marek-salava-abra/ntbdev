

function GetOrder_ID(AOS : TNxCustomObjectSpace; AFieldName : string; AValue : string) : string;
const
  cSQL = 'SELECT ID FROM ReceivedOrders WHERE %s like ''%s'' and DocQueue_ID=''D100000101''';
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

function GetStoreCard_ID(AOS : TNxCustomObjectSpace; AEAN : string) : string;
const
  cSQL = 'SELECT SC.id FROM StoreCards sc left join StoreUnits SU on su.parent_id=sc.id left join storeeans se on se.parent_id=su.id WHERE se.ean=''%s'' and sc.hidden=''N'' ';
var
  mList : TStringList;
begin
  mList := TStringList.Create;
  try
    AOS.SQLSelect(Format(cSQL, [AEAN]), mList);
    Result:='';
    if mList.Count > 0 then
      Result := mList.Strings[0]
  finally
    mList.Free;
  end;
end;

function GetFirm_ID(AOS : TNxCustomObjectSpace; AValue : string) : string;
const
  cSQL = 'SELECT F.ID FROM Firms f left join addresses a on a.id=f.ElectronicAddress_ID WHERE a.email=''%s'' and f.hidden=''N'' and f.firm_id is null';
var
  mList : TStringList;
begin
  mList := TStringList.Create;
  try
    AOS.SQLSelect(Format(cSQL, [AValue]), mList);
    Result:='';
    if mList.Count > 0 then
      Result := mList.Strings[0]
  finally
    mList.Free;
  end;
end;

begin
end.