uses
  'eu.abra.PostProviders.extras.TransportationType.Cemat.uConst';
const
  //mozne uzivatelske skripty
  cScriptNone = 0;
  cScriptAfterGetData = 1;
  cScriptAfterProviderChange = 2;
  cScriptAfterGetDataImportManager = 3;//Balíky rychle
  cScriptAfterGetDataImportManagerNonVisual = 4; //import manager například (WMS)
  cScriptGetPrinterNameHook = 5;


//CEMAT -- ZÁLOHA KÓDU KDYBY TO NĚKDO POSLAL DO PEKLA
{GetAddress}

function GetAddress(AReportHelper:TNxQRScriptHelper;AIssuedOrderID:String;FieldName:String):String;
var mBO: TNxCustomBusinessObject;
begin
  Result := '';
  try
    try
      mBO := AReportHelper.ObjectSpace.CreateObject(Class_ReceivedOrder);
      mBO.Load(AIssuedOrderID,nil);
      if UpperCase( FieldName)  = UpperCase( 'U_name') then
        Result :=  Trim(mBO.GetFieldValueAsString('U_name'));
      if UpperCase( FieldName) = UpperCase('U_street') then
        Result :=  Trim(mBO.GetFieldValueAsString('U_street'));
      if UpperCase( FieldName) = UpperCase('U_city_postcode') then
        Result :=  Trim(mBO.GetFieldValueAsString('U_city_postcode'));
      if UpperCase( FieldName) = UpperCase('U_Postcode') then
        Result :=  Trim(mBO.GetFieldValueAsString('U_Postcode'));
      if UpperCase( FieldName) = UpperCase('U_CountryCode') then
        Result :=  Trim(mBO.GetFieldValueAsString('U_CountryCode.Code'));
      if UpperCase( FieldName) = UpperCase('U_contact') then
        Result :=  Trim(mBO.GetFieldValueAsString('U_contact'));
      if UpperCase( FieldName) = UpperCase('U_email_zakazka') then
        Result :=  Trim(mBO.GetFieldValueAsString('U_email_zakazka'));
      if UpperCase( FieldName) = UpperCase('U_phone') then
        Result :=  Trim(mBO.GetFieldValueAsString('U_phone'));


    except
      Result := '';
    end;
  finally
    mBO.Free;
  end;
end;

{GetAddress}

function HaveFullAddress(AReportHelper:TNxQRScriptHelper;AIssuedOrderID:String): Boolean;
var mBO: TNxCustomBusinessObject;
begin
  Result := True;
  try
    try
      mBO := AReportHelper.ObjectSpace.CreateObject(Class_ReceivedOrder);
      mBO.Load(AIssuedOrderID,nil);
      if Trim(mBO.GetFieldValueAsString('U_street')) = '' then
        Result := False;
      if Trim(mBO.GetFieldValueAsString('U_city_postcode')) = '' then
        Result := False;
      if Trim(mBO.GetFieldValueAsString('U_Postcode')) = '' then
        Result := False;

    except
      Result := false;
    end;
  finally
    mBO.Free;
  end;

end;


//CEMAT



//Default - vizuální - "Balíky"
procedure GetDataFromDoc(AOSInt: integer; APackagesDataSetInt: integer; AHeaderDataSetInt: integer; AContentDataSetInt: integer; ARunType : Integer);
begin
  _GetDataFromDoc(AOSInt, APackagesDataSetInt, AHeaderDataSetInt, AContentDataSetInt,ARunType);

end;

//Default - vizuální - "Balík rychle" = import manager
procedure GetDataFromDocIM(AOSInt: integer; APackagesDataSetInt: integer; AHeaderDataSetInt: integer; AContentDataSetInt: integer; ARunType : Integer);
begin
  _GetDataFromDoc(AOSInt, APackagesDataSetInt, AHeaderDataSetInt, AContentDataSetInt,ARunType);

end;

//Default - nevizuální - "WMS" = import manager
procedure GetDataFromDocIM_WMS(AOSInt: integer; APackagesDataSetInt: integer; AHeaderDataSetInt: integer; AContentDataSetInt: integer; ARunType : Integer);
begin
  //Kód stejně jako GetDataFromDoc
  _GetDataFromDoc(AOSInt, APackagesDataSetInt, AHeaderDataSetInt, AContentDataSetInt,ARunType);
end;


//Default příklad - Vlastní získání názvu tiskárny
//cScriptGetPrinterNameHook
function GetPrinterName(AOSInt: integer; ABO_PDMDoc: integer;):String;
begin
  //Kód stejně jako GetDataFromDoc
  Result := _GetPrinterName(AOSInt,ABO_PDMDoc);
end;


