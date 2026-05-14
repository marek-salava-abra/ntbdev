uses
  'eu.abra.PostProviders.extras.TransportationType_LipoElastic.uConst',
  'eu.abra.PostProviders.extras.TransportationType_LipoElastic.uForm';
/////*****//////
//Předvyplnění umožní ovlivnit způsob naplnění datasetu/formuláře
//Základ se snaží pokrýt oblasti E-comerce -> balík po balíku, pobočky (zasilovna..), tvorba odeslané pošty nad FV, OP
//Nejedná se o univerzální parametrizované řešení jako WMS. Zde si konzultant může dělat co potřebuje.
//Pro koho je určené: Pro konzultanty/programátory
//Spuštění těchto scriptů je zajištěno v číselníku "Balíky - Nastavení" viz manuál.
/////*****//////

var gLog:TStringList;

const
  //Zde doplnit tři základní konstanty
  cDivisionID = '1N00000101'; //ok
  cDocQueueID = '~000000007';
  cStoreID = '1120000101';  //ok

  cLipo_FD_DeliveryNote = 'X_poznamka';



  //mozne uzivatelske skripty - podle typu volání je nastaven vstupní parametr.
  cScriptNone = 0;
  cScriptAfterGetData = 1; //Zpracování dat, načtení do datasetu.
  cScriptAfterProviderChange = 2; //Změna poštoního poskytovatele.
  cScriptAfterGetDataImportManager = 3;//Balíky rychle.
  cScriptAfterGetDataImportManagerNonVisual = 4; //import manager například (WMS,API).
  cScriptGetPrinterNameHook = 5; //Získání názvu tiskárny.
  cScriptAfterContentFieldChange = 6; //Po opravě fieldu na řádku obsahu - například po zadání rozměru může k dopočtení objemu.
  cScriptUserButton = 7; //Zakázková akce, tlačítko.


function Custom_GetIntrastatWeight(ABO: TNxCustomBusinessObject;):Extended;
var mOS: TNxCustomObjectSpace;
    mTable, mSQL:String;
    mWeight:Extended;
const cSQL = 'select sum(Case '+
            ' When SC.IntrastatWeightUnit = 0 Then (SC.IntrastatWeight * A.Quantity) /1000 '+
            ' When SC.IntrastatWeightUnit = 1 Then (SC.IntrastatWeight * A.Quantity) '+
            ' When SC.IntrastatWeightUnit = 2 Then (SC.IntrastatWeight * A.Quantity) *1000 '+
            ' end ) '+
            ' from %s A '+
            ' join StoreCards SC on SC.Id = A.StoreCard_Id '+
            ' where sc.hidden = ''N'' '+
            ' and A.Parent_Id = ''%s'' ';
begin
  Result := 0;
  mOS := ABO.ObjectSpace;

  case ABO.CLSID of
    Class_BillOfDelivery,Class_OutgoingTransfer : mTable := 'StoreDocuments2';
    Class_IssuedInvoice : mTable := 'IssuedInvoices2';
    Class_ReceivedOrder : mTable := 'ReceivedOreds2';
  end;
  mSQL := Format(cSQL,[mTable, ABO.OID]);
  OutputDebugString(mSQL);
  mWeight := mOS.SQLSelectFirstAsExtended( mSQL, 0 );
  OutputDebugString('Intrastat weight: '+FloatToStr(mWeight ));
  Result := mWeight;

end;


//Zpracování dat, načtení do datasetu. //Default - vizuální - "Balíky"
//cScriptAfterGetData
procedure GetDataFromDoc(AOSInt: integer; APackagesDataSetInt: integer; AHeaderDataSetInt: integer; AContentDataSetInt: integer; ARunType : Integer);
begin
  _GetDataFromDoc(AOSInt, APackagesDataSetInt, AHeaderDataSetInt, AContentDataSetInt,ARunType);

end;


//Balíky rychle. //Default - vizuální - "Balík rychle" = import manager
//cScriptAfterGetDataImportManager
procedure GetDataFromDocIM(AOSInt: integer; APackagesDataSetInt: integer; AHeaderDataSetInt: integer; AContentDataSetInt: integer; ARunType : Integer);
begin
  _GetDataFromDoc(AOSInt, APackagesDataSetInt, AHeaderDataSetInt, AContentDataSetInt,ARunType);

end;

//import manager například (WMS,API).//Default - nevizuální - "WMS" = import manager
//cScriptAfterGetDataImportManagerNonVisual
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

//Po provedení změny na políčkách v contentu.
//cScriptAfterContentFieldChange
procedure ChangeContentField(AOSInt: integer; AContentDataSetInt: integer;  AField: integer; ARunType : Integer);
begin
  _ChangeContentField(AOSInt, AContentDataSetInt, AField, ARunType);

