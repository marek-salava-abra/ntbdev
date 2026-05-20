uses
  'REST_SkladTerm_Customer.U_Func';

function processSpecialGetRequests(AContext: TNxContext; AHeaders, APath: TStringList; ABody: String; AResponse: TStringList): Boolean;
begin
  Result := True;
  case APath.Strings[0] of
    'getStoreBatchesByEAN': getStoreBatchesByEAN(AContext.GetObjectSpace, APath, AResponse);
    'getKlausTimberBarcodeResult': getKlausTimberBarcodeResult(AContext.GetObjectSpace, APath, AResponse);
    'getVaskyQRCodeResult': getVaskyQRCodeResult(AContext.GetObjectSpace, APath, AResponse);
    'get_ABRAIssuedOrderRow_Abra': Get_ABRAIssuedOrderRow_Abra(AContext.GetObjectSpace, APath, AResponse);
    'get_ReceiptCardFromIOListDocQueue_Abra': Get_ReceiptCardFromIOListDocQueue_Abra(AContext.GetObjectSpace, APath, AResponse);
    else Result := False;
  end;
end;

function processSpecialPutRequests(AContext: TNxContext; AHeaders, APath: TStringList; ABody: String; AResponse: TStringList): Boolean;
begin
  Result := True;
  case APath.Strings[0] of
    'putOrdersRequestsWithoutDocStopPicking': putOrdersRequestsWithoutDocStopPicking(AContext.GetObjectSpace, APath, ABody, AResponse);
    'raycom_ReceiptCardSave': Raycom_ReceiptCardSave(AContext, APath, ABody,AResponse);
    'putKonseptiQueueDocDetailStopPicking': putKonseptiQueueDocDetailStopPicking(AContext.GetObjectSpace, APath,AResponse);
    'put_FreePrintDocStopPicking_Abra_Plab': put_FreePrintDocStopPicking_Abra_Plab(AContext, APath, ABody, AResponse);
    'put_ReceiptCardFromIOStartPicking_Abra': Put_ReceiptCardFromIOStartPicking_Abra(AContext, APath, AResponse);
    'put_ReceiptCardFromIOStopPicking_Abra': Put_ReceiptCardFromIOStopPicking_Abra(AContext.GetObjectSpace, APath, ABody, AResponse);
    else Result := False;
  end;
end;

function processSpecialPostRequests(AContext: TNxContext; AHeaders, APath: TStringList; ABody: String; AResponse: TStringList): Boolean;
begin
  Result := True;
  {case APath.Strings[0] of
    else} Result := False;
  //end;
end;

begin
end.