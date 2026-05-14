{
Vyvolává se po uložení vlastních dat objektu do databáze.
}
procedure AfterSave_Hook(Self: TNxCustomBusinessObject);
var
 mJSON:TJSONSuperObject;
begin
  if  osNew in self.State then begin
     mJSON:=TJSONSuperObject.create;
     mJSON.S['Code']:=self.GetFieldValueAsString('Code');
     mJSON.S['Name']:=self.GetFieldValueAsString('Name');
     API_POST(mJSON);
  end;
end;

function API_POST(aJSON:TJSONSuperObject):TJSONSuperObject;
var
 mWinHTTP:Variant;
 mResultJSON:TJSONSuperObject;
begin
   mWinHTTP:= CreateOleObject('WinHttp.WinHttpRequest.5.1');
   mWinHTTP.Open('POST', 'http://192.168.0.81:88/Servis/script/APISync/lib/CheckBusOrder/');
   mWinHTTP.SetRequestHeader('Content-Type', 'application/json');
   mWinHTTP.SetRequestHeader('Authorization','Basic QVBJOmFicmFhcGk=');
   mWinHTTP.Send(aJSON.AsJson);
   Result:=TJSONSuperObject.Create;
   Result.I['HTTPStatus']:=StrToInt(mWinHTTP.status);
   Result.S['InputJSON']:='#'+aJSON.AsString+'#'+TJSONSuperObject.ParseString(mWinHTTP.ResponseText, True).AsString+'#';
   if mWinHTTP.status='200' then begin
     Result.S['Status']:='OK';
   end else begin
     Result.S['Status']:='Error1';
   end;
end;

begin
end.