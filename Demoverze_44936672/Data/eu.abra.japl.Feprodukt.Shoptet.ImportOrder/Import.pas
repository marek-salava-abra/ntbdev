uses 'eu.abra.japl.Feprodukt.Shoptet.ImportOrder.fce', 'eu.abra.mavy.libs.common';
function InsertOrder(OS: TNxCustomObjectSpace; AFileName: string) : boolean; //;directory: string;filename: string;mSite:TSiteForm
const
cDocQueueID= '1R00000101';
cStoreID= '2200000101';
cDivisionID='3200000101';
cLogs = True;
Var
 mXMLinput:string;
 AStream: TMemoryStream;
 mXMLHead, mXMLHead2 : TNxScriptingXMLWrapper;
 mStoreUnits, mStoreCardBO, mReceivedOrderBO, mReceivedOrderRowBO,mObj,mObj2: TNxCustomBusinessObject;
 mFirm, mFirmOffice, mStoreCard, mFirmPerson, mPerson: TNxCustomBusinessObject;
 mRows,mMon,  mColl : TNxCustomBusinessMonikerCollection;
 mOS: TNxCustomObjectSpace;
 mEAN_ID, mEshopStoreCardCode, mEshopPrefix, mQunit, mSupplier_ID, mFirm_ID, mFirmOffice_ID, mStoreCard_ID, mPrice, mPerson_ID, mPer_ID, mOrder_ID: String;
 mVAT, mCountryCode, mVarSymbol, mOrgIdentNumber,mVATIdentNumber, mFirmName,mOrderCode:string;
 mQuantityDouble, mPriceDouble :Double;
 mQuantity: extended;
 mList:TStringList;
 i,j,d,a,e: integer;
 mDeliveryPointID, mEAN, mProductCode, mVATRate_ID, AResult, mFirmOfficeName, mTransportationType_ID, mPaymentType_ID:String;
 Logs, Errors: TStringList;
 mDate,ID: string;
 IsFirm,IsChange: boolean;
 mParams: TNxParameters;
 mManager: TNxDocumentImportManager;
