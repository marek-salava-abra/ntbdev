uses '.API','.const';

function GetDavkaSici(AReportHelper:TNxQRScriptHelper;StoreCardCode:String):Extended;
var
 mResultJson:TJSONSuperObject;
 mResultJSONA:TJSONSuperObjectArray;
 mList:TStringList;
begin
 Result:=0;
 try
  mResultJson:=TJSONSuperObject.Create;
  mResultJson:=API_GET(cURL+'storecards?select=X_davka_sici&where=code eq '+QuotedStr(StoreCardCode));
  mResultJSONA:=mResultJson.AsArray;
  if mResultJSONA.O[0].D['X_davka_sici']>0 then Result:=mResultJSONA.O[0].D['X_davka_sici'];
 Except

 end;
end;

begin
end.