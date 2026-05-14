const
  cRowDescription2 = ['Obchodnik','POS','UID','Nazev_obchodnika','Nazev_obchodu','Typ_zaznamu','Cislo_vypisu','Datum_vypisu',
                      'Datum_platby','Cislo_platby','Plne_cislo_platby','Platebni_schema','Datum_transakce','Cas_transakce',
                      'Autorizacni_kod','Znacka_karty','Cislo_karty','Platba_brutto','Platba_poplatku','Uhrazena_castka',
                      'Mena_obchodnika','Castka_brutto','Vyse_poplatku','Castka_netto','Mena_transakce','Typ_karty',
                      'ID_davky','Zalozni_rezim','Variabilni_symbol','Kod_zamitnuti','Text_zamitnuti','Smenny_kurz',
                      'Cislo_bankovniho_uctu','Identifikace_zasahu_pri_platbe','DCC_castka','DCC_mena',
                      'DCC_smenny_kurz','DCC_datum_kurzu','DCC_markup','DCC_reference','DCC_poskytovatel','DCC_profil'];
  cSeparator2 = ';';
  errStoreCardNotFound2 = 'Skladová karta s kodem %s nenalezena.';

{
  funkce rozloží vstupní parametry a uloží je do TNxParameters > hierarchická struktura s pojmenovanými parametry
  pořadí parametru v řetězcích a jejich pojmenování je definováno poli cHeadDescription a cRowDescription
}
function ParseData(ARows : TStrings ) : TNxParameters;
var
  mRows, mRow : TNxParameters;
  i, j, mPos : integer;
  mToken, mStr : string;
  x : TStringList;
begin
  OutputDebugString('Enter procedure ParseData');
  Result := TNxParameters.Create;
  mRows := TNxParameters(Result.GetOrCreateParam(dtList, 'rows', pkInput));
  for j := 0 to ARows.Count - 1 do begin
    mRow := TNxParameters(mRows.GetOrCreateParam(dtList, IntToStr(j), pkInput));
    mStr := ARows.Strings[j];
   for i := 0 to  Length(cRowDescription2) - 1 do begin
      mPos := AnsiPos(cSeparator2, mStr);
      if mPos = 0 then
        mPos := Length(mStr) + 1;
      mToken := NxLeft(mStr, mPos - 1);
      mStr := copy(mStr, mPos + 1, Length(mStr) - mPos);
      mRow.GetOrCreateParam(dtString, cRowDescription2[i], pkInput).AsString := Trim(mToken);
    end;
  end;

//  Result.GetOrCreateParam(dtString, 'id', pkInput).AsString := '0000000000';
  OutputDebugString('Leave procedure ParseData');
end;

function GetAccount_ID(AOS : TNxCustomObjectSpace; aCode : string) : string;
const
  cSQL = 'SELECT ID FROM Accounts WHERE Code=''%s''  ';
var
  mList : TStringList;
begin
  mList := TStringList.Create;
  try
    AOS.SQLSelect(Format(cSQL, [aCode]), mList);
    if mList.Count > 0 then
      Result := mList.Strings[0]
      else Result:=''
  finally
    mList.Free;
  end;
end;

function GetVS(AOS : TNxCustomObjectSpace; aCode : string) : string;
const
  cSQL = 'Select ii.varsymbol from issuedinvoices ii left join issuedinvoices2 ii2 on ii.id=ii2.parent_id left join storedocuments2 sd2 on sd2.id=ii2.providerow_id '+
         'left join receivedorders ro on ro.id=sd2.provide_id where ro.externalnumber=''%s''  ';
var
  mList : TStringList;
begin
  mList := TStringList.Create;
  try
    AOS.SQLSelect(Format(cSQL, [aCode]), mList);
    if mList.Count > 0 then
      Result := mList.Strings[0]
      else Result:=''
  finally
    mList.Free;
  end;
end;

function GetVSOI(AOS : TNxCustomObjectSpace; aCode : string) : string;
const
  cSQL = 'select VarSymbol from otherincomes where docqueue_id=''6R90000101'' and electronicpaymentpaid=''A'' and electronicpaymentauthcode like ''%s'' ';
var
  mList : TStringList;
begin
  mList := TStringList.Create;
  try
    AOS.SQLSelect(Format(cSQL, ['%'+aCode]), mList);
    if mList.Count > 0 then
      Result := mList.Strings[0]
      else Result:=''
  finally
    mList.Free;
  end;
end;

function GetFirm_ID(AOS : TNxCustomObjectSpace; aCode : string) : string;
const
  cSQL = 'SELECT F.ID FROM Firms F left join Addresses A on A.ID=F.REsidenceAddress_ID WHERE A.Location=''%s'' and f.hidden=''N'' ';
var
  mList : TStringList;
begin
  mList := TStringList.Create;
  try
    AOS.SQLSelect(Format(cSQL, [aCode]), mList);
    if mList.Count > 0 then
      Result := mList.Strings[0]
      else Result:=''
  finally
    mList.Free;
  end;
end;

begin
end.