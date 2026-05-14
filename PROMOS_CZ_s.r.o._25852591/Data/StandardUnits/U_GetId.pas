//type
//  tDB_Type = (dbFireBird, dbMSSQL, dtOracle11, dtOracle12c, dtOracle19);   0, 1, 2, 3, 4

const
  DB_TYPE = 0;

////////////////////////////////////////////////////////////////////////////////
procedure FreeAndNil(var AObject: TObject);
begin
  try
    if Assigned(AObject) then
    begin
      AObject.Free;
      AObject := nil;
    end;
  except
    AObject := nil;
  end;
end;
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
//Table:
// - DIVISIONS = stredisko
// - STORES = sklad
function getIdFromCode(OS: TNxCustomObjectSpace; Table, Code: string; whereAnd : string = ''): string;
var
  list : TStringList;
begin
  list:= TStringList.create;
  try
    case DB_TYPE of
      0: OS.SQLSelect('SELECT FIRST 1 Id FROM '+Table+' WHERE Code='+QuotedStr(Code)+' '+whereAnd, list);
      1: OS.SQLSelect('SELECT TOP   1 Id FROM '+Table+' WHERE Code='+QuotedStr(Code)+' '+whereAnd, list);
      2: OS.SQLSelect('SELECT Id FROM ' + Table + ' WHERE Code = ' + QuotedStr(Code) + ' ' + whereAnd + ' rownum = 1', list);
      3, 4: OS.SQLSelect('SELECT Id FROM ' + Table + ' WHERE Code = ' + QuotedStr(Code) + ' ' + whereAnd + ' FETCH NEXT 1 ROWS ONLY', list);
      else exit;
    end;

    if(list.count > 0)then
      result:= trim(list.strings[0])
    else
      result:= '';
  finally
    list.free;
  end;
end;//getIdFromCode
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
function getIdWhere(OS: TNxCustomObjectSpace; Table, where : string): string;
var
  list : TStringList;
begin
  list:= TStringList.create;
  try
    case DB_TYPE of
      0: OS.SQLSelect('SELECT FIRST 1 Id FROM '+Table+' WHERE '+where, list);
      1: OS.SQLSelect('SELECT TOP   1 Id FROM '+Table+' WHERE '+where, list);
      2: OS.SQLSelect('SELECT Id FROM ' + Table + ' WHERE ' + where + ' rownum = 1', list);
      3, 4: OS.SQLSelect('SELECT Id FROM ' + Table + ' WHERE ' + where + ' FETCH NEXT 1 ROWS ONLY', list);
      else exit;
    end;

    if(list.count > 0)then
      result:= trim(list.strings[0])
    else
      result:= '';
  finally
    list.free;
  end;
end;//getIdWhere
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
function getCodeFromId(OS: TNxCustomObjectSpace; Table, Id : string): string;
var
  list : TStringList;
begin
  list:= TStringList.create;
  try
    case DB_TYPE of
      0: OS.SQLSelect('SELECT FIRST 1 Code FROM '+Table+' WHERE id='+QuotedStr(id), list);
      1: OS.SQLSelect('SELECT TOP   1 Code FROM '+Table+' WHERE id='+QuotedStr(id), list);
      2: OS.SQLSelect('SELECT Code FROM ' + Table + ' WHERE id = ' + QuotedStr(id) + ' rownum = 1', list);
      3, 4: OS.SQLSelect('SELECT Code FROM ' + Table + ' WHERE id = ' + QuotedStr(id) + ' FETCH NEXT 1 ROWS ONLY', list);
      else exit;
    end;

    if(list.count > 0)then
      result:= trim(list.strings[0])
    else
      result:= '';
  finally
    list.free;
  end;
end;//getCodeFromId
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
function getFieldFromId(OS: TNxCustomObjectSpace; Table, Id, Field : string): string;
var
  list : TStringList;
