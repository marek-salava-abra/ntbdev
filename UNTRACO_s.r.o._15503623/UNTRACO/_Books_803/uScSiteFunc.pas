const
  cSiteForm = 'ActSite'; // základní část názvu konstanty pro identifikaci SiteFormu v GlobData
  cSiteFormComp = 'CompActSite'; // základní část názvu konstanty pro identifikaci proměnné příslušné k SiteFormu v GlobData

// Čtení globální proměnné
function GetValue(AName: string; ADataType: TNxDataType = dtString): Variant;
begin
  case ADataType of
    dtString: Result := GlobParams.ParamAsString(AName, '');
    dtInteger: Result := GlobParams.ParamAsInteger(AName, 0);
    dtFloat: Result := GlobParams.ParamAsFloat(AName, 0);
    dtDate, dtDateTime: Result := GlobParams.ParamAsDateTime(AName, 0);
    dtBoolean: Result := GlobParams.ParamAsBoolean(AName, False);
    else Result := Null;
  end;
end;

// Zápis globální proměnné
procedure SetValue(AName: string; AValue: Variant; ADataType: TNxDataType = dtString);
begin
  case ADataType of
    dtString: GlobParams.GetOrCreateParam(ADataType, AName).AsString := AValue;
    dtInteger: GlobParams.GetOrCreateParam(ADataType, AName).AsInteger := AValue;
    dtFloat: GlobParams.GetOrCreateParam(ADataType, AName).AsFloat := AValue;
    dtDate, dtDateTime: GlobParams.GetOrCreateParam(ADataType, AName).AsDateTime := AValue;
    dtBoolean: GlobParams.GetOrCreateParam(ADataType, AName).AsBoolean := AValue;
  end;
end;

// Výmaz globální proměnné
procedure DropValue(AName: string);
begin
  if GlobParams.ParamExist(AName) then
    GlobParams.ParamByName(AName).Free;
end;

// Uloží odkaz na objekt do GlobParams podle názvu
procedure SetLocalObject(AObject: TObject; AName: string);
var
  i: integer;
begin
  i := ObjToInt(AObject);
  GlobParams.GetOrCreateParam(dtInteger, AName).AsInteger := i;
end;

// Zjistí zda existuje v GlobParams object podle názvu
function ExistsLocalObject(AName: string): Boolean;
begin
  Result := GlobParams.ParamExist(AName);
end;

// Načte odkaz na objekt z GlobParams podle názvu
function GetLocalObject(AName: string): Variant;
var
  i: integer;
  mO: TObject;
begin
  i := GlobParams.ParamAsInteger(AName, 0);
  mO := IntToObj(i);
  Result := mO;
end;

// Zruší odkaz na objekt v GlobParams podle názvu
procedure ClearLocalObject(AName: string);
begin
  if GlobParams.ParamExist(AName) then
    GlobParams.Delete(GlobParams.IndexOfName(AName));
end;

// Zruší proměnnou z GlobParams podle názvu pro zadaný SiteForm
procedure DeleteLocalSiteparam(AName: string; ASite: TSiteForm);
var
  i: integer;
  mSite: TSiteForm;
  mName: String;
begin
  mSite := ASite;
  if not Assigned(mSite) then
    if not TestRegularSite(mSite, '') then
      Exit;
  i := ObjToInt(mSite);
  mName := cSiteFormComp + '_' + IntToStr(i) + '_' + AName;
  if GlobParams.ParamExist(mName) then
    GlobParams.Delete(GlobParams.IndexOfName(mName));
end;

// Načte proměnnou z GlobParams podle názvu pro zadaný SiteForm
function GetLocalSiteParam(AName: string; AType: TNxDataType; ASite: TSiteForm): Variant;
var
  i, j: integer;
  mSite: TSiteForm;
begin
  Result := Null;
  mSite := ASite;
  if not Assigned(mSite) then
    if not TestRegularSite(mSite, '') then
      Exit;
  j := ObjToInt(mSite);
  case AType of
    dtString: Result := GlobParams.ParamAsString(cSiteFormComp + '_' + IntToStr(j) + '_' + AName, '');
    dtInteger: Result := GlobParams.ParamAsInteger(cSiteFormComp + '_' + IntToStr(j) + '_' + AName, 0);
    dtFloat: Result := GlobParams.ParamAsFloat(cSiteFormComp + '_' + IntToStr(j) + '_' + AName, 0);
    dtBoolean: Result := GlobParams.ParamAsBoolean(cSiteFormComp + '_' + IntToStr(j) + '_' + AName, False);
    dtDateTime: Result := GlobParams.ParamAsDateTime(cSiteFormComp + '_' + IntToStr(j) + '_' + AName, 0);
    else Result := GlobParams.ParamAsVariant(cSiteFormComp + '_' + IntToStr(j) + '_' + AName, Null);
  end;
