uses
  'REST_SkladTerm.U_Func',
  'REST_SkladTerm.U_FuncJSON',
  'REST_SkladTerm_Special.U_Const',
  'StandardUnits.U_GetId';

// vraci ID rady, ktera se ma doplnit na doklad (POZOR, ne vzdy musi byt k dispozici ASourceDocument - melo by tedy vychazet z kombinace typu dokladu a scenare)
// ASourceDocType obsahuje typ zdrojoveho dokladu - tedy napr. prijemka pro naskl. do pozic - je vyplneno, pouze pokud dava smysl
// ASourceDocument obsahuje zdrojovy doklad - u volnych dokladu, zde muze byt take primo doklad, kteremu se rada nastavuje
// pokud se nic nevraci, pouzije se vychozi rada z konstant
function GetDocQueue_ID(AOS: TNxCustomObjectSpace; AModule, ADocType, AUser_ID: String; ASourceDocType: String = ''; ASourceDocument: TNxCustomBusinessObject = nil;
  AStore_ID: String = ''): String;
begin
  Result := '';
end;

// AG-6802
// vraci ID strediska, ktere se ma doplnit na radek (POZOR, ne vzdy musi byt k dispozici ADocument - melo by tedy vychazet z kombinace typu dokladu a scenare)
// ADocument obsahuje hlavicku dokladu,
// pokud se nic nevraci, pouzije se vychozi stredisko z konstant
function GetDivision_ID(AOS: TNxCustomObjectSpace; AModule, ADocType, AUser_ID: String; ADocument: TNxCustomBusinessObject = nil): String;
begin
  Result := '';
end;

// ziskani defaultního skladu pro volne doklady podle uzivatele
function getDefaultStoreForUser(AOS: TNxCustomObjectSpace; AUser_ID: String): String;
begin
  Result := '';
end;

// ziskani defaultní firmy pro volne doklady podle uzivatele
function getDefaultFirmForUser(AOS: TNxCustomObjectSpace; AUser_ID: String): String;
begin
  Result := '';
end;

// ziskani skladu podle uzivatele
function getStoreForUser(AOS: TNxCustomObjectSpace; AUser_ID: String): String;
begin
  Result := SKLAD_HLAVNI;
end;

// moznost zafiltrovani skladu, ktere uzivatel muze vybrat ze seznamu
// pokud funkce vrati True, zobrazi se v seznamu pouze sklady z AStoreIDs
function filterStoresForUser(AOS: TNxCustomObjectSpace; AModule, ADocType, AUser_ID: String; AStoreIDs: TStringList): Boolean;
begin
  Result := False;
end;

// podminka, kterou lze omezit pridavané artikly  (listStoreCard a getStoreCardInfo)
function StoreCard_Where(AOS: TNxCustomObjectSpace; AModule, ADocType, AUser_ID: String): String;
begin
  Result := '';
end;

// pole hlavičky dokladu - cislo dokladu, firma, kod firmy, provozovna
// druhy radek argumentu (Label) urcuji popisek
// treti radek urcuje hodnoty
function getHeaderSql_Fields(AOS: TNxCustomObjectSpace; AModule, ADocumentType, AUser_ID: String;
  var OFirmNameLabel, OFirmCodeLabel, OFirmOfficeLabel: String;
  var ODisplayName, OFirmName, OFirmCode, OFirmOffice: String): String;
begin
  // priklad
  //OFirmCodeLabel := QuotedStr('Kód firmy:');
  //OFirmCode := 'F.Code';
end;

// pole, ktere se bude zobrazovat v druhem radku v obrazovce vyberu pozice z jejich seznamu
function listStorePositions_SelectName(AOS: TNxCustomObjectSpace): String;
begin
  Result := 'LSP.Name';
end;

// hodnota druheho radku v obrazovce vyberu sarze (SB je SQL prefix tabulky StoreBatches)
function listStoreBatches_SpecificationField(AOS: TNxCustomObjectSpace; AModule, DocumentType, AUser_ID: String): String;
begin
  Result := 'SB.Specification';
end;

// nazev firmy pri zobrazeni v dokladech (F je SQL prefix tabulky Firms)
function get_FirmInfo_NameField(AOS: TNxCustomObjectSpace; AModule, DocumentType, AUser_ID: String): String;
begin
  Result := 'F.Name';
end;

// volitelna boolean hodnota prenasena s informaci o firme (pouzivano pouze ve specialech)
// vklada se do sloupce v SQL, tabulka Firms je pod aliasem F
function get_FirmInfo_AuxFields(AOS: TNxCustomObjectSpace; AModule, DocumentType, AUser_ID: String): String;
begin
  Result := '';
end;

// hodnota druheho radku v obrazovce vyberu firmy (F je SQL prefix tabulky Frims)
function listFirms_NameField(AOS: TNxCustomObjectSpace; AModule, DocumentType, AUser_ID: String): String;
begin
  Result := 'F.Name';
end;

// umoznuje nadefinovat vlastni hledani v seznamu firem. Vzdy se zobrazuji pouze neskryte firmy a firmy, ktere nejsou predkem
// ASearchStr obsahuje text, ktery skladnik zadal do vyhledavaciho pole
function listFirms_Search(AOS: TnxCustomObjectSpace; ADocType, AModule, AUser_ID, ASearchStr: String): String;
begin
  Result := '';

  if Trim(ASearchStr) <> '' then
    Result := Result + 'and (F.Code' + COLLATION_AI + 'like ''%' + ASearchStr + '%'' ' +
      '  or F.Name' + COLLATION_AI + 'like ''%' + ASearchStr + '%'') ';
end;

// text, ktery se ma predvyplnit do vyhledavani pri prvnim otevreni vyberu dokladu
function defaultSearchString_Prefill(AOS: TnxCustomObjectSpace; AModule, AUser_ID: String; ADocTypes: TStringList): String;
begin
  Result := '';
end;

// umoznuje pridat vlastni join, hlavne k vyuziti vlastniho hledani
function listDocQueue_Join(AOS: TnxCustomObjectSpace; AModule, ADocType, AUser_ID: String): String;
begin
  Result := '';
end;

// umoznuje nadefinovat vlastni hledani v seznamu dokladu
function listDocQueue_Search(AOS: TnxCustomObjectSpace; ADocType, ASearchStr, AModule, AUser_ID: String): String;
begin
  Result := '';

  if ASearchStr <> '' then
  begin
    if (ADocType = DOC_JobOrder) or (ADocType = DOC_WorkshopSchedule) then
      Result :=
        ' and (SD.CodeID' + COLLATION_AI + 'like ''%' + ASearchStr + '%''' + nxCrLf
    else
      Result :=
        ' and (SD.Description' + COLLATION_AI + 'like ''%' + ASearchStr + '%''' + nxCrLf;

    if not (ADocType in [DOC_MainInvProtocol, DOC_PartialInvProtocol]) then
      Result := Result +
        '   or (F.Name' + COLLATION_AI + 'like ''%' + ASearchStr + '%'' ) ' + nxCrLf;

    Result := Result +
      '   or (DQ.Code' + CONCAT_STR + QuotedStr('-') + CONCAT_STR + 'cast(SD.OrdNumber as varchar(6))' +
        CONCAT_STR + QuotedStr('/') + CONCAT_STR + 'P.Code like ''%' + ASearchStr + '%''))';
  end;
end;

