const
  // pevné definice speciálních pozic; pokud není pozice označena číselným kódem, je určena pro hlavní sklad 001
  // zvláštní pozice hlavního skladu
  cStoreCardCategory_Z_ID = '1000000101';
  cStoreCardCategory_ZZ_ID = '2100000101';
  cStorePosition_ZZ_ID = 'NO00000101';
  cStorePosition_Service_ID = 'MO00000101';
  cStorePosition_Saw_ID = 'OO00000101';
  cStorePosition_OldHall_ID = 'IO00000101';
  // jedinečné pozice pro ostatní sklady
  cStorePosition_010_ID = 'JO00000101';
  cStorePosition_012_ID = 'KO00000101';
  cStorePosition_042_ID = 'LO00000101';
  // chybové pozice
  cStorePosition_Error_ID = 'PO00000101';
  cStorePosition_Error010_ID = '2V00000101';
  cStorePosition_Error012_ID = '3V00000101';
  cStorePosition_Error042_ID = '1V00000101';

  cStore_001_ID = '1400000101';
  cStore_010_ID = '1900000101';
  cStore_012_ID = '3A00000101';
  cStore_042_ID = '1L00000101';

  cIssueTurnoversPercentilLimit = 70; // limit, který rozděluje vysoko/nízko obrátkové (integer)

  cMaxCountInPosition = 3;            // maximální počet různého zboží v pozici (platí pouze pro vybrané X_Form)
  cMaxCountInPosition_TypeC = 2;    // maximální počet různého zboží v pozici (platí pouze pro zálohové pozice)
  cMaxCountInPosition_BigTube = 1;    // maximální počet různého zboží v pozici (platí pouze pro velké trubky a jekly)
  cMaxCountInPosition_Plate = 1;      // maximální počet různého zboží v pozici (platí pouze pro plechy)

////////////////////////////////////////////////////////////////////////////////

// pro kartu dohledá nejvhodnější skladovou pozici

procedure SetLogStorePositions(boDoc, boDocRow: TNxCustomBusinessObject);
var
  boStoreCard: TNxCustomBusinessObject;
  boStoreCard2: TNxCustomBusinessObject;
  mcStoreUnits: TNxCustomBusinessMonikerCollection;
  mcStoreUnits2: TNxCustomBusinessMonikerCollection;
  boStoreUnit: TNxCustomBusinessObject;
  boStoreUnit2: TNxCustomBusinessObject;
  SQLSelect: String;
  mdSQLResult: TMemoryDataset;
  I, J, K: Integer;
  bErrorPosition: Boolean;  // v případe výskytu nějaké chyby se vyplní chybová pozice

  // informace o kartě
  SC_X_Form: String;
  SC_X_Size: Double;
  SC_X_Size1: Double;
  SC_StoreCardCategory_ID: String;
  SC_X_SizeTemp: String;
  SC_X_IssueTurnoversPercentil: Double;
  SC_UnitWeightKg: Double;
  SC_UnitCapacityDm3: Double;
  Quantity: Double;

  SC_UnitWeightKg_2: Double;
  SC_UnitCapacityDm3_2: Double;

  // pole pozic a jejich parametry
  arLSP_ID: array of String;
  arLSP_Code: array of String;
  arLSP_Type: array of String;
  arLSP_BasicFreeWeight: array of Double;
  arLSP_BasicFreeSpaceDm3: array of Double;
  arLSP_ExistBatchesCount: array of Integer;
  arLSP_AbsCond_X_Size1Min: array of Double;
  arLSP_AbsCond_X_Size1Max: array of Double;
  arLSP_AbsCond_X_Size: array of Double;
  arLSP_DynCond_X_Size1: array of Double;
  arLSP_Used: array of Boolean;

  mcDocRows2: TNxCustomBusinessMonikerCollection;
  boDocRow2: TNxCustomBusinessObject;
  mcDocRows: TNxCustomBusinessMonikerCollection;
  boDocRowNew: TNxCustomBusinessObject;

  Store_ID: String;
  IsSuitPosition: Boolean;
  SuitPositionNr: Integer;
  CountInPosition: Integer;
  TargetNamePositionID: String;

  TempStr: String;

