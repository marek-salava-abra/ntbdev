uses
  'REST_SkladTerm.U_Func',
  'REST_SkladTerm.U_FuncJSON',
  'REST_SkladTerm.U_TemporaryStorage',
  'REST_SkladTerm.U_Requests',
  'REST_SkladTerm_Special.U_Const',
  'REST_SkladTerm_Special.U_StandardHooks',
  'StandardUnits.U_DataSet',
  'StandardUnits.U_GetId';

const _c_SD2TTKeyName='IxByLSD2';

function isTransferBetweenPositionsAllowed(AContext: TNxContext; AStorePosition_ID, AStoreCard_ID, AStoreBatch_ID: String; AQunatityTransferred: Real; AUnblockPositions: String; var AMessage: String): Boolean;
var
  dtStoreDocs, dtLogStoreCont: TMemTable;
  mSql, mMessageSD: String;
  mQAvailableToTransfer:real;
begin
  Result := False;
  mQAvailableToTransfer:=0;
  //Zjistime, zda je mozno transfer realizovat
  //kontroluje se takto
  //Stav artiklu a šarže na pozici + blokovano - blokováno ve spatnem stavu
  //Musí být větší nebo rovno než AQunatityTransferred

  dtStoreDocs := TMemTable.Create(nil);
  dtLogStoreCont := TMemTable.Create(nil);
  try
    //Vyhledame LSD, ktere nemaji skladovy doklad povolenych stavech a jejich mnozstvi
    //Hledame vsechny neprijimaci doklady

    mSql := 'select coalesce(LSD2.QUANTITY,0) Quantity,' + nxCrLf +
            '  DQ.Code' + CONCAT_STR + QuotedStr('-') + CONCAT_STR + 'cast(SD.OrdNumber as varchar(6))' + nxCrLf +
         CONCAT_STR + QuotedStr('/') + CONCAT_STR + 'P.Code as "DisplayName",' + nxCrLf;
    if ABRA then
      mSql := mSql + '  US.Code as "UserStatusCode"' + nxCrLf
    else
      mSql := mSql + '  US.UserStatusCode as "UserStatusCode"' + nxCrLf;

    mSql := mSql +
      '  from LogStoreDocuments2 LSD2' + nxCrLf +
      '  join LogStoreDocuments LSD on LSD.ID = LSD2.Parent_ID' + nxCrLf +
      '  join StoreDocuments SD on SD.ID = LSD.StoreDocument_ID' + nxCrLf;
    if ABRA then
      mSql := mSql + 'join PMStates US on US.ID = SD.PMState_ID' + nxCrLf
    else
      mSql := mSql + 'join UserStatuses US on US.ID = SD.Status_ID' + nxCrLf;
    mSql := mSql +
      'join DocQueues DQ on DQ.ID = SD.DocQueue_ID' + nxCrLf +
      'join Periods P on P.ID = SD.Period_ID' + nxCrLf +
      'where LSD2.StorePosition_ID = ' + QuotedStr(AStorePosition_ID) + ' ' +
      '  and LSD.DocumentType in (''32'',''33'')' + nxCrLf +
      '  and LSD.Executed = ''N''' + nxCrLf +
      '  and not SD.' + GetStatusField + ' in (' + AUnblockPositions + ')' + nxCrLf +
      '  and LSD2.StoreCard_ID = ' + QuotedStr(AStoreCard_ID) + ' ';
     if not NxIsEmptyOID(aStoreBatch_ID) then
       mSql:=mSql+ '  and LSD2.StoreBatch_ID = ' + QuotedStr(AStoreBatch_ID);
    AContext.GetObjectSpace.SQLSelect2(mSql, dtStoreDocs);

    // Vyhledáme uložené množství na pozici
    mSql := 'Select Coalesce(SUM(LSC.QUANTITY),0) AvQuantity, coalesce(SUM(LSC.QUANTITYRESERVED),0) ResQuantity'+
            ' from LOGSTORECONTENTS LSC '+
            ' where LSC.PARENT_ID=' + QuotedStr(AStorePosition_ID) + ' ' +
            ' and LSC.StoreCard_ID=' + QuotedStr(AStoreCard_ID) + ' ';
    if not NxIsEmptyOID(aStoreBatch_ID) then
      mSql:=mSql+ '  and LSC.StoreBatch_ID = ' + QuotedStr(AStoreBatch_ID);
    AContext.GetObjectSpace.SQLSelect2(mSql, dtLogStoreCont);

    mMessageSD := '';

    if dtLogStoreCont.Active then
    begin
      dtLogStoreCont.First;
      while not dtLogStoreCont.Eof do
      begin
        mQAvailableToTransfer:=mQAvailableToTransfer+
          dtLogStoreCont.FieldByName('AvQuantity').AsFloat+
          dtLogStoreCont.FieldByName('ResQuantity').AsFloat;
        dtLogStoreCont.Next;
      end;
    end;
    if dtStoreDocs.Active then
    begin
      dtStoreDocs.First;
      while not dtStoreDocs.EOF do
      begin
        mQAvailableToTransfer:=mQAvailableToTransfer-
          dtStoreDocs.FieldByName('Quantity').AsFloat;
        mMessageSD := mMessageSD + dtStoreDocs.FieldByName('DisplayName').AsString + ': ' + dtStoreDocs.FieldByName('UserStatusCode').AsString + nxCrLf;
        dtStoreDocs.Next;
      end;
      mMessageSD := getString('blocking_documents') + nxCrLf + mMessageSD + nxCrLf;
    end;
    IF CFxFloat.GreaterThan4(AQunatityTransferred,mQAvailableToTransfer) then
    begin
      AMessage := getString('transfer_quantity_cannot_be_done') + nxCrLf + nxCrLf + mMessageSD;
    end
    else
      Result:=true;
  finally
    dtStoreDocs.Free;
    dtLogStoreCont.Free;
  end;
end;
///////////////////////////////////////////////////////////////////////////////

function isTransferBetweenPositionsAllowedWholeDoc(AContext: TNxContext; AJSON_Rows: TJSONSuperObjectArray; AForbiddenPositions, AUnblockPositions: String;
  var AMessage: String): Boolean;
var
  mJSON_Row,mJSON_Sernum:TJSONSuperObject;
  mJSON_SerNums:TJSONSuperObjectArray;
  i,SNi:integer;
  mMessage:string;
