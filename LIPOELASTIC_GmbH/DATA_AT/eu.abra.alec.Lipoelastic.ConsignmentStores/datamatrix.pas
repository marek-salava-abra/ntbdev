uses '.const';

function ParseEAN(AOS: TNxCustomObjectSpace; AModule, ADocType, AUser_ID, ABarcode: string): string;
var
  mAIMap, mTokens: TStringList;
  mCode: string;
begin
  mAIMap := BuildAIMap;
  try
    mTokens := TokenizeGS1(SanitizeGS1String(ABarcode), mAIMap);
    try
      result:= mTokens.Text;
    finally
      mTokens.Free;
    end;
  finally
    mAIMap.Free;
  end;
end;


function BuildAIMap(): TStringList;
begin
  Result := TStringList.Create;
  // kód = (F/V):délka
  Result.Add('00=F:18'); // SSCC
  Result.Add('01=F:14'); // GTIN
  Result.Add('02=F:14'); // GTIN of contained trade item
  //Result.Add('10=V:20'); // Batch/Lot
  Result.Add('10=F:15'); // Batch/Lot - upravené
  Result.Add('11=F:6');  // Production date
  Result.Add('12=F:6');  // Due date
  Result.Add('13=F:6');  // Packaging date
  Result.Add('15=F:6');  // Best before
  Result.Add('17=F:6');  // Expiration date
  Result.Add('20=F:2');  // Internal product variant
  //Result.Add('21=V:20'); // Serial number
  Result.Add('30=V:8');  // Count of items
  Result.Add('37=V:8');  // Quantity/units contained
  Result.Add('240=V:30'); // Additional product ID
  // 310x = Net weight in kg with x decimal places, fixní délka 6
  // pro jednoduchost uvedeme základní prefix, číslice 0–9 za ním určuje desetinná místa
  //Result.Add('310=F:7');  // prefix, při parsování kontroluj i 4. znak
end;


function SanitizeGS1String(const ABarCode: string): string;
const
  GS = Chr(29);
begin
  // pracujeme s kopií, ať nešaháme do originálu
  Result := ABarCode;

  // 1) URL-encoding na normální znaky
  Result := CFxInternet.URLDecode(Result);

  // 2) JSON \u001d -> <GS>
  Result := NxSearchReplace(Result, '\u001d', GS, [srAll]);

  // 3) Náhradní oddělovače (# nebo ~) -> <GS>
  Result := NxSearchReplace(Result, '#', GS, [srAll]);
  Result := NxSearchReplace(Result, '~', GS, [srAll]);

  //Result := NxSearchReplace(Result, '/b', GS, [srAll]);
  if Pos('/b', Result) > 0 then
    Insert(GS, Result, Pos('/b', Result) + Length('/b'));
  if Pos('/_', Result) > 0 then
  Insert(GS, Result, Pos('/_', Result) + Length('/_'));

  // 4) Odstranit případný AIM prefix ]C1
  if StartsText(']C1', Result) then
    Delete(Result, 1, 3);

  // 4) Odstranit případný AIM prefix ]D2  - jiný standard
  if StartsText(']D2', Result) then
    Delete(Result, 1, 3);

  Result:= NxSearchReplace(Result, '-A', GS, [srAll]);
  Result:= NxSearchReplace(Result, '-B', GS, [srAll]);


  // 5) Ořezat whitespace okolo
  Result := Trim(Result);
end;


function TokenizeGS1(const ABarCode: string; AIMap: TStringList): TStringList;
const
  GS = Chr(29);
var
  mRest, mAI, mVal: string;
  mFixed: Boolean;
  mLen, mNextPos, mGSPos: Integer;
  mProbeAI: string;
  mProbeFixed: Boolean;
  mProbeLen: Integer;
