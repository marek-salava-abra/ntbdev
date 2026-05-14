//rozebere radek dle fixnich hranic na jednotlive tokeny
procedure LoadFixedSizeIntoStrings(ALine: String; AStrings: TStrings; ALengths: array of Integer);
var
  i, mCurr, mLen: Integer;
begin
  AStrings.Clear;
  mCurr := 1;
  for i := 0 to Length(ALengths)-1 do begin
    mLen := ALengths[i];
    AStrings.Add(Trim(Copy(ALine, mCurr, mLen)));
    Inc(mCurr, mLen);
  end;
end;

//odstrani mezery v retezci
function NoSpace(s:string):string;
var
 i: integer;
begin
  S := Trim(S);
  Result := '';
  for i := 1 to Length(S) do
    if s[i]<> ' ' then Result := Result + s[i];
end;


begin
end.