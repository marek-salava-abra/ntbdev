uses '.API';

var
  gUpdated, gCreated: Integer;

procedure StoreCardAPISync2(ABO: TNxCustomBusinessObject; var AResultStr: string;var aIndex:integer; var aResult_ID:string);
var
  mOS: TNxCustomObjectSpace;
  mBO, mPARBO, mParSourceBO, mTempBO, mUnitBO, mEANBO, mContainerBO: TNxCustomBusinessObject;
  mUnits, mStoreEans, mStoreContainers: TNxCustomBusinessMonikerCollection;
  mList, mMatList: TStringList;
  i, j: integer;
  mJSON, mJSON2, mJSON3, mResultJSON: TJSONSuperObject;
  mRollValueCode, mTableName, mMainSupplierFirmCode, mForeignName: string;
begin
  AResultStr:= '';
  mOS:= ABO.ObjectSpace;
  mList:= TStringList.Create;
  mMatList:= TStringList.Create;
  mJSON:= TJSONSuperObject.Create;
  try
    try
      //SEKCE ZÁKLADNÍCH DAT********************************************************************************
      mJSON.O['data'] := mJSON.CreateJSONArray;
      mJSON.A['data'].O[0]:= mJSON.CreateJSON;
      mJSON.A['data'].O[0].S['StoreCard_ID']:= ABO.OID;
      mJSON.A['data'].O[0].S['Code']:= ABO.GetFieldValueAsString('Code');
      mJSON.A['data'].O[0].S['Name']:= ABO.GetFieldValueAsString('Name');
      mJSON.A['data'].O[0].I['Category']:= ABO.GetFieldValueAsInteger('Category');
      mJSON.A['data'].O[0].I['LabelType']:= ABO.GetFieldValueAsInteger('X_label_type');
      mJSON.A['data'].O[0].S['ForeignName']:= ABO.GetFieldValueAsString('ForeignName');
      mJson.A['data'].O[0].S['NameSK']:= ABO.GetFieldValueAsString('X_Name_SK');
      mJson.A['data'].O[0].S['NameDE']:= ABO.GetFieldValueAsString('X_Name_DE');
      mJson.A['data'].O[0].S['NameAT']:= ABO.GetFieldValueAsString('X_Name_AT');
      mJson.A['data'].O[0].S['CountryCode']:= ABO.GetFieldValueAsString('Country_ID.Code');
      mJSON.A['data'].O[0].S['Specification']:= ABO.GetFieldValueAsString('Specification');
      mJSON.A['data'].O[0].S['Specification2']:= ABO.GetFieldValueAsString('Specification2');
      mJSON.A['data'].O[0].S['StoreMenuItemText']:= ABO.GetFieldValueAsString('StoreMenuItem_ID.Text');
      mJSON.A['data'].O[0].S['StoreMenuItemFullPath']:= ABO.GetFieldValueAsString('StoreMenuItem_ID.FullPath');
      mJSON.A['data'].O[0].S['IntrastatCommodityCode']:= ABO.GetFieldValueAsString('IntrastatCommodity_ID.Code');
      mJSON.A['data'].O[0].D['IntrastatWeight']:= ABO.GetFieldValueAsFloat('IntrastatWeight');
      mJSON.A['data'].O[0].I['IntrastatWeightUnit']:= ABO.GetFieldValueAsInteger('IntrastatWeightUnit');
      mJSON.A['data'].O[0].D['IntrastatUnitRate']:= ABO.GetFieldValueAsFloat('IntrastatUnitRate');
      mJSON.A['data'].O[0].B['IntrastatWeightIsOptional']:= ABO.GetFieldValueAsBoolean('IntrastatCommodity_ID.WeightIsOptional');
      mJSON.A['data'].O[0].D['IntrastatUnitRateRef']:= ABO.GetFieldValueAsFloat('IntrastatUnitRateRef');
      mJSON.A['data'].O[0].S['IntrastatDescription']:= ABO.GetFieldValueAsString('IntrastatCommodity_ID.Description');
      mJSON.A['data'].O[0].S['IntrastatUnitCode']:= ABO.GetFieldValueAsString('IntrastatCommodity_ID.UnitCode');
      mJSON.A['data'].O[0].D['IntrastatConstantWeight']:= ABO.GetFieldValueAsFloat('IntrastatCommodity_ID.ConstantWeight');
      mJSON.A['data'].O[0].S['EAN']:= ABO.GetFieldValueAsString('EAN');
      mJSON.A['data'].O[0].B['X_Matka']:= ABO.GetFieldValueAsBoolean('X_Matka');
      mJSON.A['data'].O[0].B['TypProduktuCode']:= ABO.GetFieldValueAsBoolean('X_Typ_produktu.Code');
      mJSON.A['data'].O[0].B['TypProduktuName']:= ABO.GetFieldValueAsBoolean('X_Typ_produktu.Name');
      mJSON.A['data'].O[0].B['DruhCode']:= ABO.GetFieldValueAsBoolean('U_druh_ID.Code');
      mJSON.A['data'].O[0].B['DruhName']:= ABO.GetFieldValueAsBoolean('U_druh_ID.Name');
      mJSON.A['data'].O[0].B['VelikostCode']:= ABO.GetFieldValueAsBoolean('U_velikost_ID.Code');
      mJSON.A['data'].O[0].B['VelikostName']:= ABO.GetFieldValueAsBoolean('U_velikost_ID.Name');
      mJSON.A['data'].O[0].B['BarvaCode']:= ABO.GetFieldValueAsBoolean('U_barva_ID.Code');
      mJSON.A['data'].O[0].B['BarvaName']:= ABO.GetFieldValueAsBoolean('U_barva_ID.Name');
      mJSON.A['data'].O[0].S['X_Parent_IDCode']:= ABO.GetFieldValueAsString('X_Parent_ID.Code');
      //KONEC ZÁKLADNÍCH DAT********************************************************************************


      //SEKCE JEDNOTEK********************************************************************************
      mUnits:=ABO.GetLoadedCollectionMonikerForFieldCode(ABO.GetFieldCode('StoreUnits'));
      mJSON.A['data'].O[0].O['StoreUnits'] := mJSON.CreateJSONArray;
      for i:=0 to mUnits.count-1 do begin
        mUnitBO:=mUnits.BusinessObject[i];
        mJSON2:= TJSONSuperObject.Create;
        try
          mJSON2.S['Code']:=mUnitBO.GetFieldValueAsString('Code');
          mJSON2.D['UnitRate']:=mUnitBO.GetFieldValueAsFloat('UnitRate');
          mJSON2.S['Description']:=mUnitBO.GetFieldValueAsString('Description');
          mJSON2.D['Weight']:=mUnitBO.GetFieldValueAsFloat('Weight');
          mJSON2.I['WeightUnit']:=mUnitBO.GetFieldValueAsInteger('WeightUnit');
          mJSON2.D['Capacity']:=mUnitBO.GetFieldValueAsFloat('Capacity');
          mJSON2.I['CapacityUnit']:=mUnitBO.GetFieldValueAsInteger('CapacityUnit');
          mJSON2.D['IndivisibleQuantity']:= mUnitBO.GetFieldValueAsFloat('IndivisibleQuantity');
          mJSON2.S['EAN']:= mUnitBO.GetFieldValueAsString('EAN');
          mStoreEans:=mUnitBO.GetLoadedCollectionMonikerForFieldCode(mUnitBO.GetFieldCode('StoreEans'));
          if mStoreEANS.count>0 then begin
            mJSON2.O['StoreEANs']:=mJSON2.CreateJSONArray;
            for j:=0 to mStoreEANS.count-1 do begin
              mEANBO:=mStoreEANS.BusinessObject[j];
              mJSON3:= TJSONSuperObject.create;
              try
                mJSON3.S['EAN']:=mEanBO.GetFieldValueAsString('EAN');
                mJSON2.A['StoreEANs'].add(mJSON3);
              finally
                mJSON3.Free;
              end;
            end;
          end;

          mStoreContainers:= mUnitBO.GetLoadedCollectionMonikerForFieldCode(mUnitBO.GetFieldCode('StoreContainers'));
          if mStoreContainers.Count > 0 then
          begin
            mJSON2.O['StoreContainers']:= mJSON2.CreateJSONArray;
            for j:= 0 to mStoreContainers.Count -1 do
            begin
              mContainerBO:= mStoreContainers.BusinessObject[j];
              mJSON3:= TJSONSuperObject.create;
              try
                mJSON3.S['StoreCardCode']:= mContainerBO.GetFieldValueAsString('StoreCard_ID.Code');
                mJSON3.S['StoreCardName']:= mContainerBO.GetFieldValueAsString('StoreCard_ID.Name');
                if (aIndex = 1) and not(NxIsBlank(mContainerBO.GetFieldValueAsString('StoreCard_ID.X_Name_DE'))) then
                  mJSON3.S['StoreCardName']:= mContainerBO.GetFieldValueAsString('StoreCard_ID.Name');
                if (aIndex = 2) and not(NxIsBlank(mContainerBO.GetFieldValueAsString('StoreCard_ID.X_Name_DE'))) then
                  mJSON3.S['StoreCardName']:= mContainerBO.GetFieldValueAsString('StoreCard_ID.Name');

                mJSON3.I['StoreCardCategory']:= mContainerBO.GetFieldValueAsInteger('StoreCard_ID.Category');
                mJSON3.S['StoreCardMainUnitCode']:= mContainerBO.GetFieldValueAsString('StoreCard_ID.MainUnitCode');
                mJSON3.S['StoreCardMainUnitRate']:= mContainerBO.GetFieldValueAsString('StoreCard_ID.MainUnitRate');
                mJSON3.S['StoreCardEAN']:= mContainerBO.GetFieldValueAsString('StoreCard_ID.EAN');
                mJSON3.D['StoreCardVATRate']:= mContainerBO.GetFieldValueAsFloat('StoreCard_ID.VATRate_ID.Tariff');
                mJSON3.I['StoreCardVATRateType']:= mContainerBO.GetFieldValueAsInteger('StoreCard_ID.VATRate_ID.VATRateType');
                mJSON3.S['StoreCardStoreCardCategoryCode']:= mContainerBO.GetFieldValueAsString('StoreCard_ID.StoreCardCategory_ID.Code');
                mJSON3.S['StoreAssortmentGroupCode']:= mContainerBO.GetFieldValueAsString('StoreCard_ID.StoreAssortmentGroup_ID.Code');
                mJSON3.S['StoreAssortmentGroupName']:= mContainerBO.GetFieldValueAsString('StoreCard_ID.StoreAssortmentGroup_ID.Name');

                mJSON3.S['QUnit']:= mContainerBO.GetFieldValueAsString('QUnit');
                mJSON3.D['UnitQuantity']:= mContainerBO.GetFieldValueAsFloat('UnitQuantity');
                mJSON3.D['UnitRate']:= mContainerBO.GetFieldValueAsFloat('UnitRate');

                if aIndex>0 then
                  mJSON3.S['StoreAssortmentGroupName']:= mContainerBO.GetFieldValueAsString('StoreCard_ID.StoreAssortmentGroup_ID.X_EN_Nazev');

                mJSON2.A['StoreContainers'].Add(mJSON3);
              finally
                mJSON3.Free;
              end;
            end;
          end;

          mJSON.A['data'].O[0].A['StoreUnits'].Add(mJSON2);
        finally
          mJSON2.Free;
        end;
      end;
      //KONEC JEDNOTEK********************************************************************************

      //VLASTNOSTI SKLADOVÝCH KARET********************************************************************************
      mMainSupplierFirmCode:= mOS.SQLSelectFirstAsString(
        ' SELECT FI.Code FROM Suppliers SU '+
        ' JOIN Firms FI ON Fi.ID = SU.Firm_ID '+
        ' WHERE SU.ID ='+QuotedStr(ABO.GetFieldValueAsString('MainSupplier_ID')));

      mJSON.A['data'].O[0].B['X_Aktivni']:= ABO.GetFieldValueAsBoolean('X_Aktivni');
      mJSON.A['data'].O[0].B['IsProduct']:= ABO.GetFieldValueAsBoolean('IsProduct');
      mJSON.A['data'].O[0].B['IsScalable']:= ABO.GetFieldValueAsBoolean('IsScalable');
      mJSON.A['data'].O[0].S['MainSupplierCode']:= mMainSupplierFirmCode;
      mJSON.A['data'].O[0].S['MainUnitCode']:= ABO.GetFieldValueAsString('MainUnitCode');
      mJSON.A['data'].O[0].B['NonStockType']:= ABO.GetFieldValueAsBoolean('NonStockType');
      mJSON.A['data'].O[0].S['Note']:= ABO.GetFieldValueAsString('Note');
      mJSON.A['data'].O[0].I['OutOfStockBatchDelivery']:= ABO.GetFieldValueAsInteger('OutOfStockBatchDelivery');
      mJSON.A['data'].O[0].I['OutOfStockDelivery']:= ABO.GetFieldValueAsInteger('OutOfStockDelivery');
      mJSON.A['data'].O[0].S['QuantityDiscountCode']:= ABO.GetFieldValueAsString('QuantityDiscount_ID.Code');
      mJSON.A['data'].O[0].S['StoreAssortmentGroupCode']:= ABO.GetFieldValueAsString('StoreAssortmentGroup_ID.Code');
      mJSON.A['data'].O[0].S['StoreAssortmentGroupName']:= ABO.GetFieldValueAsString('StoreAssortmentGroup_ID.Name');
      if aIndex>0 then
       mJSON.A['data'].O[0].S['StoreAssortmentGroupName']:= ABO.GetFieldValueAsString('StoreAssortmentGroup_ID.X_EN_Nazev');
      mJSON.A['data'].O[0].S['StoreCardCategoryCode']:= ABO.GetFieldValueAsString('StoreCardCategory_ID.Code');
      mJSON.A['data'].O[0].B['UseOutOfStockBatchDelivery']:= ABO.GetFieldValueAsBoolean('UseOutOfStockBatchDelivery');
      mJSON.A['data'].O[0].B['UseOutOfStockDelivery']:= ABO.GetFieldValueAsBoolean('UseOutOfStockDelivery');
      //KONEC VLASTNOSTÍ********************************************************************************


      //ZÍSKÁNÍ SEZNAMU PARAMETRŮ ZE SKLADOVÉ KARTY
      mOS.SQLSelect('SELECT ID FROM DefRollData WHERE CLSID = ''2TIIQXNXIXK4B5CZUIZ20K2W10'' AND X_Rel_Def = ''10'' AND X_Value_ID = '+QuotedStr(ABO.OID), mList);

      //PŘIDÁNÍ SEKCE S PARAMETRY ********************************************************************************
      mJSON.A['data'].O[0].O['Parameters']:= mJSON.CreateJSON;
      mJSON.A['data'].O[0].O['Parameters']:= mJSON.CreateJSONArray;
      for i:= 0 to mList.Count -1 do begin
        mPARBO:= mOS.CreateObject(Class_BO_Relations);
        mParSourceBO:= mOS.CreateObject(Class_BOSCParameters);
        try
          mPARBO.Load(mList[i], nil);
          mParSourceBO.Load(mPARBO.GetFieldValueAsString('X_Parameter_ID'), nil);
          mRollValueCode:= mOS.SQLSelectFirstAsString(
            ' SELECT Code FROM DefRollData '+
            ' WHERE CLSID='+QuotedStr(mPARBO.GetFieldValueAsString('X_BOCLSID'))+
            ' AND ID='+QuotedStr(mPARBO.GetFieldValueAsString('X_RollValueID')));

          mTableName:= '';
          if mPARBO.GetFieldValueAsString('X_BOCLSID') <> '' then begin
            mTempBO:= mOS.CreateObject(mPARBO.GetFieldValueAsString('X_BOCLSID'));
            try
              mTableName:= NxGetTableNameForPersistCLSID(mTempBO.PersistCLSID);
            finally
              mTempBO.Free;
            end;
          end;

          mJSON.A['data'].O[0].O['Parameters'].AsArray.O[i]:= mJSON.CreateJSON;
          mJSON.A['data'].O[0].A['Parameters'].O[i].S['Parameter_ID']:= mPARBO.OID;
          mJSON.A['data'].O[0].O['Parameters'].AsArray.O[i].S['ParameterCode']:= mParSourceBO.GetFieldValueAsString('Code');
          mJSON.A['data'].O[0].O['Parameters'].AsArray.O[i].S['ParameterName']:= mParSourceBO.GetFieldValueAsString('Name');
          if (aIndex=1) and not(NxIsBlank(mParSourceBO.GetFieldValueAsString('X_DE_Nazev'))) then
            mJSON.A['data'].O[0].O['Parameters'].AsArray.O[i].S['ParameterName']:= mParSourceBO.GetFieldValueAsString('X_DE_nazev');
          if (aIndex=2) and not(NxIsBlank(mParSourceBO.GetFieldValueAsString('X_DE_Nazev'))) then
            mJSON.A['data'].O[0].O['Parameters'].AsArray.O[i].S['ParameterName']:= mParSourceBO.GetFieldValueAsString('X_DE_nazev');
          mJSON.A['data'].O[0].O['Parameters'].AsArray.O[i].I['X_TypeOfValue']:= mParSourceBO.GetFieldValueAsInteger('X_TypeOfValue');
          mJSON.A['data'].O[0].O['Parameters'].AsArray.O[i].S['X_RollCLSID']:= mParSourceBO.GetFieldValueAsString('X_RollCLSID');

          mJSON.A['data'].O[0].O['Parameters'].AsArray.O[i].S['X_ParamValue']:= mPARBO.GetFieldValueAsString('X_ParamValue');
          mJSON.A['data'].O[0].O['Parameters'].AsArray.O[i].S['X_BOCLSID']:= mPARBO.GetFieldValueAsString('X_BOCLSID');
          mJSON.A['data'].O[0].O['Parameters'].AsArray.O[i].S['X_RollValueID']:= mPARBO.GetFieldValueAsString('X_RollValueID');
          mJSON.A['data'].O[0].O['Parameters'].AsArray.O[i].S['TableName']:= mTableName;
          mJSON.A['data'].O[0].O['Parameters'].AsArray.O[i].S['RollValueCode']:= mRollValueCode;
          mJSON.A['data'].O[0].O['Parameters'].AsArray.O[i].S['X_RollValueName']:= mPARBO.GetFieldValueAsString('X_RollValueName');
          if (aIndex=1) or (aIndex=2) then begin
            mForeignName:=mOS.SQLSelectFirstAsString(' SELECT X_DE_Nazev FROM DefRollData '+
                                                     ' WHERE CLSID='+QuotedStr(mPARBO.GetFieldValueAsString('X_BOCLSID'))+
                                                     ' AND ID='+QuotedStr(mPARBO.GetFieldValueAsString('X_RollValueID')),'');
            if not(NxIsBlank(mForeignName)) then
                mJSON.A['data'].O[0].O['Parameters'].AsArray.O[i].S['X_RollValueName']:=mForeignName;

          end;
          mJSON.A['data'].O[0].O['Parameters'].AsArray.O[i].D['X_NumericValue']:= mPARBO.GetFieldValueAsFloat('X_NumericValue');
          mJSON.A['data'].O[0].O['Parameters'].AsArray.O[i].B['X_BooleanValue']:= mPARBO.GetFieldValueAsBoolean('X_BooleanValue');
          mJSON.A['data'].O[0].O['Parameters'].AsArray.O[i].B['X_Variantni_polozka']:= mPARBO.GetFieldValueAsBoolean('X_Variantni_polozka');
        finally
          mPARBO.Free;
          mParSourceBO.Free;
        end;
      end;
      //SEKCE PARAMETRY****************************************************************

      //ZÍSKÁNÍ SEZNAMU MATERIÁLŮ********************************************************
      mOS.SQLSelect('SELECT ID FROM DefRollData WHERE CLSID = ''2TIIQXNXIXK4B5CZUIZ20K2W10'' AND X_Rel_Def = ''06'' AND X_Value_ID = '+QuotedStr(ABO.OID), mMatList);

      //PŘIDÁNÍ SEKCE S MATERIÁLY ********************************************************************************
      mJSON.A['data'].O[0].O['Materials']:= mJSON.CreateJSON;
      mJSON.A['data'].O[0].O['Materials']:= mJSON.CreateJSONArray;
      for i:= 0 to mMatList.Count -1 do begin
        mPARBO:= mOS.CreateObject(Class_BO_Relations);
        mParSourceBO:= mOS.CreateObject(Class_BO_ND_Materials);
        try
          mPARBO.Load(mMatList[i], nil);
          mParSourceBO.Load(mPARBO.GetFieldValueAsString('X_Material_ID'), nil);
          mJSON.A['data'].O[0].O['Materials'].AsArray.O[i]:= mJSON.CreateJSON;
          mJSON.A['data'].O[0].A['Materials'].O[i].S['Material_ID']:= mPARBO.OID;
          mJSON.A['data'].O[0].O['Materials'].AsArray.O[i].S['MaterialCode']:= mParSourceBO.GetFieldValueAsString('Code');
          mJSON.A['data'].O[0].O['Materials'].AsArray.O[i].S['MaterialName']:= mParSourceBO.GetFieldValueAsString('Name');
          if (aIndex=1) and not(NxIsBlank(mParSourceBO.GetFieldValueAsString('X_DE_Nazev'))) then
           mJSON.A['data'].O[0].O['Materials'].AsArray.O[i].S['MaterialName']:= mParSourceBO.GetFieldValueAsString('X_DE_Nazev');
          if (aIndex=2) and not(NxIsBlank(mParSourceBO.GetFieldValueAsString('X_DE_Nazev'))) then
           mJSON.A['data'].O[0].O['Materials'].AsArray.O[i].S['MaterialName']:= mParSourceBO.GetFieldValueAsString('X_DE_Nazev');
          mJSON.A['data'].O[0].O['Materials'].AsArray.O[i].D['X_NumericValue']:= mPARBO.GetFieldValueAsFloat('X_NumericValue');
        finally
          mPARBO.Free;
          mParSourceBO.Free;
        end;
      end;
      //SEKCE MATERIÁLY ****************************************************************

      //LOG*****************************************************************************
      //try
        //mJSON.SaveToFile('\\CZVS0006\logy\_JSON\'+mBO.OID+'.json', true, true);
        //if NxGetActualUserID(mOS) = '4PX1000101' then
          //NxShowEditorSite(NxCreateContext(mOS), mJSON.AsString, true);
      //except
      //end;

      //LOG*****************************************************************************

      mResultJSON:= TJSONSuperObject.Create;
      mResultJSON:= API_POST(mJSON, 'StoreCards',True,aIndex);
      aResult_ID:=mResultJSON.S['ID'];
      if NxGetActualUserID(mOS) = '4PX1000101' then      //uživatel ALEC
          NxShowEditorSite(NxCreateContext(mOS), mResultJSON.AsString, true);
      //if aIndex=2 then
      // NxShowEditorSite(NxCreateContext(mOS), mJSON.AsString +nxCrLf+ mResultJSON.AsString, True);
      if NxIsEmptyOID(mResultJSON.S['ID']) then begin
        //ABO.SetFieldValueAsDateTime('X_SynchronizationDate$Date',0);
        AResultStr:= AResultStr + nxCrLf + ABO.GetFieldValueAsString('Code') + ' kartu se nepodařilo synchronizovat.';
      end;
    except
      AResultStr:= AResultStr + nxCrLf + 'Při získávání dat ze sklad. karty: '+ABO.DisplayName+ 'nastala chyba: '+ExceptionMessage;
    end;
  finally
    mBO.Free;
    mList.Free;
    mMatList.Free;
    mJSON.Free;
  end;
