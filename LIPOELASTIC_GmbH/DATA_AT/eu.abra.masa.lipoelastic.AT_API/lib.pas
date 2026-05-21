const
  cSTORE_CARD_CATEGORY_ID_NEW_CARD = '6000000101';
  cVATRATE_ID = '02000XAT00';
  cCOUNTRY_ID = '00000AT000';

  cDEFAULT_UNIT = 'stk';
  cNAME_FIELD = 'NameAT';

  cREL_DEF_MATERIALS = '06';
  cREL_DEF_PARAMETERS = '10';

{function POST_StoreCards(AContext: TNXContext; AInput: TJSONSuperObject; APath: String): TJSONSuperObject;
var
   mBO, mUnit, mEAN, mSCParamBO, mStoreContainerBO:TNxCustomBusinessObject;
   mUnits, mEANs, mStoreContainers: TNxCustomBusinessMonikerCollection;
   mBO_ID, mMessage, mMaterial_ID, mParam_ID, mRoll_ID, mStoreMenu_ID, mMainSupplier_ID, mQuantityDiscount_ID, mStoreAssortment_ID, mIntrastat_ID, mExistingEAN_ID,mUnitCode: string;
   mLog, mContainerCard_ID, mExistingContainer_ID, mContainerQUnit: string;
   i, j, k, l: integer;
   mUnitExists: boolean;
   mParamList, mMaterList:TStringList;
   mOS:TNxCustomObjectSpace;
begin
  Result := TJSONSuperObject.Create;
  mMessage:='';
  mOS:=AContext.GetObjectSpace;
  mBO_ID:=AContext.SQLSelectFirstAsString('SELECT ID FROM StoreCards WHERE hidden='+QuotedStr('N')+' and Code='+Quotedstr(AInput.A['data'].O[0].S['Code']),'');
  try
    mBO:=AContext.GetObjectSpace.CreateObject(Class_StoreCard);
    if NxIsEmptyOID(mBO_ID) then begin
      mBO.New;
      mBO.Prefill;
      mBO.SetFieldValueAsInteger('Category', AInput.A['data'].O[0].I['Category']);    //1 ??
      mBO.SetFieldValueAsString('Code', AInput.A['data'].O[0].S['Code']);
      mBO.SetFieldValueAsString('StoreCardCategory_ID', '6000000101'); //Nová karta          8000000101  MAT
      mBO.SetFieldValueAsString('VATRate_ID', '02000XAT00');           //19%
    end else begin
      mBO.Load(mBO_ID,nil);
    end;

    //mBO.SetFieldValueAsString('Name',           AInput.A['data'].O[0].S['Name']);
    mBO.SetFieldValueAsString('ForeignName',    AInput.A['data'].O[0].S['ForeignName']);
    mBO.SetFieldValueAsString('Specification',  AInput.A['data'].O[0].S['Specification']);
    mBO.SetFieldValueAsString('Specification2', AInput.A['data'].O[0].S['Specification2']);
    //mStoreMenu_ID:= GetStoreMenuID(AContext.GetObjectSpace, AInput.S['Text'], AInput.A['data'].O[0].S['StoreMenuItemFullPath']);
    //mBO.SetFieldValueAsString('StoreMenuItem_ID', mStoreMenu_ID);
    //mBO.SetFieldValueAsBoolean('X_Aktivni',     AInput.A['data'].O[0].B['X_Aktivni']);
    mBO.SetFieldValueAsBoolean('IsProduct',     AInput.A['data'].O[0].B['IsProduct']);
    mBO.SetFieldValueAsBoolean('IsScalable',    AInput.A['data'].O[0].B['IsScalable']);
    mBO.SetFieldValueAsBoolean('NonStockType',  AInput.A['data'].O[0].B['NonStockType']);
    mBO.SetFieldValueAsString('Note',           AInput.A['data'].O[0].S['Note']);
    //mBO.SetFieldValueAsInteger('X_label_type',  AInput.A['data'].O[0].I['LabelType']);

    //mMainSupplier_ID:= AContext.SQLSelectFirstAsString('SELECT ID FROM Firms WHERE Hidden =''N'' AND Firm_ID is NULL AND Code ='+QuotedStr(AInput.A['data'].O[0].S['MainSupplierCode']));
    //mBO.SetFieldValueAsString('MainSupplier_ID', mMainSupplier_ID);
    mBO.SetFieldValueAsBoolean('UseOutOfStockBatchDelivery',  AInput.A['data'].O[0].B['UseOutOfStockBatchDelivery']);
    mBO.SetFieldValueAsBoolean('UseOutOfStockDelivery',       AInput.A['data'].O[0].B['UseOutOfStockDelivery']);
    mBO.SetFieldValueAsInteger('OutOfStockBatchDelivery',     AInput.A['data'].O[0].I['OutOfStockBatchDelivery']);
    mBO.SetFieldValueAsInteger('OutOfStockDelivery',          AInput.A['data'].O[0].I['OutOfStockDelivery']);

    mQuantityDiscount_ID:= AContext.SQLSelectFirstAsString('SELECT ID FROM QuantityDiscounts WHERE Code = '+QuotedStr(AInput.A['data'].O[0].S['QuantityDiscountCode']));
    mStoreAssortment_ID:= GetOrCreateStoreAssortmentGroup(mBO.ObjectSpace,
                                                          AInput.A['data'].O[0].S['StoreAssortmentGroupCode'],
                                                          AInput.A['data'].O[0].S['StoreAssortmentGroupName']);


    //AContext.SQLSelectFirstAsString('SELECT ID FROM StoreAssortmentGroups WHERE Code = '+QuotedStr(AInput.A['data'].O[0].S['StoreAssortmentGroupCode']));
    //mBO.SetFieldValueAsString('QuantityDiscount_ID', mQuantityDiscount_ID);
    mBO.SetFieldValueAsString('StoreAssortmentGroup_ID', mStoreAssortment_ID);

    mIntrastat_ID:= GetOrCreateIntrastatCode(mBO.ObjectSpace,
                    AInput.A['data'].O[0].S['IntrastatCommodityCode'],
                    AInput.A['data'].O[0].S['IntrastatDescription'],
                    AInput.A['data'].O[0].S['IntrastatUnitCode'],
                    AInput.A['data'].O[0].D['IntrastatConstantWeight'],
                    AInput.A['data'].O[0].B['IntrastatOptionalWeight']);
    if (not(NxIsEmptyOID(mIntrastat_ID))) and (AInput.A['data'].O[0].D['IntrastatWeight'] > 0) then begin
      mBO.SetFieldValueAsString('IntrastatCommodity_ID', mIntrastat_ID);
      mBO.SetFieldValueAsFloat('IntrastatUnitRate',     AInput.A['data'].O[0].D['IntrastatUnitRate']);
      mBO.SetFieldValueAsFloat('IntrastatWeight',       AInput.A['data'].O[0].D['IntrastatWeight']);
      mBO.SetFieldValueAsFloat('IntrastatUnitRateRef',  AInput.A['data'].O[0].D['IntrastatUnitRateRef']);
      mBO.SetFieldValueAsInteger('IntrastatWeightUnit', AInput.A['data'].O[0].I['IntrastatUnitRate']);
      mBO.SetFieldValueAsString('CustomsTariffNumber', mBO.GetFieldValueAsString('IntrastatCommodity_ID.Code'));
    end;

    mUnits:= mBO.GetLoadedCollectionMonikerForFieldCode(mBO.GetFieldCode('StoreUnits'));
    if osNew in mBO.State then mUnits.BusinessObject[0].MarkForDelete;
    for i:= 0 to AInput.A['data'].O[0].A['StoreUnits'].Length -1 do begin
      mUnitExists := false;
      for j:= 0 to mUnits.Count -1 do begin
        //pokud existuje shoda mezi kódy
        mUnitCode:=AContext.SQLSelectFirstAsString('Select code from Units where X_Code_CZ='+QuotedStr(AInput.A['data'].O[0].A['StoreUnits'].O[i].S['Code']),'stk');
        if (mUnitcode = mUnits.BusinessObject[j].GetFieldValueAsString('Code')) and (mUnitExists = false) then begin
          mUnitExists:= true;
          mUnit:= mUnits.BusinessObject[j];
          mUnit.SetFieldValueAsString('Description',   AInput.A['data'].O[0].A['StoreUnits'].O[i].S['Description']);
          mUnit.SetFieldValueAsFloat('Weight',         AInput.A['data'].O[0].A['StoreUnits'].O[i].D['Weight']);
          mUnit.SetFieldValueAsInteger('WeightUnit',   AInput.A['data'].O[0].A['StoreUnits'].O[i].I['WeightUnit']);
          mUnit.SetFieldValueAsFloat('Capacity',       AInput.A['data'].O[0].A['StoreUnits'].O[i].D['Capacity']);
          mUnit.SetFieldValueAsInteger('CapacityUnit', AInput.A['data'].O[0].A['StoreUnits'].O[i].I['CapacityUnit']);
          //existuje kolekce EANu v JSON
          if AInput.A['data'].O[0].A['StoreUnits'].O[i].N['StoreEANs'].DataType <> jtNull then begin
            mEANs:= mUnit.GetLoadedCollectionMonikerForFieldCode(mUnit.GetFieldCode('StoreEans'));
            for k:= 0 to AInput.A['data'].O[0].A['StoreUnits'].O[i].A['StoreEANs'].Length -1 do begin
              mExistingEAN_ID:= '';
              mExistingEAN_ID:= AContext.SQLSelectFirstAsString('SELECT ID FROM StoreEANs WHERE EAN = '+QuotedStr(AInput.A['data'].O[0].A['StoreUnits'].O[i].A['StoreEANs'].O[k].S['EAN']));
              //if mUnit.OID = AContext.SQLSelectFirstAsString('SELECT Parent_ID FROM StoreEANs WHERE ID = '+QuotedStr(mExistingEAN_ID));
              if (NxIsEmptyOID(mExistingEAN_ID)) then begin
                for l:= 0 to mUnits.Count -1 do begin
                  if mUnits.BusinessObject[l].GetFieldValueAsString('Code') = AInput.A['data'].O[0].A['StoreUnits'].O[i].S['Code'] then begin
                  //try
                    mEANs:= mUnits.BusinessObject[l].GetLoadedCollectionMonikerForFieldCode(mUnits.BusinessObject[l].GetFieldCode('StoreEANs'));
                    mEAN:= mEANs.AddNewObject;
                    mEAN.SetFieldValueAsString('EAN', AInput.A['data'].O[0].A['StoreUnits'].O[i].A['StoreEANs'].O[k].S['EAN']);
                  //except

                  //end;
                  end;
                end;
              end;
            end;
          end;

          if AInput.A['data'].O[0].A['StoreUnits'].O[i].N['StoreContainers'].DataType <> jtNull then begin
            mStoreContainers:= mUnit.GetLoadedCollectionMonikerForFieldCode(mUnit.GetFieldCode('StoreContainers'));
            for k:= 0 to AInput.A['data'].O[0].A['StoreUnits'].O[i].A['StoreContainers'].Length -1 do begin
              mLog:= '';

              mContainerCard_ID:= GetOrCreateStoreContainerCard(mOS,
                AInput.A['data'].O[0].A['StoreUnits'].O[i].A['StoreContainers'].O[k].S['StoreCardCode'],
                AInput.A['data'].O[0].A['StoreUnits'].O[i].A['StoreContainers'].O[k].S['StoreCardName'],
                AInput.A['data'].O[0].A['StoreUnits'].O[i].A['StoreContainers'].O[k].S['StoreAssortmentGroupCode'],
                AInput.A['data'].O[0].A['StoreUnits'].O[i].A['StoreContainers'].O[k].S['StoreCardEAN'],
                AInput.A['data'].O[0].A['StoreUnits'].O[i].A['StoreContainers'].O[k].S['StoreCardMainUnitCode'],
                AInput.A['data'].O[0].A['StoreUnits'].O[i].A['StoreContainers'].O[k].D['StoreCardMainUnitRate'],
                mLog);
                if not NxIsBlank(mLog) then
                  RaiseException(mLog);

              mExistingContainer_ID:= AContext.SQLSelectFirstAsString(Format(
                ' SELECT ID FROM StoreContainers '+
                ' WHERE Parent_ID = ''%s'' '+
                ' AND StoreCard_ID = ''%s'' ',
                [mUnit.OID, mContainerCard_ID]));
              if NxIsEmptyOID(mExistingContainer_ID) then
              begin
                for l:= 0 to mUnits.Count -1 do begin
                  mContainerQUnit:= mOS.SQLSelectFirstAsString(Format('SELECT Code FROM Units WHERE X_Code_CZ = ''%s'' ', [AInput.A['data'].O[0].A['StoreUnits'].O[i].A['StoreContainers'].O[k].S['QUnit']]), 'stk');
                  if mUnits.BusinessObject[l].GetFieldValueAsString('Code') = mContainerQUnit then begin
                    mStoreContainers:= mUnits.BusinessObject[l].GetLoadedCollectionMonikerForFieldCode(mUnits.BusinessObject[l].GetFieldCode('StoreContainers'));
                    mStoreContainerBO:= mStoreContainers.AddNewObject;
                    mStoreContainerBO.SetFieldValueAsString('StoreCard_ID', mContainerCard_ID);
                    //mContainerQUnit:= mOS.SQLSelectFirstAsString(Format('SELECT Code FROM Units WHERE X_Code_CZ = ''%s'' ', [AInput.A['data'].O[0].A['StoreUnits'].O[i].A['StoreContainers'].O[k].S['QUnit']]), 'stk');
                    mStoreContainerBO.SetFieldValueAsString('QUnit', mContainerQUnit);
                    mStoreContainerBO.SetFieldValueAsFloat('UnitQuantity', AInput.A['data'].O[0].A['StoreUnits'].O[i].A['StoreContainers'].O[k].D['UnitQuantity']);
                    mStoreContainerBO.SetFieldValueAsFloat('UnitRate', AInput.A['data'].O[0].A['StoreUnits'].O[i].A['StoreContainers'].O[k].D['UnitRate']);
                  end;
                end;
              end;
            end;
          end;
        end;
      end;
      //zakladame novou jednotku
      if mUnitExists = false then begin
        mUnit:= mUnits.AddNewObject;
        mUnit.Prefill;
        mUnit.SetFieldValueAsString('Code', mUnitCode);
        mUnit.SetFieldValueAsFloat('UnitRate',       AInput.A['data'].O[0].A['StoreUnits'].O[i].D['UnitRate']);
        mUnit.SetFieldValueAsString('Description',   AInput.A['data'].O[0].A['StoreUnits'].O[i].S['Description']);
        mUnit.SetFieldValueAsFloat('Weight',         AInput.A['data'].O[0].A['StoreUnits'].O[i].D['Weight']);
        mUnit.SetFieldValueAsInteger('WeightUnit',   AInput.A['data'].O[0].A['StoreUnits'].O[i].I['WeightUnit']);
        mUnit.SetFieldValueAsFloat('Capacity',       AInput.A['data'].O[0].A['StoreUnits'].O[i].D['Capacity']);
        mUnit.SetFieldValueAsInteger('CapacityUnit', AInput.A['data'].O[0].A['StoreUnits'].O[i].I['CapacityUnit']);
        if AInput.A['data'].O[0].A['StoreUnits'].O[i].N['StoreEANs'].DataType <> jtNull then begin
          mEANs:= mUnit.GetLoadedCollectionMonikerForFieldCode(mUnit.GetFieldCode('StoreEans'));
          for j:= 0 to AInput.A['data'].O[0].A['StoreUnits'].O[i].A['StoreEANs'].Length -1 do begin
            mEAN:= mEANs.AddNewObject;
            mEAN.SetFieldValueAsString('EAN', AInput.A['data'].O[0].A['StoreUnits'].O[i].A['StoreEANs'].O[j].S['EAN']);
          end;
        end;

        if AInput.A['data'].O[0].A['StoreUnits'].O[i].N['StoreContainers'].DataType <> jtNull then begin
          mStoreContainers:= mUnit.GetLoadedCollectionMonikerForFieldCode(mUnit.GetFieldCode('StoreContainers'));
          for j:= 0 to AInput.A['data'].O[0].A['StoreUnits'].O[i].A['StoreContainers'].Length -1 do begin
            mContainerCard_ID:= GetOrCreateStoreContainerCard(mOS,
              AInput.A['data'].O[0].A['StoreUnits'].O[i].A['StoreContainers'].O[j].S['StoreCardCode'],
              AInput.A['data'].O[0].A['StoreUnits'].O[i].A['StoreContainers'].O[j].S['StoreCardName'],
              AInput.A['data'].O[0].A['StoreUnits'].O[i].A['StoreContainers'].O[j].S['StoreAssortmentGroupCode'],
              AInput.A['data'].O[0].A['StoreUnits'].O[i].A['StoreContainers'].O[j].S['StoreCardEAN'],
              AInput.A['data'].O[0].A['StoreUnits'].O[i].A['StoreContainers'].O[j].S['StoreCardMainUnitCode'],
              AInput.A['data'].O[0].A['StoreUnits'].O[i].A['StoreContainers'].O[j].D['StoreCardMainUnitRate'],
              mLog);
            if not NxIsBlank(mLog) then
              RaiseException(mLog);
            if not NxIsEmptyOID(mContainerCard_ID) then
            begin
              mContainerQUnit:= mOS.SQLSelectFirstAsString(Format('SELECT Code FROM Units WHERE X_Code_CZ = ''%s'' ', [AInput.A['data'].O[0].A['StoreUnits'].O[i].A['StoreContainers'].O[j].S['QUnit']]), 'stk');
              mStoreContainerBO:= mStoreContainers.AddNewObject;
              mStoreContainerBO.SetFieldValueAsString('StoreCard_ID', mContainerCard_ID);
              mStoreContainerBO.SetFieldValueAsString('QUnit', mContainerQUnit);
              mStoreContainerBO.SetFieldValueAsFloat('UnitQuantity', AInput.A['data'].O[0].A['StoreUnits'].O[i].A['StoreContainers'].O[j].D['UnitQuantity']);
              mStoreContainerBO.SetFieldValueAsFloat('UnitRate', AInput.A['data'].O[0].A['StoreUnits'].O[i].A['StoreContainers'].O[j].D['UnitRate']);
            end;
          end;
        end;
      end;
    end;
    mBO.SetFieldValueAsString('MainUnitCode',
     AContext.SQLSelectFirstAsString('Select code from Units where X_Code_CZ='+QuotedStr(AInput.A['data'].O[0].S['MainUnitCode']),'stk'));
    mBO.SetFieldValueAsString('Name', AInput.A['data'].O[0].S['NameDE']);
    mBO.SetFieldValueAsString('Country_ID', AContext.SQLSelectFirstAsString('Select ID from Countries where Code='+QuotedStr(AInput.A['data'].O[0].S['CountryCode']),'00000AT000'));
    //mBO.SetFieldValueAsBoolean('X_SynchronizedCZ', True);
    mBO.save;

     //Materiály
    mMaterList:=TStringList.Create;
    mOS.SQLSelect('Select id from defrolldata where clsid='+Quotedstr(Class_BO_Relations)+' and X_Rel_Def=''06'' and X_Value_ID='+QuotedStr(mBO.OID),mMaterList);
    if mMaterList.count>0 then begin
      for i:=0 to mMaterList.count-1 do begin
        mSCParamBO:=mOS.CreateObject(Class_BO_Relations);
        mSCParamBO.Load(mMaterList.Strings[i],nil);
        mSCParamBO.Delete;
      end;
    end;
    for i:= 0 to AInput.A['data'].O[0].A['Materials'].Length -1 do begin
      mMaterial_ID:=GetOrCreateRollValue(mOS,Class_BO_ND_Materials,AInput.A['data'].O[0].A['Materials'].O[i].S['MaterialCode'],AInput.A['data'].O[0].A['Materials'].O[i].S['MaterialName']);
      mSCParamBO:=mOS.CreateObject(Class_BO_Relations);
      mSCParamBO.New;
      mSCParamBO.SetFieldValueAsString('X_Rel_Def','06');
      mSCParamBO.SetFieldValueAsDateTime('X_DateTimeOfLastChange',Now);
      mSCParamBO.SetFieldValueAsString('X_Posindex',GetPosindex(mOS,mBO.OID,'06'));
      mSCParamBO.SetFieldValueAsString('X_Value_ID', mBO.OID);
      mSCParamBO.SetFieldValueAsString('X_Material_ID',mMaterial_ID);
      mSCParamBO.SetFieldValueAsFloat('X_NumericValue',AInput.A['data'].O[0].A['Materials'].O[i].D['X_NumericValue']);
      mSCParamBO.save;
      mSCParamBO.free;
    end;
    //Parametry
    mParamList:=TStringList.Create;
    mOS.SQLSelect('Select id from defrolldata where clsid='+Quotedstr(Class_BO_Relations)+' and X_Rel_Def=''10'' and X_Value_ID='+QuotedStr(mBO.OID),mParamList);
    if mParamList.count>0 then begin
      for i:=0 to mParamList.count-1 do begin
        mSCParamBO:=mOS.CreateObject(Class_BO_Relations);
        mSCParamBO.Load(mParamList.Strings[i],nil);
        mSCParamBO.Delete;
      end;
    end;
    for i:= 0 to AInput.A['data'].O[0].A['Parameters'].Length -1 do begin
      mParam_ID:=GetOrCreateParam(mOS,AInput.A['data'].O[0].A['Parameters'].O[i].S['ParameterCode'],
                                     AInput.A['data'].O[0].A['Parameters'].O[i].S['ParameterName'],
                                     AInput.A['data'].O[0].A['Parameters'].O[i].I['X_TypeOfValue'],
                                     AInput.A['data'].O[0].A['Parameters'].O[i].S['X_RollCLSID'],
                                     AInput.A['data'].O[0].A['Parameters'].O[i].S['X_BOCLSID']);
      if AInput.A['data'].O[0].A['Parameters'].O[i].I['X_TypeOfValue']=1 then begin
        mRoll_ID:=GetOrCreateRollValue(mOS,AInput.A['data'].O[0].A['Parameters'].O[i].S['X_BOCLSID'],
                                          AInput.A['data'].O[0].A['Parameters'].O[i].S['RollValueCode'],
                                          AInput.A['data'].O[0].A['Parameters'].O[i].S['X_RollValueName']);
      end;
      mSCParamBO:=mOS.CreateObject(Class_BO_Relations);
      mSCParamBO.New;
      mSCParamBO.SetFieldValueAsString('X_Rel_Def','10');
      mSCParamBO.SetFieldValueAsDateTime('X_DateTimeOfLastChange',Now);
      mSCParamBO.SetFieldValueAsString('X_Posindex',GetPosindex(mOS,mBO.OID,'10'));
      mSCParamBO.SetFieldValueAsString('X_Value_ID', mBO.OID);
      mSCParamBO.SetFieldValueAsString('X_Parameter_ID',mParam_ID);
      if AInput.A['data'].O[0].A['Parameters'].O[i].I['X_TypeOfValue']=0 then begin
         mSCParamBO.SetFieldValueAsString('X_ParamValue',AInput.A['data'].O[0].A['Parameters'].O[i].S['X_ParamValue']);
         mSCParamBO.SetFieldValueAsString('X_RollValueID','');
         mSCParamBO.SetFieldValueAsString('X_RollValueName','');
         mSCParamBO.SetFieldValueAsString('X_BOCLSID','');
         mSCParamBO.SetFieldValueAsFloat('X_NumericValue',0);
         mSCParamBO.SetFieldValueAsBoolean('X_BooleanValue',false);
         mSCParamBO.SetFieldValueAsBoolean('X_Variantni_polozka',false);
      end;
      if AInput.A['data'].O[0].A['Parameters'].O[i].I['X_TypeOfValue']=1 then begin
         mSCParamBO.SetFieldValueAsString('X_ParamValue','');
         mSCParamBO.SetFieldValueAsString('X_RollValueID',mRoll_ID);
         mSCParamBO.SetFieldValueAsString('X_RollValueName',AInput.A['data'].O[0].A['Parameters'].O[i].S['X_RollValueName']);
         mSCParamBO.SetFieldValueAsString('X_BOCLSID',AInput.A['data'].O[0].A['Parameters'].O[i].S['X_BOCLSID']);
         mSCParamBO.SetFieldValueAsFloat('X_NumericValue',0);
         mSCParamBO.SetFieldValueAsBoolean('X_BooleanValue',false);
         mSCParamBO.SetFieldValueAsBoolean('X_Variantni_polozka', AInput.A['data'].O[0].A['Parameters'].O[i].B['X_Variantni_polozka']);
      end;
      if AInput.A['data'].O[0].A['Parameters'].O[i].I['X_TypeOfValue']=2 then begin
         mSCParamBO.SetFieldValueAsString('X_ParamValue','');
         mSCParamBO.SetFieldValueAsString('X_RollValueID','');
         mSCParamBO.SetFieldValueAsString('X_RollValueName','');
         mSCParamBO.SetFieldValueAsString('X_BOCLSID','');
         mSCParamBO.SetFieldValueAsFloat('X_NumericValue',AInput.A['data'].O[0].A['Parameters'].O[i].D['X_NumericValue']);
         mSCParamBO.SetFieldValueAsBoolean('X_BooleanValue',false);
         mSCParamBO.SetFieldValueAsBoolean('X_Variantni_polozka',false);
      end;
      if AInput.A['data'].O[0].A['Parameters'].O[i].I['X_TypeOfValue']=3 then begin
         mSCParamBO.SetFieldValueAsString('X_ParamValue','');
         mSCParamBO.SetFieldValueAsString('X_RollValueID','');
         mSCParamBO.SetFieldValueAsString('X_RollValueName','');
         mSCParamBO.SetFieldValueAsString('X_BOCLSID','');
         mSCParamBO.SetFieldValueAsFloat('X_NumericValue',0);
         mSCParamBO.SetFieldValueAsBoolean('X_BooleanValue',AInput.A['data'].O[0].A['Parameters'].O[i].B['X_BooleanValue']);
         mSCParamBO.SetFieldValueAsBoolean('X_Variantni_polozka',false);
      end;
      mSCParamBO.save;
      mSCParamBO.Free;
      //mOS.SQLSelectFirstAsString('Select id from defrolldata where code='+QuotedStr(
      mMessage:=mMessage+' '+AInput.A['data'].O[0].A['Parameters'].O[i].S['ParameterName'];
    end;

    Result.S['ID']:=mBO.OID;
    Result.S['Code']:=mBO.GetFieldValueAsString('Code');
    Result.S['Status']:='Ok'+mMessage;
  except
    Result.S['ID']:='';
    Result.S['Code']:=ExceptionMessage;
    Result.S['Status']:='Error';
  end;
end;
}

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
    Result.S['error']:= 'Tato faktura již byla v ABRA AT zaevidována';
  end;
