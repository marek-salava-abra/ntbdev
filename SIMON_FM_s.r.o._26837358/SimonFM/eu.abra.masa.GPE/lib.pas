procedure CheckPaymentAPI(OS: TNxCustomObjectSpace;  var Success: Boolean; var LogInfoStr: String);
var
 mSignList, mRunBat, mOrderList:TStringList;
 mResultMessage, mSubject, mMailText, mFirmMail, mZLV_ID:string;
 i,j:integer;
 mCurrBO, mZLVBO,mZLVRowBO,mRowBO, mTextBO:TNxCustomBusinessObject;
 mRows, mZLVRows:TNxCustomBusinessMonikerCollection;
 mResult:TJSONSuperObject;
 mFee:extended;
begin
  mOrderList:=TStringList.Create;
  OS.SQLSelect('Select a.id from receivedorders a WHERE not(X_comgateID='''') and A.DocDate$DATE >='+IntToStr(trunc(date-7))+
               ' and (A.DocQueue_ID = ''1W10000101'' ) AND (A.PaymentType_ID = ''6000000101'') and (exists (SELECT 1 FROM USERDATA WHERE FIELDCODE=2000003 AND CLSID=''01CPMINJW3DL342X01C0CX3FCC'' AND ID = A.ID AND ((STRINGFIELDVALUE = ''5C92000101'') or (STRINGFIELDVALUE = ''57E2000101'')))) ',mOrderList);
  mResultMessage:='';
  if mOrderList.count>0 then begin
   for i:=0 to mOrderList.count-1 do begin
      mCurrBO:=os.CreateObject(Class_ReceivedOrder);
      mCurrBO.Load(mOrderList.strings[i],nil);
      if Assigned(mCurrBO) then begin
        if not(NxIsBlank(mCurrBO.GetFieldValueAsString('X_ComgateID'))) then begin
           mResult:=TJSONSuperObject.Create;
           mResult:=API_GEt('https://payments.comgate.cz/v2.0/payment/transId/'+mCurrBO.GetFieldValueAsString('X_ComgateID')+'.json',OS);
           //zjistit jestli bude AppliedFee v JSON následně přidat řádek do OP

           //
           if mResult.S['status']='PAID' then begin
                mCurrBO.SetFieldValueAsString('X_PPLSMart',AnsiLeftStr(mResult.S['status'],20));
                mFee:=0;
                if mResult.N['appliedFee'].DataType<>jtNull then begin
                  mFee:=NxIBStrToFloat(mResult.S['appliedFee'])/100;
                  if mFee>0 then begin
                    mRows:=mCurrBO.GetLoadedCollectionMonikerForFieldCode(mCurrBO.GetFieldCode('Rows'));
                    mRowBO:=mRows.AddNewObject;
                    mRowBO.prefill;
                    mRowBO.SetFieldValueAsInteger('RowType',1);
                    mRowBO.SetFieldValueAsString('Text','Poplatek za úhradu neregulovanou kartou');
                    mRowBO.SetFieldValueAsFloat('TotalPrice',mFee);
                    mRowBO.SetFieldValueAsString('VatRate_ID','00000X0000');
                    mRowBO.SetFieldValueAsString('Division_ID','1400000101');
                    mRowBO.SetFieldValueAsString('IncomeType_ID','3SC0000101');
                    mCurrBO.SetFieldValueAsInteger('TotalRounding',-33554175);
                    mZLV_ID:=OS.SQLSelectFirstAsString('Select id from issueddinvoices where receivedorder_id='+QuotedStr(mCurrBO.OID),'');
                    if not(NxIsEmptyOID(mZLV_ID)) then begin
                      try
                        mZLVBO:=OS.CreateObject(Class_IssuedDepositInvoice);
                        mZLVBO.Load(mZLV_ID,nil);
                        mZLVRows:=mZLVBO.GetLoadedCollectionMonikerForFieldCode(mZLVBO.GetFieldCode('Rows'));
                        for j:=0 to mZLVRows.count-1 do begin
                          mZLVRowBO:=mZLVRows.BusinessObject[j];
                          if mZLVRowBO.GetFieldValueAsInteger('RowType')=4 then mZLVRowBO.SetFieldValueAsFloat('TAmount',mfee+mZLVRowBO.GetFieldValueAsFloat('TAmount'));
                        end;
                        mzlvbo.save;
                        mzlvbo.free;
                      except

                      end;
                    end;
                  end;
                end;
                mCurrBO.SetFieldValueAsString('U_orderState_ID','IURB000101');
                mCurrBO.SetFieldValueAsString('PMState_ID','1010000101');
                mCurrBO.SetFieldValueAsString('X_PPLSMart',AnsiLeftStr(mResult.S['status'],20));
                // doplnit odeslání emailu
                  mTextBO:=OS.CreateObject('PKVPDHXNS3L4DE0DC0XUE1FP2K');
                  mTextBO.Load('IURB000101',nil);
                  mSubject:='Objednávka '+mCurrBO.GetFieldValueAsString('ExternalNumber')+' platba přijata.';
                  mFirmMail:=mCurrBO.GetFieldValueAsString('FirmOffice_ID.Address_ID.Email');
                  if not(NxIsValidEMail(mFirmMail,false)) then mFirmMail:='eshop@naradi-simon.cz';
                  mMailText:=mTextBO.GetFieldValueAsString('X_note');
                  mMailText:=NxSearchReplace(mMailText,'#CISOBJ#',mCurrBO.GetFieldValueAsString('ExternalNumber'),[srAll]);
                  SendInternalMail(OS,mFirmMail,'','',
                                             mSubject,mMailText,
                                             '','',mCurrBO.GetFieldValueAsString('Firm_ID'),'1400000101','','1300000101', mCurrBO.OID);
                //
                mCurrBO.Save;
           end;
           if not(mResult.S['status']='PAID') then begin
             mCurrBO.SetFieldValueAsString('X_PPLSMart',AnsiLeftStr(mResult.S['status'],20));
             mcurrbo.save;
           end;
           mResultMessage:=mResultMessage+nxCrLf+'Status '+mResult.S['status']+' refId: '+mResult.S['refId'];

        end;
      end;
   end;
  end;
  Success := True;
  LogInfoStr := 'Počet záznamů:'+IntToStr(mOrderList.count)+#13#10+mResultMessage;
end;


function API_Get(aURL:string; AOS:TNxCustomObjectSpace):TJSONSuperObject;
var
 mWinHTTP:Variant;
begin
  try
   mWinHTTP:= CreateOleObject('WinHttp.WinHttpRequest.5.1');
   mWinHTTP.Open('GET', aURL);
   mWinHTTP.SetRequestHeader('Content-Type', 'application/json');
   mWinHTTP.SetRequestHeader('Authorization', 'Basic ' + EncodeBase64(TEncoding.UTF8.GetBytes('502879'+':'+'dAwHk3fJKtejTg1QgEaXy0nvkVPcQrQC')));
   mWinHTTP.Send();
   if mWinHTTP.Status = 200 then begin
     Result:=TJSONSuperObject.ParseString(mWinHTTP.ResponseText, True);
   end else begin
     CFxLog.SaveLog(NxCreateContext(aOS),'ERR','Chyba GET ne 200',mWinHTTP.ResponseText,2,Now);
   end;
  except
   CFxLog.SaveLog(NxCreateContext(aOS),'ERR','Chyba GET',ExceptionMessage,2,Now);
  end;
end;


procedure CheckPayment(OS: TNxCustomObjectSpace;  var Success: Boolean; var LogInfoStr: String);
var
 mWinHTTP:Variant;
 mCertFile:string;
 mCertBO, mRowBO, mCurrBO, mTextBO:TNxCustomBusinessObject;
 mRows:TNxCustomBusinessMonikerCollection;
 mOS:TNxCustomObjectSpace;
 aRequest:string;
 mXMLHead:TNxScriptingXMLWrapper;
 i,j,k,l:integer;
 mResponse, mDateString, mMessage, mResultMessage, mSignature, mDir, mCMD, mMessageID, mMessToSign,mSubject,mFirmMail,mMailText:string;
 mStream:TMemoryStream;
 mSite:TSiteForm;
 mSignList, mRunBat, mOrderList:TStringList;
begin
  mOrderList:=TStringList.Create;
  OS.SQLSelect('Select a.id from receivedorders a WHERE A.DocDate$DATE >='+IntToStr(trunc(date-2))+' and (A.DocQueue_ID = ''1W10000101'' ) AND (A.PaymentType_ID = ''6000000101'') and (exists (SELECT 1 FROM USERDATA WHERE FIELDCODE=2000003 AND CLSID=''01CPMINJW3DL342X01C0CX3FCC'' AND ID = A.ID AND ((STRINGFIELDVALUE = ''5C92000101'') or (STRINGFIELDVALUE = ''57E2000101'')))) ',mOrderList);
  mResultMessage:='';
  if mOrderList.count>0 then begin
  for l:=0 to mOrderList.count-1 do begin
      mCurrBO:=os.CreateObject(Class_ReceivedOrder);
      mCurrBO.Load(mOrderList.strings[l],nil);
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
          if mWinHTTP.Status='200' then begin
            mXMLHead:=TNxScriptingXMLWrapper.Create;
            mResponse := ConvertUTF8toString(mWinHTTP.ResponseText); // konverze UTF8
            mXMLHead.loadFromBytes(TEncoding.UTF8.GetBytes(mResponse));
            mXMLHead.saveToFile('D:\import_gpe\'+mCurrBO.GetFieldValueAsString('ExternalNumber')+'.xml');
         //   if elementexists(mXMLHead,'soapenv:Body.ns4:getPaymentDetailResponse') then begin
            for i:=0 to mXMLHead.getElementsCountInArray('soapenv:Body.ns4:getPaymentDetailResponse.ns4:paymentDetailResponse')-1 do begin
             mResultMessage:=mResultMessage+#13#10+mCurrBO.GetFieldValueAsString('ExternalNumber')+'  Stav číselně '+
                            mXMLHead.getElementAsString('soapenv:Body.ns4:getPaymentDetailResponse.ns4:paymentDetailResponse['+IntToStr(i)+'].ns3:state')+
                            '  status text '+mXMLHead.getElementAsString('soapenv:Body.ns4:getPaymentDetailResponse.ns4:paymentDetailResponse['+IntToStr(i)+'].ns3:status')+'  '+
                            ' datum a čas platby '+mXMLHead.getElementAsString('soapenv:Body.ns4:getPaymentDetailResponse.ns4:paymentDetailResponse['+IntToStr(i)+'].ns3:paymentTime');
              if mXMLHead.getElementAsString('soapenv:Body.ns4:getPaymentDetailResponse.ns4:paymentDetailResponse['+IntToStr(i)+'].ns3:state')='8' then begin
                mCurrBO.SetFieldValueAsString('U_orderState_ID','IURB000101');
                mCurrBO.SetFieldValueAsString('PMState_ID','1010000101');
                // doplnit odeslání emailu
                  mTextBO:=OS.CreateObject('PKVPDHXNS3L4DE0DC0XUE1FP2K');
                  mTextBO.Load('IURB000101',nil);
                  mSubject:='Objednávka '+mCurrBO.GetFieldValueAsString('ExternalNumber')+' platba přijata.';
                  mFirmMail:=mCurrBO.GetFieldValueAsString('FirmOffice_ID.Address_ID.Email');
                  if not(NxIsValidEMail(mFirmMail,false)) then mFirmMail:='eshop@naradi-simon.cz';
                  mMailText:=mTextBO.GetFieldValueAsString('X_note');
                  mMailText:=NxSearchReplace(mMailText,'#CISOBJ#',mCurrBO.GetFieldValueAsString('ExternalNumber'),[srAll]);
                  SendInternalMail(OS,mFirmMail,'','',
                                             mSubject,mMailText,
                                             '','',mCurrBO.GetFieldValueAsString('Firm_ID'),'1400000101','','1300000101', mCurrBO.OID);
                //
                mCurrBO.Save;
              end;
            end;
           //end;
           if elementexists(mXMLHead,'soapenv:Body.ns2:getPaymentDetailResponse') then begin
            for i:=0 to mXMLHead.getElementsCountInArray('soapenv:Body.ns2:getPaymentDetailResponse.ns2:paymentDetailResponse')-1 do begin
             mResultMessage:=mResultMessage+#13#10+mCurrBO.GetFieldValueAsString('ExternalNumber')+'  Stav číselně '+
                            mXMLHead.getElementAsString('soapenv:Body.ns2:getPaymentDetailResponse.ns2:paymentDetailResponse['+IntToStr(i)+'].state')+
                            '  status text '+mXMLHead.getElementAsString('soapenv:Body.ns2:getPaymentDetailResponse.ns2:paymentDetailResponse['+IntToStr(i)+'].status')+'  '+
                            ' datum a čas platby '+mXMLHead.getElementAsString('soapenv:Body.ns2:getPaymentDetailResponse.ns2:paymentDetailResponse['+IntToStr(i)+'].paymentTime');
              if mXMLHead.getElementAsString('soapenv:Body.ns2:getPaymentDetailResponse.ns2:paymentDetailResponse['+IntToStr(i)+'].state')='8' then begin
                mCurrBO.SetFieldValueAsString('U_orderState_ID','IURB000101');
                mCurrBO.SetFieldValueAsString('PMState_ID','1010000101');
                // doplnit odeslání emailu
                  mTextBO:=OS.CreateObject('PKVPDHXNS3L4DE0DC0XUE1FP2K');
                  mTextBO.Load('IURB000101',nil);
                  mSubject:='Objednávka '+mCurrBO.GetFieldValueAsString('ExternalNumber')+' platba přijata.';
                  mFirmMail:=mCurrBO.GetFieldValueAsString('FirmOffice_ID.Address_ID.Email');
                  if not(NxIsValidEMail(mFirmMail,false)) then mFirmMail:='eshop@naradi-simon.cz';
                  mMailText:=mTextBO.GetFieldValueAsString('X_note');
                  mMailText:=NxSearchReplace(mMailText,'#CISOBJ#',mCurrBO.GetFieldValueAsString('ExternalNumber'),[srAll]);
                  SendInternalMail(OS,mFirmMail,'','',
                                             mSubject,mMailText,
                                             '','',mCurrBO.GetFieldValueAsString('Firm_ID'),'1400000101','','1300000101', mCurrBO.OID);
                //
                mCurrBO.Save;
              end;
            end;
           end;
          end;
       end;

      mCurrBO.free;
     end;
  end;
  Success := True;
  LogInfoStr := 'Počet záznamů:'+IntToStr(mOrderList.count)+#13#10+mResultMessage;
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

procedure SendInternalMail(AOS:TNxCustomObjectSpace; ATo:String; ACC:String; ABCC:String;
                           ASubject:String; ABody:String; AAtachement, AAtachement2:String; AFirm_ID:String; ADivision_ID:String; ABusTransaction_ID:String; aAccount_ID:string; aOrder_ID:string);
Var
  mMailBO,mUserXLink:TNxCustomBusinessObject;
  mMRecipients:TNxCustomBusinessMonikerCollection;
  mMailRecipient:TNxCustomBusinessObject;
begin
  if not(ato='') then begin
     mMailBO:=AOS.CreateObject('5C1HWDQDR3J4NAAYZRO5PWHLWK');
     mMailBO.New;
     mMailBO.Prefill;
     mMailBO.SetFieldValueAsString('EmailAccount_ID',aAccount_ID);
     mMailBO.SetFieldValueAsString('Subject',ASubject);
     mMailBO.SetFieldValueAsString('BodySavedAs','1');
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

     if not(AAtachement2='') then begin
      TNxEmailSent(mMailBO).AttachFile(AAtachement2);

     end;



     mMailBO.Save;
     if not(NxIsEmptyOID(aOrder_ID)) then begin
     mUserXLink := aOS.CreateObject(Class_UserXLink);
      try
        mUserXLink.New;
        mUserXLink.Prefill;
        mUserXLink.SetFieldValueAsString('SourceCLSID', Class_ReceivedOrder);
        mUserXLink.SetFieldValueAsString('Source_ID', aOrder_ID);
        mUserXLink.SetFieldValueAsString('DestinationCLSID', Class_EmailSent);
        mUserXLink.SetFieldValueAsString('Destination_ID', mMailBO.OID);
        mUserXLink.SetFieldValueAsBoolean('DisplayAsSystem', True);
        mUserXLink.SetFieldValueAsString('Description',ASubject);
        mUserXLink.Save;
      finally
        mUserXLink.Free;
      end;
     end;
     mMailBO.free;

  end;
end;

begin
end.