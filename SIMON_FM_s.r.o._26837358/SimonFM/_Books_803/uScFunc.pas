uses
  '_Books_803.uScSiteFunc';

// Vrátí aktuální hlavičkový dataset
function GetCurrentHeaderDataset(ASite: TSiteForm): TDataSet;
var
  mDS: TDataSource;
  mGrid: TDBGrid;
begin
  try
    mGrid := TDBGrid(ScFindControl('grdList', ASite));
    mDS := GetPropValue(mGrid, 'DataSource');
    Result := GetPropValue(mDS, 'Dataset');
  except
    Result := nil;
  end;
end;

// Vrátí aktuální řádkový dataset - předpoklad je, že agenda vlastní řádky
function GetCurrentRowDataset(ASite: TSiteForm): TDataSet;
var
  mDS: TDataSource;
  mGrid: TDBGrid;
begin
  try
    mGrid := TDBGrid(ScFindControl('grdRows', ASite));
    mDS := GetPropValue(mGrid, 'DataSource');
    Result := GetPropValue(mDS, 'Dataset');
  except
    Result := nil;
  end;
end;

// Vrátí aktuální objekt seznamu podle TSiteForm
function GetCurrentHeader(ASite: TSiteForm): TNxHeaderBusinessObject;
begin
  Result := nil;
  if not TestRegularSite(ASite, 'GetCurrentHeader') then
    Exit;
  if ASite is TDynSiteForm then
    Result := TNxHeaderBusinessObject(TDynSiteForm(ASite).CurrentObject);
end;

// Vrátí aktuální objekt z řádků z řádkového gridu - předpoklad je, že agenda
// vlastní řádky
function GetActiveRow(AGrdRows: TComponent): TNxCustomBusinessObject;
var
  mDS: TDataSource;
  mDSet: TDataset;
begin
  try
    mDS := GetPropValue(AGrdRows, 'DataSource');
    mDSet := GetPropValue(mDS, 'Dataset');
    Result := TNxRowsObjectDataset(mDSet).ActiveObject;
  except
    Result := nil;
  end;
end;

// Vrátí počet řádků - předpoklad je, že agenda vlastní řádky
function GetCountRow(ASite: TSiteForm = Nil): integer;
var
  mHeader: TNxHeaderBusinessObject;
begin
  Result := nil;
  if not TestRegularSite(ASite, 'GetRow') then
    Exit;
  mHeader := GetCurrentHeader(ASite);
  Result := mHeader.Rows.Count;
end;

// Vrátí BusinessObject řádky podle indexu - předpoklad je, že agenda vlastní řádky
function GetRow(AIndex: integer; ASite: TSiteForm = Nil): TNxCustomBusinessObject;
var
  mHeader: TNxHeaderBusinessObject;
begin
  Result := nil;
  if not TestRegularSite(ASite, 'GetRow') then
    Exit;
  mHeader := GetCurrentHeader(ASite);
  if mHeader.Rows.Count > AIndex then
    Result := mHeader.Rows.BusinessObject[AIndex];
end;

// Rušení persistentních dat přes TNxCompanyCache - náhrada INI souboru
// Zatím podpora pouze pro string
procedure DeleteValueFromStorage(AName: string; ASite: TSiteForm; AAgend: String= '');
begin
  if not TestRegularSite(ASite, 'DeleteValueFromStorage') then
    Exit;
  if AAgend <> '' then
    AName := AAgend + '_' + AName;
  ASite.CompanyCache.DeletePropertiesForCompany(AName);
end;

procedure DeleteValueFromStorageII(AName: string; AContext: TNxContext; AAgend: String= '');
begin
  if AAgend <> '' then
    AName := AAgend + '_' + AName;
  AContext.GetCompanyCache.DeletePropertiesForCompany(AName);
end;

// Rušení persistentních dat přes TNxCompanyCache - náhrada INI souboru
// Zatím podpora pouze pro string
// na uživatele
procedure DeleteValueFromStorageForUser(AName: string; ASite: TSiteForm; AAgend: String= '');
begin
  if not TestRegularSite(ASite, 'DeleteValueFromStorageForUser') then
    Exit;
  if AAgend <> '' then
    AName := AAgend + '_' + AName;
  ASite.CompanyCache.DeleteProperties(AName);
end;

procedure DeleteValueFromStorageForUserII(AName: string; AContext: TNxContext; AAgend: String= '');
begin
  if AAgend <> '' then
    AName := AAgend + '_' + AName;
  AContext.GetCompanyCache.DeleteProperties(AName);
