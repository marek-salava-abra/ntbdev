
{Rozdíl oproti yákladu, že sčítá 2 sklady T1B1}

{Forecast}
function IntForecastSunnex(mOS:TNxCustomObjectSpace;const mSubCard_ID:String):Extended;
Var
  Str : TStringList;
  mSql : string;
begin
  Result := -100000000; // když neproběhne tak bude vracethodně malý plán
  Str := TStringList.Create;
  mSql := 'select sum(f.quantity) from FORECAST_INV F where F.Promo = 0 and F.Parent_Id= '''+mSubCard_ID+''' and F.forecastdate>='+FloatToStr(Date)+' and f.forecastdate< (select Max(FORECASTDATE) from PARAM_INV where User_id = '''+ NxGetActualUserID(mOS)+''')';
  try
   mOS.SQLSelect(mSQL,Str);
   Result := StrToFloat(Str.Strings(0));
  finally
    Str.Free;
  end;
end;

{OrdersSubCard}

function IntOrdersSubCardSunnex(mOS:TNxCustomObjectSpace;const mSubCard_ID:String):Extended;
Var
  Str : TStringList;
  mSql : string;
begin
  Result := -100000000; // když neproběhne tak bude vracethodně malý plán
  Str := TStringList.Create;
  mSql := 'SELECT sum(io2.Quantity - Io2.DeliveredQuantity) FROM IssuedOrders IO inner join IssuedOrders2 IO2 on IO2.Parent_Id = IO.ID and io2.Quantity >= Io2.DeliveredQuantity inner join storesubcards SSB on ((IO2.store_id = ''1000000101'') or (IO2.store_id = ''1700000101'')) and SSB.storecard_id = IO2.storecard_id where IO.closed <> ''A''  and SSB.ID = '''+mSubCard_ID+'''';
  try
   mOS.SQLSelect(mSQL,Str);
   Result := StrToFloat(Str.Strings(0));
   //Ještě přidáme požadavky na obj. vydané
   Str.Clear;
   mSql := 'SELECT sum(io.Quantity) FROM OrdersRequests IO  inner join storesubcards SSB on ((IO.store_id = ''1000000101'') or (IO.store_id = ''1700000101'')) and SSB.storecard_id = IO.storecard_id where SSB.ID = '''+mSubCard_ID+'''';
   mOS.SQLSelect(mSQL,Str);
   Result := Result  + StrToFloat(Str.Strings(0));
  finally
    Str.Free;
  end;
end;

function OrdersSubCardSunnex(AReportHelper:TNxQRScriptHelper;const mSubCard_ID:String):Extended;
begin
  Result := IntOrdersSubCardSunnex(AReportHelper.ObjectSpace,mSubCard_ID);
end;

{ReceivedOrdersSubCard}
function IntReceivedOrdersSubCardSunnex(mOS:TNxCustomObjectSpace;mStoreCard_ID:String):Extended;
Var
  Str : TStringList;
  mSql : string;
begin
  Result := 0; // když neproběhne tak bude vracethodně malý plán
  mSql := 'Select Sum((RO2.Quantity - RO2.DeliveredQuantity)) From ReceivedOrders2 RO2 inner Join ReceivedOrders RO On RO.ID = RO2.Parent_ID And RO.Closed = ''N'' and RO.Confirmed = ''A'' ' +
        ' Where ((RO2.store_id = ''1000000101'') or (RO2.store_id = ''1700000101'')) AND RO2.StoreCard_ID = ''' + mStoreCard_ID+''' And RO2.RowType = 3 And RO2.Quantity > RO2.DeliveredQuantity ';
  Str := TStringList.Create;
  try
    mOS.SQLSelect(mSQL,Str);
   if not TryStrToFloat(Str.Strings(0),Result) then Result := 0;
  finally
    Str.Free;
  end;
end;

function ReceivedOrdersSubCardSunnex(AReportHelper:TNxQRScriptHelper;const mStoreCard_ID: string):Extended;
begin
  Result := IntReceivedOrdersSubCardSunnex(AReportHelper.ObjectSpace,mStoreCard_ID);
end;

{Vyhodnotí zda má být objednáváno}
function IntCleanOrderLogicSunnex(mOS:TNxCustomObjectSpace;const mSubCard_ID:String):Boolean;
var
  Str : TStringList;
  mSql : string;
  mCis: Extended;
begin
  mCis := 0;
  Result := true;
  mSQL := 'select sum(A.Quantity-(A.X_Min + A.X_KorekceMin)) from StoreSubCards A where A.id = '''+mSubCard_ID+''' and ((A.store_id = ''1000000101'') or (A.store_id = ''1700000101''))';
  Str := TStringList.Create;
  try
    mOS.SQLSelect(mSQL,Str);
    if not TryStrToFloat(Str.Strings(0),mCis) then mCis := 0;
    Result := (mCis+ IntReceivedOrdersSubCardSunnex(mOS,mSubCard_ID)-IntOrdersSubCardSunnex(mOS, mSubCard_ID)-  IntForecastSunnex(mOS, mSubCard_ID))<0;
  finally
    Str.Free;
  end;
end;


function CleanOrderLogicSannex(AReportHelper:TNxQRScriptHelper;const mSubCard_ID:String):Boolean;
begin
   Result := IntCleanOrderLogicSunnex(AReportHelper.ObjectSpace,mSubCard_ID);
end;

{Celková objednávka (bezzohlednění balení)}
function IntClenOrderSunnex(mOS:TNxCustomObjectSpace;const mSubCard_ID:String):Extended;
var
 mBO : TNxCustomBusinessObject;
begin
  mBO := mOS.CreateObject(Class_StoreSubCard);
  try
  mBo.Load(mSubCard_ID,nil);
    Result := mBo.GetFieldValueAsFloat('X_Max')+mBo.GetFieldValueAsFloat('X_KorekceMax') +  IntReceivedOrdersSubCardSunnex(mOS,mBo.GetFieldValueAsString('StoreCard_ID'));
  finally
    mBO.Free;
  end;
end;

function ClenOrderSannex(AReportHelper:TNxQRScriptHelper;const mSubCard_ID:String):Extended;
begin
   Result := IntClenOrderSunnex(AReportHelper.ObjectSpace,mSubCard_ID);
end;

begin
end.