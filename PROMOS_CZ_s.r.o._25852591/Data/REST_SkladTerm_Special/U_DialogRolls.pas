uses
  'REST_SkladTerm.U_Func',
  'StandardUnits.U_GetId';

// zde lze vytvaret funkce, ktere se budou volat z ciselniku v dialogu pri ukonceni dokladu (U_StandardHooks.DialogOnDocSave)

// rozcesnik na typy ciselniku
procedure listSelection(AOS: TNxCustomObjectSpace; AModule, ADocType, AUser_ID, ASearchStr, ARollName: String; var AInputValues, AList: TMemTable);
begin
  case ARollName of
    'Transport': TransporationTypeList(AOS, AModule, ADocType, AUser_ID, ASearchStr, AInputValues, AList);
    'InternalDepreciations': InternalDepreciationTypeList(AOS, AModule, ADocType, AUser_ID, ASearchStr, AInputValues, AList);
  end;

end;

// vraceni hodnot pro ciselnik. V AInputValue jsou dostupne vsechny hodnoty z dialogu - seznam poli je v komentaci funkce U_StandardHooks.DialogOnDocSave
// Sloupec ID se vyplni na pole na BO. Sloupec Code se zobrazi jako popiska hodnoty v dialogu
procedure TransporationTypeList(AOS: TNxCustomObjectSpace; AModule, ADocType, AUser_ID, ASearchStr: String; var AInputValues, AList: TMemTable);
var
  mSql: String;
begin
    mSql :=
      'select ' + FIRST_TOP(100) + nxCrLf +
      '  TT.ID as "ID", ' + nxCrLf +
      '  TT.Code as "Code", ' + nxCrLf +
      '  TT.Name as "Name" ' + nxCrLf +
      'from TransportationTypes TT ' + nxCrLf +
      'where TT.Hidden = ''N'' ';

  // pripadne hledani
  if trim(ASearchStr) <> '' then
  begin
    mSql := mSql +
      ' and (TT.Code' + COLLATION_AI + 'like ''%' + ASearchStr + '%''' + nxCrLf +
      '  or TT.Name' + COLLATION_AI + 'like ''%' + ASearchStr + '%'')';
  end;
  mSql := mSql + 'order by TT.Code';
  mSql := mSql + FIRST_TOP_ORACLE(100);
  AOS.SQLSelect2(mSql, AList);
end;

procedure InternalDepreciationTypeList(AOS: TNxCustomObjectSpace; AModule, ADocType, AUser_ID, ASearchStr: String; var AInputValues, AList: TMemTable);
var
  mSql: String;
begin
    mSql :=
      'select ' + FIRST_TOP(100) + nxCrLf +
      '  D.ID as "ID", ' + nxCrLf +
      '  D.Code as "Code", ' + nxCrLf +
      '  D.Name as "Name" ' + nxCrLf +
      'from DefRollData D ' + nxCrLf +
      'where D.Hidden = ''N'' and D.CLSID=''20YKBQLMBGS4T5AEO20HTEMJZ0'' ';

  // pripadne hledani
  if trim(ASearchStr) <> '' then
  begin
    mSql := mSql +
      ' and (D.Code' + COLLATION_AI + 'like ''%' + ASearchStr + '%''' + nxCrLf +
      '  or D.Name' + COLLATION_AI + 'like ''%' + ASearchStr + '%'')';
  end;
  mSql := mSql + 'order by D.Code';
  mSql := mSql + FIRST_TOP_ORACLE(100);
  AOS.SQLSelect2(mSql, AList);
end;


begin
end.