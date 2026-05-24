uses '.lib';

// ===== SYNCHRONIZACE OBJEDÁVEK VYDANÝCH Z FIRMY =====
// Skript slouží pro odesílání dokladů objedávek vydaných v JSON formátu na vzdálené API
// Odesílané údaje zahrnují: hlavičku dokladu a řádky s detailem

procedure InitSite_Hook(Self: TSiteForm);
var
  mAction: TBasicAction;
begin
  mAction := Self.GetNewAction;
  mAction.ShowControl := True;
  mAction.ShowMenuItem := True;
  mAction.Name := 'actGetCardOverAPI';
  mAction.Caption := '##Karta z BMS##';
  mAction.Hint := 'Dohledá kartu na BMS a založí';
  mAction.Category := 'tabList';
  mAction.OnExecute := @GetCardOverAPI;
end;

Procedure GetCardOverAPI(sender:tcomponent);
var
  mSite: TSiteForm;
  mCode, mStoreCardID, mRemoteStoreCardID: string;
  mStoreCardJSON, mResultJSON, mJSON: TJSONSuperObject;
  mStoreCardArray: TJSONSuperObjectArray;
  mList: TStringList;
  mBO, mUnitBO, mEANBO, mStorePriceBO, mStorePriceRowBO: TNxCustomBusinessObject;
  mUnits, mEANs, mStorePrices: TNxCustomBusinessMonikerCollection;
  i,j: integer;