//POZOR - Pro správné fungování je třeba naplnit definovatelné položky.
//ARunType: 1 = Po načtení dat; 2 = Import manager; 4 = Nevizuální import manager (WMS)
procedure _GetDataFromDoc(AOSInt: integer; APackagesDataSetInt: integer; AHeaderDataSetInt: integer; AContentDataSetInt: integer; ARunType : Integer);
const
  cSQLProvider = 'select a.ID from PDMPostProviders a where a.X_PD_IsLicensed = %s and a.X_PD_Driver = %s and upper(a.Code) = %s';
  cSQLContentType = 'select b.ID from PDMPostProviders2 a join PDMIssuedContentTypes b on b.ID = a.IssuedContentType_ID where a.parent_ID = %s and upper(b.Code) = %s';
  cSQLBranches = 'select a.ID from PDMServiceTypes a where a.X_PD_PostProvider_ID = %s and a.hidden = ''N'' and a.x_pd_externid = %s and a.x_pd_externid <> '''' ';
  cSQLUserStoreID = 'select a.X_Store_ID from SecurityUsers a where a.id = ''%s'' ';

  cSQLSel_IIby21 = 'select distinct II.id '+
              'from ISSUEDINVOICES2 II2 '+
              'join STOREDOCUMENTS2 SD2 on SD2.ID = II2.PROVIDEROW_ID '+
              'join ISSUEDINVOICES II on II.ID = II2.PARENT_ID '+
              'where SD2.parent_id = ''%s''';

   cDivisionID = '1000000101';
  cDocQueueID = '8M20000101';
  cStoreID = '2000000101';
  cMU_EUpal = 'VII0000101';
  cMU_DSV_EUpal = 'IYKB000101';
  cCountMUUnitField = 3;//WMS
var
  mOS: TNxCustomObjectSpace;
  mPackagesDataSet, mHeaderDataSet, mContentDataSet: TDataSet;
  mSQL, mIssuedContent_ID, mServiceType_ID, mDoc_ID, mPostProvider_ID, mDocType: string;
  mDocBO : TNxCustomBusinessObject;
  mListII:TStringList;
  mBOII: TNxCustomBusinessObject;
  x,y,j, mCountPackage:Integer;
  mStore:String;
  mTime : TDateTime;