end;

// Čtení persistentních dat přes TNxCompanyCache - náhrada INI souboru
// Zatím podpora pouze pro string
function GetValueFromStorage(AName: string; ASite: TSiteForm = nil; AAgend: String= ''; ADefault: String= ''): string;
var
  mPars: TNxParameters;
begin
  Result := ADefault;
  if not TestRegularSite(ASite, 'GetValueFromStorage') then
    Exit;
  mPars := TNxParameters.Create;
  try
    if AAgend <> '' then
      AName := AAgend + '_' + AName;
    ASite.CompanyCache.LoadPropertiesForCompany(AName, mPars);
    if mPars.ParamExist(AName) then
      Result := mPars.GetOrCreateParam(dtString, AName).AsString;
  finally
    mPars.Free;
  end;
end;

function GetValueFromStorageII(AName: string; AContext: TNxContext; AAgend: String= ''; ADefault: String= ''): string;
var
  mPars: TNxParameters;
begin
  Result := ADefault;
  mPars := TNxParameters.Create;
  try
    if AAgend <> '' then
      AName := AAgend + '_' + AName;
    AContext.GetCompanyCache.LoadPropertiesForCompany(AName, mPars);
    if mPars.ParamExist(AName) then
      Result := mPars.GetOrCreateParam(dtString, AName).AsString;
  finally
    mPars.Free;
  end;
end;

{GetValueFromStorage_OUT}
function GetValueFromStorage_OUT(AReportHelper:TNxQRScriptHelper; ANameParam:String):String;
var
  mContext: TNxContext;
begin
  mContext := NxCreateContext(AReportHelper.ObjectSpace);
  Result := GetValueFromStorageII(ANameParam, mContext);
end;

// Čtení persistentních dat přes TNxCompanyCache - náhrada INI souboru
// Zatím podpora pouze pro string
// na uživatele
function GetValueFromStorageForUser(AName: string; ASite: TSiteForm; AAgend: String= ''; ADefault: String= ''): string;
var
  mPars: TNxParameters;
begin
  Result := ADefault;
  if not TestRegularSite(ASite, 'GetValueFromStorageForUser') then
    Exit;
  mPars := TNxParameters.Create;
  try
    if AAgend <> '' then
      AName := AAgend + '_' + AName;
    ASite.CompanyCache.LoadProperties(AName, mPars);
    if mPars.ParamExist(AName) then
      Result := mPars.GetOrCreateParam(dtString, AName).AsString;
  finally
    mPars.Free;
  end;
end;

function GetValueFromStorageForUserII(AName: string; AContext: TNxContext; AAgend: String= ''; ADefault: String= ''): string;
var
  mPars: TNxParameters;
begin
  Result := ADefault;
  mPars := TNxParameters.Create;
  try
    if AAgend <> '' then
      AName := AAgend + '_' + AName;
    AContext.GetCompanyCache.LoadProperties(AName, mPars);
    if mPars.ParamExist(AName) then
      Result := mPars.GetOrCreateParam(dtString, AName).AsString;
  finally
    mPars.Free;
  end;
end;

{GetValueFromStorageForUser_OUT}
function GetValueFromStorageForUser_OUT(AReportHelper:TNxQRScriptHelper; ANameParam:String):String;
var
  mContext: TNxContext;
begin
  mContext := NxCreateContext(AReportHelper.ObjectSpace);
  Result := GetValueFromStorageForUserII(ANameParam, mContext);
end;

// Zápis persistentních dat přes TNxCompanyCache - náhrada INI souboru
// Zatím podpora pouze pro string
function SetValueToStorage(AName: string; AValue: string; ASite: TSiteForm; AAgend: String = ''): Boolean;
var
  mPars: TNxParameters;
begin
  Result := False;
  if not TestRegularSite(ASite, 'SetValueToStorage') then
    Exit;
  mPars := TNxParameters.Create;
  try
    if AAgend <> '' then
      AName := AAgend + '_' + AName;
    mPars.GetOrCreateParam(dtString, AName).AsString := AValue;
    try
      ASite.CompanyCache.SavePropertiesForCompany(AName, mPars);
      Result := True;
    except
      Result := False;
    end;
  finally
    mPars.Free;
  end;
end;

function SetValueToStorageII(AName: string; AValue: string; AContext: TNxContext; AAgend: String = ''): Boolean;
var
  mPars: TNxParameters;
