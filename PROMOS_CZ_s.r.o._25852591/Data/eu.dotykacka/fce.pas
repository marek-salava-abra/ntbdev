const
 cCloudID='354810661';
 cPassword='Michal499';
 cUserToken='bbe1baece9a4c7ff964199f2995fdfc7';
 cPrice_ID='1000000101';
 cDefaultFirm_ID='AAA1000000';
 cDivision_ID='1000000101';
 cBillOfDelivery='1B60000101';
 cEmailAccount_ID='1200000101';
 cEmailWarning='asistent@kingtony.cz';
 //cEmailWarning='marek.salava@abra.eu';

function GetToken: string;
var
  mWinHTTP: Variant;
  mJson: TJSONSuperObject;
  mToken,mRequest: string;
begin
  try
    mWinHTTP:= CreateOleObject('WinHttp.WinHttpRequest.5.1');
    mWinHTTP.Open('POST', 'https://api.dotykacka.cz/v2/signin/token');
    mWinHTTP.SetRequestHeader('Content-Type', 'application/json; charset=UTF-8');
    mWinHTTP.SetRequestHeader('Authorization', 'User '+cUserToken);
    mWinHTTP.SetRequestHeader('X-Password', cPassword);
    mRequest:= '{"_cloudId": "'+cCloudID+'"}';
    mWinHTTP.Send(mRequest);
    if mWinHTTP.Status <> 201 then begin    //kód <> 200 = dotaz vůbec neprošel
      if CFxNxRuntime.NxGetEnvironmentType = reRuntimeExe then ShowMessage('Nebylo možné vygenerovat přístupový token: ' + IntToStr(mWinHTTP.Status) +': '+ mWinHTTP.StatusText + ' '+mWinHTTP.ResponseText);
    end
    else begin
      mJson := TJSONSuperObject.ParseString(mWinHTTP.ResponseText, True);
      mToken := mJSon.S['accessToken'];
      Result:= mToken;
    end;
  except
    if CFxNxRuntime.NxGetEnvironmentType = reRuntimeExe then ShowMessage('Nastala neočekávaná chyba při získávání tokenu: '+ExceptionMessage);
  end;
end;

function API_GET(AURL:string; var AStatusCode:integer;var AStatusText, aETag: string): TJSONSuperObject;
var
  mWinHTTP: Variant;
  mToken,mRequest: string;
begin
  try
    mToken:= GetToken;
    if NxIsBlank(mToken) then
      exit;
    mWinHTTP:= CreateOleObject('WinHttp.WinHttpRequest.5.1');
    mWinHTTP.Open('GET', AURL);
    mWinHTTP.SetRequestHeader('Content-Type', 'application/json; charset=UTF-8');
    mWinHTTP.SetRequestHeader('Accept', 'application/json; charset=UTF-8');
    mWinHTTP.SetRequestHeader('Authorization', 'Bearer '+mToken);
    mWinHTTP.Send('');
    AStatusCode:= mWinHTTP.Status;
    AStatusText:= mWinHTTP.StatusText + ' '+mWinHTTP.ResponseText;
    AEtag:= mWinHTTP.getResponseHeader('etag');
    Result := TJSONSuperObject.ParseString(mWinHTTP.ResponseText, True);
  except
    if CFxNxRuntime.NxGetEnvironmentType = reRuntimeExe then ShowMessage('Při GET dotazu do Dotykačky nastala neočekávaná chyba: '+ExceptionMessage);
  end;
end;

function API_GET2(AURL:string; var AStatusCode:integer;var AStatusText: string): TJSONSuperObject;
var
  mWinHTTP: Variant;
  mToken,mRequest: string;
begin
  try
    mToken:= GetToken;
    if NxIsBlank(mToken) then
      exit;
    mWinHTTP:= CreateOleObject('WinHttp.WinHttpRequest.5.1');
    mWinHTTP.Open('GET', AURL);
    mWinHTTP.SetRequestHeader('Content-Type', 'application/json; charset=UTF-8');
    mWinHTTP.SetRequestHeader('Accept', 'application/json; charset=UTF-8');
    mWinHTTP.SetRequestHeader('Authorization', 'Bearer '+mToken);
    mWinHTTP.Send('');
    AStatusCode:= mWinHTTP.Status;
    AStatusText:= mWinHTTP.StatusText + ' '+mWinHTTP.ResponseText;
    //AEtag:= mWinHTTP.getResponseHeader('etag');
    Result := TJSONSuperObject.ParseString(mWinHTTP.ResponseText, True);
  except
    if CFxNxRuntime.NxGetEnvironmentType = reRuntimeExe then ShowMessage('Při GET dotazu do Dotykačky nastala neočekávaná chyba: '+ExceptionMessage);
  end;
end;

function API_PUT(var AURL:string; var AStatusCode:integer;var AStatusText: string;var aInputJSON:TJSONSuperObject): TJSONSuperObject;
var
  mWinHTTP: Variant;
  mToken,mRequest: string;
begin
  try
    mToken:= GetToken;
    if NxIsBlank(mToken) then
      exit;
    mWinHTTP:= CreateOleObject('WinHttp.WinHttpRequest.5.1');
    mWinHTTP.Open('PUT', AURL);
    mWinHTTP.SetRequestHeader('Content-Type', 'application/json; charset=UTF-8');
    mWinHTTP.SetRequestHeader('Accept', 'application/json; charset=UTF-8');
    mWinHTTP.SetRequestHeader('Authorization', 'Bearer '+mToken);
    mWinHTTP.Send(aInputJSON.AsJson(true));
    AStatusCode:= mWinHTTP.Status;
    AStatusText:= mWinHTTP.StatusText + ' '+mWinHTTP.ResponseText;
    //NxShowSimpleMessage(mWinHTTP.ResponseText+NxCrlf+mWinHTTP.StatusText+NxCrLf+IntToStr(AStatusCode)+nxCrLf+aInputJSON.AsString,nil);
    try
     if not(AStatusCode=409) then
      Result := TJSONSuperObject.ParseString(mWinHTTP.ResponseText, True);
    except
      //NxShowSimpleMessage(mWinHTTP.ResponseText+NxCrlf+mWinHTTP.StatusText+NxCrLf+IntToStr(AStatusCode)+nxCrLf+aInputJSON.AsString,nil);
    end;
  except
    if CFxNxRuntime.NxGetEnvironmentType = reRuntimeExe then ShowMessage('Při POST dotazu do Dotykačky nastala neočekávaná chyba: '+ExceptionMessage);
  end;
