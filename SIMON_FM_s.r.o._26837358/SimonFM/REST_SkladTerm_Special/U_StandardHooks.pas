uses
  'REST_SkladTerm.U_Func',
  'REST_SkladTerm.U_FuncJSON',
  'REST_SkladTerm_Special.U_Const',
  'StandardUnits.U_GetId';

// vraci ID rady, ktera se ma doplnit na doklad (POZOR, ne vzdy musi byt k dispozici ASourceDocument - melo by tedy vychazet z kombinace typu dokladu a scenare)
// ASourceDocType obsahuje typ zdrojoveho dokladu - tedy napr. prijemka pro naskl. do pozic - je vyplneno, pouze pokud dava smysl
// ASourceDocument obsahuje zdrojovy doklad - u volnych dokladu, zde muze byt take primo doklad, kteremu se rada nastavuje
// pokud se nic nevraci, pouzije se vychozi rada z konstant
function GetDocQueue_ID(AOS: TNxCustomObjectSpace; AModule, ADocType, AUser_ID: String; AJson: TJsonSuperObject; ASourceDocType: String = '';
  ASourceDocument: TNxCustomBusinessObject = nil; AStore_ID: String = ''): String;
begin
  Result := '';
  if (ADocType=DOC_IncomingTransfer) and (AUser_ID in ['3EI0000101','2620000101','4EP0000101','3EB0000101','4EY0000101']) then Result:='7RB0000101';
  if (ADocType=DOC_IncomingTransfer) and (AUser_ID='3EJ0000101') then Result:='7RC0000101';
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
  if (AUser_ID in ['3EJ0000101','3I00000101','5EM0000101','1O00000101','4EN0000101','3N10000101','3E40000101','3EY0000101']) then begin
   AStoreIDs.Add('4P00000101');  //sklad 01-VO
   AStoreIDs.Add('2D00000101');  //sklad 05
   AStoreIDs.Add('1000000101');  //sklad 02
   AStoreIDs.Add('1L00000101');  //sklad 555
   AStoreIDs.Add('1E00000101');  //sklad MO-II
   Result:=True;
  end;
end;

// podminka, kterou lze omezit pridavané artikly pri jejich nacteni kodem (getStoreCardInfo)
// AIsNewRow urcuje, zda jde o novy radek (napr. pri nacteni kodu ve scenarich s dokladem bude False, pokud bych nemel povoleno pridavat radky a nenacital
//   kod v obrazovce noveho radku (stisk tlacitka +). Pri volani v ramci specialniho parsovni je vzdy False
function StoreCard_Where(AOS: TNxCustomObjectSpace; AModule, ADocType, AUser_ID: String; AIsNewRow: Boolean): String;
begin
  Result := '';
end;

// podminka, kterou lze omezit pozice pri jejich nacteni kodem (get_StorePositionInfo)
function StorePosition_Where(AOS: TNxCustomObjectSpace; AModule, ADocType, AUser_ID: String; AQueryParams: TStringList): String;
begin
  Result := '';
end;

