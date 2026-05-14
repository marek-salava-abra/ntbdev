uses
  'eu.abra.PostProviders.uConstCustomScript',
  'eu.abra.PostProviders.uConstForm',
  'eu.abra.PostProviders.uConstBalikobot',
  'eu.abra.PostProviders.uLanguage';

const
  //ESHOP ABRA
  //Pro potřebu neregistrovaného zákazníka z X položek lze vypnout
  cAdrresValidateDisabled = true;

  //pro nasazení přepnout na false
  cDebug = true;

  cCrLf = #13#10;

  //neměnit!
  cOnlyValidate = true;

  cPackages_Site = 'Packages_Site';
  cLastSite = 'LastSite';
  cServiceType = 'ServiceType';
  cRelationWithIDs = 'RelationWithIDs';

  cNoneXML = 0;
  cOnlyShowXML = 1;
  cOnlyCreateFromXML = 2;
  cAllXML = 3;

  //mozne uzivatelske skripty
  cScriptNone = 0;
  cScriptAfterGetData = 1;
  cScriptAfterProviderChange = 2;
  cScriptAfterGetDataImportManager = 3;//Balíky rychle
  cScriptAfterGetDataImportManagerNonVisual = 4; //import manager například (WMS)
  cScriptGetPrinterNameHook = 5;
  cScriptAfterContentFieldChange = 6; //Po provedení změny na fieldu v contentu
  cScriptUserButton = 7; //Zakázkově přidaná akční tlačítka

  //Vazba v Relations mezi zdrojovým dokladem a odeslanou poštou
  cPDMIssuedDoc_IssuedInvoice = 1400;
  cPDMIssuedDoc_ReceivedOrder = 1431;
  cPDMIssuedDoc_BillOfDelivery = 1438;
  cPDMIssuedDoc_OutgoingTransfer  = 1443;
  cPDMIssuedDoc_ServiceDocument = 1472;

  //metoda postFile přidává XML hlavičku pokud není uveden tento parametr.
  cAddProlog = true;
  cDontAddProlog = false;
  cUseUTF8Encoding = true;
  cDontUseUTF8Encoding = false;

  //stav balíku. Implementováno pro balíkobot
  cStatusCreate = 0;//Záznam vytvořen
  cStatusExported = 1;//Exportováno
  cStatusClose = 2;//Uzavřeno, data předány přepravci
  cStatusExpedited = 3;//Expedováno
  cStatusDeleted = 4;//Smazáno

  //Extra nastavení
  cExtrasSetingFileName = 'GlobProvider.ini';



  //Volba na dokumentu
  cManifestDocument = 2; //= cTransportListDocument
  cTransportListDocument = 2; //= cManifestDocument
  cRelDefDocument = 668;

  //tisk
  cPrint = 1; //přadávací protokol
  cPrintLabel = 0; //štítky

  //Balík rychle
  //Předaný BO bude hlavním, předaný list bude pouze napojen. Napřklad více dokladů na jednu adresu.
  cOnePeaceWithConectedListDoc = 0;
  //Předaný BO bude vytvořen s početem balíku 1 pro předaný BO. List se ignoruje. Používá se pro hromadné akce
  cWithOneParcelPerDoc = 1;
begin
end.