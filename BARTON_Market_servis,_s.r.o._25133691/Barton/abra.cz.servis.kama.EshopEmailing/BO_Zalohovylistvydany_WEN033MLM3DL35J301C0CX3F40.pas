uses 'abra.cz.servis.kama.EshopEmailing.common';

var mNewDoc: Boolean;

procedure AfterSave_Hook(Self: TNxCustomBusinessObject);
begin
  mNewDoc := NxCheckBit(Self.State, osNew);
end;

procedure _FinalizeSave_PreHook(Self: TNxCustomBusinessObject);
begin
  try
    if mNewDoc and (NxCheckBit(Self.State, osInvalid) = false) then begin
      if Self.GetFieldValueAsInteger('PaymentType_ID.PaymentKind') <> 8 then
        EshopAction(self, 5)
    end;
  except
    NxScriptingLog.WriteEvent(logDebug, ExceptionMessage);
    OutputDebugString(ExceptionMessage);
  end;
end;

//pro platbu
procedure _BeforeDwarfSave_Hook(Self: TNxCustomBusinessObject; ADwarfCode: Integer);
begin
  try
   if (Self.DifferentFromOriginal_1('PaidAmount')) and (Self.GetFieldValueAsFloat('PaidAmount') = Self.GetFieldValueAsFloat('Amount')) then begin
     if (Self.GetFieldValueAsInteger('PaymentType_ID.PaymentKind') <> 8) then begin
      EshopAction(self, 20);
     end
     else if (Self.GetFieldValueAsInteger('PaymentType_ID.PaymentKind') = 8) then begin
      EshopAction(self, 24);
     end;
   end else if (Self.DifferentFromOriginal_1('PaidAmount')) and (Self.GetFieldValueAsFloat('PaidAmount') < Self.GetFieldValueAsFloat('Amount')) and (Self.GetFieldValueAsFloat('PaidAmount')<>0) then begin
     if (Self.GetFieldValueAsInteger('PaymentType_ID.PaymentKind') <> 8) then
      EshopAction(self, 27);
   end;
  except
    NxScriptingLog.WriteEvent(logDebug, ExceptionMessage);
    OutputDebugString(ExceptionMessage);
  end;
end;


begin
end.

