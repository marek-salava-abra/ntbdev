const
  cNullOID = '0000000000';
  cInDebug = True;
  cUseDebugger = True;
  cAppName = 'abra.lubi.ImportAlbertina'; // schvalne si to nechavam tady - knihovnu budu davat primo do kazdeho skriptu ne zvlast

  //cCrLf = Chr(13) + Chr(10);
  cCrLf = #13#10;

////////////////////////////////////////////////////////////////////////////////
// LUBI pomocne funkce
////////////////////////////////////////////////////////////////////////////////

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

function CorrectEmail(AEmailLine: string): string;
var
  mEmail, mResString, mEmailLine: string;
begin
  ShowDebugMessage('CorrectEmail - vstup: ' + AEmailLine);
  Result := '';
  mResString := '';
  mEmailLine := AEmailLine;
  while mEmailLine <> '' do begin
    mEmail := NxToken(mEmailLine, ',');
    if NxIsValidEMailPrecise(mEmail) then begin
      if mResString = '' then
        mResString := mEmail
      else
        mResString := mResString + ',' + mEmail;
    end;
  end;
  Result := mResString;
  ShowDebugMessage('CorrectEmail - result: ' + Result);
end;

function CdPosEx(const SubStr, S: string; Offset: Cardinal = 1): Integer;
var
  I,X: Integer;
  Len, LenSubStr: Integer;
begin
  if Offset = 1 then
    Result := Pos(SubStr, S)
  else
  begin
    I := Offset;
    LenSubStr := Length(SubStr);
    Len := Length(S) - LenSubStr + 1;
    while I <= Len do
    begin
      if S[I] = SubStr[1] then
      begin
        X := 1;
        while (X < LenSubStr) and (S[I + X] = SubStr[X + 1]) do
          Inc(X);
        if (X = LenSubStr) then
        begin
          Result := I;
          exit;
        end;
      end;
      Inc(I);
    end;
    Result := 0;
  end;
end;

{** Pozice znaku zleva. Vrátí pozici n-teho výskytu znaku SubStr v
    řetězci Str zleva.}
function NxMultiAt(const Str: string; SubStr: Char; Index: integer): Integer;
var
  mCount: integer;
begin
  mCount := 0;
  Result := 0;
  if (NxCharCount(SubStr, Str) >= Index) then begin
    Result := 1;
    repeat
      Result := CdPosEx(SubStr, Str, Result + 1);
      Inc(mCount);
    until mCount = Index;
  end;
end;

{** Vrátí, zda předaný řetězec je platná e-mailová adresa. Kontroluje se více parametrů než u NxIsValidEMail}
function NxIsValidEMailPrecise(const AStr: string): Boolean;
var
  mText: string;
  mPosition: integer;
begin
  // retezec obshauje @
  Result := (Pos('@', AStr) > 0); // DoNotLocalize
  if Result then begin
    // test zda v retezci je jen jeden @
    mPosition := NxMultiAt(AStr, '@', 2); // DoNotLocalize
    Result := mPosition = 0;
  end;
  if Result then
    // musi byt minimalne ve formatu x@z.cz
    Result := Length(AStr) >= 6;
  if Result then begin
    // retezec neobsahuje diakritiku
    mText := NxRemoveDiacritics(AStr);
    Result := mText = AStr;
  end;
  if Result then
    // retezec obshauje .
    Result := (Pos('.', AStr) > 0); // DoNotLocalize
  // Proč nesmí být doména cy
  {if Result then begin
    // nesmi byt domena cy
    mText := AStr;
    mSuffix := NxTokenR(mText, '.'); // DoNotLocalize
    Result := mSuffix <> 'cy'; // DoNotLocalize
  end;}
end;

