procedure AddStringsToSelDat(AOS : TNxCustomObjectSpace; AStation_ID: String; AValues: TStringList);
// Přidá do SelDat hodnoty ze StringListu pod AStation
var
  mStation_ID : String;
  i : Integer;
begin
  mStation_ID := aos.SQLSelectFirstAsString('Select ID from SelDef where ID = '+QuotedStr(AStation_ID), '');
  if NxIsEmptyOID(mStation_ID) then begin
    mStation_ID := AStation_ID;
    AOS.SQLExecute('Insert into SelDef (ID, Station) values ('+QuotedStr(mStation_ID) +', ''GeneratedByScript'')');
  end;
  For i:=0 to AValues.Count-1 do begin
    AOS.SQLExecute('Insert into SelDat (Sel_ID, Obj_ID) values ('+QuotedStr(mStation_ID) +', '+QuotedStr(AValues.Strings[i]) +')');
  end;
end;

procedure ClearSelDat(AOS : TNxCustomObjectSpace; AStation_ID: String);
// Smaže ze SelDat hodnoty pod AStation
begin
  AOS.SQLExecute('Delete from SelDef where ID = '+QuotedStr(AStation_ID));
end;

procedure StringsToSelDat(AOS : TNxCustomObjectSpace; AStation_ID: String; AValues: TStringList);
begin
  ClearSelDat(AOS, AStation_ID);
  AddStringsToSelDat(AOS, AStation_ID, AValues);
end;

function GetQuantityFromSG(var AOS:TNxCustomObjectSpace; var aStoreCard_ID:string):Extended;
var
 mList:TStringList;
 mSeldef, mSQL:string;
 mDateFrom, mDateTo:string;
begin
  Result:=0;
  try
    if not(NxIsEmptyOID(aStoreCard_ID)) then begin
      mDateFrom:='43831';
      mDateTo:='45854';
      mList:=TStringList.Create;
      mList.add(aStoreCard_ID);
      mSeldef:= Copy(IntToStr(Round(Frac(Now)*100000))+NxGetComputerName,1,10);
      StringsToSelDat(AOS,mSeldef,mList);
      mSQL:='Select Sum(B.II2_Quantity) + Sum(B.RC2_Quantity) - Sum(B.ICN2_Quantity) - Sum(B.RCR2_Quantity) from SoldGoods(''A'', '+mDateFrom+', '+mDateTo+','''+mSeldef+''', '''', '''', '''',';
      mSQL := mSQL +' '''', '''', '''', '''', '''','''', '''', '''',''0'', ''0'', ''0'', ''0'',''N'', 0, 0, '''',''N'', 0, 0, ''0'', ''0'',''0'') b group by B.StoreCard_ID';
      Result:=AOS.SQLSelectFirstAsExtended(mSQL,0);
      ClearSelDat(aOS,mSeldef);
    end;
  except
   //snad se nic nestane
  end;
end;

begin
end.