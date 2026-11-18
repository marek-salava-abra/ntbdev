uses 'abra.eu.mask.2017.predvyplneni.funkce',
      'Synchronizace.API' ,
       'EU.Aabra.Mask.Validace.lib',
       'abra.eu.mask_import.2018.lib';



procedure ZpracujSouborZFronty (OS: TNxCustomObjectSpace; var ProcessContinue: Boolean; Directory: string; FileName: string;msite:TDynSiteForm);
var
mOutputDocument:TNxCustomBusinessObject;
begin
  mOutputDocument := ImportFile2(OS, Directory + '\' + FileName,Directory,filename,msite,False,false,0,'1000000301');

   if mOutputDocument.oid<>'' then begin
        iSendmsg(OS, mOutputDocument , '01CPMINJW3DL342X01C0CX3FCC',
                                                                      mOutputDocument.DisplayName  + ' -  byl vytvořen novy doklad ',     // popis
                                                                      'Nový import: ' + mOutputDocument.DisplayName + ' pro ' + mOutputDocument.GetFieldValueAsString('Firm_ID.Name'),                          // tělo
                                                                      '1000000301' ,                      // komu
                                                                      mOutputDocument.getFieldValueAsString('CreatedBy_ID')); // kdo
  end;
end;


function ImportFile2(OS: TNxCustomObjectSpace; AFileName: string;directory: string;filename: string;msite:TDynSiteForm;rucne:boolean;chyba:boolean;index:Integer;mUser_ID:string) : TNxCustomBusinessObject;
var
a:integer;
 mID_Docqueue_iD,mID_Store_iD:string;
mObchodniPripad,mdivision_id:string;
mstore_id:string;
mBustransaction_ID:string;
mfind_string:string;
mr,mrsa,mxax:tstringlist;
mStoreCard_ID:string;
mBO_adress,mBO_Zaloha:TNxCustomBusinessObject;
mAdress_id:string;
mi_result:integer;
mMon,mMonZaloha:TNxCustomBusinessMonikerCollection;
mstorecard_text:string;
mbo_docqueue:TNxCustomBusinessObject;
mQunit:string;
mPacName:string;
mabraqunit:string;
mTyp_Eshopu:string;
mUnicodeName,mUnicodeCity,mUnicodeStreet,mUnicodeLocation,mUnicodeFullName:string;
mCode: integer;
mBusOrder_ID,mBusProject_ID,mbo_id:string;
mTariff: String;
mShowError:boolean;
mrx:tstringlist;
xx:integer;
mZalPrice:double;
mTypZdroje:string;
mboolean:Boolean;
mWeight:double;
begin

mShowError:=false ;
 if (mUser_ID='SUPER00000') then mShowError:=false;
    mUnicodeName:='';
    mUnicodeCity:='';
    mUnicodeStreet:= '';
    mUnicodeLocation:='';
    mUnicodeFullName:='';
    mTypZdroje:='';
    if not FileExists(AFileName) then begin
      exit;
    end else begin
    mZalPrice:=0;
    try
      mXMLHead := TNxScriptingXMLWrapper.Create;
        mXMLHead.loadFromFile(AFileName);


                      if ErrtElementString(mXMLHead ,'ABRADocuments') and (chyba) then NxShowSimpleMessage('Element "ABRADocuments" nebyl nalezen',nil) ;
                      //if ErrtElementString(mXMLHead ,'ABRADocument.Docid') and (chyba) then NxShowSimpleMessage('Element "ABRADocuments.Docid" nebyl nalezen',nil) ;
                      if ErrtElementString(mXMLHead ,'ABRADocument.Docname') and (chyba) then NxShowSimpleMessage('Element "ABRADocuments.Docname" nebyl nalezen',nil) ;
                      if ErrtElementString(mXMLHead ,'ABRADocument.Docqueue') and (chyba) then NxShowSimpleMessage('Element "ABRADocuments.Docqueue" nebyl nalezen',nil) ;
                      if ErrtElementString(mXMLHead ,'ABRADocument.Ordnumber') and (chyba) then NxShowSimpleMessage('Element "ABRADocuments.Ordnumber" nebyl nalezen',nil) ;
                      if ErrtElementString(mXMLHead ,'ABRADocument.Period') and (chyba) then NxShowSimpleMessage('Element "ABRADocuments.Period" nebyl nalezen',nil) ;
                      if ErrtElementString(mXMLHead ,'ABRADocument.Division') and (chyba) then NxShowSimpleMessage('Element "ABRADocuments.Division" nebyl nalezen',nil) ;
                      if ErrtElementString(mXMLHead ,'ABRADocument.Bank_code') and (chyba) then NxShowSimpleMessage('Element "ABRADocuments.Bank_code" nebyl nalezen',nil) ;
                      if ErrtElementString(mXMLHead ,'ABRADocument.Obchod') and (chyba) then NxShowSimpleMessage('Element "ABRADocuments.Obchod" nebyl nalezen',nil) ;
                      if ErrtElementString(mXMLHead ,'ABRADocument.Obchodnik') and (chyba) then NxShowSimpleMessage('Element "ABRADocuments.Obchodnik" nebyl nalezen',nil) ;

                      if ErrtElementString(mXMLHead ,'ABRADocument.Customer.VATPayor') and (chyba) then NxShowSimpleMessage('Element "ABRADocuments.Customer.VATPayor" nebyl nalezen',nil) ;
                      if ErrtElementString(mXMLHead ,'ABRADocument.Customer.Name') and (chyba) then NxShowSimpleMessage('Element "ABRADocuments.Customer.Name" nebyl nalezen',nil) ;
                      //if ErrtElementString(mXMLHead ,'ABRADocument.Customer.AllName') and (chyba) then NxShowSimpleMessage('Element "ABRADocuments.Customer.AllName" nebyl nalezen',nil) ;
                      if ErrtElementString(mXMLHead ,'ABRADocument.Customer.OrgIdentNumber') and (chyba) then NxShowSimpleMessage('Element "ABRADocuments.Customer.OrgIdentNumber" nebyl nalezen',nil) ;
                      if ErrtElementString(mXMLHead ,'ABRADocument.Customer.VATOrgIdentNumber') and (chyba) then NxShowSimpleMessage('Element "ABRADocuments.Customer.VATOrgIdentNumber" nebyl nalezen',nil) ;

                      if ErrtElementString(mXMLHead ,'ABRADocument.Customer.ResidenceAddress') and (chyba) then NxShowSimpleMessage('Element "ABRADocuments.Customer.ResidenceAddress" nebyl nalezen',nil) ;
                      if ErrtElementString(mXMLHead ,'ABRADocument.Customer.ResidenceAddress.Street') and (chyba) then NxShowSimpleMessage('Element "ABRADocuments.Customer.ResidenceAddress.Street" nebyl nalezen',nil) ;
                      if ErrtElementString(mXMLHead ,'ABRADocument.Customer.ResidenceAddress.City') and (chyba) then NxShowSimpleMessage('Element "ABRADocuments.Customer.ResidenceAddress.City" nebyl nalezen',nil) ;
                      if ErrtElementString(mXMLHead ,'ABRADocument.Customer.ResidenceAddress.PostCode') and (chyba) then NxShowSimpleMessage('Element "ABRADocuments.Customer.ResidenceAddress.PostCode" nebyl nalezen',nil) ;
                      if ErrtElementString(mXMLHead ,'ABRADocument.Customer.ResidenceAddress.CountryCode') and (chyba) then NxShowSimpleMessage('Element "ABRADocuments.Customer.ResidenceAddress.CountryCode" nebyl nalezen',nil) ;
                      //if ErrtElementString(mXMLHead ,'ABRADocument.Customer.ResidenceAddress.Tel1') and (chyba) then NxShowSimpleMessage('Element "ABRADocuments.Customer.ResidenceAddress.Tel1" nebyl nalezen',nil) ;
                      //if ErrtElementString(mXMLHead ,'ABRADocument.Customer.ResidenceAddress.Tel2') and (chyba) then NxShowSimpleMessage('Element "ABRADocuments.Customer.ResidenceAddress.Tel2" nebyl nalezen',nil) ;
                     // if ErrtElementString(mXMLHead ,'ABRADocument.Customer.ResidenceAddress.email') and (chyba) then NxShowSimpleMessage('Element "ABRADocuments.Customer.ResidenceAddress.email" nebyl nalezen',nil) ;
                     // if ErrtElementString(mXMLHead ,'ABRADocument.Customer.AcceptOrderEmail') and (chyba) then NxShowSimpleMessage('Element "ABRADocuments.Customer.AcceptOrderEmail" nebyl nalezen',nil) ;


                      if ErrtElementString(mXMLHead ,'ABRADocument.Customer.FirmOffice') and (chyba) then NxShowSimpleMessage('Element "ABRADocuments.Customer.FirmOffice" nebyl nalezen',nil) ;


                      if ErrtElementString(mXMLHead ,'ABRADocument.Customer.DeliveryAddress') and (chyba) then NxShowSimpleMessage('Element "ABRADocuments.Customer.DeliveryAddress" nebyl nalezen',nil) ;
                      if ErrtElementString(mXMLHead ,'ABRADocument.Customer.DeliveryAddress.Name') and (chyba) then NxShowSimpleMessage('Element "ABRADocuments.Customer.DeliveryAddress.Name" nebyl nalezen',nil) ;
                      if ErrtElementString(mXMLHead ,'ABRADocument.Customer.DeliveryAddress.Location') and (chyba) then NxShowSimpleMessage('Element "ABRADocuments.Customer.DeliveryAddress.Location" nebyl nalezen',nil) ;
                      if ErrtElementString(mXMLHead ,'ABRADocument.Customer.DeliveryAddress.Street') and (chyba) then NxShowSimpleMessage('Element "ABRADocuments.Customer.DeliveryAddress.Street" nebyl nalezen',nil) ;
                      if ErrtElementString(mXMLHead ,'ABRADocument.Customer.DeliveryAddress.City') and (chyba) then NxShowSimpleMessage('Element "ABRADocuments.Customer.DeliveryAddress.City" nebyl nalezen',nil) ;
                      if ErrtElementString(mXMLHead ,'ABRADocument.Customer.DeliveryAddress.PostCode') and (chyba) then NxShowSimpleMessage('Element "ABRADocuments.Customer.DeliveryAddress.PostCode" nebyl nalezen',nil) ;
                      if ErrtElementString(mXMLHead ,'ABRADocument.Customer.DeliveryAddress.Country') and (chyba) then NxShowSimpleMessage('Element "ABRADocuments.Customer.DeliveryAddress.Country" nebyl nalezen',nil) ;
                      if ErrtElementString(mXMLHead ,'ABRADocument.Customer.DeliveryAddress.Tel1') and (chyba) then NxShowSimpleMessage('Element "ABRADocuments.Customer.DeliveryAddress.Tel1" nebyl nalezen',nil) ;
                      if ErrtElementString(mXMLHead ,'ABRADocument.Customer.DeliveryAddress.Tel2') and (chyba) then NxShowSimpleMessage('Element "ABRADocuments.Customer.DeliveryAddress.Tel2" nebyl nalezen',nil) ;
                     // if ErrtElementString(mXMLHead ,'ABRADocument.Personid') and (chyba) then NxShowSimpleMessage('Element "ABRADocuments.Personid" nebyl nalezen',nil) ;

                      if ErrtElementString(mXMLHead ,'ABRADocument.Description') and (chyba) then NxShowSimpleMessage('Element "ABRADocuments.Description" nebyl nalezen',nil) ;
                      if ErrtElementString(mXMLHead ,'ABRADocument.VATDocument') and (chyba) then NxShowSimpleMessage('Element "ABRADocuments.VATDocument" nebyl nalezen',nil) ;
                      if ErrtElementString(mXMLHead ,'ABRADocument.VATRounding') and (chyba) then NxShowSimpleMessage('Element "ABRADocuments.VATRounding" nebyl nalezen',nil) ;
                      if ErrtElementString(mXMLHead ,'ABRADocument.TotalRounding') and (chyba) then NxShowSimpleMessage('Element "ABRADocuments.TotalRounding" nebyl nalezen',nil) ;
                      if ErrtElementString(mXMLHead ,'ABRADocument.RoundingAmount') and (chyba) then NxShowSimpleMessage('Element "ABRADocuments.RoundingAmount" nebyl nalezen',nil) ;
                      if ErrtElementString(mXMLHead ,'ABRADocument.Author') and (chyba) then NxShowSimpleMessage('Element "ABRADocuments.Author" nebyl nalezen',nil) ;
                      if ErrtElementString(mXMLHead ,'ABRADocument.ExternalNumber') and (chyba) then NxShowSimpleMessage('Element "ABRADocuments.ExternalNumber" nebyl nalezen',nil) ;
                      if ErrtElementString(mXMLHead ,'ABRADocument.TradeType') and (chyba) then NxShowSimpleMessage('Element "ABRADocuments.TradeType" nebyl nalezen',nil) ;
                      if ErrtElementString(mXMLHead ,'ABRADocument.CurrencyCode') and (chyba) then NxShowSimpleMessage('Element "ABRADocuments.CurrencyCode" nebyl nalezen',nil) ;
                      if ErrtElementString(mXMLHead ,'ABRADocument.CountryCode') and (chyba) then NxShowSimpleMessage('Element "ABRADocuments.CountryCode" nebyl nalezen',nil) ;
                      //if ErrtElementString(mXMLHead ,'ABRADocument.CurrRate') and (chyba) then NxShowSimpleMessage('Element "ABRADocuments.CurrRate" nebyl nalezen',nil) ;
                      if ErrtElementString(mXMLHead ,'ABRADocument.AmountWithoutVAT') and (chyba) then NxShowSimpleMessage('Element "ABRADocuments.AmountWithoutVAT" nebyl nalezen',nil) ;
                      if ErrtElementString(mXMLHead ,'ABRADocument.Amount') and (chyba) then NxShowSimpleMessage('Element "ABRADocuments.Amount" nebyl nalezen',nil) ;
                      if ErrtElementString(mXMLHead ,'ABRADocument.LocalTAmountWithoutVAT') and (chyba) then NxShowSimpleMessage('Element "ABRADocuments.LocalTAmountWithoutVAT" nebyl nalezen',nil) ;
                      if ErrtElementString(mXMLHead ,'ABRADocument.LocalTAmount') and (chyba) then NxShowSimpleMessage('Element "ABRADocuments.LocalTAmount" nebyl nalezen',nil) ;
                      if ErrtElementString(mXMLHead ,'ABRADocument.PricesWithVAT') and (chyba) then NxShowSimpleMessage('Element "ABRADocuments.PricesWithVAT" nebyl nalezen',nil) ;
                      if ErrtElementString(mXMLHead ,'ABRADocument.IntrastatDeliveryTerm') and (chyba) then NxShowSimpleMessage('Element "ABRADocuments.IntrastatDeliveryTerm" nebyl nalezen',nil) ;
                      if ErrtElementString(mXMLHead ,'ABRADocument.IntrastatTransactionType') and (chyba) then NxShowSimpleMessage('Element "ABRADocuments.IntrastatTransactionType" nebyl nalezen',nil) ;
                      if ErrtElementString(mXMLHead ,'ABRADocument.IntrastatTransportationType') and (chyba) then NxShowSimpleMessage('Element "ABRADocuments.IntrastatTransportationType" nebyl nalezen',nil) ;
                      if ErrtElementString(mXMLHead ,'ABRADocument.DeliveryType') and (chyba) then NxShowSimpleMessage('Element "ABRADocuments.DeliveryType" nebyl nalezen',nil) ;
                      if ErrtElementString(mXMLHead ,'ABRADocument.PaymentType') and (chyba) then NxShowSimpleMessage('Element "ABRADocuments.PaymentType" nebyl nalezen',nil) ;
                      if ErrtElementString(mXMLHead ,'ABRADocument.KonstSymbol') and (chyba) then NxShowSimpleMessage('Element "ABRADocuments.KonstSymbol" nebyl nalezen',nil) ;
                      if ErrtElementString(mXMLHead ,'ABRADocument.Voucher') and (chyba) then NxShowSimpleMessage('Element "ABRADocuments.Voucher" nebyl nalezen',nil) ;
                      if ErrtElementString(mXMLHead ,'ABRADocument.Eid') and (chyba) then NxShowSimpleMessage('Element "ABRADocuments.Eid" nebyl nalezen',nil) ;


        if ErrtElementString(mXMLHead ,'ABRADocument') and (index=2) then mDoklad := mXMLHead.getElementAsString('ABRADocument');

        //if ErrtElementString(mXMLHead ,'ABRADocument') and (index<>2) then
        mXMLHead.getElementAsString('ABRADocument.Customer');

       mObchodniPripad:='';
       mdivision_id:='';

       mtoESL:=False;
       mID_odberatel:='';
       mID_dodavatel:='';
       mID_firm_office:='';
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
       mID_odberatel:='';
       mTyp_Eshopu:='';
       mPacName := '';
       if not(ErrtElementString(mXMLHead ,'ABRADocument.Docqueue') and (index=4)) then mID_Docqueue:=getIDfromfield(os,'ID','Docqueues','Code',mXMLHead.getElementAsString('ABRADocument.Docqueue'),'Hidden','N');
       mTyp_Eshopu:=mXMLHead.getElementAsString('ABRADocument.Docqueue');
       if NxIsEmptyOID(mID_Docqueue) then begin
        mID_Docqueue:=OS.SQLSelectFirstAsString('Select id from docqueues where documenttype=''RO'' and hidden=''N'' and id='+QuotedStr(mXMLHead.getElementAsString('ABRADocument.Docqueue')),'');
        //NxShowSimpleMessage(mID_Docqueue_iD+NxCrLf+'Select id from docqueues where documenttype=''RO'' and hidden=''N'' and id='+QuotedStr(mXMLHead.getElementAsString('ABRADocument.Docqueue')),msite);
       end;
       mbo_docqueue:=OS.CreateObject('OFTMKVQH3ZD13ACL03KIU0CLP4');
       try
          mbo_docqueue.load(mID_Docqueue,nil);
                    mTyp_obchodu:=mbo_docqueue.GetFieldValueAsString('X_Typ_pripadu');
                    mID_Docqueue_iD :=mbo_docqueue.GetFieldValueAsString('X_Import_Docqueue_ID');
                    mstore_id:= mbo_docqueue.GetFieldValueAsString('X_Store_ID');
       finally
           mbo_docqueue.free;;
       end;

       if mTyp_obchodu='' then begin
           NxShowSimpleMessage('Pro řadu ' + mXMLHead.getElementAsString('ABRADocument.Docqueue') + ' není známý typ obchodu, není možné pokračovat',nil);
           exit;
       end;
      // if (mID_Docqueue='1710000101') or (mID_Docqueue='1U20000101') then mTyp_obchodu:='B2B';      // opes , opke         opke ne
      // if mID_Docqueue='2S10000101' then mTyp_obchodu:='B2C';                                       // opc                 ne
      // if (mID_Docqueue='1U10000101') or (mID_Docqueue='2U20000101') then mTyp_obchodu:='TOP';      // opte
      // if mID_Docqueue='2O20000101' then mTyp_obchodu:='MAR';                                       // opem
      // if mID_Docqueue='1020000101' then mTyp_obchodu:='GMBH';                                      // opgm


       if mXMLHead.getElementAsString('ABRADocument.Docqueue')='OPOv' then mTyp_obchodu:='GMBH';    // opov

       {if (mID_Docqueue='1710000101') or (mID_Docqueue='1S00000101') or (mID_Docqueue='1U10000101') or (mID_Docqueue='2U20000101') then mID_Docqueue_iD :='1S00000101';
       if (mID_Docqueue='2S00000101') or (mID_Docqueue='2O20000101') or (mID_Docqueue='1020000101') then mID_Docqueue_iD :='2S00000101';
       if (mID_Docqueue='1W20000101') then mID_Docqueue_iD :='1W20000101';

       if mTyp_obchodu='GMBH' then mID_Docqueue_iD :='2S00000101' ;
       if (mXMLHead.getElementAsString('ABRADocument.Docqueue')='OPE') or (mXMLHead.getElementAsString('ABRADocument.Docqueue')='OPES') then mID_Docqueue_iD :='2S00000101' ;
       if mTyp_obchodu='MAR' then mID_Docqueue_iD :='2O20000101' ;
       //mID_Docqueue_iD := mID_Docqueue ;  }


      if not(ErrtElementString(mXMLHead ,'ABRADocument.ExternalNumber') and (index=4)) then
      mexistuje:=getIDfromfield(os,'ID','ReceivedOrders','ExternalNumber',mXMLHead.getElementAsString('ABRADocument.ExternalNumber'),'','');

      if not(ErrtElementString(mXMLHead ,'ABRADocument.Division') and (index=4)) then begin
          mID_Division:=getIDfromfield(os,'ID','Divisions','Code',mXMLHead.getElementAsString('ABRADocument.Division'),'Hidden','N');
      // end else begin
          //mID_Division:='1N00000101';
       end;
      if not(ErrtElementString(mXMLHead ,'ABRADocument.Obchod')) then begin
        mID_Division:=OS.SQLSelectFirstAsString('Select division_id from busprojects where id='+QuotedStr(mXMLHead.getElementAsString('ABRADocument.obchod')),mID_Division);
      end;

      if not(ErrtElementString(mXMLHead ,'ABRADocument.CountryCode') and (index=4)) then
      mID_Country:=getIDfromfield(os,'ID','Countries','Code',mXMLHead.getElementAsString('ABRADocument.CountryCode'),'Hidden','N');
      if not ErrtElementString(mXMLHead ,'ABRADocument.CurrencyCode') and (index<>2) then
      mID_Currency:=getIDfromfield(os,'ID','Currencies','Code',mXMLHead.getElementAsString('ABRADocument.CurrencyCode'),'Hidden','N');

      if mTyp_obchodu<>'GMBH' then begin
          if not(ErrtElementString(mXMLHead ,'ABRADocument.PaymentType') and (index=4)) then
          mID_payment:=getIDfromfield(os,'ID','PaymentTypes','Code',mXMLHead.getElementAsString('ABRADocument.PaymentType'),'Hidden','N');
          if not(ErrtElementString(mXMLHead ,'ABRADocument.DeliveryType') and (index=4)) then
          mID_delivery:=getIDfromfield(os,'ID','TransportationTypes','Code',mXMLHead.getElementAsString('ABRADocument.DeliveryType'),'Hidden','N');
          //if not(ErrtElementString(mXMLHead ,'ABRADocument.KonstSymbol') and (index=4)) then
          //mID_kost_symbol:=getIDfromfield(os,'ID','ConstantSymbols','Code',mXMLHead.getElementAsString('ABRADocument.KonstSymbol'),'Hidden','N');
      end;

      if not(ErrtElementString(mXMLHead ,'ABRADocument.Eid'))  then begin
            if mXMLHead.getElementAsString('ABRADocument.Eid')<>'' then begin
                  if Length(trim(mXMLHead.getElementAsString('ABRADocument.Eid')))=10 then begin
                          if (index=2) then  NxShowSimpleMessage('EID hledá' + mXMLHead.getElementAsString('ABRADocument.Eid'),nil);
                        mr:=tstringlist.create;
                        try
                            os.SQLSelect('Select id from firms where X_E_id=' + quotedstr(mXMLHead.getElementAsString('ABRADocument.Eid')) + ' and hidden=' + quotedstr('N') + ' and firm_ID is null ',mr) ;
                             if mr.count> 0 then begin
                                  mID_odberatel:=mr.Strings[0];
                                  if (index=2) then  NxShowSimpleMessage('EID firma dohledána' + mID_odberatel,nil);
                             end else begin
                                  mID_odberatel:=mXMLHead.getElementAsString('ABRADocument.Eid');
                                  if (index=2) then  NxShowSimpleMessage('EID firma přímo' + mID_odberatel,nil);
                             end;
                        finally
                            mr.free;
                        end;
                        if (index=2) then  NxShowSimpleMessage('Základní hledání' + mID_odberatel,nil);

                        if not(ErrtElementString(mXMLHead ,'ABRADocument.Customer.FirmOffice') and (index=4)) then begin

                                    if trim(mXMLHead.getElementAsString('ABRADocument.Customer.FirmOffice'))<>'' then begin
                                       mr:=TStringList.create;
                                       try

                                           if Length(trim(mXMLHead.getElementAsString('ABRADocument.Customer.FirmOffice')))=10 then begin
                                                 msite.BaseObjectSpace.SQLSelect('select Parent_id,id from FirmOffices where id=' +quotedstr(trim(mXMLHead.getElementAsString('ABRADocument.Customer.FirmOffice'))),mr);
                                           end;

                                                   if Length(mXMLHead.getElementAsString('ABRADocument.Customer.FirmOffice'))=4 then begin
                                                         msite.BaseObjectSpace.SQLSelect('select fo.Parent_id,fo.id from FirmOffices FO join firms f on f.id=fo.parent_ID where substring(fo.OfficeIdentNumber,1,4)='
                                                         +quotedstr(trim(copy(mXMLHead.getElementAsString('ABRADocument.Customer.FirmOffice'),1,4)))
                                                         + ' And F.id=' +quotedstr(mID_odberatel)
                                                          ,mr);
                                                         if (index=2) then NxShowSimpleMessage('lipoline dotaz ' + copy(mXMLHead.getElementAsString('ABRADocument.Customer.FirmOffice'),1,4),nil);
                                                   end;

                                           if mr.count>0 then begin
                                                mID_odberatel:=copy(mr.Strings(0),1,10);
                                                mID_firm_office:=copy(mr.Strings(0),12,10);
                                               if (index=2) then  NxShowSimpleMessage('EID lipoline nalezeno ' + copy(mXMLHead.getElementAsString('ABRADocument.Customer.FirmOffice'),1,4),nil);
                                                if mShowError then  NxShowSimpleMessage('EID - B2B dceřinka ' + mID_odberatel + ' - ' +  mXMLHead.getElementAsString('ABRADocument.Customer.FirmOffice'),nil);
                                           end else begin
                                                // ***** založení provozovny
                                                // NxShowSimpleMessage('lipoline zakladani 01' + mXMLHead.getElementAsString('ABRADocument.Customer.FirmOffice'),nil);
                                                  if Length(trim(mXMLHead.getElementAsString('ABRADocument.Customer.FirmOffice')))=4 then begin
                                                       mrx:=tstringlist.Create;

                                                             try
                                                               msite.BaseObjectSpace.SQLSelect(format('select id from firms where (hidden=''N'') and (Name=%s) and (Firm_ID is null)',[quotedstr(TEncoding.RemoveDiacritics(trim(mXMLHead.getElementAsString('ABRADocument.Customer.Name'))))]),mrx);
                                                              if (index=2) then  NxShowSimpleMessage('lipoline zakladani 02' + mXMLHead.getElementAsString('ABRADocument.Customer.FirmOffice'),nil);
                                                               if mrx.count>0 then begin
                                                                    //mID_odberatel:=mrx.Strings[0] ;
                                                                  if (index=2) then  NxShowSimpleMessage('lipoline zakladani 03' + mXMLHead.getElementAsString('ABRADocument.Customer.FirmOffice'),nil);

                                                                   mfirm_office:=OS.CreateObject('AT011EZZ5DFO115YJ1HCZJDXJ4');
                                                                  if (index=2) then NxShowSimpleMessage('lipoline zakladani 04' + mXMLHead.getElementAsString('ABRADocument.Customer.FirmOffice'),nil);
                                                                  mr2:=tstringlist.create;
                                                                  try
                                                                     //os.SQLSelect('select id from FirmOffices where Parent_ID=' + quotedstr(mID_odberatel),mr2);
                                                                     if true then begin
                                                                           //if mr2.count=1 then begin
                                                                           //   mfirm_office.load(mr2.Strings[0],nil);
                                                                           //        mfirm_office.SetFieldValueAsString('Name',TranslateUnicode(trim(mXMLHead.getElementAsString('ABRADocument.Customer.AllName'))));
                                                                           //
                                                                           //        if Length(mXMLHead.getElementAsString('ABRADocument.Customer.FirmOffice'))=4 then mfirm_office.SetFieldValueAsString('OfficeIdentNumber',TranslateUnicode(trim(mXMLHead.getElementAsString('ABRADocument.Customer.FirmOffice'))));
                                                                           //        mfirm_office.save;
                                                                           //        mID_firm_office:=mfirm_office.oid;
                                                                           //end;


                                                                     //end else begin
                                                                    if (index=2) then  NxShowSimpleMessage('lipoline zakladani 05' + mXMLHead.getElementAsString('ABRADocument.Customer.FirmOffice'),nil);
                                                                         mfirm_office.new;
                                                                         mfirm_office.prefill;
                                                                         mfirm_office.SetFieldValueAsString('Parent_ID',mID_odberatel);
                                                                         mfirm_office.SetFieldValueAsString('Name',TranslateUnicode(trim(copy(mXMLHead.getElementAsString('ABRADocument.Customer.DeliveryAddress.Name'),1,30))));
                                                                         mfirm_office.SetFieldValueAsString('OfficeIdentNumber',trim(mXMLHead.getElementAsString('ABRADocument.Customer.FirmOffice')));
                                                                         mfirm_office.SetFieldValueAsString('X_code',mXMLHead.getElementAsString('ABRADocument.Customer.FirmOffice'));

                                                                          mfirm_office.SetFieldValueAsString('Address_ID.Recipient',copy(mXMLHead.getElementAsString('ABRADocument.Customer.DeliveryAddress.Name'),1,30));
                                                                          mfirm_office.SetFieldValueAsString('Address_ID.X_Location',copy(mXMLHead.getElementAsString('ABRADocument.Customer.DeliveryAddress.Location'),1,60));
                                                                          mfirm_office.SetFieldValueAsString('Address_ID.Location',copy(mXMLHead.getElementAsString('ABRADocument.Customer.DeliveryAddress.Location'),1,60));
                                                                          mfirm_office.SetFieldValueAsString('Address_ID.X_City',copy(mXMLHead.getElementAsString('ABRADocument.Customer.DeliveryAddress.City'),1,60));
                                                                          mfirm_office.SetFieldValueAsString('Address_ID.City',copy(mXMLHead.getElementAsString('ABRADocument.Customer.DeliveryAddress.City'),1,60));
                                                                          mfirm_office.SetFieldValueAsString('Address_ID.CountryCode',copy(mXMLHead.getElementAsString('ABRADocument.Customer.DeliveryAddress.Country'),1,10));
                                                                          mfirm_office.SetFieldValueAsString('Address_ID.EMail',copy(mXMLHead.getElementAsString('ABRADocument.Customer.ResidenceAddress.Email'),1,200));



                                                                          if (mXMLHead.getElementAsString('ABRADocument.Customer.ResidenceAddress.Street')= mXMLHead.getElementAsString('ABRADocument.Customer.DeliveryAddress.Street')) then begin
                                                                                  if trim(mHead.GetFieldValueAsString('Firm_ID.ResidenceAddress_ID.Street')) <>'' then begin
                                                                                     mfirm_office.SetFieldValueAsString('Address_ID.Street',mHead.GetFieldValueAsString('Firm_ID.ResidenceAddress_ID.Street'));
                                                                                     mfirm_office.SetFieldValueAsString('Address_ID.X_Street',mHead.GetFieldValueAsString('Firm_ID.ResidenceAddress_ID.Street'));
                                                                                  end else begin
                                                                                     mfirm_office.SetFieldValueAsString('Address_ID.Street',mXMLHead.getElementAsString('ABRADocument.Customer.DeliveryAddress.Street'));
                                                                                     mfirm_office.SetFieldValueAsString('Address_ID.X_Street',mXMLHead.getElementAsString('ABRADocument.Customer.DeliveryAddress.Street'));
                                                                                  end;
                                                                          end else begin

                                                                              if (mXMLHead.getElementAsString('ABRADocument.Customer.ResidenceAddress.CountryCode')<>'CZ') and
                                                                                  (mXMLHead.getElementAsString('ABRADocument.Customer.ResidenceAddress.CountryCode')<>'') and
                                                                                  (mXMLHead.getElementAsString('ABRADocument.Customer.ResidenceAddress.CountryCode')<>'SK')

                                                                                   then begin
                                                                                  mfirm_office.SetFieldValueAsString('Address_ID.X_Street',mXMLHead.getElementAsString('ABRADocument.Customer.DeliveryAddress.Street')) ;
                                                                                  mfirm_office.SetFieldValueAsString('Address_ID.Street',mXMLHead.getElementAsString('ABRADocument.Customer.DeliveryAddress.Street'));
                                                                              end else begin
                                                                                    // ********
                                                                                    if (((isTagExist(mXMLHead ,'ABRADocument.Customer.DeliveryAddress.PickupPointID'))) and (mXMLHead.getElementAsString('ABRADocument.Customer.DeliveryAddress.PickupPointID')<>'')) then begin
                                                                                          mfirm_office.SetFieldValueAsString('Address_ID.X_Street',mXMLHead.getElementAsString('ABRADocument.Customer.DeliveryAddress.Street')) ;
                                                                                          mfirm_office.SetFieldValueAsString('Address_ID.Street',mXMLHead.getElementAsString('ABRADocument.Customer.DeliveryAddress.Street'));
                                                                                    end else begin
                                                                                                  mStringCisloPopisne:='';
                                                                                                  mStringCisloPopisne:=copy(trim(mXMLHead.getElementAsString('ABRADocument.Customer.DeliveryAddress.Street')),NxAtR(' ',trim(mXMLHead.getElementAsString('ABRADocument.Customer.DeliveryAddress.Street'))),100);
                                                                                                  mStringCisloPopisne:=NxSearchReplace(mStringCisloPopisne,'/','',[srCase,srAll]);
                                                                                                  mStringCisloPopisne:=NxSearchReplace(mStringCisloPopisne,'\','',[srCase,srAll]);
                                                                                                  try
                                                                                                         if NxIBStrToFloat(mStringCisloPopisne)>0 then begin
                                                          //                                                  NxShowSimpleMessage(mStringCisloPopisne,nil);
                                                                                                         end else begin
                                                                                                             mStringCisloPopisne:=trim(mXMLHead.getElementAsString('ABRADocument.Customer.DeliveryAddress.Street'));
                                                                                                               if InputQuery('Možný problém v importu' + mXMLHead.getElementAsString('ABRADocument.ExternalNumber') +chr(10), 'Adresa ' + trim(mXMLHead.getElementAsString('ABRADocument.Customer.Name')) + ' / '+ trim(mXMLHead.getElementAsString('ABRADocument.Customer.DeliveryAddress.Tel1'))  +' je:', mStringCisloPopisne) then begin
                                                                                                                  mfirm_office.SetFieldValueAsString('Address_ID.X_Street',mStringCisloPopisne);
                                                                                                                  mfirm_office.SetFieldValueAsString('Address_ID.Street',mStringCisloPopisne);
                                                                                                               end;
                                                                                                         end;
                                                                                                   finally

                                                                                                   end;
                                                                                       end;


                                                                                     // ********
                                                                              end;
                                                                           end;



                                                                          //mfirm_office.SetFieldValueAsString('Address_ID.X_Street',copy(mXMLHead.getElementAsString('ABRADocument.Customer.DeliveryAddress.Street'),1,60));
                                                                          //mfirm_office.SetFieldValueAsString('Address_ID.Street',copy(mXMLHead.getElementAsString('ABRADocument.Customer.DeliveryAddress.Street'),1,60));
                                                                          mfirm_office.SetFieldValueAsString('Address_ID.PostCode',mXMLHead.getElementAsString('ABRADocument.Customer.DeliveryAddress.PostCode'));
                                                                          mfirm_office.SetFieldValueAsString('Address_ID.Country',copy(mXMLHead.getElementAsString('ABRADocument.Customer.DeliveryAddress.Country'),1,40));
                                                                          mfirm_office.SetFieldValueAsString('Address_ID.CountryCode',copy(mXMLHead.getElementAsString('ABRADocument.Customer.DeliveryAddress.Country'),1,10));
                                                                          mfirm_office.SetFieldValueAsString('Address_ID.PhoneNumber1',copy(mXMLHead.getElementAsString('ABRADocument.Customer.DeliveryAddress.Tel1'),1,30));
                                                                          mfirm_office.SetFieldValueAsString('Address_ID.PhoneNumber2',copy(mXMLHead.getElementAsString('ABRADocument.Customer.DeliveryAddress.Tel2'),1,30));
                                                                          mfirm_office.SetFieldValueAsString('Address_ID.EMail',copy(mXMLHead.getElementAsString('ABRADocument.Customer.ResidenceAddress.Email'),1,200));
                                                                          mfirm_office.save;
                                                                          mID_firm_office:=mfirm_office.oid;
                                                                      if (index=2) then     NxShowSimpleMessage('lipoline založeno ' + mXMLHead.getElementAsString('ABRADocument.Customer.FirmOffice'),nil);
                                                                     end;
                                                                  finally
                                                                     mr2.free;
                                                                     mfirm_office.free;
                                                                  end;




                                                                end;
                                                             finally
                                                                mrx.free;
                                                             end;
                                                  end;

                                           end   ;


                                       finally
                                           mr.free;
                                       end;
                                    end else begin
                                        // ***** dohledání provozovny    *****
                                    mID_firm_office:='';
                                    end;
                  end;

            end;
      end else begin
//         mID_odberatel:='';
//         mID_firm_office:='';
        //NxShowSimpleMessage('Položka EID neni uvedena',nil);
      end;
      end else begin
//       mID_odberatel:='';
//         mID_firm_office:='';
      if (index=2) then  NxShowSimpleMessage('EID firma' + mID_odberatel,nil);
      if (index=2) then  NxShowSimpleMessage('EID provozovna' + mID_firm_office,nil);
      end;




      if mID_odberatel='' then begin
          if mTyp_obchodu='TOP' then begin
                mID_odberatel:='';
                if not(ErrtElementString(mXMLHead ,'ABRADocument.Customer.FirmOffice') and (index=4)) then begin

                                    if trim(mXMLHead.getElementAsString('ABRADocument.Customer.FirmOffice'))<>'' then begin
                                       mr:=TStringList.create;
                                       try

                                           if Length(trim(mXMLHead.getElementAsString('ABRADocument.Customer.FirmOffice')))=10 then begin
                                                 msite.BaseObjectSpace.SQLSelect('select Parent_id,id from FirmOffices where id=' +quotedstr(trim(mXMLHead.getElementAsString('ABRADocument.Customer.FirmOffice'))),mr);
                                           end;

                                           if Length(mXMLHead.getElementAsString('ABRADocument.Customer.FirmOffice'))=4 then begin
                                                 msite.BaseObjectSpace.SQLSelect('select fo.Parent_id,fo.id from FirmOffices FO join firms f on f.id=fo.parent_ID where substring(fo.OfficeIdentNumber,1,4)='
                                                 +quotedstr(trim(copy(mXMLHead.getElementAsString('ABRADocument.Customer.FirmOffice'),1,4)))
                                                 + ' And F.name=' +quotedstr(trim(mXMLHead.getElementAsString('ABRADocument.Customer.Name')))
                                                  ,mr);
                                                 if (index=2) then NxShowSimpleMessage('lipoline dotaz ' + copy(mXMLHead.getElementAsString('ABRADocument.Customer.FirmOffice'),1,4),nil);
                                           end;

                                           if mr.count>0 then begin
                                                mID_odberatel:=copy(mr.Strings(0),1,10);
                                                mID_firm_office:=copy(mr.Strings(0),12,10);
                                               if (index=2) then  NxShowSimpleMessage('lipoline nalezeno ' + copy(mXMLHead.getElementAsString('ABRADocument.Customer.FirmOffice'),1,4),nil);
                                                //if mShowError then NxShowSimpleMessage('B2B dceřinka ' + mID_odberatel + ' - ' +  mXMLHead.getElementAsString('ABRADocument.Customer.FirmOffice'),nil);
                                           end else begin
                                                // ***** založení provozovny
                                                // NxShowSimpleMessage('lipoline zakladani 01' + mXMLHead.getElementAsString('ABRADocument.Customer.FirmOffice'),nil);
                                                  if Length(trim(mXMLHead.getElementAsString('ABRADocument.Customer.FirmOffice')))=4 then begin
                                                       mrx:=tstringlist.Create;

                                                             try
                                                               msite.BaseObjectSpace.SQLSelect(format('select id from firms where (hidden=''N'') and (Name=%s) and (Firm_ID is null)',[quotedstr(TEncoding.RemoveDiacritics(trim(mXMLHead.getElementAsString('ABRADocument.Customer.Name'))))]),mrx);
                                                              if (index=2) then  NxShowSimpleMessage('lipoline zakladani 02' + mXMLHead.getElementAsString('ABRADocument.Customer.FirmOffice'),nil);
                                                               if mrx.count>0 then begin
                                                                    mID_odberatel:=mrx.Strings[0] ;
                                                                  if (index=2) then  NxShowSimpleMessage('lipoline zakladani 03' + mXMLHead.getElementAsString('ABRADocument.Customer.FirmOffice'),nil);

                                                                   mfirm_office:=OS.CreateObject('AT011EZZ5DFO115YJ1HCZJDXJ4');
                                                                  if (index=2) then NxShowSimpleMessage('lipoline zakladani 04' + mXMLHead.getElementAsString('ABRADocument.Customer.FirmOffice'),nil);
                                                                  mr2:=tstringlist.create;
                                                                  try
                                                                     //os.SQLSelect('select id from FirmOffices where Parent_ID=' + quotedstr(mID_odberatel),mr2);
                                                                     if true then begin
                                                                           //if mr2.count=1 then begin
                                                                           //   mfirm_office.load(mr2.Strings[0],nil);
                                                                           //        mfirm_office.SetFieldValueAsString('Name',TranslateUnicode(trim(mXMLHead.getElementAsString('ABRADocument.Customer.AllName'))));
                                                                           //
                                                                           //        if Length(mXMLHead.getElementAsString('ABRADocument.Customer.FirmOffice'))=4 then mfirm_office.SetFieldValueAsString('OfficeIdentNumber',TranslateUnicode(trim(mXMLHead.getElementAsString('ABRADocument.Customer.FirmOffice'))));
                                                                           //        mfirm_office.save;
                                                                           //        mID_firm_office:=mfirm_office.oid;
                                                                           //end;


                                                                     //end else begin
                                                                    if (index=2) then  NxShowSimpleMessage('lipoline zakladani 05' + mXMLHead.getElementAsString('ABRADocument.Customer.FirmOffice'),nil);
                                                                         mfirm_office.new;
                                                                         mfirm_office.prefill;
                                                                         mfirm_office.SetFieldValueAsString('Parent_ID',mID_odberatel);
                                                                         mfirm_office.SetFieldValueAsString('Name',TranslateUnicode(trim(copy(mXMLHead.getElementAsString('ABRADocument.Customer.DeliveryAddress.Name'),1,30))));
                                                                         mfirm_office.SetFieldValueAsString('OfficeIdentNumber',trim(mXMLHead.getElementAsString('ABRADocument.Customer.FirmOffice')));
                                                                         mfirm_office.SetFieldValueAsString('X_code',mXMLHead.getElementAsString('ABRADocument.Customer.FirmOffice'));
                                                                         mfirm_office.SetFieldValueAsString('Address_ID.X_Street',copy(mXMLHead.getElementAsString('ABRADocument.Customer.DeliveryAddress.Street'),1,60));
                                                                         mfirm_office.SetFieldValueAsString('Address_ID.Street',copy(mXMLHead.getElementAsString('ABRADocument.Customer.DeliveryAddress.Street'),1,60));

                                                                          mfirm_office.SetFieldValueAsString('Address_ID.Recipient',copy(mXMLHead.getElementAsString('ABRADocument.Customer.DeliveryAddress.Name'),1,30));
                                                                          mfirm_office.SetFieldValueAsString('Address_ID.X_Location',copy(mXMLHead.getElementAsString('ABRADocument.Customer.DeliveryAddress.Location'),1,60));
                                                                          mfirm_office.SetFieldValueAsString('Address_ID.Location',copy(mXMLHead.getElementAsString('ABRADocument.Customer.DeliveryAddress.Location'),1,60));
                                                                          mfirm_office.SetFieldValueAsString('Address_ID.X_City',copy(mXMLHead.getElementAsString('ABRADocument.Customer.DeliveryAddress.City'),1,60));
                                                                          mfirm_office.SetFieldValueAsString('Address_ID.City',copy(mXMLHead.getElementAsString('ABRADocument.Customer.DeliveryAddress.City'),1,60));
                                                                          mfirm_office.SetFieldValueAsString('Address_ID.PostCode',mXMLHead.getElementAsString('ABRADocument.Customer.DeliveryAddress.PostCode'));
                                                                          mfirm_office.SetFieldValueAsString('Address_ID.Country',copy(mXMLHead.getElementAsString('ABRADocument.Customer.DeliveryAddress.Country'),1,40));
                                                                          mfirm_office.SetFieldValueAsString('Address_ID.CountryCode',copy(mXMLHead.getElementAsString('ABRADocument.Customer.DeliveryAddress.Country'),1,40));




                                                                          mfirm_office.SetFieldValueAsString('Address_ID.PhoneNumber1',copy(mXMLHead.getElementAsString('ABRADocument.Customer.DeliveryAddress.Tel1'),1,30));
                                                                          mfirm_office.SetFieldValueAsString('Address_ID.PhoneNumber2',copy(mXMLHead.getElementAsString('ABRADocument.Customer.DeliveryAddress.Tel2'),1,30));
                                                                          mfirm_office.SetFieldValueAsString('Address_ID.EMail',copy(mXMLHead.getElementAsString('ABRADocument.Customer.ResidenceAddress.Email'),1,200));
                                                                          mfirm_office.save;
                                                                          mID_firm_office:=mfirm_office.oid;
                                                                      if (index=2) then     NxShowSimpleMessage('lipoline založeno ' + mXMLHead.getElementAsString('ABRADocument.Customer.FirmOffice'),nil);
                                                                     end;
                                                                  finally
                                                                     mr2.free;
                                                                     mfirm_office.free;
                                                                  end;




                                                                end;
                                                             finally
                                                                mrx.free;
                                                             end;
                                                  end;

                                           end   ;


                                       finally
                                           mr.free;
                                       end;
                                    end else begin
                                         if mID_odberatel='' then mID_odberatel:=GetFirmID_TOP(os,mXMLHead,msite,mID_Country,mTyp_Eshopu);
                                    end;
                end;

          end;
          if mTyp_obchodu='GMBH' then mID_odberatel:='1TZ1000101';
          if (mTyp_obchodu='B2B') or (mTyp_obchodu='MAR') then mID_odberatel:='1WD1000101';
          if mTyp_obchodu='B2C' then mID_odberatel:=GetFirmID_B2C(os,mXMLHead,msite);
          //if mTyp_obchodu='B2C' then mID_odberatel:=GetFirmID_B2C(os,mXMLHead,msite);
          if mTyp_obchodu='OPTF' then mID_odberatel:=GetFirmID_B2C(os,mXMLHead,msite);
          if mTyp_obchodu='OPE' then begin

              if not(ErrtElementString(mXMLHead ,'ABRADocument.Customer.FirmOffice') and (index=4)) then begin

                                    if (trim(mXMLHead.getElementAsString('ABRADocument.Customer.FirmOffice'))<>'')
                                        //and (mID_firm_office<>'')
                                     then begin
                                       mr:=TStringList.create;
                                       try

                                           if Length(trim(mXMLHead.getElementAsString('ABRADocument.Customer.FirmOffice')))=10 then begin
                                                 msite.BaseObjectSpace.SQLSelect('select Parent_id,id from FirmOffices where id=' +quotedstr(trim(mXMLHead.getElementAsString('ABRADocument.Customer.FirmOffice'))),mr);
                                           end;

                                                   if Length(mXMLHead.getElementAsString('ABRADocument.Customer.FirmOffice'))=4 then begin
                                                         msite.BaseObjectSpace.SQLSelect('select fo.Parent_id,fo.id from FirmOffices FO join firms f on f.id=fo.parent_ID where substring(fo.OfficeIdentNumber,1,4)='
                                                         +quotedstr(trim(copy(mXMLHead.getElementAsString('ABRADocument.Customer.FirmOffice'),1,4)))
                                                         + ' And F.name=' +quotedstr(trim(mXMLHead.getElementAsString('ABRADocument.Customer.Name')))
                                                          ,mr);
                                                         if (index=2) then NxShowSimpleMessage('lipoline dotaz ' + copy(mXMLHead.getElementAsString('ABRADocument.Customer.FirmOffice'),1,4),nil);
                                                   end;

                                           if mr.count>0 then begin
                                                mID_odberatel:=copy(mr.Strings(0),1,10);
                                                mID_firm_office:=copy(mr.Strings(0),12,10);
                                                if (index=2) then  NxShowSimpleMessage('OPE firma' + mID_odberatel,nil);
                                                if (index=2) then  NxShowSimpleMessage('OPE provozovna' + mID_firm_office,nil);
                                               if (index=2) then  NxShowSimpleMessage('lipoline nalezeno ' + copy(mXMLHead.getElementAsString('ABRADocument.Customer.FirmOffice'),1,4),nil);
                                                if mShowError then  NxShowSimpleMessage('B2B dceřinka ' + mID_odberatel + ' - ' +  mXMLHead.getElementAsString('ABRADocument.Customer.FirmOffice'),nil);
                                           end else begin
                                                // ***** založení provozovny
                                                // NxShowSimpleMessage('lipoline zakladani 01' + mXMLHead.getElementAsString('ABRADocument.Customer.FirmOffice'),nil);
                                                  if Length(trim(mXMLHead.getElementAsString('ABRADocument.Customer.FirmOffice')))=4 then begin
                                                       mrx:=tstringlist.Create;

                                                             try
                                                               msite.BaseObjectSpace.SQLSelect(format('select id from firms where (hidden=''N'') and (Name=%s) and (Firm_ID is null)',[quotedstr(TEncoding.RemoveDiacritics(trim(mXMLHead.getElementAsString('ABRADocument.Customer.Name'))))]),mrx);
                                                              if (index=2) then  NxShowSimpleMessage('lipoline zakladani 02' + mXMLHead.getElementAsString('ABRADocument.Customer.FirmOffice'),nil);
                                                               if mrx.count>0 then begin
                                                                    mID_odberatel:=mrx.Strings[0] ;
                                                                  if (index=2) then  NxShowSimpleMessage('lipoline zakladani 03' + mXMLHead.getElementAsString('ABRADocument.Customer.FirmOffice'),nil);

                                                                   mfirm_office:=OS.CreateObject('AT011EZZ5DFO115YJ1HCZJDXJ4');
                                                                  if (index=2) then NxShowSimpleMessage('lipoline zakladani 04' + mXMLHead.getElementAsString('ABRADocument.Customer.FirmOffice'),nil);
                                                                  mr2:=tstringlist.create;
                                                                  try
                                                                     //os.SQLSelect('select id from FirmOffices where Parent_ID=' + quotedstr(mID_odberatel),mr2);
                                                                     if true then begin
                                                                           //if mr2.count=1 then begin
                                                                           //   mfirm_office.load(mr2.Strings[0],nil);
                                                                           //        mfirm_office.SetFieldValueAsString('Name',TranslateUnicode(trim(mXMLHead.getElementAsString('ABRADocument.Customer.AllName'))));
                                                                           //
                                                                           //        if Length(mXMLHead.getElementAsString('ABRADocument.Customer.FirmOffice'))=4 then mfirm_office.SetFieldValueAsString('OfficeIdentNumber',TranslateUnicode(trim(mXMLHead.getElementAsString('ABRADocument.Customer.FirmOffice'))));
                                                                           //        mfirm_office.save;
                                                                           //        mID_firm_office:=mfirm_office.oid;
                                                                           //end;


                                                                     //end else begin
                                                                    if (index=2) then  NxShowSimpleMessage('lipoline zakladani 05' + mXMLHead.getElementAsString('ABRADocument.Customer.FirmOffice'),nil);
                                                                         mfirm_office.new;
                                                                         mfirm_office.prefill;
                                                                         mfirm_office.SetFieldValueAsString('Parent_ID',mID_odberatel);
                                                                         mfirm_office.SetFieldValueAsString('Name',TranslateUnicode(trim(copy(mXMLHead.getElementAsString('ABRADocument.Customer.DeliveryAddress.Name'),1,30))));
                                                                         mfirm_office.SetFieldValueAsString('OfficeIdentNumber',trim(mXMLHead.getElementAsString('ABRADocument.Customer.FirmOffice')));
                                                                         mfirm_office.SetFieldValueAsString('X_code',mXMLHead.getElementAsString('ABRADocument.Customer.FirmOffice'));

                                                                          mfirm_office.SetFieldValueAsString('Address_ID.Recipient',copy(mXMLHead.getElementAsString('ABRADocument.Customer.DeliveryAddress.Name'),1,30));
                                                                          mfirm_office.SetFieldValueAsString('Address_ID.X_Location',copy(mXMLHead.getElementAsString('ABRADocument.Customer.DeliveryAddress.Location'),1,60));
                                                                          mfirm_office.SetFieldValueAsString('Address_ID.Location',copy(mXMLHead.getElementAsString('ABRADocument.Customer.DeliveryAddress.Location'),1,60));
                                                                          mfirm_office.SetFieldValueAsString('Address_ID.X_City',copy(mXMLHead.getElementAsString('ABRADocument.Customer.DeliveryAddress.City'),1,60));
                                                                          mfirm_office.SetFieldValueAsString('Address_ID.City',copy(mXMLHead.getElementAsString('ABRADocument.Customer.DeliveryAddress.City'),1,60));
                                                                          mfirm_office.SetFieldValueAsString('Address_ID.Street',copy(mXMLHead.getElementAsString('ABRADocument.Customer.DeliveryAddress.Street'),1,60));
                                                                          mfirm_office.SetFieldValueAsString('Address_ID.X_Street',copy(mXMLHead.getElementAsString('ABRADocument.Customer.DeliveryAddress.Street'),1,60));

                                                                          mfirm_office.SetFieldValueAsString('Address_ID.CountryCode',copy(mXMLHead.getElementAsString('ABRADocument.Customer.DeliveryAddress.Country'),1,10));





                                                                          if (mXMLHead.getElementAsString('ABRADocument.Customer.ResidenceAddress.Street')= mXMLHead.getElementAsString('ABRADocument.Customer.DeliveryAddress.Street')) then begin
                                                                                  if trim(mHead.GetFieldValueAsString('Firm_ID.ResidenceAddress_ID.Street'))<>'' then begin

                                                                                     mfirm_office.SetFieldValueAsString('Address_ID.Street',mHead.GetFieldValueAsString('Firm_ID.ResidenceAddress_ID.Street'));
                                                                                     mfirm_office.SetFieldValueAsString('Address_ID.X_Street',mHead.GetFieldValueAsString('Firm_ID.ResidenceAddress_ID.Street'));
                                                                                  end;
                                                                          end else begin

                                                                              if (mXMLHead.getElementAsString('ABRADocument.Customer.ResidenceAddress.CountryCode')<>'CZ') and
                                                                                  (mXMLHead.getElementAsString('ABRADocument.Customer.ResidenceAddress.CountryCode')<>'') and
                                                                                  (mXMLHead.getElementAsString('ABRADocument.Customer.ResidenceAddress.CountryCode')<>'SK')
                                                                                  then begin
                                                                                  mfirm_office.SetFieldValueAsString('Address_ID.X_Street',mXMLHead.getElementAsString('ABRADocument.Customer.DeliveryAddress.Street')) ;
                                                                                  mfirm_office.SetFieldValueAsString('Address_ID.Street',mXMLHead.getElementAsString('ABRADocument.Customer.DeliveryAddress.Street'));
                                                                              end else begin
                                                                                   if (((isTagExist(mXMLHead ,'ABRADocument.Customer.DeliveryAddress.PickupPointID'))) and (mXMLHead.getElementAsString('ABRADocument.Customer.DeliveryAddress.PickupPointID')<>'')) then begin
                                                                                        mfirm_office.SetFieldValueAsString('Address_ID.X_Street',mXMLHead.getElementAsString('ABRADocument.Customer.DeliveryAddress.Street')) ;
                                                                                        mfirm_office.SetFieldValueAsString('Address_ID.Street',mXMLHead.getElementAsString('ABRADocument.Customer.DeliveryAddress.Street'));
                                                                                   end else begin
                                                                                   // ***********
                                                                                            mStringCisloPopisne:='';
                                                                                            mStringCisloPopisne:=copy(trim(mXMLHead.getElementAsString('ABRADocument.Customer.DeliveryAddress.Street')),NxAtR(' ',trim(mXMLHead.getElementAsString('ABRADocument.Customer.DeliveryAddress.Street'))),100);
                                                                                            mStringCisloPopisne:=NxSearchReplace(mStringCisloPopisne,'/','',[srCase,srAll]);
                                                                                            mStringCisloPopisne:=NxSearchReplace(mStringCisloPopisne,'\','',[srCase,srAll]);
                                                                                            try
                                                                                                   if NxIBStrToFloat(mStringCisloPopisne)>0 then begin
                                                    //                                                  NxShowSimpleMessage(mStringCisloPopisne,nil);
                                                                                                   end else begin
                                                                                                       mStringCisloPopisne:=trim(mXMLHead.getElementAsString('ABRADocument.Customer.DeliveryAddress.Street'));
                                                                                                         if InputQuery('Možný problém v importu' + mXMLHead.getElementAsString('ABRADocument.ExternalNumber') +chr(10), 'Adresa ' + trim(mXMLHead.getElementAsString('ABRADocument.Customer.Name')) + ' / '+ trim(mXMLHead.getElementAsString('ABRADocument.Customer.DeliveryAddress.Tel1'))  +' je:', mStringCisloPopisne) then begin
                                                                                                            mfirm_office.SetFieldValueAsString('Address_ID.X_Street',mStringCisloPopisne);
                                                                                                            mfirm_office.SetFieldValueAsString('Address_ID.Street',mStringCisloPopisne);
                                                                                                         end;
                                                                                                   end;
                                                                                             finally

                                                                                             end;
                                                                                     end;
                                                                                     // *******
                                                                              end;
                                                                           end;

                                                                          mfirm_office.SetFieldValueAsString('Address_ID.PostCode',mXMLHead.getElementAsString('ABRADocument.Customer.DeliveryAddress.PostCode'));
                                                                          mfirm_office.SetFieldValueAsString('Address_ID.Country',copy(mXMLHead.getElementAsString('ABRADocument.Customer.DeliveryAddress.Country'),1,40));
                                                                          mfirm_office.SetFieldValueAsString('Address_ID.CountryCode',copy(mXMLHead.getElementAsString('ABRADocument.Customer.DeliveryAddress.Country'),1,10));

                                                                          mfirm_office.SetFieldValueAsString('Address_ID.PhoneNumber1',copy(mXMLHead.getElementAsString('ABRADocument.Customer.DeliveryAddress.Tel1'),1,30));
                                                                          mfirm_office.SetFieldValueAsString('Address_ID.PhoneNumber2',copy(mXMLHead.getElementAsString('ABRADocument.Customer.DeliveryAddress.Tel2'),1,30));
                                                                          mfirm_office.SetFieldValueAsString('Address_ID.EMail',copy(mXMLHead.getElementAsString('ABRADocument.Customer.ResidenceAddress.Email'),1,200));
                                                                          mfirm_office.save;
                                                                          mID_firm_office:=mfirm_office.oid;
                                                                      if (index=2) then     NxShowSimpleMessage('lipoline založeno ' + mXMLHead.getElementAsString('ABRADocument.Customer.FirmOffice'),nil);
                                                                     end;
                                                                  finally
                                                                     mr2.free;
                                                                     mfirm_office.free;
                                                                  end;




                                                                end;
                                                             finally
                                                                mrx.free;
                                                             end;
                                                  end;

                                           end   ;


                                       finally
                                           mr.free;
                                       end;
                                    end else begin
                                        mID_odberatel:='';
                                        mID_firm_office:='';
                                    end;
          end;

      end;

    end;
      if mID_odberatel='' then
           if (mTyp_obchodu<>'B2B') and (mTyp_obchodu<>'MAR') and (mTyp_obchodu<>'GMBH') then mID_odberatel:=GetFirmID_B2C(os,mXMLHead,msite);

        mHead := TNxHeaderBusinessObject(OS.CreateObject('01CPMINJW3DL342X01C0CX3FCC'));
        try
                if ((nxisemptyoid(mexistuje)) or ( mUser_ID='SUPER00000')) then begin
                      // if ((mUser_ID='SUPER00000') and (rucne)) then NxShowSimpleMessage('Doklad již existuje - prosím zmažte',nil);
                      mHead.New;
                      mHead.Prefill;
                      //mHead.SetFieldValueAsInteger('VATRounding',(-33554175)) ;
                      //mHead.SetFieldValueAsInteger('TotalRounding',(-33554175)) ;
                      mHead.SetFieldValueAsString('X_source', mTyp_obchodu);
                   //   if rucne and chyba then NxShowSimpleMessage('Novy',nil);
                              mHead.SetFieldValueAsString('DocQueue_ID', mID_Docqueue_ID);
                              mHead.SetFieldValueAsBoolean('PricesWithVAT',mHead.getFieldValueAsBoolean('DocQueue_ID.X_PricesWithVAT'));
                               {if not(ErrtElementString(mXMLHead ,'ABRADocument.PricesWithVAT') and (index=4)) then begin
                                       mHead.SetFieldValueAsBoolean('PricesWithVAT',mHead.SetFieldValueAsBoolean('DocQueue_ID.x_priceswithwat'));

                                  if mXMLHead.getElementAsstring('ABRADocument.PricesWithVAT') ='A' then begin
                                         mHead.SetFieldValueAsBoolean('PricesWithVAT',mHead.SetFieldValueAsBoolean('DocQueue_ID.x_priceswithwat'));
                                   end else begin
                                       mHead.SetFieldValueAsBoolean('PricesWithVAT',false) ;
                                   end;
                               end;}
                               if not(ErrtElementString(mXMLHead ,'ABRADocument.VATDocument') and (index=4)) then begin
                                   if mXMLHead.getElementAsstring('ABRADocument.VATDocument') ='A' then mHead.SetFieldValueAsBoolean('VATDocument',true) else mHead.SetFieldValueAsBoolean('VATDocument',false) ;
                               end;

                          //   if mShowError then  NxShowSimpleMessage('1' ,nil);
                              if not(ErrtElementString(mXMLHead ,'ABRADocument.TradeType') and (index=4)) then begin
                                  mHead.SetFieldValueAsInteger('Tradetype',mXMLHead.getElementAsinteger('ABRADocument.TradeType'));
                                 // if mShowError then  NxShowSimpleMessage('Tradetype: ' + inttostr(mXMLHead.getElementAsinteger('ABRADocument.TradeType')) +  ', Country: ' +mID_Country ,nil);
                                       try
                                           mHead.SetFieldValueAsString('Country_id', mID_Country);
                                       except

                                       end;

                                             if mHead.getFieldValueAsInteger('Tradetype')>1 then mID_VATcountry:='00000CZ000' else mID_VATcountry:=getIDfromfield(os,'ID','Countries','Code',mXMLHead.getElementAsString('ABRADocument.CountryCode'),'Hidden','N');
                                             if mHead.getFieldValueAsInteger('Tradetype')= 5 then mID_VATcountry:=getIDfromfield(os,'ID','Countries','Code',mXMLHead.getElementAsString('ABRADocument.CountryCode'),'Hidden','N');
                                             if ((mHead.getFieldValueAsInteger('Tradetype')>1) and (mID_VATCountry<>'')) then mHead.SetFieldValueAsString('VATCountry_ID',mID_VATCountry) ;
                                             if mHead.getFieldValueAsInteger('Tradetype')>1 then mID_country:=getIDfromfield(os,'ID','Countries','Code',mXMLHead.getElementAsString('ABRADocument.CountryCode'),'Hidden','N');
                                             if mHead.getFieldValueAsInteger('Tradetype')>1 then begin
                                                  mhead.SetFieldValueAsString('TransportationType_ID',mID_delivery);

                                             end;
                                             if mHead.getFieldValueAsInteger('Tradetype')= 4 then mID_country:=getIDfromfield(os,'ID','Countries','Code',mXMLHead.getElementAsString('ABRADocument.Customer.DeliveryAddress.Country'),'Hidden','N');
                              //    mhead.SetFieldValueAsString('Firm_ID',mID_odberatel);

                                  if not(ErrtElementString(mXMLHead ,'ABRADocument.Customer.FirmOffice') and (index=4)) then begin
                                    if mXMLHead.getElementAsString('ABRADocument.Customer.FirmOffice')<>'' then begin
                                       mhead.SetFieldValueAsString('Firm_ID',mID_odberatel);
                                       if mID_firm_office<>'' then mhead.SetFieldValueAsString('FirmOffice_ID',mID_firm_office);
                                      // mhead.SetFieldValueAsString('FirmOffice_ID',mID_firm_office);

                                  //     if mShowError then  NxShowSimpleMessage('Zapsání B2B dceřinka ' + mID_odberatel + ' - ' +  mXMLHead.getElementAsString('ABRADocument.Customer.FirmOffice'),nil);
                                       // ************************


                                    end else begin
                                       if (mTyp_obchodu='B2B') then mID_odberatel:='1WD1000101';
                                       mhead.SetFieldValueAsString('Firm_ID',mID_odberatel);
                                       if mID_firm_office<>'' then mhead.SetFieldValueAsString('FirmOffice_ID',mID_firm_office);

                                    end;
                               end;
                              end;
                           //  if mShowError then  NxShowSimpleMessage('2' ,nil);
                              if mhead.getFieldValueAsString('Firm_ID')='1WD1000101' then begin
                                     mr:=tstringlist.Create;

                                     try
                                       msite.BaseObjectSpace.SQLSelect(format('select id from firms where (hidden=''N'') and (Name=%s) and (Firm_ID is null)',[quotedstr(TEncoding.RemoveDiacritics(mXMLHead.getElementAsString('ABRADocument.Customer.Name')))]),mr);
                                       if mr.count>0 then begin
                                            mhead.setFieldValueAsString('Firm_ID',mr.Strings[0]) ;
                                        end;
                                     finally
                                        mr.free;
                                     end;
                              end;

                           //   if mShowError then  NxShowSimpleMessage('3' ,nil);
                            mAdress_id:='';
                          if not(ErrtElementString(mXMLHead ,'ABRADocument.Customer.DeliveryAddress.Name') and (index=4)) then begin


                                     if mXMLHead.getElementAsString('ABRADocument.Customer.DeliveryAddress.Name')<>'' then begin
                                            mxax:=TStringList.Create;

                                            try

                                               if isTagExist(mXMLHead ,'ABRADocument.Customer.DeliveryAddress.PickupPointID') then begin
                                                 if not NxIsblank(mXMLHead.getElementAsString('ABRADocument.Customer.DeliveryAddress.PickupPointID')) then begin
                                                             msite.BaseObjectSpace.SQLSelect(format('select id from Addresses where Recipient=%s and City=%s and Street=%s and Location=%s and X_PickupPoint=%s and PhoneNumber1=%s and EMail=%s and PostCode=%s and Country=%s ',[
                                                             quotedstr(copy(TranslateUnicode(mXMLHead.getElementAsString('ABRADocument.Customer.DeliveryAddress.Name')),1,30)),
                                                             quotedstr(copy(TranslateUnicode(mXMLHead.getElementAsString('ABRADocument.Customer.DeliveryAddress.City')),1,60)),
                                                             quotedstr(copy(TranslateUnicode(mXMLHead.getElementAsString('ABRADocument.Customer.DeliveryAddress.Street')),1,60)),
                                                             quotedstr(copy(TranslateUnicode(mXMLHead.getElementAsString('ABRADocument.Customer.DeliveryAddress.Location')),1,60)),
                                                             quotedstr(copy(mXMLHead.getElementAsString('ABRADocument.Customer.DeliveryAddress.PickupPointID'),1,10)),
                                                             quotedstr(copy(TranslateUnicode(mXMLHead.getElementAsString('ABRADocument.Customer.DeliveryAddress.Tel1')),1,30)),
                                                             quotedstr(copy(TranslateUnicode(mXMLHead.getElementAsString('ABRADocument.Customer.ResidenceAddress.email')),1,320)),
                                                             quotedstr(copy(TranslateUnicode(mXMLHead.getElementAsString('ABRADocument.Customer.DeliveryAddress.PostCode')),1,10)),
                                                             quotedstr(copy(TranslateUnicode(mXMLHead.getElementAsString('ABRADocument.Customer.DeliveryAddress.Country')),1,40))
                                                             ]),mxax);
                                                 end else begin

                                                 end;
                                               end else begin
                                                 msite.BaseObjectSpace.SQLSelect(format('select id from Addresses where Recipient=%s and City=%s and Street=%s and Location=%s and PhoneNumber1=%s  and EMail=%s and PostCode=%s and Country=%s ',[

                                                 quotedstr(copy(TranslateUnicode(mXMLHead.getElementAsString('ABRADocument.Customer.DeliveryAddress.Name')),1,30)),
                                                 quotedstr(copy(TranslateUnicode(mXMLHead.getElementAsString('ABRADocument.Customer.DeliveryAddress.City')),1,60)),
                                                 quotedstr(copy(TranslateUnicode(mXMLHead.getElementAsString('ABRADocument.Customer.DeliveryAddress.Street')),1,60)),
                                                 quotedstr(copy(TranslateUnicode(mXMLHead.getElementAsString('ABRADocument.Customer.DeliveryAddress.Location')),1,60)),
                                                 quotedstr(copy(TranslateUnicode(mXMLHead.getElementAsString('ABRADocument.Customer.DeliveryAddress.Tel1')),1,30))  ,
                                                 quotedstr(copy(TranslateUnicode(mXMLHead.getElementAsString('ABRADocument.Customer.ResidenceAddress.email')),1,320)),
                                                 quotedstr(copy(TranslateUnicode(mXMLHead.getElementAsString('ABRADocument.Customer.DeliveryAddress.PostCode')),1,10)),
                                                 quotedstr(copy(TranslateUnicode(mXMLHead.getElementAsString('ABRADocument.Customer.DeliveryAddress.Country')),1,40))



                                                 ]),mxax);
                                               end ;
                                               if mxax.count>0 then begin
                                                      mAdress_id:=mxax.Strings[0];
                                               end else begin
                                                   mBO_adress:=msite.BaseObjectSpace.CreateObject('4C3EXM5PQBCL35CH000ILPWJF4');
                                                   try
                                                          if not nxisblank(copy(mXMLHead.getElementAsString('ABRADocument.Customer.DeliveryAddress.Name'),1,30)) then begin
                                                                      mBO_adress.new;
                                                                      mBO_adress.Prefill;
                                                                      mBO_adress.SetFieldValueAsString('X_Name',copy(mXMLHead.getElementAsString('ABRADocument.Customer.DeliveryAddress.Name'),1,30));
                                                                      mBO_adress.SetFieldValueAsString('Recipient',copy(mXMLHead.getElementAsString('ABRADocument.Customer.DeliveryAddress.Name'),1,30));
                                                                      mBO_adress.SetFieldValueAsString('X_Location',copy(mXMLHead.getElementAsString('ABRADocument.Customer.DeliveryAddress.Location'),1,60));
                                                                      mBO_adress.SetFieldValueAsString('Location',copy(mXMLHead.getElementAsString('ABRADocument.Customer.DeliveryAddress.Location'),1,60));
                                                                   //   if nxIsBlank(mBO_adress.GetFieldValueAsString('Location')) then
                                                                   //      mBO_adress.SetFieldValueAsString('Location',copy(mXMLHead.getElementAsString('ABRADocument.Customer.DeliveryAddress.Name'),1,30));
                                                                      mBO_adress.SetFieldValueAsString('X_City',copy(mXMLHead.getElementAsString('ABRADocument.Customer.DeliveryAddress.City'),1,60));
                                                                      mBO_adress.SetFieldValueAsString('City',copy(mXMLHead.getElementAsString('ABRADocument.Customer.DeliveryAddress.City'),1,60));

                                                                    mBO_adress.SetFieldValueAsString('Country',copy(mXMLHead.getElementAsString('ABRADocument.Customer.DeliveryAddress.Country'),1,60));
                                                                    mBO_adress.SetFieldValueAsString('CountryCode',copy(mXMLHead.getElementAsString('ABRADocument.Customer.DeliveryAddress.Country'),1,10));

                                                                       mBO_adress.SetFieldValueAsString('Street',copy(mXMLHead.getElementAsString('ABRADocument.Customer.DeliveryAddress.Street'),1,60));
                                                                      mBO_adress.SetFieldValueAsString('X_Street',copy(mXMLHead.getElementAsString('ABRADocument.Customer.DeliveryAddress.Street'),1,60));


                                                                      if (mXMLHead.getElementAsString('ABRADocument.Customer.ResidenceAddress.Street')= mXMLHead.getElementAsString('ABRADocument.Customer.DeliveryAddress.Street')) then begin
                                                                                 if trim(mHead.GetFieldValueAsString('Firm_ID.ResidenceAddress_ID.Street'))<>'' then begin
                                                                                     mBO_adress.SetFieldValueAsString('Street',mHead.GetFieldValueAsString('Firm_ID.ResidenceAddress_ID.Street'));
                                                                                     mBO_adress.SetFieldValueAsString('X_Street',mHead.GetFieldValueAsString('Firm_ID.ResidenceAddress_ID.Street'));
                                                                                 end;
                                                                          end else begin

                                                                              if (mXMLHead.getElementAsString('ABRADocument.Customer.ResidenceAddress.CountryCode')<>'CZ') and
                                                                                  (mXMLHead.getElementAsString('ABRADocument.Customer.ResidenceAddress.CountryCode')<>'') and
                                                                                  (mXMLHead.getElementAsString('ABRADocument.Customer.ResidenceAddress.CountryCode')<>'SK')

                                                                                  then begin

                                                                                  mBO_adress.SetFieldValueAsString('X_Street',mXMLHead.getElementAsString('ABRADocument.Customer.DeliveryAddress.Street')) ;
                                                                                  mBO_adress.SetFieldValueAsString('Street',mXMLHead.getElementAsString('ABRADocument.Customer.DeliveryAddress.Street'));
                                                                              end else begin
                                                                                    if (((isTagExist(mXMLHead ,'ABRADocument.Customer.DeliveryAddress.PickupPointID'))) and (mXMLHead.getElementAsString('ABRADocument.Customer.DeliveryAddress.PickupPointID')<>'')) then begin
                                                                                       mBO_adress.SetFieldValueAsString('X_Street',mXMLHead.getElementAsString('ABRADocument.Customer.DeliveryAddress.Street')) ;
                                                                                       mBO_adress.SetFieldValueAsString('Street',mXMLHead.getElementAsString('ABRADocument.Customer.DeliveryAddress.Street'));
                                                                                    end else begin
                                                                                          mStringCisloPopisne:='';
                                                                                          mStringCisloPopisne:=copy(trim(mXMLHead.getElementAsString('ABRADocument.Customer.DeliveryAddress.Street')),NxAtR(' ',trim(mXMLHead.getElementAsString('ABRADocument.Customer.DeliveryAddress.Street'))),100);

                                                                                          mStringCisloPopisne:=NxSearchReplace(mStringCisloPopisne,'/','',[srCase,srAll]);
                                                                                          mStringCisloPopisne:=NxSearchReplace(mStringCisloPopisne,'\','',[srCase,srAll]);
                                                                                          try
                                                                                                 if NxIBStrToFloat(mStringCisloPopisne)>0 then begin
                                                  //                                                  NxShowSimpleMessage(mStringCisloPopisne,nil);
                                                                                                 end else begin
                                                                                                     mStringCisloPopisne:=trim(mXMLHead.getElementAsString('ABRADocument.Customer.DeliveryAddress.Street'));
                                                                                                       if InputQuery('Možný problém v importu' + mXMLHead.getElementAsString('ABRADocument.ExternalNumber') +chr(10), 'Adresa ' + trim(mXMLHead.getElementAsString('ABRADocument.Customer.Name')) + ' / '+ trim(mXMLHead.getElementAsString('ABRADocument.Customer.DeliveryAddress.Tel1'))  +' je:', mStringCisloPopisne) then begin
                                                                                                          mBO_adress.SetFieldValueAsString('X_Street',mStringCisloPopisne);
                                                                                                          mBO_adress.SetFieldValueAsString('Street',mStringCisloPopisne);
                                                                                                       end;
                                                                                                 end;
                                                                                           finally

                                                                                           end;
                                                                                    end;
                                                                              end;
                                                                           end;


                                                                      mBO_adress.SetFieldValueAsString('PostCode',mXMLHead.getElementAsString('ABRADocument.Customer.DeliveryAddress.PostCode'));
                                                                      mBO_adress.SetFieldValueAsString('Country',copy(mXMLHead.getElementAsString('ABRADocument.Customer.DeliveryAddress.Country'),1,40));
                                                                      mBO_adress.SetFieldValueAsString('CountryCode',copy(mXMLHead.getElementAsString('ABRADocument.Customer.DeliveryAddress.Country'),1,40));
                                                                      mBO_adress.SetFieldValueAsString('PhoneNumber1',copy(mXMLHead.getElementAsString('ABRADocument.Customer.DeliveryAddress.Tel1'),1,30));
                                                                      mBO_adress.SetFieldValueAsString('PhoneNumber2',copy(mXMLHead.getElementAsString('ABRADocument.Customer.DeliveryAddress.Tel2'),1,30));
                                                                      mBO_adress.SetFieldValueAsString('EMail',copy(mXMLHead.getElementAsString('ABRADocument.Customer.ResidenceAddress.Email'),1,200));
                                                                      if isTagExist(mXMLHead ,'ABRADocument.Customer.DeliveryAddress.PickupPointID') then
                                                                        mBO_adress.SetFieldValueAsString('X_PickupPoint', copy(mXMLHead.getElementAsString('ABRADocument.Customer.DeliveryAddress.PickupPointID'),1,10));
                                                                   mBO_adress.save;
                                                                   mAdress_id:=mBO_adress.oid;
                                                           end else begin
                                                                mAdress_id:='';
                                                           end;
                                                   finally
                                                        mBO_adress.free;
                                                   end;
                                               end;
                                               mHead.SetFieldValueAsString('X_Delivery_adress_id',mAdress_id);

                                               mHead.SetFieldValueAsinteger('DeliveryType',3);
                                               mHead.SetFieldValueAsString('DeliveryAddress_ID',mAdress_id);

                                            finally
                                               mxax.free;
                                            end;
                                     end;
                         end;



                         //if mShowError then  NxShowSimpleMessage('501 '+ mID_Country ,nil);
                              if mShowError then NxShowSimpleMessage('5011 '+ mTyp_obchodu,nil);
                         //     if mShowError then NxShowSimpleMessage('5012 '+ inttostr(mHead.getFieldValueAsInteger('Tradetype')),nil);



                                     //  mHead.SetFieldValueAsString('Country_id', '00000CZ000');
                                     // ******** chyba
                            if mID_Country<>'' then mHead.SetFieldValueAsString('Country_id', mID_Country);
                              if mShowError then  NxShowSimpleMessage('502 ',nil);



                                              if mHead.getFieldValueAsInteger('Tradetype')= 4 then begin
                                                    mID_country:=getIDfromfield(os,'ID','Countries','Code',mXMLHead.getElementAsString('ABRADocument.Customer.DeliveryAddress.Country'),'Hidden','N');

                                                    if mID_Country<>'' then mHead.SetFieldValueAsString('Country_id', mID_Country);
                                              end;




                             if mShowError then  NxShowSimpleMessage('4 ',nil);
                          if not(ErrtElementString(mXMLHead ,'ABRADocument.Personid') and (index=4)) then begin
                                    if (mXMLHead.getElementAsString('ABRADocument.Personid')<>'') and (mXMLHead.getElementAsString('ABRADocument.Personid')<>'-1') then begin
                                         mr:=tstringlist.create;
                                         try
                                             msite.BaseObjectSpace.SQLSelect('select id from persons where id=' +quotedstr(mXMLHead.getElementAsString('ABRADocument.Personid')) + ' and hidden=' + quotedstr('N'),mr);
                                             if mr.count>0 then begin
                                                mhead.SetFieldValueAsString('Person_ID',mr.Strings[0]);
                                             end  ;
                                         finally
                                            mr.free;
                                         end;
                                    end;
                          end;

                             if mShowError then  NxShowSimpleMessage('5' ,nil);

                              if not(ErrtElementString(mXMLHead ,'ABRADocument.ExternalNumber') and (index=4)) then
                              mHead.SetFieldValueAsString('ExternalNumber',mXMLHead.getElementAsString('ABRADocument.ExternalNumber'));

                              if not(ErrtElementString(mXMLHead ,'ABRADocument.ExternalNumber') and (index=4)) then   begin
                                  if NxIBStrToFloat(mXMLHead.getElementAsString('ABRADocument.ExternalNumber'))<2147483647 then begin
                                    mHead.SetFieldValueAsString('X_VarSymbol',copy(mXMLHead.getElementAsString('ABRADocument.ExternalNumber'),1,10));
                                  end else begin
                                      NxShowSimpleMessage('Číslo objednávky nellze použít jako variabilní symbol , prosím upravte ručně', nil);
                                  end;
                              end;
                               mHead.SetFieldValueAsString('X_VarSymbol_',mXMLHead.getElementAsString('ABRADocument.ExternalNumber'));
                              if not(ErrtElementString(mXMLHead ,'ABRADocument.Bank_code') and (index=4)) then
                              mhead.SetFieldValueAsString('BankAccount_ID',mXMLHead.getElementAsString('ABRADocument.Bank_code'));


                              if mShowError then  NxShowSimpleMessage('508' ,nil);
                              if mShowError then  NxShowSimpleMessage('6' ,nil);
                              if not(ErrtElementString(mXMLHead ,'ABRADocument.Description') and (index=4)) then
                              mHead.SetFieldValueAsString('Description', mXMLHead.getElementAsString('ABRADocument.Description'));

                              if isTagExist(mXMLHead ,'ABRADocument.CustomerDesc') then
                              mHead.SetFieldValueAsString('X_Poznamka', mXMLHead.getElementAsString('ABRADocument.CustomerDesc'));

                              if mID_Currency<>'' then
                              mHead.SetFieldValueAsString('Currency_ID', mID_Currency);

                              //if not(ErrtElementString(mXMLHead ,'ABRADocument.VATRounding') and (index=4)) then
                             // mHead.SetFieldValueAsString('VATRounding', mXMLHead.getElementAsinteger('ABRADocument.VATRounding'));

                             // if not(ErrtElementString(mXMLHead ,'ABRADocument.TotalRounding') and (index=4)) then
                             // mHead.SetFieldValueAsString('TotalRounding', mXMLHead.getElementAsinteger('ABRADocument.TotalRounding'));
                              if mShowError then  NxShowSimpleMessage('7' ,nil);
                              if not(ErrtElementString(mXMLHead ,'ABRADocument.RoundingAmount') and (index=4)) then
                              if NxIBStrToFloat(mXMLHead.getElementAsstring('ABRADocument.RoundingAmount'))<> 0 then begin
                                  mHead.SetFieldValueAsfloat('RoundingAmount', NxIBStrToFloat(mXMLHead.getElementAsstring('ABRADocument.RoundingAmount')));
                                  mHead.SetFieldValueAsinteger('TotalRounding',0) ;
                              end;
                                                                //NxShowSimpleMessage(
                                 if mHead.getFieldValueAsString('Currency_ID')= '0000CZK000' then   begin
                                    //NxShowSimpleMessage( avalue.AsString + ' - zaokrouhlit',nil);
                                     //mHead.SetFieldValueAsinteger('TotalRounding',(257))
                                     end else begin
                                     if not(ErrtElementString(mXMLHead ,'ABRADocument.CurrRate') and (index=4)) then
                                            if ((nxibstrtofloat(mXMLHead.getElementAsstring('ABRADocument.CurrRate'))<>0) and (nxibstrtofloat(mXMLHead.getElementAsstring('ABRADocument.CurrRate'))<>1))  then
                                                mHead.SetFieldValueAsfloat('CurrRate', nxibstrtofloat(mXMLHead.getElementAsstring('ABRADocument.CurrRate')));
                                                mHead.SetFieldValueAsinteger('TotalRounding',(0)) ;
                                     //NxShowSimpleMessage( avalue.AsString + ' - nezaokrouhlovat',nil);
                                 end;


                              if mID_payment<>'' then mhead.SetFieldValueAsString('PaymentType_ID',mID_payment);
                              if mID_delivery<>'' then mhead.SetFieldValueAsString('TransportationType_ID',mID_delivery);


                              if mHead.getFieldValueAsInteger('Tradetype')= 7 then begin
                                          mHead.SetFieldValueAsString('IntrastatDeliveryTerm_ID','3001000000');
                                          mHead.SetFieldValueAsString('IntrastatTransactionType_ID','T001000000');
                                          mHead.SetFieldValueAsString('IntrastatTransportationType_ID','4000000000');
                                          mHead.SetFieldValueAsString('U_dodaci_podminky','1000000101');
                              end;

                               //   if mID_kost_symbol<>'' then mhead.SetFieldValueAsString('ConstSymbol_ID',mID_kost_symbol);
                     if mShowError then  NxShowSimpleMessage('8' ,nil);
                     mHead.SetFieldValueAsBoolean('IsRowDiscount',True);

                     if mTyp_obchodu='GMBH' then begin

                              mID_odberatel:='1TZ1000101';
                              mHead.SetFieldValueAsstring('Firm_ID', mID_odberatel);
                      end;
                      //if strtoint(mXMLHead.getElementAsString('ABRADocument.TradeType'))<>1 then mtoESL:=True;



                      if mTyp_obchodu='MAR' then begin
                                  mRow := mHead.Rows.AddNewObject;
                                  mRow.Prefill;
                                  mRow.SetFieldValueAsInteger('PosIndex',-1);
                                  mRow.SetFieldValueAsInteger('RowType',0);
                                  mRow.SetFieldValueAsstring('Text','Marketing Discount');
                                  mRow.SetFieldValueAsString('Division_ID',mID_Division); //text bude  ...
                              end;
                                  //  if mUser_ID='SUPER00000' then NxShowSimpleMessage('Hlavička v pořádku',nil);
                              for i := 0 to mXMLHead.getElementsCountInArray('AbraDocument.Rows.Row') - 1 do begin
                                 //    if ((mUser_ID='SUPER00000') and (rucne)) then NxShowSimpleMessage(inttostr(i),nil);
                                    mQunit:='';
                                    mabraqunit:='';
                                        if ErrtElementString(mXMLHead ,'AbraDocument.Rows.Row['+inttostr(i)+'].PosIndex') then NxShowSimpleMessage('Element "AbraDocument.Rows.Row['+inttostr(i)+'].PosIndex" nebyl nalezen',nil) ;
                                        if ErrtElementString(mXMLHead ,'AbraDocument.Rows.Row['+inttostr(i)+'].RowType') then NxShowSimpleMessage('Element "AbraDocument.Rows.Row['+inttostr(i)+'].RowType" nebyl nalezen',nil) ;
                                        if ErrtElementString(mXMLHead ,'AbraDocument.Rows.Row['+inttostr(i)+'].Text') then NxShowSimpleMessage('Element "AbraDocument.Rows.Row['+inttostr(i)+'].Text" nebyl nalezen',nil) ;
                                        if ErrtElementString(mXMLHead ,'AbraDocument.Rows.Row['+inttostr(i)+'].AcceptPrices') then NxShowSimpleMessage('Element "AbraDocument.Rows.Row['+inttostr(i)+'].AcceptPrices" nebyl nalezen',nil) ;
                                        if ErrtElementString(mXMLHead ,'AbraDocument.Rows.Row['+inttostr(i)+'].Packed') then NxShowSimpleMessage('Element "AbraDocument.Rows.Row['+inttostr(i)+'].Packed" nebyl nalezen',nil) ;
                                        if ErrtElementString(mXMLHead ,'AbraDocument.Rows.Row['+inttostr(i)+'].Commodity') then NxShowSimpleMessage('Element "AbraDocument.Rows.Row['+inttostr(i)+'].Commodity" nebyl nalezen',nil) ;
                                        if ErrtElementString(mXMLHead ,'AbraDocument.Rows.Row['+inttostr(i)+'].Commodity.EAN') then NxShowSimpleMessage('Element "AbraDocument.Rows.Row['+inttostr(i)+'].Commodity.EAN" nebyl nalezen',nil) ;
                                        if ErrtElementString(mXMLHead ,'AbraDocument.Rows.Row['+inttostr(i)+'].Commodity.Name') then NxShowSimpleMessage('Element "AbraDocument.Rows.Row['+inttostr(i)+'].Commodity.Name" nebyl nalezen',nil) ;
                                        if ErrtElementString(mXMLHead ,'AbraDocument.Rows.Row['+inttostr(i)+'].Commodity.ForeignName') then NxShowSimpleMessage('Element "AbraDocument.Rows.Row['+inttostr(i)+'].Commodity.ForeignName" nebyl nalezen',nil) ;
                                        if ErrtElementString(mXMLHead ,'AbraDocument.Rows.Row['+inttostr(i)+'].UnitRate') then NxShowSimpleMessage('Element "AbraDocument.Rows.Row['+inttostr(i)+'].UnitRate" nebyl nalezen',nil) ;
                                        if ErrtElementString(mXMLHead ,'AbraDocument.Rows.Row['+inttostr(i)+'].Note') then NxShowSimpleMessage('Element "AbraDocument.Rows.Row['+inttostr(i)+'].Note" nebyl nalezen',nil) ;
                                        if ErrtElementString(mXMLHead ,'AbraDocument.Rows.Row['+inttostr(i)+'].Quantity') then NxShowSimpleMessage('Element "AbraDocument.Rows.Row['+inttostr(i)+'].Quantity" nebyl nalezen',nil) ;
                                        if ErrtElementString(mXMLHead ,'AbraDocument.Rows.Row['+inttostr(i)+'].QUnit') then NxShowSimpleMessage('Element "AbraDocument.Rows.Row['+inttostr(i)+'].QUnit" nebyl nalezen',nil) ;
                                        if ErrtElementString(mXMLHead ,'AbraDocument.Rows.Row['+inttostr(i)+'].UnitPrice') then NxShowSimpleMessage('Element "AbraDocument.Rows.Row['+inttostr(i)+'].UnitPrice" nebyl nalezen',nil) ;
                                        if ErrtElementString(mXMLHead ,'AbraDocument.Rows.Row['+inttostr(i)+'].TotalPrice') then NxShowSimpleMessage('Element "AbraDocument.Rows.Row['+inttostr(i)+'].TotalPrice" nebyl nalezen',nil) ;

                                         if ErrtElementString(mXMLHead ,'AbraDocument.Rows.Row['+inttostr(i)+'].LocalTAmountWithoutVAT') then NxShowSimpleMessage('Element "AbraDocument.Rows.Row['+inttostr(i)+'].LocalTAmountWithoutVAT" nebyl nalezen',nil) ;
                                         if ErrtElementString(mXMLHead ,'AbraDocument.Rows.Row['+inttostr(i)+'].LocalTAmount') then NxShowSimpleMessage('Element "AbraDocument.Rows.Row['+inttostr(i)+'].LocalTAmount" nebyl nalezen',nil) ;

                                        if ErrtElementString(mXMLHead ,'AbraDocument.Rows.Row['+inttostr(i)+'].Discount') then NxShowSimpleMessage('Element "AbraDocument.Rows.Row['+inttostr(i)+'].Discount" nebyl nalezen',nil) ;
                                        if ErrtElementString(mXMLHead ,'AbraDocument.Rows.Row['+inttostr(i)+'].VATRate') then NxShowSimpleMessage('Element "AbraDocument.Rows.Row['+inttostr(i)+'].VATRate" nebyl nalezen',nil) ;
                                        if ErrtElementString(mXMLHead ,'AbraDocument.Rows.Row['+inttostr(i)+'].TAmountWithoutVAT') then NxShowSimpleMessage('Element "AbraDocument.Rows.Row['+inttostr(i)+'].TAmountWithoutVAT" nebyl nalezen',nil) ;
                                        if ErrtElementString(mXMLHead ,'AbraDocument.Rows.Row['+inttostr(i)+'].TAmount') then NxShowSimpleMessage('Element "AbraDocument.Rows.Row['+inttostr(i)+'].TAmount" nebyl nalezen',nil) ;

                                                    if ErrtElementString(mXMLHead ,'AbraDocument.Rows.Row['+inttostr(i)+'].Specification') then NxShowSimpleMessage('Element "AbraDocument.Rows.Row['+inttostr(i)+'].Specification" nebyl nalezen',nil) ;
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
                                                mID_Vatrate:='';
                                   //      if mUser_ID='SUPER00000' then NxShowSimpleMessage(inttostr(i) + '- 001',nil);
                                          if not(ErrtElementString(mXMLHead ,'AbraDocument.Rows.Row['+inttostr(i)+'].Vatrate') and (index=4)) then begin
                                                if mHead.getFieldValueAsInteger('Tradetype')= 7 then begin
                                                              mr:= tstringlist.create;
                                                              try
                                                                  mTariff := mXMLHead.getElementAsString('AbraDocument.Rows.Row['+inttostr(i)+'].Vatrate');
                                                                  if mTariff = '' then mTariff := '0' ;
                                                                  os.SQLSelect('select id from VATRates where Country_ID=' + quotedstr(mID_country) +' and Tariff=' + mTariff + ' and hidden=' + quotedstr('N'),mr);

                                                                   if mr.count>0 then begin
                                                                        mID_Vatrate:=mr.strings[0];
                                                                   end else begin
                                                                        NxShowSimpleMessage('Pro uvedenou zemi není možné požít daň ' + mXMLHead.getElementAsString('AbraDocument.Rows.Row['+inttostr(i)+'].Vatrate') + '%', nil);
                                                                        if (mUser_ID<>'SUPER00000') then exit;
                                                                   end;
                                                              finally
                                                                  mr.free;
                                                              end;
                                                 end else begin
                                                          if mID_Vatrate='' then begin
                                                              if mXMLHead.getElementAsstring('AbraDocument.Rows.Row['+inttostr(i)+'].Vatrate')='21' then mID_Vatrate:='02100X0000';
                                                              if mXMLHead.getElementAsstring('AbraDocument.Rows.Row['+inttostr(i)+'].Vatrate')='15' then mID_Vatrate:='01500X0000';
                                                              if mXMLHead.getElementAsstring('AbraDocument.Rows.Row['+inttostr(i)+'].Vatrate')='20' then mID_Vatrate:='02000X0000';
                                                              if mXMLHead.getElementAsstring('AbraDocument.Rows.Row['+inttostr(i)+'].Vatrate')='14' then mID_Vatrate:='01400X0000';
                                                              if mXMLHead.getElementAsstring('AbraDocument.Rows.Row['+inttostr(i)+'].Vatrate')='0' then  mID_Vatrate:='00000X0000';
                                                          end;
                                                 end;
                                          end;
                                          mRow := mHead.Rows.AddNewObject;
                                             mRow.Prefill;

                                         if not(ErrtElementString(mXMLHead ,'ABRADocument.Obchod') and (index=4)) then
                                           mRow.SetFieldValueAsstring('BusProject_id',mXMLHead.getElementAsString('ABRADocument.Obchod'));
                                           mTypZdroje:= mRow.getFieldValueAsstring('BusProject_id.Code');
                                         if not(ErrtElementString(mXMLHead ,'ABRADocument.Obchodnik') and (index=4)) then
                                           mRow.SetFieldValueAsstring('BusOrder_id',mXMLHead.getElementAsString('ABRADocument.Obchodnik'));
                                         if IsTagExist(mXMLHead ,'AbraDocument.Rows.Row['+inttostr(i)+'].PrintLink') then
                                           mHead.SetFieldValueAsString('U_PrintLink', mXMLHead.getElementAsString('AbraDocument.Rows.Row['+inttostr(i)+'].PrintLink'));

                                           //   if ((mUser_ID='SUPER00000') and (rucne)) then NxShowSimpleMessage(inttostr(i) + '- 002',nil);
                                             mStoreCard_ID:='';
                                             mstorecard_text:='';
                                                         if not(ErrtElementString(mXMLHead ,'AbraDocument.Rows.Row['+inttostr(i)+'].Commodity.EAN') and (index=4)) then begin
                                                                if (mXMLHead.getElementAsString('AbraDocument.Rows.Row['+inttostr(i)+'].Commodity.EAN')<>'') then begin
                                                                         mr:=tstringlist.create;
                                                                          try
                                                                              msite.BaseObjectSpace.SQLSelect(format('select sc.id,su.code from STOREEANS SE left join StoreUnits SU on SU.id=se.Parent_id left join Storecards SC on sc.id=su.parent_id where ((se.EAN=%s ) or (sc.EAN=%s )) and (sc.hidden=%s) order by su.code',
                                                                              [quotedstr(mXMLHead.getElementAsString('AbraDocument.Rows.Row['+inttostr(i)+'].Commodity.EAN')),quotedstr(mXMLHead.getElementAsString('AbraDocument.Rows.Row['+inttostr(i)+'].Commodity.EAN')),QuotedStr('N')]),mr);

                                                        //NxShowSimpleMessage('Hledání skladové karty v počtu ' + inttostr(mr.count),nil);
                                                                                   if mr.count=0 then begin
                                                                                       mstorecard_text:=mXMLHead.getElementAsString('AbraDocument.Rows.Row['+inttostr(i)+'].Commodity.Ean') + ' - ' + mXMLHead.getElementAsString('AbraDocument.Rows.Row['+inttostr(i)+'].Commodity.Name');

                                                                                       mStoreCard_ID:='3NQ1000101';
                                                                                       mQunit:='ks';
                                                                                   end else begin
                                                                                       //smazat
                                                                                       if mUser_ID='SUPER00000' then begin
                                                                                               if mXMLHead.getElementAsString('AbraDocument.Rows.Row['+inttostr(i)+'].Commodity.EAN')='8591846911954' then begin
                                                                                                       NxShowSimpleMessage(mr.Strings[0],nil);
                                                                                               end;
                                                                                       end;
                                                                                       mStoreCard_ID:=copy(

                                                                                        ReplaceStr(mr.Strings[0],'"',''),1,10);

                                                                                       //if mUser_ID<>'SUPER00000' then
                                                                                       //mStoreCard_ID:=Validate_API(msite.BaseObjectSpace,mStoreCard_ID);
                                                                                       mQunit:=copy(ReplaceStr(mr.Strings[0],'"',''),12,5);

                                                                                       //NxShowSimpleMessage(mr.Strings[0],nil);
                                                                                       // ************
                                                                                   end;
                                                                           finally
                                                                                mr.free;
                                                                           end;
                                                                 end else begin
                                                                      mStoreCard_ID:='3NQ1000101';
                                                                      mQunit:='ks';
                                                                      mstorecard_text:=mXMLHead.getElementAsString('AbraDocument.Rows.Row['+inttostr(i)+'].Commodity.Ean') + ' - ' + mXMLHead.getElementAsString('AbraDocument.Rows.Row['+inttostr(i)+'].Commodity.Name');
                                                                 end;
                                                         end;

                                                         mabraqunit :='';
                                                         mr:=tstringlist.create;
                                                         try
                                                              msite.BaseObjectSpace.SQLSelect('SELECT ID FROM DefRollData A WHERE A.CLSID = ''TE4DZNKNND34R3SQOPGPEE1TU4'' and code=' + quotedstr(mQunit),mr) ;
                                                              if mr.count>0 then begin
                                                                 mAbraQunit:=copy(mr.Strings[0],1,10);
                                                              end;
                                                         finally

                                                         end;

                                          //    if mUser_ID='SUPER00000' then NxShowSimpleMessage(inttostr(i) + '- 003',nil);

                                         {
                                              mr:=TStringList.create;
                                              try
                                                     msite.BaseObjectSpace.SQLSelect(format('select su.id from StoreUnits SU where su.Parent_ID=%s and su.code=%s',[quotedstr(mStoreCard_ID),quotedstr(mXMLHead.getElementAsString('AbraDocument.Rows.Row['+inttostr(i)+'].Qunit'))]) ,mr);
                                                     if mr.count=0 then begin
                                                               if UpperCase(mXMLHead.getElementAsString('AbraDocument.Rows.Row['+inttostr(i)+'].Qunit'))='PKG' then  mQunit:='ks';
                                                               if UpperCase(mXMLHead.getElementAsString('AbraDocument.Rows.Row['+inttostr(i)+'].Qunit'))='PC' then  mQunit:='ks';
                                                               if UpperCase(mXMLHead.getElementAsString('AbraDocument.Rows.Row['+inttostr(i)+'].Qunit'))='PCX' then  mQunit:='ks';
                                                               if UpperCase(mXMLHead.getElementAsString('AbraDocument.Rows.Row['+inttostr(i)+'].Qunit'))='PCS' then  mQunit:='ks';
                                                     end;
                                                     if mr.count>1 then begin
                                                        mQunit:=mXMLHead.getElementAsString('AbraDocument.Rows.Row['+inttostr(i)+'].Qunit') ;
                                                     end;
                                              finally

                                              end;
                                                  }


                                              if mTyp_obchodu='GMBH' then begin
                                                    mrow.prefill;
                                                    if not(ErrtElementString(mXMLHead ,'AbraDocument.Rows.Row['+inttostr(i)+'].Posindex') and (index=4)) then
                                                      mRow.SetFieldValueAsInteger('PosIndex',i);
                                                    mRow.SetFieldValueAsInteger('RowType',3);
                                                    //mstore_id:='2G10000101';
                                                    mRow.SetFieldValueAsString('Store_ID',mstore_id);
                                                    mRow.SetFieldValueAsString('Storecard_ID',mStoreCard_ID);
                                                    if not(ErrtElementString(mXMLHead ,'AbraDocument.Rows.Row['+inttostr(i)+'].Quantity') and (index=4)) then
                                                      mRow.SetFieldValueAsFloat('Quantity',NxIBStrToFloat(mXMLHead.getElementAsString('AbraDocument.Rows.Row['+inttostr(i)+'].Quantity'))); //text bude  ...
                                                    mRow.SetFieldValueAsstring('QUnit',mQunit);

                                                    //else mRow.SetFieldValueAsstring('QUnit',mRow.getFieldValueAsString('Storecard_ID.MainUnitCode'));
                                                    if mStoreCard_ID='3NQ1000101'then mRow.SetFieldValueAsString('X_note',mstorecard_text);

                                                    //mRow.SetFieldValueAsstring('Store_id',mstore_id);


                                            //     if ((mUser_ID='SUPER00000') and (rucne)) then NxShowSimpleMessage(inttostr(i) + '- 004',nil);

                                                    if not nxisemptyoid(mRow.getFieldValueAsString('Storecard_ID')) then begin

                                                           mrsa:=TStringList.create;
                                                           try
                                                                msite.BaseObjectSpace.SQLSelect('select max(X_Specifikace_id) from Subscribers where StoreCard_ID=' + quotedstr(mRow.getFieldValueAsString('Storecard_ID')) + ' and  Firm_ID=' +
                                                                quotedstr(mRow.GetFieldValueAsString('parent_id.Firm_id')),mrsa);
                                                                if mrsa.count=1 then  begin
                                                                   if (trim(mrsa.Strings[0])<>'') and (trim(mrsa.Strings[0])<>'""')  then begin
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
                                                                msite.BaseObjectSpace.SQLSelect('select ExternalSpecification from Subscribers where StoreCard_ID=' +
                                                                    quotedstr(mRow.getFieldValueAsString('Storecard_ID')) + ' and Firm_ID=' +quotedstr(mRow.GetFieldValueAsString('parent_id.Firm_ID')),mrsa) ;
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

                                                           if not NxIsEmptyOID((mRow.GetFieldValueAsString('StoreCard_id.X_BusTransaction_ID'))) then begin
                                                                             mBustransaction_ID:=(mRow.GetFieldValueAsString('StoreCard_id.X_BusTransaction_ID'));
                                                                             mRow.SetFieldValueAsString('BusTransaction_id',mBustransaction_ID );
                                                           end;
                                                end;

                                                 if mShowError then  NxShowSimpleMessage('11' ,nil);
                                                    mRow.SetFieldValueAsString('Division_ID','1J00000101'); //text bude  ...

                                                     if mXMLHead.getElementAsString('AbraDocument.Rows.Row['+inttostr(i)+'].AcceptPrices')='1' then begin

                                                             //NxShowSimpleMessage('Ceny akceptovany',nil);
                                                             if mhead.getFieldValueAsBoolean('PricesWithVAT') then begin
                                                                    // ************* doplnit nul do stringu a připojit k cislu
                                                                       if not(ErrtElementString(mXMLHead ,'AbraDocument.Rows.Row['+inttostr(i)+'].UnitPrice') and (index=4)) then
                                                                    mRow.SetFieldValueAsFloat('Unitprice',NxIBStrToFloat(mXMLHead.getElementAsString('AbraDocument.Rows.Row['+inttostr(i)+'].TAmount'))/(mRow.getFieldValueAsFloat('Quantity')/mRow.getFieldValueAsFloat('unitrate') ));



                                                                     if not(ErrtElementString(mXMLHead ,'AbraDocument.Rows.Row['+inttostr(i)+'].TotalPrice') and (index=4)) then
                                                                    mRow.SetFieldValueAsFloat('Totalprice',NxIBStrToFloat(mXMLHead.getElementAsString('AbraDocument.Rows.Row['+inttostr(i)+'].TAmount')));

                                                                     if not(ErrtElementString(mXMLHead ,'AbraDocument.Rows.Row['+inttostr(i)+'].TAmountWithoutVAT') and (index=4)) then
                                                                    mRow.SetFieldValueAsfloat('TAmountWithoutVAT',NxIBStrToFloat(mXMLHead.getElementAsString('AbraDocument.Rows.Row['+inttostr(i)+'].TAmountWithoutVAT')));


                                                                    if not(ErrtElementString(mXMLHead ,'AbraDocument.Rows.Row['+inttostr(i)+'].TAmount') and (index=4)) then
                                                                    mRow.SetFieldValueAsfloat('TAmount',NxIBStrToFloat(mXMLHead.getElementAsString('AbraDocument.Rows.Row['+inttostr(i)+'].TAmount')));

                                                                      if not(ErrtElementString(mXMLHead ,'AbraDocument.Rows.Row['+inttostr(i)+'].LocalTAmountWithoutVAT') and (index=4)) then
                                                                    if NxIBStrToFloat(mXMLHead.getElementAsString('AbraDocument.Rows.Row['+inttostr(i)+'].LocalTAmountWithoutVAT'))<>0 then
                                                                    mRow.SetFieldValueAsFloat('LocalTAmountWithoutVAT',NxIBStrToFloat( mXMLHead.getElementAsString('AbraDocument.Rows.Row['+inttostr(i)+'].LocalTAmountWithoutVAT')));


                                                                     if not(ErrtElementString(mXMLHead ,'AbraDocument.Rows.Row['+inttostr(i)+'].localtamount') and (index=4)) then
                                                                    if NxIBStrToFloat(mXMLHead.getElementAsString('AbraDocument.Rows.Row['+inttostr(i)+'].localtamount'))<>0 then
                                                                    mRow.SetFieldValueAsFloat('localTamount',NxIBStrToFloat(mXMLHead.getElementAsString('AbraDocument.Rows.Row['+inttostr(i)+'].localtamount'))); //text bude  ...

                                                              end else begin

                                                              if not(ErrtElementString(mXMLHead ,'AbraDocument.Rows.Row['+inttostr(i)+'].UnitPrice') and (index=4)) then
                                                                    mRow.SetFieldValueAsFloat('Unitprice',NxIBStrToFloat(mXMLHead.getElementAsString('AbraDocument.Rows.Row['+inttostr(i)+'].TAmountWithoutVAT'))/((mRow.getFieldValueAsFloat('Quantity') / mRow.getFieldValueAsFloat('unitrate'))));


                                                                     if not(ErrtElementString(mXMLHead ,'AbraDocument.Rows.Row['+inttostr(i)+'].TotalPrice') and (index=4)) then
                                                                    mRow.SetFieldValueAsFloat('Totalprice',NxIBStrToFloat(mXMLHead.getElementAsString('AbraDocument.Rows.Row['+inttostr(i)+'].TAmountWithoutVAT')));

                                                                     if not(ErrtElementString(mXMLHead ,'AbraDocument.Rows.Row['+inttostr(i)+'].localtamount') and (index=4)) then
                                                                    if NxIBStrToFloat(mXMLHead.getElementAsString('AbraDocument.Rows.Row['+inttostr(i)+'].localtamount'))<>0 then
                                                                    mRow.SetFieldValueAsFloat('localTamount',NxIBStrToFloat(mXMLHead.getElementAsString('AbraDocument.Rows.Row['+inttostr(i)+'].localtamount'))); //text bude  ...

                                                                    if not(ErrtElementString(mXMLHead ,'AbraDocument.Rows.Row['+inttostr(i)+'].LocalTAmountWithoutVAT') and (index=4)) then
                                                                    if NxIBStrToFloat( mXMLHead.getElementAsString('AbraDocument.Rows.Row['+inttostr(i)+'].LocalTAmountWithoutVAT'))<>0 then
                                                                    mRow.SetFieldValueAsFloat('LocalTAmountWithoutVAT',NxIBStrToFloat(mXMLHead.getElementAsString('AbraDocument.Rows.Row['+inttostr(i)+'].LocalTAmountWithoutVAT')));

                                                              end;
                                                                  if not(ErrtElementString(mXMLHead ,'AbraDocument.Rows.Row['+inttostr(i)+'].TAmount') and (index=4)) then
                                                                    mRow.SetFieldValueAsfloat('TAmount',NxIBStrToFloat(mXMLHead.getElementAsString('AbraDocument.Rows.Row['+inttostr(i)+'].TAmount')));

                                                                     if not(ErrtElementString(mXMLHead ,'AbraDocument.Rows.Row['+inttostr(i)+'].TAmountWithoutVAT') and (index=4)) then
                                                                    mRow.SetFieldValueAsFloat('TAmountWithoutVAT',NxIBStrToFloat(mXMLHead.getElementAsString('AbraDocument.Rows.Row['+inttostr(i)+'].TAmountWithoutVAT')));

                                                                          if not(ErrtElementString(mXMLHead ,'AbraDocument.Rows.Row['+inttostr(i)+'].localtamount') and (index=4)) then
                                                                    if NxIBStrToFloat(mXMLHead.getElementAsString('AbraDocument.Rows.Row['+inttostr(i)+'].localtamount'))<>0 then
                                                                    mRow.SetFieldValueAsFloat('localTamount',NxIBStrToFloat(mXMLHead.getElementAsString('AbraDocument.Rows.Row['+inttostr(i)+'].localtamount'))); //text bude  ...

                                                                     if not(ErrtElementString(mXMLHead ,'AbraDocument.Rows.Row['+inttostr(i)+'].LocalTAmountWithoutVAT') and (index=4)) then
                                                                    if NxIBStrToFloat( mXMLHead.getElementAsString('AbraDocument.Rows.Row['+inttostr(i)+'].LocalTAmountWithoutVAT'))<>0 then
                                                                    mRow.SetFieldValueAsFloat('LocalTAmountWithoutVAT',NxIBStrToFloat( mXMLHead.getElementAsString('AbraDocument.Rows.Row['+inttostr(i)+'].LocalTAmountWithoutVAT')));



                                                     end else begin
                                                     //NxShowSimpleMessage('Ceny neakceptovany',nil);

                                                     end;

                                             //    if ((mUser_ID='SUPER00000') and (rucne)) then NxShowSimpleMessage(inttostr(i) + '- 006',nil);

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
                                                              if not(ErrtElementString(mXMLHead ,'ABRADocument.Obchod') and (index=4)) then
                                                              mRow.SetFieldValueAsstring('BusProject_id',mXMLHead.getElementAsString('ABRADocument.Obchod'));
                                                              if not(ErrtElementString(mXMLHead ,'ABRADocument.Obchodnik') and (index=4)) then
                                                              mRow.SetFieldValueAsstring('BusOrder_id',mXMLHead.getElementAsString('ABRADocument.Obchodnik'));
                                                          end else begin

                                                          end;

                                                    //mRow.SetFieldValueAsboolean('ToESL',mtoESL);

                                              end else begin

                                                      {    if (mID_Docqueue='1710000101') or (mID_Docqueue='1S00000101') or (mID_Docqueue='1U10000101') or (mID_Docqueue='2U20000101') then mRow.SetFieldValueAsstring('Store_id','1120000101');     // hlavní expediční
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

                                                          }

                                                //         if ((mUser_ID='SUPER00000') and (rucne)) then NxShowSimpleMessage(inttostr(i) + '- 007',nil);
                                                  if mTyp_obchodu<>'TOP' then begin

                                                       if not(ErrtElementString(mXMLHead ,'AbraDocument.Rows.Row['+inttostr(i)+'].Note') and (index=4)) then
                                                       if Trim(NxRemoveDiacritics(mXMLHead.getElementAsString('AbraDocument.Rows.Row['+inttostr(i)+'].Note')))<>'' then begin
                                                           mRow.SetFieldValueAsstring('X_Note',NxRemoveDiacritics(mXMLHead.getElementAsString('AbraDocument.Rows.Row['+inttostr(i)+'].Note')));
                                                       end;
                                                  end;
                                                          if not(ErrtElementString(mXMLHead ,'AbraDocument.Rows.Row['+inttostr(i)+'].Posindex') and (index=4)) then
                                                          mRow.SetFieldValueAsInteger('PosIndex',i);
                                                          if not(ErrtElementString(mXMLHead ,'AbraDocument.Rows.Row['+inttostr(i)+'].RowType') and (index=4)) then
                                                          mRow.SetFieldValueAsInteger('RowType',strtoint(mXMLHead.getElementAsString('AbraDocument.Rows.Row['+inttostr(i)+'].RowType')));

                                                          if NxIsEmptyOID(mstore_ID) then
                                                            if not NxIsEmptyOID(mhead.getFieldValueAsString('FirmOffice_ID.X_Store_ID')) then begin
                                                                mstore_id:=mhead.getFieldValueAsString('FirmOffice_ID.X_Store_ID');
                                                          end;

                                                          mRow.SetFieldValueAsString('Store_ID',mstore_id);
                                                          mRow.SetFieldValueAsString('Storecard_ID',mStoreCard_ID);
                                                          if not(ErrtElementString(mXMLHead ,'AbraDocument.Rows.Row['+inttostr(i)+'].Quantity') and (index=4)) then
                                                          mRow.SetFieldValueAsFloat('Quantity',NxIBStrToFloat(mXMLHead.getElementAsString('AbraDocument.Rows.Row['+inttostr(i)+'].Quantity'))); //text bude  ...

                                                         // mRow.SetFieldValueAsstring('QUnit',mXMLHead.getElementAsString('AbraDocument.Rows.Row['+inttostr(i)+'].Qunit'));

                                                         mRow.SetFieldValueAsstring('QUnit',mQunit);
                                                          if mStoreCard_ID='3NQ1000101'then mRow.SetFieldValueAsString('X_note',mstorecard_text);


                                                          mRow.SetFieldValueAsString('Division_ID',mID_Division); //text bude  ...



                                                          //xxxxxx
                                                          // voucher prodej
                                                            if not(ErrtElementString(mXMLHead ,'AbraDocument.Rows.Row['+inttostr(i)+'].Vouchers')) then begin
                                                                for xx := 0 to mXMLHead.getElementsCountInArray('AbraDocument.Rows.Row['+inttostr(i)+'].Vouchers.Voucher') - 1 do begin
                                                                      if mXMLHead.getElementAsString('AbraDocument.Rows.Row['+inttostr(i)+'].Vouchers.Voucher['+inttostr(XX)+'].SN')<>'' then begin
                                                                              mRow.SetFieldValueAsString('Text',mRow.getFieldValueAsString('Text') +mXMLHead.getElementAsString('AbraDocument.Rows.Row['+inttostr(i)+'].Vouchers.Voucher['+inttostr(XX)+'].SN')  );
                                                                              if XX<>mXMLHead.getElementsCountInArray('AbraDocument.Rows.Row['+inttostr(i)+'].Vouchers.Voucher') then begin
                                                                                    mRow.SetFieldValueAsString('Text',mRow.getFieldValueAsString('Text') +';' );
                                                                              end;



                                                                      end;
                                                                end;
                                                            end;







                                                         // if mUser_ID='SUPER00000' then NxShowSimpleMessage(inttostr(i) + '- 008',nil);
                                                              {     if rucne and chyba then NxShowSimpleMessage(
                                                                   'ID skladové karty: ' + mXMLHead.getElementAsString('AbraDocument.Rows.Row['+inttostr(i)+'].Commodity.CustomerCode')+
                                                                   ' neby hohledáno ( může být skryté). EAN : ' + mXMLHead.getElementAsString('AbraDocument.Rows.Row['+inttostr(i)+'].Commodity.EAN') +
                                                                   ' Název: ' +mXMLHead.getElementAsString('AbraDocument.Rows.Row['+inttostr(i)+'].Commodity.Name'),nil) ;
                                                              }

                                                          if not NxIsEmptyOID((mRow.GetFieldValueAsString('StoreCard_id.X_BusTransaction_ID'))) then begin
                                                                       mBustransaction_ID:=(mRow.GetFieldValueAsString('StoreCard_id.X_BusTransaction_ID'));
                                                                       mRow.SetFieldValueAsString('BusTransaction_id',mBustransaction_ID );
                                                          end;

                                                          if mTyp_obchodu<>'GMBH'then begin
                                                                if not(ErrtElementString(mXMLHead ,'ABRADocument.Obchod') and (index=4)) then
                                                                mRow.SetFieldValueAsstring('BusProject_id',mXMLHead.getElementAsString('ABRADocument.Obchod'));
                                                                if not(ErrtElementString(mXMLHead ,'ABRADocument.Obchodnik') and (index=4)) then
                                                                mRow.SetFieldValueAsstring('BusOrder_id',mXMLHead.getElementAsString('ABRADocument.Obchodnik'));
                                                           end;

                                                           if mXMLHead.getElementAsString('AbraDocument.Rows.Row['+inttostr(i)+'].AcceptPrices')='1' then begin
                                                               if  mhead.getFieldValueAsBoolean('PricesWithVAT') then begin
                                                                    // *************      doplnit nulo

                                                                    if not(ErrtElementString(mXMLHead ,'AbraDocument.Rows.Row['+inttostr(i)+'].UnitPrice') and (index=4)) then
                                                                    mRow.SetFieldValueAsFloat('Unitprice',NxIBStrToFloat(mXMLHead.getElementAsString('AbraDocument.Rows.Row['+inttostr(i)+'].TAmount'))/(mRow.getFieldValueAsFloat('Quantity')/(mRow.getFieldValueAsFloat('unitrate')) ));

                                                                     if not(ErrtElementString(mXMLHead ,'AbraDocument.Rows.Row['+inttostr(i)+'].TotalPrice') and (index=4)) then
                                                                    mRow.SetFieldValueAsFloat('Totalprice',NxIBStrToFloat(mXMLHead.getElementAsString('AbraDocument.Rows.Row['+inttostr(i)+'].TAmount')));

                                                                 {   if not(ErrtElementString(mXMLHead ,'AbraDocument.Rows.Row['+inttostr(i)+'].localtamount') and (index=4)) then
                                                                    mRow.SetFieldValueAsFloat('localTamount',NxIBStrToFloat('0'+mXMLHead.getElementAsString('AbraDocument.Rows.Row['+inttostr(i)+'].localtamount'))); //text bude  ...

                                                                    if not(ErrtElementString(mXMLHead ,'AbraDocument.Rows.Row['+inttostr(i)+'].LocalTAmountWithoutVAT') and (index=4)) then
                                                                    mRow.SetFieldValueAsFloat('LocalTAmountWithoutVAT',NxIBStrToFloat('0'+ mXMLHead.getElementAsString('AbraDocument.Rows.Row['+inttostr(i)+'].LocalTAmountWithoutVAT')));

                                                                    if not(ErrtElementString(mXMLHead ,'AbraDocument.Rows.Row['+inttostr(i)+'].TAmount') and (index=4)) then
                                                                    mRow.SetFieldValueAsfloat('TAmount',NxIBStrToFloat('0'+mXMLHead.getElementAsString('AbraDocument.Rows.Row['+inttostr(i)+'].TAmount')));

                                                                       //  NxShowSimpleMessage(NxFloatToIBStr(mRow.getFieldValueAsfloat('TAmount')),nil) ;

                                                                    if not(ErrtElementString(mXMLHead ,'AbraDocument.Rows.Row['+inttostr(i)+'].TAmountWithoutVAT') and (index=4)) then
                                                                    mRow.SetFieldValueAsfloat('TAmountWithoutVAT',NxIBStrToFloat('0'+mXMLHead.getElementAsString('AbraDocument.Rows.Row['+inttostr(i)+'].TAmountWithoutVAT')));
                                                                    // NxShowSimpleMessage(NxFloatToIBStr(mRow.getFieldValueAsfloat('TAmount')) + ' - ' + NxFloatToIBStr(mRow.getFieldValueAsfloat('TAmountWithoutVAT')),nil) ;
                                                                      }

                                                              end else begin
                                                                   if not(ErrtElementString(mXMLHead ,'AbraDocument.Rows.Row['+inttostr(i)+'].UnitPrice') and (index=4)) then
                                                                    mRow.SetFieldValueAsFloat('Unitprice',NxIBStrToFloat(mXMLHead.getElementAsString('AbraDocument.Rows.Row['+inttostr(i)+'].TAmountWithoutVAT'))/(mRow.getFieldValueAsFloat('Quantity')/(mRow.getFieldValueAsFloat('unitrate')) ) );



                                                                     if not(ErrtElementString(mXMLHead ,'AbraDocument.Rows.Row['+inttostr(i)+'].TotalPrice') and (index=4)) then
                                                                    mRow.SetFieldValueAsFloat('Totalprice',NxIBStrToFloat(mXMLHead.getElementAsString('AbraDocument.Rows.Row['+inttostr(i)+'].TAmountWithoutVAT')));

                                                                   {  if not(ErrtElementString(mXMLHead ,'AbraDocument.Rows.Row['+inttostr(i)+'].localtamount') and (index=4)) then
                                                                    mRow.SetFieldValueAsFloat('localTamount',NxIBStrToFloat('0'+mXMLHead.getElementAsString('AbraDocument.Rows.Row['+inttostr(i)+'].localtamount'))); //text bude  ...

                                                                    if not(ErrtElementString(mXMLHead ,'AbraDocument.Rows.Row['+inttostr(i)+'].LocalTAmountWithoutVAT') and (index=4)) then
                                                                    mRow.SetFieldValueAsFloat('LocalTAmountWithoutVAT',NxIBStrToFloat('0'+mXMLHead.getElementAsString('AbraDocument.Rows.Row['+inttostr(i)+'].LocalTAmountWithoutVAT')));

                                                                    if not(ErrtElementString(mXMLHead ,'AbraDocument.Rows.Row['+inttostr(i)+'].TAmount') and (index=4)) then
                                                                    mRow.SetFieldValueAsfloat('TAmount',NxIBStrToFloat('0'+mXMLHead.getElementAsString('AbraDocument.Rows.Row['+inttostr(i)+'].TAmount')));


                                                                     if not(ErrtElementString(mXMLHead ,'AbraDocument.Rows.Row['+inttostr(i)+'].TAmountWithoutVAT') and (index=4)) then
                                                                    mRow.SetFieldValueAsfloat('TAmountWithoutVAT',NxIBStrToFloat('0'+mXMLHead.getElementAsString('AbraDocument.Rows.Row['+inttostr(i)+'].TAmountWithoutVAT')));
                                                                  //   NxShowSimpleMessage(NxFloatToIBStr(mRow.getFieldValueAsfloat('TAmount')) + ' - ' + NxFloatToIBStr(mRow.getFieldValueAsfloat('TAmountWithoutVAT')),nil) ;
                                                          } end;
                                                                 {  if not(ErrtElementString(mXMLHead ,'AbraDocument.Rows.Row['+inttostr(i)+'].localtamount') and (index=4)) then
                                                                    mRow.SetFieldValueAsFloat('localTamount',NxIBStrToFloat('0'+mXMLHead.getElementAsString('AbraDocument.Rows.Row['+inttostr(i)+'].localtamount'))); //text bude  ...

                                                                    if not(ErrtElementString(mXMLHead ,'AbraDocument.Rows.Row['+inttostr(i)+'].LocalTAmountWithoutVAT') and (index=4)) then
                                                                    mRow.SetFieldValueAsFloat('LocalTAmountWithoutVAT',NxIBStrToFloat('0'+ mXMLHead.getElementAsString('AbraDocument.Rows.Row['+inttostr(i)+'].LocalTAmountWithoutVAT')));

                                                                    if not(ErrtElementString(mXMLHead ,'AbraDocument.Rows.Row['+inttostr(i)+'].TAmount') and (index=4)) then
                                                                    mRow.SetFieldValueAsfloat('TAmount',NxIBStrToFloat('0'+mXMLHead.getElementAsString('AbraDocument.Rows.Row['+inttostr(i)+'].TAmount')));


                                                                    if not(ErrtElementString(mXMLHead ,'AbraDocument.Rows.Row['+inttostr(i)+'].TAmountWithoutVAT') and (index=4)) then
                                                                    mRow.SetFieldValueAsfloat('TAmountWithoutVAT',NxIBStrToFloat('0'+mXMLHead.getElementAsString('AbraDocument.Rows.Row['+inttostr(i)+'].TAmountWithoutVAT')));

                                                 }   end;

                              //mRow.SetFieldValueAsstring('QUnit',mXMLHead.getElementAsString('AbraDocument.Rows.Row['+inttostr(i)+'].Qunit'));

                                                     //     mRow.SetFieldValueAsboolean('ToESL',mtoESL);
                                                          //mrow.prefill;
                                                      //    if ((mUser_ID='SUPER00000') and (rucne)) then NxShowSimpleMessage(inttostr(i) + '- 009',nil);
                                                          if mTyp_obchodu='B2B' then begin
                                                              if not(ErrtElementString(mXMLHead ,'AbraDocument.Rows.Row['+inttostr(i)+'].Specification.Jmeno') and (index=4)) then begin
                                                                      if not NxIsBlank(mXMLHead.getElementAsstring('AbraDocument.Rows.Row['+inttostr(i)+'].Specification.Jmeno')) then begin
                                                                            if not(ErrtElementString(mXMLHead ,'AbraDocument.Rows.Row['+inttostr(i)+'].Specification.Jmeno') and (index=4)) then
                                                                            if not NxIsBlank(mXMLHead.getElementAsstring('AbraDocument.Rows.Row['+inttostr(i)+'].Specification.Jmeno')) then  mRow.SetFieldValueAsString('U_Jmenopacienta',mXMLHead.getElementAsstring('AbraDocument.Rows.Row['+inttostr(i)+'].Specification.Jmeno'));
                                                                            if not(ErrtElementString(mXMLHead ,'AbraDocument.Rows.Row['+inttostr(i)+'].Specification.Telefon') and (index=4)) then
                                                                            if not NxIsBlank(mXMLHead.getElementAsstring('AbraDocument.Rows.Row['+inttostr(i)+'].Specification.Telefon')) then  mRow.SetFieldValueAsString('Telefon',mXMLHead.getElementAsstring('AbraDocument.Rows.Row['+inttostr(i)+'].Specification.Telefon'));
                                                                            if not(ErrtElementString(mXMLHead ,'AbraDocument.Rows.Row['+inttostr(i)+'].Specification.Vyska') and (index=4)) then
                                                                            if not NxIsBlank(mXMLHead.getElementAsstring('AbraDocument.Rows.Row['+inttostr(i)+'].Specification.Vyska')) then  mRow.SetFieldValueAsFloat('U_Vyska',NxIBStrToFloat(mXMLHead.getElementAsstring('AbraDocument.Rows.Row['+inttostr(i)+'].Specification.Vyska')));
                                                                            if not(ErrtElementString(mXMLHead ,'AbraDocument.Rows.Row['+inttostr(i)+'].Specification.TG') and (index=4)) then
                                                                            if not NxIsBlank(mXMLHead.getElementAsstring('AbraDocument.Rows.Row['+inttostr(i)+'].Specification.TG')) then  mRow.SetFieldValueAsFloat('U_TG',NxIBStrToFloat(mXMLHead.getElementAsstring('AbraDocument.Rows.Row['+inttostr(i)+'].Specification.TG')));
                                                                            if not(ErrtElementString(mXMLHead ,'AbraDocument.Rows.Row['+inttostr(i)+'].Specification.TF') and (index=4)) then
                                                                            if not NxIsBlank(mXMLHead.getElementAsstring('AbraDocument.Rows.Row['+inttostr(i)+'].Specification.TF')) then  mRow.SetFieldValueAsFloat('U_TF',NxIBStrToFloat(mXMLHead.getElementAsstring('AbraDocument.Rows.Row['+inttostr(i)+'].Specification.TF')));
                                                                            if not(ErrtElementString(mXMLHead ,'AbraDocument.Rows.Row['+inttostr(i)+'].Specification.TD') and (index=4)) then
                                                                            if not NxIsBlank(mXMLHead.getElementAsstring('AbraDocument.Rows.Row['+inttostr(i)+'].Specification.TD')) then  mRow.SetFieldValueAsFloat('U_TD',NxIBStrToFloat(mXMLHead.getElementAsstring('AbraDocument.Rows.Row['+inttostr(i)+'].Specification.TD')));
                                                                            if not(ErrtElementString(mXMLHead ,'AbraDocument.Rows.Row['+inttostr(i)+'].Specification.TB') and (index=4)) then
                                                                            if not NxIsBlank(mXMLHead.getElementAsstring('AbraDocument.Rows.Row['+inttostr(i)+'].Specification.TB')) then  mRow.SetFieldValueAsFloat('U_TB',NxIBStrToFloat(mXMLHead.getElementAsstring('AbraDocument.Rows.Row['+inttostr(i)+'].Specification.TB')));
                                                                            if not(ErrtElementString(mXMLHead ,'AbraDocument.Rows.Row['+inttostr(i)+'].Specification.VG') and (index=4)) then
                                                                            if not NxIsBlank(mXMLHead.getElementAsstring('AbraDocument.Rows.Row['+inttostr(i)+'].Specification.VG')) then  mRow.SetFieldValueAsFloat('U_VG',NxIBStrToFloat(mXMLHead.getElementAsstring('AbraDocument.Rows.Row['+inttostr(i)+'].Specification.VG')));
                                                                            if not(ErrtElementString(mXMLHead ,'AbraDocument.Rows.Row['+inttostr(i)+'].Specification.VD') and (index=4)) then
                                                                            if not NxIsBlank(mXMLHead.getElementAsstring('AbraDocument.Rows.Row['+inttostr(i)+'].Specification.VD')) then  mRow.SetFieldValueAsFloat('U_VD',NxIBStrToFloat(mXMLHead.getElementAsstring('AbraDocument.Rows.Row['+inttostr(i)+'].Specification.VD')));
                                                                            if not(ErrtElementString(mXMLHead ,'AbraDocument.Rows.Row['+inttostr(i)+'].Specification.VB') and (index=4)) then
                                                                            if not NxIsBlank(mXMLHead.getElementAsstring('AbraDocument.Rows.Row['+inttostr(i)+'].Specification.VB')) then  mRow.SetFieldValueAsFloat('U_VB',NxIBStrToFloat(mXMLHead.getElementAsstring('AbraDocument.Rows.Row['+inttostr(i)+'].Specification.VB')));
                                                                            if not(ErrtElementString(mXMLHead ,'AbraDocument.Rows.Row['+inttostr(i)+'].Specification.Oblicej') and (index=4)) then
                                                                            if not NxIsBlank(mXMLHead.getElementAsstring('AbraDocument.Rows.Row['+inttostr(i)+'].Specification.Oblicej')) then  mRow.SetFieldValueAsFloat('U_Oblicej',NxIBStrToFloat(mXMLHead.getElementAsstring('AbraDocument.Rows.Row['+inttostr(i)+'].Specification.Oblicej')));
                                                                            if not(ErrtElementString(mXMLHead ,'AbraDocument.Rows.Row['+inttostr(i)+'].Specification.Hlava') and (index=4)) then
                                                                            if not NxIsBlank(mXMLHead.getElementAsstring('AbraDocument.Rows.Row['+inttostr(i)+'].Specification.Hlava')) then  mRow.SetFieldValueAsFloat('U_Hlava',NxIBStrToFloat(mXMLHead.getElementAsstring('AbraDocument.Rows.Row['+inttostr(i)+'].Specification.Hlava')));
                                                                            if not(ErrtElementString(mXMLHead ,'AbraDocument.Rows.Row['+inttostr(i)+'].Specification.Krk') and (index=4)) then
                                                                            if not NxIsBlank(mXMLHead.getElementAsstring('AbraDocument.Rows.Row['+inttostr(i)+'].Specification.Krk')) then  mRow.SetFieldValueAsFloat('U_Krk',NxIBStrToFloat(mXMLHead.getElementAsstring('AbraDocument.Rows.Row['+inttostr(i)+'].Specification.Krk')));
                                                                            if not(ErrtElementString(mXMLHead ,'AbraDocument.Rows.Row['+inttostr(i)+'].Specification.Pres_prsa') and (index=4)) then
                                                                            if not NxIsBlank(mXMLHead.getElementAsstring('AbraDocument.Rows.Row['+inttostr(i)+'].Specification.Pres_prsa')) then  mRow.SetFieldValueAsFloat('U_Pres_prsa',NxIBStrToFloat(mXMLHead.getElementAsstring('AbraDocument.Rows.Row['+inttostr(i)+'].Specification.Pres_prsa')));
                                                                            if not(ErrtElementString(mXMLHead ,'AbraDocument.Rows.Row['+inttostr(i)+'].Specification.Pod_prsy') and (index=4)) then
                                                                            if not NxIsBlank(mXMLHead.getElementAsstring('AbraDocument.Rows.Row['+inttostr(i)+'].Specification.Pod_prsy')) then  mRow.SetFieldValueAsFloat('U_Pod_prsy',NxIBStrToFloat(mXMLHead.getElementAsstring('AbraDocument.Rows.Row['+inttostr(i)+'].Specification.Pod_prsy')));
                                                                            if not(ErrtElementString(mXMLHead ,'AbraDocument.Rows.Row['+inttostr(i)+'].Specification.Pas') and (index=4)) then
                                                                            if not NxIsBlank(mXMLHead.getElementAsstring('AbraDocument.Rows.Row['+inttostr(i)+'].Specification.Pas')) then  mRow.SetFieldValueAsFloat('U_Pas',NxIBStrToFloat(mXMLHead.getElementAsstring('AbraDocument.Rows.Row['+inttostr(i)+'].Specification.Pas')));
                                                                            if not(ErrtElementString(mXMLHead ,'AbraDocument.Rows.Row['+inttostr(i)+'].Specification.Stehna') and (index=4)) then
                                                                            if not NxIsBlank(mXMLHead.getElementAsstring('AbraDocument.Rows.Row['+inttostr(i)+'].Specification.Stehna')) then  mRow.SetFieldValueAsFloat('U_Stehna',NxIBStrToFloat(mXMLHead.getElementAsstring('AbraDocument.Rows.Row['+inttostr(i)+'].Specification.Stehna')));
                                                                            if not(ErrtElementString(mXMLHead ,'AbraDocument.Rows.Row['+inttostr(i)+'].Specification.Boky') and (index=4)) then
                                                                            if not NxIsBlank(mXMLHead.getElementAsstring('AbraDocument.Rows.Row['+inttostr(i)+'].Specification.Boky')) then  mRow.SetFieldValueAsFloat('U_Boky',NxIBStrToFloat(mXMLHead.getElementAsstring('AbraDocument.Rows.Row['+inttostr(i)+'].Specification.Boky')));
                                                                            if not(ErrtElementString(mXMLHead ,'AbraDocument.Rows.Row['+inttostr(i)+'].Specification.Stehno_horni') and (index=4)) then
                                                                            if not NxIsBlank(mXMLHead.getElementAsstring('AbraDocument.Rows.Row['+inttostr(i)+'].Specification.Stehno_horni')) then  mRow.SetFieldValueAsFloat('U_Stehno_horni',NxIBStrToFloat(mXMLHead.getElementAsstring('AbraDocument.Rows.Row['+inttostr(i)+'].Specification.Stehno_horni')));
                                                                            if not(ErrtElementString(mXMLHead ,'AbraDocument.Rows.Row['+inttostr(i)+'].Specification.Stehna_stredni') and (index=4)) then
                                                                            if not NxIsBlank(mXMLHead.getElementAsstring('AbraDocument.Rows.Row['+inttostr(i)+'].Specification.Stehna_stredni')) then  mRow.SetFieldValueAsFloat('U_Stehna_stredni',NxIBStrToFloat(mXMLHead.getElementAsstring('AbraDocument.Rows.Row['+inttostr(i)+'].Specification.Stehna_stredni')));
                                                                            if not(ErrtElementString(mXMLHead ,'AbraDocument.Rows.Row['+inttostr(i)+'].Specification.Nad_kolenem') and (index=4)) then
                                                                            if not NxIsBlank(mXMLHead.getElementAsstring('AbraDocument.Rows.Row['+inttostr(i)+'].Specification.Nad_kolenem')) then  mRow.SetFieldValueAsFloat('U_Nad_kolenem',NxIBStrToFloat(mXMLHead.getElementAsstring('AbraDocument.Rows.Row['+inttostr(i)+'].Specification.Nad_kolenem')));
                                                                            if not(ErrtElementString(mXMLHead ,'AbraDocument.Rows.Row['+inttostr(i)+'].Specification.Pod_kolenem') and (index=4)) then
                                                                            if not NxIsBlank(mXMLHead.getElementAsstring('AbraDocument.Rows.Row['+inttostr(i)+'].Specification.Pod_kolenem')) then  mRow.SetFieldValueAsFloat('U_Pod_kolenem',NxIBStrToFloat(mXMLHead.getElementAsstring('AbraDocument.Rows.Row['+inttostr(i)+'].Specification.Pod_kolenem')));
                                                                            if not(ErrtElementString(mXMLHead ,'AbraDocument.Rows.Row['+inttostr(i)+'].Specification.Lytko') and (index=4)) then
                                                                            if not NxIsBlank(mXMLHead.getElementAsstring('AbraDocument.Rows.Row['+inttostr(i)+'].Specification.Lytko')) then  mRow.SetFieldValueAsFloat('U_Lytko',NxIBStrToFloat(mXMLHead.getElementAsstring('AbraDocument.Rows.Row['+inttostr(i)+'].Specification.Lytko')));
                                                                            if not(ErrtElementString(mXMLHead ,'AbraDocument.Rows.Row['+inttostr(i)+'].Specification.Nad_kotnikem') and (index=4)) then
                                                                            if not NxIsBlank(mXMLHead.getElementAsstring('AbraDocument.Rows.Row['+inttostr(i)+'].Specification.Nad_kotnikem')) then  mRow.SetFieldValueAsFloat('U_Nad_kotnikem',NxIBStrToFloat(mXMLHead.getElementAsstring('AbraDocument.Rows.Row['+inttostr(i)+'].Specification.Nad_kotnikem')));
                                                                            if not(ErrtElementString(mXMLHead ,'AbraDocument.Rows.Row['+inttostr(i)+'].Specification.Brada_temeno') and (index=4)) then
                                                                            if not NxIsBlank(mXMLHead.getElementAsstring('AbraDocument.Rows.Row['+inttostr(i)+'].Specification.Brada_temeno')) then  mRow.SetFieldValueAsFloat('U_Brada_temeno',NxIBStrToFloat(mXMLHead.getElementAsstring('AbraDocument.Rows.Row['+inttostr(i)+'].Specification.Brada_temeno')));
                                                                            if not(ErrtElementString(mXMLHead ,'AbraDocument.Rows.Row['+inttostr(i)+'].Specification.Rukav') and (index=4)) then
                                                                            if not NxIsBlank(mXMLHead.getElementAsstring('AbraDocument.Rows.Row['+inttostr(i)+'].Specification.Rukav')) then  mRow.SetFieldValueAsFloat('U_Rukav',NxIBStrToFloat(mXMLHead.getElementAsstring('AbraDocument.Rows.Row['+inttostr(i)+'].Specification.Rukav')));
                                                                            if not(ErrtElementString(mXMLHead ,'AbraDocument.Rows.Row['+inttostr(i)+'].Specification.Nad_loktem1') and (index=4)) then
                                                                            if not NxIsBlank(mXMLHead.getElementAsstring('AbraDocument.Rows.Row['+inttostr(i)+'].Specification.Nad_loktem1')) then  mRow.SetFieldValueAsFloat('U_Nad_loktem1',NxIBStrToFloat(mXMLHead.getElementAsstring('AbraDocument.Rows.Row['+inttostr(i)+'].Specification.Nad_loktem1')));
                                                                            if not(ErrtElementString(mXMLHead ,'AbraDocument.Rows.Row['+inttostr(i)+'].Specification.Nad_loktem2') and (index=4)) then
                                                                            if not NxIsBlank(mXMLHead.getElementAsstring('AbraDocument.Rows.Row['+inttostr(i)+'].Specification.Nad_loktem2')) then  mRow.SetFieldValueAsFloat('U_Nad_loktem2',NxIBStrToFloat(mXMLHead.getElementAsstring('AbraDocument.Rows.Row['+inttostr(i)+'].Specification.Nad_loktem2')));
                                                                            if not(ErrtElementString(mXMLHead ,'AbraDocument.Rows.Row['+inttostr(i)+'].Specification.Nad_loktem3') and (index=4)) then
                                                                            if not NxIsBlank(mXMLHead.getElementAsstring('AbraDocument.Rows.Row['+inttostr(i)+'].Specification.Nad_loktem3')) then  mRow.SetFieldValueAsFloat('U_Nad_loktem3',NxIBStrToFloat(mXMLHead.getElementAsstring('AbraDocument.Rows.Row['+inttostr(i)+'].Specification.Nad_loktem3')));
                                                                            if not(ErrtElementString(mXMLHead ,'AbraDocument.Rows.Row['+inttostr(i)+'].Specification.barva') and (index=4)) then
                                                                            if not NxIsBlank(mXMLHead.getElementAsstring('AbraDocument.Rows.Row['+inttostr(i)+'].Specification.barva')) then mrow.setFieldValueAsstring('U_barva',mXMLHead.getElementAsstring('AbraDocument.Rows.Row['+inttostr(i)+'].Specification.barva'));
                                                                       end;
                                                               end;
                                                            //   if ((mUser_ID='SUPER00000') and (rucne)) then if mUser_ID='SUPER00000' then NxShowSimpleMessage(inttostr(i) + '- 010',nil);
                                                          end;
                                              end;
                              //mRow.SetFieldValueAsstring('QUnit',mXMLHead.getElementAsString('AbraDocument.Rows.Row['+inttostr(i)+'].Qunit'));

                              // --- Dopsání jména zákazníka z TAGu ExternalSpecification ---
                               if isTagExist(mXMLHead ,'AbraDocument.Rows.Row['+inttostr(i)+'].ExternalSpecification') then begin
                                  mPacName:=mXMLHead.getElementAsString('AbraDocument.Rows.Row['+inttostr(i)+'].ExternalSpecification');
                                  if mPacName<>'' then
                                     mRow.SetFieldValueAsstring('X_ExternalSpecification',mPacName);
                                end ;



                if NxIsEmptyOID(mRow.GetFieldValueAsString('BusTransaction_id')) then begin
                        if not NxIsEmptyOID((mRow.GetFieldValueAsString('StoreCard_id.X_BusTransaction_ID'))) then begin
                                     mBustransaction_ID:=(mRow.GetFieldValueAsString('StoreCard_id.X_BusTransaction_ID'));
                                     mRow.SetFieldValueAsString('BusTransaction_id',mBustransaction_ID );
                        end;
                end;

                if NxIsEmptyOID(mRow.GetFieldValueAsString('BusOrder_id')) then begin
                          mBusOrder_ID:=GetBusOrder_ID(mRow);
                          if not nxisblank(mBusOrder_ID) then mRow.SetFieldValueAsString('BusOrder_id',mBusOrder_ID);
                end;

                if NxIsEmptyOID(mRow.GetFieldValueAsString('BusProject_id')) then begin
                    mBusProject_ID:=GetProject_ID(mRow);
                    if not nxisblank(mBusProject_ID) then mRow.SetFieldValueAsString('BusProject_id',mBusProject_ID);
                end;








                              end;    // cyklus řádků

                              // ************ vyjímky  ******************

                              //if (mID_Docqueue='1710000101') or (mID_Docqueue='2U20000101') or (mID_Docqueue='1020000101') then begin
                              //    mHead.SetFieldValueAsInteger('VATRounding',(-33554175)) ;
                              //    mHead.SetFieldValueAsInteger('TotalRounding',(-33554175))

                              //end;

                              //if mXMLHead.getElementAsString('AbraDocument.Rows.Row[0].AcceptPrices')='1' then begin
                              if (mTyp_obchodu='B2B') then mHEAD.SetFieldValueAsString('FIRM_ID','1WD1000101');
                                if mShowError then  NxShowSimpleMessage('Ukládání',nil);
                                  if mHEAD.GetFieldValueAsString('DocQueue_ID.Code')<>'OPT' then begin
                                    if (trim(mHEAD.GetFieldValueAsString('PaymentType_ID.Code'))<>'U4') and (Trim(mHEAD.GetFieldValueAsString('PaymentType_ID.Code'))<>'M') then begin
                                        if not NxIsEmptyOID(mHEAD.GetFieldValueAsString('FIRM_ID.X_BankAcount')) then begin
                                              mHEAD.SetFieldValueAsString('BankAccount_ID',mHEAD.GetFieldValueAsString('FIRM_ID.X_BankAcount')) ;
                                        end;
                                    end;
                                  end;


                              if ((mRow.GetFieldValueAsString('BusOrder_id') ='3G90000101') or (mRow.GetFieldValueAsString('BusOrder_id')='2700000101')) and ( mhead.getFieldValueAsinteger('TradeType')=7) then begin

                                 mWeight:=0;

                                  mMon:= mHEAD.GetLoadedCollectionMonikerForFieldCode(mHEAD.GetFieldCode('ROWS'));
                                                        for xx := 0 to mMon.Count - 1 do begin
                                                                     mr:=TStringList.create;
                                                                     try
                                                                           msite.BaseObjectSpace.SQLSelect('SELECT (SU.Weight* CASE WHEN (SU.WeightUnit=0) THEN 0.001 WHEN (SU.WeightUnit=2) THEN 1000 ELSE 1 END )' +
                                                                            ' From storecards SC join StoreUnits SU on SU.Parent_ID=SC.id AND SU.Code='+ quotedstr(mMon.BusinessObject[xx].GetFieldValueAsString('Qunit'))+
                                                                            ' where (sc.id IS NOT NULL) AND SU.Parent_ID=sc.id AND SU.Code=' + quotedstr(mMon.BusinessObject[i].GetFieldValueAsString('Qunit'))+
                                                                              ' and SC.id =' + quotedstr(mMon.BusinessObject[xx].GetFieldValueAsString('Storecard_ID')),mr);
                                                                          if mr.count>0 then  mWeight:=mWeight + NxRoundByValue(NxIBStrToFloat(mr.Strings[0]), 2, 0.5);

                                                                     finally
                                                                         mr.free;
                                                                     end;
                                                        end;
                                                        if mHEAD.getFieldValueAsFloat('U_weight')=0 then begin
                                                              mHEAD.SetFieldValueAsFloat('U_weight',mWeight);
                                                        end;
                                                         mHEAD.SetFieldValueAsstring('U_DodPod_Mesto', mHEAD.GetFieldValueAsString('FirmOffice_ID.Address_ID.City'));


                             end;


                              //end;
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

                                        // voucher uplatnění
                                          if not(ErrtElementString(mXMLHead ,'AbraDocument.Used_Vouchers')) then begin
                                          //if isTagExist(mXMLHead ,'AbraDocument.Used_Vouchers') then begin
                                              mZalPrice:=0;
                                              for xx := 0 to mXMLHead.getElementsCountInArray('AbraDocument.Used_Vouchers.Used_Voucher') - 1 do begin
                                                    if isTagExist(mXMLHead ,'AbraDocument.Used_Vouchers.Used_Voucher['+inttostr(xx)+'].SN') then begin
                                                         if Trim(mXMLHead.getElementAsString('AbraDocument.Used_Vouchers.Used_Voucher['+inttostr(XX)+'].SN'))<>'' then begin
                                                            mHead.setFieldValueAsString('X_Voucher',mHead.getFieldValueAsString('X_Voucher') + mXMLHead.getElementAsString('AbraDocument.Used_Vouchers.Used_Voucher['+inttostr(XX)+'].SN'));
                                                              mr:=tstringlist.create;
                                                             try


                                                                  os.SQLSelect('Select ID from IssuedDInvoices where ((X_Voucher=' + QuotedStr(mXMLHead.getElementAsString('AbraDocument.Used_Vouchers.Used_Voucher['+inttostr(XX)+'].SN')) + ') and (X_Voucher <>' + QuotedStr('') + '))'
                                                                               + ' and (docqueue_ID=' + quotedstr('47D2000101')  + ')'
                                                                               ,mr);

                                                                       if isTagExist(mXMLHead ,'AbraDocument.Used_Vouchers.Used_Voucher['+inttostr(xx)+'].used_price') then begin
                                                                                 if mr.count>0 then begin
                                                                                         mBO_Zaloha:=msite.BaseObjectSpace.CreateObject('WEN033MLM3DL35J301C0CX3F40');
                                                                                            try
                                                                                                mBO_Zaloha.Load(mr.Strings[0],nil);
                                                                                                     mMonZaloha:=mBO_Zaloha.GetLoadedCollectionMonikerForFieldCode(mBO_Zaloha.GetFieldCode('Rows'));
                                                                                                         for a:=0 to mMonZaloha.count-1 do begin
                                                                                                                if mMonZaloha.BusinessObject[a].GetFieldValueAsInteger('RowType')=4 then begin
                                                                                                                       mMonZaloha.BusinessObject[a].setFieldValueAsFloat('TAmount',mXMLHead.getElementAsFloat('AbraDocument.Used_Vouchers.Used_Voucher['+inttostr(XX)+'].used_price'));
                                                                                                                       mZalPrice:=mZalPrice+ mMonZaloha.BusinessObject[a].getFieldValueAsFloat('TAmount');
                                                                                                                end;
                                                                                                         end;
                                                                                                //mBO_Zaloha.SetFieldValueAsString('ReceivedOrder_ID', mhead.oid);
                                                                                                mBO_Zaloha.save;
                                                                                                NxShowSimpleMessage('Pro objednávku ' + mHead.displayname
                                                                                                                    + ' byl použit voucher ' + mXMLHead.getElementAsString('AbraDocument.Used_Vouchers.Used_Voucher['+inttostr(XX)+'].SN')
                                                                                                                    + ' v ceně ' + mXMLHead.getElementAsString('AbraDocument.Used_Vouchers.Used_Voucher['+inttostr(XX)+'].used_price')
                                                                                                                    , nil);

                                                                                                        //xxxxxx

                                                                                             finally
                                                                                                  mBO_Zaloha.free;
                                                                                              end;
                                                                                             mi_result:=os.SQLExecute('update IssuedDInvoices set ReceivedOrder_ID=' + QuotedStr(mhead.oid) + ' where id=' + QuotedStr(mr.Strings[0]))

                                                                                 end;
                                                                       end;

                                                             finally
                                                                 mr.free;
                                                             end;
                                                          end;
                                                    end;
                                              if not(ErrtElementString(mXMLHead ,'AbraDocument.Used_Vouchers')) then begin
                                                  if xx<>mXMLHead.getElementsCountInArray('AbraDocument.Used_Vouchers.Used_Voucher') then  mHead.setFieldValueAsString('X_Voucher',mHead.getFieldValueAsString('X_Voucher')+', ');
                                              end;
                                              end;



                                               mr:=tstringlist.create;
                                                             try


                                                                  msite.BaseObjectSpace.sqlselect('Select id from IssuedDInvoices where ReceivedOrder_ID=' + quotedstr(mHead.oid) + ' and DocQueue_ID<>' + quotedstr('47D2000101'),mr);

                                                              if mr.count>0 then begin
                                                                   mBO_Zaloha:=msite.BaseObjectSpace.CreateObject('WEN033MLM3DL35J301C0CX3F40');
                                                                        try
                                                                            mBO_Zaloha.Load(mr.Strings[0],nil);
                                                                            mMonZaloha:=mBO_Zaloha.GetLoadedCollectionMonikerForFieldCode(mBO_Zaloha.GetFieldCode('Rows'));
                                                                            for i:=0 to mMonZaloha.count-1 do begin
                                                                                if mMonZaloha.BusinessObject[i].GetFieldValueAsInteger('Rowtype')=4 then begin
                                                                                        mMonZaloha.BusinessObject[i].setFieldValueAsFloat('TAmount',mMonZaloha.BusinessObject[i].GetFieldValueAsFloat('TAmount')- mZalPrice);
                                                                                end;
                                                                            end;
                                                                            mBO_Zaloha.save;

                                                                        finally
                                                                            mBO_Zaloha.free;
                                                                        end;

                                                              end;
                                                              finally
                                                                  mr.free;
                                                              end;






                                          end;






                                      //NxShowSimpleMessage('Častky s daní si neodpovídají',nil);
                                      if mXMLHead.getElementAsString('AbraDocument.Rows.Row['+inttostr(0)+'].AcceptPrices')='1' then begin
                                          mi_result:=msite.BaseObjectSpace.SQLExecute('update receivedorders set Amount=' + (mXMLHead.getElementAsstring('ABRADocument.Amount')) + ',AmountWithoutVAT=' + mXMLHead.getElementAsstring('ABRADocument.AmountWithoutVAT') +
                                                 //',LocalAmount=' + mXMLHead.getElementAsstring('ABRADocument.LocalTAmount') + ',LocalAmountWithoutVAT='+mXMLHead.getElementAsstring('ABRADocument.LocalTAmountWithoutVAT')  +
                                                   ' where id=' + quotedstr(mhead.oid)
                                          )   ;

                                                for i := 0 to mXMLHead.getElementsCountInArray('AbraDocument.Rows.Row') - 1 do begin
                                                     // if mMon.BusinessObject[i].GetFieldValueAsInteger('Posindex') = StrToInt(mXMLHead.getElementAsString('AbraDocument.Rows.Row['+inttostr(i)+'].posindex')) then begin


                                                            if mXMLHead.getElementAsString('AbraDocument.Rows.Row['+inttostr(i)+'].AcceptPrices')='1' then begin
                                                                    mi_result:=OS.SQLExecute('update ReceivedOrders2 set tamount=' + mXMLHead.getElementAsString('AbraDocument.Rows.Row['+inttostr(i)+'].TAmount') +
                                                                                                                   ',tamountwithoutvat=' + mXMLHead.getElementAsString('AbraDocument.Rows.Row['+inttostr(i)+'].tamountwithoutvat') +
                                                                                                                 //  ',localtamountwithoutvat=' + mXMLHead.getElementAsString('AbraDocument.Rows.Row['+inttostr(i)+'].localtamountwithoutvat') +
                                                                                                                 //  ',localtamount=' + mXMLHead.getElementAsString('AbraDocument.Rows.Row['+inttostr(i)+'].localtamount') +


                                                                    ' where parent_id=' + quotedstr(mhead.oid) +
                                                                     ' and posindex='  +  IntToStr(i) );
                                                             end;
                                                     // end;
                                                end;

                                      end;



                                        //mhead.Save;
                                        if (rucne) and (index<>1) then NxShowSimpleMessage('Objednávka ' + mhead.GetFieldValueAsstring('Docqueue_ID.code') + '-' + inttostr(mhead.GetFieldValueAsinteger('Ordnumber')) + '/' +
                                                                                mhead.GetFieldValueAsstring('Period_ID.code') + ' byla vytvořena',nil);
                                  end;
                              end else begin
                                      // voucher uplatnění
                                              if isTagExist(mXMLHead ,'AbraDocument.Used_Vouchers') then begin
                                                  for xx := 0 to mXMLHead.getElementsCountInArray('AbraDocument.Used_Vouchers.Used_Voucher') - 1 do begin
                                                        if isTagExist(mXMLHead ,'AbraDocument.Used_Vouchers.Used_Voucher['+inttostr(xx)+'].SN') then begin
                                                             if Trim(mXMLHead.getElementAsString('AbraDocument.Used_Vouchers.Used_Voucher['+inttostr(XX)+'].SN'))<>'' then begin
                                                                mHead.setFieldValueAsString('X_Voucher',mXMLHead.getElementAsString('AbraDocument.Used_Vouchers.Used_Voucher['+inttostr(XX)+'].SN'));
                                                                  mr:=tstringlist.create;
                                                                 try
                                                                      os.SQLSelect('Select ID from IssuedDInvoices where ((X_Voucher=' + QuotedStr(mXMLHead.getElementAsString('AbraDocument.Used_Vouchers.Used_Voucher['+inttostr(XX)+'].SN')) + ') and (X_Voucher <>' + QuotedStr('') + '))'
                                                                                   + ' and (docqueue_ID=' + quotedstr('47D2000101')  + ')'
                                                                                   ,mr);
                                                                           if mr.count>0 then begin
                                                                               mi_result:=os.SQLExecute('update IssuedDInvoices set ReceivedOrder_ID=' + QuotedStr(mhead.oid) + ' where id=' + QuotedStr(mr.Strings[0]))
                                                                           end;
                                                                 finally
                                                                     mr.free;
                                                                 end;
                                                              end;
                                                        end;
                                                  end;
                                              end;





                                      mhead.Save;


                                      if mXMLHead.getElementAsString('AbraDocument.Rows.Row['+inttostr(0)+'].AcceptPrices')='1' then begin
                                      mi_result:=msite.BaseObjectSpace.SQLExecute('update receivedorders set Amount=' + (mXMLHead.getElementAsstring('ABRADocument.Amount')) + ',AmountWithoutVAT=' + mXMLHead.getElementAsstring('ABRADocument.AmountWithoutVAT') +
                                      //',LocalAmount=' + mXMLHead.getElementAsstring('ABRADocument.LocalTAmount') + ',LocalAmountWithoutVAT='+mXMLHead.getElementAsstring('ABRADocument.LocalTAmountWithoutVAT')   +
                                      ' where id=' + quotedstr(mhead.oid)
                                      )   ;

                                          for i := 0 to mXMLHead.getElementsCountInArray('AbraDocument.Rows.Row') - 1 do begin
                                                   if mXMLHead.getElementAsString('AbraDocument.Rows.Row['+inttostr(i)+'].AcceptPrices')='1' then begin
                                                              mi_result:=OS.SQLExecute('update ReceivedOrders2 set tamount=' + mXMLHead.getElementAsString('AbraDocument.Rows.Row['+inttostr(i)+'].TAmount') +
                                                                                                             ',tamountwithoutvat=' + mXMLHead.getElementAsString('AbraDocument.Rows.Row['+inttostr(i)+'].tamountwithoutvat') +
                                                                                                             //',localtamountwithoutvat=' + mXMLHead.getElementAsString('AbraDocument.Rows.Row['+inttostr(i)+'].localtamountwithoutvat') +
                                                                                                             //',localtamount=' + mXMLHead.getElementAsString('AbraDocument.Rows.Row['+inttostr(i)+'].localtamount') +


                                                              ' where parent_id=' + quotedstr(mhead.oid) +
                                                               ' and posindex='  +  IntToStr(i) );

                                                  end;
                                         end;

                                        end;


                                      if (rucne) and (index<>1) then NxShowSimpleMessage('Objednávka ' + mhead.GetFieldValueAsstring('Docqueue_ID.code') + '-' + inttostr(mhead.GetFieldValueAsinteger('Ordnumber')) + '/' +
                                                                                mhead.GetFieldValueAsstring('Period_ID.code') + ' byla vytvořena',nil);
                              end;

                              // voucher uplatnění
                              if isTagExist(mXMLHead ,'AbraDocument.Used_Vouchers') then begin
                                  for xx := 0 to mXMLHead.getElementsCountInArray('AbraDocument.Used_Vouchers.Used_Voucher') - 1 do begin
                                        if isTagExist(mXMLHead ,'AbraDocument.Used_Vouchers.Used_Voucher['+inttostr(xx)+'].SN') then begin
                                             if Trim(mXMLHead.getElementAsString('AbraDocument.Used_Vouchers.Used_Voucher['+inttostr(XX)+'].SN'))<>'' then begin
                                                mHead.setFieldValueAsString('X_Voucher',mXMLHead.getElementAsString('AbraDocument.Used_Vouchers.Used_Voucher['+inttostr(XX)+'].SN'));
                                                  mr:=tstringlist.create;
                                                 try
                                                      os.SQLSelect('Select ID from IssuedDInvoices where ((X_Voucher=' + QuotedStr(mXMLHead.getElementAsString('AbraDocument.Used_Vouchers.Used_Voucher['+inttostr(XX)+'].SN')) + ') and (X_Voucher <>' + QuotedStr('') + '))'
                                                                   + ' and (docqueue_ID=' + quotedstr('47D2000101')  + ')'
                                                                   ,mr);
                                                           if mr.count>0 then begin
                                                               mi_result:=os.SQLExecute('update IssuedDInvoices set ReceivedOrder_ID=' + QuotedStr(mhead.oid) + ' where id=' + QuotedStr(mr.Strings[0]))
                                                           end;
                                                 finally
                                                     mr.free;
                                                 end;
                                              end;
                                        end;
                                  end;
                              end;


                               if (mhead.getFieldValueAsFloat('LocalAmount')=0) AND (mhead.getFieldValueAsFloat('Amount')<>0) then begin
                                                mHead.setFieldValueAsString('Currency_ID','0000CZK000');
                                                mhead.Save;

                                                mHead.SetFieldValueAsString('Currency_ID', mID_Currency);
                                                mhead.Save;

                               end;
                              mboolean:=false;
                              if index=1 then begin
                                   mboolean:=nxcopyfile(AFileName,'\\CZVS0006\Import\Zpracovane\' + FileName);
                                   //NxShowSimpleMessage('Přesun  ' + AFileName + '  - '   + '\\CZVS0006\Import\Zpracovane\' + FileName ,nil);
                              end else begin
                                   mboolean:=nxcopyfile(AFileName,'\\CZVS0006\Import\Zpracovane\' + FileName);
                              end;
                              if mboolean then begin
                                  //NxShowSimpleMessage('mazaání',nil);
                                  DeleteFile(AFileName);
                                  if rucne and mboolean and chyba then begin
                                         NxShowSimpleMessage('Soubor ' + afilename + ' byl přesunut do zpracovaných',nil);
                                  end;
                              end;

                    end else begin
                        if rucne then NxShowSimpleMessage('Doklad již existuje',nil);
                    end;
                 Result := mhead;
            finally

                 mhead.free;
            end;
     finally
      mXMLHead.Free;
     end;


end;
end;



begin
end.