function ReplaceApostrophes(AValue: string): string;
begin
  Result := NxSearchReplace(AValue, '''', '''''', [srAll]);
end;

procedure AddButton(ASite: TSiteForm; AShowControl, AShowMenuItem: Boolean; ACaption, AHint, ACategory: String; AOnExecute: Pointer);
var
  mAction: TNxAction;
begin
  if Assigned(ASite) then begin
    mAction := ASite.GetNewAction;
    if Assigned(mAction) then begin
      mAction.ShowControl := AShowControl;
      mAction.ShowMenuItem := AShowMenuItem;
      mAction.Caption := ACaption;
      mAction.Hint := AHint;
      mAction.Category := ACategory;
      mAction.OnExecute := AOnExecute;
    end;
  end;
end;

function GetPeriodIDForDate(AOS : TNxCustomObjectSpace; ADate: TDateTime): string;
var
  mSQL: string;
  mValues: TStringList;
begin
  Result := '';
  mValues := TStringList.Create;
  try
    mSQL := Format('select ID from Periods where DateFrom$DATE <= %s and DateTo$DATE > %s', [IntToStr(Trunc(ADate)), IntToStr(Trunc(ADate))]);
    AOS.SQLSelect(mSQL, mValues);
    if mValues.Count > 0 then
      Result := mValues.Strings[0];
  finally
    mValues.Free;
  end;
end;

procedure ShowSelectedDynForm(AForm: TDynSiteForm; AOIDs: TStrings; AFormCLSID: string; ASelCaption: string);
var
  mPars: TNxParameters;
  mParameter: TNxParameter;
begin
  if AOIDs.Count > 0 then begin
    // otevreni zafiltrovane agendy aktivit
    mPars := TNxParameters.Create;
    try
      mPars.NewFromDataType(dtString, '_SelectionCaption', pkUnknown).AsString := ASelCaption;
      mParameter := mPars.NewFromDataType(dtList, '_DefaultSelection', pkUnknown);
      mParameter := mParameter.AsList.NewFromDataType(dtList, 'CONDITIONS', pkUnknown);
      mParameter := mParameter.AsList.NewFromDataType(dtList, 'ID', pkUnknown);
      mParameter.AsList.NewFromDataType(dtInteger, 'USEDKIND', pkUnknown).AsInteger := 3; //ckList
      mParameter.AsList.NewFromDataType(dtString, 'VALUELIST', pkUnknown).AsString := NxStringsTockListStr(AOIDs);
      AForm.ShowDynForm(AFormCLSID, mPars, nil, True, '');
    finally
      mPars.Free;
    end;
  end
end;

{** To samé jako Token, ale respektuje i prázdné položky }
function CdTokenEx(var AStr: string; const ASeparators: string): string;
var
  i: Integer;
begin
  i := NxCharPos(ASeparators, AStr);
  if i > 0 then begin
    Result := Copy(AStr, 1, i-1);
    Delete(AStr, 1, i-1);
    Delete(AStr, 1, Length(ASeparators));
//    AStr := TrimL(AStr, ASeparators);
  end
  else begin
    Result := AStr;
    AStr := '';
  end;
end;

////////////////////////////////////////////////////////////////////////////////
/// Tabulka SELDAT /////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

procedure AddStringsToSelDat(AOS : TNxCustomObjectSpace; AStation_ID: String; AValues: TStringList);
// Přidá do SelDat hodnoty ze StringListu pod AStation
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
// Smaže ze SelDat hodnoty pod AStation
begin
  AOS.SQLExecute('Delete from SelDef where ID = ''' + AStation_ID + '''');
end;

procedure StringsToSelDat(AOS : TNxCustomObjectSpace; AStation_ID: String; AValues: TStringList);
begin
  ClearSelDat(AOS, AStation_ID);
  AddStringsToSelDat(AOS, AStation_ID, AValues);
end;

////////////////////////////////////////////////////////////////////////////////
//        Rolls
////////////////////////////////////////////////////////////////////////////////
// dohledani IDCka - nesmysl jen na zkousku, zda ciselnik skutecne takovy zaznam obsahuje
function ID_RollFind(AContext: TNxContext; ARoll: TNxCustomRoll; const ATextField: String; const AText: Variant; var AID: String; AFilter: TStrings=nil): Boolean;
var
  mRollParams: TNxParameters;
  i: Integer;
begin
  mRollParams := TNxParameters.Create;
  try
    mRollParams.NewFromDataType(dtString, '_ID', pkInput).AsString:= AText; //DoNotLocalize
    if Assigned(AFilter) then begin
      for i := 0 to AFilter.Count - 1 do begin
        mRollParams.NewFromDataType(dtString, AFilter.Names[i], pkInput).AsString := AFilter.ValueFromIndex[i];
      end;
    end;
    Result := ARoll.Validate(AContext, vkCheckOnly, mRollParams, pmNone);
    if Result then
      AID := mRollParams.ParamByName('_ID').AsString;
  finally
    mRollParams.Free;
  end;
end;


function RollFind(AContext: TNxContext; ARoll: TNxCustomRoll; const ATextField: String; const AText: Variant; var AID: String; AFilter: TStrings=nil): Boolean;
var
  mRollParams: TNxParameters;
  i: Integer;
begin
  mRollParams := TNxParameters.Create;
  try
    mRollParams.NewFromDataType(dtBoolean, '_ForcedField', pkInput).AsBoolean := True; //DoNotLocalize
    mRollParams.NewFromDataType(dtString, '_Text', pkInputOutput).AsVariant:= AText; //DoNotLocalize
    mRollParams.NewFromDataType(dtString, '_TextField', pkInput).AsString := ATextField; //DoNotLocalize
    if Assigned(AFilter) then begin
      for i := 0 to AFilter.Count - 1 do begin
        mRollParams.NewFromDataType(dtString, AFilter.Names[i], pkInput).AsString := AFilter.ValueFromIndex[i];
      end;
    end;
    mRollParams.GetOrCreateParam(dtString, '_ID', pkInputOutput).AsString := AID;
    Result := ARoll.Validate(AContext, vkCheckOnly, mRollParams, pmNone);
    if Result then
      AID := mRollParams.ParamByName('_ID').AsString;
  finally
    mRollParams.Free;
  end;
end;

function GetRoll(ABO: TNxCustomBusinessObject; AFieldName: String): TNxCustomRoll;
var
  mCode: Integer;
begin
  mCode := ABO.GetFieldCode(AFieldName);
  Result := NxCreateRoll_1(mCode, ABO);
end;

function SetFieldFromRoll(AContext: TNxContext; ABO: TNxCustomBusinessObject; const ABOFieldName: String; const ATextField: String; const AText: Variant; AFilter: TStrings=nil): Boolean;
var
  mRoll: TNxCustomRoll;
  mID: String;
begin
  mRoll := GetRoll(ABO, ABOFieldName);
  Result := RollFind(AContext, mRoll, ATextField, AText, mID, AFilter);
  if Result then begin
    ABO.SetFieldValueAsString(ABOFieldName, mID);
  end;
end;

function CreateProgressInfo(AForm: TCustomForm; AProcCount: Integer; AInfo: string): TForm;
var
  mForm: TForm;
  mProgr: TProgressBar;
  mLabel: TLabel;
begin
  mForm := TForm.Create(AForm);
  with mForm do begin
    Width := 380;
    Height := 131;
    Caption := 'Průběh zpracování';
    Position := poOwnerFormCenter;
    FormStyle := fsStayOnTop;
    BorderStyle := bsDialog;
    with TLabel.Create(mForm) do begin
      Parent := mForm;
      Left := 8;
      Top := 16;
      Width := 300;
      Height := 16;
      //AutoSize := False;
      Name := 'lblInfoLabel';
      Caption := AInfo;
      Transparent := True;
      //WordWrap := True;
      Font.Height := -13;
      Font.Style := [fsBold];
      Tag := 3;
    end;
    with TProgressBar.Create(mForm) do begin
      Parent := mForm;
      Left := 8;
      Top := 48;
      Width := 353;
      Height := 33;
      Tag := 3;
      Name := 'pgInfoBar';
      Max := AProcCount;
      Position := 0;
    end;
  end;
  Result := mForm;
end;

///////////////Zapis perzistentnich str dat ////////////////////////////////////

function SetValueToStorage(AName: string; AValue: string; AContext: TNxContext): Boolean;
var
  mPars: TNxParameters;
begin
  Result := False;
  mPars := TNxParameters.Create;
  try
    mPars.GetOrCreateParam(dtString, AName).AsString := AValue;
    try
      AContext.GetCompanyCache.SavePropertiesForCompany(AName, mPars);
      Result := True;
    except
      Result := False;
    end;
  finally
    mPars.Free;
  end;
end;

function GetValueFromStorage(AName: string; AContext: TNxContext): string;
var
  mPars: TNxParameters;
begin
  Result := '';
  mPars := TNxParameters.Create;
  try
    AContext.GetCompanyCache.LoadPropertiesForCompany(AName, mPars);
    if mPars.ParamExist(AName) then
      Result := mPars.GetOrCreateParam(dtString, AName).AsString;
  finally
    mPars.Free;
  end;
end;

function SetValueToCentralStorage(AKeyName: string; AValue: string; AOS: TNxCustomObjectSpace): Boolean;
var
  mSQL, mResValue: string;
begin
  Result := False;
  try
    mSQL := 'select Path from CentralStorage where Path = ''%s''';
    mSQL := Format(mSQL, [AKeyName]);
    mResValue := GetFirstRecordFromSQL(AOS, mSQL);
    if mResValue = '' then begin
      mSQL := 'INSERT INTO CentralStorage (Path, Data) Values (''%s'', ''%s'')';
      mSQL := Format(mSQL, [AKeyName, AValue]);
      ShowDebugMessage('SQL: ' + mSQL);
      AOS.SQLExecute(mSQL);
    end
    else begin
      mSQL := 'update CentralStorage set (Data = ''%s'') where Path = ''%s''';
      mSQL := Format(mSQL, [AValue, AKeyName]);
      ShowDebugMessage('SQL: ' + mSQL);
      AOS.SQLExecute(mSQL);
    end;
    Result := True;
  except
    ShowDebugMessage(ExceptionMessage);
    Result := False;
  end;
end;

function GetValuesFromCentralStorage(AKeyName: string; var AResNameList, AResValueList: TStringList; AOS: TNxCustomObjectSpace): Boolean;
var
  mSQL, mResValue: string;
  mDataSet: TRxMemoryData;
begin
  Result := False;
  try
    AResValueList.Clear;
    AResNameList.Clear;
    mSQL := 'select Path, Data from CentralStorage where Path like ''' + AKeyName + '%''';
    mDataSet := TRxMemoryData.Create(nil);
    try
      ShowDebugMessage('SQL: ' + mSQL);
      AOS.SQLSelect2(mSQL, mDataSet);
      if mDataSet.Active then begin
        mDataSet.First;
        // vzdy by melo vracet je jeden radek
        while not mDataSet.Eof do begin
          AResNameList.Add(mDataSet.FieldByName('Path').AsString);
          AResValueList.Add(mDataSet.FieldByName('Data').AsString);
          mDataSet.Next;
        end;
      end;
    finally
      mDataset.Free;
    end;
    Result := True;
  except
    ShowDebugMessage(ExceptionMessage);
    Result := False;
  end;
end;

function DeleteValueFromCentralStorage(AKeyName: string; AOS: TNxCustomObjectSpace): Boolean;
var
  mSQL, mResValue: string;
begin
  Result := False;
  try
    mSQL := 'delete from CentralStorage where Path = ''%s''';
    mSQL := Format(mSQL, [AKeyName]);
    ShowDebugMessage('SQL: ' + mSQL);
    AOS.SQLExecute(mSQL);
    Result := True;
  except
    ShowDebugMessage(ExceptionMessage);
    Result := False;
  end;
end;

/////////// formular pro editaci textu /////////////////////////////////////////
//Vytvoří editační formulář
function StringEditDlg(ASourceForm: TForm; AFormCaption: string): string;
var
  mForm: TForm;
  lblEdit: TLabel;
  edEdit: TEdit;
  btnClose, btnCancel: TButton;
begin
  mForm := TForm.Create(ASourceForm); // muze byt i nil...
  try
    mForm.Top := 196;
    mForm.Left := 218;
    mForm.Width := 280;
    mForm.Height := 130;
    mForm.Name := 'frmStrDialog';
    mForm.Caption := AFormCaption;
    //mForm.FormStyle := fsStayOnTop;
    mForm.BorderStyle := bsSizeable;
    mForm.Scaled := False;

    lblEdit := TLabel.Create(mForm);
    with lblEdit do begin
      Name := 'lblEdit';
      Parent := mForm;
      Caption := 'Zadejte text:';
      Left := 8;
      Top := 19;
      Width := 131;
      Height := 13;
    end;

   edEdit := TEdit.Create(mForm);
   with edEdit do begin
      Name := 'edEdit';
      Parent := mForm;
      Left := 70;
      Top := 16;
      Width := 190;
      Height := 21;
      Text := '';
      TabOrder := 0;
    end;

    ShowDebugMessage('make form - btnClose');
    btnClose := TButton.Create(mForm);
    with btnClose do begin
      Name := 'btnClose';
      Parent := mForm;
      Left := 84;
      Top := 56;
      Width := 75;
      Height := 25;
      Anchors := [akTop, akRight];
      Caption := 'OK';
      TabOrder := 1;
      ModalResult := mrOk;
    end;

    ShowDebugMessage('make form - btnCancel');
    btnCancel := TButton.Create(mForm);
    with btnCancel do begin
      Name := 'btnCancel';
      Parent := mForm;
      Left := 180;
      Top := 56;
      Width := 75;
      Height := 25;
      Anchors := [akTop, akRight];
      Caption := 'Zrušit';
      TabOrder := 1;
      ModalResult := mrCancel;
    end;

    //Konec vytvoření formuláře
    if mForm.ShowModal = mrOK then
      Result := edEdit.Text
    else
      Result := '';
  except
    mForm.Free;
  end;
end;

begin
end.