uses
  'ABRA.RAHU.Stappert.LogStore.Support.Common';

////////////////////////////////////////////////////////////////////////////////

const
  cLogStoreTransferDocQueue_ID = '3Z20000101';
  cSplitConditions = ['zakazky_dily', 'zakazky_plechy', 'zakazky_ostatni', 'dily', 'stara_hala', 'plechy', 'pila', 'trubky', 'nova_hala'];  // definice podmínek v bloku mazání řádků, závislé na pořadí

////////////////////////////////////////////////////////////////////////////////
// ovládací akce

procedure FormCreate_Hook(Self: TSiteForm);
var
  mAction: TBasicAction;
begin
  if (GetUserWorkingPosition() = 2) or (GetUserWorkingPosition() = 3) then
  begin
    mAction := Self.GetNewAction;
    mAction.ShowControl := True;
    mAction.ShowMenuItem := True;
    mAction.Name := 'actNewPreparation';
    mAction.Caption := 'Připravit k vychystání';
    mAction.Hint := 'Připravit k vychystání (PPZ)';
    mAction.Category := 'tabList';
    //mAction.ShortCut := TextToShortCut('CTRL+V');
    mAction.OnExecute := @NewPreparation_OnExecute;
    mAction.OnUpdate:= @NewPreparation_OnUpdate;  // spouští se hodně často&#xD;
  end;
end;


////////////////////////////////////////////////////////////////////////////////

//nastavení, kdy bude tlačítko k dispozici
procedure NewPreparation_OnUpdate(Sender: TObject);
var
  mSiteForm: TSiteForm;
begin
  if Sender is TComponent then
  begin
    mSiteForm := NxFindSiteForm(TComponent(Sender));
    if Assigned(mSiteForm) then
    begin
      TBasicAction(Sender).Enabled := (not TDynSiteForm(mSiteForm).Edit) and not TDynSiteForm(mSiteForm).ActiveDataset.IsEmpty;
    end;
  end;
end;

////////////////////////////////////////////////////////////////////////////////

procedure NewPreparation_OnExecute(Sender: TObject);
var
  mSiteForm: TSiteForm;
  mOS: TNxCustomObjectSpace;
  mParam: TNxParameters;

  ROIDs: TStringList;
  iROs: Integer;
  boRO: TNxCustomBusinessObject;
  mImportManager: TNxDocumentImportManager;
  boOutputDoc: TNxCustomBusinessObject;
  mcOutputRows: TNxCustomBusinessMonikerCollection;
  boOutputRow: TNxCustomBusinessObject;
  boNewOutputRow: TNxCustomBusinessObject;

  SQLString: String;

  mdLogStoreContents: TMemoryDataset;
  mdStorePreferredBatches: TMemoryDataset;
  bIsStorePreferredBatches: Boolean;
  PickingPosition_ID: String;

  slStoresID: TStringList;
  iStores: Integer;

  RemainOutputRowQuantity: Double;
  PositionQuantity: Double;
  InsertOutputRowQuantity: Double;
  FreeStoreBatchQuantity: Double;

  slSQLResult: TStringList;

  bOriginalRow: Boolean;
  bAllQuantity: Boolean;

  iOutputRows: Integer;
  iStoreBatches: Integer;

  iSplitConditions: Integer;
  iRow: Integer;

  bMarkAllRowForDelete: Boolean;
  slResultInfo: TStringList;

  arFreeStoreBatchIDs: array of string;
  arFreeStoreBatchQuantity: array of Double;

  ReceiptQuantity: Double;  // množství na připojené PR (tzv. zakázkový prodej)
  bDirectSale: Boolean;     // info, že se jedná o zakázkový prodej
  TempPreferredQuanty: Double;
  TempContentQuantity: Double;
  bTempExistPreferredInContent: Boolean;

