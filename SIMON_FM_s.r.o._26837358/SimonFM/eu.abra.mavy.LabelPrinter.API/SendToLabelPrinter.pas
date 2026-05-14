uses 'eu.abra.mavy.libs.common', 'eu.abra.mavy.LabelPrinter.API.fce', 'eu.abra.mavy.LabelPrinter.API.consts.consts';
procedure SendPackage(AOS: TNxCustomObjectSpace; ABO, ASourceBO: TNxCustomBusinessObject;var AJSON: TJSONSuperObject;var AError: boolean; var mStateCode,mMessage,mBarcode,mLabelPrinter_ID:string);
var
  mSite: TSiteForm;
  mBO, mRow, mContentType, mStoreCardBO, mStoreCardRowBO,mStoreCardEansBO : TNxCustomBusinessObject;
  mRows : TNxCustomBusinessMonikerCollection;
  i,a,x : integer;
  mPhoneNumber, mState_ID, mIssuedContentType_ID, mPostProvider_ID : string;
  mOS: TNxCustomObjectSpace;
  mWinHTTP: Variant;
  mJSON, mJSON2, mJSON3: TJSONSuperObject;
  mShippersArray,mShipperRowsArray : TJSONSuperObjectArray;
  mEmail, mEAN, mProcessUser, mInvoiceContent, mToken,mRequest: string;
  mErrors: TStringList;
  mContext: TNxContext;
  mBytes : TBytes;
