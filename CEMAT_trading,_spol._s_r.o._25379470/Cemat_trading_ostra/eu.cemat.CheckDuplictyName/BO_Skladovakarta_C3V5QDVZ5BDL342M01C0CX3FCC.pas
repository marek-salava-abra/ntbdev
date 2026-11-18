procedure BeforeSoftValidate_Hook(Self: TNxCustomBusinessObject);
var
  mHodnota, mChyba, mPole, mPopis, mSQL, mID: string;
  mResult:TStrings;
  mSiteForm: TSiteForm;
  mOS: TNxCustomObjectSpace;
  mPocet : integer;
begin
  //validace na duplicitu kodu
  mChyba:='';
  mPole := 'Name';
  mPopis := '"Název"';
  // Nacteni obsahu polozky do lokalni promenne
  mHodnota := Self.GetFieldValueAsString(mPole);
  mID := Self.GetFieldValueAsString('ID');
  mSQL := 'SELECT count(ID) FROM StoreCards WHERE Hidden=' + QuotedStr('N')
                + ' and ' + mPole + '='+ QuotedStr(mHodnota)
                + ' and  ID <> ' + QuotedStr(mID) ;
  // Provedeme dotaz
  mPocet := StrToInt(GetFirstRecordFromSQL(Self.ObjectSpace, mSQL, '0'));
  if (mPocet > 0) then begin
     //AResult := False;
     Self.AddValidateError(Self.GetFieldCode(#39+mPole+#39), 'Pozor duplicita. Hodnota v poli '
       + mPopis + ' je již použita.' + #13#10   + 'Zadejte jinou nepoužitou hodnotu.' );

  end;
  //AResult:=True;
end;

//procedure Validate_Hook(Self: TNxCustomBusinessObject; var AResult: Boolean);



{
Vyvolává se bezprostředně před provedením softvalidace objektu.
}


function GetFirstRecordFromSQL(AOS: TNxCustomObjectSpace; ASQL, AResult: String): String;
var
  mSQLRes: TStrings;
begin
  Result := AResult;
  mSQLRes := TStringList.Create;
  try
    AOS.SQLSelect(ASQL, mSQLRes);
    if mSQLRes.Count > 0 then
      Result := mSQLRes.Strings[0]
  finally
    mSQLRes.Free;
  end;
end;

begin
end.