end;


function POST_StoreCards(AContext: TNXContext; AInput: TJSONSuperObject; APath: String): TJSONSuperObject;
var
   mBO, mUnit, mEAN, mSCParamBO:TNxCustomBusinessObject;
   mUnits, mEANs: TNxCustomBusinessMonikerCollection;
   mBO_ID, mMessage, mMaterial_ID, mParam_ID, mRoll_ID, mStoreMenu_ID, mMainSupplier_ID, mQuantityDiscount_ID, mStoreAssortment_ID, mIntrastat_ID, mExistingEAN_ID,mUnitCode: string;
   mLog, mMainUnitCode: string;
   i, j, k, l: integer;
   mUnitExists: boolean;
   mParamList, mMaterList:TStringList;
   mOS:TNxCustomObjectSpace;
begin
  Result := TJSONSuperObject.Create;

  mOS:= AContext.GetObjectSpace;

  mMessage:= '';
  mLog:= '';

  mBO_ID:= mOS.SQLSelectFirstAsString(Format('SELECT ID FROM StoreCards WHERE hidden= ''N'' AND Code= ''%s''', [AInput.A['data'].O[0].S['Code']]),'');

  mBO:= mOS.CreateObject(Class_StoreCard);
  try
    try
      HandleStoreCardBasicData(mBO, mBO_ID, AInput, mLog);
      if not NxIsBlank(mLog) then
        RaiseException(mLog);

      HandleStoreUnits(mBO, AInput, mLog);
      if not NxIsBlank(mLog) then
        RaiseException(mLog);

      mMainUnitCode:= mOS.SQLSelectFirstAsString(Format('SELECT CODE FROM Units WHERE X_Code_CZ=''%s'' ', [AInput.A['data'].O[0].S['MainUnitCode']]), cDEFAULT_UNIT);
      mBO.SetFieldValueAsString('MainUnitCode', mMainUnitCode);

      mBO.save;

      HandleStoreCardMaterials(mBO, AInput, mLog);
      if not NxIsBlank(mLog) then
        RaiseException(mLog);

      HandleStoreCardParameters(mBO, AInput, mLog, mMessage);
      if not NxIsBlank(mLog) then
        RaiseException(mLog);

      Result.S['ID']:= mBO.OID;
      Result.S['Code']:= mBO.GetFieldValueAsString('Code');
      Result.S['Status']:='Ok'+mMessage;
    except
      Result.S['ID']:='';
      Result.S['Code']:=ExceptionMessage;
      Result.S['Status']:='Error';
    end;
  finally
    mBO.Free;
  end;