end;


procedure CreateObjectJSON(Sender: TComponent);
var
  mSite: TSiteForm;
  mOS: TNxCustomObjectSpace;
  mBO, mRow: TNxCustomBusinessObject;
  mRows: TNxCustomBusinessMonikerCollection;
  mList, mSingleList: TStringList;
  mJSON, mJSON1, mResultJSON: TJSONSuperObject;
  mCLSID, mFinalMsg, mErrors: string;
  i, mCounter: integer;
begin
  mCounter:= 0;
  mErrors:= '';
  mFinalMsg:='';
  mSite:= Sender.Site;
  mOS:= mSite.BaseObjectSpace;
  mList:= TStringList.Create;

  mCLSID:= mSite.GetFakeBusinessObject.CLSID;
  try
    mSite.FillListWithSelectedRows(mList);
    WaitWin.StartProgress('Čekejte, prosím ...', '', mList.Count);
    for i:= 0 to mList.Count -1 do begin
      mSingleList:= TStringList.Create;
      try
        mSingleList.Add(mList[i]);
        case mCLSID of
          Class_PLMWorkPlace: mJSON:= CreatePLMWorkPlaceJSON(mOS, mSingleList);
          Class_PLMPieceList: mJSON:= CreatePLMPieceListsJSON(mOS, mSingleList);
          Class_PLMRoutine:   mJSON:= CreatePLMRoutinesJSON(mOS, mSingleList);
        end;
        //mJSON.SaveToFile('C:\Users\acoufal\Desktop\ABRA temp\JSON\JSONObject.json');
        mResultJSON:= API_POST(mJSON,NxGetTableNameForPersistCLSID(mSite.GetFakeBusinessObject.PersistCLSID));
        //NxShowSimpleMessage(mResultJSON.AsString, mSite);
        if NxIsEmptyOID(mResultJSON.A['result'].O[0].S['ID']) then begin
          mErrors:= mErrors + nxCrLf + mResultJSON.A['result'].O[0].S['error'];
        end else begin
          mCounter:= mCounter +1;
        end;
        WaitWin.ChangeText(IntToStr(1+i) + ' / ' + IntToStr(mList.Count));
        WaitWin.StepIt;
        mSingleList.Clear;
      finally
        mSingleList.Free;
      end;
    end;

    NxShowSimpleMessage('Synchronizace proběhla u '+IntToStr(mCounter)+ ' z '+IntToStr(mList.Count)+' položek. Pokud došlo k chybám budou nyní zobrazeny.', mSite);
    if not(NxIsBlank(mErrors)) then NxShowEditorSite(mSite.SiteContext, mErrors, false);

  finally
    WaitWin.Stop;
    mList.Free;
  end;
end;


function CreatePLMWorkPlaceJSON(AOS: TNxCustomObjectSpace; var AList: TStringList): TJSONSuperObject;
var
  mBO: TNxCustomBusinessObject;
  mJSON: TJSONSuperObject;
  i: Integer;
