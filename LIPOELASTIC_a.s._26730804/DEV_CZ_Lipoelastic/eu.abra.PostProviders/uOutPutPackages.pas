uses
  'eu.abra.PostProviders.uConst',
  'eu.abra.PostProviders.uPostProvider',
  'eu.abra.PostProviders.uWSFunc',
  'eu.abra.PostProviders.uPrint',
  'eu.abra.PostProviders.uBalikobotFunc',
  'eu.abra.PostProviders.uProgressForm',
  'eu.abra.PostProviders.uSQLFunc',
  'eu.abra.PostProviders.uLanguage';


procedure ExportPackages(ASite: TSiteForm; AOS:TNxCustomObjectSpace ;const AIDs: TStringList; const ADriver: integer; const AWhat: Integer; var ALogInfoStr:TStringList = nil;);
var
  mFileName: string;
  mPostProviderBO: TNxCustomBusinessObject;
  mOS: TNxCustomObjectSpace;
  mStatusText, mResponseText, mErrorLog: string;
  mXML: TNxScriptingXMLWrapper;
  mBytes: TBytes;
  mMessage, mAuthToken: string;
begin
  if (AWhat = 1)  then
  begin
    RaiseException(lng_msg_ExportError);
  end;

  mMessage := '';
  mOS:= AOS;
  mPostProviderBO := nil;
  if Assigned(ASite) then
    ProgressInit(ASite, lng_msg_progress0, 1000);
  try
    if Assigned(ASite) then
      ProgressSetPos(100,Format( lng_msg_progress1  ,[IntToStr(AIDs.Count)])  );
    GetPostProviderWithModules(mOS, ADriver, mPostProviderBO);


    try
      mFileName := DoExport(mOS, AIDs, ADriver, mPostProviderBO);
      if not FileExists(mFileName) then
        RaiseException(lng_msg_FileNotFondExport);

      if (ADriver = cDriverBalikobot) then begin
        if (AWhat = 0) then
        begin
          mErrorLog := '';
          if Assigned(ASite) then
            ProgressSetPos(900, lng_msg_progress2);
          BBExport(mOS, AIDs, mErrorLog, ADriver ,mPostProviderBO);
          if mErrorLog <> '' then
            RaiseException(mErrorLog);
          if not (GetExtrasSetings('baliky','AutoExport','') = 'A') then
            mMessage := lng_msg_ExportInfo;
        end;
      end;
    finally
      if mPostProviderBO <> nil then
        mPostProviderBO.Free;
    end;
  finally
    if Assigned(ASite) then
      ProgressDispose();
    if mMessage <> '' then
      if Assigned(ASite) then
        NxShowSimpleMessage(mMessage, ASite);
      if Assigned(ALogInfoStr) then
        ALogInfoStr.add(mMessage);

  end;
end;

//Check
procedure CheckPackages(ASite: TSiteForm; const AIDs: TStringList; const ADriver: integer; const AWhat: Integer);
var
  mFileName: string;
  mPostProviderBO: TNxCustomBusinessObject;
  mOS: TNxCustomObjectSpace;
  mStatusText, mResponseText, mErrorLog: string;
  mXML: TNxScriptingXMLWrapper;
  mBytes: TBytes;
  mMessage, mAuthToken: string;