end;

// Uloží proměnnou do GlobParams podle názvu pro zadaný SiteForm
procedure SetLocalSiteParam(AParam: Variant; AName: string; AType: TNxDataType; ASite: TSiteForm);
var
  i, j: integer;
  mSite: TSiteForm;
begin
  mSite := ASite;
  if not Assigned(mSite) then
    if not TestRegularSite(mSite, '') then
      Exit;
  j := ObjToInt(mSite);
  case AType of
    dtString: GlobParams.GetOrCreateParam(dtString, cSiteFormComp + '_' + IntToStr(j) + '_' + AName).AsString := AParam;
    dtInteger: GlobParams.GetOrCreateParam(dtInteger, cSiteFormComp + '_' + IntToStr(j) + '_' + AName).AsInteger := AParam;
    dtFloat: GlobParams.GetOrCreateParam(dtFloat, cSiteFormComp + '_' + IntToStr(j) + '_' + AName).AsFloat := AParam;
    dtBoolean: GlobParams.GetOrCreateParam(dtBoolean, cSiteFormComp + '_' + IntToStr(j) + '_' + AName).AsBoolean := AParam;
    dtDateTime: GlobParams.GetOrCreateParam(dtDateTime, cSiteFormComp + '_' + IntToStr(j) + '_' + AName).AsDateTime := AParam;
    else GlobParams.GetOrCreateParam(dtString, cSiteFormComp + '_' + IntToStr(j) + '_' + AName).AsVariant := AParam;
  end;
end;

// Načte odkaz na objekt z GlobParams podle názvu pro aktuální SiteForm
function GetLocalSiteObject(AName: string; ASite: TSiteForm): Variant;
var
  i, j, k: integer;
  mO: TObject;
  mSite: TSiteForm;
begin
  Result := Null;
  mSite := ASite;
  if not Assigned(mSite) then
    if not TestRegularSite(mSite, '') then
      Exit;
  j := ObjToInt(mSite);
  i := GlobParams.ParamAsInteger(cSiteFormComp + '_' + IntToStr(j) + '_' + AName, 0);
  mO := IntToObj(i);
  Result := mO;
end;

// Uloží odkaz na objekt do GlobParams podle názvu pro aktuální SiteForm
procedure SetLocalSiteObject(AObject: TObject; AName: string; ASite: TSiteForm);
var
  i, j: integer;
  mSite: TSiteForm;
begin
  mSite := ASite;
  if not Assigned(mSite) then
    if not TestRegularSite(mSite, '') then
      Exit;
  i := ObjToInt(AObject);
  j := ObjToInt(mSite);
  GlobParams.GetOrCreateParam(dtInteger, cSiteFormComp + '_' + IntToStr(j) + '_' + AName).AsInteger := i;
end;

// Zruší odkaz na objekt v GlobParams podle názvu pro aktuální SiteForm
procedure ClearLocalSiteObject(AName: string; ASite: TSiteForm);
var
  i: integer;
  mSite: TSiteForm;
begin
  if not Assigned(ASite) then
    if not TestRegularSite(mSite, 'ClearLocalSiteObject') then
      Exit
    else
  else
    mSite := ASite;
  i := ObjToInt(mSite);
  if GlobParams.ParamExist(cSiteFormComp + '_' + IntToStr(i) + '_' + AName) then
    GlobParams.Delete(GlobParams.IndexOfName(cSiteFormComp + '_' + IntToStr(i) + '_' + AName));
end;

// Uloží odkaz na SiteForm
procedure MemberSiteForm(ASite: TSiteForm);
var
  i, j: Integer;
  s: String;
