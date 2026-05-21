uses '.const';

Function GetDate(var ASite : TSiteform; var aDate:Extended):Boolean;
var
    mLabel: TLabel;
    mAllowed:TStringList;
    mButOk, mButCancel : TButton;
    mResult, mCount : integer;
    mForm : TForm;
    mDateEd:TDateEdit;
 begin
 if ASite <> nil then begin
    Result:=False;
    mCount:=0;
    mForm:= TForm.Create(ASite);
    mForm.Width:= 350;
    mForm.Position:=poScreenCenter;
    mForm.Caption := 'Date of Inventory:';
    mForm.OnCloseQuery:= @OnFormCloseAction;

    mLabel := TLabel.Create(mForm);
    mLabel.Parent := mForm;
    mLabel.Caption := 'Date:';
    mLabel.Top := (mCount*25)+12;
    mLabel.Left := 17;
    mLabel.Height := 13;
    mLabel.Width := 100;
    mLabel.Font.Size := 10;

    mDateEd:= TDateEdit.Create(mForm);
    mDateEd.Parent:= mForm;
    mDateEd.Left:= 140;
    mDateEd.Top:= (mCount*25)+12;
    mDateEd.Width:= 80;
    mDateEd.Date:=aDate;

    mCount:= mCount+1;

    mButOk:= TButton.Create(mForm);
    mButOk.Parent := mForm;
    mButOk.Default:= true;
    mButOk.Caption := 'OK';
    mButOk.Top := (mCount*25)+20;
    mButOk.Left := 152;
    mButOk.Height := 24;
    mButOk.Width := 62;
    mButOk.ModalResult := 1;

    mButCancel := TButton.Create(mForm);
    mButCancel.Parent := mForm;
    mButCancel.Caption := 'Cancel';
    mButCancel.Top := (mCount*25)+20;
    mButCancel.Left := 220;
    mButCancel.Height := 24;
    mButCancel.Width := 62;
    mButCancel.ModalResult := 2;
    mForm.Height:= (mCount*25)+95;

    mResult := mForm.ShowModal(ASite);
    if mResult = 1 then begin
         aDate:=mDateEd.Date;
         Result:=True;
     end;
    mForm.free;
  end;
end;

procedure OnFormCloseAction(Sender: TObject; var Action: TCloseAction);
begin
  if Action = caHide then TForm(Sender).ModalResult := mrCancel;
end;

procedure AddStringsToSelDat(AOS : TNxCustomObjectSpace; AStation_ID: String; AValues: TStringList);
// Přidá do SelDat hodnoty ze StringListu pod AStation
var
  mStation_ID : String;
  i : Integer;
begin
  mStation_ID := aos.SQLSelectFirstAsString('Select ID from SelDef where ID = '+QuotedStr(AStation_ID), '');
  if NxIsEmptyOID(mStation_ID) then begin
    mStation_ID := AStation_ID;
    AOS.SQLExecute('Insert into SelDef (ID, Station) values ('+QuotedStr(mStation_ID) +', ''GeneratedByScript'')');
  end;
  For i:=0 to AValues.Count-1 do begin
    AOS.SQLExecute('Insert into SelDat (Sel_ID, Obj_ID) values ('+QuotedStr(mStation_ID) +', '+QuotedStr(AValues.Strings[i]) +')');
  end;
end;

procedure ClearSelDat(AOS : TNxCustomObjectSpace; AStation_ID: String);
// Smaže ze SelDat hodnoty pod AStation
begin
  AOS.SQLExecute('Delete from SelDef where ID = '+QuotedStr(AStation_ID));
end;

procedure StringsToSelDat(AOS : TNxCustomObjectSpace; AStation_ID: String; AValues: TStringList);
begin
  ClearSelDat(AOS, AStation_ID);
  AddStringsToSelDat(AOS, AStation_ID, AValues);
end;

function PosEx(const SubStr, S: string; Offset: Integer): Integer;
var
  i: Integer;