end;

function API_PATCH(var AURL:string; var AStatusCode:integer;var AStatusText: string;var aInputJSON:TJSONSuperObject; var aETag: string;): TJSONSuperObject;
var
  mWinHTTP: Variant;
  mToken,mRequest: string;
begin
  try
    mToken:= GetToken;
    if NxIsBlank(mToken) then
      exit;
    mWinHTTP:= CreateOleObject('WinHttp.WinHttpRequest.5.1');
    mWinHTTP.Open('PATCH', AURL);
    mWinHTTP.SetRequestHeader('Content-Type', 'application/json; charset=UTF-8');
    mWinHTTP.SetRequestHeader('Accept', 'application/json; charset=UTF-8');
    mWinHTTP.SetRequestHeader('Authorization', 'Bearer '+mToken);
    mWinHTTP.SetRequestHeader('If-Match',aETag);
    mWinHTTP.Send(aInputJSON.AsJson(true));
    AStatusCode:= mWinHTTP.Status;
    AStatusText:= mWinHTTP.StatusText + ' '+mWinHTTP.ResponseText;
    Result := TJSONSuperObject.ParseString(mWinHTTP.ResponseText, True);
  except
    if CFxNxRuntime.NxGetEnvironmentType = reRuntimeExe then ShowMessage('Při Patch dotazu do Dotykačky nastala neočekávaná chyba: '+ExceptionMessage);
  end;
end;

function GetAvailableQuantity(var AOS : TNxCustomObjectSpace;var aStoreCard_ID, aStore_ID:string): extended;
const
  cSQL = 'SELECT Quantity FROM StoreSubCards WHERE StoreCard_ID=''%s'' and Store_id=''%s'' ';
var
  mList : TStringList;
begin
  mList := TStringList.Create;
  try
    AOS.SQLSelect(Format(cSQL, [aStoreCard_ID, aStore_ID]), mList);
    if mList.Count > 0 then
      Result := StrToFloat(mList.Strings[0])
      else Result:=0;
  finally
    mList.Free;
  end;
end;

function ProcessJSONData(var AOS:TNxCustomObjectSpace; var mJSON:TJSONSuperObject; var mDateFrom, mDateTo:string):string;
var
 i,j,k,l :integer;
 mFirm_ID, mStoreCard_ID, mPeriod_ID, mCR_ID, mBOD_ID, mII_ID, mII2_ID:string;
 mBO, mRowBO, mBoDBO:TNxCustomBusinessObject;
 mRows:TNxCustomBusinessMonikerCollection;
 mCreated:TDateTime;
 mStorno:Boolean;
 mBody, mSklad,mSCText:string;
 mSCList, mBODList:TStringList;
 mAvalaibleQuantity:extended;
 mJSONMasterPay, mJSONPayPage:TJSONSuperObject;
 mURL, mStatusText:string;
 mStatusCode:Integer;
 mCash,mCard:Boolean;
 mResult:String;
 mCashString, mCardString:string;
 mLastPage,n:integer;
