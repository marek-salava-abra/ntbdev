uses
  'abra.mask.Rozpad_prace.Books';
  
const
  cStorageDataKey = 'CdRowDecay_ABRA';
  
var
  //Proměnné formuláře
  dtRowMatData,dtRowWorkData,dtRowEvData: TMemoryDataset;
  dsRowMatSource,dsRowWorkSource,dsRowEvSource: TDataSource;
  grdPayments,grdMat,grdWork,grdEv,: TDBGrid;
  pnTop: TPanel;
  pnAll: TPanel;
  btnCreateDecay: TButton;
  btnClose: TButton;
  btnDeleteRow: TButton;
  edRemainAmount: TNumEdit;
  edTotalAmount: TNumEdit;
  cbDefinitions: TComboBox;
  lblDefinitions: TLabel;
  lblTotalAmount: TLabel;
  lblRemainAmount: TLabel;
  btnDeleteDef: TButton;
  btnProceedDecay: TButton;
  fDataset: TNxRowsObjectDataSet;
  fObject: TNxCustomBusinessObject;
  fForm: TForm;

  fContext: TNxContext;
  fObjectSpace: TNxCustomObjectSpace;

  fSite: TDynSiteForm;

procedure RowDecay2(AOS: TNxCustomObjectSpace; ASite: TDynSiteForm; ADataset: TNxRowsObjectDataSet);
var
  mResNameList, mResValueList: TStringList;
  mName: string;
  i: integer;
begin
  fObjectSpace := AOS;
  fContext := ASite.SiteContext;
  fDataset := ADataset;
  fObject := nil;
  if Assigned(ADataset.CurrentObject) then
    fObject := ADataset.CurrentObject;
  mResNameList := TStringList.Create;
  mResValueList := TStringList.Create;
  try
    fForm := MakeForm;
    if not (dtRowMatData.Active) then
      dtRowMatData.Open;
      dtRowMatData.Edit;
      dtRowMatData.Append;


    ShowDebugMessage('mFieldName: ' + dtRowMatData.FieldByName('VATRate_ID').FieldName);
    ShowDebugMessage('Zdrojové množství: ' + FloatToStr(ADataset.FieldByName('Quantity').AsFloat));
    edTotalAmount.Value := ADataset.FieldByName('Quantity').AsFloat;
    edRemainAmount.Value := edTotalAmount.Value;
    // predvyplneni podle definice
    //      SetValueToCentralStorage(cStorageDataKey + '!*' + mName, mList.Text,fObjectSpace);
    if GetValuesFromCentralStorage(cStorageDataKey, mResNameList, mResValueList, AOS) then begin
      for i := 0 to mResNameList.Count - 1 do begin
        mName := mResNameList.Strings[i];
        mName := NxTokenR(mName, '!*');
        cbDefinitions.Items.Add(mName);
      end;
    end;
    fForm.ShowModal(ASite);
  finally
    mResNameList.Free;
    mResValueList.Free;
  end;
end;

procedure RowDecay(AOS: TNxCustomObjectSpace; ASite: TDynSiteForm; AObject: TNxCustomBusinessObject; ADataset: TNxRowsObjectDataSet);
var
  mResNameList, mResValueList: TStringList;
  mName: string;
  i: integer;
begin
  fObjectSpace := AOS;
  fContext := ASite.SiteContext;
  fDataset := ADataset;
  fObject := AObject;
  mResNameList := TStringList.Create;
  mResValueList := TStringList.Create;
  try
    fForm := MakeForm;
    if not (dtRowMatData.Active) then
      dtRowMatData.Open;
    ShowDebugMessage('mFieldName: ' + dtRowMatData.FieldByName('VATRate_ID').FieldName);
    ShowDebugMessage('Zdrojové množství: ' + FloatToStr(AObject.GetFieldValueAsFloat('Quantity')));
    edTotalAmount.Value := AObject.GetFieldValueAsFloat('Quantity');
    edRemainAmount.Value := edTotalAmount.Value;
    // predvyplneni podle definice
    //      SetValueToCentralStorage(cStorageDataKey + '!*' + mName, mList.Text,fObjectSpace);
    if GetValuesFromCentralStorage(cStorageDataKey, mResNameList, mResValueList, AOS) then begin
      for i := 0 to mResNameList.Count - 1 do begin
        mName := mResNameList.Strings[i];
        mName := NxTokenR(mName, '!*');
        cbDefinitions.Items.Add(mName);
      end;
    end;
    fForm.ShowModal(asite);
  finally
    mResNameList.Free;
    mResValueList.Free;
  end;
end;

procedure ProceedDecay;
var
  mSQL, mResOID, mCountryOID: string;
  mNewRowBO, mHeader: TNxCustomBusinessObject;
begin
  ShowDebugMessage('mrOK - provadim rozpad');
  if (dtRowMatData.State = dsInsert) or (dtRowMatData.State = dsEdit) then
    dtRowMatData.Post;

  if Assigned(fObject) then
    fObject.MarkForDelete
  else begin
    fObject := fDataset.CurrentObject;
    fDataset.Delete;
  end;

  mHeader := TNxNotPositionedRowBusinessObject(fObject).Header.BusinessObject;
  mCountryOID :=cVATCountry_ID;
  dtRowMatData.First;
  while not dtRowMatData.Eof do begin
    mNewRowBO := fDataset.CreateBusinessObject;
    //ShowDebugMessage('CreateBusinessObject ok');
    mNewRowBO.SetFieldValueAsInteger('Itemtype', 0);
    if dtRowMatData.FieldByName('VatRate_ID').AsString <> '' then begin
      //mNewRowBO.SetFieldValueAsFloat('VatRate', StrToFloat(dtRowMatData.FieldByName('VatRate_ID').AsString));
      mSQL := 'select ID from VatRates where Tariff = %s and Hidden = ''N'' and Country_ID = ''%s''';
      mSQL := Format(mSQL, [dtRowMatData.FieldByName('VatRate_ID').AsString, mCountryOID]); // lubi
      ShowDebugMessage('SQL: ' + mSQL);
      mResOID := GetFirstRecordFromSQL(fObjectSpace, mSQL);
      ShowDebugMessage('SQLres: ' + mResOID);
      mNewRowBO.SetFieldValueAsString('VatRate_ID', mResOID);
    end;

