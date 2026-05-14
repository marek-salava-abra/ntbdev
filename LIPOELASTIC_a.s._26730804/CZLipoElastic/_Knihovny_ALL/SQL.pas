function SQLSelectFirstRecosrds(SQLObjectSpace : TNxCustomObjectSpace; query : String;) : String;
var
  mList : TStrings;
begin
  Result := '';
  mList := TStringList.Create;
  try
    SQLObjectSpace.SQLSelect(query, mList);
    if mList.Count > 0 then begin
         Result := mList.Strings[0];
      end else begin
        Result := '';

    end;
  finally
    mList.Free;
  end;
end;






// SQL SELECT, vrací 1. záznam jako řetězec, hodnoty oddělené ;
// -----------------------------------------------------------------------------------------------------



function SQLSelectValue(SQLObjectSpace : TNxCustomObjectSpace; query : String;) : String;
var
  mList : TStrings;
begin
  Result := '';
  mList := TStringList.Create;
  try
    SQLObjectSpace.SQLSelect(query, mList);
    if mList.Count > 0 then begin
      if (NxLeft(mList.Strings[0], 1) = '"') and (NxRight(mList.Strings[0], 1) = '"') then begin
        Result := NxExtractQuotedString(mList.Strings[0], '"');
      end else begin
        Result := mList.Strings[0];
      end;
    end;
  finally
    mList.Free;
  end;
end;


// SQL SELECT, vrací 1. záznam jako stringlist hodnot
// -----------------------------------------------------------------------------------------------------

function SQLSelectFirstRowList(SQLObjectSpace : TNxCustomObjectSpace; query : String;) : TStringList;
var
  mList, mFields : TStringList;
  mRow: string;
begin
  try
    mList := TStringList.Create;
    mRow := '';
    SQLObjectSpace.SQLSelect(query, mList);
    if mList.Count > 0 then mRow := mList.Strings[0];
    mFields := TStringList.Create;
    if (mRow <> '') then begin
      mFields.Delimiter := ';';
      mFields.QuoteChar := '"';
      mFields.DelimitedText := mRow;
    end;
    Result := mFields;
  finally
    mList.Free;
    //mFields.Free;
  end;
end;


// SQL SELECT, vrací string list hodnot dotazu na 1 sloupec
// -----------------------------------------------------------------------------------------------------

function SQLSelectValues(SQLObjectSpace : TNxCustomObjectSpace; query : String;) : TStringList;
var
  mList, mFields, mValues : TStringList;
  mRow: string;
  i: integer;
begin
  mList := TStringList.Create;
  try
    mValues := TStringList.Create;
    SQLObjectSpace.SQLSelect(query, mList);
    for i := 0 to mList.Count - 1 do begin
      mRow := mList.Strings[i];
      mFields := TStringList.Create;
      if (mRow <> '') then begin
        mFields.Delimiter := ';';
        mFields.QuoteChar := '"';
        mFields.DelimitedText := mRow;
        mValues.Add(mFields[0]);
      end;
    end;
    Result := mValues;
  finally
    mList.Free;
  end;

end;


// Převede StringList na seznam hodnot pro SQL IN
// [AAA,BBB,CCC] => 'AAA','BBB','CCC'
// -----------------------------------------------------------------------------------------------------

function SQLStringList(AList: TStringList;): String;
var
  i: integer;
  mResult: string;
begin
  //AList.Delimiter := ',';
  //AList.QuoteChar := '"';
  //Result := AList.DelimitedText;
  mResult := '';
  for i := 0 to AList.Count-1 do begin
    mResult := mResult + QuotedStr(AnsiDequotedStr(AList[i], '"')) + ',';
  end;
  mResult := NxLeft(mResult, Length(mResult)-1);
  Result := mResult;

end;



begin
end.