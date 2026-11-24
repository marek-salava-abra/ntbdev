const
 cURLGoPay = 'https://gate.gopay.cz/api';
 cMQ_RO_DocQueue_ID_OPDS = '~S00000F01';

procedure GetStatement(OS: TNxCustomObjectSpace; var Success: Boolean; var LogInfoStr: String);
var
  mHorizontalSplitter, mToken: string;
  mList, mLogs: TStringList;
  mPostJSON: TJSONSuperObject;
  mWinHTTP: Variant;
  mStream: TMemoryStream;
  mDateTo, mDateFrom:Extended;
  l:integer;
begin
  mHorizontalSplitter := GetHorizontalSplitter(50);
  mToken := GetToken(OS);
  mList := TStringList.Create;
  mLogs := TStringList.Create;
  mLogs.Add(mHorizontalSplitter);
  mLogs.Add(DateTimeToStr(Now) + ' Start of action');
  mLogs.Add(mHorizontalSplitter);
  mLogs.Add(mToken);
   for l:=trunc(date) to trunc(date) do begin
   //for l:=46346 to trunc(date)-1 do begin
      mDateFrom:=l;
      mDateTo:=l;
      mPostJSON := TJSONSuperObject.Create;
      try
        mPostJSON.S['date_from'] := FormatDateTime('YYYY-MM-DD', mDateFrom);
        mPostJSON.S['date_to'] := FormatDateTime('YYYY-MM-DD', mDateTo);
        mPostJSON.S['goid'] := '8306609223';
        mPostJSON.S['currency'] := 'CZK';
        mPostJSON.S['format'] := 'CSV_A';

        mWinHTTP := CreateOleObject('WinHttp.WinHttpRequest.5.1');
        mWinHTTP.Open('POST', cURLGoPay + '/accounts/account-statement');
        mWinHTTP.SetRequestHeader('Content-Type', 'application/json');
        mWinHTTP.SetRequestHeader('Accept', 'application/octet-stream');
        mWinHTTP.SetRequestHeader('Authorization', 'Bearer ' + mToken);
        mWinHTTP.Send(mPostJSON.AsJson);

        mStream := TMemoryStream.Create;
        try
          mStream.SetBytes(mWinHTTP.ResponseBody);
          mStream.Position := 0;
          mList.LoadFromStream(mStream);
          if mList.Count>1 then CreateStatement(OS, mList, mDateTo,'~000000B01');
          mLogs.add('Zpracovávané datum: '+DateToStr(mDateTo)+' počet operací: '+IntToStr(mList.Count-1));
        finally
          mStream.Free;
        end;
      finally
        mPostJSON.Free;
      end;
    end;
  mLogs.Add(mHorizontalSplitter);
  mLogs.Add(DateTimeToStr(Now) + ' End of action');
  mLogs.Add(mHorizontalSplitter);
  Success := True;
  LogInfoStr := '' + NxCrLf + mLogs.Text;
end;

function CreateStatement(Var aOS:TNxCustomObjectSpace; var aList:TStringList; var aDate:Extended; var aBankAccount_ID:string):boolean;
var
 i, j:integer;
 mBO, mRowBO, mExternalIDBO, mLogBO:TNxCustomBusinessObject;
 mRows, mExternalIDs:TNxCustomBusinessMonikerCollection;
 mRowList, mLogs:TStringList;
 mIDPohybu, mVarSymbol, mDefaultFirm_ID, mTyp, mAccountText, mBankStatement_ID, mBSRow_ID, mText, mZLV_ID, mLog_ID:String;
 mDate, mAmount:Extended;
