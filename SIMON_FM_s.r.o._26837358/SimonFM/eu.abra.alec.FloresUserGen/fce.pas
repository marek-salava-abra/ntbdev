function GenerateNum(AChrCount: Integer): String;
Var
  i: integer;
  mResult, mSwitchResult: string;
  mSwitch: Array of string;

begin
  mResult:= '';
  SetLength(mSwitch,3);
  Randomize;
//Generuje pseudo-náhodný string o délce [AChrCount], složený z velkých a malých písmen a číslic
  for i := 0 to AChrCount -1 do begin
    mSwitch[0]:= (Chr(ord('a') + RandomRange(0, 26)));
    mSwitch[1]:= (Chr(ord('A') + RandomRange(0, 26)));
    mSwitch[2]:= (Chr(ord('0') + RandomRange(0, 10)));
    mResult:= mResult + mSwitch[RandomRange(0, 3)];
  end;
  Result := mResult;
end;

begin
end.