begin
  if Sender is TComponent then
  begin
    mSiteForm := NxFindSiteForm(TComponent(Sender));
    if Assigned(mSiteForm) then
    begin
      if NxMessageBox('Dotaz', 'Opravdu chcete připravit označené doklad k vychystávání?', mdConfirm, mdbYesNo, 0, 0, False, Nil) = mrYes then
      begin

        mOS := mSiteForm.BaseObjectSpace;
        boRO := mOS.CreateObject(Class_ReceivedOrder);
        slResultInfo := TStringList.Create;
        ROIDs := TStringList.Create;
        try
          TDynSiteForm(mSiteForm).FillListWithSelectedRows(ROIDs);
          bAllQuantity := True;
          slResultInfo.Sorted := True;
          slResultInfo.Duplicates := dupIgnore;
          for iROs := 0 to ROIDs.Count - 1 do
          begin
            boRO.Load(ROIDs.Strings(iROs), nil);
            OutputDebugString('--- doklad ---');
            OutputDebugString(boRO.GetFieldValueAsString('DisplayName'));
            OutputDebugString(boRO.OID);

            {
            // kontrola, zda je k OP již nějaká pozice připojená - vypnuto - buď se použije stávající nebo se připojí nová
            SQLString := Format('SELECT LSP.ID FROM LogStorePositions LSP WHERE LSP.ReservedForDocType = %s AND LSP.ReservedForDoc_ID = %s AND LSP.PositionType = 1 ORDER BY LSP.Code', [QuotedStr('RO'), QuotedStr(boRO.OID)]);
            //OutputDebugString(SQLString);
            PickingPosition_ID := SQLSelectFirstRow(mOS, SQLString);
            if not NxIsEmptyOID(PickingPosition_ID) then
            begin
              MessageDlg('Doklad již má připojenou vychystávací pozici.', mtWarning, [mbOK], 0);
              Exit;
            end;
            }

            // kontrola, má smyls OP vychystávat - už připravená v plné výši
            if boRO.GetFieldValueAsBoolean('Closed') then
            begin
              MessageDlg('Doklad ' + boRO.GetFieldValueAsString('DisplayName') +' je vyřízený a není možné ho vychystávat.', mtWarning, [mbOK], 0);
              Exit;
            end;

            {
            // kontrola, má smyls OP vychystávat - vychystaná OP - na požadavek vypnuto
            SQLString := Format('SELECT COALESCE(sum(Quantity), 0)'
                     + #13#10 + 'FROM'
                     + #13#10 + '('
                     + #13#10 + '  SELECT'
                     + #13#10 + '    sum(CASE WHEN RO2.Quantity < RO2.DeliveredQuantity THEN 0 ELSE RO2.Quantity - RO2.DeliveredQuantity END)'
                     + #13#10 + '    -'
                     + #13#10 + '    (SELECT COALESCE(sum(LSD2.Quantity), 0) FROM LogStoreDocuments LSD JOIN LogStoreDocuments2 LSD2 ON LSD2.Parent_ID = LSD.ID WHERE LSD.ReservedForDoc_ID = RO.ID AND LSD2.StoreCard_ID = RO2.StoreCard_ID AND LSD2.MasterRow_ID IS NULL) AS Quantity'
                     + #13#10 + '  FROM ReceivedOrders2 RO2 JOIN ReceivedOrders RO ON RO.ID = RO2.Parent_ID'
                     + #13#10 + '  WHERE RO.ID = %s AND RO2.RowType = 3'
                     + #13#10 + '  GROUP BY RO.ID, RO2.StoreCard_ID'
                     + #13#10 + '  HAVING'
                     + #13#10 + '    sum(CASE WHEN RO2.Quantity < RO2.DeliveredQuantity THEN 0 ELSE RO2.Quantity - RO2.DeliveredQuantity END)'
                     + #13#10 + '    >'
                     + #13#10 + '    (SELECT COALESCE(sum(LSD2.Quantity), 0) FROM LogStoreDocuments LSD JOIN LogStoreDocuments2 LSD2 ON LSD2.Parent_ID = LSD.ID WHERE LSD.ReservedForDoc_ID = RO.ID AND LSD2.StoreCard_ID = RO2.StoreCard_ID AND LSD2.MasterRow_ID IS NULL)'
                     + #13#10 + ')',
                     [QuotedStr(boRO.OID)]);
            //OutputDebugString(SQLString);
            if StrToFloat(SQLSelectFirstRow(mOS, SQLString)) = 0 then
            begin
              MessageDlg('Doklad není třeba vychystávat.', mtWarning, [mbOK], 0);
              Exit;
            end;
            }

            // případné připojení volných vychystávací pozice pro všechny požité sklady s kontrolou dříve připojených
            slStoresID := TStringList.Create;
            try
              // zjiští se, jaké polohované sklady se na dokladu používají
              SQLString := Format('SELECT DISTINCT S.ID FROM ReceivedOrders2 RO2 LEFT JOIN Stores S ON S.ID = RO2.Store_ID WHERE RO2.Parent_ID = %s AND S.IsLogistic = ''A''', [QuotedStr(boRO.OID)]);
              //OutputDebugString(SQLString);
              mOS.SQLSelect(SQLString, slStoresID);
              for iStores := 0 to slStoresID.Count - 1 do
              begin
                // pro každý sklad zkontroluje, zda je již pozice připojena
                PickingPosition_ID := GetPickingPosition(mOS, boRO.OID, slStoresID.Strings(iStores));
                if NxIsEmptyOID(PickingPosition_ID) then
                begin
                  // pokud není připojena, dohledá se a připojí se
                  SQLString := Format('SELECT LSP.ID FROM LogStorePositions LSP WHERE LSP.ReservedForDoc_ID IS NULL AND LSP.PositionType = 1 AND LSP.Store_ID = %s ORDER BY LSP.Code', [QuotedStr(slStoresID.Strings(iStores))]);
                  //OutputDebugString(SQLString);
                  PickingPosition_ID := SQLSelectFirstRow(mOS, SQLString);
                  if PickingPosition_ID = '' then
                  begin
                    MessageDlg(Format(boRO.GetFieldValueAsString('DisplayName') + ': ' + 'Není volná žádná vychystávací pozice pro sklad ID: %s. Doklad nebude připraven k vychystávání.', [slStoresID.Strings(iStores)]), mtWarning, [mbOK], 0);   // !!! ne ID skladu ale kód
                  end
                  else
                  begin
                    // připojení vychystávací pozice k dokladu
                    SQLString := Format('UPDATE LogStorePositions LSP SET LSP.ReservedForDocType = %s, LSP.ReservedForDoc_ID = %s WHERE LSP.ID = %s', [QuotedStr('RO'), QuotedStr(boRO.OID), QuotedStr(PickingPosition_ID)]);
                    //OutputDebugString(SQLString);
                    mOS.SQLExecute(SQLString);
                  end;
                end;
              end;
            finally
              slStoresID.Free;
            end;

            for iSplitConditions := 0 to Length(cSplitConditions) - 1 do  // tímto se rozděluje OP na více PPZ dokladů
            begin
              OutputDebugString('--- rozdělující podmínka ---');
              OutputDebugString(cSplitConditions[iSplitConditions]);
              try
                mImportManager := NxCreateDocumentImportManager(mOS, Class_ReceivedOrder, Class_LogStoreTransfer);
                try

                  // tvorba PPZ z OP
                  mImportManager.AddInputDocument(boRO.OID);
                  mParam:= TNxParameters.Create;
                  try
                    mImportManager.SaveParams(mParam);
                    mParam.GetOrCreateParam(dtString, 'DocQueue_ID').AsString := cLogStoreTransferDocQueue_ID;
                    mImportManager.LoadParams(mParam);
                  finally
                    mParam.Free;
                  end;
                  mImportManager.Execute;

                  boOutputDoc := mImportManager.OutputDocument;
                  mcOutputRows := boOutputDoc.GetLoadedCollectionMonikerForFieldCode(boOutputDoc.GetFieldCode('Rows'));
                  for iOutputRows := 0 to mcOutputRows.Count - 1 do
                  begin
                    boOutputRow := mcOutputRows.BusinessObject(iOutputRows);
                    RemainOutputRowQuantity := boOutputRow.GetFieldValueAsFloat('Quantity');

                    // zjištění, zda je karta na OP v režimu zakázkového prodeje (ZZ) = existuje připojená PR
                    // pro zakázkový prodej ZZ se množství "v pozici" navýší množství dle příjemky
                    // pouze pro hlavní sklad 001
                    ReceiptQuantity := GetReceiptQuantity(boOutputRow);
                    OutputDebugString('ReceiptQuantity: ' + FloatToStr(ReceiptQuantity));
                    if (boOutputRow.GetFieldValueAsString('Store_ID') = cStore_001_ID) and (ReceiptQuantity > 0) and (ReceiptQuantity > RemainOutputRowQuantity) then
                    begin
                      slResultInfo.Add('Zakázkový prodej: ' + boRO.GetFieldValueAsString('DisplayName')
                                       + ': ' + boOutputRow.GetFieldValueAsString('StoreCard_ID.Code')
                                       + ' - ' + boOutputRow.GetFieldValueAsString('StoreCard_ID.Name')
                                       + '; počet na OP: ' + FormatFloat('0.00,', RemainOutputRowQuantity)
                                       + '; počet na PR: ' + FormatFloat('0.00,', ReceiptQuantity) + '.');
                      RemainOutputRowQuantity := ReceiptQuantity;
                      bDirectSale := True;
                    end
                    else
                    begin
                      bDirectSale := False;
                    end;

                    //OutputDebugString('OutputRowQuantity:' + FloatToStr(boOutputRow.GetFieldValueAsFloat('Quantity')));
                    OutputDebugString('--- řádek - karta ---');
                    OutputDebugString(boOutputRow.GetFieldValueAsString('StoreCard_ID.Code'));
                    bOriginalRow := True;

                    if boOutputRow.GetFieldValueAsInteger('StoreCard_ID.Category') = 2 {šarže} then
                    begin // pro šarže

                      mdLogStoreContents := TMemoryDataset.Create(nil);
                      mdStorePreferredBatches := TMemoryDataset.Create(nil);
                      try

                        // přednostní zjištění, zda existují přeferovaná šarže na OP pro skladovou kartu na řádku PPZ
                        SQLString := Format('SELECT RO2.X_PreferredStoreBatch_ID X_PreferredStoreBatch_ID, sum(RO2.Quantity) Quantity'
                                 + #13#10 + 'FROM ReceivedOrders2 RO2'
                                 + #13#10 + 'JOIN ReceivedOrders RO ON RO.ID = RO2.Parent_ID'
                                 + #13#10 + 'WHERE RO.ID = %s'
                                 + #13#10 + '  AND RO2.StoreCard_ID = %S'
                                 + #13#10 + '  AND RO2.X_PreferredStoreBatch_ID IS NOT NULL -- zajímají nás pouze karty s preferovanou šarží'
                                 + #13#10 + '  AND RO2.Quantity > RO2.DeliveredQuantity'
                                 + #13#10 + 'GROUP BY RO2.X_PreferredStoreBatch_ID',
                                 [QuotedStr(boRO.OID), QuotedStr(boOutputRow.GetFieldValueAsString('StoreCard_ID'))]);
                        mOS.SQLSelect2(SQLString, mdStorePreferredBatches);

                        // v případě, že budou šarže preferované, nastaví se příznak
                        bIsStorePreferredBatches := False;
                        if Assigned(mdStorePreferredBatches) then
                        begin
                          if mdStorePreferredBatches.Active then
                          begin
                            bIsStorePreferredBatches := True;
                          end;
                        end;

                        // hlavní dotaz
                        // je modifikován (minimalizován) dle bDirectSale (zakázkový prodej ZZ)
                        SQLString := Format('SELECT'
                                + #13#10 + '  LSP.ID AS LSP_ID,'
                                + #13#10 + '  LSP.Code AS LSP_Code,'
                                + #13#10 + '  LSC.Quantity - LSC.QuantityReserved AS LSC_Quantity,'
                                + #13#10 + '  SB.ID AS SB_ID,'
                                + #13#10 + '  SB.Name AS SB_Name'
                                + #13#10 + 'FROM LogStoreContents LSC'
                                + #13#10 + 'JOIN LogStorePositions LSP ON LSP.ID = LSC.Parent_ID'
                                + #13#10 + 'JOIN StoreBatches SB ON SB.ID = LSC.StoreBatch_ID'
                                + #13#10 + 'JOIN StoreCards SC ON SC.ID = LSC.StoreCard_ID'
                                + #13#10 + 'JOIN StoreSubBatches SSB ON SSB.StoreBatch_ID = SB.ID AND SSB.Store_ID = LSP.Store_ID'
                                + #13#10 + 'WHERE LSP.Store_ID = ''%1:s'''
                                + #13#10 + '  AND LSC.StoreCard_ID = ''%0:s'''
                                + #13#10 + '  AND SSB.Quantity > 0'
                                + #13#10 + '  AND LSC.Quantity - LSC.QuantityReserved > 0'
                                + #13#10 + '  AND LSP.PositionType IN (0, 2)'
                                + #13#10 + '  AND LSP.X_Type <> ''X'' /* tyto nebereme v úvahu */'
                                + #13#10 + NxIIfStr(bDirectSale, '  AND LSP.ID = ' + QuotedStr(cStorePosition_ZZ_ID), '')
                                + #13#10 + 'ORDER BY'
                                + #13#10 + '  CASE WHEN (ib_string_left(SC.X_Form, 1) = ''P'') AND (LSP.ID = ' + QuotedStr(cStorePosition_OldHall_ID) + ') THEN 0 ELSE 1 END,'
                                + #13#10 + '  CASE WHEN (LSP.PositionType = 0) AND (LSP.X_Type <> ''C'') THEN 0 ELSE CASE WHEN (LSP.PositionType = 0) AND (LSP.X_Type = ''C'') THEN 1 ELSE 2 END END,'
                                + #13#10 + '  SB.ExpirationDate$Date,'
                                + #13#10 + '  LSC.Quantity - LSC.QuantityReserved DESC',
                                [boOutputRow.GetFieldValueAsString('StoreCard_ID'), boOutputRow.GetFieldValueAsString('Store_ID')]);
                        //OutputDebugString(SQLString);
                        mOS.SQLSelect2(SQLString, mdLogStoreContents);

                        if not Assigned(mdLogStoreContents) then
                        begin
                          boOutputRow.SetFieldValueAsString('StorePosition_ID', cStorePosition_Error_ID); // řádek s touto pozicí se odstraní níže
                        end
                        else
                        begin
                          if not mdLogStoreContents.Active then
                          begin
                            boOutputRow.SetFieldValueAsString('StorePosition_ID', cStorePosition_Error_ID); // řádek s touto pozicí se odstraní níže
                          end
                          else
                          begin

                            // modifikace mdLogStoreContents dle bIsStorePreferredBatches
                            if bIsStorePreferredBatches then
                            begin
                              mdLogStoreContents.First;
                              while not mdLogStoreContents.Eof do
                              begin
                                mdLogStoreContents.Edit;
                                bTempExistPreferredInContent := False;
                                mdStorePreferredBatches.First;
                                while not mdStorePreferredBatches.Eof do
                                begin
                                  mdStorePreferredBatches.Edit;
                                  if mdLogStoreContents.FieldByName('SB_ID').AsString = mdStorePreferredBatches.FieldByName('X_PreferredStoreBatch_ID').AsString then
                                  begin
                                    bTempExistPreferredInContent := True;
                                    TempPreferredQuanty := mdStorePreferredBatches.FieldByName('Quantity').AsFloat;
                                    TempContentQuantity := mdLogStoreContents.FieldByName('LSC_Quantity').AsFloat;
                                    if TempPreferredQuanty = 0 then
                                    begin
                                      TempContentQuantity := 0;
                                    end
                                    else
                                    begin
                                      if TempContentQuantity >= TempPreferredQuanty then
                                      begin
                                        TempContentQuantity := TempPreferredQuanty;
                                        TempPreferredQuanty := 0
                                      end
                                      else
                                      begin
                                        TempPreferredQuanty := TempPreferredQuanty - TempContentQuantity;
                                      end;
                                    end;
                                    mdStorePreferredBatches.FieldByName('Quantity').AsFloat := TempPreferredQuanty;
                                    mdLogStoreContents.FieldByName('LSC_Quantity').AsFloat := TempContentQuantity;
                                  end;
                                  mdStorePreferredBatches.Post;
                                  mdStorePreferredBatches.Next;
                                end;
                                if not bTempExistPreferredInContent then
                                begin
                                  mdLogStoreContents.FieldByName('LSC_Quantity').AsFloat := 0;
                                end;
                                mdLogStoreContents.Post;
                                mdLogStoreContents.Next;
                              end;
                            end;

                            SetLength(arFreeStoreBatchIDs, 0);
                            SetLength(arFreeStoreBatchQuantity, 0);
                            mdLogStoreContents.First;
                            while not mdLogStoreContents.Eof do
                            begin

                              // načtení množství v pozici
                              PositionQuantity := mdLogStoreContents.FieldByName('LSC_Quantity').AsFloat;
                              if not bIsStorePreferredBatches then
                              begin
                                // úprava množství v pozici s ohledem na preferované šarže a rezervované množství
                                FreeStoreBatchQuantity := SetAndGetStoreBatchFreeQuantity(mOS, boOutputRow, mdLogStoreContents.FieldByName('SB_ID').AsString, PositionQuantity, arFreeStoreBatchIDs, arFreeStoreBatchQuantity);
                                if FreeStoreBatchQuantity < PositionQuantity then
                                begin
                                  PositionQuantity := FreeStoreBatchQuantity; // případné nastavení disponibilního stavu
                                end;
                              end;

                              // vkládané množství do řádku PPZ
                              InsertOutputRowQuantity := Min_1(PositionQuantity, RemainOutputRowQuantity);
                              RemainOutputRowQuantity := RemainOutputRowQuantity - InsertOutputRowQuantity;

                              {
                              OutputDebugString('--- volné pozice ---');
                              OutputDebugString(mdLogStoreContents.FieldByName('SB_Name').AsString);
                              OutputDebugString(mdLogStoreContents.FieldByName('LSP_Code').AsString);
                              OutputDebugString('v pozici: ' + FloatToStr(mdLogStoreContents.FieldByName('LSC_Quantity').AsFloat));
                              OutputDebugString('volné   : ' + FloatToStr(FreeStoreBatchQuantity));
                              OutputDebugString('disponib: ' + FloatToStr(PositionQuantity));
                              OutputDebugString('vloženo : ' + FloatToStr(InsertOutputRowQuantity));
                              OutputDebugString('zbývá vl: ' + FloatToStr(RemainOutputRowQuantity));
                              }

                              if InsertOutputRowQuantity > 0 then
                              begin
                                if bOriginalRow then
                                begin
                                  boOutputRow.SetFieldValueAsString('StoreBatch_ID', mdLogStoreContents.FieldByName('SB_ID').AsString);
                                  boOutputRow.SetFieldValueAsFloat('Quantity', InsertOutputRowQuantity);
                                  boOutputRow.SetFieldValueAsFloat('InPositionQuantity', InsertOutputRowQuantity);
                                  boOutputRow.SetFieldValueAsString('StorePosition_ID', mdLogStoreContents.FieldByName('LSP_ID').AsString);
                                  if bIsStorePreferredBatches then
                                  begin
                                    boOutputRow.SetFieldValueAsBoolean('X_IsPreferredStoreBatch', True);
                                  end;
                                  bOriginalRow := False;
                                  //OutputDebugString('- bOriginalRow+');
                                  //OutputDebugString(boOutputRow.GetFieldValueAsString('StorePosition_ID'));
                                  //OutputDebugString(FloatToStr(boOutputRow.GetFieldValueAsFLoat('Quantity')));
                                end
                                else
                                begin
                                  boNewOutputRow := mcOutputRows.AddNewObject;
                                  boNewOutputRow.SetFieldValueAsString('Store_ID', boOutputRow.GetFieldValueAsString('Store_ID'));
                                  boNewOutputRow.SetFieldValueAsString('StoreCard_ID', boOutputRow.GetFieldValueAsString('StoreCard_ID'));
                                  boNewOutputRow.SetFieldValueAsString('StoreBatch_ID', mdLogStoreContents.FieldByName('SB_ID').AsString);
                                  boNewOutputRow.SetFieldValueAsString('QUnit', boOutputRow.GetFieldValueAsString('QUnit'));
                                  boNewOutputRow.SetFieldValueAsFLoat('Quantity', InsertOutputRowQuantity);
                                  boNewOutputRow.SetFieldValueAsFLoat('InPositionQuantity', InsertOutputRowQuantity);
                                  boNewOutputRow.SetFieldValueAsFLoat('UnitRate', boOutputRow.GetFieldValueAsFloat('UnitRate'));
                                  boNewOutputRow.SetFieldValueAsString('StorePosition_ID', mdLogStoreContents.FieldByName('LSP_ID').AsString);
                                  boNewOutputRow.SetFieldValueAsString('IncomingStorePosition_ID', GetPickingPosition(mOS, boRO.OID, boOutputRow.GetFieldValueAsString('Store_ID')));
                                  boNewOutputRow.SetFieldValueAsString('X_InterniPoznamka', boOutputRow.GetFieldValueAsString('X_InterniPoznamka'));
                                  if bIsStorePreferredBatches then
                                  begin
                                    boNewOutputRow.SetFieldValueAsBoolean('X_IsPreferredStoreBatch', True);
                                  end;
                                  //OutputDebugString('- bOriginalRow-');
                                  //OutputDebugString(boNewOutputRow.GetFieldValueAsString('StorePosition_ID'));
                                  //OutputDebugString(FloatToStr(boNewOutputRow.GetFieldValueAsFLoat('Quantity')));
                                end;
                              end;
                              mdLogStoreContents.Next;

                            end;
                          end;
                        end;

                      finally
                        mdLogStoreContents.Free;
                      end;

                    end
                    else // if - StoreCard_ID.Category
                    begin

                      // -->> výběr pozice s případným rozpadem na více řádků (2) - analogicky s (1) jen bez šarží
                      mdLogStoreContents :=  TMemoryDataset.Create(nil);
                      try
                        SQLString := Format('SELECT LSP.ID AS LSP_ID, LSC.Quantity - LSC.QuantityReserved AS LSC_Quantity'
                          + #13#10 + 'FROM LogStoreContents LSC'
                          + #13#10 + 'LEFT JOIN LogStorePositions LSP ON LSP.ID = LSC.Parent_ID'
                          + #13#10 + 'WHERE LSP.Store_ID = %s'
                          + #13#10 + '  AND LSC.StoreCard_ID = %s'
                          + #13#10 + '  AND LSC.Quantity - LSC.QuantityReserved > 0'
                          + #13#10 + '  AND LSP.PositionType = 0 /* jen bezne pozice */'
                          + #13#10 + 'ORDER BY LSC.Quantity - LSC.QuantityReserved DESC',
                          [QuotedStr(boOutputRow.GetFieldValueAsString('Store_ID')), QuotedStr(boOutputRow.GetFieldValueAsString('StoreCard_ID'))]);
                        //OutputDebugString(SQLString);
                        mOS.SQLSelect2(SQLString, mdLogStoreContents);
                        if mdLogStoreContents.RecordCount <> 0 then
                        begin
                          mdLogStoreContents.First;
                          while not mdLogStoreContents.Eof do
                          begin
                            //OutputDebugString('---');
                            //OutputDebugString(mdLogStoreContents.FieldByName('LSP_ID').AsString);
                            //OutputDebugString(FloatToStr(mdLogStoreContents.FieldByName('LSC_Quantity').AsFloat));

                            InsertOutputRowQuantity := 0;
                            if RemainOutputRowQuantity > mdLogStoreContents.FieldByName('LSC_Quantity').AsFloat then
                            begin
                              InsertOutputRowQuantity := mdLogStoreContents.FieldByName('LSC_Quantity').AsFloat;
                              RemainOutputRowQuantity := RemainOutputRowQuantity - InsertOutputRowQuantity;
                            end
                            else
                            begin
                              InsertOutputRowQuantity := RemainOutputRowQuantity;
                              RemainOutputRowQuantity := 0;
                            end;

                            //OutputDebugString('-');
                            //OutputDebugString('Karta: ' + boOutputRow.GetFieldValueAsString('StoreCard_ID'));
                            //OutputDebugString('Pozice: ' + mdLogStoreContents.FieldByName('LSP_ID').AsString);
                            //OutputDebugString('InsertOutputRowQuantity: ' + FloatToStr(InsertOutputRowQuantity));
                            //OutputDebugString('RemainOutputRowQuantity: ' + FloatToStr(RemainOutputRowQuantity));

                            if InsertOutputRowQuantity > 0 then
                            begin
                              if bOriginalRow then
                              begin
                                boOutputRow.SetFieldValueAsString('StoreCard_ID', boOutputRow.GetFieldValueAsString('StoreCard_ID'));
                                boOutputRow.SetFieldValueAsFloat('Quantity', InsertOutputRowQuantity);
                                boOutputRow.SetFieldValueAsFloat('InPositionQuantity', InsertOutputRowQuantity);
                                boOutputRow.SetFieldValueAsString('StorePosition_ID', mdLogStoreContents.FieldByName('LSP_ID').AsString);
                                bOriginalRow := False;

                                //OutputDebugString('-');
                                //OutputDebugString(boOutputRow.GetFieldValueAsString('StorePosition_ID'));
                                //OutputDebugString(FloatToStr(boOutputRow.GetFieldValueAsFLoat('Quantity')));
                              end
                              else
                              begin
                                boNewOutputRow := mcOutputRows.AddNewObject;
                                boNewOutputRow.SetFieldValueAsString('Store_ID', boOutputRow.GetFieldValueAsString('Store_ID'));
                                boNewOutputRow.SetFieldValueAsString('StoreCard_ID', boOutputRow.GetFieldValueAsString('StoreCard_ID'));
                                boNewOutputRow.SetFieldValueAsString('QUnit', boOutputRow.GetFieldValueAsString('QUnit'));
                                boNewOutputRow.SetFieldValueAsFLoat('Quantity', InsertOutputRowQuantity);
                                boNewOutputRow.SetFieldValueAsFLoat('InPositionQuantity', InsertOutputRowQuantity);
                                boNewOutputRow.SetFieldValueAsFLoat('UnitRate', boOutputRow.GetFieldValueAsFloat('UnitRate'));
                                boNewOutputRow.SetFieldValueAsString('StorePosition_ID', mdLogStoreContents.FieldByName('LSP_ID').AsString);
                                boNewOutputRow.SetFieldValueAsString('IncomingStorePosition_ID', PickingPosition_ID);
                                boNewOutputRow.SetFieldValueAsString('X_InterniPoznamka', boOutputRow.GetFieldValueAsString('X_InterniPoznamka'));

                                //OutputDebugString('-');
                                //OutputDebugString(boNewOutputRow.GetFieldValueAsString('StorePosition_ID'));
                                //OutputDebugString(FloatToStr(boNewOutputRow.GetFieldValueAsFLoat('Quantity')));
                              end;
                            end;
                            mdLogStoreContents.Next;
                          end; // if - SQLResult.RecordCount <> 0;
                        end;
                      finally
                        mdLogStoreContents.Free;
                      end; // <<-- výběr pozice s případným rozpadem na více řádků (2) - analogicky s (1) jen bez šarží

                    end;

                    // pokud se vše nevychystalo, uložíme si informaci
                    OutputDebugString('RemainOutputRowQuantity: ' + FloatToStr(RemainOutputRowQuantity));
                    if RemainOutputRowQuantity > 0 then
                    begin
                      bAllQuantity := False;
                      slResultInfo.Add('Nevychystáno zcela: ' + boRO.GetFieldValueAsString('DisplayName')
                                       + ': ' + boOutputRow.GetFieldValueAsString('StoreCard_ID.Code')
                                       + ' - ' + boOutputRow.GetFieldValueAsString('StoreCard_ID.Name')
                                       + NxIIfStr(boOutputRow.GetFieldValueAsString('X_InterniPoznamka') = '', '', ' | ' + boOutputRow.GetFieldValueAsString('X_InterniPoznamka')));
                    end;
                  end; // mcOutputRows.Count

                  // odstranění řádků, které se nám nehodí
                  for iRow := 0 to mcOutputRows.Count - 1 do
                  begin
                    //OutputDebugString('celkem řádků: ' + IntToStr(mcOutputRows.Count));
                    //OutputDebugString('řádek: ' + IntToStr(iRow));
                    boOutputRow := mcOutputRows.BusinessObject(iRow);
                    boOutputDoc.SetFieldValueAsString('Description', NxSearchReplace(cSplitConditions[iSplitConditions], '_', ' ', [srAll]));
                    //OutputDebugString(IntToStr(mcOutputRows.Count));

                    // odstranění jednoduchých karet
                    if boOutputRow.GetFieldValueAsString('StoreCard_ID.Category') in [0, 4] then
                    begin
                      boOutputRow.SetFieldValueAsFloat('Quantity', 0);
                      boOutputRow.SetFieldValueAsFloat('InPositionQuantity', 0);
                      // boOutputRow.MarkForDelete; nefungovalo dobře
                    end;

                    // odstranění chybných pozic (šarže není skladem nebo jsou jiné preferované), na pořadí zde nezáleží (důležité je pořadí v definici cSplitConditions)
                    if (boOutputRow.GetFieldValueAsString('StorePosition_ID') in [cStorePosition_Error_ID]) or NxIsEmptyOID(boOutputRow.GetFieldValueAsString('StorePosition_ID')) then
                    begin
                      boOutputRow.SetFieldValueAsFloat('Quantity', 0);
                      boOutputRow.SetFieldValueAsFloat('InPositionQuantity', 0);
                      // boOutputRow.MarkForDelete; nefungovalo dobře
                    end;

                    if cSplitConditions[iSplitConditions] = 'zakazky_dily' then
                    begin
                      if (boOutputRow.GetFieldValueAsString('StorePosition_ID') = cStorePosition_ZZ_ID) and (UpCase(NxLeft(boOutputRow.GetFieldValueAsString('StoreCard_ID.X_Form'), 1)) = 'A') then
                      begin
                      end
                      else
                      begin
                        boOutputRow.SetFieldValueAsFloat('Quantity', 0);
                        boOutputRow.SetFieldValueAsFloat('InPositionQuantity', 0);
                        // boOutputRow.MarkForDelete; nefungovalo dobře
                      end
                    end;
                    if cSplitConditions[iSplitConditions] = 'zakazky_plechy' then
                    begin
                      if (boOutputRow.GetFieldValueAsString('StorePosition_ID') = cStorePosition_ZZ_ID) and (UpCase(NxLeft(boOutputRow.GetFieldValueAsString('StoreCard_ID.X_Form'), 1)) = 'P') then
                      begin
                      end
                      else
                      begin
                        boOutputRow.SetFieldValueAsFloat('Quantity', 0);
                        boOutputRow.SetFieldValueAsFloat('InPositionQuantity', 0);
                        // boOutputRow.MarkForDelete; nefungovalo dobře
                      end
                    end;
                    if cSplitConditions[iSplitConditions] = 'zakazky_ostatni' then
                    begin
                      if (boOutputRow.GetFieldValueAsString('StorePosition_ID') = cStorePosition_ZZ_ID) and (not (UpCase(NxLeft(boOutputRow.GetFieldValueAsString('StoreCard_ID.X_Form'), 1)) in ['A', 'P'])) then
                      begin
                      end
                      else
                      begin
                        boOutputRow.SetFieldValueAsFloat('Quantity', 0);
                        boOutputRow.SetFieldValueAsFloat('InPositionQuantity', 0);
                        // boOutputRow.MarkForDelete; nefungovalo dobře
                      end
                    end;

                    if cSplitConditions[iSplitConditions] = 'dily' then
                    begin
                      if UpCase(NxLeft(boOutputRow.GetFieldValueAsString('StoreCard_ID.X_Form'), 1)) <> 'A' then
                      begin
                        boOutputRow.SetFieldValueAsFloat('Quantity', 0); // boOutputRow.MarkForDelete; nefungovalo dobře
                        boOutputRow.SetFieldValueAsFloat('InPositionQuantity', 0);
                      end
                    end;
                    if cSplitConditions[iSplitConditions] = 'stara_hala' then
                    begin
                      if not (boOutputRow.GetFieldValueAsString('StorePosition_ID') in [cStorePosition_OldHall_ID, cStorePosition_010_ID, cStorePosition_012_ID, cStorePosition_042_ID])
                        or (UpCase(NxLeft(boOutputRow.GetFieldValueAsString('StoreCard_ID.X_Form'), 1)) = 'A') then
                      begin
                        boOutputRow.SetFieldValueAsFloat('Quantity', 0); // boOutputRow.MarkForDelete; nefungovalo dobře
                        boOutputRow.SetFieldValueAsFloat('InPositionQuantity', 0);
                      end
                    end;
                    if cSplitConditions[iSplitConditions] = 'plechy' then
                    begin
                      if (UpCase(NxLeft(boOutputRow.GetFieldValueAsString('StoreCard_ID.X_Form'), 1)) <> 'P')
                        or (boOutputRow.GetFieldValueAsString('StorePosition_ID') in [cStorePosition_OldHall_ID, cStorePosition_010_ID, cStorePosition_012_ID, cStorePosition_042_ID])
                        or (UpCase(NxLeft(boOutputRow.GetFieldValueAsString('StoreCard_ID.X_Form'), 1)) = 'A') then
                      begin
                        boOutputRow.SetFieldValueAsFloat('Quantity', 0); // boOutputRow.MarkForDelete; nefungovalo dobře
                        boOutputRow.SetFieldValueAsFloat('InPositionQuantity', 0);
                      end
                    end;
                    if cSplitConditions[iSplitConditions] = 'pila' then
                    begin
                      if not (boOutputRow.GetFieldValueAsString('StorePosition_ID') in [cStorePosition_Saw_ID])
                        or (UpCase(NxLeft(boOutputRow.GetFieldValueAsString('StoreCard_ID.X_Form'), 1)) = 'P')
                        or (boOutputRow.GetFieldValueAsString('StorePosition_ID') in [cStorePosition_OldHall_ID, cStorePosition_010_ID, cStorePosition_012_ID, cStorePosition_042_ID])
                        or (UpCase(NxLeft(boOutputRow.GetFieldValueAsString('StoreCard_ID.X_Form'), 1)) = 'A') then
                      begin
                        boOutputRow.SetFieldValueAsFloat('Quantity', 0); // boOutputRow.MarkForDelete; nefungovalo dobře
                        boOutputRow.SetFieldValueAsFloat('InPositionQuantity', 0);
                      end
                    end;
                    if cSplitConditions[iSplitConditions] = 'trubky' then
                    begin
                      if (LeftStr(boOutputRow.GetFieldValueAsString('StorePosition_ID.X_Type'), 1) <> 'T')
                        or (boOutputRow.GetFieldValueAsString('StorePosition_ID') in [cStorePosition_Saw_ID])
                        or (UpCase(NxLeft(boOutputRow.GetFieldValueAsString('StoreCard_ID.X_Form'), 1)) = 'P')
                        or (boOutputRow.GetFieldValueAsString('StorePosition_ID') in [cStorePosition_OldHall_ID, cStorePosition_010_ID, cStorePosition_012_ID, cStorePosition_042_ID])
                        or (UpCase(NxLeft(boOutputRow.GetFieldValueAsString('StoreCard_ID.X_Form'), 1)) = 'A') then
                      begin
                        boOutputRow.SetFieldValueAsFloat('Quantity', 0); // boOutputRow.MarkForDelete; nefungovalo dobře
                        boOutputRow.SetFieldValueAsFloat('InPositionQuantity', 0);
                      end
                    end;
                    if cSplitConditions[iSplitConditions] = 'nova_hala' then // pouze zbytek z OP
                    begin
                      if (LeftStr(boOutputRow.GetFieldValueAsString('StorePosition_ID.X_Type'), 1) = 'T')
                        or (boOutputRow.GetFieldValueAsString('StorePosition_ID') in [cStorePosition_Saw_ID])
                        or (UpCase(NxLeft(boOutputRow.GetFieldValueAsString('StoreCard_ID.X_Form'), 1)) = 'P')
                        or (boOutputRow.GetFieldValueAsString('StorePosition_ID') in [cStorePosition_OldHall_ID, cStorePosition_010_ID, cStorePosition_012_ID, cStorePosition_042_ID])
                        or (UpCase(NxLeft(boOutputRow.GetFieldValueAsString('StoreCard_ID.X_Form'), 1)) = 'A') then
                      begin
                        boOutputRow.SetFieldValueAsFloat('Quantity', 0); // boOutputRow.MarkForDelete; nefungovalo dobře
                        boOutputRow.SetFieldValueAsFloat('InPositionQuantity', 0);
                      end
                    end;
                  end;

                  {
                  mImportManager.CheckOutputDocument;
                  }
                  // zjištění zda je doklad prázdný (= všechny řádky smazané) a uložení
                  bMarkAllRowForDelete := True;
                  for iRow := 0 to mcOutputRows.Count - 1 do
                  begin
                    boOutputRow := mcOutputRows.BusinessObject(iRow);
                    if (boOutputRow.GetFieldValueAsFloat('Quantity') <> 0) or (boOutputRow.GetFieldValueAsFloat('InPositionQuantity') <> 0) then
                    //if not ((osDeleted in boOutputRow.State) or (osMarkForDelete in boOutputRow.State)) then
                    begin
                      bMarkAllRowForDelete := False;
                    end;
                  end;
                  // případné uložení dokladu
                  if not bMarkAllRowForDelete then
                  begin
                    mImportManager.OutputDocument.Save;
                  end

                finally
                  mImportManager.Free;
                end;
              except
                MessageDlg(boRO.GetFieldValueAsString('DisplayName') + ': ' + ExceptionMessage, mtWarning, [mbOK], 0);
              end;
            end;
          end;

          // občerstvení agendy
          TDynSiteForm(mSiteForm).RefreshData;

          // informativní výpis
          if not bAllQuantity then
          begin
            MessageDlg('Příprava dokladů proběhla s upozorněním. Nepřipravily se tyto položky:' + #13#10 + slResultInfo.Text, mtWarning, [mbOK], 0);
          end
          else
          begin
            MessageDlg('Příprava dokladů proběhla.' + #13#10 + slResultInfo.Text, mtInformation, [mbOK], 0);
          end;

            // !!! nastavit OP jako "předáno na sklad OT/PR"
        finally
          boRO.Free;
          slResultInfo.Free;
        end; // try
      end; // NxMessageBox('Dotaz', 'Opravdu
    end; // Assigned(mSiteForm)
  end; // Sender is TComponent
end;

////////////////////////////////////////////////////////////////////////////////

function GetPickingPosition(mOS: TNxCustomObjectSpace; ReceivedOrder_ID, Store_ID: String): String;
var
  SQLString: String;
begin
  SQLString := Format('SELECT LSP.ID FROM LogStorePositions LSP WHERE LSP.ReservedForDocType = %s AND LSP.ReservedForDoc_ID = %s AND LSP.Store_ID = %s', [QuotedStr('RO'), QuotedStr(ReceivedOrder_ID), QuotedStr(Store_ID)]);
  Result := SQLSelectFirstRow(mOS, SQLString);
end;

////////////////////////////////////////////////////////////////////////////////

function SetAndGetStoreBatchFreeQuantity(mOS: TNxCustomObjectSpace; boOutputRow: TNxCustomBusinessObject; StoreBatchUsed_ID: String; StoreBatchUsedQuantity: Double; var arFreeStoreBatchIDs: array of String; var arFreeStoreBatchQuantity: array of Double): Double;
var
  I: Integer;
  bExistBatchInArray: Boolean;
  SubBatchQuantity: Double;
  PreferredQuantity: Double;
  ReservedQuantity: Double;
  SQLString: String;
  slSQLResult: TStringList;

begin
  Result := 0;
  bExistBatchInArray := False;

  // v případě, že se dohledá šarže, uvolní se množství
  for I := 0 to Length(arFreeStoreBatchIDs) - 1 do
  begin
    if StoreBatchUsed_ID = arFreeStoreBatchIDs[I] then
    begin
      bExistBatchInArray := True;
      {10. 2. 2016 >>}
      { nahrazeno odstavcem níže
      Result := Max_1(StoreBatchUsedQuantity, arFreeStoreBatchQuantity[I]);
      arFreeStoreBatchQuantity[I] := arFreeStoreBatchQuantity[I] - Result;
      }
      Result := arFreeStoreBatchQuantity[I];
      arFreeStoreBatchQuantity[I] := Max_1(0, arFreeStoreBatchQuantity[I] - StoreBatchUsedQuantity);
      {<< 10. 2. 2016}
    end;
  end;

  // pokud se šarže nedohledá, založí se
  if not bExistBatchInArray then
  begin
    SetLength(arFreeStoreBatchIDs, Length(arFreeStoreBatchIDs) + 1);
    SetLength(arFreeStoreBatchQuantity, Length(arFreeStoreBatchQuantity) + 1);

    arFreeStoreBatchIDs[Length(arFreeStoreBatchIDs) - 1] := StoreBatchUsed_ID;

    // množství na dílší šarži
    SQLString := Format('SELECT sum(SSB.Quantity)'
             + #13#10 + 'FROM StoreSubBatches SSB'
             + #13#10 + 'WHERE SSB.StoreBatch_ID = ''%0:s'''
             + #13#10 + '  AND SSB.Store_ID = ''%1:s''',
            [StoreBatchUsed_ID, boOutputRow.GetFieldValueAsString('Store_ID')]);
    slSQLResult := TStringList.Create;
    try
      mOS.SQLSelect(SQLString, slSQLResult);
      if slSQLResult.Count > 0 then
      begin
        SubBatchQuantity := StrToFloat(slSQLResult.Strings(0));
      end
      else
      begin
        SubBatchQuantity := 0;
      end;
    finally
      slSQLResult.Free;
    end;

    // preferované množštví na ostatních OP
    SQLString := Format('SELECT COALESCE(sum(RO2.Quantity - RO2.DeliveredQuantity), 0)'
             + #13#10 + 'FROM ReceivedOrders2 RO2'
             + #13#10 + 'LEFT JOIN ReceivedOrders RO ON RO.ID = RO2.Parent_ID'
             + #13#10 + 'WHERE RO.Closed = ''N'''
             + #13#10 + '  AND RO.Confirmed = ''A'''
             + #13#10 + '  AND RO.ID <> ''%0:s'''
             + #13#10 + '  AND RO2.X_PreferredStoreBatch_ID = ''%1:s'''
             + #13#10 + '  AND RO2.Quantity > RO2.DeliveredQuantity'
             + #13#10 + '  AND RO2.Store_ID || ''x'' = ''%2:s'' || ''x''',
             [boOutputRow.GetFieldValueAsString('Parent_ID.ReservedForDoc_ID'), StoreBatchUsed_ID, boOutputRow.GetFieldValueAsString('Store_ID')]);
    //OutputDebugString(SQLString);
    slSQLResult := TStringList.Create;
    try
      mOS.SQLSelect(SQLString, slSQLResult);
      if slSQLResult.Count > 0 then
      begin
        PreferredQuantity := StrToFloat(slSQLResult.Strings(0));
      end
      else
      begin
        PreferredQuantity := 0;
      end;
    finally
      slSQLResult.Free;
    end;

    // rezervované množství na pozicích
    SQLString := Format('SELECT sum(LSC.QuantityReserved)'
            + #13#10 + 'FROM LogStoreContents LSC'
            + #13#10 + 'LEFT JOIN LogStorePositions LSP ON LSP.ID = LSC.Parent_ID'
            + #13#10 + 'WHERE LSP.Store_ID = ''%0:s'''
            + #13#10 + '  AND LSC.StoreBatch_ID = ''%1:s'''
            + #13#10 + '  AND LSP.PositionType = 0 /* jen bezne pozice */',
           [boOutputRow.GetFieldValueAsString('Store_ID'), StoreBatchUsed_ID, ]);
    slSQLResult := TStringList.Create;
    try
      mOS.SQLSelect(SQLString, slSQLResult);
      if slSQLResult.Count > 0 then
      begin
        ReservedQuantity := StrToFloat(slSQLResult.Strings(0));
      end
      else
      begin
        ReservedQuantity := 0;
      end;
    finally
      slSQLResult.Free;
    end;

    arFreeStoreBatchQuantity[Length(arFreeStoreBatchQuantity) - 1] := SubBatchQuantity - PreferredQuantity - ReservedQuantity;
    Result := arFreeStoreBatchQuantity[Length(arFreeStoreBatchQuantity) - 1];
    arFreeStoreBatchQuantity[Length(arFreeStoreBatchQuantity) - 1] := Max_1(0, arFreeStoreBatchQuantity[Length(arFreeStoreBatchQuantity) - 1] - StoreBatchUsedQuantity);
  end;

end;

////////////////////////////////////////////////////////////////////////////////
{
  Funkce vrátí množství na příjemce (příjemkách), které jsou svázány z řádekm
  dokladu PPZ přes vazbu PPZ -> řádek OP -> řádek OV -> řádek PR. Jedná se
  o zakázkové prodeje (ZZ), kdy je zboží objednáváno u dodavatelů přesně
  na požadavky zákazníků.
}
function GetReceiptQuantity(boLogStoreTransferRow: TNxCustomBusinessObject): Double;
var
  SQLString: String;
  SQLResult: String;

begin
  SQLString := Format('SELECT sum(SD2.Quantity)'
           + #13#10 + 'FROM StoreDocuments2 SD2'
           + #13#10 + 'JOIN IssuedOrders2 IO2 ON IO2.ID = SD2.ProvideRow_ID'
           + #13#10 + 'JOIN ReceivedOrdersToIssuedOrders ROTIO ON ROTIO.Target_ID = IO2.ID'
           + #13#10 + 'JOIN ReceivedOrders2 RO2 ON RO2.ID = ROTIO.Source_ID'
           + #13#10 + 'JOIN ReceivedOrders RO ON RO.ID = RO2.Parent_ID'
           + #13#10 + 'JOIN StoreCards SC ON SC.ID = RO2.StoreCard_ID'
           + #13#10 + 'WHERE RO.ID = %0:s'
           + #13#10 + '  AND SC.Code = %1:s'
           + #13#10 + '  AND SD2.Store_ID = %2:s',
           [QuotedStr(boLogStoreTransferRow.GetFieldValueAsString('Parent_ID.ReservedForDoc_ID')),
            QuotedStr(boLogStoreTransferRow.GetFieldValueAsString('StoreCard_ID.Code')),
            QuotedStr(boLogStoreTransferRow.GetFieldValueAsString('Store_ID'))]);
  SQLResult := SQLSelectFirstRow(boLogStoreTransferRow.ObjectSpace, SQLString);
  if SQLResult <> '' then
  begin
    Result := StrToFloat(SQLResult);
  end
  else
  begin
    Result := 0;
  end;
end;

////////////////////////////////////////////////////////////////////////////////

begin
end.