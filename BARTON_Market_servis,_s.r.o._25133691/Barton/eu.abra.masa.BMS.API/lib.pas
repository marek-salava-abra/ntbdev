function POST_StoreCards(AContext: TNXContext; AInput: TJSONSuperObject; APath: String): TJSONSuperObject;
var
    mOS: TNxCustomObjectSpace;
    mCode, mName, mErrorMessage: string;
    mStoreUnitJSON, mEANJSON: TJSONSuperObject;
    mBO, mUnitBO, mEANBO: TNxCustomBusinessObject;
    mUnits, mEANs: TNxCustomBusinessMonikerCollection;
    i,j,k: integer;
    mSite: TDynSiteForm;
begin
  Result := TJSONSuperObject.Create; 
  mOS := AContext.GetObjectSpace;
  mBO:=mOS.createobject(Class_StoreCard);
  mbo.load(AInput.S['id'],nil);
   result.S['ID']:=mBO.OID;
   Result.S['Code']:=mBO.GetFieldValueAsString('Code');
   result.s['Name']:=mBO.GetFieldValueAsString('Name');
   Result.S['StoreCardCategoryCode']:=mBO.GetFieldValueAsString('StoreCardCategory_ID.Code');
   //Result.S['StoreMenuText']:=mBO.GetFieldValueAsString('StoreMenuItem_ID.Text');
   Result.S['StoreMenuText']:=mBO.GetFieldValueAsString('StoreMenuItem_ID.Text');
   Result.S['VATRate_ID']:= mBO.GetFieldValueAsString('VATRate_ID');
   REsult.S['MainUnitCode']:=mBO.GetFieldValueAsString('MainUnitCode');
   Result.S['X_Name_35']:=mBO.GetFieldValueAsString('x_Name_35');
   Result.S['X_DIN']:=mBO.GetFieldValueAsString('x_DIN');
   Result.S['X_ISO']:=mBO.GetFieldValueAsString('x_ISO');
   Result.S['X_CSN']:=mBO.GetFieldValueAsString('x_CSN');
   Result.S['X_Rozmer']:=mBO.GetFieldValueAsString('X_Rozmer');
   Result.S['StoreAssortmentGroupCode']:=mBO.GetFieldValueAsString('StoreAssortmentGroup_ID.Code');
   Result.S['BMSMaterialCode']:=mBO.GetfieldValueAsString('X_BMS_Material_ID.Code');
   Result.S['BMSSkupinaCode']:=mBO.GetfieldValueAsString('X_BMS_Skupina_ID.Code');
   Result.S['BMSPovrchCode']:=mBO.GetfieldValueAsString('X_BMS_povrchUprava_ID.Code');
   Result.S['BMSTvarHlavaCode']:=mBO.GetfieldValueAsString('X_BMS_tvarhlava_ID.Code');
   Result.S['BMSObalCode']:=mBO.GetfieldValueAsString('X_BMS_Obal_ID.Code');
   Result.S['Specification']:=mBO.GetFieldValueAsString('Specification');
   Result.I['X_Prumer']:=mBO.GetFieldValueAsInteger('X_Prumer');
   Result.I['X_Delka']:=mBO.GetFieldValueAsInteger('X_delka');
   Result.I['X_Typ_Zavitu']:=mBO.GetFieldValueAsInteger('X_Typ_Zavitu');
   Result.O['StoreUnits']:=Result.CreateJSONArray;
   munits:=mBO.GetLoadedCollectionMonikerForFieldCode(mBO.GetFieldCode('StoreUnits'));
   for i:=0 to munits.count-1 do begin
     mUnitBO:=munits.BusinessObject[i];
     mStoreUnitJSON:=TJSONSuperObject.Create;
     mStoreUnitJSON.S['Code']:=mUnitBO.GetFieldValueAsString('Code');
     mStoreUnitJSON.S['EAN']:=mUnitBO.GetFieldValueAsString('EAN');
     mStoreUnitJSON.I['PLU']:=mUnitBO.GetFieldValueAsInteger('PLU');
     mStoreUnitJSON.S['Description']:=mUnitBO.GetFieldValueAsString('Description');
     mStoreunitjson.D['UnitRate']:=mUnitBO.GetFieldValueAsFloat('UnitRate');
     mStoreunitJSON.O['EANs']:=mStoreUnitJSON.CreateJSONArray;
     means:=mUnitBO.GetLoadedCollectionMonikerForFieldCode(mUnitBO.GetFieldCode('StoreEANs'));
     for j:=0 to means.count-1 do begin
       mEANBO:=means.BusinessObject[j];
       mEANJSON:=TJSONSuperObject.Create;
       mEANJSON.S['EAN']:=mEANBO.GetFieldValueAsString('EAN');
       mStoreUnitJSON.A['EANs'].Add(mEANJSON);
     end;
     result.A['StoreUnits'].Add(mStoreUnitJSON);
   end;
  mbo.free;
 end;   

function POST_IssuedOrders(AContext: TNXContext; AInput: TJSONSuperObject; APath: String): TJSONSuperObject;
var
 mHeaderBO, mRowBO, mIORowBO:TNxCustomBusinessObject;
 i,j:integer;
 mRows, mIORows:TNxCustomBusinessMonikerCollection;
 mOS:TNxCustomObjectSpace;
 mDocQueue_ID, mStore_ID, mDivision_ID, mIODocQueue_ID, mMainSupplier_ID, mReceivedOrder_ID,mBusProject_ID, mNotFoundCard, mStoreCard_ID, mFirm_ID:string;
 mInputParams:TNxParameters;
 mParam:TNxParameter;
 mImportMan: TNxDocumentImportManager;
