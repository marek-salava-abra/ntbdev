{ERR:
NxFindSiteForm}

uses  'eu.abra.roeh.Logio.ConstVar',
       'eu.abra.roeh.Logio.func',
      'eu.abra.roeh.Logio.LibCsv',
      'eu.abra.roeh.Logio.Lib';

const
 // fieldy faktury import
 cProduct_id = UpperCase('product_id');  //ID skladové karty ABRA
 cInventoro_product_id = UpperCase('inventoro_product_id'); // ID sklad. karty v rámci Inventoro
 cProduct_name =UpperCase('product_name'); //Jméno skladové karty POZOR často se vkládá jiná identifikace-  asi není k ničemu potřeba
 cStore_id =UpperCase('store_id'); // ABRA ID skladu
 cinventoro_store_id =UpperCase('inventoro_store_id'); //  ID skladu v rámci Inventoro
 cStore_name =UpperCase('store_name'); // Jméno skladu  - není potřeba
 cCategory_id=UpperCase('category_id'); // Kategorie - není potřeba
 cinventoro_category_id=UpperCase('inventoro_category_id'); // není potřeba
 ccategory_name=UpperCase('category_name'); // není potřeba
 cmonth=UpperCase('month'); // Měsíc
 cabc_margin =UpperCase('abc_margin'); // ABC zisk
 cabc_margin_revenue_sales = UpperCase('abc_margin_revenue_sales'); // ABC zisk +četnost prodejů
 cabc_margin_sales_frequency = UpperCase('abc_margin_sales_frequency'); // ABC zisk + tržby+ četnost prodejů
 cabc_revenue = UpperCase('abc_revenue'); //ABC tržby
 cabc_sales_frequency = UpperCase('abc_sales_frequency'); //ABC četnost prodeje
 cabc_sales_quantity=UpperCase('abc_sales_quantity'); //ABC množství prodeje
 cforecast_quantity=UpperCase('forecast_quantity'); //plánované množství
 cforecast_value=UpperCase('forecast_value'); //plánované hodnota
 cmax_inventory_quantity=UpperCase('order_quantity'); //Sklad. inventoro maximum
 cmax_inventory_value=UpperCase('order_quantity_value'); //Skald. inventoro max hodnota
 cmin_inventory_quantity=UpperCase('reorder_level_quantity'); //Sklad. inventoro minimum
 cmin_inventory_value=UpperCase('reorder_level_value'); //Skald. inventoro min hodnota
 con_hand_quantity=UpperCase('on_hand_quantity'); //disponibilní množství
 con_hand_value=UpperCase('on_hand_value'); //disponibilní hodnota
 csafetystock_quantity=UpperCase('safetystock_quantity'); // pojistná zásoba množství
 csafetystock_value=UpperCase('safetystock_value'); //pojistná zásoba  - hodnota
 cDateFrom = UpperCase('date_from'); // datum od
 cDateTo = UpperCase('date_to'); // datum od

  // Konstanty na import parametrů dodavatele ke skl. kartám
  cFirm_ID= UpperCase('Firm_ID');                // 1. Volba pro hledání
  cFirm_Code= UpperCase('Firm_Code');            // 2. Volba pro hledání
  cFirm_IC= UpperCase('Firm_IC');                // 3. Volba pro hledání
  cFirm_Name= UpperCase('Firm_Name');            // 4. Volba pro hledání
  cStoreCard_Id = UpperCase('StoreCard_ID');     // 1. Volba pro hledání
  cStoreCard_Code = UpperCase('StoreCard_Code'); // 2. Volba pro hledání

  cLeadTime = UpperCase('Lead time');
  cLeadPeriod = UpperCase('Periodicita');
  cstd_provider = UpperCase('Odchylka');
  cPacking = UpperCase('Packing');
  cMinimalQuantity = UpperCase('MinimalQuantity');

procedure DeleteForecastTab (mOS:TNxCustomObjectSpace);
var
 N: Integer;
 S : String;
begin
   S := Trim(GetParamValue(mOS,'PROMOTEST'));
   try
     if S = '' then N := 0
       else N := StrToInt(S); // ošetřeno na BO, že bude Jen Integer
    Except
      N :=0;
    end;
  if N = 0 then mOS.SQLExecute('DELETE from FORECAST_INV')
   else mOS.SQLExecute('DELETE from FORECAST_INV where Promo = ' + IntToStr(N));
end;