begin
  Result := 0;
  if (SubStr = '') or (Offset < 1) or (Offset > Length(S)) then
    Exit;

  for i := Offset to Length(S) do
  begin
    if S[i] = SubStr[1] then
      if Copy(S, i, Length(SubStr)) = SubStr then
      begin
        Result := i;
        Exit;
      end;
  end;
end;

function ExtractKey(const Line: string): string;
var
  p1, p2: Integer;
begin
  // první ;
  p1 := Pos(';', Line);
  if p1 = 0 then
  begin
    Result := Line;
    Exit;
  end;

  // druhý ;
  p2 := PosEx(';', Line, p1 + 1);
  if p2 = 0 then
  begin
    Result := Line;
    Exit;
  end;

  // klíč = StoreCard_ID;StoreBatch_ID
  Result := Copy(Line, 1, p2 - 1);
end;

function ExtractQty(const Line: string): Extended;
var
  p1, p2, p3: Integer;
  sQty: string;
begin
  Result := 0;

  p1 := Pos(';', Line);
  if p1 = 0 then Exit;

  p2 := PosEx(';', Line, p1 + 1);
  if p2 = 0 then Exit;

  // třetí ; (oddělovač mezi Quantity a StoreBatchName)
  p3 := PosEx(';', Line, p2 + 1);

  if p3 = 0 then
    sQty := Copy(Line, p2 + 1, 50)            // fallback: kdyby chyběl 4. sloupec
  else
    sQty := Copy(Line, p2 + 1, p3 - p2 - 1);      // přesně Quantity

  Result := NxIBStrToFloat(Trim(sQty));
end;

procedure FindStoreNotInExcelOrDiffQty(const StoreList, ExcelList, ResultList: TStringList);
var
  ExcelKeys, ExcelQty, ExcelName: TStringList;
  StoreKeys, StoreQty, StoreName: TStringList;
  i, idx: Integer;
  Key: string;
  QtyS, QtyE, Diff: Extended;
  Name: string;
const
  EPS = 0.000001;
begin
  ResultList.Clear;

  ExcelKeys := TStringList.Create; ExcelQty := TStringList.Create; ExcelName := TStringList.Create;
  StoreKeys := TStringList.Create; StoreQty := TStringList.Create; StoreName := TStringList.Create;
  try
    ExcelKeys.Sorted := True; ExcelKeys.Duplicates := dupIgnore;
    StoreKeys.Sorted := True; StoreKeys.Duplicates := dupIgnore;

    // agregace Excel
    for i := 0 to ExcelList.Count - 1 do
      AddLineToMap(ExcelKeys, ExcelQty, ExcelName, ExcelList[i]);

    // agregace Store
    for i := 0 to StoreList.Count - 1 do
      AddLineToMap(StoreKeys, StoreQty, StoreName, StoreList[i]);

    // porovnání: co je ve Store a (není v Excelu) nebo (liší se suma qty)
    for i := 0 to StoreKeys.Count - 1 do
    begin
      Key := StoreKeys[i];
      QtyS := NxIBStrToFloat(StoreQty[i]);
      Name := StoreName[i];

      idx := ExcelKeys.IndexOf(Key);
      if idx = -1 then
      begin
        // v Excelu vůbec není -> rozdíl = celé množství ze skladu
        ResultList.Add(MakeLine(Key, QtyS, Name));
      end
      else
      begin
        QtyE := NxIBStrToFloat(ExcelQty[idx]);
        Diff := QtyS - QtyE;
        if Abs(Diff) > EPS then
          // Quantity = rozdíl (Store - Excel)
          ResultList.Add(MakeLine(Key, Diff, Name));
      end;
    end;

  finally
    ExcelKeys.Free; ExcelQty.Free; ExcelName.Free;
    StoreKeys.Free; StoreQty.Free; StoreName.Free;
  end;
end;


procedure FindExcelMoreThanStore(const StoreList, ExcelList, ResultList: TStringList);
var
  StoreKeys, StoreQty, StoreName: TStringList;
  ExcelKeys, ExcelQty, ExcelName: TStringList;
  i, idx: Integer;
  Key: string;
  QtyS, QtyE, Diff: Extended;
  Name: string;
