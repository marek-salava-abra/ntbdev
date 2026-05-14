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
  'REST_SkladTerm_Customer.U_Requests'
  ;
  
////////////////////////////////////////////////////////////////////////////////
procedure get(Self: TNxWebServicesHelper; ARequest: TNxHTTPRequest; AResponse: TNxHTTPResponse);
var
  slPath, slArguments: TStringList;
  adr   : string;
begin
  gLogSectionIndex:= 0;
  slPath := TStringList.Create;
  slArguments := TStringList.Create;
  gLog:= TNxCustomLog.Create(REST_LogName);
  try
    try
      gTimeStart:= now;
      glog.EnterSection('SkladTerm GET', logDebug);
      glog.WriteEventFmt(logDebug, 'path=%s', [ARequest.Path]);
  
      if(not HTTP_Authorization(Self.ObjectSpace, ARequest, AResponse))then begin
        exit;
      end;

      ParsePath(ARequest.Path, slPath);

      slArguments.Delimiter:= '&';
      slArguments.DelimitedText:= ARequest.Arguments;
      slArguments.Text:= CFxInternet.URLDecode(slArguments.Text);

      //pokud nemam nic v ceste, vracim chybna cesta
      if(slPath.Count = 0)then begin
        ErrREST(ARequest, AResponse, HTTP_SC_BadRequest);
        exit;
      end;

      AResponse.Header.OtherHeaders := 'Requested-Client-Version=' + CLIENT_CURRENT_VERSION;

      // specialni zpracovani
      if not processSpecialGetRequests(Self, ARequest, AResponse, slPath) then
      begin
        // standardni zpracovani
        //podle toho zavolam funkci, ktera pozadavek zpracuje
        case slPath.Strings[0] of
          'storeCardInfo': get_StoreCardInfo(Self, ARequest, AResponse, slPath);
          'storeCardInfoSpecial': get_StoreCardInfo(Self, ARequest, AResponse, slPath);
          'storeCardPicture': get_StoreCardPicture(Self, ARequest, AResponse, slPath);
          'storeCardInfoPositions': get_StoreCardInfoPositions(Self, ARequest, AResponse, slPath);
          'storePositionInfo': get_StorePositionInfo(Self, ARequest, AResponse, slPath);
          'storePositionInfo2': get_StorePositionInfo2(Self, ARequest, AResponse, slPath);
          'storeInfo': get_StoreInfo(Self, ARequest, AResponse, slPath);
          'storeBatchInfo': get_StoreBatchInfo(Self, ARequest, AResponse, slPath);
          'firmInfo': get_FirmInfo(Self, ARequest, AResponse, slPath);
          'availableQuantity': get_AvailableQuantity(Self, ARequest, AResponse, slPath);
          'temporaryStorage': get_TemporaryStorage(Self, ARequest, AResponse, slPath);
          'listStores': listStores(Self, ARequest, AResponse, slPath);
          'listStoreCards': listStoreCards(Self, ARequest, AResponse, slPath);
          'listStorePositions': listStorePositions(Self, ARequest, AResponse, slPath);
          'listStoreBatches': listStoreBatches(Self, ARequest, AResponse, slPath);
          'listFirms': listFirms(Self, ARequest, AResponse, slPath);
          'listDocQueue': listDocQueue(Self, ARequest, AResponse, slPath);
          'listWithoutDocQueue': listWithoutDocQueue(Self, ARequest, AResponse, slPath);
          'listPartialInvProtocols': listPartialInvProtocols(Self, ARequest, AResponse, slPath);
          'listMainInvProtocols': listMainInvProtocols(Self, ARequest, AResponse, slPath);
          'isStoreLogistic': isStoreLogistic(Self, ARequest, AResponse, slPath);
          'listStoreCardsForInv': listStoreCardsForInv(Self, ARequest, AResponse, slPath);
          'listStorePositionsInv': listStorePositionsForInv(Self, ARequest, AResponse, slPath);
          'postProviderInfo': get_PostProviderInfo(Self, ARequest, AResponse, slPath);
          'packageInfo': get_PackageInfo(Self, ARequest, AResponse, slPath);
          'listPostProviders': listPostProviders(Self, ARequest, AResponse, slPath);
          'getSumQuantityForStoreCardAndStoreDocument': get_SumQuantityForStoreCardAndStoreDocument(Self, ARequest, AResponse, slPath);
          'getTransferWholePositionContentsAllowed': getTransferWholePositionContentsAllowed(Self, ARequest, AResponse, slPath);
          'auxStorePositionInfo': get_AuxStorePositionInfo(Self, ARequest, AResponse, slPath);
          'defaultSearchString': defaultSearchString(Self, ARequest, AResponse, slPath);
          //'idlingResourceTest': idlingResourceTest(Self, ARequest, AResponse, slPath);
          'getAuxField': getAuxField(Self, ARequest, AResponse, slPath);
          'getStoreDocumentRow': getStoreDocumentRow(Self, ARequest, AResponse, slPath);
          'transportationTypeInfo': get_TransportationTypeInfo(Self, ARequest, AResponse, slPath);
          'listTransportationTypes': get_ListTransportationTypes(Self, ARequest, AResponse, slPath);
          'personInfo': get_PersonInfo(Self, ARequest, AResponse, slPath);
          'listPersons': get_ListPersons(Self, ARequest, AResponse, slPath);
          'listWorkplaces': get_ListWorkplaces(Self, ARequest, AResponse, slPath);
          'workplaceInfo': get_WorkplaceInfo(Self, ARequest, AResponse, slPath);
          'listDocQueues': get_ListDocQueues(Self, ARequest, AResponse, slPath);
          'docQueueInfo': get_DocQueueInfo(Self, ARequest, AResponse, slPath);
          'storeCardInfoBatchesOnPositions': get_StoreCardInfoBatchesOnPosition(Self, ARequest, AResponse, slPath);
          'listStoreUnits': listStoreUnits(Self, ARequest, AResponse, slPath);
          'storeUnitInfo': get_StoreUnitInfo(Self, ARequest, AResponse, slPath);
          'get_AssetLocationInfo': get_AssetLocationInfo(Self, ARequest, AResponse, slPath);
          'get_AssetResponsibleInfo': get_AssetResponsibleInfo(Self, ARequest, AResponse, slPath);
          'get_SmallAssetCardInfo': get_SmallAssetCardInfo(Self, ARequest, AResponse, slPath);
          'GetMainMenuButtons': GetMainMenuButtons(Self, ARequest, AResponse, slPath);
          'get_CheckEanExistence': Get_CheckEanExistence(Self, ARequest, AResponse, slPath);
          'get_FirmOfficeInfo': get_FirmOfficeInfo(Self, ARequest, AResponse, slPath);
          'get_BusOrderInfo': get_BusOrderInfo(Self, ARequest, AResponse, slPath);
          'get_DivisionInfo': get_DivisionInfo(Self, ARequest, AResponse, slPath);
          'get_ListFirmOffices': get_ListFirmOffices(Self, ARequest, AResponse, slPath);
          'get_ListBusOrders': get_ListBusOrders(Self, ARequest, AResponse, slPath);
          'get_ListDivisions': get_ListDivisions(Self, ARequest, AResponse, slPath);
          'get_ListAssetLocations': get_ListAssetLocations(Self, ARequest, AResponse, slPath);
          'get_ListAssetResponsibles': get_ListAssetResponsibles(Self, ARequest, AResponse, slPath);
          'get_ListSmallAssetCards': get_ListSmallAssetCards(Self, ARequest, AResponse, slPath);
          'get_ListDocuments': get_ListDocuments(Self, ARequest, AResponse, slPath, slArguments);
          'get_ShowDocumentPhoto': get_ShowDocumentPhoto(Self, ARequest, AResponse, slPath);
          else ErrREST(ARequest, AResponse, HTTP_SC_BadRequest);
        end;
      end;
    except
      ErrREST(ARequest, AResponse, HTTP_SC_ExpectationFailed, ExceptionMessage);
    end;

  finally
    LogWriteDuration('SkladTerm GET', ARequest, AResponse);
    glog.LeaveSection('SkladTerm GET', logDebug);
    slPath.free;
    slArguments.Free;
    glog.free;
  end;
end;
////////////////////////////////////////////////////////////////////////////////

begin
end.