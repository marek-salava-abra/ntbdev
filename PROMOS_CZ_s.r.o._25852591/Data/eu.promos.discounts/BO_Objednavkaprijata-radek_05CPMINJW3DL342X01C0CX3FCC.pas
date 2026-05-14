{
Vyvolává se po změně každé položky. A to pouze, pokud k této změně nedochází díky načítání objektu z databáze nebo díky vytváření kopie.
}
{
procedure AfterSetFieldValue_Hook(Self: TNxCustomBusinessObject; AFieldCode: Integer; AValue: TNxParameter; AOriginalValue: TNxParameter);
var
 mDiscount, mPrice, mFirmPrice:Extended;
 mList:tstringList;

begin
  if (AFieldCode=self.GetFieldCode('StoreCard_ID')) and not(AValue.AsString=AOriginalValue.AsString) then begin
   mFirmPrice:=GetFirmPrice(Self.ObjectSpace,self.GetFieldValueAsString('Parent_ID.Firm_ID.PriceList_ID'),self.GetFieldValueAsString('StoreCard_ID'),self.GetFieldValueAsString('Qunit'));
   mPrice:=GetPrice(Self.ObjectSpace,self.GetFieldValueAsString('StoreCard_ID'),self.GetFieldValueAsString('Qunit'));
   if (mFirmPrice=0) and (mPrice>0) then begin
    self.SetFieldValueAsFloat('UnitPrice',mPrice/self.GetFieldValueAsFloat('Parent_ID.CurrRate'));
   self.SetFieldValueAsFloat('RowDiscount',GetDiscount(self.ObjectSpace,self.GetFieldValueAsString('StoreCard_ID.StoreAssortmentGroup_ID'),self.GetFieldValueAsString('Parent_ID.Firm_ID')));
   end;
  end;
end;  }


function GetDiscount(AOS : TNxCustomObjectSpace; aGroup,aFirm : string) : Extended;
const
  cSQL = 'SELECT Discount FROM FirmassortmentDiscounts WHERE Parent_ID=''%s'' and StoreAssortmentGroup_ID=''%s''  ';
var
  mList : TStringList;
begin
  mList := TStringList.Create;
  try
    AOS.SQLSelect(Format(cSQL, [afirm, aGroup]), mList);
    if mList.Count > 0 then
      Result := StrToFloat(mList.Strings[0])
      else Result:=0;
  finally
    mList.Free;
  end;
end;

function GetPrice(AOS : TNxCustomObjectSpace; aStoreCard_ID, aQunit : string) : Extended;
const
  cSQL = 'SELECT sp2.Amount FROM StorePrices SP LEFT JOIN StorePrices2 SP2 ON SP.ID = SP2.Parent_ID WHERE SP2.Price_ID=''1000000101'' AND SP.PriceList_ID=''1000000101'' AND SP.StoreCard_ID=''%s'' and sp2.qunit=''%s'' ';
var
  mList : TStringList;
begin
  mList := TStringList.Create;
  try
    AOS.SQLSelect(Format(cSQL, [aStoreCard_ID, aQunit]), mList);
    if mList.Count > 0 then
      Result := StrToFloat(mList.Strings[0])
      else Result:=0;
  finally
    mList.Free;
  end;
end;

function GetFirmPrice(AOS : TNxCustomObjectSpace; APriceList_ID, aStoreCard_ID, aQunit : string) : Extended;
const
  cSQL = 'SELECT sp2.Amount FROM StorePrices SP LEFT JOIN StorePrices2 SP2 ON SP.ID = SP2.Parent_ID WHERE SP2.Price_ID=''1000000101'' AND SP.PriceList_ID=''%s'' AND SP.StoreCard_ID=''%s'' and sp2.qunit=''%s'' ';
var
  mList : TStringList;
begin
  mList := TStringList.Create;
  try
    AOS.SQLSelect(Format(cSQL, [APriceList_ID, aStoreCard_ID, aQunit]), mList);
    if mList.Count > 0 then
      Result := StrToFloat(mList.Strings[0])
      else Result:=0;
  finally
    mList.Free;
  end;
end;


begin
end.