begin
  // inicializace
  bErrorPosition := False;
  SetLength(arLSP_ID, 0);
  SetLength(arLSP_Code, 0);
  SetLength(arLSP_Type, 0);
  SetLength(arLSP_BasicFreeWeight, 0);
  SetLength(arLSP_BasicFreeSpaceDm3, 0);
  SetLength(arLSP_ExistBatchesCount, 0);
  SetLength(arLSP_AbsCond_X_Size1Min, 0);
  SetLength(arLSP_AbsCond_X_Size1Max, 0);
  SetLength(arLSP_AbsCond_X_Size, 0);
  SetLength(arLSP_DynCond_X_Size1, 0);
  SetLength(arLSP_Used, 0);

  // přiřazení správného názvu fieldu
  if boDoc.GetFieldValueAsString('DocumentType') = '31' then  // NPZ
  begin
    TargetNamePositionID := 'StorePosition_ID';
  end;
  if boDoc.GetFieldValueAsString('DocumentType') = '32' then  // VPZ
  begin
    TargetNamePositionID := 'StorePosition_ID';
  end;
  if boDoc.GetFieldValueAsString('DocumentType') = '33' then  // PPZ
  begin
    TargetNamePositionID := 'IncomingStorePosition_ID';
  end;

  // Načíst info o kartě, size, výdejovost,...
  boStoreCard := boDocRow.ObjectSpace.CreateObject(Class_StoreCard);
  try
    boStoreCard.Load(boDocRow.GetFieldValueAsString('StoreCard_ID'), nil);
    SC_StoreCardCategory_ID := boStoreCard.GetFieldValueAsString('StoreCardCategory_ID');
    SC_X_Form := boStoreCard.GetFieldValueAsString('X_Form');
    SC_X_IssueTurnoversPercentil := boStoreCard.GetFieldValueAsFloat('X_IssueTurnoversPercentil');
    SC_X_Size1 := boStoreCard.GetFieldValueAsFloat('X_Size1');
    SC_X_SizeTemp := boStoreCard.GetFieldValueAsString('X_Size');
    SC_X_SizeTemp := Copy(SC_X_SizeTemp, NxCharPosR('-', SC_X_SizeTemp) + 1,  999);

    // dohledání hmotnosti/objemu karty
    boStoreCard.Load(boDocRow.GetFieldValueAsString('StoreCard_ID'), nil);
    mcStoreUnits := boStoreCard.GetLoadedCollectionMonikerForFieldCode(boStoreCard.GetFieldCode('StoreUnits'));
    for K := 0 to mcStoreUnits.Count - 1 do
    begin
      boStoreUnit := mcStoreUnits.BusinessObject(K);
      if boStoreUnit.GetFieldValueAsString('Code') = boStoreCard.GetFieldValueAsString('MainUnitCode') then
      begin
        SC_UnitWeightKg := boStoreUnit.GetFieldValueAsFloat('Weight') * GetWeightUnitToKg(boStoreUnit.GetFieldValueAsInteger('WeightUnit'));
        SC_UnitCapacityDm3 := boStoreUnit.GetFieldValueAsFloat('Capacity') * GetRateCapacityUnitToDm3(boStoreUnit.GetFieldValueAsInteger('CapacityUnit'));
      end;
    end;

    try
      SC_X_Size := StrToInt(SC_X_SizeTemp);
    except
      bErrorPosition := True;
    end;

    OutputDebugString('--------');
    OutputDebugString('SC_Code: ' + boStoreCard.GetFieldValueAsString('Code'));
    OutputDebugString('SC_Form: ' + SC_X_Form);
    OutputDebugString('SC_Size: ' + FloatToStr(SC_X_Size));
    OutputDebugString('SC_Siz1: ' + FloatToStr(SC_X_Size1));
    OutputDebugString('SC_Perc: ' + FloatToStr(SC_X_IssueTurnoversPercentil));
    OutputDebugString('Quantity = ' + FloatToStr(boDocRow.GetFieldValueAsFloat('Quantity')));
    OutputDebugString('RestQuantity = ' + FloatToStr(boDocRow.GetFieldValueAsFloat('RestQuantity')));
    OutputDebugString('InPositionQuantity = ' + FloatToStr(boDocRow.GetFieldValueAsFloat('InPositionQuantity')));

  finally
    boStoreCard.Free;
  end;

  // načtení dalších údajů
  Store_ID := boDocRow.GetFieldValueAsString('Store_ID');

  // správné naplnění položky V pozici
  if boDocRow.GetFieldValueAsFloat('RestQuantity') > 0 then
  begin
    Quantity := boDocRow.GetFieldValueAsFloat('RestQuantity');
  end
  else
  begin
    Quantity := boDocRow.GetFieldValueAsFloat('InPositionQuantity');
  end;
  boDocRow.SetFieldValueAsFloat('InPositionQuantity', Quantity);

  // pevné přiřazení pozic - dle skladu

  if Store_ID = cStore_010_ID then
  begin
    boDocRow.SetFieldValueAsString(TargetNamePositionID, cStorePosition_010_ID);
    Exit;
  end;

  if Store_ID = cStore_012_ID then
  begin
    boDocRow.SetFieldValueAsString(TargetNamePositionID, cStorePosition_012_ID);
    Exit;
  end;

  if Store_ID = cStore_042_ID then
  begin
    boDocRow.SetFieldValueAsString(TargetNamePositionID, cStorePosition_042_ID);
    Exit;
  end;

  // pevné přiřazení pozic - dle skladové karty (prakticky jen pro sklad 001)

  // pro karty typu "ZZ" existuje pevná pozice
  if SC_StoreCardCategory_ID in [cStoreCardCategory_ZZ_ID] then
  begin
    boDocRow.SetFieldValueAsString(TargetNamePositionID, cStorePosition_ZZ_ID);
    Exit;
  end;

  // pro karty typu "Z", s vazbou NPZ -> PR -> OV -> OP (tj. projektová objednávka) přiřadit pozici jako ZZ
  if SC_StoreCardCategory_ID in [cStoreCardCategory_Z_ID] then
  begin
    TempStr := SQLSelectFirstRow(boDoc.ObjectSpace, 'SELECT FIRST 1 SourceHeader_ID FROM ReceivedOrdersToIssuedOrders WHERE Target_ID = (SELECT ProvideRow_ID FROM StoreDocuments2 WHERE ID = ' + QuotedStr(boDocRow.GetFieldValueAsString('StoreDocRow_ID')) + ')');
    if not NxIsEmptyOID(TempStr) then
    begin
      boDocRow.SetFieldValueAsString(TargetNamePositionID, cStorePosition_ZZ_ID);
      Exit;
    end;
  end;

  // pro karty jiné než "ZZ" a "Z" (= služby atd.) existuje pevná samostatná pozice
  if not (SC_StoreCardCategory_ID in [cStoreCardCategory_ZZ_ID, cStoreCardCategory_Z_ID]) then
  begin
    boDocRow.SetFieldValueAsString(TargetNamePositionID, cStorePosition_Service_ID);
    Exit;
  end;

  // velkou kruhovou ocel ukládat na pilu
  if (SC_X_Form = 'BRF') or ((SC_X_Form = 'BR') and (SC_X_Size1 > 141)) then
  begin
    boDocRow.SetFieldValueAsString(TargetNamePositionID, cStorePosition_Saw_ID);
    Exit;
  end;

  // velké plechy na starou halu
  if ((SC_X_Form = 'P') or (SC_X_Form = 'PC') or (SC_X_Form = 'PCBFL') or (SC_X_Form = 'PCFL') or (SC_X_Form = 'PCGFL') or (SC_X_Form = 'PT')) and (SC_X_Size > 3000) then
  begin
    boDocRow.SetFieldValueAsString(TargetNamePositionID, cStorePosition_OldHall_ID);
    Exit;
  end;

  // blok pro karty, které mají vlastní pozice; načíst záznamy z definovatelného číselníku (seřadit podle prázdných a priorit)
  SQLSelect := Format('SELECT DRD.X_LSCR_Position_ID AS StorePosition_ID'
           + #13#10 + 'FROM DefRollData DRD'
           + #13#10 + 'JOIN LogStorePositions LSP ON LSP.ID = DRD.X_LSCR_Position_ID '
           + #13#10 + 'WHERE LSP.Hidden = ''N'' AND LSP.Frozen = ''N'' AND DRD.CLSID = ''454OQV2M0F041CPAXWNZV4PXRW'' AND DRD.X_LSCR_StoreCard_ID = %s'
           + #13#10 + 'ORDER BY CASE WHEN (SELECT COALESCE(count(1), 0) FROM LogStoreContents LSC WHERE LSC.ID = DRD.X_LSCR_Position_ID) = 0 THEN 0 ELSE 1 END, DRD.X_LSCR_InputPriority',
           [QuotedStr(boDocRow.GetFieldValueAsString('StoreCard_ID'))]);
  //OutputDebugString(SQLSelect);
  mdSQLResult := TMemoryDataset.Create(nil);
  try
    boDocRow.ObjectSpace.SQLSelect2(SQLSelect, mdSQLResult);
    if mdSQLResult.RecordCount > 0 then
    begin
      mdSQLResult.First;
      boDocRow.SetFieldValueAsString(TargetNamePositionID, mdSQLResult.FieldByName('StorePosition_ID').AsString);
      OutputDebugString('SC: ' + boDocRow.GetFieldValueAsString('StorePosition_ID.Code'));
      Exit;
    end;
  finally
    mdSQLResult.Free;
  end;

  // pro ostatní karty pokračujeme
  // načtení pozic a jejich parametrů možných pro kartu

  // dohledání možných pozic podle číselníku vazeb pozic na X_Form skladové karty - seřazení za patra, sloupce, ulice
  SQLSelect := Format('SELECT DISTINCT'
           + #13#10 + '  LSP.ID,'
           + #13#10 + '  LSP.Code,'
           + #13#10 + '  LSP.X_Type,'
           + #13#10 + '  LSP.BasicFreeWeight,' // včetně neprovedených dokladů
           + #13#10 + '  LSP.BasicFreeSpace,' // včetně neprovedených dokladů
           + #13#10 + '  (SELECT COALESCE(count(1), 0) FROM LogStoreContents LSC WHERE LSC.Parent_ID = LSP.ID) AS ExistBatchesCount,'
           + #13#10 + '  LSPTR.X_LSPTR_AbsCond_X_Size1,'
           + #13#10 + '  LSPTR.X_LSPTR_AbsCond_X_Size1Min,'
           + #13#10 + '  LSPTR.X_LSPTR_AbsCond_X_Size,'
           + #13#10 + '  LSPTR.X_LSPTR_DynCond_X_Size1'
           + #13#10 + 'FROM LogStorePositions LSP'
           + #13#10 + 'JOIN DefRollData LSPTR ON LSPTR.CLSID = %s AND LSPTR.Hidden = ''N'' AND LSPTR.X_LSPTR_Type = LSP.X_Type'
           + #13#10 + 'WHERE LSP.Hidden = ''N'''
           + #13#10 + '  AND LSP.Frozen = ''N'''
           + #13#10 + '  AND LSPTR.X_LSPTR_X_Form = %s', [QuotedStr('4LCWOLMNI2X43A1XTKQSNEP5Z0'), QuotedStr(SC_X_Form)])
           + #13#10 + 'ORDER BY'
           + #13#10 + '  CASE WHEN (LSP.X_Type = ''D'') AND ((LSPTR.X_LSPTR_X_Form = ''TRWG'') OR (LSPTR.X_LSPTR_X_Form = ''TRW'') OR (LSPTR.X_LSPTR_X_Form = ''TRH'')) THEN 0 ELSE 1 END,'  // toto je zbytečné, v budoucnu odstranit - trubky se řeší jinak
           + #13#10 + '  CASE WHEN (LSP.X_Type = ''C'') THEN 0 ELSE 1 END,'
           + #13#10 + '  CASE WHEN (LSP.X_Type = ''E'') THEN 0 ELSE 1 END,'
           + #13#10 + '  CASE WHEN (LSP.X_Type = ''F'') THEN 0 ELSE 1 END,'
           + #13#10 + '  CASE WHEN (' + IntToStr(Round(SC_X_IssueTurnoversPercentil)) + ' < ' + IntToStr(cIssueTurnoversPercentilLimit) + ') AND (LSP.X_ForHighTurnover = ''N'') THEN 0 ELSE 1 END,'
           + #13#10 + '  (SELECT count(1) FROM LogStoreContents LSC WHERE LSC.Parent_ID = LSP.ID),'
           + #13#10 + '  ib_string_right(LSP.Code, 2),'
           + #13#10 + '  ib_string_left(ib_string_right(LSP.Code, 3), 1),'
           + #13#10 + '  ib_string_left(ib_string_right(LSP.Code, 5), 2)';
  //OutputDebugString(SQLSelect);
  mdSQLResult :=  TMemoryDataset.Create(nil);
  try
    boDocRow.ObjectSpace.SQLSelect2(SQLSelect, mdSQLResult);
    if mdSQLResult.RecordCount > 0 then
    begin
      SetLength(arLSP_ID, mdSQLResult.RecordCount);
      SetLength(arLSP_Code, mdSQLResult.RecordCount);
      SetLength(arLSP_Type, mdSQLResult.RecordCount);
      SetLength(arLSP_BasicFreeWeight, mdSQLResult.RecordCount);
      SetLength(arLSP_BasicFreeSpaceDm3, mdSQLResult.RecordCount);
      SetLength(arLSP_ExistBatchesCount, mdSQLResult.RecordCount);
      SetLength(arLSP_AbsCond_X_Size1Min, mdSQLResult.RecordCount);
      SetLength(arLSP_AbsCond_X_Size1Max, mdSQLResult.RecordCount);
      SetLength(arLSP_AbsCond_X_Size, mdSQLResult.RecordCount);
      SetLength(arLSP_DynCond_X_Size1, mdSQLResult.RecordCount);
      SetLength(arLSP_Used, mdSQLResult.RecordCount);

      mdSQLResult.First;
      I := 0;
      while not mdSQLResult.Eof do
      begin
        arLSP_ID[I] := mdSQLResult.FieldByName('ID').AsString;
        arLSP_Code[I] := mdSQLResult.FieldByName('Code').AsString;
        arLSP_Type[I] := mdSQLResult.FieldByName('X_Type').AsString;
        arLSP_BasicFreeWeight[I] := mdSQLResult.FieldByName('BasicFreeWeight').AsFloat;
        arLSP_BasicFreeSpaceDm3[I] := mdSQLResult.FieldByName('BasicFreeSpace').AsFloat / 1000;
        arLSP_ExistBatchesCount[I] := mdSQLResult.FieldByName('ExistBatchesCount').AsInteger;
        arLSP_AbsCond_X_Size1Min[I] := mdSQLResult.FieldByName('X_LSPTR_AbsCond_X_Size1Min').AsFloat;
        arLSP_AbsCond_X_Size1Max[I] := mdSQLResult.FieldByName('X_LSPTR_AbsCond_X_Size1').AsFloat;
        arLSP_AbsCond_X_Size[I] := mdSQLResult.FieldByName('X_LSPTR_AbsCond_X_Size').AsFloat;
        arLSP_DynCond_X_Size1[I] := mdSQLResult.FieldByName('X_LSPTR_DynCond_X_Size1').AsFloat;
        arLSP_Used[I] := True;
        Inc(I);
        mdSQLResult.Next;
      end;
    end;
  finally
    mdSQLResult.Free;
  end;

  // vyloučení pozic, které nesplňují statické podmínky pro různé X_Form růžně

  // pro různé X_Form různé podmínky
  if SC_X_Form in ['P', 'PC', 'PCBFL', 'PCFL', 'PCGFL', 'PT'] then
  begin
    for I := 0 to Length(arLSP_ID) - 1 do
    begin
      //OutputDebugString(FloatToStr(SC_X_Size) + ' ' + FloatToStr(arLSP_AbsCond_X_Size[I]));
      if SC_X_Size <> arLSP_AbsCond_X_Size[I] then
      begin
        arLSP_Used[I] := False;
        //OutputDebugString(arLSP_Code[I] + ' off');
      end;
    end;
  end;
  if SC_X_Form in ['BR', 'TRH', 'TAW', 'TAWG', 'TRW', 'TRWG'] then
  begin
    for I := 0 to Length(arLSP_ID) - 1 do
    begin
      if (SC_X_Size1 <= arLSP_AbsCond_X_Size1Min[I]) or (SC_X_Size1 > arLSP_AbsCond_X_Size1Max[I]) then
      begin
        arLSP_Used[I] := False;
      end;
    end;
  end;

  // odstranění vypnutých pozic z polí
  RemoveNotUsedPositions(arLSP_ID, arLSP_Code, arLSP_Type, arLSP_BasicFreeWeight, arLSP_BasicFreeSpaceDm3, arLSP_ExistBatchesCount, arLSP_AbsCond_X_Size1Min, arLSP_AbsCond_X_Size1Max, arLSP_AbsCond_X_Size, arLSP_DynCond_X_Size1, arLSP_Used);

  // kontrola na hmotnost a objem
  boStoreCard2 := boDoc.ObjectSpace.CreateObject(Class_StoreCard);
  try
    for I := 0 to Length(arLSP_ID) - 1 do
    begin
      //OutputDebugString('SP_info: ' + arLSP_Code[I] + ' ' + NxBoolToStr(arLSP_Used[I]) + ' ' + arLSP_Type[I] + ' ' + NxBoolToString(arLSP_Used[I]));
      // pozice, které jsou již na dokladu - úprava arLSP_BasicFreeWeight a arLSP_BasicFreeCapacity
      mcDocRows2 := boDoc.GetLoadedCollectionMonikerForFieldCode(boDoc.GetFieldCode('Rows'));
      for J := 0 to mcDocRows2.Count - 1 do
      begin
        boDocRow2 := mcDocRows2.BusinessObject(J);
        if (arLSP_ID[I] = boDocRow2.GetFieldValueAsString(TargetNamePositionID)) and (boDocRow.OID <> boDocRow2.OID) then
        begin

          // dohledání hmotnosti/objemu karty
          boStoreCard2.Load(boDocRow2.GetFieldValueAsString('StoreCard_ID'), nil);
          mcStoreUnits2 := boStoreCard2.GetLoadedCollectionMonikerForFieldCode(boStoreCard2.GetFieldCode('StoreUnits'));
          for K := 0 to mcStoreUnits2.Count - 1 do
          begin
            boStoreUnit2 := mcStoreUnits2.BusinessObject(K);
            if boStoreUnit2.GetFieldValueAsString('Code') = boStoreCard2.GetFieldValueAsString('MainUnitCode') then
            begin
              SC_UnitWeightKg_2 := boStoreUnit2.GetFieldValueAsFloat('Weight') * GetWeightUnitToKg(boStoreUnit2.GetFieldValueAsInteger('WeightUnit'));
              SC_UnitCapacityDm3_2 := boStoreUnit2.GetFieldValueAsFloat('Capacity') * GetRateCapacityUnitToDm3(boStoreUnit2.GetFieldValueAsInteger('CapacityUnit'));
            end;
          end;

          // odečtení z volné hmotnosti/objemu
          arLSP_BasicFreeWeight[I] := arLSP_BasicFreeWeight[I] - boDocRow2.GetFieldValueAsFloat('InPositionQuantity') * SC_UnitWeightKg_2;
          arLSP_BasicFreeSpaceDm3[I] := arLSP_BasicFreeSpaceDm3[I] - boDocRow2.GetFieldValueAsFloat('InPositionQuantity') * SC_UnitCapacityDm3_2;

          OutputDebugString(arLSP_Code[I] + ': ' + FloatToStr(arLSP_BasicFreeWeight[I]));
          OutputDebugString(arLSP_Code[I] + ': ' + FloatToStr(boDocRow2.GetFieldValueAsFloat('InPositionQuantity') * SC_UnitWeightKg_2));
          OutputDebugString(arLSP_Code[I] + ': ' + FloatToStr(arLSP_BasicFreeSpaceDm3[I]));
          OutputDebugString(arLSP_Code[I] + ': ' + FloatToStr(boDocRow2.GetFieldValueAsFloat('InPositionQuantity') * SC_UnitCapacityDm3_2));
        end;
      end;

       // kontrola vůči uloženému v databázi ponížené o hmotnost/objem na dokladu
      if arLSP_BasicFreeWeight[I] < (boDocRow.GetFieldValueAsFloat('InPositionQuantity') * SC_UnitWeightKg) then
      begin
        arLSP_Used[I] := False;
      end;
      if arLSP_BasicFreeSpaceDm3[I] < (boDocRow.GetFieldValueAsFloat('InPositionQuantity') * SC_UnitCapacityDm3) then
      begin
        arLSP_Used[I] := False;
      end;

    end;

  finally
    boStoreCard2.Free;
  end;

  // odstranění vypnutých pozic z polí
  RemoveNotUsedPositions(arLSP_ID, arLSP_Code, arLSP_Type, arLSP_BasicFreeWeight, arLSP_BasicFreeSpaceDm3, arLSP_ExistBatchesCount, arLSP_AbsCond_X_Size1Min, arLSP_AbsCond_X_Size1Max, arLSP_AbsCond_X_Size, arLSP_DynCond_X_Size1, arLSP_Used);

  // pro každou pozici aplikovat dynamická pravidla, zda je možné uložit
  if SC_X_Form in ['TRS', 'HR', 'SA', 'SU', 'TAW', 'TAWG', 'TRWG', 'TRH', 'TRW', 'BF', 'BR', 'BS', 'BFS', 'BHC', 'BRC', 'BRG', 'BSC', 'BFC'] then
  begin
    SuitPositionNr := -1;
    for I := 0 to Length(arLSP_ID) - 1 do
    begin

      IsSuitPosition := True;  // předpokladá se, že pozice je vyhovující

      // načtení informací o obsahu pozice
      SQLSelect := Format('SELECT LSC.ID AS LSC_ID, SC.X_Form AS X_Form, SC.X_Size1 AS X_Size1, LSC.StoreBatch_ID, SC.ID AS SC_ID' // !!! načšítat i hmotost provedeného i neprovedeného
               + #13#10 + 'FROM LogStoreContents LSC'
               + #13#10 + 'JOIN StoreCards SC ON SC.ID = LSC.StoreCard_ID'
               + #13#10 + 'WHERE LSC.StoreBatch_ID <> %s'
               + #13#10 + '  AND Parent_ID = %s', [QuotedStr(boDocRow.GetFieldValueAsString('StoreBatch_ID')), QuotedStr(arLSP_ID[I])]);
      mdSQLResult :=  TMemoryDataset.Create(nil);
      try
        boDocRow.ObjectSpace.SQLSelect2(SQLSelect, mdSQLResult);

        // kontrola na počet naskladněných položek (zvlášť pro velké trubky a ostatní)
        CountInPosition := mdSQLResult.RecordCount;
        if arLSP_Type[I] in ['TM', 'TV'] then
        begin
          if CountInPosition >= cMaxCountInPosition_BigTube then
          begin
            IsSuitPosition := False;
          end;
        end
        else
        begin
          if arLSP_Type[I] in ['C'] then
          begin
            if CountInPosition >= cMaxCountInPosition_TypeC then
            begin
              IsSuitPosition := False;
            end;
          end
          else
          begin
            if CountInPosition >= cMaxCountInPosition then
            begin
              IsSuitPosition := False;
            end;
          end;
        end;

        // pokud v pozici nic nením kontrola ani neprovádí
        if IsSuitPosition and (CountInPosition > 0) then
        begin
          mdSQLResult.First;
          while not mdSQLResult.Eof do
          begin
            // kontrola na X_Size1 (
            if Abs(mdSQLResult.FieldByName('X_Size1').AsFloat - SC_X_Size1) < arLSP_DynCond_X_Size1[I] then
            begin
              IsSuitPosition := False;
            end;

            // kontrola na stejnou kartu (4. 9. 2015)
            if IsSuitPosition and (boDocRow.GetFieldValueAsString('StoreCard_ID') = mdSQLResult.FieldByName('SC_ID').AsString) then
            begin
              IsSuitPosition := False;
            end;

            mdSQLResult.Next;
          end;
        end;

      finally
        mdSQLResult.Free;
      end;

      // práce s pozicemi, které se na dokladu již vyskytují
      if IsSuitPosition then
      begin
        mcDocRows2 := boDoc.GetLoadedCollectionMonikerForFieldCode(boDoc.GetFieldCode('Rows'));
        for J := 0 to mcDocRows2.Count - 1 do
        begin
          boDocRow2 := mcDocRows2.BusinessObject(J);
          //OutputDebugString(IntToStr(J) + ': ' + arLSP_ID[I] + ' ' + boDocRow2.GetFieldValueAsString(TargetNamePositionID));
          if (arLSP_ID[I] = boDocRow2.GetFieldValueAsString(TargetNamePositionID)) and (boDocRow.GetFieldValueAsString('StoreBatch_ID') <> boDocRow2.GetFieldValueAsString('StoreBatch_ID')) then
          begin

            // kontrola na počet naskladněných položek
            // v pozici je navic i tato položka
            Inc(CountInPosition);
            //OutputDebugString('CountInPosition: ' + IntToStr(CountInPosition));
            if arLSP_Type[I] in ['TM', 'TV'] then
            begin
              if CountInPosition >= cMaxCountInPosition_BigTube then
              begin
                IsSuitPosition := False;
              end;
            end
            else
            begin
              if arLSP_Type[I] in ['C'] then
              begin
                if CountInPosition >= cMaxCountInPosition_TypeC then
                begin
                  IsSuitPosition := False;
                end;
              end
              else
              begin
                if CountInPosition >= cMaxCountInPosition then
                begin
                  IsSuitPosition := False;
                end;
              end;
            end;

            // kontrola na X_Size1 (pokud v pozici nic není nebo je v ní moc, pak se kontrola ani neprovádí
            if IsSuitPosition and (CountInPosition > 0) then
            begin
              if Abs(boDocRow2.GetFieldValueAsFloat('StoreCard_ID.X_Size1') - SC_X_Size1) < arLSP_DynCond_X_Size1[I] then
              begin
                IsSuitPosition := False;
              end;
            end;

            // kontrola na stejnou kartu (4. 9. 2015)
            if IsSuitPosition and (boDocRow2.GetFieldValueAsString('StoreCard_ID') = boDocRow.GetFieldValueAsString('StoreCard_ID')) then
            begin
               IsSuitPosition := False;
            end;

          end;
        end;
      end;

      // poslední kontrola na počet naskladněných položek
      if CountInPosition >= cMaxCountInPosition then
      begin
        IsSuitPosition := False;
      end;

      // nalezení vyhovující pozice - můžeme ukončit hledání
      if IsSuitPosition then
      begin
        SuitPositionNr := I;
        Break;
      end;

    end;
  end; // if SC_X_Form in [...]

  // pro každou pozici aplikovat dynamická pravidla, zda je možné uloži
  if SC_X_Form in ['P', 'PC', 'PCBFL', 'PCFL', 'PCGFL', 'PT',] then
  begin
    SuitPositionNr := -1;
    for I := 0 to Length(arLSP_ID) - 1 do
    begin

      IsSuitPosition := True;  // předpokladá se, že pozice je vyhovující

      // načtení informací o obsahu pozice
      SQLSelect := Format('SELECT LSC.ID, SC.X_Form, SC.X_Size1, LSC.StoreBatch_ID' // !!! načšítat i hmotost provedeného i neprovedeného
               + #13#10 + 'FROM LogStoreContents LSC'
               + #13#10 + 'JOIN StoreCards SC ON SC.ID = LSC.StoreCard_ID'
               + #13#10 + 'WHERE Parent_ID = %s', [QuotedStr(arLSP_ID[I])]);
      mdSQLResult :=  TMemoryDataset.Create(nil);
      try
        boDocRow.ObjectSpace.SQLSelect2(SQLSelect, mdSQLResult);

        // kontrola na počet naskladněných položek
        CountInPosition := mdSQLResult.RecordCount;
        if CountInPosition >= cMaxCountInPosition_Plate then
        begin
          IsSuitPosition := False;
        end;

      finally
        mdSQLResult.Free;
      end;

      // práce s pozicemi, které se na dokladu již vyskytují
      if IsSuitPosition then
      begin
        mcDocRows2 := boDoc.GetLoadedCollectionMonikerForFieldCode(boDoc.GetFieldCode('Rows'));
        for J := 0 to mcDocRows2.Count - 1 do
        begin
          boDocRow2 := mcDocRows2.BusinessObject(J);
          //OutputDebugString(IntToStr(J) + ': ' + arLSP_Code[I] + ' ' + boDocRow2.GetFieldValueAsString('StorePosition_ID.Code'));
          if arLSP_ID[I] = boDocRow2.GetFieldValueAsString(TargetNamePositionID) then
          begin
            //OutputDebugString('>>> ' + arLSP_Code[I]);
            // kontrola na počet naskladněných položek
            // v pozici je navic i tato položka
            Inc(CountInPosition);
            if CountInPosition >= cMaxCountInPosition_Plate then
            begin
              IsSuitPosition := False;
            end;

          end;
        end;
      end;

      // poslední kontrola na počet naskladněných položek - má smysl pro větší množství než 1, ale je zavedeno formálně i zde
      if CountInPosition >= cMaxCountInPosition_Plate then
      begin
        IsSuitPosition := False;
      end;

      // nalezení vyhovující pozice - můžeme ukončit hledání
      if IsSuitPosition then
      begin
        SuitPositionNr := I;
        Break;
      end;

    end;
  end; // if SC_X_Form in [...]

  // když nezbyde žádná pozice -> chybová pozice
  if (Length(arLSP_ID) = 0) or (SuitPositionNr = -1) then
  begin
    boDocRow.SetFieldValueAsString(TargetNamePositionID, cStorePosition_Error_ID);
  end
  else
  begin
    boDocRow.SetFieldValueAsString(TargetNamePositionID, arLSP_ID[SuitPositionNr]);
  end;

  // testovací výpis pozic
  {
  for I := 0 to Length(arLSP_ID) - 1 do
  begin
    OutputDebugString('SP_info: ' + arLSP_Code[I] + ' ' + NxBoolToStr(arLSP_Used[I]) + ' ' + arLSP_Type[I] + ' ' + NxBoolToString(arLSP_Used[I]));
  end;
  }

end;

////////////////////////////////////////////////////////////////////////////////

procedure RemoveNotUsedPositions(var arLSP_ID: array of String;
                                 var arLSP_Code: array of String;
                                 var arLSP_Type: array of String;
                                 var arLSP_BasicFreeWeight: array of Double;
                                 var arLSP_BasicFreeSpace: array of Double;
                                 var arLSP_ExistBatchesCount: array of Integer;
                                 var arLSP_AbsCond_X_Size1Min: array of Double;
                                 var arLSP_AbsCond_X_Size1Max: array of Double;
                                 var arLSP_AbsCond_X_Size: array of Double;
                                 var arLSP_DynCond_X_Size1: array of Double;
                                 var arLSP_Used: array of Boolean);

var
  I, J: Integer;
  arTmpLSP_ID: array of String;
  arTmpLSP_Code: array of String;
  arTmpLSP_Type: array of String;
  arTmpLSP_BasicFreeWeight: array of Double;
  arTmpLSP_BasicFreeSpace: array of Double;
  arTmpLSP_ExistBatchesCount: array of Integer;
  arTmpLSP_AbsCond_X_Size1Min: array of Double;
  arTmpLSP_AbsCond_X_Size1Max: array of Double;
  arTmpLSP_AbsCond_X_Size: array of Double;
  arTmpLSP_DynCond_X_Size1: array of Double;
  arTmpLSP_Used: array of Boolean;

begin

  // kopie polí do pomocných polí 1:1
  arTmpLSP_ID := arLSP_ID;
  arTmpLSP_Code := arLSP_Code;
  arTmpLSP_Type := arLSP_Type;
  arTmpLSP_BasicFreeWeight := arLSP_BasicFreeWeight;
  arTmpLSP_BasicFreeSpace := arLSP_BasicFreeSpace;
  arTmpLSP_ExistBatchesCount := arLSP_ExistBatchesCount;
  arTmpLSP_AbsCond_X_Size1Min := arLSP_AbsCond_X_Size1Min;
  arTmpLSP_AbsCond_X_Size1Max := arLSP_AbsCond_X_Size1Max;
  arTmpLSP_AbsCond_X_Size := arLSP_AbsCond_X_Size;
  arTmpLSP_DynCond_X_Size1 := arLSP_DynCond_X_Size1;
  arTmpLSP_Used := arLSP_Used;

  // postupná kopie z pomocných polí do hlavních, pouze pokud je pozice zapnutá
  J := 0;
  for I := 0 to Length(arTmpLSP_ID) - 1 do
  begin
    if arTmpLSP_Used[I] = True then
    begin
      arLSP_ID[J] := arLSP_ID[I];
      arLSP_Code[J] := arLSP_Code[I];
      arLSP_Type[J] := arLSP_Type[I];
      arLSP_BasicFreeWeight[J] := arLSP_BasicFreeWeight[I];
      arLSP_BasicFreeSpace[J] := arLSP_BasicFreeSpace[I];
      arLSP_ExistBatchesCount[J] := arLSP_ExistBatchesCount[I];
      arLSP_AbsCond_X_Size1Min[J] := arLSP_AbsCond_X_Size1Min[I];
      arLSP_AbsCond_X_Size1Max[J] := arLSP_AbsCond_X_Size1Max[I];
      arLSP_AbsCond_X_Size[J] := arLSP_AbsCond_X_Size[I];
      arLSP_DynCond_X_Size1[J] := arLSP_DynCond_X_Size1[I];
      arLSP_Used[J] := arLSP_Used[I];
      Inc(J);
    end;
  end;

  // nastavení (useknutí) velikosti hlavních polí
  SetLength(arLSP_ID, J);
  SetLength(arLSP_Type, J);
  SetLength(arLSP_BasicFreeWeight, J);
  SetLength(arLSP_BasicFreeSpace, J);
  SetLength(arLSP_ExistBatchesCount, J);
  SetLength(arLSP_AbsCond_X_Size1Min, J);
  SetLength(arLSP_AbsCond_X_Size1Max, J);
  SetLength(arLSP_AbsCond_X_Size, J);
  SetLength(arLSP_DynCond_X_Size1, J);
  SetLength(arLSP_Used, J);
end;

////////////////////////////////////////////////////////////////////////////////

procedure SwapPositions(I, J: Integer;
                        var arLSP_ID: array of String;
                        var arLSP_Code: array of String;
                        var arLSP_Type: array of String;
                        var arLSP_BasicFreeWeight: array of Double;
                        var arLSP_BasicFreeSpace: array of Double;
                        var arLSP_ExistBatchesCount: array of Integer;
                        var arLSP_AbsCond_X_Size1Min: array of Double;
                        var arLSP_AbsCond_X_Size1Max: array of Double;
                        var arLSP_AbsCond_X_Size: array of Double;
                        var arLSP_DynCond_X_Size1: array of Double;
                        var arLSP_Used: array of Boolean);
var
  TempLSP_ID: String;
  TempLSP_Code: String;
  TempLSP_Type: String;
  TempLSP_BasicFreeWeight: Double;
  TempLSP_BasicFreeSpace: Double;
  TempLSP_ExistBatchesCount: Integer;
  TempLSP_AbsCond_X_Size1Min: Double;
  TempLSP_AbsCond_X_Size1Max: Double;
  TempLSP_AbsCond_X_Size: Double;
  TempLSP_DynCond_X_Size1: Double;
  TempLSP_Used: Boolean;

begin
  TempLSP_ID := arLSP_ID[I];
  TempLSP_Code := arLSP_Code[I];
  TempLSP_Type := arLSP_Type[I];
  TempLSP_BasicFreeWeight := arLSP_BasicFreeWeight[I];
  TempLSP_BasicFreeSpace := arLSP_BasicFreeSpace[I];
  TempLSP_ExistBatchesCount := arLSP_ExistBatchesCount[I];
  TempLSP_AbsCond_X_Size1Min := arLSP_AbsCond_X_Size1Min[I];
  TempLSP_AbsCond_X_Size1Max := arLSP_AbsCond_X_Size1Max[I];
  TempLSP_AbsCond_X_Size := arLSP_AbsCond_X_Size[I];
  TempLSP_DynCond_X_Size1 := arLSP_DynCond_X_Size1[I];
  TempLSP_Used := arLSP_Used[I];

  arLSP_ID[I] := arLSP_ID[J];
  arLSP_Code[I] := arLSP_Code[J];
  arLSP_Type[I] := arLSP_Type[J];
  arLSP_BasicFreeWeight[I] := arLSP_BasicFreeWeight[J];
  arLSP_BasicFreeSpace[I] := arLSP_BasicFreeSpace[J];
  arLSP_ExistBatchesCount[I] := arLSP_ExistBatchesCount[J];
  arLSP_AbsCond_X_Size1Min[I] := arLSP_AbsCond_X_Size1Min[J];
  arLSP_AbsCond_X_Size1Max[I] := arLSP_AbsCond_X_Size1Max[J];
  arLSP_AbsCond_X_Size[I] := arLSP_AbsCond_X_Size[J];
  arLSP_DynCond_X_Size1[I] := arLSP_DynCond_X_Size1[J];
  arLSP_Used[I] := arLSP_Used[J];

  arLSP_ID[J] := TempLSP_ID;
  arLSP_Code[J] := TempLSP_Code;
  arLSP_Type[J] := TempLSP_Type;
  arLSP_BasicFreeWeight[J] := TempLSP_BasicFreeWeight;
  arLSP_BasicFreeSpace[J] := TempLSP_BasicFreeSpace;
  arLSP_ExistBatchesCount[J] := TempLSP_ExistBatchesCount;
  arLSP_AbsCond_X_Size1Min[J] := TempLSP_AbsCond_X_Size1Min;
  arLSP_AbsCond_X_Size1Max[J] := TempLSP_AbsCond_X_Size1Max;
  arLSP_AbsCond_X_Size[J] := TempLSP_AbsCond_X_Size;
  arLSP_DynCond_X_Size1[J] := TempLSP_DynCond_X_Size1;
  arLSP_Used[J] := TempLSP_Used;
end;

////////////////////////////////////////////////////////////////////////////////

function GetWeightUnitToKg(WeightUnit: Double): Double;
begin
  case WeightUnit of
    0: Result := 0.001; // g
    1: Result := 1;     // kg
    2: Result := 1000;  // t
  end;  // else není třeba
end;

////////////////////////////////////////////////////////////////////////////////

function GetRateCapacityUnitToDm3(CapacityUnit: Integer): Double;
begin
  case CapacityUnit of
    0: Result := 0.001; // ml
    1: Result := 1;     // l
    2: Result := 1000;  // m3
    3: Result := 0.01;  // cl
    4: Result := 0.1;   // dl
    5: Result := 100;   // hl
    6: Result := 0.001; // cm3 = ml
    7: Result := 1;     // dm3 = l
  end;
end;

////////////////////////////////////////////////////////////////////////////////

// určeno pro získání prvního záznamu SLQ dotazu, vrací text

function SQLSelectFirstRow(mOS: TNxCustomObjectSpace; SQLString: String): String;
var
  SQLResult: TStringList;

begin
  SQLResult := TStringList.Create;
  try
    mOS.SQLSelect(SQLString, SQLResult);
    if SQLResult.Count > 0 then
      Result := SQLResult.Strings(0)
    else
      Result := '';
  finally
    SQLResult.Free;
  end;
end;

////////////////////////////////////////////////////////////////////////////////

function GetUserWorkingPosition: Integer;
var
  Gx: Variant;
  SQLSelect: Variant;
  SQLResult: Variant;
  mID : string;
begin
  Result := 0; // předpoklad
  Gx := GetAbraOLEApplication;
  mID := Gx.ActiveUser;
  SQLSelect := Format('SELECT X_WorkingPosition FROM SecurityUsers WHERE ID = ''%s''', [mID]);
  SQLResult := TStringList.Create;
  SQLResult := Gx.SQLSelectAsRowSet(SQLSelect);
  if not SQLResult.Eof then
    Result := SQLResult.Data.ValueByName['X_WorkingPosition'];
end;

////////////////////////////////////////////////////////////////////////////////

procedure ClearNotPreparedRowsFromStoreDocument(var Self: TNxDocumentImportManager);
var
  iRow, iBatchRow: Integer;
  boRow, boBatchRow: TNxCustomBusinessObject;
  mcRows, mcBatchRows: TNxCustomBusinessMonikerCollection;
  BatchQuantity: Double;

begin
  mcRows := Self.OutputDocument.GetLoadedCollectionMonikerForFieldCode(Self.OutputDocument.GetFieldCode('Rows'));
  for iRow := 0 to mcRows.Count - 1 do
  begin
    boRow := mcRows.BusinessObject(iRow);
    if (boRow.GetFieldValueAsInteger('RowType') = 3) and (boRow.GetFieldValueAsBoolean('Store_ID.IsLogistic') = True) and (boRow.GetFieldValueAsInteger('StoreCard_ID.Category') in [1, 2]) then
    begin
      mcBatchRows := boRow.GetLoadedCollectionMonikerForFieldCode(boRow.GetFieldCode('DocRowBatches'));
      BatchQuantity := 0;
      for iBatchRow := 0 to mcBatchRows.Count - 1 do
      begin
        boBatchRow := mcBatchRows.BusinessObject(iBatchRow);
        BatchQuantity := BatchQuantity + boBatchRow.GetFieldValueAsFloat('Quantity');
      end;
      if BatchQuantity = 0 then
      begin
        boRow.MarkForDelete;
      end
      else
      begin
        boRow.SetFieldValueAsFloat('Quantity', BatchQuantity);
      end;
    end;
  end;
end;

////////////////////////////////////////////////////////////////////////////////

// kontrola, zda se na DL vyskytují stejné karty ze stejné OP - to je problémové
// pozor - v této nevizuální funkci se záměrně volá vizuální prvek MessageDlg
procedure DuplicateStoreCardInfo(var Self: TNxDocumentImportManager);
var
  I: Integer;
  boRow: TNxCustomBusinessObject;
  mcRows: TNxCustomBusinessMonikerCollection;
  slCompareRows, slDuplicateCards: TStringList;
  LastString: String;

begin
  slCompareRows := TStringList.Create;
  slDuplicateCards := TStringList.Create;
  try
    // načtení řádků do StringListu
    mcRows := Self.OutputDocument.GetLoadedCollectionMonikerForFieldCode(Self.OutputDocument.GetFieldCode('Rows'));
    for I := 0 to mcRows.Count - 1 do
    begin
      boRow := mcRows.BusinessObject(I);
      if (boRow.GetFieldValueAsInteger('RowType') = 3) and (boRow.GetFieldValueAsBoolean('Store_ID.IsLogistic') = True) and (boRow.GetFieldValueAsInteger('StoreCard_ID.Category') in [1, 2]) and (not ((osDeleted in boRow.State) or (osMarkForDelete in boRow.State))) then
      begin
        // načítáme ID objednávky, kód a název do jednoho řetězce
        slCompareRows.Add(boRow.GetFieldValueAsString('Provide_ID') + boRow.GetFieldValueAsString('StoreCard_ID.Code') + ' - ' + boRow.GetFieldValueAsString('StoreCard_ID.Name'));
      end;
    end;

    // seřazení načtených dat
    slCompareRows.Sort;

    // dohledání duplicitních řádků (ID objednávky a karta jsou stejné)
    LastString := '';
    for I := 0 to slCompareRows.Count - 1 do
    begin
      if LastString = slCompareRows.Strings(I) then
      begin
        slDuplicateCards.Add(Copy(slCompareRows.Strings(I), 11, 999));
      end;
      LastString := slCompareRows.Strings(I);
    end;

    // výpis - pozor - jedná se sice o nevizuální funkci, ale vyvolání vizuální informace je nutné
    if slDuplicateCards.Count > 0 then
    begin
      MessageDlg('Na dokladu se nachází duplicitní karty ze stejné objednávky přijaté.' + #13#10 + slDuplicateCards.Text, mtWarning, [mbOK], 0);
    end;

  finally
    slCompareRows.Free;
    slDuplicateCards.Free;
  end;
end;

////////////////////////////////////////////////////////////////////////////////

begin
end.