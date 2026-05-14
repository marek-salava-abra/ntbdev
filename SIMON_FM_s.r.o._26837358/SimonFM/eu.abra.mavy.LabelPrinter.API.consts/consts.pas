const
  cURL = 'http://BSERVER:5000';
  cClient_ID = 'labelprinter';
  cClient_Secret = 'ZdaWamph603tWZJsHTGtRI8g8gSQaIEpfQ==';
  cGrant_type = 'client_credentials';
  cScope = 'lp_api_full';

  cPDM_DocQueue_OID = '6R30000101';                   // řada dokladů odeslané pošty
  cDefaultState_ID = '80S5000101';                     // Výchozí stav zásilky (0 - Před odesláním)
  cDefaultUser = '';                             // výchozí uživatel pro odeslání do LP (pokud není vyplněn na uživateli)
  cPDMPriceListID =  'KC00000000';                    // Ceník pošty - nevyužíváme, ale je nutné ho vyplnit při importu přepravců.
  cDeliveryPointFieldName = 'X_LP_DeliveryPointID';   // název položky, ze které se bude načítat ID odběrného místa ze zdrojových dokladů (musí být na všech zdrojových dokladech, ze kterých se odesílají balíky!)
  cCODInvoiceFieldName = 'NotPaidAmount';             // z jaké položky čerpat částku dobírky u FV (nezaplacená částka nebo celková částka) - Amount, NotPaidAmount
  cSendBankAccount = False;                             // odesílat číslo bankovního účtu pro výplatu dobírky? Pokud ne, LabelPrinter doplní výchozí pro daného přepravce

  cSendStoreCards = True;                             // Odesílat obsah dokladu (skladové karty) pro kontrolu v LP, včetně různých jednotek
  cAddStoreCardsCode = True;                          // při odesílání skladových karet přidat jednu alternativu pro kód karty místo EAN. Aby bylo možné dohledat při kontrole i karty bez EAN pro výchozí jednotku

  cUseWeight = True;                                  // odesílat váhu ze zdrojových dokladů z položku uložené v cWeightFieldName
  cWeightFieldName = 'Weight';                       // slouží pro volbu pole, ze kterého se bude odesílat váha (musí být na všech zdrojových dokladech, ze kterých se odesílají balíky!)

  cSendInvoicePDF = False;
  cInvoiceDynSourceID = '40SBPEINEFD13ACM03KIU0CLP4'; // DynSQL zdroj pro sestavu, pokud je parametr cSendInvoicePDF = true
  cInvoiceReportID = 'W400000001';                    // ID Tiskové sestavy, pokud je paremetr cSendInvoicePDF = true

  cAutoSendFromInvoice = False;                        // po uložení FV se automaticky pokusí vytvořit PDM a odeslat do LP

  cLoaderMode = True;                                 // LP uložíi chybné zásilky. Chyby pak zobrazí u sebe. Toto nastavení je vhodné zejména pro automatické odesílání do LP přes WS nebo API

  cInsuredTolerance = 0;                               // nastavení tolerance dobírky, pokud je částka nižší než cInsuredTolerance, tak se neodesílá jako dobírka. Slouží pro toleranci nezaplacené částky
  cGetInvoiceDataForOrders = false;                     // pokud se odesílá do LP z objednávky a za předpokladu, že už existuje faktura, dohledám si z ní částku dobírky a variabilní symbol

  cDaysOffSetForUpdate = 30;                           // počet dní zpětně, pro které se zpětně synchronizují data z LP (změna stavu, datum doručení apod...)

  cSender_ID = '';                            //ID uživatele modulu evidence pošty (pro jednodušší administraci jde zvolit jeden, nemusí se pro každého uživatele přidávat oprávnění)
begin
end.