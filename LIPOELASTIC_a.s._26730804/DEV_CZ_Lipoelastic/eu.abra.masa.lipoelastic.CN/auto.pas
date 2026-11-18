procedure UpdateRetinoStateIssuedCreditNote(OS: TNxCustomObjectSpace; var Success: Boolean; var LogInfoStr: String);
var
  mCIBO: TNxCustomBusinessObject;
  mCIList: TStringList;
  i: Integer;
  mJSON, mResultJSON: TJSONSuperObject;
begin
  Success := True;
  LogInfoStr := '';
  mJSON:= TJSONSuperObject.Create;
  mResultJSON:= TJSONSuperObject.Create;
  //mJSON.ParseString('{"state": "c3e50be8-5c55-4421-8671-c877c4b61a4c"}', false);
  mJSON.S['state']:='c3e50be8-5c55-4421-8671-c877c4b61a4c';
  mCIList:= TStringList.Create;
  try
    OS.SQLSelect(
      ' SELECT ICN.ID FROM PaymentsForDocument_VIEW PFD '+
      ' JOIN IssuedCreditNotes ICN ON ICN.ID = PFD.PDocument_ID '+
      ' WHERE (PFD.DocDate$DATE >= '+NxFloatToIBStr(DATE - 7)+') and (PFD.DocDate$DATE < '+NxFloatToIBStr(DATE)+') '+
      ' AND (PFD.PDocumentType = ''60'') '+
      ' AND (PFD.Amount = PFD.PAmount) '+
      ' AND ICN.X_TicketID <> '''' '+
      ' AND ICN.X_Retino$Date = 0 ', mCIList);

    for i:= 0 to mCIList.Count -1 do begin
      mCIBO:= OS.CreateObject(Class_IssuedCreditNote);
      try
        mCIBO.Load(mCIList[i], nil);
        mResultJSON:= mResultJSON.CreateJSON;
        mResultJSON:= API_METHOD('PATCH', 'https://app.retino.com/api/v2/tickets/'+mCIBO.GetFieldValueAsString('X_TicketID'), mJSON);
        //mResultJSON:= API_PATCH('https://app.retino.com/api/v2/tickets/'+mCIBO.GetFieldValueAsString('X_TicketID'), mJSON);
        if mResultJSON.S['PATCH-Status'] = 'OK' then begin
          mResultJSON:= API_METHOD('POST', 'https://app.retino.com/api/v2/tickets/'+mCIBO.GetFieldValueAsString('X_TicketID')+'/close', mJSON);
          if mResultJSON.S['POST-Status'] = 'OK' then begin
            mCIBO.SetFieldValueAsDateTime('X_Retino$Date', Date);
            mCIBO.Save;
            LogInfoStr:= LogInfoStr + nxCrLf + mCIBO.DisplayName + ' - OK '+ mJSON.AsString;
          end;
        end;
      finally
        mCIBO.Free;
      end;
    end;
    //LogInfoStr:= LogInfoStr + nxCrLf + mResultJSON.AsString;
  finally
    mResultJSON.Free;
    mCIList.Free;
    mJSON.Free;
  end;
end;


procedure GeneratePaymentOrdersRetino (OS: TNxCustomObjectSpace; var Success: Boolean; var LogInfoStr: String);
var
  mList: TStringList;
  mPOBO, mPaymentOrderDocumentBO, mICNBO: TNxCustomBusinessObject;
  mPORows: TNxCustomBusinessMonikerCollection;
  i: integer;
begin
  Success := True;
  LogInfoStr := '';
  mList:= TStringList.Create;
  try
    OS.SQLSelect(
      ' SELECT ICN.ID FROM IssuedCreditNotes ICN '+
      ' LEFT JOIN PaymentOrders3 PO3 ON PO3.PDocument_ID = ICN.ID '+
      ' WHERE ICN.X_TicketID <> '''' '+
      ' AND DueDate$DATE > '+NxFloatToIBStr(Date -7)+
      ' AND DueDate$DATE <= '+NxFloatToIBStr(Date)+
      ' AND ((0 = (SELECT COUNT(*) FROM PaymentOrders3 PO3 join PaymentOrders2 PO2 on '+
      ' (PO3.Parent_id=PO2.ID) WHERE PO3.PDocument_ID = ICN.ID AND PO3.PDocumentType = ''60'' '+
      ' AND PO2.IsNotOK = ''N''))) ', mList);
    //LogInfoStr:= LogInfoStr + nxCrLf + mList.Text;
    for i:= 0 to mList.Count -1 do begin
      mICNBO:= OS.CreateObject(Class_IssuedCreditNote);
      try
        mICNBO.Load(mList[i], nil);
        mPOBO:= OS.CreateObject(Class_PaymentOrderRow);
        try
          mPOBO.new;
          mPOBO.prefill;
          mPOBO.SetFieldValueAsFloat('Amount', mICNBO.GetFieldValueAsFloat('Amount'));
          mPOBO.SetFieldValueAsString('Firm_ID', mICNBO.GetFieldValueAsString('Firm_ID'));
          mPOBO.SetFieldValueAsString('VarSymbol', mICNBO.GetFieldValueAsString('VarSymbol'));
          mPOBO.SetFieldValueAsString('TargetBankAccount', mICNBO.GetFieldValueAsString('FirmBankAccount_ID.BankAccount'));
          mPOBO.SetFieldValueAsDateTime('DueDate$Date', Date);
          mPOBO.SetFieldValueAsString('BankAccount_ID', '3JN0000101');
          mPOBO.SetFieldValueAsString('Currency_ID', mICNBO.GetFieldValueAsString('Currency_ID'));
          mPORows:= mPOBO.GetLoadedCollectionMonikerForFieldCode(mPOBO.GetFieldCode('PaymentOrderDocuments'));
          mPaymentOrderDocumentBO:= mPORows.AddNewObject;
          mPaymentOrderDocumentBO.SetFieldValueAsString('PDocument_ID', mICNBO.OID);
          mPaymentOrderDocumentBO.SetFieldValueAsString('PDocumentType', '60');
          mPaymentOrderDocumentBO.SetFieldValueAsFloat('Amount', mICNBO.GetFieldValueAsFloat('Amount'));
          {
          LogInfoStr:= LogInfoStr + nxCrLf + mICNBO.DisplayName;
          LogInfoStr:= LogInfoStr + nxCrLf + NxFloatToIBStr(mPOBO.GetFieldValueAsFloat('Amount'));
          LogInfoStr:= LogInfoStr + nxCrLf + mPOBO.GetFieldValueAsString('Firm_ID');
          LogInfoStr:= LogInfoStr + nxCrLf + mPOBO.GetFieldValueAsString('VarSymbol');
          LogInfoStr:= LogInfoStr + nxCrLf + mPOBO.GetFieldValueAsString('TargetBankAccount');
          LogInfoStr:= LogInfoStr + nxCrLf + mPOBO.GetFieldValueAsString('BankAccount_ID');
          LogInfoStr:= LogInfoStr + nxCrLf + mPOBO.GetFieldValueAsString('Currency_ID');
          LogInfoStr:= LogInfoStr + nxCrLf + mPaymentOrderDocumentBO.GetFieldValueAsString('PDocument_ID');
          LogInfoStr:= LogInfoStr + nxCrLf + mPaymentOrderDocumentBO.GetFieldValueAsString('PDocumentType');
          LogInfoStr:= LogInfoStr + nxCrLf + NxFloatToIBStr(mPaymentOrderDocumentBO.GetFieldValueAsFloat('Amount'));
          LogInfoStr:= LogInfoStr + nxCrLf + DateToStr(mPOBO.GetFieldValueAsDateTime('DueDate$Date'));
          }
          mPOBO.save;
          LogInfoStr:= LogInfoStr + nxCrLf + mICNBO.DisplayName + ' --> '+mPOBO.DisplayName;
        finally
          mPOBO.Free;
        end;
      finally
        mICNBO.Free;
      end;
    end;
  finally
    mList.Free;
  end;
