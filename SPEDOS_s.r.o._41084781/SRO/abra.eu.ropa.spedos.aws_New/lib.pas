

{ Prevede retezec na TNxParameters }
procedure ParseData(AStru : TNxParameters; const ADescription : array of string; const ASeparator: string; const AData : string);
var
  mStr, mToken : string;
  mPos, i : integer;
begin
  mStr := AData;
  for i := 0 to Length(ADescription) - 1 do begin
    mPos := AnsiPos(ASeparator, mStr);
    if mPos = 0 then
      mPos := Length(mStr) + 1;
    mToken := NxLeft(mStr, mPos - 1);
    mStr := copy(mStr, mPos + 1, Length(mStr) - mPos);
    AStru.GetOrCreateParam(dtString, ADescription[i], pkInput).AsString := mToken;
  end;
end;




function IsMemberEU(AOS : TNxCustomObjectSpace; const ACountry_ID : string; ADateOf : TDateTime) : boolean;
var
  mCountry : TNxCustomBusinessObject;
  mColl : TNxCustomBusinessMonikerCollection;
  i : integer;
  mDateOfChange : TDateTime;
begin
  Result := False;
  mDateOfChange := 0.0;
  mCountry := AOS.CreateObject('4J5FINKNYNDL3C5P00CA141B44'); // Country
  try
    if not mCountry.Test(ACountry_ID) then
      exit;
    mCountry.Load(ACountry_ID, nil);
    mColl := mCountry.GetLoadedCollectionMonikerForFieldCode(mCountry.GetFieldCode('Rows'));
    for i := 0 to mColl.Count - 1 do begin
      if mDateOfChange < mColl.BusinessObject[i].GetFieldValueAsDateTime('DateOfChange$DATE') then begin
        Result := mColl.BusinessObject[i].GetFieldValueAsBoolean('EUMember');
        mDateOfChange := mColl.BusinessObject[i].GetFieldValueAsDateTime('DateOfChange$DATE')
      end;
    end;
  finally
    mCountry.Free;
  end
end;


function GetVATRate_ID(AOS : TNxCustomObjectSpace; ATariff : Double) : string;
var
  mR : TStrings;
const
  cSQL = 'SELECT ID FROM VATRates WHERE Tariff = %s';
begin
  Result := '';
  mR := TStringList.create;
  try
    AOS.SQLSelect(Format(cSQL, [NxFloatToIBStr(ATariff)]), mR);
    if mR.Count = 1 then
      Result := mR.strings[0];
  finally
    mR.Free;
  end;
end;



begin
end.