procedure CreateTebleForecast (mOS:TNxCustomObjectSpace);
Const
  cCreateTable = 'CREATE TABLE FORECAST_INV (PARENT_ID ID , QUANTITY  QUANTITY , DATEFrom DATETIME ,FORECASTDATE   DATETIME , FORECASTVALUE  AMOUNT ,PROMO SMALLINT DEFAULT 0);';
  cCreateTableOra = 'CREATE TABLE FORECAST_INV (PARENT_ID CHAR(10), QUANTITY  NUMERIC(15,6) DEFAULT 0 NOT NULL, DATEFROM  DOUBLE PRECISION DEFAULT 0 NOT NULL, FORECASTDATE  DOUBLE PRECISION DEFAULT 0 NOT NULL, FORECASTVALUE NUMERIC(13,2) DEFAULT 0 NOT NULL,PROMO SMALLINT DEFAULT 0);';
  cCreateTableMSSQL = 'CREATE TABLE FORECAST_INV (PARENT_ID CHAR(10) COLLATE Czech_CS_AS, QUANTITY  NUMERIC(15,6) DEFAULT 0 NOT NULL, DATEFROM  DOUBLE PRECISION DEFAULT 0 NOT NULL,FORECASTDATE  DOUBLE PRECISION DEFAULT 0 NOT NULL,  FORECASTVALUE NUMERIC(13,2) DEFAULT 0 NOT NULL,PROMO SMALLINT DEFAULT 0);';
  cCreateIndex = 'ALTER TABLE FORECAST_INV ADD CONSTRAINT FK_FORECAST_INV_2 FOREIGN KEY (PARENT_ID) REFERENCES STORESUBCARDS (ID) ON DELETE CASCADE ON UPDATE CASCADE;';
  cCreateIndexDate ='CREATE INDEX FORECAST_INV_IDX1 ON FORECAST_INV (FORECASTDATE);';
  cCreateIndexOra = 'ALTER TABLE FORECAST_INV ADD CONSTRAINT FK_FORECAST_INV_2 FOREIGN KEY (PARENT_ID) REFERENCES STORESUBCARDS (ID);';
  cCreateIndexDateMSSQL ='CREATE INDEX FORECAST_INV_IDX1 ON dbo.FORECAST_INV (FORECASTDATE);';
var
 Str : TStringList;
begin
  Str := TStringList.Create;
  try
    if CFxNxRuntime.NxGetDatabaseCode = 'IB' then begin
     mOS.SQLSelect('select RDB$RELATION_NAME from  RDB$RELATIONS R where  Upper(R.RDB$RELATION_NAME) = ''FORECAST_INV''',Str);
     if Str.Count >0 then DeleteForecastTab(mOS)
     else begin
       try
         mOS.SQLExecute(cCreateTable);
       except end;
       mOS.SQLExecute(cCreateIndex);
       mOS.SQLExecute(cCreateIndexDate);
     end;
    end;

    if CFxNxRuntime.NxGetDatabaseCode = 'ORA' then begin
      mOS.SQLSelect('select table_name from user_tables where Upper(table_name)= ''FORECAST_INV''',Str);
    if Str.Count >0 then DeleteForecastTab(mOS)
     else begin
       try
         mOS.SQLExecute(cCreateTableOra);
       except end;
        mOS.SQLExecute(cCreateIndexOra);
        mOS.SQLExecute(cCreateIndexDate);
     end;
    end;
   if CFxNxRuntime.NxGetDatabaseCode = 'MSSQL' then begin
      mOS.SQLSelect('select name from sysobjects where Upper(name)= ''FORECAST_INV''',Str);
    if Str.Count >0 then DeleteForecastTab(mOS)
     else begin
       try
         mOS.SQLExecute(cCreateTableMSSQL);
       except end;
       mOS.SQLExecute(cCreateIndex);
       mOS.SQLExecute(cCreateIndexDateMSSQL);
     end;
    end;

  finally
    Str.Free;
  end;
end;

Procedure SetNewProduct;
begin
{update storesubcards sbc
set sbc.X_abc_margin_sales_frequency = 'N'
where sbc.quantity>0 and (not Exists (select 1
        from storedocuments sd
        inner join storedocuments2 sd2 on SD2.parent_id = SD.id
        where Sd.DocumentType = '20' and sd.docdate$date < 41275 /*1.1.2013*/
         and sd2.storecard_id = SBC.storecard_id))
}
end;

function GetIdSubStoreCards(mOS:TNxCustomObjectSpace; const iStoreCardID,iStoreID:string):string;// získá ID dílčí skladové karty
var
  Str: TStringList;
