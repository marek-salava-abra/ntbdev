procedure _CanSaveNow_Hook(Self: TDynSiteForm; var ACanSaveNow: Boolean);
var
 mCurrBO:TNxCustomBusinessObject;
 mZLV_ID:string;
 mOS:TNxCustomObjectSpace;
 mOrigValue:String;
begin
  mCurrBO:=TDynSiteForm(self).CurrentObject;
  if (mCurrBO.GetFieldValueAsString('DocQueue_ID')='7RQ0000101') then begin
    ACanSaveNow:=True;
    if NxIsEmptyOID(mCurrBO.GetFieldValueAsString('TransportationType_ID')) then begin
      NxShowSimpleMessage('Není vybrán způsob dopravy.', self);
      ACanSaveNow:=false;
    end;
  end;
  if (mCurrBO.GetFieldValueAsString('DocQueue_ID')='1W10000101') then begin
    mCurrBO.GetOriginalValue('U_orderState_ID', mOrigValue);
    if not(mCurrBO.GetFieldValueAsString('U_orderState_ID')='5C92000101') and (mOrigValue='5C92000101') then begin
      if (mCurrBO.GetFieldValueAsString('PaymentType_ID')='6000000101') then begin
       if NxMessageBox('Dotaz','Měníte stav objednávky z Přijato na '+mCurrBO.GetFieldValueAsString('U_orderState_ID.Name')+', doopravdy uložit?', mdConfirm, mdbYesNo, 0, 0, False, Nil)=mrYes then ACanSaveNow:=True else ACanSaveNow:=false;
      end else begin
       ACanSaveNow:=True;
      end;
    end;
  end;
end;

begin
end.