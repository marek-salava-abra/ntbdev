procedure PrepareDataSet(ADataSet: TMemoryDataset; var ALog: string;);
var
  mFieldDef: TFieldDef;
  mField: TField;
  mFieldNum: integer;
begin
  try
    mFieldNum:= 300000;
    AddField(ADataSet, 'ID', ftString, IncreaseByOne(mFieldNum), 10);
    AddField(ADataSet, 'DocumentNumber', ftString, IncreaseByOne(mFieldNum), 30);
    //AddField(ADataSet, 'DocumentType', ftString, IncreaseByOne(mFieldNum), 2);
    AddField(ADataSet, 'VarSymbol', ftString, IncreaseByOne(mFieldNum), 15);
    AddField(ADataSet, 'DocDate', ftDateTime, IncreaseByOne(mFieldNum));
    AddField(ADataSet, 'DueDate', ftDateTime, IncreaseByOne(mFieldNum));
    AddField(ADataSet, 'AmountWithoutVAT', ftFloat, IncreaseByOne(mFieldNum));
    AddField(ADataSet, 'Amount', ftFloat, IncreaseByOne(mFieldNum));
    AddField(ADataSet, 'PaidAmount', ftFloat, IncreaseByOne(mFieldNum));
    //AddField(ADataSet, 'NotPaid', ftFloat, IncreaseByOne(mFieldNum));
    AddField(ADataSet, 'CreditAmount', ftFloat, IncreaseByOne(mFieldNum));
    AddField(ADataSet, 'PaidCreditAmount', ftFloat, IncreaseByOne(mFieldNum));
    AddField(ADataSet, 'Selected', ftBoolean, IncreaseByOne(mFieldNum));
    AddField(ADataSet, 'Description', ftString, IncreaseByOne(mFieldNum), 100);

    ADataSet.FieldByName('Amount').Alignment:= taRightJustify;

  except
    ALog:= ALog + Format('PrapareDataSet - Vyskytla se chyba při přípravě datasetu %s', [ExceptionMessage])+ nxCrLf;
    RaiseException(Format('PrapareDataSet - Vyskytla se chyba při přípravě datasetu %s', [ExceptionMessage]));
    exit;
  end;
end;

procedure AddField(ADataSet: TMemoryDataset; const AFieldName: string; AFieldType: TFieldType; AFieldCode: integer; ASize: Integer = 0;);
var
  mFieldDef: TFieldDef;
begin
  mFieldDef := TFieldDef.Create(ADataSet.FieldDefs, AFieldName, AFieldType, ASize, False, AFieldCode);
  with mFieldDef.CreateField(ADataSet, nil, 'x' + AFieldName, False) do
  begin
    if ASize > 0 then
      Size := ASize;
    FieldKind := fkData;
    FieldName := AFieldName;
  end;
end;


procedure AddFloatField(ADataSet: TMemoryDataset; const AFieldName: string; AFieldType: TFieldType; AFieldCode: integer; ASize: Integer = 0;);
var
  mFieldDef: TFieldDef;
begin
  mFieldDef := TFieldDef.Create(ADataSet.FieldDefs, AFieldName, AFieldType, ASize, False, AFieldCode);
  with mFieldDef.CreateField(ADataSet, nil, 'x' + AFieldName, False) do
  begin
    if ASize > 0 then
      Size := ASize;
    FieldKind := fkData;
    FieldName := AFieldName;
    Alignment:= taRightJustify;
  end;
end;


function IncreaseByOne(var A: Integer): Integer;
begin
  Inc(A);
  Result:= A;
end;

begin
end.