begin
  i := ObjToInt(ASite);
  if i = 0 then
    Exit;
  s := cSiteForm + '_' + ASite.Name + '_' + IntToStr(i);
  if ExistsLocalObject(s) then begin
    j := GlobParams.GetOrCreateParam(dtInteger, 'Stack_' + s).AsInteger;
    GlobParams.GetOrCreateParam(dtInteger, 'Stack_' + s).AsInteger := j + 1;
  end
  else begin
    SetLocalObject(ASite, s);
    GlobParams.GetOrCreateParam(dtInteger, 'Stack_' + s).AsInteger := 1;
  end;
end;

// Zruší odkaz na SiteForm
procedure UnMemberSiteForm(ASite: TSiteForm);
var
  i, j: integer;
  s: String;
  mParam: TNxParameter;
  
  // Zruší všechny odkazy na objekty v GlobParams pro aktuální SiteForm
  // AIdentSite je tady Integer(SiteForm)
  procedure iClearAllLocalSiteObjects(AIdentSite: Integer);
  var
    i, k: integer;
    mSite: TSiteForm;
  begin
    for i:=GlobParams.Count-1 downto 0 do
      if Pos(cSiteFormComp + '_' + IntToStr(AIdentSite) + '_', GlobParams.Params[i].Name) = 1 then
        GlobParams.Delete(i);
  end;

  procedure iClearSiteForm(ASite: TSiteForm);
  var
    i, j, k: integer;
    mSite: TSiteForm;
    mO: TObject;
    s: String;
  begin
    k := ObjToInt(ASite);
    s := cSiteForm + '_' + ASite.Name + '_' + IntToStr(k);
    i := GlobParams.IndexOfName(s);
    if i >= 0 then
      GlobParams.Delete(i);
  end;

begin
  i := ObjToInt(ASite);
  if i = 0 then
    Exit;
  try
    s := cSiteForm + '_' + ASite.Name + '_' + IntToStr(i);
    mParam := GlobParams.GetOrCreateParam(dtInteger, 'Stack_' + s);
    j := mParam.AsInteger;
    if j < 2 then begin
      iClearAllLocalSiteObjects(i);
      iClearSiteForm(ASite);
      i := GlobParams.IndexOfName('Stack_' + s);
      if i >= 0 then
        GlobParams.Delete(i);
    end
    else
      mParam.AsInteger := j - 1;
  except
  end;
end;

function EnumSites: String;
var
  i: Integer;
begin
  Result := 'Seznam aktivních sitů:';
  for i:=0 to GlobParams.Count-1 do
    if Pos(cSiteForm, GlobParams.Params[i].Name) = 1 then
      Result := Result + #13#10 + GlobParams.Params[i].Name;
end;

// Načte odkaz na aktuální SiteForm - ten co je uživatelem právě vybrán
// Site, který nemá focus, vrací v GetSiteAppForm sám sebe a není visible
// POZOR - Site musí být Visible (aktivní)
function ActualSiteForm: TSiteForm;
var
  i, j, k: integer;
  mO, mO2: TForm;
begin
  Result := nil;
  for i:= GlobParams.Count-1 downto 0 do
    if Pos(cSiteForm, GlobParams.Params[i].Name) = 1 then begin
      j := GlobParams.ParamAsInteger(GlobParams.Params[i].Name, 0);
      mO2 := TForm(IntToObj(j));
      try
        mO := TSiteForm(mO2).GetSiteAppForm;
        k := ObjToInt(mO);
        if (j <> k) then // mělo by to nastat max. pouze jednou
          Result := TSiteForm(mO2);
      except
        GlobParams.Delete(i);
      end;
    end;
end;

function ActualSiteAppForm: TForm;
var
  mSite: TSiteForm;
begin
  mSite := ActualSiteForm;
  if Assigned(mSite) then
    Result := TForm(mSite.GetSiteAppForm)
  else
    Result := nil;
end;

// Zjistí, zda je ASite regulérní TSiteForm, pokud ne, zkusí ho získat z globálních
// nastavení, Result vrací úspěšnost testu, vypisuje varovný message, pokud je nastaven
// ACaller
function TestRegularSite(var ASite: TSiteForm; ACaller: string = ''): boolean;
begin
  if not Assigned(ASite) or not(ASite is TSiteForm) then
    ASite := ActualSiteForm;
  Result := Assigned(ASite);
  if not Assigned(Result) and (ACaller <> '') then
    MessageDlg(ACaller + ': Nenalezen TSiteForm v aktivním uložení!', mtError, [mbOk], 0);
end;

begin
end.