begin
 mDefaultFirm_ID:=aOS.SQLSelectFirstAsString('Select id from firms where hidden=''N'' and  firm_id is null and orgidentnumber='+Quotedstr('26730804'),'');
 mRowList:=TStringList.create;
 mRowList.Delimiter:=';';
 mLogs:=TStringList.Create;
 mBankStatement_ID:=aOS.SQLSelectFirstAsString('Select id from bankstatements where BankAccount_id='+QuotedStr(aBankAccount_ID)+' and docdate$date='+IntToStr(Trunc(aDate)),'');
 mBO:=aOS.CreateObject(Class_BankStatement);
 if NxIsEmptyOID(mBankStatement_ID) then begin
  mBO.new;
  mBO.Prefill;
  mBO.SetFieldValueAsString('BankAccount_ID',aBankAccount_ID);
  mBO.SetFieldValueAsDateTime('DocDate$Date', aDate);
 end else mBO.Load(mBankStatement_ID);
 mRows:=mBO.GetLoadedCollectionMonikerForFieldCode(mBO.GetFieldCode('Rows'));
 for i:=1 to aList.count-1 do begin
    mRowList.Clear;
    mRowList.DelimitedText:=aList.Strings[i];
    mIDPohybu:=NxSearchReplace(mRowList.Strings[0],'"','',[srAll]);
    mDate:=ISODateTimeToDateTime(NxSearchReplace(mRowList.Strings[1],'"','',[srAll]));
    mTyp:=NxSearchReplace(mRowList.Strings[2],'"','',[srAll]);
    mAccountText:=NxSearchReplace(mRowList.Strings[3],'"','',[srAll]);
    mVarSymbol:=NxSearchReplace(mRowList.Strings[4],'"','',[srAll]);
    mAmount:=NxIBStrToFloat(NxSearchReplace(mRowList.Strings[5],'"','',[srAll]));
    mBSRow_ID:=aOS.SQLSelectFirstAsString('Select bs2.id from bankstatements2 bs2 join BankStatementRowEIDS bseid on bs2.id=bseid.parent_id where bseid.ExternalID='
                                          +QuotedStr(mIDPohybu)+' and bs2.parent_id='+QuotedStr(mBankStatement_ID),'');
    if not(mAmount=0) and NxIsEmptyOID(mBSRow_ID) then begin
       mRowBO:=mRows.AddNewObject;
       mRowBO.Prefill;
       if mAmount>0 then
       mRowBO.SetFieldValueAsBoolean('Credit',true) else mRowBO.SetFieldValueAsBoolean('Credit',false);
       mRowBO.SetFieldValueAsString('Division_ID',mbo.GetFieldValueAsString('BankAccount_ID.Division_ID'));
       if mAmount>0 then
       mRowBO.SetFieldValueAsFloat('Amount',mAmount) else mRowBO.SetFieldValueAsFloat('Amount',-mAmount);
       mRowBO.SetFieldValueAsString('VarSymbol',mVarSymbol);
       mRowBO.SetFieldValueAsString('BankAccount', AnsiLeftStr(mAccountText,42));
       mRowBO.SetFieldValueAsString('Text', mTyp+' '+mIDPohybu);
       mRowBO.SetFieldValueAsDateTime('DocDate$DATE',mDate);
       mExternalIDs:=mRowBO.GetLoadedCollectionMonikerForFieldCode(mRowBO.GetFieldCode('ExternalIDs'));
       mExternalIDBO:=mExternalIDs.AddNewObject;
       mExternalIDBO.Prefill;
       mExternalIDBO.SetFieldValueAsString('ExternalID', mIDPohybu);
       if NxIsEmptyOID(mRowBO.GetFieldValueAsString('Firm_ID')) then mRowBO.SetFieldValueAsString('Firm_ID',mDefaultFirm_ID);
       mText:='nový';
    end else begin
       mText:='existující';
       for j:=0 to mRows.count-1 do begin
         mRowBO:=mRows.BusinessObject[j];
         if mRowBO.OID=mBSRow_ID then begin
           if NxIsEmptyOID(mRowBO.GetFieldValueAsString('PDocument_ID')) then begin
             mZLV_ID:=aOS.SQLSelectFirstAsString('Select id from issueddinvoices where paidamount=0 and varsymbol='+QuotedStr(mVarSymbol),'');
             if not(NxIsEmptyOID(mZLV_ID)) then begin
               mRowBO.SetFieldValueAsString('PDocumentType','10');
               mRowBO.SetFieldValueAsString('PDocument_ID', mZLV_ID);
             end;
           end;
         end;
       end;
    end;
    mLogs.add(DateTimeToStr(Now)+' '+ansirightstr('000'+IntToStr(i),4)+'   pohyb:  '+mIDPohybu+'  datum:  '+DateTimeToStr(mDate)+'   var symbol: '+mVarSymbol+'  částka: '+FloatToStr(mAmount)+'   '+mTyp+'    '+mText);
 end;
 mbo.save;
 mLogs.add(GetHorizontalSplitter(50));
  mLog_ID:=aOS.SQLSelectFirstAsString('select pl.id from prflogs pl where pl.docqueue_id='+QuotedStr('~000000B02')+' and pl.code='+QuotedStr('Banka '+mBO.DisplayName),'');
   if NxIsEmptyOID(mLog_ID) then
    CFxLog.SaveLog(NxCreateContext(aOS),'LA','Banka '+mBO.DisplayName,mLogs.Text,ltScripting,Now)
   else begin
     mLogBO:=aOS.CreateObject(Class_PRFLog);
     mLogBO.Load(mLog_ID,nil);
     mLogBO.SetFieldValueAsString('Note', mLogBO.GetFieldValueAsString('Note')+nxCrLf+mLogs.Text);
     mLogBO.save;
     mLogBO.free;
   end;

 mbo.free;
