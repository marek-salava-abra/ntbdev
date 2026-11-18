procedure AfterSave_Hook(Self: TNxCustomBusinessObject);

var
  mOrigQuantity : Double;
  mBody : TStringList;
  mPneuID : string;
  mQuantity : string;
  mInterCode : string;
  mManufacturer : string;
  mInterID : string;
  mPriceS : TStringList;
  mName : string;

const
  cBodyFile1 = '\\192.168.1.194\AbraG3\B2B\temp\Bohumin\TXT\';
  cLogFile1 = '\\192.168.1.194\AbraG3\B2B\temp\Bohumin\log\';
  cBodyFile2 = '\\192.168.1.194\AbraG3\B2B\temp\Praha\TXT\';
  cLogFile2 = '\\192.168.1.194\AbraG3\B2B\temp\Praha\log\';

begin
  if osNew in Self.State then mOrigQuantity := 0
  else Self.GetOriginalValue_1('Quantity', mOrigQuantity);
  if not(CFxFloat.Equal3(mOrigQuantity, Self.GetFieldValueAsFloat('Quantity'))) then

  if (Self.GetFieldValueAsString('Store_ID') = '2000000101') and (Self.GetFieldValueAsString('StoreCard_ID.U_pneu_B2B') <> '0') then begin   //Sklad 1 - Hlavní sklad Bohumín
    mPriceS := TStringList.Create;
    mInterID := Self.GetFieldValueAsString('StoreCard_ID.ID');
    mManufacturer := Self.GetFieldValueAsString('StoreCard_ID.Producer_ID.Name');
    mName := NxSearchReplace(Trim(Self.GetFieldValueAsString('StoreCard_ID.Name')), '"', '', 4);
    mInterCode := Trim(Self.GetFieldValueAsString('StoreCard_ID.Code'));
    mQuantity := FloatToStr(NxEvalObjectExprAsFloat(Self, 'NxGetAvailableQuantity(''' + Self.GetFieldValueAsString('StoreCard_ID') + ''', ''2000000101'', NxNow)'));
    Self.ObjectSpace.SQLSelect('SELECT Amount FROM StorePrices2 AS SP2 ' +
          'JOIN StorePrices AS SP ON SP.ID = SP2.Parent_ID ' +
          'WHERE SP.StoreCard_ID = ''' + Self.GetFieldValueAsString('StoreCard_ID') + ''' AND SP.PriceList_ID = ''2K00000101''', mPriceS);
    mPneuID := Self.GetFieldValueAsString('StoreCard_ID.X_PneuID');
    mBody := TStringList.Create;
    try
      if (mPneuID <> '') then begin
        try
          mBody.Add(mInterCode + #13#10 + mInterID + #13#10 + mPneuID + #13#10 + '<?xml version="1.0" encoding="utf-8"?>'#13#10'<Request xmlns="http://pneub2b.eu/SupplierStockPriceImport.xsd">'#13#10'<Items>'#13#10'<Item CodeInternal1="' + mInterID + '" Note="' + mName + '" ID="' + mPneuID + '" StockAmount="' + mQuantity + '" Price="' + mPriceS[0] + '"/>'#13#10'</Items>'#13#10'</Request>');
          mBody.SaveToFile(cBodyFile1 + mInterCode + '.txt');
        except
          if FileExists(cBodyFile1 + mInterCode + '.txt') then begin
            NxShellExecute('open', 'C:\Windows\system32\WindowsPowerShell\v1.0\powershell.exe', '-windowstyle hidden -ExecutionPolicy Bypass \\192.168.1.194\AbraG3\B2B\FileDel.ps1 -File ' + '''' + cBodyFile1 + mInterCode + '.txt' + '''', nil);
            Sleep(5000);
          end;
          try
            mBody.SaveToFile(cBodyFile1 + mInterCode + '.txt');
          except end;
          mBody.Clear;
          mBody.Add(ExceptionMessage);
          try
            mBody.SaveToFile(cLogFile1 + 'Error-' + mInterCode + '.txt');
          except end;
        end;
      end;{end else begin
        try
          mBody.Add(mInterCode + #13#10 + mInterID + #13#10 + mPneuID + #13#10 + '<?xml version="1.0" encoding="utf-8"?>'#13#10'<Request xmlns="http://pneub2b.eu/SupplierStockPriceImport.xsd">'#13#10'<Items>'#13#10'<Item CodeInternal1="' + mInterID + '" PartNo="' + mInterCode + '" Manufacturer="' + mManufacturer + '" StockAmount="' + mQuantity + '" Price="' + mPriceS[0] + '"/>'#13#10'</Items>'#13#10'</Request>');
          mBody.SaveToFile(cBodyFile1 + mInterCode + '.txt');
        except
          if FileExists(cBodyFile1 + mInterCode + '.txt') then begin
            NxShellExecute('open', 'C:\Windows\system32\WindowsPowerShell\v1.0\powershell.exe', '-windowstyle hidden -ExecutionPolicy Bypass \\192.168.1.194\AbraG3\B2B\FileDel.ps1 -File ' + '''' + cBodyFile1 + mInterCode + '.txt' + '''', nil);
            Sleep(5000);
          end;
          try
            mBody.SaveToFile(cBodyFile1 + mInterCode + '.txt');
          except end;
          mBody.Clear;
          mBody.Add(ExceptionMessage);
          try
            mBody.SaveToFile(cLogFile1 + 'Error-' + mInterCode + '.txt');
          except end;
        end;
      end;}
    finally
      mBody.Free;
      mPriceS.Free;
    end;  //Sklad 2 - Praha + Lovosice
  end else if ((Self.GetFieldValueAsString('Store_ID') = '3000000101') or (Self.GetFieldValueAsString('Store_ID') = '1300000101')) and (Self.GetFieldValueAsString('StoreCard_ID.U_pneu_B2B') <> '0') then begin
    mPriceS := TStringList.Create;
    mInterID := Self.GetFieldValueAsString('StoreCard_ID.ID');
    mManufacturer := Self.GetFieldValueAsString('StoreCard_ID.Producer_ID.Name');
    mInterCode := Trim(Self.GetFieldValueAsString('StoreCard_ID.Code'));
    mName := NxSearchReplace(Trim(Self.GetFieldValueAsString('StoreCard_ID.Name')), '"', '', 4);
    mQuantity := FloatToStr(NxEvalObjectExprAsFloat(Self, 'NxGetAvailableQuantity(''' + Self.GetFieldValueAsString('StoreCard_ID') + ''', ''3000000101;1300000101'', NxNow)'));
    Self.ObjectSpace.SQLSelect('SELECT Amount FROM StorePrices2 AS SP2 ' +
          'JOIN StorePrices AS SP ON SP.ID = SP2.Parent_ID ' +
          'WHERE SP.StoreCard_ID = ''' + Self.GetFieldValueAsString('StoreCard_ID') + ''' AND SP.PriceList_ID = ''2K00000101''', mPriceS);
    mPneuID := Self.GetFieldValueAsString('StoreCard_ID.X_PneuID');
    mBody := TStringList.Create;
    try
      if (mPneuID <> '') then begin
        try
          mBody.Add(mInterCode + #13#10 + mInterID + #13#10 + mPneuID + #13#10 + '<?xml version="1.0" encoding="utf-8"?>'#13#10'<Request xmlns="http://pneub2b.eu/SupplierStockPriceImport.xsd">'#13#10'<Items>'#13#10'<Item CodeInternal1="' + mInterID + '" Note="' + mName + '" ID="' + mPneuID + '" StockAmount="' + mQuantity + '" Price="' + mPriceS[0] + '"/>'#13#10'</Items>'#13#10'</Request>');
          mBody.SaveToFile(cBodyFile2 + mInterCode + '.txt');
        except
          if FileExists(cBodyFile2 + mInterCode + '.txt') then begin
            NxShellExecute('open', 'C:\Windows\system32\WindowsPowerShell\v1.0\powershell.exe', '-windowstyle hidden -ExecutionPolicy Bypass \\192.168.1.194\AbraG3\B2B\FileDel.ps1 -File ' + '''' + cBodyFile2 + mInterCode + '.txt' + '''', nil);
            Sleep(5000);
          end;
          try
            mBody.SaveToFile(cBodyFile2 + mInterCode + '.txt');
          except end;
          mBody.Clear;
          mBody.Add(ExceptionMessage);
          try
            mBody.SaveToFile(cLogFile2 + 'Error-' + mInterCode + '.txt');
          except end;
        end;
      end;{end else begin
        try
          mBody.Add(mInterCode + #13#10 + mInterID + #13#10 + mPneuID + #13#10 + '<?xml version="1.0" encoding="utf-8"?>'#13#10'<Request xmlns="http://pneub2b.eu/SupplierStockPriceImport.xsd">'#13#10'<Items>'#13#10'<Item CodeInternal1="' + mInterID + '" PartNo="' + mInterCode + '" Manufacturer="' + mManufacturer + '" StockAmount="' + mQuantity + '" Price="' + mPriceS[0] + '"/>'#13#10'</Items>'#13#10'</Request>');
          mBody.SaveToFile(cBodyFile2 + mInterCode + '.txt');
        except
          if FileExists(cBodyFile2 + mInterCode + '.txt') then begin
            NxShellExecute('open', 'C:\Windows\system32\WindowsPowerShell\v1.0\powershell.exe', '-windowstyle hidden -ExecutionPolicy Bypass \\192.168.1.194\AbraG3\B2B\FileDel.ps1 -File ' + '''' + cBodyFile2 + mInterCode + '.txt' + '''', nil);
            Sleep(5000);
          end;
          try
            mBody.SaveToFile(cBodyFile2 + mInterCode + '.txt');
          except end;
          mBody.Clear;
          mBody.Add(ExceptionMessage);
          try
            mBody.SaveToFile(cLogFile2 + 'Error-' + mInterCode + '.txt');
          except end;
        end;
      end;}
    finally
      mBody.Free;
      mPriceS.Free;
    end;
  end;
end;

begin
end.