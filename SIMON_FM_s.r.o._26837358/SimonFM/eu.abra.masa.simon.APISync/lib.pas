procedure GetKingTonyQ(OS: TNxCustomObjectSpace; var Success: Boolean; var LogInfoStr: String);
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
  if mTime<(1/24) then os.SQLExecute('update storesubcards set quantity=0 where store_id='+QuotedStr('5R10000101'));
  mJSON:=TJSONSuperObject.Create;
  mJSON2:=TJSONSuperObject.Create;
  mJSONArray:=TJSONSuperObjectArray.Create;
   mJSON:=API_GET('https://api.kingtony.cz/data/StoreSubcards?Select=StoreCard_ID.Code as code,Quantity&where=(Store_ID eq '+
                    QuotedStr('1000000101')+') and storecard_id in (class storecards select id where ((StoreAssortmentGroup_ID eq '+
                    QuotedStr('1000000101')+') or (StoreAssortmentGroup_ID eq '+QuotedStr('1100000101')+')))');
  //CFxLog.SaveLog(NxCreateContext(OS),'ERR','GetKingtony',mJSON.AsString,2,Now);
  //(Store_ID eq '1000000101') or (Store_ID eq '1420000101')
  mJSONArray:=mJSON.AsArray;
  j:=mJSONArray.Length;
  k:=0;
  for i:=0 to mJSONArray.Length-1 do begin
     mStoreCard_ID:=OS.SQLSelectFirstAsString('Select id from storecards where hidden=''N'' and code='+QuotedStr(mJSONArray.O[i].S['code']),'');
     if not(NxIsEmptyOID(mStoreCard_ID)) then begin
         mSSC_ID:=OS.SQLSelectFirstAsString('Select id from storesubcards where storecard_id='+QuotedStr(mStoreCard_ID)+' and store_id='+QuotedStr('5R10000101'),'');
         mSSCBO:=os.CreateObject(Class_StoreSubCard);
         if NxIsEmptyOID(mSSC_ID) then begin
           mSSCBO.New;
           mSSCBO.Prefill;
           mSSCBO.SetFieldValueAsString('StoreCard_ID',mStoreCard_ID);
           mSSCBO.SetFieldValueAsString('Store_ID','5R10000101');
           mSSCBO.SetFieldValueAsFloat('Quantity',mJSONArray.O[i].D['Quantity']);
         end else begin
           mSSCBO.Load(mSSC_ID,nil);
           mSSCBO.SetFieldValueAsFloat('Quantity',mJSONArray.O[i].D['Quantity']);
         end;
         mSSCBO.save;
         mSSCBO.Free;
         k:=k+1;
      end;
  end;
  Success := True;
  LogInfoStr := 'Records KT: '+IntToStr(j)+'  Records Simon: '+IntToStr(k);
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
    mWinHTTP.SetRequestHeader('Authorization','Basic V2ViQVBJOlV6Ry0yaXUzX1IzOFUtNnpQbw==');
    mWinHTTP.Send();
    Result:=TJSONSuperObject.ParseString(mWinHTTP.ResponseText, True);
  except

  end;
end;

begin
end.