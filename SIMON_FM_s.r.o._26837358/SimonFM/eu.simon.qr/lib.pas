
{GetBool}


{FileExists}

function FExists(AReportHelper:TNxQRScriptHelper;mFilePath:String):Boolean;
begin
  Result:=FileExists(mFilePath);
end;

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


function GetFloat(AReportHelper:TNxQRScriptHelper;StoreCard_ID:String):Extended;
var
 mBO:TNxCustomBusinessObject;
begin
 Result:=0;
 if not(NxIsEmptyOID(StoreCard_ID)) then begin
   mBO:=AReportHelper.ObjectSpace.CreateObject(Class_StoreCard);
   mBO.Load(StoreCard_ID,nil);
   Result:=mbo.GetFieldValueAsFloat('U_ProcentoMax');
   mbo.free;
 end;
end;


begin
end.