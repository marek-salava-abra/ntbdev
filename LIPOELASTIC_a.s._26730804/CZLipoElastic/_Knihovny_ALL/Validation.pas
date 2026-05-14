uses '_Knihovny_ALL.SQL';

// kontrola RČ
//----------------------------------------------------------------

function CheckBirthNumber(ABirthNumber: string): boolean;
begin
  if (Length(ABirthNumber) > 9) then begin
    Result := true;
  end else begin
    Result := false;
  end;
end;


// kontrola IČO
//----------------------------------------------------------------

Function CheckOrgIdentNumber(Self: TNxCustomBusinessObject ):string;
Const
  cDiv = 11;
  cCislo = 8;
var
  mOrgIdentNumber: string;
  i, mSuma, mCast, mPoslZnak, mMod: integer;
begin
  Result := '';

      mOrgIdentNumber := Self.GetFieldValueAsString('OrgIdentNumber');
      if not NxIsNumeric(mOrgIdentNumber) then begin
        //showmessage('Chybné IČO, obsahuje nejen číslice 0..9!');
        Result := 'Chybné IČO, obsahuje nejen číslice 0..9!';
        exit;
      end;
      if Length(mOrgIdentNumber)<>cCislo then begin
        //showmessage('Chybné IČO, délka IČa má být ' + IntToStr(cCislo) + ' znaků!');
        Result := 'Chybné IČO, délka IČa má být ' + IntToStr(cCislo) + ' znaků!';
        exit;
      end;
      mOrgIdentNumber := NxPadl(mOrgIdentNumber, 8, '0');
      mSuma := 0;
      for i := 0 to cCislo - 2 do begin //Length(mOrgIdentNumber)-1 do begin
        mCast := (cCislo - i ) * StrToInt(NxLeft(NxRight(mOrgIdentNumber,Length(mOrgIdentNumber)-i),1));
        mSuma := mSuma + mCast  ;
      end;
      mMod := mSuma mod cDiv;
      if (mMod = 0) or (mMod = 10) then mPoslZnak := 1;
      if (mMod = 1) then mPoslZnak := 0;
      if (mMod > 1) and (mMod < 10) then mPoslZnak := cDiv - mMod;
      if IntTostr(mPoslZnak) <> NxRight(mOrgIdentNumber, 1) then
        //ShowMessage('Chybné IČO!')
        Result := 'Chybné IČO!'
      else ;//ShowMessage('IČO vyhovuje kontrole!');

end;


// Kontrola e-mailu
//----------------------------------------------------------------

function CheckEmail(AEmail: string; AEmptyAllowed: boolean): boolean;
var
  mList, mList2: TStringList;
begin

  // možno prázdný email
  if (AEmptyAllowed) and (AEmail = '') then begin
    Result := True;
    exit;
  end;

  // povolené znaky
  AEmail := LowerCase(AEmail);
  AEmail := NxCorrectText(AEmail, 'abcdefghijklmnopqrstuvwxyz0123456789._-@', '#');
  if (NxAt('#', AEmail) > 0) then begin
    Result := false;
    exit;
  end;

  try
    // počet znaků kolem zavináče
    mList := TStringList.Create;
    mList.Delimiter := '@';
    mList.DelimitedText := AEmail;
    if (mList.Count < 2) then begin
      Result := false;
      exit;
    end;
    if (Length(mList[0]) < 1) then begin
      Result := false;
      exit;
    end;
    if (Length(mList[1]) < 1) then begin
      Result := false;
      exit;
    end;

    try
      // počet znaků za zavináčem kolem tečky
      mList2 := TStringList.Create;
      mList2.Delimiter := '.';
      mList2.DelimitedText := mList[1];
      if (mList2.Count < 2) then begin
        Result := false;
        exit;
      end;
      if (Length(mList2[0]) < 1) then begin
        Result := false;
        exit;
      end;
      if (Length(mList2[1]) < 1) then begin
        Result := false;
        exit;
      end;

    finally
      mList2.Free;
    end;

  finally
    mList.Free;
  end;

  Result := true;
end;


// Kontrola telefonu
//----------------------------------------------------------------

function CheckPhoneNumber(ANumber: string; AEmptyAllowed: boolean): boolean;
var
  mList, mList2: TStringList;
