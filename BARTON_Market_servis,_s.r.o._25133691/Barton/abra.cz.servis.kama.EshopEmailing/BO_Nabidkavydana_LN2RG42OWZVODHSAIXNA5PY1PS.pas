uses 'abra.cz.servis.kama.EshopEmailing.common';

var mNewDoc: Boolean;
  mOrigStateID: string;

procedure BeforeSave_Hook(Self: TNxCustomBusinessObject);
begin
  Self.GetOriginalValue('OfferState_ID', mOrigStateID);
end;


procedure AfterSave_Hook(Self: TNxCustomBusinessObject);
begin
  mNewDoc := NxCheckBit(Self.State, osNew);
end;


procedure _AfterDwarfSave_Hook(Self: TNxCustomBusinessObject; ADwarfCode: Integer);
var mActValue: string;
begin
  if ADwarfCode = 23 then begin
    mNewDoc := NxCheckBit(Self.State, osNew);
    try
      if NxCheckBit(Self.State, osInvalid) = false then begin
        if mNewDoc then begin
          EshopAction(self, 11);
        end else begin
          if (mOrigStateID <> Self.GetFieldValueAsString('OfferState_ID')) then
            EshopAction(self, 12, Self.GetFieldValueAsString('OfferState_ID'));
        end;
      end;
    except
      NxScriptingLog.WriteEvent(logDebug, ExceptionMessage);
      OutputDebugString(ExceptionMessage);
    end;
  end;
end;


procedure _BeforeDwarfSave_Hook(Self: TNxCustomBusinessObject; ADwarfCode: Integer);
begin
  if ADwarfCode = 23 then
    Self.GetOriginalValue('OfferState_ID', mOrigStateID);
end;

procedure _FinalizeSave_PreHook(Self: TNxCustomBusinessObject);
var mActValue: string;
begin
  try
    if NxCheckBit(Self.State, osInvalid) = false then begin
      if mNewDoc then begin
        EshopAction(self, 11);
      end else begin
        if (mOrigStateID <> Self.GetFieldValueAsString('OfferState_ID')) then
          EshopAction(self, 12, Self.GetFieldValueAsString('OfferState_ID'));
      end;
    end;
  except
    NxScriptingLog.WriteEvent(logDebug, ExceptionMessage);
    OutputDebugString(ExceptionMessage);
  end;
end;


begin
end.
