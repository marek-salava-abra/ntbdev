uses 'const.const';

const
  // Pokud chci verzi skriptu pro ABRA
  ABRA = True;

  // kvuli ABRA si sjednotim nazvoslovi
  Class_RemovalList = Class_PickingList;
  Class_RemovalListRow = Class_PickingListRow;
  Class_PRFJobOrder = Class_PLMJobOrder;
  Class_PRFWorkshopSchedule = CFxGuid.Null;

  //ZAKLADNI NASTAVENI----------------------------------------------------------
  // nasledujici typy dokladu se nemeni
  DOC_ReceiptCard                     = '20';  // Příjemka
  DOC_BillOfDelivery                  = '21';  // Výdejka (Dodací list)
  DOC_OutgoingTransfer                = '22';  // Převodka výdej
  DOC_RefundedBillOfDelivery          = '23';  // Vratka výdejky (Vratka dodacího listu)
  DOC_RefundedReceiptCard             = '30';  // Vratka příjemky
  DOC_IncomingTransfer                = '24';  // Převodka příjem
  DOC_RemovalList                     = 'RL';  // Vyskladňovací list
  DOC_ShippingList                    = 'EL';  // Expediční list
  DOC_JobOrder                        = 'JO';  // Výrobní příkaz
  DOC_MaterialDistribution            = '27';  // Výdej materiálu do výroby
  DOC_ProductReception                = '28';  // Příjem hotových výrobků
  DOC_RefundedMaterialDistribution    = '29';  // Vrácení materiálu z výroby
  DOC_ReceivedOrder                   = 'RO';  // Objednávka přijatá
  DOC_IssuedOrder                     = 'IO';  // Objednávka vydaná
  DOC_MainInvProtocol                 = 'MI';  // Hlavní inventární protokol
  DOC_PartialInvProtocol              = 'PI';  // Dílčí inventární protokol
  DOC_WorkshopSchedule                = 'WS';  // Dílenský plán
  DOC_LogStoreInput                   = '31';  // Naskladnění do pozic
  DOC_LogStoreOutput                  = '32';  // Vyskladnění z pozic
  DOC_LogStoreTransfer                = '33';  // Přesun mezi pozicemi
  DOC_OutgoingSubstitution            = '36';  // Záměna výdej
  DOC_IncomingSubstitution            = '37';  // Záměna příjem
  DOC_OutgoingTransformation          = '38';  // Přeměna výdej
  DOC_IncomingTransformation          = '39';  // Přeměna příjem
  DOC_SmallAssetCard                  = 'SAC'; // Drobný majetek
  DOC_OrdersGeneration                = 'OG';  // Pozadavky na OV

  DIALOG_TYPE_BOOLEAN = 0;
  DIALOG_TYPE_TEXT    = 1;
  DIALOG_TYPE_NUMBER  = 2;

  // prihlasovaci udaje k REST sluzbe
  Authorization_Login    = 'flores';
  Authorization_Password = 'floSklTerm';

  DomainLoginUsed              = False; // musi byt True, pokud ma zakaznik zapnute prihlasovani do Floresu domenovym uctem
  DuplicateLoginCheck          = True; // kontrola, jestli neni jeden uzivatel prihlaseny do vice ctecek zaroven (krome zduvodnenych vyjimek vzdy True)
  OnlyOneScenarioWork          = False; // uzivatel nemuze pracovat ve vice scenarich najednou
  CheckLicence                 = false; // jestli kontrolovat licence podle ID zarizeni (u zakaznika vzdy True)
  NoncancelableWork            = False; // zda je mozne prerusit praci na dokladu bez smazani rozpracovaneho stavu
  NoncancelableWorkOnlyOneUser = True; // pokud je nastaveno na True, tak rozpracovany doklad muze dokoncit pouze uzivatel, ktery ho zacal
  ShowDocumentQueueCount       = False; // zda se v hlavnim menu maji zobrazit u tlacitek pocty dokladu ve fronte
  ShowQuickSupportAction       = True; // zda se v panelu akci zobrazuje ikonka pro TeamViewer
  NotConfirmedSerNumsToNewRow  = True; // pokud je nastaveno na True, tak se "smazana" seriova cisla prenesou na oddeleny radek (stejne jako napr. sarze)
  SerialNumbersConfirming      = False; // zda se ma pouzivat mechanismus potvrzovani seriovych cisel (ST-703)
  ShowDialogOnSave             = False; // zda se ma pred ulozenim volneho dokladu zobrazit upozorneni (AG-73)
  UseUnitsEANs                 = False; // pokud je nastaveno na True, tak se zacne menit mnozstvi a jednotky dle nacteneho EANu (AG-2528)
  AddingByOne                  = False; // pokud je nastaveno na True, tak se nacitanim artiklu mnozstvi navyuje o 1 (AG-4831)
  SelectScenarioByBarcode      = False; // umoznuje vybrat scenar nactenim jeho kodu (AG-5914)
  ToastBeep                    = False; // zda se ma ozvat pipnuti v pripade zobrazeni hlasky toastem (zprava ve spodni casti obrazovky) (AG-10559)
  SeparatedDocumentByClone     = False; // zda se ma oddeleny doklad na nezpracovane radky vytvorit funkci Clone (AG-4510)
  CanEnterQuantityByBarcode    = False; // zda je mozne nacist znaky do pole s mnozstvim (AG-11795)
  SaveTemporaryStorageOnDisk   = False; // zda se maji data z tabulky REST_TemporaryStorage ukladat na disk (AG-15927)

  PrintWithPDFtoPrinter = False; // zda se pro tisk PDF souborů má používat PDFtoPrinter (http://www.columbia.edu/~em36/pdftoprinter.html)

  SKLAD_HLAVNI      = '1000000101'; // pouzije se napr. pro predvyplneni skladu, taky pri vytvoreni novych volnych dokladu
  FIRM_OWN          = 'AAA1000000'; // vlastni firma
  STREDISKO_HLAVNI  = '1000000101'; // středisko

  RADA_PRIJEMKA           = 'L000000101'; // rada Prijemka
  RADA_PREVYDEJ           = 'N000000101'; // rada Prevodka vydej
  RADA_PREPRIJEM          = 'P000000101'; // rada Prevodka prijem
  RADA_VYDEJKA            = 'M000000101'; // rada Vydejka
  RADA_VRATKA_VYDEJKY     = 'R600000101'; // rada Vratka vydejky
  RADA_DILCI_INV_PROTOKOL = ''; // rada Dilci inventarni protokol
  RADA_UZAVERKA_POSTY     = 'T700000101'; // rada Uzaverka posty
  RADA_OBP                = 'I700000101'; // rada Objednavka prijata
  RADA_DOKUMENT           = ''; // rada Dokument
  RADA_OutgoingTransformation = ''; // rada Premena vydej
  RADA_IncomingTransformation = ''; // rada Premena prijem
  RADA_OutgoingSubstitution   = ''; // rada Zamena vydej
  RADA_IncomingSubstitution   = ''; // rada Zamena prijem
  RADA_RefundedReceiptCard    = ''; // rada Vratka příjemky
  RADA_ShippingList           = ''; // rada Expedicni list
  RADA_MaterialDistribution   = ''; // rada Vydej materialu do vyroby
  Document_DocumentCategory_ID = ''; // Kategorie dokumentu pro nove dokumenty

  LogStoreOutput_DocQueue_ID     = '2900000101'; // rada Vyskladneni z pozic
  LogStoreOutput_StoreGateway_ID = '1000000101'; // Nasklad. a vyskladnovaci misto pro Vyskladneni z pozic
  LogStoreInput_DocQueue_ID      = '1900000101'; // rada Naskladneni do pozic
  LogStoreInput_StoreGateway_ID  = '1000000101'; // Nasklad. a vyskladnovaci misto pro Naskladneni do pozic
  LogStoreTransfer_DocQueue_ID   = '3900000101'; // rada Presun mezi pozicemi

  PDMIssuedDoc_DocQueue_ID = 'R700000101';

  RemovalList_DocQueue_ID = '2V00000101';

  InvetarizationFree_CloseDIP = false;      //Zda se DIP po ulozeni i zamkne
  InvetarizationByDIP_CloseDIP = true;      //Zda se DIP po ulozeni i zamkne

  // zda se pri vyberu sarze ve volne inventure maji nabizet pouze dostupne sarze
  InvetarizationFree_ListOnlyAvailableBatches = False;

  // pocet desetinnych mist pro zobrazeni mnozstvi (0 - 6)
  DecimalPlaces = 2;

  // jednotky (oddelene strednikem), pro ktere se v aplikaci nezobrazuji zadna desetinná místa (Informace ze skladu, seznamy) (AG-7207)
  UnitsWithoutDecimalPlaces = 'ks';

  ROLE_SKLADNIK = '2000000101';
  ROLE_CTECKA_SERVIS = '';

  // uzivatel, na ktereho se presune doklad pri pouziti tlacitka "Přesunout rozp. doklad"
  USER_KONZULTANT = '';

  TISKARNA_SKLAD = '';
  PRINT_GLOBAL_PARAM_NAME = 'REST_PRINT_PARAMETERS';

  // cesta, do ktere se ulozi vyfocene fotky (na konci musi byt lomitko!)
  NEW_PHOTOS_PATH = '';

  // cesta, do ktere se ulozi chybove hlasky z dialogu (na konci musi byt lomitko!)
  LOG_PATH = '';
  // cesta k souboru s konfiguraci profileru (AG-12986)
  PROFILER_CONFIG_FILE_PATH = '';
  // cesta, do ktere se ukladaji vysledky profilovani. Pokud jde o adresar, tak na konci musi byt lomitko! (AG-12986)
  PROFILER_RESULTS_PATH = '';

  // po kolika dnech se mohou mazat zaznamy v tabulce REST_TemporaryStorage (a soubory k nim patrici) (AG-15927)
  TEMPORARY_STORAGE_DELETE_AFTER = 180;

  CLIENT_CURRENT_VERSION = '6.10.1';    // aktualni verze, ctecky si kontroluji, jestli ji maji
  CLIENT_CURRENT_VERSION_URL = ''; // adresa na APK nove verze - musi byt vyplneno pri aktualizovani z verze 5.2.1 a nizsich (AG-6185)
  CLIENT_CURRENT_VERSION_DOCUMENT_ID = ''; // ID dokumentu v systému, pod kterým je uloženo APK - musi vyplneno pri aktualizaci z verze 5.3.1 a novejsich (AG-6185)

  // delka timeoutu pripojeni ctecky v sekundach
  // - prilis kratky timeout muze zpusobovat, ze to ve ctecce nahlasi chybu spojeni,
  //   i kdyz ve skutecnosti je problem pouze v tom, ze serveru to trva o neco dele
  // - prilis dlouhy timeout zase zpusobi to, ze pri opravdovem vypadku site musi uzivatel cekat cely tento timeout,
  //   nez mu ve ctecce vyskoci chyba a muze operaci zkusit zopakovat
  CLIENT_CONNECTION_TIMEOUT = 15;           // timeout pro dotazy, u kterych se neocekava dlouhe trvani (vetsinou cteni a jednoduche zapisy)
  CLIENT_CONNECTION_TIMEOUT_LONG = 600;      // timeout pro velke ukladacky (napr. prace s polohovacimi doklady na pozicich se spoustou artiklu muze trvat velmi dlouho)

  // jak casto se maji aktualizovat tlacitka v hlavnim menu (v sekundach). Hlavne kvuli poctum dokladu u tlacitek - 0 znamena neaktualizovat
  MAINMENU_BUTTONS_REFRESH_TIME = 0;