begin
 Result := TJSONSuperObject.Create;
 mOS:=AContext.GetObjectSpace;
 CFxLog.SaveLog(NxCreateContext(mOS),'LA','DataOrder '+AInput.S['IssuedOrder_ID'],AInput.AsString,2,Now);
  try
      mReceivedOrder_ID:=mOS.SQLSelectFirstAsString('Select id from receivedorders where X_IssuedOrderID='+QuotedStr(AInput.S['IssuedOrder_ID']),'');
      if NxIsEmptyOID(mReceivedOrder_ID) then begin
          mHeaderBO:=mOS.CreateObject(Class_ReceivedOrder);
          mHeaderBO.New;
          mHeaderBO.prefill;
          mNotFoundCard:='';
          mDocQueue_ID:='I700000101';
          mHeaderBO.SetFieldValueAsString('DocQueue_ID',mDocQueue_ID);
          mHeaderBO.SetFieldValueAsString('ExternalNumber',AInput.S['DocumentNumber']);
          mHeaderBO.SetFieldValueAsString('Description',AInput.S['Description']);
          mHeaderBO.SetFieldValueAsString('X_IssuedOrderID',AInput.S['IssuedOrder_ID']);
          mFirm_ID:=mOS.SQLSelectFirstAsString('select id from firms where hidden='+QuotedStr('N')+' and firm_id is null and orgidentnumber='+QuotedStr(AInput.S['FirmOrgIdentNumber']),'');
          mheaderBO.SetFieldValueAsString('Firm_ID',mFirm_ID);
          mHeaderBO.setfieldvalueasboolean('X_FromAPI',true);
          mRows:=mHeaderBO.GetLoadedCollectionMonikerForFieldCode(mHeaderBO.GetFieldCode('Rows'));
           for i:= 0 to AInput.A['Rows'].Length -1 do begin
             mRowBO:=mRows.AddNewObject;
             mrowBO.Prefill;
             mStore_ID:='1210000101';
             mDivision_ID:='2100000101';
             mRowBO.SetFieldValueAsInteger('RowType', AInput.A['Rows'].O[i].I['RowType']);
             if not(NxIsEmptyOID(AInput.A['Rows'].O[i].S['Row_ID'])) then
              mRowBO.SetFieldValueAsString('X_IssuedOrderRowID',AInput.A['Rows'].O[i].S['Row_ID']);
             mRowBO.SetFieldValueAsString('Division_ID',mDivision_ID);
             if AInput.A['Rows'].O[i].I['RowType']=3 then begin
               mRowBO.SetFieldValueAsString('Store_ID',mStore_ID);
               mStoreCard_ID:=mOS.SQLSelectFirstAsString('select id from storecards where hidden='+QuotedStr('N')+' and code='+QuotedStr(AInput.A['Rows'].O[i].S['StoreCardCode']),'');
               mRowBO.SetFieldValueAsString('StoreCard_ID',mStoreCard_ID);
               if NxIsEmptyOID(mStoreCard_ID) then mNotFoundCard:=mNotFoundCard+NxCrLf+AInput.A['Rows'].O[i].S['StoreCardCode'];
               //if NxIsEmptyOID(mMainSupplier_ID)  and not(NxIsEmptyOID(mIODocQueue_ID)) then mMainSupplier_ID:=mRowBO.GetFieldValueAsString('Storecard_id.MainSupplier_ID.Firm_ID');
               mRowBO.SetFieldValueAsFloat('Quantity',AInput.A['Rows'].O[i].D['Quantity']);
               //mRowBO.SetFieldValueAsFloat('UnitPrice',0);
               //mRowBO.SetFieldValueAsFloat('TotalPrice',0);
             end else begin
               if AInput.A['Rows'].O[i].I['RowType']=2 then begin
                mRowBO.SetFieldValueAsFloat('Quantity',AInput.A['Rows'].O[i].D['Quantity']);
                mrowBO.SetFieldValueAsString('QUnit',AInput.A['Rows'].O[i].S['QUnit']);
               end;
               mRowBO.SetFieldValueAsString('Text',AInput.A['Rows'].O[i].S['Text']);
             end;
           end;
          mHeaderBO.save;
          
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
        mHeaderBO.free;
      end;
  except
      Result.S['ID']:='';
      Result.S['Code']:=ExceptionMessage+nxCrLf+'Nenalezené karty:'+NxCrlF+mNotFoundCard;
      Result.S['Status']:='Error';
      mHeaderBO.Free;
  end;
end;

function API_PUT(aJSON:TJSONSuperObject; AObjectName, AID:string; aIndex: integer = 0):TJSONSuperObject;
var
 mWinHTTP:Variant;
 mResultJSON:TJSONSuperObject;
 mURL, mAuth:string;
begin
  try
    mWinHTTP:= CreateOleObject('WinHttp.WinHttpRequest.5.1');
    mWinHTTP.Open('PUT', 'https://api.barton.cz:8444/Srouby_Matice/' + AObjectName + '/' + AID + '?select=id');
    mWinHTTP.SetRequestHeader('Content-Type', 'application/json');
    mWinHTTP.SetRequestHeader('Authorization','Basic '+EncodeBase64(TEncoding.UTF8.GetBytes('API:ApiHeslo')));
    mWinHTTP.Send(aJSON.AsJson);
    Result:=TJSONSuperObject.ParseString(ConvertToText(mWinHTTP.Responsebody), True);
  except
    Result:=TJSONSuperObject.create;
    Result.S['error']:='error';
  end;
end;

function ConvertToText(aUnicodeBytes: TBytes): String;
var
  mUnicodeBites: TBytes;
begin
  mUnicodeBites := TEncoding.Convert(aUnicodeBytes,Encoding_cpUTF_8,Encoding_cpUTF_16);
  Result := TEncoding.Unicode.GetString(mUnicodeBites);
end;


begin
end.