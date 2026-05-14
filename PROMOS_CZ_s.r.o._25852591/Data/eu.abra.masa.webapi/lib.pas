function GET_KingTonyPrices(AContext: TNxContext; APath: String): TJSONSuperObject;
var
  mStoreCardBO: TNxCustomBusinessObject;
  mOS: TNxCustomObjectSpace;
  mPath: String;
  mJSON:TJSONSuperObject;
  mList:TStringList;
  i:integer;
  mPrice, mNormalPrice:Extended;
begin
  mOS:=AContext.GetObjectSpace;
  Result:=TJSONSuperObject.Create;
  mList:=TStringList.Create;
  mOS.SQLSelect('select ap.StoreCard_id from ActionPricelists a '+
                'left join actionstoreprices ap on ap.pricelist_id=a.id '+
                'left join storecards sc on sc.id=ap.storecard_id where sc.X_Card_B2B=''A'' and sc.hidden=''N'' and (a.datefrom$date<=('+inttostr(trunc(date))+')) and (a.dateto$date>=('+inttostr(trunc(date))+'))', mList);
  if mlist.count>0 then begin
    Result.O['KingTonyPrices'] := Result.CreateJSONArray;
    for i:=0 to mlist.count-1 do begin
      mJSON:= TJSONSuperObject.Create;
      mJSON.S['StoreCard_ID']:=mlist.strings[i];
      mStoreCardBO:=mOS.CreateObject(Class_StoreCard);
      mStorecardBO.Load(mlist.Strings[i],nil);
      mPrice:=NxEvalObjectExprAsFloatDef(mStoreCardBO,'NxGetStoreCardUnitPriceDef('+Quotedstr('')+', '+Quotedstr('')+', ' + QuotedStr(mstorecardBO.OID) + ','+Quotedstr('1000000101')+', '+Quotedstr(mStoreCardBO.GetFieldValueAsString('MainUnitCode'))+',false,'+QuotedStr('0000CZK000')+','+inttostr(trunc(Date))+')',0);
      mJSON.D['ActionPrice']:=mPrice;
      Result.A['KingTonyPrices'].Add(mJSON);
    end;
  end;
end;

begin
end.