begin

  try

    mOS := TNxCustomObjectSpace(IntToObj(AOSInt));

    mPackagesDataSet := TDataSet(IntToObj(APackagesDataSetInt));
    mHeaderDataSet := TDataSet(IntToObj(AHeaderDataSetInt));
    mContentDataSet := TDataSet(IntToObj(AContentDataSetInt));

    mPackagesDataSet.First;
    while not mPackagesDataSet.Eof do
    begin
      mPackagesDataSet.Edit;
      mDoc_ID := '';
      mServiceType_ID := '';
      mIssuedContent_ID := '';
      mDocType := mPackagesDataSet.FieldByName(cFDDocumentType).AsString;
      try
        mPackagesDataSet.Edit;
        mHeaderDataSet.Edit;


        //default pokud to dále nezměním
        //Vždy je první řádek přidán. Další se přidávájí pomocí AddContentRow(TMemoryDataset(mContentDataSet) );
        mContentDataSet.First;
        while not mContentDataSet.eof do
        begin
          mContentDataSet.Edit;
          mContentDataSet.FieldByName(cFDWeight).AsFloat := 0;
          mContentDataSet.FieldByName(cFDWidth).AsFloat := cDefaultPackageWidth;
          mContentDataSet.FieldByName(cFDHeight).AsFloat := 0;
          mContentDataSet.FieldByName(cFDLength).AsFloat := cDefaultPackageLength;
          mContentDataSet.FieldByName(cFDVolume).AsFloat := 0;
          mContentDataSet.Next;
        end;


        if (mDocType = 'RO') or (mDocType = '03') or (mDocType = '21') or (mDocType = '22')
        //or (mDocType = 'SL')
        then
        begin
          case mDocType of
            'RO': mDocBO := mOS.CreateObject(Class_ReceivedOrder);
            '03': mDocBO := mOS.CreateObject(Class_IssuedInvoice);
            '21': mDocBO := mOS.CreateObject(Class_BillOfDelivery);
            '22': mDocBO := mOS.CreateObject(Class_OutgoingTransfer);
            'SL': mDocBO := mOS.CreateObject(Class_ServiceDocument);
          end;

          mDoc_ID := mPackagesDataSet.FieldByName(cFDID).AsString;
          if not NxIsEmptyOID(mDoc_ID) then
          begin
            mDocBO.Load(mDoc_ID,nil);

            //Musí existovat X položky z instalační sady "FLORES, BALÍKOBOT - Položky.ais"
            //Obsah - balíky - jendotky (Začátek)
            //Edituji ten první co jsem prve založil/editoval. Přepisuji na něco správného.
            if ARunType = cScriptAfterGetDataImportManagerNonVisual then
            begin
              if mDocBO.CLSID in [Class_BillOfDelivery, Class_OutgoingTransfer] then
              begin
                if (CFxOID.IsEmptyOrFull(mDocBO.GetFieldValueAsString('X_PD_MU_0_ID')) and ( mDocBO.GetFieldValueAsInteger('X_PD_MUCount_0') > 0 )) then
                begin
                  //Balík
                  mContentDataSet.First;
                  mContentDataSet.Delete;
                  for j := 0 to mDocBO.GetFieldValueAsInteger('X_PD_MUCount_0') -1 do
                  begin
                    AddContentRow(TMemoryDataset(mContentDataSet) );
                    mContentDataSet.FieldByName(cFDWeight).AsFloat := 0;
                    mContentDataSet.FieldByName(cFDWidth).AsFloat := cDefaultPackageWidth;
                    mContentDataSet.FieldByName(cFDHeight).AsFloat := 0;
                    mContentDataSet.FieldByName(cFDLength).AsFloat := cDefaultPackageLength;
                    mContentDataSet.FieldByName(cFDVolume).AsFloat := 0;
                    mContentDataSet.FieldByName(cFDManipulationUnit).AsString := '';
                    mContentDataSet.FieldByName(cFDContent).AsString := '';
                  end;
                end
                else if (not CFxOID.IsEmptyOrFull(mDocBO.GetFieldValueAsString('X_PD_MU_0_ID')) and ( mDocBO.GetFieldValueAsInteger('X_PD_MUCount_0') > 0 )) then
                begin
                  //Palety
                  for x := 0 to cCountMUUnitField -1 do
                  if (not CFxOID.IsEmptyOrFull(mDocBO.GetFieldValueAsString('X_PD_MU_'+IntToStr(x)+'_ID')) and ( mDocBO.GetFieldValueAsInteger('X_PD_MUCount_'+IntToStr(x)) > 0 )) then
                  begin
                    if x = 0 then
                    begin
                      mContentDataSet.First;
                      mContentDataSet.Delete;
                    end;

                    for y:=0 to mDocBO.GetFieldValueAsInteger('X_PD_MUCount_'+IntToStr(x)) -1 do
                    begin
                      AddContentRow(TMemoryDataset(mContentDataSet) );
                      mContentDataSet.FieldByName(cFDWeight).AsFloat := 0;
                      mContentDataSet.FieldByName(cFDWidth).AsFloat := cDefaultPackageWidth;
                      mContentDataSet.FieldByName(cFDHeight).AsFloat := 0;
                      mContentDataSet.FieldByName(cFDLength).AsFloat := cDefaultPackageLength;
                      mContentDataSet.FieldByName(cFDVolume).AsFloat := 0;
                      mContentDataSet.FieldByName(cFDManipulationUnit).AsString := mDocBO.GetFieldValueAsString('X_PD_MU_'+IntToStr(x)+'_ID');
                      mContentDataSet.FieldByName(cFDContent).AsString := '';
                    end;

                  end;


                end;

              end;
            end;
            //Obsah - balíky - jendotky (KONEC)

            //Balíky rychle
            if ARunType = cScriptAfterGetDataImportManager then
            begin
              mCountPackage := Round( ShowInputField(nil, 1,'Počet balíků'));
              if mCountPackage = -1 then
                exit;
              for x:= 0 to  mCountPackage - 1 do
              begin
              if x = 0 then
                begin
                  mContentDataSet.First;
                  mContentDataSet.Delete;
                end;
                AddContentRow(TMemoryDataset(mContentDataSet) );
                mContentDataSet.FieldByName(cFDWeight).AsFloat := ShowInputField(nil, 1,'Hmotnost č. '+ IntToStr(x+1),2);;
                mContentDataSet.FieldByName(cFDWidth).AsFloat := cDefaultPackageWidth;
                mContentDataSet.FieldByName(cFDHeight).AsFloat := 0;
                mContentDataSet.FieldByName(cFDLength).AsFloat := cDefaultPackageLength;
                mContentDataSet.FieldByName(cFDVolume).AsFloat := 0;
                mContentDataSet.FieldByName(cFDContent).AsString := '';
              end;
            end;
            //Balíky rychle (KONEC)


            mPostProvider_ID := '';
            //dopravce podle dokladu
            if CFxOID.IsEmptyOrFull(mPostProvider_ID) then
            begin
              mPostProvider_ID := mDocBO.GetFieldValueAsString('TransportationType_ID.X_Postprovider_ID');//GetFirstRecordFromSQL(mOS, mSQL); //X_PD_BB_Modul
              mHeaderDataSet.First;
              mHeaderDataSet.Edit;
              if not CFxOID.IsEmptyOrFull(mPostProvider_ID) then
                mHeaderDataSet.FieldByName(cFDPDMProvider).AsString := mPostProvider_ID;
              mHeaderDataSet.FieldByName(cFDDocQueue).AsString := cDocQueueID;
              mHeaderDataSet.FieldByName(cFDStore).AsString := cStoreID;
              mHeaderDataSet.FieldByName(cFDDivision).AsString := cDivisionID;
              if not(mDocBO.CLSID in [Class_BillOfDelivery,Class_OutgoingTransfer, Class_ServiceDocument] ) then
                mHeaderDataSet.FieldByName(cFDBankAccount).AsString := mDocBO.GetFieldValueAsString('BankAccount_ID');


              mHeaderDataSet.Post;
              mHeaderDataSet.Edit;
            end;


            //ČEMAT SKLAD A UŽIVATEL
            if mDocBO.CLSID = Class_ReceivedOrder then
            begin
              mStore := GetFirstRecordFromSQL(mOS, 'select first 1 B.Store_ID from receivedOrders A join ReceivedOrders2 B on b.parent_id = a.id where B.RowType = 3 and A.ID = ' +QuotedStr(mDocBO.OID)+ '');
              if not CFxOID.IsEmptyOrFull(mStore) then
              begin
                mHeaderDataSet.FieldByName(cFDStore).AsString := mStore;
              end
              else
              begin
                //z uživatele
                mStore := GetFirstRecordFromSQL(mOS, Format(cSQLUserStoreID,[NxGetActualUserID(mDocBO.ObjectSpace)]) );
                if not CFxOID.IsEmptyOrFull(mStore) then
                  mHeaderDataSet.FieldByName(cFDStore).AsString := mStore;
              end;

            end
            else
            begin
              mHeaderDataSet.FieldByName(cFDStore).AsString := cStoreID;
            end;



            if not CFxOID.IsEmptyOrFull(mPostProvider_ID) then
            begin

              mIssuedContent_ID := mDocBO.GetFieldValueAsString('TransportationType_ID.X_Service_ID');//GetFirstRecordFromSQL(mOS, mSQL); //X_PD_BB_Modul

              //Dohledání provozovny podle předaného ID v položce X_PD_BB_Branches
              if mDocBO.HasField('X_PD_BB_Branches') then
                if ( mDocBO.GetFieldValueAsString('X_PD_BB_Branches') <> '' )  then
                begin
                  mServiceType_ID := '';
                  mSQL := format(cSQLBranches, [QuotedStr(mPostProvider_ID), QuotedStr( UpperCase(mDocBO.GetFieldValueAsString('X_PD_BB_Branches')))  ]);
                  mServiceType_ID := GetFirstRecordFromSQL(mOS, mSQL); //X_PD_BB_Branches
                end;

              if not CFxOID.IsEmptyOrFull(mIssuedContent_ID) then
                mPackagesDataSet.FieldByName(cFDContentType).AsString := mIssuedContent_ID;
              if not CFxOID.IsEmptyOrFull(mServiceType_ID) then
                mPackagesDataSet.FieldByName(cFDPDMServiceType+IntToStr(0)).AsString := mServiceType_ID;

              //if mDocBO.HasField('Weight') then
              //  mPackagesDataSet.FieldByName(cFDWeight+IntToStr(0)).AsFloat := mDocBO.GetFieldValueAsFloat('Weight');
               //Manipulační jednotky
              {if mPostProvider_ID =  then
              begin
                mPackagesDataSet.FieldByName(cFDCountMUnit+IntToStr(0)).AsInteger := 1;
                mPackagesDataSet.FieldByName(cFDManipulationUnit+IntToStr(0)).AsString := cMU_KUS;
              end;}



              if UpperCase( mDocBO.GetFieldValueAsString('TransportationType_ID.X_Postprovider_ID.code')) in ['DSV','GEIS'] then
              begin
                mPackagesDataSet.FieldByName(cFDPickupDate).AsDateTime := Today();
                mPackagesDataSet.FieldByName(cFDDeliveryDate).AsDateTime := IncDay(Today(),1);

                mPackagesDataSet.FieldByName(cFDPickupTimeFrom).AsDateTime :=  EncodeTime(8,0,0,0);
                mPackagesDataSet.FieldByName(cFDPickupTimeTo).AsDateTime := EncodeTime(16,0,0,0);
                mPackagesDataSet.FieldByName(cFDDeliveryTimeFrom).AsDateTime := EncodeTime(0,0,0,0);
                mPackagesDataSet.FieldByName(cFDDeliveryTimeTo).AsDateTime := EncodeTime(23,59,0,0);
                //Vratné obaly
                mPackagesDataSet.FieldByName(cFDManipulationUnitCountBack).AsInteger := 1;
                mPackagesDataSet.FieldByName(cFDMUnitNoteBack).AsString := 'EURO';
              end;



              //Tohle musím nějak předělat.
              if mDocBO.HasField('Weight') then
              begin

                //U Paletové přepravy se zeptám na počet jednotek a pak to rozdělím + 15kg na paleu
                if UpperCase( mDocBO.GetFieldValueAsString('TransportationType_ID.X_Postprovider_ID.code')) in ['DSV','GEIS'] then
                begin
                  mCountPackage := Round( ShowInputField(nil, 1,'Počet Europalet'));
                  if mCountPackage = -1 then
                    exit;
                  for x:= 0 to  mCountPackage - 1 do
                  begin
                    if x = 0 then
                    begin
                      mContentDataSet.First;
                      mContentDataSet.Delete;
                    end;
                    AddContentRow(TMemoryDataset(mContentDataSet) );
                    if mDocBO.GetFieldValueAsFloat('Weight') > 0 then
                      mContentDataSet.FieldByName(cFDWeight).AsFloat := ShowInputField(nil,  ((mDocBO.GetFieldValueAsFloat('Weight') + 15) /mCountPackage) ,'Hmotnost č. '+ IntToStr(x+1),2 );
                    if mDocBO.GetFieldValueAsFloat('Weight') <= 0 then
                      mContentDataSet.FieldByName(cFDWeight).AsFloat := ShowInputField(nil,  0 ,'Hmotnost č. '+ IntToStr(x+1),2 );
                    mContentDataSet.FieldByName(cFDWidth).AsFloat := cDefaultPackageWidth;
                    mContentDataSet.FieldByName(cFDHeight).AsFloat := 0;
                    mContentDataSet.FieldByName(cFDLength).AsFloat := cDefaultPackageLength;
                    mContentDataSet.FieldByName(cFDVolume).AsFloat := 0;
                    mContentDataSet.FieldByName(cFDContent).AsString := '';
                    if UpperCase( mDocBO.GetFieldValueAsString('TransportationType_ID.X_Postprovider_ID.code')) in ['GEIS'] then
                      mContentDataSet.FieldByName(cFDManipulationUnit).AsString := cMU_EUpal;
                    if UpperCase( mDocBO.GetFieldValueAsString('TransportationType_ID.X_Postprovider_ID.code')) in ['DSV'] then
                      mContentDataSet.FieldByName(cFDManipulationUnit).AsString := cMU_DSV_EUpal;
                    mContentDataSet.FieldByName(cFDContent).AsString := 'zboží';
                  end;
                end
                else
                begin

                  mCountPackage := Round( ShowInputField(nil, 1,'Počet Balíků'));
                  if mCountPackage = -1 then
                    exit;
                  for x:= 0 to  mCountPackage - 1 do
                  begin
                    if x = 0 then
                    begin
                      mContentDataSet.First;
                      mContentDataSet.Delete;
                    end;
                    AddContentRow(TMemoryDataset(mContentDataSet) );
                    if mDocBO.GetFieldValueAsFloat('Weight') > 0 then
                      mContentDataSet.FieldByName(cFDWeight).AsFloat := ShowInputField(nil,  ((mDocBO.GetFieldValueAsFloat('Weight') + 0) /mCountPackage) ,'Hmotnost č. '+ IntToStr(x+1),2 );
                    if mDocBO.GetFieldValueAsFloat('Weight') <= 0 then
                      mContentDataSet.FieldByName(cFDWeight).AsFloat := ShowInputField(nil, 0 ,'Hmotnost č. '+ IntToStr(x+1),2 );
                    mContentDataSet.FieldByName(cFDWidth).AsFloat := cDefaultPackageWidth;
                    mContentDataSet.FieldByName(cFDHeight).AsFloat := 0;
                    mContentDataSet.FieldByName(cFDLength).AsFloat := cDefaultPackageLength;
                    mContentDataSet.FieldByName(cFDVolume).AsFloat := 0;
                    mContentDataSet.FieldByName(cFDContent).AsString := '';
                  end;

                end;
              end;
              //Když přidají jednotku, tak asi zase musíme něco udělat.

              //HMOTNOST Z DOKLADU
              //mPackagesDataSet.FieldByName(cFDManipulationUnit+IntToStr(0)).OnChange := @AddPackageWeight;
              //mPackagesDataSet.FieldByName(cFDWeight+IntToStr(0)).OnChange := @AddPackageWeightAfterSet;
              //mPackagesDataSet.FieldByName(cFDCountMUnit+IntToStr(0)).OnChange := @AddPackageWeightAfterSetQuanty;


            end;



            //FV
            if mDocBO.CLSID = Class_IssuedInvoice then
            begin
              mPackagesDataSet.FieldByName(cFDVarSymbol).AsString := mDocBO.GetFieldValueAsString('VarSymbol');
            end
            else if (mDocBO.CLSID = Class_ReceivedOrder) then
              mPackagesDataSet.FieldByName(cFDVarSymbol).AsString := mDocBO.GetFieldValueAsString('ExternalNumber');

            //čemat VS
            if mDocBO.HasField('ExternalNumber') and ( mDocBO.GetFieldValueAsString('ExternalNumber') <> '' ) then
            begin
              mPackagesDataSet.FieldByName(cFDVarSymbol).AsString := NxLeft( mDocBO.GetFieldValueAsString('ExternalNumber'), 10);
            end;

            if mDocBO.HasField('U_note_driver') then
            begin
              if not NxIsBlank(mDocBO.GetFieldValueAsString('ExternalNumber')) then
              begin
                mPackagesDataSet.FieldByName(cFDNoteForDriver).AsString := mDocBO.GetFieldValueAsString('ExternalNumber');
                if not NxIsBlank(mDocBO.GetFieldValueAsString('U_note_driver')) then
                  mPackagesDataSet.FieldByName(cFDNoteForDriver).AsString := mPackagesDataSet.FieldByName(cFDNoteForDriver).AsString +'; '+  mDocBO.GetFieldValueAsString('U_note_driver');
              end
              else
                mPackagesDataSet.FieldByName(cFDNoteForDriver).AsString := mDocBO.GetFieldValueAsString('U_note_driver');
            end
            else
              mPackagesDataSet.FieldByName(cFDNoteForDriver).AsString := mDocBO.GetFieldValueAsString('ExternalNumber');
            //čemat VS


            //Dobírka
            if not(mDocBO.CLSID in [Class_BillOfDelivery,Class_OutgoingTransfer, Class_ServiceDocument] ) then
              if mDocBO.GetFieldValueAsInteger('PaymentType_ID.PaymentKind') = 3 then
                mPackagesDataSet.FieldByName(cFDCashOnDelivery).AsFloat:= mDocBO.GetFieldValueAsFloat('Amount');
            //Měna dokladu je přenášena základním řešením. U dodacího listu je pouze CZK

            //Udaná cena zásilky. Vždy by měla být větší než 0,- v měně dokladu.
            mPackagesDataSet.FieldByName(cFDAmount).AsFloat:= mDocBO.GetFieldValueAsFloat('Amount');


            //Dobírka, hodnota zásilky
            //Dohledání pro případ, že se jedná o dodaví list. Hledáme na Faktuře vydané pokud existuje.
            //Stačí odkomentovat. Původní čísla (Udaná cena zásilky) bude pro případ existence FV přepsána. A také se v případě platby na dobríku doplní cena dobírky, cena, měna, VS  FV




            if mDocBO.CLSID = Class_BillOfDelivery then
            begin
              mListII := TStringList.Create();
              mBOII := mOS.CreateObject(Class_IssuedInvoice);
              try
                mOS.SQLSelect(Format(cSQLSel_IIby21,[mDocBO.OID]),mListII);
                if mListII.Count > 0 then
                begin
                  mBOII.Load(mListII[0],nil);
                  mPackagesDataSet.FieldByName(cFDVarSymbol).AsString := mBOII.GetFieldValueAsString('VarSymbol');
                  mPackagesDataSet.FieldByName(cFDCurrency).AsString := mBOII.GetFieldValueAsString('Currency_ID');
                  if (mBOII.GetFieldValueAsInteger('PaymentType_ID.PaymentKind') = 3) then
                    mPackagesDataSet.FieldByName(cFDCashOnDelivery).AsFloat:= mBOII.GetFieldValueAsFloat('Amount');
                  mPackagesDataSet.FieldByName(cFDAmount).AsFloat:= mBOII.GetFieldValueAsFloat('Amount');
                end;
              finally
                mListII.free;
                mBOII.Free;
              end;
            end;
            //-- ČEMAT begin: adresa z uživatelských U_ položek na OP ----------
            // Pokud jsou na OP vyplny uživatelské položky adresy (U_street,
            // U_city_postcode, U_Postcode), použije se tato adresa místo
            // standardní adresy firmy/provozovny.
            if (mDocBO.CLSID = Class_ReceivedOrder) then
            begin
              if (Trim(mDocBO.GetFieldValueAsString('U_street')) <> '') and
                 (Trim(mDocBO.GetFieldValueAsString('U_city_postcode')) <> '') and
                 (Trim(mDocBO.GetFieldValueAsString('U_Postcode')) <> '') then
              begin
                mPackagesDataSet.FieldByName(cFDTargetAddressType).AsInteger := cFromAddress;
                mPackagesDataSet.FieldByName(cFDAdrName).AsString := Trim(mDocBO.GetFieldValueAsString('U_name'));
                mPackagesDataSet.FieldByName('PersonName').AsString := Trim(mDocBO.GetFieldValueAsString('U_contact'));
                mPackagesDataSet.FieldByName(cFDAdrStreet).AsString := Trim(mDocBO.GetFieldValueAsString('U_street'));
                mPackagesDataSet.FieldByName(cFDAdrCity).AsString := Trim(mDocBO.GetFieldValueAsString('U_city_postcode'));
                mPackagesDataSet.FieldByName(cFDAdrPostCode).AsString := Trim(mDocBO.GetFieldValueAsString('U_Postcode'));
                mPackagesDataSet.FieldByName(cFDAdrCountryCode).AsString := Trim(mDocBO.GetFieldValueAsString('U_CountryCode.Code'));
                mPackagesDataSet.FieldByName(cFDAdrPhoneNumber).AsString := Trim(mDocBO.GetFieldValueAsString('U_phone'));
              end;
            end;
            //-- ČEMAT end ------------------------------------------------
            mPackagesDataSet.Post;



          end;
        end;
      finally
        mDocBO.Free;
      end;
      mPackagesDataSet.Next;
    end;
    mPackagesDataSet.First;
    mPackagesDataSet.Edit;
    mHeaderDataSet.Post;

  except
    ShowMessage('Nastala vyjímka během předvyplnění.' + ExceptionMessage);
  end;


