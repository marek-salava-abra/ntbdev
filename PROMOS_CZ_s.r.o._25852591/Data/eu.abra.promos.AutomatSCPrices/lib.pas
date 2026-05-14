procedure SetPricesForDate(OS: TNxCustomObjectSpace; var Success: Boolean; var LogInfoStr: String);
var
 mPriceListValidity_ID, mPrevPriceListValidity_ID, mPriceList_ID, mStorePrice_ID, mPrevStorePrice_ID, mStoreCard_ID,mUnitCode:string;
 mLog, mStoreCardList:TStringList;
 mStorePrice, mStorePriceRow, mStoreCardBO:TNxCustomBusinessObject;
 mPriceCZK, mPriceEUR:extended;
 mSPRows:TNxCustomBusinessMonikerCollection;
 i,j,k:integer;
begin
  mLog:=TStringList.create;
  mLog.Add(DateTimeToStr(Now)+' - začátek tvorby cen');
  mPriceList_ID:='1000000101';
  mPriceListValidity_ID:=OS.SQLSelectFirstAsString('Select id from pricelistvalidities where parent_id='+QuotedStr(mPriceList_ID)+' and validfromdate$date='+IntToStr(Trunc(date)),'');
  //mPrevPriceListValidity_ID:=OS.SQLSelectFirstAsString('Select id from pricelistvalidities where parent_id='+QuotedStr(mPriceList_ID)+' and validfromdate$date='+IntToStr(Trunc(date-1)),'');
  mPrevPriceListValidity_ID:=OS.SQLSelectFirstAsString('Select first 1 id from pricelistvalidities where parent_id='+QuotedStr(mPriceList_ID)+' and not(validfromdate$date='+IntToStr(Trunc(date))+') order by validfromdate$date desc ','');
  if not(NxIsEmptyOID(mPriceListValidity_ID)) then begin
   mLog.Add(DateTimeToStr(Now)+' - máme časovou platnost pro datum '+DateToStr(date));
   mLog.add(DateTimeToStr(Now)+' - mPriceListValidity_ID: '+mPriceListValidity_ID);
   mLog.add(DateTimeToStr(Now)+' - mPrevPriceListValidity_ID: '+mPrevPriceListValidity_ID);
   mLog.Add(DateTimeToStr(Now)+' - jdeme hledat seznam skladových karet');
   mStoreCardList:=TStringList.Create;
   //mStoreCardList.add('MBCD000101');
   OS.SQLSelect('select distinct(sc.id) from storecards sc left join storeprices sp on sc.id=sp.storecard_id where sp.pricelist_id='
           +Quotedstr(mPriceList_ID)+' and sc.hidden='+QuotedStr('N')+' and sc.X_Card_B2B='+QuotedStr('A'),mStoreCardList);
   //OS.SQLSelect('Select id from storecards where ((createdat$date > 45824) or (correctedat$date > 45824))',mStoreCardList);
   if mStoreCardList.Count>0 then begin
     mLog.Add(DateTimeToStr(Now)+' - seznam má '+IntToStr(mStoreCardList.count)+' karet');
     for i:=0 to mStoreCardList.count-1 do begin
        mStoreCard_ID:=mStoreCardList.Strings[i];
        mStorePrice_ID:=OS.SQLSelectFirstAsString('Select id from storeprices where pricelist_id='+QuotedStr(mPriceList_ID)+
                                                  ' and pricelistvalidity_id='+QuotedStr(mPriceListValidity_ID)+
                                                  ' and storecard_id='+QuotedStr(mStoreCard_ID),'');
        mPrevStorePrice_ID:=OS.SQLSelectFirstAsString('Select id from storeprices where pricelist_id='+QuotedStr(mPriceList_ID)+
                                                  ' and pricelistvalidity_id='+QuotedStr(mPrevPriceListValidity_ID)+
                                                  ' and storecard_id='+QuotedStr(mStoreCard_ID),'');
        if NxIsEmptyOID(mStorePrice_ID) then begin
          mUnitCode:=OS.SQLSelectFirstAsString('Select mainunitcode from storecards where id='+QuotedStr(mStoreCard_ID),'');
          mStorePrice:=OS.CreateObject(Class_StorePrice);
          mStorePrice.new;
          mStorePrice.prefill;
          //mPriceCZK:=NxEvalObjectExprAsFloatDef(mStorePrice,'NxGetStoreCardUnitPriceDef('+Quotedstr('')+', '+Quotedstr('')+', ' + QuotedStr(mStoreCard_ID) + ','+Quotedstr('1000000101')+', '+Quotedstr(mUnitCode)+',false,'+QuotedStr('0000CZK000')+','+inttostr(trunc(Date))+')',0);
          //mPriceEUR:=NxEvalObjectExprAsFloatDef(mStorePrice,'NxGetStoreCardUnitPriceDef('+Quotedstr('')+', '+Quotedstr('')+', ' + QuotedStr(mStoreCard_ID) + ','+Quotedstr('1100000101')+', '+Quotedstr(mUnitCode)+',false,'+QuotedStr('0000EUR000')+','+inttostr(trunc(Date))+')',0);
          mPriceCZK:=OS.SQLSelectFirstAsExtended('Select amount from storeprices2 where parent_id='+QuotedStr(mPrevStorePrice_ID)+' and price_id='+QuotedStr('1000000101'),0);
          mPriceEUR:=OS.SQLSelectFirstAsExtended('Select amount from storeprices2 where parent_id='+QuotedStr(mPrevStorePrice_ID)+' and price_id='+QuotedStr('1100000101'),0);
          mStorePrice.SetFieldValueAsString('StoreCard_ID',mStoreCard_ID);
          mStorePrice.SetFieldValueAsString('PriceList_ID',mPriceList_ID);
          mStorePrice.SetFieldValueAsString('PriceListValidity_ID',mPriceListValidity_ID);
          mSPRows:=mStorePrice.GetLoadedCollectionMonikerForFieldCode(mStorePrice.GetFieldCode('PriceRows'));
          if mPriceCZK>0 then begin
            mStorePriceRow:=mSPRows.AddNewObject;
            mStorePriceRow.SetFieldValueAsString('Price_ID','1000000101');
            mStorePriceRow.SetFieldValueAsFloat('Amount',mPriceCZK);
            mStorePriceRow.SetFieldValueAsString('Qunit',mUnitCode);
          end;
          if mPriceEUR>0 then begin
            mStorePriceRow:=mSPRows.AddNewObject;
            mStorePriceRow.SetFieldValueAsString('Price_ID','1100000101');
            mStorePriceRow.SetFieldValueAsFloat('Amount',mPriceEUR);
            mStorePriceRow.SetFieldValueAsString('Qunit',mUnitCode);
          end;
          mStorePrice.save;
          mStorePrice.free;
        end else begin
          mUnitCode:=OS.SQLSelectFirstAsString('Select mainunitcode from storecards where id='+QuotedStr(mStoreCard_ID),'');
          mStorePrice:=OS.CreateObject(Class_StorePrice);
          mStorePrice.Load(mStorePrice_ID,nil);
          //mPriceCZK:=NxEvalObjectExprAsFloatDef(mStorePrice,'NxGetStoreCardUnitPriceDef('+Quotedstr('')+', '+Quotedstr('')+', ' + QuotedStr(mStoreCard_ID) + ','+Quotedstr('1000000101')+', '+Quotedstr(mUnitCode)+',false,'+QuotedStr('0000CZK000')+','+inttostr(trunc(Date))+')',0);
          //mPriceEUR:=NxEvalObjectExprAsFloatDef(mStorePrice,'NxGetStoreCardUnitPriceDef('+Quotedstr('')+', '+Quotedstr('')+', ' + QuotedStr(mStoreCard_ID) + ','+Quotedstr('1100000101')+', '+Quotedstr(mUnitCode)+',false,'+QuotedStr('0000EUR000')+','+inttostr(trunc(Date))+')',0);
          mPriceCZK:=OS.SQLSelectFirstAsExtended('Select amount from storeprices2 where parent_id='+QuotedStr(mPrevStorePrice_ID)+' and price_id='+QuotedStr('1000000101'),0);
          mPriceEUR:=OS.SQLSelectFirstAsExtended('Select amount from storeprices2 where parent_id='+QuotedStr(mPrevStorePrice_ID)+' and price_id='+QuotedStr('1100000101'),0);
          mSPRows:=mStorePrice.GetLoadedCollectionMonikerForFieldCode(mStorePrice.GetFieldCode('PriceRows'));
          for k:=0 to mSPRows.count-1 do begin
            mStorePriceRow:=mSPRows.BusinessObject[k];
            if (mStorePriceRow.GetFieldValueAsString('Price_ID')='1000000101') and not(mPriceCZK=0)
              then mStorePriceRow.SetFieldValueAsFloat('Amount',mPriceCZK);
            if (mStorePriceRow.GetFieldValueAsString('Price_ID')='1100000101') and not(mPriceEUR=0)
              then mStorePriceRow.SetFieldValueAsFloat('Amount',mPriceEUR);
          end;
          mStorePrice.save;
          mStorePrice.free;
        end;
     end;
   end;
  end;
  mLog.Add(DateTimeToStr(Now)+' - konec tvorby tvorby cen');
  Success := True;
  LogInfoStr := 'výsledek'+#13#10+mLog.text;
end;

begin
end.