//    mNewRowBO.SetFieldValueAsFloat('PaymentAmount', dtRowMatData.FieldByName('PaymentAmount').AsFloat);

    mNewRowBO.SetFieldValueAsString('Text', dtRowMatData.FieldByName('Text').AsString);

    if dtRowMatData.FieldByName('Store_ID').AsString <> '' then begin
      mSQL := 'select ID from Stores where Code = ''%s'' and Hidden = ''N''';
      mSQL := Format(mSQL, [dtRowMatData.FieldByName('Store_ID').AsString]);
      ShowDebugMessage('SQL: ' + mSQL);
      mResOID := GetFirstRecordFromSQL(fObjectSpace, mSQL);
      ShowDebugMessage('SQLres: ' + mResOID);
      mNewRowBO.SetFieldValueAsString('Store_ID', mResOID);
    end;


    if dtRowMatData.FieldByName('StoreCard_ID').AsString <> '' then begin
      mSQL := 'select ID from Storecards where Code = ''%s'' and Hidden = ''N''';
      mSQL := Format(mSQL, [dtRowMatData.FieldByName('StoreCard_ID').AsString]);
      ShowDebugMessage('SQL: ' + mSQL);
      mResOID := GetFirstRecordFromSQL(fObjectSpace, mSQL);
      ShowDebugMessage('SQLres: ' + mResOID);
      mNewRowBO.SetFieldValueAsString('StoreCard_ID', mResOID);
    end;

    if dtRowMatData.FieldByName('WorkerRole_ID').AsString <> '' then begin
      mSQL := 'select ID from SecurityRoles where Name = ''%s'' and Hidden = ''N''';
      mSQL := Format(mSQL, [dtRowMatData.FieldByName('WorkerRole_ID').AsString]);
      ShowDebugMessage('SQL: ' + mSQL);
      mResOID := GetFirstRecordFromSQL(fObjectSpace, mSQL);
      ShowDebugMessage('SQLres: ' + mResOID);
      mNewRowBO.SetFieldValueAsString('WorkerRole_ID', mResOID);
    end;


    dtRowMatData.Next;
  end;
  fDataset.RefreshAndRestoreLastSelectedItem;

   mNewRowBO.New;
    //ShowDebugMessage('CreateBusinessObject ok');
    mNewRowBO.SetFieldValueAsInteger('Itemtype', 0);
    dtRowMatData.Next;
    fDataset.RefreshAndRestoreLastSelectedItem;



  fForm.Close;
end;

//Vytvoří editační formulář
function MakeForm: TForm;
var
  mForm: TForm;
begin
  mForm := TForm.Create(Nil);
  try
    mForm.Top := 196;
    mForm.Left := 218;
    mForm.Width := 620;
    mForm.Height := 350;//410;
    mForm.Name := 'frmRowDecay';
    mForm.Caption := 'Rozpad řádku DZV';
    //mForm.FormStyle := fsStayOnTop;
    mForm.BorderStyle := bsSizeable;
    mForm.Scaled := False;
    mForm.OnClose := @frmFormClose;
    //
    dtRowMatData := TMemoryDataset.Create(mForm);
    dtRowMatData.Name := 'dtRowMatData';
    dtRowMatData.AfterInsert := @dtRowMatDataAfterInsert;
    dtRowMatData.AfterPost := @dtRowMatDataAfterPost;

    dsRowMatSource := TDataSource.Create(mForm);
    dsRowMatSource.Name := 'dsRowSource';
    dsRowMatSource.DataSet := dtRowMatData;

    //
    dtRowMatData.FieldDefs.Add('Itemtype', ftInteger);
    dtRowMatData.FieldDefs.Add('Store_ID', ftString, 10);

    dtRowMatData.FieldDefs.Add('WorkerRole_ID', ftString, 10);
    dtRowMatData.FieldDefs.Add('StoreCard_ID', ftString, 10);
    dtRowMatData.FieldDefs.Add('Quantity', ftFloat);
    dtRowMatData.FieldDefs.Add('WorkHoursPlanned', ftFloat);
    dtRowMatData.FieldDefs.Add('WorkHoursReal', ftFloat);
    dtRowMatData.FieldDefs.Add('UnitPriceWithoutVAT', ftFloat);
//    dtRowMatData.FieldDefs.Add('X_QuantityTransport', ftFloat);
//    dtRowMatData.FieldDefs.Add('X_UnitPriceTransportWithoutVAT', ftFloat);
//    dtRowMatData.FieldDefs.Add('X_Discount', ftFloat);
//    dtRowMatData.FieldDefs.Add('X_Koeficient', ftFloat);
//    dtRowMatData.FieldDefs.Add('X_KonecPrace', ftDateTime);
//        dtRowMatData.FieldDefs.Add('X_Storno', ftBoolean);

    dtRowMatData.FieldDefs.Add('Text', ftString, 160);
    dtRowMatData.FieldDefs.Add('VATRate_ID', ftString, 10);




























        dtRowWorkData := TMemoryDataset.Create(mForm);
    dtRowWorkData.Name := 'dtRowMatData';
    dtRowWorkData.AfterInsert := @dtRowWorkDataAfterInsert;
    dtRowWorkData.AfterPost := @dtRowWorkDataAfterPost;

    dsRowWorkSource := TDataSource.Create(mForm);
    dsRowWorkSource.Name := 'dsRowWorkSource';
    dsRowWorkSource.DataSet := dtRowWorkData;

    //
    dtRowWorkData.FieldDefs.Add('Itemtype', ftInteger);
    dtRowWorkData.FieldDefs.Add('Store_ID', ftString, 10);

    dtRowWorkData.FieldDefs.Add('WorkerRole_ID', ftString, 10);
    dtRowWorkData.FieldDefs.Add('StoreCard_ID', ftString, 10);
    dtRowWorkData.FieldDefs.Add('Quantity', ftFloat);
    dtRowWorkData.FieldDefs.Add('WorkHoursPlanned', ftFloat);
    dtRowWorkData.FieldDefs.Add('WorkHoursReal', ftFloat);
    dtRowWorkData.FieldDefs.Add('UnitPriceWithoutVAT', ftFloat);
//    dtRowMatData.FieldDefs.Add('X_QuantityTransport', ftFloat);
//    dtRowMatData.FieldDefs.Add('X_UnitPriceTransportWithoutVAT', ftFloat);
//    dtRowMatData.FieldDefs.Add('X_Discount', ftFloat);
//    dtRowMatData.FieldDefs.Add('X_Koeficient', ftFloat);
//    dtRowMatData.FieldDefs.Add('X_KonecPrace', ftDateTime);
//        dtRowMatData.FieldDefs.Add('X_Storno', ftBoolean);

    dtRowWorkData.FieldDefs.Add('Text', ftString, 160);
    dtRowWorkData.FieldDefs.Add('VATRate_ID', ftString, 10);


























        dtRowEvData := TMemoryDataset.Create(mForm);
    dtRowEvData.Name := 'dtRowEvData';
    dtRowEvData.AfterInsert := @dtRowEvDataAfterInsert;
    dtRowEvData.AfterPost := @dtRowEvDataAfterPost;

    dsRowEvSource := TDataSource.Create(mForm);
    dsRowEvSource.Name := 'dsRowEvSource';
    dsRowEvSource.DataSet := dtRowEvData;

    //
    dtRowEvData.FieldDefs.Add('Itemtype', ftInteger);
    dtRowEvData.FieldDefs.Add('Store_ID', ftString, 10);

    dtRowEvData.FieldDefs.Add('WorkerRole_ID', ftString, 10);
    dtRowEvData.FieldDefs.Add('StoreCard_ID', ftString, 10);
    dtRowEvData.FieldDefs.Add('Quantity', ftFloat);
    dtRowEvData.FieldDefs.Add('WorkHoursPlanned', ftFloat);
    dtRowEvData.FieldDefs.Add('WorkHoursReal', ftFloat);
    dtRowEvData.FieldDefs.Add('UnitPriceWithoutVAT', ftFloat);