// seznam scenaru, ktere se maji objevit v hlavnim menu
// standardne se scenare odeluji strednikem. Mohou ale mit parametry (ty jsou oddelene dvojteckou), aktualne jsou podporovane tri:
//   nazev scenare - vzdy v uvozovkach - napr. "Muj vydej"
//   typ dokladu - dle konstant vyse v tomto souboru. Pokud jich je vice, oddeluji se carkou
//   vlastni kod scenare - nastavi se interne v aplikaci a pote se zasila do funkci v parametru AModule
// poradi parametru je povinne - tzn. pokud chci zadat pouze typ dokladu (druhy parametr), musim stejne zadat prazdny nazev: STD_:"":21
// kompletni format: STD_ReceiptCardQueue:"Vlastni nazev":21:STD_MujPrijem;STD_Bill....
// v nazvu lze vyuzit i odradkovani pomoci \n - napr. "Muj\nvydej"
// v pripade pouziti parametru, prestane fungovat stand. zobrazeni poctu dokladu
function CLIENT_VISIBLE_MODULES(AOS: TNxCustomObjectSpace; AUserStore_ID, AUser_ID: String): String;
begin
  Result :=
    'STD_ReceiptCardQueue' +
    ';STD_BillOfDeliveryQueue' +
    ';STD_TransferQueue' +
    ';STD_InfoFromStores' +
    ';STD_ReceiptCardWithoutDoc' +
    ';STD_BillOfDeliveryWithoutDoc' +
    ';STD_TransferBetweenPositionsQueue' +
    ';STD_TransferBetweenPositions' +
    ';STD_TransferWithoutDoc' +
    ';STD_InventorizationByDIP' +
    ';STD_InventorizationFree';