begin
  list:= TStringList.create;
  try
    case DB_TYPE of
      0: OS.SQLSelect('SELECT FIRST 1 '+Field+' FROM '+Table+' WHERE id='+QuotedStr(id), list);
      1: OS.SQLSelect('SELECT TOP   1 '+Field+' FROM '+Table+' WHERE id='+QuotedStr(id), list);
      2: OS.SQLSelect('SELECT ' + Field + ' FROM ' + Table + ' WHERE id = ' + QuotedStr(id) + ' rownum = 1', list);
      3, 4: OS.SQLSelect('SELECT ' + Field + ' FROM ' + Table + ' WHERE id = ' + QuotedStr(id) + ' FETCH NEXT 1 ROWS ONLY', list);
      else exit;
    end;

    if(list.count > 0)AND (list.strings[0] <> '""')then //pokud je vysledek NULL, tak dostanu ""
      result:= AnsiDequotedStr(trim(list.strings[0]), list.QuoteChar)
    else
      result:= '';
  finally
    list.free;
  end;
end;//getFieldFromId
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
function getFieldFromWhere(OS: TNxCustomObjectSpace; Field, Table, Where : string): string;
var
  list : TStringList;
begin
  list:= TStringList.create;
  try
    case DB_TYPE of
      0: OS.SQLSelect('SELECT FIRST 1 '+Field+' FROM '+Table+' WHERE '+Where, list);
      1: OS.SQLSelect('SELECT TOP   1 '+Field+' FROM '+Table+' WHERE '+Where, list);
      2: OS.SQLSelect('SELECT ' + Field + ' FROM ' + Table + ' WHERE ' + Where + ' rownum = 1', list);
      3, 4: OS.SQLSelect('SELECT ' + Field + ' FROM ' + Table + ' WHERE ' + Where + ' FETCH NEXT 1 ROWS ONLY', list);
      else exit;
    end;

    if(list.count > 0)AND (list.strings[0] <> '""')then //pokud je vysledek NULL, tak dostanu ""
      result:= AnsiDequotedStr(trim(list.strings[0]), list.QuoteChar)
    else
      result:= '';
  finally
    list.free;
  end;
end;//getFieldFromId
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
function SQLSelectStr(OS: TNxCustomObjectSpace; SQLString: string): string;
var
  list : TStringList;
begin
  list:= TStringList.create;
  try
    OS.SQLSelect(SQLString, list);

    if(list.count > 0)AND (list.strings[0] <> '""')then //pokud je vysledek NULL, tak dostanu ""
      result:= AnsiDequotedStr(trim(list.strings[0]), list.QuoteChar)
    else
      result:= '';
  finally
    list.free;
  end;
end;//SQLSelectStr
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
function SQLSelectInt(OS: TNxCustomObjectSpace; SQLString: string): integer;
var
  list : TStringList;
begin
  list:= TStringList.create;
  try
    OS.SQLSelect(SQLString, list);

    if(list.count > 0)then
      result:= StrToIntDef(trim(list.strings[0]), 0)
    else
      result:= 0;
  finally
    list.free;
  end;
end;//SQLSelectInt
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
function SQLSelectFloat(OS: TNxCustomObjectSpace; SQLString: string): double;
var
  list : TStringList;
begin
  list:= TStringList.create;
  try
    OS.SQLSelect(SQLString, list);

    if(list.count > 0)then
      result:= StrToFloatDef(trim(list.strings[0]),0)
    else
      result:= 0;
  finally
    list.free;
  end;
end;//SQLSelectFloat
////////////////////////////////////////////////////////////////////////////////