end;



//Provede vyčištění služby, která by mohla zůstat stará od jiného přepravce
procedure AfterChangeProvider(AOSInt: integer; APackagesDataSetInt: integer; AHeaderDataSetInt: integer);
const
  cSQL = 'select a.ID from PDMPostProviders a where a.X_PD_IsLicensed = %s and a.X_PD_Driver = %s and upper(a.Code) = %s';
var
  mOS: TNxCustomObjectSpace;
  mPackagesDataSet, mHeaderDataSet: TDataSet;
  mSQL, mPostProvider_ID, mIssuedContent_ID: string;
begin
  mOS := TNxCustomObjectSpace(IntToObj(AOSInt));
  mPackagesDataSet := TDataSet(IntToObj(APackagesDataSetInt));
  mHeaderDataSet := TDataSet(IntToObj(AHeaderDataSetInt));

  mHeaderDataSet.First;
  mHeaderDataSet.Edit;


  mPostProvider_ID := '';
  mPostProvider_ID := mHeaderDataSet.FieldByName(cFDPDMProvider).AsString;
  if not CFxOID.IsEmptyOrFull( mPostProvider_ID ) then
  begin
    mPackagesDataSet.First;
    mPackagesDataSet.Edit;
    while not mPackagesDataSet.Eof do
    begin
      mPackagesDataSet.Edit;
      {
      //Předvyplnění po zadání přepravce, default služba
      case mPostProvider_ID of
        //PPL
        '5000000101': mIssuedContent_ID := '8000000101';
        //toptrans
        '4000000101': mIssuedContent_ID := '6000000101';
      end;}
      mIssuedContent_ID := '';
      if not CFxOID.IsEmptyOrFull(mIssuedContent_ID) then
        mPackagesDataSet.FieldByName(cFDContentType).AsString := mIssuedContent_ID;
      mPackagesDataSet.Post;
      mPackagesDataSet.Next;
    end;

  end;
  mPackagesDataSet.First;
  mPackagesDataSet.Edit;



