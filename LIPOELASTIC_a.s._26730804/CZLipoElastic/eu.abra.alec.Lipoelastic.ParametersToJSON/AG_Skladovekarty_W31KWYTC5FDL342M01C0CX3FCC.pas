uses '.lib';

{
Vyvolává se po provedení inicializace agendy/formuláře. V tento okamžik je již na formuláři dostupný SiteContext.
}
procedure InitSite_Hook(Self: TSiteForm);
var
  mAction: TMultiAction;
begin
  mAction:= Self.GetNewMultiAction;
  mAction.Caption:= '##ParamToJSON TEST##';
  mAction.Items.Add('##ParamToJSON TEST##');
  maction.Items.Add('##JSONToParam TEST##');
  mAction.Category:= 'tabList';
  mAction.OnExecuteItem:= @ParameterJSONSwitch;
end;

procedure ParameterJSONSwitch(Sender: Tcomponent; AIndex: Integer;);
var
  mBO: TNxCustomBusinessObject;
  mSite: TSiteForm;
  i: integer;
  mList: TStringList;
  mLogStr: string;
begin
  mLogStr:= '';
  mSite:= Sender.Site;
  mList:= TStringList.Create;
  try
    TBusRollSiteForm(mSite).FillListWithSelectedRows(mList);
    if AIndex = 0 then begin
      for i:=0 to mList.Count -1 do begin
        mBO:= mSite.BaseObjectSpace.CreateObject(Class_StoreCard);
        try
          mBO.Load(mList[i], nil);
          TestParamToJSON(mBO, mLogStr);
        finally
          mBO.Free;
        end;
      end;
    end;

    if AIndex = 1 then begin


    end;
    {
    case AIndex of
      0 : TestParamToJSON(Sender);
      1 : TestJSONToParam(Sender);
    end;  }
  finally
    mList.Free;
  end;
end;

procedure TestParamToJSON(ABO: TNxCustomBusinessObject; var AResultStr: string;);
var
  mOS: TNxCustomObjectSpace;
  mBO, mPARBO, mParSourceBO, mTempBO, mUnitBO, mEANBO: TNxCustomBusinessObject;
  mUnits, mStoreEans: TNxCustomBusinessMonikerCollection;
  mList, mMatList: TStringList;
  i, j: integer;
  mJSON, mJSON2, mJSON3, mResultJSON: TJSONSuperObject;
  mRollValueCode, mTableName, mMainSupplierFirmCode: string;
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
      mJSON.A['data'].O[0].S['ForeignName']:= ABO.GetFieldValueAsString('ForeignName');
      mJson.A['data'].O[0].S['NameSK']:= ABO.GetFieldValueAsString('X_Name_SK');
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
      //KONEC ZÁKLADNÍCH DAT********************************************************************************


      //SEKCE JEDNOTEK********************************************************************************
      mUnits:=ABO.GetLoadedCollectionMonikerForFieldCode(ABO.GetFieldCode('StoreUnits'));
      mJSON.A['data'].O[0].O['StoreUnits'] := mJSON.CreateJSONArray;
      for i:=0 to mUnits.count-1 do begin
        mUnitBO:=mUnits.BusinessObject[i];
        mJSON2:=TJSONSuperObject.Create;
        mJSON2.S['Code']:=mUnitBO.GetFieldValueAsString('Code');
        mJSON2.D['UnitRate']:=mUnitBO.GetFieldValueAsFloat('UnitRate');
        mJSON2.S['Description']:=mUnitBO.GetFieldValueAsString('Description');
        mJSON2.D['Weight']:=mUnitBO.GetFieldValueAsFloat('Weight');
        mJSON2.I['WeightUnit']:=mUnitBO.GetFieldValueAsInteger('WeightUnit');
        mJSON2.D['Capacity']:=mUnitBO.GetFieldValueAsFloat('Capacity');
        mJSON2.I['CapacityUnit']:=mUnitBO.GetFieldValueAsInteger('CapacityUnit');
        mStoreEans:=mUnitBO.GetLoadedCollectionMonikerForFieldCode(mUnitBO.GetFieldCode('StoreEans'));
        if mStoreEANS.count>0 then begin
          mJSON2.O['StoreEANs']:=mJSON2.CreateJSONArray;
          for j:=0 to mStoreEANS.count-1 do begin
            mEANBO:=mStoreEANS.BusinessObject[j];
            mJSON3:=TJSONSuperObject.create;
            mJSON3.S['EAN']:=mEanBO.GetFieldValueAsString('EAN');
            mJSON2.A['StoreEANs'].add(mJSON3);
          end;
        end;
        mJSON.A['data'].O[0].A['StoreUnits'].Add(mJSON2);
      end;
      //KONEC JEDNOTEK********************************************************************************

      //VLASTNOSTI SKLADOVÝCH KARET********************************************************************************
      mMainSupplierFirmCode:= mOS.SQLSelectFirstAsString(
        ' SELECT FI.Code FROM Suppliers SU '+
        ' JOIN Firms FI ON Fi.ID = SU.Firm_ID '+
        ' WHERE SU.ID ='+QuotedStr(ABO.GetFieldValueAsString('MainSupplier_ID')));

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
          mJSON.A['data'].O[0].O['Parameters'].AsArray.O[i].I['X_TypeOfValue']:= mParSourceBO.GetFieldValueAsInteger('X_TypeOfValue');
          mJSON.A['data'].O[0].O['Parameters'].AsArray.O[i].S['X_RollCLSID']:= mParSourceBO.GetFieldValueAsString('X_RollCLSID');

          mJSON.A['data'].O[0].O['Parameters'].AsArray.O[i].S['X_ParamValue']:= mPARBO.GetFieldValueAsString('X_ParamValue');
          mJSON.A['data'].O[0].O['Parameters'].AsArray.O[i].S['X_BOCLSID']:= mPARBO.GetFieldValueAsString('X_BOCLSID');
          mJSON.A['data'].O[0].O['Parameters'].AsArray.O[i].S['X_RollValueID']:= mPARBO.GetFieldValueAsString('X_RollValueID');
          mJSON.A['data'].O[0].O['Parameters'].AsArray.O[i].S['TableName']:= mTableName;
          mJSON.A['data'].O[0].O['Parameters'].AsArray.O[i].S['RollValueCode']:= mRollValueCode;
          mJSON.A['data'].O[0].O['Parameters'].AsArray.O[i].S['X_RollValueName']:= mPARBO.GetFieldValueAsString('X_RollValueName');
          mJSON.A['data'].O[0].O['Parameters'].AsArray.O[i].D['X_NumericValue']:= mPARBO.GetFieldValueAsFloat('X_NumericValue');
          mJSON.A['data'].O[0].O['Parameters'].AsArray.O[i].B['X_BooleanValue']:= mPARBO.GetFieldValueAsBoolean('X_BooleanValue');
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
          mJSON.A['data'].O[0].O['Materials'].AsArray.O[i].D['X_NumericValue']:= mPARBO.GetFieldValueAsFloat('X_NumericValue');
        finally
          mPARBO.Free;
          mParSourceBO.Free;
        end;
      end;
      //SEKCE MATERIÁLY ****************************************************************
      //mJSON.SaveToFile('C:\Users\acoufal\Desktop\ABRA temp\JSON\param.json', true, true);
      mResultJSON:= TJSONSuperObject.Create;
      mResultJSON:= API_POST(mJSON, 'StoreCards2');
      NxShowEditorSite(NxCreateContext(mOS), mJSON.AsString +nxCrLf+ mResultJSON.AsString, True);
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


