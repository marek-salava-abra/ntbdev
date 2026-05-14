procedure GetSKQ(OS: TNxCustomObjectSpace; var Success: Boolean; var LogInfoStr: String);
var
 mJSON, mJSON2:TJSONSuperObject;
 mJSONArray:TJSONSuperObjectArray;
 mDate:string;
 i,j,k:integer;
 mSSCBO:TNxCustomBusinessObject;
 mStoreCard_ID, mSSC_ID, mStore_ID:string;
begin
  mJSON:=TJSONSuperObject.Create;
  mJSON2:=TJSONSuperObject.Create;
  mJSONArray:=TJSONSuperObjectArray.Create;
   mJSON:=API_GET('http://api.abra-sk.prod.ad.lipoelastic.com:83/SK_LipoElastic/storesubcards?select=storecard_id.code as sccode, store_id.code as scode, quantity');
  mJSONArray:=mJSON.AsArray;
  j:=mJSONArray.Length;
  k:=0;
  for i:=0 to mJSONArray.Length-1 do begin
     mStoreCard_ID:=OS.SQLSelectFirstAsString('Select id from storecards where hidden=''N'' and code='+QuotedStr(mJSONArray.O[i].S['sccode']),'');
     if not(NxIsEmptyOID(mStoreCard_ID)) then begin
       mStore_ID:=OS.SQLSelectFirstAsString('Select id from stores where hidden=''N'' and code='+QuotedStr(mJSONArray.O[i].S['scode']),'');
       if not(NxIsEmptyOID(mStore_ID)) then begin
         mSSC_ID:=OS.SQLSelectFirstAsString('Select id from storesubcards where storecard_id='+QuotedStr(mStoreCard_ID)+' and store_id='+QuotedStr(mStore_ID),'');
         mSSCBO:=os.CreateObject(Class_StoreSubCard);
         if NxIsEmptyOID(mSSC_ID) then begin
           mSSCBO.New;
           mSSCBO.Prefill;
           mSSCBO.SetFieldValueAsString('StoreCard_ID',mStoreCard_ID);
           mSSCBO.SetFieldValueAsString('Store_ID',mStore_ID);
           mSSCBO.SetFieldValueAsFloat('Quantity',mJSONArray.O[i].D['quantity']);
         end else begin
           mSSCBO.Load(mSSC_ID,nil);
           mSSCBO.SetFieldValueAsFloat('Quantity',mJSONArray.O[i].D['quantity']);
         end;
         mSSCBO.save;
         mSSCBO.Free;
         k:=k+1;
       end;
      end;
  end;
  Success := True;
  LogInfoStr := 'Records SK: '+IntToStr(j)+'  Records CZ: '+IntToStr(k);
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
    mWinHTTP.SetRequestHeader('Authorization','Basic VGVzdDoxMjM=');
    mWinHTTP.Send();
    Result:=TJSONSuperObject.ParseString(mWinHTTP.ResponseText, True);
  except

  end;
end;

begin
end.