procedure AfterSave_Hook(Self: TNxCustomBusinessObject);
var
  mOrigQuantity : Double;
  mBody : TStringList;
  mPneuID : string;
  mPriceS : TStringList;
  mQuantity : string;
  mInterCode : string;
  mManufacturer : string;
  mInterID : string;
  mName : string;

const
  mBodyFile1 = '\\192.168.1.194\AbraG3\B2B\temp\Bohumin\TXT\';
  mLogFile1 = '\\192.168.1.194\AbraG3\B2B\temp\Bohumin\log\';
  mBodyFile2 = '\\192.168.1.194\AbraG3\B2B\temp\Praha\TXT\';
  mLogFile2 = '\\192.168.1.194\AbraG3\B2B\temp\Praha\log\';

begin
  if (Self.GetFieldValueAsInteger('RowType') <> 3) or (Self.GetFieldValueAsString('StoreCard_ID.U_pneu_B2B') = '0') then exit;
  mPriceS := TStringList.Create;
  mInterID := Self.GetFieldValueAsString('StoreCard_ID.ID');
  mManufacturer := Self.GetFieldValueAsString('StoreCard_ID.Producer_ID.Name');
  mInterCode := Trim(Self.GetFieldValueAsString('StoreCard_ID.Code'));
  mName := NxSearchReplace(Trim(Self.GetFieldValueAsString('StoreCard_ID.Name')), '"', '', 4);
  Self.ObjectSpace.SQLSelect('SELECT Amount FROM StorePrices2 AS SP2 ' +
        'JOIN StorePrices AS SP ON SP.ID = SP2.Parent_ID ' +
        'WHERE SP.StoreCard_ID = ''' + Self.GetFieldValueAsString('StoreCard_ID') + ''' AND SP.PriceList_ID = ''2K00000101''', mPriceS);
  mPneuID := Self.GetFieldValueAsString('StoreCard_ID.X_PneuID');
  mBody := TStringList.Create;
  try
    if Self.GetFieldValueAsString('Store_ID') = '2000000101' then begin
      mQuantity := FloatToStr(NxEvalObjectExprAsFloat(Self, 'NxGetAvailableQuantity(''' + Self.GetFieldValueAsString('StoreCard_ID') + ''', ''2000000101'', NxNow)'));
      if mPneuID <> '' then begin
        try
          mBody.Add(mInterCode + #13#10 + mInterID + #13#10 + mPneuID + #13#10 + '<?xml version="1.0" encoding="utf-8"?>'#13#10'<Request xmlns="http://pneub2b.eu/SupplierStockPriceImport.xsd">'#13#10'<Items>'#13#10'<Item CodeInternal1="' + mInterID + '" Note="' + mName + '" ID="' + mPneuID + '" StockAmount="' + mQuantity + '" Price="' + mPriceS[0] + '"/>'#13#10'</Items>'#13#10'</Request>');
          mBody.SaveToFile(mBodyFile1 + mInterCode + '.txt');
        except
          if FileExists(mBodyFile1 + mInterCode + '.txt') then begin
            NxShellExecute('open', 'C:\Windows\system32\WindowsPowerShell\v1.0\powershell.exe', '-windowstyle hidden -ExecutionPolicy Bypass \\192.168.1.194\AbraG3\B2B\FileDel.ps1 -File ' + '''' + mBodyFile1 + mInterCode + '.txt' + '''', nil);
            Sleep(5000);
          end;
          mBody.Clear;
          mBody.Add(ExceptionMessage);
           try
            mBody.SaveToFile(mLogFile1 + 'Error-' + mInterCode + '.txt');
          except end;
        end;
      end;{end else begin
        try
          mBody.Add (mInterCode + #13#10 + mInterID + #13#10 + mPneuID + #13#10 + '<?xml version="1.0" encoding="utf-8"?>'#13#10'<Request xmlns="http://pneub2b.eu/SupplierStockPriceImport.xsd">'#13#10'<Items>'#13#10'<Item CodeInternal1="' + mInterID + '" PartNo="' + mInterCode + '" Manufacturer="' + mManufacturer + '" StockAmount="' + mQuantity + '" Price="' + mPriceS[0] + '"/>'#13#10'</Items>'#13#10'</Request>');
         mBody.SaveToFile(mBodyFile1 + mInterCode + '.txt');
       except
         if FileExists(mBodyFile1 + mInterCode + '.txt') then begin
           NxShellExecute('open', 'C:\Windows\system32\WindowsPowerShell\v1.0\powershell.exe', '-windowstyle hidden -ExecutionPolicy Bypass \\192.168.1.194\AbraG3\B2B\FileDel.ps1 -File ' + '''' + mBodyFile1 + mInterCode + '.txt' + '''', nil);
           Sleep(5000);
         end;
         try
           mBody.SaveToFile(mBodyFile1 + mInterCode + '.txt');
         except end;
         mBody.Clear;
         mBody.Add(ExceptionMessage);
         try
           mBody.SaveToFile(mLogFile1 + 'Error-' + mInterCode + '.txt');
         except end;
        end;
      end;}
    end else if (Self.GetFieldValueAsString('Store_ID') = '3000000101') or (Self.GetFieldValueAsString('Store_ID') = '1300000101') then begin
      mQuantity := FloatToStr(NxEvalObjectExprAsFloat(Self, 'NxGetAvailableQuantity(''' + Self.GetFieldValueAsString('StoreCard_ID') + ''', ''3000000101;1300000101'', NxNow)'));
      if mPneuID <> '' then begin
        try
          mBody.Add(mInterCode + #13#10 + mInterID + #13#10 + mPneuID + #13#10 + '<?xml version="1.0" encoding="utf-8"?>'#13#10'<Request xmlns="http://pneub2b.eu/SupplierStockPriceImport.xsd">'#13#10'<Items>'#13#10'<Item CodeInternal1="' + mInterID + '" Note="' + mName + '" ID="' + mPneuID + '" StockAmount="' + mQuantity + '" Price="' + mPriceS[0] + '"/>'#13#10'</Items>'#13#10'</Request>');
          mBody.SaveToFile(mBodyFile2 + mInterCode + '.txt');
        except
          if FileExists(mBodyFile2 + mInterCode + '.txt') then begin
            NxShellExecute('open', 'C:\Windows\system32\WindowsPowerShell\v1.0\powershell.exe', '-windowstyle hidden -ExecutionPolicy Bypass \\192.168.1.194\AbraG3\B2B\FileDel.ps1 -File ' + '''' + mBodyFile2 + mInterCode + '.txt' + '''', nil);
            Sleep(5000);
          end;
          mBody.Clear;
          mBody.Add(ExceptionMessage);
           try
            mBody.SaveToFile(mLogFile2 + 'Error-' + mInterCode + '.txt');
          except end;
        end;
      end;{end else begin
        try
          mBody.Add (mInterCode + #13#10 + mInterID + #13#10 + mPneuID + #13#10 + '<?xml version="1.0" encoding="utf-8"?>'#13#10'<Request xmlns="http://pneub2b.eu/SupplierStockPriceImport.xsd">'#13#10'<Items>'#13#10'<Item CodeInternal1="' + mInterID + '" PartNo="' + mInterCode + '" Manufacturer="' + mManufacturer + '" StockAmount="' + mQuantity + '" Price="' + mPriceS[0] + '"/>'#13#10'</Items>'#13#10'</Request>');
         mBody.SaveToFile(mBodyFile2 + mInterCode + '.txt');
       except
         if FileExists(mBodyFile2 + mInterCode + '.txt') then begin
           NxShellExecute('open', 'C:\Windows\system32\WindowsPowerShell\v1.0\powershell.exe', '-windowstyle hidden -ExecutionPolicy Bypass \\192.168.1.194\AbraG3\B2B\FileDel.ps1 -File ' + '''' + mBodyFile2 + mInterCode + '.txt' + '''', nil);
           Sleep(5000);
         end;
         try
           mBody.SaveToFile(mBodyFile2 + mInterCode + '.txt');
         except end;
         mBody.Clear;
         mBody.Add(ExceptionMessage);
         try
           mBody.SaveToFile(mLogFile2 + 'Error-' + mInterCode + '.txt');
         except end;
        end;
      end;}
    end;
  finally
    mBody.Free;
    mPriceS.Free;
  end;
end;

procedure AfterDelete_Hook(Self: TNxCustomBusinessObject);

var
  mOrigQuantity : Double;
  mBody : TStringList;
  mPneuID : string;
  mPriceS : TStringList;
  mQuantity : string;
  mInterCode : string;
  mManufacturer : string;
  mInterID : string;

const
  mBodyFile1 = '\\192.168.1.194\AbraG3\B2B\temp\Bohumin\TXT\';
  mLogFile1 = '\\192.168.1.194\AbraG3\B2B\temp\Bohumin\log\';
  mBodyFile2 = '\\192.168.1.194\AbraG3\B2B\temp\Praha\TXT\';
  mLogFile2 = '\\192.168.1.194\AbraG3\B2B\temp\Praha\log\';

begin
  if (Self.GetFieldValueAsInteger('RowType') <> 3) or (Self.GetFieldValueAsString('StoreCard_ID.U_pneu_B2B') = '0') then exit;
  mPriceS := TStringList.Create;
  mInterID := Self.GetFieldValueAsString('StoreCard_ID.ID');
  mManufacturer := Self.GetFieldValueAsString('StoreCard_ID.Producer_ID.Name');
  mInterCode := Trim(Self.GetFieldValueAsString('StoreCard_ID.Code'));
  Self.ObjectSpace.SQLSelect('SELECT Amount FROM StorePrices2 AS SP2 ' +
        'JOIN StorePrices AS SP ON SP.ID = SP2.Parent_ID ' +
        'WHERE SP.StoreCard_ID = ''' + Self.GetFieldValueAsString('StoreCard_ID') + ''' AND SP.PriceList_ID = ''2K00000101''', mPriceS);
  mPneuID := Self.GetFieldValueAsString('StoreCard_ID.X_PneuID');
  mBody := TStringList.Create;
  try
    if Self.GetFieldValueAsString('Store_ID') = '2000000101' then begin
      mQuantity := FloatToStr(NxEvalObjectExprAsFloat(Self, 'NxGetAvailableQuantity(''' + Self.GetFieldValueAsString('StoreCard_ID') + ''', ''2000000101'', NxNow)'));
      if mPneuID <> '' then begin
        try
          mBody.Add(mInterCode + #13#10 + mInterID + #13#10 + mPneuID + #13#10 + '<?xml version="1.0" encoding="utf-8"?>'#13#10'<Request xmlns="http://pneub2b.eu/SupplierStockPriceImport.xsd">'#13#10'<Items>'#13#10'<Item ID="' + mPneuID + '" StockAmount="' + mQuantity + '" Price="' + mPriceS[0] + '"/>'#13#10'</Items>'#13#10'</Request>');
          mBody.SaveToFile(mBodyFile1 + mInterCode + '.txt');
        except
          if FileExists(mBodyFile1 + mInterCode + '.txt') then begin
            NxShellExecute('open', 'C:\Windows\system32\WindowsPowerShell\v1.0\powershell.exe', '-windowstyle hidden -ExecutionPolicy Bypass \\192.168.1.194\AbraG3\B2B\FileDel.ps1 -File ' + '''' + mBodyFile1 + mInterCode + '.txt' + '''', nil);
            Sleep(5000);
          end;
          mBody.Clear;
          mBody.Add(ExceptionMessage);
           try
            mBody.SaveToFile(mLogFile1 + 'Error-' + mInterCode + '.txt');
          except end;
        end;
      end;{end else begin
        try
          mBody.Add (mInterCode + #13#10 + mInterID + #13#10 + mPneuID + #13#10 + '<?xml version="1.0" encoding="utf-8"?>'#13#10'<Request xmlns="http://pneub2b.eu/SupplierStockPriceImport.xsd">'#13#10'<Items>'#13#10'<Item CodeInternal1="' + mInterID + '" PartNo="' + mInterCode + '" Manufacturer="' + mManufacturer + '" StockAmount="' + mQuantity + '" Price="' + mPriceS[0] + '"/>'#13#10'</Items>'#13#10'</Request>');
         mBody.SaveToFile(mBodyFile1 + mInterCode + '.txt');
       except
         if FileExists(mBodyFile1 + mInterCode + '.txt') then begin
           NxShellExecute('open', 'C:\Windows\system32\WindowsPowerShell\v1.0\powershell.exe', '-windowstyle hidden -ExecutionPolicy Bypass \\192.168.1.194\AbraG3\B2B\FileDel.ps1 -File ' + '''' + mBodyFile1 + mInterCode + '.txt' + '''', nil);
           Sleep(5000);
         end;
         try
           mBody.SaveToFile(mBodyFile1 + mInterCode + '.txt');
         except end;
         mBody.Clear;
         mBody.Add(ExceptionMessage);
         try
           mBody.SaveToFile(mLogFile1 + 'Error-' + mInterCode + '.txt');
         except end;
        end;
      end;}
    end else if (Self.GetFieldValueAsString('Store_ID') = '3000000101') or (Self.GetFieldValueAsString('Store_ID') = '1300000101') then begin
      mQuantity := FloatToStr(NxEvalObjectExprAsFloat(Self, 'NxGetAvailableQuantity(''' + Self.GetFieldValueAsString('StoreCard_ID') + ''', ''3000000101;1300000101'', NxNow)'));
      if mPneuID <> '' then begin
        try
          mBody.Add(mInterCode + #13#10 + mInterID + #13#10 + mPneuID + #13#10 + '<?xml version="1.0" encoding="utf-8"?>'#13#10'<Request xmlns="http://pneub2b.eu/SupplierStockPriceImport.xsd">'#13#10'<Items>'#13#10'<Item ID="' + mPneuID + '" StockAmount="' + mQuantity + '" Price="' + mPriceS[0] + '"/>'#13#10'</Items>'#13#10'</Request>');
          mBody.SaveToFile(mBodyFile2 + mInterCode + '.txt');
        except
          if FileExists(mBodyFile2 + mInterCode + '.txt') then begin
            NxShellExecute('open', 'C:\Windows\system32\WindowsPowerShell\v1.0\powershell.exe', '-windowstyle hidden -ExecutionPolicy Bypass \\192.168.1.194\AbraG3\B2B\FileDel.ps1 -File ' + '''' + mBodyFile2 + mInterCode + '.txt' + '''', nil);
            Sleep(5000);
          end;
          mBody.Clear;
          mBody.Add(ExceptionMessage);
           try
            mBody.SaveToFile(mLogFile2 + 'Error-' + mInterCode + '.txt');
          except end;
        end;
      end;{end else begin
        try
          mBody.Add (mInterCode + #13#10 + mInterID + #13#10 + mPneuID + #13#10 + '<?xml version="1.0" encoding="utf-8"?>'#13#10'<Request xmlns="http://pneub2b.eu/SupplierStockPriceImport.xsd">'#13#10'<Items>'#13#10'<Item CodeInternal1="' + mInterID + '" PartNo="' + mInterCode + '" Manufacturer="' + mManufacturer + '" StockAmount="' + mQuantity + '" Price="' + mPriceS[0] + '"/>'#13#10'</Items>'#13#10'</Request>');
         mBody.SaveToFile(mBodyFile2 + mInterCode + '.txt');
       except
         if FileExists(mBodyFile2 + mInterCode + '.txt') then begin
           NxShellExecute('open', 'C:\Windows\system32\WindowsPowerShell\v1.0\powershell.exe', '-windowstyle hidden -ExecutionPolicy Bypass \\192.168.1.194\AbraG3\B2B\FileDel.ps1 -File ' + '''' + mBodyFile2 + mInterCode + '.txt' + '''', nil);
           Sleep(5000);
         end;
         try
           mBody.SaveToFile(mBodyFile2 + mInterCode + '.txt');
         except end;
         mBody.Clear;
         mBody.Add(ExceptionMessage);
         try
           mBody.SaveToFile(mLogFile2 + 'Error-' + mInterCode + '.txt');
         except end;
        end;
      end;}
    end;
  finally
    mBody.Free;
    mPriceS.Free;
  end;
end;

begin
end.