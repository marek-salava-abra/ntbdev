//FREE - OK

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
  'REST_SkladTerm.U_TemporaryStorage',
  'REST_SkladTerm.U_Test',
  'REST_SkladTerm.U_TransferBetweenPositions',
  'REST_SkladTerm.U_TransferWholePosition',
  'REST_SkladTerm.U_WithoutDoc',
  'REST_SkladTerm_Customer.U_Requests';

////////////////////////////////////////////////////////////////////////////////
procedure put(Self: TNxWebServicesHelper; ARequest: TNxHTTPRequest; AResponse: TNxHTTPResponse);
var
  slPath: TStringList;
  adr   : string;
  WS_User_ID: string;
begin
  WS_User_ID:= '';
  gLogSectionIndex := 0;
  slPath := TStringList.Create;
  gLog := TNxCustomLog.Create(REST_LogName);
  try
    try
      gTimeStart:= now;
      glog.EnterSection('SkladTerm PUT', logDebug);
      glog.WriteEventFmt(logDebug, 'Path:%s'     , [getRequestPath(ARequest)]);
      glog.WriteEventFmt(logDebug, 'Arguments:%s', [CFxInternet.URLDecode(ARequest.Arguments)]);
      //glog.WriteEventFmt(logDebug, 'Content:%s'  , [REST_ByteUTF82String(ARequest.Content.Content)]);

      if(not HTTP_Authorization(Self.ObjectSpace, ARequest, AResponse))then begin
        exit;
      end;

      //rozparsruju si cestu a vytahnu prvni cast (/xxx/)
      ParsePath(ARequest.Path, slPath);

      //pokud nemam nic v ceste, vracim chybna cesta
      if(slPath.Count = 0)then begin
        ErrREST(ARequest, AResponse, HTTP_SC_BadRequest);
        exit;
      end;

      //nastavim si globalni promenou WS_User_ID (predstavuje uzivatele, ktery je prihlaseni do aplikace)
      WS_User_ID:= getHeaderValue(ARequest, 'UserID');
      if(not NxIsEmptyOID(WS_User_ID))then
        GlobParams.GetOrCreateParam(dtString, 'WS_User_ID').AsString := WS_User_ID
      else
        GlobParams.DeleteByName('WS_User_ID');

      AResponse.Header.OtherHeaders := 'Requested-Client-Version=' + CLIENT_CURRENT_VERSION;
      glog.WriteEventFmt(logDebug, 'ResponseHeaders:%s'  , [AResponse.Header.OtherHeaders]);

      // specialni zpracovani
      if not processSpecialPutRequests(Self, ARequest, AResponse, slPath) then
      begin
        // standardni zpracovani
        //podle toho zavolam funkci, ktera pozadavek zpracuje
        case slPath.Strings[0] of
          // prihlaseni do systemu
          'login'    : put_LoginToSystem(Self, ARequest, AResponse, slPath);
          'logout'   : put_Logout(Self, ARequest, AResponse, slPath);
          'saveTransferBetweenPositions': saveTransferBetweenPositions(Self, ARequest, AResponse, slPath);
          'temporaryStorage': put_TemporaryStorage(Self, ARequest, AResponse, slPath);
          'putQueueDocDetailStartPicking': putQueueDocDetailStartPicking(Self, ARequest, AResponse, slPath);
          'putQueueDocDetailCancelPicking': putQueueDocDetailCancelPicking(Self, ARequest, AResponse, slPath);
          // zatim obsluhuje ulozeni VYD a PRE stejna funkce putQueueDocDetailStopPicking
          'putBillOfDeliveryStopPicking': putQueueDocDetailStopPicking(Self, ARequest, AResponse, slPath);
          'putJobOrdersStopPicking': putQueueDocDetailStopPicking(Self, ARequest, AResponse, slPath);
          'putRefundedBillOfDeliveryStopPicking': putQueueDocDetailStopPicking(Self, ARequest, AResponse, slPath);
          'putTransferStopPicking': putQueueDocDetailStopPicking(Self, ARequest, AResponse, slPath);
          'putReceiptCardStopPicking': putQueueDocDetailStopPicking(Self, ARequest, AResponse, slPath);
          'putQueueDocDetailStopPicking': putQueueDocDetailStopPicking(Self, ARequest, AResponse, slPath);
          'putTransferWithoutDocStopPicking': putTransferWithoutDocStopPicking(Self, ARequest, AResponse, slPath);
          'putPartialInvProtocolDocDetailStartPicking': putPartialInvProtocolDocDetailStartPicking(Self, ARequest, AResponse, slPath);
          'putPartialInvProtocolDocDetailStopPicking': putPartialInvProtocolDocDetailStopPicking(Self, ARequest, AResponse, slPath);
          'putMainInvProtocolDocDetailStartPicking': putMainInvProtocolDocDetailStartPicking(Self, ARequest, AResponse, slPath);
          'putNewStoreBatch': putNewStoreBatch(Self, ARequest, AResponse, slPath);
          'putNewStoreBatches': putNewStoreBatches(Self, ARequest, AResponse, slPath);
          'saveInventorizationFree': saveInventorizationFree(Self, ARequest, AResponse, slPath);
          'putPackageShipping': putPackageShipping(Self, ARequest, AResponse, slPath);
          'putTransferWholePositionContents': putTransferWholePositionContents(Self, ARequest, AResponse, slPath);
          'putReceiptCardWithoutDocStopPicking': putWithoutDocStopPicking(Self, ARequest, AResponse, slPath);
          'putBillOfDeliveryWithoutDocStopPicking': putWithoutDocStopPicking(Self, ARequest, AResponse, slPath);
          'putReceivedOrdersWithoutDocStopPicking': putWithoutDocStopPicking(Self, ARequest, AResponse, slPath);
          'putWithoutDocStartPicking': putWithoutDocStartPicking(Self, ARequest, AResponse, slPath);
          'printRow': printRow(Self, ARequest, AResponse, slPath);
          'listDialogSelection': listDialogSelection(Self, ARequest, AResponse, slPath);
          'putLabelDefinitions': putLabelDefinitions(Self, ARequest, AResponse, slPath);
          'put_SaveStoreCardUnit': Put_SaveStoreCardUnit(Self, ARequest, AResponse, slPath);
          'putDispatchWholePosition': PutDispatchWholePosition(Self, ARequest, AResponse, slPath);
          'put_ProcessBarcode': put_ProcessBarcode(Self, ARequest, AResponse, slPath);
          'put_CodeResult': put_CodeResult(Self, ARequest, AResponse, slPath);
          'put_saveTransferBetweenPositionsQueue': put_SaveTransferBetweenPositionsQueue(Self, ARequest, AResponse, slPath);
          'put_FormatExpirationDate': put_FormatExpirationDate(Self, ARequest, AResponse, slPath);
          'put_SaveSmallAssetCards': put_SaveSmallAssetCards(Self, ARequest, AResponse, slPath);
          'put_SavePhoto': put_SavePhoto(Self, ARequest, AResponse, slPath);
          'putReceiptCardFromIOStopPicking': putQueueDocDetailStopPicking(Self, ARequest, AResponse, slPath);

          {'putCreateOutgoingSubstitution': PutCreateOutgoingSubstitution(Self, ARequest, AResponse, slPath);
          'prepareReceiptCardDocQueueTest': prepareReceiptCardDocQueueTest(Self, ARequest, AResponse, slPath);
          'receiptCardWithoutDocTest': ReceiptCardWithoutDocTest(Self, ARequest, AResponse, slPath);
          'removeWorkInProgress': removeWorkInProgress(Self, ARequest, AResponse, slPath);
          'checkResult': checkResult(Self, ARequest, AResponse, slPath);}
          else ErrREST(ARequest, AResponse, HTTP_SC_BadRequest);
        end;
      end;
    except
      ErrREST(ARequest, AResponse, HTTP_SC_ExpectationFailed, ExceptionMessage);
    end;
  finally
    //zrusim globalni promennou
    if(not NxIsEmptyOID(WS_User_ID))then
      GlobParams.DeleteByName('WS_User_ID');

    LogWriteDuration('SkladTerm PUT', ARequest, AResponse);
    glog.LeaveSection('SkladTerm PUT', logDebug);
    slPath.free;
    gLog.free;
  end;
end;
////////////////////////////////////////////////////////////////////////////////

begin
end.