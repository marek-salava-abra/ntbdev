procedure Validate_Hook(Self: TNxCustomBusinessObject; var AResult: Boolean);
var
  mSqlData: TMemoryDataset;
begin
  mSqlData := TMemoryDataset.Create(nil);
  try
    if Self.GetFieldValueAsString('X_StoreCard_ID') = '0000000000' then begin
      Self.AddValidateError(Self.GetFieldCode('X_StoreCard_ID'), 'Vypňte prosím skladovou kartu.');
      AResult := False;
    end;
    if Self.GetFieldValueAsString('X_StoreCard2_ID') = '0000000000' then begin
      Self.AddValidateError(Self.GetFieldCode('X_StoreCard2_ID'), 'Vypňte prosím příslušenství.');
      AResult := False;
    end;
    if Self.GetFieldValueAsString('X_StoreCard_ID') = Self.GetFieldValueAsString('X_StoreCard2_ID') then begin
      Self.AddValidateError(Self.GetFieldCode('X_StoreCard2_ID'), 'V příslušenství je stejná položka jako ve skladové kartě.');
      AResult := False;
    end;
    if (AResult = True) and NxCheckBit(Self.State, osNew) then begin
      Self.ObjectSpace.SQLSelect2('SELECT A.ID' +
                                   ' FROM DefRollData A' +
                                   ' WHERE A.CLSID = ' + QuotedStr('2MV1EAYNMBW4RAH1W01CWIIWC0') +
                                     ' AND A.X_StoreCard_ID = ' + QuotedStr(Self.GetFieldValueAsString('X_StoreCard_ID')) +
                                     ' AND A.X_StoreCard2_ID = ' + QuotedStr(Self.GetFieldValueAsString('X_StoreCard2_ID')), mSqlData);
      if mSqlData.RecordCount > 0 then begin
        Self.AddValidateError(Self.GetFieldCode('X_StoreCard2_ID'), 'Pro skladovou kartu ' + Self.GetFieldValueAsString('X_StoreCard_ID.DisplayName') +
        ' již existuje příslušenství ' + Self.GetFieldValueAsString('X_StoreCard2_ID.DisplayName'));
        AResult := False;
      end;
    end;
  finally
    mSqlData.Free;
  end;
end;


procedure BeforeSave_Hook(Self: TNxCustomBusinessObject);
begin
  // Dle nazvu eshop tridi prislusentvi, pokud neni urceno poradi
  if Self.GetFieldValueAsString('X_StoreCard2_ID') <> '0000000000' then begin
    Self.SetFieldValueAsString('Code', NxLeft(Self.GetFieldValueAsString('X_StoreCard2_ID.Code'), 20));
    Self.SetFieldValueAsString('Name', NxLeft(Self.GetFieldValueAsString('X_StoreCard2_ID.Name'), 50));
  end;
  // Zatim to je pouzito ve zdroji eshopu
  Self.SetFieldValueAsInteger('X_DataType', 4);
end;

begin
end.