

{
  Definuje webovou službu:
    string 	QReceiptCardIns(TStringDynArray Head, TStringDynArray RowDesc, TStringDynArray Rows)
}
function ReceiptCardInsert(Self: TNxWebServicesHelper;Head: TStringDynArray;RowDesc: TStringDynArray;Rows: TStringDynArray):String;
var
  mHead, mRowDesc, mRowItem : TStringList;
  mRowsTxt : string;
  mRows : TList;
  i, j : integer;
  mErrMsg : string;
begin



  NxScriptingLog.EnterSection('ReceiptCardInsert', logNotice);
  try
    try
      mHead := TStringList.Create;
      try
        for i := 0 to Length(Head) - 1 do begin
          NxScriptingLog.WriteEvent(logDebug, 'Head.row' + Head[i] );
          mHead.Add(Head[i]);
        end;
        NxScriptingLog.WriteEventAndData_1(logDebug, 'Head', mHead.Text);
        if not validateHead(Self.ObjectSpace, mHead, mErrMsg) then begin
          Result := 'ERR|' + mErrMsg;
          exit;
        end;
        mRowDesc := TStringList.Create;
        try
          for i := 0 to Length(RowDesc) - 1 do
            mRowDesc.add(RowDesc[i]);
          NxScriptingLog.WriteEventAndData_1(logDebug, 'RowDesc', mRowDesc.Text);
          if not validateRowDesc(Self.ObjectSpace, mRowDesc, mErrMsg) then begin
            Result := 'ERR|' + mErrMsg;
            exit;
          end;

          mRows := TObjectList.Create;
          try
            mRowsTxt := '';
            for i := 0 to Length(Rows) - 1 do begin
              if NxIsBlank(Rows[i]) then continue;
              mRowItem := TStringList.Create;
              NxTrapStrToStrings(Rows[i], '|', mRowItem);
              if mRowItem.Count > mRowDesc.Count then
                RaiseException(Format('Řádek ''%s'' má více položek, než určuje popisvač řádku.', [Rows[i]]));
              for j := 0 to mRowItem.Count - 1 do
                mRowItem.Strings[j] := mRowDesc.Strings[j] + '=' + mRowItem.Strings[j];
              for j := 0 to mRowItem.Count - 1 do
                mRowsTxt := mRowsTxt + mRowItem.Strings[j] + ';';
              mRowsTxt := mRowsTxt +#13#10;
              mRows.Add(mRowItem);
            end;
            NxScriptingLog.WriteEventAndData_1(logDebug, 'Rows count:' + IntToStr(Length(Rows)), mRowsTxt);

            Result := importRC(Self.ObjectSpace, mHead, mRows);

          finally
            mRows.Free;
          end;
        finally
          mRowDesc.Free;
        end;
      finally
        mHead.Free;
      end;
    except
      Result := 'ERR|' + ExceptionMessage;
      NxScriptingLog.WriteEvent(logError, ExceptionMessage);
    end;
  finally
    NxScriptingLog.LeaveSection('ReceiptCardInsert', logNotice);
  end;
end;


function validateRowDesc(AOS : TNxCustomObjectSpace; ARowDesc : TStringList; var AErrMsg : string) : boolean;
const
  resErrHeadFieldNotFound = 'Popisovač řádku neobsahuje pole ''%s''';
var
  mS : string;
begin
  if ARowDesc.IndexOf('IssuedOrder_ID') < 0 then begin
    AErrMsg := Format(resErrHeadFieldNotFound, ['IssuedOrder_ID']);
    Result := false;
    exit;
  end;
  if ARowDesc.IndexOf('IssuedOrderRow_ID') < 0 then begin
    AErrMsg := Format(resErrHeadFieldNotFound, ['IssuedOrderRow_ID']);
    Result := false;
    exit;
  end;
  if ARowDesc.IndexOf('QUnit') < 0 then begin
    AErrMsg := Format(resErrHeadFieldNotFound, ['QUnit']);
    Result := false;
    exit;
  end;
  if ARowDesc.IndexOf('UnitRate') < 0 then begin
    AErrMsg := Format(resErrHeadFieldNotFound, ['UnitRate']);
    Result := false;
    exit;
  end;
  if ARowDesc.IndexOf('UnitQuantity') < 0 then begin
    AErrMsg := Format(resErrHeadFieldNotFound, ['UnitQuantity']);
    Result := false;
    exit;
  end;
  Result := true;
end;


function validateHead(AOS : TNxCustomObjectSpace; AHead : TStringList; var AErrMsg : string) : boolean;
const
  resErrHeadFieldNotFound = 'Hlavička neobsahuje pole ''%s''';
  resErrHeadFieldNodValid = 'Pole %s neobsahuje validní hodnotu (%s)';
var
  mS : string;
  mBO : TNxCustomBusinessObject;
begin
  mS := AHead.Values('ReceiptCardDocQueue_ID');
  if NxIsBlank(mS) then begin
    AErrMsg := Format(resErrHeadFieldNotFound, ['ReceiptCardDocQueue_ID']);
    Result := false;
    exit;
  end;
  mBO := AOS.CreateObject(Class_DocQueue);
  try
    if not mBO.Test(mS) then begin
      AErrMsg := Format(resErrHeadFieldNodValid, ['ReceiptCardDocQueue_ID', mS]);
      result := false;
      exit;
    end;
  finally
    mBO.Free;
  end;
  Result := True;
end;


