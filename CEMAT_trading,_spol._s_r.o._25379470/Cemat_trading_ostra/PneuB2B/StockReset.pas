//Hlavní sklad Bohumín
procedure CardsExport1(OS: TNxCustomObjectSpace; var Success: Boolean; var LogInfoStr: String);
var
  mIDs : TStringList;
  mStoreCard : TStringList;
  mFileName : String;
  mFilePath : String;
  mI : integer;
  mII : integer;
  mIII : integer;
  mBody : TStringList;
  mCode : string;
  mPneuID : string;
  mQty : string;
  mPrice : TStringList;
  mManufacturer: string;

const
  cFilePath = '\\192.168.1.194\AbraG3\B2B\temp\Bohumin\TXT_R\';

begin
  mIDs := TStringList.Create;
  mBody := TStringList.Create;
  mStoreCard := TStringList.Create;
  mPrice := TStringList.Create;
  mIII := 0;
  mII := 0;
  try     //FieldCode 2000017 = U_Pneu_B2B, StringFieldValue 0 = Neodesílat do B2B
    OS.SQLSelect('SELECT UD.ID FROM StoreSubCards AS SSC ' +
                 'JOIN UserData AS UD ON UD.CLSID = ''C3V5QDVZ5BDL342M01C0CX3FCC'' ' +
                 'WHERE UD.FieldCode = ''2000017'' AND UD.StringFieldValue <> ''0'' ' +
                 'AND SSC.Store_ID = ''2000000101'' AND SSC.StoreCard_ID = UD.ID', mIDs);
    for mI := 0 to mIDs.Count - 1 do begin
      if mII = 0 then begin  //Hlavičku píšu jen do nového souboru
        mBody.Add('<?xml version="1.0" encoding="utf-8"?>');
        mBody.Add('<Request xmlns="http://pneub2b.eu/SupplierStockPriceImport.xsd">');
        mBody.Add('<Items>');
        mII := mII + 1;
      end;
      try   //Výrobce občas nebyl vyplněn, proto je v exceptu dotaz bez něj
        OS.SQLSelect('SELECT SC.Code, F.Name, SC.X_PneuID FROM StoreCards AS SC ' +
                     'JOIN Firms AS F ON F.ID = SC.Producer_ID ' +
                     'WHERE SC.ID = ''' + mIDs[mI] + '''', mStoreCard);
        OS.SQLSelect('SELECT Amount FROM StorePrices2 AS SP2 ' +
                     'JOIN StorePrices AS SP ON SP.ID = SP2.Parent_ID ' +
                     'WHERE SP.StoreCard_ID = ''' + mIDs[mI] + ''' AND SP.PriceList_ID = ''2K00000101''', mPrice);
        mQty := NxEvalObjectExprAsString(OS.CreateObject(Class_StoreCard), 'NxGetAvailableQuantity(''' + mIDs[mI] + ''', ''2000000101'', NxNow)');
        mCode := NxToken(mStoreCard[0], ';');
        mManufacturer := NxSearchReplace(NxToken(mStoreCard[0], ';'), '"', '', 4);  //&quot;
        mPneuID := NxToken(mStoreCard[0], ';');
        if (StrToInt(mQty) > 0) and (mPrice.Count = 1) then begin  //Na B2B se zasílají jen produkty s nenulovým stavem skladu
          mBody.Add('<Item CodeInternal1="' + mIDs[mI] + '" ID="' + mPneuID + '" PartNo="' + mCode + '" Manufacturer="' + mManufacturer + '" StockAmount="' + mQty + '" Price="' + mPrice[0] + '"/>');;
          mIII := mIII + 1;  //Počítám průchody, kde mQty > 0, abych jich měl vždy 100 v souboru
        end;

        if (mIII = 100) or (mI = mIDs.Count - 1) then begin
          mBody.Add('</Items>');
          mBody.Add('</Request>');
          mBody.SaveToFile(cFilePath + 'produkty-' + IntToStr(mI) + '.txt');
          mBody.Clear;
          mIII := 0;  //Po 100 průchodech s mQty > 0 vynuluji počítadla, abych založil nový soubor
          mII := 0;
        end;
      except
        try //Try blok kvůli poslednímu průchodu pro případy mI > mIDs.Count
          OS.SQLSelect('SELECT SC.Code, SC.X_PneuID FROM StoreCards AS SC ' +
                       'WHERE SC.ID = ''' + mIDs[mI] + '''', mStoreCard);
          OS.SQLSelect('SELECT Amount FROM StorePrices2 AS SP2 ' +
                       'JOIN StorePrices AS SP ON SP.ID = SP2.Parent_ID ' +
                       'WHERE SP.StoreCard_ID = ''' + mIDs[mI] + ''' AND SP.PriceList_ID = ''2K00000101''', mPrice);
          mQty := NxEvalObjectExprAsString(OS.CreateObject(Class_StoreCard), 'NxGetAvailableQuantity(''' + mIDs[mI] + ''', ''2000000101'', NxNow)');
          mCode := NxToken(mStoreCard[0], ';');
          mManufacturer := '';
          mPneuID := NxToken(mStoreCard[0], ';');
          if StrToInt(mQty) > 0 then begin
            mBody.Add('<Item CodeInternal1="' + mIDs[mI] + '" ID="' + mPneuID + '" PartNo="' + mCode + '" Manufacturer="' + mManufacturer + '" StockAmount="' + mQty + '" Price="' + mPrice[0] + '"/>');
            mIII := mIII + 1;
          end;
          if (mIII = 100) or (mI = mIDs.Count - 1) then begin
            mBody.Add('</Items>');
            mBody.Add('</Request>');
            mBody.SaveToFile(cFilePath + 'produkty-' + IntToStr(mI) + '.txt');
            mBody.Clear;
            mIII := 0;  //Po 100 průchodech s mQty > 0 vynuluji počítadla, abych založil nový soubor
            mII := 0;
          end;
        except end;
      end;
    end;
  finally
    mIDs.Free;
    mBody.Free;
    mStoreCard.Free;
    mPrice.Free;
  end;
end;

//Sklad Praha +9 Lovosice
procedure CardsExport2(OS: TNxCustomObjectSpace; var Success: Boolean; var LogInfoStr: String);
var
  mIDs : TStringList;
  mStoreCard : TStringList;
  mFileName : String;
  mFilePath : String;
  mI : integer;
  mII : integer;
  mIII : integer;
  mBody: TStringList;
  mCode : string;
  mPneuID : string;
  mQty : string;
  mPrice : TStringList;
  mManufacturer: string;

const
  cFilePath = '\\192.168.1.194\AbraG3\B2B\temp\Praha\TXT_R\';

begin
  mIDs := TStringList.Create;
  mBody := TStringList.Create;
  mStoreCard := TStringList.Create;
  mPrice := TStringList.Create;
  mIII := 0;
  mII := 0;
  try     //FieldCode 2000017 = U_Pneu_B2B, StringFieldValue 0 = Neodesílat do B2B
    OS.SQLSelect('SELECT DISTINCT UD.ID FROM StoreSubCards AS SSC ' +
                 'JOIN UserData AS UD ON UD.CLSID = ''C3V5QDVZ5BDL342M01C0CX3FCC'' ' +
                 'WHERE UD.FieldCode = ''2000017'' AND UD.StringFieldValue <> ''0'' ' +
                 'AND (SSC.Store_ID = ''3000000101'' OR SSC.Store_ID = ''1300000101'') AND SSC.StoreCard_ID = UD.ID', mIDs);
    for mI := 0 to mIDs.Count - 1 do begin
      if mII = 0 then begin
        mBody.Add('<?xml version="1.0" encoding="utf-8"?>');
        mBody.Add('<Request xmlns="http://pneub2b.eu/SupplierStockPriceImport.xsd">');
        mBody.Add('<Items>');
        mII := mII + 1;
      end;
      try   //Výrobce občas nebyl vyplněn, proto je v exceptu dotaz bez něj
        OS.SQLSelect('SELECT SC.Code, F.Name, SC.X_PneuID FROM StoreCards AS SC ' +
                     'JOIN Firms AS F ON F.ID = SC.Producer_ID ' +
                     'WHERE SC.ID = ''' + mIDs[mI] + '''', mStoreCard);
        OS.SQLSelect('SELECT Amount FROM StorePrices2 AS SP2 ' +
                     'JOIN StorePrices AS SP ON SP.ID = SP2.Parent_ID ' +
                     'WHERE SP.StoreCard_ID = ''' + mIDs[mI] + ''' AND SP.PriceList_ID = ''2K00000101''', mPrice);
        mQty := NxEvalObjectExprAsString(OS.CreateObject(Class_StoreCard), 'NxGetAvailableQuantity(''' + mIDs[mI] + ''', ''3000000101;1300000101'', NxNow)');
        mCode := NxToken(mStoreCard[0], ';');
        mManufacturer := NxSearchReplace(NxToken(mStoreCard[0], ';'), '"', '', 4);  //&quot;
        mPneuID := NxToken(mStoreCard[0], ';');
        if StrToInt(mQty) > 0 then begin  //Na B2B se zasílají jen produkty s nenulovým stavem skladu
          mBody.Add('<Item CodeInternal1="' + mIDs[mI] + '" ID="' + mPneuID + '" PartNo="' + mCode + '" Manufacturer="' + mManufacturer + '" StockAmount="' + mQty + '" Price="' + mPrice[0] + '"/>');
          mIII := mIII + 1;
        end;
        if (mIII = 100) or (mI = mIDs.Count - 1) then begin
          mBody.Add('</Items>');
          mBody.Add('</Request>');
          mBody.SaveToFile(cFilePath + 'produkty-' + IntToStr(mI) + '.txt');
          mBody.Clear;
          mIII := 0;  //Po 100 průchodech s mQty > 0 vynuluji počítadla, abych založil nový soubor
          mII := 0;
        end;
      except
        try //Try blok kvůli poslednímu průchodu pro případy mI > mIDs.Count
          OS.SQLSelect('SELECT SC.Code, SC.X_PneuID FROM StoreCards AS SC ' +
                       'WHERE SC.ID = ''' + mIDs[mI] + '''', mStoreCard);
          OS.SQLSelect('SELECT Amount FROM StorePrices2 AS SP2 ' +
                       'JOIN StorePrices AS SP ON SP.ID = SP2.Parent_ID ' +
                       'WHERE SP.StoreCard_ID = ''' + mIDs[mI] + ''' AND SP.PriceList_ID = ''2K00000101''', mPrice);
          mQty := NxEvalObjectExprAsString(OS.CreateObject(Class_StoreCard), 'NxGetAvailableQuantity(''' + mIDs[mI] + ''', ''3000000101;1300000101'', NxNow)');
          mCode := NxToken(mStoreCard[0], ';');
          mManufacturer := '';
          mPneuID := NxToken(mStoreCard[0], ';');
          if StrToInt(mQty) > 0 then begin
            mBody.Add('<Item CodeInternal1="' + mIDs[mI] + '" ID="' + mPneuID + '" PartNo="' + mCode + '" Manufacturer="' + mManufacturer + '" StockAmount="' + mQty + '" Price="' + mPrice[0] + '"/>');
            mIII := mIII + 1;
          end;
        if (mIII = 100) or (mI = mIDs.Count - 1) then begin
          mBody.Add('</Items>');
          mBody.Add('</Request>');
          mBody.SaveToFile(cFilePath + 'produkty-' + IntToStr(mI) + '.txt');
          mBody.Clear;
          mIII := 0;  //Po 100 průchodech s mQty > 0 vynuluji počítadla, abych založil nový soubor
          mII := 0;
        end;
        except end;
      end;
    end;
  finally
    mIDs.Free;
    mBody.Free;
    mStoreCard.Free;
    mPrice.Free;
  end;
end;


begin
end.