uses
  'REST_SkladTerm.U_DialogRolls',
  'REST_SkladTerm.U_File',
  'REST_SkladTerm.U_Func',
  'REST_SkladTerm.U_Inventorization',
  'REST_SkladTerm.U_Login',
  'REST_SkladTerm.U_PackageShipping',
  'REST_SkladTerm.U_Print',
  'REST_SkladTerm.U_Queue',
  'REST_SkladTerm.U_StoreBatch',
  'REST_SkladTerm.U_StoreCard',
  'REST_SkladTerm.U_TemporaryStorage',
  'REST_SkladTerm.U_Test',
  'REST_SkladTerm.U_TransferBetweenPositions',
  'REST_SkladTerm.U_TransferWholePosition',
  'REST_SkladTerm.U_WithoutDoc',
  'REST_SkladTerm_Customer.U_Requests';

procedure put(AContext: TNxContext; AHeaders, APath, AArguments: TStringList; ABody: TBytes; AWithApi: Boolean; AResponse: TStringList);
var
  mOS: TNxCustomObjectSpace;
  mBody: String;
begin
  mOS := AContext.GetObjectSpace;

  if (pos(ContentType_JSON, AHeaders.Values('Content-Type')) > 0)
      or (pos(ContentType_PlainText, AHeaders.Values('Content-Type')) > 0) then
    mBody := TEncoding.UTF8.GetString(ABody);

  if not processSpecialPutRequests(AContext, AHeaders, APath, AArguments, mBody, AResponse) then
  begin
    case APath.Strings[0] of
      'login'    : put_LoginToSystem(AContext, AHeaders.Values('DeviceID'), mBody, AWithApi, AResponse);
      'logout'   : put_Logout(mOS, AResponse);
      'put_SaveLogStoreDocumentWithoutDoc': put_SaveLogStoreDocumentWithoutDoc(mOS, mBody, AResponse);
      'temporaryStorage': put_TemporaryStorage(mOS, APath, mBody, AResponse);
      'putQueueDocDetailStartPicking': putQueueDocDetailStartPicking(AContext, APath, AResponse);
      'putQueueDocDetailCancelPicking': putQueueDocDetailCancelPicking(mOS, APath, AResponse);
      'putBillOfDeliveryStopPicking': putQueueDocDetailStopPicking(mOS, APath, mBody, AResponse);
      'putJobOrdersStopPicking': putQueueDocDetailStopPicking(mOS, APath, mBody, AResponse);
      'putRefundedBillOfDeliveryStopPicking': putQueueDocDetailStopPicking(mOS, APath, mBody, AResponse);
      'putRefundedReceiptCardStopPicking': putQueueDocDetailStopPicking(mOS, APath, mBody, AResponse);
      'putTransferStopPicking': putQueueDocDetailStopPicking(mOS, APath, mBody, AResponse);
      'putReceiptCardStopPicking': putQueueDocDetailStopPicking(mOS, APath, mBody, AResponse);
      'putQueueDocDetailStopPicking': putQueueDocDetailStopPicking(mOS, APath, mBody, AResponse);
      'putTransferWithoutDocStopPicking': putTransferWithoutDocStopPicking(mOS, APath, mBody, AResponse);
      'putPartialInvProtocolDocDetailStartPicking': putPartialInvProtocolDocDetailStartPicking(mOS, AHeaders.Values('DeviceID'), APath, AResponse);
      'putPartialInvProtocolDocDetailStopPicking': putPartialInvProtocolDocDetailStopPicking(mOS, APath, mBody, AHeaders.Values('DeviceID'), AResponse);
      'putMainInvProtocolDocDetailStartPicking': putMainInvProtocolDocDetailStartPicking(mOS, APath, AResponse);
      'putNewStoreBatch': putNewStoreBatch(mOS, APath, mBody, AResponse);
      'putNewStoreBatches': putNewStoreBatches(mOS, APath, mBody, AResponse);
      'saveInventorizationFree': saveInventorizationFree(mOS, APath, mBody, AHeaders.Values('DeviceID'), AResponse);
      'putPackageShipping': putPackageShipping(mOS, APath, mBody, AResponse);
      'putTransferWholePositionContents': putTransferWholePositionContents(mOS, APath, mBody, AResponse);
      'putReceiptCardWithoutDocStopPicking': putWithoutDocStopPicking(mOS, APath, mBody, AResponse);
      'putBillOfDeliveryWithoutDocStopPicking': putWithoutDocStopPicking(mOS, APath, mBody, AResponse);
      'putReceivedOrdersWithoutDocStopPicking': putWithoutDocStopPicking(mOS, APath, mBody, AResponse);
      'putWithoutDocStartPicking': putWithoutDocStartPicking(mOS, AResponse);
      'printRow': printRow(mOS, mBody, AResponse);
      'listDialogSelection': listDialogSelection(mOS, APath, AArguments, mBody, AResponse);
      'putLabelDefinitions': putLabelDefinitions(mOS, APath, mBody, AResponse);
      'put_SaveStoreCardUnit': Put_SaveStoreCardUnit(mOS, APath, mBody, AResponse);
      'putDispatchWholePosition': PutDispatchWholePosition(mOS, APath, mBody, AResponse);
      'put_ProcessBarcode': put_ProcessBarcode(mOS, APath, AArguments, mBody, AResponse);
      'put_CodeResult': put_CodeResult(mOS, APath, mBody, AResponse);
      'put_saveTransferBetweenPositionsQueue': put_SaveTransferBetweenPositionsQueue(mOS, APath, mBody, AResponse);
      'put_FormatExpirationDate': put_FormatExpirationDate(mOS, APath, mBody, AResponse);
      'put_SaveSmallAssetCards': put_SaveSmallAssetCards(mOS, APath, mBody, AResponse);
      'put_SavePhoto': put_SavePhoto(mOS, ABody, AResponse);
      'putReceiptCardFromIOStopPicking': putQueueDocDetailStopPicking(mOS, APath, mBody, AResponse);
      'putTransformationWithoutDocStopPicking': putWithoutDocStopPicking(mOS, APath, mBody, AResponse);
      'putSubstitutionWithoutDocStopPicking': putWithoutDocStopPicking(mOS, APath, mBody, AResponse);
      'put_CustomCall': put_CustomCall(mOS, APath, mBody, AResponse);
      'put_SaveLog': Put_SaveLog(mOS, APath, mBody, AResponse);
      'put_OrdersGenerationWithoutDocStopPicking': PutOrdersGenerationWithoutDocStopPicking(mOS, APath, mBody, AResponse);

      {'putCreateOutgoingSubstitution': PutCreateOutgoingSubstitution(Self, ARequest, AResponse, slPath);
      'prepareReceiptCardDocQueueTest': prepareReceiptCardDocQueueTest(Self, ARequest, AResponse, slPath);
      'receiptCardWithoutDocTest': ReceiptCardWithoutDocTest(Self, ARequest, AResponse, slPath);
      'removeWorkInProgress': removeWorkInProgress(Self, ARequest, AResponse, slPath);
      'checkResult': checkResult(Self, ARequest, AResponse, slPath);}
      else SetResponse(AResponse, Format(getString('error_path_not_found'), [APath.Text]), ContentType_PlainText, HTTP_SC_BadRequest);
    end;
  end;
end;

begin
end.