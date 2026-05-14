uses
  'REST_SkladTerm_Special.U_Aspera',
  'REST_SkladTerm_Special.U_ExpressAlarm',
  'REST_SkladTerm_Special.U_Obaly',
  'REST_SkladTerm_Special.U_Poltrade',
  'REST_SkladTerm_Special.U_Roka';

function processSpecialGetRequests(Self: TNxWebServicesHelper; ARequest: TNxHTTPRequest; AResponse: TNxHTTPResponse; slPath: TStringList): Boolean;
begin
  {Result := True;
  case slPath.Strings[0] of
    // ASPERA
    'getAsperaAvailableQuantityInFirmPlan': getAsperaAvailableQuantityInFirmPlan(Self, ARequest, AResponse, slPath);

    // OBALY
    'listShippingListsDocQueue': listShippingListsDocQueue(Self, ARequest, AResponse, slPath);
    'getPersonalDelivery': getPersonalDelivery(Self, ARequest, AResponse, slPath);

    // Poltrade
    'listTypObalu': listTypObalu(Self, ARequest, AResponse, slPath);

    else} Result := False;
  //end;
end;

function processSpecialPutRequests(Self: TNxWebServicesHelper; ARequest: TNxHTTPRequest; AResponse: TNxHTTPResponse; slPath: TStringList): Boolean;
begin
  Result := True;
  {case slPath.Strings[0] of
    // ASPERA
    'putAsperaBillOfDeliveryWithoutDocStopPicking': putAsperaBillOfDeliveryWithoutDocStopPicking(Self, ARequest, AResponse, slPath);

    // ROKA Kominy
    'putRokaBillOfDeliveryWithoutDocStopPicking': putRokaBillOfDeliveryWithoutDocStopPicking(Self, ARequest, AResponse, slPath);
    'putRokaCreateFAVOrPP': putRokaCreateFAVOrPP(Self, ARequest, AResponse, slPath);

    // OBALY
    'putPersonalDelivery': putPersonalDelivery(Self, ARequest, AResponse, slPath);
    'putShippingListsQueueDocDetailStartPicking': putShippingListsQueueDocDetailStartPicking(Self, ARequest, AResponse, slPath);
    'putShippingListsQueueDocDetailCancelPicking': putShippingListsQueueDocDetailCancelPicking(Self, ARequest, AResponse, slPath);
    'putObalyShippingListsQueueDocDetailStopPicking': putObalyShippingListsQueueDocDetailStopPicking(Self, ARequest, AResponse, slPath);

    // Poltrade
    'putPoltradeNewStoreBatch': putPoltradeNewStoreBatch(Self, ARequest, AResponse, slPath);
    'putValuesFromSpecialBarcode': PutValuesFromSpecialBarcode(Self, ARequest, AResponse, slPath);

    // Express Alarm
    'expressChangePosition': expressChangePosition(Self, ARequest, AResponse, slPath);

    else} Result := False;
  //end;
end;

function processSpecialPostRequests(Self: TNxWebServicesHelper; ARequest: TNxHTTPRequest; AResponse: TNxHTTPResponse; slPath: TStringList): Boolean;
begin
  Result := True;
  //case slPath.Strings[0] of

  //  else
      Result := False;
  //end;
end;

begin
end.