end;


procedure HandleStoreCardBasicData(var ABO: TNxCustomBusinessObject; const AStoreCard_ID: string; const AInput:TJSONSuperObject; var ALog: string);
var
  mOS: TNxCustomObjectSpace;
  mUnitCodeTranslated, mCountry_ID, mIntrastat_ID, mQuantityDiscount_ID, mStoreAssortment_ID, mParentCard_ID: string;
begin
  mOS:= ABO.ObjectSpace;
  try
    if NxIsEmptyOID(AStoreCard_ID) then
    begin
      ABO.New;
      ABO.Prefill;
      ABO.SetFieldValueAsInteger('Category', AInput.A['data'].O[0].I['Category']);
      ABO.SetFieldValueAsString('Code', AInput.A['data'].O[0].S['Code']);
      ABO.SetFieldValueAsString('StoreCardCategory_ID', cSTORE_CARD_CATEGORY_ID_NEW_CARD);
      ABO.SetFieldValueAsString('VATRate_ID', cVATRATE_ID);
      //Sortimentní skupinu nastavujeme pouze u nové synchronizace
      mStoreAssortment_ID:= GetOrCreateStoreAssortmentGroup(mOS, AInput.A['data'].O[0].S['StoreAssortmentGroupCode'], AInput.A['data'].O[0].S['StoreAssortmentGroupName']);
      ABO.SetFieldValueAsString('StoreAssortmentGroup_ID', mStoreAssortment_ID);
    end else begin
      ABO.Load(AStoreCard_ID,nil);
    end;

    ABO.SetFieldValueAsString('Name',           AInput.A['data'].O[0].S[cNAME_FIELD]);
    ABO.SetFieldValueAsString('ForeignName',    AInput.A['data'].O[0].S['ForeignName']);
    ABO.SetFieldValueAsString('Specification',  AInput.A['data'].O[0].S['Specification']);
    ABO.SetFieldValueAsString('Specification2', AInput.A['data'].O[0].S['Specification2']);

    ABO.SetFieldValueAsBoolean('IsProduct',     AInput.A['data'].O[0].B['IsProduct']);
    ABO.SetFieldValueAsBoolean('IsScalable',    AInput.A['data'].O[0].B['IsScalable']);
    ABO.SetFieldValueAsBoolean('NonStockType',  AInput.A['data'].O[0].B['NonStockType']);
    ABO.SetFieldValueAsString('Note',           AInput.A['data'].O[0].S['Note']);
    ABO.SetFieldValueAsBoolean('X_Matka',       AInput.A['data'].O[0].B['X_Matka']);

    mParentCard_ID:= mOS.SQLSelectFirstAsString(Format('SELECT ID FROM StoreCards WHERE hidden= ''N'' AND Code= ''%s''', [AInput.A['data'].O[0].S['X_Parent_IDCode']]),'');
    //dočasně podmínka
    if ABO.HasField('X_Parent_ID') then
      ABO.SetFieldValueAsString('X_Parent_ID', mParentCard_ID);

    //ABO.SetFieldValueAsString('EAN',            AInput.A['data'].O[0].S['EAN']);

    mCountry_ID:= mOS.SQLSelectFirstAsString('SELECT ID FROM Countries WHERE Code='+QuotedStr(AInput.A['data'].O[0].S['CountryCode']), cCOUNTRY_ID);
    ABO.SetFieldValueAsString('Country_ID', mCountry_ID);

    ABO.SetFieldValueAsBoolean('UseOutOfStockBatchDelivery',  AInput.A['data'].O[0].B['UseOutOfStockBatchDelivery']);
    ABO.SetFieldValueAsBoolean('UseOutOfStockDelivery',       AInput.A['data'].O[0].B['UseOutOfStockDelivery']);
    ABO.SetFieldValueAsInteger('OutOfStockBatchDelivery',     AInput.A['data'].O[0].I['OutOfStockBatchDelivery']);
    ABO.SetFieldValueAsInteger('OutOfStockDelivery',          AInput.A['data'].O[0].I['OutOfStockDelivery']);

    mQuantityDiscount_ID:= mOS.SQLSelectFirstAsString('SELECT ID FROM QuantityDiscounts WHERE Code = '+QuotedStr(AInput.A['data'].O[0].S['QuantityDiscountCode']));


    //mStoreMenu_ID:= GetStoreMenuID(AContext.GetObjectSpace, AInput.S['Text'], AInput.A['data'].O[0].S['StoreMenuItemFullPath']);
    //mBO.SetFieldValueAsString('StoreMenuItem_ID', mStoreMenu_ID);
    //mBO.SetFieldValueAsBoolean('X_Aktivni',     AInput.A['data'].O[0].B['X_Aktivni']);
    //mBO.SetFieldValueAsInteger('X_label_type',  AInput.A['data'].O[0].I['LabelType']);
    //mMainSupplier_ID:= AContext.SQLSelectFirstAsString('SELECT ID FROM Firms WHERE Hidden =''N'' AND Firm_ID is NULL AND Code ='+QuotedStr(AInput.A['data'].O[0].S['MainSupplierCode']));
    //mBO.SetFieldValueAsString('MainSupplier_ID', mMainSupplier_ID);
    //mBO.SetFieldValueAsString('QuantityDiscount_ID', mQuantityDiscount_ID);

    mIntrastat_ID:= GetOrCreateIntrastatCode(mOS,
                    AInput.A['data'].O[0].S['IntrastatCommodityCode'],
                    AInput.A['data'].O[0].S['IntrastatDescription'],
                    AInput.A['data'].O[0].S['IntrastatUnitCode'],
                    AInput.A['data'].O[0].D['IntrastatConstantWeight'],
                    AInput.A['data'].O[0].B['IntrastatOptionalWeight']);
    if (not(NxIsEmptyOID(mIntrastat_ID))) and (AInput.A['data'].O[0].D['IntrastatWeight'] > 0) then
    begin
      ABO.SetFieldValueAsString('IntrastatCommodity_ID', mIntrastat_ID);
      ABO.SetFieldValueAsFloat('IntrastatUnitRate',     AInput.A['data'].O[0].D['IntrastatUnitRate']);
      ABO.SetFieldValueAsFloat('IntrastatWeight',       AInput.A['data'].O[0].D['IntrastatWeight']);
      ABO.SetFieldValueAsFloat('IntrastatUnitRateRef',  AInput.A['data'].O[0].D['IntrastatUnitRateRef']);
      ABO.SetFieldValueAsInteger('IntrastatWeightUnit', AInput.A['data'].O[0].I['IntrastatUnitRate']);
      ABO.SetFieldValueAsString('CustomsTariffNumber', ABO.GetFieldValueAsString('IntrastatCommodity_ID.Code'));
    end;
  except
    ALog:= ALog + 'HandleStoreCardBasicData - Error: ' + ExceptionMessage + nxCrLf;
  end;
