Const
   cDocQueue_DL_ID = 'P600000101'; //DL
   cDocQueue_VPZ_ID = '2900000101'; //VPZ
   cStoreGateway_ID = '1010000101'; // Vyskladnovací místo
   cStoreMan_ID = '5000000101'; // Skladník

   cNxSameGoodsInPositionStrategyID = '{BD31E23F-18B7-43B9-93B6-B652714090F1}';
   cNxOldestStorageStrategyID = '{37A351FA-D60D-4A98-9A58-1FD1ACAD5339}';
   cNxFreePositionsStrategyID = '{CBF7FC08-CAB3-4172-9A01-A7456BD4BC35}';
   cNxMinimumPositionsStrategyID = '{C8F75D91-DDC3-40B4-A89E-24CDCBBDD523}';
   cNxAccessibilityInputStrategyID = '{4F47491B-EAFC-4B9E-A905-45B7471C6723}';
   cNxAccessibilityOutputStrategyID = '{0881618E-DF24-4A2E-87BC-DD75BD1E3F51}';
   cNxMinimumAccessiblePositionsStrategyID = '{96BA5D26-14C5-4704-AF1A-157438752679}';
   cNxFreeNoPreferredPositionsStrategyID = '{CFF06E40-E587-4DFF-9680-880751B3F359}';

procedure CreateBOD (OS: TNxCustomObjectSpace; var Success: Boolean; var LogInfoStr: String);
var
 mList,mValidateErrors, mLogs:TStringList;
 i:integer;
 mBO, mBoDBO:TNxCustomBusinessObject;
 mImportMan, mImportMan2:TNxDocumentImportManager;
 mInputParams, mInputParams2:TNxParameters;
 mParam:TNxParameter;
begin
  mList:=TStringList.Create;
  mLogs:=TStringList.Create;
  mValidateErrors:= TStringList.Create;
  OS.SQLSelect('SELECT A.ID FROM ReceivedOrders A WHERE (A.IsAvailableForDelivery = ''A'')  AND (a.X_FromAPI=''A'')' , mList);
  if mlist.Count>0 then begin
   for i:=0 to mList.count-1 do begin
      mBO:=OS.CreateObject(Class_ReceivedOrder);
      mBO.Load(mlist.Strings[i],nil);
            mLogs.add('Objednávka '+mbo.DisplayName);
            try
              mImportMan := NxCreateDocumentImportManager(OS, Class_ReceivedOrder, Class_BillOfDelivery);
              mImportMan.AddInputDocument(mBO.OID);
              mImportMan.SelectedHeader:= mImportMan.InputDocuments[0];
              mInputParams := TNxParameters.Create;
              mParam := mInputParams.GetOrCreateParam(dtstring,'DocQueue_ID');
              mParam.AsString:=cDocQueue_DL_ID;
              mImportMan.LoadParams(mInputParams);
              mImportMan.Execute;
              mImportMan.OutputDocument.save;
              
                            try
                              mValidateErrors.Clear;
                              mImportMan2 := NxCreateDocumentImportManager(OS, Class_BillOfDelivery, Class_LogStoreOutput);
                              mInputParams2 := TNxParameters.Create;
                              mImportMan2.AddInputDocument(mImportMan.OutputDocument.OID);
                              mImportMan2.SelectedHeader:= mImportMan2.InputDocuments[0];
                              mInputParams2.GetOrCreateParam(dtString, 'StoreGateway_ID').AsString := cStoreGateway_ID;
                              mInputParams2.GetOrCreateParam(dtString, 'DocQueue_ID').AsString := cDocQueue_VPZ_ID;
                              mInputParams2.GetOrCreateParam(dtString, 'StoreMan_ID').AsString := cStoreMan_ID;
                              mInputParams2.GetOrCreateParam(dtBoolean, 'AutoPrefillPosition').AsBoolean := True;
                              mInputParams2.GetOrCreateParam(dtString, 'Strategy_ID').AsString := cNxFreePositionsStrategyID;
                              mInputParams2.GetOrCreateParam(dtBoolean, 'IsAccessibilityLimitFilter').AsBoolean := False;
                              mInputParams2.GetOrCreateParam(dtInteger, 'AccessibilityLimit').AsInteger := 0;

                              mImportMan2.LoadParams(mInputParams2);
                              mImportMan2.Execute;
                              if mImportMan2.OutputDocument.Validate then
                              begin
                                 mImportMan2.OutputDocument.Save;
                                 mBODBO := OS.CreateObject(Class_BillOfDelivery);
                                 mBODBO.Load(mImportMan.OutputDocument.OID, nil);
                                 mBODBO.PMChangeState('2010000101');
                                 mbodbo.free;
                                 mLogs.Add(' - Vytvořen polohovací doklad:'+mImportMan2.OutputDocument.DisplayName);
                              end else begin
                                 mImportMan2.OutputDocument.GetValidateErrors(mValidateErrors);
                                 mLogs.Add(' - Polohovací doklad nebylo možné uložit, chyby:'+mValidateErrors.Text);
                              end;
                           finally
                              mImportMan2.Free;
                           end;
            except
              mLogs.add('Výjimka '+ExceptionMessage);
            end;
            mLogs.Add('Dodací list '+mImportMan.OutputDocument.DisplayName);
   end;
  end;
  Success := True;
  LogInfoStr := ''+NxCrlf+mLogs.Text;
