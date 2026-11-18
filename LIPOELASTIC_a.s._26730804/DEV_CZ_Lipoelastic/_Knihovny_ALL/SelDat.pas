

// vyčištění a naplnění tabulky SelDef a SelDat hodnotami ze StringListu s připraveným ID a Station

procedure StringListToSelDat(AOS: TNxCustomObjectSpace; AID, AStation: String; AValues: TStringList);
begin
  ClearSelDat(AOS, AID);
  AddStringsToSelDat(AOS, AID, AStation, AValues);
end;



procedure AddStringsToSelDat(AOS : TNxCustomObjectSpace; AID, AStation: String; AValues: TStringList);
var
  mStation_ID, mQuery: String;
  i : Integer;
begin
  AOS.SQLExecute('INSERT INTO SelDef (ID, Station) VALUES ('''+AID+''', '''+AStation+''')');
  for i := 0 to AValues.Count - 1 do begin
    mQuery := 'INSERT INTO SelDat (Sel_ID, Obj_ID) VALUES ('''+AID+''', '+QuotedStr(AValues.Strings[i])+')';
    AOS.SQLExecute(mQuery);
  end;
end;

procedure ClearSelDat(AOS: TNxCustomObjectSpace; AID: String);
begin
  AOS.SQLExecute('DELETE FROM SelDat WHERE Sel_ID = '''+AID+'''');
  AOS.SQLExecute('DELETE FROM SelDef WHERE ID = '''+AID+'''');
end;


begin
end.