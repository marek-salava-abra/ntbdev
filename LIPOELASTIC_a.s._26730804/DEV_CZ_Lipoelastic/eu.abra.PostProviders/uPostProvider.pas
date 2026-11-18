uses
  'eu.abra.PostProviders.uConst',
  'eu.abra.PostProviders.uIniFile',
  'eu.abra.PostProviders.uDocTypeFunc',
  'eu.abra.PostProviders.uSQLFunc';

const
  cSQLAllowedPostDriver = 'SELECT ID FROM PDMPostProviders WHERE X_PD_IsLicensed = ''A'' and (X_PD_Driver > 0)';
  cSQLAllowedServiceType = 'SELECT PST.ID FROM PDMServiceTypes PST JOIN PDMPostProviders PPP ON PPP.ID = PST.X_PD_PostProvider_ID WHERE PST.Hidden = ''N'' AND PPP.X_PD_IsLicensed = ''A'' AND (PPP.X_PD_Driver > 0) AND PPP.ID = ';
  cConditionContentType = ' AND( ((PPP.X_PD_Driver = %s) AND (PST.X_PD_IssuedContentType_ID = %s)) OR (PPP.X_PD_Driver <> %s) ) ';
  cSQLAllowedManipulationUnit = 'SELECT A.ID FROM DefRollData A WHERE A.CLSID = ''%s'' AND A.X_AN_PostProvider_ID = ''%s'' AND A.Hidden = ''N'' ';
  cSQLGetAllowedContentTypes = 'SELECT ID FROM PDMIssuedContentTypes WHERE X_PD_MainPostProvider_ID = ''%s'' and X_PD_ServiceType = %s ';
//vrati postovniho poskytovatele dle driveru
//AID = TNxPDMIssuedDoc
procedure GetPostProvider(AOS: TNxCustomObjectSpace; const ADriver: integer; var APostProviderBO: TNxCustomBusinessObject; const AID :String = '');
const
  cSQL = 'select ID from PDMPostProviders where X_PD_IsLicensed = ''A'' and X_PD_Driver = ';
var
  mList: TStringList;
begin
  if APostProviderBO <> nil then
    APostProviderBO.Free;
  APostProviderBO := nil;
  mList := TStringList.Create;
  try
    if (ADriver = cDriverBalikobot) and (AID <> '') then
      mList.add(GetProviderID(AOS, AID));
    if mList.Count = 0 then
      AOS.SQLSelect(cSQL+IntToStr(ADriver), mList);
    //if NxGetActualUserID(AOS)='4PU1000101' then NxShowSimpleMessage(cSQL+IntToStr(ADriver)+NxCrlf+mlist.DelimitedText,nil);
    if (mList.Count = 1) then begin
      APostProviderBO := AOS.CreateObject(Class_PDMPostProvider);
      APostProviderBO.Load(mList[0], nil);
    end else begin
      RaiseException(lng_msg_internalError0)
    end;
  finally
    mList.Free;
  end;
end;


procedure GetPostProviderWithModules(AOS: TNxCustomObjectSpace; const ADriver: integer; var APostProviderBO: TNxCustomBusinessObject);
const
  cSQL = 'select ID from PDMPostProviders where X_PD_IsLicensed = ''A'' and X_PD_BB_ProviderModul <> 1 and X_PD_Driver = ';
var
  mList: TStringList;
begin
  if APostProviderBO <> nil then
    APostProviderBO.Free;
  APostProviderBO := nil;
  mList := TStringList.Create;
  try
    AOS.SQLSelect(cSQL+IntToStr(ADriver), mList);
    //if NxGetActualUserID(AOS)='4PU1000101' then NxShowSimpleMessage(cSQL+IntToStr(ADriver),nil);
    if (mList.Count >= 1) then begin
      APostProviderBO := AOS.CreateObject(Class_PDMPostProvider);
      APostProviderBO.Load(mList[0], nil);
    end else begin
      RaiseException(lng_msg_internalError0)
    end;
  finally
    mList.Free;
  end;
end;

//vrati provider ze zaznamu posty
function GetProviderID(AOS: TNxCustomObjectSpace; AID: TNxOID): TNxOID;
const
  cSQL = 'select pp.id from PDMIssuedDocs pio join PDMPostProviders pp on pio.PostProvider_ID = pp.id where pio.id =';
var
  mList: TStringList;
  mSQL: string;
  i: integer;