end;

//Po provedení změny na políčkách v contentu.
//cScriptAfterContentFieldChange
procedure ActionButton_EditFirmOfficeAddress(ASite: integer; APackagesDataSetInt: integer; AHeaderDataSetInt: integer; AContentDataSetInt: integer; ARunType : Integer);
begin
  _ActionButton_EditFirmOfficeAddress(ASite, APackagesDataSetInt, AHeaderDataSetInt, AContentDataSetInt,ARunType);

end;

//LIPOELASTIC START
//Projde spojené doklady a něco udělá.
function Custom_RelatedDoc(mOS:TNxCustomObjectSpace ;var mDocBO: TNxCustomBusinessObject; var mPackagesDataSet:TDataSet; var mHeaderDataSet:TDataSet; var mContentDataSet: TDataSet):Boolean;
var mRelatedIds:TStringList;
    mRel_DocBO:TNxCustomBusinessObject;
    i:Integer;
begin

  //Z Hlavního záznamu
  //Kontroluji, že se shoduje měna a typ zp. uhrady.
  if not Custom_GetInfoFromIssuedInvoice(mOS,mDocBO,mPackagesDataSet) then
    Custom_GetInfoFromReceivedOrder(mOS,mDocBO,mPackagesDataSet);

  //Sloučená zásilka
  mRelatedIds := TStringList.Create;
  try
    mRelatedIds.Clear;
    if not (NxTrim(mPackagesDataSet.FieldByName(cFDRelationWithIDs).AsString,' ') = '') then
    begin
      mRelatedIds.CommaText := mPackagesDataSet.FieldByName(cFDRelationWithIDs).AsString;
    end;
    OutputDebugString(mRelatedIds.Text);
    gLog.add(Format('   Hlavní ID: %s ',[mDocBO.OID ]));

    if mRelatedIds.Count > 0 then
      gLog.add(Format('Připojené ID: %s ',[mRelatedIds.CommaText ]));

    for i:=0 to mRelatedIds.Count -1 do
    begin
      mRel_DocBO := mOS.CreateObject(mDocBO.CLSID);
      try
        mRel_DocBO.Load(mRelatedIds[i],nil);
        OutputDebugString(Format('Načten připojený doklad %s',[mRel_DocBO.DisplayName]));
        //Z připojených.
        if not Custom_GetInfoFromIssuedInvoice(mOS,mRel_DocBO,mPackagesDataSet,true) then
          Custom_GetInfoFromReceivedOrder(mOS,mRel_DocBO,mPackagesDataSet,true);
      finally
        mRel_DocBO.Free;
        mRel_DocBO:= nil;
      end;
    end;
  finally
    mRelatedIds.free;
  end;

end;



//Dotažení dat z OP. Částka se bere jenom ta část, která je v aktuálním DL. Z prvního dokladu se bere ostatní. Neřeší se kombinace měn.
//Když něco najdu, pak vracím True
function Custom_GetInfoFromReceivedOrder(mOS:TNxCustomObjectSpace ;var mDocBO: TNxCustomBusinessObject; var mPackagesDataSet: TDataSet; AIsRelatedDoc:Boolean = False):Boolean;
var
  mDataRO:TMemoryDataset;
  mBORO: TNxCustomBusinessObject;
  mSQL:String;
  mAmount:Extended;
  mCount:Integer;

Const cSQLSel_RORowby21 = 'select RO.id as ID,Sum(RO2.TAmount) as TAmount  '+
              'from ReceivedOrders2 RO2 '+
              'join ReceivedOrders RO on RO.ID = RO2.PARENT_ID '+
              'join STOREDOCUMENTS2 SD2 on SD2.PROVIDEROW_ID = RO2.ID '+
              'where SD2.parent_id = ''%s''  group by RO.id  ';

