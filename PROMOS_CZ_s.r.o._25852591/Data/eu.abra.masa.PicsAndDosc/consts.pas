const
 cMainDir = '\\10.0.0.15\abra_images';
 cMainDir2 = '\\10.0.0.15\abra_images\dokumenty';
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