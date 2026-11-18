





{
  Vytvori datovy 'stream' pro preposlani pres AWS
}
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