end;

function API_PATCH(aURL: string; AJSON:TJSONSuperObject): TJSONSuperObject;
var
  mWinHTTP: Variant;
  mRequest, mLogin: string;
  mJSON:TJSONSuperObject;
  mList:TStringList;
begin
  try
    mWinHTTP:= CreateOleObject('WinHttp.WinHttpRequest.5.1');
    mWinHTTP.Open('PATCH', aURL);
    mWinHTTP.SetRequestHeader('Content-Type', 'application/json');
    mWinHTTP.SetRequestHeader('Authorization','Token 09b8138ec06eeb39cae5f43e2b97f486e8f902d6');
    mWinHTTP.Send(AJSON.AsJson);
    Result:=TJSONSuperObject.Create;
    Result:=TJSONSuperObject.ParseString(mWinHTTP.ResponseText, True);
    if mWinHTTP.status='200' then begin
      Result.S['Status']:='OK';
    end else begin
      Result.S['Status']:='Error'
    end;
  except

  end;
end;


function API_METHOD(AMethod, AURL: string; AJSON:TJSONSuperObject): TJSONSuperObject;
var
  mWinHTTP: Variant;
  mRequest, mLogin: string;
  mJSON:TJSONSuperObject;
  mList:TStringList;
begin
  try
    mWinHTTP:= CreateOleObject('WinHttp.WinHttpRequest.5.1');
    mWinHTTP.Open(AMethod, aURL);
    mWinHTTP.SetRequestHeader('Content-Type', 'application/json');
    mWinHTTP.SetRequestHeader('Authorization','Token 09b8138ec06eeb39cae5f43e2b97f486e8f902d6');
    mWinHTTP.Send(AJSON.AsJson);
    Result:=TJSONSuperObject.Create;
    Result:=TJSONSuperObject.ParseString(mWinHTTP.ResponseText, True);
    if mWinHTTP.status='200' then begin
      Result.S[AMethod+'-Status']:='OK';
    end else begin
      Result.S[AMethod+'-Status']:='Error'
    end;
  except

  end;
end;

begin
end.