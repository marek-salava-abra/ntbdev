const
  cSQL_X_Aktivni = ' AND X_Aktivni = ''A'' ';

{GET_StoreCardParams}

procedure GET_StoreCardParams(AContext:TNxContext; ARequest: TAPIRequest; AResponse: TAPIResponse);
var
  mList: TStringList;
  i: Integer;
  mStoreCard_ID, mRollValueCode,mTableName:string;
  mJSON, mParamJSON:TJSONSuperObject;
  mPARBO,mParSourceBO, mTempBO:TNxCustomBusinessObject;
  mOS:TNxCustomObjectSpace;
begin
  mJSON:=TJSONSuperObject.Create;
  try
    mList:=TStringList.Create;
    mStoreCard_ID:=ARequest.GetQueryParamValue('storecard_id');
    mOS:=AContext.GetObjectSpace;
    mOS.SQLSelect('SELECT ID FROM DefRollData WHERE CLSID = ''2TIIQXNXIXK4B5CZUIZ20K2W10'' AND X_Rel_Def = ''10'' AND X_Value_ID = '+QuotedStr(mStoreCard_ID), mList);
    mJSON.S['storecard_id']:=mStoreCard_ID;
    mJSON.O['parameters'] := mJSON.CreateJSONArray;
    for i:=0 to mlist.count-1 do begin
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

          mParamJSON:= mJSON.CreateJSON;
          mParamJSON.S['Parameter_ID']:= mPARBO.OID;
          mParamJSON.S['ParameterCode']:= mParSourceBO.GetFieldValueAsString('Code');
          mParamJSON.S['ParameterName']:= mParSourceBO.GetFieldValueAsString('Name');
          mParamJSON.I['X_TypeOfValue']:= mParSourceBO.GetFieldValueAsInteger('X_TypeOfValue');
          mParamJSON.S['X_RollCLSID']:= mParSourceBO.GetFieldValueAsString('X_RollCLSID');

          mParamJSON.S['X_ParamValue']:= mPARBO.GetFieldValueAsString('X_ParamValue');
          mParamJSON.S['X_BOCLSID']:= mPARBO.GetFieldValueAsString('X_BOCLSID');
          mParamJSON.S['X_RollValueID']:= mPARBO.GetFieldValueAsString('X_RollValueID');
          mParamJSON.S['TableName']:= mTableName;
          mParamJSON.S['RollValueCode']:= mRollValueCode;
          mParamJSON.S['X_RollValueName']:= mPARBO.GetFieldValueAsString('X_RollValueName');
          mParamJSON.D['X_NumericValue']:= mPARBO.GetFieldValueAsFloat('X_NumericValue');
          mParamJSON.B['X_BooleanValue']:= mPARBO.GetFieldValueAsBoolean('X_BooleanValue');
          mParamJSON.B['X_Variantni_polozka']:= mPARBO.GetFieldValueAsBoolean('X_Variantni_polozka');
          mJSON.A['parameters'].Add(mParamJSON);
        finally
          mPARBO.Free;
          mParSourceBO.Free;
        end;
      //SEKCE PARAMETRY****************************************************************
    end;
    AResponse.Body := mJSON.AsString;
    AResponse.SetHeader('Content-Type','application/json');
    AResponse.Status := 200;
  finally
    mList.Free;
  end;
end;

procedure GET_MaterialComposition(AContext:TNxContext; ARequest: TAPIRequest; AResponse: TAPIResponse);
var
  mList: TStringList;
  i: Integer;
  mStoreCard_ID, mChildSC_ID, mRollValueCode, mTableName, mMaterialHTML_CZ, mMaterialHTML_EN:string;
  mJSON, mMaterialJSON:TJSONSuperObject;
  mPARBO,mParSourceBO:TNxCustomBusinessObject;
  mOS:TNxCustomObjectSpace;
  mMaterialHTML_DE:string;
  mX_Name_Eshop_AT, mX_Name_Eshop_DE, mX_Name_Eshop_DK, mX_Name_Eshop_EN, mX_Name_Eshop_ES, mX_Name_Eshop_FR, mX_Name_Eshop_HU: string;
  mX_Name_Eshop_IT, mX_Name_Eshop_NL, mX_Name_Eshop_PL, mX_Name_Eshop_RU, mX_Name_Eshop_SK, mX_Name_Eshop_SA, mX_Name_Eshop_USA:string;