begin
  mResult:='';
  for i:= 0 to mJSON.A['data'].Length -1 do begin
   mResult:=mResult+#13#10+mJSON.A['data'].O[i].S['documentNumber'];
   mStorno:= NxCheckBit(mJSON.A['data'].O[i].I['flags'],2);
   if mStorno then mResult:=mResult+#13#10+'Doklad byl stornován';
   if not(mStorno) then begin
    if not(NxIsBlank(mJSON.A['data'].O[i].S['_customerId'])) then mFirm_ID:=GetFirm_ID(AOS,mJSON.A['data'].O[i].S['_customerId']) else mFirm_ID:=cDefaultFirm_ID;
          mCash:=False;
          mCard:=False;
          mCashString:='Ne';
          mCardString:='Ne';
        if mJSON.A['data'].O[i].B['paid'] then begin

          mURL:= 'https://api.dotykacka.cz/v2/clouds/'+cCloudID+'/money-logs?filter=created|gteq|'+mDateFrom+'000'+';created|lt|'+mDateTo+'000';
          mURL:= CFxInternet.URLEncode(mURL);
          mJSONMasterPay:= API_GET2(mURL, mStatusCode, mStatusText);
          if mStatusCode=200 then begin
            mLastPage:=StrToInt(mJSONMasterPay.S['lastPage']);
            for n:=1 to mLastPage do begin
             mURL:= 'https://api.dotykacka.cz/v2/clouds/'+cCloudID+'/money-logs?filter=created|gteq|'+mDateFrom+'000'+';created|lt|'+mDateTo+'000&page='+IntToStr(n);
             mURL:= CFxInternet.URLEncode(mURL);
             mJSONPayPage:= API_GET2(mURL, mStatusCode, mStatusText);
                for l:=0 to mJSONPayPage.A['data'].Length -1 do begin
                   if mJSON.A['data'].O[i].S['id']=mJSONPayPage.A['data'].O[l].S['_orderId'] then begin
                    mResult:=mResult+#13#10+mJSONPayPage.A['data'].O[l].S['paymentTypeId'];
                    if mJSONPayPage.A['data'].O[l].S['paymentTypeId']='900000001' then mCash:=True;
                    if mJSONPayPage.A['data'].O[l].S['paymentTypeId']='900000002' then mCard:=True;
                   end;
                end;
            end;
          end;
          if mCash then mCashString:='Ano';
          if mCard then mCardString:='Ano';
          mResult:=mResult+#13#10+'Hotově: '+mCashString+' Kartou: '+mCardString;
        end;
        mResult:=mResult+#13#10+'Result po kontrole plateb Hotově: '+mCashString+' Kartou: '+mCardString;

        if mCash then begin
          mCR_ID:=GetCR_ID(AOS, mJSON.A['data'].O[i].S['documentNumber']);
           mResult:=mResult+#13#10+'CR_ID: '+mCR_ID;
           if NxIsEmptyOID(mCR_ID) then begin
            mResult:=mResult+#13#10+'tvořím pokladnu ';
            try
             mSCText:='';
             mSCList:=TStringList.Create;
             mCreated:= mJSON.A['data'].O[i].DT8601['completed'];
             mPeriod_ID:= GetPeriod_ID(AOS,mCreated);
             mBO:=AOS.CreateObject(Class_CashReceived);
             mBO.new;
             mbo.prefill;
             mBO.SetFieldValueAsString('CashDesk_ID','1200000101');
             mBO.SetFieldValueAsString('DocQueue_ID','1500000101');
             mBO.SetFieldValueAsString('Firm_ID',mFirm_ID);
             mBO.SetFieldValueAsString('Period_ID',mPeriod_ID);
             mBO.SetFieldValueAsDateTime('DocDate$Date',mCreated);
             mBO.SetFieldValueAsString('StoreDocQueue_ID', cBillOfDelivery);
             mBO.SetFieldValueAsString('Description',mJSON.A['data'].O[i].S['documentNumber']);
             mBO.SetFieldValueAsString('X_dotykackaID',mJSON.A['data'].O[i].S['documentNumber']);
             mResult:=mResult+#13#10+' hotová hlavička';
             mRows:=mbo.GetLoadedCollectionMonikerForFieldCode(mBO.GetFieldCode('Rows'));
               for j:= 0 to mJSON.A['data'].O[i].A['orderItems'].Length -1 do begin
                 mStoreCard_ID:=GetStoreCard_ID(AOS,mJSON.A['data'].O[i].A['orderItems'].O[j].S['_productId']);
                 if not(NxIsEmptyOID(mStoreCard_ID)) and (mJSON.A['data'].O[i].A['orderItems'].O[j].D['quantity']>0) then begin
                   mRowBO:=mRows.AddNewObject;
                   mRowBO.SetFieldValueAsInteger('RowType',3);
                   if mJSON.A['data'].O[i].A['orderItems'].O[j].S['_branchId']='103080560' then mRowBO.SetFieldValueAsString('Store_ID','1100000101');
                   if mJSON.A['data'].O[i].A['orderItems'].O[j].S['_branchId']='103080560' then mBO.SetFieldValueAsString('CreatedBy_ID','1720000101');
                   if mJSON.A['data'].O[i].A['orderItems'].O[j].S['_branchId']='103657813' then mRowBO.SetFieldValueAsString('Store_ID','2100000101');
                   if mJSON.A['data'].O[i].A['orderItems'].O[j].S['_branchId']='103657813' then mBO.SetFieldValueAsString('CreatedBy_ID','2720000101');
                   mRowBO.SetFieldValueAsString('StoreCard_ID',mStoreCard_ID);
                   mRowBO.SetFieldValueAsFloat('Quantity',mJSON.A['data'].O[i].A['orderItems'].O[j].D['quantity']);
                   mRowBO.SetFieldValueAsFloat('UnitPrice',mJSON.A['data'].O[i].A['orderItems'].O[j].D['unitPriceWithoutVat']);
                   if mJSON.A['data'].O[i].A['orderItems'].O[j].D['discountPercent']>0 then begin
                    mBO.SetFieldValueAsBoolean('IsRowDiscount',True);
                    mrowBO.SetFieldValueAsFloat('RowDiscount',mJSON.A['data'].O[i].A['orderItems'].O[j].D['discountPercent']);
                   end;
                   mRowBO.SetFieldValueAsString('Division_ID',cDivision_ID);
                   if mJSON.A['data'].O[i].A['orderItems'].O[j].S['_branchId']='103080560' then mRowBO.SetFieldValueAsString('BusTransaction_ID','4000000101');
                   if mJSON.A['data'].O[i].A['orderItems'].O[j].S['_branchId']='103657813' then mRowBO.SetFieldValueAsString('BusTransaction_ID','5000000101');
                   mAvalaibleQuantity:=GetAvailableQuantity(AOS,mRowBO.GetFieldValueAsString('StoreCard_ID'),mRowBO.GetFieldValueAsString('Store_ID'));
                    if mAvalaibleQuantity<mrowbo.GetFieldValueAsFloat('Quantity') then
                   mSCList.Add(mRowBO.GetFieldValueAsString('StoreCard_ID.Code')+Chr(9)+
                               mRowBO.GetFieldValueAsString('StoreCard_ID.name')+Chr(9)+Chr(9)+
                               FloatToStrF(mAvalaibleQuantity,ffNumber,8,2)+chr(9)+chr(9)+
                               FloatToStrF(mRowBO.GetFieldValueAsFloat('Quantity'),ffNumber,8,2));


                 end else begin
                   mRowBO:=mRows.AddNewObject;
                   mRowBO.SetFieldValueAsInteger('RowType',1);
                   mRowBO.SetFieldValueAsString('Text',mJSON.A['data'].O[i].A['orderItems'].O[j].S['name']);
                   mRowBO.SetFieldValueAsFloat('TotalPrice',mJSON.A['data'].O[i].A['orderItems'].O[j].D['totalPriceWithoutVat']);
                   if mJSON.A['data'].O[i].A['orderItems'].O[j].D['discountPercent']>0 then begin
                    mBO.SetFieldValueAsBoolean('IsRowDiscount',True);
                    mrowBO.SetFieldValueAsFloat('RowDiscount',mJSON.A['data'].O[i].A['orderItems'].O[j].D['discountPercent']);
                   end;
                   mRowBO.SetFieldValueAsString('VatRate_ID','00000X0000');
                   mRowBO.SetFieldValueAsString('Division_ID',cDivision_ID);
                   if mJSON.A['data'].O[i].A['orderItems'].O[j].S['_branchId']='103080560' then mRowBO.SetFieldValueAsString('BusTransaction_ID','4000000101');
                   if mJSON.A['data'].O[i].A['orderItems'].O[j].S['_branchId']='103657813' then mRowBO.SetFieldValueAsString('BusTransaction_ID','5000000101');
                 end;
               end;
             mbo.save;
             mBODList:=TStringList.Create;
              AOS.SQLSelect(format('Select ii2.Provide_id from issuedinvoices2 ii2 where ii2.parent_id=''%s'' ',[mBO.OID]),mBODList);
              if mBODList.count>0 then begin
                mBoDBO:=AOS.CreateObject(Class_BillOfDelivery);
                mBODBO.Load(mbodlist.Strings[0],nil);
                mBOdBO.SetFieldValueAsString('PMState_ID','SDDEF00000');
                mBoDBO.SetFieldValueAsString('Createdby_ID',mBO.GetFieldValueAsString('Createdby_ID'));
                mbodbo.save;
                mbodbo.free;
              end;
             mResult:=mResult+#13#10+'Číslo dokladu: '+mbo.DisplayName;
             mbo.free;
            except
             for k:=0 to mSCList.count-1 do begin
                if k=0 then mSCText:=mSCList.Strings[k] else mSCText:=mSCText+#13#10+mSCList.Strings[k];
             end;
             if mJSON.A['data'].O[i].S['_branchId']='103080560' then mSklad:='Peugeot-Bužek';
             if mJSON.A['data'].O[i].S['_branchId']='103657813' then mSklad:='Volkswagen-Dýrr';
             mBody:='Při zpracovávání dokladu '+mJSON.A['data'].O[i].S['documentNumber']+ #13#10+
                    'na skladu '+mSklad+#13#10+
                     ' vznikla následující chyba '+#13#10+ExceptionMessage+#13#10+#13#10+'Karta'+Chr(9)+Chr(9)+Chr(9)+Chr(9)+Chr(9)+'Dostupné'+Chr(9)+Chr(9)+Chr(9)+'Vydáno'+#13#10+mSCText;
             SendInternalMail(AOS,cEmailWarning,'','','Chyba při zpracování dat z Dotykačky',mBody,'',mFirm_ID,cDivision_ID,'');
           end;
          end;
         end;
         end;
        if mCard then begin
          mII_ID:=GetII_ID(AOS, mJSON.A['data'].O[i].S['documentNumber']);
          mResult:=mResult+#13#10+'II_ID: '+mII_ID;
           if NxIsEmptyOID(mII_ID) then begin

            try
             mSCText:='';
             mSCList:=TStringList.Create;
             mCreated:= mJSON.A['data'].O[i].DT8601['completed'];
             mPeriod_ID:= GetPeriod_ID(AOS,mCreated);
             mBO:=AOS.CreateObject(Class_IssuedInvoice);
             mBO.new;
             mbo.prefill;
             mBO.SetFieldValueAsString('BankAccount_ID','1000000101');
             mBO.SetFieldValueAsString('DocQueue_ID','2B50000101');
             mBO.SetFieldValueAsString('Firm_ID',mFirm_ID);
             mBO.SetFieldValueAsString('Period_ID',mPeriod_ID);
             mBO.SetFieldValueAsDateTime('DocDate$Date',trunc(mCreated));
             mBO.SetFieldValueAsString('StoreDocQueue_ID', cBillOfDelivery);
             mBO.SetFieldValueAsInteger('TotalRounding', 0);
             mBO.SetFieldValueAsString('Description',mJSON.A['data'].O[i].S['documentNumber']);
             mBO.SetFieldValueAsString('X_dotykackaID',mJSON.A['data'].O[i].S['documentNumber']);
             mRows:=mbo.GetLoadedCollectionMonikerForFieldCode(mBO.GetFieldCode('Rows'));
               for j:= 0 to mJSON.A['data'].O[i].A['orderItems'].Length -1 do begin
                 mStoreCard_ID:=GetStoreCard_ID(AOS,mJSON.A['data'].O[i].A['orderItems'].O[j].S['_productId']);
                 if not(NxIsEmptyOID(mStoreCard_ID)) and (mJSON.A['data'].O[i].A['orderItems'].O[j].D['quantity']>0) then begin
                   mRowBO:=mRows.AddNewObject;
                   mRowBO.SetFieldValueAsInteger('RowType',3);
                   if mJSON.A['data'].O[i].A['orderItems'].O[j].S['_branchId']='103080560' then mRowBO.SetFieldValueAsString('Store_ID','1100000101');
                   if mJSON.A['data'].O[i].A['orderItems'].O[j].S['_branchId']='103080560' then mBO.SetFieldValueAsString('CreatedBy_ID','1720000101');
                   if mJSON.A['data'].O[i].A['orderItems'].O[j].S['_branchId']='103657813' then mRowBO.SetFieldValueAsString('Store_ID','2100000101');
                   if mJSON.A['data'].O[i].A['orderItems'].O[j].S['_branchId']='103657813' then mBO.SetFieldValueAsString('CreatedBy_ID','2720000101');
                   mRowBO.SetFieldValueAsString('StoreCard_ID',mStoreCard_ID);
                   mRowBO.SetFieldValueAsFloat('Quantity',mJSON.A['data'].O[i].A['orderItems'].O[j].D['quantity']);
                   mRowBO.SetFieldValueAsFloat('UnitPrice',mJSON.A['data'].O[i].A['orderItems'].O[j].D['unitPriceWithoutVat']);
                   mRowBO.SetFieldValueAsString('Division_ID',cDivision_ID);
                   if mJSON.A['data'].O[i].A['orderItems'].O[j].D['discountPercent']>0 then begin
                    mBO.SetFieldValueAsBoolean('IsRowDiscount',True);
                    mrowBO.SetFieldValueAsFloat('RowDiscount',mJSON.A['data'].O[i].A['orderItems'].O[j].D['discountPercent']);
                   end;
                   if mJSON.A['data'].O[i].A['orderItems'].O[j].S['_branchId']='103080560' then mRowBO.SetFieldValueAsString('BusTransaction_ID','4000000101');
                   if mJSON.A['data'].O[i].A['orderItems'].O[j].S['_branchId']='103657813' then mRowBO.SetFieldValueAsString('BusTransaction_ID','5000000101');
                   mAvalaibleQuantity:=GetAvailableQuantity(AOS,mRowBO.GetFieldValueAsString('StoreCard_ID'),mRowBO.GetFieldValueAsString('Store_ID'));
                   if mAvalaibleQuantity<mrowbo.GetFieldValueAsFloat('Quantity') then
                   mSCList.Add(mRowBO.GetFieldValueAsString('StoreCard_ID.Code')+Chr(9)+
                               mRowBO.GetFieldValueAsString('StoreCard_ID.name')+Chr(9)+Chr(9)+
                               FloatToStrF(mAvalaibleQuantity,ffNumber,8,2)+chr(9)+chr(9)+
                               FloatToStrF(mRowBO.GetFieldValueAsFloat('Quantity'),ffNumber,8,2));


                 end else begin
                   mRowBO:=mRows.AddNewObject;
                   mRowBO.SetFieldValueAsInteger('RowType',1);
                   mRowBO.SetFieldValueAsString('Text',mJSON.A['data'].O[i].A['orderItems'].O[j].S['name']);
                   mRowBO.SetFieldValueAsFloat('TotalPrice',mJSON.A['data'].O[i].A['orderItems'].O[j].D['totalPriceWithoutVat']);
                   mRowBO.SetFieldValueAsString('VatRate_ID','00000X0000');
                   mRowBO.SetFieldValueAsString('Division_ID',cDivision_ID);
                   if mJSON.A['data'].O[i].A['orderItems'].O[j].S['_branchId']='103080560' then mRowBO.SetFieldValueAsString('BusTransaction_ID','4000000101');
                   if mJSON.A['data'].O[i].A['orderItems'].O[j].S['_branchId']='103657813' then mRowBO.SetFieldValueAsString('BusTransaction_ID','5000000101');
                 end;
               end;
             mbo.save;
              mBODList:=TStringList.Create;
              AOS.SQLSelect(format('Select ii2.Provide_id from issuedinvoices2 ii2 where ii2.parent_id=''%s'' ',[mBO.OID]),mBODList);
              if mBODList.count>0 then begin
                mBoDBO:=AOS.CreateObject(Class_BillOfDelivery);
                mBODBO.Load(mbodlist.Strings[0],nil);
                mBOdBO.SetFieldValueAsString('PMState_ID','SDDEF00000');
                mBoDBO.SetFieldValueAsString('Createdby_ID',mBO.GetFieldValueAsString('Createdby_ID'));
                mbodbo.save;
                mbodbo.free;
              end;
             mbo.free;
            except
             for k:=0 to mSCList.count-1 do begin
                if k=0 then mSCText:=mSCList.Strings[k] else mSCText:=mSCText+#13#10+mSCList.Strings[k];
             end;
             if mJSON.A['data'].O[i].S['_branchId']='103080560' then mSklad:='Peugeot-Bužek';
             if mJSON.A['data'].O[i].S['_branchId']='103657813' then mSklad:='Volkswagen-Dýrr';
             mBody:='Při zpracovávání dokladu '+mJSON.A['data'].O[i].S['documentNumber']+ #13#10+
                    'na skladu '+mSklad+#13#10+
                     ' vznikla následující chyba '+#13#10+ExceptionMessage+#13#10+#13#10+'Karta'+Chr(9)+Chr(9)+Chr(9)+Chr(9)+Chr(9)+'Dostupné'+Chr(9)+Chr(9)+Chr(9)+'Vydáno'+#13#10+mSCText;
             SendInternalMail(AOS,cEmailWarning,'','','Chyba při zpracování dat z Dotykačky',mBody,'',mFirm_ID,cDivision_ID,'');
           end;
          end;
         end;

        mResult:=mResult+#13#10+'Result řádek 377 Hotově: '+mCashString+' Kartou: '+mCardString;
        if not(mCash or mCard) then begin
         mII2_ID:=GetII_ID(AOS, mJSON.A['data'].O[i].S['documentNumber']);
           mResult:=mResult+#13#10+'II2_ID: '+mII2_ID;
           if NxIsEmptyOID(mII2_ID) then begin
            try
             mSCText:='';
             mSCList:=TStringList.Create;
             mCreated:= mJSON.A['data'].O[i].DT8601['completed'];
             mPeriod_ID:= GetPeriod_ID(AOS,mCreated);
             mBO:=AOS.CreateObject(Class_IssuedInvoice);
             mBO.new;
             mbo.prefill;
             mBO.SetFieldValueAsString('BankAccount_ID','1000000101');
             mBO.SetFieldValueAsString('DocQueue_ID','4000000101');
             mBO.SetFieldValueAsString('Firm_ID',mFirm_ID);
             mBO.SetFieldValueAsString('Period_ID',mPeriod_ID);
             mBO.SetFieldValueAsDateTime('DocDate$Date',trunc(mCreated));
             mBO.SetFieldValueAsString('StoreDocQueue_ID', cBillOfDelivery);
             mBO.SetFieldValueAsInteger('TotalRounding', 0);
             mBO.SetFieldValueAsString('PaymentType_ID','1000000101');
             mBO.SetFieldValueAsString('TransportationType_ID','00000V1000');
             mBO.SetFieldValueAsString('Description',mJSON.A['data'].O[i].S['documentNumber']);
             mBO.SetFieldValueAsString('X_dotykackaID',mJSON.A['data'].O[i].S['documentNumber']);
             mRows:=mbo.GetLoadedCollectionMonikerForFieldCode(mBO.GetFieldCode('Rows'));
               for j:= 0 to mJSON.A['data'].O[i].A['orderItems'].Length -1 do begin
                 mStoreCard_ID:=GetStoreCard_ID(AOS,mJSON.A['data'].O[i].A['orderItems'].O[j].S['_productId']);
                 if not(NxIsEmptyOID(mStoreCard_ID)) and (mJSON.A['data'].O[i].A['orderItems'].O[j].D['quantity']>0) then begin
                   mRowBO:=mRows.AddNewObject;
                   mRowBO.SetFieldValueAsInteger('RowType',3);
                   if mJSON.A['data'].O[i].A['orderItems'].O[j].S['_branchId']='103080560' then mRowBO.SetFieldValueAsString('Store_ID','1100000101');
                   if mJSON.A['data'].O[i].A['orderItems'].O[j].S['_branchId']='103080560' then mBO.SetFieldValueAsString('CreatedBy_ID','1720000101');
                   if mJSON.A['data'].O[i].A['orderItems'].O[j].S['_branchId']='103657813' then mRowBO.SetFieldValueAsString('Store_ID','2100000101');
                   if mJSON.A['data'].O[i].A['orderItems'].O[j].S['_branchId']='103657813' then mBO.SetFieldValueAsString('CreatedBy_ID','2720000101');
                   mRowBO.SetFieldValueAsString('StoreCard_ID',mStoreCard_ID);
                   mRowBO.SetFieldValueAsFloat('Quantity',mJSON.A['data'].O[i].A['orderItems'].O[j].D['quantity']);
                   mRowBO.SetFieldValueAsString('Division_ID',cDivision_ID);
                   if mJSON.A['data'].O[i].A['orderItems'].O[j].S['_branchId']='103080560' then mRowBO.SetFieldValueAsString('BusTransaction_ID','4000000101');
                   if mJSON.A['data'].O[i].A['orderItems'].O[j].S['_branchId']='103657813' then mRowBO.SetFieldValueAsString('BusTransaction_ID','5000000101');
                   mAvalaibleQuantity:=GetAvailableQuantity(AOS,mRowBO.GetFieldValueAsString('StoreCard_ID'),mRowBO.GetFieldValueAsString('Store_ID'));
                    if mAvalaibleQuantity<mrowbo.GetFieldValueAsFloat('Quantity') then
                   mSCList.Add(mRowBO.GetFieldValueAsString('StoreCard_ID.Code')+Chr(9)+
                               mRowBO.GetFieldValueAsString('StoreCard_ID.name')+Chr(9)+Chr(9)+
                               FloatToStrF(mAvalaibleQuantity,ffNumber,8,2)+chr(9)+chr(9)+
                               FloatToStrF(mRowBO.GetFieldValueAsFloat('Quantity'),ffNumber,8,2));
                 end;
               end;
             mbo.save;
             mBODList:=TStringList.Create;
              AOS.SQLSelect(format('Select ii2.Provide_id from issuedinvoices2 ii2 where ii2.parent_id=''%s'' ',[mBO.OID]),mBODList);
              if mBODList.count>0 then begin
                mBoDBO:=AOS.CreateObject(Class_BillOfDelivery);
                mBODBO.Load(mbodlist.Strings[0],nil);
                mBOdBO.SetFieldValueAsString('PMState_ID','SDDEF00000');
                mBoDBO.SetFieldValueAsString('Createdby_ID',mBO.GetFieldValueAsString('Createdby_ID'));
                mbodbo.save;
                mbodbo.free;
              end;
             mbo.free;
            except
              for k:=0 to mSCList.count-1 do begin
                if k=0 then mSCText:=mSCList.Strings[k] else mSCText:=mSCText+#13#10+mSCList.Strings[k];
             end;
             if mJSON.A['data'].O[i].S['_branchId']='103080560' then mSklad:='Peugeot-Bužek';
             if mJSON.A['data'].O[i].S['_branchId']='103657813' then mSklad:='Volkswagen-Dýrr';
             mBody:='Při zpracovávání dokladu '+mJSON.A['data'].O[i].S['documentNumber']+ #13#10+
                    'na skladu '+mSklad+#13#10+
                     ' vznikla následující chyba '+#13#10+ExceptionMessage+#13#10+#13#10+'Karta'+Chr(9)+Chr(9)+Chr(9)+Chr(9)+Chr(9)+'Dostupné'+Chr(9)+Chr(9)+Chr(9)+'Vydáno'+#13#10+mSCText;
             SendInternalMail(AOS,cEmailWarning,'','','Chyba při zpracování dat z Dotykačky',mBody,'',mFirm_ID,cDivision_ID,'');
            end;
           end;
        end;
       end;
  Result:=mResult;
