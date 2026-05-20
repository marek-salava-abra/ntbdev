uses 'abra.cz.servis.kama.EshopEmailing.common';

var mNewDoc: Boolean;
    mOrigProcessID: string;

procedure BeforeSave_Hook(Self: TNxCustomBusinessObject);
begin
  Self.GetOriginalValue('ActivityProcess_ID', mOrigProcessID);
end;

procedure AfterSave_Hook(Self: TNxCustomBusinessObject);
begin
  mNewDoc := NxCheckBit(Self.State, osNew);
end;

procedure _FinalizeSave_PreHook(Self: TNxCustomBusinessObject);
var mActValue: string;
begin
  try
    if NxCheckBit(Self.State, osInvalid) = false then begin
      if (mOrigProcessID <> Self.GetFieldValueAsString('ActivityProcess_ID')) then
        EshopAction(self, 13, Self.GetFieldValueAsString('ActivityProcess_ID'));
    end;
  except
    NxScriptingLog.WriteEvent(logDebug, ExceptionMessage);
    OutputDebugString(ExceptionMessage);
  end;
end;


begin
end.