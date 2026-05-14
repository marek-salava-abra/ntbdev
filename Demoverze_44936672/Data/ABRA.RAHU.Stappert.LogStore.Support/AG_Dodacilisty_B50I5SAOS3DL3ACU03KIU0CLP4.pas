uses
  'ABRA.RAHU.Stappert.LogStore.Support.Common';

////////////////////////////////////////////////////////////////////////////////

// ovládací akce

procedure FormCreate_Hook(Self: TSiteForm);
var
  mAction: TBasicAction;
begin
  mAction := Self.GetNewAction;
  mAction.ShowControl := True;
  mAction.ShowMenuItem := True;
  mAction.Name := 'actNewLogStoreDocument';
  mAction.Caption := 'Polohovat hromadně';
  mAction.Hint := 'Vytvoří hromadně polohovací doklady s kontrolou';
  mAction.Category := 'tabList';
  mAction.ShortCut := TextToShortCut('CTRL+P');
  mAction.OnExecute := @NewLogStoreDocument_OnExecute;
  mAction.OnUpdate:= @NewLogStoreDocument_OnUpdate;
end;


////////////////////////////////////////////////////////////////////////////////

//nastavení, kdy bude tlačítko k dispozici
procedure NewLogStoreDocument_OnUpdate(Sender: TObject);
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

procedure NewLogStoreDocument_OnExecute(Sender: TObject);
var
  mSiteForm: TSiteForm;
  mOS: TNxCustomObjectSpace;
  mParam: TNxParameters;

  DocIDs: TStringList;
  iDocROs: Integer;
  boDoc: TNxCustomBusinessObject;
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

  slResultInfo: TStringList;

  arFreeStoreBatchIDs: array of string;
  arFreeStoreBatchQuantity: array of Double;

  ReceiptQuantity: Double;  // množství na připojené PR (tzv. zakázkový prodej)
  bDirectSale: Boolean;     // info, že se jedná o zakázkový prodej
  TempPreferredQuanty: Double;
  TempContentQuantity: Double;
  bTempExistPreferredInContent: Boolean;

  slParamNames: TStringList;
  iTemp: Integer;
  bCanSave: Boolean;