begin
  Result := False;
  //Nejprve juknu na OP
  //A jenom poměrnou čáastku z dokladu
  mDataRO := TMemoryDataset.Create(nil);
  mBORO := mOS.CreateObject(Class_ReceivedOrder);
  try
    mCount := 0;
    mSQL := Format(cSQLSel_RORowby21,[mDocBO.OID]);
    OutputDebugString(mSQL);
    mOS.SQLSelect2(mSQL,mDataRO);
    if mDataRO.Active then
      mDataRO.First;
    if not mDataRO.Eof then
    begin

      mBORO.Load(mDataRO.FieldByName('ID').AsString ,nil);
      gLog.add(Format('K dokladu %s byl nalezen %s (Objednávka)',[mDocBO.DisplayName, mBORO.DisplayName ]));

      //Z hlavního beru základ.
      if not AIsRelatedDoc then begin
        mPackagesDataSet.FieldByName(cFDVarSymbol).AsString := mBORO.GetFieldValueAsString('ExternalNumber');
        mPackagesDataSet.FieldByName(cFDCurrency).AsString := mBORO.GetFieldValueAsString('Currency_ID');
        gLog.add(Format('Měna: %s',[mBORO.GetFieldValueAsString('Currency_ID.code') ]));
        gLog.add(Format('VS: %s',[mPackagesDataSet.FieldByName(cFDVarSymbol).AsString ]));
      end else begin
        if not (mPackagesDataSet.FieldByName(cFDCurrency).AsString = mBORO.GetFieldValueAsString('Currency_ID')) then
          NxShowMessage('Nalezen konflik v dokladech','Měna hlavního doklad se liší od připojených.',mdWarning,True,nil);
        if ((mPackagesDataSet.FieldByName(cFDCashOnDelivery).AsFloat > 0) and (mBORO.GetFieldValueAsInteger('PaymentType_ID.PaymentKind') <> 3)) then
          NxShowMessage('Nalezen konflik v dokladech','Způsob úhrady se liší na připojených dokladech. Hlavní je s dobírkou, ale jeden (nebo více) má jiný typ úhrady. Proveďte kontrolu výše dobírky. Nemusí se jednat o chybu, ale pokračujete na vlastní nebezpečí.',mdWarning,True,nil);
      end;

      //U prvního nuluji data, ale když je to připojený, tak postupně přidávám
      if not AIsRelatedDoc then begin
        mAmount := 0;
      end else begin
        mAmount := mPackagesDataSet.FieldByName(cFDAmount).AsFloat;
      end;


      while not mDataRO.Eof do
      begin
        inc(mCount,1);

        if not AIsRelatedDoc then begin
          gLog.add(Format('nastavuji částku: %s',[ FloatToStr(mDataRO.FieldByName('TAmount').AsFloat)   ]));
        end else begin
          gLog.add(Format(' přičítám částku: %s',[ FloatToStr(mDataRO.FieldByName('TAmount').AsFloat)   ]));
        end;

        mAmount := mAmount +  mDataRO.FieldByName('TAmount').AsFloat;
        mDataRO.Next;
      end;

      if (mBORO.GetFieldValueAsInteger('PaymentType_ID.PaymentKind') = 3) then
      begin

        //U prvního nastavuji dobírku, ale když je to připojený, tak postupně přidávám
        if not AIsRelatedDoc then begin
          mPackagesDataSet.FieldByName(cFDCashOnDelivery).AsFloat:= mAmount;
        end else begin
          mPackagesDataSet.FieldByName(cFDCashOnDelivery).AsFloat:= mPackagesDataSet.FieldByName(cFDCashOnDelivery).AsFloat + mAmount;
        end;

        if mCount > 1 then
          ShowMessage('Pozor do dokladu DL je vloženo více Objednávek a navíc byl nalezen příznak dobírka. Zkontrolujte částku dobírky.');
      end;
      mPackagesDataSet.FieldByName(cFDAmount).AsFloat:= mAmount;
      Result := true;
    end;

  finally
    mDataRO.free;
    mBORO.Free;
  end;


end;



//Dotažení dat z OP. Částka se bere jenom ta část, která je v aktuálním DL. Z prvního dokladu se bere ostatní. Neřeší se kombinace měn.
//Když něco najdu, pak vracím True
function Custom_GetInfoFromIssuedInvoice(mOS:TNxCustomObjectSpace ;var mDocBO: TNxCustomBusinessObject; var mPackagesDataSet: TDataSet; AIsRelatedDoc:Boolean = False):Boolean;
var
  mDataRO:TMemoryDataset;
  mBORO: TNxCustomBusinessObject;
  mSQL:String;
  mAmount:Extended;
  mCount:Integer;

Const cSQLSel_RORowby21 = 'select II.id as ID,Sum(II2.TAmount) as TAmount  '+
              'from ISSUEDINVOICES2 II2 '+
              'join ISSUEDINVOICES II on II.ID = II2.PARENT_ID '+
              'join STOREDOCUMENTS2 SD2 on SD2.ID = II2.PROVIDEROW_ID '+
              'where SD2.parent_id = ''%s'' group by II.id  ';