begin
  Result := False;
  mPars := TNxParameters.Create;
  try
    if AAgend <> '' then
      AName := AAgend + '_' + AName;
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

// Zápis persistentních dat přes TNxCompanyCache - náhrada INI souboru
// Zatím podpora pouze pro string
// na uživatele
function SetValueToStorageForUser(AName: string; AValue: string; ASite: TSiteForm; AAgend: String = ''): Boolean;
var
  mPars: TNxParameters;
begin
  Result := False;
  if not TestRegularSite(ASite, 'SetValueToStorageForUser') then
    Exit;
  mPars := TNxParameters.Create;
  try
    if AAgend <> '' then
      AName := AAgend + '_' + AName;
    mPars.GetOrCreateParam(dtString, AName).AsString := AValue;
    try
      ASite.CompanyCache.SaveProperties(AName, mPars);
      Result := True;
    except
      Result := False;
    end;
  finally
    mPars.Free;
  end;
end;

function SetValueToStorageForUserII(AName: string; AValue: string; AContext: TNxContext; AAgend: String = ''): Boolean;
var
  mPars: TNxParameters;
begin
  Result := False;
  mPars := TNxParameters.Create;
  try
    if AAgend <> '' then
      AName := AAgend + '_' + AName;
    mPars.GetOrCreateParam(dtString, AName).AsString := AValue;
    try
      AContext.GetCompanyCache.SaveProperties(AName, mPars);
      Result := True;
    except
      Result := False;
    end;
  finally
    mPars.Free;
  end;
end;

// Připraví Form, který může zobrazovat informace o průběhu nějaké akce
// Vhodné pro déle trvající akce
// Použití: Po vytvoření touto procedurou se volá na něm .Show
// Přes ALabel se dá měnit zobrazovaný text
// Na konci akce je potřeba ho zrušit (Free)
function CreateFormInfo(ASite: TSiteForm; var ALabel: TLabel): TForm;
var
  mMyForm, mInfoForm: TForm;
  mPanel: TPanel;
  mLabel: TLabel;
  s: string;
begin
  Result := nil;
  if not TestRegularSite(ASite, 'CreateFormInfo') then
    Exit;
  mMyForm := TForm(ASite.GetSiteAppForm);
  mInfoForm := TForm.Create(mMyForm);
  Result := mInfoForm;
  with mInfoForm do begin
    Position := poOwnerFormCenter;
    Width := 418;
    Height := 109;
    Left := 0;
    Top := 0;
    Caption := 'Info';
    Color := clBtnFace;
    OldCreateOrder := False;
    BorderStyle := bsNone;
  end;
  mPanel := TPanel.Create(mInfoForm);
  with mPanel do begin
    mPanel.Parent := mInfoForm;
    Left := 44;
    Top := 36;
    Width := 409;
    Height := 77;
    Align := alClient;
    BevelWidth := 4;
  end;
  TLabel(mPanel).Caption := '';
  mLabel := TLabel.Create(mInfoForm);
  ALabel := mLabel;
  with mLabel do begin
    Parent := mPanel;
    Name := 'lblInfo';
    Left := 12;
    Top := 8;
    Width := 385;
    Height := 57;
    Anchors := [akLeft, akTop, akRight, akBottom];
    AutoSize := False;
    Caption := '';
    Color := 16776176;
    Font.Height := -13;
    Font.Style := [fsBold];
    ParentColor := False;
    ParentFont := False;
    Transparent := False;
    WordWrap := True;
  end;
end;

// Vytvoří multitlačítko na pravém panelu Abry, v AItems je seznam nadpisů tlačítek
// oddělených CRLF
procedure CreateMultiAction(ASite: TSiteForm; AItems: string; AOnExecute, AOnUpdate: Pointer;
  ACategory: string = 'tabList;tabDetail'; ACaption: string = ''; AHint: string = '');
var
  mMAction: TMultiAction;
