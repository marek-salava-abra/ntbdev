uses 'abra.cz.servis.kama.EshopEmailing.common';

var mNewDoc: Boolean;
    mOrigStatus: Integer;



procedure AfterSave_Hook(Self: TNxCustomBusinessObject);
begin
  mNewDoc := NxCheckBit(Self.State, osNew);
  if (Self.GetFieldCode('X_PD_Status') > 0) then begin
    Self.GetOriginalValue_2('X_PD_Status', mOrigStatus);
  end;
end;


procedure _FinalizeSave_PreHook(Self: TNxCustomBusinessObject);
begin
  try
    if mNewDoc and (NxCheckBit(Self.State, osInvalid) = false) then begin
      EshopAction(self, 18)
    end;
    //exportováno
    if (Self.GetFieldCode('X_PD_Status') > 0) then begin
      if (NxCheckBit(Self.State, osInvalid) = false) and (Self.GetFieldValueAsInteger('X_PD_Status') = 2) and (mOrigStatus < 2) then begin
        EshopAction(self, 22)
      end;
    end;
    //uzavřeno
    if (Self.GetFieldCode('X_PD_Status') > 0) then begin
      if (NxCheckBit(Self.State, osInvalid) = false) and (Self.GetFieldValueAsInteger('X_PD_Status') = 3) and (mOrigStatus < 3) then begin
        EshopAction(self, 26)
      end;
    end;

  except
    NxScriptingLog.WriteEvent(logDebug, ExceptionMessage);
    OutputDebugString(ExceptionMessage);
  end;
end;


begin
end.