////////////////////////////////////////////////////////////////////////////////
//vrati text ze vsech radku oddeleny Delimiterem
//Quoted - uzavrit jednotlive prvky do apostrofu?
//predelano na TMemoryStream - zrychleni
function SQLSelectStrDelimited(OS: TNxCustomObjectSpace; SQLString, Delimiter: string; Quoted: boolean = false; QuoteChr : char = ''''): string;
var
  list : TMemTable;
  first: boolean;
  str  : TMemoryStream;
begin
  list:= TMemTable.create(nil);
  str:= TMemoryStream.create();
  try
    OS.SQLSelect2(SQLString, list);

    result:= '';
    if(not list.Active)then exit;

    first:= true;
    list.First;
    while(not list.Eof)do begin
      //pridam oddelovac (pokud nejsu prvni)
      if(first)then
        first:= false
      else
        NxWriteString(str, Delimiter);

      //zapisu hodnotu
      if(Quoted)then
        NxWriteString(str, AnsiQuotedStr(TrimRight(list.FieldList.Fields[0].AsString), QuoteChr))
      else
        NxWriteString(str, TrimRight(list.FieldList.Fields[0].AsString));

      {if(result = '')then begin
        if(Quoted)then
          result:= QuotedStr(TrimRight(list.FieldList.Fields[0].AsString))
        else
          result:= TrimRight(list.FieldList.Fields[0].AsString);
      end else begin
        if(Quoted)then
          result:= result+Delimiter+QuotedStr(TrimRight(list.FieldList.Fields[0].AsString))
        else
          result:= result+Delimiter+TrimRight(list.FieldList.Fields[0].AsString);
      end; }
      list.Next;
    end;
    result:= NxReadString(str);
  finally
    list.free;
    str.free;
  end;
end;//SQLSelectStr
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
//prevede strings na text oddeleny carkou. a kazda hodnota je v apostrofech
function StringsToQuotedList(sl: TStringList): string;
var
  i: integer;
  str: TMemoryStream;
begin
  str:= TMemoryStream.create();
  try
    for i:= 0 to sl.Count-1 do begin
       if(i > 0)then
         NxWriteString(str, ',');
       NxWriteString(str, QuotedStr(sl.Strings[i]));
    end;
    result:= NxReadString(str);
  finally
    str.free;
  end;
end;
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
//prevede text odleleny delimiterem na text oddeleny carkou. a kazda hodnota je v apostrofech
function StringToQuotedList(DelimitedText: string; Delimiter: char = ','): string;
var
  i: integer;
  str: TMemoryStream;
  sl: TStringList;
begin
  sl:= TStringList.Create;
  str:= TMemoryStream.create();
  try
    sl.Delimiter:= Delimiter;
    sl.DelimitedText:= DelimitedText;
    for i:= 0 to sl.Count-1 do begin
       if(i > 0)then
         NxWriteString(str, ',');
       NxWriteString(str, QuotedStr(sl.Strings[i]));
    end;
    result:= NxReadString(str);
  finally
    str.free;
    sl.free;
  end;
end;
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
//funkce pro pouziti v sql dotazech
//predam string obsahujici OID nebo prazdny.
//poku je prazdny vratim text null, jinak vratim text obalejej apostrofama
function QuotedStrOrNull(str: string): string;
begin
  if(NxIsEmptyOID(str))then
    result:= 'NULL'
  else
    result:= QuotedStr(str);
end;
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
//provede update s tim, ze pokud je polozek ID moc, tak jej rozdeli do nekolika dotazu
//sqlUpdate - ocekavam kompletni dotaz pro funkci Format:
//  UPDATE tabulka SET pole=hodnota WHERE id in (%s)
procedure sqlUpdateWhereIdIn(OS: TNxCustomObjectSpace; sqlUpdate: string; slId: tstringList);
const
  MAX_IDs = 500;
var
  mInTransaction: boolean;
  sAux: TMemoryStream;
  start, i: integer;
begin
  if(slId.count <= MAX_IDs)then
    OS.SQLExecute(Format(sqlUpdate, [StringsToQuotedList(slId)]));


  sAux:= TMemoryStream.Create;
  try
    mInTransaction := OS.InTransaction;
    if not mInTransaction then
      OS.StartTransaction(taReadCommited);
    try
      start:= 0;
      repeat
        sAux.Clear;
        sAux.Position:= 0;

        for i:= start to slId.Count-1 do begin
          if(i-start > 0)then
            NxWriteString(sAux, ',');
          NxWriteString(sAux, QuotedStr(slId[i]));

          if(i-start+1 = MAX_IDs)then begin
            start:= i+1;
            break;
          end;
        end;
        OS.SQLExecute(Format(sqlUpdate, [NxReadString(sAux)]));
//        ShowMessage(Format(sqlUpdate, [NxReadString(sAux)]));
      until (i = slId.Count-1);

      //commit
      if not mInTransaction then begin
        OS.Commit;
      end;
    except
      if not mInTransaction then
        OS.RollBack;
      RaiseException(ExceptionMessage);
    end;
  finally
    sAux.free;
  end;
end;
////////////////////////////////////////////////////////////////////////////////

begin
end.