end;

const
  cStoreCardInfoCodeField = 'Code';
  cStoreCardInfoNameField = 'Name';

  cNewRowsDocIssuedOrderField = 'Description'; // do jakeho pole dokladu s novymi radky (pri zapnutem putQueueDocDetailStopPicking_NewRowsToSeperateDoc) se ulozi ID puvodni OB (Provide_ID)

  // podle ceho se ma zkusit hledat artikl (krome SC1000000101):
  // E - EAN, C - kod artiklu, X - vlastni hledani (U_StandardHooks.StoreCard_CustomSearch)
  cStoreCardInfoSearchIn = 'EC';

// stav dokladu zobrazenych ve fronte pro vyskladneni
function STAV_K_VYSKLADNENI(docTyp: string; AModule: String): string;
begin
  case docTyp of
    DOC_ReceiptCard:                    Result := ReceiptCard_Status_ID_K_Vyskladneni;
    DOC_BillOfDelivery:                 Result := BillOfDelivery_Status_ID_K_Vyskladneni;
    DOC_RefundedBillOfDelivery:         Result := RefundedBillOfDelivery_Status_ID_K_Vyskladneni; // stav Vratky nebo v pripade useBillOfDeliveryForRefunding = True stav Vydejky
    DOC_RefundedReceiptCard:            Result := RefundedReceiptCard_Status_ID_K_Vyskladneni;
    DOC_OutgoingTransfer:               Result := OutgoingTransfer_Status_ID_K_Vyskladneni;
    DOC_IncomingTransfer:               Result := IncomingTransfer_Status_ID_K_Vyskladneni;
    DOC_ShippingList:                   Result := ShippingList_Status_ID_K_Vyskladneni;
    DOC_RemovalList:                    Result := RemovalList_Status_ID_K_Vyskladneni;
    DOC_JobOrder:                       Result := JobOrder_Status_ID_K_Vyskladneni;
    DOC_MaterialDistribution:           Result := MaterialDistribution_Status_ID_K_Vyskladneni;
    DOC_ProductReception:               Result := ProductReception_Status_ID_K_Vyskladneni;
    DOC_RefundedMaterialDistribution:   Result := RefundedMaterialDistribution_Status_ID_K_Vyskladneni;
    DOC_IssuedOrder:                    Result := IssuedOrder_Status_ID_K_Vyskladneni;
    DOC_WorkshopSchedule:               Result := WorkshopSchedule_Status_ID_K_Vyskladneni;
    DOC_OutgoingSubstitution:           Result := OutgoingSubstitution_Status_ID_K_Vyskladneni;
    DOC_IncomingSubstitution:           Result := IncomingSubstitution_Status_ID_K_Vyskladneni;
    DOC_OutgoingTransformation:         Result := OutgoingTransformation_Status_ID_K_Vyskladneni;
    DOC_IncomingTransformation:         Result := IncomingTransformation_Status_ID_K_Vyskladneni;
  end;
