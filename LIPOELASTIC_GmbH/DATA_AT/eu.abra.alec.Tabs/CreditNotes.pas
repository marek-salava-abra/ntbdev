uses '.lib';

procedure BuildLayout_CreditNotes(AGrid: TMultiGrid);
begin
  // Doporučení: nejdřív smazat existující sloupce, pokud tab přestavuješ opakovaně
  // AGrid.Columns.Clear; // podle verze komponenty

  AddTextCol(AGrid, 'ID', 'ID', 'colID', 60, 0, False);
  AddBoolCol(AGrid, 'Use', 'Selected', 'colSelected', 50, 1);
  AddTextCol(AGrid, 'Document', 'DocumentNumber', 'colDoc', 100, 2);
  AddTextCol(AGrid, 'VarSymbol', 'VarSymbol', 'colVar', 100, 3);
  AddDateCol(AGrid, 'DocDate', 'DocDate', 'colDocDate', 80, 4);
  AddDateCol(AGrid, 'DueDate', 'DueDate', 'colDueDate', 80, 5);
  AddFloatCol(AGrid, 'AmountWithoutVAT', 'AmountWithoutVAT', 'colAmountWithoutVAT', 100, 6);
  AddFloatCol(AGrid, 'Amount', 'Amount', 'colAmount', 100, 7);
  AddFloatCol(AGrid, 'Paid', 'PaidAmount', 'colPaid', 100, 8);
  //AddFloatCol(AGrid, 'CreditAmount', 'CreditAmount', 'colCreditAmount', 100, 9);
  //AddFloatCol(AGrid, 'PaidCreditAmount', 'PaidCreditAmount', 'colPaidCreditAmount', 100, 10);
  AddTextCol(AGrid, 'Description', 'Description', 'colDesc', 200, 11, True, True);


end;

procedure PrepareDataSet_CreditNotes(ADataSet: TMemoryDataset; var ALog: string);
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
    AddField(ADataSet, 'VarSymbol', ftString, IncreaseByOne(mFieldNum), 15);

    AddField(ADataSet, 'DocDate', ftDateTime, IncreaseByOne(mFieldNum));
    AddField(ADataSet, 'DueDate', ftDateTime, IncreaseByOne(mFieldNum));

    AddField(ADataSet, 'AmountWithoutVAT', ftFloat, IncreaseByOne(mFieldNum));
    AddField(ADataSet, 'Amount', ftFloat, IncreaseByOne(mFieldNum));
    AddField(ADataSet, 'PaidAmount', ftFloat, IncreaseByOne(mFieldNum));

    //AddField(ADataSet, 'CreditAmount', ftFloat, IncreaseByOne(mFieldNum));
    //AddField(ADataSet, 'PaidCreditAmount', ftFloat, IncreaseByOne(mFieldNum));

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

procedure Refresh_CreditNotes(AOS: TNxCustomObjectSpace; ADataSet: TMemoryDataset; AParams: TNxParameters);
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
        '   FROM "FSU$IssuedCreditNotes" FSU ' +
        '   WHERE FSU.Parent_ID = CN.ID ' +
     //   '     AND FSU.Index_ID = :IndexID ' +
        '     AND FSU.Word LIKE :Fulltext ' +
        ' ) ';

    mSQL :=
      ' SELECT ' +
      '   CN.ID AS ID, ' +
      '   DQ.Code || ''-'' || CAST(CN.OrdNumber AS VARCHAR) || ''/'' || PE.Code AS DocumentNumber, ' +
      '   CN.VarSymbol AS VarSymbol, ' +
      '   CN.DocDate$DATE AS DocDate, ' +
      '   CN.DueDate$DATE AS DueDate, ' +
      '   CN.AmountWithoutVAT AS AmountWithoutVAT, ' +
      '   CN.Amount AS Amount, ' +
      '   CN.PaidAmount AS PaidAmount, ' +
      //'   CN.CreditAmount AS CreditAmount, ' +
      //'   CN.PaidCreditAmount AS PaidCreditAmount, ' +
      '   CN.Description AS Description ' +
      ' FROM IssuedCreditNotes CN ' +
      ' JOIN DocQueues DQ ON DQ.ID = CN.DocQueue_ID ' +
      ' JOIN Periods  PE ON PE.ID = CN.Period_ID ' +
      ' WHERE CN.Firm_ID = :FirmID ' +
      '   AND CN.DocDate$DATE >= :DateFrom ' +
      '   AND CN.DocDate$DATE <= :DateTo ' +
          mFulltextSQL+
      ' ORDER BY CN.DocDate$DATE DESC ';

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
        ADataSet.FieldByName('VarSymbol').AsString:=        mTempDS.FieldByName('VarSymbol').AsString;
        ADataSet.FieldByName('DocDate').AsDateTime:=        mTempDS.FieldByName('DocDate').AsFloat;
        ADataSet.FieldByName('DueDate').AsDateTime:=        mTempDS.FieldByName('DueDate').AsFloat;
        ADataSet.FieldByName('AmountWithoutVAT').AsFloat:=  mTempDS.FieldByName('AmountWithoutVAT').AsFloat;
        ADataSet.FieldByName('Amount').AsCurrency:=            mTempDS.FieldByName('Amount').AsCurrency;
        ADataSet.FieldByName('PaidAmount').AsFloat:=        mTempDS.FieldByName('PaidAmount').AsFloat;
        //ADataSet.FieldByName('CreditAmount').AsFloat:=      mTempDS.FieldByName('CreditAmount').AsFloat;
        //ADataSet.FieldByName('PaidCreditAmount').AsFloat:=  mTempDS.FieldByName('PaidCreditAmount').AsFloat;
        ADataSet.FieldByName('Description').AsString:=      mTempDS.FieldByName('Description').AsString;

        TNumericField(ADataSet.FieldByName('AmountWithoutVAT')).DisplayFormat:= '#,##0.000';
        TNumericField(ADataSet.FieldByName('Amount')).DisplayFormat:= '#,##0.000';
        TNumericField(ADataSet.FieldByName('PaidAmount')).DisplayFormat:= '#,##0.000';
        //TNumericField(ADataSet.FieldByName('CreditAmount')).DisplayFormat:= '#,##0.000';
        //TNumericField(ADataSet.FieldByName('PaidCreditAmount')).DisplayFormat:= '#,##0.000';

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

procedure FillSortCombo_CreditNotes(ACombo: TComboBox);
begin
  if not Assigned(ACombo) then Exit;

  ACombo.Items.Clear;

  ACombo.Items.Add('DocumentNumber');
  ACombo.Items.Add('VarSymbol');
  ACombo.Items.Add('DocDate');
  ACombo.Items.Add('DueDate');
  ACombo.Items.Add('AmountWithoutVAT');
  ACombo.Items.Add('Amount');
  ACombo.Items.Add('PaidAmount');
  //ACombo.Items.Add('Credit');
  //ACombo.Items.Add('PaidCreditAmount');
  ACombo.Items.Add('Description');

  if ACombo.Items.Count > 0 then
    ACombo.ItemIndex := 0;
end;


begin
end.