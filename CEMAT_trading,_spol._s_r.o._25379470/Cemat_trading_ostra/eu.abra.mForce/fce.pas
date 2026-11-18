function scrGetLisar_ID(AOS : TNxCustomObjectSpace; AFieldname : string) : string;
const
  cSQL = 'SELECT max(X_lisar1) FROM ReceivedOrders2 WHERE Parent_ID=''%s'' ';
var
  mList : TStringList;
begin
  mList := TStringList.create;
  try
    AOS.SQLSelect(Format(cSQL, [AFieldName]), mList);
    if mList.Count > 0 then
      Result := mList.Strings[0]
      else Result:=''
  finally
    mList.Free;
  end;
end;

function scrGetBusProject_ID(AOS : TNxCustomObjectSpace; AFieldname : string) : string;
const
  cSQL = 'SELECT max(BusProject_ID) FROM ReceivedOrders2 WHERE Parent_ID=''%s'' ';
var
  mList : TStringList;
begin
  mList := TStringList.create;
  try
    AOS.SQLSelect(Format(cSQL, [AFieldName]), mList);
    if mList.Count > 0 then
      Result := mList.Strings[0]
      else Result:=''
  finally
    mList.Free;
  end;
end;

function scrGetStore_ID(AOS : TNxCustomObjectSpace; AFieldname : string) : string;
const
  cSQL = 'SELECT X_Store_ID FROM DefrollData WHERE ID=''%s'' ';
var
  mList : TStringList;
begin
  mList := TStringList.create;
  try
    AOS.SQLSelect(Format(cSQL, [AFieldName]), mList);
    if mList.Count > 0 then
      Result := mList.Strings[0]
      else Result:=''
  finally
    mList.Free;
  end;
end;

function scrGetStore_ID2(AOS : TNxCustomObjectSpace; AFieldname : string) : string;
const
  cSQL = 'SELECT X_SourceStore_ID FROM DefrollData WHERE ID=''%s'' ';
var
  mList : TStringList;
begin
  mList := TStringList.create;
  try
    AOS.SQLSelect(Format(cSQL, [AFieldName]), mList);
    if mList.Count > 0 then
      Result := mList.Strings[0]
      else Result:=''
  finally
    mList.Free;
  end;
end;

function scrGetSourceStore_ID(AOS : TNxCustomObjectSpace; AFieldname : string) : string;
const
  cSQL = 'SELECT X_SourceStore_ID FROM DefrollData WHERE ID=''%s'' ';
var
  mList : TStringList;
begin
  mList := TStringList.create;
  try
    AOS.SQLSelect(Format(cSQL, [AFieldName]), mList);
    if mList.Count > 0 then
      Result := mList.Strings[0]
      else Result:=''
  finally
    mList.Free;
  end;
end;

begin
end.