end;


Procedure CreateOrUpdateStoreCard(var aBO:TNxCustomBusinessObject;);
var
 mJSON:TJSONSuperObject;
 mResponseJSON:TJSONSuperObject;
 mJSONInput:TJSONSuperObject;
 mETag, mURL, mGenID:string;
 mStatusCode:integer;
 mStatusText:string;
 mDate, mPrice:extended;
begin
       mJSON:=TJSONSuperObject.Create;
       if not(NxIsBlank(abo.GetFieldValueAsString('X_ProductID'))) then begin
         mGenID:= abo.GetFieldValueAsString('X_ProductID');
         mURL:='https://api.dotykacka.cz/v2/clouds/'+cCloudID+'/products/'+mGenID;
         mURL:=CFxInternet.URLEncode(mURL);
         mETag:='';
         mResponseJSON:=API_Get(mURL, mStatusCode,mStatusText,mETag);
         //NxShowSimpleMessage('B'+mResponseJSON.AsString,nil);
         end else begin
         mDate:=Now+0.0001;
         mGenID:=NxSearchReplace(FloatToStr(mdate),',','',[srAll]);
       end;
       mPrice:=NxEvalObjectExprAsFloatDef(aBO,'NxGetStoreCardUnitPriceDef('+Quotedstr('')+', '+Quotedstr('')+', ' + QuotedStr(aBO.OID) + ','+Quotedstr(cPrice_ID)+', '+Quotedstr(abo.GetFieldValueAsString('MainUnitCode'))+',false,'+QuotedStr('0000CZK000')+','+inttostr(trunc(Date))+')',0);
       mJSON.D['_categoryId']:=0;
       mJSON.I['_cloudId']:=StrToInt(cCloudID);
       mJSON.B['deleted']:=false;
       mJSON.D['discountPercent']:=0;
       mJSON.B['discountPermitted']:=true;
       //mJSON.B['display']:=true;
       mJSON.B['display']:=not(abo.GetFieldValueAsBoolean('X_HideDotykacka'));
       mJSON.I['flags']:=0;
       mJSON.S['hexColor']:='#B81321';
       mJSON.D['id']:=StrToFloat(mGenID);
       mJSON.S['name']:=aBO.GetFieldValueAsString('Name');
       mJSON.B['onSale']:=true;
       mJSON.D['packaging']:=1;
       mJSON.D['points']:=0;
       mJSON.D['priceWithoutVat']:=mPrice;
       mJSON.B['requiresPriceEntry']:=false;
       mjSON.B['stockDeduct']:=False;
       mJSON.S['stockOverdraft']:='ALLOW';
       mJSON.S['unit']:='Piece';
       mJSON.D['vat']:=(100+abo.GetFieldValueAsFloat('VatRate'))/100;
       mJSON.DT8601['versionDate']:=Now;
       // konec povinných polí
       mJSON.S['subtitle']:=aBO.GetFieldValueAsString('code');

       mJSON.S['externalId']:=aBO.OID;
       if not(NxIsBlank(abo.GetFieldValueAsString('Code'))) then begin
         mJSON.O['plu']:=mJSON.CreateJSONArray;
         mJSON.A['plu'].S[0]:=abo.GetFieldValueAsString('Code');
       end;
       if not(NxIsBlank(abo.GetFieldValueAsString('EAN'))) then begin
         mJSON.O['ean']:=mJSON.CreateJSONArray;
         mJSON.A['ean'].S[0]:=abo.GetFieldValueAsString('EAN');
       end;
       //NxShowSimpleMessage(mJSON.AsString,nil);
       mURL:='https://api.dotykacka.cz/v2/clouds/'+cCloudID+'/products/'+mGenID;
       mURL:=CFxInternet.URLEncode(mURL);
       if NxIsBlank(abo.GetFieldValueAsString('X_ProductID')) then  mResponseJSON:=API_PUT(murl, mStatusCode, mStatusText, mJSON);
       if not(NxIsBlank(abo.GetFieldValueAsString('X_ProductID'))) then  mResponseJSON:=API_PATCH(murl, mStatusCode, mStatusText, mJSON,mETag);
       mJSON.free;
       //NxShowSimpleMessage(mResponseJSON.AsString+' '+mStatusText,nil);
       if NxIsBlank(abo.GetFieldValueAsString('X_ProductID')) then begin
          abo.SetFieldValueAsString('X_ProductID', mResponseJSON.S['id']);
          abo.save;
       end;


