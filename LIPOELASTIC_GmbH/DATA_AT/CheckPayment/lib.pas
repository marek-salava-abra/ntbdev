Const
DateDif=14;
mdebug=false;

function CheckPayment(mBO:TNxCustomBusinessObject): TJSONSuperObject ;
var
  mOS:TNxCustomObjectSpace;
  mtyp,mURL,mID,mToken:string;
  mJSON:TJSONSuperObject;
begin

 if not nxisemptyoid(mbo.getFieldValueAsString('X_Payment_ID')) then begin
             if mbo.getFieldValueAsString('PaymentType_ID')='~000000008' then begin
                mOS:=mbo.ObjectSpace;
                mtyp:='POST';
                mURL:=mbo.getFieldValueAsString('PaymentType_ID.X_ApiConnector_ID.Name') + mbo.getFieldValueAsString('X_Payment_ID.name') ;
                mID:=mbo.getFieldValueAsString('X_Payment_ID.name');
                mToken:=mbo.getFieldValueAsString('PaymentType_ID.X_Token') ;

                mJSON:=TJSONSuperObject.create;
                try
                    mJSON:=APICallJSON(mos,mTyp,mUrl,mID,mToken,mJSON);
                    result:=mJSON ;
                finally

                end;


             end;
 end;
end;


procedure CheckPayAuto (OS: TNxCustomObjectSpace;  var Success: Boolean; var LogInfoStr: String);
var
 mr:tstringlist;
   i:integer;
   mBO,mBOPay:TNxCustomBusinessObject;
   mTJSONSuperObject:TJSONSuperObject;
begin
  Success := True;
  LogInfoStr := '';
  mr:=tstringlist.create;
  mbo:=os.createobject('01CPMINJW3DL342X01C0CX3FCC');
  try

        // kontrola ( ověření) platby pomocí API
        os.sqlselect('select id from receivedorders where X_payment_ID not is null and  (DocDate$DATE>' + nxfloattoibstr(date() - datedif) + ' and DocDate$DATE>=' + nxfloattoibstr(date())+ ') and  ( ((A.X_PaymentStatus_ID IN (''~000000ORY'',''~000000OS0'',''~000000OS2'')) OR (A.X_PaymentStatus_ID = ''0000000000'') OR (A.X_PaymentStatus_ID = '''')))' ,mr);
        if mr.count>0 then begin
            for i:=0 to mr.count-1 do begin
                mbo.load(mr.strings[i],null);
                    mTJSONSuperObject:=CheckPayment(mBO);


                     case mTJSONSuperObject.S['status'] of
                          'paid': begin
                                      mbo.SetFieldValueAsString('X_PaymentStatus_ID','~000000ORZ');
                                      mbopay:=os.createobject('4MUQWZQK1Q1OP2LF40ST0232US');
                                             try
                                                 mbopay.load(mbo.getFieldValueAsString('X_payment_ID'),nil);
                                                 mbopay.SetFieldValueAsString('X_URL',mTJSONSuperObject.S['_links.dashboard.href']);
                                                 mbopay.save;
                                             finally
                                                 mbopay.free;
                                             end;
                                      //mbo.SetFieldValueAsString('X_PaymentURL',mTJSONSuperObject.S['redirectUrl']);
                                      mbo.SetFieldValueAsString('PMState_ID','~000000004')  ;
                                      mbo.save ;
                                  end;
                          'unpaid': begin
                                      mbo.SetFieldValueAsString('X_PaymentStatus_ID','~000000OS0');
                                      mbo.SetFieldValueAsString('PMState_ID','~000000003')  ;
                                      mbo.save ;
                                  end;
                     end;

            end;
        end;



        // stornování starších dokladů
        os.sqlselect('select id from receivedorders where X_payment_ID not is null and  (DocDate$DATE<=' + nxfloattoibstr(date() - datedif) + ' ) and  ( ((A.X_PaymentStatus_ID IN (''~000000ORY'',''~000000OS0'',''~000000OS2'')) OR (A.X_PaymentStatus_ID = ''0000000000'') OR (A.X_PaymentStatus_ID = '''')))' ,mr);
        if mr.count>0 then begin
            for i:=0 to mr.count-1 do begin
                mbo.load(mr.strings[i],null);
                     mbo.SetFieldValueAsString('X_PaymentStatus_ID','~000000OS1');
                     mbo.SetFieldValueAsString('PMState_ID','~00000000C')  ;
                     mbo.save ;
            end;
        end;

  finally
      mbo.free;
      mr.free;

  end;
end;

function APICallJSON(os: TNxCustomObjectSpace; mTyp: string;mUrl: string;mID: string;mToken: string;mJSON:TJSONSuperObject): TJSONSuperObject;
var
  mWinHTTP: Variant;
begin
  try
         if GetHTTP(mWinHTTP) then begin
              mWinHTTP.Open(mTyp, mUrl );
              //NxShowSimpleMessage(mUrl  , nil);
              mWinHTTP.SetRequestHeader('Content-Type', 'application/json');
              mWinHTTP.SetRequestHeader('Authorization', 'Bearer ' + mtoken);  //    mWinHTTP.SetRequestHeader('Content-Type', 'application/json; charset=CP1250'); //'); //mWinHTTP.SetRequestHeader('Accept', 'application/json; charset=UTF-8');
              mWinHTTP.Send();
              //nxshowsimplemessage(mWinHTTP.ResponseText ,nil);
              Result:=TJSONSuperObject.ParseString(mWinHTTP.ResponseText, True);
        end;
      finally
      end;

end;


function GetHTTP(var WinHttpRequest: Variant): Boolean;
begin
  try
    if not VarIsType(WinHttpRequest, varDispatch) then begin
      WinHttpRequest := CreateOleObject('WinHttp.WinHttpRequest.5.1');
    end;
    Result:=True;
  except
    Result := False;
    OutputDebugString(ExceptionMessage);
    WinHttpRequest := nil;
  end;
end;


begin
end.