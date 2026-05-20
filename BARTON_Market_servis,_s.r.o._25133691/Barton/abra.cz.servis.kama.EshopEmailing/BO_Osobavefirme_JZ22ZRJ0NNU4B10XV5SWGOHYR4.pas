uses 'abra.cz.servis.kama.EshopEmailing.common';

var mNewDoc: Boolean;

procedure AfterSave_Hook(Self: TNxCustomBusinessObject);
begin
  mNewDoc := NxCheckBit(Self.State, osNew);
end;

procedure _FinalizeSave_PreHook(Self: TNxCustomBusinessObject);
var mOrigValueUser: string;
begin
  try
    if mNewDoc and (NxCheckBit(Self.State, osInvalid) = false) then begin
      if not NxIsBlank(Self.GetFieldValueAsString('Person_ID.X_USER')) then begin
        if Self.GetFieldValueAsInteger('Parent_ID.ObjVersion') > 0 then begin
          if GetFieldExists(Self.ObjectSpace, Self.GetFieldValueAsString('Person_ID'), 'X_EshopID') then
            EshopAction(self, 0, Self.GetFieldValueAsString('Person_ID.X_EshopID'))
          else
            EshopAction(self, 0, '');
        end;
      end;
    end;
  except
    NxScriptingLog.WriteEvent(logDebug, ExceptionMessage);
    OutputDebugString(ExceptionMessage);
  end;
end;

function GetFieldExists(AOS: TNxCustomObjectSpace; AID, AFieldName: String): Boolean;
var mBO: TNxCustomBusinessObject;
begin
  result := false;
  if not NxIsEmptyOID(AID) then begin
    mBO := AOS.CreateObject(Class_Person);
    try
      mBO.Load(AID, nil);
      result := mBO.GetFieldCode(AFieldName) > 0;
    finally
      mBO.Free;
    end;
  end;
end;

function GetPrevFirms(AOS: TNxCustomObjectSpace; AFirmID: string): integer;
var mStr: TStrings;
  mSQL: string;
begin
  try
    result := 0;
    mSQL := Format('Select count(ID) from Firms where Firm_ID=%s', [QuotedStr(AFirmID)]);
    mStr := TStringList.Create;
    try
      AOS.SQLSelect(mSQL, mStr);
      if mStr.Count > 0 then
        result := StrToInt(mStr.Strings[0]);
    finally
      mStr.free;
    end;
  except
    NxScriptingLog.WriteEvent(logDebug, ExceptionMessage);
    OutputDebugString(ExceptionMessage);
  end;
end;

begin
end.
