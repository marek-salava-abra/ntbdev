function GetQuantity(AOS : TNxCustomObjectSpace; AStore_ID : string; AStoreCard_ID: string) : Extended;
const
  cSQL = 'SELECT Quantity FROM Storesubcards where Store_ID=''%s'' and StoreCard_ID=''%s''';
var
  mList : TStringList;
begin
  mList := TStringList.create;
  try
    Result:=0;
    AOS.SQLSelect(Format(cSQL, [AStore_ID,AStoreCard_ID]), mList);
    if mList.Count > 0 then
      Result := StrToFloat(mList.Strings[0]);
  finally
    mList.Free;
  end;
end;

procedure RefreshDataset(AGrid : TDBGrid);
begin
NxRefreshDataSetWithoutValidate(TNxDataDataSet(AGrid.DataSource.DataSet), true);
end;



begin
end.