begin
  Result := nil;
  if CFxOID.IsEmpty(AID) then exit;
  mList := TStringList.Create;
  try
    mSQL := cSQL+QuotedStr(AID);
    AOS.SQLSelect(mSQL, mList);
    if mList.Count > 0 then
      Result := mList[0];
  finally
    mList.Free;
  end;
end;



function GetProvider(AOS: TNxCustomObjectSpace; AID: TNxOID): Integer;
const
  cSQL = 'select pp.X_PD_Driver from PDMIssuedDocs pio join PDMPostProviders pp on pio.PostProvider_ID = pp.id where pio.id =';
var
  mList: TStringList;
  mSQL: string;
  i: integer;
begin
  Result := nil;
  if CFxOID.IsEmpty(AID) then exit;
  mList := TStringList.Create;
  try
    mSQL := cSQL+QuotedStr(AID);
    AOS.SQLSelect(mSQL, mList);
    if mList.Count > 0 then
      Result := StrToInt(mList[0]);
  finally
    mList.Free;
  end;
end;

//vrati driver dle OID postovniho poskytovatele
function GetPDMProviderDriver(AOS: TNxCustomObjectSpace; const APostProvider_ID: TNxOID): Integer;
const
  cSQL = 'select X_PD_Driver from PDMPostProviders where X_PD_IsLicensed = ''A'' and ID = %s';
var
  mSQL: string;
begin
  mSQL := Format(cSQL, [QuotedStr(APostProvider_ID)]);
  Result := StrToIntDef(GetFirstRecordFromSQL(AOS, mSQL), cDriverNone);
end;

//povolene druhy obsahu dle poskytovatele
{
function GetAllowedContentTypes(AObjSpace: TNxCustomObjectSpace; APostProvider: TNxOID; const AServiceType): string;
var
  mBC: TNxCustomBusinessClass;
  mResult: TStringList;
  mParam: TNXParameters;
  i: Integer;
begin
  Result:= '';
  mResult:= TStringList.Create;
  try
    mParam:= TNXParameters.Create;
    try
      //Perzistentní třída-PDMPostProviders
      //mParam.GetOrCreateParam(dtString, 'IssuedContentType').AsString:= AContentTypes;
      mBC:= AObjSpace.CreateClassObject('0TB2X3G3Y3ROTAPEXVWMTGZ34G');
      try
        mBC.LoadStringsFromObjectAction(APostProvider, 3, mParam, mResult);
        //for i:= 0 to mResult.Count - 1 do
        //  mResult[i] := QuotedStr(mResult[i]);
        mResult.Delimiter := ';';
        Result := mResult.DelimitedText;
      finally
        mBC.Free;
      end;
    finally
      mParam.Free;
    end;
  finally
    mResult.Free;
  end;
end;
     }


//povolene typy sluzeb dle poskytovatele
function GetAllowedContentTypes(AOS: TNxCustomObjectSpace; APostProvider: TNxOID; const AServiceType:Integer):string;
var
  mList: TStringList;
begin
  Result := '';
  mList:= TStringList.create;
  try
    AOS.SQLSelect( Format(cSQLGetAllowedContentTypes,[APostProvider,IntToStr(AServiceType) ]), mList);
    //for i:= 0 to mList.Count - 1 do
    //  mList[i] := QuotedStr(mList[i]);
    mList.Delimiter := ';';
    Result := mList.DelimitedText;
  finally
    mList.Free;
  end;
end;

//povolene typy sluzeb dle poskytovatele
function GetAllowedServiceTypes(AOS: TNxCustomObjectSpace; APostProvider: TNxOID; const AIContentType: TNxOID = '' ): string;
var
  mList: TStringList;
  i: integer;
  mCondition : string;
begin
  Result := '';
  mCondition := '';
  mList:= TStringList.create;
  if AIContentType <> '' then
    mCondition := Format(cConditionContentType, [IntToStr(cDriverBalikobot) ,QuotedStr(AIContentType),IntToStr(cDriverBalikobot)]);
  try
    AOS.SQLSelect(cSQLAllowedServiceType+QuotedStr(APostProvider)+mCondition, mList);
    //for i:= 0 to mList.Count - 1 do
    //  mList[i] := QuotedStr(mList[i]);
    mList.Delimiter := ';';
    Result := mList.DelimitedText;
  finally
    mList.Free;
  end;
end;


//povolene manipulační jednotky dle poskytovatele
function GetAllowedManipulationUnits(AOS: TNxCustomObjectSpace; APostProvider: TNxOID): string;
var
  mList: TStringList;
  i: integer;
  mCondition : string;
