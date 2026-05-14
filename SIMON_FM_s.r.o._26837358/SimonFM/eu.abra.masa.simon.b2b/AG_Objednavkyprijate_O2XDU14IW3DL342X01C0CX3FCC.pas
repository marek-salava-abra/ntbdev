procedure InitSite_Hook(Self: TSiteForm);
var
  mAction, mAction2: TBasicAction;
begin
  mAction := Self.GetNewAction;
  mAction.ShowControl := True;
  mAction.ShowMenuItem := True;
  mAction.Name := 'actCheckPayment';
  mAction.Caption := '##CheckGPE##';
  mAction.Hint := 'Naimportuje data z CSV';
  mAction.Category := 'tabList';
  mAction.OnExecute := @CheckPayment;
end;

Procedure CheckPayment(var Sender:TComponent);
var
 mWinHTTP:Variant;
 mCertFile:string;
 mCertBO, mRowBO, mCurrBO:TNxCustomBusinessObject;
 mRows:TNxCustomBusinessMonikerCollection;
 mOS:TNxCustomObjectSpace;
 aRequest:string;
 mXMLHead:TNxScriptingXMLWrapper;
 i,j,k:integer;
 mResponse, mDateString, mMessage, mSignature, mDir, mCMD, mMessageID, mMessToSign:string;
 mStream:TMemoryStream;
 mSite:TSiteForm;
 mSignList, mRunBat:TStringList;
begin
  mSite:=TComponent(Sender).dynsite;
  mOS:=mSite.BaseObjectSpace;
  mCurrBO:=TDynSiteForm(mSite).CurrentObject;
  if Assigned(mCurrBO) then begin
     mDir:=NxEvalObjectExprAsString(mCurrBO,'NxGetSpecialFolder(11)');
     if DirectoryExists(mDir) then begin
      mMessageID:=mCurrBO.GetFieldValueAsString('ExternalNumber')+'11422797';
      mMessageID:=IntToStr(trunc(1000000000000*Now));
      mMessToSign:=mMessageID+'|0110|11422797|'+mCurrBO.GetFieldValueAsString('ExternalNumber');
      mCMD:=mDir+'AbraWebAPI\jre.win\bin\java.exe'+' -jar '+mDir+'gp_prod\digestProc.jar'+' -s "'+mMessToSign+'"';
      mRunBat:=TStringList.create;
      mRunBat.add('@echo off');
      mRunBat.add('D:');
      mRunBat.add('cd \AbraGen');
      mRunBat.add('cd gp_prod');
      mRunBat.add(mCMD);
      //mRunBat.add('timeout /t 2 /nobreak > nul');
      mRunBat.SaveToFile(NxGetTempDir+'\run.bat');
      ShellAPI.Execute('open',NxGetTempDir+'run.bat','','');
      Sleep(1500);
      mSignList:=TStringList.Create;
      mSignList.LoadFromFile(mdir+'gp_prod\digestProc.sign');
      if mSignList.count>0 then begin
        k:=mSignList.count;
        mSignature:=mSignList.strings[k-1];
      end;
     end;
      aRequest:='<?xml version="1.0" encoding="UTF-8"?>'+
                '<SOAP-ENV:Envelope xmlns:SOAP-ENV="http://schemas.xmlsoap.org/soap/envelope/" xmlns:ns1="http://gpe.cz/pay/pay-ws/proc/v1/type" xmlns:ns2="http://gpe.cz/pay/pay-ws/proc/v1">'+
                '<SOAP-ENV:Body>'+
                '<ns2:getPaymentDetail>'+
                 '<ns2:paymentDetailRequest>'+
                 '<ns1:messageId>'+mMessageID+'</ns1:messageId>'+
                 //'<type:provider>0880</type:provider>'+
                 '<ns1:provider>0110</ns1:provider>'+
                 '<ns1:merchantNumber>11422797</ns1:merchantNumber>'+
                 '<ns1:paymentNumber>'+mCurrBO.GetFieldValueAsString('ExternalNumber')+'</ns1:paymentNumber>'+
                 '<ns1:signature>'+mSignature+'</ns1:signature>'+
                 '</ns2:paymentDetailRequest>'+
                 '</ns2:getPaymentDetail>'+
                 '</SOAP-ENV:Body>'+
                 '</SOAP-ENV:Envelope>';
      mWinHTTP:= CreateOleObject('WinHttp.WinHttpRequest.5.1');
      mWinHTTP.Open('POST','https://3dsecure.gpwebpay.com/pay-ws/v1/PaymentService');
      mWinHTTP.SetRequestHeader('Content-Type', 'text/xml;charset=utf-8');
      mWinHTTP.SetRequestHeader('SOAPAction','getPaymentDetail');
      mWinHTTP.Send(aRequest);
      NxShowSimpleMessage(mWinHTTP.status,msite);
      //NxShowSimpleMessage(mWinHTTP.ResponseText,mSite);
      if mWinHTTP.Status='200' then begin
        NxShowSimpleMessage(mWinHTTP.ResponseText,mSite);
        mXMLHead:=TNxScriptingXMLWrapper.Create;
        mResponse := ConvertUTF8toString(mWinHTTP.ResponseText); // konverze UTF8
        mXMLHead.loadFromBytes(TEncoding.UTF8.GetBytes(mResponse));
        //NxShowSimpleMessage(IntToStr(mXMLHead.getElementsCountInArray('soapenv:Body.ns4:getPaymentDetailResponse.ns4:paymentDetailResponse')),mSite);
        for i:=0 to mXMLHead.getElementsCountInArray('soapenv:Body.ns4:getPaymentDetailResponse.ns4:paymentDetailResponse')-1 do begin
          NxShowSimpleMessage(mXMLHead.getElementAsString('soapenv:Body.ns4:getPaymentDetailResponse.ns4:paymentDetailResponse['+IntToStr(i)+'].ns3:state'),mSite);
        end;
      end;
   end;
end;

function ElementExists(mXMLHead : TNxScriptingXMLWrapper; AName: string): Boolean;

begin
  try
    if mXMLHead.getElementAsString(AName) then Result:= True;
  except
    Result:= False
  end;
end;

function ConvertUTF8toString(aString: String): String;
var
  mUnicodeBites: TBytes;
begin
  mUnicodeBites := TEncoding.UTF8.GetBytes(aString);
  mUnicodeBites := TEncoding.Convert(mUnicodeBites,Encoding_cpUTF_8,Encoding_cpUTF_16);
  Result := TEncoding.Unicode.GetString(mUnicodeBites);
end;


begin
end.