procedure TestJSONToParam(Sender: TComponent);
var
  mSite: TSiteForm;
  mOS: TNxCustomObjectSpace;
  mBO, mPARBO, mParSourceBO, mTempBO: TNxCustomBusinessObject;
  mList: TStringList;
  i: integer;
  mJSON, mJSONData: TJSONSuperObject;
  mRollValueCode, mTableName, mInput: string;
  mParameterID, mParameterName, mX_RollCLSID, mX_BOCLSID, mStoreCard_ID: string;
  mX_TypeOfValue: integer;
begin
  mSite:= Sender.Site;
  mOS:= mSite.BaseObjectSpace;
  mBO:= TBusRollSiteForm(mSite).CurrentObject;
  mList:= TStringList.Create;
  mJSON:= TJSONSuperObject.Create;

  mInput:= 'C:\Users\acoufal\Desktop\ABRA temp\JSON\param.json';
  try
    mJSON:= mJSONData.ParseFile(mInput, false);

    mParameterName:= mJSON.A['data'].O[0].A['Parameters'].O[0].S['ParameterName'];
    mX_TypeOfValue:= mJSON.A['data'].O[0].A['Parameters'].O[0].I['X_TypeOfValue'];
    mX_RollCLSID:=   mJSON.A['data'].O[0].A['Parameters'].O[0].S['X_RollCLSID'];
    mX_BOCLSID:=     mJSON.A['data'].O[0].A['Parameters'].O[0].S['X_BOCLSID'];

    NxShowSimpleMessage(mJSON.AsString, mSite);
    exit;

    mParameterID:= GetOrCreateSCParameter(mOS, mParameterName, mX_BOCLSID, mX_RollCLSID, mX_TypeOfValue);
    mStoreCard_ID:= mOS.SQLSelectFirstAsString('SELECT ID FROM StoreCards WHERE Hidden=''N'' AND Code='+QuotedStr(mJSON.A['data'].O[0].S['Code']));
    if not(NxIsEmptyOID(mStoreCard_ID)) then begin
      //nahrát relations
    end;






    mOS.SQLSelect('SELECT ID FROM DefRollData WHERE CLSID = ''2TIIQXNXIXK4B5CZUIZ20K2W10'' AND X_Rel_Def = ''10'' AND X_Value_ID = '+QuotedStr(mBO.OID), mList);
    mJSON.O[mBO.OID]:= mJSON.CreateJSON;
    mJSON.O[mBO.OID] := mJSON.CreateJSONArray;
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

        mTempBO:= mOS.CreateObject(mPARBO.GetFieldValueAsString('X_BOCLSID'));
        try
          mTableName:= NxGetTableNameForPersistCLSID(mTempBO.PersistCLSID);
        finally
          mTempBO.Free;
        end;

        mJSON.O[mBO.OID].AsArray.O[i]:= mJSON.CreateJSON;
        mJSON.O[mBO.OID].AsArray.O[i].S['Parameter_ID']:= mPARBO.OID;
        mJSON.O[mBO.OID].AsArray.O[i].S['ParameterCode']:= mParSourceBO.GetFieldValueAsString('Code');
        mJSON.O[mBO.OID].AsArray.O[i].S['ParameterName']:= mParSourceBO.GetFieldValueAsString('Name');
        mJSON.O[mBO.OID].AsArray.O[i].I['ParameterValueType']:= mParSourceBO.GetFieldValueAsInteger('X_TypeOfValue');
        mJSON.O[mBO.OID].AsArray.O[i].S['ParameterValue']:= mPARBO.GetFieldValueAsString('X_ParamValue');
        mJSON.O[mBO.OID].AsArray.O[i].S['BOCLSID']:= mPARBO.GetFieldValueAsString('X_BOCLSID');
        //mJSON.O[mBO.OID].AsArray.O[i].S['RollCLSID']:= mPARBO.GetFieldValueAsString('X_RollCLSID');
        mJSON.O[mBO.OID].AsArray.O[i].S['RollValueID']:= mPARBO.GetFieldValueAsString('X_RollValueID');
        mJSON.O[mBO.OID].AsArray.O[i].S['TableName']:= mTableName;
        mJSON.O[mBO.OID].AsArray.O[i].S['RollValueCode']:= mRollValueCode;
        mJSON.O[mBO.OID].AsArray.O[i].S['RollValueName']:= mPARBO.GetFieldValueAsString('X_RollValueName');
        mJSON.O[mBO.OID].AsArray.O[i].D['NumericValue']:= mPARBO.GetFieldValueAsFloat('X_NumericValue');
        mJSON.O[mBO.OID].AsArray.O[i].B['BooleanValue']:= mPARBO.GetFieldValueAsBoolean('X_BooleanValue');

        //NxShowSimpleMessage(mJSON.AsString, mSite);
        //exit;
      finally
        mPARBO.Free;
        mParSourceBO.Free;
      end;
    end;
    NxShowEditorSite(NxCreateContext(mOS), mJSON.AsString, True);
  finally
    //ABO.Free;
    mList.Free;
    mJSON.Free;
  end;
