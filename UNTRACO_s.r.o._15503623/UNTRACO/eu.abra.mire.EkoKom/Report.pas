uses
  'eu.abra.mire.EkoKom.Settings',
  'eu.abra.mire.EkoKom.Lib',
  'eu.abra.mire.EkoKom.Progress';

const cViewSQL =
'(' +
'SELECT ' +
'  CASE ' +
'    WHEN sd.Country_ID = (SELECT Country_ID FROM GlobData) THEN X_EKO_ZpoplatneniObalu ' +
'    ELSE 10 ' +
'  END AS X_EKO_ZpoplatneniObalu, ' +
'  X_EKO_TypObchodu, ' +
'  X_EKO_ZpusobUziti, ' +
'  X_EKO_ZpusobUvedeni, ' +
'  X_EKO_PuvodMaterialu, ' +
'  X_EKO_MaterialKompozitu, ' +
'  X_EKO_OpakovanePouzivany, ' +
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
'  * cast ((sd2.Quantity / su.UnitRate) as numeric(15, 3))) /1000/1000 as Numeric(15,3)) as Hmotnost, ' +
'  sd2.StoreCard_ID, ' +
'  sd.ID, ' +
'  sd.DocDate$DATE, ' +
'  sd.DocumentType ' +
'FROM StoreDocuments2 sd2 ' +
//'JOIN StoreDocuments sd ON sd.ID = sd2.Parent_ID AND sd.DocumentType IN (21, 23, 26) ' +  originál
'JOIN StoreDocuments sd ON sd.ID = sd2.Parent_ID AND sd.DocumentType IN (20) ' +
'JOIN StoreCards sc ON sc.ID = sd2.StoreCard_ID ' +
'JOIN DefRollData df ON df.hidden = ''N'' AND df.CLSID = ''3DROIEGQRFMOH4ZT4I53BZCXKO'' ' +
'  AND df.X_EKO_StoreCard_ID = sd2.StoreCard_ID ' +
'  AND ' +
'  ( ' +
'    (df.X_EKO_StoreCardUnit = sd2.QUnit) ' +
'    or ' +
'    ( ' +
'      df.X_EKO_StoreCardUnit <> sd2.QUnit ' +
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
  cZpoplatneniExport = 3;

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
  cSheetO1_1A = 16;
  cSheetO1_1B = 17;
  cSheetO1_1K = 18;
  cSheetO1_2A = 19;
  cSheetO1_2B = 20;
  cSheetO1_2K = 21;
  cSheetO1_3 = 22;
  cSheetO1_3K = 23;
  cSheetO2 = 24;
  cSheetO3 = 25;
  cSheetO4 = 26;
  cSheetS1 = 27;
  cSheetS2 = 28;
  cSheetS3 = 29;
var
  gStart : TDateTime;
  gEnd : TDateTime;
  gPeriodCondition : string;


procedure FillQReport(ASite: TSiteForm; ASpace : TNxCustomObjectSpace; AExcel : Variant);
var
  mSheet : Variant;
  mQuarter : Integer;
  mYear : Integer;
begin

  ProgressInit(ASite, 'Příprava výkazu...', 6);

  try
    ProgressSetPos(0);

    if not GetCorrectSheetOrder(AExcel) then
    begin
      ProgressDispose();
      NxShowSimpleMessage('Byla zvolena nekompatabilní verze výkazu EkoKomByla.' + #13#10 +
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
    ProgressSetPos(2);

    ProgressDispose();
    ProgressInit(ASite, 'Vyplňování výkazu...', 6);
    FillHeader(ASpace, AExcel.ActiveWorkbook.WorkSheets[cSheetUvod]);
    ProgressSetPos(3);

    FillValues(ASpace, AExcel);
    ProgressSetPos(4);

    FillValuesForEvaluate(ASpace, AExcel);
    ProgressSetPos(5);

    AExcel.ActiveWorkbook.WorkSheets[cSheetUvod].Select();
    AExcel.ActiveWorkbook.WorkSheets[cSheetUvod].Cells[1,1].Select();
    ProgressSetPos(6);

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
    '  SUM( ' +
    '  CASE ' +
    '    WHEN (DocumentType = 21) OR (DocumentType = 26) THEN Hmotnost ' +
    '    ELSE Hmotnost * (-1) ' +
    '  END) AS Hmotnost ' +
    'FROM ' +
    mViewSQL +
    gPeriodCondition +
    ' AND X_EKO_TypObchodu <> 2 ' +
    'GROUP BY X_EKO_ZpoplatneniObalu, X_EKO_TypObchodu, X_EKO_ZpusobUziti, ' +
    '  X_EKO_ZpusobUvedeni, X_EKO_PuvodMaterialu, X_EKO_MaterialKompozitu, X_EKO_MaterialObalu, ' +
    '  X_EKO_SkupinaMaterialu, X_EKO_BarvaObalu, X_EKO_ObsahujeNapoje, ' +
    '  X_EKO_VyrazTypObchodu, X_EKO_OpakovanePouzivany ';

  mData := TMemoryDataset.Create(nil);

  try
    ASpace.SQLSelect2(mSQL, mData);
    if mData.Active then
    begin
      mData.First();

      while not mData.EOF do
      begin
        ProcessDataRow(AExcel,
          mData.FieldByName('X_EKO_OpakovanePouzivany').AsInteger,
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
          CFxFloat.Max3(0, mData.FieldByName('Hmotnost').AsFloat)
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
    '  X_EKO_SkupinaMaterialu, ' +
    '  X_EKO_BarvaObalu, ' +
    '  X_EKO_ObsahujeNapoje, ' +
    '  CASE ' +
    '    WHEN (DocumentType = 21) OR (DocumentType = 26) THEN Hmotnost ' +
    '    ELSE Hmotnost * (-1) ' +
    '  END AS Hmotnost ' +
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
              if mData.FieldByName('DocumentType').AsInteger = 2 then
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
                mData.FieldByName('Hmotnost').AsFloat);
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

procedure ProcessDataRow(AExcel: Variant; AOpakovanePouzivany, AZpoplatneniObalu, ATypObchodu,
  AZpusobUziti, AZpusobUvedeni, APuvodMaterialu, AMaterialKompozitu, AMaterial, ASkupina, ABarva: Integer;
  AObsahujeNapoje: Boolean; AHmotnost : Extended);
var
  mRow : Integer;
  mCol : Integer;
  mSheet : Integer;
  mVal : Extended;
begin
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
      AExcel.ActiveWorkbook.WorkSheets[mSheet].Cells[mRow, mCol] := CFxFloat.Max3(0, mVal);
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
    else if (AZpoplatneniObalu = cZpoplatneniPredplaceny) and (AMaterialKompozitu = 0) then
      mSheet := cSheetJ2 // List J2 - Předplacené
    else if (AZpoplatneniObalu = cZpoplatneniNeplaceny) and (AMaterialKompozitu = 0) then
      mSheet := cSheetJ3 // List J3 - Neplacené
    else if (AZpoplatneniObalu = cZpoplatneniExport) and (AMaterialKompozitu = 0) then
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
  Smaže všechny zadané hodnoty
}
procedure ClearWorkbook(AExcel : Variant);
var
  mSheet : Integer;
  mRow : Integer;
  mCol : Integer;

  mSheetV : Variant;
  mCellV : Variant;
begin

  // Listy J1-1A až O4
  for mSheet := cSheetJ1_1A to cSheetO4 do
  begin
    mSheetV := AExcel.ActiveWorkbook.WorkSheets[mSheet];
    for mRow := 9 to 53 do
      for mCol := 5{E} to 20{T} do
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