uses
  '_Knihovny_ALL.SQL';


// zjištění počtu kusů dané skladové karty na daném skladě
// nebere v úvahu rezervace
// počet vrací v hlavní jednotce se vztahem 1

function GetAvailableSCQuantity(AOS: TNxCustomObjectSpace; AStoreCardID, AStoreID: string): double;
var
  mQuery: string;
begin
  mQuery := 'SELECT Quantity FROM StoreSubCards WHERE Store_ID = '+QuotedStr(AStoreID)+' AND StoreCard_ID = '+QuotedStr(AStoreCardID);
  Result := NxIBStrToFloat(SQLSelectValue(AOS, mQuery));
end;

begin
end.