begin
  mJSON:=TJSONSuperObject.Create;
  try
    mList:=TStringList.Create;
    mStoreCard_ID:=ARequest.GetQueryParamValue('storecard_id');
    mOS:=AContext.GetObjectSpace;
    mChildSC_ID:='';
    mOS.SQLSelect('SELECT ID FROM DefRollData WHERE CLSID = ''2TIIQXNXIXK4B5CZUIZ20K2W10'' AND X_Rel_Def = ''06'' AND X_Value_ID = '+QuotedStr(mStoreCard_ID), mList);
    if mList.count=0 then begin
      mChildSC_ID:=mOS.SQLSelectFirstAsString('Select id from storecards where hidden=''N'' '+cSQL_X_Aktivni+' and X_Parent_ID='+QuotedStr(mStoreCard_ID),'');
      mOS.SQLSelect('SELECT ID FROM DefRollData WHERE CLSID = ''2TIIQXNXIXK4B5CZUIZ20K2W10'' AND X_Rel_Def = ''06'' AND X_Value_ID = '+QuotedStr(mChildSC_ID), mList);
    end;
    mJSON.S['storecard_id']:=mStoreCard_ID;
    mJSON.S['childsc_ID']:=mChildSC_ID;
    mJSON.O['materials'] := mJSON.CreateJSONArray;
    mMaterialHTML_CZ:='<table>';
    mMaterialHTML_EN:='<table>';
    mMaterialHTML_DE:='<table>';
    mX_Name_Eshop_AT:='<table>';
    mX_Name_Eshop_DE:='<table>';
    mX_Name_Eshop_DK:='<table>';
    mX_Name_Eshop_EN:='<table>';
    mX_Name_Eshop_ES:='<table>';
    mX_Name_Eshop_FR:='<table>';
    mX_Name_Eshop_HU:='<table>';
    mX_Name_Eshop_IT:='<table>';
    mX_Name_Eshop_NL:='<table>';
    mX_Name_Eshop_PL:='<table>';
    mX_Name_Eshop_RU:='<table>';
    mX_Name_Eshop_SK:='<table>';
    mX_Name_Eshop_SA:='<table>';
    mX_Name_Eshop_USA:='<table>';

    for i:=0 to mlist.count-1 do begin
        mPARBO:= mOS.CreateObject(Class_BO_Relations);
        mParSourceBO:= mOS.CreateObject(Class_BO_ND_Materials);
        try
          mPARBO.Load(mList.strings[i], nil);
          mParSourceBO.Load(mPARBO.GetFieldValueAsString('X_Material_ID'), nil);
          mMaterialJSON :=TJSONSuperObject.create;
          mMaterialJSON.S['Material_ID']:= mPARBO.OID;
          mMaterialJSON.S['MaterialCode']:= mParSourceBO.GetFieldValueAsString('Code');
          mMaterialJSON.S['MaterialName']:= mParSourceBO.GetFieldValueAsString('Name');
          mMaterialJSON.D['X_NumericValue']:= mPARBO.GetFieldValueAsFloat('X_NumericValue');
          mMaterialHTML_CZ:=mMaterialHTML_CZ+'<tr><td>'+mParSourceBO.GetFieldValueAsString('Name')+'</td><td>'+FloatToStr(mPARBO.GetFieldValueAsFloat('X_NumericValue'))+'</td>';
          mMaterialHTML_EN:=mMaterialHTML_EN+'<tr><td>'+mParSourceBO.GetFieldValueAsString('X_EN_Nazev')+'</td><td>'+FloatToStr(mPARBO.GetFieldValueAsFloat('X_NumericValue'))+'</td>';
          mMaterialHTML_DE:=mMaterialHTML_DE+'<tr><td>'+mParSourceBO.GetFieldValueAsString('X_DE_Nazev')+'</td><td>'+FloatToStr(mPARBO.GetFieldValueAsFloat('X_NumericValue'))+'</td>';
          mX_Name_Eshop_AT := mX_Name_Eshop_AT + '<tr><td>' + mParSourceBO.GetFieldValueAsString('X_AT_Nazev') + '</td><td>' + FloatToStr(mPARBO.GetFieldValueAsFloat('X_NumericValue')) + '</td>';
          mX_Name_Eshop_DK := mX_Name_Eshop_DK + '<tr><td>' + mParSourceBO.GetFieldValueAsString('X_DK_Nazev') + '</td><td>' + FloatToStr(mPARBO.GetFieldValueAsFloat('X_NumericValue')) + '</td>';
          mX_Name_Eshop_EN := mX_Name_Eshop_EN + '<tr><td>' + mParSourceBO.GetFieldValueAsString('X_EN_Nazev') + '</td><td>' + FloatToStr(mPARBO.GetFieldValueAsFloat('X_NumericValue')) + '</td>';
          mX_Name_Eshop_ES := mX_Name_Eshop_ES + '<tr><td>' + mParSourceBO.GetFieldValueAsString('X_ES_Nazev') + '</td><td>' + FloatToStr(mPARBO.GetFieldValueAsFloat('X_NumericValue')) + '</td>';
          mX_Name_Eshop_FR := mX_Name_Eshop_FR + '<tr><td>' + mParSourceBO.GetFieldValueAsString('X_FR_Nazev') + '</td><td>' + FloatToStr(mPARBO.GetFieldValueAsFloat('X_NumericValue')) + '</td>';
          mX_Name_Eshop_HU := mX_Name_Eshop_HU + '<tr><td>' + mParSourceBO.GetFieldValueAsString('X_HU_Nazev') + '</td><td>' + FloatToStr(mPARBO.GetFieldValueAsFloat('X_NumericValue')) + '</td>';
          mX_Name_Eshop_IT := mX_Name_Eshop_IT + '<tr><td>' + mParSourceBO.GetFieldValueAsString('X_IT_Nazev') + '</td><td>' + FloatToStr(mPARBO.GetFieldValueAsFloat('X_NumericValue')) + '</td>';
          mX_Name_Eshop_NL := mX_Name_Eshop_NL + '<tr><td>' + mParSourceBO.GetFieldValueAsString('X_NL_Nazev') + '</td><td>' + FloatToStr(mPARBO.GetFieldValueAsFloat('X_NumericValue')) + '</td>';
          mX_Name_Eshop_PL := mX_Name_Eshop_PL + '<tr><td>' + mParSourceBO.GetFieldValueAsString('X_PL_Nazev') + '</td><td>' + FloatToStr(mPARBO.GetFieldValueAsFloat('X_NumericValue')) + '</td>';
          mX_Name_Eshop_RU := mX_Name_Eshop_RU + '<tr><td>' + mParSourceBO.GetFieldValueAsString('X_RU_nazev') + '</td><td>' + FloatToStr(mPARBO.GetFieldValueAsFloat('X_NumericValue')) + '</td>';
          mX_Name_Eshop_SK := mX_Name_Eshop_SK + '<tr><td>' + mParSourceBO.GetFieldValueAsString('X_SK_Nazev') + '</td><td>' + FloatToStr(mPARBO.GetFieldValueAsFloat('X_NumericValue')) + '</td>';
          mX_Name_Eshop_SA := mX_Name_Eshop_SA + '<tr><td>' + mParSourceBO.GetFieldValueAsString('X_SA_nazev') + '</td><td>' + FloatToStr(mPARBO.GetFieldValueAsFloat('X_NumericValue')) + '</td>';
          mX_Name_Eshop_USA := mX_Name_Eshop_USA + '<tr><td>' + mParSourceBO.GetFieldValueAsString('X_US_Nazev') + '</td><td>' + FloatToStr(mPARBO.GetFieldValueAsFloat('X_NumericValue')) + '</td>';

          mJSON.A['materials'].Add(mMaterialJSON);
        finally
          mPARBO.Free;
          mParSourceBO.Free;
        end;
    end;
    mMaterialHTML_CZ:=mMaterialHTML_CZ+'</table>';
    mMaterialHTML_EN:=mMaterialHTML_EN+'</table>';
    mMaterialHTML_DE:=mMaterialHTML_DE+'</table>';
    mX_Name_Eshop_AT:=mX_Name_Eshop_AT+'</table>';
    mX_Name_Eshop_DE:=mX_Name_Eshop_DE+'</table>';
    mX_Name_Eshop_DK:=mX_Name_Eshop_DK+'</table>';
    mX_Name_Eshop_EN:=mX_Name_Eshop_EN+'</table>';
    mX_Name_Eshop_ES:=mX_Name_Eshop_ES+'</table>';
    mX_Name_Eshop_FR:=mX_Name_Eshop_FR+'</table>';
    mX_Name_Eshop_HU:=mX_Name_Eshop_HU+'</table>';
    mX_Name_Eshop_IT:=mX_Name_Eshop_IT+'</table>';
    mX_Name_Eshop_NL:=mX_Name_Eshop_NL+'</table>';
    mX_Name_Eshop_PL:=mX_Name_Eshop_PL+'</table>';
    mX_Name_Eshop_RU:=mX_Name_Eshop_RU+'</table>';
    mX_Name_Eshop_SK:=mX_Name_Eshop_SK+'</table>';
    mX_Name_Eshop_SA:=mX_Name_Eshop_SA+'</table>';
    mX_Name_Eshop_USA:=mX_Name_Eshop_USA+'</table>';
    mJSON.S['materialsHTML_CZ']:=mMaterialHTML_CZ;
    mJSON.S['materialsHTML_EN']:=mMaterialHTML_EN;
    mJSON.S['materialsHTML_DE']:=mMaterialHTML_DE;
    mJSON.S['materialsHTML_AT']:=mX_Name_Eshop_AT;
    mJSON.S['materialsHTML_DK']:=mX_Name_Eshop_DK;
    mJSON.S['materialsHTML_ES']:=mX_Name_Eshop_ES;
    mJSON.S['materialsHTML_FR']:=mX_Name_Eshop_FR;
    mJSON.S['materialsHTML_HU']:=mX_Name_Eshop_HU;
    mJSON.S['materialsHTML_IT']:=mX_Name_Eshop_IT;
    mJSON.S['materialsHTML_NL']:=mX_Name_Eshop_NL;
    mJSON.S['materialsHTML_PL']:=mX_Name_Eshop_PL;
    mJSON.S['materialsHTML_RU']:=mX_Name_Eshop_RU;
    mJSON.S['materialsHTML_SK']:=mX_Name_Eshop_SK;
    mJSON.S['materialsHTML_SA']:=mX_Name_Eshop_SA;
    mJSON.S['materialsHTML_US']:=mX_Name_Eshop_USA;

    AResponse.Body := mJSON.AsString;
    AResponse.SetHeader('Content-Type','application/json');
    AResponse.Status := 200;
  finally
    mList.Free;
  end;