begin
  if (AWhat = 1)  then
  begin
    RaiseException(lng_msg_ExportError2);
  end;

  mMessage := '';
  mOS:= ASite.BaseObjectSpace;
  mPostProviderBO := nil;
  ProgressInit(ASite, 'Validace zásilky...', 1000);
  try
    ProgressSetPos(100, 'Příprava '+IntToStr(AIDs.Count)+' balíků.');
    GetPostProviderWithModules(mOS, ADriver, mPostProviderBO);


    try
      mFileName := DoExport(mOS, AIDs, ADriver, mPostProviderBO);
      if not FileExists(mFileName) then
        RaiseException(lng_msg_FileNotFondExport);

      if (ADriver = cDriverBalikobot) then begin
        if (AWhat = 0) then
        begin
          mErrorLog := '';
          ProgressSetPos(900, 'Odesílání dat.');
          BBCheck(mOS, AIDs, mErrorLog, ADriver ,mPostProviderBO);
          if mErrorLog <> '' then
            RaiseException(mErrorLog);
          if not (GetExtrasSetings('baliky','AutoExport','') = 'A') then
            mMessage := 'Podklady validace odeslány k dopravci.';
        end;
      end;
    finally
      if mPostProviderBO <> nil then
        mPostProviderBO.Free;
    end;
  finally
    ProgressDispose();
    if mMessage <> '' then
      NxShowSimpleMessage(mMessage, ASite);
  end;
end;


//Cena přepravy
procedure TransportCostsPackages(ASite: TSiteForm; const AIDs: TStringList; const ADriver: integer; const AWhat: Integer);
var
  mFileName: string;
  mPostProviderBO: TNxCustomBusinessObject;
  mOS: TNxCustomObjectSpace;
  mStatusText, mResponseText, mErrorLog: string;
  mXML: TNxScriptingXMLWrapper;
  mBytes: TBytes;
  mMessage, mAuthToken: string;
  mResultText: TStringList;
begin
  if (AWhat = 1)  then
  begin
    RaiseException('Získání ceny přepravy tímto způsobem není povolen.')
  end;

  mMessage := '';
  mOS:= ASite.BaseObjectSpace;
  mPostProviderBO := nil;
  ProgressInit(ASite, lng_msg_progress3, 1000);
  try
    ProgressSetPos(100, 'Příprava '+IntToStr(AIDs.Count)+' balíků.');
    GetPostProviderWithModules(mOS, ADriver, mPostProviderBO);


    try
      mResultText := TStringList.Create();
      mFileName := DoExport(mOS, AIDs, ADriver, mPostProviderBO);
      if not FileExists(mFileName) then
        RaiseException(lng_msg_FileNotFondExport);

      if (ADriver = cDriverBalikobot) then begin
        if (AWhat = 0) then
        begin
          mErrorLog := '';
          ProgressSetPos(900, lng_msg_progress4);
          BBTransportCosts(mOS, AIDs, mErrorLog, ADriver ,mPostProviderBO, mResultText);
          if mErrorLog <> '' then
            RaiseException(mErrorLog);
          mMessage := lng_msg_ExportInfoGetPrice+cCRLF+mResultText.Text;
        end;
      end;
    finally
      mResultText.Free;
      if mPostProviderBO <> nil then
        mPostProviderBO.Free;
    end;
  finally
    ProgressDispose();
    if mMessage <> '' then
      NxShowSimpleMessage(mMessage, ASite);
  end;
end;

procedure PrintPackages(AOS: TNxCustomObjectSpace; const AIDs: TStringList; const ADriver, AWhat: integer; APrinterName:String='');
var
  mPostProviderBO: TNxCustomBusinessObject;
begin

  mPostProviderBO := nil;
  //GetAllPackages(mOS, AIDs, ADriver);
  RemoveQuoted(AIDs);
  GetPostProvider(AOS, ADriver, mPostProviderBO, AIDs[0]);
  try
    DoPrint(AOS, AIDs, ADriver, mPostProviderBO, AWhat,APrinterName);
  finally
    if mPostProviderBO <> nil then
      mPostProviderBO.Free;
  end;
end;


procedure AddID(var AIDs: TStringList; const AID: TNxOID);
begin
  if AIDs.IndexOf(AID) = -1 then
    AIDs.Add(AID);
end;

//provede export baliku
function DoExport(AOS: TNxCustomObjectSpace; const AIDs: TStringList; const ADriver: integer; const APostProviderBO: TNxCustomBusinessObject): string;
var
  mFileName, mExport_ID, mExportDataSource: string;
