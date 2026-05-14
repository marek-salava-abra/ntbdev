uses
  '_Books_803.uScFunc', '_Books_803.uScOLEFunc';

const
  cDefaultStepHeight = 28;
  cDefaultWidthProp = 200;
  cDefaultIndent = 16;
  // Konstanty pro perzistentní ukládání parametrů ve fci SetAndSaveParams - ANames
  // jsou to Names
  // příklad zápisu: ...cParamName_NameField + '=FirmName'#13#10.....
  // nebo použít pomocné fce Str.....
  cParamName_Name = 'Name';
  cParamName_DataType = 'DataType';
  cParamName_DisplayName = 'DisplayName';
  cParamName_DefaultValue = 'Default';
  cParamName_DefaultValueHigh = 'DefaultHigh';
  cParamName_Size = 'Size';
  cParamName_RollCLSID = 'CLSID';
  cParamName_RollParam = 'Param';
  cParamName_RollFieldEdit = 'FieldEdit';
  cParamName_RollFieldDisplay = 'FieldDisplay';
  cParamName_RollMultiSelect = 'MultiSelect';
  cParamName_WithoutSave = 'WithoutSave';
  cParamName_WithoutLoad = 'WithoutLoad';
  cParamName_SaveWithPrefix = 'SaveWithPrefix';
  cParamName_ParamNames = 'ParamNames'; // výčet Names pro RadioButton, odděleno středníkem
  cParamName_SaveForUser = 'SaveForUser'; // uložení pro všechny uživatele
  cParamName_FileFilter = 'FileFilter'; // filtrace pro soubory
  cParamName_AgendTable = 'AgendTable';
  cParamName_AgendSelectIDs = 'AgendSelectIDs';
  cParamName_LabelFontSize = 'LabelFontSize';
  cParamName_LabelFontColor = 'LabelFontColor';
  cParamName_WidthForm = 'WithForm';
  cParamName_Indent = 'Indent';
  cParamName_LabelFontStyles = 'LabelFontStyles';
  cParamName_IntFormat = 'IntFormat';
  cParamName_MaskFormat = 'MaskFormat';
  cParamName_DecimalPlaces = 'DecimalPlaces';
  cParamName_ColorLine = 'ColorLine';
  cParamName_X_Move = 'X_Move';
  cParamName_Y_Move = 'Y_Move';
  cParamName_NoLabel = 'NoLabel';

  // Konstanty typů dat pro perzistentní ukládání parametrů ve fci SetAndSaveParams - ANames
  // použití v parametru cParamName_DataType
  // příklad zápisu: ...cParamName_DataType + '=' + cDataType_Number + '#13#10.....
  // nebo fce StrDataType
  cDataType_String = 1;
  cDataType_Number = 2;
  cDataType_Number2 = 3;
  cDataType_Date = 4;
  cDataType_Date2 = 5;
  cDataType_Boolean = 6;
  cDataType_Folder = 7;
  cDataType_File = 8;
  cDataType_Roll = 9;
  cDataType_Int = 10;
  cDataType_Int2 = 11;
  cDataType_Password = 12;
  cDataType_Memo = 13;
  cDataType_Enum = 14;
  cDataType_Time = 15;
  cDataType_Agend = 16;
  cDataType_Combo = 17;
  cDataType_InsertLine = 18;
  cDataType_Label = 19;

var
  gPersistParamContext: TNxContext;

// Pomocná fce pro zápis do vstupních parametrů
function StrName(AStr: string): string;
begin
  Result := cParamName_Name + '=' + AStr;
end;

// Pomocná fce pro zápis do vstupních parametrů
function StrDataType(ADataType: integer): string;
begin
  Result := cParamName_DataType + '=' + IntToStr(ADataType);
end;

// Pomocná fce pro zápis do vstupních parametrů
function StrDisplayName(AStr: string): string;
begin
  Result := cParamName_DisplayName + '=' + AStr;
end;

// Pomocná fce pro zápis do vstupních parametrů
function StrDefault(AValue: Variant): string;
var
  s: string;
begin
  case VarType(AValue) of
    varEmpty, varNull: s := '';
    varInteger, varDouble, varDate, varSmallint, varByte: s := VarToStr(AValue);
    varString, varVariant, varOleStr: s := VarToStr(AValue);
    varBoolean: if AValue then s := 'A' else s := 'N';
  end;
  Result := cParamName_DefaultValue + '=' + s;
end;

// Pomocná fce pro zápis do vstupních parametrů
function StrDefaultHigh(AValue: Variant): string;
var
  s: string;
begin
  case VarType(AValue) of
    varEmpty, varNull: s := '';
    varInteger, varDouble, varDate, varSmallint, varByte: s := VarToStr(AValue);
    varString, varVariant, varOleStr: s := VarToStr(AValue);
    varBoolean: if AValue then s := 'A' else s := 'N';
  end;
  Result := cParamName_DefaultValueHigh + '=' + s;
end;

// Pomocná fce pro zápis do vstupních parametrů
function StrSize(AInt: Integer): string;
begin
  Result := cParamName_Size + '=' + IntToStr(AInt);
end;

// Pomocná fce pro zápis do vstupních parametrů
function StrCLSID(AStr: string): string;
begin
  Result := cParamName_RollCLSID + '=' + AStr;
end;

// Pomocná fce pro zápis do vstupních parametrů
function StrRollParam(AStr: string): string;
begin
  Result := cParamName_RollParam + '=' + AStr;
end;

// Pomocná fce pro zápis do vstupních parametrů
function StrRollFieldEdit(AStr: string): string;
begin
  Result := cParamName_RollFieldEdit + '=' + AStr;
end;

// Pomocná fce pro zápis do vstupních parametrů
function StrRollFieldDisplay(AStr: string): string;
begin
  Result := cParamName_RollFieldDisplay + '=' + AStr;
end;

// Pomocná fce pro zápis do vstupních parametrů
function StrMultiSelect(ABool: Boolean): string;
begin
  if ABool then
    Result := cParamName_RollMultiSelect + '=A'
  else
    Result := cParamName_RollMultiSelect + '=N';
end;

// Pomocná fce pro zápis do vstupních parametrů
function StrWithoutSave(ABool: Boolean): string;
begin
  if ABool then
    Result := cParamName_WithoutSave + '=A'
  else
    Result := cParamName_WithoutSave + '=N';
end;

// Pomocná fce pro zápis do vstupních parametrů
function StrWithoutLoad(ABool: Boolean): string;
begin
  if ABool then
    Result := cParamName_WithoutLoad + '=A'
  else
    Result := cParamName_WithoutLoad + '=N';
end;

// Pomocná fce pro zápis do vstupních parametrů
function StrSaveWithPrefix(AStr: String): string;
begin
  Result := cParamName_SaveWithPrefix+ '=' + AStr;
end;

// Pomocná fce pro zápis do vstupních parametrů
function StrParamNames(AStr: String): string;
begin
  Result := cParamName_ParamNames+ '=' + AStr;
end;

// Pomocná fce pro zápis do vstupních parametrů
function StrSaveForUser(ABool: Boolean): string;
begin
  if ABool then
    Result := cParamName_SaveForUser+ '=A'
  else
    Result := cParamName_SaveForUser+ '=N';
end;

// Pomocná fce pro zápis do vstupních parametrů
function StrFileFilter(AStr: string): string;
begin
  Result := cParamName_FileFilter + '=' + AStr;
end;

// Pomocná fce pro zápis do vstupních parametrů
function StrAgendTable(AStr: string): string;
begin
  Result := cParamName_AgendTable + '=' + AStr;
end;

