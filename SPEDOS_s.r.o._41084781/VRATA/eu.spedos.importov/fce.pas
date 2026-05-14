function GetFirm_ID(var AOS : TNxCustomObjectSpace; var AValue : string) : string;
const
  cSQL = 'SELECT ID FROM Firms WHERE OrgIdentNumber=''%s'' and Hidden=''N'' and firm_id is null';
var
  mList : TStringList;
begin
  mList := TStringList.create;
  try
    AOS.SQLSelect(Format(cSQL, [AValue]), mList);
    Result:='';
    if mList.Count > 0 then
      Result := mList.Strings[0]
  finally
    mList.Free;
  end;
end;

function GetBusOrder_ID(var AOS : TNxCustomObjectSpace; var AValue : string) : string;
const
  cSQL = 'SELECT ID FROM BusOrders WHERE Code=''%s'' and Hidden=''N''';
var
  mList : TStringList;
begin
  mList := TStringList.create;
  try
    AOS.SQLSelect(Format(cSQL, [AValue]), mList);
    Result:='';
    if mList.Count > 0 then
      Result := mList.Strings[0]
  finally
    mList.Free;
  end;
end;

function GetStoreCardCategory_ID(var AOS : TNxCustomObjectSpace; var AValue : string) : string;
const
  cSQL = 'SELECT ID FROM StoreCardCategories WHERE Code=''%s'' and Hidden=''N''';
var
  mList : TStringList;
begin
  mList := TStringList.create;
  try
    AOS.SQLSelect(Format(cSQL, [AValue]), mList);
    Result:='';
    if mList.Count > 0 then
      Result := mList.Strings[0]
  finally
    mList.Free;
  end;
end;

function GetStoreCard_ID(var AOS : TNxCustomObjectSpace; var AValue : string) : string;
const
  cSQL = 'SELECT ID FROM StoreCards WHERE X_RailCode=''%s'' and Hidden=''N''';
var
  mList : TStringList;
begin
  mList := TStringList.create;
  try
    AOS.SQLSelect(Format(cSQL, [AValue]), mList);
    Result:='';
    if mList.Count > 0 then
      Result := mList.Strings[0]
  finally
    mList.Free;
  end;
end;

function GetStoreCard2_ID(var AOS : TNxCustomObjectSpace; var AValue, aFirm_ID : string) : string;
const
  cSQL = 'SELECT sc.id from storecards sc left join SubScribers s on sc.id=s.storecard_id WHERE s.ExternalNumber=''%s'' and s.Firm_ID=''%s'' and sc.hidden=''N'' ';
var
  mList : TStringList;
begin
  mList := TStringList.create;
  try
    AOS.SQLSelect(Format(cSQL, [AValue, aFirm_ID]), mList);
    Result:='';
    if mList.Count > 0 then
      Result := mList.Strings[0]
  finally
    mList.Free;
  end;
end;




begin
end.