uses '.lib';
{
Vyvolává se po uložení vlastních dat objektu do databáze.
}
procedure AfterSave_Hook(Self: TNxCustomBusinessObject);
var
  mOriginalString, mReceivedOrder_ID: string;
  mOrigSendCloudState: string;
begin
  Self.GetOriginalValue('X_TrackingNumber', mOriginalString);
  mReceivedOrder_ID:= GetReceivedOrderID(Self.ObjectSpace, Self.GetFieldValueAsString('X_ExternalNumber'));

  if NxIsEmptyOID(mReceivedOrder_ID) then
    exit;

  //if Self.DifferentFromOriginal_1('X_TrackingNumber') and (NxIsBlank(mOriginalString)) then
  //  UpdateReceivedOrderPMState(Self.ObjectSpace, mReceivedOrder_ID);

  if Self.DifferentFromOriginal_1('X_SC_State_ID') then
  begin
    if (Self.GetFieldValueAsString('X_SC_State_ID') in [cSC_STATE_ID_22_Shipment_picked_up_by_driver]) then
      UpdateReceivedOrderPMState(Self.ObjectSpace, mReceivedOrder_ID);

    if (Self.GetFieldValueAsString('X_SC_State_ID') = cSC_STATE_ID_11_DELIVERED) then
      UpdateReceivedOrderPMState(Self.ObjectSpace, mReceivedOrder_ID, cPMSTATE_ID_1100_COMPLETED);
  end;
end;


{
Vyvolává se před fyzickým uložením vlastních dat objektu do databáze.
}
procedure BeforeSave_Hook(Self: TNxCustomBusinessObject);
begin
  if Self.DifferentFromOriginal_1('X_SC_State_ID') and not(Self.GetFieldValueAsBoolean('X_GenerateInvoice')) then
  begin
    if (Self.GetFieldValueAsString('X_SC_State_ID') in [cSC_STATE_ID_22_Shipment_picked_up_by_driver,cSC_STATE_ID_91_Parcel_en_route,cSC_STATE_ID_62990_At_sorting_centre]) then
      Self.SetFieldValueAsBoolean('X_GenerateInvoice', True);
  end;
end;

procedure UpdateReceivedOrderPMState(AOS:TNxCustomObjectSpace; AReceivedOrder_ID: string; APMState_ID: string = '');
var
  mROBO: TNxCustomBusinessObject;
begin
  mROBO:= AOS.CreateObject(Class_ReceivedOrder);
  try
    mROBO.Load(AReceivedOrder_ID, nil);
    if NxIsEmptyOID(APMState_ID) then
    begin
      if mROBO.GetFieldValueAsBoolean('Closed') then
        mROBO.PMChangeState(cPMSTATE_ID_1070_DISPATCHED)
      else
        mROBO.PMChangeState(cPMSTATE_ID_1060_PARTIALLY_DISPATCHED);
    end else
    begin
      if not(mROBO.GetFieldValueAsBoolean('Closed')) and (APMState_ID = cPMSTATE_ID_1100_COMPLETED) then
        exit;
      mROBO.PMChangeState(APMState_ID);
    end;
  finally
    mROBO.Free;
  end;
end;




begin
end.