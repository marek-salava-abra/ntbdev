uses
  'REST_SkladTerm.U_Func',
  'REST_SkladTerm.U_Translation',
  'REST_SkladTerm_Special.U_Const',
  'StandardUnits.U_GetId';

////////////////////////////////////////////////////////////////////////////////
//doplneni pozic do polohovaciho dokladu
//predpokladam, ze pozice NEJSOU na radcich jeste zapsany
//hodnotu fieldu datasetu Quantity postupne snizuju, jak zaznami umistuji na doklad
function REST_Create_LogStoreDocument(
  OS                              : TNxCustomObjectSpace;
  InputDocument                   : TNxCustomBusinessObject;
  LogStoreDocument_ID             : string; //pokud je prazdne, tak vytvarim novy. jinak upravuju predany
  LogStoreDocument_Class_CLSID    : string;
  LogStoreDocument_DocQueue_ID    : string;
  LogStoreDocument_StoreGateway_ID: string;
  dsRow                           : TMemTable; //Store_ID,StoreCard_ID,StoreBatch_ID,StorePosition_ID,Quantity
  user_id                         : string;//skladnik
  aExecute                        : boolean; //provest?
  ): string;
var
  DIM    : TNxDocumentImportManager;
  mParams: TNxParameters;
  Row    : TNxCustomBusinessObject;
  RowN   : TNxCustomBusinessObject;
  Rows   : TNxCustomBusinessMonikerCollection;
  LogStoreDocument: TNxLogStoreDocument;
  i      : integer;
  Opakovat: boolean;