end;


procedure HandleStoreUnits(var ABO: TNxCustomBusinessObject; const AInput:TJSONSuperObject; var ALog: string);
var
  mOS: TNxCustomObjectSpace;
  mUnit: TNxCustomBusinessObject;
  mUnits, mEANs: TNxCustomBusinessMonikerCollection;
  mUnitJSON: TJSONSuperObject;
  mUnitCode: string;
  mUnitExists: boolean;
  i, j: integer;
begin
  mOS:= ABO.ObjectSpace;
  try
    mUnits:= ABO.GetLoadedCollectionMonikerForFieldCode(ABO.GetFieldCode('StoreUnits'));

    if osNew in ABO.State then mUnits.BusinessObject[0].MarkForDelete;

    for i:= 0 to AInput.A['data'].O[0].A['StoreUnits'].Length -1 do
    begin
      mUnitJSON:= AInput.A['data'].O[0].A['StoreUnits'].O[i];
      mUnitCode:= mOS.SQLSelectFirstAsString(Format('SELECT CODE FROM Units WHERE X_Code_CZ=''%s'' ', [mUnitJSON.S['Code']]), cDEFAULT_UNIT);

      mUnitExists := false;

      for j:= 0 to mUnits.Count -1 do begin
        //pokud existuje shoda mezi kódy
        if (mUnitcode = mUnits.BusinessObject[j].GetFieldValueAsString('Code')) then
        begin
          mUnitExists:= true;

          mUnit:= mUnits.BusinessObject[j];
          mUnit.SetFieldValueAsString('Description',        mUnitJSON.S['Description']);
          mUnit.SetFieldValueAsFloat('Weight',              mUnitJSON.D['Weight']);
          mUnit.SetFieldValueAsInteger('WeightUnit',        mUnitJSON.I['WeightUnit']);
          mUnit.SetFieldValueAsFloat('Capacity',            mUnitJSON.D['Capacity']);
          mUnit.SetFieldValueAsInteger('CapacityUnit',      mUnitJSON.I['CapacityUnit']);
          mUnit.SetFieldValueAsString('EAN',                mUnitJSON.S['EAN']);
          mUnit.SetFieldValueAsFloat('IndivisibleQuantity', mUnitJSON.D['IndivisibleQuantity']);

          HandleEANs(mOS, mUnit, mUnitJSON, ALog);

          HandleStoreContainers(mOS, mUnit, mUnitJSON, ALog);

          break;
        end;
      end;

      if not mUnitExists then
      begin
        mUnit:= mUnits.AddNewObject;
        mUnit.Prefill;
        mUnit.SetFieldValueAsString('Code', mUnitCode);
        mUnit.SetFieldValueAsFloat('UnitRate',            mUnitJSON.D['UnitRate']);
        mUnit.SetFieldValueAsString('Description',        mUnitJSON.S['Description']);
        mUnit.SetFieldValueAsFloat('Weight',              mUnitJSON.D['Weight']);
        mUnit.SetFieldValueAsInteger('WeightUnit',        mUnitJSON.I['WeightUnit']);
        mUnit.SetFieldValueAsFloat('Capacity',            mUnitJSON.D['Capacity']);
        mUnit.SetFieldValueAsInteger('CapacityUnit',      mUnitJSON.I['CapacityUnit']);
        mUnit.SetFieldValueAsFloat('IndivisibleQuantity', mUnitJSON.D['IndivisibleQuantity']);

        HandleEANs(mOS, mUnit, mUnitJSON, ALog);

        HandleStoreContainers(mOS, mUnit, mUnitJSON, ALog);
      end;
    end;
  except
    ALog:= ALog + 'HandleStoreUnits - Error: '+ExceptionMessage+ nxCrLf;
  end;
