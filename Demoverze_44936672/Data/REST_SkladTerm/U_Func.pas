(*logovani - nastaveni NEXUS.cfg
[Log.REST]
Level=6
Enabled=1

Úroven informací, které se mají logovat. Platí, že cím vyšší císlo, tím více informací se bude logovat.
0 (System) - systémové informace, typicky spuštení a ukoncení aplikací
1 (Critical) - kritické chyby
2 (Error) - chyby
3 (Warning) - varování : sem zapisuji duvody, proc se neco neulozilo
4 (Notice) - bežná hlášení:
  -sem zapisuji funkci "LogWriteDuration" kazdy dotaz a jeho parametry (trvani a velikost dat)
  -dale zapisuji provedeni tisku
5 (Info) - rozširující informace : nic
6 (Debug) - ladící informace : vse ostatni
*)

uses
  'REST_Licence.libSecurity',
  'REST_SkladTerm.U_Const',
  'REST_SkladTerm.U_Translation',
  'REST_SkladTerm_Special.U_Const',
  'StandardUnits.U_GetId',
  'StandardUnits.U_Relation',
  'StandardUnits.U_PrintReport';

const
  //HTTP statusCode
  HTTP_SC_BadRequest         = 400; //nespravna cesta
  HTTP_SC_Unauthorized       = 401; //chyba autorizace
  HTTP_SC_NotFound           = 404; //nenalezeno
  HTTP_SC_ExpectationFailed  = 417; //vlastni chyba. Nepodarilo se spracovat pozadavek. Chyba pri ukladani BO, ...
  HTTP_SC_InternalServerError= 500; //chyba pri zpracovani pozadavku
  //HTTP_SC_ErrREST_ServiceUnavailable = 503; //toto by mel vracet apache, pokud neni dostupna sluzba

  HTTP_SC_OK       = 200;
  HTTP_SC_Created  = 201; //put ok (vytvoreni noveho)
  HTTP_SC_Accepted = 202; //post/delete ok (ulozeni/smazani)

  ContentType_JSON = 'application/json';
  ContentType_PlainText = 'text/plain';

  //Logovani ukladani
  STATUS_Saved = 1; //uklada se
  STATUS_Save  = 2; //uz je ulozen

  MAX_LOG_LEVEL = 20; //maximalni pocet zanoreni meho logovani
var
  gLog            : TNxCustomLog; //globalni log
  gTimeStart      : TDateTime;    //cas spusteni hlavni funkce
  gLogSectionIndex: integer;      //aktualni sekce. Muzu mit az 20 sekci najednou
  gLogSection     : array[1..MAX_LOG_LEVEL] of string;
  gTimeStartLocal : array[1..MAX_LOG_LEVEL] of TDateTime; //cas START sekce vlogu

function MaxTemporaryStorageDataLength: Integer;
begin
  // radeji nastavim vychozi nizsi velikost
  Result := 4000;
  case DB_TYPE of
    0:       Result := 16000;
    1:       if IsUnicodeVersion then Result := 4000 else Result := 16000;
    2, 3, 4: Result := 4000;
  end;
end;

function IsUnicodeVersion: Boolean;
var
  mVersion: TStringList;
  mMajorVersion, mMinorVersion: Integer;
begin
  Result := False;
  mVersion := TStringList.Create;
  try
    mVersion.Delimiter := '.';
    mVersion.DelimitedText := CFxNxRuntime.NxGetVersionString;

    if mVersion.Count >= 2 then
    begin
      mMajorVersion := StrToInt(mVersion.Strings(0));
      mMinorVersion := StrToInt(mVersion.Strings(1));

      //if (mMajorVersion >= 22) and (mMinorVersion >= 0) then
        Result := True;
    end
    else
      RaiseException('');
  finally
    mVersion.Free;
  end;
end;

// funkce pro spolecne dotazy pro FB i MSSQL
function COLLATION_AI: String;
begin
  Result := ' COLLATE ';
    case DB_TYPE of
      0:    if IsUnicodeVersion then Result := Result + 'UNICODE_CI_AI' else Result := Result + 'WIN_CZ_CI_AI';
      1:    Result := Result + 'Latin1_General_CI_AI';
      2:    Result := '';
      3, 4: Result := Result + 'LATIN_CI';
    end;
    Result := Result + ' ';
end;

// pouzit na zacatku dotazu, kde se pro FB a MSSQL dava na zacatek dotazu hned za SELECT
function FIRST_TOP(ATop: Integer): String;
begin
  Result := '';

  if ATop > 0  then
  begin
    case DB_TYPE of
      0: Result := ' first ' + IntToStr(ATop) + ' ';
      1: Result := ' top ' + IntToStr(ATop) + ' ';
      // pro Oracle 11 vracim musim udelat obalku, abych mel radky spravne serazene, pro 12 nevracim nic
      2: Result := ' * from (select ';
      3, 4: Result := '';
    end;
  end;
end;

// pouzit na konci dotazu, kde se pro Oracle dava na konec dotazu
function FIRST_TOP_ORACLE(ATop: Integer): String;
begin
  Result := '';

  if (ATop > 0) then
  begin
    case DB_TYPE of
      2: Result := ') where rownum < ' + IntToStr(ATop + 1);
      3, 4: Result := ' FETCH NEXT ' + IntToStr(ATop) + ' ROWS ONLY';
    end;
  end;
end;

function CONCAT_STR: String;
begin
  case DB_TYPE of
    0, 2, 3, 4: Result := ' || ';
    1: Result := ' + ';
  end;
end;

function PAD_LEFT(AField: String; APad: Char; ALength: Integer): String;
begin
  case DB_TYPE of
    0, 2, 3, 4: Result := 'cast(lpad(cast(' + AField + ' as varchar(' + IntToStr(ALength) + ')), ' + IntToStr(ALength) + ', ' + QuotedStr(APad) + ') as varchar(' + IntToStr(ALength) + '))';
    1: Result := 'REPLICATE(' + QuotedStr(APad) + ', ' + IntToStr(ALength) + ' - LEN(RTRIM(' + AField + '))) + RTRIM(' + AField + ')';
  end;
end;

function PAD_RIGHT(AField: String; APad: Char; ALength: Integer): String;
begin
  case DB_TYPE of
    0, 2, 3, 4: Result := 'cast(rpad(cast(' + AField + ' as varchar(' + IntToStr(ALength) + ')), ' + IntToStr(ALength) + ', ' + QuotedStr(APad) + ') as varchar(' + IntToStr(ALength) + '))';
    1: Result := 'RTRIM(' + AField + ') + ' + 'REPLICATE(' + QuotedStr(APad) + ', ' + IntToStr(ALength) + ' - LEN(RTRIM(' + AField + ')))';
  end;
