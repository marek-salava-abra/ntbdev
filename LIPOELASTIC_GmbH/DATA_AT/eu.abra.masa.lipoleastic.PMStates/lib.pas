uses '.const';

procedure ChangeStatusonOrder (OS: TNxCustomObjectSpace; var Success: Boolean; var LogInfoStr: String);
var
  mROBO: TNxCustomBusinessObject;
  mROList, mPDMIDList: TStringList;
  i, j: integer;
begin
  //změna procesního stavu pro objednávky které nejsou vyřízené, stav 1050 a mají dodací list
  //nastavit do stavu 1060

  Success := True;
  LogInfoStr := '';

  mROList:= FetchReceivedOrdersIDs(OS);
  if mROList.Count = 0 then
    exit;

  mROBO:= OS.CreateObject(Class_ReceivedOrder);
  try
    for i:=0 to mROList.Count -1 do
    begin
      mROBO.Load(mROList[i], nil);
      mPDMIDList:= FetchPDMIssuedDocsForReceivedOrder(OS, mROBO.OID);
      for j:= 0 to mPDMIDList.Count -1 do
      begin

      end;
    end;
  finally
    mROBO.Free;
  end;
end;


function FetchReceivedOrdersIDs(AOS: TNxCustomObjectSpace): TStringList;
var
  mSQL: string;
begin
  Result:= nil;
  mSQL:= Format(
    ' SELECT ID FROM ReceivedOrders WHERE PMState_ID in (''%s'', ''%s'', ''%s'')',
    [cPMSTATE_ID_1050_SCANNED, cPMSTATE_ID_1060_PARTIALLY_DISPATCHED, cPMSTATE_ID_1070_DISPATCHED]);

  Result:= TStringList.Create;
  AOS.SQLSelect(mSQL, Result);
end;


function FetchPDMIssuedDocsForReceivedOrder(AOS: TNxCustomObjectSpace; AReceivedOrder_ID: string): TStringList;
var
  mSQL: string;
begin
  //CreateNewRelation(mOS, mRelDef, mPDMBO.OID, ABO.OID);
  mSQL:= Format(
    ' SELECT LEFTSIDE_ID FROM RELATIONS WHERE REL_DEF = %d AND RIGHTSIDE_ID = ''%s''',
    [1438, AReceivedOrder_ID]);

  Result:= TStringList.Create;
  AOS.SQLSelect(mSQL, Result);
end;


procedure GetPDMIssuedDocData(AOS: TNxCustomObjectSpace; var ASC_State_ID: string; var ATrackingNum: string);
begin

end;


function GetReceivedOrderID(AOS: TNxCustomObjectSpace; AExternalNumber: String): string;
begin
  Result:= '';
  Result:= AOS.SQLSelectFirstAsString(Format('SELECT ID FROM ReceivedOrders WHERE ExternalNumber = ''%s''', [AExternalNumber]));

  if NxIsEmptyOID(Result) then
    Result:= GetDocumentIDFromDisplayName(AOS, AExternalNumber, 'ReceivedOrders');
end;


function GetDocumentIDFromDisplayName(AOS: TNxCustomObjectSpace; AOrderNumber, ATableName: string;): string;
var
  mParams: TNxParameters;
  mFakeBO: TNxCustomBusinessObject;
  mDashPos, mSlashPos: Integer;
  mSQL, mTableName: String;
  mList: TStringList;
begin
  Result:= '';
  if Pos('/', AOrderNumber) = 0 then exit;

  mDashPos:= Pos('-', AOrderNumber);
  mSlashPos:= Pos('/', AOrderNumber);

  mList:= TStringList.Create;
  mParams:= TNxParameters.Create;
  //mFakeBO:= AOS.CreateObject(ACLSID);
  try
    //mParams.GetOrCreateParam(dtString, 'TableName').AsString:= NxGetTableNameForPersistCLSID(mFakeBO.PersistCLSID);
    mParams.GetOrCreateParam(dtString, 'DocQueueCode').AsString:= Copy(AOrderNumber, 1, mDashPos -1);
    mParams.GetOrCreateParam(dtInteger, 'OrdNumber').AsInteger:= StrToInt(Copy(AOrderNumber, mDashPos + 1, mSlashPos - mDashPos - 1));
    mParams.GetOrCreateParam(dtString, 'PeriodCode').AsString:= Copy(AOrderNumber, mSlashPos + 1, Length(AOrderNumber));

    mSQL:=  ' SELECT A.ID FROM ' + ATableName + ' A '+
            ' JOIN DocQueues DQ ON DQ.ID = A.DocQueue_ID '+
            ' JOIN Periods PE ON PE.ID = A.Period_ID '+
            ' WHERE DQ.Code = :DocQueueCode '+
            ' AND A.OrdNumber = :OrdNumber '+
            ' AND PE.Code = :PeriodCode ';

    AOS.SQLSelect(mSQL, mList, mParams);

    Result:= mList[0];
  finally
    mParams.Free;
    mList.Free;
    //mFakeBO.Free;
  end;
end;