// pole, ktera se maji ziskat v SELECTu, ale do ctecky se nedostanou (slouzi napriklad k vlastnimu razeni)
function listDocQueue_AuxNonVisibleFields(AOS: TNxCustomObjectSpace; AModule, ADocType, AUser_ID: String): String;
begin
  Result := ' '''' as "Aux"';
end;

// razeni fronty dokladu
function listDocQueue_OrderBy(AOS: TNxCustomObjectSpace; AModule, ADocType, AUser_ID: String): String;
begin
  Result := ' order by "DocDate$DATE" ';
end;

// pomocne joiny pro predchozi funkci listStorePositions_SelectName
function listStorePositions_Join(AOS: TNxCustomObjectSpace): String;
begin
  Result := '';
end;

// umoznuje pridat omezeni na seznam pozic
function listStorePositions_Search(AOS: TNxCustomObjectSpace; AModule, ADocType, AUser_ID, AStore_ID, AStoreCard_ID,
  AStoreBatch_ID: String): String;
begin
  Result := '';
end;

// Zda se do dostupneho mnozstvi v seznamu pozic ma zahrnovat take rezervovane mnozstvi (standardne se rezervovane mnozstvi odecita od dostupneho)
// Pokud vraci False, dostupne mnozstvi je AvailableQuantity - ReservedQuantity, pokud True, dostupne mnozstvi je pouze AvailableQuantity
function listStorePositions_IncludeReservedQuantity(AOS: TNxCustomObjectSpace; AModule, ADocType, AUser_ID: String): Boolean;
begin
  Result := False;
end;

// vlastni join pro funkci vracejici detail skladu
function get_StoreInfo_Join(AOS: TNxCustomObjectSpace; AModule, AUser_ID: String): String;
begin
  Result := '';
end;

// vlastni join pro funkci vracejici detail artiklu
function get_StoreCardInfo_Join(AOS: TNxCustomObjectSpace; AModule, AUser_ID: String): String;
begin
  Result := '';
end;

// pro vlastni urceni, zda je sklad polohovany
function get_StoreInfo_IsLogistic(AOS: TNxCustomObjectSpace; AModule, AUser_ID: String): String;
begin
  Result := 'S.IsLogistic';
end;

// pole obsahujici navrzenou "pozici z"
// standardne se bere z existujiciho Vyskladneni z pozic
function putQueueDocDetailStartPicking_StorePositionFromJoinField(AOS: TNxCustomObjectSpace; ADocType: String): String;
begin
  Result := 'LSD2.StorePosition_ID';
end;

// pole podle ktereho se vyhledava ve ctecce v seznamu polozek dokladu pri nacteni caroveho kodu
// proste pole, ktere v dane firme obsahuje carovy kod artiklu
// funguje i pro inventury
function putQueueDocDetailStartPicking_StoreCardBarcodeField(AOS: TNxCustomObjectSpace; mModule: String): String;
begin
  Result := 'SC.EAN';

  // priklad - vcetne EANu jednotek - MSSQL
  {Result :=
    '(SC.Code + '';'' + coalesce((select ' +
    '  SU.EAN + '';'' + SE.EAN + '';'' + SE.X_EANEx + '';'' ' +
    'from StoreUnits SU ' +
    'join StoreEANs SE on SE.Parent_ID = SU.ID ' +
    'join StoreCards SC2 on SC2.ID = SU.Parent_ID ' +
    'where SC2.ID =  SC.ID ' +
  	'and (ltrim(rtrim(SU.EAN)) != '''' or ltrim(rtrim(SE.X_EANEx)) != '''' ) ' +
    'FOR XML PATH('''')), ''''))';}
  // priklad - vcetne EANu jednotek - FB
     {Result := '(select list(SE.EAN, '';'') ' +
        'from StoreUnits SU ' +
        'join StoreEANs SE on SE.Parent_ID = SU.ID ' +
        'join StoreCards SC2 on SC2.ID = SU.Parent_ID ' +
        'where SC2.ID =  SC.ID)';}
  // JOKO BARTON2
  Result := '(SELECT list (distinct SC2.code, '';'') || '';'' ' +
        '|| list(SE.EAN, '';'') || '';'' ' +
        '|| coalesce (list (distinct SUP.ExternalNumber, '';''),'''') ' +
        'from StoreCards SC2 ' +
        'left join Suppliers SUP on SUP.storecard_id = SC2.ID ' +
        'left join StoreUnits SU on SC2.ID = SU.Parent_ID ' +
        'left join StoreEANs SE on SE.Parent_ID = SU.ID ' +
        'where SC2.ID =  SC.ID)';
end;

// pole, ktere obsahuje informaci, zda u artiklu evidujeme doplnkovou informaci k seriovemu cislu (napr. IMEI)
function putQueueDocDetailStartPicking_StoreCardAuxInfoForSerNumField(AOS: TNxCustomObjectSpace): String;
begin
  Result := '''N''';
end;

// pole, do ktereho se uklada doplnkova informace k seriovemu cislu (objekt StoreBatch)
function putQueueDocDetailStopPicking_AuxInfoForSerNumField(AOS: TNxCustomObjectSpace): String;
begin
  Result := '';
end;

// vyraz pro serazeni polozek dokladu pri jeho nacteni do ctecky
function putQueueDocDetailStartPicking_RowsOrderBy(AOS: TNxCustomObjectSpace; AModule, ADocType, AUser_ID: String): String;
begin
  if ADocType = DOC_LogStoreTransfer then
    Result := PAD_LEFT('SD2.PosIndex', '0', 4)
  else if ADocType = DOC_PartialInvProtocol then
    Result := 'SC.Code' + CONCAT_STR + 'SB.Name' + nxCrLf
  else
    // JOKO BARTON
    Result := 'LSP.Code' + CONCAT_STR + PAD_LEFT('SD2.PosIndex', '0', 4) + CONCAT_STR + PAD_LEFT('coalesce(DRB.PosIndex, 0)', '0', 4) +
              CONCAT_STR + PAD_LEFT('coalesce(LSD2.PosIndex, 0)', '0', 4);
end;

