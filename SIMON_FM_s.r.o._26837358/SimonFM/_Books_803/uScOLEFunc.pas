uses
  '_Books_803.uScFunc';

// Nalezení období k datumu
function FindPeriodIDByDate(AOLE: Variant; ADate: TDateTime): string;
var
  mDQ: Variant;
  mRS: Variant;
begin
  Result := '';
  ADate := Trunc(ADate);
  try
    mDQ := AOLE.CreateCommand('Period');
    mRS := mDQ.RowsetByName('Main');
    mDQ.ConstraintByID('DateFrom').UsedKind := 2;
    mDQ.ConstraintByID('DateFrom').Value := '0';
    mDQ.ConstraintByID('DateFrom').ValueHigh := FloatToStr(ADate);
    mDQ.ConstraintByID('DateTo').UsedKind := 2;
    mDQ.ConstraintByID('DateTo').Value := FloatToStr(ADate+1);
    mDQ.ConstraintByID('DateTo').ValueHigh := '100000';
    mRS.UsedFields := 'ID';
    mRS.Used := True;
    mDQ.Execute;
    if not mRS.EOF then
      Result := mRS.Data.Item[0];
  finally
  end;
end;

// Čtení fieldu přes SQL
function GetFieldByOLE(AOLE: Variant; AValue: Variant; ASrcFld, ATable, ADestFld: string;
  ADefault: Variant; AWhere: string): Variant;
var
  s, mSQL: string;
  mRS: Variant; // Rowset
begin
  case VarType(AValue) of
    varEmpty, varNull: s := '''''';
    varInteger, varDouble, varDate, varSmallint, varByte: s := VarToStr(AValue);
    varString, varVariant, varOleStr: s := '''' + VarToStr(AValue) + '''';
    varBoolean: if AValue then s := '''A''' else s := '''N''';
  end;
  mSQL := 'select ' + ADestFld + ' from ' + ATable + ' where ' + ASrcFld + ' = ' + s;
  if AWhere <> '' then
    mSQL := mSQL + ' and ' + AWhere;
  mRS := AOLE.SQLSelectAsRowset(mSQL);
  if not mRS.EOF then begin
    case VarType(ADefault) of
      varEmpty, varNull: Result := ADefault;
      varInteger, varSmallint, varByte: Result := mRS.Data.Item[0];
      varDouble, varDate: Result := mRS.Data.Item[0];
      varString, varOleStr: Result := mRS.Data.Item[0];
      varBoolean: Result := UpperCase(mRS.Data.Item[0]) = 'A';
      else Result := mRS.Data.Item[0];
    end;
    if (VarType(Result) = varString) or (VarType(Result) = varOleStr) then begin
      s := Result;
      if (s <> '') and (s[1] = '"') and (s[Length(s)] = '"') then
        Result := Copy(s, 2, Length(s)-2);
    end;
  end
  else
    Result := ADefault;
end;

// Zápis fieldu přes SQL podle OID
procedure SetFieldByOLE(AOLE: Variant; AFld, AOID, ATable: string; AValue: Variant);
var
  s, mSQL: string;