// Pomocná fce pro zápis do vstupních parametrů
function StrLabelFontSize(AInt: Integer): string;
begin
  Result := cParamName_LabelFontSize + '=' + IntToStr(AInt);
end;

// Pomocná fce pro zápis do vstupních parametrů
function StrLabelFontColor(AInt: Integer): string;
begin
  Result := cParamName_LabelFontColor + '=' + IntToStr(AInt);
end;

// Pomocná fce pro zápis do vstupních parametrů
function StrWidthForm(AInt: Integer): string;
begin
  Result := cParamName_WidthForm + '=' + IntToStr(AInt);
end;

// Pomocná fce pro zápis do vstupních parametrů
function StrIndent(AInt: Integer): string;
begin
  Result := cParamName_Indent + '=' + IntToStr(AInt);
end;

// Pomocná fce pro zápis do vstupních parametrů
function StrLabelFontStyles(AFS: String): string;
begin
  Result := cParamName_LabelFontStyles + '=' + AFS;
end;

// Pomocná fce pro zápis do vstupních parametrů
// oddělovač je čárka
function StrAgendSelectIDs(AStr: string): string;
begin
  Result := cParamName_AgendSelectIDs + '=' + AStr;
end;

// Pomocná fce pro zápis do vstupních parametrů
function StrIntFormat(AStr: string): string;
begin
  Result := cParamName_IntFormat + '=' + AStr;
end;

// Pomocná fce pro zápis do vstupních parametrů
function StrMaskFormat(AStr: string): string;
begin
  Result := cParamName_MaskFormat + '=' + AStr;
end;

// Pomocná fce pro zápis do vstupních parametrů
function StrDecimalPlaces(AInt: Integer): string;
begin
  Result := cParamName_DecimalPlaces + '=' + IntToStr(AInt);
end;

// Pomocná fce pro zápis do vstupních parametrů
function StrColorLine(AInt: Integer): string;
begin
  Result := cParamName_ColorLine + '=' + IntToStr(AInt);
end;

// Pomocná fce pro zápis do vstupních parametrů
function StrX_Move(AInt: Integer): string;
begin
  Result := cParamName_X_Move + '=' + IntToStr(AInt);
end;

// Pomocná fce pro zápis do vstupních parametrů
function StrY_Move(AInt: Integer): string;
begin
  Result := cParamName_Y_Move + '=' + IntToStr(AInt);
end;

// Pomocná fce pro zápis do vstupních parametrů
function StrNoLabel(ABool: Boolean): string;
begin
  if ABool then
    Result := cParamName_NoLabel + '=A'
  else
    Result := cParamName_NoLabel + '=N';
end;

function iGetDefault(ADataType: Integer): Variant;
begin
  case ADataType of
    cDataType_Number, cDataType_Number2, cDataType_Int, cDataType_Int2:
      Result := 0;
    cDataType_Enum:
      Result := -1;
    cDataType_Date, cDataType_Date2:
      Result := 0;
    cDataType_Boolean:
      Result := False;
    else
      Result := '';
  end;
end;

function iConvert(AStr: string; ADataType: Integer): Variant;
begin
  try
    case ADataType of
      cDataType_Number, cDataType_Number2:
        Result := StrToFloat(AStr);
      cDataType_Int, cDataType_Int2, cDataType_Enum:
        Result := StrToInt(AStr);
      cDataType_Date, cDataType_Date2:
        Result := StrToFloat(AStr);
      cDataType_Boolean:
        Result := AStr = 'A';
      else
        Result := AStr;
    end;
  except
    Result := iGetDefault(ADataType);
  end;
end;

function iGetPropByControl(ANameControl: String; AProp: string; ADataType: integer; ADefault: Variant; AListOfParams: TStringList): Variant;
var
  ss: TStringList;
  i: Integer;
begin
  ss := TStringList.Create;
  Result := ADefault;
  try
    for i:=0 to AListOfParams.Count-1 do begin
      ss.Text := AListOfParams[i];
      if ss.IndexOfName(ANameControl) > -1 then begin
        Result := iGetProp(AProp, ADataType, ADefault, ss);
        break;
      end;
    end;
  finally
    ss.Free;
  end;
end;

function iGetProp(AProp: string; ADataType: integer; ADefault: Variant; AListOfParams: TStringList): Variant;
begin
  if AListOfParams.Values[AProp] <> '' then
    Result := iConvert(AListOfParams.Values[AProp], ADataType)
  else
    Result := ADefault;
end;

procedure iSetTextValueToStorage(AControlName, AName, APrefix, AValue: String);
var
  mSaveForUser: Boolean;
begin
  mSaveForUser := iGetPropByControl(AControlName, cParamName_SaveForUser, cDataType_Boolean, False, GetLocalObject('TempParams'));
  if mSaveForUser then
    if Assigned(gPersistParamContext) then
      SetValueToStorageForUserII(AName, AValue, gPersistParamContext, APrefix)
    else
      SetValueToStorageForUser(AName, AValue, Nil, APrefix)
  else
    if Assigned(gPersistParamContext) then
      SetValueToStorageII(AName, AValue, gPersistParamContext, APrefix)
    else
      SetValueToStorage(AName, AValue, Nil, APrefix);
end;

procedure iSetRollAgendValue(AControlName, AName, APrefix, AValue: String);
var
  mType: Integer;
  s, mTable: String;
  mOLE: Variant;
begin
  iSetTextValueToStorage(AControlName, AName, APrefix, AValue);
  mType := iGetPropByControl(AControlName, cParamName_DataType, cDataType_Int, cDataType_String, GetLocalObject('TempParams'));
  if mType in [cDataType_Agend] then begin
    mOLE := AbraOLE;
    mTable := iGetPropByControl(AControlName, cParamName_AgendTable, cDataType_String, '', GetLocalObject('TempParams'));
    s := GetIDByDocDisplayName(mOLE, AValue, mTable);
    iSetTextValueToStorage(AControlName, AName+ '_ID', APrefix, s);
  end;
end;

procedure OnClickBack(Sender: TObject);
begin
  TForm(GetLocalObject('ParForm')).Tag := 0;  // Vrácení (ne)potvrzení dialogu
  TForm(GetLocalObject('ParForm')).Close;
end;

procedure OnClickSave(Sender: TObject);
var
  mMyPanel: TPanel;
  mEdit: TEdit;
  mDateEdit: TDateEdit;
  mCheckBox: TCheckBox;
  mRGroup: TRadioGroup;
  mComboBox: TComboBox;
  mPrefix: String;
  i: integer;
begin
  if iGetProp(cParamName_WithoutSave, cDataType_Boolean, False, GetLocalObject('TempParams')) then
    Exit;
  mMyPanel := TPanel(TButton(Sender).Parent);
  mPrefix := TButton(Sender).Hint;
  for i:=0 to mMyPanel.ControlCount-1 do begin
    if mMyPanel.Controls[i] is TDateEdit then begin
      mDateEdit := TDateEdit(mMyPanel.Controls[i]);
      iSetTextValueToStorage(mMyPanel.Controls[i].Name, mDateEdit.Hint, mPrefix, FloatToStr(mDateEdit.Date));
      Continue;
    end;
    if mMyPanel.Controls[i] is TEdit then begin
      mEdit := TEdit(mMyPanel.Controls[i]);
      iSetRollAgendValue(mMyPanel.Controls[i].Name, mEdit.Hint, mPrefix, mEdit.Text);
    end;
    if mMyPanel.Controls[i] is TCheckBox then begin
      mCheckBox := TCheckBox(mMyPanel.Controls[i]);
      if mCheckBox.Checked then
        iSetTextValueToStorage(mMyPanel.Controls[i].Name, mCheckBox.Hint, mPrefix, 'A')
      else
        iSetTextValueToStorage(mMyPanel.Controls[i].Name, mCheckBox.Hint, mPrefix, 'N');
    end;
    if mMyPanel.Controls[i] is TRadioGroup then begin
      mRGroup := TRadioGroup(mMyPanel.Controls[i]);
      iSetTextValueToStorage(mMyPanel.Controls[i].Name, mRGroup.Hint, mPrefix, IntToStr(mRGroup.ItemIndex));
    end;
    if mMyPanel.Controls[i] is TComboBox then begin
      mComboBox := TComboBox(mMyPanel.Controls[i]);
      iSetTextValueToStorage(mMyPanel.Controls[i].Name, mComboBox.Hint, mPrefix, mComboBox.Text);
    end;
  end;
  TForm(GetLocalObject('ParForm')).Tag := 1;  // Vrácení (ne)potvrzení dialogu
  TForm(GetLocalObject('ParForm')).Close;