begin
  gLog.WriteEvent(logDebug, 'Create_LogStoreDocument - BEGIN');
  result:= nil;

  try
    //vytvorim polohovaci doklad (pokud uz nemam)
    //if(LogStoreDocument_ID = '')then begin
      mParams:= TNxParameters.Create;
      DIM:= NXCreateDocumentImportManager(OS, InputDocument.GetFieldValueAsString('ClassID'), LogStoreDocument_Class_CLSID);
      try
        //vytvorim pomoci importniho manazera
        DIM.SaveParams(mParams);
        mParams.GetOrCreateParam(dtstring,'DocQueue_ID').AsString:= LogStoreDocument_DocQueue_ID;
        mParams.GetOrCreateParam(dtstring,'StoreGateway_ID').asstring := LogStoreDocument_StoreGateway_ID;
        DIM.LoadParams(mParams);
        DIM.AddInputDocument(InputDocument.OID);
        DIM.SelectedHeader := InputDocument;
        if not CFxOID.IsEmpty(LogStoreDocument_ID) then
        begin
          LogStoreDocument:= TNxLogStoreDocument(OS.CreateObject(LogStoreDocument_Class_CLSID));
          LogStoreDocument.Load(LogStoreDocument_ID, nil);
          DIM.OutputDocument := LogStoreDocument;
        end;
        DIM.Execute;
        LogStoreDocument:= TNxLogStoreDocument(DIM.OutputDocument);
        LogStoreDocument.ExplicitTransaction:= OS.InTransaction;
      finally
        mParams.free;
      end;
    //end else begin
    //  LogStoreDocument:= TNxLogStoreDocument(OS.CreateObject(LogStoreDocument_Class_CLSID));
    //  LogStoreDocument.ExplicitTransaction:= OS.InTransaction;
    //  LogStoreDocument.Load(LogStoreDocument_ID, nil);
    //end;

    //skladnik (pokud jsem dostal uzivatele)
    if not ABRA and (user_id <> '') then
      LogStoreDocument.SetFieldValueAsString('StoreMan_ID',
        sqlSelectStr(OS, 'Select Person_ID from SecurityUsers where ID='+QuotedStr(user_id)));

    //radky
    gLog.WriteEvent(logDebug, '.Rows - BEGIN');
    Rows:= LogStoreDocument.GetLoadedCollectionMonikerForFieldCode(LogStoreDocument.GetFieldCode('Rows'));

    //projdu radky pol. dokladu a doplnim k nim udaje
    Opakovat:= true;
    while Opakovat do begin
      Opakovat:= false;
      for i := 0 to Rows.Count - 1 do begin
        Row:= Rows.BusinessObject[i];

        gLog.WriteEventFmt(logDebug, '..Row %d BEGIN - StoreCard_ID=%s Quantity=%f Unit=%s',
          [i, Row.GetFieldValueAsString ('StoreCard_ID'), Row.GetFieldValueAsFloat('Quantity'), Row.GetFieldValueAsString('QUnit')]
        );

        //uz nemam mnozstvi na umisteni do pozice
        if Row.GetFieldValueAsFloat('RestQuantity') = 0 then begin
          gLog.WriteEvent(logDebug, '.Rows - END (RestQuantity=0)');
          continue;
        end;

        //polozka muze byt prijata na vice ruznych pozic
        dsRow.First;
        if(dsRow.FindNearest([
          Row.GetFieldValueAsString('Store_ID'),
          Row.GetFieldValueAsString('StoreCard_ID'),
          Row.GetFieldValueAsString('StoreBatch_ID'),
          '']))
          OR  //nebo sem si poslal polozky bez sarze
          (dsRow.FindNearest([
          Row.GetFieldValueAsString('Store_ID'),
          Row.GetFieldValueAsString('StoreCard_ID'),
          'ZZZZZZZZZZ',
          '']))
        then begin
          while
              (not dsRow.eof) AND
              (dsRow.FieldByName('Store_ID').AsString = Row.GetFieldValueAsString('Store_ID')) AND
              (dsRow.FieldByName('StoreCard_ID').AsString = Row.GetFieldValueAsString('StoreCard_ID')) AND
              ((dsRow.FieldByName('StoreBatch_ID').AsString = 'ZZZZZZZZZZ') OR
               (dsRow.FieldByName('StoreBatch_ID').AsString = Row.GetFieldValueAsString('StoreBatch_ID'))
              )
            do begin
            try
              if(dsRow.FieldByName('Quantity').AsFloat = 0)then begin
                gLog.WriteEvent(logDebug,'...Row %d not EDIT (Quantity=0)');
                continue;
              end;

              //mam dostatek - umistim vse na pozici
              if(dsRow.FieldByName('Quantity').AsFloat >= Row.GetFieldValueAsFloat('RestQuantity'))then begin
                Row.BeginModifyFields;
                Row.SetFieldValueAsString('StorePosition_ID', dsRow.FieldByName('StorePosition_ID').AsString);
                Row.SetFieldValueAsFloat ('Quantity'        , Row.GetFieldValueAsFloat('RestQuantity'));
                Row.SetFieldValueAsFloat ('RestQuantity'    , 0);
                Row.EndModifyFields;

                dsRow.edit;
                dsRow.FieldByName('Quantity').AsFloat:=
                  dsRow.FieldByName('Quantity').AsFloat - Row.GetFieldValueAsFloat('Quantity');
                dsRow.post;

              end else begin
                //nemam dostatek - musim polozku na doklade rozdelit
                Opakovat:= true; //musim znovu projit radky
                RowN:= Rows.AddNewObject;
                RowN.prefill;
                RowN.BeginModifyFields;
                RowN.SetFieldValueAsString('Storecard_ID'    ,Row.GetFieldValueAsString('Storecard_ID'));
                RowN.SetFieldValueAsString('Store_ID'        ,Row.GetFieldValueAsString('Store_ID'));
                RowN.SetFieldValueAsString('StoreBatch_ID'   ,Row.GetFieldValueAsString('StoreBatch_ID'));
                RowN.SetFieldValueAsString('StoreDocRow_ID'  ,Row.GetFieldValueAsString('StoreDocRow_ID'));
                RowN.SetFieldValueAsString('StorePosition_ID','0000000000');
                RowN.SetFieldValueAsString('QUnit'           ,Row.GetFieldValueAsString('QUnit'));
                RowN.SetFieldValueAsFloat ('Quantity'        ,0);
                RowN.SetFieldValueAsFloat ('RestQuantity'    ,Row.GetFieldValueAsFloat('RestQuantity')-dsRow.FieldByName('Quantity').AsFloat);
                RowN.EndModifyFields;

                Row.BeginModifyFields;
                Row.SetFieldValueAsString('StorePosition_ID',dsRow.FieldByName('StorePosition_ID').AsString);
                Row.SetFieldValueAsFloat ('Quantity'        ,dsRow.FieldByName('Quantity').AsFloat);
                Row.SetFieldValueAsFloat ('RestQuantity'    ,0);
                Row.EndModifyFields;

                dsRow.edit;
                dsRow.FieldByName('Quantity').AsFloat:=0;
                dsRow.post;
              end;

              //log
              gLog.WriteEventFmt(logDebug,'...Row %d EDIT:id=%s,Store_ID=%s,StoreCard_ID=%s,StoreBatch_ID=%s,StorePosition_ID=%s,Quantity=%n,Unit=%s',
               [i, Row.OID,
                Row.GetFieldValueAsString ('Store_ID'),
                Row.GetFieldValueAsString ('StoreCard_ID'),
                Row.GetFieldValueAsString ('StoreBatch_ID'),
                Row.GetFieldValueAsString ('StorePosition_ID'),
                Row.GetFieldValueAsFloat('Quantity'),
                Row.GetFieldValueAsString('QUnit')]
              );
              break;
            finally
              dsRow.next;
            end;
          end;
        end;
        gLog.WriteEventFmt(logDebug, '..Row %d END', [i]);
      end;
    end;
    gLog.WriteEvent(logDebug, '.Rows - END');

    //kontrola, ze jsem vsechno zapsal
    dsRow.First;
    while(not dsRow.Eof)do begin
      if(abs(dsRow.FieldByName('Quantity').AsFloat) > 0.000001) AND
        ((ABRA and (SQLSelectStr(OS, 'select NonStockType from storecards where id = ' + QuotedStr(dsRow.FieldByName('StoreCard_ID').AsString)) = 'N'))
        or (not ABRA and (SQLSelectStr(OS, 'select IsStockType from storecards where id=' + QuotedStr(dsRow.FieldByName('StoreCard_ID').AsString)) = 'A')))
      then
        RaiseException(getString('logstoredocument_creating_error')+#13#13+
        'StoreCard_ID='+dsRow.FieldByName('StoreCard_ID').AsString+', Quantity='+dsRow.FieldByName('Quantity').AsString);
      dsRow.Next;
    end;

    //ulozim a provedu
    LogStoreDocument.Save;
    if(LogStoreDocument_ID = '')then
      gLog.WriteEventFmt(logDebug, 'Save new OID:%s', [LogStoreDocument.OID])
    else
      gLog.WriteEventFmt(logDebug, 'Save OID:%s', [LogStoreDocument.OID]);

    if AExecute then
    begin
      LogStoreDocument.Load(LogStoreDocument.OID, nil);
      LogStoreDocument.ExplicitTransaction := os.InTransaction;
      if not LogStoreDocument.MakeExecuted then
        RaiseException('Error:LogStoreDocument.MakeExecuted');
    end;

    //setCreatedAndCorrectedBy(LogStoreDocument, user_id, (LogStoreDocument_ID = ''));

    result:= LogStoreDocument.OID;
    gLog.WriteEvent(logDebug, 'Create_LogStoreDocument - END');
  finally
    //pokud jsem vytvarel pres Managera, tak uvolnim managera, jinak primo objekt
    //if(LogStoreDocument_ID = '')then
      DIM.free;
    //else
    //  LogStoreDocument.free;
  end;