end;

function POST_GetOrdersForInvoices(AContext: TNXContext; AInput: TJSONSuperObject; APath: String): TJSONSuperObject;
var
 mBO:TNxCustomBusinessObject;
 mOS:TNxCustomObjectSpace;
 mJSONInvoice, mJSONOrder:TJSONSuperObject;
 mInvoice_ID:string;
 i,j:integer;
 mOrderList:TStringList;
begin
 Result:=TJSONSuperObject.Create;
 mOS:=AContext.GetObjectSpace;
 Result.O['invoices'] := Result.CreateJSONArray;
 for i:=0 to AInput.A['invoices'].Length-1 do begin
    mInvoice_ID:=AInput.A['invoices'].O[i].S['id'];
    mJSONInvoice:=TJSONSuperObject.create;
    mJSONInvoice.S['id']:=mInvoice_ID;
    mOrderList:=TStringList.create;
    mOrderList.Clear;
    mOS.SQLSelect('select distinct sd2.provide_id from issuedinvoices2 ii2 join storedocuments2 sd2 on sd2.id=ii2.providerow_id where ii2.parent_id='+QuotedStr(mInvoice_ID),mOrderList);
    if mOrderList.count>0 then begin
      mJSONInvoice.O['orders'] := mJSONInvoice.CreateJSONArray;
      for j:=0 to mOrderList.Count-1 do begin
        mJSONOrder:=TJSONSuperObject.create;
        mJSONOrder.S['orderId']:=mOrderList.Strings[j];
        mJSONInvoice.A['orders'].Add(mJSONOrder);
      end;
    end;
    Result.A['invoices'].Add(mJSONInvoice);
 end;