function importRC(AOS : TNxCustomObjectSpace; AHead : TStringList; ARows : TList) : string;
  function getImportDocuments(ARows :TList ) : TstringList;
  var
    i : integer;
    s : string;
  begin
    Result := TStringList.Create;
    Result.sorted := true;
    for i := 0 to ARows.Count - 1 do begin
      s := TStringList(ARows.Items(i)).Values('IssuedOrder_ID');
      if not NxIsBlank(s) then
        if Result.IndexOf(s)< 0 then
           Result.Add(s);
    end;

  end;

  function iFloat(AValue : string) : double;
  var
    mS : string;
  begin
    mS := '0' + Trim(AValue) ;
    mS := NxSearchReplace(mS, ',', '.', [srAll]);
   Result := NxIBStrToFloat(mS);
  end;

var
  mOID : TNxOID;
  mIM : TNxDocumentImportManager;
  mImportedRows, mS : string;
  i, j : integer;
  x : TNxParameters;
  mHead : TNxHeaderBusinessObject;
  mSList : TStringList;
begin
  result := '';
  NxScriptingLog.EnterSection('importRC', logInfo);
  try
    mIM := NxCreateDocumentImportManager(AOS, Class_IssuedOrder, Class_ReceiptCard);
    try
      mSList := getImportDocuments(ARows);
      try
        for i := 0 to mSList.Count - 1 do begin
          mIM.AddInputDocument(mSList.Strings[i]);
        end;
      finally
        mSList.Free;
      end;

      x := TNxParameters.Create;
      try
        x.GetOrCreateParam(dtString, 'DocQueue_ID', pkInput).AsString := AHead.Values('ReceiptCardDocQueue_ID');
        x.GetOrCreateParam(dtInteger, 'StoreQuantityKind', pkInput).AsInteger := 0;
        mImportedRows := '';
        for i := 0 to ARows.Count - 1 do
          mImportedRows := NxIIfStr(NxIsBlank(mImportedRows), '', mImportedRows+#13#10) + TStringList(ARows.Items[i]).Values('IssuedOrderRow_ID');
        NxScriptingLog.WriteEvent(logDebug, 'SelectedRows=' + mImportedRows);
        x.GetOrCreateParam(dtString, 'SelectedRows', pkInput).AsString := mImportedRows;
        mIM.LoadParams(x);
//        mIM.SaveParams(x);
//        x.SaveToFile('c:\im_params.dat');
      finally
        x.Free;
      end;
      mIM.SelectedHeader := mIM.InputDocuments[0];
      mIM.Execute;
      mHead := TNxHeaderBusinessObject(mIM.OutputDocument);
      
//      mHead.SetFieldValueAsString('Firm_ID', mIM.InputDocuments[0].GetFieldValueAsString('Firm_ID'));
      for i := 0 to mHead.Rows.Count - 1 do begin
        mOID := mHead.Rows.BusinessObject[i].GetFieldValueAsString('ProvideRow_ID');
        for j := 0 to ARows.Count - 1 do
          if mOID = TStringList(ARows.Items(j)).Values('IssuedOrderRow_ID') then begin
            mHead.Rows.BusinessObject[i].SetFieldValueAsFloat('UnitQuantity', iFloat(TStringList(ARows.Items(j)).Values('UnitQuantity')));
            mHead.Rows.BusinessObject[i].SetFieldValueAsString('QUnit', TStringList(ARows.Items(j)).Values('Qunit'));
            mHead.Rows.BusinessObject[i].SetFieldValueAsFloat('UnitRate', iFloat(TStringList(ARows.Items(j)).Values('UnitRate')));
            mHead.Rows.BusinessObject[i].SetFieldValueAsFloat('UnitPrice', iFloat(TStringList(ARows.Items(j)).Values('UnitPrice')));
            mHead.Rows.BusinessObject[i].SetFieldValueAsFloat('TotalPrice', iFloat(TStringList(ARows.Items(j)).Values('TotalPrice')));
            if (not NxIsEmptyOID(TStringList(ARows.Items(j)).Values('Division_ID'))) then
              mHead.Rows.BusinessObject[i].SetFieldValueAsString('Division_ID', TStringList(ARows.Items(j)).Values('Division_ID'));
            if (not NxIsEmptyOID(TStringList(ARows.Items(j)).Values('BusOrder_ID'))) then
              mHead.Rows.BusinessObject[i].SetFieldValueAsString('BusOrder_ID', TStringList(ARows.Items(j)).Values('BusOrder_ID'));
            if (not NxIsEmptyOID(TStringList(ARows.Items(j)).Values('BusTransaction_ID'))) then
              mHead.Rows.BusinessObject[i].SetFieldValueAsString('BusTransaction_ID', TStringList(ARows.Items(j)).Values('BusTransaction_ID'));
            if (not NxIsEmptyOID(TStringList(ARows.Items(j)).Values('BusProject_ID'))) then
              mHead.Rows.BusinessObject[i].SetFieldValueAsString('BusProject_ID', TStringList(ARows.Items(j)).Values('BusProject_ID'));
            if (not NxIsEmptyOID(TStringList(ARows.Items(j)).Values('Store_ID'))) then
              mHead.Rows.BusinessObject[i].SetFieldValueAsString('Store_ID', TStringList(ARows.Items(j)).Values('Store_ID'));
          end;
      end;
      mHead.Save;
      Result := mHead.DisplayName;
    finally
      mIM.Free;
    end;
  finally
    NxScriptingLog.LeaveSection('importRC', logInfo);
  end;
end;



begin
end.