end;

// stav oddeleneho dokladu s poskozenymi polozkami
// scenar ABRA_ReceiptCardDamagedQueue
function STAV_PO_ODDELENI_POSKOZENE(docTyp: string; AModule: String): string;
begin
  case docTyp of
    DOC_ReceiptCard:                    Result := '';
    DOC_BillOfDelivery:                 Result := '';
    DOC_RefundedBillOfDelivery:         Result := '';
    DOC_RefundedReceiptCard:            Result := '';
    DOC_OutgoingTransfer:               Result := '';
    DOC_IncomingTransfer:               Result := '';
    DOC_ShippingList :                  Result := '';
    DOC_RemovalList :                   Result := '';
    DOC_MaterialDistribution:           Result := '';
    DOC_OutgoingSubstitution:           Result := '';
    DOC_IncomingSubstitution:           Result := '';
    DOC_OutgoingTransformation:         Result := '';
    DOC_IncomingTransformation:         Result := '';
  end;
end;

// stav oddeleneho dokladu s novymi polozkami
// pokud je pouzito nastaveno oddeleni novych radku putQueueDocDetailStopPicking_NewRowsToSeperateDoc
function STAV_PO_ODDELENI_NOVE(docTyp: string; AModule: String): string;
begin
  case docTyp of
    DOC_ReceiptCard:                    Result := '';
    DOC_BillOfDelivery:                 Result := '';
    DOC_RefundedBillOfDelivery:         Result := '';
    DOC_RefundedReceiptCard:            Result := '';
    DOC_OutgoingTransfer:               Result := '';
    DOC_IncomingTransfer:               Result := '';
    DOC_ShippingList :                  Result := '';
    DOC_RemovalList :                   Result := '';
    DOC_MaterialDistribution:           Result := '';
    DOC_OutgoingSubstitution:           Result := '';
    DOC_IncomingSubstitution:           Result := '';
    DOC_OutgoingTransformation:         Result := '';
    DOC_IncomingTransformation:         Result := '';
  end;