// umoznuje nadefinovat vlastni hledani v seznamu artiklu. Vzdy se zobrazuji pouze neskryte artikly
// ASearchStr obsahuje text, ktery skladnik zadal do vyhledavaciho pole
function ListStoreCards_Search(AOS: TnxCustomObjectSpace; AModule, ADocType, AUser_ID, ASearch: String): String;
begin
  Result := '';

  if Trim(ASearch) <> '' then
    Result := Result + nxCrLf +
      '  and (SC.' + cStoreCardInfoCodeField + COLLATION_AI + 'like ''%' + ASearch + '%''' + nxCrLf +
      '    or SC.Code' + COLLATION_AI + 'like ''%' + ASearch + '%''' + nxCrLf +
      '    or SC.' + cStoreCardInfoNameField + COLLATION_AI + 'like ''%' + ASearch + '%'')';
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

  if ABRA and (ADocType = DOC_JobOrder) then
    Result :=
      '   and SD.ReleasedAt$DATE > 0' + nxCrLf +
      '   and SD.FinishedAt$DATE = 0' + nxCrLf;

  if ASearchStr <> '' then
  begin
    if ((ADocType = DOC_JobOrder) or (ADocType = DOC_WorkshopSchedule)) then
    begin
      if ABRA then
        Result := Result +
          ' and (1 = 0' + nxCrLf;
      if not ABRA then
        Result := Result +
          ' and (SD.CodeID' + COLLATION_AI + 'like ''%' + ASearchStr + '%''' + nxCrLf;
    end
    else
      Result := Result +
        ' and (SD.Description' + COLLATION_AI + 'like ''%' + ASearchStr + '%''' + nxCrLf;

    if not (ADocType in [DOC_MainInvProtocol, DOC_PartialInvProtocol]) then
      Result := Result +
        '   or (F.Name' + COLLATION_AI + 'like ''%' + ASearchStr + '%'' ) ' + nxCrLf;

    Result := Result +
      '   or (DQ.Code' + CONCAT_STR + QuotedStr('-') + CONCAT_STR + 'cast(SD.OrdNumber as varchar(6))' +
        CONCAT_STR + QuotedStr('/') + CONCAT_STR + 'P.Code like ''%' + ASearchStr + '%''))';
  end;
   if (ADocType = DOC_OutgoingTransfer) and (AUser_ID in ['3EI0000101','2620000101','4EP0000101','3EB0000101','4EY0000101']) then Result:= Result + ' and SD.DocQueue_ID =  ''6RC0000101''';   //pda eshop
   if (ADocType = DOC_OutgoingTransfer) and (AUser_ID in ['3EJ0000101','3I00000101','5EM0000101','1O00000101','4EN0000101','3N10000101','3E40000101','3EY0000101'])
        then Result:= Result + ' and ((SD.DocQueue_ID =  ''6RB0000101'') or (SD.DocQueue_ID =''Z200000101''))';   //pda simon U200000101
   if (ADocType = DOC_IncomingTransfer) and (AUser_ID in ['3EI0000101','2620000101','4EP0000101','3EB0000101','4EY0000101']) then Result:= Result + ' and SD.DocQueue_ID =  ''7RC0000101''';
   if (ADocType = DOC_IncomingTransfer) and (AUser_ID in ['3EJ0000101','3I00000101','5EM0000101','1O00000101','4EN0000101','3N10000101','3E40000101','3EY0000101'])
     then Result:= Result + ' and SD.DocQueue_ID in (''7RB0000101'',''X200000101'') ';
   if (ADocType = DOC_ReceiptCard) and (AUser_ID in ['3EI0000101','2620000101','4EP0000101','3EB0000101','4EY0000101']) then Result:= Result + ' and SD.DocQueue_ID =  ''6N20000101''';
   if (ADocType = DOC_ReceiptCard) and (AUser_ID = '3EJ0000101') then Result:= Result + ' and SD.DocQueue_ID =  ''7RD0000101''';
   if (ADocType = DOC_BillOfDelivery) and (AUser_ID in ['3EI0000101','2620000101','4EP0000101','3EB0000101','4EY0000101']) then Result:= Result + ' and SD.DocQueue_ID =  ''8RC0000101''';
    //DL03 pro velkoobchodní uživatele
   if (ADocType = DOC_BillOfDelivery) and (AUser_ID in ['3EJ0000101','3I00000101','5EM0000101','1O00000101','4EN0000101','3N10000101','3E40000101','3EY0000101']) then
      Result:= Result + ' and SD.DocQueue_ID =  ''U200000101''';
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
    Result := PAD_LEFT('coalesce(LSP.Code, ' + EMPTY_STRING + ')', '0', 30) + CONCAT_STR + PAD_LEFT('SC.Code', '0', 40) +
      CONCAT_STR + PAD_LEFT('coalesce(SB.Name, ' + EMPTY_STRING + ')', '0', 40) + nxCrLf
  else if ADocType = DOC_JobOrder then
    Result := PAD_LEFT('N.PosIndex', '0', 4) + CONCAT_STR + PAD_LEFT('NMI.PosIndex', '0', 4)
  else
    Result := PAD_LEFT('SD2.PosIndex', '0', 4) + CONCAT_STR + PAD_LEFT('coalesce(DRB.PosIndex, 0)', '0', 4) +
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
end;

// Umoznuje pro kazdy radek urcit, zda na nem lze zadad vyssi mnozstvi nez je zadane na dokladu - vklada se jako SQL fragment, radek
// dokladu je pod aliasem SD2, artikl pak pod aliasem SC
// Hodnoty, ktere je potreba vratit jsou stejne jako boolean v systemu (tedy A jako True, a N jako False)
function putQueueDocDetailStartPicking_CanEnterBiggerQuantity(AOS: TNxCustomObjectSpace; AModule, ADocType, AUser_ID: String): String;
begin
  Result := '''N''';
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
var
 mBO:TNxCustomBusinessObject;
 mPrice, mReserved:Extended;
 mFlist:TStringList;
 mFNames, mResult:string;
 i:integer;
 mPriceDPH:Extended;