//    dtRowMatData.FieldDefs.Add('X_QuantityTransport', ftFloat);
//    dtRowMatData.FieldDefs.Add('X_UnitPriceTransportWithoutVAT', ftFloat);
//    dtRowMatData.FieldDefs.Add('X_Discount', ftFloat);
//    dtRowMatData.FieldDefs.Add('X_Koeficient', ftFloat);
//    dtRowMatData.FieldDefs.Add('X_KonecPrace', ftDateTime);
//        dtRowMatData.FieldDefs.Add('X_Storno', ftBoolean);

    dtRowEvData.FieldDefs.Add('Text', ftString, 160);
    dtRowEvData.FieldDefs.Add('VATRate_ID', ftString, 10);


















    pnTop := TPanel.Create(mForm);
    pnAll := TPanel.Create(mForm);
    with pnTop do
    begin
      Caption := ' ';
      Name := 'pnTop';
      Parent := mForm;
      Left := 0;
      Top := 0;
      Width := 651;
      Height := 97;
      Align := alTop;
      TabOrder := 1;
    end;
    with pnAll do
    begin
      Caption := ' ';
      Name := 'pnAll';
      Parent := mForm;
      Left := 0;
      Top := 97;
      Width := 651;
      Height := 214;
      Align := alClient;
      TabOrder := 5;
    end;

    lblDefinitions := TLabel.Create(mForm);
    with lblDefinitions do begin
      Name := 'lblDefinitions';
      Parent := pnTop;
      Left := 16;
      Top := 15;
      Width := 125;
      Height := 13;
      Caption := 'Předdefinovaná rozdělení:';
    end;

    lblTotalAmount := TLabel.Create(mForm);
    with lblTotalAmount do begin
      Name := 'lblTotalAmount';
      Parent := pnTop;
      Left := 16;
      Top := 46;
      Width := 130;
      Height := 13;
      Caption := 'Celkové množství pro rozpad:';
    end;

    lblRemainAmount := TLabel.Create(mForm);
    with lblRemainAmount do begin
      Name := 'lblRemainAmount';
      Parent := pnTop;
      Left := 16;
      Top := 70;
      Width := 86;
      Height := 13;
      Caption := 'Zbývá pro rozpad:';
    end;

    cbDefinitions := TComboBox.Create(mForm);
    with cbDefinitions do begin
      Name := 'cbDefinitions';
      Parent := pnTop;
      Left := 152;
      Top := 11;
      Width := 145;
      Height := 21;
      Style := csDropDownList;
      ItemHeight := 13;
      TabOrder := 2;
      OnChange := @cbDefinitionsOnChange;
    end;

    edTotalAmount := TNumEdit.Create(mForm);
    with edTotalAmount do begin
      Name := 'edTotalAmount';
      Parent := pnTop;
      Left := 152;
      Top := 41;
      Width := 121;
      Height := 21;
      AutoSize := False;
      TabOrder := 3;
    end;

    edRemainAmount := TNumEdit.Create(mForm);
    with edRemainAmount do begin
      Name := 'edRemainAmount';
      Parent := pnTop;
      Left := 152;
      Top := 65;
      Width := 121;
      Height := 21;
      AutoSize := False;
      TabOrder := 4;
    end;

    // prvni sloupec
    btnProceedDecay := TButton.Create(mForm);
    with btnProceedDecay do begin
      Name := 'btnProceedDecay';
      Parent := pnTop;
      Left := 415;
      Top := 8;
      Width := 81;
      Height := 25;
      Anchors := [akTop, akRight];
      Caption := 'Rozpadnout';
      TabOrder := 7;
      //ModalResult := mrOK;
      OnClick := @btnProceedDecayClick;
    end;

    btnCreateDecay := TButton.Create(mForm);
    with btnCreateDecay do begin
      Name := 'btnCreateDecay';
      Parent := pnTop;
      Left := 415;
      Top := 38;
      Width := 81;
      Height := 25;
      Anchors := [akTop, akRight];
      Caption := 'Uložit def.';
      TabOrder := 8;
      OnClick := @btnCreateDecayClick;
    end;

    btnClose := TButton.Create(mForm);
    with btnClose do begin
      Name := 'btnClose';
      Parent := pnTop;
      Left := 415;
      Top := 68;
      Width := 81;
      Height := 25;
      Anchors := [akTop, akRight];
      Caption := 'Zavřít';
      TabOrder := 9;
      OnClick := @btnCloseClick;
    end;

    btnDeleteDef := TButton.Create(mForm);
    with btnDeleteDef do begin
      Name := 'btnDeleteDef';
      Parent := pnTop;
      Left := 510;
      Top := 8;
      Width := 81;
      Height := 25;
      Anchors := [akTop, akRight];
      Caption := 'Odstranit def.';
      TabOrder := 10;
      OnClick := @btnDeleteDefClick;
    end;

    btnDeleteRow := TButton.Create(mForm);
    with btnDeleteRow do begin
      Name := 'btnDeleteRow';
      Parent := pnTop;
      Left := 510;
      Top := 38;
      Width := 81;
      Height := 25;
      Anchors := [akTop, akRight];
      Caption := 'Odstranit řádek';
      TabOrder := 11;
      OnClick := @btnDeleteClick;
    end;

    //  Evidence
    grdEv := TDBGrid.Create(mForm);
    with grdMat do
      begin
        Name := 'grdEvs';
        Parent := pnAll;
        Left := 8;
        Top := 8;
        Width := 200;
        Height := 195;
        //Align := alTop;
        Anchors := [akLeft, akTop, akRight, akBottom];
        DataSource := dsRowEvSource;
        TabOrder := 6;
        OnEditButtonClick := @btnEditButtonClick;
        Options := [dgEditing,dgAlwaysShowEditor,dgTitles,dgIndicator,dgColumnResize,dgColLines,dgRowLines,dgConfirmDelete,dgCancelOnExit];
        with Columns.Add do begin
          Expanded := False;
          FieldName := 'Itemtype';
          //PickList.Text := ACodeColumnValues;
          ReadOnly := True;
          Title.Caption := 'Typ';
          Width := 30;
          Visible := True;
        end;
        with Columns.Add do begin
          Expanded := False;
          FieldName := 'Store_ID';
          //ReadOnly := True;
          Title.Caption := 'Sklad';
          Width := 80;
          Visible := True;
          ButtonStyle := cbsEllipsis;
        end;
        with Columns.Add do begin
          Expanded := False;
          FieldName := 'StoreCard_ID';
          //ReadOnly := True;
          Title.Caption := 'Skladová karta';
          Width := 80;
          Visible := True;
          ButtonStyle := cbsEllipsis;
        end;
        with Columns.Add do begin
          Expanded := False;
          FieldName := 'Quantity';
          //ReadOnly := True;
          Title.Caption := 'Částka platby';
          Width := 100;
          Visible := True;
        end;

        with Columns.Add do begin
          Expanded := False;
          FieldName := 'WorkHoursPlanned';
          //ReadOnly := True;
          Title.Caption := 'Plán práce';
          Width := 100;
          Visible := True;
        end;

       with Columns.Add do begin
          Expanded := False;
          FieldName := 'WorkHoursReal';
          //ReadOnly := True;
          Title.Caption := 'Reálna práce';
          Width := 100;
          Visible := True;
        end;

               with Columns.Add do begin
          Expanded := False;
          FieldName := 'UnitPriceWithoutVAT';
          //ReadOnly := True;
          Title.Caption := 'Jednotková cena před slevou';
          Width := 100;
          Visible := True;
        end;

               with Columns.Add do begin
          Expanded := False;
          FieldName := 'X_konec_prace';
          //ReadOnly := True;
          Title.Caption := 'Konec práce';
          Width := 100;
          Visible := True;
        end;







 {


                with Columns.Add do begin
          Expanded := False;
          FieldName := 'X_QuantityTransport';
          //ReadOnly := True;
          Title.Caption := 'Množství vzdálenost';
          Width := 100;
          Visible := True;
        end;

                with Columns.Add do begin
          Expanded := False;
          FieldName := 'X_UnitPriceTransportWithoutVAT';
          //ReadOnly := True;
          Title.Caption := 'Částka za dopravu';
          Width := 100;
          Visible := True;
        end;

                with Columns.Add do begin
          Expanded := False;
          FieldName := 'X_Discount';
          //ReadOnly := True;
          Title.Caption := 'Sleva %';
          Width := 100;
          Visible := True;
        end;

                with Columns.Add do begin
          Expanded := False;
          FieldName := 'X_Koeficient';
          //ReadOnly := True;
          Title.Caption := 'Koeficient';
          Width := 100;
          Visible := True;
        end;

                with Columns.Add do begin
          Expanded := False;
          FieldName := 'X_KonecPrace';
          //ReadOnly := True;
          Title.Caption := 'Konec práce';
          Width := 100;
          Visible := True;
        end;
                with Columns.Add do begin
          Expanded := False;
          FieldName := 'X_storno';
          //ReadOnly := True;
          Title.Caption := 'Storno';
          Width := 100;
          Visible := True;
        end;
    }


        with Columns.Add do begin
          Expanded := False;
          FieldName := 'WorkerRole_ID';
          //ReadOnly := True;
          Title.Caption := 'Pracovník';
          Width := 80;
          Visible := True;
          ButtonStyle := cbsEllipsis;
        end;

        with Columns.Add do begin
          Expanded := False;
          FieldName := 'VatRate_ID';
          //ReadOnly := True;
          Title.Caption := '% DPH';
          Width := 80;
          Visible := True;
          ButtonStyle := cbsEllipsis;
        end;
         with Columns.Add do begin
          Expanded := False;
          FieldName := 'Text';
          //ReadOnly := True;
          Title.Caption := 'Text';
          Width := 200;
          Visible := True;
        end;



  //      dsRowSource.DataSet.AppendRecord([0,'2000000101','QXM0000101','FG10000101',]);

   {
        dsRowSource.DataSet.FieldByName('Itemtype').AsInteger := 0;
        dsRowSource.DataSet.FieldByName('Store_ID').Asstring := '2000000101';
        dsRowSource.DataSet.FieldByName('Storecard_ID').Asstring := 'QXM0000101';
        dsRowSource.DataSet.FieldByName('WorkerRole_ID').Asstring := 'FG10000101';
      }





















































      //  work
    grdWork := TDBGrid.Create(mForm);
    with grdWork do
      begin
        Name := 'grdWorks';
        Parent := pnAll;
        Left := 8;
        Top := 208;
        Width := 400;
        Height := 195;
        //Align := alTop;
        Anchors := [akLeft, akTop, akRight, akBottom];
        DataSource := dsRowWorkSource;
        TabOrder := 6;
        OnEditButtonClick := @btnEditButtonClick;
        Options := [dgEditing,dgAlwaysShowEditor,dgTitles,dgIndicator,dgColumnResize,dgColLines,dgRowLines,dgConfirmDelete,dgCancelOnExit];
        with Columns.Add do begin
          Expanded := False;
          FieldName := 'Itemtype';
          //PickList.Text := ACodeColumnValues;
          ReadOnly := True;
          Title.Caption := 'Typ';
          Width := 30;
          Visible := True;
        end;
        with Columns.Add do begin
          Expanded := False;
          FieldName := 'Store_ID';
          //ReadOnly := True;
          Title.Caption := 'Sklad';
          Width := 80;
          Visible := True;
          ButtonStyle := cbsEllipsis;
        end;
        with Columns.Add do begin
          Expanded := False;
          FieldName := 'StoreCard_ID';
          //ReadOnly := True;
          Title.Caption := 'Skladová karta';
          Width := 80;
          Visible := True;
          ButtonStyle := cbsEllipsis;
        end;
        with Columns.Add do begin
          Expanded := False;
          FieldName := 'Quantity';
          //ReadOnly := True;
          Title.Caption := 'Částka platby';
          Width := 100;
          Visible := True;
        end;

        with Columns.Add do begin
          Expanded := False;
          FieldName := 'WorkHoursPlanned';
          //ReadOnly := True;
          Title.Caption := 'Plán práce';
          Width := 100;
          Visible := True;
        end;

       with Columns.Add do begin
          Expanded := False;
          FieldName := 'WorkHoursReal';
          //ReadOnly := True;
          Title.Caption := 'Reálna práce';
          Width := 100;
          Visible := True;
        end;

               with Columns.Add do begin
          Expanded := False;
          FieldName := 'UnitPriceWithoutVAT';
          //ReadOnly := True;
          Title.Caption := 'Jednotková cena před slevou';
          Width := 100;
          Visible := True;
        end;

               with Columns.Add do begin
          Expanded := False;
          FieldName := 'X_konec_prace';
          //ReadOnly := True;
          Title.Caption := 'Konec práce';
          Width := 100;
          Visible := True;
        end;







 {


                with Columns.Add do begin
          Expanded := False;
          FieldName := 'X_QuantityTransport';
          //ReadOnly := True;
          Title.Caption := 'Množství vzdálenost';
          Width := 100;
          Visible := True;
        end;

                with Columns.Add do begin
          Expanded := False;
          FieldName := 'X_UnitPriceTransportWithoutVAT';
          //ReadOnly := True;
          Title.Caption := 'Částka za dopravu';
          Width := 100;
          Visible := True;
        end;

                with Columns.Add do begin
          Expanded := False;
          FieldName := 'X_Discount';
          //ReadOnly := True;
          Title.Caption := 'Sleva %';
          Width := 100;
          Visible := True;
        end;

                with Columns.Add do begin
          Expanded := False;
          FieldName := 'X_Koeficient';
          //ReadOnly := True;
          Title.Caption := 'Koeficient';
          Width := 100;
          Visible := True;
        end;

                with Columns.Add do begin
          Expanded := False;
          FieldName := 'X_KonecPrace';
          //ReadOnly := True;
          Title.Caption := 'Konec práce';
          Width := 100;
          Visible := True;
        end;
                with Columns.Add do begin
          Expanded := False;
          FieldName := 'X_storno';
          //ReadOnly := True;
          Title.Caption := 'Storno';
          Width := 100;
          Visible := True;
        end;
    }


        with Columns.Add do begin
          Expanded := False;
          FieldName := 'WorkerRole_ID';
          //ReadOnly := True;
          Title.Caption := 'Pracovník';
          Width := 80;
          Visible := True;
          ButtonStyle := cbsEllipsis;
        end;

        with Columns.Add do begin
          Expanded := False;
          FieldName := 'VatRate_ID';
          //ReadOnly := True;
          Title.Caption := '% DPH';
          Width := 80;
          Visible := True;
          ButtonStyle := cbsEllipsis;
        end;
         with Columns.Add do begin
          Expanded := False;
          FieldName := 'Text';
          //ReadOnly := True;
          Title.Caption := 'Text';
          Width := 200;
          Visible := True;
        end;



  //      dsRowSource.DataSet.AppendRecord([0,'2000000101','QXM0000101','FG10000101',]);

   {
        dsRowSource.DataSet.FieldByName('Itemtype').AsInteger := 0;
        dsRowSource.DataSet.FieldByName('Store_ID').Asstring := '2000000101';
        dsRowSource.DataSet.FieldByName('Storecard_ID').Asstring := 'QXM0000101';
        dsRowSource.DataSet.FieldByName('WorkerRole_ID').Asstring := 'FG10000101';
      }















       end;

















      //  materiál
    grdMat := TDBGrid.Create(mForm);
    with grdMat do
      begin
        Name := 'grdMats';
        Parent := pnAll;
        Left := 8;
        Top := 408;
        Width := 200;
        Height := 195;
        //Align := alTop;
        Anchors := [akLeft, akTop, akRight, akBottom];
        DataSource := dsRowMatSource;
        TabOrder := 6;
        OnEditButtonClick := @btnEditButtonClick;
        Options := [dgEditing,dgAlwaysShowEditor,dgTitles,dgIndicator,dgColumnResize,dgColLines,dgRowLines,dgConfirmDelete,dgCancelOnExit];
        with Columns.Add do begin
          Expanded := False;
          FieldName := 'Itemtype';
          //PickList.Text := ACodeColumnValues;
          ReadOnly := True;
          Title.Caption := 'Typ';
          Width := 30;
          Visible := True;
        end;
        with Columns.Add do begin
          Expanded := False;
          FieldName := 'Store_ID';
          //ReadOnly := True;
          Title.Caption := 'Sklad';
          Width := 80;
          Visible := True;
          ButtonStyle := cbsEllipsis;
        end;
        with Columns.Add do begin
          Expanded := False;
          FieldName := 'StoreCard_ID';
          //ReadOnly := True;
          Title.Caption := 'Skladová karta';
          Width := 80;
          Visible := True;
          ButtonStyle := cbsEllipsis;
        end;
        with Columns.Add do begin
          Expanded := False;
          FieldName := 'Quantity';
          //ReadOnly := True;
          Title.Caption := 'Částka platby';
          Width := 100;
          Visible := True;
        end;

        with Columns.Add do begin
          Expanded := False;
          FieldName := 'WorkHoursPlanned';
          //ReadOnly := True;
          Title.Caption := 'Plán práce';
          Width := 100;
          Visible := True;
        end;

       with Columns.Add do begin
          Expanded := False;
          FieldName := 'WorkHoursReal';
          //ReadOnly := True;
          Title.Caption := 'Reálna práce';
          Width := 100;
          Visible := True;
        end;

               with Columns.Add do begin
          Expanded := False;
          FieldName := 'UnitPriceWithoutVAT';
          //ReadOnly := True;
          Title.Caption := 'Jednotková cena před slevou';
          Width := 100;
          Visible := True;
        end;

               with Columns.Add do begin
          Expanded := False;
          FieldName := 'X_konec_prace';
          //ReadOnly := True;
          Title.Caption := 'Konec práce';
          Width := 100;
          Visible := True;
        end;



 end;



 {


                with Columns.Add do begin
          Expanded := False;
          FieldName := 'X_QuantityTransport';
          //ReadOnly := True;
          Title.Caption := 'Množství vzdálenost';
          Width := 100;
          Visible := True;
        end;

                with Columns.Add do begin
          Expanded := False;
          FieldName := 'X_UnitPriceTransportWithoutVAT';
          //ReadOnly := True;
          Title.Caption := 'Částka za dopravu';
          Width := 100;
          Visible := True;
        end;

                with Columns.Add do begin
          Expanded := False;
          FieldName := 'X_Discount';
          //ReadOnly := True;
          Title.Caption := 'Sleva %';
          Width := 100;
          Visible := True;
        end;

                with Columns.Add do begin
          Expanded := False;
          FieldName := 'X_Koeficient';
          //ReadOnly := True;
          Title.Caption := 'Koeficient';
          Width := 100;
          Visible := True;
        end;

                with Columns.Add do begin
          Expanded := False;
          FieldName := 'X_KonecPrace';
          //ReadOnly := True;
          Title.Caption := 'Konec práce';
          Width := 100;
          Visible := True;
        end;
                with Columns.Add do begin
          Expanded := False;
          FieldName := 'X_storno';
          //ReadOnly := True;
          Title.Caption := 'Storno';
          Width := 100;
          Visible := True;
        end;
    }


        with Columns.Add do begin
          Expanded := False;
          FieldName := 'WorkerRole_ID';
          //ReadOnly := True;
          Title.Caption := 'Pracovník';
          Width := 80;
          Visible := True;
          ButtonStyle := cbsEllipsis;
        end;

        with Columns.Add do begin
          Expanded := False;
          FieldName := 'VatRate_ID';
          //ReadOnly := True;
          Title.Caption := '% DPH';
          Width := 80;
          Visible := True;
          ButtonStyle := cbsEllipsis;
        end;
         with Columns.Add do begin
          Expanded := False;
          FieldName := 'Text';
          //ReadOnly := True;
          Title.Caption := 'Text';
          Width := 200;
          Visible := True;
        end;



  //      dsRowSource.DataSet.AppendRecord([0,'2000000101','QXM0000101','FG10000101',]);

   {
        dsRowSource.DataSet.FieldByName('Itemtype').AsInteger := 0;
        dsRowSource.DataSet.FieldByName('Store_ID').Asstring := '2000000101';
        dsRowSource.DataSet.FieldByName('Storecard_ID').Asstring := 'QXM0000101';
        dsRowSource.DataSet.FieldByName('WorkerRole_ID').Asstring := 'FG10000101';
      }























      end;
    //Konec vytvoření formuláře
    Result := mForm;
  except
    mForm.Free;
  end;
