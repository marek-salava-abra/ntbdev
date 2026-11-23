uses '.const';


function API_GET(aURL, aLogin, aPass: String): TNxScriptingXMLWrapper;
var
  mWinHTTP: Variant;
  mResponse: TMemoryStream;
begin
  Result := nil;
  try
    mWinHTTP := CreateOleObject('WinHttp.WinHttpRequest.5.1');
    mWinHTTP.Open('GET', aURL, False);
    mWinHTTP.SetRequestHeader('Content-Type', 'application/xml');
    mWinHTTP.SetRequestHeader('Authorization', 'Basic ' + EncodeBase64(TEncoding.UTF8.GetBytes(aLogin + ':' + aPass)));
    mWinHTTP.Send();

    if mWinHTTP.Status = 200 then
    begin
      mResponse := TMemoryStream.Create;
      try
        mResponse.SetBytes(mWinHTTP.ResponseBody);
        mResponse.Position := 0;

        Result := TNxScriptingXMLWrapper.Create;
        Result.LoadFromStream(mResponse);
      finally
        mResponse.Free;
      end;
    end;
  except
    if Assigned(Result) then
    begin
      Result.Free;
      Result := nil;
    end;
    NxShowSimpleMessage(ExceptionMessage, nil);
  end;
end;

procedure GetOrderFromPneuB2B(OS: TNxCustomObjectSpace; var Success: Boolean; var LogInfoStr: String);
var
  mXMLHead, mXMLResponse, mXMLPostResponse: TNxScriptingXMLWrapper;
  mBatchID, mOrderID, mFirm_ID, mStoreCard_ID, mFirmOffice_ID, mLogin: String;
  i, j, mOrderCount, mItemCount, k: Integer;
  mLogs: TStringList;
  mBO, mRowBO, mFirmBO, mFirmOfficeBO:TNxCustomBusinessObject;
  mRows, mFirmOffices:TNxCustomBusinessMonikerCollection;
  mFirmOfficeFound, mNewOrders:Boolean;
