procedure BeforeSoftValidate_Hook(Self: TNxCustomBusinessObject);

var
  U_HmotnostTabule: Double;  // pro přepočet
  RemainingQuantity: Double; // zbývající množství na zdrojové pozici
  RemainingLength: Double; // zbývající hmotnost (přepočteno přes U_HmotnostTabule)
  slSQLResult: TStringList;
  SQLString: String;
  SQLResult: String;
  bInfo: Boolean;

begin
  // pouze pro řádek-výdej (validuje se na obě části LogStoreDocuments2), jsou vyplněny potřebné položky a jednotka je "KG" a není to plech
  if not NxIsEmptyOID(Self.GetFieldValueAsString('MasterRow_ID'))
     and not NxIsEmptyOID(Self.GetFieldValueAsString('StoreCard_ID'))
     and not NxIsEmptyOID(Self.GetFieldValueAsString('StoreBatch_ID'))
     and not NxIsEmptyOID(Self.GetFieldValueAsString('StorePosition_ID'))
     and not NxIsEmptyOID(Self.GetFieldValueAsString('IncomingStorePosition_ID'))
     and (UpperCase(Self.GetFieldValueAsString('QUnit')) = 'KG')
     and (NxLeft(Self.GetFieldValueAsString('StoreCard_ID.X_Form'), 1) <> 'P') then
  begin
    // položka pro přepočet
    U_HmotnostTabule := Self.GetFieldValueAsFloat('StoreCard_ID.U_HmotnostTabule');
    if U_HmotnostTabule > 0 then
    begin

      // (A) zjištění zbývajícího množství šarže na zdrojové pozici - pozor na (ne)uložení dokladu v databázi, pozor i na množství opravované
      SQLString := Format('SELECT LSC.Quantity - LSC.QuantityReserved FROM LogStoreContents LSC WHERE LSC.Parent_ID = %s AND LSC.StoreBatch_ID = %s',
                          [QuotedStr(Self.GetFieldValueAsString('StorePosition_ID')), QuotedStr(Self.GetFieldValueAsString('StoreBatch_ID'))]);
      SQLResult := SQLSelectFirstRow(Self.ObjectSpace, SQLString);
      if SQLResult <> '' then
      begin
        RemainingQuantity := StrToFloat(SQLResult);
        OutputDebugString(FloatToStr(RemainingQuantity));

        // korekce o počet uložený v databázi pro tento doklad
        SQLString := Format('SELECT LSD2.Quantity FROM LogStoreDocuments2 LSD2 WHERE LSD2.ID = %s AND LSD2.MasterRow_ID IS NOT NULL', [QuotedStr(Self.OID)]);
        SQLResult := SQLSelectFirstRow(Self.ObjectSpace, SQLString);
        if SQLResult <> '' then
        begin
          RemainingQuantity := RemainingQuantity + StrToFloat(SQLResult);
        end;
        OutputDebugString(FloatToStr(RemainingQuantity));

        // korekce o množství na rozeditovaném dokladu
        RemainingQuantity := RemainingQuantity - Self.GetFieldValueAsFloat('Quantity');

        OutputDebugString(FloatToStr(RemainingQuantity));

        // pro zbývající množství > 0
        if (RemainingQuantity > 0) then
        begin
          RemainingLength := RemainingQuantity / U_HmotnostTabule;
          bInfo := False;

          // vlastní kontrola na množství (délky)
          if (Self.GetFieldValueAsString('StorePosition_ID.X_Type') in ['A', 'B', 'D']) and (RemainingLength <= 6) then
          begin
            bInfo := True;
          end;
          if (Self.GetFieldValueAsString('StorePosition_ID.X_Type') in ['C', 'E']) and (RemainingLength <= 3) then
          begin
            bInfo := True;
          end;
          if (Self.GetFieldValueAsString('StorePosition_ID.X_Type') in ['F']) and (RemainingLength <= 4) then
          begin
            bInfo := True;
          end;
          if (Self.GetFieldValueAsString('StorePosition_ID.X_Type') in ['Z']) then
          begin
            if (RemainingQuantity <= 5) then // zde RemainingQuantity
            begin
              bInfo := True;
            end;
            if (RemainingQuantity <= (U_HmotnostTabule / 10)) then // explicitně určeno zákazníkem
            begin
              bInfo := True;
            end;
          end;

          // výpis
          if bInfo = True then
          begin
            Self.AddValidateError(Self.GetFieldCode('Quantity'),
              Format('Po převodu zůstane v pozici %s jen %s %s (%s m).',
                [Self.GetFieldValueAsString('StorePosition_ID.Code'), NxFormatNumeric('0.##,', RemainingQuantity), Self.GetFieldValueAsString('QUnit'), NxFormatNumeric('0.00,', RemainingLength)]));
          end;
        end; // RemainingQuantity > 0
      end; // (A)
    end; // U_HmotnostTabule > 0
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