end;

// role oddeleneho dokladu s poskozenymi polozkami
// scenar ABRA_ReceiptCardDamagedQueue
function ROLE_PO_ODDELENI_POSKOZENE(docTyp: string; AModule: String): string;
begin
  case docTyp of
    DOC_ReceiptCard:                    Result := '';
    DOC_BillOfDelivery:                 Result := '';
    DOC_RefundedBillOfDelivery:         Result := '';
    DOC_RefundedReceiptCard:            Result := '';
    DOC_OutgoingTransfer:               Result := '';
    DOC_IncomingTransfer:               Result := '';
    DOC_ShippingList :                  Result := '';
    DOC_RemovalList :                   Result := '';
    DOC_OutgoingSubstitution:           Result := '';
    DOC_IncomingSubstitution:           Result := '';
    DOC_OutgoingTransformation:         Result := '';
    DOC_IncomingTransformation:         Result := '';
  end;
end;

// role oddeleneho dokladu s novymi polozkami
// scenar ABRA_ReceiptCardDamagedQueue
function ROLE_PO_ODDELENI_NOVE(docTyp: string; AModule: String): string;
begin
  case docTyp of
    DOC_ReceiptCard:                    Result := '';
    DOC_BillOfDelivery:                 Result := '';
    DOC_RefundedBillOfDelivery:         Result := '';
    DOC_RefundedReceiptCard:            Result := '';
    DOC_OutgoingTransfer:               Result := '';
    DOC_IncomingTransfer:               Result := '';
    DOC_ShippingList :                  Result := '';
    DOC_RemovalList :                   Result := '';
    DOC_OutgoingSubstitution:           Result := '';
    DOC_IncomingSubstitution:           Result := '';
    DOC_OutgoingTransformation:         Result := '';
    DOC_IncomingTransformation:         Result := '';
  end;
end;

