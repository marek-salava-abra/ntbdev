//toto je zkopírováno z eu.abra.PostProviders.uConstCustomScript
//neměnit

//tuto knihovnu nakopirovat do eu.abra.PostProviders.extras.uConst
const

  //odpovídá X_PD_Driver
  cDriverNone = 0;
 (*  //Geis Parcel
  cDriverGeisParcel = 1;
  //PPL
  cDriverPPL = 2;
  //TopTrans
  cDriverTopTrans = 3;
  //DPD - rezervace
  cDriverDPD = 4;

  //InTime - rezervace
  cDriverInTime = 6;
  //Balikobot
  *)
  //Česká pošta
  cDriverCP = 5;
  cDriverBalikobot = 7;

  //Práva k číselníkům
  cSecurityMask_Store = 2;
  cSecurityMask_Division = 2;
  cSecurityMask_BankAccount = 2;

  //maximální počet vytvořených balíků a maximální počet druhů služeb
  //měnit opatrně a ověřit grid
  cMaxCount = 15;

  //Jenom TopTrans pro balíkobot má 3 jinak všichni jednu
  cMaxCountManipulationUnit = 3;

  //počet druhů obalů pro TopTrans
  cMaxTopTransCount = 3;

  cServiceTypeMaxCount = 4;

  //typ dobirka v typech plateb
  cCODPaymentKind = 3;

  //Fieldy datasetu rows
  //ID zdrojového dokladu
  cFDID = 'ID';
  //složené číslo zdrojového dokladu
  cFDDisplayNumber = 'DisplayNumber';
  //označení - u FV variabilní symbol, u DL a OP číslo dokladu
  cFDVarSymbol = 'VarSymbol';
  //částka z dokladu má smysl u OP a FV
  cFDAmount = 'Amount';
  //počet balíků, resp. počet kusů jako suma počtu jednotlivých obalů u TopTrans
  cFDCount = 'Count';
  //druh obsahu
  cFDContentType = 'ContentType';
  //dobírečně v měně zdrojového dokladu
  cFDCashOnDelivery = 'CashOnDelivery';
  //Prefix na sendera
  cFDSen = '_Sen';
  //odkud se má vzít adresa hodnoty 0/1/2 = ze sídla, provozovny, osoby na zdrojovém dokladu
  cFDTargetAddressType = 'TargetAddressType';
  cFDTargetAddressTypeSen = 'TargetAddressType'+cFDSen;
  //Firm_ID / Firma
  cFDFirm_ID = 'Firm_ID';
  cFDFirm_IDSen = 'Firm_ID'+cFDSen;
  //FirmOffice_ID / Provozovna
  cFDFirmOffice_ID = 'FirmOffice_ID';
  cFDFirmOffice_IDSen = 'FirmOffice_ID'+cFDSen;
  //Person_ID / Osoba
  cFDPerson_ID = 'Person_ID';
  cFDPerson_IDSen = 'Person_ID'+cFDSen;
  //název firmy / jméno a příjmení osoby
  cFDAdrName = 'AdrName';
  cFDAdrNameSen = 'AdrName'+cFDSen;
  //ulice
  cFDAdrStreet = 'AdrStreet';
  cFDAdrStreetSen = 'AdrStreet'+cFDSen;
  //město
  cFDAdrCity = 'AdrCity';
  cFDAdrCitySen = 'AdrCity'+cFDSen;
  //PSČ
  cFDAdrPostCode = 'AdrPostCode';
  cFDAdrPostCodeSen = 'AdrPostCode'+cFDSen;
  //kód země
  cFDAdrCountryCode = 'AdrCountryCode';
  cFDAdrCountryCodeSen = 'AdrCountryCode'+cFDSen;
  //telefon
  cFDAdrPhoneNumber = 'AdrPhoneNumber';
  cFDAdrPhoneNumberSen = 'AdrPhoneNumber'+cFDSen;
  //počet již existujících balíků - pokud je > 0 tak se jinak podbarví řádek gridu
  cFDExistCount = 'ExistCount';
  //hmotnost jednotlivých balíků - jméno fieldu v datasetu je doplněno o číslo 0 až cMaxCount-1
  cFDWeight = 'Weight';
  //jednotka hmotnosti jednotlivých balíků - jméno fieldu v datasetu je doplněno o číslo 0 až cMaxCount-1
  cFDWeightUnit = 'WeightUnit';
  //hmotnost ze zdrojového dokladu
  cFDTotalWeight = 'TotalWeight';
  //jednotka hmotnosti ze zdrojového dokladu
  cFDTotalWeightUnit = 'TotalWeightUnit';
  //doplňkové služby - jméno fieldu v datasetu je doplněno o číslo 0 až cServiceTypeMaxCount-1
  cFDPDMServiceType = 'PDMServiceType';
  //hodnota v měně zdrojového dokladu
  cFDInsurance = 'Insurance';
  //textová poznámka, někteří poskytovatelé umožňují tisk na svých sestavách
  cFDNoteForDriver = 'NoteForDriver';
  //typ zdrojového dokladu
  cFDDocumentType = 'DocumentType';
  //typ platby ze zdrojového dokladu
  cFDPaymentKind = 'PaymentKind';
  //měna ze zdrojového dokladu
  cFDCurrency = 'Currency';
  cFDPersonName = 'PersonName';
  cFDPersonNameSen ='PersonName'+cFDSen;
  //cizí účet
  cFDFirmBankAccount = 'FirmBankAccount';
  //obal - jméno fieldu v datasetu je doplněno o číslo 0 až cMaxTopTransCount-1
  cFDContainer = 'Container';
  //Poštovní poskytovatel na řádku datasetu agendy balíky.
  cFDPostProviderRow = 'PDMProviderDriverRow';
  //Manipulační jednotka jako obal jednotlivých balíků - jméno fieldu v datasetu je doplněno o číslo 0 až cMaxCount-1
  cFDManipulationUnit = 'ManipulationUnit';
  //Počet manipulačních jednotek jednotlivých balíků - jméno fieldu v datasetu je doplněno o číslo 0 až cMaxCount-1
  cFDCountMUnit = 'CountMUnit';
  //Popis vratných obalů pro Balíkobot TopTrans. Jedná se o popis slovní nad rámec manipulačních jednotek. Specifická forma přepravy nadrozměrných zásilek
  cFDMUnitNoteBack = 'MUnitNoteBack';
  //Počet vracených kusů celkem k vrácení
  cFDManipulationUnitCountBack = 'ManipulationUnitCountBack';


  //Fieldy datasetu header
  //řada dokladů odeslané pošty
  cFDDocQueue = 'DocQueue';
  //středisko
  cFDPeriod = 'Period';
  //datum
  cFDDate = 'Date';
  //uživatel z modulu Evidence pošty
  cFDPDMUser = 'PDMUser';
  //středisko
  cFDDivision = 'Division';
  //poštovní poskytovatel
  cFDPDMProvider = 'PDMProvider';
  //bankovní účet firmy odesílající balíky - použito pro zaslání vybrané dobírky dopdavcem
  cFDBankAccount = 'BankAccount';
  //zakázka
  cFDBusOrder = 'BusOrder';
  //obchodní případ
  cFDBusTransaction = 'BusTransaction';
  //projekt - nyní není na BO odeslané pošty použit
  cFDBusProject = 'BusProject';
  //driver poštovního poskytovatele - mělo by korespondovat s nastavením položky cFDPDMProvider
  //je to celočíselná hodnota viz X_PD_Driver
  cFDPDMProviderDriver = 'PDMProviderDriver';
  //sklad nakládky
  cFDStore = 'Store';
  //ADD, B2A, B2C
  cFDServiceType = 'ServiceType';

  //ServiceType
  cBBServiceType_ADD = 0; //ADD
  cBBServiceType_B2A = 1; //B2A
  cBBServiceType_B2C = 2; //B2C

  //Play ELE a speciál pro více tech. čísel s jedním dopravcem X_PD_Setting_ID
  cFDSetting = 'FDSetting';

  //ID dokladu (stejného typu) které mají být připojena k odeslané poště.
  cFDRelationWithIDs = 'FDRelationWithIDs';

  //DocumentType
  cDocumentTypeIssuedInvoice = '03';
  cDocumentTypeReceivedOrder = 'RO';
  cDocumentTypeBillOfDelivery = '21';
  cDocumentTypeOutgoingTransfer = '22';
  cDocumentTypeServiceDocument = 'SL';

  cFDParentID = 'FDParentID';
  cFDWidth = 'FDWidth';
  cFDHeight = 'FDHeight';
  cFDLength = 'FDLength';
  cFDVolume = 'FDVolume';
  //Textově popsaný obsah, nebo v případě exportu mimo EU může být zakázkově JSON s detailem obsahu.
  cFDContent = 'FDContent';
  cFDADRUnit = 'FDADRUnit';
  cFDPosindex = 'FDPosindex';

  //Liftágo
  cFDPickupDate = 'FDPickupDate';
  cFDDeliveryDate = 'FDDeliveryDate';
  cFDPickupTimeFrom = 'FDPickupTimeFrom';
  cFDPickupTimeTo = 'FDPickupTimeTo';
  cFDDeliveryTimeFrom = 'FDDeliveryTimeFrom';
  cFDDeliveryTimeTo = 'FDDeliveryTimeTo';

begin
end.