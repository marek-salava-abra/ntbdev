procedure BeforeSave_Hook(Self: TNxCustomBusinessObject);
var
 mStoreCardBO, mPriceBO:TNxCustomBusinessObject;
begin
  //self.SetFieldValueAsDateTime('X_date_of_change',Now);
  mPriceBO:=self.GetMonikerForFieldCode(self.GetFieldCode('Parent_ID')).BusinessObject;
  if mPriceBO.GetFieldValueAsString('PriceList_ID')='1000000101' then begin
   mStoreCardBO:=mPriceBO.GetMonikerForFieldCode(mPriceBO.GetFieldCode('StoreCard_ID')).BusinessObject;
   mStoreCardBO.SetFieldValueAsString('U_PriceChangeName', AnsiLeftStr(NxCreateContext_1(mPriceBO).GetCentralCache.getuserName(NxGetActualUserID_1(mPriceBO)),20));
   mStoreCardBo.SetFieldValueAsDateTime('U_PriceChangeDate', Now);
   mStoreCardBO.save;
  end;
end;

begin
end.