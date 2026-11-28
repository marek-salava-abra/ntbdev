function GetStoreCard_ID(AOS : TNxCustomObjectSpace; aEAN : string) : string;
const
  cSQL = 'SELECT su.Parent_ID FROM StoreUnits su left join storeeans se on se.parent_id=su.id where se.ean=''%s'' ';
var
  mList : TStringList;
begin
  mList := TStringList.Create;
  try
    Result:='';
    AOS.SQLSelect(Format(cSQL, [aEAN]), mList);
    if mList.Count > 0 then
      Result := mList.Strings[0]
  finally
    mList.Free;
  end;
end;

function GetStoreUnitRate(AOS : TNxCustomObjectSpace; aStoreCard_ID : string) : Extended;
const
  cSQL = 'SELECT su.Unitrate FROM StoreUnits su where su.parent_ID=''%s'' and su.X_EDI=''A'' ';
var
  mList : TStringList;
begin
  mList := TStringList.Create;
  try
    Result:=1;
    AOS.SQLSelect(Format(cSQL, [aStoreCard_ID]), mList);
    if mList.Count > 0 then
      Result := StrToFloat(mList.Strings[0])
  finally
    mList.Free;
  end;
end;

begin
end.