end;



procedure ExAfterGetData_DoNothing(AOSInt: integer; APackagesDataSetInt: integer; AHeaderDataSetInt: integer);
const
  cSQL = 'select a.ID from PDMPostProviders a where a.X_PD_IsLicensed = %s and a.X_PD_Driver = %s and upper(a.Code) = %s';
var
  mOS: TNxCustomObjectSpace;
  mPackagesDataSet, mHeaderDataSet: TDataSet;
  mSQL, mPostProvider_ID: string;
begin
  mOS := TNxCustomObjectSpace(IntToObj(AOSInt));
  mPackagesDataSet := TDataSet(IntToObj(APackagesDataSetInt));
  mHeaderDataSet := TDataSet(IntToObj(AHeaderDataSetInt));

// dohledani poskytovatele a prirazeni do hlavickoveho datasetu
  mSQL := format(cSQL, [QuotedStr('A'), IntToStr(cDriverBalikobot), QuotedStr('DPD')]);
  mPostProvider_ID := GetFirstRecordFromSQL(mOS, mSQL);

  if not CFxOID.IsEmpty(mPostProvider_ID) then begin
    //změna posktytovatele
    mHeaderDataSet.First;
    mHeaderDataSet.Edit;
    mHeaderDataSet.FieldByName(cFDPDMProvider).AsString := mPostProvider_ID;
  end;

