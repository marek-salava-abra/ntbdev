function GetBool(AReportHelper:TNxQRScriptHelper;StoreCard_ID:String):Boolean;
var
 mBO:TNxCustomBusinessObject;
begin
 if not(NxIsEmptyOID(StoreCard_ID)) then begin
   mBO:=AReportHelper.ObjectSpace.CreateObject(Class_StoreCard);
   mBO.Load(StoreCard_ID,nil);
   Result:=mbo.GetFieldValueAsBoolean('U_MinPriceValidate');
   mBO.Free;
 end;
end;

function GetProcento(AReportHelper:TNxQRScriptHelper;StoreAssortmentGroup_ID,BusTransaction_ID:String):Extended;
var
 mList:TStringList;
begin
  mList:=tstringlist.create;
  AReportHelper.ObjectSpace.SQLSelect(format('select max(x_procento) from defrolldata where clsid=''A2VZUVV0YF14PASQQXGICHOCSK'' and x_value_ID=''%s'' and X_StoreAssortmentGroup_ID=''%s'' ',[BusTransaction_ID,StoreAssortmentGroup_ID]),mList);
  if mlist.count>0 then Result:=NxIBStrToFloat(mlist.Strings[0]) else Result:=0;
  mList.free;
end;

function GetFloat(AReportHelper:TNxQRScriptHelper;StoreCard_ID,BusTransaction_ID:String):Extended;
var
 mBO, mBBO:TNxCustomBusinessObject;
 mProcento:extended;
begin
 Result:=0;
 mProcento:=0;
 if not(NxIsEmptyOID(BusTransaction_ID)) then begin
   mbbo:=AReportHelper.ObjectSpace.CreateObject(Class_BusTransaction);
   mbbo.load(BusTransaction_ID,nil);
   mProcento:=mBBO.GetFieldValueAsFloat('U_dod_sleva');
   mbbo.free;
 end;
 if not(NxIsEmptyOID(StoreCard_ID)) then begin
   mBO:=AReportHelper.ObjectSpace.CreateObject(Class_StoreCard);
   mBO.Load(StoreCard_ID,nil);
   Result:=mbo.GetFieldValueAsFloat('U_ProcentoMax')+mprocento;
   mbo.free;
 end;
end;

begin
end.