begin
  Result := true;
  AMessage := '';
  if Assigned(AJSON_Rows) then
  begin
    for i:=0 to AJSON_Rows.Length - 1 do
    begin
      mJSON_Row := AJSON_Rows.O[i];

      // pokud se presouva do zakazanych pozic, tak odblokovani pouzivat nebudeme
      // a nemusime tedy kontrolovat mnozstvi
      if (pos(mJSON_Row.S['StorePositionTo_ID'], AForbiddenPositions) > 0) then
        continue;

      if mJSON_Row.I['StoreCardCategory'] = 1 then //pokud se eviduji SC kontrolujeme kazde jeno
  //pokud je jedno nepreveditelne, nelze prevod realizovat
      begin
        mJSON_SerNums := mJSON_Row.A['sernums'];
        for SNi:=0 to mJSON_SerNums.Length - 1 do
        begin
          if not isTransferBetweenPositionsAllowed(AContext
                                                   ,mJSON_Row.S['StorePositionFrom_ID']
                                                   ,mJSON_Row.S['StoreCard_ID']
                                                   ,mJSON_Row.S['StoreBatch_ID']
                                                   ,1
                                                   ,AUnblockPositions
                                                   ,mMessage) then
          begin
            Result:=false;
            AMessage:=AMessage+nxCrLf+mMessage;
          end;
        end;
      end
      else
      begin
        if not isTransferBetweenPositionsAllowed(AContext
                                                 ,mJSON_Row.S['StorePositionFrom_ID']
                                                 ,mJSON_Row.S['StoreCard_ID']
                                                 ,mJSON_Row.S['StoreBatch_ID']
                                                 ,mJSON_Row.D['UnitQuantity']
                                                 ,AUnblockPositions
                                                 ,mMessage) then
        begin
          Result:=false;
          AMessage:=AMessage+nxCrLf+mMessage;
        end;
      end;
    end;
  end
  else
  begin
    Result:=false;
    AMessage:=AMessage+getString('rows_list_not_assigned');
  end;
end;

///////////////////////////////////////////////////////////////////////////////
{procedure getTransferBetweenPositionsAllowed(Self: TNxWebServicesHelper; ARequest: TNxHTTPRequest;
  AResponse: TNxHTTPResponse; mJSON_Rows:TJSONSuperObjectArray);
var
  mStorePosition_ID: String;
  mMessage: String;
  mJSON_Row,mJSON_Sernum:TJSONSuperObject;
  mJSON_SerNums:TJSONSuperObjectArray;
  i,SNi:integer;
  TransferAllowed:boolean;
begin
//kontrola, jestli je prevod mezi pozicemi mozny
  if not Assigned(mJSON_Rows) then
  begin
    ErrREST(ARequest, AResponse, HTTP_SC_BadRequest, getString('rows_list_not_assigned'));
    exit;
  end;
  TransferAllowed:=true;
  LogWriteSectionStart('getTransferBetweenPositionsAllowed');
  for i:=0 to mJSON_Rows.Length - 1 do
  begin
    mJSON_Row := mJSON_Rows.O[i];
    if mJSON_Row.I['StoreCardCategory'] = 1 then //pokud se eviduji SC kontrolujeme kazde jeno
//pokud je jedno nepreveditelne, nelze prevod realizovat
    begin
      mJSON_SerNums := mJSON_Row.A['sernums'];
      for SNi:=0 to mJSON_SerNums.Length - 1 do
      begin
        if not isTransferBetweenPositionsAllowed(Self.Context
                                                 ,mJSON_Row.S['StorePositionFrom_ID']
                                                 ,mJSON_Row.S['StoreCard_ID']
                                                 ,mJSON_Row.S['StoreBatch_ID']
                                                 ,1
                                                 ,AUnblockPositions
                                                 ,mMessage) then
          TransferAllowed:=false;
      end;
    end
    else
    begin
      if not isTransferBetweenPositionsAllowed(Self.Context
                                               ,mJSON_Row.S['StorePositionFrom_ID']
                                               ,mJSON_Row.S['StoreCard_ID']
                                               ,mJSON_Row.S['StoreBatch_ID']
                                               ,mJSON_Row.D['UnitQuantity']
                                               ,AUnblockPositions
                                               ,mMessage) then
        TransferAllowed:=false;
    end;
  end;
  if TransferAllowed then
  begin
    HTTPResponse(AResponse, HTTP_SC_OK, ContentType_JSON, PlainResponse(''));
  end
  else begin
    ErrREST(ARequest, AResponse, HTTP_SC_ExpectationFailed, mMessage);
  end;
  LogWriteSectionEnd;
end;}
///////////////////////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////////////////////
procedure GetBlockingRows(AOS:TNxCustomObjectSpace; ASC_ID, ASB_ID, ALSP_ID, ALSPTo, AUnblockPositions: String; AQ: Real; ADS: TMemTable);
var
  mSQL: String;
  mRDS: TMemTable;
  mQToUnblock: Real;