begin
  case VarType(AValue) of
    varEmpty, varNull: s := '''''';
    varInteger, varDouble, varDate, varSmallint, varByte: s := VarToStr(AValue);
    varString, varVariant, varOleStr: s := '''' + VarToStr(AValue) + '''';
    varBoolean: if AValue then s := '''A''' else s := '''N''';
  end;
  mSQL := 'update ' + ATable + ' set ' + AFld + ' = ' + s + ' where ID = ''' + AOID + '''';
  AOLE.SQLExecute(mSQL);
end;

function SingleSQL(AOLE: Variant; ASQL: string): string;
var
  _ss: Variant;
begin
  _ss := AOLE.CreateStrings;
  AOLE.SQLSelect(ASQL, _ss);
  if _ss.Count > 0 then
    Result := TrimQuote(_ss.Strings[0])
  else
    Result := '';
end;

function SingleSQLII(AObjectSpace: TNxCustomObjectSpace; ASQL: string): string;
var
  ss: TStringList;
begin
  ss := TStringList.Create;
  try
    AObjectSpace.SQLSelect(ASQL, ss);
    if ss.Count > 0 then
      Result := TrimQuote(ss.Strings[0])
    else
      Result := '';
  finally
    ss.Free;
  end;
end;

// Vrací DisplayName dokladu
function GetDocDisplayNameByID(AOLE: Variant; AID, ATable: string): string;
var
  _ss: Variant;
begin
  _ss := AOLE.CreateStrings;
  AOLE.SQLSelect(
    'select DQ.Code || ''-'' || A.OrdNumber || ''/'' || P.Code from ' + ATable + ' A ' +
    '  left join DocQueues DQ on DQ.ID = A.DocQueue_ID ' +
    '  left join Periods P on P.ID = A.Period_ID ' +
    ' where A.ID = ''' + AID + '''', _ss);
  if _ss.Count > 0 then
    Result := _ss.Strings[0]
  else
    Result := '';
end;

function GetDocDisplayNameByID2(AID, ATable: string): string;
var
  _ss: Variant;
  mOLE: Variant;
begin
  mOLE := GetAbraOLEApplication;
  _ss := mOLE.CreateStrings;
  mOLE.SQLSelect(
    'select DQ.Code || ''-'' || A.OrdNumber || ''/'' || P.Code from ' + ATable + ' A ' +
    '  left join DocQueues DQ on DQ.ID = A.DocQueue_ID ' +
    '  left join Periods P on P.ID = A.Period_ID ' +
    ' where A.ID = ''' + AID + '''', _ss);
  if _ss.Count > 0 then
    Result := _ss.Strings[0]
  else
    Result := '';
end;

function GetIDByDocDisplayName(AOLE: Variant; ADDN, ATable: string): string;
var
  mDocQueue, mOrder, mPeriod: string;
  _ss: Variant;
begin
  mOrder := '';
  mPeriod := '';
  if Pos('-', ADDN) = 0 then
    mDocQueue := ADDN
  else begin
    mDocQueue := Copy(ADDN, 1, Pos('-', ADDN)-1);
    if Pos('/', ADDN) = 0 then
      mOrder := Copy(ADDN, Pos('-', ADDN)+1, 20)
    else begin
      mOrder := Copy(ADDN, Pos('-', ADDN)+1, Pos('/', ADDN)-Pos('-', ADDN)-1);
      mPeriod := Copy(ADDN, Pos('/', ADDN)+1, 20);
    end;
  end;
  mDocQueue := UpperCase(mDocQueue);
  mPeriod := UpperCase(mPeriod);
  _ss := AOLE.CreateStrings;
  AOLE.SQLSelect(
    'select A.ID from ' + ATable + ' A ' +
    '  join DocQueues DQ on DQ.ID = A.DocQueue_ID ' +
    '  join Periods P on P.ID = A.Period_ID ' +
    'where Upper(DQ.Code) like ''' + mDocQueue + ''' and Upper(P.Code) like ''' + mPeriod + ''' and CAST(A.OrdNumber as VarChar(10)) like ''' + mOrder + ''''
    , _ss);
  if _ss.Count > 0 then
    Result := _ss.Strings[0]
  else
    Result := '';
end;

function GetIDByVarSymbol(AOLE: Variant; AVarSymbol, ATable: string): string;
var
  _ss: Variant;
begin
  _ss := AOLE.CreateStrings;
  AOLE.SQLSelect('select ID from ' + ATable + ' where VarSymbol = ''' + AVarSymbol + '''', _ss);
  if _ss.Count > 0 then
    Result := _ss.Strings[0]
  else
    Result := '';
end;

function ExistsUserField(AClass, AFldName: String): Boolean;
var
  mID: String;
  mFldName: string;
  mOLE: Variant;
  mIsExtra: Boolean;
  a: Char;
begin
  Result := False;
  mFldName := AFldName;
  mIsExtra := UpperCase(Copy(mFldName, 1, 2)) = 'X_';
  if mIsExtra then
    a := 'A'
  else
    a := 'N';
  if (UpperCase(Copy(mFldName, 1, 2)) = 'X_') or (UpperCase(Copy(mFldName, 1, 2)) = 'U_') then
    mFldName := Copy(mFldName, 3, 255);
  mOLE := GetAbraOLEApplication;
  mID := GetFieldByOLE(mOLE, AClass, 'CLSID', 'UserFieldDefs', 'ID', '', '');
  mID := SingleSQL(mOLE,
    'select AA.ID from UserFieldDefs2 AA ' +
    '  join UserFieldDefs A on A.ID = AA.Parent_ID and A.CLSID = ''' + AClass + ''' ' +
    'where Upper(AA.FieldName) = ''' + UpperCase(mFldName) + ''' and ExtraField = ''' + a + '''');
  Result := not NxIsEmptyOID(mID);
end;

// Případné vytvoření def.fieldu, pokud neexistuje
// AClass - clsid objektu, ke kterému patří def.field
// AFldName - název def.fieldu
// ADataType - typ def.fieldu
// AFldDisplayLabel - zobrazovaný název def.fieldu
// AFldSize - velikost def.fieldu (pouze pro string)
// AFldPrecision - počet desetinných míst (pouze pro necelá čísla)
// ARollCLSID - clsid číselníku (číselníková položka)
// ATextField - název fieldu (číselníková položka)
// AReadOnly - field bude pouze pro čtení
// AEnumeration - výčet hodnot (typ celé číslo) nebo také parametry číselníku (typ číselník)
// AUseInDynSQL - používat v podmínkách
function GetOrCreateField(ASite_or_ObjectSpace: TObject; AClass, AFldName: String; ADataType: TNxDataType;
  AExtra: Boolean; AFldDisplayLabel: string = ''; AFldSize, AFldPrecision: Integer = 0;
  ARollCLSID, ATextField: string = ''; AReadOnly: Boolean = False; AEnumeration: String = '';
  AUseInDynSQL: Boolean = True; AUpdateFld: Boolean = True): Boolean;
  
  // Řešení je jen částečné, pokud by nevyhovovalo, lze doplnit
  function iIsDifferent(ARow: TNxCustomBusinessObject): Boolean;
  begin
    Result :=
      (ARow.GetFieldValueAsString('FieldDisplayLabel') <> Copy(AFldDisplayLabel, 1, 30)) or
      (ARow.GetFieldValueAsBoolean('IsReadOnly') <> AReadOnly) or
      (ARow.GetFieldValueAsBoolean('UseInDynSQL') <> AUseInDynSQL) or
      (ARow.GetFieldValueAsString('Enumeration') <> AEnumeration) or
      (ARow.GetFieldValueAsString('TextField') <> ATextField);
  end;
  
  procedure iSetDifferent(ARow: TNxCustomBusinessObject);
  begin
    ARow.SetFieldValueAsString('FieldDisplayLabel', Copy(AFldDisplayLabel, 1, 30));
    ARow.SetFieldValueAsBoolean('IsReadOnly', AReadOnly);
    ARow.SetFieldValueAsBoolean('UseInDynSQL', AUseInDynSQL);
    ARow.SetFieldValueAsString('Enumeration', AEnumeration);
    ARow.SetFieldValueAsString('TextField', ATextField);
  end;

var
  mId: String;
  mHeader: TNxCustomBusinessObject;
  mRow: TNxCustomBusinessObject;
  mRows: TNxCustomBusinessMonikerCollection;
  i: Integer;
  mAddNewFld, mUpdateFld: Boolean;
  mFldName: string;
  mClass, mData: Variant;
  mOLE: Variant;
  mOS: TNxCustomObjectSpace;
begin
  Result := False;
  if ASite_or_ObjectSpace is TSiteForm then
    if not TestRegularSite(TSiteForm(ASite_or_ObjectSpace), 'GetOrCreateExtraField') then
      Exit
    else
      mOS := TSiteForm(ASite_or_ObjectSpace).BaseObjectSpace
  else
    mOS := TNxCustomObjectSpace(ASite_or_ObjectSpace);
  if AFldDisplayLabel = '' then
    AFldDisplayLabel := AFldName;
  mFldName := AFldName;
  if (UpperCase(Copy(mFldName, 1, 2)) = 'X_') or (UpperCase(Copy(mFldName, 1, 2)) = 'U_') then
    mFldName := Copy(mFldName, 3, 255);
  mHeader := mOS.CreateObject('W1MZBIJR3VF13JXR00KEZYD5AW'); //UserFieldDef
  mOLE := GetAbraOLEApplication;
  mID := GetFieldByOLE(mOLE, AClass, 'CLSID', 'UserFieldDefs', 'ID', '', '');
  mAddNewFld := True;
  mUpdateFld := False;
  if mID = '' then begin
    mHeader.New;
    mHeader.Prefill;
    mHeader.SetFieldValueAsString('CLSID', AClass);
    mRows := mHeader.GetLoadedCollectionMonikerForFieldCode(mHeader.GetFieldCode('Rows'));
  end
  else begin
    mHeader.Load(mID, nil);
    mRows := mHeader.GetLoadedCollectionMonikerForFieldCode(mHeader.GetFieldCode('Rows'));
    for i:=0 to mRows.Count -1 do begin
      mRow := mRows.BusinessObject(i);
      if SameText(mRow.GetFieldValueAsString('FieldName'), mFldName) then begin
        mAddNewFld := False;
        if AUpdateFld and iIsDifferent(mRow) then begin
          iSetDifferent(mRow);
          mUpdateFld := True;
          // nelze - padá na chybu, zkusím znovu
          mHeader.Save;
          Result := True;
        end;
        Break;
      end;
    end;
  end;
  if mAddNewFld then begin
    mRow := mRows.AddNewObject;
    mRow.Prefill;
    mRow.SetFieldValueAsString('FieldName', mFldName);
    mRow.SetFieldValueAsBoolean('ExtraField', AExtra);
    mRow.SetFieldValueAsInteger('FieldDataType', ADataType);
    if ADataType = dtString then
      mRow.SetFieldValueAsInteger('FieldSize', AFldSize);
    mRow.SetFieldValueAsInteger('FieldPrecision', AFldPrecision);
    mRow.SetFieldValueAsString('FieldDisplayLabel', Copy(AFldDisplayLabel, 1, 30));
    mRow.SetFieldValueAsBoolean('IsReadOnly', AReadOnly);
    mRow.SetFieldValueAsBoolean('UseInDynSQL', AUseInDynSQL);
    if AEnumeration <> '' then begin
      mRow.SetFieldValueAsString('Enumeration', AEnumeration);
      mRow.SetFieldValueAsInteger('EditMethod', 1); // skrytý combobox
    end;
    if ARollCLSID <> '' then begin
      mRow.SetFieldValueAsString('FieldRollCLSID', ARollCLSID);
//      mRow.SetFieldValueAsString('FieldCLSID', AFieldCLSID); // CLS BO - není potřeba, doplní se podle rollu
      mRow.SetFieldValueAsString('TextField', ATextField); // Tohle zdá se nefunguje
      mRow.SetFieldValueAsInteger('EditMethod', 4);
    end;
    mHeader.Save;
    //  mHeader.CorrectTableStructure(mClass); - nefunguje
    mClass := mOLE.CreateObject('@UserFieldDef');
    mClass.CorrectTableStructure(AClass);
    Result := True;
  end;
end;

function GetActualExchangeRate(ACurrency_ID: string): Extended;
var
  mRS: Variant; // Rowset
  mOLE: Variant;
begin
  mOLE := AbraOLE;
  mRS := mOLE.SQLSelectAsRowset(
    'select ER2.CurrRate from ExchangeRates2 ER2 ' +
    '  join ExchangeRates ER on ER.ID = ER2.Parent_ID ' +
    'where ER.Currency_ID = ''' + ACurrency_ID + ''' and ER2.Date$DATE <= ' + FloatToStr(Date) + ' ' +
    'order by ER2.Date$DATE descending');
  if mRS.EOF then
    Result := 1
  else
    Result := mRS.Data.Item[0];
end;

function GetSecurityRightObject(APersistClsID, ABO_ID, ARole_ID: string;
  var AGrantedMask: Integer; var ADeniedMask: Integer): Boolean;
var
  mRS: Variant; // Rowset
  mOLE: Variant;
begin
  mOLE := AbraOLE;
  mRS := mOLE.SQLSelectAsRowset(
    'select GrantedMask, DeniedMask from SecurityObjectRights ' +
    'where ClassID = ''' + APersistClsID + ''' and ProgID = ''' + ABO_ID + ''' and ' +
    '  Role_ID = ''' + ARole_ID + '''');
  if not mRS.EOF then begin
    Result := True;
    AGrantedMask := mRS.Data.ValueByName['GrantedMask'];
    ADeniedMask := mRS.Data.ValueByName['DeniedMask'];
  end
  else begin
    AGrantedMask := 0;
    ADeniedMask := 0;
    Result := False;
  end;
end;

function GetSecurityRightObjectForActiveUser(APersistClsID, ABO_ID: string;
  var AGrantedMask: Integer; var ADeniedMask: Integer): Boolean;
var
  mRS: Variant; // Rowset
  mIDUser: string;
  mGrantedMask, mDeniedMask: Integer;
  mOLE: Variant;
begin
  mOLE := AbraOLE;
  mIDUser := NxGetActualUserID(ObjectSpace);
  mRS := mOLE.SQLSelectAsRowset(
    'select Role_ID from SecurityUserRoleLinks ' +
    'where User_ID = ''' + mIDUser + '''');
  AGrantedMask := 0;
  ADeniedMask := 0;
  while not mRS.EOF do begin
    if GetSecurityRightObject(APersistClsID, ABO_ID, mRS.Data.ValueByName['Role_ID'], mGrantedMask, mDeniedMask) then begin
      AGrantedMask := AGrantedMask or mGrantedMask;
      ADeniedMask := ADeniedMask or mDeniedMask;
    end;
    mRS.Next;
  end;
end;

// vrátí pro chráněný objekt informaci, zda je povoleno právo zobrazit nebo ne
function GetSecurityRightObjectForActiveUser_Show(APersistClsID, ABO_ID: string): Boolean;
var
  mGrantedMask, mDeniedMask: Integer;
begin
  Result := False;
  if GetSecurityRightObjectForActiveUser(APersistClsID, ABO_ID, mGrantedMask, mDeniedMask) then begin
    mGrantedMask := mGrantedMask and 1;
    mDeniedMask := mDeniedMask and 1;
    Result := (mGrantedMask = 1) and (mDeniedMask = 0);
  end;
end;

// vrátí pro chráněný objekt informaci, zda je povoleno právo použít nebo ne
function GetSecurityRightObjectForActiveUser_Use(APersistClsID, ABO_ID: string): Boolean;
var
  mGrantedMask, mDeniedMask: Integer;
begin
  Result := False;
  if GetSecurityRightObjectForActiveUser(APersistClsID, ABO_ID, mGrantedMask, mDeniedMask) then begin
    mGrantedMask := mGrantedMask and 2;
    mDeniedMask := mDeniedMask and 2;
    Result := (mGrantedMask = 2) and (mDeniedMask = 0);
  end;
end;

procedure SetSecurityRightObject(APersistClsID, ABO_ID, ARole_ID: string;
  AGrantedMask, ADeniedMask: Integer);
var
  mRS: Variant; // Rowset
  s: String;
  mOLE: Variant;
begin
  mOLE := AbraOLE;
  mRS := mOLE.SQLSelectAsRowset(
    'select 0 from SecurityObjectRights ' +
    'where ClassID = ''' + APersistClsID + ''' and ProgID = ''' + ABO_ID + ''' and ' +
    '  Role_ID = ''' + ARole_ID + '''');
  if not mRS.Eof then
    mOLE.SQLExecute(
      'update SecurityObjectRights set GrantedMask = ' + IntToStr(AGrantedMask) +
      ', DeniedMask = ' + IntToStr(ADeniedMask) + ' ' +
      'where ClassID = ''' + APersistClsID + ''' and ProgID = ''' + ABO_ID + ''' and ' +
      '  Role_ID = ''' + ARole_ID + '''')
  else
    mOLE.SQLExecute(
      'insert into SecurityObjectRights (ClassID, ProgID, Role_ID, GrantedMask, DeniedMask) ' +
      '  values (''' + APersistClsID + ''', ''' + ABO_ID + ''', ''' + ARole_ID + ''', ' +
        IntToStr(AGrantedMask) + ', ' + IntToStr(ADeniedMask) + ')');
end;

// očekává se aspoň jedna role u uživatele, nastavuje se to ve všech rolích uživatele
procedure SetSecurityRightObjectForActiveUser(APersistClsID, ABO_ID: string;
  AGrantedMask, ADeniedMask: Integer);
var
  mRS: Variant; // Rowset
  mIDUser: string;
  mGrantedMask, mDeniedMask: Integer;
  mOLE: Variant;
begin
  mOLE := AbraOLE;
  mIDUser := NxGetActualUserID(ObjectSpace);
  mRS := mOLE.SQLSelectAsRowset(
    'select Role_ID from SecurityUserRoleLinks ' +
    'where User_ID = ''' + mIDUser + '''');
  while not mRS.EOF do begin
    SetSecurityRightObject(APersistClsID, ABO_ID, mRS.Data.ValueByName['Role_ID'], AGrantedMask, ADeniedMask);
    mRS.Next;
  end;
end;

// nastaví pro chráněný objekt právo zobrazit
procedure SetSecurityRightObjectForActiveUser_Show(APersistClsID, ABO_ID: string; ARight: Boolean);
var
  mGrantedMask, mDeniedMask: Integer;
begin
  GetSecurityRightObjectForActiveUser(APersistClsID, ABO_ID, mGrantedMask, mDeniedMask);
  if ARight then begin
    mGrantedMask := mGrantedMask or 1;
    mDeniedMask := mDeniedMask and 2;
  end
  else begin
    mGrantedMask := mGrantedMask and 2;
    mDeniedMask := mDeniedMask or 1;
  end;
  SetSecurityRightObjectForActiveUser(APersistClsID, ABO_ID, mGrantedMask, mDeniedMask);
end;

// vrátí pro chráněný objekt informaci, zda je povoleno právo použít nebo ne
procedure SetSecurityRightObjectForActiveUser_Use(APersistClsID, ABO_ID: string; ARight: Boolean);
var
  mGrantedMask, mDeniedMask: Integer;
begin
  GetSecurityRightObjectForActiveUser(APersistClsID, ABO_ID, mGrantedMask, mDeniedMask);
  if ARight then begin
    mGrantedMask := mGrantedMask or 2;
    mDeniedMask := mDeniedMask and 1;
  end
  else begin
    mGrantedMask := mGrantedMask and 1;
    mDeniedMask := mDeniedMask or 2;
  end;
  SetSecurityRightObjectForActiveUser(APersistClsID, ABO_ID, mGrantedMask, mDeniedMask);
end;

//vrátí seznam ID chráněných objektů podle třídy, které má aktuální uživatel povoleny pouze pro prohlížení
//výsledek je jako text ve stringlistu
function GetSecurityAllowedOIDForActiveUser_OnlyShow(APersistClsID: string): string;
var
  mRS: Variant; // Rowset
  mOLE: Variant;
  mGrantedMask, mDeniedMask: Integer;
  mIDUser: string;
begin
  mOLE := AbraOLE;
  mIDUser := mOLE.ActiveUser;
  mRS := mOLE.SQLSelectAsRowset(
    'select A.ProgID from SecurityObjectRights A ' +
    'where A.ClassID = ''' + APersistClsID + ''' and ' +
    '  A.GrantedMask = 1 and A.DeniedMask = 0 and ' +
    '  A.Role_ID in (select X.Role_ID from SecurityUserRoleLinks X ' +
    '              where X.User_ID = ''' + mIDUser + ''')');
  Result := '';
  while not mRS.EOF do begin
    Result := Result + mRS.Data.ValueByName['ProgID'] + #13#10;
    mRS.Next;
  end
end;

function IsExtraField(var AFieldName: string): string;
var
  s: string;
begin
  Result := '%';
  s := Copy(AFieldName, 1, 2);
  if s  = 'X_' then
    Result := 'A';
  if s  = 'U_' then
    Result := 'N';
  if Result <> '%' then
    Delete(AFieldName, 1, 2);
end;

function CodeByNameDefField(AOLE: Variant; ABusinessCLSID, ANameDefField: string): Integer;
var
  _ss: Variant;
  mExtraF: string;
begin
  mExtraF := IsExtraField(ANameDefField);
  _ss := AOLE.CreateStrings;
  AOLE.SQLSelect(
    'select UFD2.FieldCode from UserFieldDefs2 UFD2 ' +
    '  left join UserFieldDefs UFD on UFD.CLSID = ''' + ABusinessCLSID + '''' +
    'where UFD2.Parent_ID = UFD.ID and UFD2.FieldName = ''' + ANameDefField + ''' and UFD2.ExtraField like ''' + mExtraF + '''', _ss);
  if _ss.Count > 0 then
    Result := StrToInt(_ss.Strings[0])
  else
    Result := 0;
end;

//Změna definovatelné položky přes OLE
function SetValueDefField(ABusinessCLSID, ANameDefField, AOIDRec: string;
  AValue: Variant; ATable: string): Boolean;
var
  mValue: string;
  mCode: Integer;
  mExtraF: string;
  mNameF: string;
  mRS: Variant;
  mOLE: Variant;
begin
  mOLE := AbraOLE;
  Result := False;
  mNameF := ANameDefField;
  mExtraF := IsExtraField(mNameF);
  case VarType(AValue) of
    varEmpty, varNull: mValue := '';
    varInteger, varSmallint, varShortInt: mValue := IntToStr(AValue);
    varBoolean: if AValue then mValue := 'A' else mValue := 'N';
    varDouble, varCurrency, varDate: mValue := FloatToStr(AValue);
    else mValue := AValue;
  end;
  if mExtraF = 'A' then begin
    if (VarType(AValue) = varString) or (VarType(AValue) = varBoolean) or (VarType(AValue) = varOLEStr) then
      mValue := '''' + mValue + '''';
    mOLE.SQLExecute('update ' + ATable + ' set ' + ANameDefField + '=' + mValue + ' where ID=''' + AOIDRec + '''');
    Exit;
  end;
  mRS := mOLE.SQLSelectAsRowset(
    'select UD.StringFieldValue, UFD2.FieldCode from UserData UD ' +
    '  join UserFieldDefs UFD on UFD.CLSID = ''' + ABusinessCLSID + '''' +
    '  join UserFieldDefs2 UFD2 on UFD2.Parent_ID = UFD.ID and ' +
    '    UFD2.FieldName = ''' + mNameF + ''' and UFD2.ExtraField like ''' + mExtraF + '''' +
    'where UD.CLSID = ''' + ABusinessCLSID + ''' and UD.ID = ''' + AOIDRec + ''' and ' +
    '  UD.FieldCode = UFD2.FieldCode');
  if not mRS.EOF then
    if mValue <> mRS.Data.ValueByName['StringFieldValue'] then begin
      mOLE.SQLExecute(
        'update UserData UD set UD.StringFieldValue = ''' + mValue + ''' ' +
        'where UD.CLSID = ''' + ABusinessCLSID + ''' and UD.ID = ''' + AOIDRec + ''' and ' +
        '  UD.FieldCode = ' + IntToStr(mRS.Data.ValueByName['FieldCode']));
      Result := True;
    end
    else
  else begin
    mCode := CodeByNameDefField(mOLE, ABusinessCLSID, ANameDefField);
    if (mCode <> 0) and (mValue <> '') then begin
      mOLE.SQLExecute('insert into UserData (CLSID, FieldCode, ID, StringFieldValue) ' +
        'Values (''' + ABusinessCLSID + ''', ' + IntToStr(mCode) + ', ''' + AOIDRec + ''', ''' + mValue + ''')');
      Result := True;
    end;
  end;
end;

function IsSupervisorActiveUser(AObjectSpace: TNxCustomObjectSpace): Boolean;
var
  mIDUser: string;
  ss: TStringList;
begin
  Result := False;
  ss := TStringList.Create;
  try
    mIDUser := NxGetActualUserID(AObjectSpace);
    AObjectSpace.SQLSelect(
      'select SURL.Role_ID from SecurityUserRoleLinks SURL ' +
      '  join SecurityPrivilegeRights SPR on SPR.Role_ID = SURL.Role_ID and ClassID = ''G1TDNZSKTVCL33N2010DELDFKK''' + //supervizor
      'where SURL.User_ID = ''' + mIDUser + '''', ss);
    Result := ss.Count > 0;
  finally
    ss.Free;
  end;
end;

function SQLValue(ASQL: string; ADefault: Variant): Variant;
var
  mOLE: Variant;
  s: string;
  mRS: Variant;
begin
  mOLE := GetAbraOLEApplication;
  mRS := mOLE.SQLSelectAsRowset(ASQL);
  if not mRS.EOF then begin
    case VarType(ADefault) of
      varEmpty, varNull: Result := ADefault;
      varInteger, varSmallint, varByte: Result := mRS.Data.Item[0];
      varDouble, varDate: Result := mRS.Data.Item[0];
      varString, varOleStr: Result := mRS.Data.Item[0];
      varBoolean: Result := UpperCase(mRS.Data.Item[0]) = 'A';
      else Result := mRS.Data.Item[0];
    end;
    if (VarType(Result) = varString) or (VarType(Result) = varOleStr) then begin
      s := Result;
      if (s <> '') and (s[1] = '"') and (s[Length(s)] = '"') then
        Result := Copy(s, 2, Length(s)-2);
    end;
  end
  else
    Result := ADefault;
end;

begin
end.