const
  EPS = 0.000001;
begin
  ResultList.Clear;

  StoreKeys := TStringList.Create; StoreQty := TStringList.Create; StoreName := TStringList.Create;
  ExcelKeys := TStringList.Create; ExcelQty := TStringList.Create; ExcelName := TStringList.Create;
  try
    StoreKeys.Sorted := True; StoreKeys.Duplicates := dupIgnore;
    ExcelKeys.Sorted := True; ExcelKeys.Duplicates := dupIgnore;

    // agregace Store
    for i := 0 to StoreList.Count - 1 do
      AddLineToMap(StoreKeys, StoreQty, StoreName, StoreList[i]);

    // agregace Excel
    for i := 0 to ExcelList.Count - 1 do
      AddLineToMap(ExcelKeys, ExcelQty, ExcelName, ExcelList[i]);

    // porovnání: kde ExcelSum > StoreSum
    for i := 0 to ExcelKeys.Count - 1 do
    begin
      Key := ExcelKeys[i];
      QtyE := NxIBStrToFloat(ExcelQty[i]);
      Name := ExcelName[i];

      idx := StoreKeys.IndexOf(Key);
      if idx = -1 then
      begin
        // ve skladu není vůbec -> celé množství chybí
        ResultList.Add(MakeLine(Key, QtyE, Name));
      end
      else
      begin
        QtyS := NxIBStrToFloat(StoreQty[idx]);
        Diff := QtyE - QtyS;
        if Diff > EPS then
          // Quantity = kolik chybí (Excel - Store)
          ResultList.Add(MakeLine(Key, Diff, Name));
      end;
    end;

  finally
    StoreKeys.Free; StoreQty.Free; StoreName.Free;
    ExcelKeys.Free; ExcelQty.Free; ExcelName.Free;
  end;
end;




function ExtractName(const Line: string): string;
var
  p1, p2, p3: Integer;
begin
  Result := '';

  p1 := Pos(';', Line);
  if p1 = 0 then Exit;

  p2 := PosEx(';', Line, p1 + 1);
  if p2 = 0 then Exit;

  p3 := PosEx(';', Line, p2 + 1);
  if p3 = 0 then Exit;

  // Name = 4. položka (za 3. ;)
  Result := Copy(Line, p3 + 1, 100);
end;

procedure AddLineToMap(Keys, QtyList, NameList: TStringList; const Line: string);
var
  Key: string;
  Qty: Extended;
  Name: string;
  idx, insIdx: Integer;
  cur: Extended;
begin
  Key := ExtractKey(Line);
  Qty := ExtractQty(Line);
  Name := ExtractName(Line);

  idx := Keys.IndexOf(Key);
  if idx = -1 then
  begin
    insIdx := Keys.Add(Key); // při Sorted=True vrací insert index
    QtyList.Insert(insIdx, NxFloatToIBStr(Qty));
    NameList.Insert(insIdx, Name);
  end
  else
  begin
    cur := NxIBStrToFloat(QtyList[idx]);
    QtyList[idx] := NxFloatToIBStr(cur + Qty);
    // Name necháváme první (nebo můžeš přepsat, pokud chceš)
  end;
end;

function MakeLine(const Key: string; Qty: Extended; const Name: string): string;
begin
  Result := Key + ';' + NxFloatToIBStr(Qty) + ';' + Name;
end;


function CreateInventoryShortFall(var mOS:TNxCustomObjectSpace; var mDocList:TStringList; var mStore_ID:string; var mDate:Extended):string;
var
 mDocBO, mDocRowBO, mDocRowBatchBO:TNxCustomBusinessObject;
 mRows, mDRBRows:TNxCustomBusinessMonikerCollection;
 mTempStr, mStoreCard_ID, mStoreBatch_ID, mStoreCardCategory_ID:string;
 i:integer;
 mQuantity:Extended;
