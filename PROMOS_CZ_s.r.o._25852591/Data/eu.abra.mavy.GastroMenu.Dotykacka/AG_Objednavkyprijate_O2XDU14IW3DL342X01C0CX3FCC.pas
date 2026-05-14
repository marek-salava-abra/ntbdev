uses 'eu.abra.mavy.GastroMenu.Dotykacka.fce', 'eu.abra.mavy.GastroMenu.Dotykacka.form';

procedure InitSite_Hook(Self: TSiteForm);
var
  mAction, mAction2: TBasicAction;
begin
  mAction := Self.GetNewAction;
  mAction.ShowControl := True;
  mAction.ShowMenuItem := True;
  mAction.Name := 'actDotykacka';
  mAction.Caption := 'Dotykacka';
  mAction.Hint := 'Import dat z Dotykačky';
  mAction.Category := 'tabList';
  mAction.OnExecute := @ImportMarkeeta;
end;

procedure ImportMarkeeta(Sender: TObject);
var
  mLog, mDocsList: TStrings;
  i,a, mStatusCode: integer;
  mObject, mSourceBO: TNxCustomBusinessObject;
  mCurrencyCode, mPaymentName, mFirmName, mFirmIdentNumber, mDateStr, mStoreCode,mStoreCardCode,mPeriod_ID,mCurrency_ID, mFirmOffice_ID: string;
  mPriceDefinition, mQUnit, mExpr, mProductID, mFirmExternalID, mCustomerID, mFilter, mToken, mVATRate, mVATRate_ID, mStore_ID,mStoreCard_ID,mStatusText, mURL, mFirm_ID,mOrder_ID:string;
  mOS: TNxCustomObjectSpace;
  mSite: TDynSiteForm;
  mJSON,mJSON2,mJSON3: TJSONSuperObject;
  mError,mStorno: Boolean;
  mQuantity, mPrice,mVAT,mAbraPrice: Extended;
  mRows: TNxCustomBusinessMonikerCollection;
  mRow:TNxCustomBusinessObject;
  mDateFrom,mDateTo,mCreated: TDateTime;
