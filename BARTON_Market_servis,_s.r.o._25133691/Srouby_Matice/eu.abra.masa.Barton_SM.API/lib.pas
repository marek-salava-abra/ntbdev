var
  gUpdated, gCreated: Integer;

// API_POST - Odesílání dat na API v JSON formátu
function API_POST(aJSON:TJSONSuperObject;AName:string; AIsScript: Boolean = True; aIndex: integer = 0):TJSONSuperObject;
var
 mWinHTTP:Variant;
 mResultJSON:TJSONSuperObject;
 mSuffix, mURL: string;
begin
  mSuffix:= 'script/eu.abra.masa.BMS.API/lib/';
  try
   mWinHTTP:= CreateOleObject('WinHttp.WinHttpRequest.5.1');
   mURl:='https://api.barton.cz:8444/barton/'+mSuffix+aName;  // UPRAVIT: URL_ENDPOINT nahradit správným URL
   mWinHTTP.Open('POST', mURL);
   mWinHTTP.SetRequestHeader('Content-Type', 'application/json');
   mWinHTTP.SetRequestHeader('Authorization','Basic '+EncodeBase64(TEncoding.UTF8.GetBytes('API:ApiHeslo')));
   mWinHTTP.Send(aJSON.AsJson);
   if mWinHTTP.status='200' then begin
     Result:=TJSONSuperObject.ParseString(mWinHTTP.ResponseText, True);
   end else begin
     Result:=TJSONSuperObject.ParseString(mWinHTTP.ResponseText, True);
   end;
  except
   Result:=TJSONSuperObject.create;
   Result.S['error']:='error';
  end;
end;

function API_GET(aURL:String; aIndex: integer = 0): TJSONSuperObject;
var
  mWinHTTP: Variant;
  mRequest, mLogin, mAuth: string;
  mJSON:TJSONSuperObject;
  mList:TStringList;
begin
  try
    mWinHTTP:= CreateOleObject('WinHttp.WinHttpRequest.5.1');
    mWinHTTP.Open('GET', aURL);
    mWinHTTP.SetRequestHeader('Content-Type', 'application/json');
    mWinHTTP.SetRequestHeader('Authorization','Basic '+EncodeBase64(TEncoding.UTF8.GetBytes('API:ApiHeslo')));
    mWinHTTP.Send();
    Result:=TJSONSuperObject.ParseString(ConvertToText(mWinHTTP.Responsebody), True);
  except
    Result:=TJSONSuperObject.create;
    Result.S['error']:='error';
  end;
end;


{POST_BillOfDelivery}

procedure POST_BillOfDelivery(AContext:TNxContext; ARequest: TAPIRequest; AResponse: TAPIResponse);
var
  mInputJSON, mOutputJSON:TJSONSuperObject;
  mOS:TNxCustomObjectSpace;
  mBO, mRowBO:TNxCustomBusinessObject;
  mRows:TNxCustomBusinessMonikerCollection;
  i,j,k:integer;
  mImportManager: TNxDocumentImportManager;
  mInputParams: TNxParameters;
  mParam: TNxParameter;
  mSelectedRows:TStringList;
begin
  mOS:=AContext.GetObjectSpace;
  mInputJSON:=TJSONSuperObject.Create;
  mOutputJSON:=TJSONSuperObject.Create;
  mInputJSON:=TJSONSuperObject.ParseString(ARequest.Body,True);
  try
    if (mInputJSON.A['Rows'].Length>0) and not(NxIsEmptyOID(mInputJSON.S['IssuedOrder_ID'])) then begin
      mSelectedRows:=TStringList.Create;
      for i:=0 to mInputJSON.A['Rows'].Length-1 do begin
        mSelectedRows.add(mInputJSON.A['Rows'].O[i].S['IssuedOrderRow_ID']);
      end;
      mInputParams := TNxParameters.Create;
      mParam := mInputParams.GetOrCreateParam(dtString, 'SelectedRows'); // jen povolene radky
      mParam.AsString := mSelectedRows.Text;
      mParam := mInputParams.GetOrCreateParam(dtString, 'DocQueue_ID');
      mParam.AsString := 'L000000101';
      mImportManager := NxCreateDocumentImportManager(mOS, Class_IssuedOrder, Class_ReceiptCard);
      mImportManager.AddInputDocument(mInputJSON.S['IssuedOrder_ID']);
      //mImportManager.SelectedHeader:=mImportManager.InputDocuments[0];
      mImportManager.LoadParams(mInputParams);
      mImportManager.Execute;
      mImportManager.OutputDocument.SetFieldValueAsString('DocQueue_ID','L000000101');
      mImportManager.OutputDocument.SetFieldValueAsString('Description',mInputJSON.S['DocNumber']);
      mRows:=mImportManager.OutputDocument.GetLoadedCollectionMonikerForFieldCode(mImportManager.OutputDocument.GetFieldCode('Rows'));
      for i:=0 to mrows.Count-1 do begin
       mRowBO:=mRows.BusinessObject[i];
        for j:=0 to mInputJSON.A['Rows'].Length-1 do begin
          if mRowBO.GetFieldValueAsString('ProvideRow_ID')=mInputJSON.A['Rows'].O[j].S['IssuedOrderRow_ID'] then begin
           mRowBO.SetFieldValueAsFloat('Quantity',mInputJSON.A['Rows'].O[j].D['Quantity']);
           mRowBO.SetFieldValueAsFloat('UnitPrice',0);
           mRowBO.SetFieldValueAsFloat('TotalPrice',mInputJSON.A['Rows'].O[j].D['TotalPrice']);
          end;
        end;
      end;
      mImportManager.OutputDocument.Save;
      mOutputJSON.S['Status']:='Ok';
      mOutputJSON.S['DocNumber']:=mImportManager.OutputDocument.DisplayName;
    end else begin
      mOutputJSON.S['Status']:='error';
      mOutputJSON.S['DocNumber']:='';
    end;
    AResponse.Body:=mOutputJSON.AsString;
    AResponse.SetHeader('Content-Type','application/json');
    AResponse.Status := 200;
  except
    mOutputJSON.S['Status']:='error';
    mOutputJSON.S['DocNumber']:='';
    AResponse.Body:=mOutputJSON.AsString;
    AResponse.SetHeader('Content-Type','application/json');
    AResponse.Status := 200;
  end;