end;

Procedure CreateOrUpdateFirm(var aBO:TNxCustomBusinessObject;);
var
 mJSON:TJSONSuperObject;
 mResponseJSON:TJSONSuperObject;
 mJSONInput:TJSONSuperObject;
 mETag, mURL, mGenID:string;
 mStatusCode:integer;
 mStatusText:string;
 mDate, mPrice:extended;
begin
       mJSON:=TJSONSuperObject.Create;
       if not(NxIsBlank(abo.GetFieldValueAsString('X_CustomerID'))) then begin
         mGenID:= abo.GetFieldValueAsString('X_CustomerID');
         mURL:='https://api.dotykacka.cz/v2/clouds/'+cCloudID+'/customers/'+mGenID;
         mURL:=CFxInternet.URLEncode(mURL);
         mETag:='';
         mResponseJSON:=API_Get(mURL, mStatusCode,mStatusText,mETag);
         end else begin
         mDate:=Now+0.0001;
         mGenID:=NxSearchReplace(FloatToStr(mdate),',','',[srAll]);
       end;
       mJSON.I['_cloudId']:=StrToInt(cCloudID);
       mJSON.S['addressLine1']:=aBO.GetFieldValueAsString('ResidenceAddress_ID.Street');
       mJSON.S['addressLine2']:=aBO.GetFieldValueAsString('ResidenceAddress_ID.City');
       mJSON.S['barcode']:='';
       mJSON.S['city']:=aBO.GetFieldValueAsString('ResidenceAddress_ID.City');
       mJSON.S['companyId']:=aBO.GetFieldValueAsString('OrgIdentNumber');
       mJSON.S['companyName']:=aBO.GetFieldValueAsString('Name');
       mJSON.B['deleted']:=false;
       mJSON.B['display']:=not(abo.GetFieldValueAsBoolean('X_HideDotykacka'));
       mJSON.S['email']:=aBO.GetFieldValueAsString('ResidenceAddress_ID.Email');
       mJSON.S['externalId']:=abo.oid;
       mJSON.S['firstName']:=aBO.GetFieldValueAsString('Name');
       mJSON.D['flags']:=0;
       mJSON.S['headerPrint']:='';
       mJSON.S['hexColor']:='#B81321';
       mJSON.D['id']:=StrToFloat(mGenID);
       mJSON.S['internalNote']:='';//aBO.GetFieldValueAsString('Note');
       mJSON.S['lastName']:='';
       mJSON.S['phone']:=aBO.GetFieldValueAsString('ResidenceAddress_ID.PhoneNumber1');
       mJSON.D['points']:=0;
       mJSON.O['tags']:=mJSON.CreateJSONArray;
       mJSON.A['tags'].S[0]:='900000001';
       mJSON.S['vatId']:=aBO.GetFieldValueAsString('VATIdentNumber');
       mJSON.DT8601['versionDate']:=Now;
       mJSON.S['zip']:=aBO.GetFieldValueAsString('ResidenceAddress_ID.PostCode');
       // konec povinných polí



       mURL:='https://api.dotykacka.cz/v2/clouds/'+cCloudID+'/customers/'+mGenID;
       mURL:=CFxInternet.URLEncode(mURL);
       if NxIsBlank(abo.GetFieldValueAsString('X_CustomerID')) then  mResponseJSON:=API_PUT(murl, mStatusCode, mStatusText, mJSON);
       if not(NxIsBlank(abo.GetFieldValueAsString('X_CustomerID'))) then  mResponseJSON:=API_PATCH(murl, mStatusCode, mStatusText, mJSON,mETag);
       //NxShowSimpleMessage(mResponseJSON.AsString,nil);
       mJSON.free;
       if NxIsBlank(abo.GetFieldValueAsString('X_CustomerID')) then begin
          abo.SetFieldValueAsString('X_CustomerID', mResponseJSON.S['id']);
          abo.save;
       end;