end;

procedure SetRollStaticText(AParam: TStringList; AComp: TStaticText);
var
  mMyPanel: TPanel;
  mEdit: TEdit;
  i: integer;
  s, s2, s3, mID, mCLSID, mParam, mFieldEdit, mFieldDisplay, mPrefix: string;
  mRoll: Variant;
  mMultiSelect: Boolean;
  ss: TStringList;
  mOLE: Variant;
begin
  mOLE := AbraOLE;
  mMyPanel := TPanel(AComp.Parent);
  for i:=0 to mMyPanel.ControlCount-1 do
    if mMyPanel.Controls[i] is TEdit then
      if Pos(Copy(AComp.Name, 4, 255), Copy(mMyPanel.Controls[i].Name, 3, 255)) = 1 then
        mEdit := TEdit(mMyPanel.Controls[i]);
  mCLSID := AParam.Values[cParamName_RollCLSID];
  mParam := NxSearchReplace(AParam.Values[cParamName_RollParam], '#13#10', #13#10, [srAll]);
  mFieldEdit := AParam.Values[cParamName_RollFieldEdit];
  mMultiSelect := AParam.Values[cParamName_RollMultiSelect] = 'A';
  mPrefix := AParam.Values[cParamName_SaveWithPrefix];
  if mFieldEdit = '' then
    mFieldEdit := 'Code';
  mFieldDisplay := AParam.Values[cParamName_RollFieldDisplay];
  if mFieldDisplay = '' then
    mFieldDisplay := 'Name';
  mRoll := mOLE.GetRoll(mCLSID, 0);
  mRoll.Params.Text := mParam;
  if not mMultiSelect then begin
    if mFieldEdit <> 'ID' then
      mID := mRoll.Find2(mFieldEdit, mEdit.Text, mID)
    else
      mID := mEdit.Text;
    s := mRoll.Lookup2(mID, mFieldDisplay);
    iSetTextValueToStorage(mEdit.Name, mEdit.Hint + '_ID', mPrefix, mID);
//    SetValueToStorage(mEdit.Hint + '_ID', mID, Nil, mPrefix);
    if NxIsEmptyOID(mID) then begin
      AComp.Caption := ' -- nenalezeno --';
      AComp.Font.Color := clRed;
    end
    else begin
      AComp.Caption := ' ' + s;
      AComp.Font.Color := clBlack;
    end;
  end
  else
    try
      ss := TStringList.Create;
      s := StringReplace(mEdit.Text, ';', #13#10, [rfReplaceAll]);
      ss.Text := s;
      s := '';
      s2 := '';
      for i:=0 to ss.Count-1 do begin
        if mFieldEdit = 'ID' then
          s3 := ss[i]
        else
          s3 := mRoll.Find2(mFieldEdit, ss[i], mID);
        s := s + s3 + #13#10;
        if s2 = '' then
          s2 := '''' + s3 + ''''
        else
          s2 := s2 + ',''' + s3 + '''';
      end;
      if s2 = '' then
        s2 := '''''';
//      SetValueToStorage(mEdit.Hint + '_IDs', s, Nil, mPrefix);
//      SetValueToStorage(mEdit.Hint + '_CommaIDs', s2, Nil, mPrefix);
      iSetTextValueToStorage(mEdit.Name, mEdit.Hint + '_IDs', mPrefix, s);
      iSetTextValueToStorage(mEdit.Name, mEdit.Hint + '_CommaIDs', mPrefix, s2);
      ss.Text := s;
      s := '';
      for i:=0 to ss.Count-1 do
        if i < ss.Count-1 then
          s := s + mRoll.Lookup2(ss[i], mFieldDisplay) + ';'
        else
          s := s + mRoll.Lookup2(ss[i], mFieldDisplay);
      AComp.Caption := ' ' + s;

    finally
      ss.Free;
    end;
end;

procedure OnClickRoll(Sender: TObject);
var
  mMyForm: TForm;
  mMyPanel: TPanel;
  mEdit: TEdit;
  mStatic: TStaticText;
  i: integer;
  ss: TStringList;
  s, mID, mCLSID, mParam, mFieldEdit, mPrefix: string;
  mRoll: Variant;
  mMultiSelect: Boolean;
  _ss: Variant;
  mOLE: Variant;
begin
  mOLE := AbraOLE;
  mMyForm := TForm(TButton(Sender).Owner);
  mMyPanel := TPanel(TButton(Sender).Parent);
  for i:=0 to mMyPanel.ControlCount-1 do begin
    if mMyPanel.Controls[i] is TEdit then
      if Copy(TButton(Sender).Name, 4, 255) = Copy(mMyPanel.Controls[i].Name, 3, 255) then
        mEdit := TEdit(mMyPanel.Controls[i]);
    if mMyPanel.Controls[i] is TStaticText then
      if Copy(TButton(Sender).Name, 4, 255) = Copy(mMyPanel.Controls[i].Name, 4, 255) then
        mStatic := TStaticText(mMyPanel.Controls[i]);
  end;
  ss := TStringList.Create;
  _ss := mOLE.CreateStrings;
  try
    ss.Text := TButton(Sender).Hint;
    mCLSID := ss.Values[cParamName_RollCLSID];
    mParam := NxSearchReplace(ss.Values[cParamName_RollParam], '#13#10', #13#10, [srAll]);
    mFieldEdit := ss.Values[cParamName_RollFieldEdit];
    mMultiSelect := ss.Values[cParamName_RollMultiSelect] = 'A';
    mPrefix := ss.Values[cParamName_SaveWithPrefix];
    if mFieldEdit = '' then
      mFieldEdit := 'Code';
//    mRoll := GetAbraOLEApplication.GetRoll(mCLSID, 0);
    mRoll := mOLE.GetRoll(mCLSID, 0);
    mRoll.SetBoundRect(mMyForm.Top + 20, mMyForm.Left + 20, mMyForm.Top + 200, mMyForm.Left + 150);
    mRoll.Params.Text := mParam;
    if not mMultiSelect then begin
      if mFieldEdit <> 'ID' then
        mID := mRoll.Find2(mFieldEdit, mEdit.Text, mID)
      else
        mID := mEdit.Text;
      mID := mRoll.SelectDialog2(False, mID);
      if mID <> '' then begin
        s := mRoll.Lookup2(mID, mFieldEdit);
        if s <> '' then begin
          mEdit.Text := s;
//          SetValueToStorage(mEdit.Hint + '_ID', mID, Nil, mPrefix);
          iSetTextValueToStorage(mEdit.Name, mEdit.Hint + '_ID', mPrefix, mID);
        end;
      end;
    end
    else begin
      s := StringReplace(mEdit.Text, ';', #13#10, [rfReplaceAll]);
      ss.Text := s;
      s := '';
      for i:=0 to ss.Count-1 do
        if mFieldEdit = 'ID' then
          s := s + ss[i] + #13#10
        else
          s := s + mRoll.Find2(mFieldEdit, ss[i], mID) + #13#10;
      _ss.Text := s;
      if mRoll.MultiSelectDialog(False, _ss) then begin
        s := '';
        for i:=0 to _ss.Count-1 do
          if i < _ss.Count-1 then
            s := s + mRoll.Lookup2(_ss.Strings[i], mFieldEdit) + ';'
          else
            s := s + mRoll.Lookup2(_ss.Strings[i], mFieldEdit);
        mEdit.Text := s;
//        SetValueToStorage(mEdit.Hint + '_IDs', _ss.Text, Nil, mPrefix);
        iSetTextValueToStorage(mEdit.Name, mEdit.Hint + '_IDs', mPrefix, _ss.Text);
      end;
    end;
//    SetRollStaticText(ss, mStatic);
  finally
    ss.Free;
  end;
end;

procedure OnClickAgend(Sender: TObject);
var
  mMyPanel: TPanel;
  mEdit: TEdit;
  i: integer;
  ss: TStringList;
  s, mID, mCLSID, mParam, mPrefix, mTable: string;
  mAgend: Variant;
  mMultiSelect: Boolean;
  _ss: Variant;
  mOLE: Variant;
  mAgendSelectIDs: String;
begin
  mOLE := AbraOLE;
  mMyPanel := TPanel(TButton(Sender).Parent);
  for i:=0 to mMyPanel.ControlCount-1 do begin
    if mMyPanel.Controls[i] is TEdit then
      if Copy(TButton(Sender).Name, 4, 255) = Copy(mMyPanel.Controls[i].Name, 3, 255) then
        mEdit := TEdit(mMyPanel.Controls[i]);
  end;
  ss := TStringList.Create;
  _ss := mOLE.CreateStrings;
  try
    ss.Text := TButton(Sender).Hint;
    mCLSID := ss.Values[cParamName_RollCLSID];
    mParam := NxSearchReplace(ss.Values[cParamName_RollParam], '#13#10', #13#10, [srAll]);
    mMultiSelect := ss.Values[cParamName_RollMultiSelect] = 'A';
    mPrefix := ss.Values[cParamName_SaveWithPrefix];
    mTable := ss.Values[cParamName_AgendTable];
    mAgendSelectIDs := ss.Values[cParamName_AgendSelectIDs];
    mAgend := mOLE.GetAgenda(mCLSID);
    mAgend.Params.Text := mParam;
    mID := '';
    if mAgendSelectIDs <> '' then begin
      _ss.CommaText := mAgendSelectIDs;
      mID := mAgend.SingleSelectFromSelected2(_ss, 'Výběr dokladů', '');
    end
    else
      mID := mAgend.SingleSelect2('QueryPage', mID);
    if mID <> '' then begin
      mEdit.Text := GetDocDisplayNameByID(mOLE, mID, mTable);
      iSetTextValueToStorage(mEdit.Name, mEdit.Hint + '_ID', mPrefix, mID);
//      SetValueToStorage(mEdit.Hint + '_ID', mID, Nil, mPrefix);
    end;
  finally
    ss.Free;
  end;
end;

procedure OnClickAgend_1(Sender: TObject);
var
  mMyPanel: TPanel;
  mEdit: TEdit;
  mOLE: Variant;
  s: String;
  ss: TStringList;
  i: Integer;
begin
  mOLE := AbraOLE;
  mMyPanel := TPanel(TButton(Sender).Parent);
  for i:=0 to mMyPanel.ControlCount-1 do begin
    if mMyPanel.Controls[i] is TEdit then
      if Copy(TButton(Sender).Name, 4, 255) = Copy(mMyPanel.Controls[i].Name + '_1', 3, 255) then
        mEdit := TEdit(mMyPanel.Controls[i]);
  end;
  ss := TStringList.Create;
  try
    ss.Text := TButton(Sender).Hint;
    s := GetIDByDocDisplayName(mOLE, mEdit.Text, ss.Values[cParamName_AgendTable]);
    if s = '' then
      MessageDlg('Doklad nebyl nalezen.', mtWarning, [mbOk], 0)
    else
      MessageDlg('Doklad byl nalezen.', mtInformation, [mbOk], 0);
  finally
    ss.Free;
  end;
end;

procedure OnChangeEditRoll(Sender: TObject);
var
  mMyPanel: TPanel;
  mButton: TButton;
  mStatic: TStaticText;
  i: integer;
  ss: TStringList;
  s, mID, mCLSID, mParam, mFieldEdit: string;
  mRoll: Variant;
begin
  mMyPanel := TPanel(TEdit(Sender).Parent);
  for i:=0 to mMyPanel.ControlCount-1 do begin
    if mMyPanel.Controls[i] is TButton then
      if Pos(Copy(TEdit(Sender).Name, 3, 255), Copy(mMyPanel.Controls[i].Name, 4, 255)) = 1 then
        mButton := TButton(mMyPanel.Controls[i]);
    if mMyPanel.Controls[i] is TStaticText then
      if Pos(Copy(TEdit(Sender).Name, 3, 255), Copy(mMyPanel.Controls[i].Name, 4, 255)) = 1 then
        mStatic := TStaticText(mMyPanel.Controls[i]);
  end;
  ss := TStringList.Create;
  try
    ss.Text := mButton.Hint;
    SetRollStaticText(ss, mStatic);
  finally
    ss.Free;
  end;
end;

procedure Form_OnShow(Sender: TObject);
var
  i: integer;
  procedure iUpdateForm(AControl: TWinControl);
  var
    ii: Integer;
  begin
    if TForm(Sender).Width - 20 < AControl.Left + AControl.Width then
      TForm(Sender).Width := AControl.Left + AControl.Width + 20;
    if not(AControl is TWinControl) then
      exit;
    for ii:=0 to AControl.ControlCount-1 do
      if (AControl.Controls[ii] is TWinControl) or
        (AControl.Controls[ii] is TGraphicControl) or
        (AControl.Controls[ii] is TBevel) then begin
        iUpdateForm(TWinControl(AControl.Controls[ii]));
      end;
  end;
  procedure iUpdateForm2(AControl: TWinControl);
  var
    ii: Integer;
  begin
    case AControl.Tag of
      1: AControl.Anchors := [akLeft, akBottom];
      2: AControl.Anchors := [akRight,akBottom];
      3: AControl.Anchors := [akLeft, akTop, akRight];
      4: AControl.Anchors := [akRight,akTop];
      5:begin
          AControl.Left := 8;
          AControl.Width := TForm(Sender).Width - 16;
          AControl.Anchors := [akLeft, akTop, akRight];
        end;
    end;
    if not(AControl is TWinControl) then
      exit;
    for ii:=0 to AControl.ControlCount-1 do
      if (AControl.Controls[ii] is TWinControl) or
        (AControl.Controls[ii] is TGraphicControl) or
        (AControl.Controls[ii] is TBevel) then begin
        iUpdateForm2(TWinControl(AControl.Controls[ii]));
      end;
  end;
  procedure iUpdateForm3(AControl: TWinControl);
  var
    ii: Integer;
  begin
    if AControl.Name = 'btnMyBack' then begin
      AControl.Left := TForm(Sender).Width - 90;
      AControl.Top := TForm(Sender).Height - 60;
//      ShowMessage(IntToStr(AControl.Left) + '/' + IntToStr(AControl.Top));
    end;
    if AControl.Name = 'btnMySave' then begin
      AControl.Left := TForm(Sender).Width - 170;
      AControl.Top := TForm(Sender).Height - 60;
//      ShowMessage(IntToStr(AControl.Left) + '\' + IntToStr(AControl.Top));
    end;
    if not(AControl is TWinControl) then
      exit;
    for ii:=0 to AControl.ControlCount-1 do
      if (AControl.Controls[ii] is TWinControl) or
        (AControl.Controls[ii] is TGraphicControl) or
        (AControl.Controls[ii] is TBevel) then begin
        iUpdateForm3(TWinControl(AControl.Controls[ii]));
      end;
  end;
begin
  for i:=0 to TForm(Sender).ControlCount-1 do
    if (TForm(Sender).Controls[i] is TWinControl) or
      (TForm(Sender).Controls[i] is TGraphicControl) or
      (TForm(Sender).Controls[i] is TBevel) then begin
      iUpdateForm(TWinControl(TForm(Sender).Controls[i]));
    end;
  for i:=0 to TForm(Sender).ControlCount-1 do
    if (TForm(Sender).Controls[i] is TWinControl) or
      (TForm(Sender).Controls[i] is TGraphicControl) or
      (TForm(Sender).Controls[i] is TBevel) then begin
      iUpdateForm2(TWinControl(TForm(Sender).Controls[i]));
    end;
  for i:=0 to TForm(Sender).ControlCount-1 do
    if (TForm(Sender).Controls[i] is TWinControl) then begin
      iUpdateForm3(TWinControl(TForm(Sender).Controls[i]));
    end;
end;

procedure OnFileClick(Sender: TObject);
var
  mDialog: TOpenDialog;
  mMyPanel: TPanel;
  mEdit: TEdit;
  i: integer;
begin
  mMyPanel := TPanel(TButton(Sender).Parent);
  for i:=0 to mMyPanel.ControlCount-1 do begin
    if mMyPanel.Controls[i] is TEdit then
      if Copy(TButton(Sender).Name, 4, 255) = Copy(mMyPanel.Controls[i].Name, 3, 255) then
        mEdit := TEdit(mMyPanel.Controls[i]);
  end;
  mDialog := TOpenDialog.Create(nil);
  try
    mDialog.FileName := mEdit.Text;
    if Copy(mDialog.FileName, Length(mDialog.FileName), 1) = '\' then
      mDialog.FileName := mDialog.FileName + '*.*';
    if TButton(Sender).HelpKeyword = '' then
      mDialog.Filter := 'All files|*.*'
    else
      mDialog.Filter := TButton(Sender).HelpKeyword;
    if mDialog.Execute then
      mEdit.Text := mDialog.FileName;
  finally
    mDialog.Free;
  end;
end;

// Vyvolání okna, který načte ze storage (central) a ukáže parametry (ANames)
// a po potvrzení je potom uloží - něco jako uživatelské nastavení INI, zatím
// podpora pouze pro strings
// uložení jedné hodnoty(jeden item) v ANames:
//   StrName(<jméno fieldu>:String) + #1310
//   StrDisplayName(<displayname fieldu>:String) + #1310
//   StrDefault(<default value>:Variant) + #1310
//   StrLength(<length displayname>:Integer) + #1310
//   StrDataType(cDataType_....:Integer)
//    .. a další
// Příslušné metody: SetValueToStorage, GetValueFromStorage
function SetAndSaveParamsII(AOwnerForm: TForm; AContext: TNxContext; ANames: TStrings; AOnlyInputDialog: Boolean = False; ALeft: Integer = 50;
  ATop: Integer = 50; AColor: Integer = clBtnFace): Boolean;
var
  mMyForm, mParForm: TForm;
  mPanel: TPanel;
  i, j, mWidthProp, mDataType, mIndent: Integer;
  s, mPrefix, mNameProp, mDisplayProp, mParamEnum, mFileFilter, mIntFormat,
    mMaskFormat: string;
  mValueProp, mValuePropHigh: Variant;
  ss, ss2: TStringList;
  mDefault, mMultiSelect: boolean;
  mStatic: TStaticText;
  mChkBox: TCheckBox;
  mEdit: TEdit;
  mCalcEdit: TNumEdit;
  mDateEdit: TDateEdit;
  mBTNST, mBTNOK: TButton;
  mActualTop: Integer;
  mRGroup: TRadioGroup;
  mSaveForUser, mOrigWidthProp, mNoLabel: Boolean;
  mRoll: Variant;
  mOLE: Variant;
  mLabelFontSize, mLabelFontColor, mWidthForm: Integer;
  mLabelFontStyles: TFontStyles;
  mLine: TPanel;
  mDecimalPlaces, mColorLine, mX_Move, mY_Move: Integer;
begin
  gPersistParamContext := AContext;
  mOLE := AbraOLE;
  if not Assigned(gPersistParamContext) then
    if not TestRegularSite(nil, 'SetAndSaveParams') then
      Exit;
  SetLocalObject(ANames, 'TempParams');
  mMyForm := AOwnerForm;
  ss := TStringList.Create;
  ss2 := TStringList.Create;
  try
    mParForm := TForm.Create(mMyForm);
    with mParForm do begin
      if not Assigned(mMyForm) then
        Position := poScreenCenter
      else
        Position := poOwnerFormCenter;
      Width := cDefaultWidthProp + 40;
      Height := ANames.Count * 40 + 100;
      Caption := 'Nastavení parametrů';
//      BorderIcons := 0;
//      BorderStyle := bsToolWindow;
      OnShow := @Form_OnShow;
    end;
    SetLocalObject(TObject(mParForm), 'ParForm');
    mPanel := TPanel.Create(mParForm);
    with mPanel do begin
      Parent := mParForm;
      Align := alClient;
      Name := 'MyPanel';
      SetPropValue(mPanel, 'Caption', ''); // Tady takhle, protože na TPanel zatím není vyveden Caption
      Color := AColor;
      mActualTop := 16;
    end;
    for i:=0 to ANames.Count-1 do begin
      //šířku formu nastavujeme pouze podle prvního vstupu
      mWidthForm := iGetProp(cParamName_WidthForm, cDataType_Int, mParForm.Width, ss);
      if i = 0 then
        mParForm.Width := mWidthForm;
      ss.Text := ANames[i];
      mNameProp := iGetProp(cParamName_Name, cDataType_String, 'no_defined', ss);
      mDataType := iGetProp(cParamName_DataType, cDataType_Int, cDataType_String, ss);
      mDisplayProp := iGetProp(cParamName_DisplayName, cDataType_String, mNameProp, ss);
      mIntFormat := iGetProp(cParamName_IntFormat, cDataType_String, '', ss);
      mMaskFormat := iGetProp(cParamName_MaskFormat, cDataType_String, '', ss);
      mWidthProp := iGetProp(cParamName_Size, cDataType_Int, cDefaultWidthProp, ss);
			mOrigWidthProp := mWidthProp = cDefaultWidthProp;
      mMultiSelect := iGetProp(cParamName_RollMultiSelect, cDataType_Boolean, False, ss);
      mSaveForUser := iGetProp(cParamName_SaveForUser, cDataType_Boolean, False, ss);
      mParamEnum := iGetProp(cParamName_ParamNames, cDataType_String, '', ss);
      mFileFilter := iGetProp(cParamName_FileFilter, cDataType_String, 'All files|*.*', ss);
      mLabelFontSize := iGetProp(cParamName_LabelFontSize, cDataType_Int, mPanel.Font.Size, ss);
      mLabelFontColor := iGetProp(cParamName_LabelFontColor, cDataType_Int, mPanel.Font.Color, ss);
      mDecimalPlaces := iGetProp(cParamName_DecimalPlaces, cDataType_Int, 2, ss);
      mColorLine := iGetProp(cParamName_ColorLine, cDataType_Int, clBtnFace, ss);
      mX_Move := iGetProp(cParamName_X_Move, cDataType_Int, 0, ss);
      mY_Move := iGetProp(cParamName_Y_Move, cDataType_Int, 0, ss);
      mNoLabel := iGetProp(cParamName_NoLabel, cDataType_Boolean, False, ss);
      if mNoLabel then
        mDisplayProp := '';
      s := iGetProp(cParamName_LabelFontStyles, cDataType_String, '', ss);
      mLabelFontStyles := 0;
      if Pos('fsBold', s) > 0 then
        NxSetBit(mLabelFontStyles, fsBold);
      if Pos('fsStrikeOut', s) > 0 then
        NxSetBit(mLabelFontStyles, fsStrikeOut);
      if Pos('fsItalic', s) > 0 then
        NxSetBit(mLabelFontStyles, fsItalic);
      if Pos('fsUnderline', s) > 0 then
        NxSetBit(mLabelFontStyles, fsUnderline);
      mIndent := iGetProp(cParamName_Indent, cDataType_Int, cDefaultIndent, ss);
      if mX_Move <> 0 then
        mIndent := mX_Move;
      mActualTop := mActualTop + mY_Move;
      mPrefix := iGetProp(cParamName_SaveWithPrefix, cDataType_String, '', ss);
      if mSaveForUser then begin
        if Assigned(gPersistParamContext) then begin
          mValueProp := GetValueFromStorageForUserII(mNameProp, gPersistParamContext, mPrefix);
          mValuePropHigh := GetValueFromStorageForUserII(mNameProp + '.High', gPersistParamContext, mPrefix);
        end
        else begin
          mValueProp := GetValueFromStorageForUser(mNameProp, nil, mPrefix);
          mValuePropHigh := GetValueFromStorageForUser(mNameProp + '.High', nil, mPrefix);
        end
      end
      else begin
        if Assigned(gPersistParamContext) then begin
          mValueProp := GetValueFromStorageII(mNameProp, gPersistParamContext, mPrefix);
          mValuePropHigh := GetValueFromStorageII(mNameProp + '.High', gPersistParamContext, mPrefix);
        end
        else begin
          mValueProp := GetValueFromStorage(mNameProp, nil, mPrefix);
          mValuePropHigh := GetValueFromStorage(mNameProp + '.High', nil, mPrefix);
        end;
      end;
      mDefault := (mValueProp = '') and (mValuePropHigh = '');
      if mValueProp = '' then
        mValueProp := iGetProp(cParamName_DefaultValue, mDataType, iGetDefault(mDataType), ss)
      else
        mValueProp := iConvert(mValueProp, mDataType);
      if mValuePropHigh = '' then
        mValuePropHigh := iGetProp(cParamName_DefaultValueHigh, mDataType, iGetDefault(mDataType), ss)
      else
        mValuePropHigh := iConvert(mValuePropHigh, mDataType);
      mDefault := mDefault and not AOnlyInputDialog;
      if not(mDataType in [cDataType_Boolean, cDataType_Enum, cDataType_Label, cDataType_InsertLine]) and
        (mDisplayProp <> 'no_defined') then
        with TLabel.Create(mParForm) do begin
          Parent := mPanel;
          Name := 'lbl' + mNameProp;
          ss.Values['CompName'] := Name;
          ss.Add(Name + '=');
          Left := mIndent;
          Top := mActualTop;
          mActualTop := Top + 16;
          Caption := mDisplayProp;
          Font.Color := mLabelFontColor;
          Font.Size := mLabelFontSize;
          Font.Style := mLabelFontStyles;
          if mDefault then
            Caption := Caption + ' (NEULOŽENO)';
        end;
      if iGetProp(cParamName_WithoutLoad, cDataType_Boolean, False, ss) then begin
        mValueProp := iGetDefault(mDataType);
        mValuePropHigh := iGetDefault(mDataType);
      end;
      case mDataType of
        cDataType_String:
          with TEdit.Create(mParForm) do begin
            Parent := mPanel;
            Name := 'ed' + mNameProp;
            ss.Values['CompName'] := Name;
            ss.Add(Name + '=');
            Hint := mNameProp;
            Left := mIndent;
            Top := mActualTop;
            Width := mWidthProp;
            Text := mValueProp;
            EditMask := mMaskFormat;
            if mDefault then begin
              Font.Color := clRed;
              Color := clYellow;
            end;
            if mOrigWidthProp then
              Tag := 3;
            Inc(mActualTop, cDefaultStepHeight);
          end;
        cDataType_Combo:
          with TComboBox.Create(mParForm) do begin
            Parent := mPanel;
            Name := 'cb' + mNameProp;
            ss.Values['CompName'] := Name;
            ss.Add(Name + '=');
            Hint := mNameProp;
            Left := mIndent;
            Top := mActualTop;
            Width := mWidthProp;
            Style := csDropDownList;
            ScTokenToStrings(mParamEnum, ';', ss2);
            for j:=ss2.Count-1 downto 0 do
              if ss2[j] = '' then
                ss2.Delete(j);
            Items.Assign(ss2);
            Text := mValueProp;
            if mDefault then begin
              Font.Color := clRed;
              Color := clYellow;
            end;
            if mOrigWidthProp then
              Tag := 3;
            Inc(mActualTop, cDefaultStepHeight);
          end;
        cDataType_Time:
          with TEdit.Create(mParForm) do begin
            Parent := mPanel;
            Name := 'ed' + mNameProp;
            ss.Values['CompName'] := Name;
            ss.Add(Name + '=');
            Hint := mNameProp;
            Left := mIndent;
            Top := mActualTop;
            if mOrigWidthProp then
              Width := mWidthProp
            else
              Width := 100;
            EditMask := '!90:00;1;_';
            Text := mValueProp;
            if mDefault then begin
              Font.Color := clRed;
              Color := clYellow;
            end;
            if mOrigWidthProp then
              Tag := 3;
            Inc(mActualTop, cDefaultStepHeight);
          end;
        cDataType_Memo:
          with TMemo.Create(mParForm) do begin
            Parent := mPanel;
            Name := 'ed' + mNameProp;
            ss.Values['CompName'] := Name;
            ss.Add(Name + '=');
            Hint := mNameProp;
            Height := cDefaultStepHeight*3;
            Left := mIndent;
            Top := mActualTop;
            Width := mWidthProp;
            ScrollBars := ssVertical;
            Text := mValueProp;
            if mDefault then begin
              Font.Color := clRed;
              Color := clYellow;
            end;
            if mOrigWidthProp then
              Tag := 3;
            Inc(mActualTop, cDefaultStepHeight*3);
          end;
        cDataType_Password:
          with TEdit.Create(mParForm) do begin
            Parent := mPanel;
            Name := 'ed' + mNameProp;
            ss.Values['CompName'] := Name;
            ss.Add(Name + '=');
            Hint := mNameProp;
            Left := mIndent;
            Top := mActualTop;
            Width := mWidthProp;
            PasswordChar := '*';
            Text := mValueProp;
            if mDefault then begin
              Font.Color := clRed;
              Color := clYellow;
            end;
            Inc(mActualTop, cDefaultStepHeight);
          end;
        cDataType_File: begin
          with TEdit.Create(mParForm) do begin
            Parent := mPanel;
            Name := 'ed' + mNameProp;
            ss.Values['CompName'] := Name;
            ss.Add(Name + '=');
            Hint := mNameProp;
            Left := mIndent;
            Top := mActualTop;
            Width := mWidthProp;
            Text := mValueProp;
            if mDefault then begin
              Font.Color := clRed;
              Color := clYellow;
            end;
            if mOrigWidthProp then
              Tag := 3;
          end;
          with TSpeedButton.Create(mParForm) do begin
            Parent := mPanel;
            Name := 'btn' + mNameProp;
            ss.Values['CompName'] := Name;
            ss.Add(Name + '=');
            Hint := mNameProp;
            Left := mWidthProp;
            Top := mActualTop - 2;
            Caption := '...';
            OnClick := @OnFileClick;
            HelpKeyword := mFileFilter;
            Tag := 4;
          end;
          Inc(mActualTop, cDefaultStepHeight);
        end;
        cDataType_Folder: begin
          with TDirectoryEdit.Create(mParForm) do begin
            Parent := mPanel;
            Name := 'ed' + mNameProp;
            ss.Values['CompName'] := Name;
            ss.Add(Name + '=');
            Hint := mNameProp;
            Left := mIndent;
            Top := mActualTop;
            Width := mWidthProp;
            EditText := mValueProp;
            if mDefault then begin
              Font.Color := clRed;
              Color := clYellow;
            end;
            if mOrigWidthProp then
              Tag := 3;
          end;
          Inc(mActualTop, cDefaultStepHeight);
        end;
        cDataType_Roll: begin
          mEdit := TEdit.Create(mParForm);
          with mEdit do begin
            Parent := mPanel;
            Name := 'ed' + mNameProp;
            ss.Values['CompName'] := Name;
            ss.Add(Name + '=');
            Hint := mNameProp;
            Left := mIndent;
            Top := mActualTop;
            Width := Round(mWidthProp / 4);
            if Pos('_ID', mNameProp) = Length(mNameProp) - 2 then begin
              mRoll := mOLE.GetRoll(iGetProp(cParamName_RollCLSID, cDataType_String, '', ss), 0);
              Text := mRoll.Lookup2(mValueProp, iGetProp(cParamName_RollFieldEdit, cDataType_String, mNameProp, ss));
            end
            else
              Text := mValueProp;
            OnChange := @OnChangeEditRoll;
            if mDefault then begin
              Font.Color := clRed;
              Color := clYellow;
            end;
          end;
          with TButton.Create(mParForm) do begin
            Parent := mPanel;
            Name := 'btn' + mNameProp;
            ss.Values['CompName'] := Name;
            ss.Add(Name + '=');
            Left := mEdit.Left + mEdit.Width;
            Top := mActualTop;
            Width := 20;
            Caption := '...';
            OnClick := @OnClickRoll;
            Hint := ss.Text;
          end;
          mStatic := TStaticText.Create(mParForm);
          with mStatic do begin
            Parent := mPanel;
            Name := 'stx' + mNameProp;
            ss.Values['CompName'] := Name;
            ss.Add(Name + '=');
            Hint := mNameProp;
            Left := mEdit.Left + mEdit.Width + 20;
            Top := mActualTop;
            Width := Round(mWidthProp / 4 * 3 - 20);
            if mMultiSelect then
              Height := Height + 26
            else
              Height := Height + 4;
            BevelKind := bkFlat;
            BevelInner := bvLowered;
            BevelOuter := bvRaised;
            AutoSize := False;
            if mOrigWidthProp then
              Tag := 3;
            SetRollStaticText(ss, mStatic);
          end;
          if mMultiSelect then
            Inc(mActualTop, 50)
          else
            Inc(mActualTop, cDefaultStepHeight);
        end;
        cDataType_Agend: begin
          mEdit := TEdit.Create(mParForm);
          with mEdit do begin
            Parent := mPanel;
            Name := 'ed' + mNameProp;
            ss.Values['CompName'] := Name;
            ss.Add(Name + '=');
            Hint := mNameProp;
            Left := mIndent;
            Top := mActualTop;
            Width := mWidthProp - 120;
            Text := GetIDByDocDisplayName(mOLE, mValueProp, iGetProp(cParamName_AgendTable, cDataType_String, '', ss));
            if Text <> '' then
              Text := mValueProp;
            if mDefault then begin
              Font.Color := clRed;
              Color := clYellow;
            end;
          end;
          with TButton.Create(mParForm) do begin
            Parent := mPanel;
            Name := 'btn' + mNameProp + '_1';
            ss.Values['CompName'] := Name;
            ss.Add(Name + '=');
            Left := mEdit.Left + mEdit.Width;
            Top := mActualTop;
            Width := 60;
            Caption := 'Ověřit';
            OnClick := @OnClickAgend_1;
            Hint := ss.Text;
          end;
          with TButton.Create(mParForm) do begin
            Parent := mPanel;
            Name := 'btn' + mNameProp;
            ss.Values['CompName'] := Name;
            ss.Add(Name + '=');
            Left := mEdit.Left + mEdit.Width + 60;
            Top := mActualTop;
            Width := 60;
            Caption := 'Agenda';
            OnClick := @OnClickAgend;
            Hint := ss.Text;
          end;
          if mMultiSelect then
            Inc(mActualTop, 50)
          else
            Inc(mActualTop, cDefaultStepHeight);
        end;
        cDataType_Number: begin
          with TNumEdit.Create(mParForm) do begin
            Parent := mPanel;
            Name := 'ed' + mNameProp;
            ss.Values['CompName'] := Name;
            ss.Add(Name + '=');
            Hint := mNameProp;
            Left := mIndent;
            Top := mActualTop;
            Width := mWidthProp;
            Value := mValueProp;
            if mDefault then begin
              Font.Color := clRed;
              Color := clYellow;
            end;
            DecimalPlaces := mDecimalPlaces;
            //DisplayFormat := '0.' + Copy('00000000', 1, mDecimalPlaces);
          end;
          Inc(mActualTop, cDefaultStepHeight);
        end;
        cDataType_Number2: begin
          mCalcEdit := TNumEdit.Create(mParForm);
          with mCalcEdit do begin
            Parent := mPanel;
            Name := 'ed' + mNameProp + 'Low';
            ss.Values['CompName'] := Name;
            ss.Add(Name + '=');
            ss.Add(Name + '=');
            Hint := mNameProp;
            Left := mIndent;
            Top := mActualTop;
            Width := Round(mWidthProp / 2 - 10);
            Value := mValueProp;
            if mDefault then begin
              Font.Color := clRed;
              Color := clYellow;
            end;
            DecimalPlaces := mDecimalPlaces;
            //DisplayFormat := '0.' + Copy('00000000', 1, mDecimalPlaces);
          end;
          with TNumEdit.Create(mParForm) do begin
            Parent := mPanel;
            Name := 'ed' + mNameProp + 'High';
            ss.Values['CompName'] := Name;
            ss.Add(Name + '=');
            Hint := mNameProp + '.High';
            Left := mCalcEdit.Left + mCalcEdit.Width + 20;
            Top := mActualTop;
            Width := Round(mWidthProp / 2 - 10);
            Value := mValuePropHigh;
            if mDefault then begin
              Font.Color := clRed;
              Color := clYellow;
            end;
            DecimalPlaces := mDecimalPlaces;
            //DisplayFormat := '0.' + Copy('00000000', 1, mDecimalPlaces);
          end;
          Inc(mActualTop, cDefaultStepHeight);
        end;
        cDataType_Int: begin
          with TNumEdit.Create(mParForm) do begin
            Parent := mPanel;
            Name := 'ed' + mNameProp;
            ss.Values['CompName'] := Name;
            ss.Add(Name + '=');
            Hint := mNameProp;
            Left := mIndent;
            Top := mActualTop;
            Width := mWidthProp;
            DecimalPlaces := 0;
            Value := mValueProp;
            //if mIntFormat <> '' then
              //DisplayFormat := mIntFormat;
            if mDefault then begin
              Font.Color := clRed;
              Color := clYellow;
            end;
          end;
          Inc(mActualTop, cDefaultStepHeight);
        end;
        cDataType_Int2: begin
          mCalcEdit := TNumEdit.Create(mParForm);
          with mCalcEdit do begin
            Parent := mPanel;
            Name := 'ed' + mNameProp + 'Low';
            ss.Values['CompName'] := Name;
            ss.Add(Name + '=');
            Hint := mNameProp;
            Left := mIndent;
            Top := mActualTop;
            Width := Round(mWidthProp / 2 - 10);
            DecimalPlaces := 0;
            Value := mValueProp;
            //if mIntFormat <> '' then
            //  DisplayFormat := mIntFormat;
            if mDefault then begin
              Font.Color := clRed;
              Color := clYellow;
            end;
          end;
          with TNumEdit.Create(mParForm) do begin
            Parent := mPanel;
            Name := 'ed' + mNameProp + 'High';
            ss.Values['CompName'] := Name;
            ss.Add(Name + '=');
            Hint := mNameProp + '.High';
            Left := mCalcEdit.Left + mCalcEdit.Width + 20;
            Top := mActualTop;
            Width := Round(mWidthProp / 2 - 10);
            DecimalPlaces := 0;
            Value := mValuePropHigh;
            //if mIntFormat <> '' then
            //  DisplayFormat := mIntFormat;
            if mDefault then begin
              Font.Color := clRed;
              Color := clYellow;
            end;
          end;
          Inc(mActualTop, cDefaultStepHeight);
        end;
        cDataType_Date: begin
          with TDateEdit.Create(mParForm) do begin
            Parent := mPanel;
            Name := 'ed' + mNameProp;
            ss.Values['CompName'] := Name;
            ss.Add(Name + '=');
            Hint := mNameProp;
            Left := mIndent;
            Top := mActualTop;
            Width := mWidthProp;
            Date := mValueProp;
            if mDefault then begin
              Font.Color := clRed;
              Color := clYellow;
            end;
          end;
          Inc(mActualTop, cDefaultStepHeight);
        end;
        cDataType_Date2: begin
          mDateEdit := TDateEdit.Create(mParForm);
          with mDateEdit do begin
            Parent := mPanel;
            Name := 'ed' + mNameProp + 'Low';
            ss.Values['CompName'] := Name;
            ss.Add(Name + '=');
            Hint := mNameProp;
            Left := mIndent;
            Top := mActualTop;
            Width := Round(mWidthProp / 2 - 10);
            Date := mValueProp;
            if mDefault then begin
              Font.Color := clRed;
              Color := clYellow;
            end;
          end;
          with TDateEdit.Create(mParForm) do begin
            Parent := mPanel;
            Name := 'ed' + mNameProp + 'High';
            ss.Values['CompName'] := Name;
            ss.Add(Name + '=');
            Hint := mNameProp + '.High';
            Left := mDateEdit.Left + mDateEdit.Width + 20;
            Top := mActualTop;
            Width := Round(mWidthProp / 2 - 10);
            Date := mValuePropHigh;
            if mDefault then begin
              Font.Color := clRed;
              Color := clYellow;
            end;
          end;
          Inc(mActualTop, cDefaultStepHeight);
        end;
        cDataType_Boolean: begin
          mChkBox := TCheckBox.Create(mParForm);
          with mChkBox do begin
            Parent := mPanel;
            Name := 'chk' + mNameProp;
            ss.Values['CompName'] := Name;
            ss.Add(Name + '=');
            SetPropValue(mChkBox, 'Caption', mDisplayProp);
//              Caption := mDisplayProp; - chyba ve scriptingu
            Hint := mNameProp;
            Left := mIndent;
            Top := mActualTop;
            Width := mWidthProp;
            Checked := mValueProp;
            if mDefault then begin
              Font.Color := clRed;
              Color := clYellow;
            end;
          end;
          Inc(mActualTop, cDefaultStepHeight);
        end;
        cDataType_Enum: begin
          mRGroup := TRadioGroup.Create(mParForm);
          with mRGroup do begin
            Parent := mPanel;
            Name := 'rg' + mNameProp;
            ss.Values['CompName'] := Name;
            ss.Add(Name + '=');
            Hint := mNameProp;
            Left := mIndent;
            Top := mActualTop;
            Width := mWidthProp;
            ScTokenToStrings(mParamEnum, ';', ss2);
            for j:=ss2.Count-1 downto 0 do
              if ss2[j] = '' then
                ss2.Delete(j);
            Items.Assign(ss2);
            Height := 20 + 20 * Items.Count;
            Caption := mDisplayProp;
            ItemIndex := mValueProp;
          end;
          Inc(mActualTop, mRGroup.Height);
        end;
        cDataType_InsertLine: begin
          mLine := TPanel.Create(mParForm);
          with mLine do begin
            Parent := mPanel;
            Name := 'pn' + NxUniqueID(5);
            Left := mIndent;
            Top := mActualTop;
            if mOrigWidthProp then
              Width := mWidthProp
            else
              Tag := 5;
            Height := 8;
            SetPropValue(mLine, 'Caption', '');
            SetPropValue(mLine, 'Color', mColorLine);
            if mOrigWidthProp then
              Anchors := [akLeft, akRight, akTop];
          end;
          Inc(mActualTop, 12);
        end;
        cDataType_Label: begin
          with TLabel.Create(mParForm) do begin
            Parent := mPanel;
            Name := 'txt' + NxUniqueID(5);
            Left := mIndent;
            Top := mActualTop;
            AutoSize := True;
            Caption := mDisplayProp;
            Font.Color := mLabelFontColor;
            Font.Size := mLabelFontSize;
            Font.Style := mLabelFontStyles;
          end;
          Inc(mActualTop, cDefaultStepHeight - mPanel.Font.Size + mLabelFontSize);
        end;
      end;
      ANames[i] := ss.Text;
    end;
    mBTNOK := TButton.Create(mParForm);
    with mBTNOK do begin
      Parent := mPanel;
      Name := 'btnMySave';
      Left := mPanel.Width - 170;
      Top := mActualTop + 16;
      Width := 75;
      Height := 25;
      Caption := 'OK';
      OnClick := @OnClickSave;
      Hint := mPrefix;
      Default := True;
      Anchors := [akRight,akBottom];
    end;
    mBTNST := TButton.Create(mParForm);
    with mBTNST do begin
      Parent := mPanel;
      Name := 'btnMyBack';
      Left := mPanel.Width - 90;
      Top := mActualTop + 16;
      Width := 75;
      Height := 25;
      Caption := 'Storno';
      OnClick := @OnClickBack;
      Anchors := [akRight,akBottom];
    end;
    mParForm.Height := mActualTop + 70;
    mBTNOK.Top := mActualTop;
    mBTNST.Top := mActualTop;
    mParForm.ShowModal(mParForm);
  finally
    ClearLocalObject('TempParams');
    Result := mParForm.Tag = 1;
    ss.Free;
    ss2.Free;
    mParForm.Free;
  end;
end;

begin
end.
