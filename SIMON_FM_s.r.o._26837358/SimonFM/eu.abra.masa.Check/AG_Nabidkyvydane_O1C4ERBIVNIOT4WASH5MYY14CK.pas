procedure _CanSaveNow_Hook(Self: TDynSiteForm; var ACanSaveNow: Boolean);
var
 mCurrBO:TNxCustomBusinessObject;
 mZLV_ID:string;
 mOS:TNxCustomObjectSpace;
 mOrigValue:String;
begin
  mCurrBO:=TDynSiteForm(self).CurrentObject;
  if (mCurrBO.GetFieldValueAsString('DocQueue_ID')='2900000101') then begin
    ACanSaveNow:=True;
    if NxIsEmptyOID(mCurrBO.GetFieldValueAsString('TransportationType_ID')) then begin
      NxShowSimpleMessage('Není vybrán způsob dopravy.', self);
      ACanSaveNow:=false;
    end;
  end;
end;

begin
end.