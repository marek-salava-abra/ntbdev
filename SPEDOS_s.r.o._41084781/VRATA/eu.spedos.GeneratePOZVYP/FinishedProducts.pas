procedure ProcessingFinishedProducts (OS: TNxCustomObjectSpace;  var Success: Boolean; var LogInfoStr: String);
const
  Queues = ['VYP','VYPP']; // řady vyrobnich příkazů, které se zpracovávají
  closingEnable = false;
  mailingEnable = true;
  mailFrom = 'abra@';
  mailCopyTo = 'vyroba@....cz';


  procedure doClosing(mCloseable : TStringList);
  var
    mContext : TNxContext;
    mAbraOLEApp, mPLMJobOrderOLE : variant;
    mWarning, mError : string;
    i : integer;
  begin
    try
      NxScriptingLog.WriteEventFmt(logInfo, 'Zahajuji uzavírání výrobních příkazů (%d VYP)', [mCloseable.Count]);
      mContext := NxCreateContext(OS);
      try
        NxScriptingLog.WriteEvent(logDebug, 'GetAbraOLEApplication');
        mAbraOLEApp := mContext.GetAbraOLEApplication;
        for i := 0 to mCloseable.Count - 1 do begin
          mPLMJobOrderOLE := mAbraOLEApp.CreateObject('@PLMJobOrder');
          mWarning := '';
          mError := '';
          NxScriptingLog.WriteEventFmt(logDebug, 'mPLMJobOrderOLE.Finish: %s(%d)',[mCloseable.Strings[i], i]);
          if not mPLMJobOrderOLE.Finish(mCloseable.Strings[i], 0, mWarning, mError) then begin
            NxScriptingLog.WriteEventFmt(logError, 'Při ukončení VYP došlo k chybě/varování %s/%s.', [mWarning, mError]);
          end;
        end;
      finally
        mContext.Free;
      end;
    finally
    end;
  end;

  // test uzavirani VYP
  procedure testClosing;
  var
    mContext : TNxContext;
    mAbraOLEApp, mPLMJobOrderOLE : variant;
    mWarning, mError : string;
  begin
    try
      mWarning := '';
      mError := '';
      mAbraOLEApp := GetAbraOLEApplication;
      LogInfoStr := '1:';
      mPLMJobOrderOLE := mAbraOLEApp.CreateObject('@PLMJobOrder');
      LogInfoStr := LogInfoStr + '2:';
      mPLMJobOrderOLE.Finish('1HV6000101', 0, mWarning, mError); // (!) OLE error 80020003: Finish: Člen nebyl nalezen
      LogInfoStr := LogInfoStr + '3:';
    except
      LogInfoStr := LogInfoStr + ExceptionMessage;
      Success := false;
    end;
  end;


  const
    htmlTableFinishedRow = '<tr><td>%s</td><td>%s</td><td class="quantity">%s %s</td></tr>';
    htmlBodyHead = '<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">' +#13#10 +
                '<html><head><mata http-equiv="content-type" content="text/html; charset=windows-1250"> <meta charset="windows-1250"> '+
                '<style> td{padding-left: 3px; padding-right:1px;}  td.quantity{text-align:right; width: 80px; padding-right:3px; }  thead{font-weight:bold;} </style> </head> <body> ';
    //htmlTableHead = '<table border="1" cellpadding="0" cellspacing="0"><tr><td style="width:60px">Kód</td><td style="min-width:60px">Název</td><td class="quantity">Vyrobeno</td></tr>';
    htmlTableHead = '<table border="1" cellpadding="0" cellspacing="0"><tr><td style="width:60px">Kód</td><td style="min-width:60px">Název</td><td class="quantity">Plánováno</td><td>Výrobní příkaz</td><td class="quantity">Vyrobeno</td></tr>';
    htmlTableRow = '<tr><td>%s</td><td>%s</td><td class="quantity">%s %s</td><td>%s</td><td class="quantity">%s %s</td> </tr>';

  procedure doMailProcessingNew(AReceivedOrders : TStringList);
    function makeTableData(AReceivedOrderBO : TNxHeaderBusinessObject) : string;
    var
      r : string;
      mJobOrders : TStringList;
      i : integer;
      //mRowBO : TNxCustomBusinessObject;
      mValues : TStringList;
      s : string;
    begin
      r := '';
      mJobOrders := getAllManufacturedItemForOrder(AReceivedOrderBO);
      try
        for i := 0 to mJobOrders.Count - 1 do begin
          s := mJobOrders.strings[i];
          NxScriptingLog.WriteEvent(logDebug, 'doMailProcessingNew = ' + s );
          mValues := TStringList.Create;
          try
          NxTokenToStrings(s, ';', mValues);
            r := r + format(htmlTableRow,
                   [mValues.Values['StoreCard_Code'],
                    mValues.Values['StoreCard_Name'],
                    mValues.Values['PlanedQuantity'],
                    mValues.Values['QUnit'],
                    mValues.Values['JobOrder_DisplayName'],
                    mValues.Values['ManufacturedQuantity'],
                    mValues.Values['QUnit']
                   ] );
          finally
            mValues.Free;
          end;
        end;
      finally
        mJobOrders.Free;
      end;
      Result := r;
    end;

    function getAllManufacturedItemForOrder(AReceivedOrderBO : TNxHeaderBusinessObject) : TStringList;
      function getFinishedQuantity(AJO_ID : string) : double;
      const
        cSQLFinishedQuantity = 'SELECT SUM(FP.Quantity) FROM PLMFinishedProducts2 FP ' + #13#10 +
                               ' JOIN PLMJOOutputItems OI  ON FP.JOOutputItem_ID = OI.ID ' + #13#10 +
                               ' JOIN PLMJONodes N ON N.ID=OI.Owner_ID ' + #13#10 +
                               ' WHERE N.Parent_ID = ''%s''';
      var
        L : TStringList;
      begin
        Result := 0.0;
        L := TStringList.Create;
        try
          AReceivedOrderBO.ObjectSpace.SQLSelect(format(cSQLFinishedQuantity, [AJO_ID]), L);
          if L.Count <> 1 then exit;
          if not NxIsNumeric(L.Strings[0]) then exit;
          Result := NxIBStrToFloat(NxSearchReplace(L.Strings[0], ',', '.', [srAll]));
        finally
          L.Free;
        end;
      end;

    const
      constReturnStr = 'StoreCard_ID=%s;Store_ID=%s;JobOrder_ID=%s;JobOrder_DisplayName=%s;PlanedQuantity=%s;ManufacturedQuantity=%s;QUnit=%s;StoreCard_Code=%s;StoreCard_Name=%s';
      cSQL = 'select RQ.JobOrder_ID from Relations A  JOIN PLMProduceRequests RQ ON RQ.ID=A.LeftSide_ID WHERE A.RightSide_ID=''%s'' AND a.rel_def=1621';
      cSQL2 = 'select RQ.ID from Relations A JOIN PLMProduceRequests RQ ON RQ.ID=A.LeftSide_ID WHERE A.RightSide_ID=''%s'' AND a.rel_def=1621 AND RQ.JobOrder_ID is null';
    var
      L, R : TStringList;
      i : integer;
      mProductionDocBO : TNxCustomBusinessObject;
      s : string;
    begin
      R := TStringList.Create;
      L := TstringList.Create;
      try
        // projdu vsechny pozadavky, ktere maji vyrobni prikazy
        AReceivedOrderBO.ObjectSpace.SQLSelect(format(cSQL, [AReceivedOrderBO.OID]), L);
        for i := 0 to L.Count - 1 do begin
          mProductionDocBO := OS.CreateObject(Class_PLMJobOrder);
          try
            if mProductionDocBO.Test(L.Strings[i]) then begin
              mProductionDocBO.Load(L.Strings[i], nil);
              s := format(constReturnStr, [
                   mProductionDocBO.GetFieldValueAsString('StoreCard_ID'),
                   mProductionDocBO.GetFieldValueAsString('Store_ID'),
                   mProductionDocBO.OID,
                   mProductionDocBO.DisplayName,
                   FormatFloat('0.000', mProductionDocBO.GetFieldValueAsFloat('Quantity')),
                   FormatFloat('0.000', getFinishedQuantity(mProductionDocBO.OID)),
                   mProductionDocBO.GetFieldValueAsString('qunit'),
                   mProductionDocBO.GetFieldValueAsString('StoreCard_ID.Code'),
                   mProductionDocBO.GetFieldValueAsString('StoreCard_ID.Name')
              ]);
              R.Add(s);
            end;
          finally
            mProductionDocBO.Free;
          end;
        end;
        L.Clear;

        // projdu vsechny pozadavky, bez vyrobnich prikazu
        AReceivedOrderBO.ObjectSpace.SQLSelect(format(cSQL2, [AReceivedOrderBO.OID]), L);
        for i := 0 to L.Count - 1 do begin
          mProductionDocBO := OS.CreateObject(Class_PLMProduceRequest);
          try
            if mProductionDocBO.Test(L.Strings[i]) then begin
              mProductionDocBO.Load(L.Strings[i], nil);
              s := format(constReturnStr, [
                   mProductionDocBO.GetFieldValueAsString('StoreCard_ID'),
                   mProductionDocBO.GetFieldValueAsString('Store_ID'),
                   ' ',
                   mProductionDocBO.DisplayName,
                   FormatFloat('0.000', mProductionDocBO.GetFieldValueAsFloat('Quantity')),
                   FormatFloat('0.000', 0),
                   mProductionDocBO.GetFieldValueAsString('qunit'),
                   mProductionDocBO.GetFieldValueAsString('StoreCard_ID.Code'),
                   mProductionDocBO.GetFieldValueAsString('StoreCard_ID.Name')
              ]);
              R.Add(s);
            end;
          finally
            mProductionDocBO.Free;
          end;
        end;
        Result := R;
      finally
        L.Free;
      end;
    end;

  var
    i, j : integer;
    mReceivedOrderBO : TNxHeaderBusinessObject;
    s, mailTo, mailBody, mailSubject, mMailTableData : string;
  begin

  end;


  procedure doMailProcessingOLD(AJobOrders : TStringList);
  var
    i : integer;
    mValues, mNextValues : TStringList;
    s : string;
    mReceivedOrderBO : TNxCustomBusinessObject;
    mailSubject, mailBody, mailTo : string;
  begin

  end;

  procedure doCommit(AHead : TNxCustomBusinessObject; AObjects : TObjectList);
  var
    i : integer;
  begin
    OS.StartTransaction(taReadCommited);
    try
      NxScriptingLog.WriteEvent(logDebug, 'Zahajuji ukládání dokladu');
      NxScriptingLog.WriteEvent(logDebug, '  - Ukladádám příjem hotových výrobků');
      AHead.Save;
      for i := 0 to AObjects.Count - 1 do begin
        NxScriptingLog.WriteEvent(logDebug, '  - Ukladádám dokončené výrobky');
        TNxCustomBusinessObject(AObjects.Items[i]).Save;
      end;
      OS.Commit;
      NxScriptingLog.WriteEventFmt(logDebug, 'eu.abra.aws.production/autoserver.ProcessingFinishedProducts() - Transaction Commited (%s)',
                                   [AHead.DisplayName]);
      LogInfoStr := LogInfoStr + Format('Uložen doklad %s', [AHead.DisplayName]) + #13#10;
    except
      OS.RollBack;
      NxScriptingLog.WriteEventFmt(logError, 'eu.abra.aws.production/autoserver.ProcessingFinishedProducts() - Transaction rollbacked %s',
                                   [ExceptionMessage]);
      RaiseException(ExceptionMessage);
    end;
  end;