begin
  Result := TStringList.Create;
  mRest := ABarCode;

  while mRest <> '' do
  begin
    // najdi další AI na začátku zbytku
    if not FindAI(mRest, AIMap, mAI, mFixed, mLen) then
      Break;

    // odstřihni AI kód
    Delete(mRest, 1, Length(mAI));

    if mFixed then
    begin
      // pevná délka
      mVal := Copy(mRest, 1, mLen);
      Delete(mRest, 1, mLen);
    end else
    begin
      // 1) terminátor <GS>, pokud je (a nepřekročí max délku)
      mGSPos := Pos(GS, mRest);
      if (mGSPos > 0) and ((mLen = 0) or (mGSPos - 1 <= mLen)) then
      begin
        mVal := Copy(mRest, 1, mGSPos - 1);
        Delete(mRest, 1, mGSPos); // přeskoč i GS
      end
      else
      begin
        // 2) hledej další AI jako konec proměnné hodnoty
        //    nezačínej na 1 (min délka proměnné hodnoty je 1)
        mNextPos := 2;
        while mNextPos <= Length(mRest) do
        begin
          if FindAI(Copy(mRest, mNextPos, 4), AIMap, mProbeAI, mProbeFixed, mProbeLen) or
             FindAI(Copy(mRest, mNextPos, 3), AIMap, mProbeAI, mProbeFixed, mProbeLen) or
             FindAI(Copy(mRest, mNextPos, 2), AIMap, mProbeAI, mProbeFixed, mProbeLen) then
          begin
            // ignoruj '00' (SSCC) uprostřed proměnné hodnoty
            if mProbeAI <> '00' then Break;
          end;
          Inc(mNextPos);
        end;

        if mNextPos <= Length(mRest) then
        begin
          // našli jsme další AI
          mVal := Copy(mRest, 1, mNextPos - 1);
          Delete(mRest, 1, mNextPos - 1);
        end
        else
        begin
          // 3) žádný další AI: ořízni na max. délku (pokud je známá), jinak vezmi zbytek
          if (mLen > 0) and (Length(mRest) > mLen) then
          begin
            mVal := Copy(mRest, 1, mLen);
            Delete(mRest, 1, mLen);
          end
          else
          begin
            mVal := mRest;
            mRest := '';
          end;
        end;
      end;
    end;

    // ulož hodnotu pod PŮVODNÍ mAI (ne pod mProbeAI)
    Result.Values[mAI] := mVal;
  end;
end;


procedure TokenizeGS1ToDataSet(const ABarCode: string; AIMap: TStringList; var ADataSet: TDataSet);
const
  GS = Chr(29);
var
  mRest, mAI, mVal: string;
  mFixed: Boolean;
  mLen, mNextPos, mGSPos: Integer;
  mProbeAI: string;
  mProbeFixed: Boolean;
  mProbeLen: Integer;