begin
  mJSON:= TJSONSuperObject.Create;
  mJSON.O['items'] := mJSON.CreateJSONArray;
  for i:=0 to AList.Count -1 do begin
    mBO:= AOS.CreateObject(Class_PLMWorkPlace);
    mJSON.A['items'].O[i]:= mJSON.CreateJSON;
    try
      mBO.Load(AList[i], nil);
      mJSON.A['items'].O[i].S['Code']:= mBO.GetFieldValueAsString('Code');
      mJSON.A['items'].O[i].S['Name']:= mBO.GetFieldValueAsString('Name');
      mJSON.A['items'].O[i].S['X_SN']:= mBO.GetFieldValueAsString('X_SN');
      mJSON.A['items'].O[i].S['X_ParentCode']:= mBO.GetFieldValueAsString('X_Parent_ID.Code');
      mJSON.A['items'].O[i].S['X_SupplierCode']:= mBO.GetFieldValueAsString('X_Supplier_ID.Code');
      mJSON.A['items'].O[i].S['DivisionCode']:= mBO.GetFieldValueAsString('Division_ID.Code');
      mJSON.A['items'].O[i].D['HourlyRate'] := mBO.GetFieldValueAsDateTime('HourlyRate');
      mJSON.A['items'].O[i].D['X_AquisitionDate'] := mBO.GetFieldValueAsDateTime('X_AquisitionDate');
      mJSON.A['items'].O[i].D['X_CommisionDate'] := mBO.GetFieldValueAsDateTime('X_CommisionDate');

    finally
      mBO.Free;
    end;
  end;
  Result:= mJSON;
end;

function CreatePLMPieceListsJSON(AOS:TNxCustomObjectSpace; var AList: TStringList):TJSONSuperObject;
var
  mBO: TNxCustomBusinessObject;
  mRows: TNxCustomBusinessMonikerCollection;
  mJSON: TJSONSuperObject;
  i, j: Integer;
begin
  mJSON:= TJSONSuperObject.Create;
  mJSON.O['items'] := mJSON.CreateJSONArray;
  for i:=0 to AList.Count -1 do begin
    mBO:= AOS.CreateObject(Class_PLMPieceList);
    mJSON.A['items'].O[i]:= mJSON.CreateJSON;
    try
      mBO.Load(AList[i], nil);
      mJSON.A['items'].O[i].S['Name']:= mBO.GetFieldValueAsString('Name');
      mJSON.A['items'].O[i].S['StoreCardCode']:= mBO.GetFieldValueAsString('StoreCard_ID.Code');
      mJSON.A['items'].O[i].I['PieceListType']:= mBO.GetFieldValueAsInteger('PieceListType');
      mJSON.A['items'].O[i].D['Quantity']:= mBO.GetFieldValueAsFloat('Quantity');
      mJSON.A['items'].O[i].S['Qunit']:= mBO.GetFieldValueAsString('Qunit');
      mJSON.A['items'].O[i].S['BusProjectCode']:= mBO.GetFieldValueAsString('BusProject_ID.Code');
      mJSON.A['items'].O[i].S['BusOrderCode']:= mBO.GetFieldValueAsString('BusOrder_ID.Code');
      mJSON.A['items'].O[i].S['BusTransactionCode']:= mBO.GetFieldValueAsString('BusTransaction_ID.Code');
      mJSON.A['items'].O[i].S['Note']:= mBO.GetFieldValueAsString('Note');
      mRows:= mBO.GetLoadedCollectionMonikerForFieldCode(mBO.GetFieldCode('Rows'));
      mJSON.A['items'].O[i].O['rows']:= mJSON.CreateJSONArray;
      for j:= 0 to mRows.Count -1 do begin
        mJSON.A['items'].O[i].A['rows'].O[j]:= mJSON.CreateJSON;
        mJSON.A['items'].O[i].A['rows'].O[j].S['StoreCardCode']:= mRows.BusinessObject[j].GetFieldValueAsString('StoreCard_ID.Code');
        mJSON.A['items'].O[i].A['rows'].O[j].I['PosIndex']:= mRows.BusinessObject[j].GetFieldValueAsInteger('PosIndex');
        mJSON.A['items'].O[i].A['rows'].O[j].D['Quantity']:= mRows.BusinessObject[j].GetFieldValueAsFloat('Quantity');
        mJSON.A['items'].O[i].A['rows'].O[j].S['Qunit']:= mRows.BusinessObject[j].GetFieldValueAsString('Qunit');
        mJSON.A['items'].O[i].A['rows'].O[j].I['Issue']:= mRows.BusinessObject[j].GetFieldValueAsInteger('Issue');
        mJSON.A['items'].O[i].A['rows'].O[j].B['AllowMix']:= mRows.BusinessObject[j].GetFieldValueAsBoolean('AllowMix');
        mJSON.A['items'].O[i].A['rows'].O[j].B['Replaceable']:= mRows.BusinessObject[j].GetFieldValueAsBoolean('Replaceable');
        mJSON.A['items'].O[i].A['rows'].O[j].B['RecordsSN']:= mRows.BusinessObject[j].GetFieldValueAsBoolean('RecordsSN');
        mJSON.A['items'].O[i].A['rows'].O[j].B['DoNotMultiply']:= mRows.BusinessObject[j].GetFieldValueAsBoolean('DoNotMultiply');
        mJSON.A['items'].O[i].A['rows'].O[j].S['PhaseCode']:= mRows.BusinessObject[j].GetFieldValueAsString('Phase_ID.Code');
        mJSON.A['items'].O[i].A['rows'].O[j].S['Description']:= mRows.BusinessObject[j].GetFieldValueAsString('Description');
        mJSON.A['items'].O[i].A['rows'].O[j].S['Note']:= mRows.BusinessObject[j].GetFieldValueAsString('Note');
        mJSON.A['items'].O[i].A['rows'].O[j].S['SupposedStoreCode']:= mRows.BusinessObject[j].GetFieldValueAsString('SupposedStore_ID.Code');
        mJSON.A['items'].O[i].A['rows'].O[j].I['CostingMethod']:= mRows.BusinessObject[j].GetFieldValueAsInteger('CostingMethod');
        mJSON.A['items'].O[i].A['rows'].O[j].D['WastePercentage']:= mRows.BusinessObject[j].GetFieldValueAsFloat('WastePercentage');
      end;
    finally
      mBO.Free;
    end;
  end;
  Result:= mJSON;
end;


function CreatePLMRoutinesJSON(AOS:TNxCustomObjectSpace; var AList: TStringList):TJSONSuperObject;
var
  mBO: TNxCustomBusinessObject;
  mRows, mMaterials, mPlmPictires: TNxCustomBusinessMonikerCollection;
  mJSON: TJSONSuperObject;
  i, j, k, p: Integer;
begin
  mJSON:= TJSONSuperObject.Create;
  mJSON.O['items'] := mJSON.CreateJSONArray;
  for i:=0 to AList.Count -1 do begin
    mBO:= AOS.CreateObject(Class_PLMRoutine);
    mJSON.A['items'].O[i]:= mJSON.CreateJSON;
    try
      mBO.Load(AList[i], nil);
      mJSON.A['items'].O[i].S['Name']:= mBO.GetFieldValueAsString('Name');
      mJSON.A['items'].O[i].S['StoreCardCode']:= mBO.GetFieldValueAsString('StoreCard_ID.Code');
      mJSON.A['items'].O[i].S['RoutineTypeCode']:= mBO.GetFieldValueAsString('RoutineType_ID.Code');
      mJSON.A['items'].O[i].D['Quantity']:= mBO.GetFieldValueAsFloat('Quantity');
      mJSON.A['items'].O[i].S['Qunit']:= mBO.GetFieldValueAsString('Qunit');
      mJSON.A['items'].O[i].S['BusProjectCode']:= mBO.GetFieldValueAsString('BusProject_ID.Code');
      mJSON.A['items'].O[i].S['BusOrderCode']:= mBO.GetFieldValueAsString('BusOrder_ID.Code');
      mJSON.A['items'].O[i].S['BusTransactionCode']:= mBO.GetFieldValueAsString('BusTransaction_ID.Code');
      mJSON.A['items'].O[i].S['Note']:= mBO.GetFieldValueAsString('Note');
      mRows:= mBO.GetLoadedCollectionMonikerForFieldCode(mBO.GetFieldCode('Rows'));
      mJSON.A['items'].O[i].O['rows']:= mJSON.CreateJSONArray;
      for j:= 0 to mRows.Count -1 do begin
        mJSON.A['items'].O[i].A['rows'].O[j]:= mJSON.CreateJSON;
        mJSON.A['items'].O[i].A['rows'].O[j].I['PosIndex']:= mRows.BusinessObject[j].GetFieldValueAsInteger('PosIndex');
        mJSON.A['items'].O[i].A['rows'].O[j].S['PhaseCode']:= mRows.BusinessObject[j].GetFieldValueAsString('Phase_ID.Code');
        mJSON.A['items'].O[i].A['rows'].O[j].S['Title']:= mRows.BusinessObject[j].GetFieldValueAsString('Title');
        mJSON.A['items'].O[i].A['rows'].O[j].D['TAC']:= mRows.BusinessObject[j].GetFieldValueAsFloat('TAC');
        mJSON.A['items'].O[i].A['rows'].O[j].D['TBC']:= mRows.BusinessObject[j].GetFieldValueAsFloat('TBC');
        mJSON.A['items'].O[i].A['rows'].O[j].B['Cooperation']:= mRows.BusinessObject[j].GetFieldValueAsBoolean('Cooperation');
        mJSON.A['items'].O[i].A['rows'].O[j].B['Finished']:= mRows.BusinessObject[j].GetFieldValueAsBoolean('Finished');
        mJSON.A['items'].O[i].A['rows'].O[j].B['Batch']:= mRows.BusinessObject[j].GetFieldValueAsBoolean('Batch');
        mJSON.A['items'].O[i].A['rows'].O[j].D['AdvanceQuantity']:= mRows.BusinessObject[j].GetFieldValueAsFloat('AdvanceQuantity');
        mJSON.A['items'].O[i].A['rows'].O[j].B['Ongoing']:= mRows.BusinessObject[j].GetFieldValueAsBoolean('Ongoing');
        mJSON.A['items'].O[i].A['rows'].O[j].B['Planned']:= mRows.BusinessObject[j].GetFieldValueAsBoolean('Planned');
        mJSON.A['items'].O[i].A['rows'].O[j].I['CompulsoryOperation']:= mRows.BusinessObject[j].GetFieldValueAsInteger('CompulsoryOperation');
        mJSON.A['items'].O[i].A['rows'].O[j].S['SalaryClassCode']:= mRows.BusinessObject[j].GetFieldValueAsString('SalaryClass_ID.Code');
        mJSON.A['items'].O[i].A['rows'].O[j].S['WorkPlaceCode']:= mRows.BusinessObject[j].GetFieldValueAsString('WorkPlace_ID.Code');
        mJSON.A['items'].O[i].A['rows'].O[j].I['CRPGrain']:= mRows.BusinessObject[j].GetFieldValueAsInteger('CRPGrain');
        mJSON.A['items'].O[i].A['rows'].O[j].I['LabelType']:= mRows.BusinessObject[j].GetFieldValueAsInteger('X_label_type');
        mJSON.A['items'].O[i].A['rows'].O[j].B['Suspend']:= mRows.BusinessObject[j].GetFieldValueAsBoolean('Suspend');
        mJSON.A['items'].O[i].A['rows'].O[j].S['Note']:= mRows.BusinessObject[j].GetFieldValueAsString('Note');
        mMaterials:= mRows.BusinessObject[j].GetLoadedCollectionMonikerForFieldCode(mRows.BusinessObject[j].GetFieldCode('Materials'));
        mJSON.A['items'].O[i].A['rows'].O[j].O['materials']:= mJSON.CreateJSONArray;
        for k:= 0 to mMaterials.Count -1 do begin
          mJSON.A['items'].O[i].A['rows'].O[j].A['materials'].O[k]:= mJSON.CreateJSON;
          mJSON.A['items'].O[i].A['rows'].O[j].A['materials'].O[k].I['PosIndex']:= mMaterials.BusinessObject[k].GetFieldValueAsInteger('PosIndex');
          mJSON.A['items'].O[i].A['rows'].O[j].A['materials'].O[k].S['StoreCardCode']:= mMaterials.BusinessObject[k].GetFieldValueAsString('StoreCard_ID.Code');
          mJSON.A['items'].O[i].A['rows'].O[j].A['materials'].O[k].B['AllQuantity']:= mMaterials.BusinessObject[k].GetFieldValueAsBoolean('AllQuantity');
          mJSON.A['items'].O[i].A['rows'].O[j].A['materials'].O[k].B['DoNotMultiply']:= mMaterials.BusinessObject[k].GetFieldValueAsBoolean('DoNotMultiply');
          mJSON.A['items'].O[i].A['rows'].O[j].A['materials'].O[k].D['UnitQuantity']:= mMaterials.BusinessObject[k].GetFieldValueAsFloat('UnitQuantity');
          mJSON.A['items'].O[i].A['rows'].O[j].A['materials'].O[k].S['QUnit']:= mMaterials.BusinessObject[k].GetFieldValueAsString('QUnit');
        end;
        mPlmPictires:= mRows.BusinessObject[j].GetLoadedCollectionMonikerForFieldCode(mRows.BusinessObject[j].GetFieldCode('Rows'));
        mJSON.A['items'].O[i].A['rows'].O[j].O['plmPictures']:= mJSON.CreateJSONArray;
        for p:= 0 to mPlmPictires.Count -1 do begin
          mJSON.A['items'].O[i].A['rows'].O[j].A['plmPictures'].O[p]:= mJSON.CreateJSON;
          mJSON.A['items'].O[i].A['rows'].O[j].A['plmPictures'].O[p].S['Picture_ID']:= mPlmPictires.BusinessObject[p].GetFieldValueAsString('PLMPicture_ID.Picture_ID');
          mJSON.A['items'].O[i].A['rows'].O[j].A['plmPictures'].O[p].S['Name']:= mPlmPictires.BusinessObject[p].GetFieldValueAsString('PLMPicture_ID.Name');
        end;
      end;
      //LOG*****************************************************************************
      try
        mJSON.SaveToFile('\\CZVS0006\logy\_JSON\CreatePLMRoutinesJSON_'+mBO.OID+'.json', true, true);
      except
      end;
      //LOG*****************************************************************************
    finally
      mBO.Free;
    end;
  end;
  Result:= mJSON;