end;

function GetFirm_ID(AOS : TNxCustomObjectSpace; ACode: string) : string;
const
  cSQL = 'SELECT ID from Firms where X_CustomerID=''%s'' and hidden=''N''';
var
  mList : TStringList;
begin
  mList := TStringList.create;
  Result:=cDefaultFirm_ID;
  try
    NxScriptingLog.WriteEventFmt(logDebug, cSQL, [ACode]);
    AOS.SQLSelect(Format(cSQL,  [ACode]), mList);
    if mList.Count > 0 then
      Result := mList.Strings[0]
  finally
    mList.Free;
  end;
end;

function GetCR_ID(AOS : TNxCustomObjectSpace; ACode: string) : string;
const
  cSQL = 'SELECT ID from CashReceived where X_dotykackaID=''%s'' ';
var
  mList : TStringList;
begin
  mList := TStringList.create;
  Result:='';
  try
    NxScriptingLog.WriteEventFmt(logDebug, cSQL, [ACode]);
    AOS.SQLSelect(Format(cSQL,  [ACode]), mList);
    if mList.Count > 0 then
      Result := mList.Strings[0]
  finally
    mList.Free;
  end;
end;

function GetII_ID(AOS : TNxCustomObjectSpace; ACode: string) : string;
const
  cSQL = 'SELECT ID from IssuedInvoices where X_dotykackaID=''%s'' ';
