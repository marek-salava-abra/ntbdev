uses 'eu.abra.roeh.Logio.constVar',
     'eu.abra.roeh.Logio.func';



{Forecast}

function IntForecastAllStore(mOS:TNxCustomObjectSpace;const mSubCard_ID:String):Extended;
Var
  Str : TStringList;
  mSql : string;
begin
  Result := -100000000; // když neproběhne tak bude vracethodně malý plán
  mSql := 'select sum(f.quantity) from FORECAST_INV F where F.Promo = 0 and exists (SELECT 1 from  StoreSubCards spc '+
     ' inner join  StoreCards sx on spc.storecard_id = sx.id inner join StoreSubCards spx on spx.storecard_id = sx.id ' +
     ' where spx.id = '''+mSubCard_ID+''' and F.Parent_Id = spc.id) and F.datefrom>='+FloatToStr(Date)+' and f.forecastdate< (select Max(FORECASTDATE) from PARAM_INV where User_id = '''+ NxGetActualUserID(mOS)+''')';
  Str := TStringList.Create;
  try
   mOS.SQLSelect(mSQL,Str);
   Result := StrToFloat(Str.Strings(0));
  finally
    Str.Free;
  end;
end;


function ForecastAllStore(AReportHelper:TNxQRScriptHelper;const mSubCard_ID:String):Extended;
begin
  Result := IntForecastAllStore(AReportHelper.ObjectSpace,mSubCard_ID);
end;


function IntForecast(mOS:TNxCustomObjectSpace;const mSubCard_ID:String):Extended;
Var
  Str : TStringList;
  mSql : string;
begin
  Result := -100000000; // když neproběhne tak bude vracethodně malý plán
  Str := TStringList.Create;
  mSql := 'select sum(f.quantity) from FORECAST_INV F where F.Promo = 0 and F.Parent_Id= '''+mSubCard_ID+''' and F.datefrom>='+FloatToStr(Date)+' and f.forecastdate< (select Max(FORECASTDATE) from PARAM_INV where User_id = '''+ NxGetActualUserID(mOS)+''')';
  try
   mOS.SQLSelect(mSQL,Str);
   Result := StrToFloat(Str.Strings(0));
  finally
    Str.Free;
  end;
end;

function Forecast(AReportHelper:TNxQRScriptHelper;const mSubCard_ID:String):Extended;
begin
  Result := IntForecast(AReportHelper.ObjectSpace,mSubCard_ID);
end;

function IntForecastSCM(mOS:TNxCustomObjectSpace;const mStore_Id,mStoreCard_ID:String; const fromDate, ToDate: TDateTime):Extended;
Var
  Str : TStringList;
  mSql : string;
begin
  Result := -100000000; // když neproběhne tak bude vracethodně malý plán
  Str := TStringList.Create;
  mSql := 'select sum(f.quantity) from FORECAST_INV F inner join StoreSubCards s on s.id = F.Parent_Id '+
      ' where F.Promo = 0 ';
  if (Trim(mStore_Id) <> '') and (mStore_Id<>'0000000000') then mSql := mSql  + ' and  S.Store_Id= '''+mStore_ID+'''' ;
  mSql := mSql  + ' and S.StoreCard_Id= '''+mStoreCard_ID+''' and F.datefrom>='+FloatToStr(Round(FromDate))+' and f.forecastdate< ' + FloatToStr(Round(ToDate));
  try
   mOS.SQLSelect(mSQL,Str);
   Result := StrToFloat(Str.Strings(0));
  finally
    Str.Free;
  end;
end;

function ForecastSCM(AReportHelper:TNxQRScriptHelper;const mStore_Id,mStoreCard_ID:String; const fromDate, ToDate: TDateTime):Extended;
begin
  Result := IntForecastSCM(AReportHelper.ObjectSpace,mStore_Id,mStoreCard_ID,fromDate, ToDate);
end;

function IntNextOrderdate(mOS:TNxCustomObjectSpace; const mSubCard_ID:string):Integer;
var
  mRollShare : Boolean;
  mStr : TStringList;
  mSQL : String;
begin
  Result :=0;
  mRollShare := UpperCase(GetParamValue(mOS,'ROLLSHARE')) = 'ANO';
  mStr := TStringList.Create;
  try
    if mRollShare then begin
      mSQL := 'select s.X_max_lt_provider from StoreSubCards SB inner join Suppliers s on s.StoreCard_ID = SB.StoreCard_ID where s.DoDemand = ''A'' and SB.ID =''' + mSubCard_ID + '''';
    end else begin
      mSQL:= 'select s.X_max_lt_provider from StoreSubCards SB inner join StoreCards sc on sc.ID = SB.StoreCard_ID '+
        ' inner join Suppliers s on s.id = sc.MainSupplier_ID where SB.ID =''' + mSubCard_ID + '''';
    end;
      mOS.SQLSelect(mSql,mStr);
    if mStr.Count = 0 then Result := StrToInt(GetParamValue(mOS,'MAXPROVIDE'))
    else begin
      Result := StrToInt(mStr.Strings(0));
      if Result = 0 then Result := StrToInt(GetParamValue(mOS,'MAXPROVIDE'));
    end;
  finally
    mStr.Free;
  end;
end;

function IntForecastOrder(mOS:TNxCustomObjectSpace;const mSubCard_ID:String):Extended;
var
  mStr : TStringList;
  mSQL : string;
  mBO : TNxCustomBusinessObject;
begin
   Result := 0;
   mBo := mOS.CreateObject(Class_StoreSubCard);
   try
     mBo.Load(mSubCard_ID,nil);
    // X_MaterStore_ID vychytávka v IGM, kde některé položky centrálně objednávají z jiného skladu
     if (not mBo.GetFieldValueAsBoolean('X_DirectOrder')) or (mBo.HasField('StoreCard_ID.X_MaterStore_ID')) then
   // všechy napodřízené sklady
//      mSql := 'select sum(f.quantity) from FORECAST_INV F where F.Promo = 0 and F.Parent_Id in (SELECT spc.id from  StoreSubCards spc '+
//       ' inner join  StoreCards sx on spc.storecard_id = sx.id inner join StoreSubCards spx on spx.storecard_id = sx.id ' +
//       ' where spx.id = '''+mSubCard_ID+''') and F.datefrom>='+FloatToStr(Date)+' and f.forecastdate< ' + FloatToStr(Date+IntNextOrderdate(mOs,mSubCard_ID))
      mSql := 'select sum(f.quantity) from FORECAST_INV F where F.Promo = 0 and exists (SELECT 1 from  StoreSubCards spc '+
       ' inner join  StoreCards sx on spc.storecard_id = sx.id inner join StoreSubCards spx on spx.storecard_id = sx.id ' +
       ' where spx.id = '''+mSubCard_ID+''' and F.Parent_Id = spc.id) and F.datefrom>='+FloatToStr(Date)+' and f.forecastdate< ' + FloatToStr(Date+IntNextOrderdate(mOs,mSubCard_ID))

   else
     mSql := 'select sum(f.quantity) from FORECAST_INV F where F.Promo = 0 and F.Parent_Id= '''+mSubCard_ID+''' and F.datefrom>='+FloatToStr(Date)+' and f.forecastdate< ' + FloatToStr(Date+IntNextOrderdate(mOs,mSubCard_ID));
     mStr := TStringList.Create;
     try
       mOS.SQLSelect(mSql,mStr);
      if mStr.Count = 1 then Result := StrToFloat(mStr.Strings(0))
      else Result := 0;
     finally
       mStr.Free;
     end;
   finally
     mBo.Free;
   end;
end;

function ForecastOrder(AReportHelper:TNxQRScriptHelper;const mSubCard_ID:String):Extended;
begin
  Result := IntForecastOrder(AReportHelper.ObjectSpace,mSubCard_ID);
end;

{OrdersSubCard}

function IntOrdersSubCard(mOS:TNxCustomObjectSpace;const mSubCard_ID:String):Extended;
Var
  Str : TStringList;
  mSql : string;
  mAllStoreOrder:Boolean;
begin
  Result := -100000000; // když neproběhne tak bude vracethodně malý plán
  mAllStoreOrder := UpperCase(GetParamValue(mOS,'ORDERALLST'))= 'ANO';

  Str := TStringList.Create;
  // Bere opravdu všechny sklady na objednávky bez ohledu zda jsou nebo nejsou počítány
  if mAllStoreOrder then mSql := 'SELECT sum(io2.Quantity - Io2.DeliveredQuantity) FROM IssuedOrders IO inner join IssuedOrders2 IO2 on IO2.Parent_Id = IO.ID and io2.Quantity >= Io2.DeliveredQuantity inner join storesubcards SSB on SSB.storecard_id = IO2.storecard_id where IO.closed <> ''A'' and (nullif(IO.Revided_ID,''0000000000'') is null) and SSB.ID = '''+mSubCard_ID+'''/* and (IO2.store_id in (select sx.id from stores sx where sx.X_DirectStore = SSB.store_id and sx.X_NotCalculate=''N'' and sx.X_AnalyseStore=''N''))*/'
  else mSql := 'SELECT sum(io2.Quantity - Io2.DeliveredQuantity) FROM IssuedOrders IO inner join IssuedOrders2 IO2 on IO2.Parent_Id = IO.ID and io2.Quantity >= Io2.DeliveredQuantity inner join storesubcards SSB on SSB.storecard_id = IO2.storecard_id where IO.closed <> ''A'' and (nullif(IO.Revided_ID,''0000000000'') is null) and SSB.ID = '''+mSubCard_ID+''' and ((IO2.store_id =SSB.store_id) or (exists (select 1 from stores sx where IO2.store_id = sx.id and sx.X_DirectStore = SSB.store_id and sx.X_NotCalculate=''N'' and sx.X_AnalyseStore=''N'')))';
  try
   mOS.SQLSelect(mSQL,Str);
   Result := StrToFloat(Str.Strings(0));
   //Ještě přidáme požadavky na obj. vydané
   Str.Clear;
   if mAllStoreOrder then mSql := 'SELECT sum(io.Quantity) FROM OrdersRequests IO  inner join storesubcards SSB on SSB.storecard_id = IO.storecard_id where SSB.ID = '''+mSubCard_ID+''' and (exists (select 1 from stores sx where IO.store_id =sx.id/*where sx.X_DirectStore = SSB.store_id and sx.X_NotCalculate=''N'' and sx.X_AnalyseStore=''N''*/))'
   else mSql := 'SELECT sum(io.Quantity) FROM OrdersRequests IO  inner join storesubcards SSB on SSB.storecard_id = IO.storecard_id where SSB.ID = '''+mSubCard_ID+''' and ((IO.store_id =SSB.store_id) or (exists (select 1 from stores sx where IO.store_id = sx.id and sx.X_DirectStore = SSB.store_id and sx.X_NotCalculate=''N'' and sx.X_AnalyseStore=''N'')))';
   mOS.SQLSelect(mSQL,Str);
   Result := Result  + StrToFloat(Str.Strings(0));
  finally
    Str.Free;
  end;
end;

function IntOrdersSubCardOnlyRes(mOS:TNxCustomObjectSpace;const mSubCard_ID:String):Extended;
Var
  Str : TStringList;
  mSql : string;
  mAllStoreOrder:Boolean;
begin
  Result := -100000000; // když neproběhne tak bude vracethodně malý plán
  mAllStoreOrder := UpperCase(GetParamValue(mOS,'ORDERALLST'))= 'ANO';

  Str := TStringList.Create;
  // Bere opravdu všechny sklady na objednávky bez ohledu zda jsou nebo nejsou počítány
  // musím řešit i sklady, protože je potřeba vědět zda obj. vydané beru jen na svém skladu nebo na všech
  if mAllStoreOrder then mSql := 'SELECT  sum(RTI.Quantity) FROM IssuedOrders IO inner join IssuedOrders2 IO2 on IO2.Parent_Id = IO.ID and io2.Quantity >= Io2.DeliveredQuantity '
                             +' inner join storesubcards SSB on SSB.storecard_id = IO2.storecard_id inner join ReceivedOrdersToIssuedOrders RTI on RTI.Target_ID = IO2.ID '
                             +' inner join ReceivedOrders2 RO2 on RO2.ID =RTI.Source_ID and RO2.quantity > RO2.DeliveredQuantity inner join ReceivedOrders RO on RO.ID = RTI.SourceHeader_ID and RO.closed= ''N'''
                             +' where IO.closed = ''N'' and (nullif(IO.Revided_ID,''0000000000'') is null) and SSB.ID = '''+mSubCard_ID+''''
  else mSql := 'SELECT sum(RTI.Quantity) FROM IssuedOrders IO inner join IssuedOrders2 IO2 on IO2.Parent_Id = IO.ID and io2.Quantity >= Io2.DeliveredQuantity '
            +' inner join storesubcards SSB on SSB.storecard_id = IO2.storecard_id inner join ReceivedOrdersToIssuedOrders RTI on RTI.Target_ID = IO2.ID '
            +' inner join ReceivedOrders2 RO2 on RO2.ID =RTI.Source_ID and RO2.quantity > RO2.DeliveredQuantity inner join ReceivedOrders RO on RO.ID = RTI.SourceHeader_ID and RO.closed= ''N'''
            +' where IO.closed = ''N'' and (nullif(IO.Revided_ID,''0000000000'') is null) and SSB.ID = '''+mSubCard_ID+''' and ((IO2.store_id =SSB.store_id) or (exists (select 1 from stores sx where IO2.store_id = sx.id and sx.X_DirectStore = SSB.store_id and sx.X_NotCalculate=''N'' and sx.X_AnalyseStore=''N'')))';
  try
   mOS.SQLSelect(mSQL,Str);
   Result := StrToFloat(Str.Strings(0));
   //Ještě přidáme požadavky na obj. vydané
   Str.Clear;
   if mAllStoreOrder then mSql := 'SELECT sum(io.Quantity) FROM OrdersRequests IO  inner join storesubcards SSB on SSB.storecard_id = IO.storecard_id where SSB.ID = '''+mSubCard_ID+''' and ( exists (select 1 from stores sx where IO.store_id =sx.id/*where sx.X_DirectStore = SSB.store_id and sx.X_NotCalculate=''N'' and sx.X_AnalyseStore=''N''*/))'
   else mSql := 'SELECT sum(io.Quantity) FROM OrdersRequests IO  inner join storesubcards SSB on SSB.storecard_id = IO.storecard_id where SSB.ID = '''+mSubCard_ID+''' and ((IO.store_id =SSB.store_id) or (exists (select 1 from stores sx where IO.store_id = sx.id and sx.X_DirectStore = SSB.store_id and sx.X_NotCalculate=''N'' and sx.X_AnalyseStore=''N'')))';
   mOS.SQLSelect(mSQL,Str);
   Result := Result  + StrToFloat(Str.Strings(0));
  finally
    Str.Free;
  end;
end;

{ReceivedOrdersSubCard}
function IntReceivedOrdersSubCard(mOS:TNxCustomObjectSpace;const mStore_ID,mStoreCard_ID:String):Extended;
Var
  Str : TStringList;
  mSql : string;
  mAllStoreOrder:Boolean;
begin
  Result := 0; // když neproběhne tak bude vracethodně malý plán
  mAllStoreOrder := UpperCase(GetParamValue(mOS,'ORDERALLST'))= 'ANO';
  if mAllStoreOrder then mSql := 'Select Sum((RO2.Quantity - RO2.DeliveredQuantity)) From ReceivedOrders2 RO2 inner join ReceivedOrders RO On RO.ID = RO2.Parent_ID And RO.Closed = ''N'' and RO.Confirmed = ''A'' ' +
        ' Where (nullif(RO.Revided_ID,''0000000000'') is null)  AND RO2.StoreCard_ID = ''' + mStoreCard_ID+''' And RO2.RowType = 3 And RO2.Quantity > RO2.DeliveredQuantity '
  else mSql := 'Select Sum((RO2.Quantity - RO2.DeliveredQuantity)) From ReceivedOrders2 RO2 inner join ReceivedOrders RO On RO.ID = RO2.Parent_ID And RO.Closed = ''N'' and RO.Confirmed = ''A'' ' +
        ' Where (nullif(RO.Revided_ID,''0000000000'') is null) and ((RO2.store_id ='''+mStore_ID+''') or (exists (select 1 from stores sx where RO2.store_id = sx.id and sx.X_DirectStore = '''+mStore_ID+''' and sx.X_NotCalculate=''N'' and sx.X_AnalyseStore=''N''))) AND RO2.StoreCard_ID = ''' + mStoreCard_ID+''' And RO2.RowType = 3 And RO2.Quantity > RO2.DeliveredQuantity ';
  Str := TStringList.Create;
  try
    mOS.SQLSelect(mSQL,Str);
   if not TryStrToFloat(Str.Strings(0),Result) then Result := 0;
  finally
    Str.Free;
  end;
end;

function ReceivedOrdersSubCard(AReportHelper:TNxQRScriptHelper;const mStore_ID,mStoreCard_ID:String):Extended;
begin
  Result := IntReceivedOrdersSubCard(AReportHelper.ObjectSpace,mStore_ID,mStoreCard_ID);
end;

function OrdersSubCard(AReportHelper:TNxQRScriptHelper;const mSubCard_ID:String):Extended;
begin
  Result := IntOrdersSubCard(AReportHelper.ObjectSpace,mSubCard_ID);
end;

function OrdersSubCardOnlyRes(AReportHelper:TNxQRScriptHelper;const mSubCard_ID:String):Extended;
begin
  Result := IntOrdersSubCardOnlyRes(AReportHelper.ObjectSpace,mSubCard_ID);
end;

function IntOutgoingTransfer(mOS:TNxCustomObjectSpace;const mStore_Id,mStoreCard_ID:String):Extended;
Var
  Str : TStringList;
  mSql,mSql1 : string;
begin
  Result := -100000000; // když neproběhne tak bude vracethodně malý plán
  Str := TStringList.Create;
  if CFxNxRuntime.NxGetDatabaseCode = 'IB' then
     mSql1 := '(select FieldCode from GetUserFieldCode(''0P0I5SAOS3DL3ACU03KIU0CLP4'',''U_OutgoingStore_Id''))';
  if CFxNxRuntime.NxGetDatabaseCode = 'ORA' then
     mSql1 := 'GetUserFieldCode(''0P0I5SAOS3DL3ACU03KIU0CLP4'',''U_OutgoingStore_Id'')';
  if CFxNxRuntime.NxGetDatabaseCode = 'MSSQL' then
    mSql1:='dbo.GetUserFieldCode(''0P0I5SAOS3DL3ACU03KIU0CLP4'',''U_OutgoingStore_Id'')';

  mSql := 'select Sum(S2.Quantity) from storedocuments2 S2 inner join  storedocuments S on S2.parent_id = S.Id where (s.DocDate$Date > ('+FloatToStr(Date)+'-90)) and S.DocumentType = ''22''';
  mSql := mSql + ' and (not exists (Select 1 from  storedocuments Sx inner join storedocuments2 Sx2 on Sx2.Parent_Id = Sx.id where (sx.DocDate$Date > ('+FloatToStr(Date)+'-90)) and Sx.DocumentType = ''24'' and Sx.RDocument_Id =S.id)) ';
  mSql := mSql + ' and (''' + mStore_Id + ''' = (select distinct cast(u.stringfieldvalue as char(10)) from  UserData u ';
  mSql := mSql + ' where u.CLSID = ''0P0I5SAOS3DL3ACU03KIU0CLP4'' and u.id = s.id and u.FieldCode= '+mSql1+') ) and s2.StoreCard_id =''' + mStoreCard_ID + '''';

  try
   mOS.SQLSelect(mSQL,Str);
   Result := StrToFloat(Str.Strings(0));
  finally
    Str.Free;
  end;
end;

function OutgoingTransfer(AReportHelper:TNxQRScriptHelper;const mStore_Id, mSubCard_ID:String):Extended;
begin
  Result := IntOutgoingTransfer(AReportHelper.ObjectSpace,mStore_Id,mSubCard_ID);
end;

{Vyhodnotí zda má být objednáváno}
function IntClenOrderLogic(mOS:TNxCustomObjectSpace;const mSubCard_ID:String):Boolean;
var
 mBO : TNxCustomBusinessObject;
 mS : String;
 mR,mF : Extended;
begin
  Result := false;
  mBO := mOS.CreateObject(Class_StoreSubCard);
  try
    mBo.Load(mSubCard_ID,nil);
    mS := GetParamValue(mOS,'MINLIMIT');
    mR := mBo.GetFieldValueAsFloat('X_Min');
    if Trim(mS) <> '' then begin
      if mR < (mBo.GetFieldValueAsFloat(mS)-mBo.GetFieldValueAsFloat('Quantity')) then mR := mBo.GetFieldValueAsFloat(mS)-mBo.GetFieldValueAsFloat('Quantity');
    end;
    mF := IntForecastOrder(mOS, mSubCard_ID);
{    Result := mBo.GetFieldValueAsFloat('Quantity')<
        (mR + mBo.GetFieldValueAsFloat('X_KorekceMin') +
         IntReceivedOrdersSubCard(mOS,mBo.GetFieldValueAsString('Store_ID'),mBo.GetFieldValueAsString('StoreCard_ID'))
        -IntOrdersSubCard(mOS, mSubCard_ID)-  mF);}
        
    Result := (mR + mBo.GetFieldValueAsFloat('X_KorekceMin')) > (mBo.GetFieldValueAsFloat('Quantity')
         -IntReceivedOrdersSubCard(mOS,mBo.GetFieldValueAsString('Store_ID'),mBo.GetFieldValueAsString('StoreCard_ID'))
        +IntOrdersSubCard(mOS, mSubCard_ID)-  mF);
  finally
    mBO.Free;
  end;
end;

function ClenOrderLogic(AReportHelper:TNxQRScriptHelper;const mSubCard_ID:String):Boolean;
begin
   Result := IntClenOrderLogic(AReportHelper.ObjectSpace,mSubCard_ID);
end;

{Celková objednávka (bezzohlednění balení)}
function IntCleanOrder(mOS:TNxCustomObjectSpace;const mSubCard_ID:String):Extended;
var
 mBO : TNxCustomBusinessObject;
 mS : String;
 mR,mObjVyd : Extended;
begin
  Result := 0;
  mBO := mOS.CreateObject(Class_StoreSubCard);
  try
    mS := GetParamValue(mOS,'MINLIMIT');
    mBo.Load(mSubCard_ID,nil);
    mR := mBo.GetFieldValueAsFloat('X_Min') - mBo.GetFieldValueAsFloat('Quantity') - IntOrdersSubCard(mOS,mSubCard_ID);
    if mR < 0 then mR := 0;
    mR := mR + mBo.GetFieldValueAsFloat('X_Max');
    if GetParamValue(mOS,'RESREVORDE') = 'ANO' then mObjVyd := IntOrdersSubCardOnlyRes(mOS, mSubCard_ID) //Odečte jen ty Obj, který vykrývají dané obj. přijaté
    else mObjVyd:= IntOrdersSubCard(mOS, mSubCard_ID);
    if Trim(mS) <> '' then begin
       if mR < (mBo.GetFieldValueAsFloat(mS)-mBo.GetFieldValueAsFloat('Quantity')) then mR := mBo.GetFieldValueAsFloat(mS)-mBo.GetFieldValueAsFloat('Quantity');
    end;
    Result := mR + mBo.GetFieldValueAsFloat('X_KorekceMax') + IntReceivedOrdersSubCard(mOS,mBo.GetFieldValueAsString('Store_ID'),mBo.GetFieldValueAsString('StoreCard_ID'))
// zde je diskutabiln9 odečítat objednávky vydané, protože je-li jich více a dlouhá doba dodání není to dobře, pro běžné obj. , kdy se kompenzují obj. přijaté to dobře je
// časem asi udělatna parametr
    -mObjVyd;
  finally
    mBO.Free;
  end;
end;

function ClenOrder(AReportHelper:TNxQRScriptHelper;const mSubCard_ID:String):Extended;
begin
   Result := IntCleanOrder(AReportHelper.ObjectSpace,mSubCard_ID);
end;

function IntDateExportImportInv(const AObjectSpace: TNxCustomObjectSpace;mDateExp:TDateTime;const mExp:Byte): Extended;
{mDateExp - datum  + čas Exportu Do Inventora a načetní z Inventora. Je-li 0 je se čte hodnota z repozitoře
mExp 0 - Datum a čas Expotr z SW ABRA
mExp 1 - datum a čas ukončení importu do SW ABRA}

var
  mPars: TNxParameters;
  mCon: TNxContext;
  mName: string;
begin
  Result := 0;
  mCon := NxCreateContext(AObjectSpace);
  try
    mPars := TNxParameters.Create;
    try
      case mExp of
        0: mName := cExpToInv;
        1: mName := cImpFromInv;
        else RaiseException('Nepovolený parametr mExp ve funkci IntDateExportImportInv:' + IntToStr(mExp));
      end;
       if mDateExp = 0 then begin
        mCon.GetCompanyCache.LoadPropertiesForCompany(mName, mPars);
        if mPars.ParamExist(mName) then
          Result := mPars.GetOrCreateParam(dtDateTime, mName).AsDateTime;
       end else begin
        mPars.GetOrCreateParam(dtDateTime, mName).AsDateTime := mDateExp;
        mCon.GetCompanyCache.SavePropertiesForCompany(mName, mPars);
       end;
    finally
      mPars.Free;
    end;
  finally
    mCon.Free;
  end;
end;

function DateExportImportInv(AReportHelper:TNxQRScriptHelper;const mDateExp:TDateTime;const mExp:Byte):Extended;
begin
   Result := IntDateExportImportInv(AReportHelper.ObjectSpace,mDateExp,mExp);
end;

{objednání s ohledm na balení}

function GetClearQuantity(aBOSubCard:TNxCustomBusinessObject):Extended;
//Funkce vrátí ideální potřebné množství bez ohledu na balení
{var
   mS : String;
   mR : Extended;}
begin
  (* mS := GetParamValue(aBOSubCard.ObjectSpace,'MINLIMIT');
   mR := aBOSubCard.GetFieldValueAsFloat('X_Max');
   if Trim(mS) <> '' then begin
      if mR < (aBOSubCard.GetFieldValueAsFloat(mS)-aBOSubCard.GetFieldValueAsFloat('Quantity')) then mR := aBOSubCard.GetFieldValueAsFloat(mS)-aBOSubCard.GetFieldValueAsFloat('Quantity');
   end;
  Result := mR + aBOSubCard.GetFieldValueAsFloat('X_KorekceMax')+
       IntReceivedOrdersSubCard(aBOSubCard.ObjectSpace,aBOSubCard.GetFieldValueAsString('Store_id'),aBOSubCard.GetFieldValueAsString('StoreCard_id'))
       -IntOrdersSubCard(aBOSubCard.ObjectSpace, aBOSubCard.OID);*)

 Result := IntCleanOrder(aBOSubCard.ObjectSpace,aBOSubCard.OID);
   if Result < 0 then Result := 0;
end;

(*function GetQuantity(aBOSubCard:TNxCustomBusinessObject):Extended;
var
 Res,mMin,mBal{,mCoef}: Extended;
 mUnit : string;
   //Původní verze bez sdílených číselníků
begin
  Result :=0;
  Res := GetClearQuantity(aBOSubCard);
  mBal := NxEvalObjectExprAsFloat(aBOSubCard,'StoreCard_ID.MainSupplier_ID.UnitRate') *
           NxEvalObjectExprAsFloat(aBOSubCard,'StoreCard_ID.MainSupplier_ID.Packing');
 if mBal = 0 then mBal := 1; //Ošetření nevyplnění - minimálně 1 ks.
//  poladíme, že minimum není počet balení, ale celkové minimum
  if UpperCase(GetParamValue(aBOSubCard.ObjectSpace,'MINPACKING'))= 'ANO' then
    mMin := NxEvalObjectExprAsFloat(aBOSubCard,'StoreCard_ID.MainSupplier_ID.MinimalQuantity')
  else
    mMin := NxEvalObjectExprAsFloat(aBOSubCard,'StoreCard_ID.MainSupplier_ID.MinimalQuantity') * mBal;
  if Res < mMin then Res := mMin;
  // zaokrouhlíme na celé balení
  if (Res mod mBal) <>0 then
    Res := (Res div mBal)* mBal  + mBal;
 //   mCoef := NxEvalObjectExprAsFloat(mBOSubCard,'StoreCard_ID.MainSupplier_ID.Purchase');
  Result := Res;
end;

*)
function GetQuantity(aBOSubCard:TNxCustomBusinessObject):Extended;
var
  Res,mMin,mBal{,mCoef}: Extended;
  mSupplier : TNxCustomBusinessObject;
  mUnit : string;
  mRollShare : Boolean;
  mStr : TStringList;
  mErr: Boolean;
begin
  Result :=0;
  Res := GetClearQuantity(aBOSubCard);
  mRollShare := UpperCase(GetParamValue(aBOSubCard.ObjectSpace,'ROLLSHARE')) = 'ANO';
  mSupplier := aBOSubCard.ObjectSpace.CreateObject(Class_Supplier);
  mErr := false;
  try //nebyly ošetřeny sdílené číselníky
    if mRollShare then begin
      mStr := TStringList.Create;
      try
         aBOSubCard.ObjectSpace.SQLSelect('select id from Suppliers S where s.DoDemand = ''A'' and S.StoreCard_ID = ''' + aBOSubCard.GetFieldValueAsString('StoreCard_ID') + '''',mStr);
         if mStr.Count = 0 then mErr := True
         else mSupplier.Load(mStr.Strings(0),nil);
      finally
        mStr.Free;
      end;
    end else mSupplier.Load(aBOSubCard.GetFieldValueAsString('StoreCard_ID.MainSupplier_ID'),nil);
    if mErr then mBal := 1
    else {mBal := NxEvalObjectExprAsFloat(aBOSubCard,'StoreCard_ID.MainSupplier_ID.UnitRate') *
             NxEvalObjectExprAsFloat(aBOSubCard,'StoreCard_ID.MainSupplier_ID.Packing');}
         mBal := mSupplier.GetFieldValueAsFloat('UnitRate') * mSupplier.GetFieldValueAsFloat('Packing');

     if mBal = 0 then mBal := 1; //Ošetření nevyplnění - minimálně 1 ks.
  //  poladíme, že minimum není počet balení, ale celkové minimum
{     if UpperCase(GetParamValue(aBOSubCard.ObjectSpace,'MINPACKING'))= 'ANO' then
       mMin := NxEvalObjectExprAsFloat(aBOSubCard,'StoreCard_ID.MainSupplier_ID.MinimalQuantity')
     else mMin := NxEvalObjectExprAsFloat(aBOSubCard,'StoreCard_ID.MainSupplier_ID.MinimalQuantity') * mBal;
 }

     if UpperCase(GetParamValue(aBOSubCard.ObjectSpace,'MINPACKING'))= 'ANO' then
       mMin := mSupplier.GetFieldValueAsFloat('MinimalQuantity')
     else mMin := mSupplier.GetFieldValueAsFloat('MinimalQuantity') * mBal;

     if Res < mMin then Res := mMin;
  // zaokrouhlíme na celé balení
     if (Res mod mBal) <>0 then Res := (Res div mBal)* mBal  + mBal;
 //   mCoef := NxEvalObjectExprAsFloat(mBOSubCard,'StoreCard_ID.MainSupplier_ID.Purchase');
    Result := Res;
  finally
    mSupplier.Free;
  end;
end;
function OrderWithPacking(AReportHelper:TNxQRScriptHelper;const mSubCard_ID:String):Extended;
Var
  mBO : TNxCustomBusinessObject;
begin
  mBo := AReportHelper.ObjectSpace.CreateObject(Class_StoreSubCard);
  try
    mBo.Load(mSubCard_ID,nil);
    Result := GetQuantity(mBo);
  finally
    mBo.Free;
  end;
end;

begin
end.