begin
  mSQL:='select LSD.DocumentType DT, LSD2.Parent_ID LSD_ID, LSD2.ID LSD2_ID,LSD2.STOREPOSITION_ID SP_ID ' +
        ' , LSD2.STORECARD_ID SC_ID, LSD2.STOREBATCH_ID SB_ID, LSD2.Qunit QUnit, LSD2.UnitRate UnitRate, LSD2.QUANTITY Quantity, LSD2.StoreDocRow_ID SD2_ID, LSD.StoreDocument_ID SD_ID ' +
        ' from LogStoreDocuments2 LSD2 ' +
        ' join LogStoreDocuments LSD on LSD.ID = LSD2.Parent_ID ' +
        ' join StoreDocuments SD on SD.ID = LSD.StoreDocument_ID ' +
        ' where LSD2.StorePosition_ID = ' + QuotedStr(ALSP_ID) + ' ' +
        '  and LSD.DocumentType in (''32'',''33'') '+
        '  and LSD.Executed = ''N'''+
        '  and SD.' + GetStatusField + ' in (' + AUnblockPositions + ')' +
        '  and LSD2.StoreCard_ID = ' + QuotedStr(ASC_ID) + ' ';
     if not NxIsEmptyOID(aSB_ID) then
       mSql:=mSql+ '  and LSD2.StoreBatch_ID = ' + QuotedStr(ASB_ID);

  mRDS := TMemTable.Create(nil);
  try
    aOS.SQLSelect2(mSQL,mRDS);
    aDS.IndexName:=_c_SD2TTKeyName;
    if mRDS.Active then
    begin
      mRDS.First;
      //Projdu vsechny blokujici radky a do aDS si ke kazdemu poznamenam kolik
      //potrebuji odblokovat To delam dokud je co odblokovavat. Pokud jsou blokace mensi, nez
      //je mnozstvi k prevodu dal je nerusim Prevedu to co je blokovane na jine misto
      while not mRDS.Eof and not CFxFloat.IsZero6(aQ) do
      begin
        mQToUnblock:=0;
        if aDS.FindKey([mRDS.FieldByName('LSD2_ID').AsString]) then
        begin
        //Pokud uz jsem jednou blokacni radek nasel a je na nem jeste co odblokovat udelam to
         if aDS.FieldByName('Quantity').AsFloat<mRDS.FieldByName('Quantity').AsFloat then
         begin
           //odblokujem bud to co jde maximalne odblokovat, nebo cele mnozstvi, podle toho co je mensi.
           mQToUnblock:=min_1(aQ,mRDS.FieldByName('Quantity').AsFloat-aDS.FieldByName('Quantity').AsFloat);
           aDS.Edit;
           aDS.FieldByName('Quantity').AsFloat:=aDS.FieldByName('Quantity').AsFloat+mQToUnblock;
           aDS.Post;
         end;
        end
        else
        begin
          //Pokud jsem na blokacni radek narazil poprve odblokuji vse nebo pozadovane mnozstvi, podle toho co je mensi
          mQToUnblock:=min_1(aQ,mRDS.FieldByName('Quantity').AsFloat);
          aDS.AppendRecord([mRDS.FieldByName('DT').AsString
                           ,mRDS.FieldByName('LSD_ID').AsString
                           ,mRDS.FieldByName('LSD2_ID').AsString
                           ,mRDS.FieldByName('SP_ID').AsString
                           ,aLSPTo
                           ,mRDS.FieldByName('SC_ID').AsString
                           ,mRDS.FieldByName('SB_ID').AsString
                           ,mRDS.FieldByName('QUnit').AsString
                           ,mRDS.FieldByName('UnitRate').AsFloat
                           ,mQToUnblock
                           ,mRDS.FieldByName('SD_ID').AsString
                           ,mRDS.FieldByName('SD2_ID').AsString
                            ]);

        end;
        //Ponizime pozadovane mnozstvi na co co jsme jiz odblokovali
        aQ:=aQ-mQToUnblock;
        //Pokracujeme na dalsi radek blokaci
        mRDS.Next;
      end;
    end;
  finally
    mRDS.Free;
    mRDS:=nil;
  end;
end;
///////////////////////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////////////////////
procedure UnblockPosition(aOS:TNxCustomObjectSpace;aDS:TMemTable);
var
  mCustomLSD,mLSDOut,mLSDTran,mLSDRow:TNxCustomBusinessObject;
  mLSDRows:TNxCustomBusinessMonikerCollection;
  mPrevDOCID:string;
begin
  mLSDOut :=aOS.CreateObject(Class_LogStoreOutput);
  mLSDTran:=aOS.CreateObject(Class_LogStoreTransfer);
  mCustomLSD:=nil;
  try
    aDS.First;
    mPrevDOCID:='';
    aDS.IndexName:=_c_SD2TTKeyName;
    while not aDS.Eof do
    begin
      if mPrevDOCID<>aDS.FieldByName('LSD_ID').AsString then
      begin
        if mPrevDOCID<>'' then
          mCustomLSD.Save;
        if aDS.FieldByName('DOCTYPE').AsString='32' then
          mCustomLSD:=mLSDOut
        else
          mCustomLSD:=mLSDTran;
        mCustomLSD.ExplicitTransaction:=aOS.InTransaction;
        mCustomLSD.Load(aDS.FieldByName('LSD_ID').AsString,nil);
        mLSDRows:=mCustomLSD.GetLoadedCollectionMonikerForFieldCode(mCustomLSD.GetFieldCode('Rows'));
      end;
      mLSDRow:=mLSDRows.BusinessObject(mLSDRows.IndexOfOID(aDS.FieldByName('LSD2_ID').AsString));
      if CFxFloat.GreaterThan6(mLSDRow.GetFieldValueAsFloat('Quantity'),aDS.FieldByName('Quantity').AsFloat) then
        mLSDRow.SetFieldValueAsFloat('Quantity',mLSDRow.GetFieldValueAsFloat('Quantity')-aDS.FieldByName('Quantity').AsFloat)
      else
        mLSDRow.MarkForDelete;
      mPrevDOCID:=aDS.FieldByName('LSD_ID').AsString;
      aDS.Next;
    end;
    if Assigned(mCustomLSD) then
     if mCustomLSD.NeedSave then
       mCustomLSD.Save;
  finally
    mLSDOut.Free;
    mLSDOut:=nil;
    mLSDTran.Free;
    mLSDTran:=nil;
    mCustomLSD:=nil;
  end;
end;
///////////////////////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////////////////////
procedure BlockPosition(aOS:TNxCustomObjectSpace;aDS:TMemTable);
var
  mCustomLSD,mLSDOut,mLSDTran,mLSDRow:TNxCustomBusinessObject;
  mLSDRows:TNxCustomBusinessMonikerCollection;
  mPrevDOCID:string;
begin
  mLSDOut :=aOS.CreateObject(Class_LogStoreOutput);
  mLSDTran:=aOS.CreateObject(Class_LogStoreTransfer);
  mCustomLSD:=nil;
  try
    aDS.First;
    mPrevDOCID:='';
    aDS.IndexName:=_c_SD2TTKeyName;
    while not aDS.Eof do
    begin
      if mPrevDOCID<>aDS.FieldByName('LSD_ID').AsString then
      begin
        if mPrevDOCID<>'' then
          mCustomLSD.Save;
        if aDS.FieldByName('DOCTYPE').AsString='32' then
          mCustomLSD:=mLSDOut
        else
          mCustomLSD:=mLSDTran;
        mCustomLSD.ExplicitTransaction:=aOS.InTransaction;
        mCustomLSD.Load(aDS.FieldByName('LSD_ID').AsString,nil);
        mLSDRows:=mCustomLSD.GetLoadedCollectionMonikerForFieldCode(mCustomLSD.GetFieldCode('Rows'));
      end;

      if not NxIsEmptyOID(GetIDWhere(aOS,'LogStoreDocuments2','ID='+QuotedStr(aDS.FieldByName('LSD2_ID').AsString))) then
      begin
        mLSDRow:=mLSDRows.BusinessObject(mLSDRows.IndexOfOID(aDS.FieldByName('LSD2_ID').AsString));
        mLSDRow.BeginModifyFields;
        try
          mLSDRow.SetFieldValueAsFloat('Quantity',mLSDRow.GetFieldValueAsFloat('Quantity')+aDS.FieldByName('Quantity').AsFloat);
        finally
          mLSDRow.EndModifyFields;
        end;
      end
      else
      begin
        mLSDRow:=mLSDRows.AddNewObject;
        mLSDRow.Prefill;
        mLSDRow.BeginModifyFields;
        try
          mLSDRow.SetFieldValueAsString('StorePosition_ID', aDS.FieldByName('SPTO_ID').AsString);
          mLSDRow.SetFieldValueAsString('Store_ID', mLSDRow.GetFieldValueAsString('StorePosition_ID.Store_ID'));
          mLSDRow.SetFieldValueAsString('StoreCard_ID', aDS.FieldByName('SC_ID').AsString);
          mLSDRow.SetFieldValueAsString('StoreBatch_ID', aDS.FieldByName('SB_ID').AsString);
          mLSDRow.SetFieldValueAsString('StoreDocRow_ID', aDS.FieldByName('SD2_ID').AsString);
          mLSDRow.SetFieldValueAsString('QUnit', aDS.FieldByName('QUnit').AsString);
          mLSDRow.SetFieldValueAsFloat('Quantity', aDS.FieldByName('Quantity').AsFloat);
          mLSDRow.SetFieldValueAsFloat('RestQuantity', 0);
        finally
          mLSDRow.EndModifyFields;
        end;
      end;
      mPrevDOCID:=aDS.FieldByName('LSD_ID').AsString;
      aDS.Next;
    end;
    if Assigned(mCustomLSD) then
     if mCustomLSD.NeedSave then
       mCustomLSD.Save;
  finally
    mLSDOut.Free;
    mLSDOut:=nil;
    mLSDTran.Free;
    mLSDTran:=nil;
    mCustomLSD:=nil;
  end;