begin
  Result := '';
  if not NxCreateTempFile(mFileName) then
    RaiseException(lng_msg_FileNotFondExport);
  mExport_ID := APostProviderBO.GetFieldValueAsString('X_PD_Export_ID');
  if not CFxOID.IsEmpty(mExport_ID) then begin
    mExportDataSource := APostProviderBO.GetFieldValueAsString('X_PD_Export_ID.DataSource');
    CFxReportManager.ExportByIDs(NxCreateContext(AOS), AIDs, mExportDataSource, mExport_ID, 2, '', mFileName);
    Result := mFileName;
  end else
    RaiseException(lng_msg_PProviderFieldExportNotSet);
end;

//provede tisk baliku
procedure DoPrint(AOS: TNxCustomObjectSpace; const AIDs: TStringList; const ADriver: integer; const APostProviderBO: TNxCustomBusinessObject; const AWhat: integer; APrinterName:String='');
begin
  case ADriver of
   cDriverBalikobot:
    begin
      PrintDocumentLabel(AOS, AIDs, APostProviderBO, GetPrintTypeByIndex(AWhat),APrinterName)
    end;
  end;
end;



procedure DoDropPackage(AOS: TNxCustomObjectSpace; const AID: String; const ADriver: integer; const AWhat: integer );
var
  mErrorLog : string;
  mBO, mPostProviderBO : TNxCustomBusinessObject;
begin
  try
    try
      mBO := AOS.CreateObject(Class_PDMIssuedDoc);
      mPostProviderBO := AOS.CreateObject(Class_PDMPostProvider);
      if ADriver <> cDriverBalikobot then
        RaiseException('Tento dopravce nepodporuje mazání zásilek.');
      if NxMessageBox(lng_msgtit_DeletePackage, lng_msg_DeletePackage,mdConfirm,mdbYesNo,mrYes,nil,False,nil) = mrYes then
      begin
        mBO.Load(AID,nil);
        mPostProviderBO.Load(mBO.GetFieldValueAsString('PostProvider_ID'),nil);
        if not DropPackage(AOS, AID, mErrorLog, mPostProviderBO) then
          NxShowSimpleMessage(lng_msg_DeletePackageError+ mErrorLog,nil)
        else
          NxShowSimpleMessage(lng_msg_DeletePackageInfo,nil);
      end;
    finally
      mBO.Free;
      mPostProviderBO.Free;
    end;
  except
    NxShowSimpleMessage(lng_msg_DeletePackageError + mErrorLog,nil);
  end;
end;

procedure DoOrderPostProvider(AOS: TNxCustomObjectSpace; var AIDs: TStringList; const ADriver: integer; const AWhat: integer );
var
  mErrorLog : string;
  mBO, mPostProviderBO : TNxCustomBusinessObject;
begin
  try
    try
      mPostProviderBO := AOS.CreateObject(Class_PDMPostProvider);
      mBO := AOS.CreateObject(Class_PDMIssuedDoc);
      if AIDs.Count =0 then exit;
      mBO.Load(AIDs[0],nil);
      if ADriver <> cDriverBalikobot then
        RaiseException('Tento dopravce nepodporuje objednávku svozu.');
      if NxMessageBox(lng_msgtit_OrderPostProvider,lng_msg_OrderPostProvider,mdConfirm,mdbYesNo,mrYes,nil,False,nil) = mrYes then
      begin
        mPostProviderBO.Load(mBO.GetFieldValueAsString('PostProvider_ID'),nil);
        if not OrderPostProvider(AOS, AIDs, mErrorLog, mPostProviderBO) then
          NxShowSimpleMessage(lng_msgtit_OrderPostProviderError+ mErrorLog,nil)
        else
          NxShowSimpleMessage(lng_msgtit_OrderPostProviderInfo,nil);
      end;
    finally
      mPostProviderBO.Free;
      mBO.Free;
    end;
  except
    NxShowSimpleMessage(lng_msgtit_OrderPostProviderError + mErrorLog,nil);
  end;
