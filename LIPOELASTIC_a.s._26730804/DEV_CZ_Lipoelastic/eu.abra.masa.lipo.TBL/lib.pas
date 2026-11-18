
Function POST_SetJobOrderToTBL(var AContext: TNXContext;var  AInput: TJSONSuperObject;var APath: String) : TJSONSuperObject;
var
  mBO, mUserXLink:TNxCustomBusinessObject;

begin
  Result:=TJSONSuperObject.Create;
  if not(NxIsEmptyOID(AInput.S['TransportBox_ID'])) then begin
    try
      mBO:=AContext.GetObjectSpace.CreateObject('TOKRQPFRTHA4ZAYQRXGRQKHED0');
      mBO.Load(AInput.S['TransportBox_ID'],nil);
      mBO.SetFieldValueAsString('X_JobOrder',AInput.S['JobOrder_ID']);
      mBO.SetFieldValueAsFloat('X_Quantity',AInput.D['Quantity']);
      mBO.SetFieldValueAsString('X_State_ID',AInput.S['TBState_ID']);
      mBO.SetFieldValueAsString('X_StoreBatch_ID',AInput.S['StoreBatch_ID']);
      mBO.SetFieldValueAsString('X_CreatedBy_ID',AInput.S['CreatedBy_ID']);
      mBO.SetFieldValueAsString('X_WorkstationName', AInput.S['WorkstationName']);
      mBO.save;
      mUserXLink := AContext.GetObjectSpace.CreateObject(Class_UserXLink);
      try
        mUserXLink.New;
        mUserXLink.Prefill;
        mUserXLink.SetFieldValueAsString('SourceCLSID', 'TOKRQPFRTHA4ZAYQRXGRQKHED0');
        mUserXLink.SetFieldValueAsString('Source_ID', mBO.OID);
        mUserXLink.SetFieldValueAsString('DestinationCLSID', Class_PLMJobOrder);
        mUserXLink.SetFieldValueAsString('Destination_ID', AInput.S['JobOrder_ID']);
        mUserXLink.SetFieldValueAsBoolean('DisplayAsSystem', True);
        mUserXLink.Save;
      except
        Result.S['Result']:='Error';
      end;
      mBO.Free;
    except
      Result.S['Result']:='Error';
    end;
   Result.S['Result']:='Ok';
  end;
  if (NxIsEmptyOID(AInput.S['TransportBox_ID'])) then Result.S['Result']:='Error';
end;

Function POST_RemoveJobOrderFromTBL(var AContext: TNXContext;var  AInput: TJSONSuperObject;var APath: String) : TJSONSuperObject;
var
  mBO, mUserXLink:TNxCustomBusinessObject;

begin
  Result:=TJSONSuperObject.Create;
  if not(NxIsEmptyOID(AInput.S['TransportBox_ID'])) then begin
    try
      mBO:=AContext.GetObjectSpace.CreateObject('TOKRQPFRTHA4ZAYQRXGRQKHED0');
      mBO.Load(AInput.S['TransportBox_ID'],nil);
      mBO.SetFieldValueAsString('X_JobOrder','');
      mBO.SetFieldValueAsFloat('X_Quantity',0);
      mBO.SetFieldValueAsString('X_State_ID',AInput.S['TBState_ID']);
      mBO.SetFieldValueAsString('X_StoreBatch_ID','');
      mBO.SetFieldValueAsString('X_CreatedBy_ID',AInput.S['CreatedBy_ID']);
      mBO.SetFieldValueAsString('X_WorkstationName', AInput.S['WorkstationName']);
      mBO.save;
      mBO.Free;
    except
      Result.S['Result']:='Error';
    end;
  end;
  Result.S['Result']:='Ok';
end;


function GetLatestCode(AOS:TNxCustomObjectSpace; ATable, ACLSID, APrefix:string; ANumericLen:integer;):string;
var
  mMaxCode: string;
begin
  if not(NxIsBlank(ACLSID)) then ACLSID:= ' AND CLSID ='+QuotedStr(ACLSID)+' ';
  mMaxCode:= AOS.SQLSelectFirstAsString('SELECT MAX(Code) FROM '+ATable+' WHERE Code LIKE '+QuotedStr(APrefix+NxReplicate('_', ANumericLen))+ACLSID);
  if mMaxCode = '' then
    Result:= APrefix+NxPadL('1',4, '0')
  else
    Result:= APrefix+NxPadL(IntToStr(StrToInt(NxRight(mMaxCode, ANumericLen))+1), 4, '0');
end;

begin
end.