end;

function FUNCTION_PREFIX: String;
begin
  case DB_TYPE of
    0, 2, 3, 4: Result := '';
    1: Result := 'dbo.';
  end;
end;

function FROM_1_RECORD: String;
begin
  case DB_TYPE of
    0: Result := ' from RDB$DATABASE ';
    1: Result := '';
    2, 3, 4: Result := ' from dual ';
  end;
end;

////////////////////////////////////////////////////////////////////////////////
//normalizuje string
function jString(s:string):string;
begin
  s:= AnsiReplaceStr(s, '\', '\\');
  s:= AnsiReplaceStr(s, '"', '\"');
  s:= AnsiReplaceStr(s, chr(13)+chr(10), '\n');
  s:= AnsiReplaceStr(s, chr(13), '\n');
  s:= AnsiReplaceStr(s, chr(10), '\n');
  s:= AnsiReplaceStr(s, chr(9), '\t');
  result:= s;
end;
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
function json_DateURLToStr(str: string): tDate;
var
  y,m,d: word;
begin
  result:= EncodeDateTime(
  StrToIntDef(copy(str, 1, 4), 0), //y
  StrToIntDef(copy(str, 5, 2), 0), //m
  StrToIntDef(copy(str, 7, 2), 0), //d
  StrToIntDef(copy(str, 9, 2), 0), //h
  StrToIntDef(copy(str, 11, 2), 0), //m
  0, //s
  0 //ms
  );
end;
////////////////////////////////////////////////////////////////////////////////

function PlainResponse(msg: string): string;
var
  json: TJSONSuperObject;
begin
  json := TJSONSuperObject.CreateByDataType(jtObject);
  try
    json.S['message'] := msg;
    Result := json.AsJson(false, true);
  finally
    json.Free;
  end;
end;

////////////////////////////////////////////////////////////////////////////////
function getHeaderValue(ARequest: TNxHTTPRequest; name: string): string;
var
  header: TStringList;
begin
  header:= TStringList.Create;
  try
    header.Text:= ARequest.Header.AllHeaders;
    result:= header.Values[name];
  finally
    header.free;
  end;
end;
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
//vraci OK, pokud je autorizace v poradku (spravne jmeno a heslo)
function HTTP_Authorization(OS: TNxCustomObjectSpace;
  ARequest: TNxHTTPRequest; AResponse: TNxHTTPResponse): boolean;
var
  Auth: string;
  sInputDecodeAuth, sRequireAuth: String;
  ErrDesc: string;
  mSL: TStringList;
  mDeviceID: String;
begin
  //vypisu si hlavicku
  gLog.WriteEventFmt(logDebug, 'HEADERS: %s', [ARequest.Header.AllHeaders]);

  mSL := TStringList.Create;
  try
    mSL.Text := ARequest.Header.AllHeaders;
    mDeviceID := mSL.Values['DeviceID'];
  finally
    mSL.Free;
  end;

  glog.WriteEventFmt(logDebug, 'Authorization:%s', [ARequest.Header.Authorization]);

  //overit zda je zapnuto licencovani
  if CheckLicence then
  begin
    if ABRA then
      Result := not NxIsBlank(mDeviceID) and CheckLicense(OS, mDeviceID, ErrDesc)
    else
      Result := not NxIsBlank(mDeviceID) and CheckLicense(OS, mDeviceID, '7');
  end
  else begin
    Result := true;
  end;

  if not Result then
  begin
    if ABRA then
      glog.WriteEventFmt(logWarning, ErrDesc, [''])
    else
    begin
      ErrDesc := Format(getString('not_licenced'), [mDeviceID]);
      glog.WriteEventFmt(logWarning, 'Authorization: Device "%s" not licensed', [mDeviceID])
    end;
  end;

  if Result then
  begin
    //ARequest.Header.Authorization vraci jmeno:heslo zakodovane pomoci Base64
    // a na zacatku je jese typ autentizace. napr.: Basic ZmxvcmVzOmRlbW8=
    //online generator: http://www.xorbin.com/tools/base64-encoder-and-decoder
    result:= false;
    ErrDesc:= '';
    auth:= ARequest.Header.Authorization;
    if(pos('Basic ', auth) = 1)then begin //tup autentizace
      auth:= trim(copy(auth, Length('Basic ')+1, 100));

      //rozkoduju jmeno:heslo a porovnam zda je ok
      if trim(auth) = '' then
        result := false
      else begin
        sInputDecodeAuth := TEncoding.ANSI.GetString(DecodeBase64(auth));
        sRequireAuth     := Authorization_Login+':'+Authorization_Password;
        if sInputDecodeAuth = sRequireAuth then
          result := true;
      end;

      if(result)then begin
        glog.WriteEvent(logDebug, 'Authorization: OK')
      end else begin
        ErrDesc:= 'Authorization: Error ';
        glog.WriteEventFmt(logWarning, 'Authorization: Error %s', [trim(TEncoding.ANSI.GetString(DecodeBase64(auth)))])
      end;
          //'('+
          //Authorization_Login+':'+Authorization_Password+'/'+
          //trim(DecodeBase64(auth))+')';
    end else
      ErrDesc:= 'Authorization: ErrorHeader ('+ARequest.Header.Authorization+')';
  end;

  if(not result)then
    ErrREST(ARequest, AResponse, HTTP_SC_Unauthorized, ErrDesc);
end;
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
//chyba pozadavku
function ErrREST(ARequest: TNxHTTPRequest; AResponse: TNxHTTPResponse; StatusCode: integer; Desc: string = ''): boolean;
begin
  if(Desc = '')then
    glog.WriteEventFmt(logError, 'ErrREST number:%d path:%s', [StatusCode, getRequestPath(ARequest)])
  else
    glog.WriteEventFmt(logError, 'ErrREST number:%d path:%s %s%s', [StatusCode, getRequestPath(ARequest), #13#10, Desc]);

  HTTPResponse(AResponse, StatusCode, ContentType_PlainText, Desc {PlainResponse(Desc)});
end;
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
//odpoved
function HTTPResponse(AResponse: TNxHTTPResponse; StatusCode: integer; ContentType, Body: string;
  CharsetConv: boolean = true): boolean;
begin
  glog.WriteEventFmt(logDebug, 'Response:%s', [Body]);
  AResponse.StatusCode:= StatusCode;
  AResponse.Content.ContentType:= ContentType+'; charset=UTF-8';
  if(Length(Body) > 0)then
    AResponse.Content.Content:= TEncoding.UTF8.GetBytes(Body);
  glog.WriteEvent(logDebug, 'Response OK');
end;
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
//nastaveni statusu zaznamu jako provedeny
procedure TemporaryStorageCommit(OS: TNxCustomObjectSpace; DocId: integer);
begin
  OS.SQLExecute(
    'UPDATE ' + REST_TABLE_TemporaryStorage + nxCrLf +
    'set [status] = 1' + nxCrLf +
    'where ID = ' + IntToStr(DocId)
  );
end;
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
//z predaneho Contetnu vytahne pole "docId"
//predpokladam ze tam docId vzdy je. Pokud ne, tak si musim osetrit vyjimku
function getDocId(Content: String): integer;
var
  mJSON_Root: TJSONSuperObject;
begin
  mJSON_Root:= TJSONSuperObject.ParseString(Content,true);
  try
    try
      result:= mJSON_Root.I['docId'];
      if(result = 0)then
        RaiseException('DocId=0');
    except
      RaiseException(getString('error_during_doc_saving')+#13#10+
        'Error getDocId'+#13#10+
        ExceptionMessage);
    end;
  finally
    mJSON_Root.free;
  end;
end;
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
//v sqlWhere umoznim zadat specilani zjednoduseny kod, ze ktereho si nasledne postavim SQL podminku
//v takovem pripade cekam na zacatku #NAZEV# nasledovany dvojicemi field=value oddelene carkou
//Funkce vrati NAZEV a v parametru stringList s hodnotama
function getWhere(s: string; var sl: TStringList): string;
var
  i: integer;
begin
  gLog.WriteEventFmt(logDebug, 'getWhere:%s', [s]);
  result:= '';

  //neni znak #. Budu to brat jako sql podminku nebo budu ignorovat
  if(s[1] <> '#')then exit;

  //zjistim jmeno
  s:= copy(s, 2, 500);//odstranim prvni #
  Result:= copy(s, 1, pos('#', s)-1);
  s:= copy(s, pos('#', s)+1, 500); //odstranim nazev a druhy #

  //prevedu na stringlist
  sl.CommaText:= s;
  //odstranim zabaleni do uvozovek z hodnoty
  for i:= 0 to sl.Count-1 do
    sl.ValueFromIndex[i]:= AnsiDequotedStr(sl.ValueFromIndex[i], '"');

  gLog.WriteEventFmt(logDebug, 'getWhere result:name=%s value=%s', [Result, sl.CommaText]);
end;
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
procedure LogWriteDuration(aLabel: string; ARequest: TNxHTTPRequest; AResponse: TNxHTTPResponse);
begin
  //log trvani
  gLog.WriteEventFmt(logNotice,
    '%s;trvani(s):%n;IN(Byte):%d;OUT(Byte):%d;%s;product:%s;version:%s;GUID:%s;User_ID:%s',[
    aLabel,
    (now-gTimeStart)*86400,
    Length(ARequest.Content.Content),
    Length(AResponse.Content.Content),
    getRequestPath(ARequest),
    getHeaderValue(ARequest, 'Product'),
    getHeaderValue(ARequest, 'Version'),
    getHeaderValue(ARequest, 'GUID'),
    getHeaderValue(ARequest, 'user_id')
  ]);
end;
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
//vstup do sekce. zapamatuju si cas a pri vystupu napisi dobu trvani
procedure LogWriteSectionStart(Section: string);
begin
  gLogSectionIndex:= gLogSectionIndex+1;

  //osetreni prekroceni MAX_LOG_LEVEL
  if(gLogSectionIndex > MAX_LOG_LEVEL)then begin
    gLog.WriteEvent(logDebug, 'MAX_LOG_LEVEL byl prekrocen. gLogSectionIndex=' + IntToStr(gLogSectionIndex));
    exit;
  end;

  gTimeStartLocal[gLogSectionIndex] := now;
  gLogSection[gLogSectionIndex] := Section;
  gLog.WriteEvent(logDebug, NxPadR('', gLogSectionIndex - 1, '..') + Section);
end;
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
//vstup do sekce. zapamatuju si cas a pri vystupu napisi dobu trvani
procedure LogWriteSectionEnd;
begin
  //osetreni prekroceni MAX_LOG_LEVEL
  if(gLogSectionIndex > MAX_LOG_LEVEL)then begin
    gLogSectionIndex:= gLogSectionIndex-1;
    exit;
  end;

  gLog.WriteEventFmt(logDebug, '%s%s - (%n s)',
    [NxPadR('', gLogSectionIndex - 1, '..'),
     gLogSection[gLogSectionIndex],
     (now - gTimeStartLocal[gLogSectionIndex]) * 86400
  ]);
  gLogSectionIndex:= gLogSectionIndex - 1;
end;
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
//z uzivatele z pole X_Printer vrati nazev tiskarny.
//check = true - Zkontroluje zda existuje.
function getPrinterName(OS:TNxCustomObjectSpace; user_id: string; check: boolean):string;
begin
  result:= sqlselectstr(OS, 'select x_printer from SecurityUsers WITH (NoLock) where id='+QuotedStr(user_id));
  gLog.WriteEventFmt(logDebug, 'Tiskarna uzivatele %s: %s', [user_id, Result]);
  if(result = '')then exit;

  //jeste proverim, ze takova tiskarna existuje
  if(not check)then exit;
  if(Printer.Printers.IndexOf(result) = -1)then begin
    result:= '';
    gLog.WriteEvent(logDebug, 'Tiskarna neexistuje.');
  end else begin
    gLog.WriteEvent(logDebug, 'Tiskarna existuje.');
  end;
end;
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
//Zkontroluje zda existuje tiskarna
function checkPrinterName(OS:TNxCustomObjectSpace; printName: string):boolean;
begin
  //jeste proverim, ze takova tiskarna existuje
  if(Printer.Printers.IndexOf(printName) = -1)then begin
    result:= false;
    gLog.WriteEvent(logDebug, 'Tiskarna neexistuje: '+printName);
    gLog.WriteEvent(logDebug, 'Tiskarny: '+nxcrlf+Printer.Printers.CommaText);
  end else begin
    result:= true;
    //gLog.WriteEvent(logDebug, 'Tiskarna existuje: '+printName);
  end;
end;
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
// zaradi tisk do fronty. Zni jej tiskna planovana uloha.
// lze pridat parametry, ktere se zaradi do globalni promenne a budou dostupne v sestave
procedure PrintReportToPrinterByIDToQueue(AContext: TNxContext; AID: String; ADynSourceID: TNxPackedGuid;
  AReportID: String; AFilepath: String; APrinterName: String; User_ID: String; Copies: Integer; AParameters: String = '');
var
  OS: TNxCustomObjectSpace;
  mSql: String;
begin
  OS:= AContext.GetObjectSpace;
  if Assigned(gLog) then
    gLog.WriteEventFmt(logDebug, 'PrintReportToPrinterByIDToQueue document_id:%s report_id=%s filepath=%s parameters=%s',
      [AID, AReportID, AFilepath, AParameters]);

  if not CFxOID.IsEmpty(AReportID) and (ADynSourceID = '') then
    ADynSourceID := PrintReport_GetDynSQL(OS, AReportID);

  //pokud nemam uzivatele, tak musim vlozit nejakeho platneho 0 tkaze supervisor
  if(NxIsEmptyOID(User_ID))then User_ID:= 'SUPER00000';

  //ulozim si do tabulky, z niz bude planovana uloha dokumenty tisknout
  mSql :=
    'INSERT INTO ' + REST_TABLE_Print + nxCrLf +
    '  (User_ID, Document_ID, DynSource_ID, Report_ID, Filepath, PrinterName, Date$Date, Status, Error, Copies, DatePrint$Date, Parameters)' + nxCrLf +
    'VALUES (' + nxCrLf +
    '  ' + QuotedStr(User_ID) + ',' + nxCrLf +
    '  ' + QuotedStr(AID) + ',' + nxCrLf +
    '  ' + QuotedStr(ADynSourceID) + ',' + nxCrLf +
    '  ' + QuotedStr(AReportID) + ',' + nxCrLf +
    '  ' + QuotedStr(AFilepath) + ',' + nxCrLf +
    '  ' + QuotedStr(APrinterName) + ',' + nxCrLf +
    '  ' + NxFloatToIBStr(now) + ',' + nxCrLf +
    '  0,' + nxCrLf +
    '  ' + QuotedStr('') + ',' + nxCrLf +
    '  ' + IntToStr(copies) + ',' + nxCrLf +
    '  ' + NxFloatToIBStr(now) + ',' + nxCrLf +
    '  ' + QuotedStr(AParameters) + nxCrLf +
    ')';
  OS.SQLExecute(mSql);
end;
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
//zaradi tisk do fronty. Tisknce vice dokladu najednou
procedure PrintReportToPrinterByIDsToQueue(AContext: TNxContext; AIDs: TStringList; ADynSourceID: TNxPackedGuid;
  AReportID: String; AFilepath: String; APrinterName: String; User_ID: string; Copies: integer);
var
  OS: TNxCustomObjectSpace;
begin
  if not Assigned(AIDs) then
  begin
    if Assigned(gLog) then
      gLog.WriteEvent(logError, 'PrintReportToPrinterByIDsToQueue EMPTY IDS LIST');
    exit;
  end;

  AIDs.Delimiter := ';';

  PrintReportToPrinterByIDToQueue(AContext, AIDs.DelimitedText, ADynSourceID, AReportID, AFilepath, APrinterName, User_ID, Copies);
end;
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
//vytiskne pozadovany report na zadanou tiskarnu
procedure PrintReportToPrinterByID(AContext: TNxContext; AID: string;
  ADynSourceID: TNxPackedGuid; AReportID: String; APrinterName: String; Copies: integer);
var
  slID: TStringList;
begin
  if(APrinterName = '')then
    RaiseException(getString('printer_not_entered'));

  if(ADynSourceID = '')then
    ADynSourceID:= PrintReport_GetDynSQL(AContext.GetObjectSpace, AReportID);

  slID:= TStringList.Create;
  try
    slID.Delimiter := ';';
    // pokud je v ID strednik, znamena to ze jde o vice dokladu. Nastavim je tedy do string listu
    if pos(';', AID) > 0 then
      slID.DelimitedText := AID
    else
      slID.Add(AID);

//    NxPrintByIDs(AContext, slID, ADynSourceID, AReportID, rtoPreview, pekARP, '', '');
    CFxReportManager.PrintByIDs(AContext, slID, ADynSourceID, AReportID, rtoPrint, pekARP, APrinterName, '', Copies)
  finally
    slID.free;
  end;
end;
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
//vytiskne pozadovany report do temp souboru. Uzivatel by jej mel po sobe smazat.
function PrintReportToTempFile(AContext: TNxContext; AID: string;
  ADynSourceID: TNxPackedGuid; AReportID: String): string;
var
  slID: TStringList;
  path: string;
  filename: string;
begin
  //temp adresar a temp nazev
  path:= NxEvalParametersExprAsString(AContext.GetObjectSpace, nil, 'NxGetSpecialFolder(6)');
  filename:= 'Příloha-'+CFxGuid.CreateNew+'.pdf';
  result:= path +'\'+filename ;

  if(ADynSourceID = '')then
    ADynSourceID:= PrintReport_GetDynSQL(AContext.GetObjectSpace, AReportID);

  slID:= TStringList.Create;
  try
    slID.Add(AID);
    NxPrintByIDs(AContext, slID, ADynSourceID, AReportID, rtoFile, pekPDF, path, filename);
  finally
    slID.free;
  end;
end;
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
//Pomocí procedury vytvoříme vazbu
procedure CreateRel(cObj: TNxCustomObjectSpace;ARelDef : integer;
  ALeftSide_ID: string; ARightSide_ID: string; NumValue: integer = 0);
var mRelace: TNxCustomBusinessObject;
begin
  mRelace := cObj.CreateObject(Class_Relation);
  try
    mRelace.New;
    mRelace.Prefill;
    mRelace.SetFieldValueAsInteger('REL_DEF'     , ARelDef);
    mRelace.SetFieldValueAsString ('LEFTSIDE_ID' , ALeftSide_ID);
    mRelace.SetFieldValueAsString ('RIGHTSIDE_ID', ARightSide_ID);
    mRelace.SetFieldValueAsFloat  ('NUMVALUE'    , NumValue);
    mRelace.Save;
  finally;
    mRelace.free;
  end;
end;
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
//path je v ansi i pres to ze je ve stringu. To je asi chyba.
//Ja si to zde prekoduju
function getRequestPath(ARequest: TNxHTTPRequest): string;
begin
  if(Length(ARequest.Path) = 0)then
    result:= ''
  else
    result:= TEncoding.UTF8.GetString(TEncoding.ANSI.GetBytes(ARequest.Path));
end;
////////////////////////////////////////////////////////////////////////////////

//rozparsruju si cestu a vytahnu prvni cast (/xxx/)
procedure ParsePath(path: string; slPath: TStringList);
var s, adr: string;
    i, len: integer;
begin
  //slPath.Delimiter:= '/';    - TOHLE NEFUNGUJE PRO MEZERY V URL
  //slPath.DelimitedText:= CharsetConversion(copy(ARequest.Path, 2, 1000), UTF_8, CP1250);
  //s := CharsetConversion(copy(path, 2, 1000), UTF_8, CP1250);
  s := TEncoding.ANSI.GetString(TEncoding.Convert(TEncoding.UTF8.GetBytes(copy(path, 2, 1000)), Encoding_cpUTF_8, Encoding_cp1250));
  adr := '';
  len := length(s);
  for i:=1 to len do
  begin
    if s[i] = '/' then
    begin
      slPath.Append(adr);
      adr := '';
    end else
    begin
      adr := adr + s[i];
    end;
  end;
  slPath.Append(adr);

  // pote, co mame rozparsovano podle lomitek, jeste provedeme URLDecode znaku / a \ - v nekterych castech URL mohly byt tyto znaky zakodovane
  // a v apachi mame nastaveno, aby je nechal zakodovane, aby nam prosly az sem a nezkazili cestu v URL
  // v dalsim zpracovani je uz ale chceme videt jako puvodni znaky / a \
  for i := 0 to slPath.Count - 1 do
  begin
    // ostatni znaky krome lomitek uz apache rozkodoval, takze nemuzeme pouzit CFxInternet.URLDecode
    //slPath.Strings[i] := CFxInternet.URLDecode(slPath.Strings[i]);
    s := slPath.Strings[i];
    s := NxSearchReplace(s, '%2F', '/', [srAll]);
    s := NxSearchReplace(s, '%5C', '\', [srAll]);
    slPath.Strings[i] := s;
  end;
end;

// vrati pole pro stav dokladu dle typu systemu
function GetStatusField: String;
begin
  if ABRA then
    Result := 'PMState_ID'
  else
    Result := 'Status_ID';
end;

// vraci nazev tabulky podle typu dokladu
function GetTable(ADocType: String): String;
begin
  case ADocType of
    DOC_ReceiptCard:                    Result := 'StoreDocuments';
    DOC_BillOfDelivery:                 Result := 'StoreDocuments';
    DOC_RefundedBillOfDelivery:         Result := 'StoreDocuments';
    DOC_OutgoingTransfer:               Result := 'StoreDocuments';
    DOC_IncomingTransfer:               Result := 'StoreDocuments';
    DOC_ShippingList:                   Result := 'ShippingLists';
    DOC_RemovalList:                    if ABRA then Result := 'PickingLists' else Result := 'RemovalLists';
    DOC_MaterialDistribution:           Result := 'StoreDocuments';
    DOC_ProductReception:               Result := 'StoreDocuments';
    DOC_RefundedMaterialDistribution:   Result := 'StoreDocuments';
    DOC_JobOrder:                       Result := 'PRFJobOrders';
    DOC_IncomingSubstitution:           Result := 'StoreDocuments';
    DOC_IncomingTransformation:         Result := 'StoreDocuments';
    DOC_IssuedOrder:                    Result := 'IssuedOrders';
    DOC_LogStoreTransfer:               Result := 'LogStoreDocuments';
    DOC_OutgoingSubstitution:           Result := 'StoreDocuments';
    DOC_OutgoingTransformation:         Result := 'StoreDocuments';
    DOC_WorkshopSchedule:               Result := 'PRFWorkShopSchedules';
    else Result := '';
  end;
end;

// vrací BO třídy odpovídající typu skladového dokladu
function GetStoreDocBO(AOS: TNxCustomObjectSpace; ADocType: String): TNxCustomBusinessObject;
begin
  Result := AOS.CreateObject(GetStoreDocClass(ADocType));
end;

// vrací BO třídy odpovídající typu skladového dokladu
function GetStoreDocClass(ADocType: String): TNxPackedGUID;
begin
  case ADocType of
    DOC_ReceiptCard:                    Result := Class_ReceiptCard;
    DOC_BillOfDelivery:                 Result := Class_BillOfDelivery;
    DOC_RefundedBillOfDelivery:         Result := Class_RefundedBillOfDelivery;
    DOC_OutgoingTransfer:               Result := Class_OutgoingTransfer;
    DOC_IncomingTransfer:               Result := Class_IncomingTransfer;
    DOC_ShippingList:                   Result := Class_ShippingList;
    DOC_RemovalList:                    Result := Class_RemovalList;
    DOC_JobOrder:                       Result := Class_PRFJobOrder;
    DOC_WorkShopSchedule:               Result := Class_PRFWorkshopSchedule;
    DOC_MaterialDistribution:           Result := Class_MaterialDistribution;
    DOC_ProductReception:               Result := Class_ProductReception;
    DOC_RefundedMaterialDistribution:   Result := Class_RefundedMaterialDistribution;
    DOC_IncomingSubstitution:           Result := Class_IncomingSubstitution;
    DOC_IncomingTransformation:         Result := Class_IncomingTransformation;
    DOC_IssuedOrder:                    Result := Class_IssuedOrder;
    DOC_LogStoreInput:                  Result := Class_LogStoreInput;
    DOC_LogStoreOutput:                 Result := Class_LogStoreOutput;
    DOC_LogStoreTransfer:               Result := Class_LogStoreTransfer;
    DOC_OutgoingSubstitution:           Result := Class_OutgoingSubstitution;
    DOC_OutgoingTransformation:         Result := Class_OutgoingTransformation;
    else Result := '';
  end;
end;

// vraci typ a BO třídy určeného skladového dokladu
function GetStoreDocBOID(docID: string; os: TNxCustomObjectSpace; var docTyp: string): TNxCustomBusinessObject;
begin
  docTyp := SQLSelectStr(os, 'SELECT DocumentType from STOREDOCUMENTS WHERE ID=' + QuotedStr(docID));
  result := GetStoreDocBO(os, docTyp);
end;

// vraci typ určeného skladového dokladu
function GetStoreDocType(docID: String; os: TNxCustomObjectSpace): String;
begin
  result := SQLSelectStr(os, 'SELECT DocumentType from STOREDOCUMENTS WHERE ID=' + QuotedStr(docID));
end;

// vraci typ určeného skladového dokladu podle ID radku
function GetStoreDocTypeFromRow(rowID: String; os: TNxCustomObjectSpace): String;
begin
  result := SQLSelectStr(os, 'SELECT SD.DocumentType from STOREDOCUMENTS2 SD2 JOIN StoreDocuments SD on SD.id = SD2.Parent_ID WHERE SD2.ID =' + QuotedStr(rowID));
end;

function GetLogStoreDocBOID(docID: string; os: TNxCustomObjectSpace; var docTyp: string): TNxCustomBusinessObject;
begin
  docTyp := SQLSelectStr(os, 'SELECT DocumentType from LOGSTOREDOCUMENTS WHERE ID=' + QuotedStr(docID));
  result := GetStoreDocBO(os, docTyp);
end;

function GetStringFromBytes(ABytes: TBytes; AEncoding: TEncoding): String;
begin
  if length(ABytes) = 0 then
    Result := ''
  else
    Result := AEncoding.GetString(ABytes);
end;

////////////////////////////////////////////////////////////////////////////////
//podle kodu a predaneho Class_CLSID BO vrati ID rady doklady&amp;#xD;
function GetDocQueueID(AOS: TNxCustomObjectSpace; AClass_CLSID, ACode: String): String;
var
  mDocumentType: String;
begin
  case AClass_CLSID of
    Class_BillOfDelivery:         mDocumentType := DOC_BillOfDelivery;
    Class_IssuedInvoice:          mDocumentType := '03';
    Class_IssuedOffer:            mDocumentType := 'IF';
    Class_IssuedOrder:            mDocumentType := 'IO';
    Class_IncomingSubstitution:   mDocumentType := DOC_IncomingSubstitution;
    Class_IncomingTransformation: mDocumentType := DOC_IncomingTransformation;
    Class_IncomingTransfer:       mDocumentType := DOC_IncomingTransfer;
    Class_InventoryOverplus:      mDocumentType := '25';
    Class_LogStoreInput:          mDocumentType := DOC_LogStoreInput;
    Class_LogStoreOutput:         mDocumentType := DOC_LogStoreOutput;
    Class_LogStoreTransfer:       mDocumentType := DOC_LogStoreTransfer;
    Class_OtherIncome:            mDocumentType := '01';
    Class_OutgoingSubstitution:   mDocumentType := DOC_OutgoingSubstitution;
    Class_OutgoingTransfer:       mDocumentType := DOC_OutgoingTransfer;
    Class_OutgoingTransformation: mDocumentType := DOC_OutgoingTransformation;
    Class_ReceiptCard:            mDocumentType := DOC_ReceiptCard;
    Class_ReceivedOrder:          mDocumentType := DOC_RECEIVEDORDER;
    Class_RefundedBillOfDelivery: mDocumentType := DOC_RefundedBillOfDelivery;
    Class_RemovalList:            if ABRA then mDocumentType := 'PL' else mDocumentType := 'RL';
    Class_ShippingList:           mDocumentType := DOC_ShippingList;
    else RaiseException(Format(getString('unsupported_type'), [AClass_CLSID]));
  end;

  Result:= SQLSelectStr(AOS, 'Select ID FROM DocQueues WHERE Code = ' + QuotedStr(ACode) + ' and DocumentType=' + QuotedStr(mDocumentType));
  if(Result = '') then
    RaiseException(Format(GetString('doc_queue_not_exist'), [ACode, mDocumentType, AClass_CLSID]));
end;
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
function getStatusesFrom4SwitchRules(OS: TNxCustomObjectSpace; SwitchRules_ID: string): string;
begin
  result:= SQLSelectStr(OS,
    'select UserStatusesFrom_ID From UserStatusesSwitchRules '+
    'where id = ' + QuotedStr(SwitchRules_ID));
end;
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
function getStatusesTo4SwitchRules(OS: TNxCustomObjectSpace; SwitchRules_ID: string): string;
begin
  result:= SQLSelectStr(OS,
    'select UserStatusesTo_ID From UserStatusesSwitchRules '+
    'where id = ' + QuotedStr(SwitchRules_ID));
end;
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
function getResponsibleRole4SwitchRules(OS: TNxCustomObjectSpace; SwitchRules_ID: string): string;
begin
  result:= SQLSelectStr(OS,
    'select ResponsibleRole_ID From UserStatusesSwitchRules '+
    'where id = ' + QuotedStr(SwitchRules_ID));
end;
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
function GetSwitchRuleForStatusFromAndStatusTo(OS: TNxCustomObjectSpace; ASwitchRuleFrom_ID, ASwitchRuleTo_ID: String): String;
begin
  Result:= sqlSelectStr(OS,
    'select ID ' +
    'from UserStatusesSwitchRules ' +
    'where UserStatusesFrom_ID = ' + QuotedStr(ASwitchRuleFrom_ID) +
    '  and UserStatusesTo_ID = ' + QuotedStr(ASwitchRuleTo_ID));
end;
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
//Z bajtu v kodovani UTF8 si udelam string
//Musim osetrit nulovou delku
function REST_ByteUTF82String(bytes: TBytes): string;
begin
  if(Length(bytes) = 0)then
    result:= ''
  else
    result:= TEncoding.UTF8.GetString(bytes);
end;
////////////////////////////////////////////////////////////////////////////////

procedure AddTodtDocumentQuantity(dtDocumentQuantity: TMemTable; AStore_ID, AStoreCard_ID, AStoreBatch_ID, AStorePosition_ID: String;
  AQuantity, AUnitRate: Double);
var
  Quantity: Double;
begin
  if AUnitRate <> 0 then
    Quantity := AQuantity * AUnitRate
  else
    Quantity := AQuantity;

  if dtDocumentQuantity.FindKey([AStore_ID, AStoreCard_ID, AStoreBatch_ID, AStorePosition_ID]) then
  begin
    dtDocumentQuantity.Edit;
    dtDocumentQuantity.FieldByName('Quantity').AsFloat := dtDocumentQuantity.FieldByName('Quantity').AsFloat + Quantity;
    dtDocumentQuantity.Post;
  end
  else begin
    dtDocumentQuantity.Append;
    dtDocumentQuantity.FieldByName('Store_ID').AsString := AStore_ID;
    dtDocumentQuantity.FieldByName('StoreCard_ID').AsString := AStoreCard_ID;
    dtDocumentQuantity.FieldByName('StoreBatch_ID').AsString := AStoreBatch_ID;
    dtDocumentQuantity.FieldByName('StorePosition_ID').AsString := AStorePosition_ID;
    dtDocumentQuantity.FieldByName('Quantity').AsFloat := Quantity;
    dtDocumentQuantity.Post;
  end;
end;

procedure ConfirmLSD(AOS: TNxCustomObjectSpace; AClass: TNxPackedGuid; ALSD_ID, AMethodName: String; ALog: TNxCustomLog; AStartTransaction: Boolean = True);
var
  mLSD: TNxCustomBusinessObject;
begin
  if not CFxOID.IsEmpty(ALSD_ID) then
  begin
    mLSD := AOS.CreateObject(AClass);
    mLSD.ExplicitTransaction := True;
    mLSD.Load(ALSD_ID, nil);
    if not mLSD.GetFieldValueAsBoolean('Executed') then
    begin
      if AStartTransaction then
        AOS.StartTransaction(taReadCommited);
      try
        TNxLogStoreDocument(mLSD).MakeExecuted;
        if AStartTransaction then
          AOS.Commit;
      except
        if AStartTransaction then
          AOS.RollBack;
        if Assigned(ALog) then
          ALog.WriteEvent(logError, AMethodName + ' - LSD MakeExecuted - error - '+ALSD_ID+' - '+ExceptionMessage);
      end;
    end;
  end;
end;

function RemoveLeadingZeroes(AStr: String): String;
var
  mStr: String;
begin
  mStr := AStr;
  while (length(mStr) > 0) and (mStr[1] = '0') do
    mStr := copy(mStr, 2, length(mStr));
  Result := mStr;
end;

function getUnitsSql: String;
begin
  case DB_TYPE of
    0: Result := '(select list("Unit", '';'') from (select SU.Code || '':'' || SU.UnitRate "Unit" from StoreUnits SU where SU.Parent_ID = SC.ID))';
    1: Result := 'stuff((select '';'' + SU.Code + '':'' + cast(SU.UnitRate as varchar(30)) from StoreUnits SU where SU.Parent_ID = SC.id order by SU.PosIndex FOR XML PATH(''''), TYPE).value(''.'', ''varchar(max)''), 1, 1, '''')';
    2, 3: Result := '(select listagg(SU.Code || '':'' || SU.UnitRate, '';'') WITHIN GROUP (ORDER BY SU.PosIndex) from StoreUnits SU where SU.Parent_ID = SC.ID)';
    4: Result := '(select listagg(SU.Code || '':'' || SU.UnitRate, '';'') from StoreUnits SU where SU.Parent_ID = SC.ID order by SU.PosIndex)';
  end;
end;

procedure ChangeStatusByRule(ABO: TNxCustomBusinessObject; ARule_ID, AResponsibleRole_ID: String = '0000000000'; AResponsibleUser_ID: String = '0000000000');
begin
// ABRA Start
  NxScriptingLog.WriteEvent(logInfo, ABO.DisplayName+ '   orig state'+ABO.GetFieldValueAsString('PMState_ID')+'   cíl stav: '+ARule_ID+' user'+AResponsibleUser_ID);
  ABO.PMChangeStateByTransition(ARule_ID, AResponsibleRole_ID, AResponsibleUser_ID)
// ABRA End
end;
procedure ChangeStatus(ABO: TNxCustomBusinessObject; AStatus_ID, AResponsibleRole_ID: String = '0000000000'; AResponsibleUser_ID: String = '0000000000');
begin
// ABRA Start
  ABO.PMChangeState(AStatus_ID, AResponsibleRole_ID, AResponsibleUser_ID);
// ABRA End
end;

function getSumUnitQuantityForProvideRow_ID(ADataSet: TDataSet; AProvideRow_ID: String; AProcessed, ADamaged: Boolean;
  ARowUnitRate: Double; AProvideField: String = ''): Double;
var
  mBM: TBookmark;
  mProvideField: String;
begin
  Result := 0;
  if AProvideField <> '' then
    mProvideField := AProvideField
  else
    mProvideField := 'StoreDocument2ProvideRow_ID';

  mBM := ADataSet.GetBookmark;
  ADataSet.First;
  while not ADataSet.EOF do
  begin
    if (ADataSet.FieldByName('Processed').AsBoolean = AProcessed) and (ADataSet.FieldByName('IsDamaged').AsBoolean = ADamaged)
        and (ADataSet.FieldByName(mProvideField).AsString = AProvideRow_ID) then
      Result := Result + CFxFloat.DivideDef6(ADataSet.FieldByName('UnitQuantity').AsFloat * ADataSet.FieldByName('UnitRate').AsFloat, ARowUnitRate, 0);
    ADataSet.Next;
  end;
  ADataSet.GotoBookmark(mBM);
end;

function getStringFieldByProvideRow_ID(ADataSet: TDataSet; ASearchField_ID, AProvideRow_ID, AField: String; AProcessed: Boolean): String;
var
  mBM: TBookmark;
begin
  Result := '';
  mBM := ADataSet.GetBookmark;
  ADataSet.First;
  while not ADataSet.EOF do
  begin
    if (ADataSet.FieldByName('Processed').AsBoolean = AProcessed) and (ADataSet.FieldByName(ASearchField_ID).AsString = AProvideRow_ID) then
    begin
      Result := ADataSet.FieldByName(AField).AsString;
      break;
    end;
    ADataSet.Next;
  end;
  ADataSet.GotoBookmark(mBM);
end;

function getSumUnitQuantityForSD2_ID(ADataSet: TDataSet; SD2_ID: String; AProcessed, ADamaged: Boolean; var AAllSelectedByBarcode: Boolean;
  ARowUnitRate: Double; AField: String = ''): Double;
var
  mBM: TBookmark;
  mField: String;
begin
  Result := 0;
  AAllSelectedByBarcode := True;

  if AField <> '' then
    mField := AField
  else
    mField := 'StoreDocument2_ID';

  mBM := ADataSet.GetBookmark;
  ADataSet.First;
  while not ADataSet.EOF do
  begin
    if (ADataSet.FieldByName('Processed').AsBoolean = AProcessed) and (ADataSet.FieldByName('IsDamaged').AsBoolean = ADamaged)
      and (ADataSet.FieldByName(mField).AsString = SD2_ID) then
    begin
      Result := Result + CFxFloat.DivideDef6(ADataSet.FieldByName('UnitQuantity').AsFloat * ADataSet.FieldByName('UnitRate').AsFloat, ARowUnitRate, 0);
      if not ADataSet.FieldByName('WasSelectedByBarcode').AsBoolean then
        AAllSelectedByBarcode := False;
    end;
    ADataSet.Next;
  end;
  ADataSet.GotoBookmark(mBM);
end;

function getSumUnitQuantityForSD2_IDAndBatch_ID(ADataSet: TDataSet; SD2_ID, StoreBatch_ID: String; AProcessed, ADamaged: Boolean;
  ARowUnitRate: Double;): Double;
var
  mBM: TBookmark;
begin
  Result := 0;
  mBM := ADataSet.GetBookmark;
  ADataSet.First;
  while not ADataSet.EOF do
  begin
    if (ADataSet.FieldByName('Processed').AsBoolean = AProcessed) and (ADataSet.FieldByName('IsDamaged').AsBoolean = ADamaged)
      and (ADataSet.FieldByName('StoreDocument2_ID').AsString = SD2_ID) and (ADataSet.FieldByName('StoreBatch_ID').AsString = StoreBatch_ID)
    then
      Result := Result + CFxFloat.DivideDef6(ADataSet.FieldByName('UnitQuantity').AsFloat * ADataSet.FieldByName('UnitRate').AsFloat, ARowUnitRate, 0);
    ADataSet.Next;
  end;
  ADataSet.GotoBookmark(mBM);
end;

procedure GetFileFromMultiPartStream(AMultiPart: TMemoryStream; var OFileName: String; OFile: TMemoryStream);
var
  a, posZac, posKon, posKonecHeader, pozStream, posun, delka: Integer;
  sStream, sStreamOrig, s, pom, pom2, header, contentType, delimiter: String;
begin
  sStreamOrig := TEncoding.ANSI.GetString(AMultiPart.GetBytes);
  sStream := sStreamOrig;
  delimiter := copy(sStream, 1, pos(#13, sStream) - 1);

  OFileName := '';
  pozStream := 1;
  posun := 0;
  while ansipos(delimiter, sStream) > 0 do
  begin
    posZac := pos(delimiter, sStream);//začátek delimiter
    sStream := copy(sStream, posZac + length(delimiter) + 1, ByteLength(sStream));

    posKon := pos(delimiter,sStream);//konec druhého výskytu delimiteru - konec jedné part v multi part

    pom2 := copy(sStream, 1, posKon);
    posKonecHeader := ansipos(#13+#10+#13+#10, pom2) + 2; //konec headre conctentu, za ním už je content
    header := copy(pom2, 1, posKonecHeader);
    pom:=copy(header, pos('Content-Type:', header) + Length('Content-Type:'), 100);
    contentType := copy(pom, 1, pos(#13+#10, pom));
    pom := copy(header, pos('filename=', header) + Length('filename='), 100);
    OFileName := AnsiReplaceStr(copy(pom,1,pos(#13+#10,pom)-1),'"','');
    OFileName := TEncoding.ANSI.RemoveDiacritics(OFileName);
    OFileName := AnsiReplaceStr(OFileName,'*','_');
    OFileName := AnsiReplaceStr(OFileName,'?','_');
    OFileName := AnsiReplaceStr(OFileName,'/','_');
    OFileName := AnsiReplaceStr(OFileName,'\','_');
    OFileName := AnsiReplaceStr(OFileName,'|','_');
    OFileName := AnsiReplaceStr(OFileName,'<','_');
    OFileName := AnsiReplaceStr(OFileName,'>','_');
    OFileName := AnsiReplaceStr(OFileName,':','_');
    OFileName := AnsiReplaceStr(OFileName,'"','_');

    AMultiPart.Seek(posun + posZac + length(delimiter) + 1 + posKonecHeader, 0);
    delka := posKon - posKonecHeader - (posZac + length(delimiter) + 1) + length(delimiter) - 1;//-(posKonecHeader);

    if OFileName <> '' then
    begin
      OFile.CopyFrom(AMultiPart, delka);
    end;

    if pos(delimiter + '--', sStream) = ansipos(delimiter, sStream) then
      break;
    posun := {pozice odkud jsem kopiroval data}posun + posZac + length(delimiter) + 1 + posKonecHeader
      +{kolik jsem kopiroval znaku} delka;
    sStream := copy(sStreamOrig, posun, Length(sStreamOrig));
    break; //další části mi  z webu neposílají, neřeším je
  end;
end;

function GetRelationWithDocument(ADocType: String): Integer;
begin
  case ADocType of
    DOC_BillOfDelivery:                 Result := rtBillOfDelivery_Doc;
    DOC_OutgoingTransfer:               Result := rtOutgoingTransfer_Doc;
    DOC_IncomingTransfer:               Result := rtIncomingTransfer_Doc;
    DOC_RefundedMaterialDistribution:   Result := rtRefundedMaterialDistribution_Doc;
    DOC_IncomingSubstitution:           Result := rtIncomingSubstitution_Doc;
    DOC_IncomingTransformation:         Result := rtIncomingTransformation_Doc;
    DOC_IssuedOrder:                    Result := rtIssuedOrder_Doc;
    //DOC_JobOrder:                       Result := rtPRFJobOrder_Doc;
    DOC_LogStoreInput:                  Result := rtLogStoreInput_Doc;
    DOC_LogStoreOutput:                 Result := rtLogStoreOutput_Doc;
    DOC_LogStoreTransfer:               Result := rtLogStoreTransfer_Doc;
    DOC_MaterialDistribution:           Result := rtMaterialDistribution_Doc;
    DOC_OutgoingSubstitution:           Result := rtOutgoingSubstitution_Doc;
    DOC_OutgoingTransformation:         Result := rtOutgoingTransformation_Doc;
    DOC_ProductReception:               Result := rtProductReception_Doc;
    DOC_ReceiptCard:                    Result := rtReceiptCard_Doc;
    DOC_RefundedBillOfDelivery:         Result := rtRefundedBillOfDelivery_Doc;
    DOC_RemovalList:                    if ABRA then Result := -1 else Result := rtRemovalList_Doc;
    DOC_ShippingList:                   if ABRA then Result := -1 else Result := rtShippingList_Doc;
    //DOC_WorkShopSchedule:               Result := rtPRFWorkshopSchedule_Doc;
    else Result := -1;
  end;
end;

begin
end.