end;


procedure HandleEANs(AOS: TNxCustomObjectSpace; var AUnitBO: TNxCustomBusinessObject; const AStoreUnitJSON: TJSONSuperObject; var ALog: string);
var
  mEANs: TNxCustomBusinessMonikerCollection;
  mEANBO: TNxCustomBusinessObject;
  mExistingEAN_ID: String;
  i, j: integer;
begin
  try
    if AStoreUnitJSON.N['StoreEANs'].DataType = jtNull then exit;

    mEANs:= AUnitBO.GetLoadedCollectionMonikerForFieldCode(AUnitBO.GetFieldCode('StoreEANs'));

    for i:= 0 to AStoreUnitJSON.A['StoreEANs'].Length -1 do
    begin
      mExistingEAN_ID:= AOS.SQLSelectFirstAsString(Format('SELECT ID FROM StoreEANs WHERE EAN = ''%s''', [AStoreUnitJSON.A['StoreEANs'].O[i].S['EAN']]));
      {for j:= 0 to mEANs.Count -1 do
      begin
        if mEANs.BusinessObject[j].GetFieldValueAsString('EAN') = AStoreUnitJSON.A['StoreEANs'].O[i].S['EAN'] then
          mExistingEAN_ID:= mEANs.BusinessObject[j].GetFieldValueAsString('EAN');
      end;  }

      if NxIsEmptyOID(mExistingEAN_ID) then
      begin
        mEANBO:= mEANs.AddNewObject;
        mEANBO.SetFieldValueAsString('EAN', AStoreUnitJSON.A['StoreEANs'].O[i].S['EAN'] );
      end;
    end;
  except
    ALog:= ALog + 'HandleEANs - Error: '+ExceptionMessage+ nxCrLf;
  end;