end;


procedure PLMWorkPlaceAPISync(ABO: TNxCustomBusinessObject; var AResultStr: string;);
var
  mOS: TNxCustomObjectSpace;
  mJSON: TJSONSuperObject;
  mParentBO: TNxCustomBusinessObject;
begin
  mOS:= ABO.ObjectSpace;
  if ABO.GetFieldValueAsString('Division_ID') = '5O10000101' then begin
    mJSON:=TJSONSuperObject.Create;
    try
      mJSON.S['Code']:= ABO.GetFieldValueAsString('Code');
      mJSON.S['Name']:= ABO.GetFieldValueAsString('Name');
      mJSON.D['HourlyRate']:= ABO.GetFieldValueAsFloat('HourlyRate');
      mJSON.S['DivisionCode']:= ABO.GetFieldValueAsString('Division_ID.Code');    //??
      mJSON.S['X_SN']:= ABO.GetFieldValueAsString('X_SN');
      mJSON.I['X_Specification']:= ABO.GetFieldValueAsInteger('X_Specification');
      mJSON.D['X_AquisitionDate']:= ABO.GetFieldValueAsDateTime('X_AquisitionDate');
      mJSON.D['X_CommisionDate']:= ABO.GetFieldValueAsDateTime('X_CommisionDate');
      mJSON.S['SupplierCode']:= ABO.GetFieldValueAsString('X_Supplier_ID.Code');
      mJSON.B['X_Active']:= ABO.GetFieldValueAsBoolean('X_Active');
      if not(NxIsEmptyOID(ABO.GetFieldValueAsString('X_Parent_ID'))) then begin
        mParentBO:= mOS.CreateObject(Class_PLMWorkPlace);
        try
          mParentBO.Load(ABO.GetFieldValueAsString('X_Parent_ID'), nil);
          mJSON.S['Parent_Code']:= mParentBO.GetFieldValueAsString('Code');
          mJSON.S['Parent_Name']:= mParentBO.GetFieldValueAsString('Name');
          mJSON.D['Parent_HourlyRate']:= mParentBO.GetFieldValueAsFloat('HourlyRate');
          mJSON.S['Parent_DivisionCode']:= mParentBO.GetFieldValueAsString('Division_ID.Code');    //??
          mJSON.S['Parent_X_SN']:= mParentBO.GetFieldValueAsString('X_SN');
          mJSON.I['Parent_X_Specification']:= mParentBO.GetFieldValueAsInteger('X_Specification');
          mJSON.D['Parent_X_AquisitionDate']:= mParentBO.GetFieldValueAsDateTime('X_AquisitionDate');
          mJSON.D['Parent_X_CommisionDate']:= mParentBO.GetFieldValueAsDateTime('X_CommisionDate');
          mJSON.S['Parent_SupplierCode']:= mParentBO.GetFieldValueAsString('X_Supplier_ID.Code');
          mJSON.B['Parent_X_Active']:= mParentBO.GetFieldValueAsBoolean('X_Active');
        finally
          mParentBO.Free;
        end;
      end;
      NxShowEditorSite(NxCreateContext(mOS), mJSON.AsString, true);
      {
      mResultJSON:= API_POST(mJSON,NxGetTableNameForPersistCLSID(ABO.PersistCLSID), true);
      if NxIsEmptyOID(mResultJSON.S['ID']) then begin
        ABO.SetFieldValueAsDateTime('X_SynchronizationDate$Date',0);
        AResultStr:= AResultStr + nxCrLf + ABO.GetFieldValueAsString('Code') + ' kartu se nepodařilo synchronizovat.';
      end else begin
        ABO.SetFieldValueAsDateTime('X_SynchronizationDate$Date',Now);
      end;
      }
    finally
      mJSON.Free;
    end;
  end;
end;



function VerifyAndGetValue(var ABO: TNxCustomBusinessObject; AField: string;):string;
var
  mRecord_ID, mFieldValue_ID: string;
begin
  mFieldValue_ID:= ABO.GetFieldValueAsString(AField);
  mRecord_ID:= ABO.ObjectSpace.SQLSelectFirstAsString('SELECT ID FROM DefRollData WHERE ID ='+QuotedStr(mFieldValue_ID));
  if NxIsEmptyOID(mRecord_ID) then begin
    Result:= '';
    ABO.SetFieldValueAsString(AField, '');
  end else begin
    Result:= ABO.GetFieldValueAsString(AField+'.Code');
  end;
end;



function ValueDialog(aSite:TSiteForm;var aList:TStringList;var aValue, aName:string;) : boolean;
var
  mForm : TForm;
  mBtn : TButton;
  mLbl : TLabel;
  mValueCB:TComboBox;
begin
  Result := False;
  mForm := TForm.Create(Application.MainForm);
  mForm.BorderIcons := [biSystemMenu];
  mForm.Left := 30;
  mForm.Top := 50;
  mForm.Width := 330;  // sirka
  mForm.Height := 100; // vyska
  mForm.Caption := 'Vyberte '+aName;
  mForm.OnCloseQuery:= @OnFormCloseAction;

  mLbl := TLabel.Create(mForm);
  mLbl.Caption := 'Hodnota';
  mLbl.Left := 10;
  mLbl.Top := 10;
  mLbl.Name := 'lblQuantity';
  mForm.InsertControl(mLbl);

  mValueCB:= TComboBox.Create(mForm);
  mValueCB.Parent:=mForm;
  mValueCB.Left := 60;
  mValueCB.Top := 8;
  mValueCB.Width := 240;
  mValueCB.Items:=aList;
  mValueCB.ItemIndex:=0;

  mBtn := TButton.Create(mForm);
  mBtn.Width := 75;
  mBtn.Height := 25;
  mBtn.Caption := 'OK';
  mBtn.ModalResult := mrOk;
  mBtn.Cancel := False;
  mBtn.Default := True;
  mBtn.Left :=  mForm.Width - 2*(mBtn.Width+2) - 20;
  mBtn.Top := mForm.Height - mBtn.Height - 40;
  mBtn.Name := 'btnOK';
  mForm.InsertControl(mBtn);

  mBtn := TButton.Create(mForm);
  mBtn.Width := 75;
  mBtn.Height := 25;
  mBtn.Caption := 'Storno';
  mBtn.ModalResult := mrCancel;
  mBtn.Cancel := True;
  mBtn.Left := mForm.Width - (mBtn.Width+2) - 20;;
  mBtn.Top := mForm.Height - mBtn.Height - 40;
  mBtn.Name := 'btnCancel';
  mForm.InsertControl(mBtn);

  Result := mForm.ShowModal(Asite)= mrOK;
  if Result then begin
    aValue:=mValueCB.Text;
  end;
end;

function GetCountryIndex(aSite:TSiteForm;var aCountryIndex:Integer) : boolean;
var
  mForm : TForm;
  mBtn : TButton;
  mLbl : TLabel;
  mValueCB:TComboBox;
  mList : TStringList;
begin
  Result := False;
  mForm := TForm.Create(Application.MainForm);
  mForm.BorderIcons := [biSystemMenu];
  mForm.Left := 30;
  mForm.Top := 50;
  mForm.Width := 330;  // sirka
  mForm.Height := 100; // vyska
  mForm.Caption := 'Vyberte zemi';
  mForm.OnCloseQuery:= @OnFormCloseAction;

  mList:=TStringList.Create;
  mList.Add('Slovensko');
  mList.Add('Německo');
  mlist.Add('Rakousko');

  mLbl := TLabel.Create(mForm);
  mLbl.Caption := 'Země';
  mLbl.Left := 10;
  mLbl.Top := 10;
  mLbl.Name := 'lblCountryIndex';
  mForm.InsertControl(mLbl);

  mValueCB:= TComboBox.Create(mForm);
  mValueCB.Parent:=mForm;
  mValueCB.Left := 60;
  mValueCB.Top := 8;
  mValueCB.Width := 240;
  mValueCB.Items:=mList;
  mValueCB.ItemIndex:=0;

  mBtn := TButton.Create(mForm);
  mBtn.Width := 75;
  mBtn.Height := 25;
  mBtn.Caption := 'OK';
  mBtn.ModalResult := mrOk;
  mBtn.Cancel := False;
  mBtn.Default := True;
  mBtn.Left :=  mForm.Width - 2*(mBtn.Width+2) - 20;
  mBtn.Top := mForm.Height - mBtn.Height - 40;
  mBtn.Name := 'btnOK';
  mForm.InsertControl(mBtn);

  mBtn := TButton.Create(mForm);
  mBtn.Width := 75;
  mBtn.Height := 25;
  mBtn.Caption := 'Storno';
  mBtn.ModalResult := mrCancel;
  mBtn.Cancel := True;
  mBtn.Left := mForm.Width - (mBtn.Width+2) - 20;;
  mBtn.Top := mForm.Height - mBtn.Height - 40;
  mBtn.Name := 'btnCancel';
  mForm.InsertControl(mBtn);

  Result := mForm.ShowModal(Asite)= mrOK;
  if Result then begin
    aCountryIndex:=mValueCB.ItemIndex;
  end;
end;

procedure OnFormCloseAction(Sender: TObject; var Action: TCloseAction);
begin
  if Action = caHide then TForm(Sender).ModalResult := mrCancel;
end;

function POST_GetQuantity(AContext: TNXContext; AInput: TJSONSuperObject; APath: String): TJSONSuperObject;
var
 mBO:TNxCustomBusinessObject;
 mOS:TNxCustomObjectSpace;
 mList:TStringList;
 i:integer;
 mQuantity, mLowLimit, mHighLimit, mQuantityA, mQuantityB, mQuantityC, mQuantityD:Extended;
 mSSCQuantity, mSSCLowLimit, mSSCHighLimit, mSSCQuantityA,mSSCQuantityB,mSSCQuantityC,mSSCQuantityD:Extended;
