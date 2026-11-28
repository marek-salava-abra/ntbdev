uses
    'eu.abra.eshop.const', 'eu.abra.eshop.fce';

function InsertPoukaz(Self: TNxWebServicesHelper; var XMLinput: String):String;
Var
 mXMLinput:string;
 mXMLHead : TNxScriptingXMLWrapper;
 mReceivedOrderBO, mReceivedOrderRowBO: TNxCustomBusinessObject;
 mFirm, mFirmOffice, mStoreCard: TNxCustomBusinessObject;
 mRows, mColl : TNxCustomBusinessMonikerCollection;
 mOS: TNxCustomObjectSpace;
 mFirm_ID, mFirmOffice_ID, mStoreCard_ID, mQuantity, mPrice, mFirmCode, mOrder_ID, mPeriod_ID: String;
 mr1:TstringList;
 mQuantityDouble, mPriceDouble :Double;
 mList:TStringList;
 i,j,d: integer;
 AResult:String;

begin
 Aresult:='';
 Result:='';
 mOS:=self.ObjectSpace;
 mXMLHead := TNxScriptingXMLWrapper.Create;
 //mXMLinput:=DecodeBase64(XMLInput);
 mList:=TStringList.Create;
 //ShowMessage(mXMLInput);
 mXMLHead.loadFromBytes(DecodeBase64(XMLinput));
 mXMLHead.saveToFile('C:\server\abra\AbraG2\xml\'+FormatDateTime('YYYYMMDDHHmmss',Now)+'.xml');
    for i:=0 to mXMLHead.getElementsCountInArray('order')-1 do begin
    //mPeriod_ID:='2U00000101';
    mPeriod_ID:=GetPeriod_ID(mOS,Date);
    mOrder_ID:=scrGetORder_ID(mOS,mXMLHead.getElementAsString('order['+inttostr(i)+'].orderdata.id'), mPeriod_ID);
    if NxIsBlank(mOrder_ID) then begin
    mFirm_ID:='';
    mFirmOffice_ID:='';
    mReceivedOrderBO:=mOS.CreateObject(Class_ReceivedOrder);
    mReceivedOrderBO.New;
    mReceivedOrderBO.Prefill;
    mReceivedOrderBO.SetFieldValueAsString('DocQueue_ID',cDocqueue_ID);
    if ElementExists(mXMLHead, 'order['+inttostr(i)+'].orderdata.doc_queue') then begin
     if not(NxIsEmptyOID(mXMLHead.getElementAsString('order['+inttostr(i)+'].orderdata.doc_queue'))) then
       mReceivedOrderBO.SetFieldValueAsString('DocQueue_ID',mXMLHead.getElementAsString('order['+inttostr(i)+'].orderdata.doc_queue'));
    end;
    mReceivedOrderBO.SetFieldValueAsString('X_ES_ID',mXMLHead.getElementAsString('order['+inttostr(i)+'].orderdata.id'));
    mReceivedOrderBO.SetFieldValueAsString('BankAccount_ID','1000000101');
    mReceivedOrderBO.SetFieldValueAsBoolean('VatDocument',True);
    mReceivedOrderBO.SetFieldValueAsBoolean('PricesWithVAT',False);
    if not(NxIsEmptyOID(mXMLHead.getElementAsString('order['+inttostr(i)+'].transport.System_ID'))) then mReceivedOrderBO.SetFieldValueAsString('TransportationType_ID',mXMLHead.getElementAsString('order['+inttostr(i)+'].transport.System_ID'));
    if not(NxIsEmptyOID(mXMLHead.getElementAsString('order['+inttostr(i)+'].payment.System_ID'))) then mReceivedOrderBO.SetFieldValueAsString('PaymentType_ID',mXMLHead.getElementAsString('order['+inttostr(i)+'].payment.System_ID'));
    if (mXMLHead.getElementAsString('order['+inttostr(i)+'].transport.Name')='DPD') then mReceivedOrderBO.SetFieldValueAsString('TransportationType_ID','1300000101');
    if (mXMLHead.getElementAsString('order['+inttostr(i)+'].transport.Name')='Česká pošta') then mReceivedOrderBO.SetFieldValueAsString('TransportationType_ID','00000P1000');
    if (StrToFloat(NxSearchReplace(mXMLHead.getElementAsString('order['+inttostr(i)+'].transport.Price'),'.',',',[srAll])) =0) then mReceivedOrderBO.SetFieldValueAsString('TransportationType_ID','00000O1000');

    {if mXMLHead.getElementsCountInArray('order['+inttostr(i)+'].invoicedata')>0 then begin
      if not(NxIsEmptyOID(mXMLHead.getElementAsString('order['+inttostr(i)+'].orderdata.firm_system_id'))) then mFirm_ID:=mXMLHead.getElementAsString('order['+inttostr(i)+'].orderdata.firm_system_id');
      // dohledávání dle názvu firmy
      //if NxIsEmptyOID(mFirm_ID) and not(NxIsBlank(Trim(mXMLHead.getElementAsString('order['+inttostr(i)+'].invoicedata.firm')))) then mFirm_ID:=scrFirm_ID(mOS,'Name', Trim(mXMLHead.getElementAsString('order['+inttostr(i)+'].invoicedata.firm')));
      if NxIsEmptyOID(mfirm_id) and not(nxisblank(Trim(mXMLHead.getElementAsString('order['+inttostr(i)+'].invoicedata.ic')))) then mFirm_ID:=scrFirm_ID(mOS,'OrgIdentNumber', Trim(mXMLHead.getElementAsString('order['+inttostr(i)+'].invoicedata.ic')));
      if NxIsEmptyOID(mfirm_id) and not(nxisblank(Trim(mXMLHead.getElementAsString('order['+inttostr(i)+'].invoicedata.dic')))) then mFirm_ID:=scrFirm_ID(mOS,'VatIdentNumber', Trim(mXMLHead.getElementAsString('order['+inttostr(i)+'].invoicedata.dic')));
      if NxIsEmptyOID(mFirm_ID) and not(nxisblank(Trim(mXMLHead.getElementAsString('order['+inttostr(i)+'].orderdata.email')))) then mFirm_ID:=GetFirmE_ID(mOS,Trim(mXMLHead.getElementAsString('order['+inttostr(i)+'].orderdata.email')));
      if NxIsEmptyOID(mFirm_ID) and not(NxIsBlank(Trim(mXMLHead.getElementAsString('order['+inttostr(i)+'].invoicedata.firm')))) then mFirm_ID:=scrFirm_ID(mOS,'Name', Trim(mXMLHead.getElementAsString('order['+inttostr(i)+'].invoicedata.firm')));
      if NxIsEmptyOID(mFirm_ID) and not(NxIsBlank(Trim(mXMLHead.getElementAsString('order['+inttostr(i)+'].invoicedata.name')+' '+mXMLHead.getElementAsString('order['+inttostr(i)+'].invoicedata.surname'))))
        then mFirm_ID:=scrFirm_ID(mOS,'Name', Trim(mXMLHead.getElementAsString('order['+inttostr(i)+'].invoicedata.name')+' '+mXMLHead.getElementAsString('order['+inttostr(i)+'].invoicedata.surname')));
    end;     }
    //dohledávání dle jsména a příjmení
    // dohledat firmu dle emailu 11.5.2021


    if NxIsEmptyOID(mfirm_id) then mFirm_ID:=scrFirm_ID(mOS,'X_BirthNumber', mXMLHead.getElementAsString('order['+inttostr(i)+'].orderdata.BirthNumber'));
    if NxIsEmptyOID(mFirm_ID) then begin
      mFirm:= mOS.CreateObject('4K3EXM5PQBCL35CH000ILPWJF4');
      mFirmOffice:= mOS.CreateObject('AT011EZZ5DFO115YJ1HCZJDXJ4');
       mFirm.New;
       mFirm.Prefill;
       if not(NxIsBlank(Trim(mXMLHead.getElementAsString('order['+inttostr(i)+'].invoicedata.firm')))) then mFirm.SetFieldValueAsString('name',Trim(mXMLHead.getElementAsString('order['+inttostr(i)+'].invoicedata.firm')));
       if (NxIsBlank(Trim(mXMLHead.getElementAsString('order['+inttostr(i)+'].invoicedata.firm')))) then mFirm.SetFieldValueAsString('Name',Trim(mXMLHead.getElementAsString('order['+inttostr(i)+'].invoicedata.name')+' '+mXMLHead.getElementAsString('order['+inttostr(i)+'].invoicedata.surname')));
       mFirm.SetFieldValueAsString('VatIdentNumber',Trim(mXMLHead.getElementAsString('order['+inttostr(i)+'].invoicedata.dic')));
       mFirm.SetFieldValueAsString('OrgIdentNumber',Trim(mXMLHead.getElementAsString('order['+inttostr(i)+'].invoicedata.ic')));
       mFirm.SetFieldValueAsString('X_BirthNumber',mXMLHead.getElementAsString('order['+inttostr(i)+'].orderdata.BirthNumber'));
       mFirm.GetMonikerForFieldCode(mFirm.GetFieldCode('ResidenceAddress_ID')).BusinessObject.SetFieldValueAsString('PostCode',Trim(mXMLHead.getElementAsString('order['+inttostr(i)+'].invoicedata.zip')));
       mFirm.GetMonikerForFieldCode(mFirm.GetFieldCode('ResidenceAddress_ID')).BusinessObject.SetFieldValueAsString('City',Trim(mXMLHead.getElementAsString('order['+inttostr(i)+'].invoicedata.city')));
       mFirm.GetMonikerForFieldCode(mFirm.GetFieldCode('ResidenceAddress_ID')).BusinessObject.SetFieldValueAsString('Street',AnsiLeftStr(Trim(mXMLHead.getElementAsString('order['+inttostr(i)+'].invoicedata.street')),60));
       mFirm.GetMonikerForFieldCode(mFirm.GetFieldCode('ResidenceAddress_ID')).BusinessObject.SetFieldValueAsString('PhoneNumber1',Trim(mXMLHead.getElementAsString('order['+inttostr(i)+'].invoicedata.tel')));
       mFirm.GetMonikerForFieldCode(mFirm.GetFieldCode('ElectronicAddress_ID')).BusinessObject.SetFieldValueAsString('Email',Trim(mXMLHead.getElementAsString('order['+inttostr(i)+'].orderdata.email')));
       //if not(NxIsEmptyOID(Trim(mXMLHead.getElementAsString('order['+inttostr(i)+'].orderdata.pricelist_id')))) then mFirm.SetFieldValueAsString('PriceList_ID',Trim(mXMLHead.getElementAsString('order['+inttostr(i)+'].orderdata.pricelist_id')));
       mfirm.Save;
       mFirm_ID:=mFirm.OID;
       mFirm.Free;
    end;
    if not(NxIsEmptyOID(mFirm_ID)) then begin
        if mXMLHead.getElementsCountInArray('order['+inttostr(i)+'].deliverydata')>0 then begin
         mFirm:= mOS.CreateObject('4K3EXM5PQBCL35CH000ILPWJF4');
         mFirmOffice:= mOS.CreateObject('AT011EZZ5DFO115YJ1HCZJDXJ4');
         mFirm.Load(mFirm_ID,nil);
         mColl := mFirm.GetLoadedCollectionMonikerForFieldCode(mFirm.GetfieldCode('FirmOffices'));
         if not(NxIsEmptyOID(mXMLHead.getElementAsString('order['+inttostr(i)+'].deliverydata.system_id'))) then mFirmOffice_ID:=mXMLHead.getElementAsString('order['+inttostr(i)+'].deliverydata.system_id');
           if (NxIsEmptyOID(mFirmOffice_ID)) and not(Trim(mXMLHead.getElementAsString('order['+inttostr(i)+'].deliverydata.name')+' '+mXMLHead.getElementAsString('order['+inttostr(i)+'].deliverydata.surname'))='') then begin

              for d:=0 to mColl.Count-1 do begin
               // if NxSearch(mcoll.BusinessObject[d].GetFieldValueAsString('Name'),Trim(mXMLHead.getElementAsString('order['+inttostr(i)+'].deliverydata.name')+' '+mXMLHead.getElementAsString('order['+inttostr(i)+'].deliverydata.surname')),[srAll],0)>0 then
                if NxSearch(UpperCase(mcoll.BusinessObject[d].GetFieldValueAsString('Address_ID.Street')),Trim(UpperCase(mXMLHead.getElementAsString('order['+inttostr(i)+'].deliverydata.street'))),[srAll],0)>0 then
                mFirmOffice_ID:=mcoll.BusinessObject[d].OID;

              end;
           end;
           if NxIsEmptyOID(mFirmOffice_ID) then begin
            mFirmOffice :=mColl.AddNewObject;
            if ElementExists(mXMLHead, 'order['+inttostr(i)+'].deliverydata.firm') then begin
             if NxIsBlank(Trim(mXMLHead.getElementAsString('order['+inttostr(i)+'].deliverydata.firm'))) then
              mFirmOffice.SetFieldValueAsString('Name', Trim(mXMLHead.getElementAsString('order['+inttostr(i)+'].deliverydata.name')+' '+mXMLHead.getElementAsString('order['+inttostr(i)+'].deliverydata.surname'))) else
              mFirmOffice.SetFieldValueAsString('Name', Trim(mXMLHead.getElementAsString('order['+inttostr(i)+'].deliverydata.firm')));
            end else begin
              mFirmOffice.SetFieldValueAsString('Name', Trim(mXMLHead.getElementAsString('order['+inttostr(i)+'].deliverydata.name')+' '+mXMLHead.getElementAsString('order['+inttostr(i)+'].deliverydata.surname')))
            end;
            mFirmOffice.SetFieldValueAsBoolean('SynchronizeAddress', False);
            if ElementExists(mXMLHead, 'order['+inttostr(i)+'].transport.deliveryPointID') then
             mFirmOffice.SetFieldValueAsString('Address_ID.Recipient', Trim(mXMLHead.getElementAsString('order['+inttostr(i)+'].transport.deliveryPointID')));
            mFirmOffice.GetMonikerForFieldCode(mFirmOffice.GetFieldCode('Address_ID')).BusinessObject.SetFieldValueAsString('City',mXMLHead.getElementAsString('order['+inttostr(i)+'].deliverydata.city'));
            mFirmOffice.GetMonikerForFieldCode(mFirmOffice.GetFieldCode('Address_ID')).BusinessObject.SetFieldValueAsString('PostCode',mXMLHead.getElementAsString('order['+inttostr(i)+'].deliverydata.zip'));
            mFirmOffice.GetMonikerForFieldCode(mFirmOffice.GetFieldCode('Address_ID')).BusinessObject.SetFieldValueAsString('Street',AnsiLeftStr(mXMLHead.getElementAsString('order['+inttostr(i)+'].deliverydata.Street'),60));
            mFirmOffice.GetMonikerForFieldCode(mFirmOffice.GetFieldCode('Address_ID')).BusinessObject.SetFieldValueAsString('PhoneNumber1',mXMLHead.getElementAsString('order['+inttostr(i)+'].deliverydata.tel'));
            mFirmOffice.GetMonikerForFieldCode(mFirmOffice.GetFieldCode('Address_ID')).BusinessObject.SetFieldValueAsString('Email',Trim(mXMLHead.getElementAsString('order['+inttostr(i)+'].orderdata.email')));
            if mFirmOffice.GetFieldValueAsString('Name')='' then mFirmOffice.SetFieldValueAsString('Name', 'Provozovna');
            mFirmOffice_ID := mFirmOffice.OID;
           end;
       mFirm.Save;
       mFirm.Free;
      end;
    end;
    mReceivedOrderBO.SetFieldValueAsString('Firm_ID',mFirm_ID);
    if not(NxIsEmptyOID(mFirmoffice_ID)) then mReceivedOrderBO.SetFieldValueAsString('FirmOffice_ID',mFirmOffice_ID);
    mReceivedOrderBO.SetFieldValueAsString('U_created',mXMLHead.getElementAsString('order['+inttostr(i)+'].orderdata.created'));
    mReceivedOrderBO.SetFieldValueAsString('U_email',mXMLHead.getElementAsString('order['+inttostr(i)+'].orderdata.email'));
    mReceivedOrderBO.SetFieldValueAsString('X_poznamka_memo',mXMLHead.getElementAsString('order['+inttostr(i)+'].orderdata.note'));
    mReceivedOrderBO.SetFieldValueAsString('X_PoukazID',mXMLHead.getElementAsString('order['+inttostr(i)+'].orderdata.poukazID'));
    mReceivedOrderBO.SetFieldValueAsString('ExternalNumber',mXMLHead.getElementAsString('order['+inttostr(i)+'].orderdata.id'));
    if ElementExists(mXMLHead, 'order['+inttostr(i)+'].invoicedata.external_number') then mReceivedOrderBO.SetFieldValueAsString('ExternalNumber',mXMLHead.getElementAsString('order['+inttostr(i)+'].invoicedata.external_number'));
    mReceivedOrderBO.SetFieldValueAsInteger('DealerDiscountKind',0);
    mReceivedOrderBO.SetFieldValueAsBoolean('U_FromES',True);
    if ElementExists(mXMLHead, 'order['+inttostr(i)+'].orderdata.epoukaz') then begin
      if mXMLHead.getElementAsString('order['+inttostr(i)+'].orderdata.epoukaz')='1' then begin
       mReceivedOrderBO.SetFieldValueAsBoolean('X_EPoukaz',true);
      end;
    end;
    if NxIsBlank(mXMLHead.getElementAsString('order['+inttostr(i)+'].orderdata.id')) then mReceivedOrderBO.SetFieldValueAsString('BankAccount_ID','1100000101');
    if ElementExists(mXMLHead, 'order['+inttostr(i)+'].invoicedata.zp') then mReceivedOrderBO.SetFieldValueAsString('X_InsuranceCo',mXMLHead.getElementAsString('order['+inttostr(i)+'].invoicedata.zp'));
    if not(NxIsEmptyOID(mXMLHead.getElementAsString('order['+inttostr(i)+'].transport.System_ID'))) then mReceivedOrderBO.SetFieldValueAsString('TransportationType_ID',mXMLHead.getElementAsString('order['+inttostr(i)+'].transport.System_ID'));
    if not(NxIsEmptyOID(mXMLHead.getElementAsString('order['+inttostr(i)+'].payment.System_ID'))) then mReceivedOrderBO.SetFieldValueAsString('PaymentType_ID',mXMLHead.getElementAsString('order['+inttostr(i)+'].payment.System_ID'));

        for j:=0 to  mXMLHead.getElementsCountInArray('order['+inttostr(i)+'].products.product')-1 do begin
          if (mXMLHead.getElementAsFloat('order['+inttostr(i)+'].products.product['+inttostr(j)+'].amount')>0)  and not(nxisemptyoid(mXMLHead.getElementAsString('order['+inttostr(i)+'].products.product['+inttostr(j)+'].system_id'))) then begin
           mRows:=mReceivedOrderBO.GetCollectionMonikerForFieldCode(mReceivedOrderBO.getfieldcode('Rows'));
           mReceivedOrderRowBO:=mRows.AddNewObject;
           mReceivedOrderRowBO.SetFieldValueAsInteger('RowType',3);
           mReceivedOrderRowBO.SetFieldValueAsString('StoreCard_id',mXMLHead.getElementAsString('order['+inttostr(i)+'].products.product['+inttostr(j)+'].system_id'));
           mReceivedOrderRowBO.SetFieldValueAsString('Qunit',mXMLHead.getElementAsString('order['+inttostr(i)+'].products.product['+inttostr(j)+'].unit_code'));
           mReceivedOrderRowBO.SetFieldValueAsString('Store_ID',cStore_ID);
           mReceivedOrderRowBO.SetFieldValueAsString('Division_ID',cDivision_ID);
           mReceivedOrderRowBO.SetFieldValueAsFloat('UnitQuantity',mXMLHead.getElementAsFloat('order['+inttostr(i)+'].products.product['+inttostr(j)+'].amount'));

           mReceivedOrderRowBO.SetFieldValueAsFloat('UnitPrice',StrToFloat(NxSearchReplace(mXMLHead.getElementAsString('order['+inttostr(i)+'].products.product['+inttostr(j)+'].Price'),'.',',',[srAll])));
           if StrToFloat(NxSearchReplace(mXMLHead.getElementAsString('order['+inttostr(i)+'].products.product['+inttostr(j)+'].Price'),'.',',',[srAll]))=0 then begin
             mReceivedOrderRowBO.SetFieldValueAsFloat('UnitPrice',0);
             mReceivedOrderRowBO.SetFieldValueAsFloat('TotalPrice',0);
           end;
          end;

          if (mXMLHead.getElementAsFloat('order['+inttostr(i)+'].products.product['+inttostr(j)+'].amount')>0)  and (nxisemptyoid(mXMLHead.getElementAsString('order['+inttostr(i)+'].products.product['+inttostr(j)+'].system_id'))) then begin
           mRows:=mReceivedOrderBO.GetCollectionMonikerForFieldCode(mReceivedOrderBO.getfieldcode('Rows'));
           mReceivedOrderRowBO:=mRows.AddNewObject;
           mReceivedOrderRowBO.SetFieldValueAsInteger('RowType',1);
           mReceivedOrderRowBO.SetFieldValueAsString('Text',mXMLHead.getElementAsString('order['+inttostr(i)+'].products.product['+inttostr(j)+'].name'));
           //mReceivedOrderRowBO.SetFieldValueAsFloat('VatRate',21);
           mReceivedOrderRowBO.SetFieldValueAsString('VatRate_ID','02100X0000');
           mReceivedOrderRowBO.SetFieldValueAsString('Division_ID',cDivision_ID);
           mReceivedOrderRowBO.SetFieldValueAsFloat('Quantity',mXMLHead.getElementAsFloat('order['+inttostr(i)+'].products.product['+inttostr(j)+'].amount'));
           mReceivedOrderRowBO.SetFieldValueAsFloat('UnitPrice',StrToFloat(NxSearchReplace(mXMLHead.getElementAsString('order['+inttostr(i)+'].products.product['+inttostr(j)+'].Price'),'.',',',[srAll])));

          end;


        end;
     if StrToFloat(NxSearchReplace(mXMLHead.getElementAsString('order['+inttostr(i)+'].transport.Price'),'.',',',[srAll])) >0 then begin
         mRows:=mReceivedOrderBO.GetCollectionMonikerForFieldCode(mReceivedOrderBO.getfieldcode('Rows'));
           mReceivedOrderRowBO:=mRows.AddNewObject;
           mReceivedOrderRowBO.SetFieldValueAsInteger('RowType',1);
           mReceivedOrderRowBO.SetFieldValueAsString('Text',mXMLHead.getElementAsString('order['+inttostr(i)+'].transport.Name'));
           if StrToFloat(NxSearchReplace(mXMLHead.getElementAsString('order['+inttostr(i)+'].transport.vat'),'.',',',[srAll]))=21 then begin
           mReceivedOrderRowBO.SetFieldValueAsFloat('TotalPrice',StrToFloat(NxSearchReplace(mXMLHead.getElementAsString('order['+inttostr(i)+'].transport.Price'),'.',',',[srAll]))/1.21);
           //mReceivedOrderRowBO.SetFieldValueAsFloat('VatRate',21);
           mReceivedOrderRowBO.SetFieldValueAsString('VatRate_ID','02100X0000');
           end;
           if StrToFloat(NxSearchReplace(mXMLHead.getElementAsString('order['+inttostr(i)+'].transport.vat'),'.',',',[srAll]))=12 then begin
           mReceivedOrderRowBO.SetFieldValueAsFloat('TotalPrice',StrToFloat(NxSearchReplace(mXMLHead.getElementAsString('order['+inttostr(i)+'].transport.Price'),'.',',',[srAll]))/1.12);
           //mReceivedOrderRowBO.SetFieldValueAsFloat('VatRate',15);
           mReceivedOrderRowBO.SetFieldValueAsString('VatRate_ID','01200X0000');
           end;
           if StrToFloat(NxSearchReplace(mXMLHead.getElementAsString('order['+inttostr(i)+'].transport.vat'),'.',',',[srAll]))=15 then begin
           mReceivedOrderRowBO.SetFieldValueAsFloat('TotalPrice',StrToFloat(NxSearchReplace(mXMLHead.getElementAsString('order['+inttostr(i)+'].transport.Price'),'.',',',[srAll]))/1.15);
           //mReceivedOrderRowBO.SetFieldValueAsFloat('VatRate',15);
           mReceivedOrderRowBO.SetFieldValueAsString('VatRate_ID','01500X0000');
           end;
           mReceivedOrderRowBO.SetFieldValueAsString('Division_ID',cDivision_ID);

     end;
     if StrToFloat(NxSearchReplace(mXMLHead.getElementAsString('order['+inttostr(i)+'].payment.Price'),'.',',',[srAll])) >0 then begin
         mRows:=mReceivedOrderBO.GetCollectionMonikerForFieldCode(mReceivedOrderBO.getfieldcode('Rows'));
           mReceivedOrderRowBO:=mRows.AddNewObject;
           mReceivedOrderRowBO.SetFieldValueAsInteger('RowType',1);
           mReceivedOrderRowBO.SetFieldValueAsString('Text',mXMLHead.getElementAsString('order['+inttostr(i)+'].payment.Name'));
           if StrToFloat(NxSearchReplace(mXMLHead.getElementAsString('order['+inttostr(i)+'].payment.vat'),'.',',',[srAll]))=21 then begin
           mReceivedOrderRowBO.SetFieldValueAsFloat('TotalPrice',StrToFloat(NxSearchReplace(mXMLHead.getElementAsString('order['+inttostr(i)+'].payment.Price'),'.',',',[srAll]))/1.21);
           //mReceivedOrderRowBO.SetFieldValueAsFloat('VatRate',21);
           mReceivedOrderRowBO.SetFieldValueAsString('VatRate_ID','02100X0000');
           end;
           if StrToFloat(NxSearchReplace(mXMLHead.getElementAsString('order['+inttostr(i)+'].payment.vat'),'.',',',[srAll]))=12 then begin
           mReceivedOrderRowBO.SetFieldValueAsFloat('TotalPrice',StrToFloat(NxSearchReplace(mXMLHead.getElementAsString('order['+inttostr(i)+'].payment.Price'),'.',',',[srAll]))/1.12);
           //mReceivedOrderRowBO.SetFieldValueAsFloat('VatRate',15);
           mReceivedOrderRowBO.SetFieldValueAsString('VatRate_ID','01200X0000');
           end;
           if StrToFloat(NxSearchReplace(mXMLHead.getElementAsString('order['+inttostr(i)+'].payment.vat'),'.',',',[srAll]))=15 then begin
           mReceivedOrderRowBO.SetFieldValueAsFloat('TotalPrice',StrToFloat(NxSearchReplace(mXMLHead.getElementAsString('order['+inttostr(i)+'].payment.Price'),'.',',',[srAll]))/1.15);
           //mReceivedOrderRowBO.SetFieldValueAsFloat('VatRate',15);
           mReceivedOrderRowBO.SetFieldValueAsString('VatRate_ID','01500X0000');
           end;
           mReceivedOrderRowBO.SetFieldValueAsString('Division_ID',cDivision_ID);

     end;
     NxScriptingLog.EnterSection('additional_payment',logInfo);
     NxScriptingLog.WriteEvent(logInfo,'jsem před detekcí');
     if ElementExists(mXMLHead, 'order['+inttostr(i)+'].additional_payment.price') then begin
      NxScriptingLog.WriteEvent(logInfo,'jsem po detekci');
      NxScriptingLog.WriteEvent(logInfo,mXMLHead.getElementAsString('order['+inttostr(i)+'].additional_payment.Price'));
      if StrToFloat(NxSearchReplace(mXMLHead.getElementAsString('order['+inttostr(i)+'].additional_payment.Price'),'.',',',[srAll])) >0 then begin
           NxScriptingLog.WriteEvent(logInfo,'mám cenu');
           mRows:=mReceivedOrderBO.GetCollectionMonikerForFieldCode(mReceivedOrderBO.getfieldcode('Rows'));
           mReceivedOrderRowBO:=mRows.AddNewObject;
           mReceivedOrderRowBO.SetFieldValueAsInteger('RowType',1);
           mReceivedOrderRowBO.SetFieldValueAsString('Text','Spoluúčast pacienta');
           mReceivedOrderRowBO.SetFieldValueAsFloat('TotalPrice',StrToFloat(NxSearchReplace(mXMLHead.getElementAsString('order['+inttostr(i)+'].additional_payment.Price'),'.',',',[srAll]))/1.12);
           mReceivedOrderRowBO.SetFieldValueAsString('VatRate_ID','01200X0000');
           mReceivedOrderRowBO.SetFieldValueAsString('Division_ID',cDivision_ID);
      end;

     end;
     NxScriptingLog.LeaveSection('additional_payment',logInfo);
     if mReceivedOrderBO.GetFieldValueAsString('TransportationType_ID.Code') in ['01','08','V1','09'] then mReceivedOrderBO.SetFieldValueAsString('U_Stav_ID','1300000101');
     mReceivedOrderBO.save;
     AResult :=AResult+('id_eshop:'+mXMLHead.getElementAsString('order['+inttostr(i)+'].orderdata.id')+'|id_abra:'+mReceivedOrderBO.oid+'|Status_ID:'+mReceivedOrderBO.GetFieldValueAsString('U_Stav_ID')+'#');
     mReceivedOrderBO.free;
     end;
     if not(NxIsEmptyOID(mOrder_ID)) then begin
     mReceivedOrderBO:=mOS.CreateObject(Class_ReceivedOrder);
     mReceivedOrderBO.Load(mOrder_ID,nil);
     AResult :=AResult+('id_eshop:'+mXMLHead.getElementAsString('order['+inttostr(i)+'].orderdata.id')+'|id_abra:'+mOrder_ID+'|Status_ID:'+mReceivedOrderBO.GetFieldValueAsString('U_Stav_ID')+'#');
     mReceivedOrderBO.free;
     end;
    End;

 Result:=EncodeBase64(TEncoding.Unicode.GetBytes(Aresult));

end;



function InsertOrder(Self: TNxWebServicesHelper; var XMLinput: String):String;
Var
 mXMLinput:string;
 mXMLHead : TNxScriptingXMLWrapper;
 mReceivedOrderBO, mReceivedOrderRowBO: TNxCustomBusinessObject;
 mFirm, mFirmOffice, mStoreCard: TNxCustomBusinessObject;
 mRows, mColl : TNxCustomBusinessMonikerCollection;
 mOS: TNxCustomObjectSpace;
 mFirm_ID, mFirmOffice_ID, mStoreCard_ID, mQuantity, mPrice, mFirmCode, mOrder_ID, mPeriod_ID: String;
 mr1:TstringList;
 mQuantityDouble, mPriceDouble :Double;
 mList:TStringList;
 i,j,d: integer;
 AResult:String;
 
begin
 Aresult:='';
 Result:='';
 mOS:=self.ObjectSpace;
 mXMLHead := TNxScriptingXMLWrapper.Create;
 //mXMLinput:=DecodeBase64(XMLInput);
 mList:=TStringList.Create;
 //ShowMessage(mXMLInput);
 mXMLHead.loadFromBytes(DecodeBase64(XMLinput));
 mXMLHead.saveToFile('C:\server\abra\AbraG2\xml\'+FormatDateTime('YYYYMMDDHHmmss',Now)+'.xml');
    for i:=0 to mXMLHead.getElementsCountInArray('order')-1 do begin
    //mPeriod_ID:='2U00000101';
    mPeriod_ID:=GetPeriod_ID(mOS,Date);
    mOrder_ID:=scrGetORder_ID(mOS,mXMLHead.getElementAsString('order['+inttostr(i)+'].orderdata.id'), mPeriod_ID);
    if NxIsBlank(mOrder_ID) then begin
    mFirm_ID:='';
    mFirmOffice_ID:='';
    mReceivedOrderBO:=mOS.CreateObject(Class_ReceivedOrder);
    mReceivedOrderBO.New;
    mReceivedOrderBO.Prefill;
    mReceivedOrderBO.SetFieldValueAsString('DocQueue_ID',cDocqueue_ID);
    if ElementExists(mXMLHead, 'order['+inttostr(i)+'].orderdata.doc_queue') then begin
     if not(NxIsEmptyOID(mXMLHead.getElementAsString('order['+inttostr(i)+'].orderdata.doc_queue'))) then
       mReceivedOrderBO.SetFieldValueAsString('DocQueue_ID',mXMLHead.getElementAsString('order['+inttostr(i)+'].orderdata.doc_queue'));
    end;
    mReceivedOrderBO.SetFieldValueAsString('X_ES_ID',(mXMLHead.getElementAsString('order['+inttostr(i)+'].orderdata.id')));
    mReceivedOrderBO.SetFieldValueAsString('BankAccount_ID','1000000101');
    mReceivedOrderBO.SetFieldValueAsBoolean('VatDocument',True);
    mReceivedOrderBO.SetFieldValueAsBoolean('PricesWithVAT',False);
    if not(NxIsEmptyOID(mXMLHead.getElementAsString('order['+inttostr(i)+'].transport.System_ID'))) then mReceivedOrderBO.SetFieldValueAsString('TransportationType_ID',mXMLHead.getElementAsString('order['+inttostr(i)+'].transport.System_ID'));
    if not(NxIsEmptyOID(mXMLHead.getElementAsString('order['+inttostr(i)+'].payment.System_ID'))) then mReceivedOrderBO.SetFieldValueAsString('PaymentType_ID',mXMLHead.getElementAsString('order['+inttostr(i)+'].payment.System_ID'));
    if (mXMLHead.getElementAsString('order['+inttostr(i)+'].transport.Name')='DPD') then mReceivedOrderBO.SetFieldValueAsString('TransportationType_ID','1300000101');
    if (mXMLHead.getElementAsString('order['+inttostr(i)+'].transport.Name')='Česká pošta') then mReceivedOrderBO.SetFieldValueAsString('TransportationType_ID','00000P1000');
    if (StrToFloat(NxSearchReplace(mXMLHead.getElementAsString('order['+inttostr(i)+'].transport.Price'),'.',',',[srAll])) =0) then mReceivedOrderBO.SetFieldValueAsString('TransportationType_ID','00000O1000');
    
    if mXMLHead.getElementsCountInArray('order['+inttostr(i)+'].invoicedata')>0 then begin
      if not(NxIsEmptyOID(mXMLHead.getElementAsString('order['+inttostr(i)+'].orderdata.firm_system_id'))) then mFirm_ID:=mXMLHead.getElementAsString('order['+inttostr(i)+'].orderdata.firm_system_id');
      // dohledávání dle názvu firmy
      //if NxIsEmptyOID(mFirm_ID) and not(NxIsBlank(Trim(mXMLHead.getElementAsString('order['+inttostr(i)+'].invoicedata.firm')))) then mFirm_ID:=scrFirm_ID(mOS,'Name', Trim(mXMLHead.getElementAsString('order['+inttostr(i)+'].invoicedata.firm')));
      if NxIsEmptyOID(mfirm_id) and not(nxisblank(Trim(mXMLHead.getElementAsString('order['+inttostr(i)+'].invoicedata.ic')))) then mFirm_ID:=scrFirm_ID(mOS,'OrgIdentNumber', Trim(mXMLHead.getElementAsString('order['+inttostr(i)+'].invoicedata.ic')));
      if NxIsEmptyOID(mfirm_id) and not(nxisblank(Trim(mXMLHead.getElementAsString('order['+inttostr(i)+'].invoicedata.dic')))) then mFirm_ID:=scrFirm_ID(mOS,'VatIdentNumber', Trim(mXMLHead.getElementAsString('order['+inttostr(i)+'].invoicedata.dic')));
      if NxIsEmptyOID(mFirm_ID) and not(nxisblank(Trim(mXMLHead.getElementAsString('order['+inttostr(i)+'].orderdata.email')))) then mFirm_ID:=GetFirmE_ID(mOS,Trim(mXMLHead.getElementAsString('order['+inttostr(i)+'].orderdata.email')));
      if NxIsEmptyOID(mFirm_ID) and not(NxIsBlank(Trim(mXMLHead.getElementAsString('order['+inttostr(i)+'].invoicedata.firm')))) then mFirm_ID:=scrFirm_ID(mOS,'Name', Trim(mXMLHead.getElementAsString('order['+inttostr(i)+'].invoicedata.firm')));
      if NxIsEmptyOID(mFirm_ID) and not(NxIsBlank(Trim(mXMLHead.getElementAsString('order['+inttostr(i)+'].invoicedata.name')+' '+mXMLHead.getElementAsString('order['+inttostr(i)+'].invoicedata.surname'))))
        then mFirm_ID:=scrFirm_ID(mOS,'Name', Trim(mXMLHead.getElementAsString('order['+inttostr(i)+'].invoicedata.name')+' '+mXMLHead.getElementAsString('order['+inttostr(i)+'].invoicedata.surname')));
    end;
    //dohledávání dle jsména a příjmení
    // dohledat firmu dle emailu 11.5.2021


    //if NxIsEmptyOID(mfirm_id) then mFirm_ID:=scrFirm_ID(mOS,'Name', Trim(mXMLHead.getElementAsString('order['+inttostr(i)+'].invoicedata.name')+' '+mXMLHead.getElementAsString('order['+inttostr(i)+'].invoicedata.surname')));
    if NxIsEmptyOID(mFirm_ID) then begin
      mFirm:= mOS.CreateObject('4K3EXM5PQBCL35CH000ILPWJF4');
      mFirmOffice:= mOS.CreateObject('AT011EZZ5DFO115YJ1HCZJDXJ4');
       mFirm.New;
       mFirm.Prefill;
       if not(NxIsBlank(Trim(mXMLHead.getElementAsString('order['+inttostr(i)+'].invoicedata.firm')))) then mFirm.SetFieldValueAsString('name',Trim(mXMLHead.getElementAsString('order['+inttostr(i)+'].invoicedata.firm')));
       if (NxIsBlank(Trim(mXMLHead.getElementAsString('order['+inttostr(i)+'].invoicedata.firm')))) then mFirm.SetFieldValueAsString('Name',Trim(mXMLHead.getElementAsString('order['+inttostr(i)+'].invoicedata.name')+' '+mXMLHead.getElementAsString('order['+inttostr(i)+'].invoicedata.surname')));
       mFirm.SetFieldValueAsString('VatIdentNumber',Trim(mXMLHead.getElementAsString('order['+inttostr(i)+'].invoicedata.dic')));
       mFirm.SetFieldValueAsString('OrgIdentNumber',Trim(mXMLHead.getElementAsString('order['+inttostr(i)+'].invoicedata.ic')));
       mFirm.GetMonikerForFieldCode(mFirm.GetFieldCode('ResidenceAddress_ID')).BusinessObject.SetFieldValueAsString('PostCode',Trim(mXMLHead.getElementAsString('order['+inttostr(i)+'].invoicedata.zip')));
       mFirm.GetMonikerForFieldCode(mFirm.GetFieldCode('ResidenceAddress_ID')).BusinessObject.SetFieldValueAsString('City',Trim(mXMLHead.getElementAsString('order['+inttostr(i)+'].invoicedata.city')));
       mFirm.GetMonikerForFieldCode(mFirm.GetFieldCode('ResidenceAddress_ID')).BusinessObject.SetFieldValueAsString('Street',AnsiLeftStr(Trim(mXMLHead.getElementAsString('order['+inttostr(i)+'].invoicedata.street')),60));
       mFirm.GetMonikerForFieldCode(mFirm.GetFieldCode('ResidenceAddress_ID')).BusinessObject.SetFieldValueAsString('PhoneNumber1',Trim(mXMLHead.getElementAsString('order['+inttostr(i)+'].invoicedata.tel')));
       mFirm.GetMonikerForFieldCode(mFirm.GetFieldCode('ResidenceAddress_ID')).BusinessObject.SetFieldValueAsString('Email',Trim(mXMLHead.getElementAsString('order['+inttostr(i)+'].orderdata.email')));
       //if not(NxIsEmptyOID(Trim(mXMLHead.getElementAsString('order['+inttostr(i)+'].orderdata.pricelist_id')))) then mFirm.SetFieldValueAsString('PriceList_ID',Trim(mXMLHead.getElementAsString('order['+inttostr(i)+'].orderdata.pricelist_id')));
       mfirm.Save;
       mFirm_ID:=mFirm.OID;
       mFirm.Free;
    end;
    if not(NxIsEmptyOID(mFirm_ID)) then begin
        if mXMLHead.getElementsCountInArray('order['+inttostr(i)+'].deliverydata')>0 then begin
         mFirm:= mOS.CreateObject('4K3EXM5PQBCL35CH000ILPWJF4');
         mFirmOffice:= mOS.CreateObject('AT011EZZ5DFO115YJ1HCZJDXJ4');
         mFirm.Load(mFirm_ID,nil);
         mColl := mFirm.GetLoadedCollectionMonikerForFieldCode(mFirm.GetfieldCode('FirmOffices'));
         if not(NxIsEmptyOID(mXMLHead.getElementAsString('order['+inttostr(i)+'].deliverydata.system_id'))) then mFirmOffice_ID:=mXMLHead.getElementAsString('order['+inttostr(i)+'].deliverydata.system_id');
           if (NxIsEmptyOID(mFirmOffice_ID)) and not(Trim(mXMLHead.getElementAsString('order['+inttostr(i)+'].deliverydata.name')+' '+mXMLHead.getElementAsString('order['+inttostr(i)+'].deliverydata.surname'))='') then begin

              for d:=0 to mColl.Count-1 do begin
               // if NxSearch(mcoll.BusinessObject[d].GetFieldValueAsString('Name'),Trim(mXMLHead.getElementAsString('order['+inttostr(i)+'].deliverydata.name')+' '+mXMLHead.getElementAsString('order['+inttostr(i)+'].deliverydata.surname')),[srAll],0)>0 then
                if NxSearch(UpperCase(mcoll.BusinessObject[d].GetFieldValueAsString('Address_ID.Street')),Trim(UpperCase(mXMLHead.getElementAsString('order['+inttostr(i)+'].deliverydata.street'))),[srAll],0)>0 then
                mFirmOffice_ID:=mcoll.BusinessObject[d].OID;

              end;
           end;
           if NxIsEmptyOID(mFirmOffice_ID) then begin
            mFirmOffice :=mColl.AddNewObject;
            if ElementExists(mXMLHead, 'order['+inttostr(i)+'].deliverydata.firm') then begin
             if NxIsBlank(Trim(mXMLHead.getElementAsString('order['+inttostr(i)+'].deliverydata.firm'))) then
              mFirmOffice.SetFieldValueAsString('Name', Trim(mXMLHead.getElementAsString('order['+inttostr(i)+'].deliverydata.name')+' '+mXMLHead.getElementAsString('order['+inttostr(i)+'].deliverydata.surname'))) else
              mFirmOffice.SetFieldValueAsString('Name', Trim(mXMLHead.getElementAsString('order['+inttostr(i)+'].deliverydata.firm')));
            end else begin
              mFirmOffice.SetFieldValueAsString('Name', Trim(mXMLHead.getElementAsString('order['+inttostr(i)+'].deliverydata.name')+' '+mXMLHead.getElementAsString('order['+inttostr(i)+'].deliverydata.surname')))
            end;
            mFirmOffice.SetFieldValueAsBoolean('SynchronizeAddress', False);
            if ElementExists(mXMLHead, 'order['+inttostr(i)+'].transport.deliveryPointID') then
             mFirmOffice.SetFieldValueAsString('Address_ID.Recipient', Trim(mXMLHead.getElementAsString('order['+inttostr(i)+'].transport.deliveryPointID')));
            mFirmOffice.GetMonikerForFieldCode(mFirmOffice.GetFieldCode('Address_ID')).BusinessObject.SetFieldValueAsString('City',mXMLHead.getElementAsString('order['+inttostr(i)+'].deliverydata.city'));
            mFirmOffice.GetMonikerForFieldCode(mFirmOffice.GetFieldCode('Address_ID')).BusinessObject.SetFieldValueAsString('PostCode',mXMLHead.getElementAsString('order['+inttostr(i)+'].deliverydata.zip'));
            mFirmOffice.GetMonikerForFieldCode(mFirmOffice.GetFieldCode('Address_ID')).BusinessObject.SetFieldValueAsString('Street',AnsiLeftStr(mXMLHead.getElementAsString('order['+inttostr(i)+'].deliverydata.Street'),60));
            mFirmOffice.GetMonikerForFieldCode(mFirmOffice.GetFieldCode('Address_ID')).BusinessObject.SetFieldValueAsString('PhoneNumber1',mXMLHead.getElementAsString('order['+inttostr(i)+'].deliverydata.tel'));
            mFirmOffice.GetMonikerForFieldCode(mFirmOffice.GetFieldCode('Address_ID')).BusinessObject.SetFieldValueAsString('Email',Trim(mXMLHead.getElementAsString('order['+inttostr(i)+'].orderdata.email')));
            if mFirmOffice.GetFieldValueAsString('Name')='' then mFirmOffice.SetFieldValueAsString('Name', 'Provozovna');
            mFirmOffice_ID := mFirmOffice.OID;
           end;
       mFirm.Save;
       mFirm.Free;
      end;
    end;
    mReceivedOrderBO.SetFieldValueAsString('Firm_ID',mFirm_ID);
    if not(NxIsEmptyOID(mFirmoffice_ID)) then mReceivedOrderBO.SetFieldValueAsString('FirmOffice_ID',mFirmOffice_ID);
    mReceivedOrderBO.SetFieldValueAsString('U_created',mXMLHead.getElementAsString('order['+inttostr(i)+'].orderdata.created'));
    mReceivedOrderBO.SetFieldValueAsString('U_email',mXMLHead.getElementAsString('order['+inttostr(i)+'].orderdata.email'));
    mReceivedOrderBO.SetFieldValueAsString('X_poznamka_memo',mXMLHead.getElementAsString('order['+inttostr(i)+'].orderdata.note'));
    mReceivedOrderBO.SetFieldValueAsString('ExternalNumber',mXMLHead.getElementAsString('order['+inttostr(i)+'].orderdata.id'));
    if ElementExists(mXMLHead, 'order['+inttostr(i)+'].invoicedata.external_number') then mReceivedOrderBO.SetFieldValueAsString('ExternalNumber',mXMLHead.getElementAsString('order['+inttostr(i)+'].invoicedata.external_number'));
    mReceivedOrderBO.SetFieldValueAsInteger('DealerDiscountKind',0);
    mReceivedOrderBO.SetFieldValueAsBoolean('U_FromES',True);
    if ElementExists(mXMLHead, 'order['+inttostr(i)+'].orderdata.epoukaz') then begin
      if mXMLHead.getElementAsString('order['+inttostr(i)+'].orderdata.epoukaz')='1' then begin
       mReceivedOrderBO.SetFieldValueAsBoolean('X_EPoukaz',true);
      end;
    end;
    if NxIsBlank(mXMLHead.getElementAsString('order['+inttostr(i)+'].orderdata.id')) then mReceivedOrderBO.SetFieldValueAsString('BankAccount_ID','1100000101');
    if ElementExists(mXMLHead, 'order['+inttostr(i)+'].invoicedata.zp') then mReceivedOrderBO.SetFieldValueAsString('X_InsuranceCo',mXMLHead.getElementAsString('order['+inttostr(i)+'].invoicedata.zp'));
    if not(NxIsEmptyOID(mXMLHead.getElementAsString('order['+inttostr(i)+'].transport.System_ID'))) then mReceivedOrderBO.SetFieldValueAsString('TransportationType_ID',mXMLHead.getElementAsString('order['+inttostr(i)+'].transport.System_ID'));
    if not(NxIsEmptyOID(mXMLHead.getElementAsString('order['+inttostr(i)+'].payment.System_ID'))) then mReceivedOrderBO.SetFieldValueAsString('PaymentType_ID',mXMLHead.getElementAsString('order['+inttostr(i)+'].payment.System_ID'));

        for j:=0 to  mXMLHead.getElementsCountInArray('order['+inttostr(i)+'].products.product')-1 do begin
          if (mXMLHead.getElementAsFloat('order['+inttostr(i)+'].products.product['+inttostr(j)+'].amount')>0)  and not(nxisemptyoid(mXMLHead.getElementAsString('order['+inttostr(i)+'].products.product['+inttostr(j)+'].system_id'))) then begin
           mRows:=mReceivedOrderBO.GetCollectionMonikerForFieldCode(mReceivedOrderBO.getfieldcode('Rows'));
           mReceivedOrderRowBO:=mRows.AddNewObject;
           mReceivedOrderRowBO.SetFieldValueAsInteger('RowType',3);
           mReceivedOrderRowBO.SetFieldValueAsString('StoreCard_id',mXMLHead.getElementAsString('order['+inttostr(i)+'].products.product['+inttostr(j)+'].system_id'));
           mReceivedOrderRowBO.SetFieldValueAsString('Qunit',mXMLHead.getElementAsString('order['+inttostr(i)+'].products.product['+inttostr(j)+'].unit_code'));
           mReceivedOrderRowBO.SetFieldValueAsString('Store_ID',cStore_ID);
           mReceivedOrderRowBO.SetFieldValueAsString('Division_ID',cDivision_ID);
           mReceivedOrderRowBO.SetFieldValueAsFloat('UnitQuantity',mXMLHead.getElementAsFloat('order['+inttostr(i)+'].products.product['+inttostr(j)+'].amount'));

           mReceivedOrderRowBO.SetFieldValueAsFloat('UnitPrice',StrToFloat(NxSearchReplace(mXMLHead.getElementAsString('order['+inttostr(i)+'].products.product['+inttostr(j)+'].Price'),'.',',',[srAll])));
           if StrToFloat(NxSearchReplace(mXMLHead.getElementAsString('order['+inttostr(i)+'].products.product['+inttostr(j)+'].Price'),'.',',',[srAll]))=0 then begin
             mReceivedOrderRowBO.SetFieldValueAsFloat('UnitPrice',0);
             mReceivedOrderRowBO.SetFieldValueAsFloat('TotalPrice',0);
           end;
          end;

          if (mXMLHead.getElementAsFloat('order['+inttostr(i)+'].products.product['+inttostr(j)+'].amount')>0)  and (nxisemptyoid(mXMLHead.getElementAsString('order['+inttostr(i)+'].products.product['+inttostr(j)+'].system_id'))) then begin
           mRows:=mReceivedOrderBO.GetCollectionMonikerForFieldCode(mReceivedOrderBO.getfieldcode('Rows'));
           mReceivedOrderRowBO:=mRows.AddNewObject;
           mReceivedOrderRowBO.SetFieldValueAsInteger('RowType',1);
           mReceivedOrderRowBO.SetFieldValueAsString('Text',mXMLHead.getElementAsString('order['+inttostr(i)+'].products.product['+inttostr(j)+'].name'));
           if mXMLHead.getElementAsString('order['+inttostr(i)+'].products.product['+inttostr(j)+'].vat')='12' then mReceivedOrderRowBO.SetFieldValueAsString('VatRate_ID','01200X0000')
           else
           //mReceivedOrderRowBO.SetFieldValueAsFloat('VatRate',21);
           mReceivedOrderRowBO.SetFieldValueAsString('VatRate_ID','02100X0000');
           mReceivedOrderRowBO.SetFieldValueAsString('Division_ID',cDivision_ID);
           mReceivedOrderRowBO.SetFieldValueAsFloat('Quantity',mXMLHead.getElementAsFloat('order['+inttostr(i)+'].products.product['+inttostr(j)+'].amount'));
           mReceivedOrderRowBO.SetFieldValueAsFloat('UnitPrice',StrToFloat(NxSearchReplace(mXMLHead.getElementAsString('order['+inttostr(i)+'].products.product['+inttostr(j)+'].Price'),'.',',',[srAll])));

          end;


        end;
     if StrToFloat(NxSearchReplace(mXMLHead.getElementAsString('order['+inttostr(i)+'].transport.Price'),'.',',',[srAll])) >0 then begin
         mRows:=mReceivedOrderBO.GetCollectionMonikerForFieldCode(mReceivedOrderBO.getfieldcode('Rows'));
           mReceivedOrderRowBO:=mRows.AddNewObject;
           mReceivedOrderRowBO.SetFieldValueAsInteger('RowType',1);
           mReceivedOrderRowBO.SetFieldValueAsString('Text',mXMLHead.getElementAsString('order['+inttostr(i)+'].transport.Name'));
           if StrToFloat(NxSearchReplace(mXMLHead.getElementAsString('order['+inttostr(i)+'].transport.vat'),'.',',',[srAll]))=21 then begin
           mReceivedOrderRowBO.SetFieldValueAsFloat('TotalPrice',StrToFloat(NxSearchReplace(mXMLHead.getElementAsString('order['+inttostr(i)+'].transport.Price'),'.',',',[srAll]))/1.21);
           //mReceivedOrderRowBO.SetFieldValueAsFloat('VatRate',21);
           mReceivedOrderRowBO.SetFieldValueAsString('VatRate_ID','02100X0000');
           end;
           if StrToFloat(NxSearchReplace(mXMLHead.getElementAsString('order['+inttostr(i)+'].transport.vat'),'.',',',[srAll]))=12 then begin
           mReceivedOrderRowBO.SetFieldValueAsFloat('TotalPrice',StrToFloat(NxSearchReplace(mXMLHead.getElementAsString('order['+inttostr(i)+'].transport.Price'),'.',',',[srAll]))/1.12);
           //mReceivedOrderRowBO.SetFieldValueAsFloat('VatRate',15);
           mReceivedOrderRowBO.SetFieldValueAsString('VatRate_ID','01200X0000');
           end;
           if StrToFloat(NxSearchReplace(mXMLHead.getElementAsString('order['+inttostr(i)+'].transport.vat'),'.',',',[srAll]))=15 then begin
           mReceivedOrderRowBO.SetFieldValueAsFloat('TotalPrice',StrToFloat(NxSearchReplace(mXMLHead.getElementAsString('order['+inttostr(i)+'].transport.Price'),'.',',',[srAll]))/1.15);
           //mReceivedOrderRowBO.SetFieldValueAsFloat('VatRate',15);
           mReceivedOrderRowBO.SetFieldValueAsString('VatRate_ID','01500X0000');
           end;
           mReceivedOrderRowBO.SetFieldValueAsString('Division_ID',cDivision_ID);
     
     end;
     if StrToFloat(NxSearchReplace(mXMLHead.getElementAsString('order['+inttostr(i)+'].payment.Price'),'.',',',[srAll])) >0 then begin
         mRows:=mReceivedOrderBO.GetCollectionMonikerForFieldCode(mReceivedOrderBO.getfieldcode('Rows'));
           mReceivedOrderRowBO:=mRows.AddNewObject;
           mReceivedOrderRowBO.SetFieldValueAsInteger('RowType',1);
           mReceivedOrderRowBO.SetFieldValueAsString('Text',mXMLHead.getElementAsString('order['+inttostr(i)+'].payment.Name'));
           if StrToFloat(NxSearchReplace(mXMLHead.getElementAsString('order['+inttostr(i)+'].payment.vat'),'.',',',[srAll]))=21 then begin
           mReceivedOrderRowBO.SetFieldValueAsFloat('TotalPrice',StrToFloat(NxSearchReplace(mXMLHead.getElementAsString('order['+inttostr(i)+'].payment.Price'),'.',',',[srAll]))/1.21);
           //mReceivedOrderRowBO.SetFieldValueAsFloat('VatRate',21);
           mReceivedOrderRowBO.SetFieldValueAsString('VatRate_ID','02100X0000');
           end;
           if StrToFloat(NxSearchReplace(mXMLHead.getElementAsString('order['+inttostr(i)+'].payment.vat'),'.',',',[srAll]))=12 then begin
           mReceivedOrderRowBO.SetFieldValueAsFloat('TotalPrice',StrToFloat(NxSearchReplace(mXMLHead.getElementAsString('order['+inttostr(i)+'].payment.Price'),'.',',',[srAll]))/1.12);
           //mReceivedOrderRowBO.SetFieldValueAsFloat('VatRate',15);
           mReceivedOrderRowBO.SetFieldValueAsString('VatRate_ID','01200X0000');
           end;
           if StrToFloat(NxSearchReplace(mXMLHead.getElementAsString('order['+inttostr(i)+'].payment.vat'),'.',',',[srAll]))=15 then begin
           mReceivedOrderRowBO.SetFieldValueAsFloat('TotalPrice',StrToFloat(NxSearchReplace(mXMLHead.getElementAsString('order['+inttostr(i)+'].payment.Price'),'.',',',[srAll]))/1.15);
           //mReceivedOrderRowBO.SetFieldValueAsFloat('VatRate',15);
           mReceivedOrderRowBO.SetFieldValueAsString('VatRate_ID','01500X0000');
           end;
           mReceivedOrderRowBO.SetFieldValueAsString('Division_ID',cDivision_ID);

     end;
     NxScriptingLog.EnterSection('additional_payment',logInfo);
     NxScriptingLog.WriteEvent(logInfo,'jsem před detekcí');
     if ElementExists(mXMLHead, 'order['+inttostr(i)+'].additional_payment.price') then begin
      NxScriptingLog.WriteEvent(logInfo,'jsem po detekci');
      NxScriptingLog.WriteEvent(logInfo,mXMLHead.getElementAsString('order['+inttostr(i)+'].additional_payment.Price'));
      if StrToFloat(NxSearchReplace(mXMLHead.getElementAsString('order['+inttostr(i)+'].additional_payment.Price'),'.',',',[srAll])) >0 then begin
           NxScriptingLog.WriteEvent(logInfo,'mám cenu');
           mRows:=mReceivedOrderBO.GetCollectionMonikerForFieldCode(mReceivedOrderBO.getfieldcode('Rows'));
           mReceivedOrderRowBO:=mRows.AddNewObject;
           mReceivedOrderRowBO.SetFieldValueAsInteger('RowType',1);
           mReceivedOrderRowBO.SetFieldValueAsString('Text','Spoluúčast pacienta');
           mReceivedOrderRowBO.SetFieldValueAsFloat('TotalPrice',StrToFloat(NxSearchReplace(mXMLHead.getElementAsString('order['+inttostr(i)+'].additional_payment.Price'),'.',',',[srAll]))/1.12);
           mReceivedOrderRowBO.SetFieldValueAsString('VatRate_ID','01200X0000');
           mReceivedOrderRowBO.SetFieldValueAsString('Division_ID',cDivision_ID);
      end;

     end;
     NxScriptingLog.LeaveSection('additional_payment',logInfo);
     if mReceivedOrderBO.GetFieldValueAsString('TransportationType_ID.Code') in ['01','08','V1','09'] then mReceivedOrderBO.SetFieldValueAsString('U_Stav_ID','1300000101');
     mReceivedOrderBO.save;
     AResult :=AResult+('id_eshop:'+mXMLHead.getElementAsString('order['+inttostr(i)+'].orderdata.id')+'|id_abra:'+mReceivedOrderBO.oid+'|Status_ID:'+mReceivedOrderBO.GetFieldValueAsString('U_Stav_ID')+'#');
     mReceivedOrderBO.free;
     end;
     if not(NxIsEmptyOID(mOrder_ID)) then begin
     mReceivedOrderBO:=mOS.CreateObject(Class_ReceivedOrder);
     mReceivedOrderBO.Load(mOrder_ID,nil);
     AResult :=AResult+('id_eshop:'+mXMLHead.getElementAsString('order['+inttostr(i)+'].orderdata.id')+'|id_abra:'+mOrder_ID+'|Status_ID:'+mReceivedOrderBO.GetFieldValueAsString('U_Stav_ID')+'#');
     mReceivedOrderBO.free;
     end;
    End;
    
 Result:=EncodeBase64(TEncoding.Unicode.GetBytes(Aresult));
    
end;

function InsertOrder2(Self: TNxWebServicesHelper; var XMLinput: String):String;
Var
 mXMLinput:string;
 mXMLHead : TNxScriptingXMLWrapper;
 mReceivedOrderBO, mReceivedOrderRowBO: TNxCustomBusinessObject;
 mFirm, mFirmOffice, mStoreCard: TNxCustomBusinessObject;
 mRows, mColl : TNxCustomBusinessMonikerCollection;
 mOS: TNxCustomObjectSpace;
 mFirm_ID, mFirmOffice_ID, mStoreCard_ID, mQuantity, mPrice, mFirmCode, mOrder_ID, mPeriod_ID: String;
 mr1:TstringList;
 mQuantityDouble, mPriceDouble :Double;
 mList:TStringList;
 i,j,d: integer;
 AResult:String;
 mCardBO:TNxCustomBusinessObject;
begin
 Aresult:='';
 Result:='';
 mOS:=self.ObjectSpace;
 mXMLHead := TNxScriptingXMLWrapper.Create;
 //mXMLinput:=DecodeBase64(XMLInput);
 mList:=TStringList.Create;
 //ShowMessage(mXMLInput);
 mXMLHead.loadFromBytes(DecodeBase64(XMLinput));
    for i:=0 to mXMLHead.getElementsCountInArray('order')-1 do begin
    mPeriod_ID:=GetPeriod_ID(mOS,Date);
    mOrder_ID:=scrGetORder_ID(mOS,mXMLHead.getElementAsString('order['+inttostr(i)+'].orderdata.id'), mPeriod_ID);
    if NxIsBlank(mOrder_ID) then begin
    mFirm_ID:='';
    mFirmOffice_ID:='';
    mReceivedOrderBO:=mOS.CreateObject(Class_ReceivedOrder);
    mReceivedOrderBO.New;
    mReceivedOrderBO.Prefill;
    mReceivedOrderBO.SetFieldValueAsString('DocQueue_ID',cDocqueue_ID);
    if ElementExists(mXMLHead, 'order['+inttostr(i)+'].orderdata.doc_queue') then begin
     if not(NxIsEmptyOID(mXMLHead.getElementAsString('order['+inttostr(i)+'].orderdata.doc_queue'))) then
       mReceivedOrderBO.SetFieldValueAsString('DocQueue_ID',mXMLHead.getElementAsString('order['+inttostr(i)+'].orderdata.doc_queue'));
    end;
    mReceivedOrderBO.SetFieldValueAsString('X_ES_ID',(mXMLHead.getElementAsString('order['+inttostr(i)+'].orderdata.id')));
    mReceivedOrderBO.SetFieldValueAsString('BankAccount_ID','1000000101');
    mReceivedOrderBO.SetFieldValueAsBoolean('VatDocument',True);
    mReceivedOrderBO.SetFieldValueAsBoolean('PricesWithVAT',False);
    if not(NxIsEmptyOID(mXMLHead.getElementAsString('order['+inttostr(i)+'].transport.System_ID'))) then mReceivedOrderBO.SetFieldValueAsString('TransportationType_ID',mXMLHead.getElementAsString('order['+inttostr(i)+'].transport.System_ID'));
    if not(NxIsEmptyOID(mXMLHead.getElementAsString('order['+inttostr(i)+'].payment.System_ID'))) then mReceivedOrderBO.SetFieldValueAsString('PaymentType_ID',mXMLHead.getElementAsString('order['+inttostr(i)+'].payment.System_ID'));
    if (mXMLHead.getElementAsString('order['+inttostr(i)+'].transport.Name')='DPD') then mReceivedOrderBO.SetFieldValueAsString('TransportationType_ID','1300000101');
    if (mXMLHead.getElementAsString('order['+inttostr(i)+'].transport.Name')='Česká pošta') then mReceivedOrderBO.SetFieldValueAsString('TransportationType_ID','00000P1000');
    if (StrToFloat(NxSearchReplace(mXMLHead.getElementAsString('order['+inttostr(i)+'].transport.Price'),'.',',',[srAll])) =0) then mReceivedOrderBO.SetFieldValueAsString('TransportationType_ID','00000O1000');

    if mXMLHead.getElementsCountInArray('order['+inttostr(i)+'].invoicedata')>0 then begin
      if not(NxIsEmptyOID(mXMLHead.getElementAsString('order['+inttostr(i)+'].orderdata.firm_system_id'))) then mFirm_ID:=mXMLHead.getElementAsString('order['+inttostr(i)+'].orderdata.firm_system_id');
      // dohledávání dle názvu firmy
      //if NxIsEmptyOID(mFirm_ID) and not(NxIsBlank(Trim(mXMLHead.getElementAsString('order['+inttostr(i)+'].invoicedata.firm')))) then mFirm_ID:=scrFirm_ID(mOS,'Name', Trim(mXMLHead.getElementAsString('order['+inttostr(i)+'].invoicedata.firm')));
      if NxIsEmptyOID(mfirm_id) then mFirm_ID:=scrFirm_ID(mOS,'OrgIdentNumber', Trim(mXMLHead.getElementAsString('order['+inttostr(i)+'].invoicedata.ic')));
      if NxIsEmptyOID(mfirm_id) then mFirm_ID:=scrFirm_ID(mOS,'VatIdentNumber', Trim(mXMLHead.getElementAsString('order['+inttostr(i)+'].invoicedata.dic')));
      if NxIsEmptyOID(mFirm_ID) then mFirm_ID:=GetFirmE_ID(mOS,Trim(mXMLHead.getElementAsString('order['+inttostr(i)+'].orderdata.email')));
    end;
    //dohledávání dle jsména a příjmení
    //if NxIsEmptyOID(mfirm_id) then mFirm_ID:=scrFirm_ID(mOS,'Name', Trim(mXMLHead.getElementAsString('order['+inttostr(i)+'].invoicedata.name')+' '+mXMLHead.getElementAsString('order['+inttostr(i)+'].invoicedata.surname')));
    if NxIsEmptyOID(mFirm_ID) then begin
      mFirm:= mOS.CreateObject('4K3EXM5PQBCL35CH000ILPWJF4');
      mFirmOffice:= mOS.CreateObject('AT011EZZ5DFO115YJ1HCZJDXJ4');
       mFirm.New;
       mFirm.Prefill;
       if not(NxIsBlank(Trim(mXMLHead.getElementAsString('order['+inttostr(i)+'].invoicedata.firm')))) then mFirm.SetFieldValueAsString('name',Trim(mXMLHead.getElementAsString('order['+inttostr(i)+'].invoicedata.firm')));
       if (NxIsBlank(Trim(mXMLHead.getElementAsString('order['+inttostr(i)+'].invoicedata.firm')))) then mFirm.SetFieldValueAsString('Name',Trim(mXMLHead.getElementAsString('order['+inttostr(i)+'].invoicedata.name')+' '+mXMLHead.getElementAsString('order['+inttostr(i)+'].invoicedata.surname')));
       mFirm.SetFieldValueAsString('VatIdentNumber',Trim(mXMLHead.getElementAsString('order['+inttostr(i)+'].invoicedata.dic')));
       mFirm.SetFieldValueAsString('OrgIdentNumber',Trim(mXMLHead.getElementAsString('order['+inttostr(i)+'].invoicedata.ic')));
       mFirm.GetMonikerForFieldCode(mFirm.GetFieldCode('ResidenceAddress_ID')).BusinessObject.SetFieldValueAsString('PostCode',Trim(mXMLHead.getElementAsString('order['+inttostr(i)+'].invoicedata.zip')));
       mFirm.GetMonikerForFieldCode(mFirm.GetFieldCode('ResidenceAddress_ID')).BusinessObject.SetFieldValueAsString('City',Trim(mXMLHead.getElementAsString('order['+inttostr(i)+'].invoicedata.city')));
       mFirm.GetMonikerForFieldCode(mFirm.GetFieldCode('ResidenceAddress_ID')).BusinessObject.SetFieldValueAsString('Street',AnsiLeftStr(Trim(mXMLHead.getElementAsString('order['+inttostr(i)+'].invoicedata.street')),60));
       mFirm.GetMonikerForFieldCode(mFirm.GetFieldCode('ResidenceAddress_ID')).BusinessObject.SetFieldValueAsString('PhoneNumber1',Trim(mXMLHead.getElementAsString('order['+inttostr(i)+'].invoicedata.tel')));
       mFirm.GetMonikerForFieldCode(mFirm.GetFieldCode('ResidenceAddress_ID')).BusinessObject.SetFieldValueAsString('Email',Trim(mXMLHead.getElementAsString('order['+inttostr(i)+'].orderdata.email')));
       //if not(NxIsEmptyOID(Trim(mXMLHead.getElementAsString('order['+inttostr(i)+'].orderdata.pricelist_id')))) then mFirm.SetFieldValueAsString('PriceList_ID',Trim(mXMLHead.getElementAsString('order['+inttostr(i)+'].orderdata.pricelist_id')));
       mfirm.Save;
       mFirm_ID:=mFirm.OID;
       mFirm.Free;
    end;
    if not(NxIsEmptyOID(mFirm_ID)) then begin
        if mXMLHead.getElementsCountInArray('order['+inttostr(i)+'].deliverydata')>0 then begin
         mFirm:= mOS.CreateObject('4K3EXM5PQBCL35CH000ILPWJF4');
         mFirmOffice:= mOS.CreateObject('AT011EZZ5DFO115YJ1HCZJDXJ4');
         mFirm.Load(mFirm_ID,nil);
         mColl := mFirm.GetLoadedCollectionMonikerForFieldCode(mFirm.GetfieldCode('FirmOffices'));
         if not(NxIsEmptyOID(mXMLHead.getElementAsString('order['+inttostr(i)+'].deliverydata.system_id'))) then mFirmOffice_ID:=mXMLHead.getElementAsString('order['+inttostr(i)+'].deliverydata.system_id');
           if (NxIsEmptyOID(mFirmOffice_ID)) and not(Trim(mXMLHead.getElementAsString('order['+inttostr(i)+'].deliverydata.name')+' '+mXMLHead.getElementAsString('order['+inttostr(i)+'].deliverydata.surname'))='') then begin

              for d:=0 to mColl.Count-1 do begin
               // if NxSearch(mcoll.BusinessObject[d].GetFieldValueAsString('Name'),Trim(mXMLHead.getElementAsString('order['+inttostr(i)+'].deliverydata.name')+' '+mXMLHead.getElementAsString('order['+inttostr(i)+'].deliverydata.surname')),[srAll],0)>0 then
                if NxSearch(mcoll.BusinessObject[d].GetFieldValueAsString('Address_ID.Street'),Trim(mXMLHead.getElementAsString('order['+inttostr(i)+'].deliverydata.street')),[srAll],0)>0 then
                mFirmOffice_ID:=mcoll.BusinessObject[d].OID;

              end;
           end;
           if NxIsEmptyOID(mFirmOffice_ID) then begin
            mFirmOffice :=mColl.AddNewObject;
            mFirmOffice.SetFieldValueAsString('Name', Trim(mXMLHead.getElementAsString('order['+inttostr(i)+'].deliverydata.name')+' '+mXMLHead.getElementAsString('order['+inttostr(i)+'].deliverydata.surname')));
            mFirmOffice.SetFieldValueAsBoolean('SynchronizeAddress', False);
            mFirmOffice.GetMonikerForFieldCode(mFirmOffice.GetFieldCode('Address_ID')).BusinessObject.SetFieldValueAsString('City',mXMLHead.getElementAsString('order['+inttostr(i)+'].deliverydata.city'));
            mFirmOffice.GetMonikerForFieldCode(mFirmOffice.GetFieldCode('Address_ID')).BusinessObject.SetFieldValueAsString('PostCode',mXMLHead.getElementAsString('order['+inttostr(i)+'].deliverydata.zip'));
            mFirmOffice.GetMonikerForFieldCode(mFirmOffice.GetFieldCode('Address_ID')).BusinessObject.SetFieldValueAsString('Street',AnsiLeftStr(mXMLHead.getElementAsString('order['+inttostr(i)+'].deliverydata.Street'),60));
            mFirmOffice.GetMonikerForFieldCode(mFirmOffice.GetFieldCode('Address_ID')).BusinessObject.SetFieldValueAsString('PhoneNumber1',mXMLHead.getElementAsString('order['+inttostr(i)+'].deliverydata.tel'));
            mFirmOffice.GetMonikerForFieldCode(mFirmOffice.GetFieldCode('Address_ID')).BusinessObject.SetFieldValueAsString('Email',Trim(mXMLHead.getElementAsString('order['+inttostr(i)+'].orderdata.email')));
            if mFirmOffice.GetFieldValueAsString('Name')='' then mFirmOffice.SetFieldValueAsString('Name', 'Provozovna');
            mFirmOffice_ID := mFirmOffice.OID;
           end;
       mFirm.Save;
       mFirm.Free;
      end;
    end;
    mReceivedOrderBO.SetFieldValueAsString('Firm_ID',mFirm_ID);
    if not(NxIsEmptyOID(mFirmoffice_ID)) then mReceivedOrderBO.SetFieldValueAsString('FirmOffice_ID',mFirmOffice_ID);
    mReceivedOrderBO.SetFieldValueAsString('U_created',mXMLHead.getElementAsString('order['+inttostr(i)+'].orderdata.created'));
    mReceivedOrderBO.SetFieldValueAsString('U_email',mXMLHead.getElementAsString('order['+inttostr(i)+'].orderdata.email'));
    mReceivedOrderBO.SetFieldValueAsString('X_poznamka_memo',mXMLHead.getElementAsString('order['+inttostr(i)+'].orderdata.note'));
    mReceivedOrderBO.SetFieldValueAsString('ExternalNumber',mXMLHead.getElementAsString('order['+inttostr(i)+'].orderdata.id'));
    mReceivedOrderBO.SetFieldValueAsInteger('DealerDiscountKind',0);
    mReceivedOrderBO.SetFieldValueAsBoolean('U_FromES',True);
    if not(NxIsEmptyOID(mXMLHead.getElementAsString('order['+inttostr(i)+'].transport.System_ID'))) then mReceivedOrderBO.SetFieldValueAsString('TransportationType_ID',mXMLHead.getElementAsString('order['+inttostr(i)+'].transport.System_ID'));
    if not(NxIsEmptyOID(mXMLHead.getElementAsString('order['+inttostr(i)+'].payment.System_ID'))) then mReceivedOrderBO.SetFieldValueAsString('PaymentType_ID',mXMLHead.getElementAsString('order['+inttostr(i)+'].payment.System_ID'));

        for j:=0 to  mXMLHead.getElementsCountInArray('order['+inttostr(i)+'].products.product')-1 do begin
          if (mXMLHead.getElementAsFloat('order['+inttostr(i)+'].products.product['+inttostr(j)+'].amount')>0)  and not(nxisemptyoid(mXMLHead.getElementAsString('order['+inttostr(i)+'].products.product['+inttostr(j)+'].system_id')))  and (UpperCase(mXMLHead.getElementAsString('order['+inttostr(i)+'].products.product['+inttostr(j)+'].unit_code'))='JKS') then begin
           mCardBO:=mOS.CreateObject(Class_StoreCard);
           mCardBO.Load(mXMLHead.getElementAsString('order['+inttostr(i)+'].products.product['+inttostr(j)+'].system_id'),nil);
           mRows:=mReceivedOrderBO.GetCollectionMonikerForFieldCode(mReceivedOrderBO.getfieldcode('Rows'));
           mReceivedOrderRowBO:=mRows.AddNewObject;
           mReceivedOrderRowBO.SetFieldValueAsInteger('RowType',2);
           mReceivedOrderRowBO.SetFieldValueAsString('Text',mXMLHead.getElementAsString('order['+inttostr(i)+'].products.product['+inttostr(j)+'].Name'));
           mReceivedOrderRowBO.SetFieldValueAsString('Qunit',mXMLHead.getElementAsString('order['+inttostr(i)+'].products.product['+inttostr(j)+'].unit_code'));
           //mReceivedOrderRowBO.SetFieldValueAsString('Store_ID',cStore_ID);
           mReceivedOrderRowBO.SetFieldValueAsString('Division_ID',cDivision_ID);
           mReceivedOrderRowBO.SetFieldValueAsFloat('UnitQuantity',mXMLHead.getElementAsFloat('order['+inttostr(i)+'].products.product['+inttostr(j)+'].amount'));
           mReceivedOrderRowBO.SetFieldValueAsString('VatRate_ID',mCardBO.GetFieldValueAsString('VatRate_ID'));
           mReceivedOrderRowBO.SetFieldValueAsFloat('UnitPrice',StrToFloat(NxSearchReplace(mXMLHead.getElementAsString('order['+inttostr(i)+'].products.product['+inttostr(j)+'].Price'),'.',',',[srAll])));
           if StrToFloat(NxSearchReplace(mXMLHead.getElementAsString('order['+inttostr(i)+'].products.product['+inttostr(j)+'].Price'),'.',',',[srAll]))=0 then begin
             mReceivedOrderRowBO.SetFieldValueAsFloat('UnitPrice',0);
             mReceivedOrderRowBO.SetFieldValueAsFloat('TotalPrice',0);
           end;
           mCardBO.free;
          end;
          if (mXMLHead.getElementAsFloat('order['+inttostr(i)+'].products.product['+inttostr(j)+'].amount')>0)  and not(nxisemptyoid(mXMLHead.getElementAsString('order['+inttostr(i)+'].products.product['+inttostr(j)+'].system_id')))  and not(UpperCase(mXMLHead.getElementAsString('order['+inttostr(i)+'].products.product['+inttostr(j)+'].unit_code'))='JKS') then begin
           mCardBO:=mOS.CreateObject(Class_StoreCard);
           mCardBO.Load(mXMLHead.getElementAsString('order['+inttostr(i)+'].products.product['+inttostr(j)+'].system_id'),nil);
           mRows:=mReceivedOrderBO.GetCollectionMonikerForFieldCode(mReceivedOrderBO.getfieldcode('Rows'));
           mReceivedOrderRowBO:=mRows.AddNewObject;
           mReceivedOrderRowBO.SetFieldValueAsInteger('RowType',3);
           mReceivedOrderRowBO.SetFieldValueAsString('StoreCard_ID',mXMLHead.getElementAsString('order['+inttostr(i)+'].products.product['+inttostr(j)+'].system_id'));
           mReceivedOrderRowBO.SetFieldValueAsString('Qunit',mXMLHead.getElementAsString('order['+inttostr(i)+'].products.product['+inttostr(j)+'].unit_code'));
           mReceivedOrderRowBO.SetFieldValueAsString('Store_ID',cStore_ID);
           mReceivedOrderRowBO.SetFieldValueAsString('Division_ID',cDivision_ID);
           mReceivedOrderRowBO.SetFieldValueAsFloat('UnitQuantity',mXMLHead.getElementAsFloat('order['+inttostr(i)+'].products.product['+inttostr(j)+'].amount'));
           //mReceivedOrderRowBO.SetFieldValueAsString('VatRate_ID',mCardBO.GetFieldValueAsString('VatRate_ID'));
           mReceivedOrderRowBO.SetFieldValueAsFloat('UnitPrice',StrToFloat(NxSearchReplace(mXMLHead.getElementAsString('order['+inttostr(i)+'].products.product['+inttostr(j)+'].Price'),'.',',',[srAll])));
           if StrToFloat(NxSearchReplace(mXMLHead.getElementAsString('order['+inttostr(i)+'].products.product['+inttostr(j)+'].Price'),'.',',',[srAll]))=0 then begin
             mReceivedOrderRowBO.SetFieldValueAsFloat('UnitPrice',0);
             mReceivedOrderRowBO.SetFieldValueAsFloat('TotalPrice',0);
           end;
           mCardBO.free;
          end;

          if (mXMLHead.getElementAsFloat('order['+inttostr(i)+'].products.product['+inttostr(j)+'].amount')>0)  and (nxisemptyoid(mXMLHead.getElementAsString('order['+inttostr(i)+'].products.product['+inttostr(j)+'].system_id'))) then begin
           mRows:=mReceivedOrderBO.GetCollectionMonikerForFieldCode(mReceivedOrderBO.getfieldcode('Rows'));
           mReceivedOrderRowBO:=mRows.AddNewObject;
           mReceivedOrderRowBO.SetFieldValueAsInteger('RowType',1);
           mReceivedOrderRowBO.SetFieldValueAsString('Text',mXMLHead.getElementAsString('order['+inttostr(i)+'].products.product['+inttostr(j)+'].name'));
           //mReceivedOrderRowBO.SetFieldValueAsFloat('VatRate',21);
           mReceivedOrderRowBO.SetFieldValueAsString('VatRate_ID','02100X0000');
           mReceivedOrderRowBO.SetFieldValueAsString('Division_ID',cDivision_ID);
           mReceivedOrderRowBO.SetFieldValueAsFloat('Quantity',mXMLHead.getElementAsFloat('order['+inttostr(i)+'].products.product['+inttostr(j)+'].amount'));
           mReceivedOrderRowBO.SetFieldValueAsFloat('UnitPrice',StrToFloat(NxSearchReplace(mXMLHead.getElementAsString('order['+inttostr(i)+'].products.product['+inttostr(j)+'].Price'),'.',',',[srAll])));

          end;


        end;
     if StrToFloat(NxSearchReplace(mXMLHead.getElementAsString('order['+inttostr(i)+'].transport.Price'),'.',',',[srAll])) >0 then begin
         mRows:=mReceivedOrderBO.GetCollectionMonikerForFieldCode(mReceivedOrderBO.getfieldcode('Rows'));
           mReceivedOrderRowBO:=mRows.AddNewObject;
           mReceivedOrderRowBO.SetFieldValueAsInteger('RowType',1);
           mReceivedOrderRowBO.SetFieldValueAsString('Text',mXMLHead.getElementAsString('order['+inttostr(i)+'].transport.Name'));
           if StrToFloat(NxSearchReplace(mXMLHead.getElementAsString('order['+inttostr(i)+'].transport.vat'),'.',',',[srAll]))=21 then begin
           mReceivedOrderRowBO.SetFieldValueAsFloat('TotalPrice',StrToFloat(NxSearchReplace(mXMLHead.getElementAsString('order['+inttostr(i)+'].transport.Price'),'.',',',[srAll]))/1.21);
           //mReceivedOrderRowBO.SetFieldValueAsFloat('VatRate',21);
           mReceivedOrderRowBO.SetFieldValueAsString('VatRate_ID','02100X0000');
           end;
           if StrToFloat(NxSearchReplace(mXMLHead.getElementAsString('order['+inttostr(i)+'].transport.vat'),'.',',',[srAll]))=15 then begin
           mReceivedOrderRowBO.SetFieldValueAsFloat('TotalPrice',StrToFloat(NxSearchReplace(mXMLHead.getElementAsString('order['+inttostr(i)+'].transport.Price'),'.',',',[srAll]))/1.15);
           //mReceivedOrderRowBO.SetFieldValueAsFloat('VatRate',15);
           mReceivedOrderRowBO.SetFieldValueAsString('VatRate_ID','01500X0000');
           end;
           if StrToFloat(NxSearchReplace(mXMLHead.getElementAsString('order['+inttostr(i)+'].transport.vat'),'.',',',[srAll]))=12 then begin
           mReceivedOrderRowBO.SetFieldValueAsFloat('TotalPrice',StrToFloat(NxSearchReplace(mXMLHead.getElementAsString('order['+inttostr(i)+'].transport.Price'),'.',',',[srAll]))/1.12);
           //mReceivedOrderRowBO.SetFieldValueAsFloat('VatRate',15);
           mReceivedOrderRowBO.SetFieldValueAsString('VatRate_ID','01200X0000');
           end;
           mReceivedOrderRowBO.SetFieldValueAsString('Division_ID',cDivision_ID);

     end;
     if StrToFloat(NxSearchReplace(mXMLHead.getElementAsString('order['+inttostr(i)+'].payment.Price'),'.',',',[srAll])) >0 then begin
         mRows:=mReceivedOrderBO.GetCollectionMonikerForFieldCode(mReceivedOrderBO.getfieldcode('Rows'));
           mReceivedOrderRowBO:=mRows.AddNewObject;
           mReceivedOrderRowBO.SetFieldValueAsInteger('RowType',1);
           mReceivedOrderRowBO.SetFieldValueAsString('Text',mXMLHead.getElementAsString('order['+inttostr(i)+'].payment.Name'));
           if StrToFloat(NxSearchReplace(mXMLHead.getElementAsString('order['+inttostr(i)+'].payment.vat'),'.',',',[srAll]))=21 then begin
           mReceivedOrderRowBO.SetFieldValueAsFloat('TotalPrice',StrToFloat(NxSearchReplace(mXMLHead.getElementAsString('order['+inttostr(i)+'].payment.Price'),'.',',',[srAll]))/1.21);
           //mReceivedOrderRowBO.SetFieldValueAsFloat('VatRate',21);
           mReceivedOrderRowBO.SetFieldValueAsString('VatRate_ID','02100X0000');
           end;
           if StrToFloat(NxSearchReplace(mXMLHead.getElementAsString('order['+inttostr(i)+'].payment.vat'),'.',',',[srAll]))=15 then begin
           mReceivedOrderRowBO.SetFieldValueAsFloat('TotalPrice',StrToFloat(NxSearchReplace(mXMLHead.getElementAsString('order['+inttostr(i)+'].payment.Price'),'.',',',[srAll]))/1.15);
           //mReceivedOrderRowBO.SetFieldValueAsFloat('VatRate',15);
           mReceivedOrderRowBO.SetFieldValueAsString('VatRate_ID','01500X0000');
           end;
           if StrToFloat(NxSearchReplace(mXMLHead.getElementAsString('order['+inttostr(i)+'].payment.vat'),'.',',',[srAll]))=12 then begin
           mReceivedOrderRowBO.SetFieldValueAsFloat('TotalPrice',StrToFloat(NxSearchReplace(mXMLHead.getElementAsString('order['+inttostr(i)+'].payment.Price'),'.',',',[srAll]))/1.12);
           //mReceivedOrderRowBO.SetFieldValueAsFloat('VatRate',15);
           mReceivedOrderRowBO.SetFieldValueAsString('VatRate_ID','01200X0000');
           end;
           mReceivedOrderRowBO.SetFieldValueAsString('Division_ID',cDivision_ID);

     end;
     if mReceivedOrderBO.GetFieldValueAsString('TransportationType_ID.Code') in ['01','08','V1','09'] then mReceivedOrderBO.SetFieldValueAsString('U_Stav_ID','1300000101');
     mReceivedOrderBO.save;
     AResult :=AResult+('id_eshop:'+mXMLHead.getElementAsString('order['+inttostr(i)+'].orderdata.id')+'|id_abra:'+mReceivedOrderBO.oid+'|Status_ID:'+mReceivedOrderBO.GetFieldValueAsString('U_Stav_ID')+'#');
     mReceivedOrderBO.free;
     end;
     if not(NxIsEmptyOID(mOrder_ID)) then begin
     mReceivedOrderBO:=mOS.CreateObject(Class_ReceivedOrder);
     mReceivedOrderBO.Load(mOrder_ID,nil);
     AResult :=AResult+('id_eshop:'+mXMLHead.getElementAsString('order['+inttostr(i)+'].orderdata.id')+'|id_abra:'+mOrder_ID+'|Status_ID:'+mReceivedOrderBO.GetFieldValueAsString('U_Stav_ID')+'#');
     mReceivedOrderBO.free;
     end;
    End;

 Result:=EncodeBase64(TEncoding.Unicode.GetBytes(Aresult));

end;


{Funkce GetExport na základě hodnoty ExportType vrátí xml soubor

  ExportType=0 vrací Skladové Menu
  ExportType=1 vrací Skladové karty
  ExportType=2 vrací firmy
  ExportType=3 vrací sortimentní skupiny
  ExportType=4 vrací množství
  ExportType=5 vrací šarže, barvy
  ExportType=6 vrací ceniky
  ExportType=7 vrací akcni ceniky
  
  pro exporttype=1 nebo 2 je možno i druhý parametr, počet dnů dozadu od kterého se vyhrají firmy nebo karty,
  které byly změněny nebo vytvořenyy

}
function GetExport(var Self: TNxWebServicesHelper;var ExportType: Integer; var DayOffset: Integer):String;
var
  mObjectSpace: TNxCustomObjectSpace;
  mIDsList, mOutputList: TStringList;
  mSQL,mExportID, mDynSource, mFileName: String;
  mContext: TNxContext;
  mCreatedDate,mCorrectedDate:Extended;
  


begin
  Result:='';
  mIDsList:=TStringList.Create;
  mOutputList:=TStringList.Create;
  mObjectSpace := Self.ObjectSpace;
  mContext := NxCreateContext(mObjectSpace);
  if ExportType=0 then begin
      msql:=conSQL0;
      mExportID:=conExportID0;
      mFileName:=conFileName0;
      mDynSource:=conDynSource0;
      
  end;
  if ExportType=1 then begin
      if DayOffset>0 then begin;
      mCorrectedDate:=Date-DayOffset;
      mCreatedDate:=Date-DayOffset;
      mSQL:= format(conSQL1d, [IntToStr(trunc(mCreatedDate)), IntToStr(trunc(mCorrectedDate))]);
      end;
      if DayOffset=0 then msql:=conSQL1;
      mExportID:=conExportID1;
      mFileName:=conFileName1;
      mDynSource:=conDynSource1;

  end;
  if ExportType=2 then begin
      if DayOffset>0 then begin;
      mCorrectedDate:=Date-DayOffset;
      mCreatedDate:=Date-DayOffset;
      mSQL:= format(conSQL2d, [IntToStr(trunc(mCreatedDate)), IntToStr(trunc(mCorrectedDate))]);
      end;
      if DayOffset=0 then msql:=conSQL2;
      mExportID:=conExportID2;
      mFileName:=conFileName2;
      mDynSource:=conDynSource2;

  end;
  if ExportType=3 then begin
      msql:=conSQL3;
      mExportID:=conExportID3;
      mFileName:=conFileName3;
      mDynSource:=conDynSource3;

  end;
  if ExportType=4 then begin
      msql:=conSQL4;
      mExportID:=conExportID4;
      mFileName:=conFileName4;
      mDynSource:=conDynSource4;

  end;
  {if ExportType=5 then begin
      msql:=conSQL5;
      mExportID:=conExportID5;
      mFileName:=conFileName5;
      mDynSource:=conDynSource5;

  end;}
  if ExportType=6 then begin
      msql:=conSQL6;
      mExportID:=conExportID6;
      mFileName:=conFileName6;
      mDynSource:=conDynSource6;

  end;
  if ExportType=7 then begin
      msql:=conSQL7;
      mExportID:=conExportID7;
      mFileName:=conFileName7;
      mDynSource:=conDynSource7;

  end;
  if ExportType=8 then begin
      msql:=conSQL8;
      mExportID:=conExportID8;
      mFileName:=conFileName8;
      mDynSource:=conDynSource8;

  end;
  if ExportType=9 then begin
      msql:=conSQL9;
      mExportID:=conExportID9;
      mFileName:=conFileName9;
      mDynSource:=conDynSource9;

  end;
  if ExportType=10 then begin
      msql:=conSQL10;
      mExportID:=conExportID10;
      mFileName:=conFileName10;
      mDynSource:=conDynSource10;

  end;
   if ExportType=11 then begin
      if DayOffset>0 then begin;
      mCorrectedDate:=Date-DayOffset;
      mCreatedDate:=Date-DayOffset;
      mSQL:= format(conSQL11d, [IntToStr(trunc(mCreatedDate)), IntToStr(trunc(mCorrectedDate))]);
      end;
      if DayOffset=0 then msql:=conSQL11;
      mExportID:=conExportID11;
      mFileName:=conFileName11;
      mDynSource:=conDynSource11;

  end;
  mObjectSpace.SQLSelect(mSQL, mIDsList);
  if mIDsList.count=0 then Result:=EncodeBase64(TEncoding.UTF8.GetBytes('<?xml version="1.0" encoding="UTF-16"?><Results>No Entry</Results>'));
  if mIDsList.count>0 then begin
       NxExportByIDs(mContext,mIDsList,mDynSource,mExportID,0,'',mFileName);
        if FileExists(mFileName) then begin
          mOutputList.Clear;
          mOutputList.LoadFromFile(mFileName);
          Result:=EncodeBase64(TEncoding.UTF8.GetBytes(mOutputList.text));
          DeleteFile(mFilename);
        end;
  end;
  //DeleteFile(mFileName);
  mContext.Free;
  mIDsList.Free;
  mOutputList.Free;

end;

function GetOrderInfo(Self: TNxWebServicesHelper;Order_ID: String):String;
var
 mResultList, mOutputList:TStringList;
 mFilename:String;

begin
     mResultList:=TStringList.Create;
     mOutputList:=TStringList.Create;
     mResultList.Add(Order_ID);
     if not(NxIsEmptyOID(Order_ID)) then begin
     mFileName:='c:\eshop\Orders2.xml';
      if mResultList.count>0 then begin
       CFxReportManager.ExportByIDs(NxCreateContext(self.ObjectSpace),mResultList,'40V53DORW3DL342X01C0CX3FCC','IE00000101',0,'',mFileName);
        if FileExists(mFileName) then begin
          mOutputList.Clear;
          mOutputList.LoadFromFile(mFileName);
          Result:=EncodeBase64(TEncoding.UTF8.GetBytes(mOutputList.text));
          DeleteFile(mFilename);
        end;
      end;
     end;


end;

function GetOrderInfoWebli(Self: TNxWebServicesHelper;Order_ID: String):String;
var
 mResultList, mOutputList:TStringList;
 mFilename:String;

begin
     mResultList:=TStringList.Create;
     mOutputList:=TStringList.Create;
     mResultList.Add(Order_ID);
     if not(NxIsEmptyOID(Order_ID)) then begin
     mFileName:='c:\eshop\OrdersWebli.xml';
      if mResultList.count>0 then begin
       CFxReportManager.ExportByIDs(NxCreateContext(self.ObjectSpace),mResultList,'40V53DORW3DL342X01C0CX3FCC','IE00000101',0,'',mFileName);
        if FileExists(mFileName) then begin
          mOutputList.Clear;
          mOutputList.LoadFromFile(mFileName);
          Result:=EncodeBase64(TEncoding.UTF8.GetBytes(mOutputList.text));
          DeleteFile(mFilename);
        end;
      end;
     end;


end;

function GetInvoiceInfo(Self: TNxWebServicesHelper;Invoice_ID: String):String;
var
 mResultList, mOutputList:TStringList;
 mFilename:String;

begin
     mResultList:=TStringList.Create;
     mOutputList:=TStringList.Create;
     mResultList.Add(Invoice_ID);
     if not(NxIsEmptyOID(Invoice_ID)) then begin
     mFileName:='c:\eshop\Invoice.xml';
      if mResultList.count>0 then begin
       CFxReportManager.ExportByIDs(NxCreateContext(self.ObjectSpace),mResultList,'40SBPEINEFD13ACM03KIU0CLP4','IF00000101',0,'',mFileName);
        if FileExists(mFileName) then begin
        mOutputList.Clear;
          mOutputList.LoadFromFile(mFileName);
          Result:=EncodeBase64(TEncoding.UTF8.GetBytes(mOutputList.text));
          DeleteFile(mFilename);
        end;
      end;
     end;


end;


function GetInvoiceForExtNumber(Self: TNxWebServicesHelper;ExternalNumber: String):String;
var
 mResultList, mOutputList:TStringList;
 mFilename:String;

begin
     mResultList:=TStringList.Create;
     mOutputList:=TStringList.Create;
     self.ObjectSpace.SQLSelect(format('select ii2.parent_id from receivedorders ro '+
                                       'left join receivedorders2 ro2 on ro.id=ro2.parent_id '+
                                       'left join storedocuments2 sd2 on sd2.ProvideRow_id=ro2.id '+
                                       'left join issuedinvoices2 ii2 on ii2.ProvideRow_ID=sd2.id '+
                                       'where ro.externalnumber=''%s'' group by ii2.parent_id ',[ExternalNumber]),mResultList);
     if mResultList.count>0 then begin
     mFileName:='c:\eshop\Invoice.xml';
      if mResultList.count>0 then begin
       CFxReportManager.ExportByIDs(NxCreateContext(self.ObjectSpace),mResultList,'40SBPEINEFD13ACM03KIU0CLP4','IF00000101',0,'',mFileName);
        if FileExists(mFileName) then begin
        mOutputList.Clear;
          mOutputList.LoadFromFile(mFileName);
          Result:=EncodeBase64(TEncoding.UTF8.GetBytes(mOutputList.text));
        end;
      end;
     end;


end;

function PrintInvoice(Self: TNxWebServicesHelper;Invoice_ID: String):String;
Var
 mFileName, mSQL:STring;
 moutputlist, mResultList:TStringList;
 mContext:TNxContext;
 mOS:TNxCustomObjectSpace;
begin
 mOS:=self.ObjectSpace;
 mResultList:=TStringList.Create;
 mOutputList:=TStringList.Create;
 mContext := NxCreateContext(mOS);
  mFileName:=Invoice_ID+'.pdf';
  if not(NxIsEmptyOID(Invoice_ID)) then mResultList.Add(Invoice_ID);
  if mResultList.count>0 then begin
       //NxPrintByIDs(self.Context,mResultList,'40SBPEINEFD13ACM03KIU0CLP4','2520000101',rtoFile,pekExcelGraphic,'E:\ABRA\PAPILLONS\ABRAG2\eshop\',mFileName);
       NxPrintByIDs(self.Context,mResultList,'40SBPEINEFD13ACM03KIU0CLP4','W400000101',rtoFile,pekPDF,'c:\SERVER\ABRA\AbraG2\htdocs\invoices\',mFileName);
        if FileExists('c:\SERVER\ABRA\AbraG2\htdocs\invoices\' + mFileName) then begin
          Result:='http://hq.untraco.cz:8080/invoices/' + mFileName;
          //mOutputList.Clear;
          //mOutputList.LoadFromFile('E:\ABRA\PAPILLONS\ABRAG2\eshop\'+mFileName);
          //Result:=EncodeBase64(mOutputList.text);
        end;
  end;
  DeleteFile('C:\eshop\' + mFileName);
  mContext.Free;
  mResultList.Free;
  mOutputList.Free;

end;

function UpdateOrderRow(Self: TNxWebServicesHelper;XMLinput: String):String;
begin
end;

function InsertOrderRow(Self: TNxWebServicesHelper;XMLinput: String):String;
begin
end;

function DeleteOrderRow(Self: TNxWebServicesHelper;XMLinput: String):String;
begin
end;



begin
end.