end;

function ConvertToText(aUnicodeBytes: TBytes): String;
var
  mUnicodeBites: TBytes;
begin
  mUnicodeBites := TEncoding.Convert(aUnicodeBytes,Encoding_cpUTF_8,Encoding_cpUTF_16);
  Result := TEncoding.Unicode.GetString(mUnicodeBites);
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
 mPurchasePrice, mKoeficient:extended;
begin
 Result := TJSONSuperObject.Create;
 mOS:=AContext.GetObjectSpace;
 try
          mHeaderBO:=mOS.CreateObject(Class_IssuedOrder);
          mHeaderBO.New;
          mHeaderBO.prefill;
          mNotFoundCard:='';
          mDocQueue_ID:='T100000101';
          mHeaderBO.SetFieldValueAsString('DocQueue_ID',mDocQueue_ID);
          mHeaderBO.SetFieldValueAsString('ExternalNumber',AInput.S['DocumentNumber']);
          mHeaderBO.SetFieldValueAsString('Description',AInput.S['Description']);
           mFirm_ID:=mOS.SQLSelectFirstAsString('select id from firms where hidden='+QuotedStr('N')+' and firm_id is null and orgidentnumber='+QuotedStr(AInput.S['FirmOrgIdentNumber']),'');
          mheaderBO.SetFieldValueAsString('Firm_ID',mFirm_ID);
          mRows:=mHeaderBO.GetLoadedCollectionMonikerForFieldCode(mHeaderBO.GetFieldCode('Rows'));
           for i:= 0 to AInput.A['Rows'].Length -1 do begin
             mRowBO:=mRows.AddNewObject;
             mrowBO.Prefill;
             mStore_ID:='1000000101';
             mDivision_ID:='1000000101';
             mRowBO.SetFieldValueAsInteger('RowType', AInput.A['Rows'].O[i].I['RowType']);
             mRowBO.SetFieldValueAsString('Division_ID',mDivision_ID);
             if AInput.A['Rows'].O[i].I['RowType']=3 then begin
               mRowBO.SetFieldValueAsString('Store_ID',mStore_ID);
               mStoreCard_ID:=mOS.SQLSelectFirstAsString('select id from storecards where hidden='+QuotedStr('N')+' and code='+QuotedStr(AInput.A['Rows'].O[i].S['StoreCardCode']),'');
               mRowBO.SetFieldValueAsString('StoreCard_ID',mStoreCard_ID);
               if NxIsEmptyOID(mStoreCard_ID) then mNotFoundCard:=mNotFoundCard+NxCrLf+AInput.A['Rows'].O[i].S['StoreCardCode'];
               //if NxIsEmptyOID(mMainSupplier_ID)  and not(NxIsEmptyOID(mIODocQueue_ID)) then mMainSupplier_ID:=mRowBO.GetFieldValueAsString('Storecard_id.MainSupplier_ID.Firm_ID');
               mRowBO.SetFieldValueAsFloat('Quantity',AInput.A['Rows'].O[i].D['Quantity']);

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

  except
      Result.S['ID']:='';
      Result.S['Code']:=ExceptionMessage+nxCrLf+'Nenalezené karty:'+NxCrlF+mNotFoundCard;
      Result.S['Status']:='Error';
      mHeaderBO.Free;
  end;
end;



begin
end.