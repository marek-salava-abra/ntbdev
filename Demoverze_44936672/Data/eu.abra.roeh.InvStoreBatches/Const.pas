const
  cInDebug = True;
  cUseDebugger = true;
  cAppName = 'eu.abra.roeh.InvStoreBatches';
  cEmulDebugICS = false; // když nemám čtečku a potřebuji krokovat- nemazt importovaný soubor

  cHlInv = '1';
  cDilInv = '3';
  cRelNegaQuant = 1100150; // Relacni vazba na rozdeleni zaporneho srovnavaciho mnozstvi
  cSelSumRel = 'select sum(NUMVALUE) from Relations R where R.REL_DEF = '+IntToStr(cRelNegaQuant)+' and R.RIGHTSIDE_ID = ''%s''';

// cCentralStoreID='8200000101';
// cCentralStoreCode='2010';
 //cCentralStorageStore_Id ='MiniInvStore_Id';
// cCentralStorageStoreCode ='MiniInvStoreCode';
// cInvPrepMiniInv = 'AU20000101'; // jen pro řadu miniinventury
// cInvManMiniInv = 'AV20000101'; // jen pro řadu miniinventury
 cCountryERRBat = '00000CZ000'; // Default země pro šarži generovanou v rámci nulování skladu

// cDynSqlExportMinInv = 'OGQQA2C25JDL342N01C0CX3FCC';
 //cAgendaCLSIDInventoryOverplus = 'BP0I5SAOS3DL3ACU03KIU0CLP4';
 //cAgendaCLSIDShortFall = 'BT0I5SAOS3DL3ACU03KIU0CLP4';

// cExportMinInv = '7D10000101';
 cEXPORT_BasePath = 'c:\ics2\data\';
 cEXPORT_FileName = cEXPORT_BasePath + 'ABRDIO.TXT';
 cEXPORT_EXEMiniInv = 'c:\ics2\data\Export.bat';

 cIMPORT_EXEtoRunBefore = 'c:\ics2\data\Import.bat';
 cIMPORT_FileName = 'c:\ics2\data\ABRDIO.TXT';

begin
end.