end;





procedure dtRowMatDataAfterInsert(DataSet: TDataSet);
begin
  ShowDebugMessage('zacatek prefill itemtype na 0');
  DataSet.FieldByName('Itemtype').AsInteger := 0;
  DataSet.FieldByName('Store_ID').Asstring := '2000000101';
  DataSet.FieldByName('Storecard_ID').Asstring := 'QXM0000101';
  DataSet.FieldByName('WorkerRole_ID').Asstring := 'FG10000101';
  if DataSet.FieldByName('Quantity').AsFloat = 0 then begin
    DataSet.FieldByName('Quantity').AsFloat := edRemainAmount.Value;
    edRemainAmount.Value := edRemainAmount.Value - edRemainAmount.Value; // lubi coz je nula vzdy ne?
  end;
end;

procedure dtRowWorkDataAfterInsert(DataSet: TDataSet);
begin
  ShowDebugMessage('zacatek prefill itemtype na 0');
  DataSet.FieldByName('Itemtype').AsInteger := 0;
  DataSet.FieldByName('Store_ID').Asstring := '2000000101';
  DataSet.FieldByName('Storecard_ID').Asstring := 'QXM0000101';
  DataSet.FieldByName('WorkerRole_ID').Asstring := 'FG10000101';
  if DataSet.FieldByName('Quantity').AsFloat = 0 then begin
    DataSet.FieldByName('Quantity').AsFloat := edRemainAmount.Value;
    edRemainAmount.Value := edRemainAmount.Value - edRemainAmount.Value; // lubi coz je nula vzdy ne?
  end;
