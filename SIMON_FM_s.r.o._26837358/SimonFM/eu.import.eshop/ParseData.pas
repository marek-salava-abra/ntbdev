const
  cRowDescription2 = ['code','name','quantity','qunit','ean','upnuti', 'weight','wunit',
  'uhel','prumer','prumer2', 'delkab', 'Delkad','pouziti', 'material', 'zuby', 'Norma', 'DIN'];
  cRowDescription3 = ['code','name','quantity','ean','weight','wunit','dsize','Lsize','l2size',
  'uhel','uhel2','material','povrch','morse','tvar', 'Norma', 'DIN', 'upnuti','vyroba','pouziti','d','d1','d2','Din_text'];
  cRowDescription4 = ['code','name','quantity','qunit','ean','rez_kuzel','dsize','psize','l1size',
  'l2size','d2size','asize','zsize','material', 'DIN', 'katcislo','l235', 'z','n'];
   cRowDescription5 = ['code','name','quantity','qunit','ean','rez_kuzel','DIN'];
  cRowDescriptionSklicidla = ['code','name','quantity','ean','prumer','Up_R_E','F','Up_R_G',' Up_R_H',' Up_R_L','Up_R_J',
  'Up_R_K','R_N',' Up_R_O',' Up_R_P',' Up_R_R',' Up_R_S',' Up_R_T','typ_up',
  'trid_pres','Poc_cel','E_H7','F_02','G','H','J','K','L','N','O','R','S','T','U','CSN'];
  cRowDescriptionCelisti = ['code','name','quantity','ean','prumer','Up_R_E','F','Up_R_G',' Up_R_H',' Up_R_L','Up_R_J',
  'Up_R_K','R_N',' Up_R_O',' Up_R_P',' Up_R_R',' Up_R_S',' Up_R_T','typ_up',
  'trid_pres','Poc_cel','E_H7','F_02','G','H','J','K','L','N','O','R','S','T','U','CSN','E','M'];
  cSeparator2 = ';';      //řezný kužel	d1	P	l1	l2	d2	a	z

  errStoreCardNotFound2 = 'Skladová karta s kodem %s nenalezena.';
  cRowDescription = ['code','name','quantity','qunit','ean', 'weight','wunit','prumer', 'delkab', 'Delkad','prumer2','prumer3','morse1', 'morse2','pouziti', 'Norma', 'DIN'];

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
function ParseData5(ARows : TStrings ) : TNxParameters;
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
   for i := 0 to  Length(cRowDescription5) - 1 do begin
      mPos := AnsiPos(cSeparator2, mStr);
      if mPos = 0 then
        mPos := Length(mStr) + 1;
      mToken := NxLeft(mStr, mPos - 1);
      mStr := copy(mStr, mPos + 1, Length(mStr) - mPos);
      mRow.GetOrCreateParam(dtString, cRowDescription5[i], pkInput).AsString := Trim(mToken);
    end;
  end;

//  Result.GetOrCreateParam(dtString, 'id', pkInput).AsString := '0000000000';
  OutputDebugString('Leave procedure ParseData');
end;

function ParseData4(ARows : TStrings ) : TNxParameters;
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
   for i := 0 to  Length(cRowDescription4) - 1 do begin
      mPos := AnsiPos(cSeparator2, mStr);
      if mPos = 0 then
        mPos := Length(mStr) + 1;
      mToken := NxLeft(mStr, mPos - 1);
      mStr := copy(mStr, mPos + 1, Length(mStr) - mPos);
      mRow.GetOrCreateParam(dtString, cRowDescription4[i], pkInput).AsString := Trim(mToken);
    end;
  end;

//  Result.GetOrCreateParam(dtString, 'id', pkInput).AsString := '0000000000';
  OutputDebugString('Leave procedure ParseData');
end;

function ParseDataPouzdra(ARows : TStrings ) : TNxParameters;
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
   for i := 0 to  Length(cRowDescription) - 1 do begin
      mPos := AnsiPos(cSeparator2, mStr);
      if mPos = 0 then
        mPos := Length(mStr) + 1;
      mToken := NxLeft(mStr, mPos - 1);
      mStr := copy(mStr, mPos + 1, Length(mStr) - mPos);
      mRow.GetOrCreateParam(dtString, cRowDescription[i], pkInput).AsString := Trim(mToken);
    end;
  end;

//  Result.GetOrCreateParam(dtString, 'id', pkInput).AsString := '0000000000';
  OutputDebugString('Leave procedure ParseData');
end;

function ParseDataVrtaky(ARows : TStrings ) : TNxParameters;
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
   for i := 0 to  Length(cRowDescription3) - 1 do begin
      mPos := AnsiPos(cSeparator2, mStr);
      if mPos = 0 then
        mPos := Length(mStr) + 1;
      mToken := NxLeft(mStr, mPos - 1);
      mStr := copy(mStr, mPos + 1, Length(mStr) - mPos);
      mRow.GetOrCreateParam(dtString, cRowDescription3[i], pkInput).AsString := Trim(mToken);
    end;
  end;

//  Result.GetOrCreateParam(dtString, 'id', pkInput).AsString := '0000000000';
  OutputDebugString('Leave procedure ParseData');
end;

function ParseDataSklicidla(ARows : TStrings ) : TNxParameters;
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
   for i := 0 to  Length(cRowDescriptionSklicidla) - 1 do begin
      mPos := AnsiPos(cSeparator2, mStr);
      if mPos = 0 then
        mPos := Length(mStr) + 1;
      mToken := NxLeft(mStr, mPos - 1);
      mStr := copy(mStr, mPos + 1, Length(mStr) - mPos);
      mRow.GetOrCreateParam(dtString, cRowDescriptionSklicidla[i], pkInput).AsString := Trim(mToken);
    end;
  end;

//  Result.GetOrCreateParam(dtString, 'id', pkInput).AsString := '0000000000';
  OutputDebugString('Leave procedure ParseData');
end;

function ParseDataCelisti(ARows : TStrings ) : TNxParameters;
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
   for i := 0 to  Length(cRowDescriptionCelisti) - 1 do begin
      mPos := AnsiPos(cSeparator2, mStr);
      if mPos = 0 then
        mPos := Length(mStr) + 1;
      mToken := NxLeft(mStr, mPos - 1);
      mStr := copy(mStr, mPos + 1, Length(mStr) - mPos);
      mRow.GetOrCreateParam(dtString, cRowDescriptionCelisti[i], pkInput).AsString := Trim(mToken);
    end;
  end;

//  Result.GetOrCreateParam(dtString, 'id', pkInput).AsString := '0000000000';
  OutputDebugString('Leave procedure ParseData');
end;

function GetStoreCard_ID(AOS : TNxCustomObjectSpace; aCode : string) : string;
const
  cSQL = 'SELECT ID FROM StoreCards WHERE Code=''%s'' and hidden=''N'' ';
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

function GetStoreCardEAN_ID(AOS : TNxCustomObjectSpace; aCode : string) : string;
const
  cSQL = 'SELECT ID FROM StoreCards WHERE EAN=''%s'' and hidden=''N'' ';
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