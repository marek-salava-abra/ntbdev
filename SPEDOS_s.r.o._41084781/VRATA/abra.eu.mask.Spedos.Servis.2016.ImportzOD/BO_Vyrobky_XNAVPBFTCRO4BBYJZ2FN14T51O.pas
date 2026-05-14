





{
Vyvolává se po uložení vlastních dat objektu do databáze.
}
procedure AfterSave_Hook(Self: TNxCustomBusinessObject);
var
  aStream:TStream;
  mbStav:Boolean ;
  mIStav:Boolean ;
  mS_User:string;
  mr:TStringList;
  mOrdnumber:string;
  mb:Boolean;
  mIIList:TStringList;
  mString:String;
   mJSON:TJSONSuperObject;
 mWinHTTP, mWinHTTP2: Variant;
begin
    mOrdnumber:='';



  // mb:=InputQuery('AA','AA','select DQ.Code || '+quotedstr('-')+' || CAST(RO.OrdNumber AS VARCHAR(10)) || '+quotedstr('/')+' || P.Code from receivedorders RO left join periods p on p.id=ro.period_ID left join docqueues dq on dq.id=ro.docqueue_id where ro.id=' + QuotedStr(mbo.GetFieldValueAsString('X_OP_pozice.X_field5')));
   mr:=TStringList.create;
try
        self.ObjectSpace.SQLSelect('select DQ.Code || '+quotedstr('-')+' || CAST(RO.OrdNumber AS VARCHAR(10)) || '+quotedstr('/')+' || P.Code from receivedorders RO  left join periods p on p.id=ro.period_ID left join docqueues dq on dq.id=ro.docqueue_id where ro.id='
+ QuotedStr(Self.GetFieldValueAsString('X_OP_pozice.X_field5')),mr);
        if mr.count=0 then begin
               mOrdnumber:='';
        end else begin
               mOrdnumber:=mr.Strings[0];

        end;
   finally
       mr.free;
   end;


mbstav:=false;
 try
   // mb:=InputQuery('AA','AA',
   //   'https://sod.spedos.cz/api/api.abra-vyrobek.php?'+
   //   'user=aBra&password=skS8f-sxR&ID_montaz_vyrobky=' + self.GetFieldValueAsString('Code') +
   //   '&vyrobni_cislo='+ self.GetFieldValueAsString('Name')+
   //   '&datum_vyroby='+ FormatDateTime('YYYY-MM-DD',self.GetFieldValueAsDateTime('X_Datum_vyroby$date')) +
   //   '&datum_vyrobeno='+ FormatDateTime('YYYY-MM-DD',self.GetFieldValueAsDateTime('X_Vyrobeno$date'))+
   //   '&cis_zak='+ self.GetFieldValueAsString('X_busOrder_ID.CODE')+
   //   '&cis_obj='+ mOrdnumber +
   //   '&prislusenstvi='+ self.GetFieldValueAsString('X_ISIRDATA')+
   //   '&barva='+ self.GetFieldValueAsString('X_field1')+
   //   '&abra_user='+self.GetFieldValueAsString('X_field4'));

  mIIList:=TStringList.create;
  self.ObjectSpace.SQLSelect(format('select id from issuedinvoices2 where busorder_id=''%s'' ',[self.GetFieldValueAsString('X_BusOrder_ID')]),mIIList);
  if mIIList.Count=0 then mString:='0' else mString:='1';
  mIIList.free;

  AStream := TMemoryStream.Create;
    if not nxisblank(Self.GetFieldValueAsString('Name')) then begin
     {  mbstav:= CFxInternet.HTTPPostBinary('https://sod.spedos.cz/api/api.abra-vyrobek.php?',
      'user=aBra&password=skS8f-sxR&ID_montaz_vyrobky=' + self.GetFieldValueAsString('Code') +
      '&vyrobni_cislo='+ self.GetFieldValueAsString('Name')+
//      '&datum_vyroby='+ '0' +// FormatDateTime('YYYY-MM-DD',self.GetFieldValueAsDateTime('X_Datum_vyroby$date')) +
//      '&datum_vyrobeno='+ '0' + // FormatDateTime('YYYY-MM-DD',self.GetFieldValueAsDateTime('X_Vyrobeno$date'))+
      '&cis_zak='+ self.GetFieldValueAsString('X_busOrder_ID.CODE')+
      '&cis_obj='+ mOrdnumber +
      '&prislusenstvi='+ self.GetFieldValueAsString('X_ISIRDATA')+
      '&barva='+ self.GetFieldValueAsString('X_field1')+
      '&abra_user='+ self.GetFieldValueAsString('X_field4')+'&fakturovano='+mString,aStream);  }

                              mJSON:= TJSONSuperObject.CreateNew;
                              mWinHTTP2:= CreateOleObject('WinHttp.WinHttpRequest.5.1');
                              mWinHTTP2.Open('POST','https://sod.spedos.cz/api/api.abra-vyrobek.php?ID_montaz_vyrobky=' + self.GetFieldValueAsString('Code') +
      '&vyrobni_cislo='+ self.GetFieldValueAsString('Name')+
//      '&datum_vyroby='+ '0' +// FormatDateTime('YYYY-MM-DD',self.GetFieldValueAsDateTime('X_Datum_vyroby$date')) +
//      '&datum_vyrobeno='+ '0' + // FormatDateTime('YYYY-MM-DD',self.GetFieldValueAsDateTime('X_Vyrobeno$date'))+
      '&cis_zak='+ self.GetFieldValueAsString('X_busOrder_ID.CODE')+
      '&cis_obj='+ mOrdnumber +
      '&prislusenstvi='+ self.GetFieldValueAsString('X_ISIRDATA')+
      '&barva='+ self.GetFieldValueAsString('X_field1')+
      '&Rodneico='+ GetIco(self.ObjectSpace)+
      '&abra_user='+ self.GetFieldValueAsString('X_field4')+'&fakturovano='+mString);
                              mWinHTTP2.SetRequestHeader('Authorization','Basic YUJyYTpza1M4Zi1zeFI=');
                              mWinHTTP2.Send();
                              mJSON := TJSONSuperObject.ParseString(mWinHTTP2.ResponseText, True);







   //    'select DQ.Code || '+quotedstr('-')+' || CAST(RO.OrdNumber AS VARCHAR(10)) || '+quotedstr('/')+' || P.Code from receivedorders RO left join periods p on p.id=ro.period_ID left join docqueues dq on dq.id=ro.docqueue_id where ro.id=' + QuotedStr(mbo.GetFieldValueAsString('X_OP_pozice.X_field5')));




    end;

finally
  AStream.Free;
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