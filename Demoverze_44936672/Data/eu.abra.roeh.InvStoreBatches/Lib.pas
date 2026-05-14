uses 'eu.abra.roeh.InvStoreBatches.Const';

procedure ShowDebugMessage(AMessage: Variant);
begin
  if cInDebug then begin
    if cUseDebugger then
      OutputDebugString(Format('%s : %s',[cAppName, VarToStr(AMessage)]))
    else
      ShowMessage(Format('%s : %s',[cAppName, VarToStr(AMessage)]));
  end;
end;

function GetFirstRecordFromSQL(AOS: TNxCustomObjectSpace; ASQL: String): String;
var
  mSQLRes: TStrings;
begin
  Result := '';
  mSQLRes := TStringList.Create;
  try
    AOS.SQLSelect(ASQL, mSQLRes);
    if mSQLRes.Count > 0 then
      Result := mSQLRes.Strings[0]
  finally
    mSQLRes.Free;
  end;
end;

function GetId(iOS:TNxCustomObjectSpace;const itable,iField,iValue:string):string;
var
    Str: TStringList;
begin
  Result := '';
  Str := TStringList.Create;
  try
    iOS.SQLSelect('select id from '+ iTable+' a where a.Hidden <> ''A'' and Upper(a.'+iField+') =''' + UpperCase(iValue) + '''',Str);
    if Str.Count >0 then Result := Str.Strings(0);
  finally
    Str.Free;
  end;
end;

procedure RefreshRowsGrid(Self: TSiteForm);
var i: Integer;
 mList: TActionList;
begin
    mList := Self.GetMainActionList;
    for i:=0 to mList.ActionCount -1 do
    begin
      if mList.Actions[i].Name = 'actRefresh' then begin
        try
          mList.Actions[i].Execute;
        except
          // zlobylo při mazání objektu
       end;
     end;
   end;
end;

procedure MyShowMessage(AMessage : String; AType : TNxMsgDlgType = mdError);
begin
  // mdError,mdWarning,mdConfirm,mdInformation,mdExclamation,mdStop
  NxShowMessage(cAppName, AMessage, AType, false, nil);
end;

function MyShellExecute(AFileName : String; ) : Boolean;
begin
  Result := False;
  if cEmulDebugICS  then begin
    Result := True;
    Exit;
  end;
  if AFileName <> '' then begin
    try
      Result := ShellAPI.Execute('', ExtractFileName(AFileName), '', ExtractFilePath(AFileName));
    except
      MyShowMessage('Nepodařilo se spustit soubor ' + AFileName + ' (' + ExceptionMessage + ')');
    end;
  end else
    Result := True;
end;

function WaitUntilFileExist(AFileName : String; AMaxRepeat, ASleep : Integer) : Boolean;
// Čeká, dokud nebude existovat soubor na disku, kontroluje AMaxRepeat-krát, po ASleep vteřinách
// Pokud je soubor nalezen, vrátí true, jinak false
var
  mRepeatCount : Integer;
begin
  Result := False;
  mRepeatCount := 1;
  While (not FileExists(AFileName)) and (mRepeatCount <= AMaxRepeat) do begin
    ShowDebugMessage(IntToStr(mRepeatCount) + '/' + IntToStr(AMaxRepeat) + 'Čekám na soubor ' + AFileName);
    Sleep(ASleep * 100000);
    Inc(mRepeatCount);
  end;
  if FileExists(AFileName) then
    Result := True;
end;

function GetFileContent(AFileName : String; AData : TStringList) : Boolean;
// Načte obsah souboru do StringListu
var
   mCount : Integer;
begin
  Result := False;
   mCount := 30;
  if FileExists(AFileName) then begin
    repeat
      try
        AData.LoadFromFile(AFileName);
        mCount := 0;
        Result := True;
      except
        Dec(mCount);
        Sleep(1000);
      end;
    until mCount<=0;
  end;
end;

function GetCreateBatch(aOS:TNxCustomObjectSpace;const aStoreCardID,aBatch,aZP:string;aDmt:TDateTime;):string;
var
 mStr: TStringList;
 mSql : string;
 mBo: TNxCustomBusinessObject;
begin
  Result := '';
  mStr := TStringList.Create;
  try
    mSql := 'select id from STOREBATCHES b where b.storecard_id = '''+aStoreCardID+''' and name = '''+aBatch +'''';
    aOS.SqlSelect(mSql, mStr);
    if mStr.Count > 0 then
      Result := mStr.Strings[0]
    else begin
      mBo:= aOS.CreateObject(Class_StoreBatch);
      mBo.New;
      mBo.Prefill;
      mBo.SetFieldValueAsString('StoreCard_Id', aStoreCardID);
      mBo.SetFieldValueAsDateTime('ExpirationDate$Date',aDmt);
      mBo.SetFieldValueAsString('Name', aBatch);
      mBo.SetFieldValueAsBoolean('SerialNumber',false);
      mBo.SetFieldValueAsString('Note', 'Vytvoření šarže přo výdeji');
      mBo.SetFieldValueAsBoolean('X_Doplnena',true);
      mBo.SetFieldValueAsString('X_ZP_ID',GetId(aOS,'Countries','Code',aZP));
      mBo.Save;
      Result:= mBo.OID;
    end;
  finally
    mStr.Free;
  end;
end;

function GetImportRowInfoStoreRow(AOS : TNxCustomObjectSpace; AInputData : String; var AStoreCardID : String; var AQuantity : Double; var FLSCKB : String; var PID : String; var TS : String; var AUnitRate : Double) : Boolean;
// Z předaného importního řádku zjistí skladovou kartu a reálně vyskladněné množství
const
  cSQLGetStoreCard =
    'SELECT ID FROM StoreCards WHERE CODE = ''%s'' AND HIDDEN = ''N''';
  cSQLGetUnitRate =
    'SELECT coalesce(su.UnitRate, 0) FROM StoreUnits su inner join StoreCards sc on sc.ID = su.Parent_ID WHERE sc.CODE = ''%s'' AND sc.HIDDEN = ''N'' AND sc.MainUnitCode = su.Code';
var
  mStoreCardCode, mQuantity : String;
begin
  if Copy(AInputData,1,1) = '*' then begin
    Result := false;
    RaiseException('Neočekávaná šaržová věta:' + AInputData);
    Exit;
  end;
  Result := True;
  mStoreCardCode := Trim(Copy(AInputData, 12, 6));
  mQuantity:= NxSearchReplace(Trim(Copy(AInputData, 59, 10)), '.', ',', [srAll]);
  FLSCKB := Trim(Copy(AInputData, 81, 1));
  PID := Trim(Copy(AInputData, 82, 3));
  TS := Trim(Copy(AInputData, 85, 14));

  AStoreCardID := GetFirstRecordFromSQL(AOS, Format(cSQLGetStoreCard, [mStoreCardCode]));
  AUnitRate := StrToFloat(GetFirstRecordFromSQL(AOS, Format(cSQLGetUnitRate, [mStoreCardCode])));
  if AStoreCardID = '' then begin
    MyShowMessage('Nepodařilo se dohledat platnou skladovou kartu dlé kódu [' + mStoreCardCode+ ']');
    Result := False;
  end;
  try
    AQuantity := StrToFloat(mQuantity); // nenasobit jednotkou je jiz v protokolu * AUnitRate;
  except
    MyShowMessage('Importovaný údaj se nepodařilo převést na číslo [' + mQuantity + ']');
    Result := False;
  end;
end;

function GetMainProtocolRowID(aPartInvPro: TNxCustomBusinessObject; const aStoreCardID:string):string;
var
  mStr : TStringList;
  mMainProtocolRow : TNxCustomBusinessObject;
  mSQL : string;
begin
  Result := '';
 // Pokud máme kod, zkusime najít skladovou kartu v hlavním inventárním protokolu. Pokud neexistuje, založíme ji.
  mStr := TStringList.Create;
  try
    mSQL := 'select ID from MainInvProtocolRows where Parent_ID = ''' + aPartInvPro.GetFieldValueAsString('MainProtocol_ID')+ ''' and Closed = ''N'' and StoreCard_ID = ''' + aStoreCardID + '''';
    aPartInvPro.ObjectSpace.SQLSelect(mSQL, mStr);
    if mStr.Count > 0 then
      Result := mStr[0];
  finally
    mStr.Free;
  end;

  // Pokud neexistuje ani řádek hlavního inventárního protokolu, nejprve jej založíme.
  if NxIsEmptyOID(Result) then
  begin
    mMainProtocolRow := aPartInvPro.ObjectSpace.CreateObject(Class_MainInvProtocolRow);
    try
      mMainProtocolRow.New;
      mMainProtocolRow.Prefill;
      mMainProtocolRow.SetFieldValueAsString('Parent_ID', aPartInvPro.GetFieldValueAsString('MainProtocol_ID'));
      mMainProtocolRow.SetFieldValueAsString('StoreCard_ID', aStoreCardID);
      mMainProtocolRow.Save;
      Result := mMainProtocolRow.OID;
    finally
      mMainProtocolRow.Free;
    end;
  end;
end;

function GetMainProtocolBatchRowID(aPartInvProRow: TNxCustomBusinessObject; const aStoreCard,aBatchID:string):string;
var
  mStr : TStringList;
  mMainProtocolRow, mMainProtocolBatchRow : TNxCustomBusinessObject;
  mSQL,mResult : string;
begin
  Result := '';
 // Pokud máme kod, zkusime najít šarži skladové kartu v hlavním inventárním protokolu. Pokud neexistuje, založíme ji.
  mStr := TStringList.Create;
  try
    mSQL := 'select MRB.ID from MainInvProtocolRows MR inner join MainInvProtocolBatches MRB on MR.parent_id = MR.ID '+
        ' where MR.Parent_ID = '''+aPartInvProRow.GetFieldValueAsString('MIPRow_ID')+''' and MR.StoreCard_ID = '''+ aStoreCard +''' and MRB.StoreBatch_ID='''+ aBatchID +'''';
    aPartInvProRow.ObjectSpace.SQLSelect(mSQL, mStr);
    if mStr.Count > 0 then
      mResult := mStr[0];
  finally
    mStr.Free;
  end;

  // Pokud neexistuje ani řádek hlavního inventárního protokolu, nejprve jej založíme.
  if NxIsEmptyOID(Result) then
  begin
    mMainProtocolRow := aPartInvProRow.ObjectSpace.CreateObject(Class_MainInvProtocolRow);
    try
      mMainProtocolRow.Load(aPartInvProRow.GetFieldValueAsString('MIPRow_ID'),nil);
      mMainProtocolBatchRow := mMainProtocolRow.GetLoadedCollectionMonikerForFieldCode(mMainProtocolRow.GetFieldCode('Rows')).AddNewObject;
      mMainProtocolBatchRow.Prefill;
      mResult := mMainProtocolBatchRow.OID;
      mMainProtocolBatchRow.SetFieldValueAsString('StoreBatch_ID',aBatchID);
      mMainProtocolBatchRow.SetFieldValueAsString('QUnit',aPartInvProRow.GetFieldValueAsString('QUnit'));
      mMainProtocolBatchRow.SetFieldValueAsFloat('UnitRate',aPartInvProRow.GetFieldValueAsFloat('UnitRate'));
      mMainProtocolBatchRow.SetFieldValueAsFloat('RealQuantity',0);
      mMainProtocolRow.Save;
    finally
      mMainProtocolRow.Free;
    end;
  end;
  Result := mResult;
end;

function GetImportRowBatchRow(aRow:TNxCustomBusinessObject;AInputData,aStoreCard : String) : Boolean;
// Z předaného importního řádku zjistí  šarže
var
  mLot,mIDBatch,mZP : String;
  mBatchRows : TNxCustomBusinessMonikerCollection;
  N : Integer;
  mMN_s:Extended;
  mRowBatch: TNxCustomBusinessObject;
  mDMT : TDateTime;
  mYear,mMonth,mDay:Integer;
  mBatchID,mMainRowID: string;
begin
  Result := false;
  if Copy(AInputData,1,1)  <> '*' then
    exit;
  mBatchRows := aRow.GetLoadedCollectionMonikerForFieldCode(aRow.GetFieldCode('Rows'));
  mLot := Trim(Copy(AInputData, 29, 20));
  mMN_s := NxStrToFloat(Trim(Copy(AInputData, 59, 10)),'.');
  if mMN_s > 0 then begin
    for N := 0 to mBatchRows.Count - 1 do
      if mBatchRows.BusinessObject[N].GetFieldValueAsString('MIPBatch_ID.StoreBatch_ID.Name')= mLot then begin // jen přidáme stejnou šarži
        mBatchRows.BusinessObject[N].SetFieldValueAsFloat('RealQuantity',mBatchRows.BusinessObject[N].GetFieldValueAsFloat('RealQuantity') + (mMN_s*aRow.GetFieldValueAsFloat('UnitRate')));
        mMN_s := 0;
        Break;
      end;
    if mMN_s > 0 then begin
      mZP := Trim(Copy(AInputData, 26, 3));
      mYear:= StrToInt(Trim(Copy(AInputData, 18, 4)));
      mMonth:= StrToInt(Trim(Copy(AInputData, 22, 2)));
      mDay:= StrToInt(Trim(Copy(AInputData, 24, 2)));
      mDMT := EncodeDate(mYear,mMonth,mDay);
//      mStoreCard := aRow.GetMonikerForFieldCode(aRow.GetFieldCode('StoreCard_id')).BusinessObject;
      mRowBatch := mBatchRows.AddNewObject;
      mRowBatch.Prefill;
      mBatchID := GetCreateBatch(aRow.ObjectSpace,aStoreCard,mLot,mZP,mDMT);
      mMainRowID := GetMainProtocolBatchRowID(aRow,aStoreCard,mBatchID);
      mRowBatch.SetFieldValueAsString('MIPBatch_ID',mMainRowID);
      mRowBatch.SetFieldValueAsString('QUnit',aRow.GetFieldValueAsString('QUnit'));
      mRowBatch.SetFieldValueAsFloat('UnitRate',aRow.GetFieldValueAsFloat('UnitRate'));
      mRowBatch.SetFieldValueAsFloat('RealQuantity',mRowBatch.GetFieldValueAsFloat('RealQuantity') + (mMN_S*aRow.GetFieldValueAsFloat('UnitRate')));
//      mRow.SetFieldValueAsString('X_ZP_ID',GetId(aRow.ObjectSpace,'Countries','Code',mZP));
    end;
  end;
  Result := True;
end;


procedure MiniInventura(aPartInvPro: TNxCustomBusinessObject;aFileData:TStringList);
var
  mRow : TNxCustomBusinessObject;
  N : Integer;
  mStoreCardID, mRowID,mMainProtocolRowID : String;
  mUnitRate : Double;
  mQuantityAbr, mQuantityICM : Double;
  FLSCKB, PID, TS : String;
  mStoreCode,mStore, mDivision, mBusOrder, mBusTransaction, mBusProject : String;
  mCardCategory : integer;
  mSupBatches : TMemoryDataset;

begin
  N :=0;
  while N <= aFileData.Count-1 do begin
    GetImportRowInfoStoreRow(aPartInvPro.ObjectSpace, aFileData[N], mStoreCardID, mQuantityIcm, FLSCKB, PID, TS, mUnitRate);
    mRowID := GetFirstRecordFromSQL(aPartInvPro.ObjectSpace,'select P.Id from PartialInvProtocolRows P inner join MainInvProtocolRows MR on MR.ID = P.MIPRow_ID '+
       ' where P.Parent_ID = '''+aPartInvPro.OID+''' and MR.StoreCard_ID = '''+mStoreCardID+'''');
    mCardCategory := StrToInt(GetFirstRecordFromSQL(aPartInvPro.ObjectSpace,'select Category from StoreCards where id= '''+mStoreCardID+''''));
    mMainProtocolRowID := GetMainProtocolRowID(aPartInvPro,mStoreCardID);
    mRow := aPartInvPro.ObjectSpace.CreateObject(Class_PartialInvProtocolRow);
    try
     if NxIsEmptyOID(mRowID) then begin
        mRow.New;
        mRow.Prefill;
        mRow.SetFieldValueAsString('Parent_ID', aPartInvPro.OID);
        mRow.SetFieldValueAsString('MIPRow_ID', mMainProtocolRowID);
        if mCardCategory <>2 then
          mRow.SetFieldValueAsFloat('RealQuantity', mQuantityIcm {* mUnitRate});
        mRow.SetFieldValueAsFloat('X_RealQuantity', mQuantityIcm {* mUnitRate});
        mRow.SetFieldValueAsFloat('UnitRate', mUnitRate);
        mRowID := mRow.OID;
     end else begin
       mRow.Load(mRowID, nil);
      if mCardCategory <>2 then
         mRow.SetFieldValueAsFloat('RealQuantity', mRow.GetFieldValueAsFloat('RealQuantity') + mQuantityIcm {* mUnitRate});
      mRow.SetFieldValueAsFloat('X_RealQuantity', mRow.GetFieldValueAsFloat('X_RealQuantity') + mQuantityIcm {* mUnitRate});
     end;
     Inc(N);
     if mCardCategory = 2 then begin // musím vyřešit šarže
       while N <= aFileData.Count-1 do begin
         if not GetImportRowBatchRow(mRow,aFileData[N],mStoreCardID) then
            Break;
         Inc(N);
       end;
     end;
      mRow.Save;
    finally
      mRow.Free;
    end;
  end;
end;

procedure  HlavniInventura(aPartInvPro: TNxCustomBusinessObject;aFileData:TStringList);
var
  mRow : TNxCustomBusinessObject;
  N : Integer;
  mStoreCardID, mRowID,mMainProtocolRowID : String;
  mUnitRate : Double;
  mQuantityAbr, mQuantityICM : Double;
  FLSCKB, PID, TS : String;
  mStoreCode,mStore, mDivision, mBusOrder, mBusTransaction, mBusProject : String;
  mCardCategory : integer;
  mSupBatches : TMemoryDataset;

begin
  For  N := 0 to aFileData.Count-1 do begin
    GetImportRowInfoStoreRow(aPartInvPro.ObjectSpace, aFileData[N], mStoreCardID, mQuantityIcm, FLSCKB, PID, TS, mUnitRate);
    mRowID := GetFirstRecordFromSQL(aPartInvPro.ObjectSpace,'select P.Id from PartialInvProtocolRows P inner join MainInvProtocolRows MR on MR.ID = P.MIPRow_ID '+
       ' where P.Parent_ID = '''+aPartInvPro.OID+''' and MR.StoreCard_ID = '''+mStoreCardID+'''');
    mCardCategory := StrToInt(GetFirstRecordFromSQL(aPartInvPro.ObjectSpace,'select Category from StoreCards where id= '''+mStoreCardID+''''));
    mMainProtocolRowID := GetMainProtocolRowID(aPartInvPro,mStoreCardID);
    mRow := aPartInvPro.ObjectSpace.CreateObject(Class_PartialInvProtocolRow);
    try
     if NxIsEmptyOID(mRowID) then begin
        mRow.New;
        mRow.Prefill;
        mRow.SetFieldValueAsString('Parent_ID', aPartInvPro.OID);
        mRow.SetFieldValueAsString('MIPRow_ID', mMainProtocolRowID);
        mRow.SetFieldValueAsFloat('X_RealQuantity', mQuantityIcm {* mUnitRate});
        mRow.SetFieldValueAsFloat('UnitRate', mUnitRate);
        mRowID := mRow.OID;
     end else begin
       mRow.Load(mRowID, nil);
       mRow.SetFieldValueAsFloat('X_RealQuantity', mRow.GetFieldValueAsFloat('X_RealQuantity') + mQuantityIcm {* mUnitRate});
     end;
      mRow.Save;
    finally
      mRow.Free;
    end;
  end;
end;

procedure GetSubBatch(Self:TNxCustomBusinessObject; const aStoreCardID: string;aData: TMemoryDataset);
var
  mSQL : string;
begin
{  Neošetřoval souběh více dílčích protokolů
 mSql := 'select SSB.storebatch_id as ID,SSB.quantity as quantity, sb.expirationdate$date from StoreSubBatches SSB '+
      ' inner join storebatches SB on SB.id =SSB.storebatch_id where SSB.Store_ID = '''+
      Self.GetFieldValueAsString('MainProtocol_ID.Store_ID')+''' and SB.storecard_id ='''+
      aStoreCardID+''' and SSB.quantity>0 and (not (SB.Name like ''HI_%'')) order by sb.expirationdate$date desc';
 }

 { mSql :='select SSB.storebatch_id as ID,SSB.quantity -(select sum(PRB.realquantity) '
      + ' from maininvprotocolrows MPR inner join PartialInvProtocolRows PPR on PPR.miprow_id = MPR.ID '
      + ' inner join PartialInvProtocolBatches PRB on PRB.parent_id = PPR.ID inner join MainInvProtocolBatches MPB on MPB.id =PRB.mipbatch_id '
      + ' where MPR.Parent_ID = '''+Self.GetFieldValueAsString('MainProtocol_ID')+''' and MPR.storecard_id = '''+aStoreCardID
      +''' and MPB.storebatch_id = SB.ID) as quantity, sb.expirationdate$date from StoreSubBatches SSB '
      + ' inner join storebatches SB on SB.id =SSB.storebatch_id where SSB.Store_ID ='''+Self.GetFieldValueAsString('MainProtocol_ID.Store_ID')
      +''' and SB.storecard_id ='''+aStoreCardID +''' and (SSB.quantity - (select sum(PRB.realquantity) '
      + ' from maininvprotocolrows MPR inner join PartialInvProtocolRows PPR on PPR.miprow_id = MPR.ID '
      + ' inner join PartialInvProtocolBatches PRB on PRB.parent_id = PPR.ID inner join MainInvProtocolBatches MPB on MPB.id =PRB.mipbatch_id '
      + ' where MPR.Parent_ID = '''+Self.GetFieldValueAsString('MainProtocol_ID')+''' and MPR.storecard_id = '''+aStoreCardID
      +''' and MPB.storebatch_id = SB.ID))>0 and (not (SB.Name like ''HI_%'')) order by sb.expirationdate$date desc';
      }
  mSQL := 'select distinct MPB.storebatch_id as ID,MPB.DocumentedQuantity -coalesce((select sum(PRBx.realquantity) '
     + ' from maininvprotocolrows MPRx  inner join PartialInvProtocolRows PPRx on PPRx.miprow_id = MPRx.ID '
     + ' inner join PartialInvProtocolBatches PRBx on PRBx.parent_id = PPRx.ID '
     + ' inner join MainInvProtocolBatches MPBx on MPBx.id =PRBx.mipbatch_id'
     + ' where MPRx.Parent_ID = '''+Self.GetFieldValueAsString('MainProtocol_ID')+''' and MPRx.storecard_id = '''+aStoreCardID
     + ''' and MPBx.storebatch_id = MPB.storebatch_id),0) as quantity , sb.expirationdate$date '
     + ' from MainInvProtocolRows MPR inner join MainInvProtocolBatches MPB on MPB.Parent_ID = MPR.ID '
     + ' inner join storebatches SB on SB.id =MPB.storebatch_id'
     + ' where MPR.Parent_ID = '''+Self.GetFieldValueAsString('MainProtocol_ID')+''' and MPR.StoreCard_ID = '''+aStoreCardID
     + '''  and (not (SB.Name like ''HI_%'')) order by sb.expirationdate$date desc';
   Self.ObjectSpace.SQLSelect2(mSql,aData);
   if aData.Active then aData.First;
end;

procedure AddBatchRows(aRow:TNxCustomBusinessObject;const aBatchID:string; const aQuantity :Extended);
var
  mRowBatch: TNxCustomBusinessObject;
  mRowID:String;
begin
  mRowID := GetMainProtocolBatchRowID(aRow,aRow.GetFieldValueAsString('MIPRow_ID.StoreCard_ID'),aBatchID);
  mRowBatch := aRow.GetLoadedCollectionMonikerForFieldCode(aRow.GetFieldCode('Rows')).AddNewObject;
  mRowBatch.Prefill;
  mRowBatch.SetFieldValueAsString('MIPBatch_ID',mRowID);
  mRowBatch.SetFieldValueAsstring('qUnit',mRowBatch.GetFieldValueAsString('MIPBatch_ID.QUnit'));
  mRowBatch.SetFieldValueAsFloat('UnitRate',mRowBatch.GetFieldValueAsFloat('MIPBatch_ID.UnitRate'));
  mRowBatch.SetFieldValueAsFloat('RealQuantity',aQuantity*mRowBatch.GetFieldValueAsFloat('MIPBatch_ID.UnitRate'));
end;

function GetNewBatch(aRow:TNxCustomBusinessObject):string;
var
  mSql :string;
  mStr : TStringList;
  mRowsBatch : TNxCustomBusinessMonikerCollection;
  N : Integer;
  mDate:TDateTime;
  mBo,mOldBat,mNewBat: TNxCustomBusinessObject;
  S : string;
begin
  Result := '';
  mStr := TStringList.Create;
  try
    mSql := 'select SB.id as ID from  storebatches SB '+
      ' where SB.storecard_id ='''+aRow.GetFieldValueAsString('MIPRow_ID.StoreCard_ID')+''' and (SB.Name like ''HI_%'') and '+
      ' (not exists (select 1 from MainInvProtocolBatches MB where MB.Parent_ID <>'''+aRow.GetFieldValueAsString('MIPRow_ID')+''' and SB.ID = MB.StoreBatch_ID ))'; // Né starší jak 10 dní
     aRow.ObjectSpace.SQLSelect(mSql,mStr);
     if mStr.Count > 0 then
        Result := mStr.Strings[0]
     else begin
       mBo := aRow.ObjectSpace.CreateObject(class_MainInvProtocolRow);
       try
         mBo.Load(aRow.GetFieldValueAsString('MIPRow_ID'),nil);
         mRowsBatch := mBo.GetLoadedCollectionMonikerForFieldCode(mBo.GetFieldCode('Rows'));
         mDate := 50000;
         S :='';
         for N := 0 to mRowsBatch.Count - 1 do
           if (mDate > mRowsBatch.BusinessObject[N].GetFieldValueAsDateTime('StoreBatch_ID.ExpirationDate$DATE')) and
            (mRowsBatch.BusinessObject[N].GetFieldValueAsFloat('DocumentedQuantity') >0) then begin
              mDate :=  mRowsBatch.BusinessObject[N].GetFieldValueAsDateTime('StoreBatch_ID.ExpirationDate$DATE');
              S := mRowsBatch.BusinessObject[N].GetFieldValueAsString('StoreBatch_ID');
           end;
        if NxIsEmptyOID(S) then begin // zkusime jeste nejmladsi zapornou
          mDate := 0;
         for N := 0 to mRowsBatch.Count - 1 do
           if (mDate < mRowsBatch.BusinessObject[N].GetFieldValueAsDateTime('StoreBatch_ID.ExpirationDate$DATE')) and
            (mRowsBatch.BusinessObject[N].GetFieldValueAsFloat('DocumentedQuantity') < 0) then begin
              mDate :=  mRowsBatch.BusinessObject[N].GetFieldValueAsDateTime('StoreBatch_ID.ExpirationDate$DATE');
              S := mRowsBatch.BusinessObject[N].GetFieldValueAsString('StoreBatch_ID');
           end;
        end;
        if NxIsEmptyOID(S) then begin
    //      RaiseException('Nebyla dohledána žádná šarže na kartě :' + aRow.GetFieldValueAsString('MIPRow_ID.StoreCard_ID.Code') + ' a skladu: ' + aRow.GetFieldValueAsString('MIPRow_ID.Parent_ID.Store_ID.Name'));
         mSql := 'select x.id from (select b.ExpirationDate$DATE, b.ID as ID from StoreBatches b ' +
          ' where exists (select 1 from storesubbatches ssb where ssb.storecard_id ='''+aRow.GetFieldValueAsString('MIPRow_ID.StoreCard_ID')+''' and ssb.storebatch_id= b.id) order by b.ExpirationDate$DATE desc) x';
         S := GetFirstRecordFromSQL(mBo.ObjectSpace,mSql);
        end;
          mOldBat :=aRow.ObjectSpace.CreateObject(Class_StoreBatch);
          try
            mOldBat.Load(S,nil);
           //Ještě oštříme, že generovaná šarže již existuje
           mSql := 'select b.id from StoreBatches b where b.Name = ''HI_' + mOldBat.GetFieldValueAsString('Name')+''' and b.StoreCard_Id=''' +mOldBat.GetFieldValueAsString('StoreCard_Id')+ '''';
            S := GetFirstRecordFromSQL(mBo.ObjectSpace,mSql);
            if s <> '' then
              Result := S
            else begin
              mNewBat := mOldBat.Clone;
              try
                mNewBat.SetFieldValueAsString('X_ZP_ID',mOldBat.GetFieldValueAsString('X_ZP_ID'));
                mNewBat.SetFieldValueAsString('Name','HI_' + mOldBat.GetFieldValueAsString('Name'));
                mNewBat.SetFieldValueAsString('Note','Inventura' + mOldBat.GetFieldValueAsString('Note'));
                mNewBat.SetFieldValueAsDateTime('ExpirationDate$DATE',mOldBat.GetFieldValueAsDateTime('ExpirationDate$DATE') - 1); // dáváme o den kratší DMT
                Result := mNewBat.OID;
                mNewBat.Save;
              finally
                mNewBat.Free;
              end;
            end;
          finally
            mOldBat.Free;
          end;
       finally
         mBo.Free;
       end;
     end
  finally
    mStr.Free;
  end;
end;

procedure DeleteRel(aRow:TNxCustomBusinessObject);
const
 cSql = 'select PR.Parent_ID from Relations R inner join PartialInvProtocolRows PR on PR.ID =  R.RightSide_ID '+
     ' inner Join PartialInvProtocolBatches PB on PB.Parent_ID = PR.ID where R.REL_DEF = '+IntToStr(cRelNegaQuant)+' and R.LeftSide_ID = ''%s''';
 cSqlDel = 'delete from relations r where R.REL_DEF = '+IntToStr(cRelNegaQuant)+' and R.LeftSide_ID  = ''%s''';
var
  mID : string;
begin
  mID := GetFirstRecordFromSQL(aRow.ObjectSpace,Format(cSql,[aRow.OID]));
  if mID<>'' then
    RaiseException('Nepovedlo se zrušit korekční vazbu a kartě zrušte doplnění šarží na protokolu' +
    NxEvalObjectExprAsString(aRow,'NxGetDocumentDisplayName('''+mID+''',''PI'')'));
  aRow.ObjectSpace.SQLExecute(Format(cSqlDel,[aRow.OID]));
end;

procedure CorectQuantInv(aRow:TNxCustomBusinessObject;aRealQuantity:Extended);
const
  cSql1 = 'select P.ID from PartialInvProtocolRows P where P.ID <>''%s'' and P.MIPRow_ID = ''%s'' and (not exists (select 1 from PartialInvProtocolBatches PB where PB.Parent_ID=P.ID))';
var
  mOS : TNxCustomObjectSpace;
  mStr: TStringList;
  N : Integer;
  mRel,mOtherRow:TNxCustomBusinessObject;
  mNalQuant:Extended;
begin
  aRealQuantity := -1* aRealQuantity; // otocime si znamenko na to co musime umistit
  mOS := aRow.ObjectSpace;
  mStr:= TStringList.Create;
  try
   DeleteRel(aRow); // Nejprve si mus9m relace zrusit pro prepocet
    mOS.SQLSelect(Format(cSql1,[aRow.OID,aRow.GetFieldValueAsString('MIPRow_ID')]),mStr);
    for N:=0 to mStr.Count - 1 do begin
      mOtherRow := mOS.CreateObject(Class_PartialInvProtocolRow);
      try
        mOtherRow.Load(mStr.Strings[N],nil);
        mNalQuant := -1*NxIBStrToFloat(GetFirstRecordFromSQL(mOS,Format(cSelSumRel,[mStr.Strings[N]]))); // otacim si  znamenko
        if mOtherRow.GetFieldValueAsFloat('X_RealQuantity')> mNalQuant then begin // je jeste co rozdelit do daneho radku
          mNalQuant := mOtherRow.GetFieldValueAsFloat('X_RealQuantity')- mNalQuant; // nyni mam mnozstvi, ktere sem mohu dat
          mRel := mOS.CreateObject(Class_Relation);
          try
            mRel.New;
            mRel.Prefill;
            mRel.SetFieldValueAsString('LEFTSIDE_ID',aRow.OID);
            mRel.SetFieldValueAsString('RIGHTSIDE_ID',mOtherRow.OID);
            mRel.SetFieldValueAsInteger('REL_DEF',cRelNegaQuant);
            if mNalQuant> aRealQuantity then begin
              mRel.SetFieldValueAsFloat('NUMVALUE',-aRealQuantity);
              aRealQuantity := 0;
            end else begin
              mRel.SetFieldValueAsFloat('NUMVALUE',-mNalQuant);
              aRealQuantity := aRealQuantity - mNalQuant;
            end;
            mRel.Save;
          finally
            mRel.Free;
          end;
        end;
      finally
        mOtherRow.Free;
      end;
      if aRealQuantity = 0 then
        Break;
    end;
   if aRealQuantity<0 then
     RaiseException('Nepovedlo se rozdělit mezi ostatní nerorpočítané dílčí protokoly kartu '+
       GetFirstRecordFromSQL(mOS,'select s.Code || '' '' || s.Name from MainInvProtocolRows M inner join StoreCards s on s.id =M.StoreCard_ID where M.ID='''+aRow.GetFieldValueAsString('MIPRow_ID')+''''));
  finally
    mStr.Free;
  end;
end;

procedure AddBatch(mPartProt:TNxCustomBusinessObject; const aMainProtocol_ID:string);
var
  mMPRow,mPartRow,mRowBat: TNxCustomBusinessObject;
  N,M:Integer;
  mStr : TStringList;
  mRowsBat ,mRowsPartBat:  TNxCustomBusinessMonikerCollection;
  mStrBat : TMemoryDataset;
  S,mSQL,mStoreID,mID : string;
  mAdNew:Boolean;
  mOS:TNxCustomObjectSpace;
begin
  mOS := mPartProt.ObjectSpace;
  mStoreID := GetFirstRecordFromSQL(mOS,'select Store_ID from MainInvProtocols where ID='''+aMainProtocol_ID+'''');
  mStr := TStringList.Create;
  try
// Jen karty jen se šarží
    mOS.SQLSelect('select MP.ID from MainInvProtocolRows MP inner join StoreCards SC on SC.ID = MP.StoreCard_ID where  SC.Category = 2 and MP.Parent_ID = '''+aMainProtocol_ID+'''',mStr);
    for N := 0 to mStr.Count - 1 do begin
      mMPRow:= mOs.CreateObject(Class_MainInvProtocolRow);
      try
        mMPRow.Load(mStr.Strings[N],nil);
        mRowsBat := mMPRow.GetLoadedCollectionMonikerForFieldCode(mMPRow.GetFieldCode('Rows'));
        S := '';
        for M := 0 to mRowsBat.Count - 1 do
          S := S+ ',''' + mRowsBat.BusinessObject[M].GetFieldValueAsString('StoreBatch_ID')+ '''';
        if S <> '' then begin
          Delete(S,1,1);
          S := ' and (StoreBatch_ID  not in (' + S +'))'
        end;
        mSQL :=  'Select B.StoreBatch_ID,B.Quantity /U.UnitRate as DocumentedQuantity ,SC.MainUnitCode as MainUnitCode,U.UnitRate as UnitRate '
          +'from StoreSubBatches B inner join StoreCards SC on SC.ID = B.StoreCard_ID inner join StoreUnits U on U.Parent_ID = SC.ID and U.Code= SC.MainUnitCode'
         + ' where  StoreCard_ID = '''+mMPRow.GetFieldValueAsString('StoreCard_ID')
           +''' and Store_ID= '''+mStoreID+''' and Quantity<>0 ' + S;
         mStrBat := TMemoryDataset.Create(nil);
         try
           mOS.SQLSelect2(mSql,mStrBat);
           if mStrBat.Active then mStrBat.First;
           mAdNew:= false;
           while not mStrBat.Eof do begin
             mRowBat:= mRowsBat.AddNewObject;
             mAdNew:=true;
             mRowBat.Prefill;
             mRowBat.SetFieldValueAsString('StoreBatch_ID',mStrBat.FieldByName('StoreBatch_ID').AsString);
             mRowBat.SetFieldValueAsString('QUnit',mStrBat.FieldByName('MainUnitCode').AsString);
             mRowBat.SetFieldValueAsFloat('UnitRate',mStrBat.FieldByName('UnitRate').AsFloat);
             mRowBat.SetFieldValueAsFloat('DocumentedQuantity',mStrBat.FieldByName('DocumentedQuantity').AsFloat * mStrBat.FieldByName('UnitRate').AsFloat);
             mStrBat.Next;
           end;
           if mAdNew then
              mMPRow.Save;
         finally
           mStrBat.Free;
         end;
      finally
        mMPRow.Free;
      end;
    end;
(*
  // Mame doplneny sarze do hl. protokolu tak jeste do dilciho
  // Znovu jen karty jen se šarží
   mStr.Clear;
    mOS.SQLSelect('select MP.ID from MainInvProtocolRows MP inner join StoreCards SC on SC.ID = MP.StoreCard_ID where  SC.Category = 2 and MP.Parent_ID = '''+aMainProtocol_ID+'''',mStr);
    for N := 0 to mStr.Count - 1 do begin
      mMPRow:= mOs.CreateObject(Class_MainInvProtocolRow);
      try
        mMPRow.Load(mStr.Strings[N],nil);
        mRowsBat := mMPRow.GetLoadedCollectionMonikerForFieldCode(mMPRow.GetFieldCode('Rows'));
        mSql := 'select PP.ID from PartialInvProtocolRows PP inner join MainInvProtocolRows MP on MP.ID = PP.MIPRow_ID '
                 +' where PP.Parent_ID = '''+mPartProt.OID+''' and MP.Parent_ID= '''+aMainProtocol_ID+''' and MP.StoreCard_ID= '''+mMPRow.GetFieldValueAsString('StoreCard_ID')+'''';
        mID := GetFirstRecordFromSQL(mOS,mSQL);
        if not NxIsEmptyOID(mID) then begin
          mPartRow := mOS.CreateObject(Class_PartialInvProtocolRow);
          try
            mPartRow.Load(mID,nil);
            mRowsPartBat := mPartRow.GetLoadedCollectionMonikerForFieldCode(mPartRow.GetFieldCode('Rows'));
            //Nejprve si jej vcistime
            for M := 0 to mRowsPartBat.Count - 1 do
              mRowsPartBat.BusinessObject[M].MarkForDelete;
            for M := 0 to mRowsBat.Count - 1 do
              // jen sarze s kladnym stavem a ne doplnovaci
              if (mRowsBat.BusinessObject[M].GetFieldValueAsFloat('UnitDocumentedQuantity')>0) and
                 (Copy(mRowsBat.BusinessObject[M].GetFieldValueAsString('StoreBatch_ID.Name'),1,3)<>'HI_') then begin //ani docasne nedam, ty se doplni pzdeji
                mRowBat:=mRowsPartBat.AddNewObject;
                mRowBat.Prefill;
                mRowBat.SetFieldValueAsString('MIPBatch_ID',mRowsBat.BusinessObject[M].OID);
                mRowBat.SetFieldValueAsString('QUnit',mRowsBat.BusinessObject[M].GetFieldValueAsString('QUnit'));
                mRowBat.SetFieldValueAsFloat('UnitRate',mRowsBat.BusinessObject[M].GetFieldValueAsFloat('UnitRate'));
                mRowBat.SetFieldValueAsFloat('UnitDocumentedQuantity',mRowsBat.BusinessObject[M].GetFieldValueAsFloat('UnitDocumentedQuantity'));
              end;
            mPartRow.Save;
          finally
            mPartRow.Free;
          end;
        end;
      finally
        mMPRow.Free;
      end;
    end;

  *)
  finally
    mStr.Free;
  end;
end;


procedure CompleteBatches(Self:TNxCustomBusinessObject);
var
  N : Integer;
  mOs: TNxCustomObjectSpace;
  mRow: TNxCustomBusinessObject;
  mStr : TStringList;
  mReal:Extended;
  mData : TMemoryDataset;
  mNewBatchID:String;
  mUnitRate:Extended;
begin
  mOS := Self.ObjectSpace;
  AddBatch(Self,Self.GetFieldValueAsString('MainProtocol_ID'));
  mStr := TStringList.Create;
  try
    mOs.SQLSelect('select id from PartialInvProtocolRows where Parent_ID='''+Self.OID+'''',mStr);
    for N := 0 to mStr.Count - 1 do begin
      mRow:= mOS.CreateObject(class_PartialInvProtocolRow);
      try
        mRow.Load(mStr.Strings[N],nil);
        if mRow.GetFieldValueAsInteger('MIPRow_ID.StoreCard_ID.Category') <>2 then begin
           mUnitRate := NxIBStrToFloat(GetFirstRecordFromSQL(mOS,'select UnitRate from StoreUnits SU where Parent_ID= '''+mRow.GetFieldValueAsString('MIPRow_ID.StoreCard_ID')+''' and SU.Code = '''+mRow.GetFieldValueAsString('MIPRow_ID.StoreCard_ID.MainUnitCode')+''''));
           mRow.SetFieldValueAsFloat('RealQuantity',mRow.GetFieldValueAsFloat('X_RealQuantity')*mUnitRate);
        end else begin
          if mRow.GetFieldValueAsFloat('X_RealQuantity') < 0 then begin
           // srovnavaci dilci protokol
             CorectQuantInv(mRow,mRow.GetFieldValueAsFloat('X_RealQuantity'));
           end else begin
            if mRow.GetLoadedCollectionMonikerForFieldCode(mRow.GetFieldCode('Rows')).Count >0 then Continue;// šarže mám již doplněny
            //Nalzene mnozstvi je ponize o srovnavaci protoko
            mReal := mRow.GetFieldValueAsFloat('X_RealQuantity')+NxIBStrToFloat(GetFirstRecordFromSQL(mOS,Format(cSelSumRel,[mStr.Strings[N]])));
            if cfxFloat.GreaterThan3(mReal,0) then begin// načteme si dílčí šarže
              mData :=TMemoryDataset.Create(nil);
              try
                GetSubBatch(Self,mRow.GetFieldValueAsString('MIPRow_ID.StoreCard_ID'),mData);
                if mData.Active then begin
                  mData.First;
                  while cfxFloat.GreaterThan3(mReal,0) and not mData.Eof do begin
                    if mData.FieldByName('quantity').AsFloat> 0 then begin
                      if mReal <= mData.FieldByName('quantity').AsFloat then begin
                         AddBatchRows(mRow,mData.FieldByName('ID').AsString,mReal);
                         mReal:= 0;
                         Break;
                      end else begin
                        AddBatchRows(mRow,mData.FieldByName('ID').AsString,mData.FieldByName('quantity').AsFloat);
                        mReal := mReal - mData.FieldByName('quantity').AsFloat;
                      end;
                    end;
                   mData.Next;
                  end;
                end;
              finally
                mData.Free;
              end;
              if cfxFloat.GreaterThan3(mReal,0) then begin
                // ještě máme víc ks než šarží, musíme ověřit zda neexistuije již fiktivní šarže - tu najdeme nebo si musíme vygenerovat novou šarži
                mNewBatchID := GetNewBatch(mRow);
                AddBatchRows(mRow,mNewBatchID,mReal);
                mReal :=0;
              end;
            end;
          end;
        end;
        mRow.Save;
      finally
        mRow.Free;
      end;
    end;
  finally
    mStr.Free;
  end;
end;


procedure ClearRowsBatches(Self:TNxCustomBusinessObject);
var
  N,M : Integer;
  mOs: TNxCustomObjectSpace;
  mRow,mBatch: TNxCustomBusinessObject;
  mStr,mStrBatch,mStrTmpBatch : TStringList;
  mRowsBatch : TNxCustomBusinessMonikerCollection;
begin
  mOS := self.ObjectSpace;
  mStr := TStringList.Create;
  mStrBatch := TStringList.Create;
  mStrTmpBatch  := TStringList.Create;
  try
    mOS.StartTransaction(taReadCommited);
    try
      mOs.SQLSelect('select id from PartialInvProtocolRows where Parent_ID='''+Self.OID+'''',mStr);
      for N := 0 to mStr.Count - 1 do begin
        mRow:= mOS.CreateObject(class_PartialInvProtocolRow);
        try
          mRow.Load(mStr.Strings[N],nil);
          if mRow.GetFieldValueAsInteger('MIPRow_ID.StoreCard_ID.Category') <>2 then
             mRow.SetFieldValueAsFloat('RealQuantity',0)
          else begin
            DeleteRel(mRow);
            mRowsBatch := mRow.GetLoadedCollectionMonikerForFieldCode(mRow.GetFieldCode('Rows'));
            for N := 0 to mRowsBatch.Count - 1  do
              mRowsBatch.BusinessObject[N].MarkForDelete;
          end;
          mRow.Save;
        finally
          mRow.Free;
        end;
      end;
 // Ještě vyčistíme šarže na hl. inv. protokolu
     mStr.Clear;
     mOs.SQLSelect('select M.id from MainInvProtocolRows M inner join StoreCards S on S.ID = M.storecard_id where s.category =2 and Parent_ID='''+Self.GetFieldValueAsString('MainProtocol_ID')+'''',mStr);
     for N := 0 to mStr.Count - 1 do begin
        mRow:= mOS.CreateObject(Class_MainInvProtocolRow);
        try
           mRow.Load(mStr.Strings[N],nil);
           mRowsBatch := mRow.GetLoadedCollectionMonikerForFieldCode(mRow.GetFieldCode('Rows'));
           for M := 0 to mRowsBatch.Count - 1 do begin
             mStrBatch.Clear;
             mOS.SQLSelect('select PBR.ID from PartialInvProtocolBatches PBR '+
              ' where PBR.MIPBatch_ID ='''+mRowsBatch.BusinessObject[M].OID+'''',mStrBatch);
             if mStrBatch.Count = 0 then begin
                if UpperCase(Copy(mRowsBatch.BusinessObject[M].GetFieldValueAsString('StoreBatch_ID.Name'),1,3))= 'HI_' then
                    mStrTmpBatch.Add(mRowsBatch.BusinessObject[M].GetFieldValueAsString('StoreBatch_ID'));
                mRowsBatch.BusinessObject[M].MarkForDelete;
             end;
           end;
         mRow.Save;
        finally
          mRow.Free;
        end;
     end;
    // Ještě smažeme dočasné šarže
     for N := 0 to mStrTmpBatch.Count - 1 do begin
       mStr.Clear;
       mOS.SQLSelect('select id from StoreSubBatches where StoreBatch_ID='''+mStrTmpBatch.Strings[N]+'''',mStr);
       for M := 0 to mStr.Count - 1 do  begin
         mBatch := mOS.CreateObject(Class_StoreSubBatch);
         try
           mBatch.Load(mStr.Strings[M],nil);
           try
             mBatch.Delete;
           except
             // když nejde smazat
           end;
         finally
           mBatch.Free;
         end;
         mBatch := mOS.CreateObject(Class_StoreBatch);
         try
           mBatch.Load(mStrTmpBatch.Strings[N],nil);
           try
             mBatch.Delete;
           except
            // když nejde smazat
           end;
         finally
           mBatch.Free;
         end;
       end;
     end;
    mOS.Commit;
   except
     mOs.RollBack;
   end;
  finally
    mStr.Free;
    mStrBatch.Free;
    mStrTmpBatch.Free;
  end;

end;

procedure RunTerminalImport(Self : TDynSiteForm; var aNewIDInventoryOverplus,aInventoryShortFall: string);
var
  mFileData : TStringList;
  mPartInvPro: TNxCustomBusinessObject;
  mOs: TNxCustomObjectSpace;
  mStore,mStoreCode: string;
  mRow : Integer;
begin
  mOS := Self.BaseObjectSpace;
  aNewIDInventoryOverplus := '';
  aInventoryShortFall := '';
  if FileExists(cIMPORT_FileName) then
    if not cEmulDebugICS then DeleteFile(cIMPORT_FileName);
  if MyShellExecute(cIMPORT_EXEtoRunBefore) then begin
    WaitUntilFileExist(cIMPORT_FileName, 10000, 1);
    mFileData := TStringList.Create;
    try
      // Načtení exportu ze čtečky
      if GetFileContent(cIMPORT_FileName, mFileData) then begin
        if mFileData.Count > 0 then begin
          mStoreCode :=Trim(Copy(mFileData.Strings[0],72,5));
          if mStoreCode <> '' then
            mStore :=  GetFirstRecordFromSQL(mOS,'select id from stores where hidden=''N'' and Code = '''+ mStoreCode+'''')
          else mStore := '';
          mPartInvPro := Self.CurrentObject;
          try
            mRow := StrToInt(GetFirstRecordFromSQL(mOS,'select count(*) from PartialInvProtocolRows where Parent_ID='''+mPartInvPro.OID+''''));
            if mRow > 0 then begin
              if (Copy(mFileData.Strings[0],1,1) = cDilInv) and  (not mPartInvPro.GetFieldValueAsBoolean('X_MiniInv')) then
                 RaiseException('Nelze importovat mini inventuru do rozpracovaného protokolu, který má nastavení na běžnou inventuru');
              if (Copy(mFileData.Strings[0],1,1) = cHlInv) and  (mPartInvPro.GetFieldValueAsBoolean('X_MiniInv')) then
                 RaiseException('Nelze importovat inventuru do rozpracovaného protokolu, který má nastavení na mini inventuru');
            end;
            if (mStore <> '') and (mStore <> mPartInvPro.GetFieldValueAsString('MainProtocol_ID.Store_Id')) then
              RaiseException('Nesprávný sklad v souboru: ' + GetFirstRecordFromSQL(mOS,'select Name from stores where Id = '''+ mStore+''''));
            if Copy(mFileData.Strings[0],1,1) = cDilInv then begin//Mini
              mPartInvPro.SetFieldValueAsBoolean('X_MiniInv',true);
              mPartInvPro.Save;
              MiniInventura(mPartInvPro,mFileData);
            end else if Copy(mFileData.Strings[0],1,1) = cHlInv then //Hlavní
                      HlavniInventura(mPartInvPro,mFileData)
                       else RaiseException('Nesprávný typ souboru:' + mFileData.Strings[0]);
          finally
            mPartInvPro.Free;
          end;
        end;
        Self.ActiveDataSet.UpdateFields;
        RefreshRowsGrid(Self);
      end else
       MyShowMessage('Soubor ' + cIMPORT_FileName + ' nebyl vytvořen v požadovaném časovém limitu.');
    finally
      mFileData.Free;
    end;
  end;
end;

begin
end.