// pole pro zobrazeni sarze (k sarzi lze pridat dalsi informace)
function putQueueDocDetailStartPicking_StoreBatchField(AOS: TNxCustomObjectSpace; AModule, ADocType: String): String;
begin
  Result := 'coalesce(SB.Name, '''')';
end;

// zda je mozne pridavat na doklad nove radky
function putQueueDocDetailStartPicking_CanAddItems(AOS: TNxCustomObjectSpace; AModuleName, ADocType: String): String;
begin
  Result := '''false''';

  // ABRA
  Result := '''true''';
end;

// Umoznuje pro kazdy radek urcit, zda na nem lze zadad vyssi mnozstvi nez je zadane na dokladu - vklada se jako SQL fragment, radek
// dokladu je pod aliasem SD2, artikl pak pod aliasem SC
// Hodnoty, ktere je potreba vratit jsou stejne jako boolean v systemu (tedy A jako True, a N jako False)
function putQueueDocDetailStartPicking_CanEnterBiggerQuantity(AOS: TNxCustomObjectSpace; AModule, ADocType, AUser_ID: String): String;
begin
  Result := '''N''';

  // ABRA
  Result := '''A''';
end;

// Umoznuje zadat pole, ktera uzivatel muze zmenit
// Lze pouzit pouze pokud NEjsou používány šarže a sér. čísla.
// Sklad lze také změnit pouze pokud potvrzuji celý řádek
// Otestovano pouze pro vydej a prevod! Prijem pravdepodovne NEbude fungovat!!
// Dostupne: StoreFrom
function putQueueDocDetailStartPicking_ChangeableFields(AModuleName: String): String;
begin
  Result := '''''';
end;

// funkce volana pred vytvorenim JSON z datasetu. Slouzi pro upravu dat pred odeslanim do ctecky
// POZOR - protoze dataset vznika z SQL dotazu, je velikost textovych poli nastavena dle vysledku a muze se stat, ze zde budete mit omezenou delku retezce!
procedure BeforeJSONCreate(AOS: TNxCustomObjectSpace; AModule, ADocType, AUser_ID: String; ARows: TMemTable);
begin
end;

// funkce volana pred odeslanim odpovedi. Umoznuje zmenit JSON pred odeslanim
procedure BeforeJSONSend(AOS: TNxCustomObjectSpace; AModule, ADocType, AUser_ID: String; AJson: TJSONSuperObject);
begin
end;

// jestli se pri ukoncovani zpracovani podle dokladu bude vytvaret polohovaci doklad na nezpracovane polozky
function putQueueDocDetailStopPicking_CreateLogStoreDocumentForNotPickedRows(AOS: TNxCustomObjectSpace; AModule, ADocType, AUser_ID: String): Boolean;
begin
  Result := True;

  // JOKO
  Result := False;
end;

// Nazev pole v BO radku skladoveho dokladu (typ boolean), do ktereho se pri ukoncovani zpracovani dokladu ulozi informace o tom, jestli byla polozka
// vyhledana nactenim caroveho kodu (a je tedy vetsi pravdepodobnost, ze obsluha skutecne drzela v ruce spravny artikl)
// nebo tuknutim prstem na polozku, coz je mene spolehlive.
// Pokud je navracena prazdna hodnota, tato informace se neulozi nikam (standardni chovani).
function putQueueDocDetailStopPicking_FieldForWasSelectedByBarcodeInfo(AOS: TNxCustomObjectSpace): String;
begin
  Result := '';
end;

// ktere pole zobrazim jako Aux text u hlavicky dokladu a zda ho lze menit
// pole mus byt primo na dokladu (tedy v SQL bude pouzit alias "SD.")
// u volnych prijmu a vydeju se ignoruje parametr ReadOnly
function StoreDocumentAuxTextField(AModule: String; var AReadOnly: boolean): String;
begin
  Result := '';
  AReadOnly := True;
end;

// AG-8210
// Umoznuje zobrazit volitelny text k radku/artiklu.
// Volano ze dvou mist (ACalledFrom):
//   getStoreCardInfoSql - Volano z informaci o artiklu, volnych scenaru a v nekterych pripadech pri dohledavani radku v
//                          ve scenarich dle dokladu - tam se ale na tento sloupec nebere zretel
//   getRowsSql          -  Volano pri otevreni dokladu (scenare podle dokladu)
// Dale je pak potreba nastavit, kde se ma zobrazit (zobrazi se pokud do promenne nastavis True):
//   ORowList       - Seznam radku
//   ORowDetail     - Obrazovka radku
//   OStoreCardInfo - Obrazovka Informace ze skladu
function StoreCardAuxText(AOS: TNxCustomObjectSpace; AModule, ADocType, AUser_ID, ACalledFrom: String;
  var ORowList, ORowDetail, OStoreCardInfo: Boolean): String;
begin
  Result := QuotedStr('');
end;

// Celkova hodnota a nadpis vlastni hodnoty v obrazovce Informace o skladu
function get_StoreCardInfo_SummaryValue(AOS: TNxCustomObjectSpace; var ATitle: string): String;
begin
  ATitle := QuotedStr('V příjmu/Ve výdeji');
  // JOKO puvoden Result := '(select sum(SSC.BookedQuantity) / SU.UnitRate from StoreSubCards SSC where SSC.StoreCard_ID = ' + QuotedStr(AStoreCard_ID) + ')';
  Result := '(select cast((sum(SSC.acceptedquantity)/ SU.UnitRate) as NUMERIC(15,2)) || ' + QuotedStr('/') +
    ' || cast((sum(SSC.BookedQuantity)/ SU.UnitRate) as NUMERIC(15,2)) from StoreSubCards SSC where SSC.StoreCard_ID = SC.ID)';
end;

// Hodnota pro jednotlive sklady v obrazovce Informace o skladu
// Doplnuje se do puvodniho dotazu a lze tedy pouzivat napr SSC.StoreCard_ID nebo SSC.Store_ID
function get_StoreCardInfo_ByStoreValue(): String;
var
  mSql: String;
begin
  // JOKO Result := 'SSC.BookedQuantity / SU.UnitRate';
  Result := '(cast ((SSC.acceptedquantity / SU.unitrate) as NUMERIC(15,2)) || ' + QuotedStr('/') + ' || cast((SSC.BookedQuantity / SU.unitrate)as NUMERIC(15,2)))'
end;

// omezeni SQL dotazu vracejiciho dispozici na jednotlivych skladech
// SQL aliasy (Tabulka = Alias) -> Stores = S, StoreSubCards = SSC
function get_StoreCardInfo_ExtendedInfo_Where(AOS: TNxCustomObjectSpace; AModule, ADocType, AUser_ID: String): String;
begin
  Result := '';
end;

// Vola se po zjisteni dostupneho mnozstvi. Lze zde do fieldu Available vlozit vlastni dostupne mnozstvi, ktere se ve ctecce
// porovna se zadanym mnozstvim. Porovnani probiha v jednicove jednotce (tedy v hodnote, ktere je ulozenav poli Quantity
// v tabulkach StoreSubCards, LogStoreContents.
// AEnteredQuantityDifference indikuje rozdil mezi mnozstvim na radku a uzivatelem zadanym mnozstvim
// -1  - Zadane mnozstvi je mensi nez mnozstvi na radku
//  0  - Zadane mnozstvi je stejne jako mnozstvi na radku
//  1  - Zadane mnozstvi je vetsi nez mnozstvi na radku
procedure get_AvailableQuantityHook(AOS: TNxCustomObjectSpace; AModule, ADocType, AUser_ID, AStore_ID, AStorePosition_ID, AStorePositionTo_ID, AStoreCard_ID,
  AStoreBatch_ID, AStoreDocument2_ID: String; var ADS: TMemTable; AEnteredQuantityDifference: Integer; AEnteredQuantity: Double);
begin
end;

// Zda se ptat na vytvoreni dokladu pro nepotvrzene mnozstvi
function askForNewDocumentCreation(AModule: String): boolean;
begin
  Result := False;
end;

// Zda vytvorit doklad na nezpracovane polozky v pripade, ze se ctecka nema ptat
function createNewDocument(AModule: String): boolean;
begin
  if (AModule = 'STD_RefundedBillOfDeliveryQueue') and useBillOfDeliveryForRefunding then
    Result := False
  else
    Result := True;
end;

// seznam skladovych dokladu - hodnota pro zobrazeni v poli "Description"
function listDocQueue_Field_Description(AOS: TNxCustomObjectSpace; AModule, ADocType, AUser_ID: String): String;
begin
  if ADocType = DOC_JOBORDER then
    Result := 'SD.CodeID'
  else
    Result := 'SD.Description';
end;

// seznam skladovych dokladu - hodnota pro zobrazeni v poli "FirmName"
function listDocQueue_Field_FirmName(AOS: TNxCustomObjectSpace; AModule, ADocType, AUser_ID: String): String;
begin
  Result := 'F.Name';
end;

// pridani vlastniho JOINu k hlavicce odesilane do ctecky
function putQueueDocDetailStartPicking_HeaderJoin(AOS: TnxCustomObjectSpace; AModule, ADocType, AUser_ID: String): String;
begin
  Result := '';
end;

// pridani vlastniho GROUP BY k hlavicce odesilane do ctecky
function putQueueDocDetailStartPicking_HeaderGroupBy(AOS: TnxCustomObjectSpace; AModule, AUser_ID: String): String;
begin
  Result := '';
end;

// SQL sloupce, ktere se pridaji k radkum (pouziti pro specialy) - na konci musi byt carka
function putQueueDocDetailStartPicking_rowsAuxFields(AOS: TnxCustomObjectSpace; AModule, ADocType, AUser_ID: String): String;
begin
  Result := '';
end;

// pridani vlastniho JOINu k radkum odesilanym do ctecky
function putQueueDocDetailStartPicking_Join(AOS: TnxCustomObjectSpace; AModule, AUser_ID: String): String;
begin
  Result := '';
end;

// pole urcujici kategorii artiklu (1 - Ser. cisla, 2 - Sarze)
function putQueueDocDetailStartPicking_StoreCardCategory(AOS: TNxCustomObjectSpace; AModule, ADocType, AUser_ID: String): String;
begin
  Result := 'SC.Category';
end;

//
function get_StoreBatchInfo_customSql(ASql, AStoreCard_ID, AStoreBatch_ID: String;): String;
begin
  Result := ASql;
end;

// Hacek volany pred ulozenim dokladu (pred vytvarenim PRP, polohovaku a noveho oddeleneho dokladu se zbytkem polozek)
// ASDType je typ ukladaneho dokladu: 0 - puvodni doklad, 1 - oddeleny doklad na nezpracovane radky nebo nova prijemka z OV
// AJson obsahuje cely vstupni JSON (doklad vcetne radku)
// ARows obsahuje radky ze ctecky
procedure beforeSaveHook(AOS: TNxCustomObjectSpace; AModule, ADocType, AUser_ID: String; ASD: TNxCustomBusinessObject; ASDType: Integer; AJson: TJSONSuperObject;
  ARows: TMemTable);
begin
end;

// Hacek volany pred ulozenim nove sarze
procedure putNewStoreBatch_beforeSaveHook(AOS: TNxCustomObjectSpace; AModule, ADocType, AUser_ID: String; ABatch: TNxCustomBusinessObject);
begin
end;

// Hacek volany ihned po ulozeni dokladu
// ASDType je typ ukladaneho dokladu: 0 - puvodni doklad, 1 - oddleny doklad na nezpracovane radky, PRV pri prevodu apod
procedure afterSaveHook(AOS: TNxCustomObjectSpace; AModule, ADocType, AUser_ID: String; ADocument: TNxCustomBusinessObject; ASDType: Integer;
  AJson: TJSONSuperObject; ARows: TMemTable);
begin
end;

// umoznuje rucne zmenit doklad pred zmenou stavu do Vyskladneno. V pripade, ze vrati True, je stav zmenen, v pripade False stav jiz zmenen neni.
// ASDType je typ dokladu u ktereho se meni stav: 0 - puvodni doklad, 1 - oddeleny doklad na nezpracovane radky
function putQueueDocDetailStopPicking_changeSDStatus(AOS: TNxCustomObjectSpace; AModule, ADocType, AUser_ID, ASDNew_ID: String;
  ASDType: Integer; ASD, ASDNew: TNxCustomBusinessObject): Boolean;
begin
  Result := True;
end;

// vlastni ulozeni seriovych cisel
function putQueueDocDetailStopPicking_FillSerialNumbers(AOS: TNxCustomObjectSpace; mModule: String;
  AJsonSerNums: TJSONSuperObjectArray; ARow: TNxCustomBusinessObject; ADocRowBatches: TNxCustomBusinessMonikerCollection): Boolean;
var
  i: Integer;
begin
  Result := False;
end;

// zda je mozne editovat jiz potvrzenou polozku
function putQueueDocDetailStartPicking_isEditingProcessedItemAllowed(AOS: TNxCustomObjectSpace; AModule, ADocType, AUser_ID: String): Boolean;
begin
  Result := False;

  // ABRA
  Result := True;
end;

// zda při příjmu nejdříve zkusit dohledat již existující sér. číslo před vytvořením nového
function isUsingExistingSerNumberAllowed: Boolean;
begin
  Result := True;
end;

// SQL sloupce, ktere se pridaji k hlavicce (pouziti pro specialy) - na konci musi byt carka
function HeaderAuxFields(AOS: TNxCustomObjectSpace; AModule, ADocType, AUser_ID: String): String;
begin
  Result := '';
end;

// SQL sloupec, ktery se doplni do promene AuxText2
// Standardne se nikde nezobrazuje, urceno pro specialy
function rowAuxText2(AOS: TNxCustomObjectSpace; AModule, ADocType, AUser_ID: String): String;
begin
  Result := '''''';
end;

// vlastni dohledavani artiklu v pripade, ze cStoreCardInfoSearchIn obsahuje X
// vracena hodnota by mela byt ID nalezeneho artiklu (pripadne muze vratit jejich seznam a aplikace pak vybere prvni, nebo da uzivateli na vyber)
// AWithStoreUnit urcuje, zda byla karta dohledana pres EAN nektere z jednotek. Pokud bude True
// bude informace o teto jednotce predana do aplikace a ta jednotku na radku zmeni (AG-2528)
function StoreCard_CustomSearch(ABarcode: String; var AWithStoreUnit: Boolean): String;
begin
  Result := '';

  
 // JOKO
  Result := 'select ' + FIRST_TOP(1) + ' SC.ID ' +
            'from StoreCards SC ' +
            'join suppliers SUPP on Supp.storecard_id = SC.ID ' +
            'where SC.Hidden = ''N'' and SUPP.externalnumber = ' + QuotedStr(ABarcode);

  // priklad - hledani v X poli
  {Result:=
    'select ' + FIRST_TOP(1) + ' SC.ID ' +
    'from StoreCards SC ' +
    'where SC.Hidden = ''N'' and SC.X_EAN = ' + QuotedStr(ABarcode);}
end;

// Zda se ma ve scenari Prevod vydej ma vytvorit PRP. Pokud PRP jiz existuje, tak se aktualizuje
// podle upravene PRV
// Vklada se jako SQL fragment
function putQueueDocDetailStartPicking_createTransferIn(AOS: TNxCustomObjectSpace; AModule, ADocType, AUser_ID: String): String;
begin
  Result := QuotedStr('A');
end;

// Zda se ma zobrazit pole pro zadavani carovych kodu
function putQueueDocDetailStartPicking_showBarecodeField(AModule: String): boolean;
begin
  Result := True;
end;

// Vraci moduly, ve kterych se pouzije specialni parsovani, oddelene strednikem.
function specialBarcodeHandling(AUser_ID: String): String;
begin
  Result := '';
end;

// specialni parsovani EANu. K vracenemu ID karty a sarze se automaticky dohledaji vsechna potrebna pole
// U scenaru s doklady, se radek dohledava podle ID artiklu. Pokud ID artiklu zadane neni, radek se dohledava podle sarze / ser. cisla. Aby bylo mozne dohledat radek
// dle ser. cisla, musi byt na radku pouze jedno ser. cislo a stejne tak musi byt pouze jedno ser. cislo vraceno z tohoto skriptu.
// AStoreBatchAux urcuje Specifikaci u sarze a Aux informaci u ser. cisla
// Jednotka se pouzije pouze v pripade scenaru bez dokladu
// Parametry na druhem radku (ADocument_ID, ...) obsahuji hodnoty vyplnene ve ctecce.
// Parametry na tretim radku lze vyplnit jako nove hodnoty do ctecky. POZOR - musis si sam ohlidat konzistenci -> napr. nemel by jsi vracet sklad pro frontove doklady
// ODialogText pokud je vyplneny, tak je uzivateli ve ctecce zobrazen s textem v tomto argumentu
// ODialogType urcuje typ zobrazeneho dialogu - 0 - Upozorneni s tlacitkem OK, 1 - Ano/ne, kdy vyber ne obrazovku radku zavre a vrati skladknika do detailu dokladu
// AStoreBatchDataset, AStorePosition muze vratit kompletni objekt, aby se jiz nemusel dohledavat (napr. u prijmu, kdyz sarze jeste neexistuje.
//   ID ma ale vzdy prednost)
// ASerialNumbers slouží k vrácení sériových čísel (Fieldy: SerNum_ID, SerNumName, AuxText). Pokud se bude vytvářet nové sér. číslo (SerNum_ID bude prázdne),
//   tak se informace v AuxText ulozi do pole urceneho funkci putQueueDocDetailStopPicking_AuxInfoForSerNumField.
// OJson se prida k informci o artiklu, vyuziva se pouze u specialu
// funkce se pouziva take ve scenari ABRA_OneCodeQueue - v tomto pripade se ID dokladu vraci v promene OStoreCard_ID
// OStoreCardNext_ID, pokud je vyplneno, pokusi se ctecka ulozit aktualni radek a najit/vytvorit radek s timto artiklem (AG-10655)
procedure parseBarcodeForRowSpecial(AOS: TNxCustomObjectSpace; AModule, ADocType, AUser_ID, ABarcode: String;
  ADocument_ID, ARow_ID, AFirm_ID, AStoreCard_ID, AStoreFrom_ID, AStoreFromPosition_ID, AStoreTo_ID, AStoreToPosition_ID, AStoreBatch_ID, AUnitCode: String;
  AOriginalUnitQuantity, AActualUnitQuantity: Double;
  var OStoreCard_ID, OStoreBatch_ID, OStoreFrom_ID, OStorePositionFrom_ID, OStorePositionTo_ID, OUnitCode, OStoreBatchAux, ONextStoreCardBarcode: String;
  var OStoreBatchExpirationDate, OUnitQuantity: Double;
  var ODialogText: String; var ODialogType: Integer;
  var AStoreBatchDataset, AStorePositionFromDataset, ASerialNumbers: TMemTable; var OJson: TJSONSuperObject);
begin
end;

// Predvyplneni pozice na radku - ID skladu (10znaku) + ID pozice (10 znaku) + nazev pozice
function putQueueDocDetailStartPicking_defaultPosition(): String;
begin
  Result := '';
end;

// jestli pri ziskavani dostupneho mnozstvi na pozici odecitat rezervovane mnozstvi
function checkReservedQuantityInPositions: Boolean;
begin
  Result := True;
end;

// zapnuti logovano do souboru - nelze pouzit pro obecne logovani
function enableLogging(AOS: TNxCustomObjectSpace; AUser_ID: String): Boolean;
begin
  Result := False;
end;

function customGetHeaderSql(AOS: TNxCustomObjectSpace; AModule, ADoc_ID, ADocType, AAuxField: String; AAuxReadOnly: Boolean; AChangeableFields: String): String;
begin
  Result := '';
end;

function customGetRowsSql(AOS: TNxCustomObjectSpace; AModule, AUser_Id, ADocType, AOriginalSql: String; var AWhere: String): String;
begin
  Result := '';
end;

// Hacek volany po vytvoreni rozpadleho dokladu a nastaveni poli v jeho hlavicce
// AJson obsahuje kompletni JSON ze ctecky, ARows obsahuje radky z tohoto JSONu prevedene do datasetu
procedure putQueueDocDetailStopPicking_afterSDNewCreateHook(AOS: TNxCustomObjectSpace; AModule: String; ASD, ASDNew: TNxCustomBusinessObject;
  AJson: TJSONSuperObject; ARows: TMemTable);
begin
end;

function canAddNewBatch(AOS: TNxCustomObjectSpace; AModule: String): String;
begin
  Result := '''false''';
end;

// v kterych scenarich se ma zobrazit nabizet rucni vyber ze ser. cisel
function showSerNumberSelection(AOS: TNxCustomObjectSpace; AModule, ADocType, AUser_ID: String): Boolean;
begin
  if ADocType in [DOC_ReceiptCard, DOC_LogStoreInput, DOC_RefundedBillOfDelivery, DOC_IncomingTransfer] then
    Result := False
  else
    Result := True;
end;

// pri ulozeni radku (po kontrole dostupneho mnozstvi) zobrazi dialog s textem, ktery je vracen touto funkci
// pokud je vraceny text prazdny, dialog se nezobrazi
function DialogTextOnRowSave(AOS: TNxCustomObjectSpace; AModule, AUser_ID, AStoreDocument2_ID, AStoreCard_ID,
  AStoreBatch_ID, AStore_ID, AStorePosition_ID: String; AEnteredQuantity: Double): String;
begin
  Result := '';
end;

// umoznuje ve scenarich po stisku Ulozit zobrazit dialog - dialog se zobrazi, pokud je vracen neprazdny retezec
// nebo pokud je v datasetu OValues alespon jeden radek
// Result obsahuje text zobrazeneho dialogu
// OValues obsahuje jednoliva zadavatelna pole dialogu - dataset ma nasledujici fieldy:
//   type         - typ pole: number,text,roll
//   label        - popisek pole
//   field        - pole na BO, do ktereho se ulozi zadana hodnota
//   intValue     - hodnota pole v pripade typu number
//   stringValue  - hodnota pole v pripade typu text, nebo roll - v pripade typu roll je zde ulozen kod vybraneho zaznamu
//   rollValueId  - pouzivano pouze v pripade typu roll - je zde ulozeno ID vybraneho zaznamu
//   rollName     - pouzivano pouze v pripade typu roll - ciselnik, ktery se ma otevrit v pripade klepnuti (hodnota se preda do funkce REST_SkladTerm_Special.U_DialogRolls)
//
// vzdy musi byt vyplnena vsechna pole (tedy v pripade pouziti typu number musi byt stejne vyplnen rollName atd. - toto plati minimalne pro FLORES, ktery
// nevyplnenim polim pri prevodu do JSON dava nesmyslne hodnoty
//
// hodnoty pro ciselniky se zadavaji v REST_SkladTerm_Special.U_DialogRolls, je zde i ukazka
function DialogOnDocSave(AOS: TNxCustomObjectSpace; ADocType, AModule, AUser_ID, ADoc_ID: String; var OValues: TMemTable): String;
begin
  Result := '';

  // priklad pouziti pro vsechna pole
  {OValues.Edit;

  OValues.Append;
  OValues.FieldByName('type').AsString := 'number';
  OValues.FieldByName('label').AsString := 'Číslo:';
  OValues.FieldByName('field').AsString := 'X_Integer';
  OValues.FieldByName('intValue').AsInteger := 5;

  OValues.FieldByName('stringValue').AsString := '';
  OValues.FieldByName('rollValueId').AsString := '';
  OValues.FieldByName('rollName').AsString := '';

  OValues.Append;
  OValues.FieldByName('type').AsString := 'text';
  OValues.FieldByName('label').AsString := 'Text:';
  OValues.FieldByName('field').AsString := 'Description';
  OValues.FieldByName('stringValue').AsString := 'string2';

  OValues.FieldByName('intValue').AsInteger := 0;
  OValues.FieldByName('rollValueId').AsString := '';
  OValues.FieldByName('rollName').AsString := '';

  OValues.Append;
  OValues.FieldByName('type').AsString := 'roll';
  OValues.FieldByName('label').AsString := 'Způs. dopravy:';
  OValues.FieldByName('field').AsString := 'TransportationType_ID';
  OValues.FieldByName('stringValue').AsString := 'O1';
  OValues.FieldByName('rollValueId').AsString := '00000O1000';
  OValues.FieldByName('rollName').AsString := 'Transport';

  OValues.FieldByName('intValue').AsInteger := 0;

  // vsechna dostupna pole
  OValues.FieldByName('type').AsString := '';
  OValues.FieldByName('label').AsString := '';
  OValues.FieldByName('field').AsString := '';
  OValues.FieldByName('intValue').AsInteger := 0;
  OValues.FieldByName('stringValue').AsString := '';
  OValues.FieldByName('rollValueId').AsString := '';
  OValues.FieldByName('rollName').AsString := '';
  OValues.Post;}
end;

// umoznuje vypnout editaci mnozstvi radku
function DisableQuantityEdit(AOS: TNxCustomObjectSpace; AModule: String): String;
begin
  Result := '''false''';
end;

// umozni pri ukladani dokladu ignorovat nektere radky. Pokud je vraceno true, je radek pri ukladani ignorovan (nic se na nem nemeni)
function putQueueDocDetailStopPicking_IgnoreRow(AOS: TNxCustomObjectSpace; AModule: String; ARow: TNxCustomBusinessObject): Boolean;
begin
  Result := False;
end;

// vraci JSON s definicemi vlastnich poli, ktere se zobrazi pro zadani v radku
// podporovane vlastnosti jsou:
// - label    - Zobrazeny popisek (povinne)
// - field    - Pole, do ktereho hodnota ulozi (podporovany pole primo na radku dokladu)
// - type     - typ zadavane hodnoty, aktualne podporovano
//              - text - zadavani textu
//              - number - zadavani celého čísla
// - modules  - v kterem modulu se pole pro zadavani zobrazi, pokud je prazdne, tak ve vsech modulech
//            - pokud obsahuje vice modulu, odeluje se ;
// - minValue - minimalni hodnota. U textu delka retezce.
// - maxValue - maximalni hodnota. U textu delka retezce.
function customFields(AOS: TNxCustomObjectSpace; AUser_ID: String): String;
begin
  Result := '';
  // priklad v poznamce skriptu
end;

// funkce volana pri nacteni dokladu nebo zmene artiklu na radku. Urcuje, ktera pole se maji zobrazit
// zadava se seznam fieldu (hodnota field) oddelenych strednikem. Pokud je prazdne, jsou povolene vsechny
// Jde o SQL fragment, takze tabulka artiklu je dostupna pod aliasem SC.
function enabledCustomFields(AOS: TNxCustomObjectSpace; AUser_ID, AModule: String): String;
begin
  Result := QuotedStr('');

  // priklad
  {if AStoreCard_ID = '' then
    Result := 'case when SC.Code = ''39'' then ''X_Note=Rychle;X_Cislo=5'' when SC.Code = '''' then ''X_Note;X_Cislo'' else '''' end';}
end;

// vola se pred zpracovanim dalsiho radku, slouzi napriklad vyplneni vlastnich poli
// ARow - aktualne pridavany radek
// ADataset - Dataset s daty ze ctecky. Aktualni pozice je na aktualne pridavanem radku
procedure putWithoutDocStopPicking_beforeRowSave(AModule: String; AOS: TNxCustomObjectSpace; ARow: TNxCustomBusinessObject; ARowsDataset: TMemTable;
  AJson: TJSONSuperObject);
begin
end;

// umoznuje vypnout virtualni klavesnici v poli pro zadani mnozstvi. Klavesnice bude vypnuta ve scenarich, ktere se touto funkci vrati
function disableSoftInputKeyboard(AOS: TNxCustomObjectSpace; AUser_ID: String): String;
begin
  Result := '';
end;

function putQueueDocDetailStartPicking_openSerNumberScreenAutomatically(AOS: TNxCustomObjectSpace; AModule, AUser_ID: String): Boolean;
begin
  Result := False;
end;

// jake mnozstvi se prevyplni novemu radku. Predpoklada se hodnota 0 nebo 1.
// aktualne funguje pouze pro frontove doklady a inventury
function newRowDefaultValue(AOS: TNxCustomObjectSpace; AModule, AUser_ID: String): Integer;
begin
  Result := 0;
end;

// umoznuje nastavit vlastni barvu radku v seznamu dokladu
// uvadi se ve formatu "RRGGBB,RRGGBB" - prvni barva urcuje barvu dokladu ve fronte, druha urcuje barvu rozpracovaneho dokladu
// lze uvest i pouze prvni barvu - priklady: QuotedStr('FF0000,0000FF'), QuotedStr('FF0000')
// vklada se jako SQL fragment, takze se lze odkazat na doklad (alias SD)
function listDocQueue_customRowColor(AOS: TNxCustomObjectSpace; AModule, ADocType, AUser_ID: String): String;
begin
  Result := QuotedStr('');
end;

// umoznuje nastavit vlastni barvu radku. Urcuje se barva pro nezpracovany a zpracovany radek (oddelene carkou)
// vklada se do SQL dotazu vracejiciho radky
function putQueueDocDetailStartPicking_customRowColor(AOS: TNxCustomObjectSpace; AModule, AUser_ID: String): String;
begin
  Result := QuotedStr('');
end;

// Urci, ktera pole se navic oproti tem standardnim prenesou z JSONu do datasetu radku. Musi zacinat carkou.
function RowsDatasetFields(AOS: TNxCustomObjectSpace; AModule, ADocType, AUser_ID: String): String;
begin
  Result := '';
end;

// Vola se po nastaveni sarze zpracovavaneho radku. NEvola se, pokud jde o ser. cisla, nebo pokud se sarze vytvari generatorem
procedure afterDocRowBatchFill(AOS: TNxCustomObjectSpace; AModule: String; ADocRowBatch, ARow, ASD: TNxCustomBusinessObject;
  ARows: TMemTable);
begin
end;

// vola se po pridani noveho radku ve frontovych scenarich. Vola se na konci pridani radku (jsou vyplnene vsechny udaje, ktere standard vyplnuje) (ST-728)
procedure putQueueDocDetailStopPicking_afterNewRowFill(AOS: TNxCustomObjectSpace;  AModule, ADocType, AUser_ID: String; ARow, ASD: TNxCustomBusinessObject;
  ARows: TNxCustomBusinessMonikerCollection; ARowsDataset: TMemTable);
begin
end;

// zda se ma jako fronta pro Vraceni vydejek maji pouzivat Vydejky (True) nebo Vratky vydejek(False)
// pokud je nastaveno na True, melo by byt take nastaveno, ze nevznika kopie dokladu (funkce createNewDocument)
function useBillOfDeliveryForRefunding: Boolean;
begin
  Result := False;
end;

// volitelne hodnota predana do ctecky pri prihlaseni (pouziva se pouze ve specialech)
function LoginObjectAuxField(AOS: TNxCustomObjectSpace; AUser_ID: String): String;
begin
  Result := '';
end;

// vlastni cesta k obrazkum. Napriklad, pokud webove sluzby bezi jinde nez webove sluzby a je tedy potreba cestu zmenit
function get_StoreCardPicture_customPath(AOS: TNxCustomObjectSpace; AModule, AFilePath: String;): String;
begin
  Result := AFilePath;
end;

// v pripade, ze je ve ctecce zaskrtnuto prihlasovani kodem se vola tato funkce. Vysledkem je uspesne prihlaseni (nalezeni uzivatele)
// a jeho ID
function CustomCodeLogin(AOS: TNxCustomObjectSpace; ALoginCode: String): String;
begin
  Result := '';
end;

// Seznam scenaru, ve kterych se namisto pole pro zadani kodu zobrazi tlacitko, ktere spusti fotoaparat pro nacitani kodu
// Scenare musi byt oddeleny strednikem (napr STD_Prijem;STD_Neco)
function ShowBarcodeButton(AUser_ID: String): String;
begin
  Result := '';
end;

// Mnozstvi pouzite pro pricitani v scenarich rychleho nacitani
// vyplni se jako sloupec do SQL dotazu. Lze použít sql alias SC pro tabulku StoreCards
function DefaultUnitQuantity(AOS: TNxCustomObjectSpace; AModule: String): String;
begin
  Result := '''0''';
end;

function putQueueDocDetailStopPicking_NewRowsToSeperateDoc(AOS: TNxCustomObjectSpace; AModule, ADocType: String): Boolean;
begin
  // standard
  Result := False;
end;

// zda se ma ve volnych dokladech zadavat osoba. AField urci, do ktereho pole se ID osoby ulozi
function EnterPerson(AOS: TNxCustomObjectSpace; AModule, ADocType, AUser_ID: String; var AField: String): Boolean;
begin
  Result := False;
  AField := '';
end;

// zda se ma ve volnych dokladech zadavat rada
function EnterDocQueue(AOS: TNxCustomObjectSpace; AModule, ADocType, AUser_ID: String): Boolean;
begin
  Result := False;
end;

// zda se ma ve volnych dokladech zadavat provozovna
function EnterFirmOffice(AOS: TNxCustomObjectSpace; AModule, ADocType, AUser_ID: String): Boolean;
begin
  Result := False;
end;

// zda se ma ve volnych dokladech zadavat zakazka
function EnterBusOrder(AOS: TNxCustomObjectSpace; AModule, ADocType, AUser_ID: String): Boolean;
begin
  Result := False;
end;

// zda se ma ve volnych dokladech zadavat stredisko
function EnterDivision(AOS: TNxCustomObjectSpace; AModule, ADocType, AUser_ID: String): Boolean;
begin
  Result := False;
end;

// zda se ma ve volnych dokladech zadavat obchodni pripad
// OMandatory urcuje, jestli je povinne pole zadat - vychozi hodnota je False
function EnterBusTransaction(AOS: TNxCustomObjectSpace; AModule, ADocType, AUser_ID: String; var OMandatory: Boolean): Boolean;
begin
  Result := False;
end;

// zda se ma ve volnych dokladech zadavat projekt
// OMandatory urcuje, jestli je povinne pole zadat - vychozi hodnota je False
function EnterBusProject(AOS: TNxCustomObjectSpace; AModule, ADocType, AUser_ID: String; var OMandatory: Boolean): Boolean;
begin
  Result := False;
end;

// zda se ma v dokladech zadavat zpusob dopravy (volne i frontove scenare)
function EnterTransportationType(AOS: TNxCustomObjectSpace; AModule, ADocType, AUser_ID: String): Boolean;
begin
  Result := False;
end;

// pole oddeleneho dokladu, do ktereho se ulozi ID dokladu puvodniho
function putQueueDocDetailStopPicking_OriginStoreDocumentField(AOS: TnxCustomObjectSpace; AModule, ADocType, AUser_ID: String): String;
begin
  Result := '';
end;

// zda je mozne zmenit jednotku na radku (pouze volne doklady a volna inventura)
function CanEditRowUnit(AOS: TNxCustomObjectSpace; AModule, ADocType, AUser_ID: String): Boolean;
begin
  Result := False;

  // ABRA
  Result := True;
end;

// zda je mozne zadavat neexistujici cisla - tato cisla se pak pri ulozeni dokladu vytvori
function CanCreateNewSerialNumbers(AOS: TNxCustomObjectSpace; AModule, ADocType, AUser_ID, ADocument_ID: String): Boolean;
begin
  Result := False;
  if ADocType in [DOC_ReceiptCard, DOC_LogStoreInput, DOC_MainInvProtocol, DOC_PartialInvProtocol] then
    Result := True;
end;

// zda je povinne zadavani ser. cisel a sarzi
// 0 - Povinne zadavat, 1 - Nepovinne, ale musi byt nastavena struktura sarzi, 2 - Nepovinne, doklad bude bez sarze
function IsStoreBatchEnteringRequired(AOS: TNxCustomObjectSpace; AModule, ADocType, AUser_ID: String): Integer;
begin
  Result := 0;
  if ADocType in [DOC_ReceiptCard, DOC_IssuedOrder] then
    Result := 1;
end;

// zda se kontroluje dostupne mnozstvi pri ukladani radku
function IsAvailableQuantityCheckActive(AOS: TNxCustomObjectSpace; AModule, ADocType, AUser_ID: String): Boolean;
begin
  Result := True;

  // ABRA
  Result := True;
//joko
  //if AModule = 'STD_TransferWithoutDoc' then
  //Result := False;
end;

// vlastni vytvoreni polohovaciho dokladu, Pokud je vraceno True, je reseno standardne, pokud False, neudela standard nic
// u prevodu se pouzije pouze pro PRV
// ARows - dataset radku ze ctecky, ADataset - Dataset podle ktereho se vytvari standardne polohovaci doklad (funkce REST_Create_LogStoreDocument)
function CreateLogStoreDocument(AOS: TNxCustomObjectSpace; AModule, ADocType, AUser_ID, ALSD_ID: String;
  ADocument: TNxCustomBusinessObject; AJson: TJSONSuperObject; ARows, ADataset: TMemTable): Boolean;
begin
  Result := True;
end;

// zda se ve cteckach maji pouzivat hlavni jednotky
// (tzn. pokud ma radek dokladu jinou nez hlavni jednotku, zobrazi se ve ctece mnozstvi prepoctene do hlavni jednotky)
// pri pouziti musi byt doklady kompletně potvrzovány! Nemusí fungovat ve všech scénářích, vždy nejdříve otestovat!
function useMainUnits(AOS: TnxCustomObjectSpace; AModule, ADocType, AUser_ID: String): Boolean;
begin
  Result := False;
end;

// umoznuje zobrazit v obrazovce radku tlacitko Tisk
// Funkce dle navratove hodnoty:
// 0 - tlacitko se nezobrazuje
// 1 - tlacitko se zobrazi - po stisku se zobrazi dialog, kde je predvyplneno mnozstvi radku a po potvrzeni odesle informace o radku
//     do funkce PrintRowFunction, kde lze provest tisk
// 2 - tlacitko se zobrazi - po stisku se v systemu dohledaji definice stitku ulozene na artiklu (X_LabelDefinition) a uzivateli se zobrazi
//     jejich seznam. Po vybrani se definice tiskne na primo na sparovanou BT tiskarnu
function showPrintRowButton(AOS: TnxCustomObjectSpace; AModule, ADocType, AUser_ID: String): Integer;
begin
  Result := 0;

  // ABRA
  if AModule = 'STD_ReceiptCardQueue' then
    Result := 1;
end;

// funkce volana tlacitkem TISK z obrazovky radku.
// ARow obsahuje JSON s radkem, format poli je shodny s SQL dotazem v REST_SkladTerm.U_SQLQueries.getRowsSql
procedure PrintRowFunction(AOS: TnxCustomObjectSpace; AModule, ADocType, AUser_ID: String; ARow: TJSONSuperObject);
var
  mContext: TNxContext;
begin
  if AModule = 'STD_ReceiptCardQueue' then
  begin
    mContext := NxCreateContext(AOS);
    try
      PrintReportToPrinterByIDToQueue(mContext, ARow.S('StoreCard_ID'), '', Report_ID_Stitky, '', PrinterName, AUser_ID, Trunc(ARow.D['UnitQuantity']));
    finally
      mContext.Free;
    end;
  end;
end;

// zda se ma zadavat datum expirace pro sarzi. Vyplnuje se do SQL dotazu, kde je pod aliasem SC dostupna tabulka artiklu
// pokud vrati true, tak je v radku zobrazeno pole pro zadani data expirace a je nutne ho vyplnit.
// Funguje pouze u scénářů dle dokladu
// OEnterType urcuje typ zadavani data expirace:
//   0 - Kalendar (výchozí)
//   1 - Textove pole
//   2 - Posuvnik pro kazdou cast data
// OField urcuje pole, do ktereho se datum vyplni - standardne se vyplnuje do ExpirationDate$DATE
//   pole se muze zmenit, i kdyz funkce vraci False
function EnterStoreBatchExpirationDate(AOS: TNxCustomObjectSpace; AModule, ADocType, AUser_ID: String; var OEnterType: Integer; var OField: String): String;
begin
  Result := '''False''';
  OEnterType := 0;
end;

// formatovani data expirace. V pripade, ze funkce EnterStoreBatchExpirationDate ma nastaveny typ zadavani jako textove pole,
// je kazde zadani zaslano do teto funkce, ktera musi z textu ziskat a vratit datum
function FormatExpirationDate(AOS: TNxCustomObjectSpace; AModule, ADocType, AUser_ID, AExpirationDate: String): TDateTime;
begin
  Result := nil;
end;

// vlastni nahrazovani promennych v definici stitku. Funkce se pouzije v pripade, ze funkce showPrintRowButton vraci 2 - tj. tiskne se primo na BT tiskarnu
// APrintLabel je definice stitku, kde jsou jiz nahrazene promenne hodnotami z artiklu
// ARowJson obsahuje JSON s aktualnim radkem ve ctecce (pole radku lze vycist v REST_SkladTerm.U_SQLQueries.getRowsSql)
function PrintLabelCustomReplace(AOS: TNxCustomObjectSpace; AModule, ADocType, AUser_ID, AStoreCard_ID, APrintLabel_ID: String;
  APrintLabel: String; ARowJson: TJSONSuperObject): String;
begin
  Result := APrintLabel;
end;

// umoznuje k jednotlivym tlacitkum v hlavnim menu pridat informaci o poctu dokladu ve fronte
// vstupni dataset je prazdny a lze do nej vyplnit zaznamy s fieldy:
//   Module - nazev modulu (napr. STD_ReceiptCardsQueue)
//   Count  - pocet zaznamu ve fronte - pokud je zaporne, nic se nezobrazi
// vysledny dataset se pote preplni do datasetu obsahujiciho pocty standardnich scenaru - pokud chci prepsat standardni pocet, staci vlozit do datasetu zaznam pro scenar
// priklad vyplneni je v poznamce skriptu
procedure VisibleModulesDocumentCount(AOS: TNxCustomObjectSpace; AUser_ID: String; var AModules: TMemTable);
begin
end;

// zapnuti kontroly dostupnosti na pozici ihned pri jejim nacteni nebo vybrani. V parametrech je dostupny nacteny artikl a pozice
// kontrola vzdy probiha pouze u skladu z u scenaru s typem dokladu DOC_VYD a DOC_PREV (vydejky, prevodky)
function StorePosition_CheckAvailableQuantityImmediately(AOS: TNxCustomObjectSpace; AModule, ADocType, AUser_ID, AStoreCard, AStorePosition: String): Boolean;
begin
  Result := False;
end;

// pokud funkce vraci True, tak se ve scenari Informace ze skladu, pri vyberu pozice, zobrazi v seznamu krome artiklu take rovnou i sarze
function AvailableInStockActivity_Position_ShowBatches(AOS: TNxCustomObjectSpace; AModule, ADocType, AUser_ID: String): Boolean;
begin
  Result := False;

// JOKO - původne Result := False;
  Result := True;
end;

// Urci, zda se bude ve scenarich bez dokladu drzet (prenaset) pozice
// 0 - Nedrzet zadnou pozici
// 1 - Drzet pozici z
// 2 - Drzet pozici na
// 3 - drzet obe pozice
function KeepSelectedPosition(AOS: TNxCustomObjectSpace; AModule, ADocType, AUser_ID: String): Integer;
begin
  Result := 0;
end;

// Umoznuje urcit, ktere hodnoty muze skladnik menit. Ovlivnuje chovani pouze ve scenarich s doklady. Nepodporovano v rychlych scenarich.
// Potvzeni hodnoty musi byt vzdy provedeno nactenim kodu (vybrani rucne nestaci)
// Hodnoty jednotlivych parametru - umyslne jde o STRING, aby bylo mozne vkladat fragmenty SQL - vysledkem ale nakonec musi byt INT!!:
// 0 - Skladnik muze hodnotu zmenit a NEmusi ji potvzovat (standardni chovani)
// 1 - Skladnik muze hodnotu zmenit, ale musi ji potvrdit (nacist kódem)
// 2 - Skladnik NEmuze hodnotu zmenit, ale NEmusi ji potvrzovat - zatím nepodporováno
// 3 - Skladnik NEmuze hodnotu menit a musi ji potvrdit nactenim kodu
// POZOR - artikl nelze menit nikdy, zde lze pouze vynutit jeho potvrzovani (tedy rezim 3)
// V pripade pouziti v kombinaci s funkci specialBarecodeHandling se pri nacitani v radku musi konzultant sam postarat o kontrolu, zda nacteny
// odpovida udaji na radku a pripadne zobrazit chybu
procedure EnteredFieldsBehavior(AOS: TNxCustomObjectSpace; AModule, ADocType, AUser_ID: String; var OStoreCard, OStoreBatch, OStorePosition,
  OStorePositionTo: String);
begin
  // ABRA
  OStorePosition := '1';
  OStoreCard := '1';
end;

// Urcuje, zda je mozne k novym dokladum (scenare bez dokladu) fotit fotky. Ty se pak ulozi jako dokumenty a pripoji se k dokladu.
// Podporovano je nyni pouze ukladani fotek na disk
function CanTakePhotos(AOS: TNxCustomObjectSpace; AModule, ADocType, AUser_ID: String): String;
begin
  Result := '''N''';
end;

// AG-2594
// Umoznuje zmenit filtrovani jednotlivych seznamu v aplikaci (artikly, pozice, ....).
// AParameters obsahuje seznam parametru volaneho SQL dotazu. Parametry obsahujici casti dotazu (dostupine pro vsechny dotazy):
//   select
//   from
//   join
//   where
//   orderby
//
//  Zaroven muze mit kazdy seznam sve vlastni parametry. Napriklad seznam osob muze mit parameter firm_id pro omezeni za firmu.
//  Seznam parametru je dale v seznamu podporovanych seznamu.
//
// AListName je prave volany seznam:
//   - get_ListPersons - seznam osob (firm_id)
//   - get_ListStoreBatches - seznam sarzi (onlyAvailable, store_id, storeCard_id, storePosition_id)
procedure FilterList(AOS: TNxCustomObjectSpace; AModule, ADocType, AUser_ID: String; AListName: String; var AParameters: TStringList);
begin
end;

// Vraci seznam scenaru (oddelene strednikem), ve kterych se ma fokus drzet pouze v poli pro nacitani carovych kodu
function BarcodeFocusOnly(AOS: TNxCustomObjectSpace; AUser_ID: String): String;
begin
  Result := '';
end;

// AG-2877, AG-2879
// Zda se ma zobrazovat poznamka k sarzi. Vyplnuje se do SQL dotazu, kde je pod aliasem SC dostupna tabulka artiklu
// OVisibility urcuje typ zobrazeni (prenasi se k nactenemu radku nebo artiklu) - musi byt String!:
//   0 - Nezobrazovat
//   1 - Zobrazovat bez editace
//   2 - Zobrazit a umoznit editaci
//   3 - Zobrazit, umoznit editaci a vyzadovat vyplneni
// OField je pak pole, ze ktereho se poznamka k sarzi cte (pripadne kam se uklada) (prenasi se ze sarze) - MUSI byt primo na objektu sarze
//   a maximální délka je nyní omezena na 100 znaků
procedure StoreBatchNoteVisibility(AOS: TNxCustomObjectSpace; AModule, ADocType, AUser_ID: String; var OVisibility, OField: String);
begin
end;

// AG-2878
// Umoznuje zobrazit prepocet do dalsich dvou jednotek. Zobrazi se pod zadavanym mnozstvim. Jednotky jsou vybrany
// dle PosIndexu. Vysledek se vklada se SQL dotazu. Funguje pouze ve scenarich dle dokladu
function ShowOtherUnitsUnitRate(AOS: TNxCustomObjectSpace; AModule, ADocType, AUser_ID: String): String;
begin
  Result := '''N''';
end;

// AG-3871
// Zda lze potvrdit nulove mnozství.
function EnableZeroQuantity(AOS: TNxCustomObjectSpace; AModule, ADocType, AUser_ID: String): String;
begin
  Result := QuotedStr('N');
end;

// AG-2534
// Zda se ma oddeleny radek zaradit na konec seznamu (pokud ne, tak se zaradi za prave potvrzeny)
function AddSplittedRowAtTheEnd(AOS: TNxCustomObjectSpace; AModule, ADocType, AUser_ID: String): String;
begin
  Result := QuotedStr('A');
end;

// AG-5145
// Funkce pouzivana pro scenar STD_CustomCall. Pokud funkce vrati text, je tento text zobrazen uzivateli ve ctecce.
function CustomCall(AOS: TNxCustomObjectSpace; AModule, ADocType, AUser_ID, ABody: String): String;
begin
  Result := '';
end;

// AG-7214
// Umoznuje ve volnych scenarich zobrazit množství dostupné na skladě
Function ShowStoreAvailability(AOS: TNxCustomObjectSpace; AModule, ADocType, AUser_ID: String): String;
begin
  Result := QuotedStr('N');
end;

// AG-8209
// Umoznuje zavolat vlastni ukladani dokladu. Vola se pred jakoukoliv akci nad doklady. Pokud vrati True, provede se i standardni ukladani.
function putQueueDocDetailStopPicking_beforeSaveStart(AOS: TNxCustomObjectSpace; AModule, ADocType, AUser_ID, ADocument_ID: String;
  AJson: TJSONSuperObject): Boolean;
begin
  Result := True;
end;

// AG-10567
// Urcuje zda se maji potvrzene radky ve volnych scenarich pridavat na konec, nebo na zacatek seznamu radku.
function NewRowToTheEnd(AOS: TNxCustomObjectSpace; AModule, ADocType, AUser_ID: String): Boolean;
begin
  Result := True;
end;

begin
end.