procedure CheckMolliePayment (OS: TNxCustomObjectSpace; var Success: Boolean; var LogInfoStr: String);
var
 mList, mLogs:TStringList;
 i:integer;
 mBO:TNxCustomBusinessObject;
 mTransactionID, mToken, mBasicUrl:string;
 mResultJSON:TJSONSuperObject;
begin
 mList:=TStringList.Create;
 mLogs:=TStringList.Create;
 mLogs.Add('_______________________________');
 mLogs.Add(DateTimeToStr(Now)+'    Start of Check Payment');
 {os.SQLSelect('SELECT ro.id FROM receivedorders ro '+
                      'WHERE ro.pmstate_id in ('+QuotedStr('~000000002')+
                      ') and ro.docqueue_id in ('+Quotedstr('~000000002')+','+Quotedstr('~000000003')+') and ro.paymenttype_id='+QuotedStr('~000000008'),mList);}
 mList.add('~000004HAP');
 if mList.count>0 then begin
  mLogs.Add(DateTimeToStr(Now)+' Count of received orders: '+IntToStr(mList.Count));
  for i:=0 to mlist.Count-1 do begin
    mBO:=OS.CreateObject(Class_ReceivedOrder);
    mBO.load(mlist.Strings[i],nil);
    mTransactionID:=mBO.GetFieldValueAsString('X_TransactionID');
    mToken:=mBO.GetFieldValueAsString('PaymentType_ID.X_Token');
    mBasicUrl:=mBO.GetFieldValueAsString('PaymentType_ID.X_ApiConnector_ID.X_ParamValue');
    mLogs.Add(DateTimeToStr(Now)+' Order: '+mbo.DisplayName);
    if not(NxIsBlank(mTransactionID)) then begin
      mLogs.Add(DateTimeToStr(Now)+' TransactionID: '+mTransactionID);
      mResultJSON:=API_GET(mBasicUrl+mTransactionID,mToken);
      CFxLog.SaveLog(NxCreateContext(OS), 'LOG', 'Mollie_ERROR', mResultJSON.AsString, ltScripting, Now);
      mLogs.Add(DateTimeToStr(Now)+' status: '+mResultJSON.S['status']);
      //mBO.PMChangeState('~000000004');
    end;
    mbo.Free;
  end;
 end;
 mLogs.Add(DateTimeToStr(Now)+'    End of Check Payment');
 mLogs.Add('_______________________________');
 Success := True;
 LogInfoStr := ''+NxCrlf+mLogs.Text;
end;


procedure CheckBankPayment (OS: TNxCustomObjectSpace; var Success: Boolean; var LogInfoStr: String);
var
 mList, mLogs:TStringList;
 i:integer;
 mBO:TNxCustomBusinessObject;
begin
 mList:=TStringList.Create;
 mLogs:=TStringList.Create;
 mLogs.Add('_______________________________');
 mLogs.Add(DateTimeToStr(Now)+'    Start of Check Payment');
 os.SQLSelect(format('SELECT a.receivedorder_id FROM IssuedDInvoices A '+
                      'left join receivedorders ro on ro.id=a.receivedorder_id '+
                      'WHERE (A.Amount  = A.PaidAmount) '+
                      'AND (EXISTS (SELECT 1 FROM PaymentsForDocument_VIEW PFD   WHERE (PFD.DocDate$DATE >= %s) and (PFD.DocDate$DATE < %s) '+
                      'and PFD.PDocumentType = '+QuotedStr('10')+' and PFD.PDocument_ID = A.ID)) and ro.pmstate_id in ('+QuotedStr('~000000002')+','+QuotedStr('~000000003')+
                      ') and ro.docqueue_id in ('+Quotedstr('~000000002')+','+Quotedstr('~000000003')+')',[IntToStr(Trunc(date-7)), IntToStr(trunc(date+1))]),mList);
 if mList.count>0 then begin
  mLogs.Add(DateTimeToStr(Now)+' Count of received orders: '+IntToStr(mList.Count));
  for i:=0 to mlist.Count-1 do begin
    mBO:=OS.CreateObject(Class_ReceivedOrder);
    mBO.load(mlist.Strings[i],nil);
    mLogs.Add(DateTimeToStr(Now)+' Order: '+mbo.DisplayName);
    mBO.PMChangeState('~000000004');
    mbo.Free;
  end;
 end;
 mLogs.Add(DateTimeToStr(Now)+'    End of Check Payment');
 mLogs.Add('_______________________________');
 Success := True;
 LogInfoStr := ''+NxCrlf+mLogs.Text;
end;


function API_GET(aURL, aToken:String): TJSONSuperObject;
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
    mWinHTTP.SetRequestHeader('Authorization','Bearer '+aToken);
    mWinHTTP.Send();
    Result:=TJSONSuperObject.ParseString(ConvertToText(mWinHTTP.Responsebody), True);
  except

  end;
end;

function ConvertToText(aUnicodeBytes: TBytes): String;
var
  mUnicodeBites: TBytes;
begin
  mUnicodeBites := TEncoding.Convert(aUnicodeBytes,Encoding_cpUTF_8,Encoding_cpUTF_16);
  Result := TEncoding.Unicode.GetString(mUnicodeBites);
end;

begin
end.