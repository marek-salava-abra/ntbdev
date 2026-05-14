

uses
    'eu.abra.eshop.const', 'eu.abra.eshop.fce', 'eu.simon.emaileshop.mail', 'eu.simon.eshop.mail';

//aaa

function GetStoreCardPrice(Self: TNxWebServicesHelper;StoreCard_ID: String):Extended;
var
 mList:TstringList;
begin
 Result:=0;
 mList:=TStringList.Create;
 self.ObjectSpace.SQLSelect(format('SELECT sp2.Amount FROM StorePrices SP LEFT JOIN StorePrices2 SP2 ON SP.ID = SP2.Parent_ID WHERE SP2.Price_ID=''1000000101'' AND SP.PriceList_ID=''1800000101''AND SP.StoreCard_ID=''%s'' ',[StoreCard_ID]),mList);
 Result:=NxIBStrToFloat(mlist.Strings[0]);
end;

function GetStoreCardActionPrice(Self: TNxWebServicesHelper;StoreCard_ID: String):Extended;
var
 mList:TstringList;
begin
 Result:=0;
 mList:=TStringList.Create;
 self.ObjectSpace.SQLSelect(format('SELECT sp2.Amount FROM ActionStorePrices SP LEFT JOIN ActionStorePrices2 SP2 ON SP.ID = SP2.Parent_ID WHERE SP2.Price_ID=''1000000101'' AND SP.PriceList_ID=''1700000101''AND SP.StoreCard_ID=''%s'' ',[StoreCard_ID]),mList);
 Result:=NxIBStrToFloat(mlist.Strings[0]);
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
 mList, mResultList:TStringList;
 i,j,d: integer;
 AResult:String;
 mFileName, mFileName2:String;
 mAccount_ID:string;
 mCheckResult: integer;
  mCheckResultText: string;
  mCheckResultShortText: string;
  mLastCheckDateTime: TDateTime;
  mMessage: string;
  mStream, mFile, mListPrint:TStringList;
  mTempfileName, mObsah:string;
  mVIES, mNewsLetter:Boolean;