end;
///////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
procedure saveTransferBetweenPositions(Self: TNxWebServicesHelper; ARequest: TNxHTTPRequest;
  AResponse: TNxHTTPResponse; slPath: TStringList);
var
  mJSON_Root, mJSON_Row: TJSONSuperObject;
  mJSON_Rows, jsonSerNums: TJSONSuperObjectArray;
  mBO, mRow: TNxCustomBusinessObject;
  mRows: TNxCustomBusinessMonikerCollection;
  i, j: Integer;
  mTemporaryStorageID: Integer;
  mRequestID, mUser_ID, mModule, mDocType, mSql, mUnblockPositions, mForbiddenPositions: String;
  mOS: TNxCustomObjectSpace;
  mUnblockPosition, mBlockedFirst: Boolean;
  mLSD2ToUnblockPosition, mAvailableQuantities :TMemTable;
  mMessage: String;
  mQuantity: Double;

  // vrati radu dokladu
  function GetDocQueueForDocument(AOS: TNxCustomObjectSpace; AModule, ADocType, AUser_ID, ADefaultDocQueue_ID: String; ASourceDocType: String = '';
    ADocument: TNxCustomBusinessObject = nil; AStore_ID: String = ''): String;
  var
    mDocQueue_ID: String;
  begin
    Result := '';

    mDocQueue_ID := GetDocQueue_ID(AOS, AModule, ADocType, AUser_ID, ASourceDocType, ADocument);
    if not CFxOID.IsEmpty(mDocQueue_ID) then
      Result := mDocQueue_ID
    else
      Result := ADefaultDocQueue_ID;
  end;

  // vrati mnozstvi, ktere je potreba navic k volnemu mnozsti odblokovat
  function GetNeedToUnblockQuantity(AAvailableQuantities: TMemTable; AStoreCard_ID, AStoreBatch_ID, AStorePosition_ID: String; AQuantity: Double): Double;
  var
    mAvailableQuantity: Double;
  begin
    if AAvailableQuantities.FindKey([AStoreCard_ID, AStoreBatch_ID, AStorePosition_ID]) then
    begin
      AAvailableQuantities.Edit;
      if mJSON_Row.D['UnitQuantity'] > AAvailableQuantities.FieldByName('Quantity').AsFloat then
      begin
        AQuantity := AQuantity - AAvailableQuantities.FieldByName('Quantity').AsFloat;
        AAvailableQuantities.FieldByName('Quantity').AsFloat := 0;
      end
      else
      begin
        AAvailableQuantities.FieldByName('Quantity').AsFloat := AAvailableQuantities.FieldByName('Quantity').AsFloat - AQuantity;
        AQuantity := 0;
      end;
      AAvailableQuantities.Post;
    end
    else
    begin
      mSql :=
        'select' + nxCrLf +
        '  Quantity - QuantityReserved' + nxCrLf +
        'from LogStoreContents' + nxCrLf +
        'where' + nxCrLf +
        '  StoreCard_ID = ' + QuotedStr(AStoreCard_ID) + nxCrLf +
        '  and Parent_ID = ' + QuotedStr(AStorePosition_ID) + nxCrLf;

      if not CFxOID.IsEmpty(AStoreBatch_ID) then
        mSql := mSql +
          ' and StoreBatch_ID = ' + QuotedStr(AStoreBatch_ID);

      mAvailableQuantity := SQLSelectFloat(mOS, mSql);

      // pokud potrebuju vic nez je dostupny, tak budu muset brat i blokovane,
      AAvailableQuantities.Edit;
      AAvailableQuantities.FieldByName('StoreCard_ID').AsString := AStoreCard_ID;
      AAvailableQuantities.FieldByName('StoreBatch_ID').AsString := AStoreBatch_ID;
      AAvailableQuantities.FieldByName('StorePosition_ID').AsString := AStorePosition_ID;

      if AQuantity > mAvailableQuantity then
      begin
        AQuantity := AQuantity - mAvailableQuantity;
        AAvailableQuantities.FieldByName('Quantity').AsFloat := 0;
      end
      else
      begin
        AAvailableQuantities.FieldByName('Quantity').AsFloat := AAvailableQuantities.FieldByName('Quantity').AsFloat - AQuantity;
        AQuantity := 0;
      end;
      AAvailableQuantities.Post;
    end;

    Result := AQuantity;
  end;
