function GetFirstRecordFromSQL(AOS: TNxCustomObjectSpace; ASQL: String): String;
var
  mSQLRes: TStrings;
begin
  Result := '';
  mSQLRes := TStringList.Create;
  try
    AOS.SQLSelect(ASQL, mSQLRes);
    if mSQLRes.Count > 0 then
      Result := mSQLRes.Strings[0];
  finally
    mSQLRes.Free;
  end;
end;

//dle zadaného data vrátí středisko
function GetPeriodID(OS: TNxCustomObjectSpace; ADate: TDateTime): String;
const
  cSQL = 'select ID from Periods where (%s >= DateFrom$DATE) and (%s < DateTo$DATE)';
var
  mSQL, mDate: String;
begin
  Result := '';
  if (ADate <= 0) then exit;
  mDate := IntToStr(NxFloor(int(Adate)));
  mSQL := Format(cSQL, [mDate, mDate]);
  Result := GetFirstRecordFromSQL(OS, mSQL);
end;

procedure AddStringsToSelDat(AOS : TNxCustomObjectSpace; AStation_ID: String; AValues: TStringList);
// Prida do SelDat hodnoty ze StringListu pod AStation
var
  mStation_ID : String;
  i : Integer;
begin
  mStation_ID := GetFirstRecordFromSQL(AOS, 'Select ID from SelDef where ID = ''' + AStation_ID + '''');
  if NxIsEmptyOID(mStation_ID) then begin
    mStation_ID := AStation_ID;
    AOS.SQLExecute('Insert into SelDef (ID, Station) values ('''+ mStation_ID +''', ''GeneratedByScript'')');
  end;
  For i:=0 to AValues.Count-1 do begin
    AOS.SQLExecute('Insert into SelDat (Sel_ID, Obj_ID) values ('''+ mStation_ID + ''', ''' + AValues.Strings[i] + ''')');
  end;
end;

procedure ClearSelDat(AOS : TNxCustomObjectSpace; AStation_ID: String);
// Smaze ze SelDat hodnoty pod AStation
begin
  AOS.SQLExecute('Delete from SelDef where ID = ''' + AStation_ID + '''');
end;

function StringsToSelDat(AOS : TNxCustomObjectSpace; AValues: TStringList): string;
var
  mStation : Int64;
  mStation_ID : string;
  mInTransaction: Boolean;
begin
  Result := '';
  mStation := DateTimeToUnix(Now);
  mStation_ID := CFxOID.ToOID(mStation, '01');

  ClearSelDat(AOS, mStation_ID);
  //je zapnuta transakce
  //pokud neni tak si ji zapnu
  OSStartTransaction(AOS, mInTransaction);
  try
    AddStringsToSelDat(AOS, mStation_ID, AValues);
    Result := mStation_ID;
    //commit
    OSCommit(AOS, mInTransaction);
  except
    OSRollBack(AOS, mInTransaction);
    RaiseException(ExceptionMessage);
  end;
end;

procedure OSStartTransaction(var AOS: TNxCustomObjectSpace; var AInTransaction: boolean);
begin
  //je zapnuta transakce
  AInTransaction := AOS.InTransaction;
  //pokud neni tak si ji zapnu
  if not AInTransaction then
    AOS.StartTransaction(taReadCommited);
end;

procedure OSCommit(var AOS: TNxCustomObjectSpace; const AInTransaction: boolean);
begin
  if not AInTransaction then
    AOS.Commit;
end;

procedure OSRollBack(var AOS: TNxCustomObjectSpace; const AInTransaction: boolean);
begin
  if not AInTransaction then
    AOS.RollBack;
end;

procedure DeleteDefRollData(AOS: TNxCustomObjectSpace; const ACLSID: string; AAndWhere: string = '');
const
  cSQL = 'delete from DefRollData where CLSID = %s and %s';
var
  mSQL, mAndWhere: string;
  mInTransaction: Boolean;
begin
  if AAndWhere = '' then
    mAndWhere := '(1=1)'
  else
    mAndWhere := AAndWhere;

  mSQL := Format(cSQL, [QuotedStr(ACLSID), mAndWhere]);
  OSStartTransaction(AOS, mInTransaction);
  try
    AOS.SQLExecute(mSQL);
    OSCommit(AOS, mInTransaction);
  except
    OSRollBack(AOS, mInTransaction);
  end;
end;


function NewRelation(const aOS: TNxCustomObjectSpace;const aRelType : integer; const aLeftID, aRightID : string):boolean;
var mBORel : TNxCustomBusinessObject;
var mList : TStringList;
begin
  result := false;
  mList := TStringList.Create();
  try
    aOS.SQLSelect('select ID from relations where rel_def ='+IntToStr(aRelType)+
           ' and LEFTSIDE_ID = '+QuotedStr(ALeftId)+
           ' and RIGHTSIDE_ID = '+QuotedStr(aRightID),mList);
    If (mList.Count = 0) then
    begin
      mBORel := aOS.CreateObject('01ZXNDSYDVD135SA02K2CQM5AW');
      try
        mBORel.New;
        mBORel.Prefill;
        mBORel.SetFieldValueAsInteger('REL_DEF',aRelType);
        mBORel.SetFieldValueAsString('LEFTSIDE_ID', aLeftID);
        mBORel.SetFieldValueAsString('RIGHTSIDE_ID', aRightID);
        mBORel.Save;
        result := true;
      finally
        mBORel.Free;
        mBORel := nil;
      end;
    end
    else
      result := true;
  finally
    mList.Free;
    mList := nil;
  end;
end;



begin
end.