end;

function ISODateTimeToDateTime(AISODateTime: string): TDateTime;
var
  mY, mM, mD, mHH, mMM, mSS: Integer;
begin;
  mY := StrToInt(Copy(AISODateTime, 1, 4));
  mM := StrToInt(Copy(AISODateTime, 6, 2));
  mD := StrToInt(Copy(AISODateTime, 9, 2));
  mHH := StrToInt(Copy(AISODateTime, 12, 2));
  mMM := StrToInt(Copy(AISODateTime, 15, 2));
  mSS := StrToInt(Copy(AISODateTime, 18, 2));
  Result := EncodeDateTime(mY, mM, mD, mHH, mMM, mSS, 0);
end;

procedure CheckOrderPayment(OS: TNxCustomObjectSpace; var Success: Boolean; var LogInfoStr: String);
var
 mHorizontalSplitter, mToken:string;
 mList, mLogs:TStringList;
 i:integer;
 mBO:TNxCustomBusinessObject;
 mPaymentJSON:TJSONSuperObject;
begin
  mHorizontalSplitter:=GetHorizontalSplitter(50);
  mToken:=GetToken(OS);
  mList:=TStringList.Create;
  mLogs:=TStringList.Create;
  mLogs.add(mHorizontalSplitter);
  mLogs.Add(DateTimeToStr(now)+' Start of action');
  mLogs.add(mHorizontalSplitter);
  mLogs.add(mToken);
  OS.SQLSelect('Select id from receivedorders where docqueue_id='+QuotedStr(cMQ_RO_DocQueue_ID_OPDS)+' and X_PaymentState=0 and not(X_paymentid='+Quotedstr('')+')', mList);
  if mList.count>0 then begin
    mBO:=OS.CreateObject(Class_ReceivedOrder);
    for i:=0 to mList.count-1 do begin
     try
      mBO.Load(mlist.Strings[i],nil);
      mLogs.Add(DateTimeToStr(now)+' '+mBO.DisplayName);
      mPaymentJSON:=API_GET(OS,'/payments/payment/'+mBo.GetFieldValueAsString('X_paymentid'),mToken);
      mLogs.add(DateTimeToStr(now)+
                ' GoPay Amount: '+NxFloatToIBStr(mPaymentJSON.D['amount']/100)+
                '   AbraGen Amount: '+NxFloatToIBStr(mbo.GetFieldValueAsFloat('Amount'))+
                '   Status: '+mPaymentJSON.S['state']);
      if mPaymentJSON.S['state']='PAID' then begin
       if ((mPaymentJSON.D['amount']/100)=mbo.GetFieldValueAsFloat('Amount')) then
         mbo.SetFieldValueAsInteger('X_PaymentState',1) else
         mbo.SetFieldValueAsInteger('X_PaymentState',2);
       if mBO.NeedSave then mBo.save;
      end;
     except
      CFxLog.SaveLog(NxCreateContext(OS), 'MQ_Log', 'Except Platba '+mBo.DisplayName, ExceptionMessage , ltScripting, Now);
     end;
    end;
    mBO.free;
  end;
  mLogs.add(mHorizontalSplitter);
  mLogs.Add(DateTimeToStr(now)+' End of action');
  mLogs.add(mHorizontalSplitter);
  Success := True;
  LogInfoStr := ''+NxCrLf+mLogs.Text;