begin
 Result:='';
 try
   mDocBO:=mOS.CreateObject(Class_InventoryShortFall);
   mDocBO.new;
   mDocBO.Prefill;
   mDocBO.SetFieldValueAsString('DocQueue_ID', cISFDocQueue_ID);
   mDocBO.SetFieldValueAsString('Firm_ID', CFirm_ID);
   mDocBO.SetFieldValueAsDateTime('DocDate$Date', mDate);
   mDocBO.SetFieldValueAsString('Period_ID', GetPeriodID(mOS, mDate));
   mDocBO.SetFieldValueAsString('Description', 'Inventory document');
   mRows:=mDocBO.GetLoadedCollectionMonikerForFieldCode(mDocBO.GetFieldCode('Rows'));
   for i:=0 to mDocList.count-1 do begin
     mTempStr:=mDocList.strings[i];
     mStoreCard_ID:=NxTrapStrTrim(mTempStr,';');
     mStoreBatch_ID:=NxTrapStrTrim(mTempStr,';');
     mQuantity:=NxIBStrToFloat(NxTrapStrTrim(mTempStr,';'));
     mStoreCardCategory_ID:=mOS.SQLSelectFirstAsString('Select storecardcategory_ID from storecards where id='+QuotedStr(mStoreCard_ID),'');
     if (mQuantity>0) and not(mStoreCardCategory_ID='~000000101') and not(NxIsEmptyOID(mStoreBatch_ID)) then begin
       mDocRowBO:=mRows.AddNewObject;
       mDocRowBO.prefill;
       //mDocRowBO.SetFieldValueAsInteger('RowType',3);
       mDocRowBO.SetFieldValueAsString('Store_ID', mStore_ID);
       mDocRowBO.SetFieldValueAsString('StoreCard_ID',mStoreCard_ID);
       mDocRowBO.SetFieldValueAsFloat('Quantity', mQuantity);
       mDocRowBO.SetFieldValueAsString('Division_ID', cDivision_ID);
       if not(NxIsEmptyOID(mStoreBatch_ID)) then begin
         mDRBRows:=mDocRowBO.GetLoadedCollectionMonikerForFieldCode(mDocRowBO.GetFieldCode('DocRowBatches'));
         mDocRowBatchBO:=mDRBRows.AddNewObject;
         mDocRowBatchBO.SetFieldValueAsString('StoreBatch_ID', mStoreBatch_ID);
         mDocRowBatchBO.SetFieldValueAsFloat('Quantity', mQuantity);
       end;
     end;
   end;
   mDocBO.save;
   Result:=mDocBO.OID;
   mDocBO.free;
 except
   NxShowSimpleMessage(ExceptionMessage,nil);
 end;
end;

function CreateInventoryOverPlus(var mOS:TNxCustomObjectSpace; var mDocList:TStringList; var mStore_ID:string; var mDate:Extended):string;
var
 mDocBO, mDocRowBO, mDocRowBatchBO:TNxCustomBusinessObject;
 mRows, mDRBRows:TNxCustomBusinessMonikerCollection;
 mTempStr, mStoreCard_ID, mStoreBatch_ID, mStoreBatchName, mVersion, mEAN:string;
 i:integer;
 mQuantity, mSBDate, mUnitPrice:Extended;
 mInputJSON, mOutputJSON:TJSONSuperObject;