end;


procedure HandleStoreContainers(AOS: TNxCustomObjectSpace; var AUnitBO: TNxCustomBusinessObject; const AStoreUnitJSON: TJSONSuperObject; var ALog: string);
var
  mStoreContainers: TNxCustomBusinessMonikerCollection;
  mStoreContainerBO: TNxCustomBusinessObject;
  mContainerCard_ID, mContainerQUnit, mLocalLog: string;
  i: integer;
begin
  try
    if AStoreUnitJSON.N['StoreContainers'].DataType = jtNull then exit;
    mStoreContainers:= AUnitBO.GetLoadedCollectionMonikerForFieldCode(AUnitBO.GetFieldCode('StoreContainers'));

    for i:= 0 to mStoreContainers.Count -1 do
      mStoreContainers.BusinessObject[i].MarkForDelete;

    for i:= 0 to AStoreUnitJSON.A['StoreContainers'].Length -1 do
    begin
      mLocalLog:= '';
      mContainerCard_ID:= GetOrCreateStoreContainerCard(AOS,
        AStoreUnitJSON.A['StoreContainers'].O[i].S['StoreCardCode'],
        AStoreUnitJSON.A['StoreContainers'].O[i].S['StoreCardName'],
        AStoreUnitJSON.A['StoreContainers'].O[i].S['StoreAssortmentGroupCode'],
        AStoreUnitJSON.A['StoreContainers'].O[i].S['StoreCardEAN'],
        AStoreUnitJSON.A['StoreContainers'].O[i].S['StoreCardMainUnitCode'],
        AStoreUnitJSON.A['StoreContainers'].O[i].D['StoreCardMainUnitRate'],
        mLocalLog);

      if not NxIsBlank(mLocalLog) then
        RaiseException(mLocalLog);

      if not NxIsEmptyOID(mContainerCard_ID) then
      begin
        mContainerQUnit := AOS.SQLSelectFirstAsString(Format('SELECT Code FROM Units WHERE X_Code_CZ = ''%s''', [AStoreUnitJSON.A['StoreContainers'].O[i].S['QUnit']]), cDEFAULT_UNIT);

        mStoreContainerBO:= mStoreContainers.AddNewObject;
        mStoreContainerBO.SetFieldValueAsString('StoreCard_ID', mContainerCard_ID);
        mStoreContainerBO.SetFieldValueAsString('QUnit', mContainerQUnit);
        mStoreContainerBO.SetFieldValueAsFloat('UnitQuantity', AStoreUnitJSON.A['StoreContainers'].O[i].D['UnitQuantity']);
        mStoreContainerBO.SetFieldValueAsFloat('UnitRate', AStoreUnitJSON.A['StoreContainers'].O[i].D['UnitRate']);
      end;
    end;
  except
    ALog:= ALog + 'HandleStoreContainers - Error: '+ExceptionMessage + nxCrLf;
  end;
end;


procedure HandleStoreCardMaterials(const ABO: TNxCustomBusinessObject; const AInput: TJSONSuperObject; var ALog: string);
var
  mSCParamBO: TNxCustomBusinessObject;
  mOS: TNxCustomObjectSpace;
  mMaterialList: TStringList;
  mMaterial_ID: string;
  i: integer;
begin
  mOS:= ABO.ObjectSpace;
  try
    mMaterialList:= TStringList.Create;
    try
      mOS.SQLSelect(Format('SELECT ID FROM DefRollData WHERE CLSID = ''%s'' AND X_Rel_Def = ''%s'' AND X_Value_ID = ''%s''', [Class_BO_Relations, cREL_DEF_MATERIALS, ABO.OID]), mMaterialList);

      for i:= 0 to mMaterialList.Count -1 do
      begin
        mSCParamBO:= mOS.CreateObject(Class_BO_Relations);
        try
          mSCParamBO.Load(mMaterialList[i], nil);
          mSCParamBO.Delete;
        finally
          mSCParamBO.Free;
        end;
      end;

      for i:= 0 to AInput.A['data'].O[0].A['Materials'].Length -1 do
      begin
        mMaterial_ID:= GetOrCreateRollValue(mOS, Class_BO_ND_Materials, AInput.A['data'].O[0].A['Materials'].O[i].S['MaterialCode'], AInput.A['data'].O[0].A['Materials'].O[i].S['MaterialName']);
        mSCParamBO:= mOS.CreateObject(Class_BO_Relations);
        try
          mSCParamBO.New;
          mSCParamBO.SetFieldValueAsString('X_Rel_Def','06');
          mSCParamBO.SetFieldValueAsDateTime('X_DateTimeOfLastChange', Now);
          mSCParamBO.SetFieldValueAsString('X_Posindex',GetPosindex(mOS, ABO.OID,'06'));
          mSCParamBO.SetFieldValueAsString('X_Value_ID', ABO.OID);
          mSCParamBO.SetFieldValueAsString('X_Material_ID',mMaterial_ID);
          mSCParamBO.SetFieldValueAsFloat('X_NumericValue',AInput.A['data'].O[0].A['Materials'].O[i].D['X_NumericValue']);
          mSCParamBO.save;
        finally
          mSCParamBO.Free;
        end;
      end;
    finally
      mMaterialList.Free;
    end;
  except
    ALog:= ALog + 'HandleStoreCardMaterials - Error: '+ ExceptionMessage + nxCrLf;
  end;
end;


