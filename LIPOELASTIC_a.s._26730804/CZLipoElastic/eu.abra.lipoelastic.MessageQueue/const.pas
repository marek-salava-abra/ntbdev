const
  cMQ_BeautifyJSON = True;
  cMQ_BOD_DocQueue_ID_DLDS = '~000000V02';
  cMQ_BOD_PMState_ID_VYRIZENO = 'SDDEF00000';
  cMQ_BOD_PMState_ID_SYNC_READY = '~000000801';
  cMQ_BOD_PMState_ID_ZPRACOVAVA_SE = '~000000701';
  cMQ_BOD_PMState_ID_SYNC_OK = '~000000305';
  cMQ_API_MessageQueue_Endpoint = 'MessageQueue';
  cMQ_SourceInstanceKey = 'CZ';
  cRO_DocQueue_ID_OPDS = '~000000V03';
  cMQ_II_DocQueue_ID_FVE = '2F10000101';

  // Procesní stavy objednávky přijaté v CZ.
  cMQ_RO_PMState_ID_ZPRACOVAVA_SE = '~000000902';
  cMQ_RO_PMState_ID_VYFAKTUROVANA = '~000000903';
  cMQ_RO_PMState_ID_STORNOVANA = '~000000904';

  // Cílové stavy zdrojové OP v SK; dočasné mapování podle instance.
  // Po vytvoření OP v CZ:
  cMQ_SK_RO_PMState_ID_OBJEDNANA_V_CZ = '~S00000404';
  // cMQ_RO_PMState_ID_ZPRACOVAVA_SE -> SK:
  cMQ_SK_RO_PMState_ID_ZPRACOVAVA_SE = '~S00000405';
  // cMQ_RO_PMState_ID_VYFAKTUROVANA -> SK:
  cMQ_SK_RO_PMState_ID_VYFAKTUROVANA = '~S00000406';
  // cMQ_RO_PMState_ID_STORNOVANA -> SK:
  cMQ_SK_RO_PMState_ID_STORNOVANA = '~S00000408';

  // A country/instance key is inserted between the prefix and the suffix.
  // Example for "SK":
  //   DEV_LIPOELASTIC_SK_URL
  //   DEV_LIPOELASTIC_SK_AUTHENTICATION
  cAPI_SECURESTORE_KEY_PREFIX = 'LIPOELASTIC_';
  cAPI_URL_SECURESTORE_KEY_SUFFIX = '_URL';
  cAPI_AUTHENTICATION_SECURESTORE_KEY_SUFFIX = '_AUTHENTICATION';

  cAPI_SCRIPT_PATH = 'script/eu.abra.alec.Lipoelastic.API_Sync/lib/';
  cServiceName = 'DEV AbraGen CZ';

  cPrinterNameA4 = '"T69"';
  cPrinterNameLabel = '"T88"';

begin
end.
