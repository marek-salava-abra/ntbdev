uses
  'REST_Licence.libConst';

{
  Sifrovani / desifrovani licence
}
function getHASH(const AInputString: String; ADecrypt: Boolean = false): String;
const
  key = 'ecc293dea7312591abbca8debeb0cd05';
  salt = 'resFlo';
var
  i, j, iMultiple: Integer;
  sStringWithSalt, sPom, sKey: String;
  hexString, fileText: String;
begin
  result := '';
  fileText := '';
  hexString := '';
  sKey := key;

  if Length(Key) < Length(AInputString) then begin
    iMultiple := Trunc(Length(AInputString) / Length(Key)) + 1;
    for i := 0 to iMultiple - 1 do
      sKey := sKey + key; //násobím opakování klíče
  end;

  if not ADecrypt then begin
    sStringWithSalt := AInputString + salt; //osolíme to

    for i := 1 to Length(sStringWithSalt) - 1 do begin
      result := result + IntToHex(Ord(Copy(sStringWithSalt, i + 1, 1)) xor Ord(sKey[i]), 2);
    end;
  end
  else begin
    sPom := AInputString;
    for i := 1 to (Length(AInputString) div 2) do begin
      hexString := '$' + copy(sPom, 1, 2);
      sPom := copy(sPom, 3, length(sPom));
      fileText := fileText + Chr(StrToIntDef(hexString,0) xor Ord(sKey[i]));
    end;

    if Pos(salt, fileText) > 0 then
      fileText := copy(fileText, 1, pos(salt, fileText) - 1);
    Result := fileText;
  end;
end;

{
  Vrati desifrovane licencni informace
}
function LoadLicenceFile: String;
var
  mStringList: TStringList;
begin
  Result := '';

  mStringList := TStringList.Create;
  try
    if not FileExists(cLicenceFileName) then
      exit;

    mStringList.LoadFromFile(cLicenceFileName);
    if mStringList.Count > 0 then
    begin
      Result := getHASH(mStringList[0], true);
    end;
  finally
    mStringList.Free;
  end;
end;

{
  Vrati pocet licenci
}
function GetLicenceCount(AOS: TNxCustomObjectSpace): Integer;
var
  mStringList: TStringList;
begin
  Result := 0;

  mStringList := TStringList.Create;
  try
    mStringList.Delimiter := cSeparator;
    mStringList.DelimitedText := LoadLicenceFile;
    if mStringList.Count = 3 then
    begin
      Result := NxStrToInt(mStringList[1]);
    end;
  finally
    mStringList.Free;
  end;
end;

{
  Overi licenci
}
function VerifyLicense(AOS: TNxCustomObjectSpace; ALicenceCount: Integer; var AErrMesage: String = ''): Boolean;
var
  mICO: String;
  mLicenceCount, mDay, mMonth, mYear: Integer;
  mDate: TDate;
  mStringList, mDateList: TStringList;
begin
  Result := false;

  mStringList := TStringList.Create;
  mDateList := TStringList.Create;
  try
    mStringList.Delimiter := cSeparator;
    mStringList.DelimitedText := LoadLicenceFile;

    if mStringList.DelimitedText = '' then
    begin
      AErrMesage := 'Soubor s licencí neexistuje nebo obsahuje neplatné informace.';
      exit;
    end;

    if mStringList.Count = 3 then
    begin
      mICO := mStringList[0];
      mLicenceCount := NxStrToInt(mStringList[1]);

      mDateList.Delimiter := '.';
      mDateList.DelimitedText := mStringList[2];
      mDay := StrToIntDef(mDateList[0], 1);
      mMonth := StrToIntDef(mDateList[1], 1);
      mYear := StrToIntDef(mDateList[2], 2000);

      mDate := EncodeDate(mYear, mMonth, mDay);

      //kontroly
      if NxEvalParametersExprAsString(AOS, nil, 'NxGetCompanyOrgIdentNumber') <> mICO then
      begin
        AErrMesage := 'Licenční klíč je určen pro firmu s jiným IČ.';
        exit;
      end;

      if ALicenceCount > mLicenceCount then
      begin
        AErrMesage := 'Byl překročen počet licencovaných zařízení.';
        exit;
      end;

      if Date > mDate then
      begin
        AErrMesage := 'Platnost licence vypršela (' + DateToStr(mDate) + ').';
        exit;
      end;

      Result := True;
    end;
  finally
    mStringList.Free;
    mDateList.Free;
  end;
end;

{
  Funkce na otestovani, zda je zarizeni (AUDID) licencovane pro zadany typ licence
  ALicenseType - bud pouze jedno cislo odpovidajici licenci, nebo seznam cisel oddelenych carkou.
}
function CheckLicense(AOS: TNxCustomObjectSpace; AUDID: String; var AErrMesage: String = ''): Boolean;
var
  mDS: TMemTable;
  mSQL: String;
  mLicenceCount: TStringList;
begin
  Result := false;
  AErrMesage := 'Zařízení " ' + AUDID + '" není licencováno.';
  
  mDS := TMemTable.Create(nil);
  try
    mSQL := Format(cRESTLicenseCheck, [AUDID]);
    AOS.SQLSelect2(mSQL, mDS);
    if mDS.IsEmpty then exit;
    if mDS.RecordCount = 1 then
      if ((AUDID = mDS.FieldByName('GUID').AsString)
        and (getHASH(Trim(AUDID)) = mDS.FieldByName('HASH').AsString)) then
      begin
        // zarizeni je zadano v systemu, ted jeste kontrola na platnost samotne licence
        mLicenceCount := TStringList.Create;
        try
          mSQL := cRESTLicenseCount;
          AOS.SQLSelect(mSql, mLicenceCount);
          if mLicenceCount.Count = 1 then
          begin
            if VerifyLicense(AOS, StrToInt(mLicenceCount[0]), AErrMesage) then
              Result := True;
          end;
        finally
          mLicenceCount.free;
        end;
      end;
  finally
    mDS.free;
  end;
end;

begin
end.