begin
 Result:=TJSONSuperObject.Create;
 mOS:=AContext.GetObjectSpace;
 //AInput.SaveToFile('\\CZVS0006\logy\_JSON\GetQ\GetQ_'+FormatDateTime('YYYYMMDDhhmmss',Now)+'.json', true, true);
 if Length(AInput.S['storeCardCode'])>0 then begin
    mQuantity:=0;
    mLowLimit:=0;
    mHighLimit:=0;
    mQuantityA:=0;
    mQuantityB:=0;
    mQuantityC:=0;
    mQuantityD:=0;
    mSSCQuantityA:=0;
    mSSCQuantityB:=0;
    mSSCQuantityC:=0;
    mSSCQuantityD:=0;
    mList:=TStringList.Create;
    mList.Sorted:=True;
    mList.Duplicates:=dupIgnore;
    mOS.SQLSelect('Select a.id from storecards a where (a.code='+Quotedstr(AInput.S['storeCardCode'])+') or '+
                  ' (a.id in (select pl.storecard_id from plmpiecelists pl left join plmpiecelists2 plm2 on pl.id=plm2.parent_id '+
                  ' left join storecards sc on sc.id=plm2.storecard_id where sc.code='+Quotedstr(AInput.S['storeCardCode'])+')) and not(a.StoreCardCategory_ID=''~00000000C'')  '+
                  ' union all '+
                  'Select a.id from storecards a where (a.code='+Quotedstr(AInput.S['storeCardCode'])+') or  (a.id in '+
                  '(select plm2.storecard_id from plmpiecelists pl '+
                  ' left join plmpiecelists2 plm2 on pl.id=plm2.parent_id '+
                  ' left join storecards sc on sc.id=pl.storecard_id left join storecards sc2 on sc2.id=plm2.storecard_id where sc.code='+Quotedstr(AInput.S['storeCardCode'])+
                  ' and sc2.isproduct='+Quotedstr('A')+')) and not(a.StoreCardCategory_ID=''~00000000C'')', mList);
    for i:=0 to mlist.count-1 do begin
       {mSSCQuantity:=mOS.SQLSelectFirstAsExtended('Select sum(ssc.quantity) from storesubcards ssc left join stores s on s.id=ssc.store_id '+
                                                  ' where s.X_CalculateQuantity=''A'' and SSC.StoreCard_ID='+QuotedStr(mList.strings[i]),0); }
       mSSCQuantity:=mOS.SQLSelectFirstAsExtended('select sum(ro2.Quantity-ro2.deliveredquantity) from receivedorders2 ro2 left join receivedorders ro on ro.id=ro2.parent_id '+
                                                  'where ro.confirmed='+QuotedStr('A')+' and ro.closed='+QuotedStr('N')+' and ro.docqueue_id='+
                                                  QuotedStr('2S00000101')+' and ro2.storecard_id='+QuotedStr(mList.strings[i]),0);
       mSSCQuantityA:=mOS.SQLSelectFirstAsExtended('Select sum(ssc.quantity) from storesubcards ssc left join stores s on s.id=ssc.store_id '+
                                                  ' where s.X_ExternalQtyCode='+QuotedStr('A')+' and SSC.StoreCard_ID='+QuotedStr(mList.strings[i]),0);
       mSSCQuantityB:=mOS.SQLSelectFirstAsExtended('Select sum(ssc.quantity) from storesubcards ssc left join stores s on s.id=ssc.store_id '+
                                                  ' where s.X_ExternalQtyCode='+QuotedStr('B')+' and SSC.StoreCard_ID='+QuotedStr(mList.strings[i]),0);
       mSSCQuantityC:=mOS.SQLSelectFirstAsExtended('Select sum(ssc.quantity) from storesubcards ssc left join stores s on s.id=ssc.store_id '+
                                                  ' where s.X_ExternalQtyCode='+QuotedStr('C')+' and SSC.StoreCard_ID='+QuotedStr(mList.strings[i]),0);
       mSSCQuantityD:=mOS.SQLSelectFirstAsExtended('Select sum(ssc.quantity) from storesubcards ssc left join stores s on s.id=ssc.store_id '+
                                                  ' where s.X_ExternalQtyCode='+QuotedStr('D')+' and SSC.StoreCard_ID='+QuotedStr(mList.strings[i]),0);
       mSSCLowLimit:=mOS.SQLSelectFirstAsExtended('Select sum(ssc.LowLimitQuantity) from storesubcards ssc left join stores s on s.id=ssc.store_id '+
                                                  ' where s.X_TransferLimits=''A'' and SSC.StoreCard_ID='+QuotedStr(mList.strings[i]),0);
       mSSCHighLimit:=mOS.SQLSelectFirstAsExtended('Select sum(ssc.HighLimitQuantity) from storesubcards ssc left join stores s on s.id=ssc.store_id '+
                                                  ' where s.X_TransferLimits=''A'' and SSC.StoreCard_ID='+QuotedStr(mList.strings[i]),0);
       mQuantity:=mQuantity+mSSCQuantity;
       mQuantityA:=mQuantityA+mSSCQuantityA;
       mQuantityB:=mQuantityB+mSSCQuantityB;
       mQuantityC:=mQuantityC+mSSCQuantityC;
       mQuantityD:=mQuantityD+mSSCQuantityD;
       mLowLimit:=mLowLimit+mSSCLowLimit;
       mHighLimit:=mHighLimit+mSSCHighLimit;
    end;
    Result.S['storeCardCode']:=AInput.S['storeCardCode'];
    {Result.S['storeCardCode']:='Select a.id from storecards a where (a.code='+Quotedstr(AInput.S['storeCardCode'])+') or '+
                  ' (a.id in (select pl.storecard_id from plmpiecelists pl left join plmpiecelists2 plm2 on pl.id=plm2.parent_id '+
                  ' left join storecards sc on sc.id=plm2.storecard_id where sc.code='+Quotedstr(AInput.S['storeCardCode'])+')) '; }
    Result.D['quantity']:=mQuantity;
    Result.D['quantityA']:=mQuantityA;
    Result.D['quantityB']:=mQuantityB;
    Result.D['quantityC']:=mQuantityC;
    Result.D['quantityD']:=mQuantityD;
    Result.D['lowLimit']:=mLowLimit;
    result.D['highLimit']:=mHighLimit;
    mList.free;
 end;
end;

procedure POST_GetDataFromBatch(AContext:TNxContext; ARequest: TAPIRequest; AResponse: TAPIResponse);
var
  mHeaders: TStringList;
  mInputJSON, mOutputJSON:TJSONSuperObject;
  i: Integer;
  mStoreCard_ID, mCode, mStoreBatch_ID:string;
  mOS:TNxCustomObjectSpace;
  mStoreBatchBO:TNxCustomBusinessObject;
begin
  mHeaders := TStringList.Create;
  mOS:=AContext.GetObjectSpace;
  mInputJSON:=TJSONSuperObject.Create;
  mOutputJSON:=TJSONSuperObject.Create;
  mInputJSON:=TJSONSuperObject.ParseString(ARequest.Body,True);
  if mInputJSON.N['ean'].DataType<> jtNull then begin
     mCode:=mInputJSON.S['ean'];
     if NxIsNumeric(mCode) and (Length(mCode)=13) then
     mStoreCard_ID:=mOS.SQLSelectFirstAsString('SELECT  A.id FROM StoreCards A WHERE (((A.EAN LIKE N'+QuotedStr(mCode)+' ESCAPE '+QuotedStr('~')+') OR '+
                                             '(A.ID IN (SELECT SU.Parent_ID FROM StoreEANs SE JOIN StoreUnits SU ON SE.Parent_Id = SU.Id '+
                                             'WHERE SU.Parent_ID = A.ID AND SE.Ean LIKE N'+QuotedStr(mCode)+' ESCAPE '+QuotedStr('~')+')))) AND A.Hidden = '+Quotedstr('N'),'');
     if not(NxIsEmptyOID(mStoreCard_ID)) then begin
       mStoreBatch_ID:=mOS.SQLSelectFirstAsString('Select id from storebatches where storecard_id='+QuotedStr(mStoreCard_ID)+' and Name='+QuotedStr(mInputJSON.S['batchCode']),'');
       if not(NxIsEmptyOID(mStoreBatch_ID)) then begin
          mStoreBatchBO:=mOS.CreateObject(Class_StoreBatch);
          mStoreBatchBO.load(mStoreBatch_ID,nil);
          mOutputJSON.S['version']:=mStoreBatchBO.GetFieldValueAsString('X_Verze');
          mOutputJSON.S['ean']:=mStoreBatchBO.GetFieldValueAsString('StoreCard_ID.EAN');
          mOutputJSON.S['specification']:=mStoreBatchBO.GetFieldValueAsString('Specification');
          mOutputJSON.DT8601['expirationDate']:=mStoreBatchBO.GetFieldValueAsDateTime('ExpirationDate$Date');
          mOutputJSON.S['status']:='ok';
          mStoreBatchBO.free;
       end;
     end;
  end else begin
    mOutputJSON.S['status']:='error';
  end;
  try

        AResponse.Body:=mOutputJSON.AsString;
        AResponse.SetHeader('Content-Type','application/json');
        AResponse.Status := 200;

  finally
    mHeaders.Free;
  end;
end;


function POST_BillsOfDelivery(AContext: TNXContext; AInput: TJSONSuperObject; APath: String): TJSONSuperObject;
var
 mHeaderBO, mRowBO, mDRBBO, mBODRow, mLog, mDRDBo:TNxCustomBusinessObject;
 i,j,k:integer;
 mRows, mDRBRows:TNxCustomBusinessMonikerCollection;
 mOS:TNxCustomObjectSpace;
 mIORowList, mIOList:tstringlist;
 mOrder_ID, mStoreBatch_ID, mDocQueue_ID, mStore_ID, mStoreCard_ID ,mLogStr, mBody:string;
 mImportManager: TNxDocumentImportManager;
 mInputParams: TNxParameters;
 mParam: TNxParameter;
 mMessage, mReceiptCard_ID, mDefRollData_ID, mOriginID, mLogMessage:string;
 mComponentCard_ID,mProductCard_ID,mBatchMovement_ID:string;