// ID prechodovych pravidel pro stavy dokladu
// K Vyskladneni -> Vyskladnovano
function PRECHOD_ZAHAJENI(docTyp: string; AModule: String): string;
begin
  case docTyp of
    DOC_ReceiptCard:                    Result := ReceiptCard_SwitchRule_ID_Zahajeni;
    DOC_BillOfDelivery:                 Result := BillOfDelivery_SwitchRule_ID_Zahajeni;
    DOC_RefundedBillOfDelivery:         Result := RefundedBillOfDelivery_SwitchRule_ID_Zahajeni; // prechod Vratky nebo v pripade useBillOfDeliveryForRefunding = True prechod Vydejky
    DOC_RefundedReceiptCard:            Result := RefundedReceiptCard_SwitchRule_ID_Zahajeni;
    DOC_OutgoingTransfer:               Result := OutgoingTransfer_SwitchRule_ID_Zahajeni;
    DOC_IncomingTransfer:               Result := IncomingTransfer_SwitchRule_ID_Zahajeni;
    DOC_JobOrder:                       Result := JobOrder_SwitchRule_ID_Zahajeni;
    DOC_ShippingList:                   Result := ShippingList_SwitchRule_ID_Zahajeni;
    DOC_RemovalList:                    Result := RemovalList_SwitchRule_ID_Zahajeni;
    DOC_MaterialDistribution:           Result := MaterialDistribution_SwitchRule_ID_Zahajeni;
    DOC_ProductReception:               Result := ProductReception_SwitchRule_ID_Zahajeni;
    DOC_RefundedMaterialDistribution:   Result := RefundedMaterialDistribution_SwitchRule_ID_Zahajeni;
    DOC_IssuedOrder:                    Result := IssuedOrder_SwitchRule_ID_Zahajeni;
    DOC_WorkshopSchedule:               Result := WorkshopSchedule_SwitchRule_ID_Zahajeni;
    DOC_OutgoingSubstitution:           Result := OutgoingSubstitution_SwitchRule_ID_Zahajeni;
    DOC_IncomingSubstitution:           Result := IncomingSubstitution_SwitchRule_ID_Zahajeni;
    DOC_OutgoingTransformation:         Result := OutgoingTransformation_SwitchRule_ID_Zahajeni;
    DOC_IncomingTransformation:         Result := IncomingTransformation_SwitchRule_ID_Zahajeni;
  end;
end;

// Vyskladnovano -> K vyskladneni
function PRECHOD_PRERUSENI(docTyp: string; AModule: String): string;
begin
  case docTyp of
    DOC_ReceiptCard:                    Result := ReceiptCard_SwitchRule_ID_Preruseni;
    DOC_BillOfDelivery:                 Result := BillOfDelivery_SwitchRule_ID_Preruseni;
    DOC_RefundedBillOfDelivery:         Result := RefundedBillOfDelivery_SwitchRule_ID_Preruseni; // prechod Vratky nebo v pripade useBillOfDeliveryForRefunding = True prechod Vydejky
    DOC_RefundedReceiptCard:            Result := RefundedReceiptCard_SwitchRule_ID_Preruseni;
    DOC_OutgoingTransfer:               Result := OutgoingTransfer_SwitchRule_ID_Preruseni;
    DOC_IncomingTransfer:               Result := IncomingTransfer_SwitchRule_ID_Preruseni;
    DOC_JobOrder:                       Result := JobOrder_SwitchRule_ID_Preruseni;
    DOC_ShippingList:                   Result := ShippingList_SwitchRule_ID_Preruseni;
    DOC_RemovalList:                    Result := RemovalList_SwitchRule_ID_Preruseni;
    DOC_MaterialDistribution:           Result := MaterialDistribution_SwitchRule_ID_Preruseni;
    DOC_ProductReception:               Result := ProductReception_SwitchRule_ID_Preruseni;
    DOC_RefundedMaterialDistribution:   Result := RefundedMaterialDistribution_SwitchRule_ID_Preruseni;
    DOC_IssuedOrder:                    Result := IssuedOrder_SwitchRule_ID_Preruseni;
    DOC_WorkshopSchedule:               Result := WorkshopSchedule_SwitchRule_ID_Preruseni;
    DOC_OutgoingSubstitution:           Result := OutgoingSubstitution_SwitchRule_ID_Preruseni;
    DOC_IncomingSubstitution:           Result := IncomingSubstitution_SwitchRule_ID_Preruseni;
    DOC_OutgoingTransformation:         Result := OutgoingTransformation_SwitchRule_ID_Preruseni;
    DOC_IncomingTransformation:         Result := IncomingTransformation_SwitchRule_ID_Preruseni;
  end;
end;