end;

procedure POST_InvoicesForPaymentDate(AContext:TNxContext; ARequest: TAPIRequest; AResponse: TAPIResponse);
var
  mHeaders,mInvoiceList: TStringList;
  i: Integer;
  mInputJSON, mOutputJSON, mInvJSON:TJSONSuperObject;
  mName, mValue, mSQL: string;
  mDateFrom,mDateTo:extended;
begin
  mHeaders := TStringList.Create;
  mOutputJSON:=TJSONSuperObject.Create;
  mInputJSON:=TJSONSuperObject.Create;
  try
    ARequest.GetHeaders(mHeaders);
    mInputJSON:=TJSONSuperObject.ParseString(ARequest.Body,True);
    for i := 0 to mHeaders.Count - 1 do begin
      mName:=mHeaders.Strings[i];
      mValue:=ARequest.GetHeaderValue(mName);
      //mOutputJSON.S[mName]:=mValue;
    end;
    mDateFrom:=mInputJSON.DT8601['datefrom'];
    mDateTo:=mInputJSON.DT8601['dateto'];
    if (mDateFrom<mDateTo) then begin
        mSQL:='SELECT A.ID FROM IssuedInvoices A WHERE EXISTS (SELECT 1 FROM PaymentsForDocument_VIEW PFD WHERE PFD.DocDate$DATE >= '
              +IntToStr(trunc(mDateFrom))+' AND PFD.DocDate$DATE < '+IntToStr(trunc(mDateTo))+
              ' AND PFD.PDocumentType = ''03'' AND PFD.PDocument_ID = A.ID)';
        mInvoiceList:=TStringList.Create;
        AContext.SQLSelect(mSQL,mInvoiceList);
        mOutputJSON.O['invoices'] := mOutputJSON.CreateJSONArray;
        if mInvoiceList.count>0 then begin
         for i:=0 to mInvoiceList.count-1 do begin
           mInvJSON:=TJSONSuperObject.Create;
           mInvJSON.S['id']:=mInvoiceList.strings[i];
           mOutputJSON.A['invoices'].Add(mInvJSON);
         end;
        end;
        //mOutputJSON.S['body']:=mSQL;
        AResponse.Body:=mOutputJSON.AsString;
        AResponse.SetHeader('Content-Type','application/json');
        AResponse.Status := 200;
    end else begin
        mOutputJSON.S['body']:='Wrong Content, DateFrom > DateTo';
        AResponse.Body:=mOutputJSON.AsString;
        AResponse.SetHeader('Content-Type','application/json');
        AResponse.Status := 422;
    end;
  finally
    mHeaders.Free;
  end;
end;


begin
end.