begin
  Result:= '';
  Str := TStringList.Create;
  try
    Str.Clear;
    mOs.SQLSelect('select id from StoreSubCards ssc where ssc.StoreCard_ID =''' + iStoreCardID + ''' and ssc.Store_ID=''' + iStoreID +'''',Str);
    if Str.Count > 0 then
      Result := Str.Strings[0]
  finally
    Str.free;
  end;
end;

function CreateSubStoreCards(mOS:TNxCustomObjectSpace; const iStoreCardID,iStoreID:string):string;// získá ID dílčí skladové karty
//Založí dílčí skladovou kartu, jestli neexistovala. Tato situace může nastat, když Export je vytvořen pro nadřízený sklad
//(neanalyzuji daný) a nanadřízeném tato dílčí neexistuje
var
  mBo : TNxCustomBusinessObject;
begin
  Result:= '';
  mBo := mOS.CreateObject(Class_StoreSubCard);
  try
    mBo.New;
    mBo.Prefill;
    mBo.SetFieldValueAsString('Store_ID',iStoreID);
    mBo.SetFieldValueAsString('StoreCard_ID',iStoreCardID);
    mBo.Save;
    Result := mBo.OID;
  finally
    mBo.free;
  end;
end;
procedure InsertForecast(OS: TNxCustomObjectSpace; const mStoreSubCard_ID: String;const mForecast,mDateFrom,mDateTo,mForecastValue: Extended;mPromo:integer);
var
 s : string;
begin
 S := 'INSERT INTO FORECAST_INV (PARENT_ID, QUANTITY,DATEFrom,FORECASTDATE,FORECASTVALUE,PROMO) VALUES ('''+mStoreSubCard_ID+''','+NxFloatToIBStr(mForecast)+','+ NxFloatToIBStr(mDateFrom)+
         ','+ NxFloatToIBStr(mDateTo)+ ',' +NxFloatToIBStr(mForecastValue) + ',' + IntToStr(mPromo) + ')';
 Os.SQLExecute (s);
end;


procedure mImportLogio(OS: TNxCustomObjectSpace;mCSVStr:TStringList; var mLogInfoStr:string; ASite:TSiteForm);
var
  mList, mErrorMessage : TStringList;
  N : Integer;
//  mColum : Integer;
  mField: string;
  mUvoz: Boolean; //určuje zda daná položka je typu string
  mBoDoc, mDocRow : TNxCustomBusinessObject;
  mValue,mS:string;
  mIdOrgFak:String;
  mStoreCard_ID,mStore_ID,mStoreSubCard_ID,mOldStoreSubCard_ID: string;
  mForecast,mForecastValue : Extended;
  mDateFrom,mDateTo : TDateTime;
  mTypImportu : boolean;
  iStoreCard_ID,iStore_id,iForecast,iDateFrom,iDateTo,imin_inventory_quantity,imax_inventory_quantity : integer;
  iinventoro_store_id, iInventoro_product_id, iinventoro_category_id, iabc_margin, iabc_margin_revenue_sales,iForecastValue : integer;
  iabc_margin_sales_frequency, iabc_revenue, iabc_sales_frequency, iabc_sales_quantity,isafetystock_quantity,isafetystock_value :integer;
  mF : TForm;
  mPB : TProgressBar;
  mRollShare :Boolean;
  mPromo : integer;
  mTestInt: Boolean;

  
begin
  mTypImportu := (ASite = nil);
//  Nahrazeno predavanim ASite, z autoserveru je nil
//  mTypImportu := mLogInfoStr = 'AUTO';
  mLogInfoStr := '';
  if not mTypImportu then begin
    mF := TForm.createnew(ASite);
    mPB := TProgressBar.CreateParented(mF.ClientHandle);
    mF.BorderStyle := bsSingle;
    mF.Caption := 'Import predikce prodeje k dílčím skl. kartám.';
    mf.BorderIcons := 0;
    mF.Height := 70;
    mF.Width := 300;
    mf.Position := poScreenCenter;
    mPB.Parent := mF;
    mPB.Min := 0;
    mPB.Max := mCSVStr.Count - 1;
    mPB.Left := 20;
    mPB.Top := 15;
    mPB.Width := 255;
    mf.Show;
  end;
 // Nejprve shodíme spodní a horní limit pro všechny dílčí karty, aby se nenabízeli k objednání, když již se neanalizují
  CreateTebleForecast(OS);
  OS.SQLExecute('Update StoreSubCards set X_Min = 0, X_Max = 0, X_Inventoro_product_id = 0');

  N := 1; //první řádek s indexem 0 obsahuje jména sloupců
  mOldStoreSubCard_ID := '';
  iStoreCard_ID := GetColumIndex(cProduct_id,mCSVStr.Strings(0),cEvaluator,mUvoz);
  iStore_id:= GetColumIndex(cStore_id,mCSVStr.Strings(0),cEvaluator,mUvoz);
  iForecast:= GetColumIndex(cforecast_quantity,mCSVStr.Strings(0),cEvaluator,mUvoz);
  iDateFrom:= GetColumIndex(cDateFrom,mCSVStr.Strings(0),cEvaluator,mUvoz);
  iDateTo:= GetColumIndex(cDateTo,mCSVStr.Strings(0),cEvaluator,mUvoz);
  imin_inventory_quantity:= GetColumIndex(cmin_inventory_quantity,mCSVStr.Strings(0),cEvaluator,mUvoz);
  imax_inventory_quantity:= GetColumIndex(cmax_inventory_quantity,mCSVStr.Strings(0),cEvaluator,mUvoz);
  iinventoro_store_id:= GetColumIndex(cinventoro_store_id,mCSVStr.Strings(0),cEvaluator,mUvoz);
  iInventoro_product_id:= GetColumIndex(cInventoro_product_id,mCSVStr.Strings(0),cEvaluator,mUvoz);
  iinventoro_category_id:= GetColumIndex(cinventoro_category_id,mCSVStr.Strings(0),cEvaluator,mUvoz);
  iabc_margin:= GetColumIndex(cabc_margin,mCSVStr.Strings(0),cEvaluator,mUvoz);
  iabc_margin_revenue_sales := GetColumIndex(cabc_margin_revenue_sales,mCSVStr.Strings(0),cEvaluator,mUvoz);
  iabc_margin_sales_frequency := GetColumIndex(cabc_margin_sales_frequency,mCSVStr.Strings(0),cEvaluator,mUvoz);
  iabc_revenue:= GetColumIndex(cabc_revenue,mCSVStr.Strings(0),cEvaluator,mUvoz);
  iabc_sales_frequency:= GetColumIndex(cabc_sales_frequency,mCSVStr.Strings(0),cEvaluator,mUvoz);
  iabc_sales_quantity:= GetColumIndex(cabc_sales_quantity,mCSVStr.Strings(0),cEvaluator,mUvoz);
  isafetystock_quantity:= GetColumIndex(csafetystock_quantity,mCSVStr.Strings(0),cEvaluator,mUvoz);
  isafetystock_value:= GetColumIndex(csafetystock_value,mCSVStr.Strings(0),cEvaluator,mUvoz);
  iForecastValue:= GetColumIndex(cforecast_value,mCSVStr.Strings(0),cEvaluator,mUvoz);
  
  if not TryStrToInt(Trim(GetParamValue(OS,'PROMOTEST')),mPromo) then mPromo := 0;
  if mPromo <> 0 then  mLogInfoStr := mLogInfoStr + 'Promo přepočet akce ' + IntToStr(mPromo)+ ' nejsou aktualizovány limity karet!  - nastavení v čís. Objednávání skladu';
 // ověříme, že pracujeme se sdílenými číselníky - jinak přistupovat k hl. dodavateli
  mRollShare := UpperCase(GetParamValue(OS,'ROLLSHARE')) = 'ANO';
  
  While  N<= mCSVStr.Count - 1 do begin  // cyklus na hlavičky
    if not mTypImportu then
      if (n mod 1000) = 0 then begin
        mPB.Position := N;
        Application.ProcessMessages;
      end;
    mStoreCard_ID := GetColum(iStoreCard_ID,mCSVStr.Strings(N),cEvaluator);
    mStore_id := GetColum(iStore_id,mCSVStr.Strings(N),cEvaluator);
    mStoreSubCard_ID := GetIdSubStoreCards(OS,mStoreCard_ID,mStore_id);
    mValue := GetColum(iForecast,mCSVStr.Strings(N),cEvaluator);
    mForecast := NxStrToFloat(mValue,cSeparatorFloat);
    mValue := GetColum(iDateFrom,mCSVStr.Strings(N),cEvaluator);
    mDateFrom := EncodeDate(StrToInt(Copy(mValue,1,4)),StrToInt(Copy(mValue,6,2)),StrToInt(Copy(mValue,9,2)));
    mValue := GetColum(iDateTo,mCSVStr.Strings(N),cEvaluator);
    mDateTo := EncodeDate(StrToInt(Copy(mValue,1,4)),StrToInt(Copy(mValue,6,2)),StrToInt(Copy(mValue,9,2)));
    mValue := GetColum(iForecastValue,mCSVStr.Strings(N),cEvaluator);
    mForecastValue := NxStrToFloat(mValue,cSeparatorFloat);
    if Length(mStoreSubCard_ID)= 10 then InsertForecast(OS,mStoreSubCard_ID,mForecast,mDateFrom,mDateTo,mForecastValue,mPromo)
    else begin mLogInfoStr := mLogInfoStr + 'Není ID skl. karty: ' + inttoStr(N)+ '  ID Karty:' + mStoreCard_ID + '  Id Skladu:' +  mStore_id + #13#10;
       Inc(N);
       Continue;
    end;
    if mStoreSubCard_ID = '' then mStoreSubCard_ID := CreateSubStoreCards(OS,mStoreCard_ID,mStore_id);
    if mOldStoreSubCard_ID <> mStoreSubCard_ID then begin
      mOldStoreSubCard_ID := mStoreSubCard_ID;
      if mPromo = 0 then begin // u promo akce neaktualizujeme dílčí karty a jen plním tebulka Forecast_INV
          mBoDoc := OS.CreateObject(Class_StoreSubCard);
          try
            mBoDoc.Load(mStoreSubCard_ID,nil);
            try
              if mRollShare then
                mBoDoc.SetFieldValueAsString('X_MainSupplier_ID',GetSahareDod(OS,mStoreCard_ID))
              else mBoDoc.SetFieldValueAsString('X_MainSupplier_ID',mBoDoc.GetFieldValueAsString('StoreCard_ID.MainSupplier_ID.Firm_ID'));
            Except
             mLogInfoStr := mLogInfoStr + 'Pro hl. kartu ' + mStoreSubCard_ID + ' nebyl dohledán hlavní dodavatel ' + mBoDoc.GetFieldValueAsString('StoreCard_ID.MainSupplier_ID');
             mBoDoc.SetFieldValueAsString('X_MainSupplier_ID','0000000000');
            end;
            mValue := GetColum(imin_inventory_quantity,mCSVStr.Strings(N),cEvaluator);
            mBoDoc.SetFieldValueAsFloat('X_Min',NxStrToFloat(mValue,SeparatorFloat));
            mLogInfoStr := mLogInfoStr + 'ID=' + mBoDoc.OID + ';Min=' + mValue;

            mValue := GetColum(imax_inventory_quantity,mCSVStr.Strings(N),cEvaluator);
            mBoDoc.SetFieldValueAsFloat('X_Max',NxStrToFloat(mValue,SeparatorFloat));
            mLogInfoStr := mLogInfoStr + ';Max=' + mValue + #13#10;

            mValue := GetColum(iinventoro_store_id,mCSVStr.Strings(N),cEvaluator);
            mBoDoc.SetFieldValueAsInteger('X_inventoro_store_id',StrToInt(mValue));

            mValue := GetColum(iInventoro_product_id,mCSVStr.Strings(N),cEvaluator);
            mBoDoc.SetFieldValueAsInteger('X_Inventoro_product_id',StrToInt(mValue));

            mValue := GetColum(iinventoro_category_id,mCSVStr.Strings(N),cEvaluator);
            mBoDoc.SetFieldValueAsInteger('X_inventoro_category_id',StrToInt(mValue));

            mValue := GetColum(iabc_margin,mCSVStr.Strings(N),cEvaluator);
            mBoDoc.SetFieldValueAsString('X_abc_margin',mValue);

            mValue := GetColum(iabc_margin_revenue_sales,mCSVStr.Strings(N),cEvaluator);
            mBoDoc.SetFieldValueAsString('X_abc_margin_revenue_sales',mValue);

            mValue := GetColum(iabc_margin_sales_frequency,mCSVStr.Strings(N),cEvaluator);
            mBoDoc.SetFieldValueAsString('X_abc_margin_sales_frequency',mValue);

            mValue := GetColum(iabc_revenue,mCSVStr.Strings(N),cEvaluator);
            mBoDoc.SetFieldValueAsString('X_abc_revenue',mValue);

            mValue := GetColum(iabc_sales_frequency,mCSVStr.Strings(N),cEvaluator);
            mBoDoc.SetFieldValueAsString('X_abc_sales_frequency',mValue);

            mValue := GetColum(iabc_sales_quantity,mCSVStr.Strings(N),cEvaluator);
            mBoDoc.SetFieldValueAsString('X_abc_sales_quantit',mValue);

            mValue := GetColum(isafetystock_quantity,mCSVStr.Strings(N),cEvaluator);
            mBoDoc.SetFieldValueAsFloat('X_safetystock_quantity',NxStrToFloat(mValue,cSeparatorFloat));

            mValue := GetColum(isafetystock_value,mCSVStr.Strings(N),cEvaluator);
            mBoDoc.SetFieldValueAsFloat('X_safetystock_value',NxStrToFloat(mValue,cSeparatorFloat));
            mBoDoc.Save;
          finally
           mBoDoc.Free;
         end;
       end;
    end; // if  mOldStoreSubCard_ID <> mStoreSubCard_ID
    Inc(N);
  end; // while
  if not mTypImportu then begin
     mPB.Free;
     mF.Free;
  end;
  //Ještě nastavíme do kategorie D karty bez jediného DL, které se ani neexportovali
  if CFxNxRuntime.NxGetDatabaseCode = 'MSSQL' then begin
    mS := 'update storesubcards Set x_abc_margin_sales_frequency =''D''';
    mS := mS +' where LTrim(x_abc_margin_sales_frequency) ='''' and x_analyzedcard = ''A'' and';
    mS := mS +' exists (select 1 from storecards sc,Stores s where sc.id = StoreCard_id and s.id = store_id ';
    mS := mS +' and SC.x_analyzedcard = ''A'' and S.x_analysestore =''A'' and S.x_notcalculate = ''N'')';
  end else begin
    mS := 'update storesubcards ssc Set ssc.x_abc_margin_sales_frequency =''D''';
    mS := mS +' where Trim(ssc.x_abc_margin_sales_frequency) ='''' and ssc.x_analyzedcard = ''A'' and';
    mS := mS +' exists (select 1 from storecards sc,Stores s where sc.id = Ssc.StoreCard_id and s.id = ssc.store_id ';
    mS := mS +' and SC.x_analyzedcard = ''A'' and S.x_analysestore =''A'' and S.x_notcalculate = ''N'')';
  end;
  OS.SQLExecute(mS);

    // Ještě nastavíme do Kategirie N - nové produkty produkty (Novinky)
   mTestInt :=  TryStrToInt(Trim(GetParamValue(OS,'NEWPRODUCT')),N);
  if mTestInt and (N > 0) then begin // jen chci-li nsatavovat
    if CFxNxRuntime.NxGetDatabaseCode = 'MSSQL' then begin
      mS := 'update storesubcards  set X_abc_margin_sales_frequency = ''N''';
      mS := mS + ' where quantity>0 and (X_abc_margin_sales_frequency in (''A'',''B'',''C'',''D'')) and (not Exists (select 1 from storedocuments sd ';
      mS := mS + ' inner join storedocuments2 sd2 on SD2.parent_id = SD.id where Sd.DocumentType = ''20'' and sd.docdate$date < ';
      mS := mS + IntToStr(Round(Date)-N);
      mS := mS + ' and sd2.storecard_id = storecard_id ))';
    end else begin
      mS := 'update storesubcards sbc set sbc.X_abc_margin_sales_frequency = ''N''';
      mS := mS + ' where sbc.quantity>0 and (sbc.X_abc_margin_sales_frequency in (''A'',''B'',''C'',''D'')) and (not Exists (select 1 from storedocuments sd ';
      mS := mS + ' inner join storedocuments2 sd2 on SD2.parent_id = SD.id where Sd.DocumentType = ''20'' and sd.docdate$date < ';
      mS := mS + IntToStr(Round(Date)-N);
      mS := mS + ' and sd2.storecard_id = SBC.storecard_id ))';
    end;
    OS.SQLExecute(mS);
  end;
  if not mTypImportu then ShowMessage('Hotovo', ASite);

end;

procedure ImportLogio(Self: TSiteForm);
var
  mFile: string;
  mSite: TSiteForm;
  mCSVStr : TStringList;
  P: TNxParameters;
  mPar: TNxParameter;
  mS : string;
  mPromo : Integer;

begin
//  mSite :=NxFindSiteForm(Self);
  mFile:= '';
  mS := '';
  if not TryStrToInt(Trim(GetParamValue(TSiteForm(Self).BaseObjectSpace,'PROMOTEST')),mPromo) then mPromo := 0;
  if mPromo <> 0 then  ShowMessage('Promo přepočet akce ' + IntToStr(mPromo) + ' nejsou aktualizovány limity karet! - nastavení v čís. Objednávání skladu', Self);

  with {TOpenDialog}TOpenDialog.Create(Self) do   {mSite.GetSiteAppForm}
  begin
    if Execute then
      mFile:= FileName;
    Free;
  end;
  if FileExists(mFile) then begin
    mCSVStr:= TStringList.Create;
    try
      mCSVStr.LoadFromFile(mFile);
      if mCSVStr.Count > 0 then begin
        mImportLogio(TSiteForm(Self).BaseObjectSpace,mCSVStr,mS, Self);
      end;
     if mS <> '' then begin
       ShowMessage(mS, Self);
       mCSVStr.Text := mS;
       mCSVStr.SaveToFile(GetParamValue(TSiteForm(Self).BaseObjectSpace,'PATH') + 'ErrResult.csv');
     end;
    finally
    
      mCSVStr.Free;
    end;
  end;
end;

procedure mImportLogioDodav(mSite: TSiteForm;mCSVStr:TStringList; var mLogInfoStr:string);
var
  OS: TNxCustomObjectSpace;
  mList : TStringList;
  mListErr : TStringList;
  N,mColum : Integer;
  mField: string;
  mUvoz: Boolean; //určuje zda daná položka je typu string
  mBoStoreCard,mBoDod : TNxCustomBusinessObject;
  mRow:TNxCustomBusinessMonikerCollection;
  mValue,mS:string;
  mIdOrgFak:String;
  mStoreCard_ID,mFirm_ID,mDodav_ID: string;
    mF : TForm;
  mPB : TProgressBar;
  mRollShare : Boolean;
begin
  OS := TSiteForm(mSite).BaseObjectSpace;
  mRollShare := UpperCase(GetParamValue(OS,'ROLLSHARE')) = 'ANO';
  mListErr := TStringList.Create;
  mListErr.Clear;
  try
  N := 1; //první řádek s indexem 0 obsahuje jména sloupců
  mListErr.Add(mCSVStr.Strings(0));

    mF := TForm.createnew(nil);
    mPB := TProgressBar.CreateParented(mF.ClientHandle);
    mF.BorderStyle := bsSingle;
    mF.Caption := 'Import dodavatelům ke skl. kartám.';
    mf.BorderIcons := 0;
    mF.Height := 70;
    mF.Width := 300;
    mf.Position := poScreenCenter;
    mPB.Parent := mF;
    mPB.Min := 0;
    mPB.Max := mCSVStr.Count - 1;
    mPB.Left := 20;
    mPB.Top := 15;
    mPB.Width := 255;
    mf.Show;

  While  N<= mCSVStr.Count - 1 do begin  // cyklus na hlavičky
    try
    // Najdeme ID sklaové karty
    if (n mod 1000) = 0 then begin
        mPB.Position := N;
        Application.ProcessMessages;
    end;
    mColum:= GetColumIndex(cStoreCard_Id,mCSVStr.Strings(0),cEvaluator,mUvoz);
    if mColum =0 then begin // hledáme podle Code
      mColum:= GetColumIndex(cStoreCard_Code,mCSVStr.Strings(0),cEvaluator,mUvoz);
      mStoreCard_ID := GetId(OS,'StoreCards','Code',GetColum(mColum,mCSVStr.Strings(N),cEvaluator));
    end else mStoreCard_ID := GetColum(mColum,mCSVStr.Strings(N),cEvaluator);

    // Najdeme ID dodavatele (nejprve z CSV)
    mColum:= GetColumIndex(cFirm_ID,mCSVStr.Strings(0),cEvaluator,mUvoz);
    if mColum = 0 then begin
      mColum:= GetColumIndex(cFirm_Code,mCSVStr.Strings(0),cEvaluator,mUvoz);
      if mColum <> 0 then
        mFirm_ID := GetFirmId(OS,'Code',GetColum(mColum,mCSVStr.Strings(N),cEvaluator),true);
      if (mColum = 0) or (mFirm_ID = '') then begin
        mColum:= GetColumIndex(cFirm_IC,mCSVStr.Strings(0),cEvaluator,mUvoz);
        if mColum<>0 then mFirm_ID := GetFirmId(OS,'OrgIdentNumber',GetColum(mColum,mCSVStr.Strings(N),cEvaluator),true)
                     else begin
                       mColum:= GetColumIndex(cFirm_Name,mCSVStr.Strings(0),cEvaluator,mUvoz);
                       mFirm_ID := GetFirmId(OS,'Name',GetColum(mColum,mCSVStr.Strings(N),cEvaluator),true)
                     end;
      end;
    end else  mFirm_ID := GetColum(mColum,mCSVStr.Strings(N),cEvaluator);

    if (mFirm_ID = '') or (mStoreCard_ID ='') then begin
       mListErr.Add(mCSVStr.Strings(N)+';'+ ' nebyla dohledána firma nebo skladová karta' + IntToStr(N));
       Inc(N);
       continue;
      //RaiseException('V řádku ' + IntToStr(N) + ' nebyla dohledána firma nebo skladová karta');
    end;

    mBoStoreCard := OS.CreateObject(Class_StoreCard);
    Try

      mDodav_ID := GetDod(OS,mStoreCard_ID,mFirm_ID);
      mBoDod := OS.CreateObject(Class_Supplier);
      try
        if mDodav_ID = '' then begin // založíme dodavatele
          mBoDod.New;
          mBoDod.Prefill;
          mBoDod.SetFieldValueAsString('Firm_ID',mFirm_ID);
          mBoDod.SetFieldValueAsString('StoreCard_ID',mStoreCard_ID);
          mBoStoreCard.Load(mStoreCard_ID,nil); // musí se naníst 2x jinak řve na obj version
          mBoDod.SetFieldValueAsString('QUnit',mBoStoreCard.GetFieldValueAsString('MainUnitCode'));
        end else begin
           mBoDod.Load(mDodav_ID,nil);
           if mBoDod.GetFieldValueAsString('Firm_ID') <> mFirm_ID then // ošetření zásadní opravy nad firmou - vymění se platný dodavatel
              mBoDod.SetFieldValueAsString('Firm_ID',mFirm_ID);
        end;
        mColum:= GetColumIndex(cLeadTime,mCSVStr.Strings(0),cEvaluator,mUvoz);
        mValue := GetColum(mColum,mCSVStr.Strings(N),cEvaluator);
        if mValue = '' then mValue := '0';
        mBoDod.SetFieldValueAsInteger('DeliveryTime',StrToInt(mValue));
        mBoDod.SetFieldValueAsBoolean('DoDemand',true);

        mColum:= GetColumIndex(cstd_provider,mCSVStr.Strings(0),cEvaluator,mUvoz);
        if  mColum <> 0  then begin
          mValue := GetColum(mColum,mCSVStr.Strings(N),cEvaluator);
          if mValue = '' then mValue := '0';
          mBoDod.SetFieldValueAsInteger('X_lt_std_provider',StrToInt(mValue));
        end;

        mColum:= GetColumIndex(cLeadPeriod,mCSVStr.Strings(0),cEvaluator,mUvoz);
        if  mColum <> 0  then begin
          mValue := GetColum(mColum,mCSVStr.Strings(N),cEvaluator);
          if mValue = '' then mValue := '0';
          mBoDod.SetFieldValueAsInteger('X_max_lt_provider',StrToInt(mValue));
        end;

        mColum:= GetColumIndex(cPacking,mCSVStr.Strings(0),cEvaluator,mUvoz);
        if  mColum <> 0  then begin
          mValue := GetColum(mColum,mCSVStr.Strings(N),cEvaluator);
          if mValue = '' then mValue := '0';
          mBoDod.SetFieldValueAsFloat('Packing',StrToFloat(mValue));
        end;
        mColum:= GetColumIndex(cMinimalQuantity,mCSVStr.Strings(0),cEvaluator,mUvoz);
        if  mColum <> 0  then begin
          mValue := GetColum(mColum,mCSVStr.Strings(N),cEvaluator);
          if mValue = '' then mValue := '0';
          mBoDod.SetFieldValueAsFloat('MinimalQuantity',StrToFloat(mValue));
        end;
        mBoDod.Save;
        mDodav_ID := mBoDod.OID;
      finally
        mBoDod.Free;
      end;
    // ještě ověříme, že je nastaven jako hlavní dodavatel
     if not mRollShare then begin
       mBoStoreCard.Load(mStoreCard_ID,nil); //
       if mBoStoreCard.GetFieldValueAsString('MainSupplier_ID')<> mDodav_ID then begin
          mBoStoreCard.SetFieldValueAsString('MainSupplier_ID',mDodav_ID);
          mBoStoreCard.Save;
       end;
     end;
    finally
      mBoStoreCard.Free;
    end;
   Inc(N);
   Except
    mListErr.Add(mCSVStr.Strings(N)+';'+ ' Jiná chyba ' + IntToStr(N));
    Inc(N);
   end;
   end; // while
  if mListErr.Count > 1 then begin
   // Uložíme Err
   with {TSaveDialog}TSaveDialog.Create(mSite) do {mSite.GetSiteAppForm}
  begin
    if Execute then
      mListErr.SaveToFile(FileName);
    Free;
  end;
  end;
  finally
    mListErr.Free;
    mPB.Free;
    mF.Free;
  end;
end;

procedure ImportLogioDodav(Self: TSiteForm);
var
  mFile: string;
 // mSite: TSiteForm;
  mCSVStr : TStringList;
  P: TNxParameters;
  mPar: TNxParameter;
  mS : string;
begin
//  mSite:= NxFindSiteForm(Self);
  mFile:= '';
  mS := '';
  with {TOpenDialog}TOpenDialog.Create(Self) do {mSite.GetSiteAppForm}
  begin
    if Execute then
      mFile:= FileName;
    Free;
  end;
  if FileExists(mFile) then begin
    mCSVStr:= TStringList.Create;
    try
      mCSVStr.LoadFromFile(mFile);
      if mCSVStr.Count > 0 then mImportLogioDodav(Self,mCSVStr,mS);
    finally
      mCSVStr.Free;
    end;
  end;
end;


begin
end.