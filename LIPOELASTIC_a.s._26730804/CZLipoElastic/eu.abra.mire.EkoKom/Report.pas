                                                  uses
  'eu.abra.mire.EkoKom.Settings',
  'eu.abra.mire.EkoKom.Lib',
  'eu.abra.mire.EkoKom.Progress';

const cViewSQL =
'(' +
'SELECT ' +
'  CASE ' +
'    WHEN sd.Country_ID = (SELECT Country_ID FROM GlobData) AND sd.X_EKO_UzavrenaDohoda = ''N'' THEN X_EKO_ZpoplatneniObalu ' +
'    WHEN sd.Country_ID = (SELECT Country_ID FROM GlobData) AND sd.X_EKO_UzavrenaDohoda = ''A'' THEN 2 ' +
'    ELSE 10 ' +
'  END AS X_EKO_ZpoplatneniObalu, ' +
'  X_EKO_TypObchodu, ' +
'  X_EKO_ZpusobUziti, ' +
'  X_EKO_ZpusobUvedeni, ' +
'  X_EKO_PuvodMaterialu, ' +
'  X_EKO_MaterialKompozitu, ' +
'  X_EKO_OpakovanePouzivany, ' +
'  X_EKO_LitteringovyObal, ' +
'  scc.X_EKO_MaterialObalu, ' +
'  scc.X_EKO_SkupinaMaterialu, ' +
'  scc.X_EKO_BarvaObalu, ' +
'  scc.X_EKO_ObsahujeNapoje, ' +
'  %s ' +
'  cast ((cast (df.X_EKO_Hmotnost * ' +
'  case '+
'  when (df.X_EKO_UnitQuantity > 0) then df.X_EKO_UnitQuantity '+
'  when (df.X_EKO_Quantity > 0) and (df.X_EKO_UnitRate > 0) then cast(df.X_EKO_Quantity as numeric(15,6)) / df.X_EKO_UnitRate'+
'  else 0 end'+
'  as numeric(15,6)) '+
'  * cast ((sd2.Quantity / su.UnitRate) as numeric(15, 3))) /1000/1000 as Numeric(15, 6)) as Hmotnost, ' +
'  (sd2.Quantity / su.UnitRate) as Mnozstvi, ' +
'  sd2.StoreCard_ID, ' +
'  sd.ID, ' +
'  sd.DocDate$DATE, ' +
'  sd.DocumentType, ' +
'  sc.Name as StoreCardName, ' +
'  sc.Code as StoreCardCode, ' +
'  sd.OrdNumber, ' +
'  sd.Period_ID, ' +
'  sd.DocQueue_ID, ' +
'  scc.code as PackageCode, ' +
'  scc.name as PackageName ' +
'FROM StoreDocuments2 sd2 ' +
'JOIN StoreDocuments sd ON sd.ID = sd2.Parent_ID AND sd.DocumentType IN (21, 23, 26) ' +
'JOIN DocQueues DQ ON DQ.ID = SD.DocQueue_ID AND (DQ.X_IncludeEkoKom = ''A'') '+            //ALEC
'JOIN StoreCards sc ON sc.ID = sd2.StoreCard_ID ' +
'JOIN DefRollData df ON df.hidden = ''N'' AND df.CLSID = ''3DROIEGQRFMOH4ZT4I53BZCXKO'' ' +
'  AND df.X_EKO_StoreCard_ID = sd2.StoreCard_ID ' +
'  AND ' +
'  ( ' +
'    (df.X_EKO_StoreCardUnit = sd2.QUnit) ' +
'    or ' +
'    ( ' +
'      df.X_EKO_StoreCardUnit <> sd2.QUnit ' +
'      AND (SELECT COALESCE(MAX(dfs.Name), ''A'') FROM DefRollData dfs WHERE dfs.code = ''' + cSettings2Code + ''' AND dfs.CLSID = ''3DROIEGQRFMOH4ZT4I53BZCXKO'') <> ''N'' ' +
'      AND NOT EXISTS ' +
'      ( ' +
'        SELECT ID ' +
'        FROM DefRollData dfe ' +
'        WHERE dfe.hidden = ''N'' AND dfe.CLSID = ''3DROIEGQRFMOH4ZT4I53BZCXKO'' ' +
'          AND dfe.X_EKO_StoreCard_ID = sd2.StoreCard_ID ' +
'          AND dfe.X_EKO_StoreCardUnit = sd2.QUnit ' +
'          AND dfe.X_EKO_ContainerStoreCard_ID = df.X_EKO_ContainerStoreCard_ID ' +
'      ) ' +
'      AND df.X_EKO_StoreCardUnit = sc.MainUnitCode ' +
'    ) ' +
'  ) ' +
'JOIN StoreUnits su ON su.Parent_ID = sc.ID AND su.Code = df.X_EKO_StoreCardUnit ' +
'JOIN StoreCards scc ON scc.ID = df.X_EKO_ContainerStoreCard_ID ' +
') SRC ';

const
  cViewSQL2 = 'scc.X_EKO_VyrazTypObchodu,';
  cViewSQL2ORA = 'to_char(scc.X_EKO_VyrazTypObchodu) as X_EKO_VyrazTypObchodu,';

  cStatsTypeOstatni = 0;
  cStatsTypePaletyEUR = 1;
  cStatsTypePaletyProste = 2;
  cStatsTypePaletyProsteJednorazove = 3;
  cStatsTypeNapojoveKartony = 4;

  cTypObchoduObchodni = 0;
  cTypObchoduPrumyslove = 1;
  cTypObchoduVyhodnotit = 2;

  cUzitiProdejni = 0;
  cUzitiSkupinove = 1;
  cUzitiPrepravni = 2;

  cUvedeniVyrobene = 0;
  cUvedeniImportovane = 1;
  cUvedeniNakoupene = 2;

  cZpoplatneniZpoplatneny = 0;
  cZpoplatneniPredplaceny = 1;
  cZpoplatneniNeplaceny = 2;
  cZpoplatneniPuvodniExport = 3;
  cZpoplatneniExport = 10;

  cPuvodMaterialuPrimarni = 0;
  cPuvodMaterialuRecyklat = 1;

  cBarvaBarevne = 0;
  cBarvaTransparentni = 1;
  cBarvaPruhledneBarevnéPET = 2;
  cBarvaNepruhledneBarevnePET = 3;
  cBarvaKompozitniSklo = 4;

  cSkupinaMekkeFlexibilní = 0;
  cSkupinaPevnePevneDuteDo3L = 1;
  cSkupinaPevneDuteNad3L = 2;

  cLitteringovyObalNe = 0;
  cLitteringovyObalNadobyNaNapoje = 1;
  cLitteringovyObalSackyABaleniPotraviny = 2;
  cLitteringovyObalNapojoveKelimkyPlast = 3;
  cLitteringovyObalNapojoveKelimky = 4;
  cLitteringovyObalNadobyNaPotravinyPlast = 5;
  cLitteringovyObalNadobyNaPotraviny = 6;
  cLitteringovyObalPlastoveTasky10_50 = 7;
  cLitteringovyObalPlastoveTasky15 = 8;

  cRowValueKontroly = 'Kontola KOMPOZITY SOUČET 1';
  cSheetKontroly = 2;
  cSheetKontrolyName = 'KONTROLY';
  cSheetUvod = 4;
  cSheetJ1_1A = 5;
  cSheetJ1_1B = 6;
  cSheetJ1_1K = 7;
  cSheetJ1_2A = 8;
  cSheetJ1_2B = 9;
  cSheetJ1_2K = 10;
  cSheetJ1_3 = 11;
  cSheetJ1_3K = 12;
  cSheetJ2 = 13;
  cSheetJ3 = 14;
  cSheetJ4 = 15;
  cSheetL = 16;
  cSheetO1_1A = 17;
  cSheetO1_1B = 18;
  cSheetO1_1K = 19;
  cSheetO1_2A = 20;
  cSheetO1_2B = 21;
  cSheetO1_2K = 22;
  cSheetO1_3 = 23;
  cSheetO1_3K = 24;
  cSheetO2 = 25;
  cSheetO3 = 26;
  cSheetO4 = 27;
  cSheetS1 = 28;
  cSheetS2 = 29;
  cSheetS3 = 30;

  cSeparatorCSV = ';';
  cCharAlternative = ',';
var
  gStart : TDateTime;
  gEnd : TDateTime;
  gPeriodCondition : string;

function GetSheetName(aSheet: Integer): String;
begin
  Result := '-';
  case ASheet of
  cSheetJ1_1A:
    Result := 'J1_1A';
  cSheetJ1_1B:
    Result := 'J1_1B';
  cSheetJ1_1K:
    Result := 'J1_1K';
  cSheetJ1_2A:
    Result := 'J1_2A';
  cSheetJ1_2B:
    Result := 'J1_2B';
  cSheetJ1_2K:
    Result := 'J1_2K';
  cSheetJ1_3:
    Result := 'J1_3';
  cSheetJ1_3K:
    Result := 'J1_3K';
  cSheetJ2:
    Result := 'J2';
  cSheetJ3:
    Result := 'J3';
  cSheetJ4:
    Result := 'J4';
  cSheetO1_1A:
    Result := 'O1_1A';
  cSheetO1_1B:
    Result := 'O1_1B';
  cSheetO1_1K:
    Result := 'O1_1K';
  cSheetO1_2A:
    Result := 'O1_2A';
  cSheetO1_2B:
    Result := 'O1_2B';
  cSheetO1_2K:
    Result := 'O1_2K';
  cSheetO1_3:
    Result := 'O1_3';
  cSheetO1_3K:
    Result := 'O1_3K';
  cSheetO2:
    Result := 'O2';
  cSheetO3:
    Result := 'O3';
  cSheetO4:
    Result := 'O4';
  cSheetS1:
    Result := 'S1';
  cSheetS2:
    Result := 'S2';
  cSheetS3:
    Result := 'S3';
  cSheetL:
    Result := 'L';
  end;
end;
procedure FillQReportUngrouped(ASite: TSiteForm; ASpace: TNxCustomObjectSpace; AExcel: Variant; AOutputDoc: TStrings; AIsExcel: Boolean);
var
  mSheet : Variant;
  mQuarter : Integer;
  mYear : Integer;
  mMonth: Integer;
begin
  ProgressInit(ASite, 'Příprava zdrojových dat pro kontrolu...', 6);
  try
    ProgressSetPos(0);
    mYear := yearof(date);
    mMonth := monthof(date);
    mQuarter := trunc((mMonth - 1) / 3.0);
    if mMonth < 4 then
    begin
      mYear := mYear - 1;
      mQuarter := 4;
    end;

    mYear := StrToInt(InputBox('Zadání období', 'Zadejte rok:',inttostr(mYear)));
    mQuarter := StrToInt(InputBox('Zadání období', 'Zadejte čtvrtletí:', inttostr(mQuarter)));
    gStart := GetStartDate(mQuarter, mYear);
    gEnd := GetEndDate(mQuarter, mYear);
    gPeriodCondition :=
      ' WHERE DocDate$DATE >= ' + NxFloatToIBStr(gStart) +
      ' AND DocDate$DATE <= ' + NxFloatToIBStr(gEnd);
    InitSettings(ASpace);
    ProgressSetPos(1);
    ProgressDispose();
    ProgressInit(ASite, 'Export zdrojových dat výkazu...', 6);
    ProgressSetPos(3);
    FillUngroupedData(ASpace, AExcel, AOutputDoc, AIsExcel);
    ProgressSetPos(4);
    ProgressSetPos(5);
    ProgressSetPos(6);
  finally
    ProgressDispose();
  end;

end;

procedure FillQReport(ASite: TSiteForm; ASpace: TNxCustomObjectSpace; AExcel: Variant);
var
  mSheet : Variant;
  mQuarter : Integer;
  mYear : Integer;
begin

  ProgressInit(ASite, 'Příprava výkazu...', 24);

  try
    ProgressSetPos(0);

    if not GetCorrectSheetOrder(AExcel) then
    begin
      ProgressDispose();
      NxShowSimpleMessage('Byla zvolena nekompatabilní verze výkazu EkoKom.' + #13#10 +
      'Vyplnění výkazu bylo přerušeno.', ASite);
      exit;
    end;

    mQuarter := GetQuarter(AExcel);
    mYear := GetYear(AExcel);
    gStart := GetStartDate(mQuarter, mYear);
    gEnd := GetEndDate(mQuarter, mYear);
    gPeriodCondition :=
      ' WHERE DocDate$DATE >= ' + NxFloatToIBStr(gStart) +
      ' AND DocDate$DATE <= ' + NxFloatToIBStr(gEnd);
    if(mYear < 2021) then
    begin
      ProgressDispose();
      NxShowSimpleMessage('Byla zvolena stará verze výkazu EkoKom.' + #13#10 +
      'Prosím, stáhněte aktuální verzi výkazu EkoKom.' + #13#10 +
      'Vyplnění výkazu bylo přerušeno.', ASite);
      exit;
    end;

    InitSettings(ASpace);
    ProgressSetPos(1);

    ClearWorkbook(AExcel);
    ProgressSetPos(24);

    ProgressDispose();
    ProgressInit(ASite, 'Vyplňování výkazu...', 4);
    FillHeader(ASpace, AExcel.ActiveWorkbook.WorkSheets[cSheetUvod]);
    ProgressSetPos(1);

    FillValues(ASpace, AExcel);
    ProgressSetPos(2);

    FillValuesForEvaluate(ASpace, AExcel);
    ProgressSetPos(3);

    AExcel.ActiveWorkbook.WorkSheets[cSheetUvod].Select();
    AExcel.ActiveWorkbook.WorkSheets[cSheetUvod].Cells[1,1].Select();
    ProgressSetPos(4);

  finally
    ProgressDispose();
  end;

end;

{
  Vyplní záložku Úvod
}
procedure FillHeader(space : TNxCustomObjectSpace; sheet : Variant);
var
  mGlobal : TNxCustomBusinessObject;
  mAddress : TNxCustomBusinessObject;
  mUser : TNxCustomBusinessObject;
  mSettings : TNxCustomBusinessObject;
  mAddressID : string;
begin

  mGlobal := space.CreateObject(Class_GlobData);
  mAddress := space.CreateObject(Class_Address);
  mUser := space.CreateObject(Class_SecurityUser);

  try
    mSettings := GetSettingsObject(space);

    mGlobal.Load(GetDataScalar(space,
      'SELECT ID FROM GlobData'), nil);
    mAddressID := NxCreateContext(space).GetCompanyCache.AddressID;
    mAddress.Load(mAddressID, nil);
    mUser.Load(GetDataScalar(space,
      'SELECT ID FROM SecurityUsers WHERE ID = ' + QuotedStr(NxGetActualUserID(space))), nil);

    // Název společnosti
    sheet.Cells[6, 4] := mGlobal.GetFieldValueAsString('CompanyName');

    // Sídlo společnosti
    sheet.Cells[8, 4] := Format('%s, %s',
      [mAddress.GetFieldValueAsString('Street'),
      mAddress.GetFieldValueAsString('City')]);

    // Email pro příjem faktur
    sheet.Cells[10, 5] := mAddress.GetFieldValueAsString('EMail');

    // IČ
    sheet.Cells[12, 3] := mGlobal.GetFieldValueAsString('OrgIdentNumber');
    // DIČ
    sheet.Cells[12, 6] := mGlobal.GetFieldValueAsString('VATIdentNumber');

    // EKOKOM-ID
    sheet.Cells[14, 6] := mSettings.GetFieldValueAsString('Name');

    // Kontaktní osoba
    sheet.Cells[18, 4] := mUser.GetFieldValueAsString('Name');
    // Kontaktní osoba - tel
    sheet.Cells[19, 3] := mUser.GetFieldValueAsString('Address_ID.PhoneNumber1');
    // Kontaktní osoba - fax
    sheet.Cells[20, 3] := mUser.GetFieldValueAsString('Address_ID.FaxNumber');
    // Kontaktní osoba - E-mail
    sheet.Cells[21, 3] := mUser.GetFieldValueAsString('Address_ID.EMail');

  finally
    mUser.Free();
    mGlobal.Free();
    mAddress.Free();
    mSettings.Free();
  end;

end;

procedure FillUngroupedData(ASpace : TNxCustomObjectSpace; AExcel: Variant; AOutputDoc: TStrings; AIsExcel: Boolean);
var
  mSQL, mViewSQL: string;
  mData: TMemoryDataset;
  mRow: Integer;
  mCol: Integer;
  mSheet: Integer;
  mOpakovanePouzivany, mZpoplatneniObalu, mTypObchodu, mLitteringovyObal,
  mZpusobUziti, mZpusobUvedeni, mPuvodMaterialu, mMaterialKompozitu, mMaterial, mSkupina, mBarva: Integer;
  mObsahujeNapoje: Boolean;
  mHmotnost, mMnozstvi: Extended;
  mHmotnostStr, mMnozstviStr: String;
  i: Integer;
  mDisplayNameSQL: String;
  mSheetV: Variant;
  mCellV: Variant;
  mSheetName, mMnozstviStrTmp: String;
  begin
  if CFxNxRuntime.NxGetDatabaseCode = 'ORA' then
    mViewSQL := format(cViewSQL, [cViewSQL2ORA])
  else
    mViewSQL := format(cViewSQL, [cViewSQL2]);
  mSQL :=
    'SELECT ' +
    '  X_EKO_ZpoplatneniObalu, ' +
    '  X_EKO_TypObchodu, ' +
    '  X_EKO_ZpusobUziti, ' +
    '  X_EKO_ZpusobUvedeni, ' +
    '  X_EKO_PuvodMaterialu, ' +
    '  X_EKO_MaterialKompozitu, ' +
    '  X_EKO_MaterialObalu, ' +
    '  X_EKO_VyrazTypObchodu, ' +
    '  X_EKO_OpakovanePouzivany, ' +
    '  X_EKO_LitteringovyObal, ' +
    '  X_EKO_SkupinaMaterialu, ' +
    '  X_EKO_BarvaObalu, ' +
    '  X_EKO_ObsahujeNapoje, ' +
    '  %s '  +
    ' StoreCardName,' +
    ' StoreCardCode,' +
    ' PackageName,' +
    ' PackageCode,' +
    ' SRC.DocumentType,' +
    '  CASE ' +
    '    WHEN (SRC.DocumentType = 21) OR (SRC.DocumentType = 26) THEN Hmotnost ' +
    '    ELSE Hmotnost * (-1) ' +
    '  END AS Hmotnost, ' +
    '  CASE ' +
    '    WHEN (SRC.DocumentType = 21) OR (SRC.DocumentType = 26) THEN Mnozstvi ' +
    '    ELSE Mnozstvi * (-1) ' +
    '  END AS Mnozstvi ' +
    'FROM ' +
    mViewSQL +
    '  JOIN DocQueues DQ on DQ.ID = SRC.DocQueue_ID  ' +
    '  JOIN Periods P on P.ID = SRC.Period_ID  ' +
    gPeriodCondition;
  if CFxNxRuntime.NxGetDatabaseCode = 'ORA' then
    mDisplayNameSQL := ' DQ.CODE || ''-'' ||  CAST(SRC.OrdNumber as VARCHAR2(10)) || ''/'' || P.Code as DisplayName,';
  if CFxNxRuntime.NxGetDatabaseCode = 'MSSQL' then
    mDisplayNameSQL := ' DQ.CODE + ''-'' +  CAST(SRC.OrdNumber as VARCHAR(10)) + ''/'' + P.Code as DisplayName,';
  if CFxNxRuntime.NxGetDatabaseCode = 'IB' then
    mDisplayNameSQL := ' DQ.CODE || ''-'' ||  CAST(SRC.OrdNumber as VARCHAR(10)) || ''/'' || P.Code as DisplayName,';

  mSQL := format(mSQL,[mDisplayNameSQL]);
  mData := TMemoryDataset.Create(nil);

  if AIsExcel then
  begin
    AExcel.ActiveWorkbook.WorkSheets[1].Cells.Select;
    AExcel.Selection.ClearContents;
  end;

  try
    ASpace.SQLSelect2(mSQL, mData);
    if mData.Active then
    begin
      mData.First();
      i := 1;
      if AIsExcel then
      begin
        AExcel.ActiveWorkbook.WorkSheets[1].Cells[i, 1] := 'Záložka';
        AExcel.ActiveWorkbook.WorkSheets[1].Cells[i, 2] := 'Řádek';
        AExcel.ActiveWorkbook.WorkSheets[1].Cells[i, 3] := 'Sloupec';
        AExcel.ActiveWorkbook.WorkSheets[1].Cells[i, 4] := 'Hmotnost';
        AExcel.ActiveWorkbook.WorkSheets[1].Cells[i, 5] := 'Množství';
        AExcel.ActiveWorkbook.WorkSheets[1].Cells[i, 6] := 'Typ dokladu';
        AExcel.ActiveWorkbook.WorkSheets[1].Cells[i, 7] := 'Doklad';
        AExcel.ActiveWorkbook.WorkSheets[1].Cells[i, 8] := 'Skl. karta - kód';
        AExcel.ActiveWorkbook.WorkSheets[1].Cells[i, 9] := 'Skl. karta - název';
        AExcel.ActiveWorkbook.WorkSheets[1].Cells[i, 10] := 'Obal - kód';
        AExcel.ActiveWorkbook.WorkSheets[1].Cells[i, 11] := 'Obal - název';
      end
      else
      begin
        AOutputDoc.Add('Záložka' + cSeparatorCSV +
                   'Řádek' + cSeparatorCSV +
                   'Sloupec' + cSeparatorCSV +
                   'Hmotnost' + cSeparatorCSV +
                   'Množství' + cSeparatorCSV +
                   'Typ dokladu' + cSeparatorCSV +
                   'Doklad' + cSeparatorCSV +
                   'Skl. karta - kód' + cSeparatorCSV +
                   'Skl. karta - název' + cSeparatorCSV +
                   'Obal - kód' + cSeparatorCSV +
                   'Obal - název');
      end;
      while not mData.EOF do
      begin
          i := i + 1;
          mOpakovanePouzivany := mData.FieldByName('X_EKO_OpakovanePouzivany').AsInteger;
          mLitteringovyObal := mData.FieldByName('X_EKO_LitteringovyObal').AsInteger;
          mZpoplatneniObalu := mData.FieldByName('X_EKO_ZpoplatneniObalu').AsInteger;
          mTypObchodu := mData.FieldByName('X_EKO_TypObchodu').AsInteger;
          mZpusobUziti := mData.FieldByName('X_EKO_ZpusobUziti').AsInteger;
          mZpusobUvedeni := mData.FieldByName('X_EKO_ZpusobUvedeni').AsInteger;
          mPuvodMaterialu := mData.FieldByName('X_EKO_PuvodMaterialu').AsInteger;
          mMaterialKompozitu := mData.FieldByName('X_EKO_MaterialKompozitu').AsInteger;
          mMaterial := mData.FieldByName('X_EKO_MaterialObalu').AsInteger;
          mSkupina := mData.FieldByName('X_EKO_SkupinaMaterialu').AsInteger;
          mBarva := mData.FieldByName('X_EKO_BarvaObalu').AsInteger;
          mObsahujeNapoje := GetBoolean(mData.FieldByName('X_EKO_ObsahujeNapoje').AsString);
          mHmotnost := mData.FieldByName('Hmotnost').AsFloat;
          mHmotnostStr := FormatFloat('#0.###############', mHmotnost);
          mMnozstvi := mData.FieldByName('Mnozstvi').AsFloat;
          mMnozstviStr := FormatFloat('#0.###############', mMnozstvi);
          if(mZpoplatneniObalu = cZpoplatneniPuvodniExport) then
            mZpoplatneniObalu := cZpoplatneniZpoplatneny;
          // Nalezení listu
          mSheet := GetSheetIndex(mOpakovanePouzivany, mZpoplatneniObalu, mTypObchodu, mZpusobUziti, mMaterialKompozitu, mObsahujeNapoje);
          // Nalezení řádku
          mRow := GetRowIndex(mSheet, mMaterial, mBarva);
          // Nalezení sloupce
          mCol := GetColIndex(mSheet, mMaterial, mSkupina, mPuvodMaterialu, mZpusobUvedeni, mZpusobUziti, mTypObchodu, mObsahujeNapoje);
          //ShowMessage('mSheet:' + IntToStr(mSheet) + ', mRow:' + IntToStr(mRow) + ', mCol:' + IntToStr(mCol));
          //if (mSheet > 0) and (mRow > 0) and (mCol > 0) then
          //begin
          if AIsExcel then
          begin
            AExcel.ActiveWorkbook.WorkSheets[1].Cells[i, 1] := GetSheetName(mSheet);
            if mRow=0 then
              AExcel.ActiveWorkbook.WorkSheets[1].Cells[i, 2] := '-'
            else
              AExcel.ActiveWorkbook.WorkSheets[1].Cells[i, 2] := mRow;
            AExcel.ActiveWorkbook.WorkSheets[1].Cells[i, 3] := chr(mCol+64);
            AExcel.ActiveWorkbook.WorkSheets[1].Cells[i, 4] := mHmotnost;
            AExcel.ActiveWorkbook.WorkSheets[1].Cells[i, 5] := '';
            AExcel.ActiveWorkbook.WorkSheets[1].Cells[i, 6] := mData.FieldByName('DocumentType').AsString;
            AExcel.ActiveWorkbook.WorkSheets[1].Cells[i, 7] := mData.FieldByName('DisplayName').AsString;
            AExcel.ActiveWorkbook.WorkSheets[1].Cells[i, 8] := mData.FieldByName('StoreCardCode').AsString;
            AExcel.ActiveWorkbook.WorkSheets[1].Cells[i, 9] := mData.FieldByName('StoreCardName').AsString;
            AExcel.ActiveWorkbook.WorkSheets[1].Cells[i, 10] := mData.FieldByName('PackageCode').AsString;
            AExcel.ActiveWorkbook.WorkSheets[1].Cells[i, 11] := mData.FieldByName('PackageName').AsString;
          end
          else
          begin
            if mRow=0 then
              mSheetName := '-'
            else
              mSheetName := IntToStr(mRow);
            AOutputDoc.Add(GetSheetName(mSheet) + cSeparatorCSV +
                                 mSheetName + cSeparatorCSV +
                                 chr(mCol+64) + cSeparatorCSV +
                                 mHmotnostStr + cSeparatorCSV +
                                 '' + cSeparatorCSV +
                                 mData.FieldByName('DocumentType').AsString + cSeparatorCSV +
                                 mData.FieldByName('DisplayName').AsString + cSeparatorCSV +
                                 StringReplace(mData.FieldByName('StoreCardCode').AsString, cSeparatorCSV, cCharAlternative, [rfReplaceAll, rfIgnoreCase]) + cSeparatorCSV +
                                 StringReplace(mData.FieldByName('StoreCardName').AsString, cSeparatorCSV, cCharAlternative, [rfReplaceAll, rfIgnoreCase]) + cSeparatorCSV +
                                 StringReplace(mData.FieldByName('PackageCode').AsString, cSeparatorCSV, cCharAlternative, [rfReplaceAll, rfIgnoreCase]) + cSeparatorCSV +
                                 StringReplace(mData.FieldByName('PackageName').AsString, cSeparatorCSV, cCharAlternative, [rfReplaceAll, rfIgnoreCase]));
          end;
          // Litteringové obaly
          // obaly, které mají uveden, že jsou litteringové a jsou jednorázové
          if (mLitteringovyObal > 0) and (mOpakovanePouzivany = 0) then
          begin
            mRow := GetLitteringRowIndex(mLitteringovyObal);
            mCol := GetLitteringColIndex(mZpoplatneniObalu);
            if (mRow > 0) and (mCol > 0) then
            begin
              i := i + 1;
              if AIsExcel then
              begin
                AExcel.ActiveWorkbook.WorkSheets[1].Cells[i, 1] := GetSheetName(cSheetL);
                if mRow=0 then
                  AExcel.ActiveWorkbook.WorkSheets[1].Cells[i, 2] := '-'
                else
                  AExcel.ActiveWorkbook.WorkSheets[1].Cells[i, 2] := mRow;
                AExcel.ActiveWorkbook.WorkSheets[1].Cells[i, 3] := chr(mCol+64);
                AExcel.ActiveWorkbook.WorkSheets[1].Cells[i, 4] := mHmotnost;
                if mLitteringovyObal in [cLitteringovyObalPlastoveTasky10_50, cLitteringovyObalPlastoveTasky15] then
                  AExcel.ActiveWorkbook.WorkSheets[1].Cells[i, 5] := mMnozstvi
                else
                  AExcel.ActiveWorkbook.WorkSheets[1].Cells[i, 5] := '';
                AExcel.ActiveWorkbook.WorkSheets[1].Cells[i, 6] := mData.FieldByName('DocumentType').AsString;
                AExcel.ActiveWorkbook.WorkSheets[1].Cells[i, 7] := mData.FieldByName('DisplayName').AsString;
                AExcel.ActiveWorkbook.WorkSheets[1].Cells[i, 8] := mData.FieldByName('StoreCardCode').AsString;
                AExcel.ActiveWorkbook.WorkSheets[1].Cells[i, 9] := mData.FieldByName('StoreCardName').AsString;
                AExcel.ActiveWorkbook.WorkSheets[1].Cells[i, 10] := mData.FieldByName('PackageCode').AsString;
                AExcel.ActiveWorkbook.WorkSheets[1].Cells[i, 11] := mData.FieldByName('PackageName').AsString;
              end
              else
              begin
                if mRow=0 then
                  mSheetName := '-'
                else
                  mSheetName := IntToStr(mRow);
                if mLitteringovyObal in [cLitteringovyObalPlastoveTasky10_50, cLitteringovyObalPlastoveTasky15] then
                  mMnozstviStrTmp := mMnozstviStr
                else
                  mMnozstviStrTmp := '';
                AOutputDoc.Add(GetSheetName(cSheetL) + cSeparatorCSV +
                                     mSheetName + cSeparatorCSV +
                                     chr(mCol+64) + cSeparatorCSV +
                                     mHmotnostStr + cSeparatorCSV +
                                     mMnozstviStrTmp + cSeparatorCSV +
                                     mData.FieldByName('DocumentType').AsString + cSeparatorCSV +
                                     mData.FieldByName('DisplayName').AsString + cSeparatorCSV +
                                     StringReplace(mData.FieldByName('StoreCardCode').AsString, cSeparatorCSV, cCharAlternative, [rfReplaceAll, rfIgnoreCase]) + cSeparatorCSV +
                                     StringReplace(mData.FieldByName('StoreCardName').AsString, cSeparatorCSV, cCharAlternative, [rfReplaceAll, rfIgnoreCase]) + cSeparatorCSV +
                                     StringReplace(mData.FieldByName('PackageCode').AsString, cSeparatorCSV, cCharAlternative, [rfReplaceAll, rfIgnoreCase]) + cSeparatorCSV +
                                     StringReplace(mData.FieldByName('PackageName').AsString, cSeparatorCSV, cCharAlternative, [rfReplaceAll, rfIgnoreCase]));
              end;
            end;
          end;
          //end;
        mData.Next();
      end;
    end;
  finally
    mData.Free();
  end;
end;
{
  Vyplní záložky J1-1A až O4
}
procedure FillValues(ASpace : TNxCustomObjectSpace; AExcel : Variant);
var
  mSQL, mViewSQL : string;
  mData : TMemoryDataset;
begin
  if CFxNxRuntime.NxGetDatabaseCode = 'ORA' then
    mViewSQL := format(cViewSQL, [cViewSQL2ORA])
  else
    mViewSQL := format(cViewSQL, [cViewSQL2]);
  mSQL :=
    'SELECT ' +
    '  X_EKO_ZpoplatneniObalu, ' +
    '  X_EKO_LitteringovyObal, ' +
    '  X_EKO_TypObchodu, ' +
    '  X_EKO_ZpusobUziti, ' +
    '  X_EKO_ZpusobUvedeni, ' +
    '  X_EKO_PuvodMaterialu, ' +
    '  X_EKO_MaterialKompozitu, ' +
    '  X_EKO_MaterialObalu, ' +
    '  X_EKO_VyrazTypObchodu, ' +
    '  X_EKO_OpakovanePouzivany, ' +
    '  X_EKO_SkupinaMaterialu, ' +
    '  X_EKO_BarvaObalu, ' +
    '  X_EKO_ObsahujeNapoje, ' +
    '  ROUND(SUM( ' +
    '  CASE ' +
    '    WHEN (DocumentType = 21) OR (DocumentType = 26) THEN Hmotnost ' +
    '    ELSE Hmotnost * (-1) ' +
    '  END), 3) AS Hmotnost, ' +
    '  ROUND(SUM( ' +
    '  CASE ' +
    '    WHEN (SRC.DocumentType = 21) OR (SRC.DocumentType = 26) THEN Mnozstvi ' +
    '    ELSE Mnozstvi * (-1) ' +
    '  END), 3) AS Mnozstvi ' +
    'FROM ' +
    mViewSQL +
    gPeriodCondition +
    ' AND X_EKO_TypObchodu <> 2 ' +
    'GROUP BY X_EKO_ZpoplatneniObalu, X_EKO_TypObchodu, X_EKO_ZpusobUziti, ' +
    '  X_EKO_ZpusobUvedeni, X_EKO_PuvodMaterialu, X_EKO_MaterialKompozitu, X_EKO_MaterialObalu, ' +
    '  X_EKO_SkupinaMaterialu, X_EKO_BarvaObalu, X_EKO_ObsahujeNapoje, ' +
    '  X_EKO_VyrazTypObchodu, X_EKO_OpakovanePouzivany, X_EKO_LitteringovyObal ';

  mData := TMemoryDataset.Create(nil);

  try
    //ShowMessage(mSQL);
    ASpace.SQLSelect2(mSQL, mData);
    if mData.Active then
    begin
      mData.First();

      while not mData.EOF do
      begin
        ProcessDataRow(AExcel,
          mData.FieldByName('X_EKO_OpakovanePouzivany').AsInteger,
          mData.FieldByName('X_EKO_LitteringovyObal').AsInteger,
          mData.FieldByName('X_EKO_ZpoplatneniObalu').AsInteger,
          mData.FieldByName('X_EKO_TypObchodu').AsInteger,
          mData.FieldByName('X_EKO_ZpusobUziti').AsInteger,
          mData.FieldByName('X_EKO_ZpusobUvedeni').AsInteger,
          mData.FieldByName('X_EKO_PuvodMaterialu').AsInteger,
          mData.FieldByName('X_EKO_MaterialKompozitu').AsInteger,
          mData.FieldByName('X_EKO_MaterialObalu').AsInteger,
          mData.FieldByName('X_EKO_SkupinaMaterialu').AsInteger,
          mData.FieldByName('X_EKO_BarvaObalu').AsInteger,
          GetBoolean(mData.FieldByName('X_EKO_ObsahujeNapoje').AsString),
          CFxFloat.Max6(0, mData.FieldByName('Hmotnost').AsFloat),
          CFxFloat.Max6(0, mData.FieldByName('Mnozstvi').AsFloat)
        );
        mData.Next();
      end;
    end;
  finally
    mData.Free();
  end;
end;

function GetBoolean(AValue: String): Boolean;
begin
  Result := (AValue = 'A');
end;

{
  Vyplní záložky J1-1A až O4 pro obaly vyžadující vyhodnocení typu obchodu.
}
procedure FillValuesForEvaluate(ASpace : TNxCustomObjectSpace; AExcel : Variant);
var
  mSQL, mViewSQL : string;
  mData : TMemoryDataset;
  mDoc, mDocBillOfDelivery, mDocRefundedBillOfDelivery, mDocInventoryShortFall : TNxCustomBusinessObject;
begin
  if CFxNxRuntime.NxGetDatabaseCode = 'ORA' then
    mViewSQL := format(cViewSQL, [cViewSQL2ORA])
  else
    mViewSQL := format(cViewSQL, [cViewSQL2]);

  mSQL :=
    'SELECT ' +
    '  X_EKO_ZpoplatneniObalu, ' +
    '  ID, ' +
    '  DocumentType, ' +
    '  X_EKO_ZpusobUziti, ' +
    '  X_EKO_ZpusobUvedeni, ' +
    '  X_EKO_PuvodMaterialu, ' +
    '  X_EKO_MaterialKompozitu, ' +
    '  X_EKO_MaterialObalu, ' +
    '  X_EKO_VyrazTypObchodu, ' +
    '  X_EKO_OpakovanePouzivany, ' +
    '  X_EKO_LitteringovyObal, ' +
    '  X_EKO_SkupinaMaterialu, ' +
    '  X_EKO_BarvaObalu, ' +
    '  X_EKO_ObsahujeNapoje, ' +
    '  CASE ' +
    '    WHEN (DocumentType = 21) OR (DocumentType = 26) THEN Hmotnost ' +
    '    ELSE Hmotnost * (-1) ' +
    '  END AS Hmotnost, ' +
    '  CASE ' +
    '    WHEN (SRC.DocumentType = 21) OR (SRC.DocumentType = 26) THEN Mnozstvi ' +
    '    ELSE Mnozstvi * (-1) ' +
    '  END AS Mnozstvi ' +
    'FROM ' +
    mViewSQL +
    gPeriodCondition +
    ' AND X_EKO_TypObchodu = 2 ' +
    'ORDER BY Hmotnost DESC ';

  mData := TMemoryDataset.Create(nil);
  try
    mDocBillOfDelivery := ASpace.CreateObject(Class_BillOfDelivery);
    try
      mDocRefundedBillOfDelivery := ASpace.CreateObject(Class_RefundedBillOfDelivery);
      try
        mDocInventoryShortFall := ASpace.CreateObject(Class_InventoryShortFall);
        try
          ASpace.SQLSelect2(mSQL, mData);

          if mData.Active then
          begin
            mData.First();

            while not mData.EOF do
            begin
              if mData.FieldByName('DocumentType').AsInteger = 21 then
              begin
                mDoc := mDocBillOfDelivery;
              end
              else
              if mData.FieldByName('DocumentType').AsInteger = 23 then
              begin
                mDoc := mDocRefundedBillOfDelivery;
              end
              else
              if mData.FieldByName('DocumentType').AsInteger = 26 then
              begin
                mDoc := mDocInventoryShortFall;
              end
              else
              begin
                RaiseException('Nepodporovaný typ dokladu.');
              end;
              mDoc.Load(mData.FieldByName('ID').AsString, nil);

              ProcessDataRow(AExcel,
                mData.FieldByName('X_EKO_OpakovanePouzivany').AsInteger,
                mData.FieldByName('X_EKO_LitteringovyObal').AsInteger,
                mData.FieldByName('X_EKO_ZpoplatneniObalu').AsInteger,
                NxEvalObjectExprAsInteger(mDoc, mData.FieldByName('X_EKO_VyrazTypObchodu').AsString),
                mData.FieldByName('X_EKO_ZpusobUziti').AsInteger,
                mData.FieldByName('X_EKO_ZpusobUvedeni').AsInteger,
                mData.FieldByName('X_EKO_PuvodMaterialu').AsInteger,
                mData.FieldByName('X_EKO_MaterialKompozitu').AsInteger,
                mData.FieldByName('X_EKO_MaterialObalu').AsInteger,
                mData.FieldByName('X_EKO_SkupinaMaterialu').AsInteger,
                mData.FieldByName('X_EKO_BarvaObalu').AsInteger,
                mData.FieldByName('X_EKO_ObsahujeNapoje').AsBoolean,
                mData.FieldByName('Hmotnost').AsFloat,
                mData.FieldByName('Mnozstvi').AsFloat);
              mData.Next();
            end;
          end;
        finally
          mDocInventoryShortFall.Free();
        end;
      finally
        mDocRefundedBillOfDelivery.Free();
      end;
    finally
      mDocBillOfDelivery.Free();
    end;
  finally
    mDoc.Free();
    mData.Free();
  end;
end;

{
  Zkontroluje chyby ve výkazu, chyby oznámí to uživateli a chyby zapíše do servisní knížky.
}
Function CheckErrors(ASpace: TNxCustomObjectSpace; AExcel: Variant): string;
var
  mRow: Integer;
  mFoundRow: Integer;
  mSheetErr: Variant;
  mErrors: String;
  mErrorText: String;
  mErrorDiff: String;
  mSystemSupportEntryDisplayName: String;
begin
  Result := '';
  mSheetErr := AExcel.ActiveWorkbook.WorkSheets[cSheetKontroly];
  mFoundRow := 0;
  mErrors := '';
  mSystemSupportEntryDisplayName := '';
  // Pokusíme se najít řádek s kontrolou kompozitních obalů
  for mRow := 1 to 200 do
  begin
    if AnsiLowerCase(mSheetErr.Cells[mRow, 1].Value) = AnsiLowerCase(cRowValueKontroly) then
    begin
      // Řádek nalezen
      mFoundRow := mRow;
      break;
    end;
  end;
  // Zkontrolujeme, zda nedošlo ke změně záložky KONTROLY
  if (AnsiLowerCase(mSheetErr.Name) = AnsiLowerCase(cSheetKontrolyName)) and (mFoundRow > 0) then
  begin
    try
      for mRow := mFoundRow+1 to (mFoundRow+32) do
      begin
        if StrToFloat(mSheetErr.Cells[mRow, 6].Value) <> 0 then
        begin
          // Částka rozdílu není nulová, jedná se tedy o chybu
          mErrorText := mSheetErr.Cells[mRow, 5].Value;
          mErrorDiff := mSheetErr.Cells[mRow, 6].Value;
          mErrors := mErrors + Format('%0:s (rozdíl: %1:s)'#13#10, [mErrorText, mErrorDiff]);
        end;
      end;
      if mErrors <> '' then
      begin
        // Byly zjištěny chyby, které zapíšeme do servisní knížky
        mSystemSupportEntryDisplayName := SaveSystemSupportEntry(ASpace, mErrors);
        Result := 'Vyplněný výkaz obsahuje chyby!'#13#10'Podrobnosti o chybách jsou uvedeny v servisní knížce (' + mSystemSupportEntryDisplayName + ').';
      end;
    except
      Result := 'Nelze zobrazit chyby ve výkazu z důvodu změny struktury výkazu!';
    end;
  end
  else
  begin
    Result := 'Nelze zobrazit chyby ve výkazu z důvodu změny struktury výkazu.';
  end;
end;

function SaveSystemSupportEntry(ASpace: TNxCustomObjectSpace; AText: String): string;
var
  mBO: TNxCustomBusinessObject;
begin
  Result := '';
  mBO:= ASpace.CreateObject('05AXCRARHBEL3C5V00CA141B44');
  try
    mBO.New;
    mBO.Prefill;
    mBO.SetFieldValueAsString('ShortDescription', 'Výkaz EkoKom ' + DateTimeToStr(Now) + ' - chyby ve výkazu');
    mBO.SetFieldValueAsString('ProblemDescription', AText);
    mBO.Save;
    Result := mBO.DisplayName;
  finally
    mBO.Free;
  end;
end;

procedure ProcessDataRowUngrouped(ARow: Integer; AExcel: Variant; AOpakovanePouzivany, ALitteringovyObal, AZpoplatneniObalu, ATypObchodu,
  AZpusobUziti, AZpusobUvedeni, APuvodMaterialu, AMaterialKompozitu, AMaterial, ASkupina, ABarva: Integer;
  AObsahujeNapoje: Boolean; AHmotnost : Extended);
var
  mRow : Integer;
  mCol : Integer;
  mSheet : Integer;
  mVal : Extended;
begin
  // Nastavení zpoplatnění z původní již nepoužívané položky Export na Zpoplatněný
  if(AZpoplatneniObalu = cZpoplatneniPuvodniExport) then
    AZpoplatneniObalu := cZpoplatneniZpoplatneny;
  // Nalezení listu
  mSheet := GetSheetIndex(AOpakovanePouzivany, AZpoplatneniObalu, ATypObchodu, AZpusobUziti, AMaterialKompozitu, AObsahujeNapoje);
  // Nalezení řádku
  mRow := GetRowIndex(mSheet, AMaterial, ABarva);
  // Nalezení sloupce
  mCol := GetColIndex(mSheet, AMaterial, ASkupina, APuvodMaterialu, AZpusobUvedeni, AZpusobUziti, ATypObchodu, AObsahujeNapoje);
  //ShowMessage('mSheet:' + IntToStr(mSheet) + ', mRow:' + IntToStr(mRow) + ', mCol:' + IntToStr(mCol));

  if (mSheet > 0) and (mRow > 0) and (mCol > 0) then
  begin
    AExcel.ActiveWorkbook.WorkSheets[1].Cells[ARow, 1] := mSheet;
    AExcel.ActiveWorkbook.WorkSheets[1].Cells[ARow, 2] := mRow;
    AExcel.ActiveWorkbook.WorkSheets[1].Cells[ARow, 3] := mCol;
    AExcel.ActiveWorkbook.WorkSheets[1].Cells[ARow, 4] := AHmotnost;
  end;
end;

procedure ProcessDataRow(AExcel: Variant; AOpakovanePouzivany, ALitteringovyObal, AZpoplatneniObalu, ATypObchodu,
  AZpusobUziti, AZpusobUvedeni, APuvodMaterialu, AMaterialKompozitu, AMaterial, ASkupina, ABarva: Integer;
  AObsahujeNapoje: Boolean; AHmotnost, AMnozstvi : Extended);
var
  mRow : Integer;
  mCol : Integer;
  mSheet : Integer;
  mVal : Extended;
begin
  // Nastavení zpoplatnění z původní již nepoužívané položky Export na Zpoplatněný
  if(AZpoplatneniObalu = cZpoplatneniPuvodniExport) then
    AZpoplatneniObalu := cZpoplatneniZpoplatneny;
  // Nalezení listu
  mSheet := GetSheetIndex(AOpakovanePouzivany, AZpoplatneniObalu, ATypObchodu, AZpusobUziti, AMaterialKompozitu, AObsahujeNapoje);
  // Nalezení řádku
  mRow := GetRowIndex(mSheet, AMaterial, ABarva);
  // Nalezení sloupce
  mCol := GetColIndex(mSheet, AMaterial, ASkupina, APuvodMaterialu, AZpusobUvedeni, AZpusobUziti, ATypObchodu, AObsahujeNapoje);
  //ShowMessage('mSheet:' + IntToStr(mSheet) + ', mRow:' + IntToStr(mRow) + ', mCol:' + IntToStr(mCol));

  if (mSheet > 0) and (mRow > 0) and (mCol > 0) then
  begin
    if AExcel.ActiveWorkbook.WorkSheets[mSheet].Cells[mRow, mCol].Value = 0 then
      mVal := 0
    else
      mVal := AExcel.ActiveWorkbook.WorkSheets[mSheet].Cells[mRow, mCol].Value;

    mVal := mVal + AHmotnost;
    if not (AExcel.ActiveWorkbook.WorkSheets[mSheet].Cells[mRow, mCol].Locked) then // Přeskočení nevykazovaných buněk (zamčených)
    begin
      AExcel.ActiveWorkbook.WorkSheets[mSheet].Cells[mRow, mCol] := CFxFloat.Max6(0, mVal);
    end;
  end;
  // Vykazování litteringových obalů
  // obaly, které mají uveden, že jsou litteringové a jsou jednorázové
  if (ALitteringovyObal > 0) and (AOpakovanePouzivany = 0) then
  begin
    mRow := GetLitteringRowIndex(ALitteringovyObal);
    mCol := GetLitteringColIndex(AZpoplatneniObalu);
    if (mRow > 0) and (mCol > 0) then
    begin
      if AExcel.ActiveWorkbook.WorkSheets[cSheetL].Cells[mRow, mCol].Value = 0 then
        mVal := 0
      else
        mVal := AExcel.ActiveWorkbook.WorkSheets[cSheetL].Cells[mRow, mCol].Value;

      mVal := mVal + AHmotnost;
      if not (AExcel.ActiveWorkbook.WorkSheets[cSheetL].Cells[mRow, mCol].Locked) then // Přeskočení nevykazovaných buněk (zamčených)
      begin
        AExcel.ActiveWorkbook.WorkSheets[cSheetL].Cells[mRow, mCol] := CFxFloat.Max6(0, mVal);
      end;
      if mCol = 6 then
      begin
        // Jedná se o zpoplatně
        if ALitteringovyObal in [cLitteringovyObalNapojoveKelimky, cLitteringovyObalNadobyNaPotraviny] then
        begin
          // Jedná se o nápojové kelímky nebo nádoby na potraviny částečně vyrobené z plastu
          if AMaterial < 11 then
          begin
            // Materiál obalu je plast, v jiném případě se nevykazuje do sloupce "hmotnost plastu v tunách"
            mCol := mCol - 1;
            if AExcel.ActiveWorkbook.WorkSheets[cSheetL].Cells[mRow, mCol].Value = 0 then
              mVal := 0
            else
              mVal := AExcel.ActiveWorkbook.WorkSheets[cSheetL].Cells[mRow, mCol].Value;
            mVal := mVal + AHmotnost;
            if not (AExcel.ActiveWorkbook.WorkSheets[cSheetL].Cells[mRow, mCol].Locked) then // Přeskočení nevykazovaných buněk (zamčených)
            begin
              AExcel.ActiveWorkbook.WorkSheets[cSheetL].Cells[mRow, mCol] := CFxFloat.Max6(0, mVal);
            end;
          end;
        end
        else
        begin
          if ALitteringovyObal in [cLitteringovyObalPlastoveTasky10_50, cLitteringovyObalPlastoveTasky15] then
          begin
            // Jedná se o plastové odnosné tašky
            mCol := mCol + 1;
            if AExcel.ActiveWorkbook.WorkSheets[cSheetL].Cells[mRow, mCol].Value = 0 then
              mVal := 0
            else
              mVal := AExcel.ActiveWorkbook.WorkSheets[cSheetL].Cells[mRow, mCol].Value;
            mVal := mVal + AMnozstvi;
            if not (AExcel.ActiveWorkbook.WorkSheets[cSheetL].Cells[mRow, mCol].Locked) then // Přeskočení nevykazovaných buněk (zamčených)
            begin
              AExcel.ActiveWorkbook.WorkSheets[cSheetL].Cells[mRow, mCol] := CFxFloat.Max6(0, mVal);
            end;
          end;
        end;
      end;
    end;
  end;
end;

{
  Vrátí index příslušného listu
}
function GetSheetIndex(AOpakovanePouzivany, AZpoplatneniObalu, ATypObchodu,
  AZpusobUziti, AMaterialKompozitu: Integer; AObsahujeNapoje: Boolean): Integer;
var
  mSheet: Integer;
begin
  mSheet := 0;
  if (AOpakovanePouzivany = 0) then
  begin
    // Obaly na jedno použití
    if (AZpoplatneniObalu = cZpoplatneniZpoplatneny) then
    begin
      // Zpoplatněné obaly
      if ATypObchodu = cTypObchoduPrumyslove then
      begin
        if AMaterialKompozitu = 0 then
          mSheet := cSheetJ1_3 // List J1-3 - Průmyslové obaly
        else
        begin
          mSheet := cSheetJ1_3K; // List J1-3K - Průmyslové obaly - rozpad kompozitních materiálů
        end
      end
      else
      if AObsahujeNapoje then
      begin
        // Obsahuje nápoje
        if AMaterialKompozitu = 0 then
        begin
          if AZpusobUziti = cUzitiProdejni then
            mSheet := cSheetJ1_2A // List J1-2A - Prodejní
          else
            mSheet := cSheetJ1_2B; // List J1-2B - Skupinové a přepravní
        end
        else
        begin
          mSheet := cSheetJ1_2K; // List J1-2K - rozpad kompozitních materiálů
        end;
      end
      else
      begin
        // Neobsahuje nápoje
        if AMaterialKompozitu = 0 then
        begin
          if AZpusobUziti = cUzitiProdejni then
            mSheet := cSheetJ1_1A // List J1-1A - Prodejní
          else
            mSheet := cSheetJ1_1B; // List J1-1B - Skupinové a přepravní
        end
        else
        begin
          mSheet := cSheetJ1_1K; // List J1-1K - rozpad kompozitních materiálů
        end;
      end;
    end
    else if (AZpoplatneniObalu = cZpoplatneniPredplaceny) then
      mSheet := cSheetJ2 // List J2 - Předplacené
    else if (AZpoplatneniObalu = cZpoplatneniNeplaceny) then
      mSheet := cSheetJ3 // List J3 - Neplacené
    else if (AZpoplatneniObalu = cZpoplatneniExport) then
      mSheet := cSheetJ4; // List J4 - Exportované
  end
  else
  begin
    // Obaly opakovaně používané
    if (AZpoplatneniObalu = cZpoplatneniZpoplatneny) then
    begin
      // Zpoplatněné obaly
      if ATypObchodu = cTypObchoduPrumyslove then
      begin
        if AMaterialKompozitu = 0 then
          mSheet := cSheetO1_3 // List O1-3 - Průmyslové obaly
        else
          mSheet := cSheetO1_3K; // List O1-3K - Průmyslové obaly - rozpad kompozitních materiálů
      end
      else
      if AObsahujeNapoje then
      begin
        // Obsahuje nápoje
        if AMaterialKompozitu = 0 then
        begin
          if AZpusobUziti = cUzitiProdejni then
            mSheet := cSheetO1_2A // List O1-2A - Prodejní
          else
            mSheet := cSheetO1_2B; // List O1-2B - Skupinové a přepravní
        end
        else
        begin
          mSheet := cSheetO1_2K; // List O1-2K - rozpad kompozitních materiálů
        end
      end
      else
      begin
        // Neobsahuje nápoje
        if AMaterialKompozitu = 0 then
        begin
          if AZpusobUziti = cUzitiProdejni then
            mSheet := cSheetO1_1A // List O1-1A - Prodejní
          else
            mSheet := cSheetO1_1B; // List O1-1B - Skupinové a přepravní
        end
        else
        begin
          mSheet := cSheetO1_1K; // List O1-1K - rozpad kompozitních materiálů
        end;
      end;
    end
    else if (AZpoplatneniObalu = cZpoplatneniPredplaceny) and (AMaterialKompozitu = 0) then
      mSheet := cSheetO2 // List O2 - Předplacené
    else if (AZpoplatneniObalu = cZpoplatneniNeplaceny) and (AMaterialKompozitu = 0) then
      mSheet := cSheetO3 // List O3 - Neplacené
    else if (AZpoplatneniObalu = cZpoplatneniExport) and (AMaterialKompozitu = 0) then
      mSheet := cSheetO4; // List O4 - Exportované
  end;
  Result := mSheet;
end;

{
  Vrátí index příslušného řádku
}
function GetRowIndex(ASheet, AMaterial, ABarva: Integer): Integer;
var
  mRow: Integer;
  mStartRow: Integer;
  mCoefficient: Integer;
  mComposit: Boolean;
  mBarva: Boolean;
  mOnly2Colors: Boolean;
begin
  mOnly2Colors := False;
  if AMaterial = 0 then
  begin
    // Materiál není zadaný
    mRow := 0;
  end
  else if (AMaterial in [10, 13, 14, 16, 22, 24]) //Kompozitní materiály
    and (ASheet in [cSheetJ1_1K, cSheetJ1_2K, cSheetJ1_3K, cSheetJ2, cSheetJ3,
     cSheetJ4, cSheetL, cSheetO1_1K, cSheetO1_2K, cSheetO1_3K, cSheetO2,
     cSheetO3, cSheetO4]) then //Záložky na kterých se nenachází kompozitní materiál. Na záložkách se uvede až rozpad kompozitního obalu.
  begin
     mRow := 0;
  end
  else if AMaterial < 11 then
  begin
    //Plasty ----------------------------------------------
    //Nastavení počátečního řádku
    if ASheet in [cSheetJ1_1A, cSheetJ1_2A] then
    begin
      mStartRow := 10;
      mCoefficient := 2;
    end
    else if ASheet in [cSheetJ1_1B, cSheetJ1_2B, cSheetO1_1B, cSheetO1_2B] then
    begin
      mStartRow := 10;
      mCoefficient := 2;
      mOnly2Colors := True;
    end
    else if ASheet in [cSheetJ1_3, cSheetO1_3] then
    begin
      mStartRow := 10;
      mCoefficient := 2;
      mOnly2Colors := True;
    end
    else if ASheet in [cSheetJ1_1K, cSheetJ1_2K, cSheetO1_1K, cSheetO1_2K] then
    begin
      mStartRow := 9;
      mCoefficient := 1;
    end
    else if ASheet in [cSheetJ1_3K, cSheetO1_3K] then
    begin
      mStartRow := 10;
      mCoefficient := 1;
    end
    else if ASheet in [cSheetJ2, cSheetJ3, cSheetJ4, cSheetO2, cSheetO3, cSheetO4] then
    begin
      mStartRow := 8;
      mCoefficient := 1;
    end
    else if ASheet in [cSheetO1_1A, cSheetO1_2A] then
    begin
      mStartRow := 10;
      mCoefficient := 2;
    end ;
    // Zjištění řádku
    if mCoefficient = 1 then
    begin
      // Nehraje se na barvu obalu
      if AMaterial < 5 then
        mRow := mStartRow + AMaterial // PET, PE, PP, PS
      else if AMaterial = 7 then
        mRow := mStartRow + AMaterial - 2 // PVC
      else
        mRow := mStartRow + 6; // Všechny ostatní plasty
    end
    else
    begin
      // Materiál včetně barvy
      if AMaterial = 1 then // PET
      begin
        if mOnly2Colors then
        begin
          //Pouze 2 barvy
          if ABarva = cBarvaTransparentni then
            mRow := mStartRow + 1
          else
            mRow := mStartRow + 1; //ostatní zadané barvy se vykážou jako barevné
        end
        else
        begin
          if ABarva = cBarvaTransparentni then
            mRow := mStartRow
          else if ABarva = cBarvaPruhledneBarevnéPET then
            mRow := mStartRow + 1
          else
            mRow := mStartRow + 2;
        end;
      end
      else if (AMaterial > 1) and (AMaterial < 11) then // Plasty mimo PET
      begin
      mRow := mStartRow + (AMaterial*mCoefficient);
      if ABarva = cBarvaTransparentni then
        mRow := mRow - 1;
      end;
    end;
  end
  else if AMaterial < 15 then
  begin
    //Kovy ----------------------------------------------
    //Nastavení počátečního řádku
    if ASheet in [cSheetJ1_1A, cSheetJ1_2A] then
    begin
      mStartRow := 31;
      mComposit := True;
    end
    else if ASheet in [cSheetJ1_1B, cSheetJ1_2B, cSheetO1_1B, cSheetO1_2B] then
    begin
      mStartRow := 31;
      mComposit := True;
    end
    else if ASheet in [cSheetJ1_3, cSheetO1_3] then
    begin
      mStartRow := 31;
      mComposit := True;
    end
    else if ASheet in [cSheetJ1_1K, cSheetJ1_2K, cSheetO1_1K, cSheetO1_2K] then
    begin
      mStartRow := 16;
      mComposit := False;
    end
    else if ASheet in [cSheetJ1_3K, cSheetO1_3K] then
    begin
      mStartRow := 17;
      mComposit := False;
    end
    else if ASheet in [cSheetJ2, cSheetJ3, cSheetJ4, cSheetO2, cSheetO3, cSheetO4] then
    begin
      mStartRow := 15;
      mComposit := False;
    end
    else if ASheet in [cSheetO1_1A, cSheetO1_2A] then
    begin
      mStartRow := 31;
      mComposit := True;
    end;
    if (mComposit = False) and (AMaterial in [13, 14]) then
    begin
      // Korekce nekompozitního vykazování - z kompozitního materiálu uděláme nekompozitní
      AMaterial := AMaterial - 2;
    end;
    mRow := mStartRow + AMaterial - 11;
  end
  else if AMaterial = 15 then
  begin
    //Nápojové kartony ----------------------------------------------
    if ASheet in [cSheetJ1_1A, cSheetJ1_2A] then
    begin
      mRow := 35;
    end
    else if ASheet in [cSheetJ1_1B, cSheetJ1_2B, cSheetO1_1B, cSheetO1_2B] then
    begin
      mRow := 0;
    end
    else if ASheet in [cSheetJ1_3, cSheetO1_3] then
    begin
      mRow := 0;
    end
    else if ASheet in [cSheetJ1_1K, cSheetJ1_2K, cSheetO1_1K, cSheetO1_2K] then
    begin
      mRow := 0;
    end
    else if ASheet in [cSheetJ1_3K, cSheetO1_3K] then
    begin
      mRow := 0;
    end
    else if ASheet in [cSheetJ2, cSheetJ3, cSheetJ4, cSheetO2, cSheetO3, cSheetO4] then
    begin
      mRow := 0;
    end
    else if ASheet in [cSheetO1_1A, cSheetO1_2A] then
    begin
      mRow := 0;
    end;
  end
  else if AMaterial = 16 then
  begin
    //Kompozitní materiál ----------------------------------------------
    if ASheet in [cSheetJ1_1A, cSheetJ1_2A] then
    begin
      mRow := 36;
    end
    else if ASheet in [cSheetJ1_1B, cSheetJ1_2B, cSheetO1_1B, cSheetO1_2B] then
    begin
      mRow := 35;
    end
    else if ASheet in [cSheetJ1_3, cSheetO1_3] then
    begin
      mRow := 35;
    end
    else if ASheet in [cSheetJ1_1K, cSheetJ1_2K, cSheetO1_1K, cSheetO1_2K] then
    begin
      mRow := 0;
    end
    else if ASheet in [cSheetJ1_3K, cSheetO1_3K] then
    begin
      mRow := 0;
    end
    else if ASheet in [cSheetJ2, cSheetJ3, cSheetJ4, cSheetO2, cSheetO3, cSheetO4] then
    begin
      mRow := 0;
    end
    else if ASheet in [cSheetO1_1A, cSheetO1_2A] then
    begin
      mRow := 35;
    end;
  end
  else if AMaterial = 17 then
  begin
    //Sklo ----------------------------------------------
    if ASheet in [cSheetJ1_1A, cSheetJ1_2A] then
    begin
      mStartRow := 41;
      mBarva := True;
    end
    else if ASheet in [cSheetJ1_1B, cSheetJ1_2B, cSheetO1_1B, cSheetO1_2B] then
    begin
      mStartRow := 0;
    end
    else if ASheet in [cSheetJ1_3, cSheetO1_3] then
    begin
      mStartRow := 42;
      mBarva := True;
    end
    else if ASheet in [cSheetJ1_1K, cSheetJ1_2K, cSheetO1_1K, cSheetO1_2K] then
    begin
      mStartRow := 18;
      mBarva := False;
    end
    else if ASheet in [cSheetJ1_3K, cSheetO1_3K] then
    begin
      mStartRow := 19;
      mBarva := False;
    end
    else if ASheet in [cSheetJ2, cSheetJ3, cSheetJ4, cSheetO2, cSheetO3, cSheetO4] then
    begin
      mStartRow := 17;
      mBarva := False;
    end
    else if ASheet in [cSheetO1_1A, cSheetO1_2A] then
    begin
      mStartRow := 40;
      mBarva := True;
    end;
    if mStartRow = 0 then
    begin
      mRow := 0; // Obal se na záložce nevykazuje
    end
    else
    begin
      if mBarva then
      begin
        if ABarva = cBarvaKompozitniSklo then
          mCoefficient := 2
        else if ABarva in [cBarvaBarevne, cBarvaNepruhledneBarevnePET] then
          mCoefficient := 1
        else
          mCoefficient := 0;
        mRow := mStartRow + mCoefficient;
      end
      else
      begin
        mRow := mStartRow; // Na barva obalu se nerozlišuje
      end
    end
  end
  else if AMaterial < 23 then
  begin
    //Papír ----------------------------------------------
    if ASheet in [cSheetJ1_1A, cSheetJ1_2A] then
    begin
      mStartRow := 44;
      mBarva := True; //Myšlen rozpad na jednotlivé druhy papíru
    end
    else if ASheet in [cSheetJ1_1B, cSheetJ1_2B, cSheetO1_1B, cSheetO1_2B] then
    begin
      mStartRow := 42;
      mBarva := True; //Myšlen rozpad na jednotlivé druhy papíru
    end
    else if ASheet in [cSheetJ1_3, cSheetO1_3] then
    begin
      mStartRow := 45;
      mBarva := True;
    end
    else if ASheet in [cSheetJ1_1K, cSheetJ1_2K, cSheetO1_1K, cSheetO1_2K] then
    begin
      mStartRow := 19;
      mBarva := False;
    end
    else if ASheet in [cSheetJ1_3K, cSheetO1_3K] then
    begin
      mStartRow := 20;
      mBarva := False;
    end
    else if ASheet in [cSheetJ2, cSheetJ3, cSheetJ4, cSheetO2, cSheetO3, cSheetO4] then
    begin
      mStartRow := 18;
      mBarva := False;
    end
    else if ASheet in [cSheetO1_1A, cSheetO1_2A] then
    begin
      mStartRow := 43;
      mBarva := True;
    end;
    if mStartRow = 0 then
    begin
      mRow := 0; // Obal se na záložce nevykazuje
    end
    else
    begin
      if mBarva then
      begin
        mRow := mStartRow + AMaterial - 18;
      end
      else
      begin
        mRow := mStartRow; // Druh papíru se nerozlišuje
      end
    end;
  end
  else if AMaterial < 25 then
  begin
    //Dřevo ----------------------------------------------
    if ASheet in [cSheetJ1_1A, cSheetJ1_2A] then
    begin
      mStartRow := 49;
      mBarva := True; //Myšlen rozpad na jednotlivé druhy dřeva
    end
    else if ASheet in [cSheetJ1_1B, cSheetJ1_2B, cSheetO1_1B, cSheetO1_2B] then
    begin
      mStartRow := 47;
      mBarva := True;
    end
    else if ASheet in [cSheetJ1_3, cSheetO1_3] then
    begin
      mStartRow := 50;
      mBarva := True;
    end
    else if ASheet in [cSheetJ1_1K, cSheetJ1_2K, cSheetO1_1K, cSheetO1_2K] then
    begin
      mStartRow := 20;
      mBarva := False;
    end
    else if ASheet in [cSheetJ1_3K, cSheetO1_3K] then
    begin
      mStartRow := 21;
      mBarva := False;
    end
    else if ASheet in [cSheetJ2, cSheetJ3, cSheetJ4, cSheetO2, cSheetO3, cSheetO4] then
    begin
      mStartRow := 19;
      mBarva := False;
    end
    else if ASheet in [cSheetO1_1A, cSheetO1_2A] then
    begin
      mStartRow := 48;
      mBarva := True;
    end;
    if mBarva then
    begin
      mRow := mStartRow + AMaterial - 23;
    end
    else
    begin
      mRow := mStartRow; // Druh dřeva se nerozlišuje
    end
  end
  else if AMaterial = 25 then
  begin
    //Textil ----------------------------------------------
    if ASheet in [cSheetJ1_1A, cSheetJ1_2A] then
      mRow := 51
    else if ASheet in [cSheetJ1_1B, cSheetJ1_2B, cSheetO1_1B, cSheetO1_2B] then
      mRow := 49
    else if ASheet in [cSheetJ1_3, cSheetO1_3] then
      mRow := 52
    else if ASheet in [cSheetJ1_1K, cSheetJ1_2K, cSheetO1_1K, cSheetO1_2K] then
      mRow := 21
    else if ASheet in [cSheetJ1_3K, cSheetO1_3K] then
      mRow := 22
    else if ASheet in [cSheetJ2, cSheetJ3, cSheetJ4, cSheetO2, cSheetO3, cSheetO4] then
      mRow := 20
    else if ASheet in [cSheetO1_1A, cSheetO1_2A] then
      mRow := 50
    else
      mRow := 0;
  end
  else if AMaterial = 26 then
  begin
    //Jiné ----------------------------------------------
    if ASheet in [cSheetJ1_1A, cSheetJ1_2A] then
      mRow := 52
    else if ASheet in [cSheetJ1_1B, cSheetJ1_2B, cSheetO1_1B, cSheetO1_2B] then
      mRow := 50
    else if ASheet in [cSheetJ1_3, cSheetO1_3] then
      mRow := 53
    else if ASheet in [cSheetJ1_1K, cSheetJ1_2K, cSheetO1_1K, cSheetO1_2K] then
      mRow := 21
    else if ASheet in [cSheetJ1_3K, cSheetO1_3K] then
      mRow := 22
    else if ASheet in [cSheetJ2, cSheetJ3, cSheetJ4, cSheetO2, cSheetO3, cSheetO4] then
      mRow := 21
    else if ASheet in [cSheetO1_1A, cSheetO1_2A] then
      mRow := 51
    else
      mRow := 0;
  end
  else
  begin
    mRow := 0;
  end;
  Result := mRow;
end;

{
  Vrátí index příslušného sloupce
}
function GetColIndex(ASheet, AMaterial, ASkupina, APuvodMaterialu, AZpusobUvedeni, AZpusobUziti, ATypObchodu: Integer; AObsahujeNapoje: Boolean): Integer;
var
  mCol: Integer;
  mZpusobUvedeni: Integer;
  mSkupina: Integer;
  mZpusobUziti: Integer;
  mObsahujeNapoje: Integer;
begin
  mCol := 0;
  if AZpusobUvedeni = cUvedeniImportovane then
    mZpusobUvedeni := 1
  else
    mZpusobUvedeni := 0;
  if ASheet in [cSheetJ1_1A, cSheetJ1_2A] then
  begin
    if AMaterial < 17 then
      mCol := (((ASkupina+1)*4)+1) + (APuvodMaterialu*2) + (mZpusobUvedeni)
    else
      mCol := 5 + (APuvodMaterialu*4) + (mZpusobUvedeni*2);
  end
  else
  if ASheet in [cSheetJ1_1B, cSheetJ1_2B, cSheetO1_1B, cSheetO1_2B] then
  begin
    if ASkupina = cSkupinaMekkeFlexibilní then
      mSkupina := 0
    else
      mSkupina := 1;
    if AZpusobUziti = cUzitiPrepravni then
      mZpusobUziti := 1
    else
      mZpusobUziti := 0;
    if AMaterial < 17 then
      mCol := 5 + (mZpusobUziti*8) + (mSkupina*4) + (APuvodMaterialu*2) + (mZpusobUvedeni)
    else
      mCol := 5 + (mZpusobUziti*8) + (APuvodMaterialu*4) + (mZpusobUvedeni*2);
  end
  else
  if ASheet in [cSheetJ1_3, cSheetO1_3] then
  begin
    if ASkupina = cSkupinaMekkeFlexibilní then
      mSkupina := 0
    else
      mSkupina := 1;
    if AMaterial < 17 then
      mCol := 5 + (mObsahujeNapoje*8) + (mSkupina*4) + (APuvodMaterialu*2) + (mZpusobUvedeni)
    else
      mCol := 5 + (mObsahujeNapoje*8) + (APuvodMaterialu*4) + (mZpusobUvedeni*2);
  end
  else
  if ASheet in [cSheetJ1_1K, cSheetJ1_2K, cSheetO1_1K, cSheetO1_2K] then
  begin
    mCol :=  5 + (AZpusobUziti*2) + (mZpusobUvedeni);
  end
  else
  if ASheet in [cSheetJ1_3K, cSheetO1_3K] then
  begin
    if AObsahujeNapoje then
      mObsahujeNapoje := 1
    else
      mObsahujeNapoje := 0;
    mCol :=  5 + (mObsahujeNapoje*2) + (mZpusobUvedeni);
  end
  else
  if ASheet in [cSheetJ2, cSheetJ3, cSheetJ4, cSheetO2, cSheetO3, cSheetO4] then
  begin
     if ATypObchodu = cTypObchoduPrumyslove then
      mCol :=  11 + (mZpusobUvedeni)
    else
      mCol := 5 + (AZpusobUziti*2) + (mZpusobUvedeni);
  end
  else
  if ASheet in [cSheetO1_1A, cSheetO1_2A] then
  begin
    if AMaterial < 17 then
      mCol := 5 + (ASkupina*4) + (APuvodMaterialu*2) + (mZpusobUvedeni)
    else
      mCol := 5 + (APuvodMaterialu*4) + (mZpusobUvedeni*2);
  end;
  Result := mCol;
end;

{
  Vrátí index příslušného řádku litteringového obalu
}
function GetLitteringRowIndex(ALitteringovyObal: Integer): Integer;
begin
  if ALitteringovyObal > 0 then
    Result := ALitteringovyObal + 5
  else
    Result := 0;
end;

{
  Vrátí index příslušného sloupce litteringového obalu
}
function GetLitteringColIndex(AZpoplatneniObalu: Integer): Integer;
begin
  case AZpoplatneniObalu of
    cZpoplatneniZpoplatneny:
      Result := 6;
    cZpoplatneniPredplaceny:
      Result := 8;
    cZpoplatneniNeplaceny:
      Result := 9;
    cZpoplatneniExport:
      Result := 10;
  else
    Result := 0;
  end;
end;

{
  Smaže všechny zadané hodnoty
}
procedure ClearWorkbook(AExcel : Variant);
var
  mSheet : Integer;
  mRow : Integer;
  mCol : Integer;
  i : Integer;
  mSheetV : Variant;
  mCellV : Variant;
begin
  i := 0;

  // Listy J1-1A až O4
  for mSheet := cSheetJ1_1A to cSheetO4 do
  begin
    i := i+1;
    ProgressSetPos(i);
    mSheetV := AExcel.ActiveWorkbook.WorkSheets[mSheet];
    for mRow := 9 to 53 do
      for mCol := 5{E} to 20{T} do
      begin
        mCellV := mSheetV.Cells[mRow, mCol];
        if mCellV.Locked = False then
          mCellV.Value := '';
      end;
  end;
  // Čištění řádků záložky L
  mSheetV := AExcel.ActiveWorkbook.WorkSheets[cSheetL];
  for mRow := 6 to 8 do
  begin
    for mCol := 5{E} to 10{J} do
    begin
      mCellV := mSheetV.Cells[mRow, mCol];
      if mCellV.Locked = False then
        mCellV.Value := '';
    end;
  end;
end;

{
  Vrátí čtvrtletí výkazu
}
function GetQuarter(AExcel : Variant) : Integer;
begin
  Result := AExcel.ActiveWorkbook.WorkSheets[cSheetUvod].Cells[4, 4].Value;
end;

{
  Vrátí rok výkazu
}
function GetYear(AExcel : Variant) : Integer;
begin
  Result := StrToInt(NxRight(AExcel.ActiveWorkbook.WorkSheets[cSheetUvod].Cells[4, 5].Value, 4));
end;

{
  Vrátí datum začátk období
}
function GetStartDate(AQuarter : Integer; AYear : Integer) : TDateTime;
var
  mDay : Integer;
  mMonth : Integer;
begin

  mDay := 1;

  if AQuarter = 1 then
    mMonth := 1;
  if AQuarter = 2 then
    mMonth := 4;
  if AQuarter = 3 then
    mMonth := 7;
  if AQuarter = 4 then
    mMonth := 10;

  Result := EncodeDate(AYear, mMonth, mDay);

end;

{
  Vrátí datum konce období
}
function GetEndDate(AQuarter : Integer; AYear : Integer) : TDateTime;
var
  mDay : Integer;
  mMonth : Integer;
begin

  if AQuarter = 1 then
  begin
    mMonth := 3;
    mDay := 31;
  end
  else if AQuarter = 2 then
  begin
    mMonth := 6;
    mDay := 30;
  end
  else if AQuarter = 3 then
  begin
    mMonth := 9;
    mDay := 30;
  end
  else if AQuarter = 4 then
  begin
    mMonth := 12;
    mDay := 31;
  end;

  Result := EncodeDate(AYear, mMonth, mDay);

end;

function GetCorrectSheetOrder(AExcel : Variant): Boolean;
begin
  Result := (AExcel.ActiveWorkbook.WorkSheets[cSheetJ1_1A].name = 'J1-1A') and
    (AExcel.ActiveWorkbook.WorkSheets[cSheetJ1_1B].name = 'J1-1B') and
    (AExcel.ActiveWorkbook.WorkSheets[cSheetJ1_1K].name = 'J1-1K') and
    (AExcel.ActiveWorkbook.WorkSheets[cSheetJ1_2A].name = 'J1-2A') and
    (AExcel.ActiveWorkbook.WorkSheets[cSheetJ1_3].name = 'J1-3') and
    (AExcel.ActiveWorkbook.WorkSheets[cSheetJ2].name = 'J2') and
    (AExcel.ActiveWorkbook.WorkSheets[cSheetO1_1A].name = 'O1-1A') and
    (AExcel.ActiveWorkbook.WorkSheets[cSheetO1_2A].name = 'O1-2A') and
    (AExcel.ActiveWorkbook.WorkSheets[cSheetO1_3].name = 'O1-3') and
    (AExcel.ActiveWorkbook.WorkSheets[cSheetO4].name = 'O4');
end;


begin
end.