procedure HandleStoreCardParameters(const ABO: TNxCustomBusinessObject; AInput: TJSONSuperObject; var ALog: string; var AMessage: string);
var
  mSCParamBO: TNxCustomBusinessObject;
  mOS: TNxCustomObjectSpace;
  mParametersList: TStringList;
  mParam_ID, mRoll_ID: string;
  i: integer;
begin
  mOS:= ABO.ObjectSpace;
  try
    mParametersList:= TStringList.Create;
    try
      mOS.SQLSelect(Format('SELECT ID FROM DefRollData WHERE CLSID = ''%s'' AND X_Rel_Def = ''%s'' AND X_Value_ID = ''%s''', [Class_BO_Relations, cREL_DEF_PARAMETERS, ABO.OID]), mParametersList);
      for i:= 0 to mParametersList.count -1 do begin
        mSCParamBO:= mOS.CreateObject(Class_BO_Relations);
        try
          mSCParamBO.Load(mParametersList[i], nil);
          mSCParamBO.Delete;
        finally
          mSCParamBO.Free;
        end;
      end;

      for i:= 0 to AInput.A['data'].O[0].A['Parameters'].Length -1 do
      begin
        mParam_ID:= GetOrCreateParam(mOS, AInput.A['data'].O[0].A['Parameters'].O[i].S['ParameterCode'],
                                          AInput.A['data'].O[0].A['Parameters'].O[i].S['ParameterName'],
                                          AInput.A['data'].O[0].A['Parameters'].O[i].I['X_TypeOfValue'],
                                          AInput.A['data'].O[0].A['Parameters'].O[i].S['X_RollCLSID'],
                                          AInput.A['data'].O[0].A['Parameters'].O[i].S['X_BOCLSID']);

        if AInput.A['data'].O[0].A['Parameters'].O[i].I['X_TypeOfValue'] = 1 then
        begin
          mRoll_ID:= GetOrCreateRollValue(mOS,  AInput.A['data'].O[0].A['Parameters'].O[i].S['X_BOCLSID'],
                                                AInput.A['data'].O[0].A['Parameters'].O[i].S['RollValueCode'],
                                                AInput.A['data'].O[0].A['Parameters'].O[i].S['X_RollValueName']);
        end;

        mSCParamBO:= mOS.CreateObject(Class_BO_Relations);
        try
          mSCParamBO.New;
          mSCParamBO.SetFieldValueAsString('X_Rel_Def','10');
          mSCParamBO.SetFieldValueAsDateTime('X_DateTimeOfLastChange', Now);
          mSCParamBO.SetFieldValueAsString('X_Posindex', GetPosindex(mOS, ABO.OID,'10'));
          mSCParamBO.SetFieldValueAsString('X_Value_ID', ABO.OID);
          mSCParamBO.SetFieldValueAsString('X_Parameter_ID', mParam_ID);

          case AInput.A['data'].O[0].A['Parameters'].O[i].I['X_TypeOfValue'] of
            0: begin
              mSCParamBO.SetFieldValueAsString('X_ParamValue',AInput.A['data'].O[0].A['Parameters'].O[i].S['X_ParamValue']);
              mSCParamBO.SetFieldValueAsString('X_RollValueID','');
              mSCParamBO.SetFieldValueAsString('X_RollValueName','');
              mSCParamBO.SetFieldValueAsString('X_BOCLSID','');
              mSCParamBO.SetFieldValueAsFloat('X_NumericValue',0);
              mSCParamBO.SetFieldValueAsBoolean('X_BooleanValue',false);
              mSCParamBO.SetFieldValueAsBoolean('X_Variantni_polozka',false);
            end;

            1: begin
              mSCParamBO.SetFieldValueAsString('X_ParamValue','');
              mSCParamBO.SetFieldValueAsString('X_RollValueID',mRoll_ID);
              mSCParamBO.SetFieldValueAsString('X_RollValueName',AInput.A['data'].O[0].A['Parameters'].O[i].S['X_RollValueName']);
              mSCParamBO.SetFieldValueAsString('X_BOCLSID',AInput.A['data'].O[0].A['Parameters'].O[i].S['X_BOCLSID']);
              mSCParamBO.SetFieldValueAsFloat('X_NumericValue',0);
              mSCParamBO.SetFieldValueAsBoolean('X_BooleanValue',false);
              mSCParamBO.SetFieldValueAsBoolean('X_Variantni_polozka', AInput.A['data'].O[0].A['Parameters'].O[i].B['X_Variantni_polozka']);
            end;

            2: begin
              mSCParamBO.SetFieldValueAsString('X_ParamValue','');
              mSCParamBO.SetFieldValueAsString('X_RollValueID','');
              mSCParamBO.SetFieldValueAsString('X_RollValueName','');
              mSCParamBO.SetFieldValueAsString('X_BOCLSID','');
              mSCParamBO.SetFieldValueAsFloat('X_NumericValue',AInput.A['data'].O[0].A['Parameters'].O[i].D['X_NumericValue']);
              mSCParamBO.SetFieldValueAsBoolean('X_BooleanValue',false);
              mSCParamBO.SetFieldValueAsBoolean('X_Variantni_polozka',false);
            end;

            3: begin
              mSCParamBO.SetFieldValueAsString('X_ParamValue','');
              mSCParamBO.SetFieldValueAsString('X_RollValueID','');
              mSCParamBO.SetFieldValueAsString('X_RollValueName','');
              mSCParamBO.SetFieldValueAsString('X_BOCLSID','');
              mSCParamBO.SetFieldValueAsFloat('X_NumericValue',0);
              mSCParamBO.SetFieldValueAsBoolean('X_BooleanValue',AInput.A['data'].O[0].A['Parameters'].O[i].B['X_BooleanValue']);
              mSCParamBO.SetFieldValueAsBoolean('X_Variantni_polozka',false);
            end;
          end;

          mSCParamBO.save;
        finally
          mSCParamBO.Free;
        end;

        AMessage:= AMessage + ' ' + AInput.A['data'].O[0].A['Parameters'].O[i].S['ParameterName'];
      end;
    finally
      mParametersList.Free;
    end;
  except
    ALog:= ALog + 'HandleStoreCardParameters - Error: '+ExceptionMessage + nxCrLf;
  end;
end;



function GetOrCreateStoreAssortmentGroup(var AOS:TNxCustomObjectSpace;var aCode, aName:string):string;
var
 mStoreAssortementGroup_ID:string;
 mBO:TNxCustomBusinessObject;
 mParent_ID:string;
begin
 Result:='';
 if not(aCode='') then begin
   mStoreAssortementGroup_ID:= AOS.SQLSelectFirstAsString('SELECT ID FROM storeassortmentGroups WHERE Code = '+QuotedStr(ACode));
   if NxIsEmptyOID(mStoreAssortementGroup_ID) then begin
     mBO:=AOS.CreateObject(Class_StoreAssortmentGroup);
     try
       if Length(aCode)=7 then mParent_ID:=AOS.SQLSelectFirstAsString('SELECT ID FROM storeassortmentGroups WHERE Code = '+QuotedStr(AnsiLeftStr(ACode,4)));
       if Length(aCode)=10 then mParent_ID:=AOS.SQLSelectFirstAsString('SELECT ID FROM storeassortmentGroups WHERE Code = '+QuotedStr(AnsiLeftStr(ACode,7)));
       mBO.new;
       mbo.prefill;
       mbo.SetFieldValueAsString('Code',aCode);
       mBO.SetFieldValueAsString('Name',aName);
       if not(NxIsEmptyOID(mParent_ID)) then
        mBO.SetFieldValueAsString('Parent_ID',mParent_ID);
       mBO.save;
     finally
       mStoreAssortementGroup_ID:=mBO.oid;
       mbo.free;
     end;
   end;
  Result:=mStoreAssortementGroup_ID;
 end;
end;