end;

function GetFirstRecordFromSQL(AOS: TNxCustomObjectSpace; ASQL: String): String;
var
  mSQLRes: TStrings;
begin
  Result := '';
  mSQLRes := TStringList.Create;
  try
    AOS.SQLSelect(ASQL, mSQLRes);
    if mSQLRes.Count > 0 then
      Result := mSQLRes.Strings[0];
  finally
    mSQLRes.Free;
  end;
end;



//Přidání řádku obsahu
procedure AddContentRow(var AContentDataSet: TMemoryDataset; );  // var ADatasetPackages:TMemoryDataset
var mDataset,mPackagesDataSet : TMemoryDataset;
    mPosIndex : Integer;
begin
  try
    mPackagesDataSet := TMemoryDataset(( IntToObj( AContentDataSet.Tag) ));
    mPosIndex := 0;
    mPosIndex := GetContentCount(mPackagesDataSet,AContentDataSet);
    AContentDataSet.DisableControls;

    AContentDataSet.Append;
    AContentDataSet.Post;
    AContentDataSet.Edit;
    AContentDataSet.FieldByName(cFDParentID).AsString := mPackagesDataSet.FieldByName(cFDID).AsString;
    AContentDataSet.FieldByName(cFDDisplayNumber).AsString := mPackagesDataSet.FieldByName(cFDDisplayNumber).AsString;
    RTTI.SetStrProp(AContentDataSet.FieldByName(cFDWeight), 'DISPLAYFORMAT', '0.000,');
    AContentDataSet.FieldByName(cFDWeight).EditMask := '';
    RTTI.SetStrProp(AContentDataSet.FieldByName(cFDVolume), 'DISPLAYFORMAT', '0.000,');


    AContentDataSet.FieldByName(cFDVolume).EditMask := '';
    AContentDataSet.FieldByName(cFDPosindex).AsInteger := mPosIndex+1;
    AContentDataSet.FieldByName(cFDWeight).AsFloat := 0;
    AContentDataSet.FieldByName(cFDWeightUnit).AsInteger := 1;
    AContentDataSet.FieldByName(cFDWidth).AsFloat := cDefaultPackageWidth;
    AContentDataSet.FieldByName(cFDHeight).AsFloat := 0;
    AContentDataSet.FieldByName(cFDLength).AsFloat := cDefaultPackageLength;
    AContentDataSet.FieldByName(cFDVolume).AsFloat := 0;
    AContentDataSet.Edit;

  finally
    AContentDataSet.EnableControls;
  end;
