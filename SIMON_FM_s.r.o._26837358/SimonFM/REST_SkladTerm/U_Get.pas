uses
  'REST_SkladTerm.U_File',
  'REST_SkladTerm.U_Firm',
  'REST_SkladTerm.U_Func',
  'REST_SkladTerm.U_Inventorization',
  'REST_SkladTerm.U_PackageShipping',
  'REST_SkladTerm.U_Print',
  'REST_SkladTerm.U_Queue',
  'REST_SkladTerm.U_Rolls',
  'REST_SkladTerm.U_Store',
  'REST_SkladTerm.U_StoreCard',
  'REST_SkladTerm.U_StoreBatch',
  'REST_SkladTerm.U_StorePosition',
  'REST_SkladTerm.U_TemporaryStorage',
  'REST_SkladTerm.U_Test',
  'REST_SkladTerm.U_TransferWholePosition',
  'REST_SkladTerm.U_WithoutDoc',
  'REST_SkladTerm_Customer.U_Requests';
  
procedure get(AContext: TNxContext; AHeaders, APath, AArguments: TStringList; ABody: String; AResponse: TStringList);
var
  mOS: TNxCustomObjectSpace;
begin
  mOS := AContext.GetObjectSpace;

  if not processSpecialGetRequests(AContext, AHeaders, APath, AArguments, ABody, AResponse) then
  begin
    case APath.Strings[0] of
      'storeCardInfo': get_StoreCardInfo(mOS, APath, AArguments, AResponse);
      'storeCardInfoSpecial': get_StoreCardInfo(mOS, APath, AArguments, AResponse);
      'storeCardPicture': get_StoreCardPicture(mOS, APath, AResponse);
      'storeCardInfoPositions': get_StoreCardInfoPositions(mOS, APath, AArguments, AResponse);
      'storePositionInfo': get_StorePositionInfo(mOS, APath, AArguments, AResponse);
      'storePositionInfo2': get_StorePositionInfo2(mOS, APath, AResponse);
      'storeInfo': get_StoreInfo(mOS, APath, AResponse);
      'storeBatchInfo': get_StoreBatchInfo(mOS, APath, AArguments, AResponse);
      'firmInfo': get_FirmInfo(mOS, APath, AResponse);
      'temporaryStorage': Get_TemporaryStorage(mOS, APath, AResponse);
      'listDocQueue': listDocQueue(mOS, APath, AArguments, AResponse);
      'listWithoutDocQueue': listWithoutDocQueue(mOS, APath, AArguments, AResponse);
      'listPartialInvProtocols': listPartialInvProtocols(mOS, APath, AArguments, AResponse);
      'listMainInvProtocols': listMainInvProtocols(mOS, APath, AArguments, AResponse);
      'listStoreCardsForInv': listStoreCardsForInv(mOS, APath, AArguments, AResponse);
      'listStorePositionsInv': listStorePositionsForInv(mOS, APath, AArguments, AResponse);
      'postProviderInfo': get_PostProviderInfo(mOS, APath, AResponse);
      'packageInfo': get_PackageInfo(mOS, APath, AResponse);
      'getSumQuantityForStoreCardAndStoreDocument': get_SumQuantityForStoreCardAndStoreDocument(mOS, APath, AResponse);
      'getTransferWholePositionContentsAllowed': getTransferWholePositionContentsAllowed(mOS, APath, AResponse);
      'auxStorePositionInfo': get_AuxStorePositionInfo(mOS, APath, AResponse);
      'defaultSearchString': defaultSearchString(mOS, APath, AResponse);
      'getStoreDocumentRow': getStoreDocumentRow(mOS, APath, AResponse);
      'transportationTypeInfo': get_TransportationTypeInfo(mOS, APath, AResponse);
      'personInfo': get_PersonInfo(mOS, APath, AResponse);
      'workplaceInfo': get_WorkplaceInfo(mOS, APath, AResponse);
      'docQueueInfo': get_DocQueueInfo(mOS, APath, AResponse);
      'storeCardInfoBatchesOnPositions': get_StoreCardInfoBatchesOnPosition(mOS, APath, AArguments, AResponse);
      'storeUnitInfo': get_StoreUnitInfo(mOS, APath, AResponse);
      'get_AssetLocationInfo': get_AssetLocationInfo(mOS, APath, AResponse);
      'get_AssetResponsibleInfo': get_AssetResponsibleInfo(mOS, APath, AResponse);
      'get_SmallAssetCardInfo': get_SmallAssetCardInfo(mOS, APath, AResponse);
      'GetMainMenuButtons': GetMainMenuButtons(mOS, APath, AResponse);
      'get_FirmOfficeInfo': get_FirmOfficeInfo(mOS, APath, AResponse);
      'get_BusOrderInfo': get_BusOrderInfo(mOS, APath, AResponse);
      'get_BusTransactionInfo': get_BusTransactionInfo(mOS, APath, AResponse);
      'get_BusProjectInfo': get_BusProjectInfo(mOS, APath, AResponse);
      'get_DivisionInfo': get_DivisionInfo(mOS, APath, AResponse);
      'get_ShowDocumentPhoto': get_ShowDocumentPhoto(mOS, APath, AResponse);
      'get_NewVersionFile': Get_NewVersionFile(mOS, AResponse);
      'get_StoreMenuInfo': Get_StoreMenuInfo(mOS, APath, AResponse);
      'rolls': rolls(mOS, APath, AArguments, AResponse);
      else SetPlainResponse(AResponse, Format(getString('error_path_not_found'), [APath.Text]), HTTP_SC_BadRequest);
    end;
  end;
end;

begin
end.