begin
  Result := False;
  //Nejprve juknu na OP
  //A jenom poměrnou čáastku z dokladu
  mDataRO := TMemoryDataset.Create(nil);
  mBORO := mOS.CreateObject(Class_IssuedInvoice);
  try
    mCount := 0;
    mSQL := Format(cSQLSel_RORowby21,[mDocBO.OID]);
    OutputDebugString(mSQL);
    mOS.SQLSelect2(mSQL,mDataRO);
    if mDataRO.Active then
      mDataRO.First;
    if not mDataRO.Eof then
    begin

      mBORO.Load(mDataRO.FieldByName('ID').AsString ,nil);
      gLog.add(Format('K dokladu %s byl nalezen %s (Faktura)',[mDocBO.DisplayName, mBORO.DisplayName ]));
      //Z hlavního beru základ.
      if not AIsRelatedDoc then begin
        mPackagesDataSet.FieldByName(cFDVarSymbol).AsString := mBORO.GetFieldValueAsString('VarSymbol');
        mPackagesDataSet.FieldByName(cFDCurrency).AsString := mBORO.GetFieldValueAsString('Currency_ID');
        gLog.add(Format('Měna: %s',[mBORO.GetFieldValueAsString('Currency_ID.code') ]));
        gLog.add(Format('VS: %s',[mPackagesDataSet.FieldByName(cFDVarSymbol).AsString ]));
      end else begin
        if not (mPackagesDataSet.FieldByName(cFDCurrency).AsString = mBORO.GetFieldValueAsString('Currency_ID')) then
          NxShowMessage('Nalezen konflik v dokladech','Měna hlavního doklad se liší od připojených.',mdWarning,True,nil);
        if ((mPackagesDataSet.FieldByName(cFDCashOnDelivery).AsFloat > 0) and (mBORO.GetFieldValueAsInteger('PaymentType_ID.PaymentKind') <> 3)) then
          NxShowMessage('Nalezen konflik v dokladech','Způsob úhrady se liší na připojených dokladech. Hlavní je s dobírkou, ale jeden (nebo více) má jiný typ úhrady. Proveďte kontrolu výše dobírky. Nemusí se jednat o chybu, ale pokračujete na vlastní nebezpečí.',mdWarning,True,nil);
      end;


      //U prvního nuluji data, ale když je to připojený, tak postupně přidávám
      if not AIsRelatedDoc then begin
        mAmount := 0;
      end else begin
        mAmount := mPackagesDataSet.FieldByName(cFDAmount).AsFloat;
      end;

      while not mDataRO.Eof do
      begin
        inc(mCount,1);

        if not AIsRelatedDoc then begin
          gLog.add(Format('nastavuji částku: %s',[ FloatToStr(mDataRO.FieldByName('TAmount').AsFloat)   ]));
        end else begin
          gLog.add(Format(' přičítám částku: %s',[ FloatToStr(mDataRO.FieldByName('TAmount').AsFloat)   ]));
        end;

        mAmount := mAmount +  mDataRO.FieldByName('TAmount').AsFloat;
        mDataRO.Next;
      end;

      if (mBORO.GetFieldValueAsInteger('PaymentType_ID.PaymentKind') = 3) then
      begin
        //U prvního nastavuji dobírku, ale když je to připojený, tak postupně přidávám
        if not AIsRelatedDoc then begin
          mPackagesDataSet.FieldByName(cFDCashOnDelivery).AsFloat:= mAmount;
        end else begin
          mPackagesDataSet.FieldByName(cFDCashOnDelivery).AsFloat:= mPackagesDataSet.FieldByName(cFDCashOnDelivery).AsFloat + mAmount;
        end;
        if mCount > 1 then
          ShowMessage('Pozor k dokladu DL bylo nalzeno více Faktur a navíc s příznak dobírka. Zkontrolujte částku dobírky.');
      end;
      mPackagesDataSet.FieldByName(cFDAmount).AsFloat:= mAmount;
      Result := true;
    end;

  finally
    mDataRO.free;
    mBORO.Free;
  end;


end;

//LIPOELASTIC END

//POZOR - Pro správné fungování je třeba naplnit definovatelné položky.
//ARunType: viz popis konstant nahoře.
procedure _GetDataFromDoc(AOSInt: integer; APackagesDataSetInt: integer; AHeaderDataSetInt: integer; AContentDataSetInt: integer; ARunType : Integer);
const
  cSQLProvider = 'select a.ID from PDMPostProviders a where a.X_PD_IsLicensed = %s and a.X_PD_Driver = %s and upper(a.Code) = %s';
  cSQLContentType = 'select b.ID from PDMPostProviders2 a join PDMIssuedContentTypes b on b.ID = a.IssuedContentType_ID where a.parent_ID = %s and upper(b.Code) = %s';
  cSQLBranches = 'select a.ID from PDMServiceTypes a where a.X_PD_PostProvider_ID = %s and a.hidden = ''N'' and a.x_pd_externid = %s and a.x_pd_externid <> '''' ';

  cSQLSel_IIby21 = 'select distinct II.id '+
              'from ISSUEDINVOICES2 II2 '+
              'join STOREDOCUMENTS2 SD2 on SD2.ID = II2.PROVIDEROW_ID '+
              'join ISSUEDINVOICES II on II.ID = II2.PARENT_ID '+
              'where SD2.parent_id = ''%s''';

  cCountMUUnitField = 3;//WMS
