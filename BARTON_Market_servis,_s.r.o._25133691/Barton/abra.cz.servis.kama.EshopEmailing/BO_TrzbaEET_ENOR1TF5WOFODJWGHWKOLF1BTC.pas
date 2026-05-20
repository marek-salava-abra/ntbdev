uses 'abra.cz.servis.kama.EshopEmailing.common';

var mPrevState: Integer;

procedure BeforeSave_Hook(Self: TNxCustomBusinessObject);
begin
  Self.GetOriginalValue_2('TurnoverState', mPrevState);
end;


procedure _FinalizeSave_PreHook(Self: TNxCustomBusinessObject);
var mOIBO: TNxCustomBusinessObject;
  mOIID: string;
begin
  mOIID := '';
  try
    if Self.GetFieldValueAsString('MasterDocumentType') = '01' then begin
      if (Self.GetFieldValueAsInteger('TurnoverState') <> mPrevState) and (Self.GetFieldValueAsInteger('TurnoverState') = 2) then begin
        mOIID := Self.GetFieldValueAsString('MasterDocument_ID');
        if not NxIsEmptyOID(mOIID) then begin
          mOIBO := Self.ObjectSpace.CreateObject(Class_OtherIncome);
          try
            mOIBO.Load(mOIID, nil);
            EshopAction(mOIBO, 7)
          finally
            mOIBO.free;
          end;
        end;
      end;
    end;
  except
    NxScriptingLog.WriteEvent(logDebug, ExceptionMessage);
    OutputDebugString(ExceptionMessage);
  end;
end;


begin
end.
