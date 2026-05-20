Const
 cStore_ID = '1010000101';

procedure GetBMSQuantity(OS: TNxCustomObjectSpace; var Success: Boolean; var LogInfoStr: String);
var
 mJSON, mJSON2:TJSONSuperObject;
 mJSONArray:TJSONSuperObjectArray;
 mDate:string;
 i,j,k:integer;
 mSSCBO:TNxCustomBusinessObject;
 mStoreCard_ID, mSSC_ID:string;
 mTime:Extended;
begin
  mTime:=Frac(Now);
  {if mTime<(1/24) then} os.SQLExecute('update storesubcards set quantity=0 where store_id='+QuotedStr(cStore_ID));
  mJSON:=TJSONSuperObject.Create;
  mJSON2:=TJSONSuperObject.Create;
  mJSONArray:=TJSONSuperObjectArray.Create;
  mJSON:=API_GET('https://api.barton.cz:8444/barton/StoreSubcards?select=StoreCard_ID.Code as code,Quantity,AverageStorePrice&where=store_id eq '+QuotedStr('1210000101'));
  //CFxLog.SaveLog(NxCreateContext(OS),'ERR','GetKingtony',mJSON.AsString,2,Now);
  mJSONArray:=mJSON.AsArray;
  j:=mJSONArray.Length;
  k:=0;
  for i:=0 to mJSONArray.Length-1 do begin
     mStoreCard_ID:=OS.SQLSelectFirstAsString('Select id from storecards where hidden=''N'' and code='+QuotedStr(mJSONArray.O[i].S['code']),'');
     if not(NxIsEmptyOID(mStoreCard_ID)) then begin
         mSSC_ID:=OS.SQLSelectFirstAsString('Select id from storesubcards where storecard_id='+QuotedStr(mStoreCard_ID)+' and store_id='+QuotedStr(cStore_ID),'');
         mSSCBO:=os.CreateObject(Class_StoreSubCard);
         if NxIsEmptyOID(mSSC_ID) then begin
           mSSCBO.New;
           mSSCBO.Prefill;
           mSSCBO.SetFieldValueAsString('StoreCard_ID',mStoreCard_ID);
           mSSCBO.SetFieldValueAsString('Store_ID',cStore_ID);
           mSSCBO.SetFieldValueAsFloat('Quantity',mJSONArray.O[i].D['Quantity']);
           mSSCBO.SetFieldValueAsFloat('AverageStorePrice',mJSONArray.O[i].D['AverageStorePrice']);
           mSSCBO.SetFieldValueAsDateTime('AverageStorePriceDate$DATE',Date);
         end else begin
           mSSCBO.Load(mSSC_ID,nil);
           mSSCBO.SetFieldValueAsFloat('Quantity',mSSCBO.GetFieldValueAsFloat('Quantity')+mJSONArray.O[i].D['Quantity']);
           if (mJSONArray.O[i].D['AverageStorePrice']>msscbo.GetFieldValueAsFloat('AverageStorePrice')) and (mJSONArray.O[i].D['Quantity']>0) then begin
             mSSCBO.SetFieldValueAsFloat('AverageStorePrice',mJSONArray.O[i].D['AverageStorePrice']);
             mSSCBO.SetFieldValueAsDateTime('AverageStorePriceDate$DATE',Date);
           end;
         end;
         mSSCBO.save;
         mSSCBO.Free;
         k:=k+1;
      end;
  end;
  Success := True;
  LogInfoStr := 'Records BMS: '+IntToStr(j)+'  Records ŠM: '+IntToStr(k);
end;


function API_GET(aURL:String): TJSONSuperObject;
var
  mWinHTTP: Variant;
  mRequest, mLogin: string;
  mJSON:TJSONSuperObject;
  mList:TStringList;
begin
  try
    mWinHTTP:= CreateOleObject('WinHttp.WinHttpRequest.5.1');
    mWinHTTP.Open('GET', aURL);
    mWinHTTP.SetRequestHeader('Content-Type', 'application/json');
    mWinHTTP.SetRequestHeader('Authorization','Basic '+EncodeBase64(TEncoding.UTF8.GetBytes('API:ApiHeslo')));
    mWinHTTP.Send();
    Result:=TJSONSuperObject.ParseString(mWinHTTP.ResponseText, True);
  except

  end;
end;

begin
end.