var
  mOS: TNxCustomObjectSpace;
  mPackagesDataSet, mHeaderDataSet, mContentDataSet: TDataSet;
  mSQL, mIssuedContent_ID, mServiceType_ID, mDoc_ID, mPostProvider_ID, mDocType: string;
  mDocBO : TNxCustomBusinessObject;
  mListII, mListRelationsID:TStringList;
  mBOII: TNxCustomBusinessObject;
  x,y,j, mCountPackage:Integer;

  mNote:String;
  mWeight:Extended;
begin
  gLog:= nil;
  try

    mOS := TNxCustomObjectSpace(IntToObj(AOSInt));

    mPackagesDataSet := TDataSet(IntToObj(APackagesDataSetInt));
    mHeaderDataSet := TDataSet(IntToObj(AHeaderDataSetInt));
    mContentDataSet := TDataSet(IntToObj(AContentDataSetInt));

    //Jadro postroviders vkládá automaticky. Odstraníme a přidáme si vlastní.
    ClearFirst(TMemoryDataset(mContentDataSet));

    mPackagesDataSet.First;
    while not mPackagesDataSet.Eof do
    begin
      mPackagesDataSet.Edit;
      mDoc_ID := '';
      mServiceType_ID := '';
      mIssuedContent_ID := '';
      mDocType := mPackagesDataSet.FieldByName(cFDDocumentType).AsString;
      gLog:= TStringList.Create();
      gLog.add('GLOG START CUSTOM PREFIL');
      try
        mPackagesDataSet.Edit;
        mHeaderDataSet.Edit;


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

            //Pokud se nejedná o Balík rychle, nebo WMS -> tedy se jedná o variantu "tlačítko balíky" a vše ostatní
            if not (ARunType in [cScriptAfterGetDataImportManagerNonVisual,cScriptAfterGetDataImportManagerNonVisual]) then
            begin
              //Zde si můžeme upravit přidaný řádek contentu.
              AddContentRow(TMemoryDataset(mContentDataSet) );
              mWeight := Custom_GetIntrastatWeight(mDocBO);
              if mWeight <> 0 then
              begin
                mContentDataSet.FieldByName(cFDWeight).AsFloat := mWeight;
              end
              else
                if mDocBO.HasField('Weight') then
                begin
                  case mDocBO.GetFieldValueAsInteger('WeightUnit') of
                  0: mContentDataSet.FieldByName(cFDWeight).AsFloat := mDocBO.GetFieldValueAsFloat('Weight') / 1000;
                  1: mContentDataSet.FieldByName(cFDWeight).AsFloat := mDocBO.GetFieldValueAsFloat('Weight');
                  end;
                end
                else
                  mContentDataSet.FieldByName(cFDWeight).AsFloat := 0;

              mContentDataSet.FieldByName(cFDWidth).AsFloat := 0;
              mContentDataSet.FieldByName(cFDHeight).AsFloat := 0;
              mContentDataSet.FieldByName(cFDLength).AsFloat := 0;
              mContentDataSet.FieldByName(cFDVolume).AsFloat := 0;
              mContentDataSet.FieldByName(cFDManipulationUnit).AsString := '';
              mContentDataSet.FieldByName(cFDContent).AsString := '';

            end;

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
                  //#mContentDataSet.First;
                  //#mContentDataSet.Delete;
                  for j := 0 to mDocBO.GetFieldValueAsInteger('X_PD_MUCount_0') -1 do
                  begin
                    AddContentRow(TMemoryDataset(mContentDataSet) );
                    mContentDataSet.FieldByName(cFDWeight).AsFloat := 0;
                    mContentDataSet.FieldByName(cFDWidth).AsFloat := 0;
                    mContentDataSet.FieldByName(cFDHeight).AsFloat := 0;
                    mContentDataSet.FieldByName(cFDLength).AsFloat := 0;
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
                    //#if x = 0 then
                    //#begin
                      //#mContentDataSet.First;
                      //#mContentDataSet.Delete;
                    //#end;

                    for y:=0 to mDocBO.GetFieldValueAsInteger('X_PD_MUCount_'+IntToStr(x)) -1 do
                    begin
                      AddContentRow(TMemoryDataset(mContentDataSet) );
                      mContentDataSet.FieldByName(cFDWeight).AsFloat := 0;
                      mContentDataSet.FieldByName(cFDWidth).AsFloat := 0;
                      mContentDataSet.FieldByName(cFDHeight).AsFloat := 0;
                      mContentDataSet.FieldByName(cFDLength).AsFloat := 0;
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
                mContentDataSet.FieldByName(cFDWidth).AsFloat := 0;
                mContentDataSet.FieldByName(cFDHeight).AsFloat := 0;
                mContentDataSet.FieldByName(cFDLength).AsFloat := 0;
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

              //LIPO
              //Myslím si, že tohle bylo jako první a následně se to předělalo na Export a nastavení v klíčích.
              mNote := '';
              mNote := mDocBO.GetFieldValueAsString('FirmOffice_Id.Address_ID.Location');
              if mDocBO.HasField(cLipo_FD_DeliveryNote) then
              begin
                if mDocBO.GetFieldValueAsString(cLipo_FD_DeliveryNote) <> '' then
                begin
                  if mNote <> '' then
                    mNote := mNote + ', '+ mDocBO.GetFieldValueAsString(cLipo_FD_DeliveryNote)
                  else
                    mNote := mDocBO.GetFieldValueAsString(cLipo_FD_DeliveryNote);
                end;
              end;
              mPackagesDataSet.FieldByName(cFDNoteForDriver).AsString := mNote;

              //LIPO END

              if not(mDocBO.CLSID in [Class_BillOfDelivery,Class_OutgoingTransfer, Class_ServiceDocument] ) then
                mHeaderDataSet.FieldByName(cFDBankAccount).AsString := mDocBO.GetFieldValueAsString('BankAccount_ID');


              mHeaderDataSet.Post;
              mHeaderDataSet.Edit;
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



            end;

            //FV
            if mDocBO.CLSID = Class_IssuedInvoice then
            begin
              mPackagesDataSet.FieldByName(cFDVarSymbol).AsString := mDocBO.GetFieldValueAsString('VarSymbol');
            end
            else if (mDocBO.CLSID = Class_ReceivedOrder) then
              mPackagesDataSet.FieldByName(cFDVarSymbol).AsString := mDocBO.GetFieldValueAsString('ExternalNumber');

            //Dobírka
            if not(mDocBO.CLSID in [Class_BillOfDelivery,Class_OutgoingTransfer, Class_ServiceDocument] ) then
              if mDocBO.GetFieldValueAsInteger('PaymentType_ID.PaymentKind') = 3 then
                mPackagesDataSet.FieldByName(cFDCashOnDelivery).AsFloat:= mDocBO.GetFieldValueAsFloat('Amount');
            //Měna dokladu je přenášena základním řešením. U dodacího listu je pouze CZK

            //Udaná cena zásilky. Vždy by měla být větší než 0,- v měně dokladu.
            mPackagesDataSet.FieldByName(cFDAmount).AsFloat:= mDocBO.GetFieldValueAsFloat('Amount');





            (*
              //LIPO má situace, kdy je jedna OP poslána na 10* a celé to nemá FV.
            //Když něco najdu ve FV, dále nepátrám v OP
            if not Custom_GetInfoFromIssuedInvoice(mOS,mDocBO,mPackagesDataSet) then
              Custom_GetInfoFromReceivedOrder(mOS,mDocBO,mPackagesDataSet);
            *)

            //LIPO má situace, kdy je jedna OP poslána na 10* a celé to nemá FV.
            //Když něco najdu ve FV, dále nepátrám v OP

            if (mDocBO.CLSID = Class_BillOfDelivery) then
              Custom_RelatedDoc(mOS,mDocBO,mPackagesDataSet,mHeaderDataSet,mContentDataSet);


            gLog.add('GLOGEND  CUSTOM PREFIL');
            if NxGetActualUserID(mOS) = '~000000001' then
              ShowMessage( gLog.Text)
            else
              OutputDebugString(gLog.Text);

            //Dobírka, hodnota zásilky
            //Dohledání pro případ, že se jedná o dodací list. Hledáme na Faktuře vydané pokud existuje.
            (* LIPO má jinak
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
            *)


            //LIPO má situace, kdy je jedna OP poslána na 10* a celé to nemá FV.
            (*
            //U sjednocení beru součet všech FV
            //Pozor cFDRelationWithIDs obsahuje jenom relation ID. Vlastní ID záznamu na kterém stojíme si musíme případně přidat/obstarat.
            if mPackagesDataSet.FieldByName(cFDRelationWithIDs).AsString <> '' then
            begin
              mListRelationsID := TStringList.Create;
                try
                  mListRelationsID.CommaText :=mPackagesDataSet.FieldByName(cFDRelationWithIDs).AsString;

                  for x:= 0 to mListRelationsID.Count -1 do
                  begin
                    //Dohledám na FV
                    if mDocBO.CLSID = Class_BillOfDelivery then
                    begin
                      //PŘIČTENÍ
                      //Dobírka, hodnota zásilky
                      //Dohledání pro případ, že se jedná o dodací list. Hledáme na Faktuře vydané pokud existuje.
                      mListII := TStringList.Create();
                      mBOII := mOS.CreateObject(Class_IssuedInvoice);
                      try
                        mOS.SQLSelect(Format(cSQLSel_IIby21,[mListRelationsID[x]]),mListII);
                        if mListII.Count > 0 then
                        begin
                          mBOII.Load(mListII[0],nil);
                          OutputDebugString('k DL id: '+mListII[0]+' byl nalezen: '+ mBOII.DisplayName);
                          if mPackagesDataSet.FieldByName(cFDCurrency).AsString <> mBOII.GetFieldValueAsString('Currency_ID') then
                            RaiseException('Měna dobírky hlavního dokladu z FV se neshoduje se sjednoceným záznamem.');
                          if (mBOII.GetFieldValueAsInteger('PaymentType_ID.PaymentKind') = 3) then
                            mPackagesDataSet.FieldByName(cFDCashOnDelivery).AsFloat:= mPackagesDataSet.FieldByName(cFDCashOnDelivery).AsFloat + mBOII.GetFieldValueAsFloat('Amount');
                          mPackagesDataSet.FieldByName(cFDAmount).AsFloat:= mPackagesDataSet.FieldByName(cFDAmount).AsFloat + mBOII.GetFieldValueAsFloat('Amount');
                          //+Hmotnost
                          if mBOII.HasField('Weight') then
                          begin
                            case mBOII.GetFieldValueAsInteger('WeightUnit') of
                            0: mContentDataSet.FieldByName(cFDWeight).AsFloat := mContentDataSet.FieldByName(cFDWeight).AsFloat +(mBOII.GetFieldValueAsFloat('Weight') / 1000);
                            1: mContentDataSet.FieldByName(cFDWeight).AsFloat := mContentDataSet.FieldByName(cFDWeight).AsFloat + mBOII.GetFieldValueAsFloat('Weight');
                            end;
                          end;
                        end;
                      finally
                        mListII.free;
                        mBOII.Free;
                      end;
                    end;
                  end;
              finally
                mListRelationsID.Free;
              end;
            end;
            *)



            mPackagesDataSet.Post;

          end;
        end;
      finally
        mDocBO.Free;
        if gLog <> nil then
          gLog.free;
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