end;

procedure dtRowEvDataAfterInsert(DataSet: TDataSet);
begin
  ShowDebugMessage('zacatek prefill itemtype na 0');
  DataSet.FieldByName('Itemtype').AsInteger := 0;
  DataSet.FieldByName('Store_ID').Asstring := '2000000101';
  DataSet.FieldByName('Storecard_ID').Asstring := 'QXM0000101';
  DataSet.FieldByName('WorkerRole_ID').Asstring := 'FG10000101';
  if DataSet.FieldByName('Quantity').AsFloat = 0 then begin
    DataSet.FieldByName('Quantity').AsFloat := edRemainAmount.Value;
    edRemainAmount.Value := edRemainAmount.Value - edRemainAmount.Value; // lubi coz je nula vzdy ne?
  end;
end;


procedure dtRowMatDataAfterPost(DataSet: TDataSet);
var
  mTotalAmount: Extended;
  mBookMark: TBookmark;
begin
  ShowDebugMessage('dtRowMatDataAfterPost');
  DataSet.DisableControls;
  try
    mBookMark := DataSet.GetBookmark;
    try
      mTotalAmount := 0;
      DataSet.First;
      while not DataSet.Eof do begin
        ShowDebugMessage('Mnozstvi: ' + FloatToStr(DataSet.FieldByName('Quantity').AsFloat));
        mTotalAmount := mTotalAmount + DataSet.FieldByName('Quantity').AsFloat;
        DataSet.Next;
      end;
      edRemainAmount.Value := edTotalAmount.Value - mTotalAmount;
      DataSet.First;
      while not DataSet.Eof do begin
        if DataSet.FieldByName('Quantity').AsFloat = 0 then begin
          DataSet.Edit;
          DataSet.FieldByName('Quantity').AsFloat := edRemainAmount.Value;
          edRemainAmount.Value := edTotalAmount.Value - mTotalAmount - edRemainAmount.Value; // lubi coz je nula vzdy ne?
          Break;
        end;
        DataSet.Next;
      end;
    finally
      DataSet.GotoBookmark(mBookMark);
      DataSet.FreeBookmark(mBookMark);
    end;
  finally
    DataSet.EnableControls;
  end;
