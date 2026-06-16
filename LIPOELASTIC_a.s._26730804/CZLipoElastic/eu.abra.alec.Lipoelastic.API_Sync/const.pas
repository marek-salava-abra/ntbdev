const
  cURL='http://api.abra-sk.prod.ad.lipoelastic.com:83/SK_LipoElastic/';    //ostrá data
  cServiceName='AbraGen CZ';                     //ostrá data
  //cURL='http://10.5.5.96:810/DEV_SK_Lipoelastic/';    //test data
  //cServiceName='AbraGen CZ - DEV';                     //test data
  cAuthorization = 'YWJyYV9jel9zeW5jOlYyZjVWeFlaM1AwYg';

  cStateToBeSynced = '~000000303';
  cStateToBeSynced_Sales = '~000000601';
  cStateToBeSynced_Transfers = '~000000602';
  cStateToBeSynced_AT = '~000000701';
  cStateSyncOK = '~000000305';
  cStateSyncError = '~000000306';
  cStateFinished = 'SDDEF00000';


  cAPI_SK = 0;
  cAPI_DE = 1;
  cAPI_AT = 2;

  cReceiptCardCodeFieldName = 'U_SK_ReceiptCardCode';
  cStoreCodeFieldName = 'U_SK_StoreCode';

  cURLDE='http://10.5.5.96:811/Data_DE/';    //data DE
  cAuthorizationDE = 'YWJyYV9kZV9zeW5jOnF1NEZpRXdUeW1Idw';

  //cURLAT='http://10.5.5.96:811/Data_AT/';    //data AT
  cURLAT='http://10.201.194.12:811/Data_AT/';  //data AT cloud
  cAuthorizationAT = 'YWJyYV9hdF9zeW5jOnF1NEZpRXdUeW1Idw';

  cSQL_X_Aktivni = ' AND X_Aktivni = ''A'' ';

begin
end.