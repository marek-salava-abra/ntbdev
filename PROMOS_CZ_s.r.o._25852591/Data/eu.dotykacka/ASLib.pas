uses 'eu.dotykacka.fce';

procedure CheckDotykacka (OS: TNxCustomObjectSpace; var Success: Boolean; var LogInfoStr: String);
var
 mURL, mStatusText:String;
 mDateFrom,mDateTo:TDateTime;
 mStatusCode:integer;
 mJSON:TJSONSuperObject;
 mString:string;
begin
      mDateFrom:=Date-8;
      mDateTo:=Date;
      mURL:= 'https://api.dotykacka.cz/v2/clouds/'+cCloudID+'/orders/?include=orderItems&limit=100&filter=completed|gteq|'+IntToStr(DateTimeToUnix(mDateFrom))+'000'+';completed|lt|'+IntToStr(DateTimeToUnix(mDateTo+1))+'000';
      mURL:= CFxInternet.URLEncode(mURL);
      mJSON:= API_GET2(mURL, mStatusCode, mStatusText);
      if mStatusCode=200 then begin
       mstring:= ProcessJSONData(OS, mJSON,IntToStr(DateTimeToUnix(mDateFrom)),IntToStr(DateTimeToUnix(mDateTo+1)));
      end;
  Success := True;
  LogInfoStr := ''+murl+#13#10+#13#10+mstring;
end;

begin
end.