end;

procedure dtRowWorkDataAfterPost(DataSet: TDataSet);
var
  mTotalAmount: Extended;
  mBookMark: TBookmark;
begin
  ShowDebugMessage('dtRowMatDataAfterPost');
  DataSet.DisableControls;
  try
    mBookMark := DataSet.GetBookmark;
    try
      mTotalAmount := 0;
      DataSet.First;
      while not DataSet.Eof do begin
        ShowDebugMessage('Mnozstvi: ' + FloatToStr(DataSet.FieldByName('Quantity').AsFloat));
        mTotalAmount := mTotalAmount + DataSet.FieldByName('Quantity').AsFloat;
        DataSet.Next;
      end;
      edRemainAmount.Value := edTotalAmount.Value - mTotalAmount;
      DataSet.First;
      while not DataSet.Eof do begin
        if DataSet.FieldByName('Quantity').AsFloat = 0 then begin
          DataSet.Edit;
          DataSet.FieldByName('Quantity').AsFloat := edRemainAmount.Value;
          edRemainAmount.Value := edTotalAmount.Value - mTotalAmount - edRemainAmount.Value; // lubi coz je nula vzdy ne?
          Break;
        end;
        DataSet.Next;
      end;
    finally
      DataSet.GotoBookmark(mBookMark);
      DataSet.FreeBookmark(mBookMark);
    end;
  finally
    DataSet.EnableControls;
  end;
end;

procedure dtRowEvDataAfterPost(DataSet: TDataSet);
var
  mTotalAmount: Extended;
  mBookMark: TBookmark;
begin
  ShowDebugMessage('dtRowEvDataAfterPost');
  DataSet.DisableControls;
  try
    mBookMark := DataSet.GetBookmark;
    try
      mTotalAmount := 0;
      DataSet.First;
      while not DataSet.Eof do begin
        ShowDebugMessage('Mnozstvi: ' + FloatToStr(DataSet.FieldByName('Quantity').AsFloat));
        mTotalAmount := mTotalAmount + DataSet.FieldByName('Quantity').AsFloat;
        DataSet.Next;
      end;
      edRemainAmount.Value := edTotalAmount.Value - mTotalAmount;
      DataSet.First;
      while not DataSet.Eof do begin
        if DataSet.FieldByName('Quantity').AsFloat = 0 then begin
          DataSet.Edit;
          DataSet.FieldByName('Quantity').AsFloat := edRemainAmount.Value;
          edRemainAmount.Value := edTotalAmount.Value - mTotalAmount - edRemainAmount.Value; // lubi coz je nula vzdy ne?
          Break;
        end;
        DataSet.Next;
      end;
    finally
      DataSet.GotoBookmark(mBookMark);
      DataSet.FreeBookmark(mBookMark);
    end;
  finally
    DataSet.EnableControls;
  end;
end;

procedure btnDeleteClick(Sender: TObject);
begin
  if not dtRowMatData.IsEmpty then
    dtRowMatData.Delete;
end;

procedure btnCreateDecayClick(Sender: TObject);
var
  mList: TStringList;
  mLine, mName: string;
  mIndex: integer;
begin
  // ulozeni definice
  if (dtRowMatData.State = dsInsert) or (dtRowMatData.State = dsEdit) then
    dtRowMatData.Post;
  mList := TStringList.Create;
  try
    mName := StringEditDlg(nil, 'Zadání názvu definice');
    if mName <> '' then begin
      dtRowMatData.First;
      while not dtRowMatData.Eof do begin
        mLine := dtRowMatData.FieldByName('Store_ID').AsString + '!' +
                 dtRowMatData.FieldByName('StoreCard_ID').AsString+ '!' +
                 dtRowMatData.FieldByName('WorkerRole_ID').AsString+ '!' +
                 dtRowMatData.FieldByName('VATRate_ID').AsString + '!' +
                 dtRowMatData.FieldByName('Text').AsString ;
        mList.Add(mLine);
        dtRowMatData.Next;
      end;
      SetValueToStorage(cStorageDataKey + '!*' + mName, mList.Text, fContext);
      if cbDefinitions.Items.IndexOf(mName) = -1 then begin
        mIndex := cbDefinitions.Items.Add(mName);
        cbDefinitions.ItemIndex := mIndex;
      end;
    end;
  finally
    mList.Free;
  end;