begin
  Success := False;
  LogInfoStr := '';
  mLogs := TStringList.Create;
  try
   for k:=8200 to 8203 do begin
    mLogin:=IntToStr(k);
    mXMLHead := API_GET(cURL + 'orders_new',mLogin,'KingTonyDodavatel.');
    if not Assigned(mXMLHead) then
    begin
      LogInfoStr := 'Chyba načtení XML data z API.';
      Exit;
    end;
    mNewOrders:=false;
    try
      mLogs.add(mLogin+' '+mXMLHead.GetElementAsString('Message'));
    except
      mNewOrders:=True;
    end;
    if mNewOrders then begin
        try
          try
            mBatchID := mXMLHead.GetAttributeValue('', 'BatchID');
          except
            mBatchID := 'nemm';
          end;
          mLogs.add('Zpracovávám '+mLogin);
          mLogs.Add('BatchID ' + mBatchID);
          mXMLHead.saveToFile('C:\Users\abraadmin\Documents\ABRA_EXPORT\xml\'+FormatDateTime('YYYYMMDDhhnnss',Now)+'_DataFromB2B.xml');
          mXMLResponse:=TNxScriptingXMLWrapper.Create;
          mXMLResponse.CreateEmpty('Orders');
          mXMLResponse.setAttributeValue('Orders','xmlns','http://pneub2b.eu/SupplierOrdersResponse.xsd');
          mOrderCount := mXMLHead.GetElementsCountInArray('Orders.Order');
          for i := 0 to mOrderCount - 1 do begin
            mOrderID := mXMLHead.GetElementAsString('Orders.Order[' + IntToStr(i) + '].ID');
            mLogs.Add('ID objednávky ' + mOrderID);
            mLogs.Add('Zákazník ' + mXMLHead.GetElementAsString('Orders.Order[' + IntToStr(i) + '].Customer.Name'));
            mFirm_ID:='';
            mFirmOffice_ID:='';
            mFirm_ID:= OS.SQLSelectFirstAsString('Select id from firms where hidden=''N'' and Firm_ID is null and orgidentnumber='+QuotedStr(mXMLHead.GetElementAsString('Orders.Order[' + IntToStr(i) + '].Customer.RegNo')),'');
            if NxIsEmptyOID(mFirm_ID) then begin
              mFirmBO:=OS.CreateObject(Class_Firm);
              mFirmBO.new;
              mFirmBO.Prefill;
              mFirmBO.SetFieldValueAsInteger('X_TypeOfFirm',5);
              mFirmBO.SetFieldValueAsString('X_FormDL_ID','7LH0000101');
              mFirmBO.SetFieldValueAsString('Name',mXMLHead.GetElementAsString('Orders.Order[' + IntToStr(i) + '].Customer.Name'));
              mFirmBO.SetFieldValueAsString('OrgIdentNumber',mXMLHead.GetElementAsString('Orders.Order[' + IntToStr(i) + '].Customer.RegNo'));
              try
               mFirmBO.SetFieldValueAsString('VATIdentNumber',mXMLHead.GetElementAsString('Orders.Order[' + IntToStr(i) + '].Customer.VatNo'));
              except

              end;
              mFirmBO.SetFieldValueAsString('ResidenceAddress_ID.Street',mXMLHead.GetElementAsString('Orders.Order[' + IntToStr(i) + '].Customer.Street'));
              mFirmBO.SetFieldValueAsString('ResidenceAddress_ID.City',mXMLHead.GetElementAsString('Orders.Order[' + IntToStr(i) + '].Customer.City'));
              mFirmBO.SetFieldValueAsString('ResidenceAddress_ID.PostCode',mXMLHead.GetElementAsString('Orders.Order[' + IntToStr(i) + '].Customer.ZIP'));
              mFirmBO.SetFieldValueAsString('ResidenceAddress_ID.Country',mXMLHead.GetElementAsString('Orders.Order[' + IntToStr(i) + '].Customer.Country'));
              mFirmBO.SetFieldValueAsString('ResidenceAddress_ID.CountryCode',mXMLHead.GetElementAsString('Orders.Order[' + IntToStr(i) + '].Customer.CountryID'));
              mFirmBO.SetFieldValueAsString('ResidenceAddress_ID.PhoneNumber1',mXMLHead.GetElementAsString('Orders.Order[' + IntToStr(i) + '].DeliveryAddress.ContactPhone'));
              mFirmBO.SetFieldValueAsString('ResidenceAddress_ID.email',mXMLHead.GetElementAsString('Orders.Order[' + IntToStr(i) + '].DeliveryAddress.ContactEmail'));
              if not(mXMLHead.GetElementAsString('Orders.Order[' + IntToStr(i) + '].Customer.Street')=mXMLHead.GetElementAsString('Orders.Order[' + IntToStr(i) + '].DeliveryAddress.Street')) then begin
                mFirmOffices:=mFirmBO.GetLoadedCollectionMonikerForFieldCode(mFirmBO.GetFieldCode('FirmOffices'));
                mFirmOfficeBO:=mFirmOffices.AddNewObject;
                mFirmOfficeBO.Prefill;
                mFirmOfficeBO.SetFieldValueAsString('Name','Provozovna '+mXMLHead.GetElementAsString('Orders.Order[' + IntToStr(i) + '].DeliveryAddress.Name'));
                mFirmOfficeBO.SetFieldValueAsBoolean('SynchronizeAddress',false);
                mFirmOfficeBO.SetFieldValueAsString('Address_ID.City',mXMLHead.GetElementAsString('Orders.Order[' + IntToStr(i) + '].DeliveryAddress.City'));
                mFirmOfficeBO.SetFieldValueAsString('Address_ID.Street',mXMLHead.GetElementAsString('Orders.Order[' + IntToStr(i) + '].DeliveryAddress.Street'));
                mFirmOfficeBO.SetFieldValueAsString('Address_ID.PostCode',mXMLHead.GetElementAsString('Orders.Order[' + IntToStr(i) + '].DeliveryAddress.ZIP'));
                mFirmOfficeBO.SetFieldValueAsString('Address_ID.PhoneNumber1',mXMLHead.GetElementAsString('Orders.Order[' + IntToStr(i) + '].DeliveryAddress.ContactPhone'));
                mFirmOfficeBO.SetFieldValueAsString('Address_ID.email',mXMLHead.GetElementAsString('Orders.Order[' + IntToStr(i) + '].DeliveryAddress.ContactEmail'));
                mFirmOffice_ID:=mFirmOfficeBO.OID;
              end;
              mFirmBO.save;
              mFirm_ID:=mFirmBO.OID;
              mFirmBO.free;
            end else begin
             mFirmBO:=OS.CreateObject(Class_Firm);
             mFirmBO.Load(mFirm_ID,nil);
             mFirmOffices:=mFirmBO.GetLoadedCollectionMonikerForFieldCode(mFirmBO.GetFieldCode('FirmOffices'));
             mFirmOfficeFound:=False;
             for j:=0 to mFirmOffices.Count-1 do begin
              mFirmOfficeBO:=mFirmOffices.BusinessObject[j];
              if not(mFirmOfficeFound) then begin
               if (mFirmOfficeBO.GetFieldValueAsString('Address_ID.Street')=mXMLHead.GetElementAsString('Orders.Order[' + IntToStr(i) + '].DeliveryAddress.Street'))
                and (mFirmOfficeBO.GetFieldValueAsString('Address_ID.Email')=mXMLHead.GetElementAsString('Orders.Order[' + IntToStr(i) + '].DeliveryAddress.ContactEmail')) then
                 mFirmOfficeFound:=True;
                 mFirmOffice_ID:=mFirmOfficeBO.OID;
              end;
             end;
             if not(mFirmOfficeFound) then begin
                mFirmOfficeBO:=mFirmOffices.AddNewObject;
                mFirmOfficeBO.Prefill;
                mFirmOfficeBO.SetFieldValueAsString('Name','Provozovna '+mXMLHead.GetElementAsString('Orders.Order[' + IntToStr(i) + '].DeliveryAddress.Name'));
                mFirmOfficeBO.SetFieldValueAsBoolean('SynchronizeAddress',false);
                mFirmOfficeBO.SetFieldValueAsString('Address_ID.City',mXMLHead.GetElementAsString('Orders.Order[' + IntToStr(i) + '].DeliveryAddress.City'));
                mFirmOfficeBO.SetFieldValueAsString('Address_ID.Street',mXMLHead.GetElementAsString('Orders.Order[' + IntToStr(i) + '].DeliveryAddress.Street'));
                mFirmOfficeBO.SetFieldValueAsString('Address_ID.PostCode',mXMLHead.GetElementAsString('Orders.Order[' + IntToStr(i) + '].DeliveryAddress.ZIP'));
                mFirmOfficeBO.SetFieldValueAsString('Address_ID.PhoneNumber1',mXMLHead.GetElementAsString('Orders.Order[' + IntToStr(i) + '].DeliveryAddress.ContactPhone'));
                mFirmOfficeBO.SetFieldValueAsString('Address_ID.email',mXMLHead.GetElementAsString('Orders.Order[' + IntToStr(i) + '].DeliveryAddress.ContactEmail'));
                mFirmOffice_ID:=mFirmOfficeBO.OID;
             end;
             if mFirmBO.NeedSave then mFirmBO.save;
             mFirmBO.Free;
            end;
            mBO:=OS.CreateObject(Class_ReceivedOrder);
            mBO.New;
            mBO.prefill;
            mBO.SetFieldValueAsString('DocQueue_ID',cRO_DocQueue_ID);
            mBO.SetFieldValueAsString('Firm_ID',mFirm_ID);
            if not(NxIsEmptyOID(mFirmOffice_ID)) then mBO.SetFieldValueAsString('FirmOffice_ID',mFirmOffice_ID);
            mBO.SetFieldValueAsString('ExternalNumber', mOrderID);
            mBO.SetFieldValueAsString('X_B2BOrigin', mLogin);
            mBO.SetFieldValueAsString('X_B2BNumber',mXMLHead.GetElementAsString('Orders.Order[' + IntToStr(i) + '].Number'));
            mBO.SetFieldValueAsString('Currency_ID',OS.SQLSelectFirstAsString('Select id from currencies where hidden=''N'' and code='+QuotedStr(mXMLHead.GetElementAsString('Orders.Order[' + IntToStr(i) + '].Currency')),'0000CZK000'));
            mBO.SetFieldValueAsString('PaymentType_ID','1000000101');
            if mXMLHead.GetElementAsString('Orders.Order[' + IntToStr(i) + '].PaymentType')='CashOnB2B' then mBO.SetFieldValueAsString('PaymentType_ID','1200000101');
            if mXMLHead.GetElementAsString('Orders.Order[' + IntToStr(i) + '].PaymentType')='Cash' then mBO.SetFieldValueAsString('PaymentType_ID','2000000101');
            if mXMLHead.GetElementAsString('Orders.Order[' + IntToStr(i) + '].PaymentType')='CashOnDelivery' then mBO.SetFieldValueAsString('PaymentType_ID','4000000101');
            if mXMLHead.GetElementAsString('Orders.Order[' + IntToStr(i) + '].DeliveryRoute.ShippingType')='PersonalPickup' then
             mBO.SetFieldValueAsString('TransportationType_ID','00000O1000') else
             mBO.SetFieldValueAsString('TransportationType_ID','2000000101');
            if mlogin in ['8202','8203'] then begin
              mBO.SetFieldValueAsInteger('TradeType',2);
              mBO.SetFieldValueAsInteger('TradeType',2);
              mBO.SetFieldValueAsString('IntrastatDeliveryTerm_ID','1001000000');
              mBO.SetFieldValueAsString('IntrastatTransactionType_ID','0101000000');
              mBO.SetFieldValueAsString('IntrastatTransportationType_ID','2000000000');
              mBO.SetFieldValueAsString('Country_ID','00000SK000');
            end; 
            mItemCount := mXMLHead.GetElementsCountInArray('Orders.Order[' + IntToStr(i) + '].Items.Item');
            mRows:=mBO.GetLoadedCollectionMonikerForFieldCode(mBO.GetFieldCode('Rows'));
            for j := 0 to mItemCount - 1 do begin
              mStoreCard_ID:='';
              try
                mStoreCard_ID:=mXMLHead.GetElementAsString('Orders.Order[' + IntToStr(i) + '].Items.Item[' + IntToStr(j) + '].CodeInternal1');
              except

              end;
              mLogs.Add('Karta '  + mStoreCard_ID + ' '
                                  + mXMLHead.GetElementAsString('Orders.Order[' + IntToStr(i) + '].Items.Item[' + IntToStr(j) + '].PartNo') + ' ' +
                                  mXMLHead.GetElementAsString('Orders.Order[' + IntToStr(i) + '].Items.Item[' + IntToStr(j) + '].Description'));
              if not(NxIsEmptyOID(mStoreCard_ID)) then begin
                mRowBO:=mRows.AddNewObject;
                mRowBO.Prefill;
                mRowBO.SetFieldValueAsInteger('RowType',3);
                mRowBO.SetFieldValueAsString('Store_ID','1000000101');
                mRowBO.SetFieldValueAsString('StoreCard_ID',mStoreCard_ID);
                mRowBO.SetFieldValueAsFloat('Quantity',NxIBStrToFloat(mXMLHead.GetElementAsString('Orders.Order[' + IntToStr(i) + '].Items.Item[' + IntToStr(j) + '].Amount')));
                mRowBO.SetFieldValueAsFloat('UnitPrice',NxIBStrToFloat(mXMLHead.GetElementAsString('Orders.Order[' + IntToStr(i) + '].Items.Item[' + IntToStr(j) + '].UnitPrice')));
                mRowBO.SetFieldValueAsString('Division_ID','1000000101');
                mRowBO.SetFieldValueAsString('U_B2BID', mXMLHead.GetElementAsString('Orders.Order[' + IntToStr(i) + '].Items.Item[' + IntToStr(j) + '].ID'));
              end else begin
               if not(NxIBStrToFloat(mXMLHead.GetElementAsString('Orders.Order[' + IntToStr(i) + '].Items.Item[' + IntToStr(j) + '].UnitPrice'))=0) then begin
                mRowBO:=mRows.AddNewObject;
                mRowBO.Prefill;
                mRowBO.SetFieldValueAsInteger('RowType',2);
                mRowBO.SetFieldValueAsString('Text',mXMLHead.GetElementAsString('Orders.Order[' + IntToStr(i) + '].Items.Item[' + IntToStr(j) + '].Description'));
                mRowBO.SetFieldValueAsFloat('Quantity',NxIBStrToFloat(mXMLHead.GetElementAsString('Orders.Order[' + IntToStr(i) + '].Items.Item[' + IntToStr(j) + '].Amount')));
                mRowBO.SetFieldValueAsString('Qunit','ks');
                mRowBO.SetFieldValueAsFloat('UnitPrice',NxIBStrToFloat(mXMLHead.GetElementAsString('Orders.Order[' + IntToStr(i) + '].Items.Item[' + IntToStr(j) + '].UnitPrice')));
                mRowBO.SetFieldValueAsString('VatRate_ID','02100X0000');
                mRowBO.SetFieldValueAsString('Division_ID','1000000101');
                mRowBO.SetFieldValueAsString('U_B2BID', mXMLHead.GetElementAsString('Orders.Order[' + IntToStr(i) + '].Items.Item[' + IntToStr(j) + '].ID'));
               end;
              end;
            end;
            mBO.Save;
            mBO.free;
            mXMLResponse.AddElement('Order');
            mXMLResponse.setAttributeValue('Order[' + IntToStr(i) + ']','Number', morderID);
            mXMLResponse.setAttributeValue('Order[' + IntToStr(i) + ']','State', 'Accepted');
          end;
          mXMLResponse.saveToFile('C:\Users\abraadmin\Documents\ABRA_EXPORT\xml\response.xml');
          mXMLPostResponse:=API_POST(cURL+'orders_new_confirmed&batch_id='+mBatchID,mLogin,'KingTonyDodavatel.',mXMLResponse, OS);
          mXMLPostResponse.saveToFile('C:\Users\abraadmin\Documents\ABRA_EXPORT\xml\postresponse.xml');
        finally
          mXMLHead.Free;
        end;
     end;
    end;
  finally
    Success := True;
    LogInfoStr := ' ' + mLogs.Text;
    mLogs.Free;
  end;
end;

procedure GenerateStoreCardsForB2B (OS: TNxCustomObjectSpace; var Success: Boolean; var LogInfoStr: String);
var
 mSCList:TStringList;
 mFTP:TFTP;
 mContext:TNxContext;
 mMainJSON, mSCJSON, mSUJSON, mPicJSON:TJSONSuperObject;
 mBO, mUnitBO, mPictureBO:TNxCustomBusinessObject;
 mUnits, mPictures:TNxCustomBusinessMonikerCollection;
 i,j,k:integer;
 mFullPath, mPicturePath: string;
 mPathList, mSCListWP: TStringList;
 mPrice, mPriceEUR:Extended;
begin
 mSCList:=TStringList.Create;
 mSCListWP:=TStringList.Create;
 mPathList:=TStringList.Create; // Inicializace
 mPathList.Delimiter := '\';    // Nastavení oddělovače na zpětné lomítko
 mPathList.StrictDelimiter := True; // Aby to nesekalo podle mezer
 {OS.SQLSelect('SELECT a.id FROM StoreCards A WHERE (A.Hidden = ''N'' ) AND '+
              '((A.STOREASSORTMENTGROUP_ID IN (''1000000101'',''1100000101'') )) '+
              ' AND (A.X_Not_For_Use LIKE ''N'' OR (A.X_Not_For_Use is Null))', mSCList);
 OS.SQLSelect('SELECT a.ID FROM StoreCards A   '#13#10 +
              'WHERE ((A.Producer_ID IN (SELECT ID FROM Firms WHERE ID=''32L7000101'' '#13#10 +
              'or Firm_ID=''32L7000101'')) ) AND (A.Hidden = ''N'' ) '#13#10 +
              'AND (A.X_send_to_B2B LIKE ''A'') ', mSCListWP);}
 OS.SQLSelect('Select a.id from storecards a where a.hidden=''N'' and A.X_B2BSending LIKE ''_1%'' ',mSCList);
 mSCList.AddStrings(mSCListWP);
 if mSCList.count>0 then begin
   mContext:=NxCreateContext(OS);
   mMainJSON:=TJSONSuperObject.Create;
   mMainJSON.S['CompanyName']:=mContext.GetCompanyCache.CompanyName;
   mMainJSON.DT8601['Generated']:=Now;
   mMainJSON.O['StoreCards']:=mMainJSON.CreateJSONArray;
   mBO:=OS.CreateObject(Class_StoreCard);
   for i:=0 to mSCList.count-1 do begin

     mBO.Load(mSCList.strings[i],nil);
     {mPrice:=NxEvalObjectExprAsFloatDef(mBO,'NxGetStoreCardUnitPriceDef('+Quotedstr('')+', '+Quotedstr('')+', ' + QuotedStr(mbo.oid) +
                                        ','+Quotedstr('1000000101')+', '+Quotedstr(mbo.GetFieldValueAsString('MainUnitCode'))+
                                        ',false,'+QuotedStr('0000CZK000')+','+inttostr(trunc(Date))+')',0);
     mPriceEUR:=NxEvalObjectExprAsFloatDef(mBO,'NxGetStoreCardUnitPriceDef('+Quotedstr('')+', '+Quotedstr('')+', ' + QuotedStr(mbo.oid) +
                                        ','+Quotedstr('1100000101')+', '+Quotedstr(mbo.GetFieldValueAsString('MainUnitCode'))+
                                        ',false,'+QuotedStr('0000EUR000')+','+inttostr(trunc(Date))+')',0);}
     mPrice:=OS.SQLSelectFirstAsExtended( 'SELECT first 1 '#13#10 +
                                          '    sp2.Amount'#13#10 +
                                          'FROM PriceListValidities plv'#13#10 +
                                          'JOIN StorePrices sp '#13#10 +
                                          '    ON sp.PriceListValidity_ID = plv.ID'#13#10 +
                                          'JOIN StorePrices2 sp2 '#13#10 +
                                          '    ON sp2.Parent_ID = sp.ID'#13#10 +
                                          'WHERE plv.Parent_ID = ''1000000101'''#13#10 +
                                          '  AND sp.StoreCard_ID = '+QuotedStr(mbo.oid)+' '#13#10 +
                                          '  AND sp2.Price_ID = ''1000000101'''#13#10 +
                                          '  AND plv.ValidFromDate$Date <= (CURRENT_DATE - DATE ''1899-12-30'') + 1 '#13#10 +
                                          'ORDER BY plv.ValidFromDate$Date DESC',0);
     mPriceEUR:=OS.SQLSelectFirstAsExtended( 'SELECT first 1 '#13#10 +
                                          '    sp2.Amount'#13#10 +
                                          'FROM PriceListValidities plv'#13#10 +
                                          'JOIN StorePrices sp '#13#10 +
                                          '    ON sp.PriceListValidity_ID = plv.ID'#13#10 +
                                          'JOIN StorePrices2 sp2 '#13#10 +
                                          '    ON sp2.Parent_ID = sp.ID'#13#10 +
                                          'WHERE plv.Parent_ID = ''1000000101'''#13#10 +
                                          '  AND sp.StoreCard_ID = '+QuotedStr(mbo.oid)+' '#13#10 +
                                          '  AND sp2.Price_ID = ''1100000101'''#13#10 +
                                          '  AND plv.ValidFromDate$Date <= (CURRENT_DATE - DATE ''1899-12-30'') + 1 '#13#10 +
                                          'ORDER BY plv.ValidFromDate$Date DESC',0);
     mSCJSON:=TJSONSuperObject.Create;
     mSCJSON.S['ID']:=mBO.OID;
     mSCJSON.S['Code']:=mBO.GetFieldValueAsString('Code');
     mSCJSON.S['Name']:=mBO.GetFieldValueAsString('Name');
     mSCJSON.S['MainUnitCode']:=mBO.GetFieldValueAsString('MainUnitcode');
     //mSCJSON.S['Description']:=mBO.GetFieldValueAsString('Note');
     mSCJSON.S['Description']:=mBO.GetFieldValueAsString('X_DescriptionB2B');
     //mSCJSON.D['Quantity']:=OS.SQLSelectFirstAsExtended('Select sum(quantity) from storesubcards where storecard_id='+Quotedstr(mBO.OID)+' and store_id='+quotedstr('1000000101'),0);
     mSCJSON.D['PriceCZK']:=mPrice;
     mSCJSON.D['PriceEUR']:=mPriceEUR;
     if not(Nxisblank(mBO.GetFieldValueAsString('X_Product_Sheet_Filename'))) then
     mSCJSON.S['ProductSheet']:='https://data.naradi-simon.cz/prilohy/'+mBO.GetFieldValueAsString('X_Product_Sheet_Filename');
     mSCJSON.S['Manufacturer']:=mBO.GetFieldValueAsString('Producer_ID.Name');
     //mSCJSON.D['Price-15']:=0.85*mPrice;
     // --- ROZSEKÁNÍ CESTY DO JSONu ---
     mFullPath := mBO.GetFieldValueAsString('StoreMenuItem_ID.FULLPATH');
     mSCJSON.S['MenuPath']:= mFullPath; // Ponecháno i původní celé pole

     mPathList.DelimitedText := mFullPath;
     for k := 0 to mPathList.Count - 1 do begin
       mSCJSON.S['Level' + IntToStr(k)] := mPathList.Strings[k];
     end;
     // ---------------------------------
     mPictures:=mBO.GetLoadedCollectionMonikerForFieldCode(mBO.GetFieldCode('Pictures'));
     for j:=0 to mPictures.count-1 do begin
       mPictureBO:=mPictures.BusinessObject[j];
       if mPictureBO.GetFieldValueAsInteger('Posindex')=1 then begin
         mPicturePath:=mPictureBO.GetFieldValueAsString('Picture_ID.PathAndFileName');
         mPicturePath:=NxSearchReplace(mPicturePath,'\\10.0.0.15\abra_images\','https://data.naradi-simon.cz/nejvetsi/',[srAll]);
         mSCJSON.S['ImgURL']:=mPicturePath;
       end;
     end;
     mSCJSON.O['Pictures']:=mSCJSON.CreateJSONArray;
     for j:=0 to mPictures.count-1 do begin
       mPictureBO:=mPictures.BusinessObject[j];
       mPicJSON:=TJSONSuperObject.Create;
       //if mPictureBO.GetFieldValueAsInteger('Posindex')=1 then begin
         mPicturePath:=mPictureBO.GetFieldValueAsString('Picture_ID.PathAndFileName');
         mPicturePath:=NxSearchReplace(mPicturePath,'\\10.0.0.15\abra_images\','https://data.naradi-simon.cz/nejvetsi/',[srAll]);
         mPicJSON.S['ImgURL']:=mPicturePath;
         mSCJSON.A['Pictures'].Add(mPicJSON);
      // end;
     end;
     mUnits:=mBO.GetLoadedCollectionMonikerForFieldCode(mBO.GetFieldCode('StoreUnits'));
     mSCJSON.O['StoreUnits']:=mSCJSON.CreateJSONArray;
     for j:=0 to mUnits.count-1 do begin
       mUnitBO:=mUnits.BusinessObject[j];
       if mUnitBO.GetFieldValueAsString('Code')=mbo.GetFieldValueAsString('MainUnitcode') then begin
         mSUJSON:=TJSONSuperObject.Create;
         mSUJSON.S['Code']:=mUnitBO.GetFieldValueAsString('Code');
         if not(AnsiLeftStr(mUnitBO.GetFieldValueAsString('EAN'),3)='200') then
          mSUJSON.S['EAN']:=mUnitBO.GetFieldValueAsString('EAN');
         mSUJSON.D['Weight']:=mUnitBO.GetFieldValueAsFloat('Weight');
         case mUnitBO.GetFieldValueAsInteger('WeightUnit') of
           0:mSUJSON.S['WeightUnit']:='g';
           1:mSUJSON.S['WeightUnit']:='kg';
           2:mSUJSON.S['WeightUnit']:='t';
         end;
         mSCJSON.A['StoreUnits'].Add(mSUJSON);
       end;
     end;
     mMainJSON.A['StoreCards'].Add(mSCJSON);

   end;
   mBO.free;
   mMainJSON.SaveToFile('c:\Users\abraadmin\Documents\ABRA_EXPORT\xml\25852591.json');
 end;
     try
             mFTP:= TFTP.Create;
             mFTP.Host:='ftp.pneub2b.eu';
             mftp.UserName:='PneuB2B.12316';
             mFTP.Password:='m66daw55';
             mftp.Connect;
             mFTP.Passive:=true;
             mftp.ChangeDir('Catalogues');
             mFTP.TransferType:=ftBinary;
             mftp.Put('c:\Users\abraadmin\Documents\ABRA_EXPORT\xml\25852591.json','25852591.json');
             mFTP.Free;
           except

           end;
        //DeleteFile(NxGetTempDir+'\productfeed.xml');
  mPathList.Free; // Uvolnění z paměti
  mSCList.Free;
  Success := True;
  LogInfoStr := ''
end;

procedure GenerateStoreCardsForB2Bquantity (OS: TNxCustomObjectSpace; var Success: Boolean; var LogInfoStr: String);
var
 mSCList, mSCListWP, mLogs: TStringList;
 mContext:TNxContext;
 mMainJSON, mSCJSON:TJSONSuperObject;
 i, mQtyOption:integer;
 mBO:TNxCustomBusinessObject;
 mPrice, mPriceEUR, mRealQty, mSendingQty, mKoef:Extended;
 mFTP:TFTP;
 mSQL1, mSQL2:string;
begin
 mSCList:=TStringList.Create;
 mSCListWP:=TStringList.Create;
 mLogs:=TStringList.Create;
 {mSQL1:='SELECT a.id FROM StoreCards A join StoreSubcards ssc on ssc.storecard_id=A.id WHERE (SSC.quantity>0 and ssc.Store_ID=''1000000101'') and (A.Hidden = ''N'' ) AND '+
              '((A.STOREASSORTMENTGROUP_ID IN (''1000000101'',''1100000101'') )) '+
              ' AND (A.X_Not_For_Use LIKE ''N'' OR (A.X_Not_For_Use is Null))';
 mSQL2:='SELECT a.ID FROM StoreCards A  join StoreSubcards ssc on ssc.storecard_id=A.id  '#13#10 +
              'WHERE (SSC.quantity>0 and ssc.Store_ID=''1000000101'') and ((A.Producer_ID IN (SELECT ID FROM Firms WHERE ID=''32L7000101'' '#13#10 +
              'or Firm_ID=''32L7000101'')) ) AND (A.Hidden = ''N'' ) '#13#10 +
              'AND (A.X_send_to_B2B LIKE ''A'') ';  }
 mSQL1:='Select a.id from storecards a join StoreSubcards ssc on ssc.storecard_id=A.id WHERE (SSC.quantity>0 and ssc.Store_ID=''1000000101'') and a.hidden=''N'' and A.X_B2BSending LIKE ''_1%'' ';
 mLogs.Add(DateTimeToStr(Now)+' ______________________________');
 mLogs.Add(DateTimeToStr(now)+' první dotaz');
 OS.SQLSelect(mSQL1, mSCList);
 mLogs.Add(DateTimeToStr(now)+' po dotazu');
 mLogs.Add(DateTimeToStr(now)+' '+NxCrlf+msql1);
 mLogs.add(DateTimeToStr(Now)+' '+inttostr(mSCList.count));
 if mSCList.count>0 then begin
   mContext:=NxCreateContext(OS);
   mMainJSON:=TJSONSuperObject.Create;
   mMainJSON.S['CompanyName']:=mContext.GetCompanyCache.CompanyName;
   mMainJSON.DT8601['Generated']:=Now;
   mMainJSON.O['StoreCards']:=mMainJSON.CreateJSONArray;
   mBO:=OS.CreateObject(Class_StoreCard);
   //for i:=0 to 10 do begin
   for i:=0 to mSCList.count-1 do begin
     mBO.Load(mSCList.strings[i],nil);
     mKoef:=0.85;
     if mbo.GetFieldValueAsFloat('X_DiscountPneuB2B')>0 then
      mKoef:=1-(mbo.GetFieldValueAsFloat('X_DiscountPneuB2B')/100);
     //mLogs.add(DateTimeToStr(Now)+' Před nápočtem ceny '+mbo.DisplayName);
     {mPrice:=NxEvalObjectExprAsFloatDef(mBO,'NxGetStoreCardUnitPriceDef('+Quotedstr('')+', '+Quotedstr('')+', ' + QuotedStr(mbo.oid) +
                                        ','+Quotedstr('1000000101')+', '+Quotedstr(mbo.GetFieldValueAsString('MainUnitCode'))+
                                        ',false,'+QuotedStr('0000CZK000')+','+inttostr(trunc(Date))+')',0);
     //mLogs.add(DateTimeToStr(Now)+' po nápočtu ceny CZK');
     mPriceEUR:=NxEvalObjectExprAsFloatDef(mBO,'NxGetStoreCardUnitPriceDef('+Quotedstr('')+', '+Quotedstr('')+', ' + QuotedStr(mbo.oid) +
                                        ','+Quotedstr('1100000101')+', '+Quotedstr(mbo.GetFieldValueAsString('MainUnitCode'))+
                                        ',false,'+QuotedStr('0000EUR000')+','+inttostr(trunc(Date))+')',0);
     //mLogs.add(DateTimeToStr(Now)+' po nápočtu ceny EUR');  }
     mPrice:=OS.SQLSelectFirstAsExtended( 'SELECT first 1 '#13#10 +
                                          '    sp2.Amount'#13#10 +
                                          'FROM PriceListValidities plv'#13#10 +
                                          'JOIN StorePrices sp '#13#10 +
                                          '    ON sp.PriceListValidity_ID = plv.ID'#13#10 +
                                          'JOIN StorePrices2 sp2 '#13#10 +
                                          '    ON sp2.Parent_ID = sp.ID'#13#10 +
                                          'WHERE plv.Parent_ID = ''1000000101'''#13#10 +
                                          '  AND sp.StoreCard_ID = '+QuotedStr(mbo.oid)+' '#13#10 +
                                          '  AND sp2.Price_ID = ''1000000101'''#13#10 +
                                          '  AND plv.ValidFromDate$Date <= (CURRENT_DATE - DATE ''1899-12-30'') + 1 '#13#10 +
                                          'ORDER BY plv.ValidFromDate$Date DESC',0);
     mPriceEUR:=OS.SQLSelectFirstAsExtended( 'SELECT first 1 '#13#10 +
                                          '    sp2.Amount'#13#10 +
                                          'FROM PriceListValidities plv'#13#10 +
                                          'JOIN StorePrices sp '#13#10 +
                                          '    ON sp.PriceListValidity_ID = plv.ID'#13#10 +
                                          'JOIN StorePrices2 sp2 '#13#10 +
                                          '    ON sp2.Parent_ID = sp.ID'#13#10 +
                                          'WHERE plv.Parent_ID = ''1000000101'''#13#10 +
                                          '  AND sp.StoreCard_ID = '+QuotedStr(mbo.oid)+' '#13#10 +
                                          '  AND sp2.Price_ID = ''1100000101'''#13#10 +
                                          '  AND plv.ValidFromDate$Date <= (CURRENT_DATE - DATE ''1899-12-30'') + 1 '#13#10 +
                                          'ORDER BY plv.ValidFromDate$Date DESC',0);
     mSCJSON:=TJSONSuperObject.Create;
     mSCJSON.S['ID']:=mBO.OID;
     mSCJSON.S['Code']:=mBO.GetFieldValueAsString('Code');
     mSCJSON.S['Name']:=mBO.GetFieldValueAsString('Name');
     mSCJSON.S['EAN']:=mBO.GetFieldValueAsString('EAN');
     mSCJSON.D['Price-15CZK']:=mPrice*mKoef;
     mSCJSON.D['Price-15EUR']:=mPriceEUR*mKoef;
     mSCJSON.S['Manufacturer']:=mBO.GetFieldValueAsString('Producer_ID.Name');
     mRealQty:=OS.SQLSelectFirstAsExtended('Select sum(quantity) from storesubcards where storecard_id='+Quotedstr(mBO.OID)+' and store_id='+quotedstr('1000000101'),0);
     mQtyOption := mBO.GetFieldValueAsInteger('X_QuantitySending');
     if mQtyOption=0 then mSendingQty:=mRealQty;
     if mQtyOption = 1 then
      begin
        if mRealQty < 100 then
          mSendingQty := mRealQty
        else if mRealQty > 1000 then
          mSendingQty := 1000
        else
          mSendingQty := NxRoundByValue(mRealQty, ctDown, 100);
      end;
     if mQtyOption = 2 then
      begin
        if mRealQty <= 20 then
          mSendingQty := mRealQty
        else if mRealQty <= 100 then
          mSendingQty := NxRoundByValue(mRealQty, ctDown, 10)
        else if mRealQty <= 1000 then
          mSendingQty := NxRoundByValue(mRealQty, ctDown, 100)
        else
          mSendingQty := 1000;
      end;
     if mQtyOption = 3 then
      begin
        if mRealQty < 5 then
          mSendingQty := 1
        else if mRealQty < 20 then
          mSendingQty := NxRoundByValue(mRealQty, ctDown, 5)
        else if mRealQty < 100 then
          mSendingQty := NxRoundByValue(mRealQty, ctDown, 10)
        else if mRealQty < 1000 then
          mSendingQty := NxRoundByValue(mRealQty, ctDown, 100)
        else
          mSendingQty := 1000;
      end;
     if mQtyOption = 4 then
      begin
        if mRealQty < 1 then
          mSendingQty := 0
        else if mRealQty < 10 then
          mSendingQty := 1
        else if mRealQty < 20 then
          mSendingQty := 10
        else if mRealQty < 50 then
          mSendingQty := 20
        else if mRealQty < 100 then
          mSendingQty := 50
        else if mRealQty < 500 then
          mSendingQty := 100
        else if mRealQty < 1000 then
          mSendingQty := 500
        else
          mSendingQty := 1000;
      end;
     mSCJSON.D['Quantity']:=mSendingQty;
     mMainJSON.A['StoreCards'].Add(mSCJSON);
     //mLogs.add(DateTimeToStr(Now)+' po přidání JSON');
   end;
   mBO.Free;
   mMainJSON.SaveToFile('c:\Users\abraadmin\Documents\ABRA_EXPORT\xml\25852591q.json');
   mLogs.add(DateTimeToStr(Now)+' po uložení');
 end;
          try
             mFTP:= TFTP.Create;
             mFTP.Host:='ftp.pneub2b.eu';
             mftp.UserName:='PneuB2B.12316';
             mFTP.Password:='m66daw55';
             mftp.Connect;
             mFTP.Passive:=true;
             //mftp.ChangeDir('Catalogues');
             mFTP.TransferType:=ftBinary;
             mftp.Put('c:\Users\abraadmin\Documents\ABRA_EXPORT\xml\25852591q.json','25852591.json');
             mFTP.Free;
           except

           end;
  mSCList.Free;
  Success := True;
  LogInfoStr := ''+NxCrlF+mLogs.Text;
end;

procedure GenerateStoreCardsForB2BquantityKTP (OS: TNxCustomObjectSpace; var Success: Boolean; var LogInfoStr: String);
var
 mSCList, mSCListWP, mLogs: TStringList;
 mContext:TNxContext;
 mMainJSON, mSCJSON:TJSONSuperObject;
 i, mQtyOption:integer;
 mBO:TNxCustomBusinessObject;
 mPrice, mPriceEUR, mRealQty, mSendingQty, mKoef:Extended;
 mFTP:TFTP;
 mSQL1, mSQL2:string;
begin
 mSCList:=TStringList.Create;
 mSCListWP:=TStringList.Create;
 mLogs:=TStringList.Create;
 {mSQL1:='SELECT a.id FROM StoreCards A join StoreSubcards ssc on ssc.storecard_id=A.id WHERE (SSC.quantity>0 and ssc.Store_ID=''1420000101'') and (A.Hidden = ''N'' ) AND '+
              '((A.STOREASSORTMENTGROUP_ID IN (''1000000101'',''1100000101'') )) '+
              ' AND (A.X_Not_For_Use LIKE ''N'' OR (A.X_Not_For_Use is Null))';
 mSQL2:='SELECT a.ID FROM StoreCards A  join StoreSubcards ssc on ssc.storecard_id=A.id  '#13#10 +
              'WHERE (SSC.quantity>0 and ssc.Store_ID=''1420000101'') and ((A.Producer_ID IN (SELECT ID FROM Firms WHERE ID=''32L7000101'' '#13#10 +
              'or Firm_ID=''32L7000101'')) ) AND (A.Hidden = ''N'' ) '#13#10 +
              'AND (A.X_send_to_B2B LIKE ''A'') ';}
 mSQL1:='Select a.id from storecards a join StoreSubcards ssc on ssc.storecard_id=A.id WHERE (SSC.quantity>0 and ssc.Store_ID=''1420000101'') and a.hidden=''N'' and A.X_B2BSending LIKE ''_1%'' ';
 mLogs.Add(DateTimeToStr(Now)+' ______________________________');
 mLogs.Add(DateTimeToStr(now)+' první dotaz');
 OS.SQLSelect(mSQL1, mSCList);
 {mLogs.Add(DateTimeToStr(now)+' druhý dotaz');
 OS.SQLSelect(mSQL2, mSCListWP);
 mLogs.Add(DateTimeToStr(now)+' sloučíme dotaz');
 mSCList.AddStrings(mSCListWP); }
 mLogs.Add(DateTimeToStr(now)+' po sloučení');
 mLogs.Add(DateTimeToStr(now)+' '+NxCrlf+msql1);
 //mLogs.Add(DateTimeToStr(now)+' '+NxCrlf+msql2);
 mLogs.add(DateTimeToStr(Now)+' '+inttostr(mSCList.count));
 if mSCList.count>0 then begin
   mContext:=NxCreateContext(OS);
   mMainJSON:=TJSONSuperObject.Create;
   mMainJSON.S['CompanyName']:=mContext.GetCompanyCache.CompanyName;
   mMainJSON.DT8601['Generated']:=Now;
   mMainJSON.O['StoreCards']:=mMainJSON.CreateJSONArray;
   mBO:=OS.CreateObject(Class_StoreCard);
   //for i:=0 to 10 do begin
   for i:=0 to mSCList.count-1 do begin
     mBO.Load(mSCList.strings[i],nil);
     mKoef:=0.85;
     if mbo.GetFieldValueAsFloat('X_DiscountPneuB2B')>0 then
      mKoef:=1-(mbo.GetFieldValueAsFloat('X_DiscountPneuB2B')/100);
     //mLogs.add(DateTimeToStr(Now)+' Před nápočtem ceny '+mbo.DisplayName);
     {mPrice:=NxEvalObjectExprAsFloatDef(mBO,'NxGetStoreCardUnitPriceDef('+Quotedstr('')+', '+Quotedstr('')+', ' + QuotedStr(mbo.oid) +
                                        ','+Quotedstr('1000000101')+', '+Quotedstr(mbo.GetFieldValueAsString('MainUnitCode'))+
                                        ',false,'+QuotedStr('0000CZK000')+','+inttostr(trunc(Date))+')',0);
     //mLogs.add(DateTimeToStr(Now)+' po nápočtu ceny CZK');
     mPriceEUR:=NxEvalObjectExprAsFloatDef(mBO,'NxGetStoreCardUnitPriceDef('+Quotedstr('')+', '+Quotedstr('')+', ' + QuotedStr(mbo.oid) +
                                        ','+Quotedstr('1100000101')+', '+Quotedstr(mbo.GetFieldValueAsString('MainUnitCode'))+
                                        ',false,'+QuotedStr('0000EUR000')+','+inttostr(trunc(Date))+')',0);
     //mLogs.add(DateTimeToStr(Now)+' po nápočtu ceny EUR');  }
     mPrice:=OS.SQLSelectFirstAsExtended( 'SELECT first 1 '#13#10 +
                                          '    sp2.Amount'#13#10 +
                                          'FROM PriceListValidities plv'#13#10 +
                                          'JOIN StorePrices sp '#13#10 +
                                          '    ON sp.PriceListValidity_ID = plv.ID'#13#10 +
                                          'JOIN StorePrices2 sp2 '#13#10 +
                                          '    ON sp2.Parent_ID = sp.ID'#13#10 +
                                          'WHERE plv.Parent_ID = ''1000000101'''#13#10 +
                                          '  AND sp.StoreCard_ID = '+QuotedStr(mbo.oid)+' '#13#10 +
                                          '  AND sp2.Price_ID = ''1000000101'''#13#10 +
                                          '  AND plv.ValidFromDate$Date <= (CURRENT_DATE - DATE ''1899-12-30'') + 1 '#13#10 +
                                          'ORDER BY plv.ValidFromDate$Date DESC',0);
     mPriceEUR:=OS.SQLSelectFirstAsExtended( 'SELECT first 1 '#13#10 +
                                          '    sp2.Amount'#13#10 +
                                          'FROM PriceListValidities plv'#13#10 +
                                          'JOIN StorePrices sp '#13#10 +
                                          '    ON sp.PriceListValidity_ID = plv.ID'#13#10 +
                                          'JOIN StorePrices2 sp2 '#13#10 +
                                          '    ON sp2.Parent_ID = sp.ID'#13#10 +
                                          'WHERE plv.Parent_ID = ''1000000101'''#13#10 +
                                          '  AND sp.StoreCard_ID = '+QuotedStr(mbo.oid)+' '#13#10 +
                                          '  AND sp2.Price_ID = ''1100000101'''#13#10 +
                                          '  AND plv.ValidFromDate$Date <= (CURRENT_DATE - DATE ''1899-12-30'') + 1 '#13#10 +
                                          'ORDER BY plv.ValidFromDate$Date DESC',0);
     mSCJSON:=TJSONSuperObject.Create;
     mSCJSON.S['ID']:=mBO.OID;
     mSCJSON.S['Code']:=mBO.GetFieldValueAsString('Code');
     mSCJSON.S['Name']:=mBO.GetFieldValueAsString('Name');
     mSCJSON.S['EAN']:=mBO.GetFieldValueAsString('EAN');
     mSCJSON.D['Price-15CZK']:=mPrice*mKoef;
     mSCJSON.D['Price-15EUR']:=mPriceEUR*mKoef;
     mSCJSON.S['Manufacturer']:=mBO.GetFieldValueAsString('Producer_ID.Name');
     mRealQty:=OS.SQLSelectFirstAsExtended('Select sum(quantity) from storesubcards where storecard_id='+Quotedstr(mBO.OID)+' and store_id='+quotedstr('1420000101'),0);
     mQtyOption := mBO.GetFieldValueAsInteger('X_QuantitySendingKTP');
     if mQtyOption=0 then mSendingQty:=mRealQty;
     if mQtyOption = 1 then
      begin
        if mRealQty < 100 then
          mSendingQty := mRealQty
        else if mRealQty > 1000 then
          mSendingQty := 1000
        else
          mSendingQty := NxRoundByValue(mRealQty, ctDown, 100);
      end;
     if mQtyOption = 2 then
      begin
        if mRealQty <= 20 then
          mSendingQty := mRealQty
        else if mRealQty <= 100 then
          mSendingQty := NxRoundByValue(mRealQty, ctDown, 10)
        else if mRealQty <= 1000 then
          mSendingQty := NxRoundByValue(mRealQty, ctDown, 100)
        else
          mSendingQty := 1000;
      end;
     if mQtyOption = 3 then
      begin
        if mRealQty < 5 then
          mSendingQty := 1
        else if mRealQty < 20 then
          mSendingQty := NxRoundByValue(mRealQty, ctDown, 5)
        else if mRealQty < 100 then
          mSendingQty := NxRoundByValue(mRealQty, ctDown, 10)
        else if mRealQty < 1000 then
          mSendingQty := NxRoundByValue(mRealQty, ctDown, 100)
        else
          mSendingQty := 1000;
      end;
     if mQtyOption = 4 then
      begin
        if mRealQty < 1 then
          mSendingQty := 0
        else if mRealQty < 10 then
          mSendingQty := 1
        else if mRealQty < 20 then
          mSendingQty := 10
        else if mRealQty < 50 then
          mSendingQty := 20
        else if mRealQty < 100 then
          mSendingQty := 50
        else if mRealQty < 500 then
          mSendingQty := 100
        else if mRealQty < 1000 then
          mSendingQty := 500
        else
          mSendingQty := 1000;
      end;
     mSCJSON.D['Quantity']:=mSendingQty;
     mMainJSON.A['StoreCards'].Add(mSCJSON);
     //mLogs.add(DateTimeToStr(Now)+' po přidání JSON');
   end;
   mBO.Free;
   mMainJSON.SaveToFile('c:\Users\abraadmin\Documents\ABRA_EXPORT\xml\25852591qktp.json');
   mLogs.add(DateTimeToStr(Now)+' po uložení');
 end;
          try
             mFTP:= TFTP.Create;
             mFTP.Host:='ftp.pneub2b.eu';
             mftp.UserName:='PneuB2B.12389';
             mFTP.Password:='cz695r6f';
             mftp.Connect;
             mFTP.Passive:=true;
             //mftp.ChangeDir('Catalogues');
             mFTP.TransferType:=ftBinary;
             mftp.Put('c:\Users\abraadmin\Documents\ABRA_EXPORT\xml\25852591qktp.json','25852591.json');
             mFTP.Free;
           except

           end;
  mSCList.Free;
  Success := True;
  LogInfoStr := ''+NxCrlF+mLogs.Text;
end;


begin
end.