procedure ClearFirst(var AContentDataSet: TMemoryDataset; );
begin
  if AContentDataSet.Active then
  begin
    AContentDataSet.First;
    AContentDataSet.Delete;
  end;
end;





//Přidání řádku obsahu
procedure AddContentRow(var AContentDataSet: TMemoryDataset; );  // var ADatasetPackages:TMemoryDataset
var mDataset,mPackagesDataSet : TMemoryDataset;
    mPosIndex : Integer;
begin
  try
    OutputDebugString('AddContentRow');
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
    AContentDataSet.FieldByName(cFDWidth).AsFloat := 0;
    AContentDataSet.FieldByName(cFDHeight).AsFloat := 0;
    AContentDataSet.FieldByName(cFDLength).AsFloat := 0;
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
    mPrinterName:String;
begin
  mOS :=  TNxCustomObjectSpace(IntToObj(AOSInt));
  OutputDebugString( mBO.DisplayName );
  Result := '';
  mPrinterName := mOS.SQLSelectFirstAsString(Format('Select X_Printer_Label from SecurityUsers where id  = ''%s'' ',[NxGetActualUserID(mOS)]),'');
  OutputDebugString('Prefilll _GetPrinterName, result: '+mPrinterName);
  Result := mPrinterName;


end;




//Například po nastavení manipulační jednotky dojde k předvyplnění velikosti.
procedure _ChangeContentField(AOSInt: integer; AContentDataSetInt: integer; AField:Integer; ARunType : Integer);
var mOS: TNxCustomObjectSpace;
    mContentDataset: TMemoryDataset;
    mField: TField;
