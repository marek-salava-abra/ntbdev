uses '.lib';

procedure BuildLayout_OrdersIn(AGrid: TMultiGrid);
begin
  // Doporučení: nejdřív smazat existující sloupce, pokud tab přestavuješ opakovaně
  // AGrid.Columns.Clear; // podle verze komponenty

  AddTextCol(AGrid, 'ID', 'ID', 'colID', 60, 0, False);
  AddBoolCol(AGrid, 'Use', 'Selected', 'colSelected', 50, 1);
  AddTextCol(AGrid, 'Document', 'DocumentNumber', 'colDoc', 100, 2);
  AddTextCol(AGrid, 'Externalnumber', 'Externalnumber', 'colExternalnumber', 100, 3);
  AddTextCol(AGrid, 'State', 'State', 'colState', 100, 4);
  AddDateCol(AGrid, 'DocDate', 'DocDate', 'colDocDate', 80, 5);
  AddFloatCol(AGrid, 'AmountWithoutVAT', 'AmountWithoutVAT', 'colAmountWithoutVAT', 100, 6);
  AddFloatCol(AGrid, 'Amount', 'Amount', 'colAmount', 100, 7);
  AddTextCol(AGrid, 'Description', 'Description', 'colDesc', 200, 11, True, True);


end;

procedure PrepareDataSet_OrdersIn(ADataSet: TMemoryDataset; var ALog: string);
var
  mFieldNum: Integer;
begin
  if not Assigned(ADataSet) then Exit;

  // Idempotence: už připraveno? tak neotravuj dataset podruhé
  if ADataSet.FieldDefs.Count > 0 then Exit;

  try
    if ADataSet.Active then
      ADataSet.Close;

    mFieldNum := 300000;

    AddField(ADataSet, 'ID', ftString, IncreaseByOne(mFieldNum), 36);              // OID bývá delší než 10
    AddField(ADataSet, 'DocumentNumber', ftString, IncreaseByOne(mFieldNum), 30);
    AddField(ADataSet, 'ExternalNumber', ftString, IncreaseByOne(mFieldNum), 30);
    AddField(ADataSet, 'State', ftString, IncreaseByOne(mFieldNum), 30);

    AddField(ADataSet, 'DocDate', ftDateTime, IncreaseByOne(mFieldNum));

    AddField(ADataSet, 'AmountWithoutVAT', ftFloat, IncreaseByOne(mFieldNum));
    AddField(ADataSet, 'Amount', ftFloat, IncreaseByOne(mFieldNum));

    AddField(ADataSet, 'Selected', ftBoolean, IncreaseByOne(mFieldNum));
    AddField(ADataSet, 'Description', ftString, IncreaseByOne(mFieldNum), 200);

    // Aktivace datasetu (Open je bezpečný, protože je to TDataSet metoda)
    //ADataSet.FieldByName('Amount').Alignment:= taRightJustify;
    ADataSet.Open;
    //ADataSet.FieldByName('Amount').Alignment:= taRightJustify;
  except
    ALog := ALog + Format('PrepareDataSet_Invoices - chyba: %s', [ExceptionMessage]) + nxCrLf;
    RaiseException(Format('PrepareDataSet_Invoices - chyba: %s', [ExceptionMessage]));
  end;
end;

procedure Refresh_OrdersIn(AOS: TNxCustomObjectSpace; ADataSet: TMemoryDataset; AParams: TNxParameters);
var
  mParams: TNxParameters;
  mDateFrom, mDateTo: TDateTime;
  mSQL, mFulltextSQL: string;
  mTempDS: TMemoryDataset;