begin
  mSite := TComponent(Sender).BusRollSite;
  mCode := Trim(InputBox('BMS skladová karta', 'Zadejte kód skladové karty', ''));
  if mCode = '' then
    Exit;

  mStoreCardID := mSite.BaseObjectSpace.SQLSelectFirstAsString(
    'Select id from storecards where code='+QuotedStr(mCode)+' and hidden=''N''', '');

  if not NxIsEmptyOID(mStoreCardID) then
  begin
    NxShowSimpleMessage('Skladová karta ''' + mCode + ''' již existuje v aktuální databázi.', mSite);
  
    Exit;
  end;

  mRemoteStoreCardID := '';
  mStoreCardJSON := API_GET(
    'https://api.barton.cz:8444/barton/Storecards?select=id,code,name&where=code eq '+QuotedStr(mCode)+' and hidden eq ''N''');
  try
    mStoreCardArray := mStoreCardJSON.AsArray;
    if mStoreCardArray.Length = 1 then
    begin
      mRemoteStoreCardID := mStoreCardArray.O[0].S['id'];
    end else begin
      NxShowSimpleMessage('Karta podle kódu ' + mCode + ' nebyla nalezena na BMS.', mSite);
      Exit;
    end;
  finally
    mStoreCardJSON.Free;
  end;

  if not(NxIsEmptyOID(mRemoteStoreCardID)) then
  begin
    mJSON := TJSONSuperObject.Create;
    try
      mJSON.S['id']:=mremoteStoreCardID;
      mResultJSON := API_POST(mJSON, 'StoreCards', True);
    finally
      //mJSON.Free;
    end;

    try
      //Nxshowsimplemessage('InputJson'+mJSON.AsString+NxCrlF+'ResultJSON '+mResultJSON.AsString, mSite);
      if Assigned(mResultJSON) and (mResultJSON.I['error_code']>0) then
         NxShowsimplemessage('Chyba při založení skladové karty. '+inttostr(mResultJSON.I['error_code'])+nxcrlf+mresultjson.S['description'], mSite);
      if Assigned(mResultJSON) and not NxIsEmptyOID(mResultJSON.S['ID']) then
      begin
       //NxShowsimplemessage(mresultjson.AsString, mSite);
       
        mBO:= mSite.BaseObjectSpace.CreateObject(Class_StoreCard);
        mBO.new;
        mBO.prefill;
        mBO.SetFieldValueAsString('Code', mResultJSON.S['Code']);
        mBO.SetFieldValueAsString('Name', mResultJSON.S['Name']);
        mBO.SetfieldvalueasString('Specification', mResultJSON.S['Specification']);
        mBO.SetFieldvalueAsString('StoreCardCategory_ID', 
         mSite.BaseObjectSpace.SQLSelectFirstAsString('select id from storecardcategories where code='+QuotedStr(mResultJSON.S['StoreCardCategoryCode'])+' and hidden=''N''', ''));
        mBO.SetFieldvalueasstring('Vatrate_ID',mresultJSON.S['VATRate_ID']);
        mBO.SetFieldvalueasstring('X_ISO',mresultJSON.S['X_ISO']);
        mbo.SetFieldValueasString('X_Din',mresultJSON.S['X_DIN']);
        mBO.SetFieldvalueasstring('X_CSN',mresultJSON.S['X_CSN']);
        mBO.SetFieldvalueasstring('X_Name_35',mresultJSON.S['X_Name_35']);
        MBO.SetFieldvalueasstring('X_Rozmer',mresultJSON.S['X_Rozmer']);
        mBO.Setfieldvalueasinteger('X_delka',mresultJSON.I['X_Delka']);
        mBO.Setfieldvalueasinteger('X_Prumer',mresultJSON.I['X_Prumer']);
        mBO.Setfieldvalueasinteger('X_Typ_Zavitu',mresultJSON.I['X_Typ_Zavitu']);
        mUnits:=mBO.GetLoadedCollectionMonikerForFieldCode(mBO.GetFieldCode('StoreUnits'));
        for i:=0 to munits.count-1 do
          mUnits.businessobject[i].MarkForDelete;
        for i:=0 to mResultJSON.A['StoreUnits'].Length-1 do begin
          mUnitBO:=mUnits.AddNewObject;
          mUnitBO.SetFieldValueAsString('Code', mResultJSON.A['StoreUnits'].O[i].S['Code']);
          mUnitBO.SetFieldValueAsString('EAN', mResultJSON.A['StoreUnits'].O[i].S['EAN']);
          mUnitBO.SetFieldValueAsInteger('PLU', mResultJSON.A['StoreUnits'].O[i].I['PLU']);
          mUnitBO.SetFieldValueAsString('Description', mResultJSON.A['StoreUnits'].O[i].S['Description']);
          mUnitBO.SetFieldValueAsFloat('UnitRate', mResultJSON.A['StoreUnits'].O[i].D['UnitRate']);
          mEANs:=mUnitBO.GetLoadedCollectionMonikerForFieldCode(mUnitBO.GetFieldCode('StoreEANs'));
          for j:=0 to mResultJSON.A['StoreUnits'].O[i].A['EANs'].Length-1 do begin
           if not(mResultJSON.A['StoreUnits'].O[i].A['EANs'].O[j].S['EAN']=mResultJSON.A['StoreUnits'].O[i].S['EAN']) then begin
             mEANBO:=mEANs.AddNewObject;
             mEANBO.SetFieldValueAsString('EAN', mResultJSON.A['StoreUnits'].O[i].A['EANs'].O[j].S['EAN']);
            end;
          end;
        end; 

        mBO.SetFieldvalueasstring('MainUnitCode',mresultJSON.S['MainUnitCode']);
        mBO.SetFieldvalueasstring('StoreAssortmentGroup_ID',
         mSite.BaseObjectSpace.SQLSelectFirstAsString('select id from StoreAssortmentGroups where code='+QuotedStr(mResultJSON.S['StoreAssortmentGroupCode'])+' and hidden=''N''', ''));  
        mbo.setfieldvalueasstring('X_BMS_Material_ID',mSite.BaseObjectSpace.SQLSelectFirstAsString('select id from defrolldata where code='
          +QuotedStr(mResultJSON.S['BMSMaterialCode'])+' and clsid='+QuotedStr(Class_BMS_material)+' and hidden=''N''', ''));
        mbo.setfieldvalueasstring('X_BMS_Skupina_ID',mSite.BaseObjectSpace.SQLSelectFirstAsString('select id from defrolldata where code='
          +QuotedStr(mResultJSON.S['BMSSkupinaCode'])+' and clsid='+QuotedStr(Class_BMS_skupina)+' and hidden=''N''', ''));
        mbo.setfieldvalueasstring('X_BMS_povrchUprava_ID',mSite.BaseObjectSpace.SQLSelectFirstAsString('select id from defrolldata where code='
          +QuotedStr(mResultJSON.S['BMSPovrchCode'])+' and clsid='+QuotedStr(Class_BMS_povrch_uprava)+' and hidden=''N''', ''));
        mbo.setfieldvalueasstring('X_BMS_tvarhlava_ID',mSite.BaseObjectSpace.SQLSelectFirstAsString('select id from defrolldata where code='
          +QuotedStr(mResultJSON.S['BMSTvarHlavaCode'])+' and clsid='+QuotedStr(Class_BMS_tvar_hlavy)+' and hidden=''N''', ''));
        mbo.setfieldvalueasstring('X_BMS_Obal_ID',mSite.BaseObjectSpace.SQLSelectFirstAsString('select id from defrolldata where code='
          +QuotedStr(mResultJSON.S['BMSObalCode'])+' and clsid='+QuotedStr(Class_BMS_obal)+' and hidden=''N''', '')); 
        mbo.save;
        mStoreCardID := mbo.OID;
        if mresultJSON.D['Price']>0 then begin
            mStorePriceBO:=mSite.BaseObjectSpace.CreateObject(Class_StorePrice);
            mStorePriceBO.new;
            mStorePriceBO.prefill;
            mStorePriceBO.SetFieldValueAsString('PriceList_ID','1000000101');
            mStorePriceBO.SetFieldValueAsString('StoreCard_ID',mStoreCardID);
            mStorePrices:=mStorePriceBO.GetLoadedCollectionMonikerForFieldCode(mStorePriceBO.GetFieldCode('PriceRows'));
            mStorePriceRowBO:=mStorePrices.AddNewObject;
            mStorePriceRowBO.SetFieldValueAsString('Price_ID','1000000101');
            mStorePriceRowBO.SetFieldValueAsFloat('Amount',mresultJSON.D['Price']);
            mStorePriceRowBO.SetFieldValueAsString('Qunit',mresultJSON.S['MainUnitCode']);
            mStorePriceBO.save;
            mStorePriceBO.free;
        end;
          
        mBO.free;
        TBusRollSiteForm(mSite).DataSet.SeekID(mStoreCardID);
      end
      else
      begin
        NxShowSimpleMessage('Chyba při založení skladové karty: ' + mResultJSON.S['Code'] + ' ' + mResultJSON.S['Status'], mSite);
        Exit;
      end;
    finally
      mResultJSON.Free;
    end;
  end
  else
  begin
    NxShowSimpleMessage('Skladová karta již existuje na BMS: ' + mCode, mSite);
  end;

end;

begin
end.