var
  mList : TStringList;
begin
  mList := TStringList.create;
  Result:='';
  try
    NxScriptingLog.WriteEventFmt(logDebug, cSQL, [ACode]);
    AOS.SQLSelect(Format(cSQL,  [ACode]), mList);
    if mList.Count > 0 then
      Result := mList.Strings[0]
  finally
    mList.Free;
  end;
end;

function GetBOD_ID(AOS : TNxCustomObjectSpace; ACode: string) : string;
const
  cSQL = 'SELECT ID from StoreDocuments where X_dotykackaID=''%s'' ';
var
  mList : TStringList;
begin
  mList := TStringList.create;
  Result:='';
  try
    NxScriptingLog.WriteEventFmt(logDebug, cSQL, [ACode]);
    AOS.SQLSelect(Format(cSQL,  [ACode]), mList);
    if mList.Count > 0 then
      Result := mList.Strings[0]
  finally
    mList.Free;
  end;
end;

function GetPeriod_ID(AOS: TNxCustomObjectSpace; ADate: TDate): string;
var
  mList: TStringList;
begin
  Result:='';
  mList:=TStringList.Create;
  AOS.SQLSelect('Select P.ID from Periods P '+
                        'where '+FloatToStr(DateOf(ADate))+' between P.DateFrom$DATE and P.DateTo$DATE', mList);
  if mList.Count>0 then begin
    Result:=mList.Strings(0);
  end;
