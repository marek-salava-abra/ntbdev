uses 'abra.eu.mask_import.2016.lib';

procedure ZpracujSouborZFronty (OS: TNxCustomObjectSpace; var ProcessContinue: Boolean; Directory: string; FileName: string;msite:TDynSiteForm);
begin
  ProcessContinue := ImportFile2(OS, Directory + '\' + FileName,Directory,filename,msite,False,false,0);
end;




function ImportFile2(OS: TNxCustomObjectSpace; AFileName: string;directory: string;filename: string;msite:TDynSiteForm;rucne:boolean;chyba:boolean;index:Integer) : Boolean;
var
mID_Docqueue_iD,mID_Store_iD:string;
mObchodniPripad,mdivision_id:string;
mstore_id:string;
mBustransaction_ID:string;
mfind_string:string;
mr,mrsa:tstringlist;
begin
    if not FileExists(AFileName) then begin
      Result := False;
      exit;
    end;

    try
      mXMLHead := TNxScriptingXMLWrapper.Create;
        mXMLHead.loadFromFile(AFileName);

        //if ErrtElementString(mXMLHead ,'ABRADocument') then NxShowSimpleMessage('Element "ABRADocument" nebyl nalezen',nil) ;
        if ErrtElementString(mXMLHead ,'ABRADocument') and (chyba) then NxShowSimpleMessage('Element "ABRADocument" nebyl nalezen',nil) ;
        if ErrtElementString(mXMLHead ,'ABRADocument.Docqueue') and (chyba) then NxShowSimpleMessage('Element "ABRADocument.Docqueue" nebyl nalezen',nil) ;
        if ErrtElementString(mXMLHead ,'ABRADocument.Ordnumber') and (chyba) then NxShowSimpleMessage('Element "Ordnumber" nebyl nalezen',nil) ;
        if ErrtElementString(mXMLHead ,'ABRADocument.Period') and (chyba) then NxShowSimpleMessage('Element "ABRADocument.Period" nebyl nalezen',nil) ;
        if ErrtElementString(mXMLHead ,'ABRADocument.Division') and (chyba) then NxShowSimpleMessage('Element "ABRADocument.Division" nebyl nalezen',nil) ;
        if ErrtElementString(mXMLHead ,'ABRADocument.Bank_code') and (chyba) then NxShowSimpleMessage('Element "ABRADocument.Bank_code" nebyl nalezen',nil) ;
        if ErrtElementString(mXMLHead ,'ABRADocument.Obchod') and (chyba) then NxShowSimpleMessage('Element "ABRADocument.Obchod" nebyl nalezen',nil) ;
        if ErrtElementString(mXMLHead ,'ABRADocument.Obchodnik') and (chyba) then NxShowSimpleMessage('Element "ABRADocument.Obchodnik" nebyl nalezen',nil) ;
        if ErrtElementString(mXMLHead ,'ABRADocument.Customer.VATPayor') and (chyba) then NxShowSimpleMessage('Element "ABRADocument.Customer.VATPayor" nebyl nalezen',nil) ;
        if ErrtElementString(mXMLHead ,'ABRADocument.Customer.Name') and (chyba) then NxShowSimpleMessage('Element "ABRADocument.Customer.Name" nebyl nalezen',nil) ;
        if ErrtElementString(mXMLHead ,'ABRADocument.Customer.AllName') and (chyba) then NxShowSimpleMessage('Element "ABRADocument.Customer.AllName" nebyl nalezen',nil) ;
        if ErrtElementString(mXMLHead ,'ABRADocument.Customer.OrgIdentNumber') and (chyba) then NxShowSimpleMessage('Element "ABRADocument.Customer.OrgIdentNumber" nebyl nalezen',nil) ;
        if ErrtElementString(mXMLHead ,'ABRADocument.Customer.VATOrgIdentNumber') and (chyba) then NxShowSimpleMessage('Element "ABRADocument.Customer.VATOrgIdentNumber" nebyl nalezen',nil) ;
        if ErrtElementString(mXMLHead ,'ABRADocument.Customer.ResidenceAddress.Street') and (chyba) then NxShowSimpleMessage('Element "ABRADocument.Customer.ResidenceAddress.Street" nebyl nalezen',nil) ;
        if ErrtElementString(mXMLHead ,'ABRADocument.Customer.ResidenceAddress.City') and (chyba) then NxShowSimpleMessage('Element "ABRADocument.Customer.ResidenceAddress.City" nebyl nalezen',nil) ;
        if ErrtElementString(mXMLHead ,'ABRADocument.Customer.ResidenceAddress.PostCode') and (chyba) then NxShowSimpleMessage('Element "ABRADocument.Customer.ResidenceAddress.PostCode" nebyl nalezen',nil) ;
        if ErrtElementString(mXMLHead ,'ABRADocument.Customer.ResidenceAddress.CountryCode') and (chyba) then NxShowSimpleMessage('Element "ABRADocument.Customer.ResidenceAddress.CountryCode" nebyl nalezen',nil) ;
        if ErrtElementString(mXMLHead ,'ABRADocument.Customer.ResidenceAddress.Tel1') and (chyba) then NxShowSimpleMessage('Element "ABRADocument.Customer.ResidenceAddress.Tel1" nebyl nalezen',nil) ;
        if ErrtElementString(mXMLHead ,'ABRADocument.Customer.ResidenceAddress.Tel2') and (chyba) then NxShowSimpleMessage('Element "ABRADocument.Customer.ResidenceAddress.Tel2" nebyl nalezen',nil) ;
        if ErrtElementString(mXMLHead ,'ABRADocument.Customer.ResidenceAddress.email') and (chyba) then NxShowSimpleMessage('Element "ABRADocument.Customer.ResidenceAddress.email" nebyl nalezen',nil) ;

        if ErrtElementString(mXMLHead ,'ABRADocument.Customer.AcceptOrderEmail') and (chyba) then NxShowSimpleMessage('Element "ABRADocument.AcceptOrderEmail" nebyl nalezen',nil) ;
        if ErrtElementString(mXMLHead ,'ABRADocument.Customer.FirmOffice') and (chyba) then NxShowSimpleMessage('Element "ABRADocument.FirmOffice" nebyl nalezen',nil) ;


        if ErrtElementString(mXMLHead ,'ABRADocument.Description') and (chyba) then NxShowSimpleMessage('Element "ABRADocument.Description" nebyl nalezen',nil) ;
        if ErrtElementString(mXMLHead ,'ABRADocument.CountryCode') and (chyba) then NxShowSimpleMessage('Element "ABRADocument.CountryCode" nebyl nalezen',nil) ;
        if ErrtElementString(mXMLHead ,'ABRADocument.CurrencyCode') and (chyba) then NxShowSimpleMessage('Element "ABRADocument.CurrencyCode" nebyl nalezen',nil) ;
        if ErrtElementString(mXMLHead ,'ABRADocument.VATDocument') and (chyba) then NxShowSimpleMessage('Element "ABRADocument.VATDocument" nebyl nalezen',nil) ;
        if ErrtElementString(mXMLHead ,'ABRADocument.PricesWithVAT') and (chyba) then NxShowSimpleMessage('Element "ABRADocument.PricesWithVAT" nebyl nalezen',nil) ;
        if ErrtElementString(mXMLHead ,'ABRADocument.Amount') and (chyba) then NxShowSimpleMessage('Element "ABRADocument.Amount" nebyl nalezen',nil) ;
        if ErrtElementString(mXMLHead ,'ABRADocument.AmountWithoutVAT') and (chyba) then NxShowSimpleMessage('Element "ABRADocument.AmountWithoutVAT" nebyl nalezen',nil) ;
        if ErrtElementString(mXMLHead ,'ABRADocument.ExternalNumber') and (chyba) then NxShowSimpleMessage('Element "ABRADocument.ExternalNumber" nebyl nalezen',nil) ;
        if ErrtElementString(mXMLHead ,'ABRADocument.TradeType') and (chyba) then NxShowSimpleMessage('Element "ABRADocument.TradeType" nebyl nalezen',nil) ;
        if ErrtElementString(mXMLHead ,'ABRADocument.IntrastatDeliveryTerm') and (chyba) then NxShowSimpleMessage('Element "ABRADocument.IntrastatDeliveryTerm" nebyl nalezen',nil) ;
        if ErrtElementString(mXMLHead ,'ABRADocument.IntrastatTransactionType') and (chyba) then NxShowSimpleMessage('Element "ABRADocument.IntrastatTransactionType" nebyl nalezen',nil) ;
        if ErrtElementString(mXMLHead ,'ABRADocument.IntrastatTransportationType') and (chyba) then NxShowSimpleMessage('Element "ABRADocument.IntrastatTransportationType" nebyl nalezen',nil) ;
        if ErrtElementString(mXMLHead ,'ABRADocument.DeliveryType') and (chyba) then NxShowSimpleMessage('Element "ABRADocument.DeliveryType" nebyl nalezen',nil) ;
        if ErrtElementString(mXMLHead ,'ABRADocument.PaymentType') and (chyba) then NxShowSimpleMessage('Element "ABRADocument.PaymentType" nebyl nalezen',nil) ;
        if ErrtElementString(mXMLHead ,'ABRADocument.KonstSymbol') and (chyba) then NxShowSimpleMessage('Element "ABRADocument.KonstSymbol" nebyl nalezen',nil) ;
        if ErrtElementString(mXMLHead ,'ABRADocument.Voucher') and (chyba) then NxShowSimpleMessage('Element "ABRADocument.Voucher" nebyl nalezen',nil) ;





        if ErrtElementString(mXMLHead ,'ABRADocument')

        and (index=2) then mDoklad := mXMLHead.getElementAsString('ABRADocument');

        //if ErrtElementString(mXMLHead ,'ABRADocument') and (index<>2) then
        mXMLHead.getElementAsString('ABRADocument.Customer');

       mObchodniPripad:='';
       mdivision_id:='';

       mtoESL:=False;
       mID_odberatel:='';
       mID_dodavatel:='';
       mID_Docqueue:='';
       mID_BusOrder:='';
       mID_Division:='';
       mID_Country:='';
        mID_VatCountry:='';
       mID_Currency:='';
       mID_row:='';
       mexistuje:='';
       mTyp_obchodu:='';
       oprava:=false;
       mID_kost_symbol:='';
       mID_payment:='';
       mID_delivery:='';
       mCountryName:='';
       mstore_id:='';
       mBustransaction_ID:='';

       if not(ErrtElementString(mXMLHead ,'ABRADocument.Docqueue') and (index=2)) then
            mID_Docqueue:=getIDfromfield(os,'ID','Docqueues','Code',mXMLHead.getElementAsString('ABRADocument.Docqueue'),'Hidden','N');

       if (mID_Docqueue='1710000101') or (mID_Docqueue='1U20000101') then mTyp_obchodu:='B2B';      // opes , opke         opke ne
       if mID_Docqueue='2S10000101' then mTyp_obchodu:='B2C';                                       // opc                 ne
       if (mID_Docqueue='1U10000101') or (mID_Docqueue='2U20000101') then mTyp_obchodu:='TOP';      // opte
       if mID_Docqueue='2O20000101' then mTyp_obchodu:='MAR';                                       // opem
       if mID_Docqueue='1020000101' then mTyp_obchodu:='GMBH';                                      // opgm
       if mXMLHead.getElementAsString('ABRADocument.Docqueue')='OPOv' then mTyp_obchodu:='GMBH';    // opov

       if (mID_Docqueue='1710000101') or (mID_Docqueue='1S00000101') or (mID_Docqueue='1U10000101') or (mID_Docqueue='2U20000101') then mID_Docqueue_iD :='1S00000101';
       if (mID_Docqueue='2S00000101') or (mID_Docqueue='2O20000101') or (mID_Docqueue='1020000101') then mID_Docqueue_iD :='2S00000101';

       if mTyp_obchodu='GMBH' then mID_Docqueue_iD :='2S00000101' ;
       if mXMLHead.getElementAsString('ABRADocument.Docqueue')='OPE' then mID_Docqueue_iD :='2S00000101' ;
       if mXMLHead.getElementAsString('ABRADocument.Docqueue')='OPES' then mID_Docqueue_iD :='2S00000101' ;
       if mTyp_obchodu='MAR' then mID_Docqueue_iD :='2O20000101' ;
       //mID_Docqueue_iD := mID_Docqueue ;

      if not(ErrtElementString(mXMLHead ,'ABRADocument.ExternalNumber') and (index=2)) then
      mexistuje:=getIDfromfield(os,'ID','ReceivedOrders','ExternalNumber',mXMLHead.getElementAsString('ABRADocument.ExternalNumber'),'','');

      if not(ErrtElementString(mXMLHead ,'ABRADocument.Division') and (index=2)) then begin
          mID_Division:=getIDfromfield(os,'ID','Divisions','Code',mXMLHead.getElementAsString('ABRADocument.Division'),'Hidden','N');
      // end else begin
          //mID_Division:='1N00000101';
       end;
      if not(ErrtElementString(mXMLHead ,'ABRADocument.CountryCode') and (index=2)) then
      mID_Country:=getIDfromfield(os,'ID','Countries','Code',mXMLHead.getElementAsString('ABRADocument.CountryCode'),'Hidden','N');
      //if ErrtElementString(mXMLHead ,'ABRADocument.CurrencyCode') and (index<>2) then
      mID_Currency:=getIDfromfield(os,'ID','Currencies','Code',mXMLHead.getElementAsString('ABRADocument.CurrencyCode'),'Hidden','N');



      if mTyp_obchodu<>'GMBH' then begin
          if not(ErrtElementString(mXMLHead ,'ABRADocument.PaymentType') and (index=2)) then
          mID_payment:=getIDfromfield(os,'ID','PaymentTypes','Code',mXMLHead.getElementAsString('ABRADocument.PaymentType'),'Hidden','N');
          if not(ErrtElementString(mXMLHead ,'ABRADocument.DeliveryType') and (index=2)) then
          mID_delivery:=getIDfromfield(os,'ID','TransportationTypes','Code',mXMLHead.getElementAsString('ABRADocument.DeliveryType'),'Hidden','N');
          if not(ErrtElementString(mXMLHead ,'ABRADocument.KonstSymbol') and (index=2)) then
          mID_kost_symbol:=getIDfromfield(os,'ID','ConstantSymbols','Code',mXMLHead.getElementAsString('ABRADocument.KonstSymbol'),'Hidden','N');
      end;
      if mTyp_obchodu='TOP' then mID_odberatel:=GetFirmID_TOP(os,mXMLHead,msite,mID_Country);
      if mTyp_obchodu='GMBH' then mID_odberatel:='1TZ1000101';
      if (mTyp_obchodu='B2B') or (mTyp_obchodu='MAR') then mID_odberatel:='1WD1000101';
      if mTyp_obchodu='B2C' then mID_odberatel:=GetFirmID_B2C(os,mXMLHead,msite);
      if mTyp_obchodu='B2C' then mID_odberatel:=GetFirmID_B2C(os,mXMLHead,msite);

        mHead := TNxHeaderBusinessObject(OS.CreateObject('01CPMINJW3DL342X01C0CX3FCC'));
        try
                if nxisemptyoid(mexistuje) then begin
                      mHead.New;
                      mHead.Prefill;
                      if rucne and chyba then NxShowSimpleMessage('Novy',nil);
                              mHead.SetFieldValueAsString('DocQueue_ID', mID_Docqueue_ID);
                              mhead.SetFieldValueAsString('Firm_ID',mID_odberatel);
                              mHead.SetFieldValueAsString('X_source', mTyp_obchodu);

                              if not(ErrtElementString(mXMLHead ,'ABRADocument.PricesWithVAT') and (index<>2)) then
                              if mXMLHead.getElementAsString('ABRADocument.PricesWithVAT')='A' then begin
                                 mhead.SetFieldValueAsBoolean('PricesWithVAT',true);
                              end else begin
                                 mhead.SetFieldValueAsBoolean('PricesWithVAT',false);
                              end;

                              if mXMLHead.getElementAsString('ABRADocument.Docqueue')='OPTE' then mhead.SetFieldValueAsString('TransportationType_ID',mID_delivery);


                              if not(ErrtElementString(mXMLHead ,'ABRADocument.TradeType') and (index=2)) then begin
                                  if mTyp_obchodu<>'GMBH' then mhead.SetFieldValueAsString('BankAccount_ID',mXMLHead.getElementAsString('ABRADocument.Bank_code'));
                                  if strtoint(mXMLHead.getElementAsString('ABRADocument.TradeType'))=1 then mHead.SetFieldValueAsInteger('Tradetype',1);
                                  if strtoint(mXMLHead.getElementAsString('ABRADocument.TradeType'))=2 then mHead.SetFieldValueAsInteger('Tradetype',2);
                                  if strtoint(mXMLHead.getElementAsString('ABRADocument.TradeType'))=3 then mHead.SetFieldValueAsInteger('Tradetype',3);
                                  if strtoint(mXMLHead.getElementAsString('ABRADocument.TradeType'))=4 then mHead.SetFieldValueAsInteger('Tradetype',4);
                                  if strtoint(mXMLHead.getElementAsString('ABRADocument.TradeType'))=5 then mHead.SetFieldValueAsInteger('Tradetype',5);
                              end;

                              if mHead.getFieldValueAsInteger('Tradetype')>1 then mID_VATcountry:='00000CZ000' else mID_VATcountry:=getIDfromfield(os,'ID','Countries','Code',mXMLHead.getElementAsString('ABRADocument.CountryCode'),'Hidden','N');
                               if mHead.getFieldValueAsInteger('Tradetype')= 5 then mID_VATcountry:=getIDfromfield(os,'ID','Countries','Code',mXMLHead.getElementAsString('ABRADocument.CountryCode'),'Hidden','N');

                              if ((mHead.getFieldValueAsInteger('Tradetype')>1) and (mID_VATCountry<>'')) then mHead.SetFieldValueAsString('VATCountry_ID',mID_VATCountry) ;

                              if mHead.getFieldValueAsInteger('Tradetype')>1 then mID_country:=getIDfromfield(os,'ID','Countries','Code',mXMLHead.getElementAsString('ABRADocument.CountryCode'),'Hidden','N');


                              if mID_Country<>'' then mHead.SetFieldValueAsString('Country_id', mID_Country);
                              if not(ErrtElementString(mXMLHead ,'ABRADocument.ExternalNumber') and (index=2)) then
                              mHead.SetFieldValueAsString('ExternalNumber',mXMLHead.getElementAsString('ABRADocument.ExternalNumber'));
                              if not(ErrtElementString(mXMLHead ,'ABRADocument.ExternalNumber') and (index=2)) then
                              mHead.SetFieldValueAsString('X_VarSymbol',mXMLHead.getElementAsString('ABRADocument.ExternalNumber'));

                              if not(ErrtElementString(mXMLHead ,'ABRADocument.VATDocument') and (index=2)) then begin
                                  if (mXMLHead.getElementAsstring('ABRADocument.VATDocument'))='A' then mHead.SetFieldValueAsBoolean('VATDocument',true );
                                  if (mXMLHead.getElementAsstring('ABRADocument.VATDocument'))<>'A' then mHead.SetFieldValueAsBoolean('VATDocument',false );
                                  if (mXMLHead.getElementAsstring('ABRADocument.PricesWithVAT'))='A' then mHead.SetFieldValueAsBoolean('PricesWithVAT', true);
                                  if (mXMLHead.getElementAsstring('ABRADocument.PricesWithVAT'))<>'A' then mHead.SetFieldValueAsBoolean('PricesWithVAT', false);
                               end;
                              if not(ErrtElementString(mXMLHead ,'ABRADocument.Description') and (index=2)) then
                              mHead.SetFieldValueAsString('Description', mXMLHead.getElementAsString('ABRADocument.Description'));

                              mHead.SetFieldValueAsFloat('VATRounding', 1);

                              mHead.SetFieldValueAsFloat('TotalRounding',1);


                              if not(ErrtElementString(mXMLHead ,'ABRADocument.Customer.FirmOffice') and (index=2)) then begin
                                    if mXMLHead.getElementAsString('ABRADocument.Customer.FirmOffice')<>'' then begin
                                       //mID_odberatel:=getIDfromfield(os,'Parent_id','FirmOffices','Id',mXMLHead.getElementAsString('ABRADocument.Customer.FirmOffice'),'','');
                                       //mhead.SetFieldValueAsString('Firm_ID',mID_odberatel);
                                       mhead.SetFieldValueAsString('FirmOffice_ID',mXMLHead.getElementAsString('ABRADocument.Customer.FirmOffice'));
                                    end else begin
                                       mhead.SetFieldValueAsString('Firm_ID',mID_odberatel);
                                    end;
                               end;






                              mHead.SetFieldValueAsString('Currency_ID', mID_Currency);



                                 if mHead.getFieldValueAsString('Currency_ID')= '0000CZK000' then   begin
                                     mHead.SetFieldValueAsinteger('TotalRounding',(257))
                                     end else begin
                                     mHead.SetFieldValueAsinteger('TotalRounding',(0)) ;
                                 end;



                              if mID_payment<>'' then mhead.SetFieldValueAsString('PaymentType_ID',mID_payment);
                              if mID_delivery<>'' then mhead.SetFieldValueAsString('TransportationType_ID',mID_delivery);

                              if mTyp_obchodu<>'GMBH' then begin
                                  if mID_kost_symbol<>'' then mhead.SetFieldValueAsString('ConstSymbol_ID',mID_kost_symbol);
                                  if mID_payment<>'' then mhead.SetFieldValueAsString('PaymentType_ID',mID_payment);
                                  if mID_delivery<>'' then mhead.SetFieldValueAsString('TransportationType_ID',mID_delivery);
                              end;

                              if mTyp_obchodu='MAR' then begin
                                  mRow := mHead.Rows.AddNewObject;
                                  mRow.Prefill;
                                  mRow.SetFieldValueAsInteger('PosIndex',0);
                                  mRow.SetFieldValueAsInteger('RowType',0);
                                  mRow.SetFieldValueAsstring('Text','Marketing Discount');
                                  mRow.SetFieldValueAsString('Division_ID',mID_Division); //text bude  ...
                              end;
                     if mTyp_obchodu='GMBH' then begin
                              mHead.SetFieldValueAsString('DocQueue_ID', mID_Docqueue_iD);
                              mhead.SetFieldValueAsBoolean('PricesWithVAT',true);
                              //mhead.SetFieldValueAsString('BankAccount_ID','3000000101');
                              mHead.SetFieldValueAsInteger('Tradetype',2);
                              // *****  mHead.SetFieldValueAsString('Country_id', mID_Country);
                              mHead.SetFieldValueAsString('VATCountry_ID', '00000CZ000');
                              mID_odberatel:='1TZ1000101';
                              mHead.SetFieldValueAsstring('Firm_ID', mID_odberatel);
                      end;
                      //if strtoint(mXMLHead.getElementAsString('ABRADocument.TradeType'))<>1 then mtoESL:=True;


                              for i := 0 to mXMLHead.getElementsCountInArray('AbraDocument.Rows.Row') - 1 do begin

                                        if ErrtElementString(mXMLHead ,'AbraDocument.Rows.Row['+inttostr(i)+'].PosIndex') and (chyba) then NxShowSimpleMessage('Element "AbraDocument.Rows.Row['+inttostr(i)+'].PosIndex" nebyl nalezen',nil) ;
                                        if ErrtElementString(mXMLHead ,'AbraDocument.Rows.Row['+inttostr(i)+'].RowType') and (chyba) then NxShowSimpleMessage('Element "AbraDocument.Rows.Row['+inttostr(i)+'].RowType" nebyl nalezen',nil) ;
                                        if ErrtElementString(mXMLHead ,'AbraDocument.Rows.Row['+inttostr(i)+'].RowType') and (chyba) then NxShowSimpleMessage('Element "AbraDocument.Rows.Row['+inttostr(i)+'].RowType" nebyl nalezen',nil) ;
                                        if ErrtElementString(mXMLHead ,'AbraDocument.Rows.Row['+inttostr(i)+'].Commodity.EAN') and (chyba) then NxShowSimpleMessage('Element "AbraDocument.Rows.Row['+inttostr(i)+'].Commodity.EAN" nebyl nalezen',nil) ;
                                        if ErrtElementString(mXMLHead ,'AbraDocument.Rows.Row['+inttostr(i)+'].Commodity.CustomerCode') and (chyba) then NxShowSimpleMessage('Element "AbraDocument.Rows.Row['+inttostr(i)+'].Commodity.CustomerCode" nebyl nalezen',nil) ;
                                        //if ErrtElementString(mXMLHead ,'AbraDocument.Rows.Row['+inttostr(i)+'].Commodity.SupplierCode') and (chyba) then NxShowSimpleMessage('Element "AbraDocument.Rows.Row['+inttostr(i)+'].Commodity.SupplierCode" nebyl nalezen',nil) ;
                                        if ErrtElementString(mXMLHead ,'AbraDocument.Rows.Row['+inttostr(i)+'].Commodity.Name') and (chyba) then NxShowSimpleMessage('Element "AbraDocument.Rows.Row['+inttostr(i)+'].Commodity.Name" nebyl nalezen',nil) ;
                                        if ErrtElementString(mXMLHead ,'AbraDocument.Rows.Row['+inttostr(i)+'].Commodity.ForeignName') and (chyba) then NxShowSimpleMessage('Element "" nebyl nalezen',nil) ;
                                        if ErrtElementString(mXMLHead ,'AbraDocument.Rows.Row['+inttostr(i)+'].Note') and (chyba) then NxShowSimpleMessage('Element "AbraDocument.Rows.Row['+inttostr(i)+'].Note" nebyl nalezen',nil) ;
                                        if ErrtElementString(mXMLHead ,'AbraDocument.Rows.Row['+inttostr(i)+'].UnitRate') and (chyba) then NxShowSimpleMessage('Element "AbraDocument.Rows.Row['+inttostr(i)+'].UnitRate" nebyl nalezen',nil) ;
                                        if ErrtElementString(mXMLHead ,'AbraDocument.Rows.Row['+inttostr(i)+'].Quantity') and (chyba) then NxShowSimpleMessage('Element "AbraDocument.Rows.Row['+inttostr(i)+'].Quantity" nebyl nalezen',nil) ;
                                        if ErrtElementString(mXMLHead ,'AbraDocument.Rows.Row['+inttostr(i)+'].QUnit') and (chyba) then NxShowSimpleMessage('Element "AbraDocument.Rows.Row['+inttostr(i)+'].QUnit" nebyl nalezen',nil) ;
                                        if ErrtElementString(mXMLHead ,'AbraDocument.Rows.Row['+inttostr(i)+'].UnitPrice') and (chyba) then NxShowSimpleMessage('Element "AbraDocument.Rows.Row['+inttostr(i)+'].UnitPrice" nebyl nalezen',nil) ;
                                        if ErrtElementString(mXMLHead ,'AbraDocument.Rows.Row['+inttostr(i)+'].TotalPrice') and (chyba) then NxShowSimpleMessage('Element "AbraDocument.Rows.Row['+inttostr(i)+'].TotalPrice" nebyl nalezen',nil) ;
                                        if ErrtElementString(mXMLHead ,'AbraDocument.Rows.Row['+inttostr(i)+'].TAmountWithoutVAT') and (chyba) then NxShowSimpleMessage('Element "AbraDocument.Rows.Row['+inttostr(i)+'].TAmountWithoutVAT" nebyl nalezen',nil) ;
                                        if ErrtElementString(mXMLHead ,'AbraDocument.Rows.Row['+inttostr(i)+'].TAmount') and (chyba) then NxShowSimpleMessage('Element "AbraDocument.Rows.Row['+inttostr(i)+'].TAmount" nebyl nalezen',nil) ;
                                        if ErrtElementString(mXMLHead ,'AbraDocument.Rows.Row['+inttostr(i)+'].Discount') and (chyba) then NxShowSimpleMessage('Element "AbraDocument.Rows.Row['+inttostr(i)+'].Discount" nebyl nalezen',nil) ;
                                        if ErrtElementString(mXMLHead ,'AbraDocument.Rows.Row['+inttostr(i)+'].VATRate') and (chyba) then NxShowSimpleMessage('Element "AbraDocument.Rows.Row['+inttostr(i)+'].VATRate" nebyl nalezen',nil) ;

                                        if ErrtElementString(mXMLHead ,'AbraDocument.Rows.Row['+inttostr(i)+'].AcceptPrices') and (chyba) then NxShowSimpleMessage('Element "AbraDocument.Rows.Row['+inttostr(i)+'].AcceptPrices" nebyl nalezen',nil) ;


                                        if ErrtElementString(mXMLHead ,'AbraDocument.Rows.Row['+inttostr(i)+'].Specification.Jmeno') and (chyba) then NxShowSimpleMessage('Element "AbraDocument.Rows.Row['+inttostr(i)+'].Specification.Jmeno" nebyl nalezen',nil) ;
                                        if ErrtElementString(mXMLHead ,'AbraDocument.Rows.Row['+inttostr(i)+'].Specification.Telefon') and (chyba) then NxShowSimpleMessage('Element "AbraDocument.Rows.Row['+inttostr(i)+'].Specification.Telefon" nebyl nalezen',nil) ;
                                        if ErrtElementString(mXMLHead ,'AbraDocument.Rows.Row['+inttostr(i)+'].Specification.Osoba_id') and (chyba) then NxShowSimpleMessage('Element "AbraDocument.Rows.Row['+inttostr(i)+'].Specification.Osoba_id" nebyl nalezen',nil) ;
                                        if ErrtElementString(mXMLHead ,'AbraDocument.Rows.Row['+inttostr(i)+'].Specification.Vyska') and (chyba) then NxShowSimpleMessage('Element "Vyska" nebyl nalezen',nil) ;
                                        if ErrtElementString(mXMLHead ,'AbraDocument.Rows.Row['+inttostr(i)+'].Specification.TG') and (chyba) then NxShowSimpleMessage('Element "TG" nebyl nalezen',nil) ;
                                        if ErrtElementString(mXMLHead ,'AbraDocument.Rows.Row['+inttostr(i)+'].Specification.TF') and (chyba) then NxShowSimpleMessage('Element "TF" nebyl nalezen',nil) ;
                                        if ErrtElementString(mXMLHead ,'AbraDocument.Rows.Row['+inttostr(i)+'].Specification.TD') and (chyba) then NxShowSimpleMessage('Element "TD" nebyl nalezen',nil) ;
                                        if ErrtElementString(mXMLHead ,'AbraDocument.Rows.Row['+inttostr(i)+'].Specification.TB') and (chyba) then NxShowSimpleMessage('Element "TB" nebyl nalezen',nil) ;
                                        if ErrtElementString(mXMLHead ,'AbraDocument.Rows.Row['+inttostr(i)+'].Specification.VG') and (chyba) then NxShowSimpleMessage('Element "VG" nebyl nalezen',nil) ;
                                        if ErrtElementString(mXMLHead ,'AbraDocument.Rows.Row['+inttostr(i)+'].Specification.VD') and (chyba) then NxShowSimpleMessage('Element "VD" nebyl nalezen',nil) ;
                                        if ErrtElementString(mXMLHead ,'AbraDocument.Rows.Row['+inttostr(i)+'].Specification.VB') and (chyba) then NxShowSimpleMessage('Element "VB" nebyl nalezen',nil) ;
                                        if ErrtElementString(mXMLHead ,'AbraDocument.Rows.Row['+inttostr(i)+'].Specification.Oblicej') and (chyba) then NxShowSimpleMessage('Element "Oblicej" nebyl nalezen',nil) ;
                                        if ErrtElementString(mXMLHead ,'AbraDocument.Rows.Row['+inttostr(i)+'].Specification.Hlava') and (chyba) then NxShowSimpleMessage('Element "Hlava" nebyl nalezen',nil) ;
                                        if ErrtElementString(mXMLHead ,'AbraDocument.Rows.Row['+inttostr(i)+'].Specification.Krk') and (chyba) then NxShowSimpleMessage('Element "Krk" nebyl nalezen',nil) ;
                                        if ErrtElementString(mXMLHead ,'AbraDocument.Rows.Row['+inttostr(i)+'].Specification.Pres_prsa') and (chyba) then NxShowSimpleMessage('Element "Pres_prsa" nebyl nalezen',nil) ;
                                        if ErrtElementString(mXMLHead ,'AbraDocument.Rows.Row['+inttostr(i)+'].Specification.Pod_prsy') and (chyba) then NxShowSimpleMessage('Element "Pod_prsy" nebyl nalezen',nil) ;
                                        if ErrtElementString(mXMLHead ,'AbraDocument.Rows.Row['+inttostr(i)+'].Specification.Pas') and (chyba) then NxShowSimpleMessage('Element "Pas" nebyl nalezen',nil) ;
                                        if ErrtElementString(mXMLHead ,'AbraDocument.Rows.Row['+inttostr(i)+'].Specification.Stehna') and (chyba) then NxShowSimpleMessage('Element "Stehna" nebyl nalezen',nil) ;
                                        if ErrtElementString(mXMLHead ,'AbraDocument.Rows.Row['+inttostr(i)+'].Specification.Boky') and (chyba) then NxShowSimpleMessage('Element "Boky" nebyl nalezen',nil) ;
                                        if ErrtElementString(mXMLHead ,'AbraDocument.Rows.Row['+inttostr(i)+'].Specification.Stehno_horni') and (chyba) then NxShowSimpleMessage('Element "Stehno_horni" nebyl nalezen',nil) ;
                                        if ErrtElementString(mXMLHead ,'AbraDocument.Rows.Row['+inttostr(i)+'].Specification.Stehna_stredni') and (chyba) then NxShowSimpleMessage('Element "Stehna_stredni" nebyl nalezen',nil) ;
                                        if ErrtElementString(mXMLHead ,'AbraDocument.Rows.Row['+inttostr(i)+'].Specification.Nad_kolenem') and (chyba) then NxShowSimpleMessage('Element "Nad_kolenem" nebyl nalezen',nil) ;
                                        if ErrtElementString(mXMLHead ,'AbraDocument.Rows.Row['+inttostr(i)+'].Specification.Pod_kolenem') and (chyba) then NxShowSimpleMessage('Element "Pod_kolenem" nebyl nalezen',nil) ;
                                        if ErrtElementString(mXMLHead ,'AbraDocument.Rows.Row['+inttostr(i)+'].Specification.Lytko') and (chyba) then NxShowSimpleMessage('Element "Lytko" nebyl nalezen',nil) ;
                                        if ErrtElementString(mXMLHead ,'AbraDocument.Rows.Row['+inttostr(i)+'].Specification.Nad_kotnikem') and (chyba) then NxShowSimpleMessage('Element "Nad_kotnikem" nebyl nalezen',nil) ;
                                        if ErrtElementString(mXMLHead ,'AbraDocument.Rows.Row['+inttostr(i)+'].Specification.Brada_temeno') and (chyba) then NxShowSimpleMessage('Element "Brada_temeno" nebyl nalezen',nil) ;
                                        if ErrtElementString(mXMLHead ,'AbraDocument.Rows.Row['+inttostr(i)+'].Specification.Rukav') and (chyba) then NxShowSimpleMessage('Element "Rukav" nebyl nalezen',nil) ;
                                        if ErrtElementString(mXMLHead ,'AbraDocument.Rows.Row['+inttostr(i)+'].Specification.Nad_loktem1') and (chyba) then NxShowSimpleMessage('Element "Nad_loktem1" nebyl nalezen',nil) ;
                                        if ErrtElementString(mXMLHead ,'AbraDocument.Rows.Row['+inttostr(i)+'].Specification.Nad_loktem2') and (chyba) then NxShowSimpleMessage('Element "Nad_loktem2" nebyl nalezen',nil) ;
                                        if ErrtElementString(mXMLHead ,'AbraDocument.Rows.Row['+inttostr(i)+'].Specification.Nad_loktem3') and (chyba) then NxShowSimpleMessage('Element "Nad_loktem3" nebyl nalezen',nil) ;
                                        if ErrtElementString(mXMLHead ,'AbraDocument.Rows.Row['+inttostr(i)+'].Specification.Barva') and (chyba) then NxShowSimpleMessage('Element "Barva" nebyl nalezen',nil) ;


                                if not(ErrtElementString(mXMLHead ,'AbraDocument.Rows.Row['+inttostr(i)+'].Vatrate') and (index=2)) then begin
                                      if mXMLHead.getElementAsstring('AbraDocument.Rows.Row['+inttostr(i)+'].Vatrate')='21' then mID_Vatrate:='02100X0000';
                                      if mXMLHead.getElementAsstring('AbraDocument.Rows.Row['+inttostr(i)+'].Vatrate')='15' then mID_Vatrate:='01500X0000';
                                      if mXMLHead.getElementAsstring('AbraDocument.Rows.Row['+inttostr(i)+'].Vatrate')='20' then mID_Vatrate:='02000X0000';
                                      if mXMLHead.getElementAsstring('AbraDocument.Rows.Row['+inttostr(i)+'].Vatrate')='14' then mID_Vatrate:='01400X0000';
                                      if mXMLHead.getElementAsstring('AbraDocument.Rows.Row['+inttostr(i)+'].Vatrate')='0' then  mID_Vatrate:='00000X0000';
                                end;
                                          mRow := mHead.Rows.AddNewObject;
                                             mRow.Prefill;
                                             if not(ErrtElementString(mXMLHead ,'ABRADocument.Obchod') and (index=2)) then
                                             mRow.SetFieldValueAsstring('BusProject_id',mXMLHead.getElementAsString('ABRADocument.Obchod'));
                                             if not(ErrtElementString(mXMLHead ,'ABRADocument.Obchodnik') and (index=2)) then
                                             mRow.SetFieldValueAsstring('BusOrder_id',mXMLHead.getElementAsString('ABRADocument.Obchodnik'));

                                              if mTyp_obchodu='GMBH' then begin
                                                    mrow.prefill;
                                                    if not(ErrtElementString(mXMLHead ,'AbraDocument.Rows.Row['+inttostr(i)+'].Posindex') and (index=2)) then
                                                    mRow.SetFieldValueAsInteger('PosIndex',strtoint(mXMLHead.getElementAsString('AbraDocument.Rows.Row['+inttostr(i)+'].Posindex'))+1);
                                                    mRow.SetFieldValueAsInteger('RowType',3);
                                                    mstore_id:='2G10000101';
                                                    mRow.SetFieldValueAsString('Store_ID',mstore_id);
                                                    if mTyp_obchodu='GMBH' then begin
                                                               mstore_id:='2G10000101';
                                                               mRow.SetFieldValueAsstring('Store_id',mstore_id);
                                                    end;
                                                    if not(ErrtElementString(mXMLHead ,'AbraDocument.Rows.Row['+inttostr(i)+'].Commodity.CustomerCode') and (index=2)) then
                                                    mRow.SetFieldValueAsString('Storecard_ID',mXMLHead.getElementAsString('AbraDocument.Rows.Row['+inttostr(i)+'].Commodity.CustomerCode')); //text bude  ...
                                                    if chyba then begin
                                                        mr:=tstringlist.create;
                                                        try
                                                         if not(ErrtElementString(mXMLHead ,'AbraDocument.Rows.Row['+inttostr(i)+'].Commodity.CustomerCode') and (index=2)) then begin
                                                                 msite.BaseObjectSpace.SQLSelect('select id from storecards where hidden=' +QuotedStr('N') + ' and id=' +quotedstr(mXMLHead.getElementAsString('AbraDocument.Rows.Row['+inttostr(i)+'].Commodity.CustomerCode')),mr);
                                                                     if mr.count=0 then begin
                                                                         NxShowSimpleMessage('Pro položku ' + mXMLHead.getElementAsString('AbraDocument.Rows.Row['+inttostr(i)+'].Commodity.Name') + ' není dohledána skaldová karta', nil);
                                                                     end;
                                                         end;
                                                        finally
                                                            mr.free;
                                                        end;
                                                     end else begin
                                                                    mrsa:=TStringList.create;
                                                                     try
                                                                          mRow.ObjectSpace.SQLSelect('select max(X_Specifikace_id) from Subscribers where StoreCard_ID=' + quotedstr(mXMLHead.getElementAsString('AbraDocument.Rows.Row['+inttostr(i)+'].Commodity.CustomerCode')) + ' and  Firm_ID=' +
                                                                          quotedstr(mRow.GetFieldValueAsString('parent_id.Firm_id')),mrsa);
                                                                          if mrsa.count=1 then  begin
                                                                             if (trim(mrsa.Strings[0])<>'') and (trim(mrsa.Strings[0])<>'""') then begin
                                                                                 //NxShowSimpleMessage(mr.Strings[0],nil);
                                                                                 mRow.SetFieldValueAsString('X_specifikace_id',mrsa.Strings[0]);
                                                                             end;
                                                                          end else begin
                                                                            mRow.SetFieldValueAsString('X_specifikace_id','');

                                                                          end;;


                                                                     finally
                                                                        mrsa.free;
                                                                     end;



                                                                     mrsa:=TStringList.create;
                                                                     try
                                                                          mRow.ObjectSpace.SQLSelect('select ExternalSpecification from Subscribers where StoreCard_ID=' +
                                                                              quotedstr(mXMLHead.getElementAsString('AbraDocument.Rows.Row['+inttostr(i)+'].Commodity.CustomerCode')) + ' and Firm_ID=' +quotedstr(mRow.GetFieldValueAsString('parent_id.Firm_ID')),mrsa) ;
                                                                          if mrsa.count=1 then  begin
                                                                                  if mrsa.Strings[0]='""' then mRow.SetFieldValueAsString('X_ExternalSpecification', '') else
                                                                                 //NxShowSimpleMessage(mr.Strings[0],nil);
                                                                                        mRow.SetFieldValueAsString('X_ExternalSpecification', mrsa.Strings[0]);

                                                                          end else begin
                                                                            mRow.SetFieldValueAsString('X_ExternalSpecification', '');

                                                                          end;;


                                                                     finally
                                                                        mrsa.free;
                                                                     end;
                                                     end;

                                                    if not NxIsEmptyOID((mRow.GetFieldValueAsString('StoreCard_id.X_BusTransaction_ID'))) then begin
                                                                       mBustransaction_ID:=(mRow.GetFieldValueAsString('StoreCard_id.X_BusTransaction_ID'));
                                                                       mRow.SetFieldValueAsString('BusTransaction_id',mBustransaction_ID );
                                                    end;
                                                    if not(ErrtElementString(mXMLHead ,'AbraDocument.Rows.Row['+inttostr(i)+'].Quantity') and (index=2)) then
                                                    mRow.SetFieldValueAsFloat('Quantity',StrToFloat(mXMLHead.getElementAsString('AbraDocument.Rows.Row['+inttostr(i)+'].Quantity'))); //text bude  ...

                                                    mRow.SetFieldValueAsString('Division_ID','1J00000101'); //text bude  ...

                                                    //mRow.SetFieldValueAsboolean('ToESL',mtoESL);

                                              end else begin

                                                          if (mID_Docqueue='1710000101') or (mID_Docqueue='1S00000101') or (mID_Docqueue='1U10000101') or (mID_Docqueue='2U20000101') then mRow.SetFieldValueAsstring('Store_id','1120000101');     // hlavní expediční
                                                          if (mID_Docqueue='2S00000101') or (mID_Docqueue='2O20000101') or (mID_Docqueue='1020000101') then mRow.SetFieldValueAsstring('Store_id','2G10000101');                                    // převodový exportní

                                                           if mTyp_obchodu='B2B' then  mstore_id:='2G10000101';   // 77 Expedice EXPORT 1
                                                          if mTyp_obchodu='MAR' then mstore_id:='2G10000101';   // 77 Expedice EXPORT 1
                                                          if mTyp_obchodu='B2C' then mstore_id:='2G10000101';   // 77 Expedice EXPORT 1
                                                          if mTyp_obchodu='TOP' then mstore_id:='1120000101';     //   01001 Expedice Tuzemsko
                                                          if mTyp_obchodu='GMBH' then mstore_id:='2G10000101';//      55 EXPEDICE Export 2 GMBH
                                                          if mTyp_obchodu='MAR' then mstore_id :='2G10000101' ;
                                                          //if mID_Docqueue='2U20000101' then mRow.SetFieldValueAsString('Store_ID','2G10000101');  // 77 Expedice EXPORT 1
                                       //                   if mXMLHead.getElementAsString('ABRADocument.Docqueue')='OPOv' then mRow.SetFieldValueAsString('Store_ID','2G10000101');   //      55 EXPEDICE Export 2 GMBH
                                       //                   if mXMLHead.getElementAsString('ABRADocument.Docqueue')='OPES' then mRow.SetFieldValueAsString('Store_ID','2G10000101');   // 77 Expedice EXPORT 1


                                                          if mXMLHead.getElementAsString('ABRADocument.Docqueue')='OPES' then mstore_id:='2G10000101' ;

                                                  if mTyp_obchodu<>'TOP' then begin

                                                       if not(ErrtElementString(mXMLHead ,'AbraDocument.Rows.Row['+inttostr(i)+'].Note') and (index=2)) then
                                                       if Trim(NxRemoveDiacritics(mXMLHead.getElementAsString('AbraDocument.Rows.Row['+inttostr(i)+'].Note')))<>'' then begin
                                                           mRow.SetFieldValueAsstring('X_Note',NxRemoveDiacritics(mXMLHead.getElementAsString('AbraDocument.Rows.Row['+inttostr(i)+'].Note')));
                                                       end;
                                                  end;
                                                          if not(ErrtElementString(mXMLHead ,'AbraDocument.Rows.Row['+inttostr(i)+'].Posindex') and (index=2)) then
                                                          mRow.SetFieldValueAsInteger('PosIndex',strtoint(mXMLHead.getElementAsString('AbraDocument.Rows.Row['+inttostr(i)+'].Posindex'))+1);
                                                          if not(ErrtElementString(mXMLHead ,'AbraDocument.Rows.Row['+inttostr(i)+'].RowType') and (index=2)) then
                                                          mRow.SetFieldValueAsInteger('RowType',strtoint(mXMLHead.getElementAsString('AbraDocument.Rows.Row['+inttostr(i)+'].RowType')));

                                                          if not NxIsEmptyOID(mhead.getFieldValueAsString('FirmOffice_ID.X_Store_ID')) then begin
                                                             mstore_id:=mhead.getFieldValueAsString('FirmOffice_ID.X_Store_ID');
                                                          end;
                                                          mRow.SetFieldValueAsString('Store_ID',mstore_id);
                                                          if not(ErrtElementString(mXMLHead ,'AbraDocument.Rows.Row['+inttostr(i)+'].Commodity.CustomerCode') and (index=2)) then
                                                          mRow.SetFieldValueAsString('Storecard_ID',mXMLHead.getElementAsString('AbraDocument.Rows.Row['+inttostr(i)+'].Commodity.CustomerCode')); //text bude  ...

                                                          if not(ErrtElementString(mXMLHead ,'AbraDocument.Rows.Row['+inttostr(i)+'].Quantity') and (index=2)) then
                                                          mRow.SetFieldValueAsFloat('Quantity',StrToFloat(mXMLHead.getElementAsString('AbraDocument.Rows.Row['+inttostr(i)+'].Quantity'))); //text bude  ...

                                                          mRow.SetFieldValueAsString('Division_ID',mID_Division); //text bude  ...

                                                          if not(ErrtElementString(mXMLHead ,'AbraDocument.Rows.Row['+inttostr(i)+'].Commodity.CustomerCode') and (index=2)) then begin
                                                                if mRow.getFieldValueAsString('Storecard_ID') <> mXMLHead.getElementAsString('AbraDocument.Rows.Row['+inttostr(i)+'].Commodity.CustomerCode') then begin
                                                                   if rucne and chyba then NxShowSimpleMessage(
                                                                   'ID skladové karty: ' + mXMLHead.getElementAsString('AbraDocument.Rows.Row['+inttostr(i)+'].Commodity.CustomerCode')+
                                                                   ' neby hohledáno ( může být skryté). EAN : ' + mXMLHead.getElementAsString('AbraDocument.Rows.Row['+inttostr(i)+'].Commodity.EAN') +
                                                                   ' Název: ' +mXMLHead.getElementAsString('AbraDocument.Rows.Row['+inttostr(i)+'].Commodity.Name'),nil) ;
                                                                end;
                                                          end;
                                                          if not NxIsEmptyOID((mRow.GetFieldValueAsString('StoreCard_id.X_BusTransaction_ID'))) then begin
                                                                       mBustransaction_ID:=(mRow.GetFieldValueAsString('StoreCard_id.X_BusTransaction_ID'));
                                                                       mRow.SetFieldValueAsString('BusTransaction_id',mBustransaction_ID );
                                                          end;
                                                          if mTyp_obchodu='MAR' then begin
                                                                mRow.SetFieldValueAsFloat('Unitprice',0); //text bude  ...
                                                                mRow.SetFieldValueAsFloat('Totalprice',0); //text bude  ...
                                                          end;
                                                          if (mTyp_obchodu='B2B') or (mTyp_obchodu='B2C') or (mTyp_obchodu='TOP') or (mTyp_obchodu='GMBH') then begin
                                                              if mhead.getFieldValueAsBoolean('PricesWithVAT') then begin
                                                                    // *************

                                                                    if not(ErrtElementString(mXMLHead ,'AbraDocument.Rows.Row['+inttostr(i)+'].UnitPrice') and (index=2)) then
                                                                    mRow.SetFieldValueAsFloat('Unitprice',NxIBStrToFloat('0'+mXMLHead.getElementAsString('AbraDocument.Rows.Row['+inttostr(i)+'].UnitPrice'))); //text bude  ...
                                                                    if not(ErrtElementString(mXMLHead ,'AbraDocument.Rows.Row['+inttostr(i)+'].tamount') and (index=2)) then
                                                                    //mRow.SetFieldValueAsFloat('Totalprice',NxIBStrToFloat('0'+mXMLHead.getElementAsString('AbraDocument.Rows.Row['+inttostr(i)+'].tamount'))); //text bude  ...
                                                              end else begin
                                                                    // *********
                                                                    if not(ErrtElementString(mXMLHead ,'AbraDocument.Rows.Row['+inttostr(i)+'].UnitPrice') and (index=2)) then
                                                                        mRow.SetFieldValueAsFloat('Unitprice',NxIBStrToFloat('0'+mXMLHead.getElementAsString('AbraDocument.Rows.Row['+inttostr(i)+'].UnitPrice'))); //text bude  ...
                                                                    if not(ErrtElementString(mXMLHead ,'AbraDocument.Rows.Row['+inttostr(i)+'].TAmountWithoutVAT') and (index=2)) then
                                                                    //mRow.SetFieldValueAsFloat('Totalprice',NxIBStrToFloat('0'+mXMLHead.getElementAsString('AbraDocument.Rows.Row['+inttostr(i)+'].TAmountWithoutVAT')));
                                                              end;
                                                          end;
                                                          if (mTyp_obchodu<>'MAR') then begin
                                                              if not(ErrtElementString(mXMLHead ,'AbraDocument.Rows.Row['+inttostr(i)+'].TAmountWithoutVAT') and (index=2)) then
                                                              mRow.SetFieldValueAsFloat('TAmountWithoutVAT',NxIBStrToFloat('0'+mXMLHead.getElementAsString('AbraDocument.Rows.Row['+inttostr(i)+'].TAmountWithoutVAT'))); //text bude  ...
                                                              if not(ErrtElementString(mXMLHead ,'AbraDocument.Rows.Row['+inttostr(i)+'].TAmount') and (index=2)) then
                                                              mRow.SetFieldValueAsFloat('TAmount',NxIBStrToFloat('0'+mXMLHead.getElementAsString('AbraDocument.Rows.Row['+inttostr(i)+'].TAmount'))); //text bude  ...
                                                          end;


                                                          if mRow.getFieldValueAsinteger('ROwType') = 3 then  begin
                                                              if not NxIsEmptyOID(mRow.getFieldValueAsstring('Store_id.X_BusDivision_ID')) then begin
                                                                  mdivision_id:=mRow.getFieldValueAsstring('Store_id.X_BusDivision_ID');
                                                                  mRow.SetFieldValueAsstring('Division_ID',mdivision_id);
                                                              end;
                                                              //if not NxIsEmptyOID(mRow.getFieldValueAsstring('StoreCard_ID')) then
                                                              //      if not NxIsEmptyOID(mRow.getFieldValueAsstring('StoreCard_ID.x_Obchodni_Pripad')) then begin
                                                              //          mObchodniPripad:=mRow.getFieldValueAsstring('StoreCard_ID.x_Obchodni_Pripad');
                                                              //          mRow.SetFieldValueAsstring('BusTransaction_id',mObchodniPripad);
                                                              //      end;
                                                          end;
                                                          if mTyp_obchodu<>'GMBH'then begin
                                                              if not(ErrtElementString(mXMLHead ,'ABRADocument.Obchod') and (index=2)) then
                                                              mRow.SetFieldValueAsstring('BusProject_id',mXMLHead.getElementAsString('ABRADocument.Obchod'));
                                                              if not(ErrtElementString(mXMLHead ,'ABRADocument.Obchodnik') and (index=2)) then
                                                              mRow.SetFieldValueAsstring('BusOrder_id',mXMLHead.getElementAsString('ABRADocument.Obchodnik'));
                                                          end else begin

                                                          end;
                                                     //     mRow.SetFieldValueAsboolean('ToESL',mtoESL);
                                                          //mrow.prefill;

                                                          if mTyp_obchodu='B2B' then begin
                                                              if not(ErrtElementString(mXMLHead ,'AbraDocument.Rows.Row['+inttostr(i)+'].Specification.Jmeno') and (index=2)) then begin
                                                                      if not NxIsBlank(mXMLHead.getElementAsstring('AbraDocument.Rows.Row['+inttostr(i)+'].Specification.Jmeno')) then begin
                                                                            if not(ErrtElementString(mXMLHead ,'AbraDocument.Rows.Row['+inttostr(i)+'].Specification.Jmeno') and (index=2)) then
                                                                            if not NxIsBlank(mXMLHead.getElementAsstring('AbraDocument.Rows.Row['+inttostr(i)+'].Specification.Jmeno')) then  mRow.SetFieldValueAsString('U_Jmenopacienta',mXMLHead.getElementAsstring('AbraDocument.Rows.Row['+inttostr(i)+'].Specification.Jmeno'));
                                                                            if not(ErrtElementString(mXMLHead ,'AbraDocument.Rows.Row['+inttostr(i)+'].Specification.Telefon') and (index=2)) then
                                                                            if not NxIsBlank(mXMLHead.getElementAsstring('AbraDocument.Rows.Row['+inttostr(i)+'].Specification.Telefon')) then  mRow.SetFieldValueAsString('Telefon',mXMLHead.getElementAsstring('AbraDocument.Rows.Row['+inttostr(i)+'].Specification.Telefon'));
                                                                            if not(ErrtElementString(mXMLHead ,'AbraDocument.Rows.Row['+inttostr(i)+'].Specification.Vyska') and (index=2)) then
                                                                            if not NxIsBlank(mXMLHead.getElementAsstring('AbraDocument.Rows.Row['+inttostr(i)+'].Specification.Vyska')) then  mRow.SetFieldValueAsFloat('U_Vyska',StrToFloat(mXMLHead.getElementAsstring('AbraDocument.Rows.Row['+inttostr(i)+'].Specification.Vyska')));
                                                                            if not(ErrtElementString(mXMLHead ,'AbraDocument.Rows.Row['+inttostr(i)+'].Specification.TG') and (index=2)) then
                                                                            if not NxIsBlank(mXMLHead.getElementAsstring('AbraDocument.Rows.Row['+inttostr(i)+'].Specification.TG')) then  mRow.SetFieldValueAsFloat('U_TG',StrToFloat(mXMLHead.getElementAsstring('AbraDocument.Rows.Row['+inttostr(i)+'].Specification.TG')));
                                                                            if not(ErrtElementString(mXMLHead ,'AbraDocument.Rows.Row['+inttostr(i)+'].Specification.TF') and (index=2)) then
                                                                            if not NxIsBlank(mXMLHead.getElementAsstring('AbraDocument.Rows.Row['+inttostr(i)+'].Specification.TF')) then  mRow.SetFieldValueAsFloat('U_TF',StrToFloat(mXMLHead.getElementAsstring('AbraDocument.Rows.Row['+inttostr(i)+'].Specification.TF')));
                                                                            if not(ErrtElementString(mXMLHead ,'AbraDocument.Rows.Row['+inttostr(i)+'].Specification.TD') and (index=2)) then
                                                                            if not NxIsBlank(mXMLHead.getElementAsstring('AbraDocument.Rows.Row['+inttostr(i)+'].Specification.TD')) then  mRow.SetFieldValueAsFloat('U_TD',StrToFloat(mXMLHead.getElementAsstring('AbraDocument.Rows.Row['+inttostr(i)+'].Specification.TD')));
                                                                            if not(ErrtElementString(mXMLHead ,'AbraDocument.Rows.Row['+inttostr(i)+'].Specification.TB') and (index=2)) then
                                                                            if not NxIsBlank(mXMLHead.getElementAsstring('AbraDocument.Rows.Row['+inttostr(i)+'].Specification.TB')) then  mRow.SetFieldValueAsFloat('U_TB',StrToFloat(mXMLHead.getElementAsstring('AbraDocument.Rows.Row['+inttostr(i)+'].Specification.TB')));
                                                                            if not(ErrtElementString(mXMLHead ,'AbraDocument.Rows.Row['+inttostr(i)+'].Specification.VG') and (index=2)) then
                                                                            if not NxIsBlank(mXMLHead.getElementAsstring('AbraDocument.Rows.Row['+inttostr(i)+'].Specification.VG')) then  mRow.SetFieldValueAsFloat('U_VG',StrToFloat(mXMLHead.getElementAsstring('AbraDocument.Rows.Row['+inttostr(i)+'].Specification.VG')));
                                                                            if not(ErrtElementString(mXMLHead ,'AbraDocument.Rows.Row['+inttostr(i)+'].Specification.VD') and (index=2)) then
                                                                            if not NxIsBlank(mXMLHead.getElementAsstring('AbraDocument.Rows.Row['+inttostr(i)+'].Specification.VD')) then  mRow.SetFieldValueAsFloat('U_VD',StrToFloat(mXMLHead.getElementAsstring('AbraDocument.Rows.Row['+inttostr(i)+'].Specification.VD')));
                                                                            if not(ErrtElementString(mXMLHead ,'AbraDocument.Rows.Row['+inttostr(i)+'].Specification.VB') and (index=2)) then
                                                                            if not NxIsBlank(mXMLHead.getElementAsstring('AbraDocument.Rows.Row['+inttostr(i)+'].Specification.VB')) then  mRow.SetFieldValueAsFloat('U_VB',StrToFloat(mXMLHead.getElementAsstring('AbraDocument.Rows.Row['+inttostr(i)+'].Specification.VB')));
                                                                            if not(ErrtElementString(mXMLHead ,'AbraDocument.Rows.Row['+inttostr(i)+'].Specification.Oblicej') and (index=2)) then
                                                                            if not NxIsBlank(mXMLHead.getElementAsstring('AbraDocument.Rows.Row['+inttostr(i)+'].Specification.Oblicej')) then  mRow.SetFieldValueAsFloat('U_Oblicej',StrToFloat(mXMLHead.getElementAsstring('AbraDocument.Rows.Row['+inttostr(i)+'].Specification.Oblicej')));
                                                                            if not(ErrtElementString(mXMLHead ,'AbraDocument.Rows.Row['+inttostr(i)+'].Specification.Hlava') and (index=2)) then
                                                                            if not NxIsBlank(mXMLHead.getElementAsstring('AbraDocument.Rows.Row['+inttostr(i)+'].Specification.Hlava')) then  mRow.SetFieldValueAsFloat('U_Hlava',StrToFloat(mXMLHead.getElementAsstring('AbraDocument.Rows.Row['+inttostr(i)+'].Specification.Hlava')));
                                                                            if not(ErrtElementString(mXMLHead ,'AbraDocument.Rows.Row['+inttostr(i)+'].Specification.Krk') and (index=2)) then
                                                                            if not NxIsBlank(mXMLHead.getElementAsstring('AbraDocument.Rows.Row['+inttostr(i)+'].Specification.Krk')) then  mRow.SetFieldValueAsFloat('U_Krk',StrToFloat(mXMLHead.getElementAsstring('AbraDocument.Rows.Row['+inttostr(i)+'].Specification.Krk')));
                                                                            if not(ErrtElementString(mXMLHead ,'AbraDocument.Rows.Row['+inttostr(i)+'].Specification.Pres_prsa') and (index=2)) then
                                                                            if not NxIsBlank(mXMLHead.getElementAsstring('AbraDocument.Rows.Row['+inttostr(i)+'].Specification.Pres_prsa')) then  mRow.SetFieldValueAsFloat('U_Pres_prsa',StrToFloat(mXMLHead.getElementAsstring('AbraDocument.Rows.Row['+inttostr(i)+'].Specification.Pres_prsa')));
                                                                            if not(ErrtElementString(mXMLHead ,'AbraDocument.Rows.Row['+inttostr(i)+'].Specification.Pod_prsy') and (index=2)) then
                                                                            if not NxIsBlank(mXMLHead.getElementAsstring('AbraDocument.Rows.Row['+inttostr(i)+'].Specification.Pod_prsy')) then  mRow.SetFieldValueAsFloat('U_Pod_prsy',StrToFloat(mXMLHead.getElementAsstring('AbraDocument.Rows.Row['+inttostr(i)+'].Specification.Pod_prsy')));
                                                                            if not(ErrtElementString(mXMLHead ,'AbraDocument.Rows.Row['+inttostr(i)+'].Specification.Pas') and (index=2)) then
                                                                            if not NxIsBlank(mXMLHead.getElementAsstring('AbraDocument.Rows.Row['+inttostr(i)+'].Specification.Pas')) then  mRow.SetFieldValueAsFloat('U_Pas',StrToFloat(mXMLHead.getElementAsstring('AbraDocument.Rows.Row['+inttostr(i)+'].Specification.Pas')));
                                                                            if not(ErrtElementString(mXMLHead ,'AbraDocument.Rows.Row['+inttostr(i)+'].Specification.Stehna') and (index=2)) then
                                                                            if not NxIsBlank(mXMLHead.getElementAsstring('AbraDocument.Rows.Row['+inttostr(i)+'].Specification.Stehna')) then  mRow.SetFieldValueAsFloat('U_Stehna',StrToFloat(mXMLHead.getElementAsstring('AbraDocument.Rows.Row['+inttostr(i)+'].Specification.Stehna')));
                                                                            if not(ErrtElementString(mXMLHead ,'AbraDocument.Rows.Row['+inttostr(i)+'].Specification.Boky') and (index=2)) then
                                                                            if not NxIsBlank(mXMLHead.getElementAsstring('AbraDocument.Rows.Row['+inttostr(i)+'].Specification.Boky')) then  mRow.SetFieldValueAsFloat('U_Boky',StrToFloat(mXMLHead.getElementAsstring('AbraDocument.Rows.Row['+inttostr(i)+'].Specification.Boky')));
                                                                            if not(ErrtElementString(mXMLHead ,'AbraDocument.Rows.Row['+inttostr(i)+'].Specification.Stehno_horni') and (index=2)) then
                                                                            if not NxIsBlank(mXMLHead.getElementAsstring('AbraDocument.Rows.Row['+inttostr(i)+'].Specification.Stehno_horni')) then  mRow.SetFieldValueAsFloat('U_Stehno_horni',StrToFloat(mXMLHead.getElementAsstring('AbraDocument.Rows.Row['+inttostr(i)+'].Specification.Stehno_horni')));
                                                                            if not(ErrtElementString(mXMLHead ,'AbraDocument.Rows.Row['+inttostr(i)+'].Specification.Stehna_stredni') and (index=2)) then
                                                                            if not NxIsBlank(mXMLHead.getElementAsstring('AbraDocument.Rows.Row['+inttostr(i)+'].Specification.Stehna_stredni')) then  mRow.SetFieldValueAsFloat('U_Stehna_stredni',StrToFloat(mXMLHead.getElementAsstring('AbraDocument.Rows.Row['+inttostr(i)+'].Specification.Stehna_stredni')));
                                                                            if not(ErrtElementString(mXMLHead ,'AbraDocument.Rows.Row['+inttostr(i)+'].Specification.Nad_kolenem') and (index=2)) then
                                                                            if not NxIsBlank(mXMLHead.getElementAsstring('AbraDocument.Rows.Row['+inttostr(i)+'].Specification.Nad_kolenem')) then  mRow.SetFieldValueAsFloat('U_Nad_kolenem',StrToFloat(mXMLHead.getElementAsstring('AbraDocument.Rows.Row['+inttostr(i)+'].Specification.Nad_kolenem')));
                                                                            if not(ErrtElementString(mXMLHead ,'AbraDocument.Rows.Row['+inttostr(i)+'].Specification.Pod_kolenem') and (index=2)) then
                                                                            if not NxIsBlank(mXMLHead.getElementAsstring('AbraDocument.Rows.Row['+inttostr(i)+'].Specification.Pod_kolenem')) then  mRow.SetFieldValueAsFloat('U_Pod_kolenem',StrToFloat(mXMLHead.getElementAsstring('AbraDocument.Rows.Row['+inttostr(i)+'].Specification.Pod_kolenem')));
                                                                            if not(ErrtElementString(mXMLHead ,'AbraDocument.Rows.Row['+inttostr(i)+'].Specification.Lytko') and (index=2)) then
                                                                            if not NxIsBlank(mXMLHead.getElementAsstring('AbraDocument.Rows.Row['+inttostr(i)+'].Specification.Lytko')) then  mRow.SetFieldValueAsFloat('U_Lytko',StrToFloat(mXMLHead.getElementAsstring('AbraDocument.Rows.Row['+inttostr(i)+'].Specification.Lytko')));
                                                                            if not(ErrtElementString(mXMLHead ,'AbraDocument.Rows.Row['+inttostr(i)+'].Specification.Nad_kotnikem') and (index=2)) then
                                                                            if not NxIsBlank(mXMLHead.getElementAsstring('AbraDocument.Rows.Row['+inttostr(i)+'].Specification.Nad_kotnikem')) then  mRow.SetFieldValueAsFloat('U_Nad_kotnikem',StrToFloat(mXMLHead.getElementAsstring('AbraDocument.Rows.Row['+inttostr(i)+'].Specification.Nad_kotnikem')));
                                                                            if not(ErrtElementString(mXMLHead ,'AbraDocument.Rows.Row['+inttostr(i)+'].Specification.Brada_temeno') and (index=2)) then
                                                                            if not NxIsBlank(mXMLHead.getElementAsstring('AbraDocument.Rows.Row['+inttostr(i)+'].Specification.Brada_temeno')) then  mRow.SetFieldValueAsFloat('U_Brada_temeno',StrToFloat(mXMLHead.getElementAsstring('AbraDocument.Rows.Row['+inttostr(i)+'].Specification.Brada_temeno')));
                                                                            if not(ErrtElementString(mXMLHead ,'AbraDocument.Rows.Row['+inttostr(i)+'].Specification.Rukav') and (index=2)) then
                                                                            if not NxIsBlank(mXMLHead.getElementAsstring('AbraDocument.Rows.Row['+inttostr(i)+'].Specification.Rukav')) then  mRow.SetFieldValueAsFloat('U_Rukav',StrToFloat(mXMLHead.getElementAsstring('AbraDocument.Rows.Row['+inttostr(i)+'].Specification.Rukav')));
                                                                            if not(ErrtElementString(mXMLHead ,'AbraDocument.Rows.Row['+inttostr(i)+'].Specification.Nad_loktem1') and (index=2)) then
                                                                            if not NxIsBlank(mXMLHead.getElementAsstring('AbraDocument.Rows.Row['+inttostr(i)+'].Specification.Nad_loktem1')) then  mRow.SetFieldValueAsFloat('U_Nad_loktem1',StrToFloat(mXMLHead.getElementAsstring('AbraDocument.Rows.Row['+inttostr(i)+'].Specification.Nad_loktem1')));
                                                                            if not(ErrtElementString(mXMLHead ,'AbraDocument.Rows.Row['+inttostr(i)+'].Specification.Nad_loktem2') and (index=2)) then
                                                                            if not NxIsBlank(mXMLHead.getElementAsstring('AbraDocument.Rows.Row['+inttostr(i)+'].Specification.Nad_loktem2')) then  mRow.SetFieldValueAsFloat('U_Nad_loktem2',StrToFloat(mXMLHead.getElementAsstring('AbraDocument.Rows.Row['+inttostr(i)+'].Specification.Nad_loktem2')));
                                                                            if not(ErrtElementString(mXMLHead ,'AbraDocument.Rows.Row['+inttostr(i)+'].Specification.Nad_loktem3') and (index=2)) then
                                                                            if not NxIsBlank(mXMLHead.getElementAsstring('AbraDocument.Rows.Row['+inttostr(i)+'].Specification.Nad_loktem3')) then  mRow.SetFieldValueAsFloat('U_Nad_loktem3',StrToFloat(mXMLHead.getElementAsstring('AbraDocument.Rows.Row['+inttostr(i)+'].Specification.Nad_loktem3')));
                                                                            if not(ErrtElementString(mXMLHead ,'AbraDocument.Rows.Row['+inttostr(i)+'].Specification.barva') and (index=2)) then
                                                                            if not NxIsBlank(mXMLHead.getElementAsstring('AbraDocument.Rows.Row['+inttostr(i)+'].Specification.barva')) then mrow.setFieldValueAsstring('U_barva',mXMLHead.getElementAsstring('AbraDocument.Rows.Row['+inttostr(i)+'].Specification.barva'));
                                                                       end;
                                                               end;
                                                          end;
                                              end;
                                             if mTyp_obchodu<>'GMBH'then begin
                                                  if not(ErrtElementString(mXMLHead ,'ABRADocument.Obchod') and (index=2)) then
                                                  mRow.SetFieldValueAsstring('BusProject_id',mXMLHead.getElementAsString('ABRADocument.Obchod'));
                                                  if not(ErrtElementString(mXMLHead ,'ABRADocument.Obchodnik') and (index=2)) then
                                                  mRow.SetFieldValueAsstring('BusOrder_id',mXMLHead.getElementAsString('ABRADocument.Obchodnik'));
                                             end;
                              end;    // cyklus řádků
                              if (mID_Docqueue='1710000101') or (mID_Docqueue='2U20000101') or (mID_Docqueue='1020000101') then begin
                                  mHead.SetFieldValueAsInteger('VATRounding',(-33554175)) ;
                                  mHead.SetFieldValueAsInteger('TotalRounding',(-33554175))

                              end;


                              if rucne then begin
                                  mhead.ClearValidateErrors;
                                  if Not mhead.Validate() then begin
                                        mList := TStringList.Create;
                                        try
                                           mhead.GetValidateErrors(mList);
                                           mText := mList.Text;
                                           NxToken(mText, '=');
                                           MessageDlg('Automaticky vytvořenou objednávku nelze uložit z těchto důvodů:' + #13#10 + mText,
                                           mtWarning, [mbOK], 0);
                                         finally
                                           mList.Free;
                                         end;
                                         mSite.ShowDynFormWithNewDocument('O2XDU14IW3DL342X01C0CX3FCC', mSite.SiteContext, mhead);

                                  end else begin


                                        mhead.Save;
                                        //mhead.Save;
                                        if rucne then NxShowSimpleMessage('Objednávka ' + mhead.GetFieldValueAsstring('Docqueue_ID.code') + '-' + inttostr(mhead.GetFieldValueAsinteger('Ordnumber')) + '/' +
                                                                                mhead.GetFieldValueAsstring('Period_ID.code') + ' byla vytvořena',nil);
                                  end;
                              end else begin
                                      mhead.Save;
                                      if rucne then NxShowSimpleMessage('Objednávka ' + mhead.GetFieldValueAsstring('Docqueue_ID.code') + '-' + inttostr(mhead.GetFieldValueAsinteger('Ordnumber')) + '/' +
                                                                                mhead.GetFieldValueAsstring('Period_ID.code') + ' byla vytvořena',nil);
                              end;

                              result:=nxcopyfile(AFileName,Directory + '\Zpracovane\' + FileName);
                              if result then begin
                                  DeleteFile(AFileName);
                                  if rucne and result and chyba then begin
                                         NxShowSimpleMessage('Soubor ' + afilename + ' byl přesunut do zpracovaných',nil);
                                  end;
                              end;
                    end else begin
                        if rucne then NxShowSimpleMessage('Doklad již existuje',nil);
                    end;
                finally        // existuje
              mhead.free;
              //mrow.free;
        end;    // existuje
     finally
      mXMLHead.Free;
     end;
    Result := True;


end;



begin
end.