end;

procedure FillLogStoreDocumentDataset(ASourceDataset, ALogStoreDocumentDataset: TMemTable; AJSON: TJSONSuperObject;
  AFilter, AStoreField, AStorePositionField: String; AStoreCardField: String = 'StoreCard_ID'; AStoreBatchField: String = 'StoreBatch_ID';
  ASerialNumbersField: String = 'sernums');
var
  mOldFilter: String;
  mOldFiltered: Boolean;
  mJsonSerNums: TJSONSuperObjectArray;
  i: Integer;
begin
  LogWriteSectionStart('FillLogStoreDocumentDataset');
  LogWriteEvent(Format('Filter: %s, fields (store, position): %s, %s', [AFilter, AStoreField, AStorePositionField]));
  ALogStoreDocumentDataset.EmptyTable;
  mOldFilter := ASourceDataset.Filter;
  mOldFiltered := ASourceDataset.Filtered;

  ASourceDataset.Filtered := False;
  ASourceDataset.Filter := AFilter;
  ASourceDataset.Filtered := True;

  ASourceDataset.First;
  while not ASourceDataset.Eof do
  begin
    if not CFxOID.IsEmpty(ASourceDataset.FieldByName(AStorePositionField).AsString) then
    begin
      mJsonSerNums := AJSON.A['rows'].O[ASourceDataset.FieldByName('jsonIndex').AsInteger].A[ASerialNumbersField];

      // Pokud ma radek seriova cisla, tak ho musim rozpadnout po nich
      if mJsonSerNums.Length > 0 then
      begin
        for i := 0 to mJsonSerNums.Length - 1 do
          AddTodtDocumentQuantity(ALogStoreDocumentDataset,
            ASourceDataset.FieldByName(AStoreField).AsString,
            ASourceDataset.FieldByName(AStoreCardField).AsString,
            mJsonSerNums.O[i].S['SerNum_ID'],
            ASourceDataset.FieldByName(AStorePositionField).AsString,
            1,
            ASourceDataset.FieldByName('UnitRate').AsFloat,
            ASourceDataset.FieldByName('ContentUnit').AsString
            );
      end
      else
        AddTodtDocumentQuantity(ALogStoreDocumentDataset,
          ASourceDataset.FieldByName(AStoreField).AsString,
          ASourceDataset.FieldByName(AStoreCardField).AsString,
          NxIIfStr(CFxOID.IsEmpty(ASourceDataset.FieldByName(AStoreBatchField).AsString), 'ZZZZZZZZZZ', ASourceDataset.FieldByName(AStoreBatchField).AsString),
          ASourceDataset.FieldByName(AStorePositionField).AsString,
          ASourceDataset.FieldByName('UnitQuantity').AsFloat,
          ASourceDataset.FieldByName('UnitRate').AsFloat,
          ASourceDataset.FieldByName('ContentUnit').AsString
        );
    end;
    ASourceDataset.Next;
  end;
  ASourceDataset.Filtered := False;
  ASourceDataset.Filter := mOldFilter;
  ASourceDataset.Filtered := mOldFiltered;
  LogWriteSectionEnd;
end;

begin
end.