begin
  if (ADataSet = nil) or (AParams.GetOrCreateParam(dtString, 'FirmID').AsString = '') then
    Exit;

  ADataSet.FieldByName('Amount').Alignment:= taRightJustify;

  //mParams := TNxParameters.Create;
  mTempDS:= TMemoryDataset.Create(nil);
  try
    mDateTo := Date;
    mDateFrom := mDateTo - 90;

    // Parametry (žádné lepení float datumů do SQL)
    //mParams.NewFromDataType(dtString, 'FirmID').AsString := AFirmOID;
    //mParams.NewFromDataType(dtDate, 'DateFrom').AsDateTime := mDateFrom;
    //mParams.NewFromDataType(dtDate, 'DateTo').AsDateTime := mDateTo;

    mFulltextSQL:= '';
    if AParams.GetOrCreateParam(dtString, 'Fulltext').AsString <> '' then
      mFulltextSQL:=
        ' AND EXISTS ( ' +
        '   SELECT 1 ' +
        '   FROM "FSU$ReceivedOrders" FSU ' +
        '   WHERE FSU.Parent_ID = RO.ID ' +
     //   '     AND FSU.Index_ID = :IndexID ' +
        '     AND FSU.Word LIKE :Fulltext ' +
        ' ) ';

    mSQL :=
      ' SELECT ' +
      '   RO.ID AS ID, ' +
      '   DQ.Code || ''-'' || CAST(RO.OrdNumber AS VARCHAR) || ''/'' || PE.Code AS DocumentNumber, ' +
      '   RO.DocDate$DATE AS DocDate, ' +
      '   RO.ExternalNumber AS ExternalNumber, '+
      '   S.X_pr_name AS State, '+
      '   RO.AmountWithoutVAT AS AmountWithoutVAT, ' +
      '   RO.Amount AS Amount, ' +
      '   RO.Description AS Description ' +
      ' FROM ReceivedOrders RO ' +
      ' JOIN DocQueues DQ ON DQ.ID = RO.DocQueue_ID ' +
      ' JOIN Periods  PE ON PE.ID = RO.Period_ID ' +
      ' JOIN PMStates S ON S.ID = RO.PMState_ID '+
      ' WHERE RO.Firm_ID = :FirmID ' +
      '   AND RO.DocDate$DATE >= :DateFrom ' +
      '   AND RO.DocDate$DATE <= :DateTo ' +
          mFulltextSQL+
      ' ORDER BY RO.DocDate$DATE DESC ';

    ADataSet.DisableControls;
    try
      // bezpečné “vyčištění” před novým naplněním
      //if ADataSet.Active then
      //  ADataSet.Close;

      // Naplnění datasetu z SQL
      AOS.SQLSelect2(mSQL, mTempDS, AParams);

      ADataSet.EmptyTable;
      if mTempDS.Active then
        mTempDS.First;

      while not mTempDS.Eof do
      begin
        ADataSet.Append;
        ADataSet.FieldByName('ID').AsString:=               mTempDS.FieldByName('ID').AsString;
        ADataSet.FieldByName('DocumentNumber').AsString:=   mTempDS.FieldByName('DocumentNumber').AsString;
        ADataSet.FieldByName('ExternalNumber').AsString:=   mTempDS.FieldByName('ExternalNumber').AsString;
        ADataSet.FieldByName('State').AsString:=   mTempDS.FieldByName('State').AsString;
        ADataSet.FieldByName('DocDate').AsDateTime:=        mTempDS.FieldByName('DocDate').AsFloat;
        ADataSet.FieldByName('AmountWithoutVAT').AsFloat:=  mTempDS.FieldByName('AmountWithoutVAT').AsFloat;
        ADataSet.FieldByName('Amount').AsCurrency:=            mTempDS.FieldByName('Amount').AsCurrency;
        ADataSet.FieldByName('Description').AsString:=      mTempDS.FieldByName('Description').AsString;

        TNumericField(ADataSet.FieldByName('AmountWithoutVAT')).DisplayFormat:= '#,##0.000';
        TNumericField(ADataSet.FieldByName('Amount')).DisplayFormat:= '#,##0.000';

        ADataSet.Post;
        mTempDS.Next;
      end;

    finally
      ADataSet.EnableControls;
    end;

  finally
    //mParams.Free;
    mTempDS.Free;
  end;
end;


procedure FillSortCombo_OrdersIn(ACombo: TComboBox);
begin
  if not Assigned(ACombo) then Exit;

  ACombo.Items.Clear;

  ACombo.Items.Add('DocumentNumber');
  ACombo.Items.Add('ExternalNumber');
  ACombo.Items.Add('DocDate');
  ACombo.Items.Add('AmountWithoutVAT');
  ACombo.Items.Add('Amount');;
  ACombo.Items.Add('Description');

  if ACombo.Items.Count > 0 then
    ACombo.ItemIndex := 0;
end;


begin
end.