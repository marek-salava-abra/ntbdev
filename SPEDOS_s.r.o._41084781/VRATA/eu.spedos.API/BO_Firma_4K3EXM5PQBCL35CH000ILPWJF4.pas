uses 'eu.spedos.API.fce';
{
Vyvolává se po uložení vlastních dat objektu do databáze.
}
procedure AfterSave_Hook(Self: TNxCustomBusinessObject);
Var
 aStream:TMemoryStream;
 mJSON:TJSONSuperObject;
 mWinHTTP, mWinHTTP2: Variant;
begin
  mJSON:= TJSONSuperObject.CreateNew;
  mWinHTTP2:= CreateOleObject('WinHttp.WinHttpRequest.5.1');
  if self.GetFieldValueAsBoolean('X_Cernalistina') then
  mWinHTTP2.Open('POST','https://sod.spedos.cz/api/api.abra-blacklist.php?ico='+self.GetFieldValueAsString('OrgIdentNumber')+'&Rodneico='+ GetICO(Self.ObjectSpace)+'&blacklist=1') else
  mWinHTTP2.Open('POST','https://sod.spedos.cz/api/api.abra-blacklist.php?ico='+self.GetFieldValueAsString('OrgIdentNumber')+'&Rodneico='+ GetICO(Self.ObjectSpace)+'&blacklist=0');
  mWinHTTP2.SetRequestHeader('Authorization','Basic YUJyYTpza1M4Zi1zeFI=');
  mWinHTTP2.Send();
  //NxShowSimpleMessage(mWinHTTP2.ResponseText,nil);
  mJSON := TJSONSuperObject.ParseString(mWinHTTP2.ResponseText, True);
end;

begin
end.