var
  L, mCloseable, {mFinishedProducts,} mReceivedOrders : TStringList;
  mCommitList : TObjectList;
  i, j : integer;
  mCode, mReceivedOrder_ID : string;
  mHead : TNxHeaderBusinessObject;
  mFPRow, mRow, mParams, mBatch : TNxCustomBusinessObject;
  mRows, mDocRowBatches : TNxCustomBusinessMonikerCollection;
  T : TDateTime;
begin
{
  // test uzavirani VYP
  testClosing();
  exit;
}
  try
    //NxScriptingLog.EnterSection('eu.abra.aws.production/autoserver.ProcessingFinishedProducts', logNotice);
    T := now;
    try
      Success := True;
      LogInfoStr := '';
      //mFinishedProducts := TStringList.Create;
      mReceivedOrders := TStringList.Create;
      try
        mCloseable := TStringList.Create;
        try
          for j := 0 to Length(Queues) - 1 do begin
            L := getFinishedProducts(OS, Queues[j]);
            try
              //NxScriptingLog.WriteEventFmt(logDebug, 'Kontroluji řadu %s, počet nepřijatých výrobků %d', [Queues[j], L.Count]);
              if L.Count = 0 then continue;
              mCommitList := TObjectList.Create(False);
              try
                mHead := TNxHeaderBusinessObject(OS.CreateObject(Class_ProductReception));
                try


                    for i := 0 to L.count -1 do begin
                    mHead.New;
                    mHead.Prefill;
                    mParams := getJobOrderParams(OS, Queues[j]);
                    try
                     mHead.SetFieldValueAsString('DocQueue_ID', mParams.GetFieldValueAsString('X_DocQueue28_ID'));
                    finally
                     mParams.Free;
                    end;
                    mRows := mHead.GetLoadedCollectionMonikerForFieldCode(mHead.GetFieldCode('Rows'));
                    mFPRow := OS.CreateObject(Class_PLMFinishedProductRow);
                    mFPRow.Load(L.Strings[i], nil);
                    //NxScriptingLog.WriteEvent(logInfo, 'kód skladu '+mFPRow.GetFieldValueAsString('JOOutputItem_ID.Owner_ID.Parent_ID.Store_ID.code')+ ' kód řady '+mParams.GetFieldValueAsString('X_DocQueue28_ID')+ ' '+mParams.GetFieldValueAsString('X_DocQueue28_ID.code'));
                    //NxScriptingLog.WriteEventFmt(logDebug, 'Zpracovávám dokončený výrobek %s', [mFPRow.DisplayName]);
                    mHead.SetFieldValueAsString('Firm_ID', mFPRow.GetFieldValueAsString('JOOutputItem_ID.Owner_ID.Parent_ID.Firm_ID'));
                    mRow := mRows.AddNewObject;
                    mRow.SetFieldValueAsInteger('RowType', 3);
                    mRow.SetFieldValueAsString('Store_ID', mFPRow.GetFieldValueAsString('JOOutputItem_ID.Owner_ID.Parent_ID.Store_ID'));
                    mRow.SetFieldValueAsString('Division_ID', mFPRow.GetFieldValueAsString('JOOutputItem_ID.Owner_ID.Parent_ID.Division_ID'));
                    mRow.SetFieldValueAsString('BusOrder_ID', mFPRow.GetFieldValueAsString('JOOutputItem_ID.Owner_ID.Parent_ID.BusOrder_ID'));
                    mRow.SetFieldValueAsString('BusTransaction_ID', mFPRow.GetFieldValueAsString('JOOutputItem_ID.Owner_ID.Parent_ID.BusTransaction_ID'));
    //                NxScriptingLog.WriteEventFmt(logDebug, 'Division_ID=%s, Store_ID=%s',
    //                        [mFP.GetFieldValueAsString('ManufacturedItem_ID.Parent_ID.Division_ID'), mFP.GetFieldValueAsString('ManufacturedItem_ID.Parent_ID.Store_ID')]);
                    mRow.SetFieldValueAsString('StoreCard_ID', mFPRow.GetFieldValueAsString('JOOutputItem_ID.Owner_ID.StoreCard_ID'));
                    mRow.SetFieldValueAsString('ProductionTask_ID', mFPRow.GetFieldValueAsString('JOOutputItem_ID.Owner_ID.Parent_ID.ProductionTask_ID'));
                    mRow.SetFieldValueAsFloat('Quantity', mFPRow.GetFieldValueAsFloat('Quantity'));
                    mRow.SetFieldValueAsString('QUnit', mFPRow.GetFieldValueAsString('QUnit'));
                    if mRow.GetFieldValueAsInteger('StoreCard_ID.Category')=1 then begin
                       mDocRowBatches:=mrow.GetLoadedCollectionMonikerForFieldCode(mrow.GetFieldCode('DocRowBatches'));
                       mBatch:=mDocRowBatches.AddNewObject;
                       mBatch.SetFieldValueAsBoolean('NewBatch',False);
                       mbatch.SetFieldValueAsString('StoreBatch_ID',mFPRow.GetFieldValueAsString('JobOrdersSN_ID.StoreBatch_ID'));
                       mHead.SetFieldValueAsString('Description',mBatch.GetFieldValueAsString('StoreBatch_ID.Name'));
                       mbatch.SetFieldValueAsFloat('Quantity',mFPRow.GetFieldValueAsFloat('Quantity'));
                    end;
                    if NxIsBlank(mHead.GetFieldValueAsString('Description')) then mHead.SetFieldValueAsString('Description',mFPRow.GetFieldValueAsString('JOOutputItem_ID.Owner_ID.Parent_ID.U_vyrobni_cislo'));
                    mFPRow.SetFieldValueAsString('ReceivedBy_ID', mHead.GetFieldValueAsString('CreatedBy_ID'));
                    mFPRow.SetFieldValueAsString('StoreDoc2_ID', mRow.OID);
                    mFPRow.SetFieldValueAsDateTime('ReceivedAt$DATE', mHead.GetFieldValueAsDateTime('DocDate$DATE'));

                    //mFP.SetFieldValueAsFloat('UnitQuantity', mRow.GetFieldValueAsFloat('Quantity'));
                    mCommitList.Add(mFPRow);

                    if isCloseable(mFPRow) then
                      mCloseable.Add( mFPRow.GetFieldValueAsString('JOOutputItem_ID.Owner_ID.Parent_ID'));
                    if mailingEnable then begin

                      mReceivedOrder_ID := getRelationLeftSide(OS, getProduceRequest(OS, mFPRow.GetFieldValueAsString('JOOutputItem_ID.Owner_ID.Parent_ID.ProductionTask_ID')), 1620);
                      //NxScriptingLog.WriteEventFmt(logDebug, 'Ukladam data pro mailovani, ReceivedOrder_ID=%s', [mReceivedOrder_ID]);
                      if not NxIsEmptyOID(mReceivedOrder_ID) and (mReceivedOrders.IndexOf(mReceivedOrder_ID) < 0 ) then begin
                        //NxScriptingLog.WriteEventFmt(logDebug, 'Ukladam data pro mailovani, ReceivedOrder_ID=%s, ulozeno', [mReceivedOrder_ID]);
                        mReceivedOrders.add(mReceivedOrder_ID);
                      end;
                      {
                      mFinishedProducts.add(format('ReceivedOrder_ID=%s;JobOrder_ID=%s;FinishedProduct_ID=%s;JobOrder_DisplayName=%s;StoreCard_Code=%s;StoreCard_Name=%s;Quantity=%f;QUnit=%s',
                                                           [
                                                             getRelationLeftSide(OS, getProduceRequest(OS, mFP.GetFieldValueAsString('ManufacturedItem_ID.Parent_ID.ProductionTask_ID')), 1620),
                                                             mFP.GetFieldValueAsString('ManufacturedItem_ID.Parent_ID'),
                                                             L.Strings[i],
                                                             mFP.GetFieldValueAsString('ManufacturedItem_ID.Parent_ID.DisplayName'),
                                                             mFP.GetFieldValueAsString('ManufacturedItem_ID.StoreCard_ID.Code'),
                                                             mFP.GetFieldValueAsString('ManufacturedItem_ID.StoreCard_ID.Name'),
                                                             mFP.GetFieldValueAsFloat('Quantity'),
                                                             mFP.GetFieldValueAsString('QUnit')
                                                           ]));
                                                           }
                    end;
                    doCommit(mHead, mCommitList);
                    mHead.Free;
                  end;
                  // ulozeni vseho v jedne transakci

                finally

                end;
              finally
                for i := mCommitList.count -1 downto 0 do begin
                  TNxCustomBusinessObject(mCommitList.Items[i]).Free;
                end;
                mCommitList.Free;
              end;
            finally
              L.Free;
            end;
          end;
          if closingEnable then begin
            doClosing(mCloseable);
          end;
        finally
          mCloseable.Free;
        end;
        if mailingEnable then begin
          //mFinishedProducts.sort;
          //doMailProcessing(mFinishedProducts);
          //NxScriptingLog.WriteEvent(logDebug, 'bude se mailovat...');
          doMailProcessingNew(mReceivedOrders);
        end;
      finally
        //mFinishedProducts.Free;
        mReceivedOrders.Free;
      end;
    except
      Success := False;
      //NxScriptingLog.WriteEventFmt(logError, 'eu.abra.aws.production/autoserver.ProcessingFinishedProducts() - exception: %s', [ExceptionMessage]);
      LogInfoStr := ExceptionMessage;
    end;
  finally
    //NxScriptingLog.LeaveSection(Format('eu.abra.aws.production/autoserver.ProcessingFinishedProducts (%d ms)', [MilliSecondsBetween(now, T)]), logNotice);
  end;