begin
 Result:='';
 try
   mDocBO:=mOS.CreateObject(Class_InventoryOverplus);
   mDocBO.new;
   mDocBO.Prefill;
   mDocBO.SetFieldValueAsString('DocQueue_ID', cIOPDocQueue_ID);
   mDocBO.SetFieldValueAsString('Firm_ID', cFirm_ID);
   mDocBO.SetFieldValueAsDateTime('DocDate$Date', mDate);
   mDocBO.SetFieldValueAsString('Period_ID', GetPeriodID(mOS, mDate));
   mDocBO.SetFieldValueAsString('Description', 'Inventory document');
   mRows:=mDocBO.GetLoadedCollectionMonikerForFieldCode(mDocBO.GetFieldCode('Rows'));
   for i:=0 to mDocList.count-1 do begin
     mTempStr:=mDocList.strings[i];
     mStoreCard_ID:=NxTrapStrTrim(mTempStr,';');
     mStoreBatch_ID:=NxTrapStrTrim(mTempStr,';');
     mQuantity:=NxIBStrToFloat(NxTrapStrTrim(mTempStr,';'));
     mStoreBatchName:=NxTrapStrTrim(mTempStr,';');
     if mQuantity>0 then begin
       mDocRowBO:=mRows.AddNewObject;
       mDocRowBO.prefill;
       mDocRowBO.SetFieldValueAsString('Store_ID', mStore_ID);
       mDocRowBO.SetFieldValueAsString('StoreCard_ID',mStoreCard_ID);
       mDocRowBO.SetFieldValueAsFloat('Quantity', mQuantity);
       mDocRowBO.SetFieldValueAsString('Division_ID', cDivision_ID);
       if mDocRowBO.GetFieldValueAsFloat('TotalPrice')=0 then begin
        mUnitPrice:=mOS.SQLSelectFirstAsExtended('Select PurchasePrice from suppliers where id='+QuotedStr(mDocRowBO.GetFieldValueAsString('StoreCard_ID.MainSupplier_ID')),0);
        mDocRowBO.SetFieldValueAsFloat('UnitPrice', mUnitPrice);
       end;
       if mDocRowBO.GetFieldValueAsInteger('StoreCard_ID.Category') in [1,2] then begin
         mEAN:=mDocRowBO.GetFieldValueAsString('StoreCard_ID.EAN');
           if not(NxIsEmptyOID(mStoreBatch_ID)) then begin
             mDRBRows:=mDocRowBO.GetLoadedCollectionMonikerForFieldCode(mDocRowBO.GetFieldCode('DocRowBatches'));
             mDocRowBatchBO:=mDRBRows.AddNewObject;
             mDocRowBatchBO.SetFieldValueAsString('StoreBatch_ID', mStoreBatch_ID);
             mDocRowBatchBO.SetFieldValueAsFloat('Quantity', mQuantity);
           end else begin
             if not(NxIsBlank(mStoreBatchName)) then begin
               mInputJSON:=TJSONSuperObject.Create;
               mInputJSON.S['ean']:=mEAN;
               mInputJSON.S['batchCode']:=mStoreBatchName;
               mOutputJSON:=API_POST(mInputJSON,'GetDataFromBatch',true);
               mSBDate:=Date;
               mVersion:='';
               if mOutputJSON.N['status'].DataType<>jtNull then begin
                 if mOutputJSON.S['status']='ok' then begin
                   mSBDate:=mOutputJSON.DT8601['expirationDate'];
                   mVersion:=mOutputJSON.S['version'];
                 end;
               end;
               mStoreBatch_ID:=GetBatch_ID(mOS, mStoreCard_ID, mStoreBatchName, mSBDate, mVersion);
             end;
           end;
         end;
     end;
   end;
   mDocBO.save;
   Result:=mDocBO.OID;
   mDocBO.free;
 except
   NxShowSimpleMessage(ExceptionMessage,nil);
 end;
end;

Function GetPeriodID(var aOS:TNxCustomObjectSpace;var aDate:Extended):string;
var
 mSQL:string;
begin
  Result:=aOS.SQLSelectFirstAsString('select id from periods where datefrom$date<='+IntToStr(trunc(adate))+' and dateto$date>'+IntToStr(trunc(adate)),'');
end;

Function GetBatch_ID(var aOS:TNxCustomObjectSpace;var aStoreCard_ID, aBatchCode:string;var aDate:Extended;var aVersion:string):string;
var
 mBO:TNxCustomBusinessObject;
 mStoreBatch_ID:string;