begin
  if (slPath.Count = 1) then
  begin
    //mDocType := slPath.Strings[1];
  end else
  begin
    ErrREST(ARequest, AResponse, HTTP_SC_BadRequest, getString('wrong_parameters_count'));
    exit;
  end;

  mModule := getHeaderValue(ARequest, 'ModuleCode');
  mUser_ID := getHeaderValue(ARequest, 'UserID');
  mDocType := getHeaderValue(ARequest, 'DocumentType');

  mBlockedFirst := False;
  mOS := Self.ObjectSpace;
  LogWriteSectionStart('saveTransferBetweenPositions');
  mJSON_Root := TJSONSuperObject.ParseString(GetStringFromBytes(ARequest.Content.Content, TEncoding.UTF8), True);
  try
    mRequestID := REST_getJSONStr(mJSON_Root, 'saveRequestID');
    // pred transakci overime, jestli uz tento request nebezi nebo neni dokonce dokonceny. Pokud ne, tak ho zalozime.
    case Request_Start(mOS, mRequestID, 'saveTransferBetweenPositions') of
      1: begin
        ErrREST(ARequest, AResponse, HTTP_SC_ExpectationFailed, getString('request_in_process'));
        exit;
      end;
      2: begin
        HTTPResponse(AResponse, HTTP_SC_OK, ContentType_JSON, PlainResponse(''));
        exit;
      end;
    end;

    mOS.StartTransaction(taReadCommited);
    try
      mTemporaryStorageID := REST_getJSONInt(mJSON_Root, 'tempID');
      mJSON_Rows := mJSON_Root.A['rows'];

      //Pokud jsou definovany stav pro presun cele pozice,
      //znamena to, ze budeme pracovat v rezimu odblokovani pozice pro presun
      //a po ulozeni prevodu opetovnem zablokovani na nove pozici
      mUnblockPositions := POVOLENE_STAVY_PRESUN_CELE_POZICE(Self.ObjectSpace, mModule, mDocType, mUser_ID, mJSON_Root, mBlockedFirst);
      mUnblockPosition := mUnblockPositions <> '';
      mForbiddenPositions := ZAKAZANE_POZICE_PRESUN_CELE_POZICE(Self.ObjectSpace, mModule, mDocType, mUser_ID, mJSON_Root, mBlockedFirst);

      if mUnblockPosition then
      begin
        //kontrola celeho dokladu jeste jednou pred ulozenim... Kontroluje se jen v pripade nutnosti odblokovani
        if not isTransferBetweenPositionsAllowedWholeDoc(Self.Context, mJSON_Rows, mForbiddenPositions, mUnblockPositions, mMessage) then
          RaiseException(mMessage);
      end;

      //Potrebujeme dataset, ktere pozice bude treba odblokovat.
      //Odblokovani probehne ve dvou krocich, nejprve se z polohovacich dokladu
      //odmazou blokujici radky, pak se provede presun a nakonec se blokujici radky
      //znovu vlozi na polohovaci doklady...
      //To co se ma odmazat z blokujicich dokladu se v prubehu vkladani radku ulozi do mLSD2ToUnblockPosition
      mLSD2ToUnblockPosition := TMemTable.Create(nil);
      DataSet_CreataHeader(mLSD2ToUnblockPosition, 'DOCTYPE=S10,LSD_ID=S10,LSD2_ID=S10,SP_ID=S10,SPTO_ID=S10,SC_ID=S10,SB_ID=S10,QUnit=S10,UnitRate=F,Quantity=F,SD_ID=S10,SD2_ID=S10');
      mAvailableQuantities := TMemTable.Create(nil);
      mLSD2ToUnblockPosition.AddIndex(_c_SD2TTKeyName,'LSD2_ID',[ixUnique]);
      try
        DataSet_CreataHeader(mAvailableQuantities, 'StoreCard_ID=S10,StoreBatch_ID=10,StorePosition_ID=S10,Quantity=F');
        mAvailableQuantities.AddIndex('index', 'StoreCard_ID;StoreBatch_ID;StorePosition_ID', [ixUnique]);
        mAvailableQuantities.IndexName := 'index';

        mBO := mOS.CreateObject(Class_LogStoreTransfer);
        try
          mBO.ExplicitTransaction := True;
          mBO.New;
          mBO.Prefill;
          mBO.SetFieldValueAsString('DocQueue_ID',
            GetDocQueueForDocument(Self.ObjectSpace, mModule, DOC_LogStoreTransfer, mUser_ID, LogStoreTransfer_DocQueue_ID, '', nil, mJSON_Root.S['Store_ID']));
          mBO.SetFieldValueAsString('Firm_ID', FIRM_OWN);
          mRows := mBO.GetCollectionMonikerForFieldCode(mBO.GetFieldCode('Rows'));

          for i := 0 to mJSON_Rows.Length - 1 do
          begin
            mJSON_Row := mJSON_Rows.O[i];

            // pokud jsou zadana seriova cisla, jedeme podle nich
            if mJSON_Row.I['StoreCardCategory'] = 1 then
            begin
              jsonSerNums := mJSON_Row.A['sernums'];
              for j := 0 to jsonSerNums.Length - 1 do
              begin
                mRow := mRows.AddNewObject;
                mRow.Prefill;
                mRow.SetFieldValueAsString('Store_ID', mJSON_Row.S['StoreFrom_ID']);
                mRow.SetFieldValueAsString('StoreCard_ID', mJSON_Row.S['StoreCard_ID']);
                mRow.SetFieldValueAsString('StorePosition_ID', mJSON_Row.S['StorePositionFrom_ID']);
                mRow.SetFieldValueAsString('IncomingStorePosition_ID', mJSON_Row.S['StorePositionTo_ID']);
                mRow.SetFieldValueAsString('StoreBatch_ID', jsonSerNums.O[j].S['SerNum_ID']);
                mRow.SetFieldValueAsString('QUnit', mJSON_Row.S['UnitCode']);
                mRow.SetFieldValueAsFloat('Quantity', 1);

                // pokud se presouva nejdriv volne mnozstvi, tak musim zjistit kolik volneho vlastne mam
                // takze si do datasetu ulozim k artiklu volne mnozstvi a od nej pak odecitam.
                // pozadovane blokovane mnozstvi pak beru jen kdyz dojde volne
                // TODO tahle cast neni otestovana
                mQuantity := 1;
                if not mBlockedFirst and (pos(mJSON_Row.S['StorePositionTo_ID'], mForbiddenPositions) = 0) then
                begin
                  mQuantity := GetNeedToUnblockQuantity(mAvailableQuantities, mJSON_Row.S['StoreCard_ID'], mJSON_Row.S['StoreBatch_ID'],
                    mJSON_Row.S['StorePositionFrom_ID'], mQuantity);
                end;

                if mUnblockPosition and (pos(mJSON_Row.S['StorePositionTo_ID'], mForbiddenPositions) = 0) then
                  GetBlockingRows(mOS
                                  ,mJSON_Row.S['StoreCard_ID']
                                  ,jsonSerNums.O[j].S['SerNum_ID']
                                  ,mJSON_Row.S['StorePositionFrom_ID']
                                  ,mJSON_Row.S['StorePositionTo_ID']
                                  ,mUnblockPositions
                                  ,mQuantity
                                  ,mLSD2ToUnblockPosition);
              end;
            end
            else begin
              mRow := mRows.AddNewObject;
              mRow.Prefill;
              mRow.SetFieldValueAsString('Store_ID', mJSON_Row.S['StoreFrom_ID']);
              mRow.SetFieldValueAsString('StoreCard_ID', mJSON_Row.S['StoreCard_ID']);
              mRow.SetFieldValueAsString('StorePosition_ID', mJSON_Row.S['StorePositionFrom_ID']);
              mRow.SetFieldValueAsString('IncomingStorePosition_ID', mJSON_Row.S['StorePositionTo_ID']);
              mRow.SetFieldValueAsString('StoreBatch_ID', mJSON_Row.S['StoreBatch_ID']);
              mRow.SetFieldValueAsString('QUnit', mJSON_Row.S['UnitCode']);
              if mJSON_Row.D['UnitRate'] > 0 then
                mRow.SetFieldValueAsFloat('Quantity', mJSON_Row.D['UnitQuantity'] * mJSON_Row.D['UnitRate'])
              else
                mRow.SetFieldValueAsFloat('Quantity', mJSON_Row.D['UnitQuantity']);

              // pokud se presouva nejdriv volne mnozstvi, tak musim zjistit kolik volneho vlastne mam
              // takze si do datasetu ulozim k artiklu volne mnozstvi a od nej pak odecitam.
              // pozadovane blokovane mnozstvi pak beru jen kdyz dojde volne
              if not mBlockedFirst and (pos(mJSON_Row.S['StorePositionTo_ID'], mForbiddenPositions) = 0) then
              begin
                mJSON_Row.D['UnitQuantity'] := GetNeedToUnblockQuantity(mAvailableQuantities, mJSON_Row.S['StoreCard_ID'], mJSON_Row.S['StoreBatch_ID'],
                  mJSON_Row.S['StorePositionFrom_ID'], mJSON_Row.D['UnitQuantity']);
              end;

              if mUnblockPosition and (pos(mJSON_Row.S['StorePositionTo_ID'], mForbiddenPositions) = 0) then
                GetBlockingRows(mOS
                                ,mJSON_Row.S['StoreCard_ID']
                                ,mJSON_Row.S['StoreBatch_ID']
                                ,mJSON_Row.S['StorePositionFrom_ID']
                                ,mJSON_Row.S['StorePositionTo_ID']
                                ,mUnblockPositions
                                ,mJSON_Row.D['UnitQuantity']
                                ,mLSD2ToUnblockPosition);
            end;
          end;

          //Odblokujeme
          if mUnblockPosition then
            if mLSD2ToUnblockPosition.Active then
              UnblockPosition(mOS,mLSD2ToUnblockPosition);

          mBO.Save;
          TNxLogStoreDocument(mBO).MakeExecuted;

          //Zablokujeme
          if mUnblockPosition then
            if mLSD2ToUnblockPosition.Active then
              BlockPosition(mOS,mLSD2ToUnblockPosition);
        finally
          mBO.Free;
        end;
      finally
        mLSD2ToUnblockPosition.Free;
        mAvailableQuantities.Free;
      end;

      // vymaz z TemporaryStorage jeste v transakci
      TemporaryStorage_Delete(mOS, mTemporaryStorageID);

      Request_Finish(mOS, mRequestID);

      mOS.Commit;

      HTTPResponse(AResponse, HTTP_SC_OK, ContentType_JSON, PlainResponse(''));
    except
      mOS.RollBack;
      ErrREST(ARequest, AResponse, HTTP_SC_InternalServerError, getString('error_saving_transfer_position') + ExceptionMessage);
      Request_Cancel(mOS, mRequestID);
      LogWriteSectionEnd;
      exit;
    end;
  finally
    mJSON_Root.Free;
  end;
  LogWriteSectionEnd;