// Vyskladnovano -> Vyskladneno
function PRECHOD_UKONCENI(docTyp: string; AModule: String): string;
begin
  case docTyp of
    DOC_ReceiptCard:                    Result := ReceiptCard_SwitchRule_ID_Ukonceni;
    DOC_BillOfDelivery:                 Result := BillOfDelivery_SwitchRule_ID_Ukonceni;
    DOC_RefundedBillOfDelivery:         Result := RefundedBillOfDelivery_SwitchRule_ID_Ukonceni; // prechod Vratky
    DOC_RefundedReceiptCard:            Result := RefundedReceiptCard_SwitchRule_ID_Ukonceni;
    DOC_OutgoingTransfer:               Result := OutgoingTransfer_SwitchRule_ID_Ukonceni;
    // ukonceni prevodky prijem pri prevodu na PRP (Prijimano -> Prijmuto)
    DOC_IncomingTransfer:               Result := IncomingTransfer_SwitchRule_ID_Ukonceni;
    DOC_JobOrder:                       Result := JobOrder_SwitchRule_ID_Ukonceni;
    DOC_ShippingList:                   Result := ShippingList_SwitchRule_ID_Ukonceni;
    DOC_RemovalList:                    Result := RemovalList_SwitchRule_ID_Ukonceni;
    DOC_MaterialDistribution:           Result := MaterialDistribution_SwitchRule_ID_Ukonceni;
    DOC_ProductReception:               Result := ProductReception_SwitchRule_ID_Ukonceni;
    DOC_RefundedMaterialDistribution:   Result := RefundedMaterialDistribution_SwitchRule_ID_Ukonceni;
    DOC_IssuedOrder:                    Result := IssuedOrder_SwitchRule_ID_Ukonceni;
    DOC_WorkshopSchedule:               Result := WorkshopSchedule_SwitchRule_ID_Ukonceni;
    DOC_OutgoingSubstitution:           Result := OutgoingSubstitution_SwitchRule_ID_Ukonceni;
    DOC_IncomingSubstitution:           Result := IncomingSubstitution_SwitchRule_ID_Ukonceni;
    DOC_OutgoingTransformation:         Result := OutgoingTransformation_SwitchRule_ID_Ukonceni;
    DOC_IncomingTransformation:         Result := IncomingTransformation_SwitchRule_ID_Ukonceni;
  end;
end;

// Pouzito pro ukonceni PRP ve scénáři prevodu nad PRV
function PRECHOD_UKONCENI2(docTyp: String; AModule: String): String;
begin
  case docTyp of
    // ukonceni prevodky prijem pri převodu nad PRV
    // (V priprave -> Vyrizeno nebo V priprave -> K prijmu)
    DOC_IncomingTransfer:               Result := 'Y010000101';
    // ukonceni vracene vydejky v pripade, ze se zacina vyberem vydejky
    DOC_BillOfDelivery:                 Result := '4440000101';
    // prechod OV v pripade, ze se neprijalo vse
    DOC_IssuedOrder:                    Result := IssuedOrder_SwitchRule_ID_Oddeleni2;
  end;
end;

// prechod pro zmenu stavu oddeleneho dokladu s nezpracovanymi polozkami
// pokud je prazdny, nebude se prevod aplikovat
function PRECHOD_ODDELENI(docTyp: string; AModule: String): string;
begin
  case docTyp of
    DOC_ReceiptCard:                    Result := ReceiptCard_SwitchRule_ID_Oddeleni;
    DOC_BillOfDelivery:                 Result := BillOfDelivery_SwitchRule_ID_Oddeleni;
    DOC_RefundedBillOfDelivery:         Result := RefundedBillOfDelivery_SwitchRule_ID_Oddeleni;
    DOC_RefundedReceiptCard:            Result := RefundedReceiptCard_SwitchRule_ID_Oddeleni;
    DOC_OutgoingTransfer:               Result := OutgoingTransfer_SwitchRule_ID_Oddeleni;
    DOC_IncomingTransfer:               Result := IncomingTransfer_SwitchRule_ID_Oddeleni;
    DOC_ShippingList:                   Result := ShippingList_SwitchRule_ID_Oddeleni;
    DOC_RemovalList:                    Result := RemovalList_SwitchRule_ID_Oddeleni;
    DOC_MaterialDistribution:           Result := MaterialDistribution_SwitchRule_ID_Oddeleni;
    DOC_IssuedOrder:                    Result := IssuedOrder_SwitchRule_ID_Oddeleni;
    DOC_OutgoingSubstitution:           Result := OutgoingSubstitution_SwitchRule_ID_Oddeleni;
    DOC_IncomingSubstitution:           Result := IncomingSubstitution_SwitchRule_ID_Oddeleni;
    DOC_OutgoingTransformation:         Result := OutgoingTransformation_SwitchRule_ID_Oddeleni;
    DOC_IncomingTransformation:         Result := IncomingTransformation_SwitchRule_ID_Oddeleni;
    DOC_JobOrder:                       Result := JobOrder_SwitchRule_ID_Oddeleni;
  end;
