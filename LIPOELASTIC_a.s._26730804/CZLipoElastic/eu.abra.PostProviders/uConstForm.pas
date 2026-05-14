const
  //prvky na formu

  //datasource pro řádky
  cdsPackagesData = 'dsPackagesData';
  //grid pro řádky
  cgrdPackagesData = 'grdPackagesData';
  //datasource pro hlavičkové údaje
  cdsHeaderData = 'dsHeaderData';

  //datasource pro content (váhy, rozměry, adr)
  cdsContent = 'dsContent';
  //grid pro content
  cgrdContent = 'grdContent';

  cOptionalUseBusObjects = 0; //zakazka, obchodni pripad a projekt nepovinne pouzivat
  cUseBusObjects = 1; //zakazka, obchodni pripad a projekt povinne pouzivat
  cDontUseBusObjects = 2; //zakazka, obchodni pripad a projekt nepouzivat

  cedDocQueue = 'edDocQueue';
  cedPeriod = 'edPeriod';
  cedDate = 'edDate';
  cedPDMUser = 'edPDMUser';
  cedDivision = 'edDivision';
  cedPDMProvider = 'edPDMProvider';
  cedStore = 'edStore';
  cedBankAccount = 'edBankAccount';
  cedBusOrder = 'edBusOrder';
  cedBusTransaction = 'edBusTransaction';
  cedBusProject = 'edBusProject';

  clblServiceType = 'lblServiceType';
  clblDocQueue = 'lblDocQueue';
  clblPeriod = 'lblPeriod';
  clblDate = 'lblDate';
  clblPDMUser = 'lblPDMUser';
  clblDivision = 'lblDivision';
  clblPDMProvider = 'lblPDMProvider';
  clblStore = 'lblStore';
  clblBankAccount = 'lblBankAccount';
  clblBusOrder = 'lblBusOrder';
  clblBusTransaction = 'lblBusTransaction';
  clblBusProject = 'lblBusProject';

  clcbDocQueue = 'lcbDocQueue';
  clcbPeriod = 'lcbPeriod';

  clcbPDMUser = 'lcbPDMUser';
  clcbDivision = 'lcbDivision';
  clcbPDMProvider = 'lcbPDMProvider';
  clcbStore = 'lcbStore';
  clcbBankAccount = 'lcbBankAccount';
  clcbBusOrder = 'lcbBusOrder';
  clcbBusTransaction = 'lcbBusTransaction';
  clcbBusProject = 'lcbBusProject';

  cTop = 15;
  cLeft = 10;
  cLeftLcb = 190;//190
  cPlusTop = 26;
  cPlusLeft = 10;
  cMinusEd = -3;
  cMinusLcb = -2;
  cLblWidth = 70;
  cEdWidth = 100;
  cLcbWidth = 100;
  cLeftCol = 0;
  cLeftCol2 = 380;

  //rozložení layoutu dle firmy nebo dle osoby
  cLayoutCount = 2;
  cLayoutFirm = 0;
  cLayoutPerson = 1;

  //Rozdělení dle običejného balíku nebo Manipulační jednotky pro velké zásilky
  cLayoutContentCount = 2;
  cLayoutPackage = 0;
  cLayoutCargo = 1;

  //sloupce gridu
  ccolPostProviderRow = 'colPostProviderRow';
  ccolDisplayNumber = 'colDisplayNumber';
  ccolVarSymbol = 'colVarSymbol';
  ccolAmount = 'colAmount';
  ccolCount = 'colCount';
  ccolExistCount = 'colExistCount';
  ccolContentType = 'colContentType';
  ccolCashOnDelivery = 'colCashOnDelivery';
  ccolTargetAddressType = 'colTargetAddressType';

  ccolAdr = 'colAdr';
  ccolAdrName = ccolAdr+'Name';
  ccolAdrStreet = ccolAdr+'Street';
  ccolAdrCity = ccolAdr+'City';
  ccolAdrPostCode = ccolAdr+'PostCode';
  ccolAdrCountryCode = ccolAdr+'CountryCode';
  ccolAdrPhoneNumber = ccolAdr+'PhoneNumber';

  cSen = '_Sen';
  ccolTargetAddressTypeSen = 'colTargetAddressType'+cSen;
  ccolAdrNameSen = ccolAdr+'Name'+cSen;
  ccolAdrStreetSen = ccolAdr+'Street'+cSen;
  ccolAdrCitySen = ccolAdr+'City'+cSen;
  ccolAdrPostCodeSen = ccolAdr+'PostCode'+cSen;
  ccolAdrCountryCodeSen = ccolAdr+'CountryCode'+cSen;
  ccolAdrPhoneNumberSen = ccolAdr+'PhoneNumber'+cSen;

  ccolWeight = 'colWeight';
  ccolWeightUnit = 'colWeightUnit';
  ccolServiceType = 'colServiceType';
  ccolInsurance = 'colInsurance';
  ccolNoteForDriver = 'colNoteForDriver';
  ccolCurrency = 'colCurrency';
  ccolPersonName = 'colPersonName';
  ccolPersonNameSen = 'colPersonName'+cSen;
  ccolSenPersonName = 'colSenPersonName';
  ccolFirmBankAccount = 'colFirmBankAccount';
  ccolManipulationUnit = 'colManipulationUnit';
  ccolCountMUnit = 'colCountMUnit';

  ccolCountMUnitBack = 'colCountMUnitBack';
  ccolManipulationUnitNoteBack = 'colManipulationUnitNoteBack';

  ccolParentID = 'colParentID';
  ccolWidth = 'colWidth';
  ccolHeight = 'colHeight';
  ccolLength = 'colLength';
  ccolVolume = 'colVolume';
  ccolContent = 'colContent';
  ccolADRUnit = 'colADRUnit';
  ccolParentName = 'colParentName';
  ccolPosindex = 'colPosindex';

  ccolPickupDate = 'colPickupDate';
  ccolDeliveryDate = 'colDeliveryDate';
  ccolPickupTimeFrom = 'colPickupTimeFrom';
  ccolDeliveryTimeFrom = 'colDeliveryTimeFrom';
  ccolPickupTimeTo = 'colPickupTimeTo';
  ccolDeliveryTimeTo = 'colDeliveryTimeTo';


  //pro colTargetAddressType
  cFromFirm = 0;
  cFromFirmStr = 'Firmy';
  cFromFirmOffice = 1;
  cFromFirmOfficeStr = 'Provozovny';
  cFromPerson = 2;
  cFromPersonStr = 'Osoby';

  //pro colWeightUnit
  cUnitg = 0;
  cUnitgStr = 'g';
  cUnitkg = 1;
  cUnitkgStr = 'kg';
  cUnitt = 2;
  cUnittStr = 't';

  cCapacityUnitml = 'ml';
  cCapacityUnitcl = 'cl';
  cCapacityUnitdl = 'dl';
  cCapacityUnitl = 'l';
  cCapacityUnithl = 'hl';
  cCapacityUnitcm3 = 'cm3';
  cCapacityUnitmm3 = 'dm3';
  cCapacityUnitm3 = 'm3';

  // Objemové jednotky seřazené dle objemu od nejmenší
  cCapacityUnits = [
    cCapacityUnitml,
    cCapacityUnitl,
    cCapacityUnitm3,
    cCapacityUnitcl,
    cCapacityUnitdl,
    cCapacityUnithl,
    cCapacityUnitcm3,
    cCapacityUnitmm3
  ];

  // Převodní vztah mezi m3 a danou jednotkou.
  cCapacityUnitFromm3 = [
    1000000, // ml
    1000,    // l
    1,       // m3
    100000,  // cl
    10000,   // dl
    10,      // hl
    1000000, // cm3
    1000     // dm3
  ];

begin
end.