end;//saveTransferBetweenPositions
////////////////////////////////////////////////////////////////////////////////

procedure put_SaveTransferBetweenPositionsQueue(Self: TNxWebServicesHelper; ARequest: TNxHTTPRequest;
  AResponse: TNxHTTPResponse; slPath: TStringList);
var
  mDoc_ID, mUser_Id, mModule, mDocType, mRequestID, mAuxField, mAuxFieldTextOld, mSerNum_ID, mStoreBatch_ID: String;
  json: TJSONSuperObject;
  dtJSONRows: TMemTable;
  mNewLSDs: TStringList;
  mLSD,
   mLSDRow, mStoreBatch, mLSDNew, mLSDRowNew: TNxCustomBusinessObject;
  mLSDRows: TNxCustomBusinessMonikerCollection;
  mTemporaryStorageID, i, j: Integer;
  mAuxReadOnly, mAllSelectedByBarcode: Boolean;
  mRowUnitQuantityProcessed: Double;
  jsonSerNums: TJSONSuperObjectArray;

  procedure AddRow;
  var
    mLSDRow: TNxCustomBusinessObject;
  begin
    if dtJSONRows.FieldByName('StoreCardCategory').AsInteger = 1 then
    begin
      jsonSerNums := json.A['rows'].O[dtJSONRows.FieldByName('jsonIndex').AsInteger].A['sernums'];

      for j := 0 to jsonSerNums.Length - 1 do
      begin
        mLSDRow := mLSDRows.AddNewObject;
        mLSDRow.Prefill;
        mLSDRow.SetFieldValueAsString('Store_ID', dtJSONRows.FieldByName('StoreFrom_ID').AsString);
        mLSDRow.SetFieldValueAsString('StoreCard_ID', dtJSONRows.FieldByName('StoreCard_ID').AsString);

        if CFxOID.IsEmpty(jsonSerNums.O[j].S['SerNum_ID']) then
        begin
          mSerNum_ID := '';
          if isUsingExistingSerNumberAllowed then
          begin
            // zkusim sarzi ser. cislo
            mSerNum_ID := SQLSelectStr(Self.ObjectSpace, 'select ID from StoreBatches where Name = ' + QuotedStr(jsonSerNums.O[j].S['SerNumName'])
              + ' and StoreCard_ID = ' + QuotedStr(dtJSONRows.FieldByName('StoreCard_ID').AsString) + 'and Hidden = ''N''');
          end;

          // pokud jsem ser. cislo nasel, tak ho vyplnim
          if mSerNum_ID <> '' then
          begin
            mLSDRow.SetFieldValueAsString('StoreBatch_ID', mSerNum_ID);

            // doplnim aux text do specifikace
            mStoreBatch := Self.ObjectSpace.CreateObject(Class_StoreBatch);
            try
              mStoreBatch.ExplicitTransaction := True;
              mStoreBatch.Load(mSerNum_ID, nil);
              mStoreBatch.SetFieldValueAsString('Specification', jsonSerNums.O[j].S['AuxText']);
              mStoreBatch.Save;
            finally
              mStoreBatch.Free;
            end;
          end
          else
          begin
            mStoreBatch := Self.ObjectSpace.CreateObject(Class_StoreBatch);
            try
              mStoreBatch.ExplicitTransaction := True;
              mStoreBatch.New;
              mStoreBatch.Prefill;
              mStoreBatch.SetFieldValueAsString('StoreCard_ID', dtJSONRows.FieldByName('StoreCard_ID').AsString);
              mStoreBatch.SetFieldValueAsBoolean('SerialNumber', True);
              mStoreBatch.SetFieldValueAsString('Name', jsonSerNums.O[j].S['SerNumName']);
              mStoreBatch.SetFieldValueAsString('Specification', jsonSerNums.O[j].S['AuxText']);
              mStoreBatch.Save;
              mStoreBatch_ID := mStoreBatch.OID;
            finally
              mStoreBatch.Free;
            end;

            mLSDRow.SetFieldValueAsString('StoreBatch_ID', mStoreBatch_ID);
          end;
        end
        else
        begin
          mLSDRow.SetFieldValueAsString('StoreBatch_ID', jsonSerNums.O[j].S['SerNum_ID']);
        end;
        gLog.WriteEventFmt(logDebug, '....Sériové číslo %s (%s,)',
          [dtJSONRows.FieldByName('StoreBatch_ID').AsString, mLSDRow.GetFieldValueAsString('StoreBatch_ID.Name')]);

        mLSDRow.SetFieldValueAsString('StorePosition_ID', dtJSONRows.FieldByName('StorePositionFrom_ID').AsString);
        mLSDRow.SetFieldValueAsString('IncomingStorePosition_ID', dtJSONRows.FieldByName('StorePositionTo_ID').AsString);
        mLSDRow.SetFieldValueAsString('QUnit', dtJSONRows.FieldByName('UnitCode').AsString);
      end;
    end
    else
    begin
      mLSDRow := mLSDRows.AddNewObject;
      mLSDRow.Prefill;
      mLSDRow.SetFieldValueAsString('Store_ID', dtJSONRows.FieldByName('StoreFrom_ID').AsString);
      mLSDRow.SetFieldValueAsString('StoreCard_ID', dtJSONRows.FieldByName('StoreCard_ID').AsString);
      mLSDRow.SetFieldValueAsString('StoreBatch_ID', dtJSONRows.FieldByName('StoreBatch_ID').AsString);
      mLSDRow.SetFieldValueAsString('StorePosition_ID', dtJSONRows.FieldByName('StorePositionFrom_ID').AsString);
      mLSDRow.SetFieldValueAsString('IncomingStorePosition_ID', dtJSONRows.FieldByName('StorePositionTo_ID').AsString);
      mLSDRow.SetFieldValueAsString('QUnit', dtJSONRows.FieldByName('UnitCode').AsString);

      if useMainUnits(Self.ObjectSpace, mModule, mDocType, mUser_ID) then
        mLSDRow.SetFieldValueAsFloat('Quantity', CFxFloat.DivideDef6(dtJSONRows.FieldByName('UnitQuantity').AsFloat,  dtJSONRows.FieldByName('UnitRate').AsFloat, 0))
      else
        mLSDRow.SetFieldValueAsFloat('Quantity', dtJSONRows.FieldByName('UnitQuantity').AsFloat);

      mLSDRow.SetFieldValueAsFloat('RestQuantity', 0);
    end;

  end;
