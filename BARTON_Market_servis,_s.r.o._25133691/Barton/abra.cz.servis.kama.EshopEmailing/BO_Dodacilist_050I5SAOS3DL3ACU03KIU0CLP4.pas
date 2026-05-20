uses 'abra.cz.servis.kama.EshopEmailing.common';

var mNewDoc: Boolean;
    mBillID, mOldPMStateID: string;
    mParPMStatesOn, mPMSystemState: integer;

procedure Validate_Hook(Self: TNxCustomBusinessObject; var AResult: Boolean);
begin
   Self.GetOriginalValue('PMState_ID', mOldPMStateID);
end;


procedure AfterSave_Hook(Self: TNxCustomBusinessObject);
begin
  mParPMStatesOn := GetCompanyParam(Self.ObjectSpace, 'FOLNYX32RHV4P5CP55PSBN2214');
  mPMSystemState := Self.GetFieldValueAsInteger('PMState_ID.SystemState');
  mNewDoc := NxCheckBit(Self.State, osNew);
  mBillID := Self.OID;
end;

procedure _FinalizeSave_PreHook(Self: TNxCustomBusinessObject);
var mOrderObj: TNxCustomBusinessObject;
  mSQL: string;
  mStr: TStrings;
  i: Integer;
begin
  if NxCheckBit(Self.State, osInvalid) = false then begin
    if mBillID = Self.OID then begin
      if (mNewDoc and ((mParPMStatesOn = 0) or (mPMSystemState = 3))) or ((mParPMStatesOn = 1) and (mPMSystemState = 3)) then begin
        try
          EshopAction(self, 10); //odeslání DL

          //objednávky svázané s DL
          mSQL := Format('Select distinct(Provide_ID) from StoreDocuments2 where Parent_ID=%s', [QuotedStr(Self.OID)]);
          mStr := TStringList.Create;
          try
            Self.ObjectSpace.SQLSelect(mSQL, mStr);
            for i := 0 to mStr.Count - 1 do begin
              if not NxIsEmptyOID(mStr.Strings[i]) then begin
                mOrderObj := Self.ObjectSpace.CreateObject(Class_ReceivedOrder);
                try
                  mOrderObj.Load(mStr.Strings[i], nil);
                  if mOrderObj.GetFieldValueAsBoolean('Closed') then begin
                    EshopAction(mOrderObj, 4);
                  end else begin
                    EshopAction(mOrderObj, 3);
                  end;
                finally
                  mOrderObj.Free;
                end;
              end;
            end;
          finally
            mStr.free;
          end;
        except
          NxScriptingLog.WriteEvent(logDebug, ExceptionMessage);
          OutputDebugString(ExceptionMessage);
        end;
      end;
    end;

    //změna proces. stavu
    if (mParPMStatesOn = 1) and (mOldPMStateID <> Self.GetFieldValueAsString('PMState_ID')) then begin
      EshopAction(self, 25, Self.GetFieldValueAsString('PMState_ID'));
    end;
  end;
end;


begin
end.