end;

procedure SendBOD2SM (OS: TNxCustomObjectSpace; var Success: Boolean; var LogInfoStr: String);
var
 mList, mLogs:TStringList;
 i,j:integer;
 mBO, mRowBO:TNxCustomBusinessObject;
 mRows:TNxCustomBusinessMonikerCollection;
 mHeaderJSON, mRowJSON, mResultJSON:TJSONSuperObject;
 mPrice:Extended;
begin
  mList:=TStringList.Create;
  mlogs:=TStringList.Create;
  OS.SQLSelect('SELECT A.ID FROM StoreDocuments A WHERE A.Documenttype=''21'' AND (A.X_FromAPI = ''A'') and (A.X_Sent2SM = 0) AND (A.PMState_ID = ''SDDEF00000'')', mList);
  if mList.Count>0 then begin
    for i:=0 to mList.count-1 do begin
      mBO:=OS.CreateObject(Class_BillOfDelivery);
      mBO.Load(mList.Strings[i],nil);
      mRows:=mBO.GetLoadedCollectionMonikerForFieldCode(mBO.GetFieldCode('Rows'));
      mHeaderJSON:=TJSONSuperObject.Create;
      mHeaderJSON.S['DocNumber']:=mBO.DisplayName;
      mHeaderJSON.S['IssuedOrder_ID']:=mBO.GetFieldValueAsString('X_IssuedOrderID');
      mHeaderJSON.O['Rows']:=mHeaderJSON.CreateJSONArray;
      for j:=0 to mrows.count-1 do begin
        mRowBO:=mRows.BusinessObject[j];
        mRowJSON:=TJSONSuperObject.Create;
        mRowJSON.S['StoreCardCode']:=mRowBO.GetFieldValueAsString('StoreCard_ID.Code');
        mRowJSON.S['StoreCardName']:=mRowBO.GetFieldValueAsString('StoreCard_ID.Name');
        mRowJSON.D['Quantity']:=mRowBO.GetFieldValueAsFloat('Quantity');
        mRowJson.D['TotalPrice']:=OS.SQLSelectFirstAsExtended('Select TotalPrice from receivedorders2 where id='+QuotedStr(mRowBO.GetFieldValueAsString('ProvideRow_ID')),0);
        mRowJSON.S['IssuedOrderRow_ID']:=OS.SQLSelectFirstAsString('Select X_IssuedOrderRowID from receivedorders2 where id='+QuotedStr(mRowBO.GetFieldValueAsString('ProvideRow_ID')),'');
        mHeaderJSON.A['Rows'].Add(mRowJSON);
      end;
      mLogs.add(mHeaderJSON.AsString);
      mresultJSON:=API_POST(mHeaderJSON,'BillOfDelivery');
      if mResultJSON.S['Status']='Ok' then begin   
         mBO.SetFieldValueAsinteger('X_Sent2SM',1);
         mbo.Setfieldvalueasstring('Description',mresultJSON.S['DocNumber']);
         mBO.Save;
         mLogs.add(' - Odesláno do SM, číslo dokladu v SM: '+mResultJSON.S['DocNumber']);
         end else begin
         mLogs.add(' - Chyba při odesílání do SM, odpověď API: '+mResultJSON.AsString);
      end;       
    end;
  end;
  Success := True;
  LogInfoStr := ''+NxCrlf+mLogs.Text;
end;


function API_POST(aJSON:TJSONSuperObject;AName:string; AIsScript: Boolean = True; aIndex: integer = 0):TJSONSuperObject;
var
 mWinHTTP:Variant;
 mResultJSON:TJSONSuperObject;
 mSuffix, mURL: string;
begin
  mSuffix:= 'script/eu.abra.masa.Barton_SM.API/lib/';
  try
   mWinHTTP:= CreateOleObject('WinHttp.WinHttpRequest.5.1');
   mURl:='https://api.barton.cz:8444/Srouby_Matice/'+mSuffix+aName;  // UPRAVIT: URL_ENDPOINT nahradit správným URL
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

begin
end.