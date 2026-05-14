// hlavní procedura pro AutoServer, která se stará o odpojování pozic
procedure AutoDisconnectStorePositions(OS: TNxCustomObjectSpace; var Success: Boolean; var LogInfoStr: String);
var
  I: Integer;
  SQLString: String;
  Executed: Boolean;
  Original_Executed: Boolean;
  mdExpPositions: TMemoryDataset;  // Expedition
  slSQLResult: TStringList;

begin
  LogInfoStr := '';
  mdExpPositions := TMemoryDataset.Create(nil);
  slSQLResult := TStringList.Create;
  try

    // dohledání všech expedičních pozic
    SQLString := 'SELECT LSP.ID AS ID, LSP.Code AS Code FROM LogStorePositions LSP WHERE LSP.PositionType = 1 AND LSP.ReservedForDoc_ID IS NOT NULL ORDER BY LSP.Code';
    OutputDebugString(SQLString);
    OS.SQLSelect2(SQLString, mdExpPositions);
    if mdExpPositions.RecordCount > 0 then
    begin
      mdExpPositions.First;
      for I := 0 to mdExpPositions.RecordCount - 1 do
      begin

        // kontrola obsahu pozice
        SQLString := Format('SELECT count(1) FROM LogStoreContents LSC WHERE LSC.Parent_ID = %s', [QuotedStr(mdExpPositions.FieldByName('ID').AsString)]);
        OutputDebugString(SQLString);
        OS.SQLSelect(SQLString, slSQLResult);
        OutputDebugString(slSQLResult.Text);

        // pokud je pozice prázdná, můžeme ji odpojit
        if StrToInt(slSQLResult.Strings(0)) = 0 then  // kontrola na existenci Strings(0) není třeba
        begin
          SQLString := Format('UPDATE LogStorePositions LSP SET LSP.ReservedForDocType = '''', LSP.ReservedForDoc_ID = NULL WHERE LSP.ID = %s', [QuotedStr(mdExpPositions.FieldByName('ID').AsString)]);
          OutputDebugString(SQLString);
          OS.SQLExecute(SQLString);
          LogInfoStr := LogInfoStr + mdExpPositions.FieldByName('Code').AsString + #13#10;
        end;

        mdExpPositions.Next;

      end;
    end;
  finally
    slSQLResult.Free;
  end;

  if LogInfoStr <> '' then
  begin
    LogInfoStr := 'Uvolněné pozice:' + #13#10 + LogInfoStr;
  end;

end;

////////////////////////////////////////////////////////////////////////////////

// procedura pro AutoServer, která se stará o čištění pozic
procedure AutoClearLogStorePositions(OS: TNxCustomObjectSpace; var Success: Boolean; var LogInfoStr: String);
var
  I: Integer;
  SQLString: String;
  mdSQLResult: TMemoryDataset;
  slLogStorePositions_ID: TStringList;
  LogStoreOutput_ID: String;
  boLogStoreOutput: TNxCustomBusinessObject;
  mcLogStoreOutputRows: TNxCustomBusinessMonikerCollection;
  boLogStoreOutputRow: TNxCustomBusinessObject;

  OLEApp: GetAbraOLEApplication;
  OLELogStoreOutput: Variant;

begin
  LogInfoStr := '';

  // načtení expedičních pozic, které mají pouze jednoduché karty
  SQLString := 'SELECT LSP.ID'
    + #13#10 + 'FROM LogStorePositions LSP'
    + #13#10 + 'WHERE PositionType = 1'
    + #13#10 + '  AND (SELECT count(LSC.ID) FROM LogStoreContents LSC WHERE LSP.ID = LSC.Parent_ID) > 0'
    + #13#10 + '  AND NOT EXISTS'
    + #13#10 + '  ('
    + #13#10 + '    SELECT LSC.ID'
    + #13#10 + '    FROM LogStoreContents LSC'
    + #13#10 + '    JOIN StoreCards SC ON SC.ID = LSC.StoreCard_ID'
    + #13#10 + '    WHERE LSP.ID = LSC.Parent_ID AND ((LSC.QuantityAwaited <> 0) OR (LSC.QuantityReserved <> 0) OR (SC.Category <> 0))'
    + #13#10 + '  )';
   slLogStorePositions_ID := TStringList.Create;
   try
     OS.SQLSelect(SQLString, slLogStorePositions_ID);

     OS.StartTransaction(taReadCommited);  // vše v jedné transakci
     try

       // odpojení OP od pozice
       for I := 0 to slLogStorePositions_ID.Count - 1 do
       begin
         SQLString := Format('UPDATE LogStorePositions LSP SET LSP.ReservedForDocType = '''', LSP.ReservedForDoc_ID = NULL WHERE LSP.ID = %s', [QuotedStr(slLogStorePositions_ID.Strings(I))]);
         OS.SQLExecute(SQLString);
       end;

       // tvorba dokladů
       for I := 0 to slLogStorePositions_ID.Count - 1 do
       begin
         boLogStoreOutput := OS.CreateObject(Class_LogStoreOutput);
         try
           // vytvoření hlavičky VP
           boLogStoreOutput.New;
           boLogStoreOutput.Prefill;
           boLogStoreOutput.SetFieldValueAsBoolean('NoStoreDocument', True);
           mcLogStoreOutputRows := boLogStoreOutput.GetLoadedCollectionMonikerForFieldCode(boLogStoreOutput.GetFieldCode('Rows'));

           // načtení obsahu pozice a tvorba řádků VP
           SQLString := 'SELECT LSP.Store_ID Store_ID, LSC.StoreCard_ID StoreCard_ID, LSC.Quantity Quantity'
             + #13#10 + 'FROM LogStoreContents LSC'
             + #13#10 + 'JOIN LogStorePositions LSP ON LSP.ID = LSC.Parent_ID'
             + #13#10 + 'WHERE LSC.Parent_ID = '+ QuotedStr(slLogStorePositions_ID.Strings(I));
           mdSQLResult := TMemoryDataset.Create(nil);
           OS.SQLSelect2(SQLString, mdSQLResult);
           try
             if mdSQLResult.RecordCount > 0 then
             begin
               mdSQLResult.First;
               while not mdSQLResult.Eof do
               begin
                 boLogStoreOutputRow := OS.CreateObject(Class_LogStoreOutputRow);
                 try
                   boLogStoreOutputRow := mcLogStoreOutputRows.AddNewObject;
                   boLogStoreOutputRow.Prefill;
                   boLogStoreOutputRow.SetFieldValueAsString('Store_ID', mdSQLResult.FieldByName('Store_ID').AsString);
                   boLogStoreOutputRow.SetFieldValueAsString('StoreCard_ID', mdSQLResult.FieldByName('StoreCard_ID').AsString);
                   boLogStoreOutputRow.SetFieldValueAsString('StorePosition_ID', slLogStorePositions_ID.Strings(I));
                   boLogStoreOutputRow.SetFieldValueAsFloat('Quantity', mdSQLResult.FieldByName('Quantity').AsFloat);
                   boLogStoreOutput.SetFieldValueAsString('Description', 'Automatické vyčištění pozice ' + boLogStoreOutputRow.GetFieldValueAsString('StorePosition_ID.Code'));
                 finally
                   boLogStoreOutputRow.Free;
                 end;

                 mdSQLResult.Next;
               end;
             end;
           finally
             mdSQLResult.Free;
           end;

           // uložení VP
           boLogStoreOutput.Save;

           // provedení přes OLE, ve skriptingu není podpora
           OLEApp := GetAbraOLEApplication;
           OLELogStoreOutput := OLEApp.CreateObject(Class_LogStoreOutput);
           OLELogStoreOutput.MakeExecuted(boLogStoreOutput.OID);

         finally
           boLogStoreOutput.Free;
         end;
       end;

       OS.Commit;
     except
       OS.RollBack;
       RaiseException(ExceptionMessage);
     end;

   finally
     slLogStorePositions_ID.Free;
   end;
end;

////////////////////////////////////////////////////////////////////////////////

begin
end.