end;

procedure btnEditButtonClick(Sender: TObject);
var
  mOLE, mRoll: Variant;
  mRes_OID, mSQL, mSourceOID, mValue, mCountryOID: string;
  mGrid: TDBGrid;
  mField: TField;
  mStore,mStorecard,mWorkerRole, mVatRate: Boolean;
  mHeader: TNxCustomBusinessObject;
begin
  ShowDebugMessage('button click v gridu');
  mStore := False;
  mWorkerrole := False;
  mStorecard := False;
  mVatRate := False;
  if Sender is TDBGrid then begin
    mGrid := TDBGrid(sender);
    mField := mGrid.SelectedField;
    ShowDebugMessage(mField.FieldName);
    if mField.FieldName = 'VATRate_ID' then
      mVatRate := True;
    if mField.FieldName = 'Store_ID' then
      mStore := True;
      if mField.FieldName = 'StoreCard_ID' then
      mStorecard:= True;
    if mField.FieldName = 'WorkerRole_ID' then
      mWorkerRole := True;
    //ShowDebugMessage(IntToStr(mGrid.Col));
    mSourceOID := ''; // lubi mozna jiz zadana polozka
    mOLE := GetAbraOLEApplication;
    if mStore then begin
      ShowDebugMessage('pro sklad');
      mRoll := mOLE.GetRoll('O3ZO2K155FDL3CL100C4RHECN0', 0);
    end;
    if mWorkerRole then begin
      ShowDebugMessage('pro pracovníka');
      mRoll := mOLE.GetRoll('0FKKTBSSQKB4B3RLYBSJFFAFUW', 0);
    end;
    if mStorecard then begin
      ShowDebugMessage('pro skaldovou kartu');
      mRoll := mOLE.GetRoll('S3WZQKDB5FDL342M01C0CX3FCC', 0);
    end;

    if mVatRate then begin
      ShowDebugMessage('pro vatrate');
      mHeader := TNxNotPositionedRowBusinessObject(fObject).Header.BusinessObject;
      ShowDebugMessage('pro VATCountry_ID: ' + cVATCountry_ID);
      mCountryOID := cVATCountry_ID;
      mRoll := mOLE.GetRoll('KE4KIBA3Y3CL33N2010DELDFKK', 0); // tariff
      mRoll.Params.Add('Country_ID=' + mCountryOID);
    end else begin
      mRes_OID := mRoll.SelectDialog2(True, mSourceOID);
    end;
    
    ShowDebugMessage('vracene OID: ' + mRes_OID);

    if not NxIsEmptyOID(mRes_OID) then begin
      mSQL := 'select %s from %s where ID = ''%s''';
      if mStore then
        mSQL := Format(mSQL, ['Code', 'Stores', mRes_OID]);
      if mStorecard then
        mSQL := Format(mSQL, ['Code', 'Storecards', mRes_OID]);
      if mWorkerRole then
        mSQL := Format(mSQL, ['Name', 'SecurityRoles', mRes_OID]);

      if mVatRate then
        mSQL := Format(mSQL, ['Tariff', 'VatRates', mRes_OID]);
       mValue := GetFirstRecordFromSQL(fObjectSpace, mSQL);

      dtRowMatData.Edit;
      if mStore then
        dtRowMatData.FieldByName('Store_ID').AsString := mValue;
      if mStorecard then
        dtRowMatData.FieldByName('StoreCard_ID').AsString := mValue;
       if mWorkerRole then
        dtRowMatData.FieldByName('WorkerRole_ID').AsString := mValue;

      if mVatRate then
        dtRowMatData.FieldByName('VatRate_ID').AsFloat := NxIBStrToFloat(mValue);
      dtRowMatData.Post;
      dtRowMatData.Edit;
    end;
  end;
end;



procedure btnCloseClick(Sender: TObject);
var
  mForm: TForm;
begin
  mForm := TForm(TButton(Sender).Owner);
  mForm.Close;
end;

procedure btnDeleteDefClick(Sender: TObject);
var
  mName: string;
  mRes: integer;
begin
  if cbDefinitions.ItemIndex = -1 then begin
    ShowMessage('Pro vymazání definice musí být nejdříve vybrána definice.');
    Exit;
  end;
  mName := cbDefinitions.Items[cbDefinitions.ItemIndex];
  mRes := NxMessageBox('Dotaz', 'Opravdu si přejete vymazat definici "' + mName + '"?', mdConfirm, mdbYesNo, 1, nil, False, nil);
  if mRes = 6 then begin
    if DeleteValueFromCentralStorage(cStorageDataKey + '!*' + mName, fObjectSpace) then begin
      cbDefinitions.Items.Delete(cbDefinitions.ItemIndex);
      edRemainAmount.Value := edTotalAmount.Value;
      dtRowMatData.EmptyTable;
    end;
  end;
end;

procedure btnProceedDecayClick(Sender: TObject);
var
  mRes: integer;
  mVatRateOK, mStoreOK,mWorkerRoleOK,mStorecardOK: Boolean;
  mSQL, mResOID, mCountryOID: string;
  mBookMark: TBookmark;
  mList: TStringList;
  mHeader: TNxCustomBusinessObject;