end;

// Prechod pouzity pri vytvoreni volnych dokladu
function PRECHOD_VYTVORENI(docTyp: string; AModule: String): string;
begin
  case docTyp of
    DOC_ReceiptCard:                    Result := ReceiptCard_SwitchRule_ID_Vytvoreni;
    DOC_BillOfDelivery:                 Result := BillOfDelivery_SwitchRule_ID_Vytvoreni;
    DOC_RefundedBillOfDelivery:         Result := RefundedBillOfDelivery_SwitchRule_ID_Vytvoreni;
    DOC_RefundedReceiptCard:            Result := RefundedReceiptCard_SwitchRule_ID_Vytvoreni;
    DOC_OutgoingTransfer:               Result := OutgoingTransfer_SwitchRule_ID_Vytvoreni;
    DOC_IncomingTransfer:               Result := IncomingTransfer_SwitchRule_ID_Vytvoreni;
    DOC_ShippingList:                   Result := ShippingList_SwitchRule_ID_Vytvoreni;
    DOC_RemovalList:                    Result := RemovalList_SwitchRule_ID_Vytvoreni;
    DOC_MaterialDistribution:           Result := MaterialDistribution_SwitchRule_ID_Vytvoreni;
    DOC_ProductReception:               Result := ProductReception_SwitchRule_ID_Vytvoreni;
    DOC_RefundedMaterialDistribution:   Result := RefundedMaterialDistribution_SwitchRule_ID_Vytvoreni;
    DOC_ReceivedOrder:                  Result := ReceivedOrder_SwitchRule_ID_Vytvoreni;
    DOC_IssuedOrder:                    Result := IssuedOrder_SwitchRule_ID_Vytvoreni;
    DOC_OutgoingSubstitution:           Result := OutgoingSubstitution_SwitchRule_ID_Vytvoreni;
    DOC_IncomingSubstitution:           Result := IncomingSubstitution_SwitchRule_ID_Vytvoreni;
    DOC_OutgoingTransformation:         Result := OutgoingTransformation_SwitchRule_ID_Vytvoreni;
    DOC_IncomingTransformation:         Result := IncomingTransformation_SwitchRule_ID_Vytvoreni;
  end;
end;

function REPORT_VYSKLADNENI(docTyp: string; AModule: String): string;
begin
  Result := '';
  case docTyp of
    DOC_BillOfDelivery:                 Result := '';
    DOC_OutgoingTransfer:               Result := '';
    DOC_RefundedBillOfDelivery:         Result := '';
    DOC_RefundedReceiptCard:            Result := '';
    DOC_OutgoingTransfer:               Result := '';
    DOC_IncomingTransfer:               Result := '';
    DOC_ShippingList :                  Result := '';
    DOC_RemovalList :                   Result := '';
    DOC_OutgoingSubstitution:           Result := '';
    DOC_IncomingSubstitution:           Result := '';
    DOC_OutgoingTransformation:         Result := '';
    DOC_IncomingTransformation:         Result := '';
  end;
end;

// stavy skladovych dokladu (oddelene carkou - vklada se do SQL jako prava cast IN), pro ktere je mozno provest presun cele pozice
function POVOLENE_STAVY_PRESUN_CELE_POZICE(AOS: TNxCustomObjectSpace; AModule, ADocType, AUser_ID: String; AJson: TJSONSuperObject; var AReservedFirst: Boolean): String;
begin
  Result := '';
end;

// skladove pozice (oddelene carkou - vklada se do SQL jako prava cast IN), na ktere kdyz se prevadi, tak neni povoleno pouziti odblokovani pozic
function ZAKAZANE_POZICE_PRESUN_CELE_POZICE(AOS: TNxCustomObjectSpace; AModule, ADocType, AUser_ID: String; AJson: TJSONSuperObject; var ABlockedFirst: Boolean): String;
var
  mForbiddenPositionsList: TStringList;
begin
  Result := '';
end;

begin
end.