begin
  if Sender is TComponent then
  begin
    mSiteForm := NxFindSiteForm(TComponent(Sender));
    if Assigned(mSiteForm) then
    begin
      if NxMessageBox('Dotaz', 'Opravdu chcete polohovat označené doklady?', mdConfirm, mdbYesNo, 0, 0, False, Nil) = mrYes then
      begin

        mOS := mSiteForm.BaseObjectSpace;
        boDoc := mOS.CreateObject(Class_BillOfDelivery);
        slResultInfo := TStringList.Create;
        DocIDs := TStringList.Create;
        try
          TDynSiteForm(mSiteForm).FillListWithSelectedRows(DocIDs);
          for iDocROs := 0 to DocIDs.Count - 1 do
          begin
            boDoc.Load(DocIDs.Strings(iDocROs), nil);

            // kontrola, zda je již doklad plně polohován (SQL převzato z DynSQL)
            SQLString := Format('SELECT *'
                     + #13#10 + 'FROM StoreDocuments2 SD2'
                     + #13#10 + 'WHERE SD2.Parent_ID = %s'
                     + #13#10 + '  AND SD2.Quantity <> (SELECT COALESCE(SUM(Quantity), 0) FROM LogStoredocuments2 LSD2 WHERE LSD2.StoreDocRow_ID = SD2.ID)',
                                [QuotedStr(DocIDs.Strings(iDocROs))]);
            //ShowMessage(SQLString);
            slSQLResult := TStringList.Create;
            try
              mOS.SQLSelect(SQLString, slSQLResult);
              if slSQLResult.Count = 0 then
              begin
                slResultInfo.Add(Format('- %s: doklad byl již polohovaný.', [boDoc.GetFieldValueAsString('DisplayName')]));
                Continue;  // nemá smyl pokračovat v cyklu pro doklad
              end;
            finally
              slSQLResult.Free;
            end;

            mImportManager := NxCreateDocumentImportManager(mOS, Class_BillOfDelivery, Class_LogStoreOutput);
            try

              // tvorba VPZ z DL
              mImportManager.AddInputDocument(boDoc.OID);
              mParam:= TNxParameters.Create;
              try

                {
                // slouží jen pro zjištění parametrů, po stestování bude zakomentováno
                mImportManager.ExecuteWizard(mSiteForm);
                mImportManager.SaveParams(mParam);
                OutputDebugString(mParam.ShowValues);
                }

                mImportManager.SaveParams(mParam);
                mParam.GetOrCreateParam(dtString, 'StoreGateway_ID').AsString := '1000000101';
                mParam.GetOrCreateParam(dtString, 'DocQueue_ID').AsString := '2Z20000101';
                mParam.GetOrCreateParam(dtBoolean, 'AutoPrefillPosition').AsBoolean:= True;
                mParam.GetOrCreateParam(dtString, 'Strategy_ID').AsString := '{37A351FA-D60D-4A98-9A58-1FD1ACAD5339}';
                mImportManager.LoadParams(mParam);

              finally
                mParam.Free;
                slParamNames.Free;
              end;

              mImportManager.Execute;

              bCanSave := True;  // kontrolovat - softvalidace, hardvalidace, prázndé pozice
              boOutputDoc := mImportManager.OutputDocument;
              mcOutputRows := boOutputDoc.GetLoadedCollectionMonikerForFieldCode(boOutputDoc.GetFieldCode('Rows'));
              for iOutputRows := 0 to mcOutputRows.Count - 1 do
              begin
                boOutputRow := mcOutputRows.BusinessObject(iOutputRows);

                if NxIsEmptyOID(boOutputRow.GetFieldValueAsString('StorePosition_ID')) then
                begin
                  slResultInfo.Add(Format('- %s: řádek s kartou %s nemá vyplněnou pozici.', [boDoc.GetFieldValueAsString('DisplayName'), boOutputRow.GetFieldValueAsString('StoreCard_ID.Code')]));
                  bCanSave := False;
                  Break; // nemá smyl pokračovat v cyklu pro řádky dokladu
                end;

                if boOutputRow.GetFieldValueAsInteger('StoreCard_ID.Category') in [1, 2] then
                begin
                  if boOutputRow.GetFieldValueAsInteger('StorePosition_ID.PositionType') <> 1 then
                  begin
                    slResultInfo.Add(Format('- %s: řádek s kartou %s nemá vyplněnou expediční (Exxx) pozici.', [boDoc.GetFieldValueAsString('DisplayName'), boOutputRow.GetFieldValueAsString('StoreCard_ID.Code')]));
                    bCanSave := False;
                    Break; // nemá smyl pokračovat v cyklu pro řádky dokladu
                  end;
                end;

              end; // mcOutputRows.Count

              // případné uložení dokladu
              if bCanSave then
              begin
                mImportManager.OutputDocument.Save;
              end;

            finally
              mImportManager.Free;
            end;

          end; // for iDocROs

          // občerstvení agendy
          TDynSiteForm(mSiteForm).RefreshData;

          // informativní výpis
          if slResultInfo.Count > 0 then
          begin
            MessageDlg('Příprava dokladů proběhla s upozorněním. Nezpolohovaly se všechny doklady:' + #13#10 + slResultInfo.Text, mtWarning, [mbOK], 0);
          end
          else
          begin
            MessageDlg('Zpolohovaly se všechny doklady.', mtInformation, [mbOK], 0);
          end;

        finally
          boDoc.Free;
          slResultInfo.Free;
        end; // try
      end; // NxMessageBox('Dotaz', 'Opravdu
    end; // Assigned(mSiteForm)
  end; // Sender is TComponent
end;

////////////////////////////////////////////////////////////////////////////////

begin
end.