begin
 Aresult:='';
 Result:=True;
 //mOS:=self.ObjectSpace;
 mXMLHead := TNxScriptingXMLWrapper.Create;
 mList:=TStringList.Create;
 Logs:= TStringList.Create;
 Errors:=TStringList.Create;
 //Logs.Add(DateTimeToStr(Now)+' -  Parsuji XML');
 mXMLHead.loadFromFile(AFilename);
 for i:= 0 to mXMLHead.getElementsCountInArray('ORDER') - 1 do begin
    IsFirm:=false;
    IsChange:=false;
    mOrderCode:= mXMLHead.getElementAsString('ORDER['+inttostr(i)+'].Code');
    mOrder_ID:= scrOrder_ID(OS,'ExternalNumber',mOrderCode,cDocQueueID);
    try
    Logs.Add(DateTimeToStr(Now)+' - Zahájení importu');
    if not(NxIsEmptyOID(mOrder_ID)) then begin
      Logs.Add(DateTimeToStr(Now)+' - Objednávka už existuje - id_eshop:'+mOrderCode+'|id_abra:'+mOrder_ID);
      AResult :=AResult+('id_eshop:'+mOrderCode+'|id_abra:'+mOrder_ID+'#');

      //if Trim(mXMLHead.getElementAsString('Order['+inttostr(i)+'].Status')) = 'Zaplacená předem' then begin
      if mXMLHead.getElementAsString('Order['+inttostr(i)+'].TOTAL_PRICE.Paid') = '1' then begin
        mObj:= OS.CreateObject(Class_ReceivedOrder);
        mObj.load(mOrder_ID,nil);
        ID:= GetDeposit_inv(OS,mOrder_ID);
        //pokud není stav zaplaceno a není OP v hotovosti
        if not(mObj.GetFieldValueAsString('PMState_ID')='2000000101') and not (mObj.GetFieldValueAsString('PaymentType_ID')= '1200000101') then begin
          if (mObj.GetFieldValueAsInteger('TradeType') = 1) and not(NxIsEmptyOID(ID)) then begin
              mObj2:= OS.CreateObject(Class_IssuedDepositInvoice);
              mObj2.load(ID,nil);
              mParams := TNxParameters.Create();
              mManager := NxCreateDocumentImportManager(OS,Class_IssuedDepositInvoice,Class_VATIssuedDepositInvoice);
              mManager.AddInputDocument(ID);
              mParams.GetOrCreateParam(dtString, 'DocQueue_ID').AsString := '9700000101';
              mParams.GetOrCreateParam(dtBoolean, 'ImportDepositRows').AsBoolean := true;
              //mParams.GetOrCreateParam(dtBoolean, 'ImportTextRows').AsBoolean := true;
              mParams.GetOrCreateParam(dtString, 'VATRateIDOnRow').AsString := '02100X0000';
              mParams.GetOrCreateParam(dtFloat, 'DepositAmount').Asfloat := mObj2.getFieldValueAsFloat('Amount');
              mManager.LoadParams(mParams);
              mManager.Execute;
              mManager.OutputDocument.SetFieldValueAsString('Currency_ID',mObj2.GetFieldValueAsString('Currency_ID'));
              mManager.OutputDocument.SetFieldValueAsString('Country_ID',mObj2.GetFieldValueAsString('Country_ID'));
              mManager.OutputDocument.SetFieldValueAsString('Firm_id',mObj2.GetFieldValueAsString('Firm_id'));
              mManager.OutputDocument.SetFieldValueAsString('FirmOffice_id',mObj2.GetFieldValueAsString('FirmOffice_id'));
              mManager.OutputDocument.SetFieldValueAsString('Description', 'Zdaněná záloha k: '+mObj2.DisplayName);
              mManager.OutputDocument.Save;
              Logs.Add(DateTimeToStr(Now)+' - Vytvořen DZV a změněn stav (tuzemsko) - id_eshop:'+mOrderCode+'|id_abra:'+mOrder_ID);
              mManager.free;
              mParams.Clear;
              //mObj.SetFieldValueAsBoolean('Confirmed',true);
              mObj.SetFieldValueAsString('PMState_ID','2000000101');
              mObj2.free;
              IsCHange:=true;
          End
          else begin
            if (mObj.GetFieldValueAsInteger('TradeType') <> 1) then begin
              mObj.SetFieldValueAsString('PMState_ID','2000000101');
              Logs.Add(DateTimeToStr(Now)+' - Změna stavu objednávky na zaplaceno (zahraniční) - id_eshop:'+mOrderCode+'|id_abra:'+mOrder_ID);
              IsCHange:=true;
            end;
          end;
        end;


          if not(mObj.GetFieldValueAsString('PMState_ID')='2000000101') and NxIsEmptyOID(ID) then begin
            mObj.SetFieldValueAsBoolean('X_IsImportError', True);
            mObj.SetFieldValueAsString('X_ImportErrors',mObj.GetFieldValueAsString('X_ImportErrors')+ DateTimeToStr(Now)+ ' Při vytváření Daňového zálohového listu došlo k problému. '  +#13#10 );
            IsCHange:=true;
          end;

          if IsChange then begin
            mObj.save;
            mObj.free;
          end else begin
            mObj.free;
          end;

      end;
    end;
    if NxIsEmptyOID(mOrder_ID) then begin
        mFirm_ID:='';
        mFirmOffice_ID:='';
        mPerson_ID:='';
        mOrgIdentNumber:= '';
        mVATIdentNumber:='';
        mFirmName:='';
        IsFirm:= false;
        if Trim(mXMLHead.getElementAsString('Order['+inttostr(i)+'].Status')) = 'Stornována' then begin
          Logs.Add(DateTimeToStr(Now)+' - Objednávka je v eshopu stornována, přeskakuji - id_eshop:'+mOrderCode);
          continue;   //přeskakuji v cyklu na další
        end;
        if Trim(mXMLHead.getElementAsString('Order['+inttostr(i)+'].Status')) = 'Vyřízena' then begin
          Logs.Add(DateTimeToStr(Now)+' - Objednávka je v eshopu vyřízena, přeskakuji - id_eshop:'+mOrderCode);
          continue;   //přeskakuji v cyklu na další
        end;
        Logs.Add(DateTimeToStr(Now)+' - Vytvářím objednávku - '+mOrderCode);
        mReceivedOrderBO:=OS.CreateObject(Class_ReceivedOrder);
        mReceivedOrderBO.New;
        mReceivedOrderBO.Prefill;
        Logs.Add(DateTimeToStr(Now)+' - Vyplňuji řadu dokladů');
        mReceivedOrderBO.SetFieldValueAsString('DocQueue_ID',cDocQueueID);
        //if Trim(mXMLHead.getElementAsString('Order['+inttostr(i)+'].Status')) = 'Zaplacená předem' then begin
        if mXMLHead.getElementAsString('Order['+inttostr(i)+'].TOTAL_PRICE.Paid') = '1' then begin
          mReceivedOrderBO.SetFieldValueAsString('PMState_ID','2000000101');
        end else begin
          mReceivedOrderBO.SetFieldValueAsString('PMState_ID','1000000101');
        end;
        Logs.Add(DateTimeToStr(Now)+' - Zjišťuji jestli je zákazník firma');
        if ElementExists(mXMLHead,'Order['+inttostr(i)+'].Customer.Billing_Address.company_id') and not(mXMLHead.getElementAsString('Order['+inttostr(i)+'].Customer.Billing_Address.company_id')='') then begin
           IsFirm:= true;
           if ElementExists(mXMLHead,'Order['+inttostr(i)+'].Customer.Billing_Address.Company_Id') then
             mOrgIdentNumber:= trim(mXMLHead.getElementAsString('Order['+inttostr(i)+'].Customer.Billing_Address.Company_Id'));
           if ElementExists(mXMLHead,'Order['+inttostr(i)+'].Customer.Billing_Address.Vat_Id') then
             mVATIdentNumber:= trim(mXMLHead.getElementAsString('Order['+inttostr(i)+'].Customer.Billing_Address.Vat_Id'));
           if ElementExists(mXMLHead,'Order['+inttostr(i)+'].Customer.Billing_Address.Company') then
             mFirmName:= trim(mXMLHead.getElementAsString('Order['+inttostr(i)+'].Customer.Billing_Address.Company'));
           Logs.Add(DateTimeToStr(Now)+' - Zákazník je firma');
        end;
        //showmessage(mFirmName,nil);
        if IsFirm then begin
          Logs.Add(DateTimeToStr(Now)+' - Hledám firmu podle DIČ');
          if NxIsEmptyOID(mfirm_id) and not(NxIsBlank(mVATIdentNumber)) then mfirm_id:=scrFirm_ID(OS,'VatIdentNumber', mVATIdentNumber);
          Logs.Add(DateTimeToStr(Now)+' - Hledám firmu podle IČ');
          if NxIsEmptyOID(mfirm_id) and not(NxIsBlank(mOrgIdentNumber)) then mfirm_id:=scrFirm_ID(OS,'OrgIdentNumber', mOrgIdentNumber);
          //Logs.Add(DateTimeToStr(Now)+' - Hledám firmu podle Názvu');
          //if NxIsEmptyOID(mfirm_id) and not(NxIsBlank(mFirmName)) then mfirm_id:=scrFirm_ID(OS,'Name',Nxsearchreplace(mFirmName,chr(39),chr(39),[srAll]));
        end;

        if IsFirm and NxIsEmptyOID(mFirm_ID) then begin
          Logs.Add(DateTimeToStr(Now)+' - Nenašel jsem firmu');
          mFirm:= OS.CreateObject('4K3EXM5PQBCL35CH000ILPWJF4');
          mFirmOffice:= OS.CreateObject('AT011EZZ5DFO115YJ1HCZJDXJ4');
          mFirm.New;
          mFirm.Prefill;
          Logs.Add(DateTimeToStr(Now)+' - Zakládám firmu');
          if not(NxIsBlank(mFirmName)) then mFirm.SetFieldValueAsString('Name',Trim(mFirmName));
          if NxIsBlank(mFirmName) then mFirm.SetFieldValueAsString('Name',Trim(mXMLHead.getElementAsString('Order['+inttostr(i)+'].Customer.Billing_Address.Name')));
          mFirm.SetFieldValueAsString('ORGIdentNumber',Trim(mXMLHead.getElementAsString('Order['+inttostr(i)+'].Customer.Billing_Address.Company_Id')));
          mFirm.SetFieldValueAsString('VATIdentNumber',UpperCase(Trim(mXMLHead.getElementAsString('Order['+inttostr(i)+'].Customer.Billing_Address.Vat_Id'))));

          mCountryCode:= UpperCase(NxLeft(mXMLHead.getElementAsString('Order['+inttostr(i)+'].Customer.Billing_Address.VAT_ID'),2));
          if  mCountryCode = 'SK' then begin
            mFirm.GetMonikerForFieldCode(mFirm.GetFieldCode('ResidenceAddress_ID')).BusinessObject.SetFieldValueAsString('CountryCode', mCountryCode);
            mFirm.SetFieldValueAsString('VATCountry_ID', scrGetCountry_ID(OS, 'CODE', mCountryCode));
          end;
          //mFirm.SetFieldValueAsString('Code',mXMLHead.getElementAsString('Order['+inttostr(i)+'].Customer.Customer_ID'));
          mFirm.GetMonikerForFieldCode(mFirm.GetFieldCode('ResidenceAddress_ID')).BusinessObject.SetFieldValueAsString('Country', mXMLHead.getElementAsString('Order['+inttostr(i)+'].Customer.Billing_Address.Country'));
          mFirm.GetMonikerForFieldCode(mFirm.GetFieldCode('ResidenceAddress_ID')).BusinessObject.SetFieldValueAsString('CountryCode', mXMLHead.getElementAsString('Order['+inttostr(i)+'].Customer.Billing_Address.Country_Code'));
          mFirm.GetMonikerForFieldCode(mFirm.GetFieldCode('ResidenceAddress_ID')).BusinessObject.SetFieldValueAsString('Recipient',NxLeft(Trim(mXMLHead.getElementAsString('Order['+inttostr(i)+'].Customer.Billing_Address.Name')),30));
          mFirm.GetMonikerForFieldCode(mFirm.GetFieldCode('ResidenceAddress_ID')).BusinessObject.SetFieldValueAsString('PostCode',Trim(mXMLHead.getElementAsString('Order['+inttostr(i)+'].Customer.Billing_Address.zip')));
          mFirm.GetMonikerForFieldCode(mFirm.GetFieldCode('ResidenceAddress_ID')).BusinessObject.SetFieldValueAsString('City',Trim(mXMLHead.getElementAsString('Order['+inttostr(i)+'].Customer.Billing_Address.City')));
          mFirm.GetMonikerForFieldCode(mFirm.GetFieldCode('ResidenceAddress_ID')).BusinessObject.SetFieldValueAsString('Street',Trim(mXMLHead.getElementAsString('Order['+inttostr(i)+'].Customer.Billing_Address.Street')));
          mFirm.GetMonikerForFieldCode(mFirm.GetFieldCode('ResidenceAddress_ID')).BusinessObject.SetFieldValueAsString('PhoneNumber1',Trim(mXMLHead.getElementAsString('Order['+inttostr(i)+'].Customer.Phone')));
          //mFirm.GetMonikerForFieldCode(mFirm.GetFieldCode('ResidenceAddress_ID')).BusinessObject.SetFieldValueAsString('PhoneNumber2',Trim(mXMLHead.getElementAsString('Zakaznik.mobil')));
          mFirm.GetMonikerForFieldCode(mFirm.GetFieldCode('ResidenceAddress_ID')).BusinessObject.SetFieldValueAsString('Email',Trim(mXMLHead.getElementAsString('Order['+inttostr(i)+'].Customer.Email')));
          mFirm.GetMonikerForFieldCode(mFirm.GetFieldCode('ElectronicAddress_ID')).BusinessObject.SetFieldValueAsString('Email',Trim(mXMLHead.getElementAsString('Order['+inttostr(i)+'].Customer.Email')));
          mfirm.Save;
          mFirm_ID:=mFirm.OID;
          AResult :=AResult+('NewFirm:'+mFirm_ID+'#');
          Logs.Add(DateTimeToStr(Now)+' - Firma založena - '+mFirm_ID);
          mFirm.Free;
        end;

        Logs.Add(DateTimeToStr(Now)+' - Vybrána firma - '+mFirm_ID);
        //začátek zakládání provozovny
        if not(NxIsEmptyOID(mFirm_ID)) then begin
          //if not(NxIsBlank(Trim(mXMLHead.getElementAsString('Order['+inttostr(i)+'].Customer.SHIPPING_ADDRESS.company')))) or not(NxIsBlank(Trim(mXMLHead.getElementAsString('Order['+inttostr(i)+'].Customer.SHIPPING_ADDRESS.name')))) then begin
            mFirm:= OS.CreateObject('4K3EXM5PQBCL35CH000ILPWJF4');
            mFirmOffice:= OS.CreateObject('AT011EZZ5DFO115YJ1HCZJDXJ4');
            mFirm.Load(mFirm_ID,nil);
            mColl := mFirm.GetLoadedCollectionMonikerForFieldCode(mFirm.GetfieldCode('FirmOffices'));
            if not(Trim(mXMLHead.getElementAsString('Order['+inttostr(i)+'].Customer.Shipping_address.Street'))='')
              //or not(mXMLHead.getElementAsString('Order['+inttostr(i)+'].Customer.Addresses.Postal.Surname')='')
              then begin
              for d:=0 to mColl.Count-1 do begin
              if NxSearch(mcoll.BusinessObject[d].GetMonikerForFieldCode(mcoll.BusinessObject[d].GetFieldCode('Address_ID')).BusinessObject.GetFieldValueAsString('Street'),Trim(mXMLHead.getElementAsString('Order['+inttostr(i)+'].Customer.Shipping_address.Street')) + ' ' +trim(mXMLHead.getElementAsString('Order['+inttostr(i)+'].Customer.Shipping_address.Housenumber')),[srAll],0)>0 then
                mFirmOffice_ID:=mcoll.BusinessObject[d].OID;
              end;
              end;
              //mFirm.Save;
          //end;
          if NxIsEmptyOID(mFirmOffice_ID) then begin
            Logs.Add(DateTimeToStr(Now)+' - Nenašel jsem provozovnu, zakládám novou ');
            mFirmOffice :=mColl.AddNewObject;
            mFirmOfficeName:=Trim(mXMLHead.getElementAsString('Order['+inttostr(i)+'].Customer.Shipping_address.Company'));
            if not(nxisblank(mFirmOfficeName)) then mFirmOffice.SetFieldValueAsString('Name', mFirmOfficeName);
            if (nxisblank(mFirmOfficeName)) then mFirmOffice.SetFieldValueAsString('Name', 'Provozovna - eshop');
            mFirmOffice.SetFieldValueAsBoolean('SynchronizeAddress', False);
            mFirmOffice.GetMonikerForFieldCode(mFirmOffice.GetFieldCode('Address_ID')).BusinessObject.SetFieldValueAsString('City',mXMLHead.getElementAsString('Order['+inttostr(i)+'].Customer.Shipping_address.City'));
            mFirmOffice.GetMonikerForFieldCode(mFirmOffice.GetFieldCode('Address_ID')).BusinessObject.SetFieldValueAsString('PostCode',mXMLHead.getElementAsString('Order['+inttostr(i)+'].Customer.Shipping_address.ZIP'));
            mFirmOffice.GetMonikerForFieldCode(mFirmOffice.GetFieldCode('Address_ID')).BusinessObject.SetFieldValueAsString('Street',mXMLHead.getElementAsString('Order['+inttostr(i)+'].Customer.Shipping_address.Street') + ' ' + mXMLHead.getElementAsString('Order['+inttostr(i)+'].Customer.Shipping_address.Housenumber'));
            mFirmOffice.GetMonikerForFieldCode(mFirmOffice.GetFieldCode('Address_ID')).BusinessObject.SetFieldValueAsString('Recipient',NxLeft(mXMLHead.getElementAsString('Order['+inttostr(i)+'].Customer.Shipping_address.Name'),30));
            mFirmOffice.GetMonikerForFieldCode(mFirmOffice.GetFieldCode('Address_ID')).BusinessObject.SetFieldValueAsString('Country',NxLeft(mXMLHead.getElementAsString('Order['+inttostr(i)+'].Customer.Shipping_address.Country'),40));
            mFirmOffice.GetMonikerForFieldCode(mFirmOffice.GetFieldCode('Address_ID')).BusinessObject.SetFieldValueAsString('CountryCode',NxLeft(mXMLHead.getElementAsString('Order['+inttostr(i)+'].Customer.Shipping_address.Country_Code'),3));
            mFirmOffice.GetMonikerForFieldCode(mFirmOffice.GetFieldCode('Address_ID')).BusinessObject.SetFieldValueAsString('PhoneNumber1',Trim(mXMLHead.getElementAsString('Order['+inttostr(i)+'].Customer.Phone')));

            mFirmOffice.GetMonikerForFieldCode(mFirmOffice.GetFieldCode('Address_ID')).BusinessObject.SetFieldValueAsString('Email',Trim(mXMLHead.getElementAsString('Order['+inttostr(i)+'].Customer.Email')));
            mFirmOffice.GetMonikerForFieldCode(mFirmOffice.GetFieldCode('ElectronicAddress_ID')).BusinessObject.SetFieldValueAsString('Email',Trim(mXMLHead.getElementAsString('Order['+inttostr(i)+'].Customer.Email')));
            //mFirmOffice.GetMonikerForFieldCode(mFirmOffice.GetFieldCode('Address_ID')).BusinessObject.SetFieldValueAsString('PhoneNumber2',mXMLHead.getElementAsString('Zakaznik.mobil'));
            mFirmOffice_ID := mFirmOffice.OID;
            mFirm.Save;
            AResult :=AResult+('NewFirmOffice:'+mFirmOffice_ID+'#');
            Logs.Add(DateTimeToStr(Now)+' - Vytvořena nová provozovna - '+mFirmOffice_ID);
          end;
        Logs.Add(DateTimeToStr(Now)+' - Provozovna -  '+mFirmOffice_ID);

        mFirm.Free;
        mColl.Free;
        end; //konec provozovny

        Logs.Add(DateTimeToStr(Now)+' - Vyplňuji firmu');
        if IsFirm then begin
          if not (mReceivedOrderBO.GetFieldValueAsString('Firm_ID.VATIdentNumber') = UpperCase(Trim(mXMLHead.getElementAsString('Order['+inttostr(i)+'].Customer.Billing_Address.Vat_Id')))) then begin
            mFirm:= OS.CreateObject(Class_Firm);
            mFirm.Load(mFirm_ID,nil);
            mFirm.SetFieldValueAsString('VATIdentNumber', UpperCase(Trim(mXMLHead.getElementAsString('Order['+inttostr(i)+'].Customer.Billing_Address.Vat_Id'))));
            mFirm.Save;
            mFirm.Free;
          end;
          mReceivedOrderBO.SetFieldValueAsString('Firm_ID',mFirm_ID);
          mReceivedOrderBO.SetFieldValueAsString('FirmOffice_ID',mFirmOffice_ID);
          end
        else
          begin
          mReceivedOrderBO.SetFieldValueAsString('Firm_ID','1NI0000101');
          mReceivedOrderBO.SetFieldValueAsString('X_ZAK_EMAIL',Nxleft(mXMLHead.getElementAsString('Order['+inttostr(i)+'].Customer.Email'),200));
          mReceivedOrderBO.SetFieldValueAsString('X_ZAK_PHONE',Nxleft(mXMLHead.getElementAsString('Order['+inttostr(i)+'].Customer.Phone'),30));
          mReceivedOrderBO.SetFieldValueAsString('X_ZAK_NAZEV',Nxleft(mXMLHead.getElementAsString('Order['+inttostr(i)+'].Customer.Billing_Address.Name'),40));
          mReceivedOrderBO.SetFieldValueAsString('X_ZAK_ULICE',NxLeft(mXMLHead.getElementAsString('Order['+inttostr(i)+'].Customer.Billing_Address.Street'),40));
          mReceivedOrderBO.SetFieldValueAsString('X_ZAK_MESTO',NxLeft(mXMLHead.getElementAsString('Order['+inttostr(i)+'].Customer.Billing_Address.City'),40));
          mReceivedOrderBO.SetFieldValueAsString('X_ZAK_PSC',NxLeft(mXMLHead.getElementAsString('Order['+inttostr(i)+'].Customer.Billing_Address.Zip'),10));
          mReceivedOrderBO.SetFieldValueAsString('X_ZAK_STAT',NxLeft(mXMLHead.getElementAsString('Order['+inttostr(i)+'].Customer.Billing_Address.Country'),30));
          mReceivedOrderBO.SetFieldValueAsString('X_ZAK_STAT_KOD',NxLeft(mXMLHead.getElementAsString('Order['+inttostr(i)+'].Customer.Billing_Address.Country_Code'),3));

           if not(NxsearchReplace(mXMLHead.getElementAsString('Order['+inttostr(i)+'].Customer.Billing_Address.Zip'),' ','',[srAll])=NxsearchReplace(mXMLHead.getElementAsString('Order['+inttostr(i)+'].Customer.shipping_Address.Zip'),' ','',[srAll])) then begin
            mReceivedOrderBO.SetFieldValueAsString('X_ZAK_NAZEV_DOD',NxLeft(mXMLHead.getElementAsString('Order['+inttostr(i)+'].Customer.shipping_Address.Name'),40));
            mReceivedOrderBO.SetFieldValueAsString('X_ZAK_ULICE_DOD',NxLeft(mXMLHead.getElementAsString('Order['+inttostr(i)+'].Customer.shipping_Address.Street'),40));
            mReceivedOrderBO.SetFieldValueAsString('X_ZAK_MESTO_DOD',NxLeft(mXMLHead.getElementAsString('Order['+inttostr(i)+'].Customer.shipping_Address.City'),40));
            mReceivedOrderBO.SetFieldValueAsString('X_ZAK_PSC_DOD',NxLeft(mXMLHead.getElementAsString('Order['+inttostr(i)+'].Customer.shipping_Address.Zip'),10));
            mReceivedOrderBO.SetFieldValueAsString('X_ZAK_STAT_DOD',NxLeft(mXMLHead.getElementAsString('Order['+inttostr(i)+'].Customer.shipping_Address.Country'),30));
            mReceivedOrderBO.SetFieldValueAsString('X_ZAK_STAT_KOD_DOD',NxLeft(mXMLHead.getElementAsString('Order['+inttostr(i)+'].Customer.shipping_Address.Country_Code'),3));

          end;
        end;
        Logs.Add(DateTimeToStr(Now)+' - Vyplňuji externí číslo');
        mReceivedOrderBO.SetFieldValueAsString('ExternalNumber', mOrderCode);
        mReceivedOrderBO.SetFieldValueAsString('X_CustomerNote', mXMLHead.getElementAsString('Order['+inttostr(i)+'].Remark'));
        if IsFirm then begin
          if (mReceivedOrderBO.GetFieldValueAsString('Firm_ID.VatCountry_ID') = '00000SK000') then begin
            mReceivedOrderBO.SetFieldValueAsInteger('TradeType', 2);
            mReceivedOrderBO.SetFieldValueAsString('Country_ID', '00000SK000');
          end
          else begin
            if (mReceivedOrderBO.GetFieldValueAsString('FirmOffice_ID.Address_ID.Country') = 'Slovensko') then begin
              mReceivedOrderBO.SetFieldValueAsInteger('TradeType',7);
              mReceivedOrderBO.SetFieldValueAsString('Country_ID','00000SK000');
              mReceivedOrderBO.SetFieldValueAsString('VATCountry_ID','00000CZ000');
            end;
          end;
        end;

        if not IsFirm and ((mReceivedOrderBO.GetFieldValueAsString('X_ZAK_STAT') = 'Slovensko') or (mReceivedOrderBO.GetFieldValueAsString('X_ZAK_STAT_DOD') = 'Slovensko')) then begin
          mReceivedOrderBO.SetFieldValueAsInteger('TradeType',7);
          mReceivedOrderBO.SetFieldValueAsString('Country_ID','00000SK000');
          mReceivedOrderBO.SetFieldValueAsString('VATCountry_ID','00000CZ000');
        end;

        //Logs.Add(DateTimeToStr(Now)+' - Vyplňuji var symbol');
        //mReceivedOrderBO.SetFieldValueAsString('X_VarSymbol',mOrderCode);
        Logs.Add(DateTimeToStr(Now)+' - Vyplňuji období');
        mReceivedOrderBO.SetFieldValueAsString('Period_ID',ScrGetPeriod_ID(OS,trunc(CFxDate.StrToDateEx(NxLeft(mXMLHead.getElementAsString('Order['+inttostr(i)+'].Date'),10),'yyyy-mm-dd','-'))));
        Logs.Add(DateTimeToStr(Now)+' - Vyplňuji datum');
        mReceivedOrderBO.SetFieldValueAsDateTime('DocDate$DATE',CFxDate.StrToDateEx(NxLeft(mXMLHead.getElementAsString('ORDER['+inttostr(i)+'].Date'),10),'yyyy-mm-dd','-'));
        Logs.Add(DateTimeToStr(Now)+' - Vyplňuji měnu');
        mReceivedOrderBO.SetFieldValueAsString('Currency_ID', scrCurrency_ID(OS,'Code', Trim(mXMLHead.getElementAsString('ORDER['+inttostr(i)+'].Currency.Code'))));

        mReceivedOrderBO.SetFieldValueAsString('BankAccount_ID','1700000101'); //FIO CZK

        //pokud je měna EUR, vyplnit EUR účet - požadavek Radim v mailu 20.3.2023
        if mReceivedOrderBo.GetFieldValueAsString('Currency_ID') = '0000EUR000' then
          mReceivedOrderBO.SetFieldValueAsString('BankAccount_ID','1500000101'); //FIO EUR

        //začátek řádků
        for j:=0 to  mXMLHead.getElementsCountInArray('Order['+inttostr(i)+'].Order_Items.Item')-1 do begin
           if mXMLHead.getElementAsString('Order['+inttostr(i)+'].Order_Items.Item['+inttostr(j)+'].type') = 'product' then begin
             mStoreCard_ID:= scrStoreCard_ID(OS,'X_Eshop_Code', Trim(mXMLHead.getElementAsString('Order['+inttostr(i)+'].Order_Items.Item['+inttostr(j)+'].Code')));
             if NxIsEmptyOID(mStoreCard_ID) then mStoreCard_ID:= scrStoreCard_ID(OS,'Code', Trim(mXMLHead.getElementAsString('Order['+inttostr(i)+'].Order_Items.Item['+inttostr(j)+'].Code')));
               if not(NxIsEmptyOID(mStoreCard_ID)) then begin
                 mRows:=mReceivedOrderBO.GetCollectionMonikerForFieldCode(mReceivedOrderBO.getfieldcode('Rows'));
                 mReceivedOrderRowBO:=mRows.AddNewObject;
                 mReceivedOrderRowBO.SetFieldValueAsInteger('RowType',3);
                 mReceivedOrderRowBO.SetFieldValueAsString('StoreCard_ID',mStoreCard_ID);
                 mReceivedOrderRowBO.SetFieldValueAsString('Store_ID',cStoreID);
                 mReceivedOrderRowBO.SetFieldValueAsString('Division_ID',cDivisionID);
                 mReceivedOrderRowBO.SetFieldValueAsString('VatRate_ID',VatRate_ID(OS,mReceivedOrderBO.GetFieldValueAsString('Country_ID'),mXMLHead.getElementAsString('Order['+inttostr(i)+'].Order_Items.Item['+inttostr(j)+'].Unit_Price.VAT_Rate')));
                 mReceivedOrderRowBO.SetFieldValueAsFloat('Quantity',NxIBStrToFloat(mXMLHead.getElementAsString('Order['+inttostr(i)+'].Order_Items.Item['+inttostr(j)+'].Amount')));
                 mReceivedOrderRowBO.SetFieldValueAsString('Qunit',mXMLHead.getElementAsString('Order['+inttostr(i)+'].Order_Items.Item['+inttostr(j)+'].Unit'));
                 //OutputDebugString('Cena z eshopu: ' +mXMLHead.getElementAsString('Order['+inttostr(i)+'].Order_Items.Item['+inttostr(j)+'].Unit_Price.Without_VAT'));

                 mReceivedOrderRowBO.SetFieldValueAsFloat('UnitPrice',NxIBStrToFloat(mXMLHead.getElementAsString('Order['+inttostr(i)+'].Order_Items.Item['+inttostr(j)+'].Unit_Price.Without_VAT')));
                 //OutputDebugString('Cena UnitPrice: ' + FloatToStr(NxIBStrToFloat(mXMLHead.getElementAsString('Order['+inttostr(i)+'].Order_Items.Item['+inttostr(j)+'].Unit_Price.Without_VAT'))));
                 if mReceivedOrderBO.GetFieldValueAsString('Firm_ID.VatCountry_ID') = '00000SK000' then begin
                    mReceivedOrderRowBO.SetFieldValueAsBoolean('ToESL', true);
                    mReceivedOrderRowBO.SetFieldValueAsString('ESLIndicator_ID','1000000000');
                    mReceivedOrderRowBO.SetFieldValueAsString('VatRate_ID', '00000X0000');
                 end;
               End
               else begin
                //pokud nenajdu kartu, zakládám novou
                Logs.Add(DateTimeToStr(Now)+' - skladová karta nenalezena -' + Trim(mXMLHead.getElementAsString('Order['+inttostr(i)+'].Order_Items.Item['+inttostr(j)+'].code')));
                try
                  mStoreCardBO:= OS.CreateObject(Class_StoreCard);
                  mStoreCardBO.New;
                  mStoreCardBO.Prefill;
                  mStoreCardBO.SetFieldValueAsString('Name', Nxleft('lll ' + Trim(mXMLHead.getElementAsString('Order['+inttostr(i)+'].Order_Items.Item['+inttostr(j)+'].Name'))+' '+Trim(mXMLHead.getElementAsString('Order['+inttostr(i)+'].Order_Items.Item['+inttostr(j)+'].Variant_Name')),100));
                  mStoreCardBO.SetFieldValueAsString('X_Eshop_Code', Nxleft(Trim(mXMLHead.getElementAsString('Order['+inttostr(i)+'].Order_Items.Item['+inttostr(j)+'].Code')),40));
                  mStoreCardBO.SetFieldValueAsString('X_Eshop_Name', Nxleft(Trim(mXMLHead.getElementAsString('Order['+inttostr(i)+'].Order_Items.Item['+inttostr(j)+'].Name')),200));
                  mStoreCardBO.SetFieldValueAsFloat('X_Eshop_Price', NxIBStrToFloat(mXMLHead.getElementAsString('Order['+inttostr(i)+'].Order_Items.Item['+inttostr(j)+'].Unit_Price.With_VAT')));
                  mStoreCardBO.SetFieldValueAsString('StorecardCategory_ID', '1100000101');
                  mStoreCardBO.SetFieldValueAsInteger('Category',0);
                  mStoreCardBO.SetFieldValueAsString('Country_ID','00000CZ000');
                  //pokud je v názvu Makita, tak přidat do skladového menu EME Makita Eshop
                  if NxSearch(mStoreCardBO.GetFieldValueAsString('Name'),'makita',[srAll],0)>0 then begin
                    mStoreCardBO.SetFieldValueAsString('StoreMenuItem_ID', '1F10000101');    // EME Makita eshop
                  end;


                  try
                    AStream:= TMemoryStream.Create;
                    mXMLHead2:= TNxScriptingXMLWrapper.Create;
                    mProductCode:=  mXMLHead.getElementAsString('Order['+inttostr(i)+'].Order_Items.Item['+inttostr(j)+'].Code');
                    //CFxInternet.HTTPGetBinary('https://www.fepro.cz/export/productsComplete.xml?patternId=-5&hash=56f2e788ffb453cb8cbf3fc53cd61d81f72afc4fdaacf456ecffde9dc0d717c3&code='+mProductCode,'',AStream);
                    CFxInternet.HTTPGetBinary('https://www.fepro.cz/export/productsComplete.xml?patternId=-5&partnerId=8&hash=033602d34e42170e8a27ddaeab20b9cfd8206ce34f0a0021f9351b43256c1fe5&code='+mProductCode,'',AStream);
                    mXMLHead2.loadFromStream(Astream);
                    for a:= 0 to mXMLHead2.getElementsCountInArray('SHOPITEM') - 1 do begin
                      if ElementExists(mXMLHead2,'SHOPITEM['+inttostr(a)+'].VARIANTS.VARIANT[0].Code') then begin
                        for e:= 0 to mXMLHead2.getElementsCountInArray('SHOPITEM['+inttostr(a)+'].VARIANTS.VARIANT') - 1 do begin
                          if mXMLHead2.getElementAsString('SHOPITEM['+inttostr(a)+'].VARIANTS.VARIANT['+inttostr(e)+'].CODE') = mProductCode then begin
                            mEAN:= mXMLHead2.getElementAsString('SHOPITEM['+inttostr(a)+'].VARIANTS.VARIANT['+inttostr(e)+'].EAN');
                            mVAT:= mXMLHead2.getElementAsString('SHOPITEM['+inttostr(a)+'].VARIANTS.VARIANT['+inttostr(e)+'].VAT');
                            if NxLeft(mEAN,2) = '00' then mEAN:= Trim(NxRight(mEAN, Length(mEAN)-1));
                          end;
                        end;
                      end
                      else begin
                        if mXMLHead2.getElementAsString('SHOPITEM['+inttostr(a)+'].CODE') = mProductCode then begin
                          if ElementExists(mXMLHead2,'SHOPITEM['+inttostr(a)+'].EAN') then
                            mEAN:= mXMLHead2.getElementAsString('SHOPITEM['+inttostr(a)+'].EAN');
                          mVAT:= mXMLHead2.getElementAsString('SHOPITEM['+inttostr(a)+'].VAT');
                          if NxLeft(mEAN,2) = '00' then mEAN:= Trim(NxRight(mEAN, Length(mEAN)-1));
                        end;
                      end;
                    end;
                    AStream.Free;
                    mXMLHead2.Free;
                  except
                    //ShowMessage('Nepodařilo se stáhnout data ke kartě pro uložení EAN: '+ExceptionMessage);
                    Logs.Add(DateTimeToStr(Now)+' - Nepodařilo se stáhnout data ke kartě pro uložení EAN: '+ExceptionMessage);
                  end;
                  if not NxIsBlank(mEAN) then begin
                    mEAN_ID:= SQLSingleSelect(OS, 'SELECT ID FROM StoreEANS WHERE EAN = '+QuotedStr(mEAN));
                  end;

                  mVATRate_ID:= VatRate_ID(OS,'0000CZ000', mVAT);
                  if not NxIsEmptyOID(mVATRate_ID) then
                    mStoreCardBO.SetFieldValueAsString('VATRate_ID',mVATRate_ID)
                  else
                    mStoreCardBO.SetFieldValueAsString('VATRate_ID','02100X0000');

                  //jednotka
                  mMon:= mStoreCardBO.GetCollectionMonikerForFieldCode(mStoreCardBO.GetfieldCode('StoreUnits'));
                  mMon.RemoveAll;
                  mStoreUnits:=  mMon.AddNewObject;
                  mStoreUnits.SetFieldValueAsString('Code',NxLeft(mXMLHead.getElementAsString('Order['+inttostr(i)+'].Order_Items.Item['+inttostr(j)+'].Unit'),5));
                  if not NxIsBlank(mEAN) and NxIsEmptyOID(mEAN_ID) then
                    mStoreUnits.SetFieldValueAsString('EAN', mEAN);
                  mStoreUnits.SetFieldValueAsFloat('UnitRate',1);
                  mStoreUnits.SetFieldValueAsFloat('Weight', NxIBStrToFloat(mXMLHead.getElementAsString('Order['+inttostr(i)+'].Order_Items.Item['+inttostr(j)+'].Weight')));
                  mStoreCardBO.SetFieldValueAsString('MainUnitCode',mXMLHead.getElementAsString('Order['+inttostr(i)+'].Order_Items.Item['+inttostr(j)+'].Unit'));

                  mStoreCardBO.Save;
                  mStoreCard_ID:= mStoreCardBO.OID;

                  //vytvoření dodavatele ke skladové kartě

                  //pokud je Makita, tak není podle prefixu, ale podle slova Makita v názvu karty
                  if NxSearch(mXMLHead.getElementAsString('Order['+inttostr(i)+'].Order_Items.Item['+inttostr(j)+'].Name'),'makita',[srAll],0)>0 then begin
                    mFirm_ID:= '1J30000101';      //Makita
                    mEshopStoreCardCode:= Trim(mXMLHead.getElementAsString('Order['+inttostr(i)+'].Order_Items.Item['+inttostr(j)+'].Code'));
                    mQUnit:= mXMLHead.getElementAsString('Order['+inttostr(i)+'].Order_Items.Item['+inttostr(j)+'].Unit');
                    if not NxIsBlank(mEshopStoreCardCode) then begin
                      UpdateOrCreateSupplier(mStoreCard_ID, mFirm_ID, mEshopStoreCardCode, mQUnit,'', OS);
                    end;
                  end;

                  //ostatní jsou podle prefixu
                  mEshopStoreCardCode:= Trim(mXMLHead.getElementAsString('Order['+inttostr(i)+'].Order_Items.Item['+inttostr(j)+'].Code'));
                  mEshopPrefix:=Copy(mEshopStoreCardCode,0,3);
                  mQUnit:= mXMLHead.getElementAsString('Order['+inttostr(i)+'].Order_Items.Item['+inttostr(j)+'].Unit');
                  mSupplier_ID:= SQLSingleSelect(OS, 'SELECT ID FROM Firms WHERE Hidden=''N'' and Firm_ID is null and X_Eshop_Prefix = '+QuotedStr(mEshopPrefix));
                  if not NxIsEmptyOID(mStoreCard_ID) and not NxIsEmptyOID(mSupplier_ID) then UpdateOrCreateSupplier(mStoreCard_ID, mSupplier_ID, NxRight(mEshopStoreCardCode,Length(mEshopStoreCardCode)-3), mQUnit,'', OS);

                  Logs.Add(DateTimeToStr(Now)+' - Založena nová skladová karta - ' + Trim(mXMLHead.getElementAsString('Order['+inttostr(i)+'].Order_Items.Item['+inttostr(j)+'].code')));
                  if not(NxIsEmptyOID(mStoreCard_ID)) then begin
                    mRows:=mReceivedOrderBO.GetCollectionMonikerForFieldCode(mReceivedOrderBO.getfieldcode('Rows'));
                    mReceivedOrderRowBO:=mRows.AddNewObject;
                    mReceivedOrderRowBO.SetFieldValueAsInteger('RowType',3);
                    mReceivedOrderRowBO.SetFieldValueAsString('StoreCard_ID',mStoreCard_ID);
                    mReceivedOrderRowBO.SetFieldValueAsString('Store_ID',cStoreID);
                    mReceivedOrderRowBO.SetFieldValueAsString('Division_ID',cDivisionID);
                    mReceivedOrderRowBO.SetFieldValueAsString('VatRate_ID',VatRate_ID(OS,mReceivedOrderBO.GetFieldValueAsString('Country_ID'),mXMLHead.getElementAsString('Order['+inttostr(i)+'].Order_Items.Item['+inttostr(j)+'].Unit_Price.VAT_Rate')));
                    mReceivedOrderRowBO.SetFieldValueAsFloat('Quantity',NxIBStrToFloat(mXMLHead.getElementAsString('Order['+inttostr(i)+'].Order_Items.Item['+inttostr(j)+'].Amount')));
                    mReceivedOrderRowBO.SetFieldValueAsString('Qunit',mXMLHead.getElementAsString('Order['+inttostr(i)+'].Order_Items.Item['+inttostr(j)+'].Unit'));
                    mReceivedOrderRowBO.SetFieldValueAsFloat('UnitPrice',NxIBStrToFloat(mXMLHead.getElementAsString('Order['+inttostr(i)+'].Order_Items.Item['+inttostr(j)+'].Unit_Price.Without_VAT')));
                    if mReceivedOrderBO.GetFieldValueAsString('Firm_ID.VatCountry_ID') = '00000SK000' then begin
                      mReceivedOrderRowBO.SetFieldValueAsBoolean('ToESL', true);
                      mReceivedOrderRowBO.SetFieldValueAsString('ESLIndicator_ID','1000000000');
                      mReceivedOrderRowBO.SetFieldValueAsString('VatRate_ID', '00000X0000');
                    end;
                  End;
                except
                  Logs.Add(DateTimeToStr(Now)+' - Při pokusu o vytvoření nové skladové karty došlo k chybě - ' + Trim(mXMLHead.getElementAsString('Order['+inttostr(i)+'].Order_Items.Item['+inttostr(j)+'].code')));
                  Logs.Add(DateTimeToStr(Now)+' '+ ExceptionMessage);
                  mReceivedOrderBO.SetFieldValueAsBoolean('X_IsImportError', True);
                  mReceivedOrderBO.SetFieldValueAsString('X_ImportErrors',mReceivedOrderBO.GetFieldValueAsString('X_ImportErrors')+ DateTimeToStr(Now)+' - Při pokusu o vytvoření nové skladové karty došlo k chybě -' + Trim(mXMLHead.getElementAsString('Order['+inttostr(i)+'].Order_Items.Item['+inttostr(j)+'].code')) +#13#10 );
                end;
                end;
             end;

             // doprava
             if (mXMLHead.getElementAsString('Order['+inttostr(i)+'].Order_Items.Item['+inttostr(j)+'].type') = 'shipping') and (NxIBStrToFloat(mXMLHead.getElementAsString('Order['+inttostr(i)+'].Order_Items.Item['+inttostr(j)+'].Unit_price.With_vat')) >0) then begin
               mRows:=mReceivedOrderBO.GetCollectionMonikerForFieldCode(mReceivedOrderBO.getfieldcode('Rows'));
               mReceivedOrderRowBO:=mRows.AddNewObject;
               mReceivedOrderRowBO.SetFieldValueAsInteger('RowType',3);
               mReceivedOrderRowBO.SetFieldValueAsString('StoreCard_ID','4BE0000101');
               mReceivedOrderRowBO.SetFieldValueAsString('Store_ID',cStoreID);
               mReceivedOrderRowBO.SetFieldValueAsString('Division_ID',cDivisionID);
               mReceivedOrderRowBO.SetFieldValueAsString('VatRate_ID',VatRate_ID(OS,mReceivedOrderBO.GetFieldValueAsString('Country_ID'),mXMLHead.getElementAsString('Order['+inttostr(i)+'].Order_Items.Item['+inttostr(j)+'].Unit_Price.VAT_Rate')));
               mReceivedOrderRowBO.SetFieldValueAsFloat('Quantity',NxIBStrToFloat(mXMLHead.getElementAsString('Order['+inttostr(i)+'].Order_Items.Item['+inttostr(j)+'].Amount')));
               mReceivedOrderRowBO.SetFieldValueAsString('Qunit','ks');
               mReceivedOrderRowBO.SetFieldValueAsFloat('UnitPrice',NxIBStrToFloat(mXMLHead.getElementAsString('Order['+inttostr(i)+'].Order_Items.Item['+inttostr(j)+'].Unit_Price.Without_VAT')));
               if mReceivedOrderBO.GetFieldValueAsString('Firm_ID.VatCountry_ID') = '00000SK000' then begin
                  mReceivedOrderRowBO.SetFieldValueAsBoolean('ToESL', true);
                  mReceivedOrderRowBO.SetFieldValueAsString('ESLIndicator_ID','1000000000');
                  mReceivedOrderRowBO.SetFieldValueAsString('VatRate_ID', '00000X0000');
               end;
             end;

             //platba
             if (mXMLHead.getElementAsString('Order['+inttostr(i)+'].Order_Items.Item['+inttostr(j)+'].type') = 'billing') and (NxIBStrToFloat(mXMLHead.getElementAsString('Order['+inttostr(i)+'].Order_Items.Item['+inttostr(j)+'].Unit_price.With_vat')) >0) then begin
               mRows:=mReceivedOrderBO.GetCollectionMonikerForFieldCode(mReceivedOrderBO.getfieldcode('Rows'));
               mReceivedOrderRowBO:=mRows.AddNewObject;
               mReceivedOrderRowBO.SetFieldValueAsInteger('RowType',3);
               mReceivedOrderRowBO.SetFieldValueAsString('StoreCard_ID','1L21000101');
               mReceivedOrderRowBO.SetFieldValueAsString('Store_ID',cStoreID);
               mReceivedOrderRowBO.SetFieldValueAsString('Division_ID',cDivisionID);
               mReceivedOrderRowBO.SetFieldValueAsString('VatRate_ID',VatRate_ID(OS,mReceivedOrderBO.GetFieldValueAsString('Country_ID'),mXMLHead.getElementAsString('Order['+inttostr(i)+'].Order_Items.Item['+inttostr(j)+'].Unit_Price.VAT_Rate')));
               mReceivedOrderRowBO.SetFieldValueAsFloat('Quantity',NxIBStrToFloat(mXMLHead.getElementAsString('Order['+inttostr(i)+'].Order_Items.Item['+inttostr(j)+'].Amount')));
               mReceivedOrderRowBO.SetFieldValueAsString('Qunit','ks');
               mReceivedOrderRowBO.SetFieldValueAsFloat('UnitPrice',NxIBStrToFloat(mXMLHead.getElementAsString('Order['+inttostr(i)+'].Order_Items.Item['+inttostr(j)+'].Unit_Price.Without_VAT')));
               if mReceivedOrderBO.GetFieldValueAsString('Firm_ID.VatCountry_ID') = '00000SK000' then begin
                  mReceivedOrderRowBO.SetFieldValueAsBoolean('ToESL', true);
                  mReceivedOrderRowBO.SetFieldValueAsString('ESLIndicator_ID','1000000000');
                  mReceivedOrderRowBO.SetFieldValueAsString('VatRate_ID', '00000X0000');
               end;
             end;

             //slevové kupony
             if (mXMLHead.getElementAsString('Order['+inttostr(i)+'].Order_Items.Item['+inttostr(j)+'].type') = 'discount') then begin
               mRows:=mReceivedOrderBO.GetCollectionMonikerForFieldCode(mReceivedOrderBO.getfieldcode('Rows'));
               mReceivedOrderRowBO:=mRows.AddNewObject;
               mReceivedOrderRowBO.SetFieldValueAsInteger('RowType',1);
               mReceivedOrderRowBO.SetFieldValueAsString('Text', mXMLHead.getElementAsString('Order['+inttostr(i)+'].Order_Items.Item['+inttostr(j)+'].Name'));
               mReceivedOrderRowBO.SetFieldValueAsString('Division_ID',cDivisionID);
               mReceivedOrderRowBO.SetFieldValueAsString('VatRate_ID',VatRate_ID(OS,mReceivedOrderBO.GetFieldValueAsString('Country_ID'),mXMLHead.getElementAsString('Order['+inttostr(i)+'].Order_Items.Item['+inttostr(j)+'].Total_Price.VAT_Rate')));
               mReceivedOrderRowBO.SetFieldValueAsFloat('TotalPrice',NxIBStrToFloat(mXMLHead.getElementAsString('Order['+inttostr(i)+'].Order_Items.Item['+inttostr(j)+'].Total_Price.Without_VAT')));
               if mReceivedOrderBO.GetFieldValueAsString('Firm_ID.VatCountry_ID') = '00000SK000' then begin
                  mReceivedOrderRowBO.SetFieldValueAsBoolean('ToESL', true);
                  mReceivedOrderRowBO.SetFieldValueAsString('ESLIndicator_ID','1000000000');
                  mReceivedOrderRowBO.SetFieldValueAsString('VatRate_ID', '00000X0000');
               end;
             end;

             if (mXMLHead.getElementAsString('Order['+inttostr(i)+'].Order_Items.Item['+inttostr(j)+'].type') = 'shipping') then begin
                Logs.Add(DateTimeToStr(Now)+' - Hledání způsobu dopravy');
                mTransportationType_ID:= scrTransportationType_ID(OS, 'X_Eshop_Name',mXMLHead.getElementAsString('Order['+inttostr(i)+'].Order_Items.Item['+inttostr(j)+'].code'));
                if not NxIsEmptyOID(mTransportationType_ID) then begin
                  mReceivedOrderBO.SetFieldValueAsString('TransportationType_ID',mTransportationType_ID);
                end
                else begin
                  Logs.Add(DateTimeToStr(Now)+' pro objednávku '+mOrderCode+' nenalezen způsob dopravy');
                  mReceivedOrderBO.SetFieldValueAsBoolean('X_IsImportError', True);
                  mReceivedOrderBO.SetFieldValueAsString('X_ImportErrors',mReceivedOrderBO.GetFieldValueAsString('X_ImportErrors')+ DateTimeToStr(Now)+' - Chyba ve způsobu dopravy - '+mXMLHead.getElementAsString('Order['+inttostr(i)+'].Order_Items.Item['+inttostr(j)+'].name') +#13#10 );
                end;
                mDeliveryPointID:= '';
                case mTransportationType_ID of
                  '2000000101': mDeliveryPointID:= mXMLHead.getElementAsString('Order['+inttostr(i)+'].ZASILKOVNA_ID');
                  '2120000101': mDeliveryPointID:= mXMLHead.getElementAsString('Order['+inttostr(i)+'].CESKA_POSTA_ID');
                  '1100000101': mDeliveryPointID:= Copy(mXMLHead.getElementAsString('Order['+inttostr(i)+'].GLS_SERVICE'),5,Length(mXMLHead.getElementAsString('Order['+inttostr(i)+'].GLS_SERVICE'))-5);
                  '2150000101': mDeliveryPointID:= Copy(mXMLHead.getElementAsString('Order['+inttostr(i)+'].PPL_SMART'),0,NxCharPos(' ', mXMLHead.getElementAsString('Order['+inttostr(i)+'].PPL_SMART'))-1);
                end;

                //Result := Copy(InputStr, StartIndex + 1, EndIndex - StartIndex - 1);

                if not NxIsBlank(mDeliveryPointID) then
                  mReceivedOrderBO.SetFieldValueAsString('X_LP_DeliveryPointID',mDeliveryPointID);
             end;

             if (mXMLHead.getElementAsString('Order['+inttostr(i)+'].Order_Items.Item['+inttostr(j)+'].type') = 'billing') then begin
                Logs.Add(DateTimeToStr(Now)+' - Hledání způsobu platby');
                Logs.Add(DateTimeToStr(Now)+' - ' + (mXMLHead.getElementAsString('Order['+inttostr(i)+'].Order_Items.Item['+inttostr(j)+'].code')));
                mPaymentType_ID:= scrPaymentType_ID(OS, 'X_Eshop_Name',(mXMLHead.getElementAsString('Order['+inttostr(i)+'].Order_Items.Item['+inttostr(j)+'].code')));
                Logs.Add(DateTimeToStr(Now)+' - '+ mPaymentType_ID);
                if not NxIsEmptyOID(mPaymentType_ID) then begin
                  mReceivedOrderBO.SetFieldValueAsString('PaymentType_ID',mPaymentType_ID);
                end
                else begin
                  Logs.Add(DateTimeToStr(Now)+' pro objednávku '+mOrderCode+' nenalezen způsob úhrady');
                  mReceivedOrderBO.SetFieldValueAsBoolean('X_IsImportError', True);
                  mReceivedOrderBO.SetFieldValueAsString('X_ImportErrors',mReceivedOrderBO.GetFieldValueAsString('X_ImportErrors')+ DateTimeToStr(Now)+' - Chyba ve způsobu dopravy - '+mXMLHead.getElementAsString('Order['+inttostr(i)+'].Order_Items.Item['+inttostr(j)+'].name') +#13#10 );
               end;
             end;
             if mReceivedOrderBO.GetFieldValueAsString('PaymentType_ID') = '1200000101' then
                mReceivedOrderBO.SetFieldValueAsInteger('X_DruhDokladu',2)
             else
                mReceivedOrderBO.SetFieldValueAsInteger('X_DruhDokladu',0);

        end; //konec řádků
        Logs.Add(DateTimeToStr(Now)+' - řádky vloženy');

        Logs.Add(DateTimeToStr(Now)+' - Pokus o uložení objednávky');
        mReceivedOrderBO.save;
        //UpdateState(OS,mOrderCode);   //změna stavu objednávky v eshopu
        AResult :=AResult+('id_eshop:'+mOrderCode+'|id_abra:'+mReceivedOrderBO.oid+'#');
        Logs.Add(DateTimeToStr(Now)+' - Objednávka úspěšně uložena - id_eshop:'+mOrderCode+'|id_abra:'+mReceivedOrderBO.oid);
        mReceivedOrderBO.free;
    End; // konec zadávání objednávky
    //Result:=Aresult;
    Logs.Add(DateTimeToStr(Now)+' - Ukončení importu');
    Logs.Add(NxReplicate('_',50));

    except
      Logs.Add(DateTimeToStr(Now)+' - Nespecifikovaná chyba!');
      mReceivedOrderBO.GetValidateErrors(Errors);
      Logs.AddStrings(Errors);
      Logs.Add(DateTimeToStr(Now)+' '+ ExceptionMessage);
      if cLogs then begin
        DateTimeToString(mDate,'YYYY-MM-DD hh.nn.ss',Now);
        Logs.SaveToFile('\\SRV-ABRA\AbraGen\Logs\InsertOrder-'+mDate+'-log.txt',nil);
        //Result:=(Errors[0]);
      end;
      Result:= False;
    end;
 end; //konec cyklu
 if cLogs and (Logs.Count>0) then begin
   DateTimeToString(mDate,'YYYY-MM-DD hh.nn.ss',Now);
   Logs.SaveToFile('\\SRV-ABRA\AbraGen\Logs\InsertOrder-'+mDate+'-log.txt',nil);
 end;
end;



begin
end.