end;


function getJobOrderParams(AOS : TNxCustomObjectSpace; AJobOrderDocQueue_Code : string) : TNxCustomBusinessObject;
const
  cSQL = 'SELECT A.ID FROM PLMJOSetParsQueues A JOIN DocQueues Q ON Q.ID=A.DocQueue_ID WHERE Q.DocumentType=''JO'' AND Q.Hidden=''N'' AND Q.Code=''%s''';
var
  L : TStringList;
begin
  Result := nil;
  L := TStringList.Create;
  try
    AOS.SQLSelect(Format(cSQL, [AJobOrderDocQueue_Code]), L);
    //NxScriptingLog.WriteEvent(logDebug, Format(cSQL, [AJobOrderDocQueue_Code]));
    if L.Count <> 1 then
      exit;
    //NxScriptingLog.WriteEvent(logDebug, 'getJobOrderParams, param_id=' + L.Text);
    Result := AOS.CreateObject(Class_PLMJOSetParsQueue);
    Result.Load(L.Strings[0], nil);
  finally
    L.Free;
  end;
end;



function getFinishedProducts(AOS : TNxCustomObjectSpace; ADocQueueCode : string;) : TStringList;
const
  cSQL = 'SELECT A.ID FROM PLMFinishedProducts2 A ' +
         ' JOIN PLMJOOutputItems OI ON A.JOOutputItem_ID = OI.ID ' +
         ' JOIN PLMJONodes N ON N.ID=OI.Owner_ID ' +
         ' JOIN PLMJobOrders JO ON JO.ID=N.Parent_ID ' +
         ' JOIN DocQueues Q ON Q.ID=JO.DocQueue_ID ' +
         ' WHERE A.StoreDoc2_ID is null AND Q.Code=''%s'' ' +
         ' ORDER BY Q.Code ';