begin
  try
    mSite := TComponent(Sender).DynSite;
    mOS := mSite.SiteContext.GetObjectSpace;
    mLog:= TStringList.Create;
    if GetInputForm(mSite,mDateFrom, mDateTo) = 2 then begin
      ShowMessage('Nebyly zadány vstupní parametry, ukončuji import.');
      exit;
    end;

    try
      WaitWin.Start(Application.Title, 'Probíhá komunikace s API Markeeta');
      mURL:= 'https://api.dotykacka.cz/v2/clouds/354810661/orders/?include=orderItems&limit=100&filter=completed|gteq|'+IntToStr(DateTimeToUnix(mDateFrom))+'000'+';completed|lt|'+IntToStr(DateTimeToUnix(mDateTo+1))+'000';
      mURL:= CFxInternet.URLEncode(mURL);
      OutputDebugString('URL: ' + mURL);
      //ShowMessage(mURL);
      mJSON:= API_GET(mURL, mStatusCode, mStatusText);
    except
      ShowMessage('Nastala neočekávaná chyba při získávání dat z Markeety: ' + ExceptionMessage);
    end;
    WaitWin.Stop;
    if mStatusCode = 404 then begin
      ShowMessage('Pro vybrané datum neexistují žádné účtenky.');
      exit;
    end;
    if mStatusCode <> 200 then begin
      ShowMessage('Nastala chyba při načítání dat z API Markeety: '+IntToStr(mStatusCode) +' - '+ mStatusText);
      exit;
    end;
    //ProgressInit(mSite, 'Probíhá import dat z Markeety...', mJSON.A['data'].Length);
    for i:= 0 to mJSON.A['data'].Length -1 do begin
      mFirm_ID:= '';
      mFirmOffice_ID:= '';
      mCustomerID:= '';
      mFirmExternalID:= '';
      mFirmName:= '';
      mFirmIdentNumber:= '';
      mFirmExternalID:= '';
      try
        mCustomerID:=mJSON.A['data'].O[i].S['_customerId'];
        OutputDebugString('mCustomerID: '+mCustomerID);
        if not NxIsBlank(mCustomerID) then begin
          mURL:= 'https://api.dotykacka.cz/v2/clouds/354810661/customers/'+mCustomerID;
          OutputDebugString('mURL: '+mURL);
          mJSON2:= API_GET(mURL, mStatusCode, mStatusText);
          mFirmName:= mJSON2.S['companyName'];
          mFirmIdentNumber:= mJSON2.S['companyId'];
          mFirmExternalID:= mJSON2.S['externalId'];
        end;
      except
        mFirmName:= '';
        mFirmIdentNumber:= '';
        mFirmExternalID:= '';
      end;
      OutputDebugString('Firma: '+mFirmName+'/'+mFirmIdentNumber+'/'+mFirmExternalID);
      if not NxIsBlank(mFirmName) then begin
        //mFirm_ID:= GetFirmByFirmOffice(mOS, NxLeft(mFirmName,6));
        if not NxIsBlank(mFirmExternalID) then begin
          mFirm_ID:= GetFirmByFirmOffice(mOS, mFirmExternalID);
          mFirmOffice_ID:= GetFirmOfficeByFirmName(mOS, mFirmExternalID);
        end;
        if not NxIsBlank(mFirmIdentNumber) and  NxIsEmptyOID(mFirm_ID) then mFirm_ID:= GetFirmByIdentNumber(mOS, mFirmIdentNumber);
      end;
      if NxIsEmptyOID(mFirm_ID) then mFirm_ID:= cDefaultFirm_ID;
      OutputDebugString('Firma_ID: '+mFirm_ID+'/'+mFirmOffice_ID);

      //mPaymentName:= mJSON.A['data'].O[i].A['paymentdata'].O[0].O['paymentMethod'].S['name'];
      mCurrencyCode:= mJSON.A['data'].O[i].S['currency'];
      mCurrency_ID:= GetCurrencyID(mOS,mCurrencyCode);
      mOrder_ID:= GetOrder_ID(mOS,'Description',mJSON.A['data'].O[i].S['documentNumber']);
      OutputDebugString('Order_ID: ' + mOrder_ID);
      mCreated:= mJSON.A['data'].O[i].DT8601['completed'];
      OutputDebugString('Datum vytvoření: ' + DateTimeToStr(mCreated));
      //mPeriod_ID:= GetPeriodID(mOS,CFxDate.StrToDateEx(mDateStr,'YYYY-MM-YY','-'));
      mPeriod_ID:= GetPeriodID(mOS,mCreated);
      OutputDebugString('Period_ID: ' + mPeriod_ID);

      mStorno:= NxCheckBit(mJSON.A['data'].O[i].I['flags'],2);

      if not mStorno and NxIsEmptyOID(mOrder_ID) then begin
        try
          mObject := mOS.CreateObject(Class_ReceivedOrder);
          mObject.New;
          mObject.Prefill;
          OutputDebugString('******* Zakládám novou OP ******** '+mJSON.A['data'].O[i].S['documentNumber']);
          mObject.SetFieldValueAsString('DocQueue_ID', cDocQueue_ID);
          mObject.SetFieldValueAsString('Period_ID',mPeriod_ID);
          mObject.SetFieldValueAsDateTime('DocDate$DATE', Trunc(mCreated));
          mObject.SetFieldValueAsString('Description', mJSON.A['data'].O[i].S['documentNumber']);
          mObject.SetFieldValueAsString('Firm_ID', mFirm_ID);
          if not (mFirm_ID = cDefaultFirm_ID) then begin
            mObject.SetFieldValueAsInteger('TradeType', 2);
            mObject.SetFieldValueAsString('Country_ID', '00000SK000');
          end;
          mObject.SetFieldValueAsBoolean('PricesWithVAT',false);

          if not NxIsEmptyOID(mFirmOffice_ID) then mObject.SetFieldValueAsString('FirmOffice_ID', mFirmOffice_ID);
          mObject.SetFieldValueAsString('Currency_ID', mCurrency_ID);


          ///////////////////////////////////////////////
          mRows:= mObject.GetCollectionMonikerForFieldCode(mObject.GetFieldCode('Rows'));

          for a:= 0 to mJSON.A['data'].O[i].A['orderItems'].Length -1 do begin
            mProductID:= mJSON.A['data'].O[i].A['orderItems'].O[a].S['_productId'];
            if (mProductID <> '0')  then begin
              mURL:= 'https://api.dotykacka.cz/v2/clouds/354810661/products/'+mProductID;
              //OutputDebugString('mURL_product: '+mURL);
              mJSON3:= API_GET(mURL, mStatusCode, mStatusText);
              mStoreCardCode:= mJSON3.A['plu'].S[0];
              mStoreCard_ID:= SQLSingleSelect(mOS,'SELECT ID FROM StoreCards WHERE Code = '+QuotedStr(mStoreCardCode)+' and Hidden = ''N''');
              if NxIsEmptyOID(mStoreCard_ID) then begin
                ShowMessage('Skladová karta s kódem '+mStoreCardCode+' nebyla nalezena! Objednávku '+mJSON.A['data'].O[i].S['documentNumber']+' není možné naimportovat');
                //ProgressDispose();
                exit;
              end
              else begin
                OutputDebugString('Product_PLU: ' + mStoreCardCode);
                //mStoreCode:= 'A1';     //prozatím natvrdo konstanta, později bude rozděleno podle skladů jednotlivých řidičů
                //mStore_ID:= SQLSingleSelect(mOS,'SELECT ID FROM Stores WHERE Code = '+QuotedStr(mStoreCode)+' and Hidden = ''N''');
                mStore_ID:= '2900000101';
                mQuantity:= mJSON.A['data'].O[i].A['orderItems'].O[a].D['quantity'];
                if mQuantity > 0 then begin
                  //mPrice:= mJSON.A['data'].O[i].A['receiptdata'].O[a].O['unitSalePrice'].D['foreignValue'];
                  // pokud se jedná o defaultní firmu, tak se bere částka bez DPHJ
                  if not (mFirm_ID = cDefaultFirm_ID) then
                    mPrice:= mJSON.A['data'].O[i].A['orderItems'].O[a].D['totalPriceWithVat']
                  else
                    mPrice:= mJSON.A['data'].O[i].A['orderItems'].O[a].D['totalPriceWithoutVat'];
                  OutputDebugString(FloatToStr(mPrice));
                  mVAT:= mJSON.A['data'].O[i].A['orderItems'].O[a].D['vat'];
                  OutputDebugString('VAT: '+FloatToStr(mVAT));
                  if mVAT > 1 then
                    mVATRate:=  NxRight(FloatToStr(mVAT),2)
                  else
                    mVATRate:= '0';
                  OutputDebugString('VAT_Rate: '+(mVATRate));
                  mVATRate_ID:=  SQLSingleSelect(mOS,'SELECT ID FROM VATRates WHERE Tariff = '+mVATRate+' and Hidden = ''N''');
                  if not (mFirm_ID = cDefaultFirm_ID) then mVATRate_ID:= '00000X0000';

                  mRow:= mRows.AddNewObject;
                  mRow.Prefill;
                  mRow.SetFieldValueAsInteger('RowType', 3);
                  mRow.SetFieldValueAsString('Store_ID', mStore_ID);
                  mRow.SetFieldValueAsString('StoreCard_ID', mStoreCard_ID);
                  mRow.SetFieldValueAsString('VATRate_ID', mVATRate_ID);
                  mRow.SetFieldValueAsFloat('Quantity', mQuantity);
                  mRow.SetFieldValueAsFloat('UnitPrice', 0);
                  mRow.SetFieldValueAsFloat('TotalPrice', mPrice);
                  mRow.SetFieldValueAsString('Division_ID', cDivision_ID);
                  mRow.SetFieldValueAsDateTime('DeliveryDate$DATE', Trunc(mCreated));


                  mPriceDefinition:= '3300000101';
                  mQUnit:= mRow.GetFieldValueAsString('QUnit');
                  mExpr := 'NxGetStoreCardUnitPriceDef('''+mFirm_ID+''', ''' + mStore_ID + ''', ''' + mStoreCard_ID + ''', ''' + mPriceDefinition + ''' , ''' + mQUnit + ''' , False, ''' + mCurrency_ID + ''' , '''+DateToStr(Trunc(mCreated))+  ''')';
                  mAbraPrice:= NxRoundByValue(NxEvalObjectExprAsFloat{Def}(mObject, mExpr{, 0}),ctArithmetic,0.01); // bez def v pripade chyby vyskoci vyjimka
                  mPrice:= NxRoundByValue(mJSON.A['data'].O[i].A['orderItems'].O[a].D['totalPriceWithVat'],ctArithmetic,0.01);
                  if mAbraPrice <> NxRoundByValue(mPrice / mQuantity,ctArithmetic,0.01) then mLog.Add('V účtence '+mObject.GetFieldValueAsString('Description')+' u skladové karty '+mRow.GetFieldValueAsString('StoreCard_ID.DisplayName')+' nesouhlasí cena z ceníku ('+FloatToStr(mAbraPrice)+') s cenou z Dotykačky ('+FloatToStr(mPrice / mQuantity)+')!');
                end;
              end;
            end;
          end;

        mObject.Save;
        if mLog.Count > 0 then NxShowEditorSite(NxCreateContext(msite.BaseObjectSpace),mLog.Text,True);
        except
          ShowMessage('Nastala chyba při ukládání OP: ' + ExceptionMessage);
          if NxMessageBox('Chyba', 'Přejete si zobrazit zdrojová data z Dotykačky?', mdConfirm, mdbYesNo, 0, 0, False, Nil)=mrYes then begin
            NxShowEditorSite(NxCreateContext(msite.BaseObjectSpace),mJSON.AsString,True);
          end;
        end;
      end;
      //ProgressSetPos(i+1);
    end;
    //ProgressDispose();
  finally
    mOS.Free;
    if Assigned(mObject) then mObject.Free;
    mJSON.Free;
    mJSON2.Free;
    mJSON3.Free;
    mLog.Free;
    TDynSiteForm(mSite).RefreshData;
  end;
end;

function SQLSingleSelect(AOS: TNxCustomObjectSpace; ASQL: string): string;
var
  mIDs: TStringList;
begin
  Result := '';

  if Assigned(AOS) and (ASQL <> '') then
  begin
    mIDs := TStringList.Create;
    try
      SQLMultiSelect(AOS, ASQL, mIDs);
      if mIDs.Count > 0 then
        Result := NxSearchReplace(mIDs.Strings[0], '"', '', [srAll]);
    finally
      mIDs.Free;
    end;
  end;
end;

procedure SQLMultiSelect(AOS: TNxCustomObjectSpace; ASQL: string; AIDs: TStringList);
begin
  try
    if Assigned(AIDs) and Assigned(AOS) and (ASQL <> '') then
      AOS.SQLSelect(ASQL, AIDs);
  except
    //WriteErrorLog(ALog, ALogPrefix, 'DB', 'Nepodarilo se nacíst data z databáze.' + #13#10 + ExceptionMessage);
    //ALog.Add(ExceptionMessage);
  end;
end;

begin
end.