begin
  if (dtRowMatData.State = dsInsert) or (dtRowMatData.State = dsEdit) then
    dtRowMatData.Post;

  mHeader := TNxNotPositionedRowBusinessObject(fObject).Header.BusinessObject;
  mCountryOID := cVATCountry_ID;

  mList := TstringList.Create;
  try
    dtRowMatData.DisableControls;
    try
      mBookMark := dtRowMatData.GetBookmark;
      try
        mVatRateOK := True;
        mStoreOK := True;
        mStorecardOK:= True;
        mWorkerRoleOK:= True;

        if edRemainAmount.Value <> 0 then begin
          ShowDebugMessage('nenulova castka rozpadu');
          // kontrola na vyplnenost castky
          mRes := NxMessageBox('Dotaz', 'Na řádky není rozdělena celá částka.' + cCrLf + 'Přejete si přesto rozpadnutí provést?', mdConfirm, mdbYesNo, 1, nil, False, nil);
          if not (mRes = 6) then
            Exit;
        end;

        dtRowMatData.First;
        while not dtRowMatData.Eof do begin
          if dtRowMatData.FieldByName('VatRate_ID').AsString <> '' then begin
            mSQL := 'select ID from VatRates where Tariff = %s and Hidden = ''N'' and Country_ID = ''%s''';  // lubi
            mSQL := Format(mSQL, [dtRowMatData.FieldByName('VatRate_ID').AsString, mCountryOID]);
            ShowDebugMessage('SQL: ' + mSQL);
            mResOID := GetFirstRecordFromSQL(fObjectSpace, mSQL);
            ShowDebugMessage('SQLres: ' + mResOID);
            if mResOID = '' then begin
              mVatRateOK := False;
              mList.Add(Format('Neplatná DPH sazba "%s" na řádku %s.', [dtRowMatData.FieldByName('VatRate_ID').AsString, IntToStr(dtRowMatData.RecNo)]));
            end;
          end
          else begin
          //  mVatRateOK := False;
          //  mList.Add(Format('DPH sazba na řádku %s není vyplněna.', [IntToStr(dtRowMatData.RecNo)]));
          end;

           if dtRowMatData.FieldByName('WorkerRole_ID').AsString <> '' then begin
            mSQL := 'select ID from SecurityRoles where Name = ''%s'' and Hidden = ''N''';
            mSQL := Format(mSQL, [dtRowMatData.FieldByName('WorkerRole_ID').AsString]);
            ShowDebugMessage('SQL: ' + mSQL);
            mResOID := GetFirstRecordFromSQL(fObjectSpace, mSQL);
            ShowDebugMessage('SQLres: ' + mResOID);
            if mResOID = '' then begin
           //   mStoreOK := False;
           //   mList.Add(Format('Neplatné pracovník "%s" na řádku %s.', [dtRowMatData.FieldByName('WorkerRole_ID').AsString, IntToStr(dtRowMatData.RecNo)]));
            end;
          end
          else begin
            mVatRateOK := False;
            mList.Add(Format('Pracovník na řádku %s není vyplněno.', [IntToStr(dtRowMatData.RecNo)]));
          end;

          if dtRowMatData.FieldByName('Store_ID').AsString <> '' then begin
            mSQL := 'select ID from Stores where Code = ''%s'' and Hidden = ''N''';
            mSQL := Format(mSQL, [dtRowMatData.FieldByName('Store_ID').AsString]);
            ShowDebugMessage('SQL: ' + mSQL);
            mResOID := GetFirstRecordFromSQL(fObjectSpace, mSQL);
            ShowDebugMessage('SQLres: ' + mResOID);
            if mResOID = '' then begin
            //  mStoreOK := False;
            //  mList.Add(Format('Neplatné Sklad "%s" na řádku %s.', [dtRowMatData.FieldByName('Store_ID').AsString, IntToStr(dtRowMatData.RecNo)]));
            end;
          end
          else begin
            mVatRateOK := False;
            mList.Add(Format('Sklad na řádku %s není vyplněno.', [IntToStr(dtRowMatData.RecNo)]));
          end;
          if dtRowMatData.FieldByName('StoreCard_ID').AsString <> '' then begin
            mSQL := 'select ID from Storecards where Code = ''%s'' and Hidden = ''N''';
            mSQL := Format(mSQL, [dtRowMatData.FieldByName('StoreCard_ID').AsString]);
            ShowDebugMessage('SQL: ' + mSQL);
            mResOID := GetFirstRecordFromSQL(fObjectSpace, mSQL);
            ShowDebugMessage('SQLres: ' + mResOID);
            if mResOID = '' then begin
            //  mStorecardOK:= False;
            //  mList.Add(Format('Neplatná skladová karta "%s" na řádku %s.', [dtRowMatData.FieldByName('StoreCard_ID').AsString, IntToStr(dtRowMatData.RecNo)]));
            end;
          end
          else begin
            mVatRateOK := False;
            mList.Add(Format('Skladová karta na řádku %s není vyplněno.', [IntToStr(dtRowMatData.RecNo)]));
          end;
          dtRowMatData.Next;
        end;
      finally
        dtRowMatData.GotoBookmark(mBookMark);
        dtRowMatData.FreeBookmark(mBookMark);
      end;
    finally
      dtRowMatData.EnableControls;
    end;
 //   if (not mVatRateOK) or (not mStoreOK) or (not mStorecardOK) or (not mWorkerRoleOK)  then begin
 //     ShowDebugMessage('nektera polozka nevyplnena');
 //     // kontrola na zadani polozek
 //     mRes := NxMessageBox('Dotaz', 'Na řádcích nejsou správně zadány všechny položky DPH sazeb, DPH indexů , skladových karet, pracovníků, nebo středisek.' + cCrLf + mList.Text + cCrLf + 'Přejete si přesto rozpadnutí provést?', mdConfirm, mdbYesNo, 1, nil, False, nil);
 //     if not (mRes = 6) then
 //       Exit;
    //end;
  finally
    mList.Free;
  end;
  ProceedDecay;
end;

procedure frmFormClose(Sender: TObject; var Action: TCloseAction);
var
  mCashDeskName, mDocQueueCode, mStoreCode,mworkerrole,mStorecardCode: string;
begin
  ShowDebugMessage('frmFormClose');
  if (dtRowMatData.State = dsInsert) or (dtRowMatData.State = dsEdit) then
    dtRowMatData.Post;
end;

procedure cbDefinitionsOnChange(Sender: TObject);
var
  mCombo: TComboBox;
  mResValueList: TStringList;
  mName, mDefinition, mValue, mLine: string;
  i: integer;
begin
  mResValueList := TStringList.Create;
  try
    mCombo := TComboBox(Sender);
    // predvyplneni podle definice
    mName := mCombo.Items[mCombo.ItemIndex];
    ShowDebugMessage('mName: ' + mName);
    mDefinition := GetValueFromStorage(cStorageDataKey + '!*' + mName, fContext);
    //ShowDebugMessage('mDefinition: ' + mDefinition);
    if mDefinition <> '' then begin
      mResValueList.Text := mDefinition;
      //ShowDebugMessage('mResValueList.Text: ' + mResValueList.Text);
      edRemainAmount.Value := edTotalAmount.Value;
      dtRowMatData.EmptyTable;
      for i := 0 to mResValueList.Count - 1 do begin
        dtRowMatData.Append;
        mLine := mResValueList.Strings[i];
        ShowDebugMessage('mLine: ' + mLine);
        mValue := CdTokenEx(mLine, '!');
        ShowDebugMessage('VATRate_ID: ' + mValue);
        dtRowMatData.FieldByName('VATRate_ID').AsString := mValue;
        mValue := CdTokenEx(mLine, '!');
        ShowDebugMessage('Text: ' + mValue);
        dtRowMatData.FieldByName('Text').AsString := mValue;
        mValue := CdTokenEx(mLine, '!');
        ShowDebugMessage('Store_ID: ' + mValue);
        dtRowMatData.FieldByName('Store_ID').AsString := mValue;
        mValue := CdTokenEx(mLine, '!');
        ShowDebugMessage('StoreCard_ID: ' + mValue);
        dtRowMatData.FieldByName('StoreCard_ID').AsString := mValue;
        mValue := CdTokenEx(mLine, '!');
        ShowDebugMessage('WorkerRole_ID: ' + mValue);
        dtRowMatData.FieldByName('WorkerRole_ID').AsString := mValue;
        mValue := CdTokenEx(mLine, '!');


        dtRowMatData.Post;
      end;
    end;
  finally
    mResValueList.Free;
  end;
end;

begin
end.