begin
  mRest := ABarCode;

  while mRest <> '' do
  begin
    // najdi další AI na začátku zbytku
    if not FindAI(mRest, AIMap, mAI, mFixed, mLen) then
      Break;

    // odstřihni AI kód
    Delete(mRest, 1, Length(mAI));

    if mFixed then
    begin
      // pevná délka
      mVal := Copy(mRest, 1, mLen);
      Delete(mRest, 1, mLen);
    end else
    begin
      // 1) terminátor <GS>, pokud je (a nepřekročí max délku)
      mGSPos := Pos(GS, mRest);
      if (mGSPos > 0) and ((mLen = 0) or (mGSPos - 1 <= mLen)) then
      begin
        mVal := Copy(mRest, 1, mGSPos - 1);
        Delete(mRest, 1, mGSPos); // přeskoč i GS
      end
      else
      begin
        // 2) hledej další AI jako konec proměnné hodnoty
        //    nezačínej na 1 (min délka proměnné hodnoty je 1)
        mNextPos := 2;
        while mNextPos <= Length(mRest) do
        begin
          if FindAI(Copy(mRest, mNextPos, 4), AIMap, mProbeAI, mProbeFixed, mProbeLen) or
             FindAI(Copy(mRest, mNextPos, 3), AIMap, mProbeAI, mProbeFixed, mProbeLen) or
             FindAI(Copy(mRest, mNextPos, 2), AIMap, mProbeAI, mProbeFixed, mProbeLen) then
          begin
            // ignoruj '00' (SSCC) uprostřed proměnné hodnoty
            if mProbeAI <> '00' then Break;
          end;
          Inc(mNextPos);
        end;

        if mNextPos <= Length(mRest) then
        begin
          // našli jsme další AI
          mVal := Copy(mRest, 1, mNextPos - 1);
          Delete(mRest, 1, mNextPos - 1);
        end
        else
        begin
          // 3) žádný další AI: ořízni na max. délku (pokud je známá), jinak vezmi zbytek
          if (mLen > 0) and (Length(mRest) > mLen) then
          begin
            mVal := Copy(mRest, 1, mLen);
            Delete(mRest, 1, mLen);
          end
          else
          begin
            mVal := mRest;
            mRest := '';
          end;
        end;
      end;
    end;

    ADataSet.Edit;
    if mAI = '01' then
      ADataSet.FieldByName('EAN').AsString := mVal;
    if mAI = '17' then
      ADataSet.FieldByName('ExpireDate').AsDateTime := CFxDate.StrToDateEx(mVal, 'yymmdd'); //StrToDateDef(mVal, 0);
    if mAI = '17' then
      ADataSet.FieldByName('ExpireDateStr').AsString := mVal; //StrToDateDef(mVal, 0);
    if mAI = '10' then
      ADataSet.FieldByName('StoreBatchName').AsString := mVal;
    ADataSet.Post;
    // ulož hodnotu pod PŮVODNÍ mAI (ne pod mProbeAI)
    //Result.Values[mAI] := mVal;
  end;
end;


function FindAI(const ABarCode: string; AIMap: TStringList; var ACode: string; var AFixed: Boolean; var ALen: Integer): Boolean;
var
  i: Integer;
  mDef, mVal: string;
begin
  Result := False;
  ACode  := '';
  AFixed := False;
  ALen   := 0;

  for i := 0 to AIMap.Count - 1 do
  begin
    ACode := AIMap.Names[i];

    // pokud začátek vstupního řetězce odpovídá AI kódu
    if Copy(ABarCode, 1, Length(ACode)) = ACode then
    begin
      mDef := AIMap.ValueFromIndex[i]; // např. "F:14" nebo "V:20"
      if mDef <> '' then
      begin
        mVal   := UpperCase(Copy(mDef, 1, 1)); // F nebo V
        AFixed := (mVal = 'F');
        ALen   := StrToIntDef(Copy(mDef, 3, 10), 0);
      end;
      Result := True;
      Exit;
    end;
  end;
end;


function IsGS1BarCode(const ABarCode: string): Boolean;
var
  mFirst2, mFirst3, mFirst4: string;
  i: Integer;
begin

  Result := False;
  if ABarCode = '' then Exit;

  // 1) pokud obsahuje FNC1 / GS (ASCII 29) -> velmi pravděpodobně GS1
  if Pos(Chr(29), ABarCode) > 0 then
    Result:= True;

  // 2) začíná AIM prefixem ]C1 (GS1 DataMatrix indikátor)
  if Copy(ABarCode, 1, 3) = ']C1' then
    Result:= True;

  // 3) ověří první 2–4 znaky proti známým AI
  mFirst2 := Copy(ABarCode, 1, 2);
  mFirst3 := Copy(ABarCode, 1, 3);
  mFirst4 := Copy(ABarCode, 1, 4);

  if mFirst2 in ['00','01','02','10','11','12','13','15','17','20','21','30','37'] then
    Result:= True;
  if mFirst3 in ['240','310'] then
    Result:= True;

  // 4) fallback
  // try
  //   with TokenizeGS1(ABarCode, BuildAIMap) do
  //     Result := (Count > 0);
  // finally
  //   Free;
  // end;
end;



begin
end.