begin
//  if not TestRegularSite(ASite, 'CreateMultiAction') then
//    Exit;
  mMAction := ASite.GetNewMultiAction;
  // Nastavime, aby se tato akce zobrazovala jako tlacitko
  mMAction.ShowControl := True;
  // Nastavime, aby se tato akce zobrazila v menu
  mMAction.ShowMenuItem := True;
  // Nastavime nadpisy tlačítek
  mMAction.Items.Text := AItems;
  if ACaption = '' then
    ACaption := mMAction.Items[0];
  mMAction.Caption := ACaption;
  // Nastavime hint
  mMAction.Hint := AHint;
  // Nastavime, aby se tato akce nabizela na zalozkach Seznam a Detail
  mMAction.Category := ACategory;
  // Nastavime udalost, ktera se vykona pri spusteni těchto akcí
  mMAction.OnExecuteItem := AOnExecute;
  // Nastavime udalost, v niz muzeme nastavovat dostupnost těchto akcí
  mMAction.OnUpdate := AOnUpdate;
  mMAction.ShortCutCtrlNumber := True;
end;

// Vrátí AbraOLE

function AbraOLE: Variant;
begin
  try
    Result := GetAbraOLEApplication;
  except
    Result := Null;
  end;
end;


// Vrátí ObjectSpace, pokud je nastavena globální proměnná SiteForm
// viz. fce MemberSiteForm
function ObjectSpace: TNxCustomObjectSpace;
begin
  Result := Nil;
  if not TestRegularSite(nil, 'ObjectSpace') then
    Exit;
  try
    Result := ActualSiteForm.BaseObjectSpace;
  except
    Result := Nil;
  end;
end;

// Vrátí SiteContext, pokud je nastavena globální proměnná SiteForm
// viz. fce MemberSiteForm
function SiteContext: TNxContext;
begin
  Result := Nil;
  if not TestRegularSite(nil, 'SiteContext') then
    Exit;
  try
    Result := ActualSiteForm.SiteContext;
  except
    Result := Nil;
  end;
end;

// Vrátí AppForm, pokud je nastavena globální proměnná SiteForm
// viz. fce MemberSiteForm
function AppForm: TForm;
begin
  Result := Nil;
  if not TestRegularSite(nil, '') then
    Exit;
  try
    Result := TForm(ActualSiteForm.GetSiteAppForm);
  except
    Result := Nil;
  end;
end;

// Hledá control podle jména - zatím asi jediná metoda získání controlu z formu
function ScFindControl(AName: string; ASite: TSiteForm = Nil): Variant;
var
  mSite: TSiteForm;
begin
  Result := nil;
  mSite := nil;
  if not Assigned(ASite) then
    mSite := ActualSiteForm
  else
    mSite := ASite;
  if Assigned(mSite) then
    Result := NxFindChildControl(mSite.GetSiteAppForm, AName);
end;

function VisualRequestOnFile(AFileName: string; AFilter: string = ''): string;
var
  mMyPanel: TPanel;
  mEdit: TEdit;
  i: integer;
  mDialog: TOpenDialog;
begin
  mDialog := TOpenDialog.Create(ActualSiteForm);
  try
    mDialog.FileName := AFileName;
    mDialog.Filter := AFilter;
    if mDialog.Execute then
      Result := mDialog.FileName
    else
      Result := '';
  finally
    mDialog.Free;
  end;
end;

// Hledá control podle jména - zatím asi jediná metoda získání controlu z formu
function ScFindControlWithoutName(AClassName: string; AParent: TWinControl; ASite: TSiteForm = Nil): Variant;
var
  mSite: TSiteForm;
  i: integer;
begin
  Result := nil;
  mSite := nil;
  if not Assigned(ASite) then
    if not TestRegularSite(mSite, 'ScFindControlWithoutName') then
      Exit
    else
  else
    mSite := ASite;
  if not Assigned(AParent) then
    AParent := mSite.GetSiteAppForm;
  for i:=0 to AParent.ControlCount-1 do begin
    if AParent.Controls[i].ClassName = AClassName then begin
      Result := AParent.Controls[i];
      Break;
    end;
    if AParent.Controls[i] is TWinControl then
      if TWinControl(AParent.Controls[i]).ControlCount > 0 then
        Result := ScFindControlWithoutName(AClassName, TWinControl(AParent.Controls[i]), mSite);
    if Assigned(Result) then
      Break;
  end;
end;

function ScCharPos(const AChars, AStr: string): Integer;
var
  i, j: Integer;
begin
  if Length(AChars) > Length(AStr) then begin
    Result := 0;
    for i:=1 to Length(AStr) do
      if Pos(AStr[i], AChars) > 0 then begin
        Result := i;
        Break;
      end;
  end
  else begin
    Result := Length(AStr) + 1;
    for i:=1 to Length(AChars) do begin
      j := Pos(AChars[i], AStr);
      if (j > 0) and (j < Result) then
        Result := j;
    end;
    if Result > Length(AStr) then
      Result := 0;
  end;
