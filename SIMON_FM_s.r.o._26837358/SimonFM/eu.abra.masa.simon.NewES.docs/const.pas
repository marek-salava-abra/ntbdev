const
 cMainDir = '\\aserver\eshop_foto\storecards';
 cMainDir2 = '\\aserver\eshop_foto\menu';
 cURL = 'server.eline.cz';
 cPass = 'xqUogyHQC8_8';
 cLogin = 'elinewebabra';




{GetFilename}

function GetFilename(AReportHelper:TNxQRScriptHelper;mFileName:String):String;
begin
  Result:=Copy(mFileName,NxCharPosR('\',mFileName)+1,300);
end;

begin
end.