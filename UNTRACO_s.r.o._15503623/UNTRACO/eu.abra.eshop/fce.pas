function scrFirm_ID(AOS : TNxCustomObjectSpace; AFieldName : string; AValue : string) : string;
const
  cSQL = 'SELECT ID FROM Firms WHERE %s like ''%s'' and Hidden=''N'' and firm_id is null ';
var
  mList : TStringList;
begin
  mList := TStringList.create;
  try
    AOS.SQLSelect(Format(cSQL, [AFieldName, AValue]), mList);
    Result:='';
    if mList.Count > 0 then
      Result := mList.Strings[0]
  finally
    mList.Free;
  end;
end;

function scrGetORder_ID(AOS : TNxCustomObjectSpace;  AValue : string; BValue:string) : string;
const
  cSQL = 'SELECT ID FROM receivedorders WHERE X_ES_ID=''%s'' and DocQueue_ID=''B100000101'' and (period_id=''%s'' or period_id=''2F00000101'') and not(createdby_id=''1H00000101'') ';
var
  mList : TStringList;
begin
  mList := TStringList.create;
  try
    AOS.SQLSelect(Format(cSQL, [AValue, BValue]), mList);
    Result:='';
    if mList.Count > 0 then
      Result := mList.Strings[0]
  finally
    mList.Free;
  end;
end;

function MakeOutputStreamFromFile(const AFileName : string; ADelete : boolean) : string;
var
  mStream : TFileStream;
  i : int64;
  mRes : string;
  mBuff : integer;
  pBuff : pointer;
begin
  Result := '';
  if FileExists(AFileName) then begin
    mStream := TFileStream.Create(AFileName, fmOpenRead, 0);
    try
      try
        mStream.Position := 0;
        mRes := '';
        pBuff := @mBuff;
        for i := 0 to mStream.Size - 1 do begin
          mBuff := 0;
          mStream.Read(pBuff, 1);
          mRes := mRes + IntToHex(mBuff, 2);
        end;
        Result := mRes;
      finally
        mStream.Free;
      end;
    finally
      if ADelete then
        DeleteFile(AFileName);
    end;
  end;
end;

function ElementExists(mHlavicka : TNxScriptingXMLWrapper; AName: string): Boolean;

begin
 NxScriptingLog.EnterSection('ElementExists',logInfo);
 NxScriptingLog.WriteEvent(logInfo,'poprve '+AName);
  try
    if not(mHlavicka.getElementAsString(AName)='') then Result:= True;
    NxScriptingLog.WriteEvent(logInfo,'podruhe '+AName);
  except
    NxScriptingLog.WriteEvent(logInfo,ExceptionMessage);
    Result:= False;
  end;
 NxScriptingLog.LeaveSection('ElementExists',logInfo);
end;


function GetFirmE_ID(AOS : TNxCustomObjectSpace; aEmail : string) : string;
const
  cSQL = 'SELECT F.ID FROM Firms F left join addresses a on a.id=f.ResidenceAddress_ID where A.Email=''%s'' and f.hidden=''N'' and f.firm_id is null';
var
  mList : TStringList;
begin
  mList := TStringList.Create;
  try
    AOS.SQLSelect(Format(cSQL, [aEmail]), mList);
    if mList.Count > 0 then
      Result := mList.Strings[0]
      else Result:=''
  finally
    mList.Free;
  end;
end;

function GetPeriod_ID(AOS: TNxCustomObjectSpace; ADate: TDate): string;
var
  mList: TStringList;
begin
  Result:='';
  mList:=TStringList.Create;
  AOS.SQLSelect('Select P.ID from Periods P '+
                        'where '+FloatToStr(DateOf(ADate))+' between P.DateFrom$DATE and P.DateTo$DATE', mList);
  if mList.Count>0 then begin
    Result:=mList.Strings(0);
  end;
end;

begin
end.