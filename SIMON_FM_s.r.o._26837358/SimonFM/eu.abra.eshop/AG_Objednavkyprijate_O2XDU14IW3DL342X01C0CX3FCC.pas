
uses
    'eu.abra.eshop.const', 'eu.abra.eshop.fce', 'eu.simon.emaileshop.mail', 'eu.simon.eshop.mail';

{procedure InitSite_Hook(Self: TSiteForm);
var
  mAction: TBasicAction;
  mUser : TNxCustomBusinessObject;
begin
  if not Assigned(Self.BaseObjectSpace) then
    exit;

    mAction := Self.GetNewAction;
    mAction.ShowControl := True;
    mAction.ShowMenuItem := True;
    mAction.Caption := 'importXML ručně';
    mAction.Hint := 'POKUS';
    mAction.Category := 'tabList';
    mAction.OnExecute := @InsertOrderOP;

end;   }

Procedure InsertOrderOP(Sender:TComponent);
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
  mOpendlg:TOpenDialog;
  mSite:TSiteForm;
begin
 mSite:=TComponent(Sender).DynSite;
 mOS:=TDynSiteForm(mSite).BaseObjectSpace;
 Aresult:='';
 mTempfileName:='';
 //mOS:=self.ObjectSpace;
 mXMLHead := TNxScriptingXMLWrapper.Create;
 //mXMLinput:=DecodeBase64(XMLInput);
 mList:=TStringList.Create;
 mOpendlg:=TOpenDialog.Create(sender);
 NxScriptingLog.EnterSection('InsertOrder ',logInfo);
 try
 //mStream:=TStringList.Create;
 //mStream.Add(TEncoding.UTF8.GetString(DecodeBase64(XMLinput)));
 //mStream.SaveToFile('d:\abraGen\test.xml');
 //mStream.SaveToFile('d:\abragen\temp\source'+FormatDateTime('YYYYMMDDHHnnsszzz',Now)+'.xml');
 mFile := TStringList.Create();

   if mOpendlg.Execute then begin
   NxShowSimpleMessage(mOpendlg.FileName,mSite);
    mfile.LoadFromFile(mOpendlg.FileName);
    //mFile.LoadFromFile('d:\abragen\test.xml');
    //mfile.Delete(0);
    mFile.Strings[0]:='<?xml version="1.0" encoding="windows-1250"?>';
    //NxSearchReplace(mFile.strings[0],'utf-8','windows-1250',[srAll]);
    mfile.SaveToFile('C:\temp\test.xml');
    mFile.SaveToFile('C:\temp\test'+FormatDateTime('YYYYMMDDHHnnsszzz',Now)+'.xml');
    mfile.Free;
   end;
 NxShowSimpleMessage('mám soubor uložen',msite);
  //mXMLHead := TNxScriptingXMLWrapper.Create;
 mXMLHead.loadFromFile('C:\temp\test.xml');
 //mXMLHead.loadFromBytes(DecodeBase64(XMLinput));
 NxShowSimpleMessage('InsertOrder Start '+mXMLHead.getElementAsString('order['+inttostr(i)+'].orderdata.id'), mSite);
 //mXMLHead.saveToFile('d:\wamp\www\orders\'+mXMLHead.getElementAsString('order['+inttostr(i)+'].orderdata.id')+FormatDateTime('YYYYMMDDHHSS',Now)+'.xml');
    for i:=0 to mXMLHead.getElementsCountInArray('order')-1 do begin
    //mPeriod_ID:='2V00000101';
    if not(NxIsBlank(mXMLHead.getElementAsString('order['+inttostr(i)+'].orderdata.id'))) then mOrder_ID:=scrGetORder_ID(mOS,mXMLHead.getElementAsString('order['+inttostr(i)+'].orderdata.id'));
    if not(NxIsEmptyOID(mOrder_ID)) then
        SendInternalMail2(mOS,'eshop@naradi-simon.cz',
        '','', 'pokus o opakované nahrání '+mXMLHead.getElementAsString('order['+inttostr(i)+'].orderdata.id'),
        'chyba nahrávání','', 'AAA1000000',
                   '1400000101','1000000101','');

    NxShowSimpleMessage(mOrder_ID,mSite);
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
            if mXMLHead.getElementAsString('order['+inttostr(i)+'].transport.code') in ['P93', 'P97', 'P108', 'P109', 'P110'] then mFirmOffice.SetFieldValueAsString('Name',Trim(mXMLHead.getElementAsString('order['+inttostr(i)+'].invoicedata.name')));
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
    if (mXMLHead.getElementAsString('order['+inttostr(i)+'].transport.System_ID') in ['22B0000101','22C0000101','32C0000101','42C0000101']) then mReceivedOrderBO.SetFieldValueAsString('TransportationType_ID','3250000101');
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
    if mXMLHead.getElementAsString('order['+inttostr(i)+'].transport.code') in ['P93', 'P97', 'P107', 'P108', 'P109', 'P110'] then mReceivedOrderBO.SetFieldValueAsString('X_LP_DeliveryPointID',Ansileftstr(mXMLHead.getElementAsString('order['+inttostr(i)+'].deliverydata.Code'),30));
    if not(NxIsEmptyOID(mXMLHead.getElementAsString('order['+inttostr(i)+'].payment.System_ID'))) then mReceivedOrderBO.SetFieldValueAsString('PaymentType_ID',mXMLHead.getElementAsString('order['+inttostr(i)+'].payment.System_ID'));
    try
     mReceivedOrderBO.SetFieldValueAsString('X_ComgateID',mXMLHead.getElementAsString('order['+inttostr(i)+'].payment.Comgate_ID'));
    except
    end;
    if not(NxIsBlank(mReceivedOrderBO.GetFieldValueAsString('Firm_ID.OrgIdentNumber'))) and (mReceivedOrderBO.GetFieldValueAsString('TransportationType_ID')='2230000101') and (mReceivedOrderBO.GetFieldValueAsString('PaymentType_ID')='4000000101') then mReceivedOrderBO.SetFieldValueAsString('TransportationType_ID','1000000101');
    if NxIsBlank(mReceivedOrderBO.GetFieldValueAsString('Firm_ID.OrgIdentNumber')) and (mReceivedOrderBO.GetFieldValueAsString('TransportationType_ID')='2230000101') and (mReceivedOrderBO.GetFieldValueAsString('PaymentType_ID')='4000000101') then mReceivedOrderBO.SetFieldValueAsString('TransportationType_ID','4220000101');
    if NxIsBlank(mReceivedOrderBO.GetFieldValueAsString('Firm_ID.OrgIdentNumber')) and (mReceivedOrderBO.GetFieldValueAsString('TransportationType_ID')='2230000101') and not(mReceivedOrderBO.GetFieldValueAsString('PaymentType_ID')='4000000101') then mReceivedOrderBO.SetFieldValueAsString('TransportationType_ID','2200000101');
    if (mReceivedOrderBO.GetFieldValueAsString('TransportationType_ID')='2240000101') and (mReceivedOrderBO.GetFieldValueAsString('PaymentType_ID')='4000000101') then mReceivedOrderBO.SetFieldValueAsString('TransportationType_ID','3240000101');
    if (mReceivedOrderBO.GetFieldValueAsString('TransportationType_ID')='3250000101') and (mReceivedOrderBO.GetFieldValueAsString('PaymentType_ID')='3100000101') then mReceivedOrderBO.SetFieldValueAsString('TransportationType_ID','22B0000101');
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
    // if not(NxIsBlank(ExceptionMessage)) then result:=ExceptionMessage;
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
          //Result:=EncodeBase64(getfiletobytes(mFileName));
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
   NxShowSimpleMessage(ExceptionMessage,msite);
   NxScriptingLog.WriteEvent(logWarning,ExceptionMessage);

  end;
 NxScriptingLog.LeaveSection('InsertOrder ',logInfo);


end;

begin
end.