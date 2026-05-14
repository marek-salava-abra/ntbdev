// Rušení persistentních dat přes TNxCompanyCache - náhrada INI souboru
// Zatím podpora pouze pro string
procedure DeleteValueFromStorageOS(AName: string; AObjectSpace: TNxCustomObjectSpace; AAgend: String= '');
var
  mCon: TNxContext;
begin
  if VarIsNull(AObjectSpace) then
    exit;
  mCon := NxCreateContext(AObjectSpace);
  try
    if AAgend <> '' then
      AName := AAgend + '_' + AName;
    mCon.GetCompanyCache.DeletePropertiesForCompany(AName);
  finally
    mCon.Free;
  end;
end;

// Rušení persistentních dat přes TNxCompanyCache - náhrada INI souboru
// Zatím podpora pouze pro string
// na uživatele
procedure DeleteValueFromStorageForUserOS(AName: string; AObjectSpace: TNxCustomObjectSpace; AAgend: String= '');
var
  mCon: TNxContext;
begin
  if VarIsNull(AObjectSpace) then
    exit;
  mCon := NxCreateContext(AObjectSpace);
  try
    if AAgend <> '' then
      AName := AAgend + '_' + AName;
    mCon.GetCompanyCache.DeleteProperties(AName);
  finally
    mCon.Free;
  end;
end;

// Čtení persistentních dat přes TNxCompanyCache - náhrada INI souboru
// Zatím podpora pouze pro string
function GetValueFromStorageOS(AName: string; AObjectSpace: TNxCustomObjectSpace; AAgend: String= ''): string;
var
  mPars: TNxParameters;
  mCon: TNxContext;
begin
  Result := '';
  if VarIsNull(AObjectSpace) then
    exit;
  mCon := NxCreateContext(AObjectSpace);
  try
    mPars := TNxParameters.Create;
    try
      if AAgend <> '' then
        AName := AAgend + '_' + AName;
      mCon.GetCompanyCache.LoadPropertiesForCompany(AName, mPars);
      Result := mPars.GetOrCreateParam(dtString, AName).AsString;
    finally
      mPars.Free;
    end;
  finally
    mCon.Free;
  end;
end;

// Čtení persistentních dat přes TNxCompanyCache - náhrada INI souboru
// Zatím podpora pouze pro string
// na uživatele
function GetValueFromStorageForUserOS(AName: string; AObjectSpace: TNxCustomObjectSpace; AAgend: String= ''): string;
var
  mPars: TNxParameters;
  mCon: TNxContext;
begin
  Result := '';
  if VarIsNull(AObjectSpace) then
    exit;
  mCon := NxCreateContext(AObjectSpace);
  try
    mPars := TNxParameters.Create;
    try
      if AAgend <> '' then
        AName := AAgend + '_' + AName;
      mCon.GetCompanyCache.LoadProperties(AName, mPars);
      Result := mPars.GetOrCreateParam(dtString, AName).AsString;
    finally
      mPars.Free;
    end;
  finally
    mCon.Free;
  end;
end;

// Zápis persistentních dat přes TNxCompanyCache - náhrada INI souboru
// Zatím podpora pouze pro string
function SetValueToStorageOS(AName: string; AValue: string; AObjectSpace: TNxCustomObjectSpace; AAgend: String = ''): Boolean;
var
  mPars: TNxParameters;
  mCon: TNxContext;
begin
  Result := False;
  if VarIsNull(AObjectSpace) then
    exit;
  mCon := NxCreateContext(AObjectSpace);
  try
    mPars := TNxParameters.Create;
    try
      if AAgend <> '' then
        AName := AAgend + '_' + AName;
      mPars.GetOrCreateParam(dtString, AName).AsString := AValue;
      try
        mCon.GetCompanyCache.SavePropertiesForCompany(AName, mPars);
        Result := True;
      except
        Result := False;
      end;
    finally
      mPars.Free;
    end;
  finally
    mCon.Free;
  end;
end;

// Zápis persistentních dat přes TNxCompanyCache - náhrada INI souboru
// Zatím podpora pouze pro string
// na uživatele
function SetValueToStorageForUserOS(AName: string; AValue: string; AObjectSpace: TNxCustomObjectSpace; AAgend: String = ''): Boolean;
var
  mPars: TNxParameters;
  mCon: TNxContext;
begin
  Result := False;
  if VarIsNull(AObjectSpace) then
    exit;
  mCon := NxCreateContext(AObjectSpace);
  try
    mPars := TNxParameters.Create;
    try
      if AAgend <> '' then
        AName := AAgend + '_' + AName;
      mPars.GetOrCreateParam(dtString, AName).AsString := AValue;
      try
        mCon.GetCompanyCache.SaveProperties(AName, mPars);
        Result := True;
      except
        Result := False;
      end;
    finally
      mPars.Free;
    end;
  finally
    mCon.Free;
  end;
end;

// Rušení persistentních dat přes TNxCompanyCache - náhrada INI souboru
function ExistValueFromStorage(AName: string; AContext: TNxContext; AAgend: String= ''): Boolean;
var
  mPars: TNxParameters;
begin
  Result := False;
  mPars := TNxParameters.Create;
  try
    if AAgend <> '' then
      AName := AAgend + '_' + AName;
    AContext.GetCompanyCache.LoadPropertiesForCompany(AName, mPars);
    Result := mPars.ParamExist(AName);
  finally
    mPars.Free;
  end;
end;

begin
end.
