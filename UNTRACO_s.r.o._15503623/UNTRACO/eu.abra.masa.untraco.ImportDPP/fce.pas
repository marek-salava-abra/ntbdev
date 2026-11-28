procedure AddStringsToSelDat(AOS : TNxCustomObjectSpace; AStation_ID: String; AValues: TStringList);
// Přidá do SelDat hodnoty ze StringListu pod AStation
var
  mStation_ID : String;
  i : Integer;
begin
  mStation_ID := aos.SQLSelectFirstAsString('Select ID from SelDef where ID = '+QuotedStr(AStation_ID), '');
  if NxIsEmptyOID(mStation_ID) then begin
    mStation_ID := AStation_ID;
    AOS.SQLExecute('Insert into SelDef (ID, Station) values ('+QuotedStr(mStation_ID) +', ''GeneratedByScript'')');
  end;
  For i:=0 to AValues.Count-1 do begin
    AOS.SQLExecute('Insert into SelDat (Sel_ID, Obj_ID) values ('+QuotedStr(mStation_ID) +', '+QuotedStr(AValues.Strings[i]) +')');
  end;
end;

procedure ClearSelDat(AOS : TNxCustomObjectSpace; AStation_ID: String);
// Smaže ze SelDat hodnoty pod AStation
begin
  AOS.SQLExecute('Delete from SelDef where ID = '+QuotedStr(AStation_ID));
end;

procedure StringsToSelDat(AOS : TNxCustomObjectSpace; AStation_ID: String; AValues: TStringList);
begin
  ClearSelDat(AOS, AStation_ID);
  AddStringsToSelDat(AOS, AStation_ID, AValues);
end;

function GenerateString(AChrCount: Integer): String;
Var
  i: integer;
  mResult, mSwitchResult: string;
  mSwitch: Array of string;

begin
  mResult:= '';
  SetLength(mSwitch,2);
  Randomize;
//Generuje pseudo-náhodný string o délce [AChrCount], složený z velkých a malých písmen a číslic
  for i := 0 to AChrCount -1 do begin
    //mSwitch[0]:= (Chr(ord('a') + RandomRange(0, 26)));
    mSwitch[0]:= (Chr(ord('A') + RandomRange(0, 26)));
    mSwitch[1]:= (Chr(ord('0') + RandomRange(0, 10)));
    mResult:= mResult + mSwitch[RandomRange(0, 2)];
  end;
  Result := mResult;
end;

begin
end.