end;

function GetStoreCard_ID(AOS : TNxCustomObjectSpace; ACode: string) : string;
const
  cSQL = 'SELECT ID from StoreCards where X_ProductID=''%s'' and hidden=''N''';
var
  mList : TStringList;
begin
  mList := TStringList.create;
  Result:='';
  try
    NxScriptingLog.WriteEventFmt(logDebug, cSQL, [ACode]);
    AOS.SQLSelect(Format(cSQL,  [ACode]), mList);
    if mList.Count > 0 then
      Result := mList.Strings[0]
  finally
    mList.Free;
  end;
end;

procedure SendInternalMail(AOS:TNxCustomObjectSpace; ATo:String; ACC:String; ABCC:String;
                           ASubject:String; ABody:String; AAtachement:String; AFirm_ID:String; ADivision_ID:String; ABusTransaction_ID:String);
Var
  mMailBO:TNxCustomBusinessObject;
  mMRecipients:TNxCustomBusinessMonikerCollection;
  mMailRecipient:TNxCustomBusinessObject;
begin
  if not(ato='') then begin
     mMailBO:=AOS.CreateObject(Class_EmailSent);
     mMailBO.New;
     mMailBO.Prefill;
     mMailBO.SetFieldValueAsString('EmailAccount_ID', cEmailAccount_ID);
     mMailBO.SetFieldValueAsString('Subject',ASubject);
     mMailBO.SetFieldValueAsString('BodySavedAs','0');
     mMailbo.SetFieldValueAsInteger('SentState',1);
     mMailBO.SetFieldValueAsString('Body',ABody);
     mMailBO.SetFieldValueAsString('Firm_ID',AFirm_ID);
     mMailBO.SetFieldValueAsString('Division_ID',ADivision_ID);
     mMailBO.SetFieldValueAsString('BusTransaction_ID',ABusTransaction_ID);
     mMRecipients:=mMailBO.GetCollectionMonikerForFieldCode(mMailBO.GetFieldCode('Recipients'));

     mMailRecipient:=mMRecipients.AddNewObject;
     mMailRecipient.SetFieldValueAsString('Email',ATo);
     mMailRecipient.SetFieldValueAsInteger('EmailType',0);
     if not(acc='') then begin
     mMailRecipient:=mMRecipients.AddNewObject;
     mMailRecipient.SetFieldValueAsString('Email',ACC);
     mMailRecipient.SetFieldValueAsInteger('EmailType',1);
     end;
     if not(ABCC='') then begin
     mMailRecipient:=mMRecipients.AddNewObject;
     mMailRecipient.SetFieldValueAsString('Email',ABCC);
     mMailRecipient.SetFieldValueAsInteger('EmailType',2);
     end;

     if not(AAtachement='') then begin
      TNxEmailSent(mMailBO).AttachFile(AAtachement);

     end;



     mMailBO.Save;
     mMailBO.free;

  end;
end;


begin
end.