begin
  try
    try
      mToken:= GetToken;
      if NxIsBlank(mToken) then begin
        AError:= true;
        exit;
      end;

      mWinHTTP:= CreateOleObject('WinHttp.WinHttpRequest.5.1');
      mWinHTTP.Open('POST', cURL + '/shipments');
      mWinHTTP.SetRequestHeader('Content-Type', 'application/json');
      mWinHTTP.SetRequestHeader('Authorization', 'Bearer '+mToken);
      if cLoaderMode then
        mWinHTTP.SetRequestHeader('LoaderMode', 1);
      mProcessUser:= GetDataFromUser(AOS, NxGetActualUserID(AOS),'X_LP_User');
      if NxIsBlank(mProcessUser) then mProcessUser:= cDefaultUser;
      mJSON:= TJSONSuperObject.CreateNew;
      mJSON.S['id'] := '';                                                                               // Jedinečný identifikátor v systému Label Printer (při vytváření se ignoruje!)
      mJSON.S['processUser'] := NxLeft(mProcessUser,200);                                                // Specifikace uživatele (jeho login), kterému je zásilka určena
      mJSON.S['shipperCode'] := NxLeft(ABO.GetFieldValueAsString('PostProvider_ID.X_LP_Code'),20);       // Kód přepravce (CP, PPL, DPD, ...). Viz metoda pro zisk přepravců
      mJSON.S['serviceCode'] := NxLeft(ABO.GetFieldValueAsString('IssuedContent_ID.Code'),10);           // Kód přepravní služby (DR, NP, ...). Metoda pro zisk přepravců vrací i seznam služeb
      mJSON.S['variableSymbol'] := ABO.GetFieldValueAsString('VarSymbol');                               //	Variabilní symbol
      mJSON.S['orderNumber'] := NxLeft(ABO.GetFieldValueAsString('X_LP_OrderNumber'),12);                // Číslo objednávky
      mJSON.B['paymentInAdvance'] := false;                                                              // Platba předem
      mJSON.D['price'] := ABO.GetFieldValueAsFloat('InsuredValue');                                      // Cena zásilky
      mJSON.S['priceCurrency'] := ASourceBO.GetFieldValueAsString('Currency_ID.Code');                   // Měna zásilky v iso4217 formátu (např. CZK, EUR)
      mJSON.D['cod'] := ABO.GetFieldValueAsFloat('CashOnDelivery');                                      //	Cena dobírky
      mJSON.S['codCurrency'] := ASourceBO.GetFieldValueAsString('Currency_ID.Code');                     // Měna dobírky v iso4217 formátu (např. CZK, EUR)
      if (ABO.GetFieldValueAsFloat('CashOnDelivery') > 0 ) and cSendBankAccount then
        mJSON.S['codBankAccount'] := ABO.GetFieldValueAsString('BankAccount_ID.BankAccount');            // Bankovní účet, kam se má posílat vybraná dobírka (tvar 35-123457/0100)
      mJSON.I['codPaymentType'] := 1;                                                                    // Typ platby pro dobírku (0 = hotovost, 1 = kartou / šekem)
      mJSON.S['customExternalId'] := ASourceBO.OID;                                                      // Externí označení zásilky
      mJSON.S['depotAddressCode'] := '';                                                                 // Kód adresy depa (možnost využít toto pole pro změnu označení eshopu pro přepravce Zásilkovna)
      mJSON.S['description'] := '';                                                                      // Popis
      mJSON.B['personalCollection'] := false;                                                            // Osobní odběr
      mJSON.S['deliveryPointId'] := ASourceBO.GetFieldValueAsString(cDeliveryPointFieldName);            // ID Odběrného místa
      mJSON.S['expeditionNote'] := NxLeft(ABO.GetFieldValueAsString('Note'),1000);  // Poznámka expedice
      mJSON.S['paletteManipulationType'] := '';                                                          // Typ manipulace v případě paletové přepravy
      mJSON.S['palettePickupType'] := '';                                                                // Typ svozu v případě paletové přepravy
      //služby jsou jako řádky, musíme je projít a přidat do pole
      mRows:=ABO.GetLoadedCollectionMonikerForFieldCode(ABO.GetFieldCode('Rows'));
      if mRows.count > 0 then begin
        mJSON.O['additionalServices'] := mJSON.CreateJSONArray;                                          // Pole string hodnot, které označují vybrané doplňkové služby dané přepravní služby
        for a:=0 to mRows.count-1 do begin
          mRow:=mRows.BusinessObject[a];
          mJSON.A['additionalServices'].S[a] := mRow.GetFieldValueAsString('ServiceType_ID.Code');
        end;
      end;

      mJSON.O['recipient'] := mJSON.CreateJSON;
      if ABO.GetFieldValueAsString('Firm_ID.OrgIdentNumber') <> '' then
        mJSON.O['recipient'].S['ico'] := ABO.GetFieldValueAsString('Firm_ID.OrgIdentNumber');           // IČO
      mJSON.O['recipient'].S['person'] := ABO.GetFieldValueAsString('TargetAddress_ID.Recipient');      // Osobní kontakt
      mJSON.O['recipient'].S['company'] := NxLeft(ABO.GetFieldValueAsString('Firm_ID.Name'),200);       // *Název firmy nebo osoby
      mJSON.O['recipient'].S['street'] := ABO.GetFieldValueAsString('TargetAddress_ID.Street');         // *Adresa (Ulice, číslo popisné i orientační)
      mJSON.O['recipient'].S['street2'] := '';                                                          // Doplnění adresy
      mJSON.O['recipient'].S['city'] := NxLeft(ABO.GetFieldValueAsString('TargetAddress_ID.City'),50);  // *Město
      mJSON.O['recipient'].S['postalCode'] := ABO.GetFieldValueAsString('TargetAddress_ID.PostCode');   // *PSČ

      if ABO.GetFieldValueAsString('TargetAddress_ID.CountryCode') = '' then                            // *Kód státu v ISO 3166-1 alpha-2 formátu (např. CZ, SK)
        mJSON.O['recipient'].S['countryCode'] := 'CZ'
      else
        mJSON.O['recipient'].S['countryCode'] := ABO.GetFieldValueAsString('TargetAddress_ID.CountryCode');

      mPhoneNumber:= CorrectPhoneNumber(ABO.GetFieldValueAsString('TargetAddress_ID.PhoneNumber1'),ABO.GetFieldValueAsString('TargetAddress_ID.PhoneNumber2'));
      if NxIsBlank(mPhoneNumber) then mPhoneNumber:= CorrectPhoneNumber(ABO.GetFieldValueAsString('Firm_ID.ResidenceAddress_ID.PhoneNumber1'),ABO.GetFieldValueAsString('Firm_ID.ResidenceAddress_ID.PhoneNumber2'));
      mJSON.O['recipient'].S['phone'] := NxLeft(mPhoneNumber,20);                                      // telefon

      mEmail:= ABO.GetFieldValueAsString('TargetAddress_ID.Email');
      if NxIsBlank(mEmail) then mEmail:= ABO.GetFieldValueAsString('Firm_ID.ResidenceAddress_ID.Email');
      mJSON.O['recipient'].S['email'] := mEmail;                                                      // email

      mJSON.O['parcels'] := mJSON.CreateJSONArray;
      mJSON2 := TJSONSuperObject.Create;
      if not (ABO.GetFieldValueAsFloat('Weight') = 0) and cUseWeight then
        mJSON2.D['weight']:= ABO.GetFieldValueAsFloat('Weight');
      mJSON.A['parcels'].Add(mJSON2);
      mJSON2.Free;

      //Sekce odesílání seznamu skladových karet z dokladu
      if cSendStoreCards then begin
        mRows:=ASourceBO.GetLoadedCollectionMonikerForFieldCode(ASourceBO.GetFieldCode('Rows'));
        if mRows.count > 0 then begin
          mJSON.O['goods'] := mJSON.CreateJSONArray;
          for a:=0 to mRows.count-1 do begin
            mRow:=mRows.BusinessObject[a];
            if (mRow.GetFieldValueAsInteger('RowType') = 3) and not mRow.GetFieldValueAsBoolean('StoreCard_ID.X_LP_SendExcluded') then begin
              // EAN musí být vždy vyplněn, jinak nelze uložit kartu ke kontrole, takže pokud není, vyplníme kód karty
              //musím si dohledat EAN k jednotce, protože nemusí být vybrána hlavní jednotka
              mEAN:= SQLSingleSelect(AOS, Format('SELECT EAN FROM StoreUnits WHERE Code = ''%s'' and Parent_ID = ''%s''',[ mRow.GetFieldValueAsString('QUnit'),mRow.GetFieldValueAsString('StoreCard_ID')]));
              if NxIsBlank(mEAN) then mEAN:= mRow.GetFieldValueAsString('StoreCard_ID.Code');

              mJSON2 := TJSONSuperObject.Create;
              mJSON2.S['name']:= NxLeft(mRow.GetFieldValueAsString('StoreCard_ID.Code') + ' ' + mRow.GetFieldValueAsString('StoreCard_ID.Name'),200);
              mJSON2.S['barcode']:= mEAN;
              mJSON2.D['quantity']:= (mRow.GetFieldValueAsFloat('Quantity') / mRow.GetFieldValueAsFloat('UnitRate'));
              mJSON2.D['unitPrice']:= mRow.GetFieldValueAsFloat('UnitPrice');
              mJSON2.S['unitCode']:= mRow.GetFieldValueAsString('QUnit');
              mJSON2.S['currencyCode']:= ASourceBO.GetFieldValueAsString('Currency_ID.Code');

              mStoreCardBO:= AOS.CreateObject(Class_StoreCard);
              mStoreCardBO.Load(mRow.GetFieldValueAsString('StoreCard_ID'), nil);

              // přidání jedné větve alternatives pro kód skladové karty místo EAN
              if cAddStoreCardsCode then begin
                mJSON2.O['alternatives'] := mJSON.CreateJSONArray;
                mJSON3 := TJSONSuperObject.Create;
                mJSON3.S['name']:= 'Kód zboží';
                mJSON3.S['barcode']:= mStoreCardBO.GetFieldValueAsString('Code');
                mJSON3.D['ratio']:= mStoreCardBO.GetFieldValueAsFloat('MainUnitRate')  ;
                mJSON2.A['alternatives'].Add(mJSON3);
                mJSON3.Free;
              end;

              if mStoreCardBO.GetLoadedCollectionMonikerForFieldCode(mStoreCardBO.GetFieldCode('StoreUnits')).Count > 1 then begin
                //pokud nepřidáváme větev pro kód skladové karty výše, tak musíme alternatives přidat zde. Pokud už je založená, neni třeba znovu.
                if not cAddStoreCardsCode then mJSON2.O['alternatives'] := mJSON.CreateJSONArray;
                for i:= 0 to  mStoreCardBO.GetLoadedCollectionMonikerForFieldCode(mStoreCardBO.GetFieldCode('StoreUnits')).Count - 1 do begin
                  mStoreCardRowBO:= mStoreCardBO.GetLoadedCollectionMonikerForFieldCode(mStoreCardBO.GetFieldCode('StoreUnits')).BusinessObject[i];

                  if mStoreCardRowBO.GetFieldValueAsString('Code') <>  mRow.GetFieldValueAsString('QUNit') then begin
                    for x:= 0 to mStoreCardRowBO.GetLoadedCollectionMonikerForFieldCode(mStoreCardRowBO.GetFieldCode('StoreEans')).Count -1 do begin
                      mStoreCardEansBO:= mStoreCardRowBO.GetLoadedCollectionMonikerForFieldCode(mStoreCardRowBO.GetFieldCode('StoreEans')).BusinessObject[x];
                      if not NxIsBlank(mStoreCardRowBO.GetFieldValueAsString('EAN')) then begin
                        mJSON3 := TJSONSuperObject.Create;
                        mJSON3.S['name']:= mStoreCardRowBO.GetFieldValueAsString('Code');
                        mJSON3.S['barcode']:= mStoreCardEansBO.GetFieldValueAsString('EAN');
                        //Zde potřebuji zjistit vztah k jednotce, která je vybraná na dokladu. Počítám s tím, že se zde dostanou jen jednotky různé od té na dokladu.
                        mJSON3.D['ratio']:= mStoreCardRowBO.GetFieldValueAsFloat('UnitRate')/ mRow.GetFieldValueAsFloat('UnitRate')  ;
                        mJSON2.A['alternatives'].Add(mJSON3);
                        mJSON3.Free;
                      end;
                    end;
                  end
                  else begin
                  //pro hlavní skladovou jednotku už máme hlavní EAN vložen, musíme ještě projít další EANy pro jednotku

                    for x:= 0 to mStoreCardRowBO.GetLoadedCollectionMonikerForFieldCode(mStoreCardRowBO.GetFieldCode('StoreEans')).Count -1 do begin
                      mStoreCardEansBO:= mStoreCardRowBO.GetLoadedCollectionMonikerForFieldCode(mStoreCardRowBO.GetFieldCode('StoreEans')).BusinessObject[x];
                      if not NxIsBlank(mStoreCardRowBO.GetFieldValueAsString('EAN')) and not (mStoreCardEansBO.GetFieldValueAsString('EAN') = mEAN) then begin
                        mJSON3 := TJSONSuperObject.Create;
                        mJSON3.S['name']:= mStoreCardRowBO.GetFieldValueAsString('Code');
                        mJSON3.S['barcode']:= mStoreCardEansBO.GetFieldValueAsString('EAN');
                        //Zde potřebuji zjistit vztah k jednotce, která je vybraná na dokladu. Počítám s tím, že se zde dostanou jen jednotky různé od té na dokladu.
                        mJSON3.D['ratio']:= mStoreCardBO.GetFieldValueAsFloat('MainUnitRate')  ;
                        mJSON2.A['alternatives'].Add(mJSON3);
                        mJSON3.Free;
                      end;
                    end;
                  end;
                end;
              end;
              mJSON.A['goods'].Add(mJSON2);
              mStoreCardBO.Free;
            end;
          end;
        end;
        mJSON2.Free;
      end;

      //sekce pro odeslání příloh pro tisk
      if cSendInvoicePDF and (ASourceBO.CLSID = Class_IssuedInvoice) then begin
        try
          mContext:= NxCreateContext(ABO.ObjectSpace);
          mBytes:= PrintIssuedInvoice(mContext, ASourceBO.OID, cInvoiceDynSourceID, cInvoiceReportID);
          mInvoiceContent:= EncodeBase64(mBytes);
          if not NxIsBlank(mInvoiceContent) then begin
            mJSON.O['media'] := mJSON.CreateJSONArray;
            mJSON2 := TJSONSuperObject.Create;
            mJSON2.I['mediaType']:= 1; //1 pro fakturu
            mJSON2.S['fileName']:= {ASourceBO.DisplayName} 'faktura'+'.pdf';
            mJSON2.S['data']:= mInvoiceContent;
            mJSON.A['media'].Add(mJSON2);
            mJSON2.free;
          end;
        finally
        end;
      end;

   //ShowMessage(mJSON.AsString);
   //exit;
      try
        mWinHTTP.Send(mJSON.AsJson(true));
      except
        if CFxNxRuntime.NxGetEnvironmentType = reRuntimeExe then ShowMessage('Komunikace s LP nebyla úspěšná');
        AError:= true;
        exit;
      end;
      mJson.Free;
      mJson := TJSONSuperObject.ParseString(mWinHTTP.ResponseText, True);
      if (mWinHTTP.Status <> 200) and (mWinHTTP.Status <> 201) then begin    //kód <> 200 = dotaz vůbec neprošel
        mErrors:= TstringList.Create;

        for i:= 0 to mJson.A['errors'].Length - 1 do begin
          mErrors.Add(mJson.A['errors'].O[i].S['message']);
        end;
        if CFxNxRuntime.NxGetEnvironmentType = reRuntimeExe then ShowMessage('Chyba při načítání dat z LP: ' + IntToStr(mWinHTTP.Status) +#13#10+ mErrors.Text);
        mErrors.Free;
        AError:= true;
        exit;
      end
      else begin
        //ShowMessage('OK: ' + IntToStr(mWinHTTP.Status) +': '+ mWinHTTP.StatusText);
        AError:= false;
        AJSON:= mJson;
        mStateCode:= mJson.A['data'].O[0].O['state'].S['code'];
        mLabelPrinter_ID:= mJson.A['data'].O[0].S['id'];
        if not (mJson.A['data'].O[0].S['messages'] = '') then
          mMessage:= mJson.A['data'].O[0].A['messages'].O[0].S['message'];
        mBarcode:= mJson.A['data'].O[0].A['parcels'].O[0].S['barcode'];
        //ShowMessage(AJSON.AsString);
        mJSON.Free;
      end;
    except
      AError:= True;
      if CFxNxRuntime.NxGetEnvironmentType = reRuntimeExe then ShowMessage('Při importu dat z LP nastala neočekávaná chyba: '+ExceptionMessage);
    end;
  finally
  end;

end;


begin
end.