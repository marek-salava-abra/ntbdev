{
Umožňuje ovlivnit validaci.
}
procedure Validate_Hook(Self: TNxCustomBusinessObject; var AResult: Boolean);
var
 mBankAccount_ID:string;
 mEncodedStr: string;
 mDecodedBytes: TBytes;
 mParamList: TStringList;
 i: Integer;
 mParamText: string;
begin
  if self.GetFieldValueAsString('TaskCLSID')='GBI1WVVXW3XOTCTOOX54P3H2H0' then begin
    mEncodedStr := self.GetFieldValueAsString('TaskParameters');

    if mEncodedStr <> '' then begin
      mDecodedBytes := DecodeBase64(mEncodedStr);
      mParamList := ExtractParameters(mDecodedBytes);
      mBankAccount_ID:=mParamList.Strings[8];
      if not(self.GetFieldValueAsString('X_BankAccount_ID')=mBankAccount_ID)
       then self.SetFieldValueAsString('X_BankAccount_ID',mBankAccount_ID);
    end;
  end;
end;

function ExtractParameters(const Bytes: TBytes): TStringList;
var
  i: Integer;
  CurrentStr: string;
  B: Byte;
begin
  Result := TStringList.Create;
  CurrentStr := '';

  for i := 0 to Length(Bytes) - 1 do
  begin
    B := Bytes[i];
    // Sledujeme tisknutelné ASCII znaky (písmena, čísla, speciální znaky)
    if (B >= 32) and (B <= 126) then
    begin
      CurrentStr := CurrentStr + Chr(B);
    end
    else
    begin
      // Jakmile narazíme na ne-tisknutelný znak, uložíme nasbíraný řetězec
      if Length(CurrentStr) >= 2 then
        Result.Add(CurrentStr);
      CurrentStr := '';
    end;
  end;

  // Přidání případného zbytku na konci pole
  if Length(CurrentStr) >= 2 then
    Result.Add(CurrentStr);
end;

begin
end.