const
   cRowDescription2 = ['var_symbol','doklad','firma','dic','ic','datum','splatnost','mena_zbyva','mena'];
  cSeparator2 = ';';
  errStoreCardNotFound2 = 'Skladová karta s kodem %s nenalezena.';

{
  funkce rozloží vstupní parametry a uloží je do TNxParameters > hierarchická struktura s pojmenovanými parametry
  pořadí parametru v řetězcích a jejich pojmenování je definováno poli cHeadDescription a cRowDescription
}
function ParseData(ARows : TStrings ) : TNxParameters;
var
  mRows, mRow : TNxParameters;
  i, j, mPos : integer;
  mToken, mStr : string;
  x : TStringList;
begin
  OutputDebugString('Enter procedure ParseData');
  Result := TNxParameters.Create;
  mRows := TNxParameters(Result.GetOrCreateParam(dtList, 'rows', pkInput));
  for j := 0 to ARows.Count - 1 do begin
    mRow := TNxParameters(mRows.GetOrCreateParam(dtList, IntToStr(j), pkInput));
    mStr := ARows.Strings[j];
   for i := 0 to  Length(cRowDescription2) - 1 do begin
      mPos := AnsiPos(cSeparator2, mStr);
      if mPos = 0 then
        mPos := Length(mStr) + 1;
      mToken := NxLeft(mStr, mPos - 1);
      mStr := copy(mStr, mPos + 1, Length(mStr) - mPos);
      mRow.GetOrCreateParam(dtString, cRowDescription2[i], pkInput).AsString := Trim(mToken);
    end;
  end;

//  Result.GetOrCreateParam(dtString, 'id', pkInput).AsString := '0000000000';
  OutputDebugString('Leave procedure ParseData');
end;

function GetDivision_ID(AOS : TNxCustomObjectSpace; aCode : string) : string;
const
  cSQL = 'SELECT ID FROM Divisions WHERE Code=''%s''  ';
var
  mList : TStringList;
begin
  mList := TStringList.Create;
  try
    AOS.SQLSelect(Format(cSQL, [aCode]), mList);
    if mList.Count > 0 then
      Result := mList.Strings[0]
      else Result:='4100000101';
  finally
    mList.Free;
  end;
end;

function GetBusTransaction_ID(AOS : TNxCustomObjectSpace; aCode : string) : string;
const
  cSQL = 'SELECT ID FROM BusTransactions WHERE Code=''%s''  ';
var
  mList : TStringList;
begin
  mList := TStringList.Create;
  try
    AOS.SQLSelect(Format(cSQL, [aCode]), mList);
    if mList.Count > 0 then
      Result := mList.Strings[0]
      else Result:='';
  finally
    mList.Free;
  end;
end;

function GetPeriod_ID(AOS : TNxCustomObjectSpace; aCode : string) : string;
const
  cSQL = 'SELECT ID FROM Periods WHERE Code=''%s''  ';
var
  mList : TStringList;
begin
  mList := TStringList.Create;
  try
    AOS.SQLSelect(Format(cSQL, [aCode]), mList);
    if mList.Count > 0 then
      Result := mList.Strings[0]
      else Result:=''
  finally
    mList.Free;
  end;
end;

function GetFirm_ID(AOS : TNxCustomObjectSpace; aCode : string) : string;
const
  cSQL = 'SELECT ID FROM Firms WHERE orgidentnumber=''%s'' and hidden=''N'' ';
var
  mList : TStringList;
begin
  mList := TStringList.Create;
  try
    AOS.SQLSelect(Format(cSQL, [aCode]), mList);
    if mList.Count > 0 then
      Result := mList.Strings[0]
      else Result:=''
  finally
    mList.Free;
  end;
end;

function GetFirm2_ID(AOS : TNxCustomObjectSpace; aCode : string) : string;
const
  cSQL = 'SELECT ID FROM Firms WHERE vatidentnumber=''%s'' and hidden=''N'' ';
var
  mList : TStringList;
begin
  mList := TStringList.Create;
  try
    AOS.SQLSelect(Format(cSQL, [aCode]), mList);
    if mList.Count > 0 then
      Result := mList.Strings[0]
      else Result:=''
  finally
    mList.Free;
  end;
end;

begin
end.