begin
  Result := '';
  mCondition := '';
  mList:= TStringList.create;
  try
    AOS.SQLSelect(Format(cSQLAllowedManipulationUnit,[Class_BOManipulationUnits,APostProvider]), mList);
    //for i:= 0 to mList.Count - 1 do
    //  mList[i] := QuotedStr(mList[i]);
    mList.Delimiter := ';';
    Result := mList.DelimitedText;
  finally
    mList.Free;
  end;
end;


//Zjistí počet balíků pro konkrétní zvolený row
function GetContentCount(const APackagesDataSet, AContentDataSet: TMemoryDataset;):Integer;
begin
  Result:=0;
  AContentDataSet.DisableControls;
  AContentDataSet.First;
  while not AContentDataSet.Eof do
  begin
    if (APackagesDataSet.FieldByName(cFDID).AsString = AContentDataSet.FieldByName(cFDParentID).AsString) then
      Inc( Result,1);
    AContentDataSet.Next;
  end;
  AContentDataSet.EnableControls;
end;


//Přidání obsahu
procedure AddContentRow(var AContentDataSet: TMemoryDataset; );  // var ADatasetPackages:TMemoryDataset
var mDataset,mPackagesDataSet : TMemoryDataset;
    mPosIndex : Integer;
begin
  try
    mPackagesDataSet := TMemoryDataset(( IntToObj( AContentDataSet.Tag) ));
    mPosIndex := 0;
    mPosIndex := GetContentCount(mPackagesDataSet,AContentDataSet);
    AContentDataSet.DisableControls;

    AContentDataSet.Append;
    AContentDataSet.Post;
    AContentDataSet.Edit;
    AContentDataSet.FieldByName(cFDParentID).AsString := mPackagesDataSet.FieldByName(cFDID).AsString;
    AContentDataSet.FieldByName(cFDDisplayNumber).AsString := mPackagesDataSet.FieldByName(cFDDisplayNumber).AsString;
    RTTI.SetStrProp(AContentDataSet.FieldByName(cFDWeight), 'DISPLAYFORMAT', '0.000,');
    AContentDataSet.FieldByName(cFDWeight).EditMask := '';
    RTTI.SetStrProp(AContentDataSet.FieldByName(cFDVolume), 'DISPLAYFORMAT', '0.000,');


    AContentDataSet.FieldByName(cFDVolume).EditMask := '';
    AContentDataSet.FieldByName(cFDPosindex).AsInteger := mPosIndex+1;
    AContentDataSet.FieldByName(cFDWeight).AsFloat := 0;
    AContentDataSet.FieldByName(cFDWeightUnit).AsInteger := 1;
    AContentDataSet.FieldByName(cFDWidth).AsFloat := 0;
    AContentDataSet.FieldByName(cFDHeight).AsFloat := 0;
    AContentDataSet.FieldByName(cFDLength).AsFloat := 0;
    AContentDataSet.FieldByName(cFDVolume).AsFloat := 0;
    AContentDataSet.Edit;
  finally
    AContentDataSet.EnableControls;
  end;
end;


//dotahne info kolik balíků je již vytvořeno
procedure SetExistCount(AOS: TNxCustomObjectSpace; const APostProvider: TNxOID; var APackagesDataSet: TDataSet; ADocumentType: string);
var
  mIDs: TStringList;
  mSQL, mStation_ID: string;
  mSQLGetPackages: string;
begin
  //if CFxOID.IsEmpty(APostProvider) then exit;
  mIDs := TStringList.Create;
  mSQLGetPackages := GetSQLPackages(ADocumentType);
  try
    mIDs.Clear;
    mIDs.Add(APackagesDataSet.FieldByName(cFDID).AsString);
    mStation_ID := StringsToSelDat(AOS, mIDs);
    try
      if CFxOID.IsEmpty(APostProvider) then begin
        mSQL := Format(mSQLGetPackages, [QuotedStr(mStation_ID), '']);
      end else begin
        mSQL := Format(mSQLGetPackages, [QuotedStr(mStation_ID), ' and (PID.PostProvider_ID ='+ QuotedStr(APostProvider) +') ']);
      end;
      mIDs.Clear;
      AOS.SQLSelect(mSQL, mIDs);
    finally
      ClearSelDat(AOS, mStation_ID);
    end;
    APackagesDataSet.FieldByName(cFDExistCount).AsInteger := mIDs.Count;
  finally
    mIDs.free;
  end;
end;



begin
end.