begin
 Result:='';
 mStoreBatch_ID:=aOS.SQLSelectFirstAsString('Select id from storebatches where storecard_id='+QuotedStr(aStoreCard_ID)+' and name='+QuotedStr(aBatchCode),'');
 if not(NxIsEmptyOID(mStoreBatch_ID)) then begin
    mBO:=aOS.CreateObject(Class_StoreBatch);
    mBO.Load(mStoreBatch_ID,nil);
    mBO.SetFieldValueAsDateTime('ExpirationDate$DATE',aDate);
    mBO.SetFieldValueAsString('X_Verze',aVersion);
    mBO.save;
    mbo.free;
 end else begin
    mBO:=aOS.CreateObject(Class_StoreBatch);
    mBO.New;
    mBO.prefill;
    mBO.SetFieldValueAsString('StoreCard_ID',aStoreCard_ID);
    mBO.SetFieldValueAsString('Name',aBatchCode);
    mBO.SetFieldValueAsDateTime('ExpirationDate$DATE',aDate);
    mBO.SetFieldValueAsString('X_Verze',aVersion);
    mBO.save;
    mStoreBatch_ID:=mBO.OID;
    mbo.free;
 end;
 Result:=mStoreBatch_ID;
end;

function API_POST(aJSON:TJSONSuperObject;AName:string; AIsScript: Boolean = True; aIndex: integer = 0):TJSONSuperObject;
var
 mWinHTTP:Variant;
 mResultJSON:TJSONSuperObject;
 mSuffix, mURL: string;
begin
  mSuffix:= '';
  if (AIsScript = True) and (aIndex = 0) then mSuffix:= 'script/eu.abra.alec.Lipoelastic.API_Sync/lib/';

  try
   mWinHTTP:= CreateOleObject('WinHttp.WinHttpRequest.5.1');
   mURl:=cURL+mSuffix+aName;
   mWinHTTP.Open('POST', mURL);
   mWinHTTP.SetRequestHeader('Content-Type', 'application/json');
   if aIndex=0 then mWinHTTP.SetRequestHeader('Authorization','Basic '+cAuthorization);
   mWinHTTP.Send(aJSON.AsJson);
   mResultJSON:=TJSONSuperObject.Create;
   mResultJSON.S['Category']:=aName;
   mResultJSON.S['ServiceName']:=cServiceName;
   mResultJSON.I['HTTPStatus']:=StrToInt(mWinHTTP.status);
   mResultJSON.S['InputJSON']:='#'+aJSON.AsString+'#';
   if mWinHTTP.status='200' then begin
     Result:=TJSONSuperObject.ParseString(mWinHTTP.ResponseText, True);
     mResultJSON.S['Status']:='OK';
   end else begin
     Result:=TJSONSuperObject.create;
     Result.S['ID']:='';
     Result.S['Status']:=mWinHTTP.status;
     mResultJSON.S['Status']:='Error1';
   end;
   API_Result(mResultJSON);
  except
   Result:=TJSONSuperObject.create;
   Result.S['error']:='error';
   mResultJSON:=TJSONSuperObject.Create;
   mResultJSON.S['Category']:=aName;
   mResultJSON.S['ServiceName']:=cServiceName;
   mResultJSON.I['HTTPStatus']:=404;
   mResultJSON.S['InputJSON']:=aJSON.AsString;
   mResultJSON.S['Status']:='Error1';
   API_Result(mResultJSON);
  end;
end;

function API_Result(aJSON:TJSONSuperObject):TJSONSuperObject;
var
 mWinHTTP:Variant;
begin
  try
   mWinHTTP:= CreateOleObject('WinHttp.WinHttpRequest.5.1');
   mWinHTTP.Open('POST', 'https://log-api.eu.newrelic.com/log/v1');
   mWinHTTP.SetRequestHeader('Content-Type', 'application/json');
   mWinHTTP.SetRequestHeader('Api-Key','eu01xx9184505e1c59528b186a0dd8edFFFFNRAL');
   mWinHTTP.Send(aJSON.AsJson);
   Result:=TJSONSuperObject.ParseString(mWinHTTP.ResponseText, True);
  except
   Result:=TJSONSuperObject.create;
   Result.S['error']:='error';
  end;
end;


begin
end.