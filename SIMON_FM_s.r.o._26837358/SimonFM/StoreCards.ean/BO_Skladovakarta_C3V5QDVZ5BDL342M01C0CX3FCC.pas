function GenIntEAN(ABO : TNxCustomBusinessObject; APrefix : String) : string;
var
  mContext: TNxContext;
  mList: TStrings;
  mSQLSelect : string;
  mEAN : string;
  mEANPrefix : string;
  mNumEAN : Longint;
  mEANLen : integer;
const
  cSQL =  'select max(cast(ib_string_left(ean, 12) as varchar(12)) ) from StoreUnits where ean like ''%s_______'' ';
begin
  Result := '';
    mSQLSelect := Format(cSQL, [APrefix]);
    mList := TStringList.Create;
    try
      mContext := NxCreateContext_1(ABO);
      try
        mContext.SQLSelect(mSQLSelect, mList);
      finally
        mContext.Free;
      end;
      if (mList.Count > 0) then begin
        mEAN := mList.Strings[0];
        mEAN := Trim(mEAN);
        mEANPrefix := NxLeft(mEAN, 6);
        mEANLen := Length(mEAN);
        mEAN := NxRight(mEAN, mEANLen - 6);
        mNumEAN := StrToInt(mEAN);
        mNumEAN := mNumEAN + 1;
        mEAN := IntToStr(mNumEAN);
        mEAN := NxPadL(mEAN, mEANLen - 6, '0');
        mEAN := mEANPrefix + mEAN;
        NxCorrectEAN13(mEAN);
        Result := mEAN;
      end;
    finally
      mList.Free;
    end;
end;




{
Vyvolává se před fyzickým uložením vlastních dat objektu do databáze.
}
procedure BeforeSave_Hook(Self: TNxCustomBusinessObject);
var
  mMainUnitCode : string;
  mUnits : TNxCustomBusinessMonikerCollection;
  i : integer;
  mUnit : TNxCustomBusinessObject;
  mEAN : string;
begin
  if false and NxIsBlank( Self.GetFieldValueAsString('EAN')) then begin
    mMainUnitCode := Self.GetFieldValueAsString('MainUnitCode');
    mUnits := Self.GetCollectionMonikerForFieldCode(Self.GetFieldCode('StoreUnits'));
    for i := 0 to mUnits.count - 1 do begin
      mUnit := mUnits.BusinessObject[i];
      if mUnit.GetFieldValueAsString('Code') = mMainUnitCode then begin
        mEAN := GenIntEAN(Self, '200055');
        mUnit.SetFieldValueAsString('EAN', mEAN);
      end;
    end;
  end;
end;

begin
end.