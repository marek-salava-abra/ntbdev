

{
Vyvolává se po uložení vlastních dat objektu do databáze.
}
procedure AfterSave_Hook(Self: TNxCustomBusinessObject);
begin
  API_GET('https://www.abena.cz/action/import/abra/firms_update.php?systemid='+self.OID);
end;

function API_GET(aURL:String): string;
var
  mWinHTTP: Variant;
  mRequest, mLogin: string;
  mJSON:TJSONSuperObject;
  mList:TStringList;
begin
  try
    mWinHTTP:= CreateOleObject('WinHttp.WinHttpRequest.5.1');
    mWinHTTP.Open('GET', aURL);
    mWinHTTP.Send();
    Result:=mWinHTTP.StatusText;
  except

  end;
end;

begin
end.