end;



//Zjistí počet balíků pro konkrétní zvolený row
function GetContentCount(const APackagesDataSet, AContentDataSet: TMemoryDataset;):Integer;
begin
  Result:=0;
  AContentDataSet.DisableControls;
  AContentDataSet.First;
  while not AContentDataSet.Eof do
  begin
    if (APackagesDataSet.FieldByName(cFDID).AsString = AContentDataSet.FieldByName(cFDParentID).AsString) then
      Inc( Result,1);
    AContentDataSet.Next;
  end;
  AContentDataSet.EnableControls;
end;


//Možnost určit název tiskárny na kterou se odešle štítek
function _GetPrinterName(AOSInt: integer; ABO_PDMDoc: integer;):String;
var mBO: TNxCustomBusinessObject;
    mOS: TNxCustomObjectSpace;
    mList: TStringList;
begin
  mOS :=  TNxCustomObjectSpace(IntToObj(AOSInt));
  mBO :=  TNxCustomBusinessObject(IntToObj(ABO_PDMDoc));
  //mBO.GetFieldValueAsString('Sender_ID.SecurityUser_ID.X_PrinterName');
  //mBO.GetFieldValueAsString('X_Store_ID.X_PrinterName');
  OutputDebugString( mBO.DisplayName );
  Result := '';

  mList:= TStringList.Create();
  try
    mOS.SQLSelect( Format('Select A.Code from TransportationTypes A where A.X_PostProvider_ID = ''%s'' and A.X_Service_ID = ''%s'' ',[mBO.GetFieldValueAsString('PostProvider_ID'), mBO.GetFieldValueAsString('IssuedContent_ID') ]),mList);
    if mList.Count > 0 then
    begin
      Result := mList[0];
    end;
  finally
    mList.free;
  end;