begin
  Result := TStringList.Create;
  AOS.SQLSelect(Format(cSQL, [ADocQueueCode]), Result);
end;


function getDocQueue_ID(AOS : TNxCustomObjectSpace; ACode : string; AType : string) : string;
var
  L : TStringList;
const
  cSQL = 'SELECT A.ID FROM DocQueues A WHERE A.Code==''s'' AND A.DocumentType=''%s'' AND A.Hidden=''N'' ORDER BY A.ID';
begin
  Result := '';
  L := TstringList.Create;
  try
    AOS.SQLSelect(Format(cSQL, [ACode, AType]), L);
    if L.count > 0 then
      Result := L.strings[0];
  finally
    L.Free;
  end;
end;


function isCloseable(AFinishedProductBO : TNxCustomBusinessObject) : boolean;
  function cooperationCount : integer;
  const
    cSQL = 'SELECT count(*) from PLMCooperations A ' +
           ' JOIN PLMCoopOutputItems COI ON COI.Parent_ID=A.ID ' +
           ' JOIN PLMJOOutputItems OI ON COI.JOOutputItem_ID=OI.ID ' +
           ' WHERE OI.Owner_ID=''%s''';
  var
    R : TstringList;
  begin
    Result := 0;
    R := TStringList.Create;
    try
      AFinishedProductBO.ObjectSpace.SQLSelect(Format(cSQL, [AFinishedProductBO.GetFieldValueAsString('JOOutputItem_ID.Owner_ID')]), R);
      if R.Count > 0 then
         if NxIsNumeric(R.Strings[0]) then
           Result := StrToInt(R.Strings[0]);
    finally
      R.Free;
    end;
  end;
begin
  Result := False;
  result := (cooperationCount = 0);
end;



function getRelationLeftSide(AOS : TNxCustomObjectSpace; ARightSide_ID : string; ARelDef : integer) : string;
var
  L : TStringList;
const
  SQL = 'select A.LeftSide_ID from Relations A WHERE A.RightSide_ID=''%s'' AND a.rel_def=%d';
begin
  L := TStringList.Create;
  try
    Result := '';
    AOS.SQLSelect(Format(SQL, [ARightSide_ID, ARelDef]), L);
    if L.Count = 1 then begin
      Result := L.Strings[0];
    end;
  finally
    L.Free;
  end;
end;

function getProduceRequest(AOS : TNxCustomObjectSpace; AProductionTask_ID : string) : string;
var
  L : TStringList;
const
  SQL = 'SELECT A.ID FROM PLMProduceRequests A WHERE A.ProductionTask_ID = ''%s''';
begin
  L := TStringList.Create;
  try
    Result := '';
    AOS.SQLSelect(Format(SQL, [AProductionTask_ID]), L);
    if L.Count = 1 then begin
      Result := L.Strings[0];
    end;
  finally
    L.Free;
  end;
end;


begin
end.