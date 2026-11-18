procedure AfterSetFieldValue_Hook(Self: TNxCustomBusinessObject; AFieldCode: Integer; AValue: TNxParameter; AOriginalValue: TNxParameter);

var
  mBody1: TStringList;
  mBody2: TStringList;
  mPneuID: string;
  mPrice: string;
  mQuantity1: string;
  mQuantity2: string;
  mInterCode: string;
  mManufacturer: string;
  mInterID: string;
  mName: string;

const
  mBodyFile1 = '\\192.168.1.194\AbraG3\B2B\temp\Bohumin\TXT\';
  mBodyFile2 = '\\192.168.1.194\AbraG3\B2B\temp\Praha\TXT\';
  mLogFile = '\\192.168.1.194\AbraG3\B2B\temp\log\';

begin
  if (Self.GetFieldCode('Amount') = AFieldCode) and (Self.GetFieldValueAsString('Parent_ID.PriceList_ID') = '2K00000101') and (Self.GetFieldValueAsString('Price_ID.Name') = 'prodejní cena')
  and not(CFxFloat.Equal3(AValue.AsFloat, AOriginalValue.AsFloat)) and (Self.GetFieldValueAsString('Parent_ID.StoreCard_ID.U_pneu_B2B') <> '0') then begin
    mInterID := Self.GetFieldValueAsString('Parent_ID.StoreCard_ID');
    mManufacturer := Self.GetFieldValueAsString('Parent_ID.StoreCard_ID.Producer_ID.Name');
    mInterCode := Trim(Self.GetFieldValueAsString('Parent_ID.StoreCard_ID.Code'));
    mQuantity1 := FloatToStr(NxEvalObjectExprAsFloat(Self, 'NxGetAvailableQuantity(''' + mInterID + ''', ''2000000101'', NxNow)'));
    mQuantity2 := FloatToStr(NxEvalObjectExprAsFloat(Self, 'NxGetAvailableQuantity(''' + mInterID + ''', ''3000000101;1300000101'', NxNow)'));
    mPrice := Self.GetFieldValueAsString('Amount');
    mPneuID := Self.GetFieldValueAsString('Parent_ID.StoreCard_ID.X_PneuID');
    mName := Self.GetFieldValueAsString('Parent_ID.StoreCard_ID.Name');
    mBody1 := TStringList.Create;
    mBody2 := TStringList.Create;
    try
      if (mPneuID <> '') then begin
        try
          mBody1.Add(mInterCode + #13#10 + mInterID + #13#10 + mPneuID + #13#10 + '<?xml version="1.0" encoding="utf-8"?>'#13#10'<Request xmlns="http://pneub2b.eu/SupplierStockPriceImport.xsd">'#13#10'<Items>'#13#10'<Item CodeInternal1="' + mInterID + '" Note="' + mName + '" ID="' + mPneuID + '" StockAmount="' + mQuantity1 + '" Price="' + mPrice + '"/>'#13#10'</Items>'#13#10'</Request>');
          mBody2.Add(mInterCode + #13#10 + mInterID + #13#10 + mPneuID + #13#10 + '<?xml version="1.0" encoding="utf-8"?>'#13#10'<Request xmlns="http://pneub2b.eu/SupplierStockPriceImport.xsd">'#13#10'<Items>'#13#10'<Item CodeInternal1="' + mInterID + '" Note="' + mName + '" ID="' + mPneuID + '" StockAmount="' + mQuantity2 + '" Price="' + mPrice + '"/>'#13#10'</Items>'#13#10'</Request>');
          mBody1.SaveToFile(mBodyFile1 + mInterCode + '.txt');
          mBody2.SaveToFile(mBodyFile2 + mInterCode + '.txt');
        except
          if fileexists(mBodyFile1 + mInterCode + '.txt') then begin
            NxShellExecute('open', 'C:\Windows\system32\WindowsPowerShell\v1.0\powershell.exe', '-windowstyle hidden -ExecutionPolicy Bypass \\192.168.1.194\AbraG3\B2B\FileDel.ps1 -File ' + '''' + mBodyFile1 + mInterCode + '.txt' + '''', nil);
            Sleep(5000);
          end else if fileexists(mBodyFile2 + mInterCode + '.txt') then begin
            NxShellExecute('open', 'C:\Windows\system32\WindowsPowerShell\v1.0\powershell.exe', '-windowstyle hidden -ExecutionPolicy Bypass \\192.168.1.194\AbraG3\B2B\FileDel.ps1 -File ' + '''' + mBodyFile2 + mInterCode + '.txt' + '''', nil);
            Sleep(5000);
          end;
          try
            mBody1.SaveToFile(mBodyFile1 + mInterCode + '.txt');
            mBody2.SaveToFile(mBodyFile2 + mInterCode + '.txt');
          except end;
          mBody1.Clear;
          mBody1.Add(ExceptionMessage);
          try
            mBody1.SaveToFile(mLogFile + 'Error-' + mInterCode + '.txt');
          except end;
        end;
      end;{end else begin
        try
          mBody1.Add(mInterCode + #13#10 + mInterID + #13#10 + mPneuID + #13#10 + '<?xml version="1.0" encoding="utf-8"?>'#13#10'<Request xmlns="http://pneub2b.eu/SupplierStockPriceImport.xsd">'#13#10'<Items>'#13#10'<Item CodeInternal1="' + mInterID + '" PartNo="' + mInterCode + '" Manufacturer="' + mManufacturer + '" StockAmount="' + mQuantity1 + '" Price="' + mPrice + '"/>'#13#10'</Items>'#13#10'</Request>');
          mBody2.Add(mInterCode + #13#10 + mInterID + #13#10 + mPneuID + #13#10 + '<?xml version="1.0" encoding="utf-8"?>'#13#10'<Request xmlns="http://pneub2b.eu/SupplierStockPriceImport.xsd">'#13#10'<Items>'#13#10'<Item CodeInternal1="' + mInterID + '" PartNo="' + mInterCode + '" Manufacturer="' + mManufacturer + '" StockAmount="' + mQuantity2 + '" Price="' + mPrice + '"/>'#13#10'</Items>'#13#10'</Request>');
          mBody1.SaveToFile(mBodyFile1 + mInterCode + '.txt');
          mBody2.SaveToFile(mBodyFile2 + mInterCode + '.txt');
        except
          if fileexists(mBodyFile1 + mInterCode + '.txt') then begin
            NxShellExecute('open', 'C:\Windows\system32\WindowsPowerShell\v1.0\powershell.exe', '-windowstyle hidden -ExecutionPolicy Bypass \\192.168.1.194\AbraG3\B2B\FileDel.ps1 -File ' + '''' + mBodyFile1 + mInterCode + '.txt' + '''', nil);
            Sleep(5000);
          end else if fileexists(mBodyFile2 + mInterCode + '.txt') then begin
            NxShellExecute('open', 'C:\Windows\system32\WindowsPowerShell\v1.0\powershell.exe', '-windowstyle hidden -ExecutionPolicy Bypass \\192.168.1.194\AbraG3\B2B\FileDel.ps1 -File ' + '''' + mBodyFile2 + mInterCode + '.txt' + '''', nil);
            Sleep(5000);
          end;
          try
            mBody1.SaveToFile(mBodyFile1 + mInterCode + '.txt');
            mBody2.SaveToFile(mBodyFile2 + mInterCode + '.txt');
          except end;
          mBody1.Clear;
          mBody1.Add (ExceptionMessage);
          try
            mBody1.SaveToFile(mLogFile + 'Error-' + mInterCode + '.txt');
          except end;
        end;
      end;}
    finally
      mBody1.Free;
      mBody2.Free;
    end;
  end;
end;

begin
end.