end;




function ShowInputField(Sender: TObject; ADefaultValue : Double = 1; ACaption:String;ADecimalPlaces:Integer =  0):Double;
var
  mFormInput: TForm;
  mEdit: TNumEdit;
  mButtonEnter: TButton;
begin
  try
    Result := ADefaultValue;
    mFormInput := nil;
    mEdit := nil;
    mFormInput := TForm.Create(TDynSiteForm(Sender));
    mEdit := TNumEdit.Create(mFormInput);
    mButtonEnter := TButton.Create(mFormInput);

    with mFormInput do
    begin
      Name := 'mFormInput';
      Left := 192;
      Top := 125;
      Width := 400;
      Height := 82+10;
      Caption := ACaption;
      Color := clBtnFace;
      OldCreateOrder := False;
      PixelsPerInch := 96;
    end;
    mFormInput.Font.Size := mFormInput.Font.Size +4;
    with mEdit do
    begin
      Name := 'mEdit';
      Value := ADefaultValue;
      Parent := mFormInput;
      Left := 8;
      Top := 8;
      Width := 369;
      Height := 40;
      TabOrder := 0;
      OnKeyDown:= @ActEnter;
      Tag := ObjToInt(mButtonEnter);
      DecimalPlaces := ADecimalPlaces;
    end;
    mEdit.Font.Size := mEdit.Font.Size +4;



    with mButtonEnter do
    begin
      Name := 'mButtonEnterInput';
      Parent := mFormInput;
      Left := 384;
      Top := 8;
      Width := 0;
      Height := 0;
      Caption := 'mButtonEnter';
      TabOrder := 1;
      ModalResult := mrOk;
    end;


    mFormInput.SetFocusedControl(mEdit);
    if mFormInput.ShowModal(TDynSiteForm(Sender)) = mrOk then
    begin
      mFormInput.Close;

      Result :=  mEdit.Value;
      mEdit.Clear;
    end
    else
    begin
      ShowMessage('Přerušení');
      Result :=  -1;
      exit;
    end;


  finally
    if mEdit <> nil then
      mEdit.Free;
    if mFormInput <> nil then
      mFormInput.Free;
  end;
end;


procedure ActEnter(Sender: TObject; var Key: Word; Shift: TShiftState);
var
  mButton: TButton;
begin
  mButton := nil;
  if Key = VK_RETURN then
  begin
    mButton := TButton(IntToObj(TNumEdit(Sender).Tag));
    //mButton := TButton(TEdit(Sender).Parent.FindChildControl('mButtonEnterInput'));
    if Assigned(mButton) then
      mButton.Click;
  end;
end;




begin
end.