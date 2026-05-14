procedure AfterSave_Hook(Self: TNxCustomBusinessObject);
var
  mOS: TNxCustomObjectSpace;
  mcRows: TNxCustomBusinessMonikerCollection;
  boRow: TNxCustomBusinessObject;
  mcBatchRows: TNxCustomBusinessMonikerCollection;
  boBatchRow: TNxCustomBusinessObject;
  boLSD: TNxCustomBusinessObject;
  mcLSDRows: TNxCustomBusinessMonikerCollection;
  boLSDRow: TNxCustomBusinessObject;
  SQLString: String;
  LSDRow_ID, LSD_ID: String;
  LSDBatchQuantity: Double;
  StoreBatch_ID: String;
  iRow, iBatchRow, iLSDRow: Integer;

begin
  mOS := Self.ObjectSpace;
  mcRows := Self.GetLoadedCollectionMonikerForFieldCode(Self.GetFieldCode('Rows'));
  for iRow := 0 to mcRows.Count - 1 do
  begin
    boRow := mcRows.BusinessObject(iRow);
    if boRow.GetFieldValueAsInteger('StoreCard_ID.Category') in [1, 2] then
    begin  // sériová čísla nebo šarže
      mcBatchRows := boRow.GetLoadedCollectionMonikerForFieldCode(boRow.GetFieldCode('DocRowBatches'));
      for iBatchRow := 0 to mcBatchRows.Count - 1 do
      begin
        boBatchRow := mcBatchRows.BusinessObject(iBatchRow);
        StoreBatch_ID := boBatchRow.GetFieldValueAsString('StoreBatch_ID');

        SQLString := Format('SELECT LSD2.ID FROM LogStoreDocuments2 LSD2 WHERE LSD2.StoreDocRow_ID = %s AND LSD2.StoreBatch_ID = %s', [QuotedStr(boRow.OID), QuotedStr(StoreBatch_ID)]);
        LSDRow_ID := SQLSelectFirstRow(mOS, SQLString);
        if not NxIsEmptyOID(LSDRow_ID) then
        begin
          SQLString := Format('SELECT LSD2.Parent_ID FROM LogStoreDocuments2 LSD2 WHERE LSD2.ID = %s', [QuotedStr(LSDRow_ID)]);
          LSD_ID := SQLSelectFirstRow(mOS, SQLString);  // hlavička musí vždy existovat - tj. bez kontroly na prázdné LSD_ID

          SQLString := Format('SELECT COALESCE(sum(Quantity), 0) FROM LogStoreDocuments2 LSD2 WHERE LSD2.StoreDocRow_ID = %s AND LSD2.StoreBatch_ID = %s', [QuotedStr(boRow.OID), QuotedStr(StoreBatch_ID)]);
          LSDBatchQuantity := StrToFloat(SQLSelectFirstRow(mOS, SQLString));
          OutputDebugString(FloatToStr(LSDBatchQuantity));

          boLSD := mOS.CreateObject(Class_LogStoreInput);
          try
            boLSD.Load(LSD_ID, nil);
            mcLSDRows := boLSD.GetLoadedCollectionMonikerForFieldCode(boLSD.GetFieldCode('Rows'));
            for iLSDRow := 0 to mcLSDRows.Count - 1 do
            begin
              boLSDRow := mcLSDRows.BusinessObject(iLSDRow);
              if boLSDRow.OID = LSDRow_ID then
              begin
//                boLSDRow.SetFieldValueAsFloat('InPositionQuantity', boBatchRow.GetFieldValueAsFloat('Quantity'));
                boLSDRow.SetFieldValueAsFloat('Quantity', boLSDRow.GetFieldValueAsFloat('Quantity') + (boBatchRow.GetFieldValueAsFloat('Quantity') - LSDBatchQuantity));
                break;  // pokud navýší množství na jednom řádku, dál se kontrolovat nemusí
              end;
            end;
            if boLSD.NeedSave then
            begin
              boLSD.Save;
            end;
          finally
            boLSD.Free;
          end;
        end;
      end;
    end
    else
    begin  // ostatní typy karet
    end;
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

begin
end.