begin
 Aresult:='';
 Result:='';
 mTempfileName:='';
 mOS:=self.ObjectSpace;
 mXMLHead := TNxScriptingXMLWrapper.Create;
 //mXMLinput:=DecodeBase64(XMLInput);
 mList:=TStringList.Create;
 NxScriptingLog.EnterSection('InsertOrder ',logInfo);
 try
 mStream:=TStringList.Create;
 mStream.Add(TEncoding.UTF8.GetString(DecodeBase64(XMLinput)));
 mStream.SaveToFile('d:\abraGen\test.xml');
 mStream.SaveToFile('d:\abragen\temp\source'+FormatDateTime('YYYYMMDDHHnnsszzz',Now)+'.xml');
 mFile := TStringList.Create();
   if FileExists('d:\abragen\test.xml') then begin
    mFile.LoadFromFile('d:\abragen\test.xml');
    //mfile.Delete(0);
    mFile.Strings[0]:='<?xml version="1.0" encoding="windows-1250"?>';
    //NxSearchReplace(mFile.strings[0],'utf-8','windows-1250',[srAll]);
    mfile.SaveToFile('d:\abragen\test.xml');
    mFile.SaveToFile('d:\abragen\temp\test'+FormatDateTime('YYYYMMDDHHnnsszzz',Now)+'.xml');
    mfile.Free;
   end;
  //mXMLHead := TNxScriptingXMLWrapper.Create;
 mXMLHead.loadFromFile('d:\abraGen\test.xml');
 //mXMLHead.loadFromBytes(DecodeBase64(XMLinput));
 NxScriptingLog.WriteEvent(logInfo, 'InsertOrder Start '+mXMLHead.getElementAsString('order['+inttostr(i)+'].orderdata.id'));
 mXMLHead.saveToFile('d:\wamp\www\orders\'+mXMLHead.getElementAsString('order['+inttostr(i)+'].orderdata.id')+FormatDateTime('YYYYMMDDHHSS',Now)+'.xml');
    for i:=0 to mXMLHead.getElementsCountInArray('order')-1 do begin
    //mPeriod_ID:='2V00000101';
    if not(NxIsBlank(mXMLHead.getElementAsString('order['+inttostr(i)+'].orderdata.id'))) then mOrder_ID:=scrGetORder_ID(mOS,mXMLHead.getElementAsString('order['+inttostr(i)+'].orderdata.id'));
    if not(NxIsEmptyOID(mOrder_ID)) then
        SendInternalMail2(self.ObjectSpace,'eshop@naradi-simon.cz',
        '','', 'pokus o opakované nahrání '+mXMLHead.getElementAsString('order['+inttostr(i)+'].orderdata.id'),
        'chyba nahrávání','', 'AAA1000000',
                   '1400000101','1000000101','');


    if NxIsBlank(mOrder_ID) then begin
    mFirm_ID:='';
    mFirmOffice_ID:='';
    mObsah:='';
    mNewsLetter:=False;
    mReceivedOrderBO:=mOS.CreateObject('01CPMINJW3DL342X01C0CX3FCC');
    mReceivedOrderBO.New;
    mReceivedOrderBO.Prefill;
    mReceivedOrderBO.SetFieldValueAsString('DocQueue_ID',cDocqueue_ID);
    mReceivedOrderBO.SetFieldValueAsString('CreatedBy_ID','1C10000101');
    if UpperCase(mXMLHead.getElementAsString('order['+inttostr(i)+'].Newsletter'))='ANO' then mNewsLetter:=true;
    mReceivedOrderBO.SetFieldValueAsString('U_OrderState_ID','5C92000101');
    if not(NxIsEmptyOID(mXMLHead.getElementAsString('order['+inttostr(i)+'].transport.System_ID'))) then mReceivedOrderBO.SetFieldValueAsString('TransportationType_ID',mXMLHead.getElementAsString('order['+inttostr(i)+'].transport.System_ID'));
    if not(NxIsEmptyOID(mXMLHead.getElementAsString('order['+inttostr(i)+'].payment.System_ID'))) then mReceivedOrderBO.SetFieldValueAsString('PaymentType_ID',mXMLHead.getElementAsString('order['+inttostr(i)+'].payment.System_ID'));
    if (mXMLHead.getElementAsString('order['+inttostr(i)+'].transport.Name')='DPD') then mReceivedOrderBO.SetFieldValueAsString('TransportationType_ID','1300000101');
    if (mXMLHead.getElementAsString('order['+inttostr(i)+'].transport.Name')='Česká pošta') then mReceivedOrderBO.SetFieldValueAsString('TransportationType_ID','00000P1000');
    if (mXMLHead.getElementAsString('order['+inttostr(i)+'].transport.System_ID') in ['2260000101','4260000101','5260000101','6260000101','7260000101','8260000101','9260000101','C260000101','2280000101']) then mReceivedOrderBO.SetFieldValueAsString('TransportationType_ID','2230000101');
    if (mXMLHead.getElementAsString('order['+inttostr(i)+'].transport.System_ID') in ['D260000101','E260000101','F260000101','G260000101','H260000101','I260000101']) then mReceivedOrderBO.SetFieldValueAsString('TransportationType_ID','2000000101');
    if (mXMLHead.getElementAsString('order['+inttostr(i)+'].transport.System_ID') in ['A260000101']) then mReceivedOrderBO.SetFieldValueAsString('TransportationType_ID','00000P1000');
    if (mXMLHead.getElementAsString('order['+inttostr(i)+'].transport.System_ID') in ['B260000101']) then mReceivedOrderBO.SetFieldValueAsString('TransportationType_ID','4100000101');
    if (mReceivedOrderBO.GetFieldValueAsString('PaymentType_ID')='6000000101') then  mReceivedOrderBO.SetFieldValueAsString('BankAccount_ID','1000000101');
    //if (StrToFloat(NxSearchReplace(mXMLHead.getElementAsString('order['+inttostr(i)+'].transport.Price'),'.',',',[srAll])) =0) 00000O1000 then mReceivedOrderBO.SetFieldValueAsString('TransportationType_ID','00000O1000');
    if (mReceivedOrderBO.GetFieldValueAsString('TransportationType_ID')='00000O1000') and (mReceivedOrderBO.GetFieldValueAsString('PaymentType_ID')='6000000101')  then mReceivedOrderBO.SetFieldValueAsString('U_OrderState_ID','57E2000101');
    if mXMLHead.getElementsCountInArray('order['+inttostr(i)+'].invoicedata')>0 then begin
      if not(NxIsEmptyOID(mXMLHead.getElementAsString('order['+inttostr(i)+'].orderdata.firm_system_id'))) then mFirm_ID:=mXMLHead.getElementAsString('order['+inttostr(i)+'].orderdata.firm_system_id');
      // dohledávání dle názvu firmy
      //if NxIsEmptyOID(mFirm_ID) and not(NxIsBlank(Trim(mXMLHead.getElementAsString('order['+inttostr(i)+'].invoicedata.firm')))) then mFirm_ID:=scrFirm_ID(mOS,'Name', Trim(mXMLHead.getElementAsString('order['+inttostr(i)+'].invoicedata.firm')));
      if NxIsEmptyOID(mfirm_id) then mFirm_ID:=scrFirm_ID(mOS,'OrgIdentNumber', Trim(mXMLHead.getElementAsString('order['+inttostr(i)+'].invoicedata.ic')));
      if NxIsEmptyOID(mfirm_id) then mFirm_ID:=scrFirm_ID(mOS,'VatIdentNumber', Trim(mXMLHead.getElementAsString('order['+inttostr(i)+'].invoicedata.dic')));
      end;
    //dohledávání dle jsména a příjmení

    //zkusit dle ič na ARES
    if NxIsEmptyOID(mfirm_id) and NxIsBlank(Trim(mXMLHead.getElementAsString('order['+inttostr(i)+'].invoicedata.ic'))) then mFirm_ID:=scrFirm2_ID(mOS, Trim(mXMLHead.getElementAsString('order['+inttostr(i)+'].orderdata.email')));
    if NxIsEmptyOID(mFirm_ID) then begin
      mFirm:= mOS.CreateObject('4K3EXM5PQBCL35CH000ILPWJF4');
      mFirmOffice:= mOS.CreateObject('AT011EZZ5DFO115YJ1HCZJDXJ4');
       mFirm.New;
       mFirm.Prefill;
       if not(NxIsBlank(Trim(mXMLHead.getElementAsString('order['+inttostr(i)+'].invoicedata.firm')))) then mFirm.SetFieldValueAsString('name',Trim((mXMLHead.getElementAsString('order['+inttostr(i)+'].invoicedata.firm'))));
       if (NxIsBlank(Trim(mXMLHead.getElementAsString('order['+inttostr(i)+'].invoicedata.firm')))) then mFirm.SetFieldValueAsString('Name',Trim(mXMLHead.getElementAsString('order['+inttostr(i)+'].invoicedata.name')+' '+mXMLHead.getElementAsString('order['+inttostr(i)+'].invoicedata.surname')));
       mFirm.SetFieldValueAsString('VatIdentNumber',ansileftstr(Trim(mXMLHead.getElementAsString('order['+inttostr(i)+'].invoicedata.dic')),20));
       mFirm.SetFieldValueAsString('OrgIdentNumber',ansileftstr(Trim(mXMLHead.getElementAsString('order['+inttostr(i)+'].invoicedata.ic')),15));
       mFirm.GetMonikerForFieldCode(mFirm.GetFieldCode('ResidenceAddress_ID')).BusinessObject.SetFieldValueAsString('PostCode',Ansileftstr(Trim(mXMLHead.getElementAsString('order['+inttostr(i)+'].invoicedata.zip')),10));
       mFirm.GetMonikerForFieldCode(mFirm.GetFieldCode('ResidenceAddress_ID')).BusinessObject.SetFieldValueAsString('City',ansileftstr(Trim(mXMLHead.getElementAsString('order['+inttostr(i)+'].invoicedata.city')),60));
       mFirm.GetMonikerForFieldCode(mFirm.GetFieldCode('ResidenceAddress_ID')).BusinessObject.SetFieldValueAsString('Street',Ansileftstr(Trim(mXMLHead.getElementAsString('order['+inttostr(i)+'].invoicedata.street')),60));
       mFirm.GetMonikerForFieldCode(mFirm.GetFieldCode('ResidenceAddress_ID')).BusinessObject.SetFieldValueAsString('PhoneNumber1',AnsiLeftStr(Trim(mXMLHead.getElementAsString('order['+inttostr(i)+'].invoicedata.tel')),30));
       mFirm.GetMonikerForFieldCode(mFirm.GetFieldCode('ResidenceAddress_ID')).BusinessObject.SetFieldValueAsString('Email',Trim(mXMLHead.getElementAsString('order['+inttostr(i)+'].orderdata.email')));
       mFirm.GetMonikerForFieldCode(mFirm.GetFieldCode('ResidenceAddress_ID')).BusinessObject.SetFieldValueAsString('Recipient',Trim(mXMLHead.getElementAsString('order['+inttostr(i)+'].invoicedata.name')));
       mFirm.SetFieldValueAsString('ResidenceAddress_ID.CountryCode','CZ');
       mFirm.SetFieldValueAsString('ResidenceAddress_ID.Country','Česká republika');

       if Trim(mXMLHead.getElementAsString('order['+inttostr(i)+'].invoicedata.COUNTRY_CODE'))='SLOVENSKO' then begin
         mFirm.SetFieldValueAsString('ResidenceAddress_ID.CountryCode','SK');
         mFirm.SetFieldValueAsString('ResidenceAddress_ID.Country','Slovenská republika');
       end;
       mfirm.Save;
       InsolvencyCheck.CheckSubject(mFirm,
      '', '', '', 0,
      mCheckResult, mCheckResultText, mCheckResultShortText, mLastCheckDateTime,
      mMessage,
      True);
       mFirm_ID:=mFirm.OID;
       mFirm.Free;
    end;
    if not(NxIsEmptyOID(mFirm_ID)) then begin
        if mXMLHead.getElementsCountInArray('order['+inttostr(i)+'].deliverydata')>0 then begin
         mFirm:= mOS.CreateObject('4K3EXM5PQBCL35CH000ILPWJF4');
         mFirmOffice:= mOS.CreateObject('AT011EZZ5DFO115YJ1HCZJDXJ4');
         mFirm.Load(mFirm_ID,nil);
          InsolvencyCheck.CheckSubject(mFirm,
      '', '', '', 0,
      mCheckResult, mCheckResultText, mCheckResultShortText, mLastCheckDateTime,
      mMessage,
      True);
        if Trim(mXMLHead.getElementAsString('order['+inttostr(i)+'].invoicedata.COUNTRY_CODE'))='SLOVENSKO' then begin
          mVIES:=false;
          if not(NxIsBlank(mFirm.GetFieldValueAsString('VatIdentNumber')))then begin
            if NxIsEmptyOID(mFirm.GetFieldValueAsString('VATCountry_ID')) then begin
              mVIES:=VIESCheckVAT.CheckSubject(mFirm,'','','',0, mCheckResult, mCheckResultText, mLastCheckDateTime, mMessage);
              if mVIES then begin
                mFirm.SetFieldValueAsString('VATCountry_ID','00000SK000');
                mFirm.SetFieldValueAsBoolean('VATPayor',true);
              end;
            end;
          end;
        end;
         mColl := mFirm.GetLoadedCollectionMonikerForFieldCode(mFirm.GetfieldCode('FirmOffices'));
         if not(NxIsEmptyOID(mXMLHead.getElementAsString('order['+inttostr(i)+'].deliverydata.system_id'))) then mFirmOffice_ID:=mXMLHead.getElementAsString('order['+inttostr(i)+'].deliverydata.system_id');
           if (NxIsEmptyOID(mFirmOffice_ID)) and not(Trim(mXMLHead.getElementAsString('order['+inttostr(i)+'].deliverydata.name')+' '
           +mXMLHead.getElementAsString('order['+inttostr(i)+'].deliverydata.surname'))='') then begin

              for d:=0 to mColl.Count-1 do begin
               // if NxSearch(mcoll.BusinessObject[d].GetFieldValueAsString('Name'),Trim(mXMLHead.getElementAsString('order['+inttostr(i)+'].deliverydata.name')+' '+mXMLHead.getElementAsString('order['+inttostr(i)+'].deliverydata.surname')),[srAll],0)>0 then

                if NxSearch(mcoll.BusinessObject[d].GetFieldValueAsString('Address_ID.Street'),Trim(mXMLHead.getElementAsString('order['+inttostr(i)+'].deliverydata.street')),[srAll],0)>0 then begin
                 if NxSearch(mcoll.BusinessObject[d].GetFieldValueAsString('Address_ID.Recipient'),Trim(mXMLHead.getElementAsString('order['+inttostr(i)+'].invoicedata.name')),[srAll],0)>0 then begin
                  if NxSearch(mcoll.BusinessObject[d].GetFieldValueAsString('Address_ID.Email'),Trim(mXMLHead.getElementAsString('order['+inttostr(i)+'].orderdata.email')),[srAll],0)>0 then begin
                    mFirmOffice_ID:=mcoll.BusinessObject[d].OID;
                    if mNewsLetter then begin
                      mColl.BusinessObject[d].SetFieldValueAsBoolean('X_CommercialsAgreement',true);
                      mColl.BusinessObject[d].SetFieldValueAsDateTime('X_AgreementFrom$Date',Now);
                    end;
                  end;
                 end;
                end;
              end;
           end;
           if NxIsEmptyOID(mFirmOffice_ID) then begin
            mFirmOffice :=mColl.AddNewObject;
            mFirmOffice.SetFieldValueAsString('Name', Trim(mXMLHead.getElementAsString('order['+inttostr(i)+'].deliverydata.name')+' '+mXMLHead.getElementAsString('order['+inttostr(i)+'].deliverydata.surname')));
            if AnsiLeftStr(mFirmOffice.GetFieldValueAsString('Name'),10)='Balíkovna ' then mFirmOffice.SetFieldValueAsString('Name',Trim(mXMLHead.getElementAsString('order['+inttostr(i)+'].invoicedata.name')));
            if AnsiLeftStr(mFirmOffice.GetFieldValueAsString('Name'),6)='Pošta ' then mFirmOffice.SetFieldValueAsString('Name',Trim(mXMLHead.getElementAsString('order['+inttostr(i)+'].invoicedata.name')));
            if mXMLHead.getElementAsString('order['+inttostr(i)+'].transport.code')='P93' then mFirmOffice.SetFieldValueAsString('Name',Trim(mXMLHead.getElementAsString('order['+inttostr(i)+'].invoicedata.name')));
            mFirmOffice.SetFieldValueAsBoolean('SynchronizeAddress', False);
            mFirmOffice.GetMonikerForFieldCode(mFirmOffice.GetFieldCode('Address_ID')).BusinessObject.SetFieldValueAsString('City',mXMLHead.getElementAsString('order['+inttostr(i)+'].deliverydata.city'));
            mFirmOffice.GetMonikerForFieldCode(mFirmOffice.GetFieldCode('Address_ID')).BusinessObject.SetFieldValueAsString('PostCode',AnsiLeftStr(mXMLHead.getElementAsString('order['+inttostr(i)+'].deliverydata.zip'),10));
            mFirmOffice.GetMonikerForFieldCode(mFirmOffice.GetFieldCode('Address_ID')).BusinessObject.SetFieldValueAsString('Street',Ansileftstr(mXMLHead.getElementAsString('order['+inttostr(i)+'].deliverydata.Street'),60));
            mFirmOffice.GetMonikerForFieldCode(mFirmOffice.GetFieldCode('Address_ID')).BusinessObject.SetFieldValueAsString('PhoneNumber1',mXMLHead.getElementAsString('order['+inttostr(i)+'].deliverydata.tel'));
            mFirmOffice.GetMonikerForFieldCode(mFirmOffice.GetFieldCode('Address_ID')).BusinessObject.SetFieldValueAsString('Email',Trim(mXMLHead.getElementAsString('order['+inttostr(i)+'].orderdata.email')));
            mFirmOffice.GetMonikerForFieldCode(mFirmOffice.GetFieldCode('Address_ID')).BusinessObject.SetFieldValueAsString('Recipient',Trim(mXMLHead.getElementAsString('order['+inttostr(i)+'].invoicedata.name')));
            if mFirmOffice.GetFieldValueAsString('Name')='' then mFirmOffice.SetFieldValueAsString('Name', 'Provozovna');
             mFirmOffice.SetFieldValueAsString('Address_ID.CountryCode','CZ');
             mFirmOffice.SetFieldValueAsString('Address_ID.Country','Česká republika');

             if Trim(mXMLHead.getElementAsString('order['+inttostr(i)+'].deliverydata.COUNTRY_CODE'))='SLOVENSKO' then begin
               mFirmOffice.SetFieldValueAsString('Address_ID.CountryCode','SK');
               mFirmOffice.SetFieldValueAsString('Address_ID.Country','Slovenská republika');
             end;
             if mNewsLetter then begin
              mFirmOffice.SetFieldValueAsBoolean('X_CommercialsAgreement',true);
              mFirmOffice.SetFieldValueAsDateTime('X_AgreementFrom$Date',Now);
            end;
            mFirmOffice_ID := mFirmOffice.OID;
           end;
       mFirm.Save;
       mFirm.Free;
      end;
    end;
    mReceivedOrderBO.SetFieldValueAsString('Firm_ID',mFirm_ID);
    if not(NxIsEmptyOID(mFirmoffice_ID)) then mReceivedOrderBO.SetFieldValueAsString('FirmOffice_ID',mFirmOffice_ID);
    mReceivedOrderBO.SetFieldValueAsInteger('DealerDiscountKind',0);
    mReceivedOrderBO.SetFieldValueAsBoolean('FrozenDiscounts',true);
    mReceivedOrderBO.SetFieldValueAsString('X_AES_D_Street',Ansileftstr(mXMLHead.getElementAsString('order['+inttostr(i)+'].deliverydata.Street'),30));
    mReceivedOrderBO.SetFieldValueAsString('X_AES_D_City',mXMLHead.getElementAsString('order['+inttostr(i)+'].deliverydata.city'));
    mReceivedOrderBO.SetFieldValueAsString('X_AES_D_PostCode',Ansileftstr(mXMLHead.getElementAsString('order['+inttostr(i)+'].deliverydata.zip'),30));
    mReceivedOrderBO.SetFieldValueAsString('ExternalNumber',mXMLHead.getElementAsString('order['+inttostr(i)+'].orderdata.id'));
    mReceivedOrderBO.SetFieldValueAsString('X_AES_Description',mXMLHead.getElementAsString('order['+inttostr(i)+'].orderdata.note'));
    if not(NxIsEmptyOID(mXMLHead.getElementAsString('order['+inttostr(i)+'].transport.System_ID'))) then mReceivedOrderBO.SetFieldValueAsString('TransportationType_ID',mXMLHead.getElementAsString('order['+inttostr(i)+'].transport.System_ID'));
    if (mXMLHead.getElementAsString('order['+inttostr(i)+'].transport.System_ID') in ['2260000101','4260000101','5260000101','6260000101','7260000101','8260000101','9260000101','C260000101','2280000101']) then mReceivedOrderBO.SetFieldValueAsString('TransportationType_ID','2230000101');
    if (mXMLHead.getElementAsString('order['+inttostr(i)+'].transport.System_ID') in ['D260000101','E260000101','F260000101','G260000101','H260000101','I260000101']) then mReceivedOrderBO.SetFieldValueAsString('TransportationType_ID','2000000101');
    if (mXMLHead.getElementAsString('order['+inttostr(i)+'].transport.System_ID') in ['A260000101']) then mReceivedOrderBO.SetFieldValueAsString('TransportationType_ID','00000P1000');
    if (mXMLHead.getElementAsString('order['+inttostr(i)+'].transport.System_ID') in ['B260000101']) then mReceivedOrderBO.SetFieldValueAsString('TransportationType_ID','4100000101');
    if (mXMLHead.getElementAsString('order['+inttostr(i)+'].transport.System_ID') in ['2270000101']) then mReceivedOrderBO.SetFieldValueAsString('TransportationType_ID','00000O1000');
    if mReceivedOrderBO.GetFieldValueAsString('TransportationType_ID')='3100000101' then mReceivedOrderBO.SetFieldValueAsString('TransportationType_ID','00000P1000');
    if mReceivedOrderBO.GetFieldValueAsString('TransportationType_ID')='5100000101' then begin
     mReceivedOrderBO.SetFieldValueAsString('X_LP_DeliveryPointID',Ansileftstr(mXMLHead.getElementAsString('order['+inttostr(i)+'].deliverydata.zip'),30));
     if elementexists(mXMLHead,'order['+inttostr(i)+'].deliverydata.ID_Balikovna') then
        mReceivedOrderBO.SetFieldValueAsString('X_LP_DeliveryPointID',Ansileftstr(mXMLHead.getElementAsString('order['+inttostr(i)+'].deliverydata.ID_Balikovna'),30));
    end;
    if mReceivedOrderBO.GetFieldValueAsString('TransportationType_ID')='4100000101' then mReceivedOrderBO.SetFieldValueAsString('X_LP_DeliveryPointID',Ansileftstr(mXMLHead.getElementAsString('order['+inttostr(i)+'].deliverydata.zip'),30));
    if mXMLHead.getElementAsString('order['+inttostr(i)+'].transport.code')='P93' then mReceivedOrderBO.SetFieldValueAsString('X_LP_DeliveryPointID',Ansileftstr(mXMLHead.getElementAsString('order['+inttostr(i)+'].deliverydata.Code'),30));
    if not(NxIsEmptyOID(mXMLHead.getElementAsString('order['+inttostr(i)+'].payment.System_ID'))) then mReceivedOrderBO.SetFieldValueAsString('PaymentType_ID',mXMLHead.getElementAsString('order['+inttostr(i)+'].payment.System_ID'));
    try
     mReceivedOrderBO.SetFieldValueAsString('X_ComgateID',mXMLHead.getElementAsString('order['+inttostr(i)+'].payment.Comgate_ID'));
    except
    end;
    if not(NxIsBlank(mReceivedOrderBO.GetFieldValueAsString('Firm_ID.OrgIdentNumber'))) and (mReceivedOrderBO.GetFieldValueAsString('TransportationType_ID')='2230000101') and (mReceivedOrderBO.GetFieldValueAsString('PaymentType_ID')='4000000101') then mReceivedOrderBO.SetFieldValueAsString('TransportationType_ID','1000000101');
    if NxIsBlank(mReceivedOrderBO.GetFieldValueAsString('Firm_ID.OrgIdentNumber')) and (mReceivedOrderBO.GetFieldValueAsString('TransportationType_ID')='2230000101') and (mReceivedOrderBO.GetFieldValueAsString('PaymentType_ID')='4000000101') then mReceivedOrderBO.SetFieldValueAsString('TransportationType_ID','4220000101');
    if NxIsBlank(mReceivedOrderBO.GetFieldValueAsString('Firm_ID.OrgIdentNumber')) and (mReceivedOrderBO.GetFieldValueAsString('TransportationType_ID')='2230000101') and not(mReceivedOrderBO.GetFieldValueAsString('PaymentType_ID')='4000000101') then mReceivedOrderBO.SetFieldValueAsString('TransportationType_ID','2200000101');
    if (mReceivedOrderBO.GetFieldValueAsString('TransportationType_ID')='2240000101') and (mReceivedOrderBO.GetFieldValueAsString('PaymentType_ID')='4000000101') then mReceivedOrderBO.SetFieldValueAsString('TransportationType_ID','3240000101');
    mReceivedOrderBO.SetFieldValueAsInteger('DealerDiscountKind',0);
    if Trim(mXMLHead.getElementAsString('order['+inttostr(i)+'].invoicedata.COUNTRY_CODE'))='SLOVENSKO' then begin
     if (mReceivedOrderBO.GetFieldValueAsString('TransportationType_ID')='3220000101') and
        (mReceivedOrderBO.GetFieldValueAsString('PaymentType_ID')='3200000101') then mReceivedOrderBO.SetFieldValueAsString('TransportationType_ID','2220000101');
      if not(NxIsEmptyOID(mReceivedOrderBO.GetFieldValueAsString('Firm_ID.VATCountry_ID'))) then begin
        mReceivedOrderBO.SetFieldValueAsInteger('TradeType',2);
        mReceivedOrderBO.SetFieldValueAsString('Country_ID','00000SK000');
        mReceivedOrderBO.SetFieldValueAsstring('IntrastatDeliveryTerm_ID','3001000000'); ;
        mReceivedOrderBO.SetFieldValueAsstring('IntrastatTransactionType_ID','1001000000');
        mReceivedOrderBO.SetFieldValueAsstring('IntrastatTransportationType_ID','2000000000');
        mReceivedOrderBO.SetFieldValueAsString('BankAccount_ID','5100000101');
        mReceivedOrderBO.SetFieldValueAsString('Currency_ID','0000EUR000');
      end else begin
        mReceivedOrderBO.SetFieldValueAsInteger('TradeType',4);
        mReceivedOrderBO.SetFieldValueAsString('Country_ID','00000SK000');
      end;
    end;
        mObsah:=mObsah+mReceivedOrderBO.GetFieldValueAsString('Firm_ID.Name')+'<br>'+mReceivedOrderBO.GetFieldValueAsString('Firm_ID.ResidenceAddress_ID.City')+'<br>'+
                mReceivedOrderBO.GetFieldValueAsString('TransportationType_ID.Name')+'<br>';
        for j:=0 to  mXMLHead.getElementsCountInArray('order['+inttostr(i)+'].products.product')-1 do begin
          if mXMLHead.getElementAsFloat('order['+inttostr(i)+'].products.product['+inttostr(j)+'].amount')>0 then begin
           mRows:=mReceivedOrderBO.GetCollectionMonikerForFieldCode(mReceivedOrderBO.getfieldcode('Rows'));
           mReceivedOrderRowBO:=mRows.AddNewObject;
           mReceivedOrderRowBO.SetFieldValueAsInteger('RowType',3);
           mReceivedOrderRowBO.SetFieldValueAsString('StoreCard_id',mXMLHead.getElementAsString('order['+inttostr(i)+'].products.product['+inttostr(j)+'].system_id'));
           mReceivedOrderRowBO.SetFieldValueAsString('Store_ID',cStore_ID);
           mReceivedOrderRowBO.SetFieldValueAsString('Division_ID',cDivision_ID);
           mReceivedOrderRowBO.SetFieldValueAsString('BusTransaction_ID',cBusTransction);
           mReceivedOrderRowBO.SetFieldValueAsFloat('Quantity',mXMLHead.getElementAsFloat('order['+inttostr(i)+'].products.product['+inttostr(j)+'].amount'));
           mReceivedOrderRowBO.SetFieldValueAsFloat('UnitPrice',NxIBStrToFloat(NxSearchReplace(mXMLHead.getElementAsString('order['+inttostr(i)+'].products.product['+inttostr(j)+'].Price'),'.',',',[srAll])));
           if mReceivedOrderBO.GetFieldValueAsInteger('TradeType')=4 then begin
             mReceivedOrderRowBO.SetFieldValueAsBoolean('ToESL',false);
             mReceivedOrderRowBO.SetFieldValueAsBoolean('ToIntrastat',false);
             mReceivedOrderRowBO.SetFieldValueAsString('IncomeType_ID','2J00000101');
           end;
           if mReceivedOrderBO.GetFieldValueAsString('Currency_ID.Code')='EUR' then
             mReceivedOrderRowBO.SetFieldValueAsFloat('UnitPrice',NxIBStrToFloat(NxSearchReplace(mXMLHead.getElementAsString('order['+inttostr(i)+'].products.product['+inttostr(j)+'].Price'),'.',',',[srAll]))/
                                        mReceivedOrderBO.GetFieldValueAsFloat('CurrRate'));
           mObsah:=mObsah+'<br>'+mReceivedOrderRowBO.GetFieldValueAsString('StoreCard_ID.Code')+'&nbsp;&nbsp;&nbsp;&nbsp;'+
                                 mReceivedOrderRowBO.GetFieldValueAsString('StoreCard_ID.Name')+'&nbsp;&nbsp;&nbsp;&nbsp;'+
                                 FloatToStr(mReceivedOrderRowBO.GetFieldValueAsFloat('Quantity'))+'&nbsp;&nbsp;&nbsp;&nbsp;'+
                                 mReceivedOrderRowBO.GetFieldValueAsString('Qunit')+'&nbsp;&nbsp;&nbsp;&nbsp;'+
                                 FloatToStr(mReceivedOrderRowBO.GetFieldValueAsFloat('TotalPrice'))+' '+mReceivedOrderBO.GetFieldValueAsString('Currency_ID.Code');
          end;


        end;
     if StrToFloat(NxSearchReplace(mXMLHead.getElementAsString('order['+inttostr(i)+'].transport.Price'),'.',',',[srAll])) >0 then begin
         mRows:=mReceivedOrderBO.GetCollectionMonikerForFieldCode(mReceivedOrderBO.getfieldcode('Rows'));
           mReceivedOrderRowBO:=mRows.AddNewObject;
           mReceivedOrderRowBO.SetFieldValueAsInteger('RowType',1);
           mReceivedOrderRowBO.SetFieldValueAsString('Text',mXMLHead.getElementAsString('order['+inttostr(i)+'].transport.Name'));
           mReceivedOrderRowBO.SetFieldValueAsFloat('TotalPrice',StrToFloat(NxSearchReplace(mXMLHead.getElementAsString('order['+inttostr(i)+'].transport.Price'),'.',',',[srAll])));
           if mReceivedOrderBO.GetFieldValueAsString('Currency_ID.Code')='EUR' then
              mReceivedOrderRowBO.SetFieldValueAsFloat('TotalPrice',NxIBStrToFloat(NxSearchReplace(mXMLHead.getElementAsString('order['+inttostr(i)+'].transport.Price'),'.',',',[srAll]))/
               mReceivedOrderBO.GetFieldValueAsFloat('CurrRate'));
           mReceivedOrderRowBO.SetFieldValueAsString('VatRate_ID','02100X0000');
           if mReceivedOrderBO.GetFieldValueAsInteger('TradeType')=2 then mReceivedOrderRowBO.SetFieldValueAsString('VatRate_ID','00000X0000');
           mReceivedOrderRowBO.SetFieldValueAsString('Division_ID',cDivision_ID);
           mReceivedOrderRowBO.SetFieldValueAsString('IncomeType_ID','5100000101');
           mReceivedOrderRowBO.SetFieldValueAsString('BusTransaction_ID',cBusTransction);
           if mReceivedOrderBO.GetFieldValueAsInteger('TradeType')=2 then begin
            mReceivedOrderRowBO.SetFieldValueAsString('VatRate_ID','00000X0000');
            mReceivedOrderRowBO.SetFieldValueAsBoolean('ToESL',true);
            mReceivedOrderRowBO.SetFieldValueAsString('ESLIndicator_ID','1000000000');
            mReceivedOrderRowBO.SetFieldValueAsString('IncomeType_ID','1N00000101');
           end;
     
     end;
     if StrToFloat(NxSearchReplace(mXMLHead.getElementAsString('order['+inttostr(i)+'].payment.Price'),'.',',',[srAll])) >0 then begin
         mRows:=mReceivedOrderBO.GetCollectionMonikerForFieldCode(mReceivedOrderBO.getfieldcode('Rows'));
           mReceivedOrderRowBO:=mRows.AddNewObject;
           mReceivedOrderRowBO.SetFieldValueAsInteger('RowType',1);
           mReceivedOrderRowBO.SetFieldValueAsString('Text',mXMLHead.getElementAsString('order['+inttostr(i)+'].payment.Name'));
           mReceivedOrderRowBO.SetFieldValueAsFloat('TotalPrice',StrToFloat(NxSearchReplace(mXMLHead.getElementAsString('order['+inttostr(i)+'].payment.Price'),'.',',',[srAll])));
           if mReceivedOrderBO.GetFieldValueAsString('Currency_ID.Code')='EUR' then
              mReceivedOrderRowBO.SetFieldValueAsFloat('TotalPrice',NxIBStrToFloat(NxSearchReplace(mXMLHead.getElementAsString('order['+inttostr(i)+'].payment.Price'),'.',',',[srAll]))/
               mReceivedOrderBO.GetFieldValueAsFloat('CurrRate'));
           mReceivedOrderRowBO.SetFieldValueAsString('VatRate_ID','02100X0000');
           mReceivedOrderRowBO.SetFieldValueAsString('Division_ID',cDivision_ID);
           mReceivedOrderRowBO.SetFieldValueAsString('IncomeType_ID','5100000101');
           mReceivedOrderRowBO.SetFieldValueAsString('BusTransaction_ID',cBusTransction);
           if mReceivedOrderBO.GetFieldValueAsInteger('TradeType')=2 then begin
            mReceivedOrderRowBO.SetFieldValueAsString('VatRate_ID','00000X0000');
            mReceivedOrderRowBO.SetFieldValueAsBoolean('ToESL',true);
            mReceivedOrderRowBO.SetFieldValueAsString('ESLIndicator_ID','1000000000');
            mReceivedOrderRowBO.SetFieldValueAsString('IncomeType_ID','1N00000101');
           end;

     end;
     mReceivedOrderBO.save;
     NxScriptingLog.WriteEvent(logInfo, ExceptionMessage);
     if not(NxIsBlank(ExceptionMessage)) then result:=ExceptionMessage;
     mOrder_ID:=mreceivedOrderbo.OID;//AResult :=AResult+('id_eshop:'+mXMLHead.getElementAsString('order['+inttostr(i)+'].orderdata.id')+'|id_abra:'+mReceivedOrderBO.oid+'#');
     mAccount_id:='1300000101';
        if not(NxIsEmptyOID(mAccount_id)) then begin
        //mBody:=NxSearchReplace(cCZBody,'#ExtNumber#',self.GetFieldValueAsString('ExternalNumber'),[srAll]);
        {SendInternalMail(mReceivedOrderBO.ObjectSpace,mReceivedOrderBO.GetFieldValueAsString('Firm_id.ResidenceAddress_id.Email'),
                           '','',
                           mReceivedOrderBO.GetFieldValueAsString('ExternalNumber')+' '+mReceivedOrderBO.GetFieldValueAsString('U_OrderState_ID.Name') ,mReceivedOrderBO.GetFieldValueAsString('U_OrderState_ID.X_ISIRDATA'),'', mReceivedOrderBO.GetFieldValueAsString('Firm_ID'),
                           cDivision_ID,'',mAccount_id);
         mReceivedOrderBO.SetFieldValueAsBoolean('U_email1',true);}
     end;

     end;
     mResultList:=TStringList.Create;
     mResultList.Add(mOrder_ID);
     NxScriptingLog.WriteEvent(logInfo, 'InsertOrder End '+mOrder_ID);
     if not(NxIsEmptyOID(mOrder_ID)) then begin
     mFileName:='d:\abragen\Orders.xml';
      if mResultList.count>0 then begin
       CFxReportManager.ExportByIDs(NxCreateContext(mOS),mResultList,'40V53DORW3DL342X01C0CX3FCC','2Z00000101',0,'',mFileName);
        if FileExists(mFileName) then begin
         //Result:=mOutputList.Text;
          Result:=EncodeBase64(getfiletobytes(mFileName));
        end;
    end;
     {if not(NxIsBlank(mreceivedOrderbo.GetFieldValueAsString('Firm_id.U_bustransaction_ID.U_emailOP'))) then begin  }
        mListPrint:=TStringList.Create;
        mlistPrint.add(mreceivedOrderbo.OID);
        mFileName2:=NxSearchReplace(mreceivedOrderbo.DisplayName,'/','-',[srAll])+'.pdf';
        //CFxReportManager.PrintByIDs(NxCreateContext_1(mreceivedOrderbo),mListPrint,'40V53DORW3DL342X01C0CX3FCC','4VD0000101',rtoFile,pekPDF,NxGetTempDir,mFileName2);
        SendInternalMail2(mreceivedOrderbo.ObjectSpace,'mario.zizka@simonfm.cz',
        {mreceivedOrderbo.GetFieldValueAsString('Firm_id.U_bustransaction_ID.U_emailAS')}'','', 'Nová objednávka '+mreceivedOrderbo.DisplayName,
        'Přišla nová objednávka'+'<br>'+mObsah,'', mreceivedOrderbo.GetFieldValueAsString('Firm_ID'),
                   '1400000101','1000000101','');
        DeleteFile(NxGetTempDir+mFileName2);
      { end;   }
     end;
    End;
  except
   NxScriptingLog.WriteEvent(logWarning,ExceptionMessage);

  end;
 NxScriptingLog.LeaveSection('InsertOrder ',logInfo);

    
end;
function GetOrderInfo(Self: TNxWebServicesHelper;Order_ID: String):String;
var
 mResultList:TStringList;
 mFilename:String;

begin
     mResultList:=TStringList.Create;
     mResultList.Add(Order_ID);
     if not(NxIsEmptyOID(Order_ID)) then begin
     mFileName:='d:\abragen\Orders.xml';
      if mResultList.count>0 then begin
       CFxReportManager.ExportByIDs(NxCreateContext(self.ObjectSpace),mResultList,'40V53DORW3DL342X01C0CX3FCC','2Z00000101',0,'',mFileName);
        if FileExists(mFileName) then begin
         //Result:=mOutputList.Text;
          Result:=EncodeBase64(getfiletobytes(mFileName));
        end;
      end;
     end;


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
   NxScriptingLog.WriteEvent(logInfo, 'GetExport Start Exporttype'+IntToStr(ExportType)+','+IntToStr(DayOffset));
  if ExportType=0 then begin
      msql:=conSQL0;
      mExportID:=conExportID0;
      mFileName:=conFileName0;
      mDynSource:=conDynSource0;
      
  end;
  if ExportType=1 then begin
      if DayOffset>0 then begin;
      //mCorrectedDate:=Date-DayOffset;
      //mCreatedDate:=Date-DayOffset;
      mCorrectedDate:=Now-(1/6);
      mCreatedDate:=Now-(1/6);
      mSQL:= format(conSQL1d, [NxSearchReplace(FloatToStr(mCreatedDate),',','.',[srAll]), NxSearchReplace(FloatToStr(mCorrectedDate),',','.',[srAll])]);
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
  if ExportType=5 then begin
      msql:=conSQL5;
      mExportID:=conExportID5;
      mFileName:=conFileName5;
      mDynSource:=conDynSource5;

  end;
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
      msql:=conSQL11;
      mExportID:=conExportID11;
      mFileName:=conFileName11;
      mDynSource:=conDynSource11;

  end;
  mObjectSpace.SQLSelect(mSQL, mIDsList);
  NxScriptingLog.WriteEvent(logInfo, 'GetExport SQL '+mSQL);
  NxScriptingLog.WriteEvent(logInfo, 'GetExport Count '+IntToStr(mIDsList.count));
  //mIDsList.add('DF66000101');
  if mIDsList.count>0 then begin
       NxExportByIDs(mContext,mIDsList,GetExpSource(mObjectSpace,mExportID),mExportID,0,'',mFileName);
        if FileExists(mFileName) then begin
        mOutputList.Clear;
          mOutputList.LoadFromFile(mFileName);
          Result:=EncodeBase64(getfiletobytes(mFileName));
        end;
  end;
  //DeleteFile(mFileName);
  mContext.Free;
  mIDsList.Free;
  mOutputList.Free;
   NxScriptingLog.WriteEvent(logInfo, 'GetExport END Exporttype'+IntToStr(ExportType)+','+IntToStr(DayOffset));
end;

function GetFileToBytes(AFileName: String;): TBytes;
var
  mMS: TMemoryStream;
  mStr: string;
begin
  mMS := TMemoryStream.Create();
  try
    mMS.LoadFromFile(AFileName);
    Result := mMS.GetBytes;
  finally
    mMS.Free;
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
       CFxReportManager.PrintByIDs(self.Context,mResultList,'40SBPEINEFD13ACM03KIU0CLP4','3B80000101',rtoFile,pekPDF,'d:\wamp\www\',mFileName);
        if FileExists('d:\wamp\www\'+ mFileName) then begin
          Result:='http://aws.simonfm.cz/'+mFileName;
          //mOutputList.Clear;
          //mOutputList.LoadFromFile('E:\ABRA\PAPILLONS\ABRAG2\eshop\'+mFileName);
          //Result:=EncodeBase64(mOutputList.text);
        end;
  end;
  //DeleteFile('d:\wamp\www\images\' + mFileName);
  mContext.Free;
  mResultList.Free;
  mOutputList.Free;

end;



begin
end.