end;


function GetOrCreateSCParameter(AOS: TNxCustomObjectSpace; AParamName, ACLSID, ARollCLSID: string; ATypeInt: integer):string;
var
  mParSourceBO: TNxCustomBusinessObject;
  mParameterID: string;
begin
  mParameterID:= AOS.SQLSelectFirstAsString(
    ' SELECT ID FROM DefRollData '+
    ' WHERE Hidden=''N'' AND CLSID='+QuotedStr(Class_BOSCParameters)+
    ' AND Name='+QuotedStr(AParamName));
  if NxIsEmptyOID(mParameterID) then begin
    mParSourceBO:= AOS.CreateObject(Class_BOSCParameters);
    try
      mParSourceBO.New;
      mParSourceBO.Prefill;
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

 {
    mDS:= TMemoryDataset.Create;
    try
      mOS.SQLSelect2(
        ' SELECT DRD2.Code AS ParameterCode, '+
        ' DRD2.name AS ParameterName, '+
        ' DRD2.X_TypeOfValue AS Type, '+
        ' DRD1.X_Parameter_ID AS ParameterID , '+
        ' DRD1.X_ParamValue AS ParameterValue, '+
        ' DRD1.X_RollValueID AS RollID, '+
        ' DRD1.X_RollCLSID AS RollCLSID, '+
        ' DRD1.X_BOCLSID AS BOCLSID '+
        ' FROM DefRollData DRD1 '+
        ' LEFT JOIN DefRollData DRD2 ON DRD2.ID = DRD1.X_Parameter_ID '+
        ' WHERE DRD1.CLSID = ''2TIIQXNXIXK4B5CZUIZ20K2W10'' AND DRD1.X_Rel_Def = ''10'' '+
        ' AND DRD1.X_Value_ID = '+QuotedStr(ABO.OID), mDS);
      if mDS.Active then begin
        mDS.First;
        while not mDS.Eof do begin
          if mDS.FieldByName('Type').AsInteger = 1 then begin
            mJSON.S['']
          end;
          mDS.Next;
        end;
      end;
    finally
      mds.Free;
    end;
    }

begin
end.