begin
   if AModule in ['STD_InfoFromStores'] then begin
    if AJson.DataType = jtObject then begin
        mfnames:='';
        mBO:=aos.CreateObject(Class_StoreCard);
        mBO.Load(AJson.S['StoreCard_ID'],nil);
        mPrice:=NxEvalObjectExprAsFloatDef(mbo,'NxGetStoreCardUnitPriceDef('+Quotedstr('')+', '+Quotedstr('')+', ' + QuotedStr(mbo.OID) + ','+Quotedstr('1000000101')+', '+Quotedstr(mBO.GetFieldValueAsString('MainUnitCode'))+',True,'+QuotedStr('0000CZK000')+','+inttostr(trunc(Date))+')',0);
        mReserved:=NxEvalObjectExprAsFloatDef(mbo,'NxGetReservedQuantity('+ QuotedStr(mbo.OID) + ')',0);
        mPrice:= NxRoundByValue(mPrice,ctArithmetic,0.01);
        mFlist:=TStringList.create;
        aos.SQLSelect('select dq.code||'+Quotedstr('-')+'||ro.ordnumber||'+Quotedstr('/')+'||p.code, f.name, '+Quotedstr('(')+'||cast(ro2.quantity as numeric(13,2))||'+QuotedStr(')')+' from receivedorders ro left join receivedorders2 ro2 on ro.id=ro2.parent_id left join firms f on f.id=ro.firm_id left join docqueues dq on dq.id=ro.docqueue_id left join periods p on p.id=ro.period_id where ro.closed=''N'' and ro2.storecard_id='+Quotedstr(mBO.OID)+' and (ro2.deliveredquantity=0) ',mFlist);
        if mFlist.count>0 then begin
          for i:=0 to mFlist.count-1 do begin
            if i=0 then mFNames:=NxSearchReplace(mFlist.strings[i],'"','',[srAll]) else mFNames:=mFNames+#13#10+NxSearchReplace(mFlist.strings[i],'"','',[srAll]);
          end;
          mResult:= ('Cena: ' + FloatToStr(mPrice) + ' Kč'+#13#10+'Rezervace: '+FloatToStr(mReserved)+#13#10+mFNames);
        end;
        if mflist.Count=0 then
        mResult:= ('Cena: ' + FloatToStr(mPrice) + ' Kč'+#13#10+'Rezervace: '+FloatToStr(mReserved));
        mbo.Free;
      AJson.S['AuxText'] := mResult;
      AJson.B['AuxTextInSCInfo'] := True;
    end

    else if AJson.DataType = jtArray then begin
       //QuotedStr(AJson.AsArray.O[0].S['StoreCard_ID'])
        mfnames:='';
        mBO:=aos.CreateObject(Class_StoreCard);
        mBO.Load(AJson.AsArray.O[0].S['StoreCard_ID'],nil);
        mPrice:=NxEvalObjectExprAsFloatDef(mbo,'NxGetStoreCardUnitPriceDef('+Quotedstr('')+', '+Quotedstr('')+', ' + QuotedStr(mbo.OID) + ','+Quotedstr('1000000101')+', '+Quotedstr(mBO.GetFieldValueAsString('MainUnitCode'))+',True,'+QuotedStr('0000CZK000')+','+inttostr(trunc(Date))+')',0);
        mReserved:=NxEvalObjectExprAsFloatDef(mbo,'NxGetReservedQuantity('+ QuotedStr(mbo.OID) + ')',0);
        mPrice:= NxRoundByValue(mPrice,ctArithmetic,0.01);
        mFlist:=TStringList.create;
        aos.SQLSelect('select dq.code||'+Quotedstr('-')+'||ro.ordnumber||'+Quotedstr('/')+'||p.code, f.name, '+Quotedstr('(')+'||cast(ro2.quantity as numeric(13,2))||'+QuotedStr(')')+' from receivedorders ro left join receivedorders2 ro2 on ro.id=ro2.parent_id left join firms f on f.id=ro.firm_id left join docqueues dq on dq.id=ro.docqueue_id left join periods p on p.id=ro.period_id where ro.closed=''N'' and ro2.storecard_id='+Quotedstr(mBO.OID)+' and (ro2.deliveredquantity=0) ',mFlist);
        if mFlist.count>0 then begin
          for i:=0 to mFlist.count-1 do begin
            if i=0 then mFNames:=NxSearchReplace(mFlist.strings[i],'"','',[srAll]) else mFNames:=mFNames+#13#10+NxSearchReplace(mFlist.strings[i],'"','',[srAll]);
          end;
          mResult:= ('Cena: ' + FloatToStr(mPrice) + ' Kč'+#13#10+'Rezervace: '+FloatToStr(mReserved)+#13#10+mFNames);
        end;
        if mflist.Count=0 then
        mResult:= ('Cena: ' + FloatToStr(mPrice) + ' Kč'+#13#10+'Rezervace: '+FloatToStr(mReserved));
        mBO.free;
      AJson.AsArray.O[0].S['AuxText'] :=mResult;
      AJson.AsArray.O[0].B['AuxTextInSCInfo'] := True;
    end;
   end;
   {if AModule in ['STD_BillOfDeliveryQueue'] then begin
    if AJson.DataType = jtObject then begin
      AJson.SaveToFile('c:\log_abra\json\object.json');
      mBO:=aos.CreateObject(Class_StoreCard);
      mBO.Load(AJson.S['StoreCard_ID'],nil);
      mResult:='Spec: '+mbo.GetFieldValueAsString('Specification')+'  Spec2:'+mbo.GetFieldValueAsString('Specification2');
      AJson.S['AuxText'] := mResult;
      AJson.B['AuxTextInSCInfo'] := True;
      mBO.free;
    end

    else if AJson.DataType = jtArray then begin
      AJson.SaveToFile('c:\log_abra\json\array.json');
      mBO:=aos.CreateObject(Class_StoreCard);
      mBO.Load(AJson.AsArray.O[0].S['StoreCard_ID'],nil);
      mResult:='Spec: '+mbo.GetFieldValueAsString('Specification')+'  Spec2:'+mbo.GetFieldValueAsString('Specification2');
      AJson.AsArray.O[0].S['AuxText'] :=mResult;
      AJson.AsArray.O[0].B['AuxTextInSCInfo'] := True;
      mbo.free;
    end;
   end; }
end;

// jestli se pri ukoncovani zpracovani podle dokladu bude vytvaret polohovaci doklad na nezpracovane polozky
function putQueueDocDetailStopPicking_CreateLogStoreDocumentForNotPickedRows(AOS: TNxCustomObjectSpace; AModule, ADocType, AUser_ID: String): Boolean;
begin
  Result := True;
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
   if (AModule in ['STD_BillOfDeliveryQueue','STD_TransferQueue','STD_ReceiptCardQueue','STD_BillOfDeliveryWithoutDoc','STD_ReceiptCardWithoutDoc']) and (ACalledFrom='getRowsSql') then begin
    ORowList:=True;
    ORowDetail:=True;
    Result := Quotedstr('Kód: ')+'||SC.Code';
   end else begin
    Result := QuotedStr('');
   end;
end;

// Celkova hodnota a nadpis vlastni hodnoty v obrazovce Informace o skladu. Vždy by mělo vracet množství v hlavní jednotce artiklu.
// AType urcuje pro kterou cast se vola:
//   0 - Vola se pri zobrazeni artiklu (ID artiklu je ve sloupci SC.ID)
//   1 - Vola se pri zobrazeni sarze (ID sarze je ve sloupci SB.ID)
function AvailableInStock_SummaryCustomValue(AOS: TNxCustomObjectSpace; AModule, ADocType, AUser_ID: String; var ATitle: String; AType: Integer): String;
begin
  ATitle := QuotedStr('Ve výdeji');

  if AType = 0 then
    Result := '(select sum(SSC.BookedQuantity) / SU.UnitRate from StoreSubCards SSC where SSC.StoreCard_ID = SC.ID)'
  else
    Result := '(select sum(SSB.BookedQuantity) / SU.UnitRate from StoreSubBatches SSB where SSB.StoreBatch_ID = SB.ID)';
end;

// Hodnota pro jednotlive sklady v obrazovce Informace o skladu. Vždy by mělo vracet množství v hlavní jednotce artiklu.
// Doplnuje se do puvodniho dotazu a lze tedy pouzivat napr SSC.StoreCard_ID nebo SSC.Store_ID
// AType urcuje pro kterou cast se vola:
//   0 - Vola se pri zobrazeni artiklu (ID artiklu je ve sloupci SC.ID, vola se z tabulky StoreSubCards s aliasem SSC)
//   1 - Vola se pri zobrazeni sarze (ID sarze je ve sloupci SB.ID, vola se z tabulky StoreSubBatches s aliasem SSB)
function AvailableInStock_ByStoreCustomValue(AOS: TNxCustomObjectSpace; AModule, ADocType, AUser_ID: String; AType: Integer): String;
var
  mSql: String;
begin
  if AType = 0 then
    Result := 'SSC.BookedQuantity / SU.UnitRate'
  else
    Result := 'SSB.BookedQuantity / SU.UnitRate';
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
// ASerialNumbers obsahuje seznam seriovych cisel na radku - tj. cisla pro ktera se bude hledat dostupne mnozstvi (fieldy: SerNum_ID, isProcessed)
// ASerialNumbersQuantity obsahuje seznam seriovych cisel se ziskanym dostupnym mnozstvim s fieldy: id, available
procedure get_AvailableQuantityHook(AOS: TNxCustomObjectSpace; AModule, ADocType, AUser_ID, AStore_ID, AStorePosition_ID, AStorePositionTo_ID, AStoreCard_ID,
  AStoreBatch_ID, AStoreDocument2_ID: String; ASerialNumbers, ASerialNumbersQuantity: TMemTable; var ADS: TMemTable; AEnteredQuantityDifference: Integer; AEnteredQuantity: Double);
begin
end;

// Zda se ptat na vytvoreni dokladu pro nepotvrzene mnozstvi
function askForNewDocumentCreation(AOS: TNxCustomObjectSpace; AModule, ADocType, AUser_ID: String): Boolean;
begin
  Result := False;
end;

// Zda vytvorit doklad na nezpracovane polozky v pripade, ze se ctecka nema ptat
function createNewDocument(AOS: TNxCustomObjectSpace; AModule, ADocType, AUser_ID: String): Boolean;
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
  begin
    if not ABRA then
      Result := 'SD.CodeID';
  end
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
// ACalledFrom - Misto, odkud je volano: getStoreCardInfoSql, getRowsSql (zde jsou dostupne i udaje z radku dokladu)
function putQueueDocDetailStartPicking_StoreCardCategory(AOS: TNxCustomObjectSpace; AModule, ADocType, AUser_ID, ACalledFrom: String): String;
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
// ASDType je typ ukladaneho dokladu: 0 - puvodni doklad, 1 - oddeleny doklad na nezpracovane radky, PRV pri prevodu apod
procedure afterSaveHook(AOS: TNxCustomObjectSpace; AModule, ADocType, AUser_ID: String; ADocument: TNxCustomBusinessObject; ASDType: Integer;
  AJson: TJSONSuperObject; ARows: TMemTable);
begin
end;

// umoznuje rucne zmenit doklad pred zmenou stavu do Vyskladneno. V pripade, ze vrati True, je stav zmenen, v pripade False stav jiz zmenen neni.
// ASDType je typ dokladu u ktereho se meni stav: 0 - puvodni doklad, 1 - oddeleny doklad na nezpracovane radky
// POZOR, v pripade ASDType = 0 neni ASDNew nacteny (je nil), takze je potreba si ho pripadne rucne nacist
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
// Volano ze dvou mist (ACalledFrom):
//   getStoreCardInfoSql - Volano z informaci o artiklu, volnych scenaru a v nekterych pripadech pri dohledavani radku v
//                          ve scenarich dle dokladu - tam se ale na tento sloupec nebere zretel
//   getRowsSql          -  Volano pri otevreni dokladu (scenare podle dokladu)
//   GetPartialInvProtocolsRowsSql - Volano pri nacitani radku scenare Inventarizace dle DIP
// Standardne se nikde nezobrazuje, urceno pro specialy nebo pro prenaseni udaju mezi ukladanym a oddelenym dokladem
function rowAuxText2(AOS: TNxCustomObjectSpace; AModule, ADocType, AUser_ID, ACalledFrom: String): String;
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

  // priklad - hledani v X poli
  {Result:=
    'select ' + FIRST_TOP(1) + ' SC.ID ' +
    'from StoreCards SC ' +
    'where SC.Hidden = ''N'' and SC.X_EAN = ' + QuotedStr(ABarcode);}
end;

// Zda se ve scenarich Prevod vydej a Prevod volny jednofazovy ma vytvorit PRP. Pokud PRP jiz existuje, tak se aktualizuje
// podle upravene PRV
// Vklada se jako SQL fragment
function CreateTransferIn(AOS: TNxCustomObjectSpace; AModule, ADocType, AUser_ID: String): String;
begin
  Result := QuotedStr('N');
  //if AUser_ID='3EJ0000101' then Result := QuotedStr('A');
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

// AG-14045
// Specialni parsovani EANu. K vracenemu ID karty a sarze se automaticky dohledaji vsechna potrebna pole
// U scenaru s doklady, se radek dohledava podle ID artiklu. Pokud ID artiklu zadane neni, radek se dohledava podle sarze / ser. cisla. Aby bylo mozne dohledat radek
// dle ser. cisla, musi byt na radku pouze jedno ser. cislo a stejne tak musi byt pouze jedno ser. cislo vraceno z tohoto skriptu.
// AInputValues - Dataset z aktualnimi hodnotami radku (pokud v na nem uz jsem). Obsahuje fieldy:
//   Document_ID=S10 - ID dokladu
//   Row_ID=S10 - ID radku
//   Firm_ID=S10 - ID firmy
//   StoreCard_ID=S10 - ID artiklu
//   StoreCardNew_ID=S10 - ID ciloveho artiklu pri zamene
//   StoreFrom_ID=S10 - ID skladu
//   StoreTo_ID=S10 - ID skladu
//   StorePositionFrom_ID=S10 - ID pozice
//   StorePositionTo_ID=S10 - ID pozice na
//   StoreBatch_ID=S10 - ID sarze
//   StoreBatchNew_ID=S10 - ID cilove sarze pri zamene
//   UnitCode=S10 - jednotka
//   UnitQuantityOriginal=F - puvodni mnozstvi
//   UnitQuantityActual=F - aktualne zadane mnozstvi
// OOutputValues - Dataset z výstupními hodnotami. Pokud vrátí více řádků, tak uživatel dostane ve čtečce na výběr, který řádek chce použít.
//     Pokud je vice radku, kazdy musi mit vyplneny artikl. Obsahuje fieldy:
//   StoreCard_ID=S10 - ID artiklu
//   StoreCardNew_ID=S10 - ID ciloveho artiklu pri zamene (pri vyplneni je potreba vracet i zdrojovy artikl v StoreCard_ID)
//   StoreBatch_ID=S10 - ID sarze
//   StoreBatchNew_ID=S10 - ID cilove sarze pri zamene (pri vyplneni je potreba vracet i zdrojovy artikl v StoreCard_ID)
//   StoreFrom_ID=S10 - ID skladu
//   StoreTo_ID=S10 - ID skladu na
//   StorePositionFrom_ID=S10 - ID pozice
//   StorePositionTo_ID=S10 - ID pozice na
//   UnitQuantity=F - mnozstvi
//   UnitCode=S5 - jednotka - zmeni se pouze u scenaru bez dokladu
//   StoreBatchAux=S500 - doplnkova informace k sarzi
//   StoreBatchExpirationDate=C - datum expirace sarze
//   DialogText=S500 - text dialogu zobrazeneho pri otevreni radku
//   DialogType=I - typ tohoto dialogu: 0 - Upozorneni s tlacitkem OK, 1 - Ano/ne, kdy vyber ne obrazovku radku zavre a vrati skladknika do detailu dokladu
//   NextStoreCardBarcode=S500 - pokud je vyplneno, pokusi se ctecka ulozit aktualni radek a zavola zpracovani retezce z tohoto fieldu (AG-10655)
//   SaveRow=B - umoznuje rovnou ulozit radek (AG-14495)
//   ShowUnitConversion=B - zobrazi zobrazeni prepoctu do zadane jednotky (AG-16359)
//   AuxJson=S1000 - prida se k informaci o artiklu, vyuziva se pouze u special
// POZOR - musis si sam ohlidat konzistenci -> napr. nemel bys vracet sklad pro frontove doklady
// AStoreBatchDataset, AStorePosition muze vratit kompletni objekt, aby se jiz nemusel dohledavat (napr. u prijmu, kdyz sarze jeste neexistuje.
//   ID ma ale vzdy prednost)
// OSerialNumbers slouží k vrácení sériových čísel (Fieldy: SerNum_ID, SerNumName, AuxText). Pokud se bude vytvářet nové sér. číslo (SerNum_ID bude prázdne),
//   tak se informace v AuxText ulozi do pole urceneho funkci putQueueDocDetailStopPicking_AuxInfoForSerNumField.
// funkce se pouziva take ve scenari ABRA_OneCodeQueue - v tomto pripade se ID dokladu vraci v promene OStoreCard_ID
procedure parseBarcodeForRowSpecial(AOS: TNxCustomObjectSpace; AModule, ADocType, AUser_ID, ABarcode: String;
  AInputValues, ACurrentSerialNumbers: TMemTable;
  OOutputValues: TMemTable;
  var AStoreBatchDataset, AStorePositionFromDataset, OSerialNumbers: TMemTable);
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

// AG-11868
// Umoznuje zobrazit dialog pri ukladani radku (repektive pri volani kontroly dostupneho mnozstvi)
// Parametry k vyplneni:
//   ODialogTitle - Text dialogu (max. 50 znaku)
//   ODialogText - Text dialogu (max. 500 znaku)
//   ODialogType - Typ dialogu:
//     0 - Pouze tlacitko OK (po stisku aplikace bezi standardne dale)
//     1 - Tlacitka ANO (aplikace bezi standardne dale) a NE (uzivatel se vrati do obrazovky radku)
procedure DialogOnRowSave(AOS: TNxCustomObjectSpace; AModule, ADocType, AUser_ID, AStoreDocument2_ID, AStoreCard_ID, AStoreBatch_ID, AStore_ID,
  AStorePosition_ID: String; AEnteredQuantity: Double; AIsEditing: Boolean; var ODialogTitle, ODialogText: String; var ODialogType: Integer);
begin
end;

// AG-10790
// umoznuje ve scenarich po stisku Ok zobrazit dialog pro vyplneni hodnot. Dataset je v Edit modu.
// ACalledFrom - Misto, odkud je volano: getStoreCardInfoSql, rows (zde jsou dostupne i udaje z radku dokladu)
// OValues obsahuje jednoliva zadavatelna pole dialogu - dataset ma nasledujici fieldy:
//   type         - typ pole: number,decimalNumber,text,roll
//   label        - popisek pole
//   field        - pole na BO, do ktereho se ulozi zadana hodnota
//   dbValue      - nazev sloupce z DB, kterym se ma predvyplnit hodnota pole (napr. SC.Description) - nefunguje pro vyber z ciselniku (roll)
//   intValue     - hodnota pole v pripade typu number
//   doubleValue  - hodnota pole v pripade typu decimalNumber
//   stringValue  - hodnota pole v pripade typu text, nebo roll - v pripade typu roll je zde ulozen kod vybraneho zaznamu
//   rollValueId  - pouzivano pouze v pripade typu roll - je zde ulozeno ID vybraneho zaznamu
//   rollName     - pouzivano pouze v pripade typu roll - ciselnik, ktery se ma otevrit v pripade klepnuti (hodnota se preda do funkce REST_SkladTerm_Special.U_DialogRolls)
//
// vzdy musi byt vyplnena vsechna pole (tedy v pripade pouziti typu number musi byt stejne vyplnen rollName atd. - toto plati minimalne pro FLORES, ktery
// nevyplnenim polim pri prevodu do JSON dava nesmyslne hodnoty
//
// hodnoty pro ciselniky se zadavaji v REST_SkladTerm_Special.U_DialogRolls, je zde i ukazka
procedure RowDialog(AOS: TNxCustomObjectSpace; AModule, ADocType, AUser_ID, ACalledFrom: String; var OValues: TMemTable);
begin
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
  if AModule = 'STD_TransferWithoutDoc' then begin
      OValues.Edit;
      OValues.Append;
      OValues.FieldByName('type').AsString := 'roll';
      OValues.FieldByName('label').AsString := 'Sklad:';
      OValues.FieldByName('field').AsString := 'U_DestinationStore';
      OValues.FieldByName('stringValue').AsString := '';
      OValues.FieldByName('rollValueId').AsString := '';
      OValues.FieldByName('rollName').AsString := 'Store';
      OValues.Post;
  end;
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
function DisableQuantityEdit(AOS: TNxCustomObjectSpace; AModule, ADocType, AUser_ID: String): String;
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
    Result := 'case when SC.ID = ''1N00000101'' then ''X_Note=Rychle;X_Cislo=5'' when SC.Code = '''' then ''X_Note;X_Cislo'' else '''' end';
  }
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
  Result:=  'case when SD.TransportationType_ID = ''3000000102'' then ''01b1ed'' ' +
                 'when SD.TransportationType_ID = ''1000000102'' then ''01b1ed'' ' +
                 'when SD.TransportationType_ID = ''3200000101'' then ''01b1ed'' ' +
                 'else '''' end';
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
var
 mList:TStringList;
begin
  if not NxIsBlank(ALoginCode) then begin
    mList:=tstringlist.Create;
    aos.SQLSelect('SELECT ID FROM SecurityUsers WHERE X_Password='+QuotedStr(ALoginCode),mList);
    if mlist.count>0 then Result:=mlist.strings[0];
    end
  else
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
  if AModule='STD_TransferWithoutDoc' then Result:=True;
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
end;

// zda je mozne zadavat neexistujici cisla - tato cisla se pak pri ulozeni dokladu vytvori
function CanCreateNewSerialNumbers(AOS: TNxCustomObjectSpace; AModule, ADocType, AUser_ID, ADocument_ID: String): Boolean;
begin
  Result := False;
  if ADocType in [DOC_ReceiptCard, DOC_IssuedOrder, DOC_LogStoreInput, DOC_MainInvProtocol, DOC_PartialInvProtocol] then
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
  Result := 1;
end;

// funkce volana tlacitkem TISK z obrazovky radku.
// ARow obsahuje JSON s radkem, format poli je shodny s SQL dotazem v REST_SkladTerm.U_SQLQueries.getRowsSql
procedure PrintRowFunction(AOS: TnxCustomObjectSpace; AModule, ADocType, AUser_ID: String; ARow: TJSONSuperObject);
var
 mList:TStringList;
 mCount,i:Integer;
 mCLSID, mCLSID2, mCLSID3:string;
begin
  if AModule in ['STD_ReceiptCardQueue','STD_BillOfDeliveryQueue','STD_TransferQueue','STD_InfoFromStores','STD_TransferInQueue'] then begin
   mList:=TStringList.create;
   mList.add(aRow.S['StoreCard_ID']);
   mclsid:=aos.SQLSelectFirstAsString('SELECT DataSource FROM Reports WHERE ID='+Quotedstr('1K70000101'),'');
   mclsid2:=aos.SQLSelectFirstAsString('SELECT DataSource FROM Reports WHERE ID='+Quotedstr('5VL1000101'),'');
   mclsid3:=aos.SQLSelectFirstAsString('SELECT DataSource FROM Reports WHERE ID='+Quotedstr('3680000101'),'');
   mcount:=trunc(Arow.D['UnitQuantity']);
   if AUser_ID in ['3I00000101','5E70000101','5EM0000101','1O00000101','4EN0000101','3N10000101','3EJ0000101','3EY0000101'] then begin
     CFxReportManager.PrintByIDs(NxCreateContext(AOS),mList,mCLSID3,'3680000101',rtoPrint,pekPDF,'Honeywell_Sklad_Plus', '', mCount);
   end else begin
     if AUser_ID in ['4EP0000101','2620000101','3EI0000101','3EB0000101','6EV0000101','4EY0000101'] then
     CFxReportManager.PrintByIDs(NxCreateContext(AOS),mList,mCLSID2,'5VL1000101',rtoPrint,pekPDF,'Qoltec_eshop', '', mCount)
      else
     CFxReportManager.PrintByIDs(NxCreateContext(AOS),mList,mCLSID,'1K70000101',rtoPrint,pekPDF,'Datamax_BOSCH', '', mCount);
   end;
   //ARow.SaveToFile('F:\logy\printer\data.json');
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
end;

// AG-12405
// Urcuje, zda je mozne k dokladum pridavat fotky. Ty se pak ulozi jako dokumenty a pripoji se k dokladu.
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
//   groupby
//   orderby
//
//  Zaroven muze mit kazdy seznam sve vlastni parametry. Napriklad seznam osob muze mit parameter firm_id pro omezeni za firmu.
//  Seznam parametru je dale v seznamu podporovanych seznamu.
//
// AListName je prave volany seznam:
//   - get_ListBusOrders - seznam zakazek
//   - get_ListBusProjects - seznam projektu
//   - get_ListBusTransactions - seznam obchodnich pripadu
//   - get_ListDivisions - seznam stredisek
//   - get_ListPersons - seznam osob (firm_id)
//   - get_ListStoreBatches - seznam sarzi (onlyAvailable, store_id, storeCard_id, storePosition_id)
//   - listStoreCards - seznam artiklu (store_id, storePosition_id, allowedIds)
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
function ShowStoreAvailability(AOS: TNxCustomObjectSpace; AModule, ADocType, AUser_ID: String): String;
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
  Result := False;
end;

// AG-10521
// Zda se ma potvrdit polohovaci doklad
function MakeExecuteLogStoreDocument(AOS: TNxCustomObjectSpace; AModule, ADocType, AUser_ID, ADocument_ID: String): Boolean;
begin
  Result := True;
end;

// AG-12721
// Vraci sloupec, ktery se ma zobrazit jako dodatkova informace v seznamu artiklu (typicky napr. SC.ForeignName)
function StoreCardListAuxText(AOS: TNxCustomObjectSpace; AModule, ADocType, AUser_ID: String): String;
begin
  Result := QuotedStr('');
end;

// AG-15927
// Urcuje cestu, do ktere se budou ukladat soubory s daty z tabulky REST_TemporaryStorage (max. cca 250 znaku).
// Musi koncit lomitkem!
function TemporaryStoragePath(AOS: TNxCustomObjectSpace; AModule, ADocType, AUser_ID: String): String;
begin
  Result := '';
end;

// AG-16388
// Urcuje, zda je mozne ulozit doklad bez toho, aby byly potvrzene vsechny radky.
function CanSaveWithoutProcessingAllRows(AOS: TNxCustomObjectSpace; AModule, ADocType, AUser_ID: String): Boolean;
begin
  Result := True;
  if ADocType in [DOC_MaterialDistribution, DOC_ProductReception] then
    Result := False;
end;


begin
end.