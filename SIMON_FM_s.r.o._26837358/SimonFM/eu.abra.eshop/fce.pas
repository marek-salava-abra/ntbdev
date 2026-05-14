function scrFirm_ID(AOS : TNxCustomObjectSpace; AFieldName : string; AValue : string) : string;
const
  cSQL = 'SELECT ID FROM Firms WHERE %s like ''%s'' and Hidden=''N''';
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

function ElementExists(mXMLHead : TNxScriptingXMLWrapper; AName: string): Boolean;
begin
  try
    if mXMLHead.getElementAsString(AName) then Result:= True;
  except
    Result:= False
  end;
end;

function scrFirm2_ID(AOS : TNxCustomObjectSpace; AValue : string) : string;
const
  cSQL = 'SELECT f.ID FROM Firms f left join addresses a on a.id=f.residenceAddress_id WHERE a.email=''%s'' and f.Hidden=''N''';
var
  mList : TStringList;
begin
  mList := TStringList.create;
  try
    AOS.SQLSelect(Format(cSQL, [ AValue]), mList);
    Result:='';
    if mList.Count > 0 then
      Result := mList.Strings[0]
  finally
    mList.Free;
  end;
end;

function scrGetORder_ID(AOS : TNxCustomObjectSpace;  AValue : string) : string;
const
  cSQL = 'SELECT ID FROM receivedorders WHERE ExternalNumber=''%s'' and DocQueue_ID=''1W10000101'' ';
var
  mList : TStringList;
begin
  mList := TStringList.create;
  try
    AOS.SQLSelect(Format(cSQL, [AValue]), mList);
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


begin
end.