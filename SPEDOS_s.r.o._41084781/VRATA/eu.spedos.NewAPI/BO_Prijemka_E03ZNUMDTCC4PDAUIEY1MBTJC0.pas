{
Vyvolává se po uložení vlastních dat objektu do databáze.
}
procedure AfterSave_Hook(Self: TNxCustomBusinessObject);
var
 mDocRowBatches, mRows:TNxCustomBusinessMonikerCollection;
 mDocRowBatch, mRowBO:TNxCustomBusinessObject;
 i,j:Integer;
 mJSON:TJSONSuperObject;
 mWinHTTP, mWinHTTP2: Variant;
 mVyr, mID_montaz_vyrobky:string;
 mStream:TMemoryStream;
begin
  mRows:=self.GetLoadedCollectionMonikerForFieldCode(self.GetFieldCode('Rows'));
  for j:=0 to mrows.Count-1 do begin
    mRowBO:=mRows.BusinessObject[j];
    mDocRowBatches:=mRowBO.GetLoadedCollectionMonikerForFieldCode(mRowBO.GetFieldCode('DocRowBatches'));
    if mDocRowBatches.count>0 then begin
      for i:=0 to mDocRowBatches.count-1 do begin
         mDocRowBatch:=mDocRowBatches.BusinessObject[i];
             mJSON:= TJSONSuperObject.CreateNew;
             mVyr:=NxSearchReplace(mDocRowBatch.GetFieldValueAsString('StoreBatch_ID.Name'),'/','\/',[srAll]);
             if not(NxIsBlank(mVyr)) then begin
             mWinHTTP:= CreateOleObject('WinHttp.WinHttpRequest.5.1');
             mWinHTTP.Open('GET','https://sod.spedos.cz/api/api.abra-get-vyrobek.php?vyrobni_cislo='+mVyr);
             mWinHTTP.SetRequestHeader('Authorization','Basic YUJyYTpza1M4Zi1zeFI=');
             mWinHTTP.Send();
             mJSON:= TJSONSuperObject.CreateNew;
             mJSON := TJSONSuperObject.ParseString(mWinHTTP.ResponseText, True);
             //NxShowSimpleMessage(mJSON.AsString,nil);
             mID_montaz_vyrobky:=mJSON.S['ID_montaz_vyrobky'];
             //NxShowSimpleMessage(mID_montaz_vyrobky,nil);
             mWinHTTP2:= CreateOleObject('WinHttp.WinHttpRequest.5.1');
             mWinHTTP2.Open('POST','https://sod.spedos.cz/api/api.abra-vyrobek.php?ID_montaz_vyrobky='+mID_montaz_vyrobky+'&Rodneico='+ GetICO(self.ObjectSpace)+'&datum_vyrobeno='+ FormatDateTime('YYYY-MM-DD',self.GetFieldValueAsDateTime('DocDate$DATE'))+'&abra_id='+self.OID);
             mWinHTTP2.SetRequestHeader('Authorization','Basic YUJyYTpza1M4Zi1zeFI=');
             mWinHTTP2.Send();
             mJSON := TJSONSuperObject.ParseString(mWinHTTP2.ResponseText, True);
             //NxShowSimpleMessage(mJSON.AsString,nil);

             end;
      end;
    end;
  end;
end;


function GetICO(AOS : TNxCustomObjectSpace) : string;
const
  cSQL = 'SELECT OrgIdentNumber FROM GlobData ';
var
  mList : TStringList;
begin
  mList := TStringList.Create;
  try
    AOS.SQLSelect(cSQL, mList);
    if mList.Count > 0 then
      Result := mList.Strings[0]
      else Result:='';
  finally
    mList.Free;
  end;
end;

begin
end.