end;

function ScTrimL(const AStr: string; AChars: string = ' '): string;
begin
  Result := AStr;
  while Pos(Copy(Result, 1, 1), AChars) > 0 do
    Delete(Result, 1, 1);
end;

function ScToken(var AStr: string; const ASeparators: string): string;
var
  i: Integer;
begin
  AStr := ScTrimL(AStr, ASeparators);
  i := ScCharPos(ASeparators, AStr);
  if i > 0 then begin
    Result := Copy(AStr, 1, i-1);
    Delete(AStr, 1, i-1);
    AStr := ScTrimL(AStr, ASeparators);
  end
  else begin
    Result := AStr;
    AStr := '';
  end;
end;

procedure ScTokenToStrings(AStr: String; ASeparator: Char; AList: TStrings);
var
  mToken: string;
begin
  AList.Clear;
  mToken := ScToken(AStr, ASeparator);
  while mToken <> '' do begin
    AList.Add(mToken);
    mToken := ScToken(AStr, ASeparator);
  end;
  AList.Add(''); //pro jistotu, pokud bude poslední token prázdný, aby se na něj nezapomnělo
end;

{** To samé jako Token, ale respektuje i prázdné položky }
function TokenEx(var AStr: string; const ASeparators: string): string;
var
  i: Integer;
begin
  i := ScCharPos(ASeparators, AStr);
  if i > 0 then begin
    Result := Copy(AStr, 1, i-1);
    Delete(AStr, 1, i-1);
    Delete(AStr, 1, Length(ASeparators));
  end
  else begin
    Result := AStr;
    AStr := '';
  end;
end;

{** Respektuje i prázné tokeny }
procedure ScTokenToStringsEx(AStr: String; ASeparator: Char; AList: TStrings);
var
  mToken: string;
begin
  AList.Clear;
  mToken := TokenEx(AStr, ASeparator);
  while (AStr <> '') or (mToken <> '') do begin
    AList.Add(mToken);
    mToken := TokenEx(AStr, ASeparator) ;
  end;
  AList.Add(''); //pro jistotu, pokud bude poslední token prázdný, aby se na něj nezapomnělo
end;

