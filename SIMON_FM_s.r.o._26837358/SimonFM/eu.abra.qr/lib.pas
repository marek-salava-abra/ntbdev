
{Count}

function Count(AReportHelper:TNxQRScriptHelper;aStoreCard_ID:String;aStore_ID:String;aOrderFlow:Integer):Extended;
var
 mQinList, mQoutList:TStringList;
 mQinSQL, mQoutSql:String;
 mqin, mqout:Extended;
begin
  //Result:=0;
  mQinSQL:='Select sum(SD2.quantity/sd2.unitrate) from storedocuments2 sd2 left join storedocuments sd on SD2.parent_id=sd.ID where (sd.documenttype=''20'' or sd.documenttype=''23'' or sd.documenttype=''24'' or sd.documenttype=''25'' or sd.documenttype=''28'' or sd.documenttype=''29'') and sd2.store_ID=''%s'' and sd2.storecard_ID=''%s''  and sd2.orderflow<%s';
  mQoutSql:='Select sum(SD2.quantity/sd2.unitrate) from storedocuments2 sd2 left join storedocuments sd on SD2.parent_id=sd.ID where (sd.documenttype=''21'' or sd.documenttype=''22'' or sd.documenttype=''26'' or sd.documenttype=''27'' or sd.documenttype=''30'') and sd2.store_ID=''%s'' and sd2.storecard_ID=''%s''  and sd2.orderflow<%s';
  mQinList:=TStringList.create;
  mQoutList:=TStringList.create;
  AReportHelper.ObjectSpace.SQLSelect(Format(mQinSQL,[aStore_ID,aStoreCard_ID, IntToStr(aOrderFlow+1)]),mQinList);
  AReportHelper.ObjectSpace.SQLSelect(Format(mQoutSql,[aStore_ID,aStoreCard_ID, IntToStr(aOrderFlow+1)]),mQoutList);
  Result:= StrToFloat(mQinList.Strings[0])-StrToFloat(mQoutList.Strings[0]);
  mQinList.free;
  mQoutList.free;
end;
begin
end.