begin
  json := nil;
  if (slPath.Count = 2) then
  begin
    mDoc_ID := slPath.Strings[1]; //ocekavam ID dokladu
  end else
  begin
    ErrREST(ARequest, AResponse, HTTP_SC_BadRequest, getString('wrong_parameters_count'));
    exit;
  end;

  LogWriteSectionStart('put_SaveTransferBetweenPositionsQueue');

  mUser_Id := getHeaderValue(ARequest, 'UserID');
  mModule := getHeaderValue(ARequest, 'ModuleCode');
  mDocType := getHeaderValue(ARequest, 'DocumentType');

  json := TJSONSuperObject.ParseString(REST_ByteUTF82String(ARequest.Content.Content), True);
  dtJSONRows := TMemTable.Create(nil);
  mNewLSDs := TStringList.Create;
  mLSD := Self.ObjectSpace.CreateObject(Class_LogStoreTransfer);
  try
    mTemporaryStorageID := REST_getJSONInt(json, 'tempID');

    gLog.WriteEvent(logDebug, 'Kontrola request ID');
    mRequestID := REST_getJSONStr(json, 'saveRequestID');
    // pred transakci overime, jestli uz tento request nebezi nebo neni dokonce dokonceny. Pokud ne, tak ho zalozime.
    case Request_Start(Self.ObjectSpace, mRequestID, mModule) of
      1: begin
        ErrREST(ARequest, AResponse, HTTP_SC_ExpectationFailed, getString('request_in_process'));
        exit;
      end;
      2: begin
        HTTPResponse(AResponse, HTTP_SC_OK, ContentType_JSON, PlainResponse(''));
        exit;
      end;
    end;

    Self.ObjectSpace.StartTransaction(taReadCommited);
    try
      gLog.WriteEvent(logDebug, 'Zahájena transakce');

      DataSet_CreataHeader(dtJSONRows, 'jsonIndex=I,StoreDocument_ID=S10,StoreDocument2_ID=S10,StoreDocument2Provide_ID=S10,StoreDocument2ProvideRow_ID=S10,' +
        'DocRowBatch_ID=S10,LogStoreDocument2_ID=S10,StoreFrom_ID=S10,StoreTo_ID=S10,StoreCard_ID=S10,StorePositionFrom_ID=S10,IsDamaged=B,' +
        'StoreBatch_ID=S10,StorePositionTo_ID=S10,Processed=B,UnitQuantity=F,UnitRate=F,UnitCode=S10,Division_ID=S10,WasSelectedByBarcode=B,' +
        'IsNew=B,AccJobOrder_ID=S10,PRFContainerMater_ID=S10,BusProject_ID=S10,BusOrder_ID=S10,BusTransaction_ID=S10,EnterStoreBatchExpirationDate=B,' +
        'StoreBatchExpirationDate=S16,StoreCardCategory=I'
        + putQueueDocDetailStopPicking_rowsDatasetFields(Self.ObjectSpace, mModule));
      dtJSONRows.AddIndex('ByJsonIndex', 'jsonIndex', [ixUnique]);
      dtJSONRows.AddIndex('ByStoreDocument2_ID', 'StoreDocument_ID;StoreDocument2_ID;jsonIndex', [ixUnique]);
      dtJSONRows.AddIndex('BySD2_IDBatch_ID', 'StoreDocument_ID;StoreDocument2_ID;StoreBatch_ID;jsonIndex', [ixUnique]);
      dtJSONRows.Open;
      REST_JsonToDataSet(json.A['rows'], dtJSONRows);

      gLog.WriteEvent(logDebug, 'Vytvořeny hlavičky datasetů');

      mLSD.ExplicitTransaction := True;
      mLSD.Load(mDoc_ID, nil);

      // schovam si puvodni hodnotu a nastavim novy AuxText
      mAuxField := StoreDocumentAuxTextField(mModule, mAuxReadOnly);
      if (mAuxField <> '') and ((not mAuxReadOnly)) then
      begin
        mAuxFieldTextOld := mLSD.GetFieldValueAsString(mAuxField);
        mLSD.SetFieldValueAsString(mAuxField, json.S['AuxText']);
      end;

      gLog.WriteEvent(logDebug, 'Smazání řádků');
      mLSDRows := mLSD.GetLoadedCollectionMonikerForFieldCode(mLSD.GetFieldCode('Rows'));
      mLSDRows.MarkForDeleteAll;

      gLog.WriteEvent(logDebug, 'Přidávání řádků');
      dtJSONRows.IndexName := 'ByJsonIndex';
      dtJSONRows.First;
      while not dtJSONRows.Eof do
      begin
        if not dtJSONRows.FieldByName('Processed').AsBoolean then
        begin
          gLog.WriteEventFmt(logDebug, '..PŘESKAKUJI - Původní ID, artikl, šarže, pozice, pozice na, množství (%s, %s, %s, %s, %s, %f)',
            [dtJSONRows.FieldByName('StoreDocument2_ID').AsString, dtJSONRows.FieldByName('StoreCard_ID').AsString, dtJSONRows.FieldByName('StoreBatch_ID').AsString,
            dtJSONRows.FieldByName('StorePositionFrom_ID').AsString, dtJSONRows.FieldByName('StorePositionTo_ID').AsString, dtJSONRows.FieldByName('UnitQuantity').AsFloat]);
          dtJSONRows.Next;
          continue;
        end;

        gLog.WriteEventFmt(logDebug, '..Původní ID, artikl, šarže, pozice, pozice na, množství (%s, %s, %s, %s, %s, %f)',
          [dtJSONRows.FieldByName('StoreDocument2_ID').AsString, dtJSONRows.FieldByName('StoreCard_ID').AsString, dtJSONRows.FieldByName('StoreBatch_ID').AsString,
          dtJSONRows.FieldByName('StorePositionFrom_ID').AsString, dtJSONRows.FieldByName('StorePositionTo_ID').AsString, dtJSONRows.FieldByName('UnitQuantity').AsFloat]);

        AddRow;

        dtJSONRows.Next;
      end;

      beforeSaveHook(Self.ObjectSpace, mModule, mLSD, 0, json, dtJSONRows);
      gLog.WriteEvent(logDebug, 'Uložení dokladu');
      mLSD.Save;
      afterSaveHook(Self.ObjectSpace, mModule, mUser_Id, mLSD, 0, json, dtJSONRows);

      TNxLogStoreDocument(mLSD).MakeExecuted;

      // vytvoreni oddeleho dokladu na nepotvrzene mnozstvi
      mLSDNew := Self.ObjectSpace.CreateObject(Class_LogStoreTransfer);
      try
        gLog.WriteEvent(logDebug, 'Vytvoření odděleného dokladu');
        mLSDNew.ExplicitTransaction := True;
        mLSDNew.New;
        mLSDNew.Prefill;
        mLSDNew.SetFieldValueAsString('DocQueue_ID', mLSD.GetFieldValueAsString('DocQueue_ID'));
        mLSDNew.SetFieldValueAsString('Firm_ID', mLSD.GetFieldValueAsString('Firm_ID'));

        mLSDRows := mLSDNew.GetLoadedCollectionMonikerForFieldCode(mLSD.GetFieldCode('Rows'));

        gLog.WriteEvent(logDebug, 'Přidávání řádků');
        dtJSONRows.IndexName := 'ByJsonIndex';
        dtJSONRows.First;
        while not dtJSONRows.Eof do
        begin
          if dtJSONRows.FieldByName('Processed').AsBoolean then
          begin
            gLog.WriteEventFmt(logDebug, '..PŘESKAKUJI - Původní ID, artikl, šarže, pozice, pozice na, množství (%s, %s, %s, %s, %s, %f)',
              [dtJSONRows.FieldByName('StoreDocument2_ID').AsString, dtJSONRows.FieldByName('StoreCard_ID').AsString, dtJSONRows.FieldByName('StoreBatch_ID').AsString,
              dtJSONRows.FieldByName('StorePositionFrom_ID').AsString, dtJSONRows.FieldByName('StorePositionTo_ID').AsString, dtJSONRows.FieldByName('UnitQuantity').AsFloat]);
            dtJSONRows.Next;
            continue;
          end;

          gLog.WriteEventFmt(logDebug, '..Původní ID, artikl, šarže, pozice, pozice na, množství (%s, %s, %s, %s, %s, %f)',
            [dtJSONRows.FieldByName('StoreDocument2_ID').AsString, dtJSONRows.FieldByName('StoreCard_ID').AsString, dtJSONRows.FieldByName('StoreBatch_ID').AsString,
            dtJSONRows.FieldByName('StorePositionFrom_ID').AsString, dtJSONRows.FieldByName('StorePositionTo_ID').AsString, dtJSONRows.FieldByName('UnitQuantity').AsFloat]);

          AddRow;

          dtJSONRows.Next;
        end;

        gLog.WriteEvent(logDebug, 'Uložení dokladu');

        if mLSDNew.NeedSave and (mLSDRows.Count > 0) then
          mLSDNew.Save;
      finally
        mLSDNew.Free;
      end;

      TemporaryStorage_Delete(Self.ObjectSpace, mTemporaryStorageID);

      Request_Finish(Self.ObjectSpace, mRequestID);

      Self.ObjectSpace.Commit;

      HTTPResponse(AResponse, HTTP_SC_OK, ContentType_JSON, PlainResponse(''));
    except
      Self.ObjectSpace.Rollback;
      HTTPResponse(AResponse, HTTP_SC_OK, ContentType_JSON, PlainResponse(Format(getString('error_stopping_docqueue'), [ExceptionMessage])));
      Request_Cancel(Self.ObjectSpace, mRequestID);
      exit;
    end;

  finally
    json.Free;
    dtJSONRows.Free;
    mNewLSDs.Free;
    mLSD.Free;
    LogWriteSectionEnd;
  end;
end;

begin
end.