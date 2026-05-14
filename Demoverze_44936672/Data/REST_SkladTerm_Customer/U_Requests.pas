uses
  'REST_SkladTerm_Customer.U_Func';

function processSpecialGetRequests(Self: TNxWebServicesHelper; ARequest: TNxHTTPRequest; AResponse: TNxHTTPResponse; slPath: TStringList): Boolean;
begin
  Result := True;
  case slPath.Strings[0] of
    'getStoreBatchesByEAN': getStoreBatchesByEAN(Self, ARequest, AResponse, slPath);
    'getKlausTimberBarcodeResult': getKlausTimberBarcodeResult(Self, ARequest, AResponse, slPath);
    'getVaskyQRCodeResult': getVaskyQRCodeResult(Self, ARequest, AResponse, slPath);
    'get_ABRAIssuedOrderRow_Abra': Get_ABRAIssuedOrderRow_Abra(Self, ARequest, AResponse, slPath);
    'get_ReceiptCardFromIOListDocQueue_Abra': Get_ReceiptCardFromIOListDocQueue_Abra(Self, ARequest, AResponse, slPath);
    else Result := False;
  end;
end;

function processSpecialPutRequests(Self: TNxWebServicesHelper; ARequest: TNxHTTPRequest; AResponse: TNxHTTPResponse; slPath: TStringList): Boolean;
begin
  Result := True;
  case slPath.Strings[0] of
    'putOrdersRequestsWithoutDocStopPicking': putOrdersRequestsWithoutDocStopPicking(Self, ARequest, AResponse, slPath);
    'raycom_ReceiptCardSave': Raycom_ReceiptCardSave(Self, ARequest, AResponse, slPath);
    'putKonseptiQueueDocDetailStopPicking': putKonseptiQueueDocDetailStopPicking(Self, ARequest, AResponse, slPath);
    'put_FreePrintDocStopPicking_Abra_Plab': put_FreePrintDocStopPicking_Abra_Plab(Self, ARequest, AResponse, slPath);
    'put_ReceiptCardFromIOStartPicking_Abra': Put_ReceiptCardFromIOStartPicking_Abra(Self, ARequest, AResponse, slPath);
    'put_ReceiptCardFromIOStopPicking_Abra': Put_ReceiptCardFromIOStopPicking_Abra(Self, ARequest, AResponse, slPath);
    else Result := False;
  end;
end;

function processSpecialPostRequests(Self: TNxWebServicesHelper; ARequest: TNxHTTPRequest; AResponse: TNxHTTPResponse; slPath: TStringList): Boolean;
begin
  Result := True;
  {case slPath.Strings[0] of
    else} Result := False;
  //end;
end;

begin
end.