begin
  mOS :=  TNxCustomObjectSpace(IntToObj(AOSInt));
  mContentDataset :=  TMemoryDataset(IntToObj(AContentDataSetInt));
  mField := TField(IntToObj(AField));
  OutputDebugString(mField.FullName);
  OutputDebugString(mField.DisplayLabel);
  OutputDebugString(mField.FieldName);
  if mField.FieldName = cFDManipulationUnit then
  begin
    if not CFxOID.IsEmptyOrFull(mField.Value) then
    begin
      //ShowMessage(mField.Value);
      //case mField.Value of

      //end;
    end;
  end;
end;



//Drobná oprava provozovny. Zakázkově přidané tlačítko. Je třeba myslet na dopady. Umožnení editace firmy neřeší oprávnění. Ne vždy má skladník toto právo.
procedure _ActionButton_EditFirmOfficeAddress(ASite: integer; APackagesDataSetInt: integer; AHeaderDataSetInt: integer; AContentDataSetInt: integer; ARunType : Integer;);
var mPackagesDataSet, mHeaderDataSet, mContentDataSet: TDataSet;
    mOS: TNxCustomObjectSpace;
    mMUID,mPostProvider_ID,mFieldName,mPrefix :String;
    mBOFirm, mOffice:TNxCustomBusinessObject;
    mMon: TNxCustomBusinessMonikerCollection;
    i,j:Integer;
    mForm:TForm;
    mListComponent:TStringList;
    mEdit:TEdit;
    mSynchronizeAddress:Boolean;