function TrimQuote(AStr: string): string;
begin
  if (AStr <> '') and ((Copy(AStr,1,1) = '"') or (Copy(AStr,1,1) = '''')) then
    Delete(AStr, 1, 1);
  if (AStr <> '') and ((Copy(AStr, Length(AStr), 1) = '"') or (Copy(AStr, Length(AStr), 1) = '''')) then
    Delete(AStr, Length(AStr), 1);
  Result := AStr;
end;

//volání z "venku" - vrací uloženou hodnotu podle jména z CentralStorage
function GetStorageValue(AReportHelper: TNxQRScriptHelper; AName: string): String;
var
  mContext: TNxContext;
  mPars: TNxParameters;
begin
  mContext := NxCreateContext(AReportHelper.ObjectSpace);
  Result := '';
  mPars := TNxParameters.Create;
  try
    mContext.GetCompanyCache.LoadPropertiesForCompany(AName, mPars);
    Result := mPars.GetOrCreateParam(dtString, AName).AsString;
  finally
    mPars.Free;
  end;
end;

function GetDefaultPrinterName: String;
var
  mRegistry: TRegistry;
  mDW: DWORD;
begin
  mRegistry := TRegistry.Create(($001F0000 or $0001 or $0002 or $0004 or $0008 or $0010 or $0020) and not $00100000); //KEY_ALL_ACCESS?
  Result := '';
  with mRegistry do try
    mDW := $80000001;
    RootKey := -2147483647; //HKEY_CURRENT_USER
    if OpenKey('Software\Microsoft\Windows NT\CurrentVersion\Windows', False) then begin
      Result := ReadString('Device');
      Result := Copy(Result, 1, Pos(',', Result)-1);
      CloseKey;
    end
    else
      RaiseException('Nemohu otevřít klíč registrů.');
  finally
    Free;
  end;
end;

function CheckConnectionNameBySubStr(AOS: TNxCustomObjectSpace; ASub1, ASub2: string): Boolean;
begin
  Result := (Pos(UpperCase(ASub1), UpperCase(AOS.GetConnectionName)) > 0) or
    (Pos(UpperCase(ASub2), UpperCase(AOS.GetConnectionName)) > 0);
end;

//Test na existenci def. pole
function ExistsDefFld(AOS: TNxCustomObjectSpace; ACLSID, AFldName: String): Boolean;
var
  mOHead: TNxHeaderBusinessObject;
  mORow: TNxCustomBusinessObject;
  mID: String;
  mRows: TNxCustomBusinessMonikerCollection;
  i: Integer;
  mFldName: string;
  s: string;
  mIsExtra: Boolean;
  ss: TStringList;
begin
  ss := TStringList.Create;
  try
    mFldName := AFldName;
    mIsExtra := True;
    if UpperCase(Copy(mFldName, 1, 2)) = 'X_' then
      mFldName := Copy(mFldName, 3, 255)
    else
    if UpperCase(Copy(mFldName, 1, 2)) = 'U_' then begin
      mFldName := Copy(mFldName, 3, 255);
      mIsExtra := False;
    end;
    AOS.SQLSelect('select ID from UserFieldDefs where CLSID = ''' + ACLSID + '''', ss);
    if ss.Count = 1 then
      mID := ss[0]
    else
      mID := '';
    Result := False;
    if mID <> '' then begin
      mOHead := TNxHeaderBusinessObject(AOS.CreateObject('W1MZBIJR3VF13JXR00KEZYD5AW')); //UserFieldDef
      mOHead.Load(mID, nil);
      mRows := mOHead.GetLoadedCollectionMonikerForFieldCode(mOHead.GetFieldCode('Rows'));
      for i:=0 to mRows.Count -1 do begin
        mORow := mRows.BusinessObject[i];
        if SameText(mORow.GetFieldValueAsString('FieldName'), mFldName) then begin
          Result := True;
          Break;
        end;
      end;
    end;
  finally
    ss.Free;
  end;
end;

procedure AddColToDatasetMultiGrid(AMultiGrid: TMultiGrid; AFieldName: string;
  ADataType: TFieldType; AFieldKind: TFieldKind; ASize, AFieldNo: Integer;
  ARequired: Boolean; ACalcProc: Pointer);
var
  mMG: TMultiGrid;
  mFieldDef: TFieldDef;
  mField: TField;
  mFieldName: String;
  mSite: TSiteForm;
begin
  mMG := AMultiGrid;
  if Assigned(mMG) then begin
    mSite := NxFindSiteForm(mMG);
    if not ExistsDefFld(mSite.BaseObjectSpace,
      TNxCustomObjectDataSet(mMG.DataSource.DataSet).GetBusinessObjectCLSID, AFieldName) then
      Exit;
    mFieldName := AFieldName;
    if Assigned(ACalcProc) then
      mMG.DataSource.DataSet.OnCalcFields := ACalcProc;
    mFieldDef := TFieldDef.Create(mMG.DataSource.DataSet.FieldDefs,
      mFieldName, ADataType, ASize, ARequired, AFieldNo);
    mField := mFieldDef.CreateField(mMG.DataSource.DataSet, nil, mFieldName, False);
    with mField do begin
      ReadOnly := False;
      FieldName := mFieldName;
      FieldKind := AFieldKind;
    end;
  end;
end;

function ExecuteDLL(AOS: TNxCustomObjectSpace; AFileName: string; AData: string = ''): String;
var
  mMS: TMapStream;
  mFile: String;
  mOLE: Variant;
  mModule: Word;
  s, mParams: String;
  i: Integer;
begin
  Result := '';
  if Pos('.DLL', UpperCase(AFileName)) > 0 then begin
    try
      mOLE := GetAbraOLEApplication;
      mFile := AFileName;
      //mModule := NxDllCall('kernel32.dll', 'LoadLibraryA', 'Function(Str):Int', [mFile]);
{      for i:=0 to Screen.FormCount-1 do
        if Screen.Forms[i].Name = 'NxShellForm' then
          mParams := AData + #13#10'Owner=' + IntToStr(ObjToInt(Screen.Forms[i]));}
      mParams := AData + #13#10'Owner=' + IntToStr(ObjToInt(Screen.ActiveForm));
      //s := NxDllCall(mFile, 'Wizard', 'Function(Int,Str):Str', [DispatchFromVariant(mOLE), mParams]);
      //NxDllCall('kernel32.dll', 'FreeLibrary', 'Function(Int):Int', [mModule]);
    finally
      Result := s;
    end;
  end;
end;

begin
end.