end;


//počet provideru v označených záznamech
function GetCountProvider(AOS: TNxCustomObjectSpace; AIDs: TStringList): integer;
const
  cSQL = 'select pio.PostProvider_ID from PDMIssuedDocs pio where pio.id in (%s) group by pio.PostProvider_ID';
var
  mList: TStringList;
  mSQL: string;
  i: integer;
begin
  Result := 0;
  if AIDs.Count = 0 then exit;
  mList := TStringList.Create;
  try
    for i := 0 to AIDs.Count - 1 do
      mList.Add(QuotedStr(AIDs[i]));
    mSQL := Format(cSQL, [mList.CommaText]);
    mList.Clear;
    AOS.SQLSelect(mSQL, mList);
    Result := mList.Count;
  finally
    mList.Free;
  end;
end;


//počet provideru v označených záznamech
function GetCountSetting(AOS: TNxCustomObjectSpace; AIDs: TStringList): integer;
const
  cSQL = 'select pio.X_PD_Setting_ID from PDMIssuedDocs pio where pio.id in (%s) group by pio.X_PD_Setting_ID';
var
  mList: TStringList;
  mSQL: string;
  i: integer;
  mBO:TNxCustomBusinessObject;
begin
  Result := 1;
  mBO := AOS.CreateObject(Class_PDMIssuedDoc);
  try
    if mBO.hasField('X_PD_Setting') then
    begin
      Result := 0;
      if AIDs.Count = 0 then exit;
      mList := TStringList.Create;
      try
        for i := 0 to AIDs.Count - 1 do
          mList.Add(QuotedStr(AIDs[i]));
        mSQL := Format(cSQL, [mList.CommaText]);
        mList.Clear;
        AOS.SQLSelect(mSQL, mList);
        Result := mList.Count;
      finally
        mList.Free;
      end;
    end;
  finally
    mBO.free;
  end;
end;

function GetCountProviderModul(AOS: TNxCustomObjectSpace; AIDs: TStringList): integer;
const
  cSQL = 'select pop.x_pd_driver from PDMIssuedDocs pio join pdmpostproviders pop on pop.id = pio.postprovider_id where pio.id in (%s) group by pop.x_pd_driver';
var
  mList: TStringList;
  mSQL: string;
  i: integer;
begin
  Result := 0;
  if AIDs.Count = 0 then exit;
  mList := TStringList.Create;
  try
    for i := 0 to AIDs.Count - 1 do
      mList.Add(QuotedStr(AIDs[i]));
    mSQL := Format(cSQL, [mList.CommaText]);
    mList.Clear;
    AOS.SQLSelect(mSQL, mList);
    Result := mList.Count;
  finally
    mList.Free;
  end;
end;


//Balíkobot nepodporuje identifikaci odesílací pobočky
function GetCountStore(AOS: TNxCustomObjectSpace; AIDs: TStringList): integer;
const
  cSQL = 'select pio.x_pd_store_id from PDMIssuedDocs pio where pio.id in (%s) group by PIO.x_pd_store_id';
var
  mList: TStringList;
  mSQL: string;
  i: integer;
begin
  Result := 0;
  if AIDs.Count = 0 then exit;
  mList := TStringList.Create;
  try
    for i := 0 to AIDs.Count - 1 do
      mList.Add(QuotedStr(AIDs[i]));
    mSQL := Format(cSQL, [mList.CommaText]);
    mList.Clear;
    AOS.SQLSelect(mSQL, mList);
    Result := mList.Count;
  finally
    mList.Free;
  end;
end;


//vrati provider ze zaznamu posty
function GetProviderDriver(AOS: TNxCustomObjectSpace; AID: TNxOID): Integer;
const
  cSQL = 'select a.X_PD_Driver from pdmpostproviders a where a.id =';
var
  mList: TStringList;
  mSQL: string;
  i: integer;
begin
  Result := cDriverNone;
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






begin
end.