begin

  // možno prázdný
  if (AEmptyAllowed) and (ANumber = '') then begin
    Result := True;
    exit;
  end;
  
  // povolené znaky
  ANumber := NxCorrectText(ANumber, '0123456789+ ', '#');
  if (NxAt('#', ANumber) > 0) then begin
    Result := false;
    exit;
  end;
  
  // maximální a minimální délka
  if (Length(ANumber) < 9) or (Length(ANumber) > 20) then begin
    Result := false;
    exit;
  end;

  Result := True;
end;


// Kontrola existence firem s podobným názvem
//--------------------------------------------------------------------------------
// ignoruje skryté, předchůdce a ID=mFirmID (pokud je vyplněno). Ignoruje prázdný název
// z názvu jsou odstraněny mezery a nealfanumerické znaky, převedeno na velká písmena, porovnáno
// se stejně upravenými názvy v DB. Pokud se shoduje aspoň 70%, vrátí seznam takových firem
// Když není nalezena shoda, je vrácen prázdný řetězec
// mComparePercent = část délky řetězce, která se porovnává (např. '0.7' = stačí, když se shoduje prvních 70% znaků)
// Dále se porovnávají pouze firmy, které mají délku názvu v toleranci Length(mFirmName) +- (1-mComparePercent)
// Vyžaduje proceduru FINE_FILTERALFANUM

function CheckFirmNameExists(OS: TNxCustomObjectSpace; mFirmName, mFirmID: string; mComparePercent: double = 0.75): string;
var
  mQuery, mOriginalFirmName: string;
  mList: TStringList;
  mCompareLength, mLengthToleranceLow, mLengthToleranceHigh: double;
begin
  Result := '';
  mOriginalFirmName := mFirmName;

  if (Trim(mFirmName) = '') then exit;

  mList := TStringList.Create;
  try
    mFirmName := NxCorrectText(UpperCase(TEncoding.RemoveDiacritics(mFirmName)), 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789', '#');
    mFirmName := ReplaceStr(mFirmName, '#', '');
    mCompareLength := Round(Length(mFirmName) * mComparePercent);
    mLengthToleranceLow := Length(mOriginalFirmName) - Round(Length(mOriginalFirmName) * (1-mComparePercent));
    mLengthToleranceHigh := Length(mOriginalFirmName) + Round(Length(mOriginalFirmName) * (1-mComparePercent));

    mQuery := 'SELECT F.Name FROM Firms F WHERE F.Hidden = ''N'' AND F.Firm_ID IS NULL AND F.ID <> '+QuotedStr(mFirmID)+' '+
    'AND CHAR_LENGTH(F.Name) BETWEEN '+NxFloatToIBStr(mLengthToleranceLow)+' AND '+NxFloatToIBStr(mLengthToleranceHigh)+' '+
    'AND SUBSTRING('+QuotedStr(mFirmName)+' ,1 , '+NxFloatToIBStr(mCompareLength)+') = '+
    '(SELECT SUBSTRING(STR , 1 , '+NxFloatToIBStr(mCompareLength)+') FROM FINE_FILTERALFANUM(UPPER(Ib_Remove_Diacritics(F.Name))))';
    mList := SQLSelectValues(OS, mQuery);
    if mList.Count > 0 then begin
      Result := mList.Text;
    end;
  finally
    mList.Free;
  end;

end;

// Kontrola existence IČO
//--------------------------------------------------------------------------------
// ignoruje skryté, předchůdce, stejný kód a ID=mFirmID (pokud je vyplněno). Ignoruje prázdné ičo

function CheckOrgIdentNumberExists(OS: TNxCustomObjectSpace; mOrgIdentNumber, mFirmID: string; mFirmCode: string = ''): string;
var
  mQuery: string;
  mList: TStringList;
begin
  Result := '';

  if (Trim(mOrgIdentNumber) = '') then exit;

  mList := TStringList.Create;
  try
    mQuery := 'SELECT F.Code || '' '' || F.Name FROM Firms F WHERE F.Hidden = ''N'' AND F.Firm_ID IS NULL AND F.ID <> '+QuotedStr(mFirmID)+' '+
    'AND F.Code <> '+QuotedStr(mFirmCode)+' AND TRIM('+QuotedStr(mOrgIdentNumber)+') = TRIM(F.OrgIdentNumber) ';
    OutputDebugString('ICO: '+mQuery);
    mList := SQLSelectValues(OS, mQuery);
    if mList.Count > 0 then begin
      Result := mList.Text;
      OutputDebugString(mList.Text);
    end;
  finally
    mList.Free;
  end;

end;



begin
end.