begin
  mOS := TSiteForm(ASite).BaseObjectSpace;

  mPackagesDataSet := TDataSet(IntToObj(APackagesDataSetInt));
  mHeaderDataSet := TDataSet(IntToObj(AHeaderDataSetInt));
  mContentDataSet := TDataSet(IntToObj(AContentDataSetInt));
  mListComponent := TStringList.Create;


  if (not CFxOID.IsEmptyOrFull(mPackagesDataSet.FieldByName(cFDFirm_ID).AsString))
    and (not CFxOID.IsEmptyOrFull(mPackagesDataSet.FieldByName(cFDFirmOffice_ID).AsString)) then
  begin
    try
      mBOFirm := mOS.CreateObject(Class_Firm);
      mBOFirm.Load(mPackagesDataSet.FieldByName(cFDFirm_ID).AsString,nil);

      mMon := mBOFirm.GetLoadedCollectionMonikerForFieldCode(mBOFirm.GetFieldCode('FirmOffices'));
      for i:= 0 to mMon.CountOfNotDeleted -1 do
      begin
        mOffice := mMon.BusinessObject[i];
        if mPackagesDataSet.FieldByName(cFDFirmOffice_ID).AsString = mOffice.OID then
        begin
          try
            //Pokud je synchro, pak musím upravit na hlavičce   ResidenceAddress_ID
            mForm := Create_EditAddressFrom(TSiteForm(ASite), mPackagesDataSet, mHeaderDataSet, mContentDataSet,mListComponent);
            mPrefix := '';

            mSynchronizeAddress :=(mOffice.GetFieldValueAsBoolean('SynchronizeAddress'));
            if mSynchronizeAddress then
            begin
              mPrefix := 'Residence';
              //mOffice := mBOFirm;
            end;


            for j:= 0 to mListComponent.Count -1 do
            begin
              mFieldName := '';
              mEdit := TEdit( mForm.FindComponent(mListComponent[j]));
              mFieldName := mEdit.Name;
              mFieldName := NxSearchReplace(mFieldName,'Address_ID_',mPrefix +'Address_ID.',[srAll]);
              if mSynchronizeAddress and (not( mFieldName in ['Name'])) then
                mEdit.Text := mBOFirm.GetFieldValueAsString(mFieldName)
              else
                mEdit.Text := mOffice.GetFieldValueAsString(mFieldName);
            end;


            if mForm.ShowModal(ASite) = mrOk then //TODO najít formulář balíky
            begin

              for j:= 0 to mListComponent.Count -1 do
              begin
                mFieldName := '';
                mEdit := TEdit( mForm.FindComponent(mListComponent[j]));
                mFieldName := mEdit.Name;
                mFieldName := NxSearchReplace(mFieldName,'Address_ID_',mPrefix +'Address_ID.',[srAll]);
                if mSynchronizeAddress and (not( mFieldName in ['Name'])) then
                  mBOFirm.SetFieldValueAsString(mFieldName,mEdit.Text)
                else
                  mOffice.SetFieldValueAsString(mFieldName,mEdit.Text);
              end;

              //mOffice.SetFieldValueAsString('Address_ID.Location','TEST');
              mBOFirm.Save;
              //TODO - reeload Datasetu.

            end;

          finally
            mForm.Free;
          end;
        end;

      end;


    finally
      mBOFirm.free;
      mListComponent.free;
    end;
  end;

end;




begin
end.