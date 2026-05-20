uses 'abra.cz.servis.kama.EshopEmailing.common';

var mNewDoc: Boolean;

procedure AfterSave_Hook(Self: TNxCustomBusinessObject);
begin
  mNewDoc := NxCheckBit(Self.State, osNew);
end;


procedure _FinalizeSave_PreHook(Self: TNxCustomBusinessObject);
var mActValue: string;
begin
  try
    if NxCheckBit(Self.State, osInvalid) = false then begin
      if mNewDoc then
        EshopAction(self, 23);
    end;
  except
    NxScriptingLog.WriteEvent(logDebug, ExceptionMessage);
    OutputDebugString(ExceptionMessage);
  end;
end;


begin
end.