begin
 Result:=TJSONSuperObject.Create;
 mOS:=AContext.GetObjectSpace;
 mMessage:='';
 mLogStr:= '';
 mLogMessage:='';
 if not(NxIsEmptyOID(AInput.S['BillOfDelivery_ID'])) then
   mReceiptCard_ID:=mOS.SQLSelectFirstAsString('SELECT a.id FROM StoreDocuments A WHERE A.DocumentType='+Quotedstr('20')+
                                               ' AND ((exists (SELECT 1 FROM USERDATA WHERE FIELDCODE=2000031 AND CLSID='+
                                               QuotedStr('E03ZNUMDTCC4PDAUIEY1MBTJC0')+' AND ID = A.ID AND (STRINGFIELDVALUE LIKE '+Quotedstr(AInput.S['BillOfDelivery_ID'])+')))) ','');

 if NxIsEmptyOID(mReceiptCard_ID) then begin
  try
    if AInput.A['Rows'].Length>0 then begin
      {try
        AInput.SaveToFile('\\CZVS0006\logy\_JSON\InsertBODJSON_'+FormatDateTime('YYYYMMDDhhmmss',Now)+'.json', true, true);
      except
      end;}
      mDocQueue_ID:=mOS.SQLSelectFirstAsString('Select id from docqueues where documenttype=''20'' and hidden=''N'' and code='+QuotedStr(AInput.S['ReceiptCardCode']),'');
      if NxIsEmptyOID(mDocQueue_ID) then mDocQueue_ID:='5G10000101';
      mHeaderBO:=mOS.CreateObject(Class_ReceiptCard);
      mHeaderBO.New;
      mheaderbo.Prefill;
      mHeaderBO.SetFieldValueAsString('DocQueue_ID',mDocQueue_ID);
      mHeaderBO.SetFieldValueAsString('U_SKBillOfDelivery_ID',AInput.S['BillOfDelivery_ID']);
      mHeaderBO.SetFieldValueAsString('Description',AInput.S['ExternalNumber']);
      mHeaderBO.SetFieldValueAsString('U_DL',AInput.S['ExternalNumber']);
      mHeaderBO.SetFieldValueAsBoolean('X_ZAPI',true);
      for i:=0 to AInput.A['Rows'].Length-1 do begin
        OutputDebugString(AInput.A['Rows'].O[i].S['StoreCardCode']);
      {
        if (NxIsEmptyOID(AInput.A['Rows'].O[i].S['XProvideRowID'])) and (AInput.A['Rows'].O[i].I['RowType']=3) then begin
          mRows:= mHeaderBO.GetLoadedCollectionMonikerForFieldCode(mHeaderBO.GetFieldCode('Rows'));
          mRowBO:= mRows.AddNewObject;
          mBODRow:= mOS.CreateObject(Class_BillOfDeliveryRow);
          try
            mBODRow.Load(AInput.A['Rows'].O[i].S['BODRowID'], nil);

            mRowBO.SetFieldValueAsInteger('RowType', 3);
            mRowBO.SetFieldValueAsString('Store_ID' , mBODRow.GetFieldValueAsString('Store_ID'));
            mRowBO.SetFieldValueAsString('StoreCard_ID' , mBODRow.GetFieldValueAsString('StoreCard_ID'));
            mRowBO.SetFieldValueAsFloat('Quantity',AInput.A['Rows'].O[i].D['Quantity']);
            mRowBO.SetFieldValueAsFloat('UnitPrice',0);
            mRowBO.SetFieldValueAsFloat('TotalPrice',0);
            mRowBO.SetFieldValueAsString('X_StoreDocuments2_ID',AInput.A['Rows'].O[i].S['BODRowID']);

            if AInput.A['Rows'].O[i].A['DocRowBatches'].Length>0 then begin
              mDRBRows:=mRowBO.GetLoadedCollectionMonikerForFieldCode(mRowBO.GetFieldCode('DocRowBatches'));
              for k:=0 to AInput.A['Rows'].O[i].A['DocRowBatches'].Length-1 do begin
                mStoreBatch_ID:=mOS.SQLSelectFirstAsString(
                  ' SELECT ID FROM StoreBatches '+
                  ' WHERE StoreCard_ID='+QuotedStr(mRowBO.GetFieldValueAsString('StoreCard_ID'))+
                  ' AND Name='+QuotedStr(AInput.A['Rows'].O[i].A['DocRowBatches'].O[k].S['StoreBatchName']),'');
                if NxIsEmptyOID(mStoreBatch_ID) then begin
                  mDRBBO:=mDRBRows.AddNewObject;
                  mDRBBO.SetFieldValueAsBoolean('NewBatch',True);
                  mDRBBO.SetFieldValueAsString('NewBatchName',AInput.A['Rows'].O[i].A['DocRowBatches'].O[k].S['StoreBatchName']);
                  mDRBBO.SetFieldValueAsDateTime('NewBatchExpirationDate$Date',AInput.A['Rows'].O[i].A['DocRowBatches'].O[k].DT8601['Expiry']);
                  mDRBBO.SetFieldValueAsString('NewBatchSpecification',AInput.A['Rows'].O[i].A['DocRowBatches'].O[k].S['StoreBatchSpecification']);
                  mDRBBO.SetFieldValueAsFloat('Quantity',AInput.A['Rows'].O[i].A['DocRowBatches'].O[k].D['Quantity']);
                end else begin
                  mDRBBO:=mDRBRows.AddNewObject;
                  mDRBBO.SetFieldValueAsBoolean('NewBatch',False);
                  mDRBBO.SetFieldValueAsString('StoreBatch_ID',mStoreBatch_ID);
                  mDRBBO.SetFieldValueAsFloat('Quantity',AInput.A['Rows'].O[i].A['DocRowBatches'].O[k].D['Quantity']);
                end;
              end;
            end;
          finally
            mBODRow.Free;
          end;
        end;
        }
        if not(NxIsEmptyOID(AInput.A['Rows'].O[i].S['XProvideRowID'])) and (AInput.A['Rows'].O[i].I['RowType']=3) then begin
          mIORowList:=TStringList.create;
          mIOList:=TStringList.create;
          mIORowList.Add(AInput.A['Rows'].O[i].S['XProvideRowID']);
          mOrder_ID:= mOS.SQLSelectFirstAsString(
            ' Select parent_id from issuedorders2 '+
            ' where ((quantity-deliveredquantity)>0) '+
            ' and id='+QuotedStr(AInput.A['Rows'].O[i].S['XProvideRowID']),'');

          if NxIsEmptyOID(mOrder_ID) then begin
            mRows:= mHeaderBO.GetLoadedCollectionMonikerForFieldCode(mHeaderBO.GetFieldCode('Rows'));
            mStore_ID:= mOS.SQLSelectFirstAsString('SELECT ID FROM Stores WHERE Hidden = ''N'' AND Code = '+QuotedStr(AInput.S['StoreCode']));
            mStoreCard_ID:= mOS.SQLSelectFirstAsString('SELECT ID FROM StoreCards WHERE Hidden = ''N'' '+cSQL_X_Aktivni+' AND Code = '+QuotedStr(AInput.A['Rows'].O[i].S['StoreCardCode']));
            if NxIsEmptyOID(mStoreCard_ID) or NxIsEmptyOID(mStore_ID) then RaiseException('Nenalezen sklad nebo karta');
            mRowBO:= mRows.AddNewObject;
            mRowBO.SetFieldValueAsInteger('RowType', 3);
            mRowBO.SetFieldValueAsString('Store_ID', mStore_ID);
            mRowBO.SetFieldValueAsString('StoreCard_ID' , mStoreCard_ID);
            mRowBO.SetFieldValueAsString('QUnit', AInput.A['Rows'].O[i].S['QUnit']);
            mRowBO.SetFieldValueAsFloat('Quantity', AInput.A['Rows'].O[i].D['Quantity']);
            mRowBO.SetFieldValueAsFloat('UnitPrice',0);
            mRowBO.SetFieldValueAsFloat('TotalPrice',0);
            mRowBO.SetFieldValueAsString('X_StoreDocuments2_ID',AInput.A['Rows'].O[i].S['BODRowID']);
            mRowBO.SetFieldValueAsString('Division_ID', '6700000101'); //VV
            mRowBO.SetFieldValueAsString('BusOrder_ID', '');
            mRowBO.SetFieldValueAsString('BusProject_ID', '');
            mRowBO.SetFieldValueAsString('BusTransaction_ID', '');
            OutputDebugString('without order');

            mLogStr:= mLogStr + nxCrLf + AInput.S['ExternalNumber']+'|'+AInput.A['Rows'].O[i].S['StoreCardCode'];

            if AInput.A['Rows'].O[i].A['DocRowBatches'].Length > 0 then begin
              mLogStr:= mLogStr + nxCrLf + 'Šarže: ';
              mDRBRows:= mRowBO.GetLoadedCollectionMonikerForFieldCode(mRowBO.GetFieldCode('DocRowBatches'));
              for k:=0 to AInput.A['Rows'].O[i].A['DocRowBatches'].Length-1 do begin
                mStoreBatch_ID:=mOS.SQLSelectFirstAsString(
                  ' SELECT ID FROM StoreBatches '+
                  ' WHERE StoreCard_ID='+QuotedStr(mRowBO.GetFieldValueAsString('StoreCard_ID'))+
                  ' AND Name='+QuotedStr(AInput.A['Rows'].O[i].A['DocRowBatches'].O[k].S['StoreBatchName']),'');

                mLogStr:= mLogStr + nxCrLf + AInput.A['Rows'].O[i].A['DocRowBatches'].O[k].S['StoreBatchName'];
                if NxIsEmptyOID(mStoreBatch_ID) then begin
                  mDRBBO:=mDRBRows.AddNewObject;
                  mDRBBO.SetFieldValueAsBoolean('NewBatch',True);
                  mDRBBO.SetFieldValueAsString('NewBatchName',AInput.A['Rows'].O[i].A['DocRowBatches'].O[k].S['StoreBatchName']);
                  mDRBBO.SetFieldValueAsDateTime('NewBatchExpirationDate$Date',AInput.A['Rows'].O[i].A['DocRowBatches'].O[k].DT8601['Expiry']);
                  mDRBBO.SetFieldValueAsString('NewBatchSpecification',AInput.A['Rows'].O[i].A['DocRowBatches'].O[k].S['StoreBatchSpecification']);
                  mDRBBO.SetFieldValueAsFloat('Quantity',AInput.A['Rows'].O[i].A['DocRowBatches'].O[k].D['Quantity']);
                end else begin
                  mDRBBO:=mDRBRows.AddNewObject;
                  mDRBBO.SetFieldValueAsBoolean('NewBatch',False);
                  mDRBBO.SetFieldValueAsString('StoreBatch_ID',mStoreBatch_ID);
                  mDRBBO.SetFieldValueAsFloat('Quantity',AInput.A['Rows'].O[i].A['DocRowBatches'].O[k].D['Quantity']);
                end;
              end;
            end;

            mLogStr:= mLogStr + nxCrLf + '--------------------';

          end else begin
            OutputDebugString('with order');
            mIOList.Add(mOrder_ID);
            mInputParams := TNxParameters.Create;
            mParam := mInputParams.GetOrCreateParam(dtString, 'SelectedRows'); // jen povolene radky
            mParam.AsString := mIORowList.Text;
            mParam := mInputParams.GetOrCreateParam(dtString, 'SelectedHeader');
            mParam.AsString := mOrder_ID;
            mImportManager := NxCreateDocumentImportManager(mOS, Class_IssuedOrder, Class_ReceiptCard);
            try
              mImportManager.OutputDocument := mHeaderBO;
              mImportManager.AddInputDocuments(mIOList);
              mImportManager.LoadParams(mInputParams);
              //mImportManager.ExecuteWizard(mSite);
              mImportManager.Execute;
              //mImportManager.CheckOutputDocument;
              //mImportManager.OutputDocument.Save;
            except
             mMessage:=mMessage+#13#10+AInput.A['Rows'].O[i].S['XProvideRowID']+'  objekt '+IntToStr(i)+' Order ID:'+mOrder_ID;
             OutputDebugString(mMessage);
            end;
            mRows:=mHeaderBO.GetLoadedCollectionMonikerForFieldCode(mHeaderBO.GetFieldCode('Rows'));
            for j:=0 to mRows.Count-1 do begin
              mRowBO:=mRows.BusinessObject[j];
              if mRowBO.GetFieldValueAsString('ProvideRow_ID') = AInput.A['Rows'].O[i].S['XProvideRowID'] then begin
                mRowBO.SetFieldValueAsString('X_StoreDocuments2_ID',AInput.A['Rows'].O[i].S['BODRowID']);
                mRowBO.SetFieldValueAsFloat('Quantity',AInput.A['Rows'].O[i].D['Quantity']);
                mRowBO.SetFieldValueAsFloat('UnitPrice',0);
                mRowBO.SetFieldValueAsFloat('TotalPrice',0);
                if AInput.A['Rows'].O[i].A['DocRowBatches'].Length > 0 then begin
                  mDRBRows:=mRowBO.GetLoadedCollectionMonikerForFieldCode(mRowBO.GetFieldCode('DocRowBatches'));
                  for k:=0 to AInput.A['Rows'].O[i].A['DocRowBatches'].Length -1 do begin
                    mStoreBatch_ID:=mOS.SQLSelectFirstAsString('Select id from StoreBatches where storecard_id='+
                                                                QuotedStr(mRowBO.GetFieldValueAsString('StoreCard_ID'))+
                                                                ' and name='+QuotedStr(AInput.A['Rows'].O[i].A['DocRowBatches'].O[k].S['StoreBatchName']),'');
                    if NxIsEmptyOID(mStoreBatch_ID) then begin
                      mDRBBO:=mDRBRows.AddNewObject;
                      mDRBBO.SetFieldValueAsBoolean('NewBatch',True);
                      mDRBBO.SetFieldValueAsString('NewBatchName',AInput.A['Rows'].O[i].A['DocRowBatches'].O[k].S['StoreBatchName']);
                      mDRBBO.SetFieldValueAsDateTime('NewBatchExpirationDate$Date',AInput.A['Rows'].O[i].A['DocRowBatches'].O[k].DT8601['Expiry']);
                      mDRBBO.SetFieldValueAsString('NewBatchSpecification',AInput.A['Rows'].O[i].A['DocRowBatches'].O[k].S['StoreBatchSpecification']);
                      mDRBBO.SetFieldValueAsFloat('Quantity',AInput.A['Rows'].O[i].A['DocRowBatches'].O[k].D['Quantity']);
                      try
                       mOriginID:=mOS.SQLSelectFirstAsString('Select X_Origin_ID from issuedorders2 where id='+QuotedStr(mRowBO.GetFieldValueAsString('ProvideRow_ID')),'');
                       mLogMessage:=mLogMessage+#13#10+'Origin ID :'+mOriginID;
                       if not(NxIsEmptyOID(mOriginID)) then begin
                         mDefRollData_ID:=mOS.SQLSelectFirstAsString('Select id from defrolldata where X_Parent_ID='+QuotedStr(mOriginID)+
                                                                     ' and clsid='+QuotedStr('EC2R2HSFK5UOZ5MYVJWJOHUC4S')+
                                                                     ' and X_SK_batch='+QuotedStr(AInput.A['Rows'].O[i].A['DocRowBatches'].O[k].S['StoreBatchName']),'');
                         // pokud not(NxIsEmptyOID(mDefRollData_ID)) then send email informatika@lipoelastic.com subject?? synchronizace šarží sendinternal mail account Autoserver
                         if not(NxIsEmptyOID(mDefRollData_ID)) then begin
                          // SendInternalMail(mOS,'informatika@lipoelastic.com','synchronizace šarží',
                          // 'Šarže ze SK '+AInput.A['Rows'].O[i].A['DocRowBatches'].O[k].S['StoreBatchName']+' je již založena ID z defrolldata:'+mDefRollData_ID,'1100000101','','');

                         end;
                         mLogMessage:=mLogMessage+#13#10+'DefRollData ID :'+mDefRollData_ID;
                         if NxIsEmptyOID(mDefRollData_ID) then mDefRollData_ID:=mOS.SQLSelectFirstAsString('Select id from defrolldata where X_Parent_ID='+QuotedStr(mOriginID)+
                                                                                                           ' and clsid='+QuotedStr('EC2R2HSFK5UOZ5MYVJWJOHUC4S')+
                                                                                                           ' and X_SK_batch='''' ','');
                         if not(NxIsEmptyOID(mDefRollData_ID)) then begin
                           mDRDBo:=mOS.CreateObject('EC2R2HSFK5UOZ5MYVJWJOHUC4S');
                           mDRDBo.Load(mDefRollData_ID);
                           mDRDBo.SetFieldValueAsString('X_SK_Batch',AInput.A['Rows'].O[i].A['DocRowBatches'].O[k].S['StoreBatchName']);
                           mDRDBo.SetFieldValueAsDateTime('X_DateTimeOfLastChange',Now);
                           if mDRBBO.GetFieldValueAsFloat('Quantity')>mDRDBo.GetFieldValueAsFloat('X_Quantity') then begin
                             mBody:='Na šarži '+mDRDBo.GetFieldValueAsString('X_Batches.Name')+' bylo přijato '+FloatToStr(mDRBBO.GetFieldValueAsFloat('Quantity'))+' doklad '+AInput.S['ExternalNumber'];
                             CFxLog.SaveLog(NxCreateContext(mOS),'LA','chyba množství šarže',mBody,2,Now);
                             SendInternalMail(mOS,'informatika@lipoelastic.com','synchronizace šarží', mBody,'1100000101','','');
                            end;
                           mDRDBo.save;
                           mDRDBo.free;
                         end else begin
                           mBody:='Na šarži '+AInput.A['Rows'].O[i].A['DocRowBatches'].O[k].S['StoreBatchName']+' nedohledán pohyb šarže na OV'+' doklad '+AInput.S['ExternalNumber'];
                           CFxLog.SaveLog(NxCreateContext(mOS),'LA','chyba nenalezený pohyb šarže na OV',mBody,2,Now);
                           SendInternalMail(mOS,'informatika@lipoelastic.com','synchronizace šarží', mBody,'1100000101','','');
                         end;
                       end else begin
                         mComponentCard_ID:=mRowBO.GetFieldValueAsString('StoreCard_ID');
                         if not (NxIsEmptyOID(mComponentCard_ID)) then
                            mProductCard_ID:= mOS.SQLSelectFirstAsString(
                              ' SELECT PL.StoreCard_ID FROM PLMPieceLists PL '+
                              ' JOIN PLMPieceLists2 PL2 ON PL.ID = PL2.Parent_ID '+
                              ' WHERE PL2.StoreCard_ID = '+QuotedStr(mComponentCard_ID));
                         mBatchMovement_ID:= mOS.SQLSelectFirstAsString(
                              ' SELECT DRD.ID FROM IssuedOrders IO '+
                              ' JOIN IssuedOrders2 IO2 ON IO2.Parent_ID = IO.ID '+
                              ' JOIN DefRollData DRD ON DRD.X_Parent_ID = IO2.ID '+
                              ' left join userxlinks u on u.source_id=io.id '+
                              ' WHERE drd.x_SK_Batch='''' and IO.Closed = ''N'' '+
                              ' AND (DRD.CLSID=''EC2R2HSFK5UOZ5MYVJWJOHUC4S'') '+
                              ' AND ((IO2.Quantity - IO2.DeliveredQuantity) >= '+NxFloatToIBStr(mDRBBO.GetFieldValueAsFloat('Quantity'))+')'+    //má být množství na příjemce
                              ' AND (IO.DocDate$DATE >= 45566) '+                       //datum dočasně
                              ' AND IO2.StoreCard_ID = '+QuotedStr(mProductCard_ID)+' and u.id is null');
                         if not(NxIsEmptyOID(mBatchMovement_ID)) then begin
                          mDRDBo:= mOS.CreateObject('EC2R2HSFK5UOZ5MYVJWJOHUC4S'); //POHYBY ŠARŽÍ NA OV
                          try
                            mDRDBo.Load(mBatchMovement_ID, nil);
                            mDRDBo.SetFieldValueAsString('X_SK_Batch', AInput.A['Rows'].O[i].A['DocRowBatches'].O[k].S['StoreBatchName']);
                            mDRDBo.SetFieldValueAsDateTime('X_DateTimeOfLastChange',Now);
                            mDRDBo.Save;
                          finally
                            mDRDBo.Free;
                          end;
                         end else begin
                             mBody:='Na šarži '+AInput.A['Rows'].O[i].A['DocRowBatches'].O[k].S['StoreBatchName']+' pro kartu '+mRowBO.GetFieldValueAsString('StoreCard_ID.Code')+' se nepovedlo dohledat pohyb šarže na nevyřízené objednávce od 15.10.2024 bez vazby'+' doklad '+AInput.S['ExternalNumber'];
                             CFxLog.SaveLog(NxCreateContext(mOS),'LA','chyba nenalezená OV',mBody,2,Now);
                             SendInternalMail(mOS,'informatika@lipoelastic.com','synchronizace šarží', mBody,'1100000101','','');
                          end;
                       end;
                      except
                        CFxLog.SaveLog(NxCreateContext(mOS),'LA','chyba šarže',mBody+#13#10+ExceptionMessage,2,Now);
                      end;
                    end else begin
                      mDRBBO:=mDRBRows.AddNewObject;
                      mDRBBO.SetFieldValueAsBoolean('NewBatch',False);
                      mDRBBO.SetFieldValueAsString('StoreBatch_ID',mStoreBatch_ID);
                      mDRBBO.SetFieldValueAsFloat('Quantity',AInput.A['Rows'].O[i].A['DocRowBatches'].O[k].D['Quantity']);
                      try
                       mOriginID:=mOS.SQLSelectFirstAsString('Select X_Origin_ID from issuedorders2 where id='+QuotedStr(mRowBO.GetFieldValueAsString('ProvideRow_ID')),'');
                       if not(NxIsEmptyOID(mOriginID)) then begin
                         mDefRollData_ID:=mOS.SQLSelectFirstAsString('Select id from defrolldata where X_Parent_ID='+QuotedStr(mOriginID)+
                                                                     ' and clsid='+QuotedStr('EC2R2HSFK5UOZ5MYVJWJOHUC4S')+
                                                                     ' and X_SK_batch='+QuotedStr(AInput.A['Rows'].O[i].A['DocRowBatches'].O[k].S['StoreBatchName']),'');
                         if not(NxIsEmptyOID(mDefRollData_ID)) then begin
                           //SendInternalMail(mOS,'informatika@lipoelastic.com','synchronizace šarží',
                           //'Šarže ze SK '+AInput.A['Rows'].O[i].A['DocRowBatches'].O[k].S['StoreBatchName']+' je již založena ID z defrolldata:'+mDefRollData_ID,'1100000101','','');
                         end;
                         if NxIsEmptyOID(mDefRollData_ID) then mDefRollData_ID:=mOS.SQLSelectFirstAsString('Select id from defrolldata where X_Parent_ID='+QuotedStr(mOriginID)+
                                                                                                           ' and clsid='+QuotedStr('EC2R2HSFK5UOZ5MYVJWJOHUC4S')+
                                                                                                           ' and X_SK_batch='''' ','');
                         if not(NxIsEmptyOID(mDefRollData_ID)) then begin
                           mDRDBo:=mOS.CreateObject('EC2R2HSFK5UOZ5MYVJWJOHUC4S');
                           mDRDBo.Load(mDefRollData_ID);
                           mDRDBo.SetFieldValueAsString('X_SK_Batch',AInput.A['Rows'].O[i].A['DocRowBatches'].O[k].S['StoreBatchName']);
                           mDRDBo.SetFieldValueAsDateTime('X_DateTimeOfLastChange',Now);
                           if mDRBBO.GetFieldValueAsFloat('Quantity')>mDRDBo.GetFieldValueAsFloat('X_Quantity') then begin
                             mBody:='Na šarži '+mDRDBo.GetFieldValueAsString('X_Batches.Name')+' bylo přijato '+FloatToStr(mDRBBO.GetFieldValueAsFloat('Quantity'))+' doklad '+AInput.S['ExternalNumber'];
                             CFxLog.SaveLog(NxCreateContext(mOS),'LA','chyba množství šarže',mBody,2,Now);
                             SendInternalMail(mOS,'informatika@lipoelastic.com','synchronizace šarží', mBody,'1100000101','','');
                           end;
                           mDRDBo.save;
                           mDRDBo.free;
                         end else begin
                           mBody:='Na šarži '+AInput.A['Rows'].O[i].A['DocRowBatches'].O[k].S['StoreBatchName']+' pro kartu '+mRowBO.GetFieldValueAsString('StoreCard_ID.Code')+' se nepovedlo dohledat pohyb šarže na nevyřízené objednávce od 15.10.2024 bez vazby'+' doklad '+AInput.S['ExternalNumber'];
                           CFxLog.SaveLog(NxCreateContext(mOS),'LA','chyba nenalezený pohyb šarže na OV',mBody,2,Now);
                           SendInternalMail(mOS,'informatika@lipoelastic.com','synchronizace šarží', mBody,'1100000101','','');
                         end;
                       end else begin
                         mComponentCard_ID:=mRowBO.GetFieldValueAsString('StoreCard_ID');
                         if not (NxIsEmptyOID(mComponentCard_ID)) then
                            mProductCard_ID:= mOS.SQLSelectFirstAsString(
                              ' SELECT PL.StoreCard_ID FROM PLMPieceLists PL '+
                              ' JOIN PLMPieceLists2 PL2 ON PL.ID = PL2.Parent_ID '+
                              ' WHERE PL2.StoreCard_ID = '+QuotedStr(mComponentCard_ID));
                         mBatchMovement_ID:= mOS.SQLSelectFirstAsString(
                              ' SELECT DRD.ID FROM IssuedOrders IO '+
                              ' JOIN IssuedOrders2 IO2 ON IO2.Parent_ID = IO.ID '+
                              ' JOIN DefRollData DRD ON DRD.X_Parent_ID = IO2.ID '+
                              ' left join userxlinks u on u.source_id=io.id '+
                              ' WHERE drd.x_SK_Batch='''' and IO.Closed = ''N'' '+
                              ' AND (DRD.CLSID=''EC2R2HSFK5UOZ5MYVJWJOHUC4S'') '+
                              ' AND ((IO2.Quantity - IO2.DeliveredQuantity) >= '+NxFloatToIBStr(mDRBBO.GetFieldValueAsFloat('Quantity'))+')'+    //má být množství na příjemce
                              ' AND (IO.DocDate$DATE >= 45566) '+                       //datum dočasně
                              ' AND IO2.StoreCard_ID = '+QuotedStr(mProductCard_ID)+' and u.id is null');
                         if not(NxIsEmptyOID(mBatchMovement_ID)) then begin
                          mDRDBo:= mOS.CreateObject('EC2R2HSFK5UOZ5MYVJWJOHUC4S'); //POHYBY ŠARŽÍ NA OV
                          try
                            mDRDBo.Load(mBatchMovement_ID, nil);
                            mDRDBo.SetFieldValueAsString('X_SK_Batch', AInput.A['Rows'].O[i].A['DocRowBatches'].O[k].S['StoreBatchName']);
                            mDRDBo.SetFieldValueAsDateTime('X_DateTimeOfLastChange',Now);
                            mDRDBo.Save;
                          finally
                            mDRDBo.Free;
                          end;
                         end else begin
                             mBody:='Na šarži '+AInput.A['Rows'].O[i].A['DocRowBatches'].O[k].S['StoreBatchName']+' pro kartu '+mRowBO.GetFieldValueAsString('StoreCard_ID.Code')+' nedohledána OV'+' doklad '+AInput.S['ExternalNumber'];
                             CFxLog.SaveLog(NxCreateContext(mOS),'LA','chyba nenalezená OV',mBody,2,Now);
                             SendInternalMail(mOS,'informatika@lipoelastic.com','synchronizace šarží', mBody,'1100000101','','');
                          end;
                       end;
                      except
                        CFxLog.SaveLog(NxCreateContext(mOS),'LA','chyba šarže 2',mBody+#13#10+ExceptionMessage,2,Now);
                      end;
                    end;
                    OutputDebugString(AInput.A['Rows'].O[i].A['DocRowBatches'].O[k].S['StoreBatchName']);
                  end;
                end;
              end;
            end;
          end;
        end;
      end;
    end;
    OutputDebugString('BeforeSave');
    mHeaderBO.SetFieldValueAsInteger('TradeType',2);
    mHeaderBO.SetFieldValueAsString('IntrastatDeliveryTerm_ID','3001000000');
    mHeaderBO.SetFieldValueAsString('IntrastatTransactionType_ID','0101000000');
    mHeaderBO.SetFieldValueAsString('IntrastatTransportationType_ID','2000000000');
    mHeaderBO.SetFieldValueAsString('Country_ID','00000SK000');
    mHeaderBO.save;
    OutputDebugString('Saved');
    Result.S['status']:='ok';
    Result.S['statusMessage']:=mMessage;
    Result.S['DisplayName']:=mHeaderBO.DisplayName;
    mHeaderBO.free;

    if not(NxIsBlank(mLogStr)) then begin
      mLog:=mOS.CreateObject(Class_PRFLog);
      try
        mLog.new;
        mlog.prefill;
        mLog.SetFieldValueAsString('DocQueue_ID','~000000B02');
        mLog.SetFieldValueAsString('Code', 'PrenosDL');
        mLog.SetFieldValueAsString('Note', 'K těmto kartám nebyly dohledány objednávky vydané' + nxCrLf + mLogStr);
        mlog.save;
      finally
        mLog.Free;
      end;
    end;

  except
    Result.S['status']:='error';
    Result.S['statusMessage']:=ExceptionMessage;
    Result.S['DisplayName']:='';
    CFxLog.SaveLog(NxCreateContext(mOS),'LA','Chyba import',ExceptionMessage+#13#10+mLogStr,2,Now);
  end;
 end else begin
   mHeaderBO:=mOS.CreateObject(Class_ReceiptCard);
   mHeaderbo.Load(mReceiptCard_ID,nil);
   Result.S['status']:='ok';
   Result.S['statusMessage']:='Již synchronizováno';
   Result.S['DisplayName']:=mHeaderBO.DisplayName;
   mHeaderBO.free;
 end;
end;

function POST_IssuedOrders(AContext: TNXContext; AInput: TJSONSuperObject; APath: String): TJSONSuperObject;
var
 mHeaderBO, mRowBO, mIORowBO:TNxCustomBusinessObject;
 i,j:integer;
 mRows, mIORows:TNxCustomBusinessMonikerCollection;
 mOS:TNxCustomObjectSpace;
 mDocQueue_ID, mStore_ID, mDivision_ID, mIODocQueue_ID, mMainSupplier_ID, mReceivedOrder_ID,mBusProject_ID, mNotFoundCard, mStoreCard_ID:string;
 mInputParams:TNxParameters;
 mParam:TNxParameter;
 mImportMan: TNxDocumentImportManager;
begin
 Result := TJSONSuperObject.Create;
 mOS:=AContext.GetObjectSpace;
 CFxLog.SaveLog(NxCreateContext(mOS),'LA','DataOrder '+AInput.S['ExternalNumber'],AInput.AsString,2,Now);
  try
      mReceivedOrder_ID:=mOS.SQLSelectFirstAsString('Select id from receivedorders where externalnumber='+QuotedStr(AInput.S['ExternalNumber']),'');
      if NxIsEmptyOID(mReceivedOrder_ID) then begin
          mHeaderBO:=mOS.CreateObject(Class_ReceivedOrder);
          mHeaderBO.New;
          mHeaderBO.prefill;
          mMainSupplier_ID:='';
          mNotFoundCard:='';
          mDocQueue_ID:=mOS.SQLSelectFirstAsString('Select id from docqueues where code='+QuotedStr(AInput.S['DocQueueCode'])+' and DocumentType='+QuotedStr('RO'),'');
          mIODocQueue_ID:=mOS.SQLSelectFirstAsString('Select id from docqueues where code='+QuotedStr(AInput.S['IODocQueueCode'])+' and DocumentType='+QuotedStr('IO'),'');
          mHeaderBO.SetFieldValueAsString('DocQueue_ID',mDocQueue_ID);
          mHeaderBO.SetFieldValueAsString('ExternalNumber',AInput.S['ExternalNumber']);
          mHeaderBO.SetFieldValueAsString('Description',AInput.S['Description']);
          mHeaderBO.SetFieldValueAsString('X_Poznam_exp', AInput.S['ExpeditionNote']);
          mHeaderBO.SetFieldValueAsString('X_Poznamka', AInput.S['Note']);//+NxCrLf+ AInput.S['ExpeditionNote']);
          mHeaderBO.SetFieldValueAsString('U_SK_ReceivedOrder_DisplayName', AInput.S['SK_ReceivedOrder_DisplayName']);
          mHeaderBO.SetFieldValueAsInteger('TradeType',2);
          if AInput.S['CountryCode']='SK' then begin
           mHeaderBO.SetFieldValueAsString('U_SKIssuedOrder_ID',AInput.S['IssuedOrder_ID']);
           mHeaderBO.SetFieldValueAsString('Country_ID','00000SK000');
           mHeaderBO.SetFieldValueAsBoolean('Confirmed',True);
           mHeaderBO.SetFieldValueAsString('Firm_ID',mOS.SQLSelectFirstAsString('Select id from firms where firm_id is null and hidden='
              +QuotedStr('N')+' and orgidentnumber='+QuotedStr('53578341'),''));
          end;
          if AInput.S['CountryCode']='AT' then begin
           mHeaderBO.SetFieldValueAsString('U_ATIssuedOrder_ID',AInput.S['IssuedOrder_ID']);
           mHeaderBO.SetFieldValueAsString('Country_ID','00000AT000');
           mHeaderBO.SetFieldValueAsString('Firm_ID',mOS.SQLSelectFirstAsString('Select id from firms where firm_id is null and hidden='
              +QuotedStr('N')+' and vatidentnumber='+QuotedStr('ATU77365478'),''));
          end;
          mHeaderBO.SetFieldValueAsDateTime('X_Termin_dodani',AInput.DT8601['DeliveryDate']);

          mRows:=mHeaderBO.GetLoadedCollectionMonikerForFieldCode(mHeaderBO.GetFieldCode('Rows'));
           for i:= 0 to AInput.A['Rows'].Length -1 do begin
             mRowBO:=mRows.AddNewObject;
             mrowBO.Prefill;
             mStore_ID:=mOS.SQLSelectFirstAsString('Select id from stores where code='+QuotedStr(AInput.A['Rows'].O[i].S['StoreCode']),'');
             mDivision_ID:=mOS.SQLSelectFirstAsString('Select id from divisions where code='+QuotedStr(AInput.A['Rows'].O[i].S['DivisionCode']),'');
             mRowBO.SetFieldValueAsInteger('RowType', AInput.A['Rows'].O[i].I['RowType']);
             if not(NxIsEmptyOID(AInput.A['Rows'].O[i].S['Row_ID'])) then
              mRowBO.SetFieldValueAsString('X_provideRow_ID',AInput.A['Rows'].O[i].S['Row_ID']);
             mRowBO.SetFieldValueAsString('Division_ID',mDivision_ID);
             if AInput.A['Rows'].O[i].I['RowType']=3 then begin
               mRowBO.SetFieldValueAsString('Store_ID',mStore_ID);
               mStoreCard_ID:=mOS.SQLSelectFirstAsString('select id from storecards where hidden='+QuotedStr('N')+cSQL_X_Aktivni+' and code='+QuotedStr(AInput.A['Rows'].O[i].S['StoreCardCode']),'');
               mRowBO.SetFieldValueAsString('StoreCard_ID',mStoreCard_ID);
               if NxIsEmptyOID(mStoreCard_ID) then mNotFoundCard:=mNotFoundCard+NxCrLf+AInput.A['Rows'].O[i].S['StoreCardCode'];
               if NxIsEmptyOID(mMainSupplier_ID)  and not(NxIsEmptyOID(mIODocQueue_ID)) then mMainSupplier_ID:=mRowBO.GetFieldValueAsString('Storecard_id.MainSupplier_ID.Firm_ID');
               mRowBO.SetFieldValueAsFloat('Quantity',AInput.A['Rows'].O[i].D['Quantity']);
               mRowBO.SetFieldValueAsFloat('UnitPrice',0);
               mRowBO.SetFieldValueAsFloat('TotalPrice',0);
             end else begin
               if AInput.A['Rows'].O[i].I['RowType']=2 then begin
                mRowBO.SetFieldValueAsFloat('Quantity',AInput.A['Rows'].O[i].D['Quantity']);
                mrowBO.SetFieldValueAsString('QUnit',AInput.A['Rows'].O[i].S['QUnit']);
               end;
               mRowBO.SetFieldValueAsString('Text',AInput.A['Rows'].O[i].S['Text']);
             end;
           end;
          mHeaderBO.save;
          if Assigned(mHeaderBO) then begin
            if AInput.S['CountryCode']='AT' then begin
               SendInternalMail(mOS,'jsyrovy@lipoelastic.com;mkubikova@lipoelastic.com;dfrydrych@lipoelastic.com;dcedidlova@lipoelastic.com','Nová objednávka z AT '+mHeaderBO.DisplayName, '','1100000101','','');
            end;
          end;
          if not(NxIsEmptyOID(mIODocQueue_ID)) then begin
             mInputParams := TNxParameters.Create;
             mParam := mInputParams.GetOrCreateParam(dtString, 'DocQueue_ID');
             mParam.AsString:=mIODocQueue_ID;
             mImportMan := NxCreateDocumentImportManager(mOS, Class_ReceivedOrder, Class_IssuedOrder);
             Try
              mImportMan.AddInputDocument(mHeaderBO.OID);
              mImportMan.LoadParams(mInputParams);
              mImportMan.Execute;
              mImportMan.CheckOutputDocument;
              if Assigned(mImportMan.OutputDocument) then begin
                mImportMan.OutputDocument.SetFieldValueAsString('DocQueue_ID', mIODocQueue_ID);
                mImportMan.OutputDocument.SetFieldValueAsString('Firm_ID', mHeaderBO.GetFieldValueAsString('Firm_ID'));
                if not(NxIsEmptyOID(mMainSupplier_ID)) then mImportMan.OutputDocument.SetFieldValueAsString('Firm_ID',mMainSupplier_ID);
                mImportMan.OutputDocument.SetFieldValueAsBoolean('Confirmed',true);
                mImportMan.OutputDocument.SetFieldValueAsString('Description',mHeaderBO.GetFieldValueAsString('Description')+' '+AInput.S['ExternalNumber']);
                mImportMan.OutputDocument.SetFieldValueAsDateTime('X_Datum_dodani',mHeaderBO.GetFieldValueAsDateTime('X_Termin_dodani'));
                mIORows:=mImportMan.OutputDocument.GetLoadedCollectionMonikerForFieldCode(mImportMan.OutputDocument.GetFieldCode('Rows'));
                for j:=0 to mIORows.count-1 do begin
                  mIORowBO:=mIORows.BusinessObject[j];
                  if not(NxIsEmptyOID(mIORowBO.GetFieldValueAsString('Parent_ID.Firm_ID'))) then begin
                     mBusProject_ID:=mIORowBO.GetFieldValueAsString('Parent_ID.Firm_ID.X_BusProject_ID');
                     if not(NxIsEmptyOID(mBusProject_ID)) then begin
                      mDivision_ID:=mIORowBO.GetFieldValueAsString('Parent_ID.Firm_ID.X_BusProject_ID.Division_ID');
                     end;
                     if not(NxIsEmptyOID(mBusProject_ID)) then mIORowBO.SetFieldValueAsString('BusProject_ID',mBusProject_ID);
                     if not(NxIsEmptyOID(mDivision_ID)) then mIORowBO.SetFieldValueAsString('Division_ID',mDivision_ID);
                  end;
                end;
                mImportMan.OutputDocument.Save;
              end;
              Result.S['IODisplayName']:=mImportMan.OutputDocument.DisplayName;
             except
              Result.S['IODisplayName']:='';
             end;
          end;
          //POST_ImportManager(AContext, Class_ReceivedOrder, Class_IssuedOrder, mHeaderBO.OID, mHeaderBO.GetFieldValueAsString('DocQueue_ID.U_);

          Result.S['ID']:=mHeaderBO.OID;
          Result.S['Code']:=mHeaderBO.DisplayName;
          Result.S['Status']:='Ok';
          mHeaderBO.Free;
      end else begin
        mHeaderBO:=mOS.CreateObject(Class_ReceivedOrder);
        mHeaderBO.Load(mReceivedOrder_ID,nil);
        Result.S['ID']:=mHeaderBO.OID;
        Result.S['Code']:=mHeaderBO.DisplayName;
        Result.S['Status']:='Ok';
        Result.S['IODisplayName']:='';
        mHeaderBO.free;
      end;
  except
      Result.S['ID']:='';
      Result.S['Code']:=ExceptionMessage+nxCrLf+'Nenalezené karty:'+NxCrlF+mNotFoundCard;
      Result.S['Status']:='Error';
      Result.S['IODisplayName']:='';
      mHeaderBO.Free;
  end;
end;


function POST_InvoiceQueue(AContext: TNXContext; AInput: TJSONSuperObject; APath: String): TJSONSuperObject;
var
  mBO: TNxCustomBusinessObject;
  mDoc_ID: string;
begin
  mDoc_ID:= AContext.SQLSelectFirstAsString(
    ' SELECT ID FROM DefRollData '+
    ' WHERE CLSID = '+QuotedStr(Class_BO_Temp_Invoice_SK)+
    ' AND X_Synchronizace_ID = '+QuotedStr(AInput.S['DocumentID']));

  Result:= TJSONSuperObject.Create;
  if NxIsEmptyOID(mDoc_ID) then begin
    mBO:= AContext.GetObjectSpace.CreateObject(Class_BO_Temp_Invoice_SK);
    try
      try
        mBO.New;
        mBO.SetFieldValueAsString('X_Poznamka', AInput.AsString);
        mBO.SetFieldValueAsString('Name', AInput.S['DocumentName']);
        mBO.SetFieldValueAsString('X_Synchronizace_ID', AInput.S['DocumentID']);
        mBO.Save;
        Result.S['id']:= mBO.OID;
        Result.S['error']:= '';
      finally
        mBO.Free;
      end;
    except
      Result.S['id']:= '';
      Result.S['error']:= ExceptionMessage;
    end;
  end else begin
    Result.S['id']:= '';
    Result.S['error']:= 'Tato faktura již byla v ABRA CZ zaevidována';
  end;
end;


procedure SendInternalMail(var AOS:TNxCustomObjectSpace;var ATo, ASubject,ABody,aAccount_ID, aObjectID, aObjectCLSID:string);
Var
  mMailBO,mUserXLink:TNxCustomBusinessObject;
  mMRecipients:TNxCustomBusinessMonikerCollection;
  mMailRecipient:TNxCustomBusinessObject;
begin
  if not(ato='') then begin
     mMailBO:=AOS.CreateObject('5C1HWDQDR3J4NAAYZRO5PWHLWK');
     mMailBO.New;
     mMailBO.Prefill;
     mMailBO.SetFieldValueAsString('EmailAccount_ID',aAccount_ID);
     mMailBO.SetFieldValueAsString('Subject',ASubject);
     mMailBO.SetFieldValueAsString('BodySavedAs','1');
     mMailbo.SetFieldValueAsInteger('SentState',1);
     mMailBO.SetFieldValueAsString('Body',ABody);
     mMRecipients:=mMailBO.GetCollectionMonikerForFieldCode(mMailBO.GetFieldCode('Recipients'));

     mMailRecipient:=mMRecipients.AddNewObject;
     mMailRecipient.SetFieldValueAsString('Email',ATo);
     mMailRecipient.SetFieldValueAsInteger('EmailType',0);
     mMailBO.Save;
     if not(NxIsEmptyOID(aObjectID)) then begin
     mUserXLink := aOS.CreateObject(Class_UserXLink);
      try
        mUserXLink.New;
        mUserXLink.Prefill;
        mUserXLink.SetFieldValueAsString('SourceCLSID', aObjectCLSID);
        mUserXLink.SetFieldValueAsString('Source_ID', aObjectID);
        mUserXLink.SetFieldValueAsString('DestinationCLSID', Class_EmailSent);
        mUserXLink.SetFieldValueAsString('Destination_ID', mMailBO.OID);
        mUserXLink.SetFieldValueAsBoolean('DisplayAsSystem', True);
        mUserXLink.SetFieldValueAsString('Description',ASubject);
        mUserXLink.Save;
      finally
        mUserXLink.Free;
      end;
     end;
     mMailBO.free;

  end;
end;



begin
end.