end;


function GetHorizontalSplitter(aLength: Integer): string;
var
  i: Integer;
begin
  Result := '';
  for i := 1 to aLength do
    Result := Result + '─';
end;


function API_GET(var aOS:TNxCustomObjectSpace;var aURL, aToken:string): TJSONSuperObject;
var
  mWinHTTP: Variant;
  mRequest: string;
begin
  try

    if NxIsBlank(aToken) then
      exit;
    mWinHTTP:= CreateOleObject('WinHttp.WinHttpRequest.5.1');
    mWinHTTP.Open('GET', cURLGoPay + AURL);
    mWinHTTP.SetRequestHeader('Accept', 'application/json');
    mWinHTTP.SetRequestHeader('Authorization', 'Bearer '+aToken);
    mWinHTTP.Send();
    Result := TJSONSuperObject.ParseString(mWinHTTP.ResponseText, True);
  except
    if CFxNxRuntime.NxGetEnvironmentType = reRuntimeExe then ShowMessage('Při GET dotazu do GoPay nastala neočekávaná chyba: '+ExceptionMessage);
  end;
end;

function GetToken(var aOS:TNxCustomObjectSpace;): string;
var
  mWinHTTP: Variant;
  mJson: TJSONSuperObject;
  mToken,mRequest, mLogin, mPass, mAuthorization: string;
begin
  try
    if not AOS.ReadFromSecureStore('GoPay_ClientID', mLogin) then
     RaiseException('V bezpečném úložišti nebyl nalezen klíč GoPay_ClientID.');
    if not AOS.ReadFromSecureStore('GoPay_ClientSecret', mPass) then
     RaiseException('V bezpečném úložišti nebyl nalezen klíč GoPay_ClientSecret.');
    mAuthorization:=EncodeBase64(TEncoding.UTF8.GetBytes(mLogin+':'+mPass));
    mWinHTTP:= CreateOleObject('WinHttp.WinHttpRequest.5.1');
    mWinHTTP.Open('POST', cURLGoPay + '/oauth2/token');
    mWinHTTP.SetRequestHeader('Content-Type', 'application/x-www-form-urlencoded');
    mWinHTTP.SetRequestHeader('Accept', 'application/json');
    mWinHTTP.SetRequestHeader('Authorization','Basic '+mAuthorization);
    mRequest := mRequest + 'grant_type=' + 'client_credentials' + '&';
    mRequest := mRequest + 'scope=' + 'payment-all';
    mWinHTTP.Send(mRequest);
    if mWinHTTP.Status <> 200 then begin    //kód <> 200 = dotaz vůbec neprošel
      //CFxLog.SaveLog(NxCreateContext(aOS), 'MQ_Log', 'pokus', 'Nebylo možné vygenerovat přístupový token: ' + IntToStr(mWinHTTP.Status) +': '+ mWinHTTP.StatusText + ' '+mWinHTTP.ResponseText+NxCrLf+mAuthorization+NxCrLf+mLogin+':'+mPass, ltScripting, Now);
      if CFxNxRuntime.NxGetEnvironmentType = reRuntimeExe then ShowMessage('Nebylo možné vygenerovat přístupový token: ' + IntToStr(mWinHTTP.Status) +': '+ mWinHTTP.StatusText + ' '+mWinHTTP.ResponseText);
    end
    else begin
      mJson := TJSONSuperObject.ParseString(mWinHTTP.ResponseText, True);
      mToken := mJSon.S['access_token'];
      Result:= mToken;
    end;
  except
    if CFxNxRuntime.NxGetEnvironmentType = reRuntimeExe then ShowMessage('Nastala neočekávaná chyba při získávání tokenu: '+ExceptionMessage);
  end;
end;


begin
end.