function GetOrCreateIntrastatCode(AOS: TNxCustomObjectSpace; ACode, ADescription, AUnitCode: string; AConstantWeight: Extended; AOptionalWeight: Boolean): string;
var
  mIntrastat_ID: string;
  mBO: TNxCustomBusinessObject;
begin
  Result:='';
  if not(ACode='') then begin
    mIntrastat_ID:= AOS.SQLSelectFirstAsString('SELECT ID FROM IntrastatCommodities WHERE Code = '+QuotedStr(ACode));
    if NxIsEmptyOID(mIntrastat_ID) then begin
      mBO:= AOS.CreateObject(Class_IntrastatCommodity);
      try
        mBO.New;
        mBO.Prefill;
        mBO.SetFieldValueAsString('Code', ACode);
        mBO.SetFieldValueAsString('Description', ADescription);
        mBO.SetFieldValueAsString('UnitCode', AUnitCode);
        mBO.SetFieldValueAsFloat('ConstantWeight', AConstantWeight);
        mBO.SetFieldValueAsBoolean('WeightIsOptional', AOptionalWeight);
        mBO.Save
      finally
        mIntrastat_ID:= mBO.OID;
        mBO.Free;
      end;
    end;
    Result:= mIntrastat_ID;
  end;
end;

function GetPosindex(var AOS:TNxCustomObjectSpace;var aStoreCard_ID, aRelDef:string):string;
var
 mPosIndex:string;
begin
 mPosIndex:=AOS.SQLSelectFirstAsString('select max(X_posindex) from defrolldata where clsid='+QuotedStr(Class_BO_Relations)+
                                       'and hidden=''N'' and X_Value_ID='+QuotedStr(aStoreCard_ID)+' and X_Rel_Def='+QuotedStr(aRelDef),'');
 if NxIsBlank(mPosIndex) then mPosIndex:='01'
 else
  mPosIndex:= AnsiRightStr('0'+IntToStr(StrToInt(mPosIndex)+1),2);
 Result:=mPosindex;
end;


function GetOrCreateRollValue(var AOS:TNxCustomObjectSpace; var aBOCLSID, aCode, aName:string):string;
var
 mRollBO:TNxCustomBusinessObject;
 mRollID:string;
begin
  mRollID:=AOS.SQLSelectFirstAsString(
     ' Select id from defrolldata '+
     ' WHERE Hidden=''N'' AND CLSID='+QuotedStr(aBOCLSID)+
     ' AND Name='+QuotedStr(aName)+
     ' AND Code='+QuotedStr(aCode));
  if NxIsEmptyOID(mRollID) then begin
    mRollBO:=AOS.CreateObject(aBOCLSID);
    mRollBO.new;
    mRollBO.SetFieldValueAsString('Code',aCode);
    mRollBO.SetFieldValueAsString('Name',aName);
    mRollBO.save;
    mRollID:=mRollBO.OID;
    mRollBO.free;
  end;
  Result:=mRollID;
end;

function GetOrCreateParam(var AOS:TNxCustomObjectSpace;var AParamCode, AParamName:string;var ATypeInt:Integer;var aRollCLSID, ACLSID:string):String;
var
  mParSourceBO: TNxCustomBusinessObject;
  mParameterID: string;
begin
  mParameterID:= AOS.SQLSelectFirstAsString(
    ' SELECT ID FROM DefRollData '+
    ' WHERE Hidden=''N'' AND CLSID='+QuotedStr(Class_BOSCParameters)+
    ' AND Name='+QuotedStr(AParamName)+
    ' AND Code='+QuotedStr(AParamCode));
  if NxIsEmptyOID(mParameterID) then begin
    mParSourceBO:= AOS.CreateObject(Class_BOSCParameters);
    try
      mParSourceBO.New;
      mParSourceBO.Prefill;
      mParSourceBO.SetFieldValueAsString('Code', AParamCode);
      mParSourceBO.SetFieldValueAsString('Name', AParamName);
      mParSourceBO.SetFieldValueAsInteger('X_TypeOfValue', ATypeInt);
      mParSourceBO.SetFieldValueAsString('X_RollCLSID', ARollCLSID);
      mParSourceBO.SetFieldValueAsString('X_BOCLSID', ACLSID);
      mParSourceBO.Save;
      mParameterID:= mParSourceBO.OID;
    finally
      mParSourceBO.Free;
    end;
  end;
  Result:= mParameterID;
end;


function GetOrCreateStoreContainerCard(AOS: TNxCustomObjectSpace; ACode, AName, AAssotmentGroupCode, AEAN, AMainUnitCode: string;
                                        AMainUnitRate: Extended; var ALog: string): String;
const
  cVATRATE_ID = '02000XAT00';
  cSTORECARDCATEGORY_ID = '6000000101';
var
  mBO, mUnitBO, mEANBO: TNxCustomBusinessObject;
  mUnits, mEANs: TNxCustomBusinessMonikerCollection;
  mAssortmentGroup_ID, mStoreCardCategory_ID, mUnitCode: string;
  i: Integer;
begin
  Result:= AOS.SQLSelectFirstAsString(Format('SELECT ID FROM StoreCards WHERE Hidden = ''N'' AND Category = 4 AND Code = ''%s''', [ACode]));
  if NxIsEmptyOID(Result) then
  begin
    mUnitCode:= '';
    mBO:= AOS.CreateObject(Class_StoreCard);
    try
      try
        mBO.New;
        mBO.Prefill;
        mBO.SetFieldValueAsInteger('Category', 4);
        mBO.SetFieldValueAsString('Code', ACode);
        mBO.SetFieldValueAsString('Name', AName);

        mAssortmentGroup_ID:= AOS.SQLSelectFirstAsString(Format('SELECT ID FROM StoreAssortmentGroups WHERE Hidden = ''N'' AND Code = ''%s''', [AAssotmentGroupCode]));
        //mStoreCardCategory_ID:= AOS.SQLSelectFirstAsString(Format('SELECT ID FROM StoreCardCategories WHERE Hidden = ''N'' AND Code = ''%s''', [AStoreCardCategoryCode]));

        mBO.SetFieldValueAsString('StoreCardCategory_ID', cSTORECARDCATEGORY_ID);
        mBO.SetFieldValueAsString('StoreAssortmentGroup_ID', mAssortmentGroup_ID);
        mBO.SetFieldValueAsString('VATRate_ID', cVATRATE_ID);

        mUnits:= mBO.GetLoadedCollectionMonikerForFieldCode(mBO.GetFieldCode('StoreUnits'));
        //for i:= 0 to mUnits.Count -1 do
        //  mUnits.BusinessObject[i].Delete;
        if AMainUnitCode <> 'ks' then
          mUnitBO:= mUnits.AddNewObject
        else begin
          for i:= 0 to mUnits.Count -1 do
          begin
            mUnitBO:= mUnits.BusinessObject[i];
            if mUnitBO.GetFieldValueAsString('Code') = AMainUnitCode then
            begin
              mUnitCode:= AOS.SQLSelectFirstAsString(Format('SELECT Code FROM Units WHERE X_Code_CZ = ''%s'' ', [AMainUnitCode]),cDEFAULT_UNIT);
              mUnitBO.SetFieldValueAsString('Code', mUnitCode);
              mUnitBO.SetFieldValueAsFloat('UnitRate', AMainUnitRate);
            end;
          end;
        end;

        mEANs:= mUnitBO.GetLoadedCollectionMonikerForFieldCode(mUnitBO.GetFieldCode('StoreEANs'));
        mEANBO:= mEANs.AddNewObject;
        mEANBO.SetFieldValueAsString('EAN', AEAN);
        mBO.Save;
        Result:= mBO.OID;
      except
        ALog:= ALog + Format('GetOrCreateStoreContainerCard - Error: %s' + nxCrLf, [ExceptionMessage]);
      end;
    finally
      mBO.Free;
    end;
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

procedure OnFormCloseAction(Sender: TObject; var Action: TCloseAction);
begin
  if Action = caHide then TForm(Sender).ModalResult := mrCancel;
end;

begin
end.