uses
  'eu.abra.PostProviders.uConst',
  'eu.abra.PostProviders.uProgressForm',
  'eu.abra.PostProviders.uWSFunc',
  'eu.abra.PostProviders.uLanguage',
  'eu.abra.PostProviders.uLog';


//R
procedure BBExport(AOS: TNxCustomObjectSpace; const AIDs: TStringList; var AErrorLog: String; const ADriver:Integer; const APostProviderBO : TNxCustomBusinessObject);
var mErrorList, mTMP : TStringList;
    mJSONResponseBody : TJSONSuperObject;
    mResponseText, mStatusError, mPackageError, mFileName, mExport_ID,mExportDataSource : String;
    mStatusCode, mSoftError, mError : Integer;
    i, z : Integer;
    mPostProviderBO, mIssuedDocBO : TNxCustomBusinessObject;
    mIndex: String;
begin
  mStatusCode := -1;
  mJSONResponseBody := nil;
  mErrorList := nil;
  mPostProviderBO := nil;
  mTMP := nil;
  mIssuedDocBO := nil;
  RemoveQuoted(AIDs);
  try
    mPostProviderBO := AOS.CreateObject(Class_PDMPostProvider);
    mErrorList := TStringList.Create();
    mTMP := TStringList.Create();

    for z := 0 to AIDs.Count -1 do
    begin
      try
        mIssuedDocBO := AOS.CreateObject(Class_PDMIssuedDoc);
        mTMP.Clear;
        mTMP.Add(AIDs[z]);
        mIssuedDocBO.Load(AIDs[z],nil);
        //pokud je balík druhý a další, pak se přeskakuje. Důvodem je exportu spolu s hlavním balíkem.
        if mIssuedDocBO.GetFieldValueAsInteger('X_PD_PosIndex') > 1 then continue;

        //Funkce přidá podřízené balíky. Následně se bude exportovat v jednom requestu.
        AddToListSubPackages(AOS, mTMP[0], mTMP);

        mPostProviderBO.Load(mIssuedDocBO.GetFieldValueAsString('PostProvider_ID'),nil);
        //export pro všechny dopravce. DPD nevrací externí id při chybě a není kontrola nad tím jaký dolad je špatně. Tedy je odesíláno jedno po druhém.
        if not NxCreateTempFile(mFileName) then
          RaiseException(lng_msg_CantCreateExportFile);
        //nepodařilo se upravit soubor exportu.
        RenameFile(mFileName,NxLeft(mFileName,Length(mFileName)-4)+AIDs[z]+'.tmp');
        mFileName := NxLeft(mFileName,Length(mFileName)-4)+AIDs[z]+'.tmp';
        mExport_ID := mPostProviderBO.GetFieldValueAsString('X_PD_Export_ID');
        if not CFxOID.IsEmpty(mExport_ID) then begin
          ShowDebugMessage('bef mlist ' + mTMP.CommaText);
          mExportDataSource := mPostProviderBO.GetFieldValueAsString('X_PD_Export_ID.DataSource');
          CFxReportManager.ExportByIDs(NxCreateContext(AOS), mTMP, mExportDataSource, mExport_ID, 2, '', mFileName);
          ShowDebugMessage('aft mlist ' + mTMP.CommaText);
          RemoveQuoted(mTMP);
        end else
          RaiseException(lng_msg_PProviderFieldExportNotSet);
        OutputDebugString('Temp File Export '+ mFileName);
        if not FileExists(mFileName) then
          RaiseException(lng_msg_ExportFileNotFound+mFileName);


        //TODO podle typu služby odeslat ADD nebo B2A - Exportu bude obsahovat průnik služeb. Typ služby je na službě samotné
        case mIssuedDocBO.GetFieldValueAsInteger('IssuedContent_ID.X_PD_ServiceType') of
          cBBServiceType_ADD : mStatusCode := WSPostFile_2(NxCreateContext(AOS), mFileName, ( mPostProviderBO.GetFieldValueAsString('X_PD_WS')) +GetSubModulName(mPostProviderBO.GetFieldValueAsInteger('X_PD_BB_ProviderModul'))+'/add', mResponseText,mIssuedDocBO);
          cBBServiceType_B2A : mStatusCode := WSPostFile_2(NxCreateContext(AOS), mFileName, ( mPostProviderBO.GetFieldValueAsString('X_PD_WS')) +GetSubModulName(mPostProviderBO.GetFieldValueAsInteger('X_PD_BB_ProviderModul'))+'/b2a', mResponseText,mIssuedDocBO);
          cBBServiceType_B2C : mStatusCode := WSPostFile_2(NxCreateContext(AOS), mFileName, ( mPostProviderBO.GetFieldValueAsString('X_PD_WS')) +GetSubModulName(mPostProviderBO.GetFieldValueAsInteger('X_PD_BB_ProviderModul'))+'/b2c', mResponseText,mIssuedDocBO);
        end;
        //FileOpen(mFileName,fmShareDenyNone);
        if not DeleteFile(mFileName) then
          RaiseException(lng_msg_ExportDeleteError+mFileName);

        showdebugmessage2('BBExport', 'HTTP komunikace navrací status code: ' + IntToStr(mStatusCode));
        if mStatusCode <> 200 then
          RaiseException(lng_msg_ConnectionError + IntToStr(mStatusCode) + '.');
        mStatusCode := -1;  //reciklace

        mJSONResponseBody:= TJSONSuperObject.ParseString(mResponseText,true);

        //dohledá v JSON existenci "status" elementu
        mStatusCode := GetStatusCode(mJSONResponseBody);


        //Stav celého dotazu.
        mStatusError := TypeStatusCode(mStatusCode,mJSONResponseBody, mSoftError, mError);
        if mError > 0 then
          AErrorLog := AErrorLog + cCrLf + format(lng_msg_ErrorReceived1,[GetPMDDocDisplayName(AOS,AIDs[z]),GetSubModulName(mPostProviderBO.GetFieldValueAsInteger('X_PD_BB_ProviderModul'))]) + mStatusError;
        if mSoftError > 0 then
          AErrorLog := AErrorLog + cCrLf + format(lng_msg_WarningsReceived1,[GetPMDDocDisplayName(AOS,AIDs[z]),GetSubModulName(mPostProviderBO.GetFieldValueAsInteger('X_PD_BB_ProviderModul'))])+ mStatusError;

        if (mJSONResponseBody.AsString<> '') and (mJSONResponseBody.AsString <> 'null') and (mJSONResponseBody.AsString <> '{}') and (mJSONResponseBody.AsString <> '[]') then
        begin
          //Až když je vše v pořádku, pak lze získat další data jako je štítek
          if not ((mJSONResponseBody.N['status'].DataType = jtNull)  or (mJSONResponseBody.N['status'].DataType = -1)) then
            if mJSONResponseBody.I['status'] in [200,208] then
              for i:= 0 to cMaxCount do
              begin
                mIndex := IntToStr(i);
                if not ((mJSONResponseBody.N[mIndex].DataType = jtNull)  or (mJSONResponseBody.N[mIndex].DataType = -1)) then
                begin
                  if not ((mJSONResponseBody.O[mIndex].N['status'].DataType = jtNull)  or (mJSONResponseBody.O[mIndex].N['status'].DataType = -1)) then
                    if mJSONResponseBody.O[mIndex].I['status'] in [200,208] then
                    begin
                      try
                        //bez chyby
                        case mIssuedDocBO.GetFieldValueAsInteger('IssuedContent_ID.X_PD_ServiceType') of
                          cBBServiceType_ADD :
                          begin
                            OutputDebugString(mJSONResponseBody.AsString);
                            ResADD_SaveData(AOS, mTMP, mJSONResponseBody, mPackageError, ADriver,i);
                            ResADD_SaveLabel(AOS, mTMP, mJSONResponseBody, mPackageError, ADriver,i);
                            //vše v pořádku mohu nastavit stav;
                            mIssuedDocBO.Refresh;
                            ChangeStatus(mIssuedDocBO, 2,AErrorLog);
                            SetStartActualizeTrackingStatus(mIssuedDocBO);
                          end;
                          cBBServiceType_B2A :
                          begin
                            OutputDebugString(mJSONResponseBody.AsString);
                            ResADD_SaveData(AOS, mTMP, mJSONResponseBody, mPackageError, ADriver,i);
                            mIssuedDocBO.Refresh;
                            //ChangeStatus(mIssuedDocBO, 2,AErrorLog);
                            ChangeStatus(mIssuedDocBO, 2,AErrorLog);
                            SetStartActualizeTrackingStatus(mIssuedDocBO);
                          end;
                          cBBServiceType_B2C :
                          begin
                            OutputDebugString(mJSONResponseBody.AsString);
                            ResB2C_SaveData(AOS, mTMP, mJSONResponseBody, mPackageError, ADriver,i);
                            mIssuedDocBO.Refresh;
                            //ChangeStatus(mIssuedDocBO, 2,AErrorLog);
                            ChangeStatus(mIssuedDocBO, 2,AErrorLog);
                            SetStartActualizeTrackingStatus(mIssuedDocBO);
                          end;
                        end;
                      except
                        mErrorList.add(mPackageError);
                      end;
                    end
                    else
                    begin
                      //chyba byla již rozebrána nahoře
                    end;
                end;

              end;
            end;

      finally
        if mIssuedDocBO <> nil then
          mIssuedDocBO.Free;
      end;
    end;
  finally
    if mPostProviderBO <> nil then
      mPostProviderBO.free;
    if mJSONResponseBody <> nil then
      mJSONResponseBody.free;
    if mErrorList.text <> '' then
      AErrorLog := AErrorLog + cCrLf + mErrorList.text;
    if mErrorList <> nil then
      mErrorList.Free;
    if mTMP <> nil then
      mTMP.Free;
  end;
end;


  /////////////////////////////////
///////////METODA ORDER///////////
/////////////////////////////////

{Objednávka svozu   handover_url}
//R
function OrderPostProvider(AOS: TNxCustomObjectSpace; const AIDs: TStringList; var AErrorLog: String; const APostProviderBO :TNxCustomBusinessObject):Boolean;
var mErrorList : TStringList;
    mJSONResponseBody, mJSONRequestBody : TJSONSuperObject;
    mResponseText, mStatusError : String;
    mStatusCode, mSoftError, mError : Integer;
    z : Integer;
    mIssuedDocBO : TNxCustomBusinessObject;
    mStream: TMemoryStream;
begin
  Result := False;
  mStatusCode := -1;
  mJSONResponseBody := nil;
  mJSONRequestBody := nil;
  mIssuedDocBO := nil;
  AErrorLog := '';
  mStream := nil;
  try
    EnterSection('OrderPostProvider');
    mErrorList := TStringList.Create();
    mStream := TMemoryStream.Create;

    try
      mIssuedDocBO := AOS.CreateObject(Class_PDMIssuedDoc);

      mJSONRequestBody := TJSONSuperObject.CreateByDataType(jtObject);

      mJSONRequestBody.O['package_ids'] := TJSONSuperObject.CreateByDataType(jtArray);
      for z := 0 to AIDs.Count -1 do
      begin
        try
          mIssuedDocBO.Load(AIDs[z],nil);
          if mIssuedDocBO.GetFieldValueAsString('X_PD_API_ID') = '' then
            RaiseException( lng_msg_Stop +' '+mIssuedDocBO.GetFieldValueAsString('Displayname')+lng_msg_PostNumberNotSet);
          //Error
          mJSONRequestBody.A['package_ids'].S[z] := mIssuedDocBO.GetFieldValueAsString('X_PD_API_ID');
        except
          mErrorList.Add(ExceptionMessage);
        end;
      end;

      mJSONRequestBody.SaveToStream(mStream);
      mStatusCode := WSPostFile_3(NxCreateContext(AOS), mStream, TrimVersion( APostProviderBO.GetFieldValueAsString('X_PD_WS')) +GetSubModulName(APostProviderBO.GetFieldValueAsInteger('X_PD_BB_ProviderModul'))+'/order', mResponseText, mIssuedDocBO);
      if mStatusCode <> 200 then
        RaiseException( lng_msg_ConnectionError + IntToStr(mStatusCode) + '.');
      mStatusCode := -1;  //reciklace


      mJSONResponseBody:= TJSONSuperObject.ParseString(mResponseText,true);

      //dohledá v JSON existenci "status" elementu
      mStatusCode := GetStatusCode(mJSONResponseBody);

      //Stav celého dotazu.
      mStatusError := TypeStatusCode(mStatusCode,mJSONResponseBody, mSoftError, mError);
      if mError > 0 then
        AErrorLog := AErrorLog + cCrLf + 'modul ('+GetSubModulName(APostProviderBO.GetFieldValueAsInteger('X_PD_BB_ProviderModul'))+ lng_msg_ErrorReceived + mStatusError;
      if mSoftError > 0 then
        AErrorLog := AErrorLog + cCrLf + 'modul ('+GetSubModulName(APostProviderBO.GetFieldValueAsInteger('X_PD_BB_ProviderModul'))+ lng_msg_WarningsReceived+ mStatusError;
      //Save data CP
      //ResOrderPostProvider_SaveData(AOS, AIDs, mJSONResponseBody, mPackageError,mKeyIndex);
      //KAHA - AG-10384 - puvodne zde nebyl begin - end u IFu, ale if omezoval jen volani ResOrderPostProvider_SaveTransportList a hromadný update statusu se prováděl vždy.
      //to není správně. když přijde od BB závažná chyba nesmí se nastavit status na "uzavřeno data předána přepravci". V případě chyby to zůstane tak jak je.
      if mError = 0 then begin
        ResOrderPostProvider_SaveTransportList(AOS, AIDs, mJSONResponseBody, AErrorLog);

        //Zde musí dojít k hromadnému update statusus.
        for z := 0 to AIDs.Count -1 do
        begin
          try
            mIssuedDocBO.Load(AIDs[z],nil);
            if Assigned(mIssuedDocBO) then
              case mIssuedDocBO.GetFieldValueAsInteger('IssuedContent_ID.X_PD_ServiceType') of
                cBBServiceType_ADD : ChangeStatus(mIssuedDocBO, 3,AErrorLog);
                //cBBServiceType_B2A : ChangeStatus(mIssuedDocBO, 3,AErrorLog);
                //cBBServiceType_B2C : ChangeStatus(mIssuedDocBO, 3,AErrorLog);
              end;
          except
            mErrorList.Add(ExceptionMessage);
          end;
        end;
      end;

      if mErrorList.Count > 0 then
      begin
        Result:=true;
        AErrorLog := mErrorList.text;
      end;
      if mStatusError = 'OK' then
        Result := true;
    finally
      if mIssuedDocBO <> nil then
        mIssuedDocBO.Free;
    end;

  finally
    LeaveSection('OrderPostProvider');
    if mJSONRequestBody <> nil then
      mJSONRequestBody.Free;
    mErrorList.Free;
    mStream.free;
  end;

end;


//Uloží předávací protokol.
//R
function ResOrderPostProvider_SaveTransportList(AOS: TNxCustomObjectSpace; var AIDs: TStringList; var AJsonPackage : TJSONSuperObject; var AErrorLog: String;):Boolean;
var mLabelURL, mFileURL : String;
    i: Integer;
    mListErorr : TStringList;
    mBO : TNxCustomBusinessObject;
begin
  Result := true;
  mLabelURL := '';
  //najít status
  mListErorr := nil;
  mBO := AOS.CreateObject(Class_PDMIssuedDoc);
  try
    try
    mListErorr := TStringList.Create();
    if AIDs.Count <= 0 then exit;
    mBO.Load(AIDs[0],nil);

    if not((AJsonPackage.N['handover_url'].DataType = jtNull)  or (AJsonPackage.N['handover_url'].DataType = -1)) then
      mLabelURL := AJsonPackage.S('handover_url');

    if not ((AJsonPackage.N['file_url'].DataType = jtNull)  or (AJsonPackage.N['file_url'].DataType = -1)) then
      mFileURL := AJsonPackage.s('file_url')
    else
      mFileURL := '';

    if not ExistsDocumentLabel(AOS, AIDs[0], cTransportListDocument) then
    begin
      //if mLabelURL <> '' then
      DownloadDomument(AOS, mLabelURL, mBO,AIDs,cTransportListDocument);
      if mFileURL <> '' then
        DownloadDomument(AOS, mFileURL, mBO,AIDs,cTransportListDocument,'csv');
    end;
    except
      mListErorr.add(ExceptionMessage);
      Result := False;
    end;

    if result = false then
      AErrorLog := mListErorr.Text;
  finally
    if mListErorr <> nil then
      mListErorr.Free;
    if mBO <> nil then
      mBO.Free;
  end;

end;

/////////////////////////////////
///////////METODA DROP///////////
/////////////////////////////////

{vrací pravdu pokud se podaří odstranit balík}
//R
function DropPackage(AOS: TNxCustomObjectSpace; const AID: String; var AErrorLog: String; const APostProviderBO :TNxCustomBusinessObject):Boolean;
var mTMP : TStringList;
    mJSONResponseBody, mJSONRequestBody : TJSONSuperObject;
    mResponseText, mStatusError: String;
    mStatusCode, mSoftError, mError : Integer;
    mIssuedDocBO : TNxCustomBusinessObject;
    mStream: TMemoryStream;
begin
  Result := False;
  mStatusCode := -1;
  mJSONResponseBody := nil;
  mJSONRequestBody := nil;
  mTMP := nil;
  mIssuedDocBO := nil;
  AErrorLog := '';
  try
    EnterSection('DropPackage');
    mTMP := TStringList.Create();
    mStream := TMemoryStream.Create;

    try
      mIssuedDocBO := AOS.CreateObject(Class_PDMIssuedDoc);
      mTMP.Clear;
      mTMP.Add(AID);
      mIssuedDocBO.Load(AID,nil);

     case mIssuedDocBO.GetFieldValueAsInteger('IssuedContent_ID.X_PD_ServiceType') of
        cBBServiceType_B2A : RaiseException('B2A nepodporuje mazání');
        cBBServiceType_B2C : RaiseException('B2C nepodporuje mazání');
      end;

      //Nahrazen klasický Export pro jednoduchost.
      mJSONRequestBody := TJSONSuperObject.CreateByDataType(jtObject);
      if mIssuedDocBO.GetFieldValueAsString('X_PD_API_ID') = '' then
        RaiseException(lng_msg_StopPostNumberNotSet);
      mJSONRequestBody.I('id') := StrToInt(Trim(mIssuedDocBO.GetFieldValueAsString('X_PD_API_ID')));
      mJSONRequestBody.SaveToStream(mStream);

      mStatusCode := WSPostFile_3(NxCreateContext(AOS), mStream, TrimVersion( APostProviderBO.GetFieldValueAsString('X_PD_WS')) +GetSubModulName(APostProviderBO.GetFieldValueAsInteger('X_PD_BB_ProviderModul'))+'/drop', mResponseText, mIssuedDocBO);
      if mStatusCode <> 200 then
        RaiseException(lng_msg_ConnectionError+ IntToStr(mStatusCode) + '.');
      mStatusCode := -1;  //reciklace

      mJSONResponseBody:= TJSONSuperObject.ParseString(mResponseText,true);

      //dohledá v JSON existenci "status" elementu
      mStatusCode := GetStatusCode(mJSONResponseBody);

      //Stav celého dotazu.
      mStatusError := TypeStatusCode(mStatusCode,mJSONResponseBody, mSoftError, mError);
      if mError > 0 then
        AErrorLog := AErrorLog + cCrLf + 'modul ('+GetSubModulName(APostProviderBO.GetFieldValueAsInteger('X_PD_BB_ProviderModul'))+lng_msg_ErrorReceived + mStatusError;
      if mSoftError > 0 then
        AErrorLog := AErrorLog + cCrLf + 'modul ('+GetSubModulName(APostProviderBO.GetFieldValueAsInteger('X_PD_BB_ProviderModul'))+lng_msg_WarningsReceived + mStatusError;

      if not ((mJSONResponseBody.N['status'].DataType = jtNull)  or (mJSONResponseBody.N['status'].DataType = -1)) then
      begin
        if mJSONResponseBody.I['status'] in [200] then
        begin
          Result := true;
          mIssuedDocBO.SetFieldValueAsString('X_PD_API_ID','');
          mIssuedDocBO.SetFieldValueAsString('PostNumber','');
          mIssuedDocBO.SetFieldValueAsString('X_PD_LongPostNumber','');
          mIssuedDocBO.SetFieldValueAsString('X_PD_RawData','');
          ChangeStatus(mIssuedDocBO, 5,AErrorLog, False);
          mIssuedDocBO.Save;
        end;
      end;


    finally
      if mIssuedDocBO <> nil then
        mIssuedDocBO.Free;
    end;

  finally
    LeaveSection('DropPackage');
    if mStream <> nil then
      mStream.free;
    if mTMP <> nil then
      mTMP.Free;
  end;

end;

/////////////////////////////////
///METODA TRACK, TRACKSTATUS ////
/////////////////////////////////

// GetTrack : Vrátí Status - vrátí výčet stavů sledování zásilky - textová podoba
// Track
//R
function GetTrack(AReportHelper: TNxQRScriptHelper; const AID: string): string;
begin
  Result := GetCustomTracking(AReportHelper.ObjectSpace, AID, 'track');
end;


// GetTrackingStatus : Vrátí TrackStatus - poslední ze stavů sledování zásilky - textová podoba
// TrackStatus
//QR funkce
//R
function GetTrackingStatus(AReportHelper: TNxQRScriptHelper; const AID: string): string;
begin
  Result := GetCustomTracking(AReportHelper.ObjectSpace, AID, 'trackstatus');
end;

{GetCustomTracking  -  (bývalá getTrack přepsána na předka GetTrack a GetTrackingStatus }
//Funkce API vrací MAX 4 záznamy na dotaz. Jinak vrací kód 413
//function GetCustomTracking(AReportHelper:TNxQRScriptHelper; const AID: string; const AMethodName: string; var AStatusIndex: Integer = 0): string;
//R
function GetCustomTracking(AOS :TNxCustomObjectSpace; const AID: string; const AMethodName: string; var AStatusIndex: Integer = 0): string;
var mErrorList, mTMP : TStringList;
    mJSONResponseBody, mJSONRequestBody : TJSONSuperObject;
    mJSONKey: TJSONSuperObjectArray;
    mResponseText, mStatusError, mPackageError,mIndex : String;
    mStatusCode,mOriginalStatusIndex : Integer;
    i, j : Integer;
    mPostProviderBO, mIssuedDocBO : TNxCustomBusinessObject;
    mStream : TMemoryStream;
const
    // rozdíl v indexech u balíkobotu a v našem stavu.  např. rozdíl je 3 tak stav balíkobotu -1 je pak v doplňku 2
    cDifferenceInIndexToBB = 3;
begin
  Result := '';
  mStatusCode := -1;
  mOriginalStatusIndex := AStatusIndex;
  mJSONResponseBody := nil;
  mJSONRequestBody := nil;
  mPostProviderBO := nil;
  mTMP := nil;
  mIssuedDocBO := nil;
  mStream := nil;
  mStream := TMemoryStream.Create();
  mPostProviderBO := AOS.CreateObject(Class_PDMPostProvider);
  mErrorList := TStringList.Create();
  mTMP := TStringList.Create();
  try
    EnterSection('GetCustomTracking', logDebug);
    mIssuedDocBO := AOS.CreateObject(Class_PDMIssuedDoc);
    mTMP.Clear;
    mTMP.Add(AID);
    mIssuedDocBO.Load(AID,nil);
    mPostProviderBO.Load(mIssuedDocBO.GetFieldValueAsString('PostProvider_ID'),nil);

    mJSONRequestBody := TJSONSuperObject.CreateByDataType(jtObject);

    if mIssuedDocBO.GetFieldValueAsString('X_PD_LongPostNumber') <> '' then
      mJSONRequestBody.S('id') := mIssuedDocBO.GetFieldValueAsString('X_PD_LongPostNumber')
    else
      mJSONRequestBody.S('id') := mIssuedDocBO.GetFieldValueAsString('PostNumber');
    mJSONRequestBody.SaveToStream(mStream);
    WriteEvent(Format('Request body: %s', [mJSONRequestBody.AsJson]));

    mStatusCode := WSPostFile_3(NxCreateContext(AOS), mStream, TrimVersion( mPostProviderBO.GetFieldValueAsString('X_PD_WS')) +GetSubModulName(mPostProviderBO.GetFieldValueAsInteger('X_PD_BB_ProviderModul'))+'/'+AMethodName, mResponseText,mIssuedDocBO);
    if mStatusCode <> 200 then
      RaiseException(lng_msg_ConnectionError + IntToStr(mStatusCode) + '.');
    mStatusCode := -1;  //reciklace

    mJSONResponseBody:= TJSONSuperObject.ParseString(mResponseText,true);

    if ((mJSONResponseBody.AsString<> '') and (mJSONResponseBody.AsString <> 'null') and (mJSONResponseBody.AsString <> '{}') and (mJSONResponseBody.AsString <> '[]')) then
    begin
      //Maximální počet na dotaz = 4
      for i:= 0 to 3 do
      begin
        mIndex := IntToStr(i);

        if not ((mJSONResponseBody.N[mIndex].DataType = jtNull)  or (mJSONResponseBody.N[mIndex].DataType = -1)) then
        begin
          //status má jen když je nějaký problém. Vrací 200 a status je napsáno 503 :-(
          if ((mJSONResponseBody.O[mIndex].N['status'].DataType = jtNull)  or (mJSONResponseBody.O[mIndex].N['status'].DataType = -1)) then
          begin
            if LowerCase( AMethodName ) = 'trackstatus' then
            begin
              //Trackstatus
              if not ((mJSONResponseBody.O[mIndex].N['status_id'].DataType = jtNull)  or (mJSONResponseBody.O[mIndex].N['status_id'].DataType = -1)) then
                AStatusIndex := mJSONResponseBody.O[mIndex].I['status_id'] + cDifferenceInIndexToBB;
              if not ((mJSONResponseBody.O[mIndex].N['status_text'].DataType = jtNull)  or (mJSONResponseBody.O[mIndex].N['status_text'].DataType = -1)) then
                Result := mJSONResponseBody.O[mIndex].S['status_text'];
            end
            else if LowerCase( AMethodName ) = 'track' then
            begin
              //Track
              try
                mJSONKey := mJSONResponseBody.O[mIndex].AsObject.GetNames.AsArray;
                for j:= 0 to mJSONKey.Length do
                begin
                  if not ((mJSONResponseBody.O[mIndex].N[IntToStr(j)].DataType = jtNull)  or (mJSONResponseBody.O[mIndex].N[IntToStr(j)].DataType = -1)) then
                  begin
                    Result := Result +cCRLF + mJSONResponseBody.O[mIndex].S[IntToStr(j)];
                  end;
                end;
              finally
                mJSONKey.free;
              end;
            end;
          end
          else
          begin
            //má element status, takže se jedná o chybu. Stav bude nezměněn.
            Result := lng_msg_ConnectionError1 + mJSONResponseBody.O[mIndex].S['status'];
            AStatusIndex := mOriginalStatusIndex;
          end;
        end;
      end;

    end;

  finally
    LeaveSection('GetCustomTracking', logDebug);
    if mIssuedDocBO <> nil then
      mIssuedDocBO.Free;
    if mStream <> nil then
      mStream.free;
    if mJSONResponseBody <> nil then
      mJSONResponseBody.free;
    if mJSONRequestBody <> nil then
      mJSONRequestBody.free;
    if mErrorList.text <> '' then
      Result:=  mErrorList.text;
    if mErrorList <> nil then
      mErrorList.Free;
    if mTMP <> nil then
      mTMP.Free;
  end;
end;



// Načte aktuální stav sledování zásilky a zapíše jej do objektu odeslané pošty
function ActualizeTrackingStatus(AObjectSpace: TNxCustomObjectSpace; const AID: string; var AErrorMessage: string): Boolean;
var
  mIssuedDoc: TNxCustomBusinessObject;
  mErrorMessage: string;
  mTrackingStatus: Integer;
begin
  Result := False;
  try
  //Sjednotit, předělat
    //mTrackingStatus := GetTrackingStatusIndex(AObjectSpace, AID, AErrorMessage);
    mTrackingStatus := -99;
    mErrorMessage := GetCustomTracking(AObjectSpace,AID, 'trackstatus', mTrackingStatus);

    mIssuedDoc := AObjectSpace.CreateObject(Class_PDMIssuedDoc);
    try
      mIssuedDoc.Load(AID,nil);

      if mTrackingStatus <> -99 then
        if (mIssuedDoc.GetFieldValueAsInteger('X_PD_TrackingStatus') <> mTrackingStatus) then
        //PEMI - není důvod
        // TrackingStatus změníme a uložíme jen v případě, že došlo k změně, a že zjišťování stavu není vypnuté (Stav: "-")
        //and ((mIssuedDoc.GetFieldValueAsInteger('X_PD_TrackingStatus') <> 0)) then
        begin
          mIssuedDoc.SetFieldValueAsInteger('X_PD_TrackingStatus', mTrackingStatus);
          mIssuedDoc.Save;
        end;
    finally
      mIssuedDoc.Free;
    end;
  except
    Result := False;
    RaiseException( Format(lng_msg_TaTNoData,[AID]) +mErrorMessage );
  end;
end;

// ActualizeTrackingStatusesAutoServerAction - Aktualizuje stav sledování zásilky na všech zásilkách mimo stavy 0,4,7 teda "-", "Doručeno", "Vráceno odesílateli"
// Pro naplánovanou úlohu
//Rozšířeno o podmínu, že balík musí být uzavřený.
procedure ActualizeTrackingStatusesAutoServerAction(AObjectSpace: TNxCustomObjectSpace; var Success: Boolean; var LogInfoStr: string);
const
  //V případě, kdy dojde k přepnutí na stavc 0 již nedošlo k aktualizaci. Přitom stačí sledovat jen u zásilek co jsou již uzavřené.
  //cSQL_GetAllNotDelivered = 'SELECT A.ID FROM PDMIssuedDocs A WHERE NOT(A.X_PD_TrackingStatus in (0,4,7))  and  ( A.X_PD_Status = ''3'' )';
  cSQL_GetAllNotDelivered = 'SELECT A.ID FROM PDMIssuedDocs A WHERE NOT(A.X_PD_TrackingStatus in (4,7)) and A.X_PD_Status = ''3'' ';
var
  i: Integer;
  mWorkModulName: string;
  mNotFinishedDocs: TStrings;
  mErrorMessage: string;
begin
  LogInfoStr := '';
  mNotFinishedDocs := TStringList.Create;
  gLog := TNxCustomLog.Create(Balikobot_LogName);
  try
    EnterSection('ActualizeTrackingStatusesAutoServerAction');
    AObjectSpace.SQLSelect(cSQL_GetAllNotDelivered, mNotFinishedDocs);
    ActualizeTrackingStatuses(AObjectSpace, mNotFinishedDocs, LogInfoStr);
  finally
    LeaveSection('ActualizeTrackingStatusesAutoServerAction');
    FreeLog;
    mNotFinishedDocs.Free;
  end;
end;

// Aktualizuje stav sledování zásilky na zásilkách ze seznamu ID
procedure ActualizeTrackingStatuses(AObjectSpace: TNxCustomObjectSpace; const AIDs: TStrings; var AErrorMessage: string);
var
  i: Integer;
begin
  if AIDs <> nil then
  begin
    AErrorMessage := '';
    for i := 0 to AIDs.Count - 1 do
    begin
      try
        ActualizeTrackingStatus(AObjectSpace, AIDs[i], AErrorMessage);
        if AErrorMessage <> '' then
          RaiseException(Format(lng_msg_TaTCantFinish,[AIDs[i] ]) + cCrLf + AErrorMessage + cCrLf);
      except
        AErrorMessage :=AErrorMessage + ccrlf + ExceptionMessage;
      end;
    end;
  end;
end;


//////////////////////////////////////////////////
/////////METODA CHECK, TRANSPORTCOSTS ////////////
//////////////////////////////////////////////////

//R
procedure BBCheck(AOS: TNxCustomObjectSpace; const AIDs: TStringList; var AErrorLog: String; const ADriver:Integer; const APostProviderBO : TNxCustomBusinessObject);
var mErrorList, mTMP : TStringList;
    mJSONResponseBody : TJSONSuperObject;
    mResponseText, mStatusError, mPackageError, mFileName, mExport_ID,mExportDataSource : String;
    mStatusCode, mSoftError, mError : Integer;
    i, z : Integer;
    mPostProviderBO, mIssuedDocBO : TNxCustomBusinessObject;
    mIndex: String;
begin
  mStatusCode := -1;
  mJSONResponseBody := nil;
  mErrorList := nil;
  mPostProviderBO := nil;
  mTMP := nil;
  mIssuedDocBO := nil;
  RemoveQuoted(AIDs);
  try
    mPostProviderBO := AOS.CreateObject(Class_PDMPostProvider);
    mErrorList := TStringList.Create();
    mTMP := TStringList.Create();

    for z := 0 to AIDs.Count -1 do
    begin
      try
        mIssuedDocBO := AOS.CreateObject(Class_PDMIssuedDoc);
        mTMP.Clear;
        mTMP.Add(AIDs[z]);
        mIssuedDocBO.Load(AIDs[z],nil);
        //pokud je balík druhý a další, pak se přeskakuje. Důvodem je exportu spolu s hlavním balíkem.
        if mIssuedDocBO.GetFieldValueAsInteger('X_PD_PosIndex') > 1 then continue;

        //Funkce přidá podřízené balíky. Následně se bude exportovat v jednom requestu.
        AddToListSubPackages(AOS, mTMP[0], mTMP);

        mPostProviderBO.Load(mIssuedDocBO.GetFieldValueAsString('PostProvider_ID'),nil);
        //export pro všechny dopravce. DPD nevrací externí id při chybě a není kontrola nad tím jaký dolad je špatně. Tedy je odesíláno jedno po druhém.
        if not NxCreateTempFile(mFileName) then
          RaiseException(lng_msg_CantCreateExportFile);
        //nepodařilo se upravit soubor exportu.
        RenameFile(mFileName,NxLeft(mFileName,Length(mFileName)-4)+AIDs[z]+'.tmp');
        mFileName := NxLeft(mFileName,Length(mFileName)-4)+AIDs[z]+'.tmp';
        mExport_ID := mPostProviderBO.GetFieldValueAsString('X_PD_Export_ID');
        if not CFxOID.IsEmpty(mExport_ID) then begin
          ShowDebugMessage('bef mlist ' + mTMP.CommaText);
          mExportDataSource := mPostProviderBO.GetFieldValueAsString('X_PD_Export_ID.DataSource');
          CFxReportManager.ExportByIDs(NxCreateContext(AOS), mTMP, mExportDataSource, mExport_ID, 2, '', mFileName);
          ShowDebugMessage('aft mlist ' + mTMP.CommaText);
          RemoveQuoted(mTMP);
        end else
          RaiseException(lng_msg_PProviderFieldExportNotSet);
        OutputDebugString('Temp File Export '+ mFileName);
        if not FileExists(mFileName) then
          RaiseException(lng_msg_ExportFileNotFound+mFileName);


        mStatusCode := WSPostFile_2(NxCreateContext(AOS), mFileName, TrimVersion(mPostProviderBO.GetFieldValueAsString('X_PD_WS')) +GetSubModulName(mPostProviderBO.GetFieldValueAsInteger('X_PD_BB_ProviderModul'))+'/check', mResponseText,mIssuedDocBO);
        //FileOpen(mFileName,fmShareDenyNone);
        if not DeleteFile(mFileName) then
          RaiseException(lng_msg_ExportDeleteError+mFileName +#10#13+'. Pravděpodobně bude docházet k chybě "Nepodařilo se upravit soubor exportu"');

        showdebugmessage2('BBExport', 'HTTP komunikace navrací status code: ' + IntToStr(mStatusCode));
        if mStatusCode <> 200 then
          RaiseException(lng_msg_ConnectionError + IntToStr(mStatusCode) + '.');
        mStatusCode := -1;  //reciklace

        mJSONResponseBody:= TJSONSuperObject.ParseString(mResponseText,true);

        //dohledá v JSON existenci "status" elementu
        mStatusCode := GetStatusCode(mJSONResponseBody);


        //Stav celého dotazu.
        mStatusError := TypeStatusCode(mStatusCode,mJSONResponseBody, mSoftError, mError);
        if mError > 0 then
          AErrorLog := AErrorLog + cCrLf + format(lng_msg_ErrorReceived1,[GetPMDDocDisplayName(AOS,AIDs[z]),GetSubModulName(mPostProviderBO.GetFieldValueAsInteger('X_PD_BB_ProviderModul'))]) + mStatusError;
        if mSoftError > 0 then
          AErrorLog := AErrorLog + cCrLf + format(lng_msg_WarningsReceived1,[GetPMDDocDisplayName(AOS,AIDs[z]),GetSubModulName(mPostProviderBO.GetFieldValueAsInteger('X_PD_BB_ProviderModul'))]) + mStatusError;

        if (mJSONResponseBody.AsString<> '') and (mJSONResponseBody.AsString <> 'null') and (mJSONResponseBody.AsString <> '{}') and (mJSONResponseBody.AsString <> '[]') then
        begin
          //Až když je vše v pořádku, pak lze získat další data jako je štítek
          if not ((mJSONResponseBody.N['status'].DataType = jtNull)  or (mJSONResponseBody.N['status'].DataType = -1)) then
            if mJSONResponseBody.I['status'] in [200,208] then
              for i:= 0 to cMaxCount do
              begin
                mIndex := IntToStr(i);
                if not ((mJSONResponseBody.N[mIndex].DataType = jtNull)  or (mJSONResponseBody.N[mIndex].DataType = -1)) then
                begin
                  if not ((mJSONResponseBody.O[mIndex].N['status'].DataType = jtNull)  or (mJSONResponseBody.O[mIndex].N['status'].DataType = -1)) then
                    if mJSONResponseBody.O[mIndex].I['status'] in [200,208] then
                    begin
                      try
                        //bez chyby

                      except
                        mErrorList.add(mPackageError);
                      end;
                    end
                    else
                    begin
                      //chyba byla již rozebrána nahoře
                    end;
                end;

              end;
            end;

      finally
        if mIssuedDocBO <> nil then
          mIssuedDocBO.Free;
      end;
    end;
  finally
    if mPostProviderBO <> nil then
      mPostProviderBO.free;
    if mJSONResponseBody <> nil then
      mJSONResponseBody.free;
    if mErrorList.text <> '' then
      AErrorLog := AErrorLog + cCrLf + mErrorList.text;
    if mErrorList <> nil then
      mErrorList.Free;
    if mTMP <> nil then
      mTMP.Free;
  end;
end;


//R
procedure BBTransportCosts(AOS: TNxCustomObjectSpace; const AIDs: TStringList; var AErrorLog: String; const ADriver:Integer; const APostProviderBO : TNxCustomBusinessObject; var AResultList:TStringList);
var mErrorList, mTMP : TStringList;
    mJSONResponseBody : TJSONSuperObject;
    mResponseText, mStatusError, mPackageError, mFileName, mExport_ID,mExportDataSource : String;
    mStatusCode, mSoftError, mError : Integer;
    i, z : Integer;
    mPostProviderBO, mIssuedDocBO : TNxCustomBusinessObject;
    mIndex: String;
begin
  mStatusCode := -1;
  mJSONResponseBody := nil;
  mErrorList := nil;
  mPostProviderBO := nil;
  mTMP := nil;
  mIssuedDocBO := nil;
  RemoveQuoted(AIDs);
  try
    mPostProviderBO := AOS.CreateObject(Class_PDMPostProvider);
    mErrorList := TStringList.Create();
    mTMP := TStringList.Create();

    for z := 0 to AIDs.Count -1 do
    begin
      try
        mIssuedDocBO := AOS.CreateObject(Class_PDMIssuedDoc);
        mTMP.Clear;
        mTMP.Add(AIDs[z]);
        mIssuedDocBO.Load(AIDs[z],nil);
        //pokud je balík druhý a další, pak se přeskakuje. Důvodem je exportu spolu s hlavním balíkem.
        if mIssuedDocBO.GetFieldValueAsInteger('X_PD_PosIndex') > 1 then continue;

        //Funkce přidá podřízené balíky. Následně se bude exportovat v jednom requestu.
        AddToListSubPackages(AOS, mTMP[0], mTMP);

        mPostProviderBO.Load(mIssuedDocBO.GetFieldValueAsString('PostProvider_ID'),nil);
        //export pro všechny dopravce. DPD nevrací externí id při chybě a není kontrola nad tím jaký dolad je špatně. Tedy je odesíláno jedno po druhém.
        if not NxCreateTempFile(mFileName) then
          RaiseException(lng_msg_CantCreateExportFile);
        //nepodařilo se upravit soubor exportu.
        RenameFile(mFileName,NxLeft(mFileName,Length(mFileName)-4)+AIDs[z]+'.tmp');
        mFileName := NxLeft(mFileName,Length(mFileName)-4)+AIDs[z]+'.tmp';
        mExport_ID := mPostProviderBO.GetFieldValueAsString('X_PD_Export_ID');
        if not CFxOID.IsEmpty(mExport_ID) then begin
          ShowDebugMessage('bef mlist ' + mTMP.CommaText);
          mExportDataSource := mPostProviderBO.GetFieldValueAsString('X_PD_Export_ID.DataSource');
          CFxReportManager.ExportByIDs(NxCreateContext(AOS), mTMP, mExportDataSource, mExport_ID, 2, '', mFileName);
          ShowDebugMessage('aft mlist ' + mTMP.CommaText);
          RemoveQuoted(mTMP);
        end else
          RaiseException(lng_msg_PProviderFieldExportNotSet);
        OutputDebugString('Temp File Export '+ mFileName);
        if not FileExists(mFileName) then
          RaiseException(lng_msg_ExportFileNotFound+mFileName);


        mStatusCode := WSPostFile_2(NxCreateContext(AOS), mFileName, TrimVersion(mPostProviderBO.GetFieldValueAsString('X_PD_WS')) +GetSubModulName(mPostProviderBO.GetFieldValueAsInteger('X_PD_BB_ProviderModul'))+'/transportcosts', mResponseText,mIssuedDocBO);
        //FileOpen(mFileName,fmShareDenyNone);
        if not DeleteFile(mFileName) then
          RaiseException(lng_msg_ExportDeleteError+mFileName );

        showdebugmessage2('BBExport', 'HTTP komunikace navrací status code: ' + IntToStr(mStatusCode));
        if mStatusCode <> 200 then
          RaiseException(lng_msg_ConnectionError + IntToStr(mStatusCode) + '.');
        mStatusCode := -1;  //reciklace

        mJSONResponseBody:= TJSONSuperObject.ParseString(mResponseText,true);

        //dohledá v JSON existenci "status" elementu
        mStatusCode := GetStatusCode(mJSONResponseBody);


        //Stav celého dotazu.
        mStatusError := TypeStatusCode(mStatusCode,mJSONResponseBody, mSoftError, mError);
        if mError > 0 then
          AErrorLog := AErrorLog + cCrLf +  format(lng_msg_ErrorReceived1,[GetPMDDocDisplayName(AOS,AIDs[z]),GetSubModulName(mPostProviderBO.GetFieldValueAsInteger('X_PD_BB_ProviderModul'))]) + mStatusError;
        if mSoftError > 0 then
          AErrorLog := AErrorLog + cCrLf + format(lng_msg_WarningsReceived1,[GetPMDDocDisplayName(AOS,AIDs[z]),GetSubModulName(mPostProviderBO.GetFieldValueAsInteger('X_PD_BB_ProviderModul'))])  + mStatusError;

        if (mJSONResponseBody.AsString<> '') and (mJSONResponseBody.AsString <> 'null') and (mJSONResponseBody.AsString <> '{}') and (mJSONResponseBody.AsString <> '[]') then
        begin
          //Až když je vše v pořádku, pak lze získat další data jako je štítek
          if not ((mJSONResponseBody.N['status'].DataType = jtNull)  or (mJSONResponseBody.N['status'].DataType = -1)) then
            if mJSONResponseBody.I['status'] in [200,208] then
              if not ((mJSONResponseBody.N['message'].DataType = jtNull)  or (mJSONResponseBody.N['message'].DataType = -1)) then
                AResultList.add( mJSONResponseBody.S['message']  )  //Bože zase nekonzistentní
              else
              for i:= 0 to cMaxCount do
              begin
                mIndex := IntToStr(i);
                if not ((mJSONResponseBody.N[mIndex].DataType = jtNull)  or (mJSONResponseBody.N[mIndex].DataType = -1)) then
                begin
                  if not ((mJSONResponseBody.O[mIndex].N['status'].DataType = jtNull)  or (mJSONResponseBody.O[mIndex].N['status'].DataType = -1)) then
                    if mJSONResponseBody.O[mIndex].I['status'] in [200,208] then
                    begin
                      try
                        //bez chyby
                        ResTRANSPORTCOSTS_GetData(AOS, mJSONResponseBody, mPackageError, i, AResultList );
                      except
                        mErrorList.add(mPackageError);
                      end;
                    end
                    else
                    begin
                      //chyba byla již rozebrána nahoře
                    end;
                end;

              end;
            end;

      finally
        if mIssuedDocBO <> nil then
          mIssuedDocBO.Free;
      end;
    end;
  finally
    if mPostProviderBO <> nil then
      mPostProviderBO.free;
    if mJSONResponseBody <> nil then
      mJSONResponseBody.free;
    if mErrorList.text <> '' then
      AErrorLog := AErrorLog + cCrLf + mErrorList.text;
    if mErrorList <> nil then
      mErrorList.Free;
    if mTMP <> nil then
      mTMP.Free;
  end;
end;

//Navrácená data uloží.
//R
function ResTRANSPORTCOSTS_GetData(AOS: TNxCustomObjectSpace;var AJSON : TJSONSuperObject; var AErrorLog: String; AIndex: Integer; var AResultList:TStringList):Boolean;
var mStatusIndex: Integer;
    mBO : TNxCustomBusinessObject;
    mIndex :String;
begin
  Result := true;
  //najít status
  mBO := AOS.CreateObject(Class_PDMIssuedDoc);
  try
    try
      mIndex := IntToStr(AIndex);
      //zjistím zda má status.
      if not ((AJSON.O[mIndex].N['status'].DataType = jtNull)  or (AJSON.O[mIndex].N['status'].DataType = -1)) then
        mStatusIndex :=  AJSON.O[mIndex].I['status']
      else
        Result := false;

      if mStatusIndex = 200 then
      begin

        if not ((AJSON.O[mIndex].N['costs_total'].DataType = jtNull)  or (AJSON.O[mIndex].N['costs_total'].DataType = -1)) then
           AResultList.add( 'costs_total='+ FloatToStr( AJSON.O[mIndex].C['costs_total'] ) );

        if not ((AJSON.O[mIndex].N['currency'].DataType = jtNull)  or (AJSON.O[mIndex].N['currency'].DataType = -1)) then
           AResultList.add( 'currency='+  AJSON.O[mIndex].S['currency']  );

      end
      else
        Result := False;
    except
      AErrorLog := AErrorLog+ cCrlf+(lng_msg_ErrorGetPrice+ ExceptionMessage);
    end;
  finally
    if mBO <> nil then
      mBO.Free;
  end;

end;

/////////////////////////////////
/////////METODA API, ADD,B2A ////////
/////////////////////////////////


procedure SetStartActualizeTrackingStatus(var APDMIssuedDoc: TNxCustomBusinessObject);
begin
  if Assigned(APDMIssuedDoc) then
  begin
    //Například B2A nepodporuje u PPL sledování.
    if APDMIssuedDoc.GetFieldValueAsString('X_PD_API_ID') <> '' then
    begin
      APDMIssuedDoc.SetFieldValueAsInteger('X_PD_TrackingStatus', 1);
      APDMIssuedDoc.Save;
      APDMIssuedDoc.ObjectSpace.SQLExecute(
        'UPDATE PDMIssuedDocs SET X_PD_TrackingStatus = 1 WHERE X_PD_FirstPackage_ID = '+QuotedStr(APDMIssuedDoc.OID));
    end;
  end;
end;


{Přidá podřízené balíky připojené k hlavnímu balíku}
procedure AddToListSubPackages(var AOS:TNxCustomObjectSpace; const AFirstPackage: String; var AMainList: TStringList);
const  cSQL = 'select ID from PDMIssuedDocs where X_PD_FirstPackage_ID = ''%s'' ';
var mList: TStringList;
begin
  try
    mList := TStringList.Create();
    AOS.SQLSelect(Format(cSQL,[AFirstPackage]), mList);
    if mList.Count > 0 then
    begin
      AMainList.AddStrings(mList);
      ShowDebugMessage('Přidání připojených balíku v jedné zásilce. '+ AMainList.CommaText);
    end;
  finally
    mList.Free;
  end;
end;

//Navrácená data uloží.
//R
function ResADD_SaveData(AOS: TNxCustomObjectSpace; const AIDs: TStringList; var AJSON : TJSONSuperObject; var AErrorLog: String; const ADriver:Integer; AIndex: Integer;):Boolean;
var mStatusIndex: Integer;
    mBO : TNxCustomBusinessObject;
    mIndex :String;
begin
  Result := true;
  //najít status
  mBO := AOS.CreateObject(Class_PDMIssuedDoc);
  try
    try
      mIndex := IntToStr(AIndex);
      //zjistím zda má status.
      if not ((AJSON.O[mIndex].N['status'].DataType = jtNull)  or (AJSON.O[mIndex].N['status'].DataType = -1)) then
        mStatusIndex :=  AJSON.O[mIndex].I['status']
      else
        Result := false;

      if mStatusIndex = 200 then
      begin
        mBO.Load(AIDs[AIndex],nil);

        if not ((AJSON.O[mIndex].N['carrier_id'].DataType = jtNull)  or (AJSON.O[mIndex].N['carrier_id'].DataType = -1)) then
          mBO.SetFieldValueAsString('PostNumber', NxRight(AJSON.O[mIndex].S['carrier_id'], 15) );

        if not ((AJSON.O[mIndex].N['carrier_id'].DataType = jtNull)  or (AJSON.O[mIndex].N['carrier_id'].DataType = -1)) then
          mBO.SetFieldValueAsString('X_PD_LongPostNumber', AJSON.O[mIndex].S['carrier_id'] );


        if not ((AJSON.O[mIndex].N['package_id'].DataType = jtNull)  or (AJSON.O[mIndex].N['package_id'].DataType = -1)) then
          mBO.SetFieldValueAsString('X_PD_API_ID', AJSON.O[mIndex].S['package_id'] );

        if not ((AJSON.O[mIndex].N['label_url'].DataType = jtNull)  or (AJSON.O[mIndex].N['label_url'].DataType = -1)) then
          mBO.SetFieldValueAsString('X_PD_RawData', AJSON.O[mIndex].S['label_url'] );

        if not ((AJSON.O[mIndex].N['track_url'].DataType = jtNull)  or (AJSON.O[mIndex].N['track_url'].DataType = -1)) then
          mBO.SetFieldValueAsString('X_PD_Track_Url', AJSON.O[mIndex].S['track_url'] );

        mBO.Save;
      end
      else
        Result := False;
    except
      AErrorLog := AErrorLog+ cCrlf+(lng_msg_SaveError+ ExceptionMessage);
    end;
  finally
    if mBO <> nil then
      mBO.Free;
  end;

end;


//Navrácená data uloží.
//R
function ResB2C_SaveData(AOS: TNxCustomObjectSpace; const AIDs: TStringList; var AJSON : TJSONSuperObject; var AErrorLog: String; const ADriver:Integer; AIndex: Integer;):Boolean;
var mStatusIndex: Integer;
    mBO : TNxCustomBusinessObject;
    mIndex :String;
begin
  Result := true;
  //najít status
  mBO := AOS.CreateObject(Class_PDMIssuedDoc);
  try
    try
      mIndex := IntToStr(AIndex);
      //zjistím zda má status.
      if not ((AJSON.O[mIndex].N['status'].DataType = jtNull)  or (AJSON.O[mIndex].N['status'].DataType = -1)) then
        mStatusIndex :=  AJSON.O[mIndex].I['status']
      else
        Result := false;

      if mStatusIndex = 200 then
      begin
        mBO.Load(AIDs[AIndex],nil);

        if not ((AJSON.O[mIndex].N['carrier_id'].DataType = jtNull)  or (AJSON.O[mIndex].N['carrier_id'].DataType = -1)) then
          mBO.SetFieldValueAsString('PostNumber', NxRight(AJSON.O[mIndex].S['carrier_id'], 15) );

        if not ((AJSON.O[mIndex].N['carrier_id'].DataType = jtNull)  or (AJSON.O[mIndex].N['carrier_id'].DataType = -1)) then
          mBO.SetFieldValueAsString('X_PD_LongPostNumber', AJSON.O[mIndex].S['carrier_id'] );


        if not ((AJSON.O[mIndex].N['package_id'].DataType = jtNull)  or (AJSON.O[mIndex].N['package_id'].DataType = -1)) then
          mBO.SetFieldValueAsString('X_PD_API_ID', AJSON.O[mIndex].S['package_id'] );

        if not ((AJSON.O[mIndex].N['label_url'].DataType = jtNull)  or (AJSON.O[mIndex].N['label_url'].DataType = -1)) then
          mBO.SetFieldValueAsString('X_PD_RawData', AJSON.O[mIndex].S['label_url'] );

        if not ((AJSON.O[mIndex].N['track_url'].DataType = jtNull)  or (AJSON.O[mIndex].N['track_url'].DataType = -1)) then
          mBO.SetFieldValueAsString('X_PD_Track_Url', AJSON.O[mIndex].S['track_url'] );

        mBO.Save;
      end
      else
        Result := False;
    except
      AErrorLog := AErrorLog+ cCrlf+(lng_msg_SaveError+ ExceptionMessage);
    end;
  finally
    if mBO <> nil then
      mBO.Free;
  end;

end;




//Uloží štítek.
//R
function ResADD_SaveLabel(AOS: TNxCustomObjectSpace; const AIDs: TStringList; var AJsonPackage : TJSONSuperObject; var AErrorLog: String; const ADriver:Integer; AIndex: Integer;):Boolean;
var mBO : TNxCustomBusinessObject;
    mLabelURL : String;
begin
  Result := true;

  mBO := AOS.CreateObject(Class_PDMIssuedDoc);
  try
    try
      mBO.Load(AIDs[AIndex],nil);
      mLabelURL := mBO.GetFieldValueAsString('X_PD_RawData');
    if not ExistsDocumentLabel(AOS, AIDs[AIndex]) then
    begin
      DownloadDomument(AOS, mLabelURL, mBO,nil);
    end;
    except
      Result := False;
      RaiseException(ExceptionMessage);
    end;

  finally
    if mBO <> nil then
      mBO.Free;
  end;

end;


/////////////////////////////////
/////Synchronizace číselníky/////
/////////////////////////////////

//ruční obsluha SERVICES
//R
procedure DoSyncServices(Sender: TControl;);
var mOS : TNxCustomObjectSpace;
    mSuccess : Boolean;
    mLogInfoStr : String;
begin
  mOS := TSiteForm(Sender.Site).BaseObjectSpace;
  SyncServices(mOS, mSuccess,mLogInfoStr);
  if mLogInfoStr <> '' then
    ShowMessage(mLogInfoStr);
end;

//ruční obsluha BRANCHES
//R
procedure DoSyncBranches(Sender: TControl;);
var mOS : TNxCustomObjectSpace;
    mSuccess : Boolean;
    mLogInfoStr : String;
begin
  mOS := TSiteForm(Sender.Site).BaseObjectSpace;
  SyncBrances(mOS, mSuccess,mLogInfoStr);

  if mLogInfoStr <> '' then
    ShowMessage(mLogInfoStr);
end;


//ruční obsluha ManipulationUnits
//R
procedure DoSyncManupulationUnits(Sender: TControl;);
var mOS : TNxCustomObjectSpace;
    mSuccess : Boolean;
    mLogInfoStr : String;
begin
  mOS := TSiteForm(Sender.Site).BaseObjectSpace;
  SyncManupulationUnits(mOS, mSuccess,mLogInfoStr);

  if mLogInfoStr <> '' then
    ShowMessage(mLogInfoStr);
end;

///////////////////////////////////
///////OBSLUHA MANIPUL. UNIT///////
///////////////////////////////////

//synchronizace manipulační jednotky pro palerovou přepravu
//R
procedure  SyncManupulationUnits(OS: TNxCustomObjectSpace; var Success: Boolean; var LogInfoStr: String);
var mListSubProvider : TStringList;
    mBOProviders : TNxCustomBusinessObject;
    i : Integer;
    mWorkModulName : string;
begin
  mListSubProvider := nil;
  mBOProviders := nil;
  Success := True;
  LogInfoStr := '';
  mWorkModulName := '';
  mListSubProvider := TStringList.Create;
  try
    OS.SQLSelect(SQLGetAllLicProviderModul(True), mListSubProvider);
    if mListSubProvider.Count > 0 then
    begin
      for i:=0 to mListSubProvider.Count -1 do
      begin
        try
          try
            LoadPostProvider(OS, mListSubProvider[i], mBOProviders);
            mWorkModulName := GetSubModulName(mBOProviders.GetFieldValueAsInteger('X_PD_BB_ProviderModul'));

            SyncManipulationUnitModul(OS, mBOProviders, LogInfoStr);
          except
            LogInfoStr := LogInfoStr + cCrLf + Format( lng_msg_RequestError,[mWorkModulName]) + cCrLf + ExceptionMessage;
            //ShowDebugMessage2('SyncBrances', 'chyba při vyhodnocování poskytovatele ID: '+ mListSubProvider[i] + ' ' + ExceptionMessage);
          end;
        finally
          mWorkModulName := '';
          //zkušenost říká uvolnit
          if mBOProviders <> nil then
            mBOProviders.Free;
        end;

      end;
    end;

  finally
   if mListSubProvider <> nil then
    mListSubProvider.Free;
   if mBOProviders <> nil then
    mBOProviders.Free;
  end;

end;

///////////////////////Pokračovat zde


//obsluha jednoho modulu Branches
procedure  SyncManipulationUnitModul(const AOS: TNxCustomObjectSpace; var APostProviderBO : TNxCustomBusinessObject; var LogInfoStr: String);
var mJSONResponseBody : TJSONSuperObject;
    mResponseText, mStatusError : String;
    mStatusCode, mSoftError, mError : Integer;
    mErrorList, mListIssuedContentType : TStringList;
    mObjVer : integer;
begin
  mStatusCode := -1;
  mJSONResponseBody := nil;
  mErrorList := nil;
  mListIssuedContentType := nil;
  try
    mErrorList := TStringList.Create;
    try
      mStatusCode := WSGetFile(NxCreateContext(AOS),
                      TrimVersion( APostProviderBO.GetFieldValueAsString('X_PD_WS'))+
                      GetSubModulName(APostProviderBO.GetFieldValueAsInteger('X_PD_BB_ProviderModul'))+
                      '/manipulationunits', mResponseText,APostProviderBO);
      //ShowDebugMessage2('SyncBranchesModul', 'HTTP komunikace navrací status code: ' + IntToStr(mStatusCode));
      if mStatusCode <> 200 then
        RaiseException(lng_msg_ConnectionError + IntToStr(mStatusCode) + '.');
      mStatusCode := -1;  //reciklace
      mObjVer := 0;

      mJSONResponseBody:= TJSONSuperObject.ParseString(mResponseText,true);

      //dohledá v JSON existenci "status" elementu
      mStatusCode := GetStatusCode(mJSONResponseBody);

      mStatusError := TypeStatusCode(mStatusCode,mJSONResponseBody, mSoftError, mError);
      if mError > 0 then
        RaiseException(mStatusError);
      if mSoftError > 0 then
        LogInfoStr := LogInfoStr + cCrLf + Format( lng_msg_WarningsReceived2, [ GetSubModulName(APostProviderBO.GetFieldValueAsInteger('X_PD_BB_ProviderModul'))] ) + mStatusError;

      //Zjistím maximální číslo Verze objektu +1 bude aktuální. Co po dokončení zůstane nastavím na skryté.
      mObjVer := GetMaxObjVerManipulationUnit(AOS, APostProviderBO) + 1;
      ShowDebugMessage('Service_types: max ObjVer '+IntToStr(mObjVer));
      CreateManipulationUnit(AOS,mJSONResponseBody, APostProviderBO, mErrorList, mObjVer);

      //nakonec skrýt to co nemá správnou verzy  objver < než aktuaální verze
      HiddeOlderManipulationUnit(AOS, APostProviderBO, mObjVer);
    except
      mErrorList.add(ExceptionMessage);
    end;
    if mErrorList.Count > 0 then
      LogInfoStr := LogInfoStr + cCrLf + mErrorList.Text;
  finally
   if mJSONResponseBody <> nil then
    mJSONResponseBody.Free;
   if mErrorList <> nil then
    mErrorList.Free;
   if mListIssuedContentType <> nil then
    mListIssuedContentType.Free;
  end;

end;

function GetMaxObjVerManipulationUnit(const AOS: TNxCustomObjectSpace ;APostProviderBO : TNxCustomBusinessObject;):Integer;
var mResSQL : String;
const cSQLSelMaxFromManipulationUnit = 'select max(a.X_MU_ObjectVersion) from DefRollData a where a.hidden = ''N'' and a.clsid = ''%s'' and a.X_AN_PostProvider_ID = ''%s'' ';
begin
  Result:= 0;
  mResSQL := GetFirstRecordFromSQL(AOS, format(cSQLSelMaxFromManipulationUnit,[Class_BOManipulationUnits, APostProviderBO.OID]));
  if mResSQL <> '' then
    Result := StrToIntDef(mResSQL,0)
end;


function HiddeOlderManipulationUnit(const AOS: TNxCustomObjectSpace;  APostProviderBO : TNxCustomBusinessObject; const AObjVer: Integer):Integer;
var mResSQL, mStation_ID : String;
    mListOID : TStringList;
const cSQLSelOlder = 'select max(a.X_MU_ObjectVersion) from DefRollData a where a.hidden = ''N'' and a.X_AN_PostProvider_ID = ''%s'' and a.X_MU_ObjectVersion = ''%s'' and a.clsid = ''%s'' ';
      cSQLSelOlderSelDat = 'update DefRollData  SET HIDDEN = ''A'' where clsid = ''%s'' and id in(select s.obj_id from seldat s where s.Obj_ID = ID)';
begin
  try
    mListOID := TStringList.Create;
    Result:= 0;
    AOS.SQLSelect(Format(cSQLSelOlder,[APostProviderBO.OID,IntToStr(AObjVer-1),Class_BOManipulationUnits]), mListOID);

    if mListOID.Count > 0 then
    begin
      mStation_ID := StringsToSelDat(AOS, mListOID);
      try
        Result := AOS.SQLExecute(format(cSQLSelOlderSelDat,[Class_BOManipulationUnits]));
      finally
        ClearSelDat(AOS, mStation_ID);
      end;
    end;
  finally
    mListOID.Free;
  end;
end;

procedure CreateManipulationUnit(const AOS: TNxCustomObjectSpace; var AJSONData: TJSONSuperObject; APostProviderBO : TNxCustomBusinessObject; var AErrorList: TStringList; const AObjVer : Integer;);
var i: Integer;
    mJsonKeyArray : TJSONSuperObjectArray;
    mJsonBranches : TJSONSuperObject;
    mKey : String;
begin
  mKey := '';

  if (AJSONData.s[cBBObj_Units] <> '') and (AJSONData.s[cBBObj_Units] <> 'null') and (AJSONData.s[cBBObj_Units] <> '{}') then
  begin
    //vrátí seznam klíčů.
    mJsonKeyArray := AJSONData.O[cBBObj_Units].AsObject.GetNames.AsArray;
    for i:= 0 to mJsonKeyArray.Length -1 do
    begin
      try
        mKey := '';

        mKey := mJsonKeyArray.S(i);
        mJsonBranches :=  AJSONData.O[cBBObj_Units].O[mKey];

        ShowDebugMessage('ManipulationUnit: '+mKey + '='+AJSONData.O[cBBObj_Units].O[mKey].s['name']);
        SyncManipulationUnit(AOS,mKey, mJsonBranches, APostProviderBO,  AObjVer);
      except
        AErrorList.Add(Format(lng_msg_SyncError,[ mKey] )+ ExceptionMessage);
      end;
    end;
  end;
end;


procedure SyncManipulationUnit(const AOS: TNxCustomObjectSpace; const AIndex: String; var AJsonData : TJSONSuperObject; APostProviderBO : TNxCustomBusinessObject; const AObjVer : Integer;);
var mSelResponse : String;
    mBO : TNxCustomBusinessObject;
const cSQLSelServiceManipulationUnit = 'select a.id from DefRollData a where a.hidden = ''N'' and a.clsid = ''%s'' and a.X_AN_PostProvider_ID = ''%s'' and (a.code = ''%s'' or a.X_PD_ExternID = ''%s'') and a.name = ''%s'' ';
begin
  try
    mBO := nil;

    mSelResponse := '';
    mSelResponse := GetFirstRecordFromSQL(AOS, Format(cSQLSelServiceManipulationUnit,[Class_BOManipulationUnits,APostProviderBO.OID, AJsonData.S(cBBStrCode),AJsonData.S(cBBStrCode),  AJsonData.S(cBBStrName)]));
    if mSelResponse = '' then
    begin
      AddManipulationUnit(AOS, AIndex, AJsonData, APostProviderBO, AObjVer);
    end
    else
    begin
      mBO := AOS.CreateObject(Class_BOManipulationUnits);
      mBO.Load(mSelResponse,nil);
      if Assigned(mBO) then
        UpdManipulationUnit(AOS, AIndex, AJsonData, APostProviderBO, mBO, AObjVer);
    end;
  finally
    if mBO <> nil then
      mBO.Free;
  end;

end;


//Přidá branches podle json object
procedure AddManipulationUnit(const AOS: TNxCustomObjectSpace; const AIndex: String; var AJsonData : TJSONSuperObject; APostProviderBO : TNxCustomBusinessObject; const AObjVer : Integer);
var mRow : TNxCustomBusinessMonikerCollection;
    i : Integer;
    mBO : TNxCustomBusinessObject;
begin
  mBO := nil;
  try
    try
      mBO := AOS.CreateObject(Class_BOManipulationUnits);
      mBO.New;
      mBO.Prefill;

      mBO.SetFieldValueAsString('X_AN_PostProvider_ID', APostProviderBO.OID);
      mBO.SetFieldValueAsString('Name', AJsonData.S(cBBStrName) );
      mBO.SetFieldValueAsString('Code', nxleft(AJsonData.S(cBBStrCode),10) );
      mBO.SetFieldValueAsString('X_PD_ExternID', AJsonData.S(cBBStrCode) );
      mBO.SetFieldValueAsInteger('X_MU_ObjectVersion', AObjVer);


      mBO.Save;
    except
      RaiseException(lng_msg_SyncMUError + ExceptionMessage);
    end;
  finally
    if mBO <> nil then
      mBO.Free;
  end;
end;

//Přidá branches podle json object
procedure UpdManipulationUnit(const AOS: TNxCustomObjectSpace; const AIndex: String; var AJsonData : TJSONSuperObject; APostProviderBO : TNxCustomBusinessObject;  var ABO : TNxCustomBusinessObject; const AObjVer : Integer);
var mRow : TNxCustomBusinessMonikerCollection;
    i : Integer;
begin
  try
    OutputDebugString('Strat UpdManipulationUnit');
    ABO.SetFieldValueAsString('X_AN_PostProvider_ID', APostProviderBO.OID);
    ABO.SetFieldValueAsString('Name', AJsonData.S(cBBStrName) );
    ABO.SetFieldValueAsString('Code',  nxleft(AJsonData.S(cBBStrCode),10) );
    ABO.SetFieldValueAsString('X_PD_ExternID', AJsonData.S(cBBStrCode) );
    ABO.SetFieldValueAsInteger('X_MU_ObjectVersion', AObjVer);

    ABO.Save;
    OutputDebugString('End UpdManipulationUnit');
  except
    RaiseException( lng_msg_SyncMUSaveError + ExceptionMessage);
  end;
end;

////end

///////////////////////////////////
/////////OBSLUHA BRANCHES//////////
///////////////////////////////////

//synchronizace poboček ke konkrétní službě a poskytovateli
//SR
procedure  SyncBrances(OS: TNxCustomObjectSpace; var Success: Boolean; var LogInfoStr: String);
var mListSubProvider : TStringList;
    mBOProviders : TNxCustomBusinessObject;
    i : Integer;
    mWorkModulName : string;
begin
  mListSubProvider := nil;
  mBOProviders := nil;
  Success := True;
  LogInfoStr := '';
  mWorkModulName := '';
  mListSubProvider := TStringList.Create;
  try
    OS.SQLSelect(SQLGetAllLicProviderModul(True), mListSubProvider);
    if mListSubProvider.Count > 0 then
    begin
      for i:=0 to mListSubProvider.Count -1 do
      begin
        try
          try
            LoadPostProvider(OS, mListSubProvider[i], mBOProviders);
            mWorkModulName := GetSubModulName(mBOProviders.GetFieldValueAsInteger('X_PD_BB_ProviderModul'));

            SyncBranchesModul(OS, mBOProviders, LogInfoStr);
          except
            LogInfoStr := LogInfoStr + cCrLf +  Format( lng_msg_RequestError,[mWorkModulName]) + cCrLf + ExceptionMessage;

          end;
        finally
          mWorkModulName := '';
          //zkušenost říká uvolnit
          if mBOProviders <> nil then
            mBOProviders.Free;
        end;

      end;
    end;

  finally
   if mListSubProvider <> nil then
    mListSubProvider.Free;
   if mBOProviders <> nil then
    mBOProviders.Free;
  end;

end;

//obsluha jednoho modulu Branches
procedure  SyncBranchesModul(const AOS: TNxCustomObjectSpace; var APostProviderBO : TNxCustomBusinessObject; var LogInfoStr: String);
var mJSONResponseBody : TJSONSuperObject;
    mResponseText, mStatusError : String;
    mStatusCode, mSoftError, mError : Integer;
    mErrorList, mListIssuedContentType, mListAllowedCountryCode : TStringList;
    i, x, mObjVer : Integer;
    mBOIssuedContentType : TNxCustomBusinessObject;
    mAndWhereHide : String;
begin
  mAndWhereHide := '';
  mStatusCode := -1;
  mJSONResponseBody := nil;
  mErrorList := nil;
  mListIssuedContentType := nil;
  mBOIssuedContentType := nil;
  try
    mErrorList := TStringList.Create;
    mListAllowedCountryCode := TStringList.Create;
    mListIssuedContentType := TStringList.Create;

    //Zásilkovna má vyjímku a neexistují u ní žádné služby
    AOS.SQLSelect(SQLGetContentTypesByProvider(APostProviderBO.OID),mListIssuedContentType);
    for i := 0 to mListIssuedContentType.count -1 do
    begin
      mListAllowedCountryCode.clear;
      if APostProviderBO.GetFieldValueAsString('X_PD_CountryCodeFilter') <> '' then
      begin
        NxTrapStrToStrings(APostProviderBO.GetFieldValueAsString('X_PD_CountryCodeFilter'),',',mListAllowedCountryCode);

      end
      else
        mListAllowedCountryCode.add('*'); //projde jenom jednou bez filtru

      //Balíkobot již opravil mnou nahlášený nesmysl. nyní mohu volat v2

      for x := 0 to mListAllowedCountryCode.count -1 do
      begin
        try
          try
            if (Length(mListAllowedCountryCode[x]) <> 2) and ((mListAllowedCountryCode[x]) <> '*') then
              RaiseException(mListAllowedCountryCode[x] + ' není správný kód země.');
            mBOIssuedContentType := AOS.CreateObject(Class_PDMIssuedContentType);
            mBOIssuedContentType.Load(mListIssuedContentType[i],nil);

            mAndWhereHide := '';
            if (mListAllowedCountryCode[x] <> '*') then
            begin
              mAndWhereHide :=  Format(' and a.X_PD_BranchesCountry = ''%s'' ', [mListAllowedCountryCode[x]]);
              //if mBOIssuedContentType.GetFieldValueAsInteger('X_PD_MainPostProvider_ID.X_PD_BB_ProviderModul') <> 19 then //zasilkovna
              mStatusCode := WSGetFile(NxCreateContext(AOS), ( APostProviderBO.GetFieldValueAsString('X_PD_WS')) +GetSubModulName(APostProviderBO.GetFieldValueAsInteger('X_PD_BB_ProviderModul'))+'/branches/'+mBOIssuedContentType.GetFieldValueAsString('code')+'/'+mListAllowedCountryCode[x], mResponseText,APostProviderBO)
              //else
              //  mStatusCode := WSGetFile(NxCreateContext(AOS), ( APostProviderBO.GetFieldValueAsString('X_PD_WS')) +GetSubModulName(APostProviderBO.GetFieldValueAsInteger('X_PD_BB_ProviderModul'))+'/branches/'+mListAllowedCountryCode[x], mResponseText,APostProviderBO);
              //mErrorList.add( APostProviderBO.GetFieldValueAsString('X_PD_WS') +GetSubModulName(APostProviderBO.GetFieldValueAsInteger('X_PD_BB_ProviderModul'))+'/branches/'+mBOIssuedContentType.GetFieldValueAsString('code')+'/'+mListAllowedCountryCode[x]);
            end
            else
            begin
              //if mBOIssuedContentType.GetFieldValueAsInteger('X_PD_MainPostProvider_ID.X_PD_BB_ProviderModul') <> 19 then //zasilkovna
              mStatusCode := WSGetFile(NxCreateContext(AOS), ( APostProviderBO.GetFieldValueAsString('X_PD_WS')) +GetSubModulName(APostProviderBO.GetFieldValueAsInteger('X_PD_BB_ProviderModul'))+'/branches/'+mBOIssuedContentType.GetFieldValueAsString('code'), mResponseText,APostProviderBO);
              //else
                //mStatusCode := WSGetFile(NxCreateContext(AOS), ( APostProviderBO.GetFieldValueAsString('X_PD_WS')) +GetSubModulName(APostProviderBO.GetFieldValueAsInteger('X_PD_BB_ProviderModul'))+'/branches', mResponseText,APostProviderBO);
              //mErrorList.add( APostProviderBO.GetFieldValueAsString('X_PD_WS') +GetSubModulName(APostProviderBO.GetFieldValueAsInteger('X_PD_BB_ProviderModul'))+'/branches/'+mBOIssuedContentType.GetFieldValueAsString('code'));
            end;
            if mStatusCode <> 200 then
              RaiseException(lng_msg_ConnectionError + IntToStr(mStatusCode) + '.');
            mStatusCode := -1;  //reciklace
            mObjVer := 0;
            //SaveDebugFile('MainServices.json',mResponseText,False);

            mJSONResponseBody:= TJSONSuperObject.ParseString(mResponseText,true);

            //dohledá v JSON existenci "status" elementu
            mStatusCode := GetStatusCode(mJSONResponseBody);

            mStatusError := TypeStatusCode(mStatusCode,mJSONResponseBody, mSoftError, mError);
            if mError > 0 then
              RaiseException(mStatusError);
            if mSoftError > 0 then
              LogInfoStr := LogInfoStr + cCrLf +  Format(lng_msg_WarningsReceived2,[GetSubModulName(APostProviderBO.GetFieldValueAsInteger('X_PD_BB_ProviderModul'))]) + mStatusError;

            //Zjistím maximální číslo Verze objektu +1 bude aktuální. Co po dokončení zůstane nastavím na skryté.
            mObjVer := GetMaxObjVerBramches(AOS,  mBOIssuedContentType.GetFieldValueAsString('code'), APostProviderBO) + 1;
            //ShowDebugMessage('Service_types: max ObjVer '+IntToStr(mObjVer));
            CFxProfiler.EnterProc('SyncBranchesModul', 'Main');
            CreateBranches(AOS,mJSONResponseBody, APostProviderBO, mBOIssuedContentType, mErrorList, mObjVer);
            CFxProfiler.ExitProc('SyncBranchesModul', 'Main');

            //nakonec skrýt to co nemá správnou verzy  objver < než aktuaální verze
            //Skyrývání zrušeno. Velice často došlo k tomu, že se skryla v 5:00 po synchro a reálně nebla již v 10:00 uzařena. Mnoho potvrzených případů
            //HiddeOlderBranches(AOS, APostProviderBO, mBOIssuedContentType.GetFieldValueAsString('code'), mObjVer,mAndWhereHide);
          except
            mErrorList.add(ExceptionMessage);
          end;
        finally
          if mBOIssuedContentType <> nil then
            mBOIssuedContentType.Free;
        end;
      end;
    end;
    if mErrorList.Count > 0 then
      LogInfoStr := LogInfoStr + cCrLf + mErrorList.Text;
  finally
   if mJSONResponseBody <> nil then
    mJSONResponseBody.Free;
   if mErrorList <> nil then
    mErrorList.Free;
   if mListIssuedContentType <> nil then
    mListIssuedContentType.Free;
   mListAllowedCountryCode.free;
  end;

end;

function HiddeOlderBranches(const AOS: TNxCustomObjectSpace;  APostProviderBO : TNxCustomBusinessObject; const AContentTypeCode: String ; const AObjVer: Integer; AAndWhere : String = ''):Integer;
var mResSQL, mStation_ID : String;
    mListOID : TStringList;
const cSQLSelOlder = 'select a.id from pdmservicetypes a join pdmissuedcontenttypes ic on ic.id = a.x_pd_issuedcontenttype_id ' +
                     ' where ic.code = ''%s'' and a.hidden = ''N'' and a.x_pd_postprovider_id = ''%s'' and a.x_pd_objectVersion = %s %s ';
      cSQLSelOlderSelDat = 'update pdmservicetypes A SET A.HIDDEN = ''A'' where a.id in(select s.obj_id from seldat s where s.Obj_ID = A.ID)';
begin
  try
    mListOID := TStringList.Create;
    Result:= 0;

    AOS.SQLSelect(Format(cSQLSelOlder,[AContentTypeCode,APostProviderBO.OID,IntToStr(AObjVer-1), NxIIfStr(AAndWhere = '', '', AAndWhere  )  ]), mListOID);

    if mListOID.Count > 0 then
    begin
      mStation_ID := StringsToSelDat(AOS, mListOID);
      try
        Result := AOS.SQLExecute(cSQLSelOlderSelDat);
      finally
        ClearSelDat(AOS, mStation_ID);
      end;
    end;
  finally
    mListOID.Free;
  end;
end;

function GetMaxObjVerBramches(const AOS: TNxCustomObjectSpace; const AContentTypeCode: String ;APostProviderBO : TNxCustomBusinessObject; ):Integer;
var mResSQL : String;
const cSQLSelMaxFromBranchese = 'select max(a.X_PD_ObjectVersion) from pdmservicetypes a join pdmissuedcontenttypes ic on ic.id = a.x_pd_issuedcontenttype_id '+
                                ' where ic.code = ''%s'' and a.hidden = ''N'' and a.x_pd_postprovider_id = ''%s'' ';
begin
  Result:= 0;
  mResSQL := GetFirstRecordFromSQL(AOS, format(cSQLSelMaxFromBranchese,[AContentTypeCode,APostProviderBO.OID]));
  if mResSQL <> '' then
    Result := StrToIntDef(mResSQL,0)
end;

//dohledá branches a zjistí všechny klíče. Ty následně a synchronozuje
procedure CreateBranches(const AOS: TNxCustomObjectSpace; var AJSONData: TJSONSuperObject; APostProviderBO : TNxCustomBusinessObject; var AContentTypeBO : TNxCustomBusinessObject; var AErrorList: TStringList; const AObjVer : Integer;);
var i: Integer;
    mJsonKeyArray : TJSONSuperObjectArray;
    mJsonBranches : TJSONSuperObject;
    mKey : String;
begin
  mKey := '';

  if (AJSONData.s[cBBObj_Branches] <> '') and (AJSONData.s[cBBObj_Branches] <> 'null') and (AJSONData.s[cBBObj_Branches] <> '{}') then
  begin
    //vrátí seznam klíčů.
    mJsonKeyArray := AJSONData.O[cBBObj_Branches].AsObject.GetNames.AsArray;
    try
      for i:= 0 to mJsonKeyArray.Length -1 do
      begin
        try
          try
            mKey := '';
            mJsonBranches := nil;
            mKey := mJsonKeyArray.S(i);
            mJsonBranches :=  AJSONData.O[cBBObj_Branches].O[mKey];

            //ShowDebugMessage('Service_types: '+mKey + '='+AJSONData.O[cBBObj_Branches].O[mKey].s['name']);
            SyncBranches(AOS,mKey, mJsonBranches, APostProviderBO, AContentTypeBO, AObjVer);
          except
            AErrorList.Add( Format(lng_msg_SyncServicesError,[mKey])+ ExceptionMessage);
          end;
        finally
          mJsonBranches.free;
        end;
      end;
    finally
      mJsonKeyArray.free;
    end;
  end;
end;

//dohledá a pokud neexistuje založí službu
procedure SyncBranches(const AOS: TNxCustomObjectSpace; const AIndex: String; var AJsonData : TJSONSuperObject; APostProviderBO : TNxCustomBusinessObject; var AContentTypeBO : TNxCustomBusinessObject; const AObjVer : Integer;);
var mSelResponse : String;
    mBOServiceType : TNxCustomBusinessObject;
const cSQLSelServiceTypesByProvider = 'select a.id from pdmservicetypes a where a.x_pd_postprovider_id = ''%s'' and a.X_PD_ExternID = ''%s''  and a.X_PD_IssuedContentType_ID = ''%s'' ';
begin
  CFxProfiler.EnterProc('SyncBranchesModul', 'SaveUpdate');
  try
    mBOServiceType := nil;
    mSelResponse := '';
    mSelResponse := GetFirstRecordFromSQL(AOS, Format(cSQLSelServiceTypesByProvider,[APostProviderBO.OID, AJsonData.S(cBBStrID)   , AContentTypeBO.OID]));
    if CFxOID.IsEmptyOrFull(mSelResponse) then
    begin
      AddBranches(AOS, AIndex, AJsonData, APostProviderBO, AContentTypeBO, AObjVer);
    end
    else
    begin
      mBOServiceType := AOS.CreateObject(Class_PDMServiceType);
      mBOServiceType.Load(mSelResponse,nil);
      if Assigned(mBOServiceType) then
        UpdBranches(AOS, AIndex, AJsonData, APostProviderBO, AContentTypeBO, mBOServiceType, AObjVer);
    end;

  finally
    if mBOServiceType <> nil then
      mBOServiceType.Free;
  end;
  CFxProfiler.ExitProc('SyncBranchesModul', 'SaveUpdate');

end;


//Přidá branches podle json object
procedure AddBranches(const AOS: TNxCustomObjectSpace; const AIndex: String; var AJsonData : TJSONSuperObject; APostProviderBO : TNxCustomBusinessObject;  var AContentTypeBO : TNxCustomBusinessObject; const AObjVer : Integer);
var mRow : TNxCustomBusinessMonikerCollection;
    i : Integer;
    mBOServiceType : TNxCustomBusinessObject;
begin
  mBOServiceType := nil;
  try
    try
      mBOServiceType := AOS.CreateObject(Class_PDMServiceType);
      mBOServiceType.New;
      mBOServiceType.Prefill;

      mBOServiceType.SetFieldValueAsString('X_PD_ExternID', AJsonData.S(cBBStrID));
      mBOServiceType.SetFieldValueAsString('X_PD_PostProvider_ID', APostProviderBO.OID);
      mBOServiceType.SetFieldValueAsString('X_PD_IssuedContentType_ID', AContentTypeBO.OID);
      mBOServiceType.SetFieldValueAsString('Name',NxLeft( AJsonData.S(cBBStrName),100 ) );
      mBOServiceType.SetFieldValueAsString('X_PD_BranchesCity',NxLeft( AJsonData.S(cBBStrCity),60) );
      mBOServiceType.SetFieldValueAsString('X_PD_BranchesStreet',NxLeft( AJsonData.S(cBBStrStreet),50) );
      mBOServiceType.SetFieldValueAsString('X_PD_BranchesZip',NxLeft( AJsonData.S(cBBStrZip),20) );
      mBOServiceType.SetFieldValueAsString('X_PD_BranchesCountry',NxLeft( AJsonData.S(cBBStrCountry),3) );
      mBOServiceType.SetFieldValueAsString('X_PD_BranchesType', NxLeft( AJsonData.S(cBBStrType),10) );
      mBOServiceType.SetFieldValueAsInteger('X_PD_ObjectVersion', AObjVer);

      mBOServiceType.Save;
    except
      RaiseException(lng_msg_SyncServicesTypeError + ExceptionMessage );
    end;
  finally
    if mBOServiceType <> nil then
      mBOServiceType.Free;
  end;
end;

//Přidá branches podle json object
procedure UpdBranches(const AOS: TNxCustomObjectSpace; const AIndex: String; var AJsonData : TJSONSuperObject; APostProviderBO : TNxCustomBusinessObject;  var AContentTypeBO : TNxCustomBusinessObject; var ABOServiceType : TNxCustomBusinessObject; const AObjVer : Integer);
var mRow : TNxCustomBusinessMonikerCollection;
    i : Integer;
begin
  try
    ABOServiceType.SetFieldValueAsBoolean('Hidden',False);
    ABOServiceType.SetFieldValueAsString('X_PD_ExternID', AJsonData.S(cBBStrID) );
    ABOServiceType.SetFieldValueAsString('X_PD_PostProvider_ID', APostProviderBO.OID);
    ABOServiceType.SetFieldValueAsString('X_PD_IssuedContentType_ID', AContentTypeBO.OID);
    ABOServiceType.SetFieldValueAsString('Name',NxLeft(  AJsonData.S(cBBStrName),100) );
    ABOServiceType.SetFieldValueAsString('X_PD_BranchesCity',NxLeft( AJsonData.S(cBBStrCity),60) );
    ABOServiceType.SetFieldValueAsString('X_PD_BranchesStreet',NxLeft( AJsonData.S(cBBStrStreet),50) );
    ABOServiceType.SetFieldValueAsString('X_PD_BranchesZip',NxLeft( AJsonData.S(cBBStrZip),20) );
    ABOServiceType.SetFieldValueAsString('X_PD_BranchesCountry',NxLeft( AJsonData.S(cBBStrCountry),3) );
    ABOServiceType.SetFieldValueAsString('X_PD_BranchesType',NxLeft( AJsonData.S(cBBStrType),10) );
    ABOServiceType.SetFieldValueAsInteger('X_PD_ObjectVersion', AObjVer);

    ABOServiceType.Save;
  except
    RaiseException(lng_msg_SyncServicesTypeSaveError + ExceptionMessage);
  end;
end;

///////////////////////////////////
///////OBSLUHA SERVICES_TYPE///////
///////////////////////////////////
//v3.2 - Funkce rozšířena o parametr/schopnost synchronizovat služby 2BA a někdy i B2C


//Hlavní oblužní aparát services jednoho modulu
procedure  SyncServices(OS: TNxCustomObjectSpace; var Success: Boolean; var LogInfoStr: String);
var mListSubProvider : TStringList;
    mBOProviders : TNxCustomBusinessObject;
    i : Integer;
    mWorkModulName : string;
begin
  mListSubProvider := nil;
  mBOProviders := nil;
  Success := True;
  LogInfoStr := '';
  mWorkModulName := '';
  mListSubProvider := TStringList.Create;
  try
    OS.SQLSelect(SQLGetAllLicProviderModul(True), mListSubProvider);
    if mListSubProvider.Count > 0 then
    begin
      for i:=0 to mListSubProvider.Count -1 do
      begin
        try
          try
            LoadPostProvider(OS, mListSubProvider[i], mBOProviders);
            mWorkModulName := GetSubModulName(mBOProviders.GetFieldValueAsInteger('X_PD_BB_ProviderModul'));
            SyncServicesModul(OS, mBOProviders, LogInfoStr, cBBServiceType_ADD);
            if mBOProviders.GetFieldValueasboolean('X_PD_B2A') then
              SyncServicesModul(OS, mBOProviders, LogInfoStr, cBBServiceType_B2A);
            if mBOProviders.GetFieldValueasboolean('X_PD_B2C') then
              SyncServicesModul(OS, mBOProviders, LogInfoStr, cBBServiceType_B2C);
          except
            LogInfoStr := LogInfoStr + cCrLf +  Format( lng_msg_RequestError,[mWorkModulName]) + cCrLf + ExceptionMessage;
          end;
        finally
          mWorkModulName := '';
          if mBOProviders <> nil then
            mBOProviders.Free;
        end;

      end;
    end;

  finally
   if mListSubProvider <> nil then
    mListSubProvider.Free;
   if mBOProviders <> nil then
    mBOProviders.Free;
  end;

end;

//obsluha jednoho modulu services
//AServiceType = 0 => cBBServiceType_ADD
function  SyncServicesModul(const AOS: TNxCustomObjectSpace; var APostProviderBO : TNxCustomBusinessObject; var LogInfoStr: String; AServiceType:Integer = 0):Boolean;
var mJSONResponseBody : TJSONSuperObject;
    mResponseText, mStatusError : String;
    mStatusCode, mSoftError, mError, mObjVer : Integer;
    mErrorList,mListAllowedCountryCode : TStringList;
    x : Integer;
begin
  Result := true;
  mStatusCode := -1;
  mJSONResponseBody := nil;
  mErrorList := nil;
  mListAllowedCountryCode := nil;

  try
    mErrorList := TStringList.Create;
    mListAllowedCountryCode := TStringList.Create;

    mListAllowedCountryCode.clear;
    mListAllowedCountryCode.add('*'); //výchozí pro všechny je bez filtru. Toto zatím podporuje jenom uzasilkovna
    if APostProviderBO.GetFieldValueAsInteger('X_PD_BB_ProviderModul') = 19 then //zasilkovna
    begin
      if APostProviderBO.GetFieldValueAsString('X_PD_CountryCodeFilter') <> '' then
      begin
        mListAllowedCountryCode.clear;
        NxTrapStrToStrings(APostProviderBO.GetFieldValueAsString('X_PD_CountryCodeFilter'),',',mListAllowedCountryCode);
      end;
    end;
    for x := 0 to mListAllowedCountryCode.count -1 do
    begin

      if (Length(mListAllowedCountryCode[x]) <> 2) and ((mListAllowedCountryCode[x]) <> '*') then
        RaiseException(mListAllowedCountryCode[x] + ' není správný kód země.');

      //HTTP komunikace vrací kód 200 vždy i když nejsou data dohledána. Status je reprezentován v odpovědi  = JSON
      //TrimVersion odstraněno - funguje pro B2A i ADD
      if (mListAllowedCountryCode[x] <> '*') then
      begin
        case AServiceType of
          cBBServiceType_ADD : mStatusCode := WSGetFile(NxCreateContext(AOS), ( APostProviderBO.GetFieldValueAsString('X_PD_WS')) +GetSubModulName(APostProviderBO.GetFieldValueAsInteger('X_PD_BB_ProviderModul'))+'/services'+'/'+mListAllowedCountryCode[x], mResponseText,APostProviderBO);
          cBBServiceType_B2A : mStatusCode := WSGetFile(NxCreateContext(AOS), ( APostProviderBO.GetFieldValueAsString('X_PD_WS')) +GetSubModulName(APostProviderBO.GetFieldValueAsInteger('X_PD_BB_ProviderModul'))+'/b2a/services'+'/'+mListAllowedCountryCode[x], mResponseText,APostProviderBO);
          cBBServiceType_B2C : mStatusCode := WSGetFile(NxCreateContext(AOS), ( APostProviderBO.GetFieldValueAsString('X_PD_WS')) +GetSubModulName(APostProviderBO.GetFieldValueAsInteger('X_PD_BB_ProviderModul'))+'/services'+'/'+mListAllowedCountryCode[x], mResponseText,APostProviderBO);
        end;
      end
      else
      begin
        case AServiceType of
          cBBServiceType_ADD : mStatusCode := WSGetFile(NxCreateContext(AOS), ( APostProviderBO.GetFieldValueAsString('X_PD_WS')) +GetSubModulName(APostProviderBO.GetFieldValueAsInteger('X_PD_BB_ProviderModul'))+'/services', mResponseText,APostProviderBO);
          cBBServiceType_B2A : mStatusCode := WSGetFile(NxCreateContext(AOS), ( APostProviderBO.GetFieldValueAsString('X_PD_WS')) +GetSubModulName(APostProviderBO.GetFieldValueAsInteger('X_PD_BB_ProviderModul'))+'/b2a/services', mResponseText,APostProviderBO);
          cBBServiceType_B2C : mStatusCode := WSGetFile(NxCreateContext(AOS), ( APostProviderBO.GetFieldValueAsString('X_PD_WS')) +GetSubModulName(APostProviderBO.GetFieldValueAsInteger('X_PD_BB_ProviderModul'))+'/services', mResponseText,APostProviderBO);
        end;
      end;

      if mStatusCode <> 200 then
        RaiseException(lng_msg_ConnectionError + IntToStr(mStatusCode) + '.');
      mStatusCode := -1;  //reciklace
      mObjVer := 0;
      mJSONResponseBody:= TJSONSuperObject.ParseString(mResponseText,true);

      //dohledá v JSON existenci "status" elementu
      mStatusCode := GetStatusCode(mJSONResponseBody);

      mStatusError := TypeStatusCode(mStatusCode,mJSONResponseBody, mSoftError, mError);
      if mError > 0 then
      begin
        Result := false;
        LogInfoStr := LogInfoStr + cCrLf + mStatusError;
        exit;
      end;
      if mSoftError > 0 then
        LogInfoStr := LogInfoStr + cCrLf + Format(lng_msg_WarningsReceived2,[GetSubModulName(APostProviderBO.GetFieldValueAsInteger('X_PD_BB_ProviderModul'))]) + mStatusError;

      //Zjistím maximální číslo Verze objektu +1 bude aktuální. Co po dokončení zůstane nastavím na skryté.

      mObjVer := GetMaxObjVerServices(AOS, APostProviderBO,AServiceType) + 1;
      mObjVer :=0;
      CreateServiceTypes(AOS,mJSONResponseBody, APostProviderBO, mErrorList, mObjVer,AServiceType);

      HiddeOlderServices(AOS, APostProviderBO, mObjVer,AServiceType);

      //Projít poskytovatele a navázané skryté služby odpojím.
      UnplugOlderServicesFromProviders(AOS, APostProviderBO, mObjVer);

      if mErrorList.Count > 0 then
        LogInfoStr := LogInfoStr + cCrLf + mErrorList.Text;
    end;
  finally
   if mJSONResponseBody <> nil then
    mJSONResponseBody.Free;
   if mErrorList <> nil then
    mErrorList.Free;
   if mListAllowedCountryCode <> nil then
    mListAllowedCountryCode.free;
  end;

end;


function HiddeOlderServices(const AOS: TNxCustomObjectSpace;  APostProviderBO : TNxCustomBusinessObject; const AObjVer, AServiceType: Integer):Integer;
var mResSQL, mStation_ID : String;
    mListOID : TStringList;
const cSQLSelOlder = 'select a.id from PDMIssuedContentTypes a where a.hidden = ''N'' and a.X_PD_MainPostProvider_ID = ''%s'' and a.x_pd_objectVersion = %s and A.X_PD_ServiceType = %s ';
      cSQLSelOlderSelDat = 'update PDMIssuedContentTypes A SET A.HIDDEN = ''A'' where a.id in(select s.obj_id from seldat s where s.Obj_ID = A.ID)';
begin
  try
    mListOID := TStringList.Create;
    Result:= 0;
    AOS.SQLSelect(Format(cSQLSelOlder,[APostProviderBO.OID, IntToStr(AObjVer-1), IntToStr(AServiceType)]), mListOID);

    if mListOID.Count > 0 then
    begin
      mStation_ID := StringsToSelDat(AOS, mListOID);
      try
        Result := AOS.SQLExecute(cSQLSelOlderSelDat);
      finally
        ClearSelDat(AOS, mStation_ID);
      end;
    end;
  finally
    mListOID.Free;
  end;
end;

function UnplugOlderServicesFromProviders(const AOS: TNxCustomObjectSpace;  APostProviderBO : TNxCustomBusinessObject; const AObjVer: Integer):Integer;
var mRow : TNxCustomBusinessMonikerCollection;
    i : Integer;
    mBORow : TNxCustomBusinessObject;
begin
  Result := 0;
  try
    mRow := APostProviderBO.GetLoadedCollectionMonikerForFieldCode(APostProviderBO.GetFieldCode('rows'));
    for i := 0 to mRow.Count -1 do
    begin
      mBORow := mRow.BusinessObject(i);
      if mBORow.GetFieldValueAsBoolean('IssuedContentType_ID.Hidden') then
      begin
        Inc(Result,1);
        mBORow.Delete;
        ShowDebugMessage2('UnplugOlderServicesFromProviders', 'Byl odstraněn řádek připojené služby. ');
      end;
    end;

    APostProviderBO.Save;
  except
    RaiseException('Nepodařilo se odpojit typ slzžby v poštovním poskytovateli.' + ExceptionMessage);
  end;
end;

function GetMaxObjVerServices(const AOS: TNxCustomObjectSpace;  APostProviderBO : TNxCustomBusinessObject;const ServiceType:Integer):Integer;
var mResSQL : String;
const cSQLSelMaxFromBranchese = 'select max(a.X_PD_ObjectVersion) from PDMIssuedContentTypes a where a.hidden = ''N'' and a.X_PD_MainPostProvider_ID = ''%s'' and a.X_PD_ServiceType = %s ';
begin
  Result:= 0;
  mResSQL := GetFirstRecordFromSQL(AOS, format(cSQLSelMaxFromBranchese,[APostProviderBO.OID, IntToStr(ServiceType)]));
  if mResSQL <> '' then
    Result := StrToIntDef(mResSQL,0)
end;

//ABO musí být uvolněn
procedure LoadPostProvider(const AOS : TNxCustomObjectSpace; const AID : String; var ABO: TNxCustomBusinessObject);
begin
  ABO := AOS.CreateObject(Class_PDMPostProvider);
  if NxIsEmptyOID(AID) then
    ShowDebugMessage2('LoadPostProvider','Empty ID');
  ABO.Load(AID, nil);
end;


//dohledá service_type a zjistí všechny klíče. Ty následně dohledá a synchronozuje
procedure CreateServiceTypes(const AOS: TNxCustomObjectSpace; var AJSONData: TJSONSuperObject; APostProviderBO : TNxCustomBusinessObject; var AErrorList: TStringList; const AObjVer, AServiceType : Integer;);
var i: Integer;
    mJsonKeyArray : TJSONSuperObjectArray;
    mKey, mValue, mWorkModulName : String;
begin
  mKey := '';
  mValue := '';

  mWorkModulName := GetSubModulName(APostProviderBO.GetFieldValueAsInteger('X_PD_BB_ProviderModul'));
  //Zásilkovna vrátí prázdno (historicky v API BB), ale mi si pro něj založime jednu službu a tím nemusíme upravovat proces sync branches
  if (AJSONData.s[cBBObj_ServiceTypes] <> '') and (AJSONData.s[cBBObj_ServiceTypes] <> 'null') and (AJSONData.s[cBBObj_ServiceTypes] <> '{}')  then
  begin
    //vrátí seznam klíčů.
    mJsonKeyArray := AJSONData.O[cBBObj_ServiceTypes].AsObject.GetNames.AsArray;
    for i:= 0 to mJsonKeyArray.Length -1 do
    begin
      try
        mKey := '';
        mValue := '';
        mKey := mJsonKeyArray.S(i);
        mValue :=  AJSONData.O[cBBObj_ServiceTypes].S(mKey);

        ShowDebugMessage('Service_types: '+mKey + '='+mValue);
        SyncServiceType(AOS,mKey, mValue, APostProviderBO, AObjVer,AServiceType);
      except
        AErrorList.Add(  Format(lng_msg_SyncError2 ,[mKey,mValue]) + ExceptionMessage);
      end;
    end;
  end else if (mWorkModulName = 'zasilkovna') then
  begin
    SyncServiceType(AOS,'1', 'Zásilkovna', APostProviderBO, AObjVer,AServiceType);
  end;

end;

//dohledá a pokud neexistuje založí službu
procedure SyncServiceType(const AOS: TNxCustomObjectSpace; const AKey: String; const AValue: String; APostProviderBO : TNxCustomBusinessObject; const AObjVer,AServiceType : Integer;);
var i : Integer;
    mSelResponse : String;
    mBOContentType : TNxCustomBusinessObject;
const cSQLSelIssuedContentTypes = 'select a.id from PDMIssuedContentTypes a where a.hidden = ''N'' and a.X_PD_MainPostProvider_ID = ''%s'' and a.code = ''%s'' and a.X_PD_ServiceType = %s';
begin
  mBOContentType := nil;
  try
    mSelResponse := '';
    mSelResponse := GetFirstRecordFromSQL(AOS, Format(cSQLSelIssuedContentTypes,[APostProviderBO.OID, AKey, IntToStr(AServiceType) ]));
    if mSelResponse = '' then
    begin
      AddServiceTypeAndPrice(AOS, AKey, AValue, APostProviderBO, AObjVer,AServiceType);
    end
    else
    begin
      mBOContentType := AOS.CreateObject(Class_PDMIssuedContentType);
      mBOContentType.Load(mSelResponse,nil);
      if Assigned(mBOContentType) then
        UpdServiceTypeAndPrice(AOS, AKey, AValue, APostProviderBO,mBOContentType, AObjVer,AServiceType);
    end;
  finally
    if mBOContentType <> nil then
      mBOContentType.Free;
  end;

end;


//Provede aktualizaci služby
procedure UpdServiceTypeAndPrice(const AOS: TNxCustomObjectSpace; const AKey: String; const AValue: String; APostProviderBO : TNxCustomBusinessObject; var ABOContentType : TNxCustomBusinessObject; const AObjVer,AServiceType : Integer;);
begin
  try
    ABOContentType.SetFieldValueAsString('Code', AKey);
    ABOContentType.SetFieldValueAsString('Name', AValue );
    ABOContentType.SetFieldValueAsString('X_PD_MainPostProvider_ID', APostProviderBO.OID);
    ABOContentType.SetFieldValueAsInteger('X_PD_ObjectVersion',AObjVer);
    ABOContentType.SetFieldValueAsInteger('X_PD_ServiceType',AServiceType);

    ABOContentType.Save;
    ShowDebugMessage2('UpdServiceTypeAndPrice', 'Typ obsahu odeslané pošty byl opraven :'+AKey + ' ' + AValue);
  except
    RaiseException(lng_msg_SyncContentTypeSaveError + ExceptionMessage);
  end;
end;

//Přidá službu, ceník a připojí
procedure AddServiceTypeAndPrice(const AOS: TNxCustomObjectSpace; const AKey: String; const AValue: String; APostProviderBO : TNxCustomBusinessObject; const AObjVer,AServiceType  : Integer;);
var mRow : TNxCustomBusinessMonikerCollection;
    i : Integer;
    mBORow, mBOPriceList, mBOContentType : TNxCustomBusinessObject;
begin
  mBOPriceList := nil;
  try
    try
      mBOPriceList := AOS.CreateObject(Class_PDMPriceList);
      mBOPriceList.New;
      mBOPriceList.Prefill;
      mBOPriceList.SetFieldValueAsString('Code',NxLeft( AKey,10) );
      mBOPriceList.SetFieldValueAsString('Name',NxLeft(  AKey + ' '+AValue, 100) );

      mBOPriceList.Save;
    except
      RaiseException(lng_msg_SyncContentTypeError1+ ExceptionMessage);
    end;
    try
      mBOContentType := AOS.CreateObject(Class_PDMIssuedContentType);
      mBOContentType.New;
      mBOContentType.Prefill;
      mBOContentType.SetFieldValueAsString('Code',NxLeft( AKey, 10 ) );
      mBOContentType.SetFieldValueAsString('Name',NxLeft( AValue, 100) );
      mBOContentType.SetFieldValueAsString('X_PD_MainPostProvider_ID', APostProviderBO.OID);
      mBOContentType.SetFieldValueAsInteger('X_PD_ObjectVersion',AObjVer);
      mBOContentType.SetFieldValueAsInteger('X_PD_ServiceType',AServiceType);

      mBOContentType.Save;
      ShowDebugMessage2('AddServiceTypeAndPrice', 'Typ obsahu odeslané pošty byl založen :'+AKey + ' ' + AValue);
    except
      RaiseException(lng_msg_SyncContentTypeError + ExceptionMessage);
    end;

    try
      mRow := APostProviderBO.GetLoadedCollectionMonikerForFieldCode(APostProviderBO.GetFieldCode('rows'));
      mBORow := mRow.AddNewObject;
      mBORow.Prefill;
      mBORow.SetFieldValueAsString('IssuedContentType_ID', mBOContentType.OID);
      mBORow.SetFieldValueAsString('PriceList_ID', mBOPriceList.OID);

      APostProviderBO.Save;
    except
      RaiseException(lng_msg_SyncContentTypeError2+ ExceptionMessage);
    end;
  finally
    if mBOPriceList <> nil then
      mBOPriceList.Free;
    if mBOContentType <> nil then
      mBOContentType.Free;
  end;
end;


///////////////////
/////Prepare-SQL///
///////////////////

//vrátí všechny moduly balíkobota. Modul = poštovní poskytovatel. AWithMainProvider: omezení, které vrací pouze sub-provider.
function SQLGetAllLicProviderModul(const AWithMainProvider: Boolean = False):String;
var mCondititon: String;
const cSQLSelSubProvider = 'select a.id from pdmpostproviders a where a.x_pd_driver = %s %s';
      cCondition = 'and a.x_pd_bb_providermodul not in(0,1) and a.hidden = ''N''';
begin
  Result := '';
  mCondititon := '';
  if AWithMainProvider then mCondititon := cCondition;
  Result := Format(cSQLSelSubProvider,[IntToStr(cDriverBalikobot),mCondititon]);
end;

//vrátí všechny obsahy (služby) balíkobota. Omezené na typ služby ADD
function SQLGetContentTypesByProvider(const APostProviderID: String):String;
const cSQLSelIssuedContentTypeByProvider = 'select a.id from pdmissuedcontenttypes a where a.x_pd_mainpostprovider_id = ''%s'' and a.hidden = ''N'' and a.X_PD_ServiceType = 0';
begin
  Result := '';
  Result := Format(cSQLSelIssuedContentTypeByProvider,[APostProviderID]);
end;
//vrátí všechny moduly balíkobota. Modul = poštovní poskytovatel. AWithMainProvider: omezení, které vrací pouze sub-provider.
function SQLGetMainProviderBB():String;
var mCondititon: String;
const cSQLSelMainProvider = 'select a.id from pdmpostproviders a where a.x_pd_islicensed = ''A'' and a.x_pd_driver = %s' +
                           ' and a.x_pd_bb_providermodul = 1 and a.hidden = ''N''';
begin
  Result := '';
  Result := Format(cSQLSelMainProvider,[IntToStr(cDriverBalikobot)]);
end;

////////////////////////
/////Nástroje JSON//////
////////////////////////

//najde index klíče status.
function HaveObjectStatusKey(var AJsonArray : TJSONSuperObjectArray):Integer;
var i : Integer;
begin
  result := -1;
  for i := 0 to AJsonArray.Length -1 do
  begin
    if UpperCase(AJsonArray.S(i)) = 'STATUS' then
    begin
      Result:=i;
      break;
    end;
  end;
end;

//najde index klíče status.
(*
function JsonContainObjectName(var AJsonArray : TJSONSuperObjectArray; AName : String):Integer;
var i : Integer;
begin
  result := -1;


  for i := 0 to AJsonArray.Length -1 do
  begin
    if UpperCase(AJsonArray.S(i)) = UpperCase(AName) then
    begin
      Result:=i;
      break;
    end;
  end;
end;
*)

//Dohledá existenci node
//nahradit
(*
function IndexOfJsonNode(var AJsonArray : TJSONSuperObjectArray; const ASubStr: String):Integer;
var i : Integer;
begin
  result := -1;
  for i := 0 to AJsonArray.Length -1 do
  begin
    if UpperCase(AJsonArray.S(i)) = ASubStr then
    begin
      Result:=i;
      break;
    end;
  end;
end;
*)

//Pokud dohledá status v JSON response vrátí jej.
function GetStatusCode(const AJsonObject : TJSONSuperObject):Integer;
begin
    Result := -1;
    if not ((AJsonObject.N[cBBInt_Status].DataType = jtNull)  or (AJsonObject.N[cBBInt_Status].DataType = -1)) then
      Result := AJsonObject.I[cBBInt_Status];
end;

///////////////////
/////ACTION////////
///////////////////

procedure AddActionSyncServices(Self: TSiteForm);
var
  mAction: TAction;
begin
  mAction := Self.GetNewAction;
  mAction.ShowControl := True;
  mAction.ShowMenuItem := True;
  mAction.Caption := lng_btn_Sync;
  mAction.Hint := lng_btnHint_Sync0;
  mAction.Category := 'tabList';
  mAction.OnExecute := @DoSyncServices;

end;

procedure AddActionSyncBranches(Self: TSiteForm);
var
  mAction: TAction;
begin
  mAction := Self.GetNewAction;
  mAction.ShowControl := True;
  mAction.ShowMenuItem := True;
  mAction.Caption := lng_btn_Sync;
  mAction.Hint := lng_btnHint_Sync1;
  mAction.Category := 'tabList';
  mAction.OnExecute := @DoSyncBranches;
end;

procedure AddActionSyncManupulationUnits(Self: TSiteForm);
var
  mAction: TAction;
begin
  mAction := Self.GetNewAction;
  mAction.ShowControl := True;
  mAction.ShowMenuItem := True;
  mAction.Caption := lng_btn_Sync;
  mAction.Hint := lng_btnHint_Sync2;
  mAction.Category := 'tabList';
  mAction.OnExecute := @DoSyncManupulationUnits;
end;

///////////////////
/////CASE//////////
///////////////////

function GetSubModulName(const AIndex:Integer):string;
begin
  Result := '';
  case AIndex of
    0: Result := '';
    1: Result := 'Balíkobot';
    2: Result := 'airway'; //rezervace
    3: Result := 'cp';
    4: Result := 'dpd';
    5: Result := 'dhl';//2020
    6: Result := 'geis';
    7: Result := 'gls';
    8: Result := 'gw'; //rezervace
    9: Result := 'hds'; //rezervace
    10: Result := 'intime';
    11: Result := 'messenger';//2020
    12: Result := 'pbh';
    13: Result := 'ppl';
    14: Result := 'sm';//rezervace
    15: Result := 'tnt'; //2020
    16: Result := 'toptrans';
    17: Result := 'ulozenka';
    18: Result := 'ups';//2020
    19: Result := 'zasilkovna';
    20: Result := 'sp';
    21: Result := 'sps';
    22: Result := 'gwcz';
    23: Result := 'fofr';
    24: Result := 'wedo';
    25: Result := 'fedex';
    26: Result := 'dachser';
    27: Result := 'dhlparcel';
    28: Result := 'raben';
    29: Result := 'spring';
    30: Result := 'dsv';
    31: Result := 'dhlfreightec';
    32: Result := 'kurier';
    33: Result := 'dbschenker';
    34: Result := 'liftago';

  end;
end;

function GetSubModulNameByID(AOS: TNxCustomObjectSpace ;const AID:string):string;
const cSQLSelIndexModulByProviderId = 'select X_PD_BB_ProviderModul from pdmpostproviders where id = ''%s''';
begin
  Result:= '';
  Result := GetFirstRecordFromSQL(AOS, Format(cSQLSelIndexModulByProviderId,[AID]));
  if Result <> '' then
    Result := GetSubModulName(StrToInt(Result));
end;


//V přípdě nalezení vážné chyby inkrementuje var Error. Návratová hodnota je popis z dokumentace balíkobot.
function TypeStatusCode(const AStatusCode : Integer; var AJSON: TJSONSuperObject ; var ASoftValidateError: Integer; var AError: Integer):String;
var mError: String;
begin
  mError := '';
  ASoftValidateError := 0;
  AError := 0;
  case AStatusCode of
    200:  Result:='OK';
    208:
      begin
        Result:= '208: Položka s doloženým ID již existuje. Data, která jsou navrácena, patří k původnímu záznamu.';
        Inc(ASoftValidateError,1);
      end;
    400:
      begin
        Result:= '400: Operace neproběhla v pořádku, zkontrolujte data.';
        Inc(AError,1);
      end;
    403:
      begin
        Result:= '403: Přepravce není pro použité klíče aktivovaný.';
        Inc(AError,1);
      end;
    404:
      begin
        Result:= '404: Zásilka neexistuje, nebo již byla zpracována.';
        Inc(AError,1);
      end;
    406:
      begin
        Result:= '406: Nedorazila žádná data ke zpracování nebo nemůžou být akceptována.';
        Inc(AError,1);
      end;
    409:
      begin      //jiná formulace bude vhodná.
        Result:= '409: Konfigurační soubor daného dopravce nebo profil není vyplněn/konflikt mezi přijatými daty u zásilky '+
        '(například u DPD pokud je u zásilky, která má být zaslána službou DPD Classic, zaslána dobírka cod_price a zároveň '+
        'příznak, že se jedná o výměnnou zásilku swap, zašle se v navrácených datech u obou těchto atributů error code 409 – konflikt dat).';
        Inc(AError,1);
      end;
    413:
      begin
        Result:= '413: Špatný formát dat.';
        Inc(AError,1);
      end;
    423:
      begin
        Result:= '423: Tato funkce je dostupná jen pro „živé klíče“.';
        Inc(AError,1);
      end;
    501:
      begin
        Result:= '501: Technologie toho dopravce ještě není implementována, pro bližší informace sledujte web www.balikobot.cz.';
        Inc(AError,1);
      end;
    503:
      begin
        Result:= '503: Technologie dopravce není dostupná, požadavek bude vyřízen později';
        Inc(AError,1);
      end;
    else
      begin
        Result:= 'Jiná nespecifikovaná chyba.';
        Inc(AError,1);
      end;
  end;

  //Nově detail error
  if AStatusCode <> 200 then
  begin
    mError := GetErrors(AJSON);
    if mError <> '' then
      Result := mError;
  end;

end;


function GetErrors(var AJSON:TJSONSuperObject):String;
var mIndex, mIndex2, mMessage :String;
    i,j:Integer;
begin
  Result :='';
  mMessage := '';
  mIndex := '';
  mIndex2 := '';
  for i:= 0 to cMaxCount do
  begin
    mIndex := IntToStr(i);

    if not ((AJSON.N[mIndex].DataType = jtNull)  or (AJSON.N[mIndex].DataType = -1)) then
    begin
      if not ((AJSON.O[mIndex].N['errors'].DataType = jtNull)  or (AJSON.O[mIndex].N['errors'].DataType = -1)) then
        if not ((AJSON.O[mIndex].N['errors'].DataType = jtNull)  or (AJSON.O[mIndex].N['errors'].DataType = -1)) then
          for j := 0 to 5 do
          begin
            mIndex2 := IntToStr(j);
            if not ((AJSON.O[mIndex].O['errors'].N[mIndex2].DataType = jtNull)  or (AJSON.O[mIndex].O['errors'].N[mIndex2].DataType = -1)) then
              if not ((AJSON.O[mIndex].O['errors'].O[mIndex2].N['message'].DataType = jtNull)  or (AJSON.O[mIndex].O['errors'].O[mIndex2].N['message'].DataType = -1)) then
              begin
                mMessage := mMessage+ cCrLf + AJSON.O[mIndex].O['errors'].O[mIndex2].S['message'] ;

              end;
          end;
    end;

  end;
  Result := mMessage;

end;



///////////////////
/////Nástroje//////
///////////////////                                                                                                 //cLabelDocument = 1
procedure DownloadDomument(const AOS : TNxCustomObjectSpace; const AURL : String; var ABO: TNxCustomBusinessObject; const AIDsRelation : TStringList = nil ;const APrintTypeDocument : integer = 1; const AExt:String ='pdf');
var  mBODoc, mBODocContent, mBOData, mBOPackage, mPostProvider : TNxCustomBusinessObject;
     mStream : TMemoryStream;
     mBytes : TBytes;
     mDocID, mRelDef, mLogInfo : String;
     i: Integer;
begin
  mPostProvider := nil;
  mStream := TMemoryStream.Create();
  try

    //zjistit nastavení pro řadu a uživatele;
    try
      mPostProvider := AOS.CreateObject(Class_PDMPostProvider);
      mPostProvider.Load(ABO.GetFieldValueAsString('PostProvider_ID'),nil);
      WSGetBytes(NxCreateContext(AOS), AURL, mBytes, mPostProvider);

      mStream.SetBytes(mBytes);
      mDocID := SaveDocument(AOS, mStream, RightStr(AURL,10)+'.'+AExt,mLogInfo,mPostProvider,APrintTypeDocument);

      if NxIsEmptyOID(mDocID) then
        RaiseException(lng_msg_CantCreateFile);
      if AIDsRelation = nil then
      NewRelation(AOS,cRelDefDocument,ABO.OID,mDocID)
      else
      begin
        if Assigned(AIDsRelation) then
          for i:= 0 to AIDsRelation.Count -1 do
          begin
            NewRelation(AOS,cRelDefDocument,AIDsRelation[i],mDocID);
          end;
      end;

    finally
      mStream.Free;
      if mPostProvider <> nil then
        mPostProvider.Free;
    end;

  except
    RaiseException(mLogInfo);
  end;
end;

//ID vrátí DisplayName do výpisu chyby.
function GetPMDDocDisplayname(const AOS: TNxCustomObjectSpace ;const AID: String): string;
var
  mBO: TNxCustomBusinessObject;
begin
  try
    mBO :=AOS.CreateObject(Class_PDMIssuedDoc);
    mBO.Load(AID, nil);
    Result := mBO.GetFieldValueAsString('DisplayName');
  finally
    mBO.Free;
  end;
end;



{postará se o vytvoření a dokuemntu a nahrátí vybraného souboru}                                                                                                                   //cLabelDocument = 1
function SaveDocument(const AOS: TNxCustomObjectSpace;var AStream: TMemoryStream; const AFileName: String; var ALogInfo: String; var APostProviderBO: TNxCustomBusinessObject; const APrintTypeDocument : integer = 1):TNxOID;
var mBODoc, mBOData, mBODocContent : TNxCustomBusinessObject;
    mDocContents : TNxCustomBusinessMonikerCollection;
    mPArs : TNxParameters;
    mPar : TNxRawParameter;
begin
  /////ukládání dokumentu////////////
  try
    Result := '0000000000';
    mBODoc := AOS.CreateObject(Class_Document);
    mBODoc.New;
    mBODoc.Prefill;
    mBODoc.SetFieldValueAsString('DocQueue_ID',APostProviderBO.GetFieldValueAsString('X_PD_DPD_FileDocQueue_ID'));
    mBODoc.SetFieldValueAsString('Category_ID',APostProviderBO.GetFieldValueAsString('X_PD_DPD_DocCategory_ID'));
    mBODoc.SetFieldValueAsInteger('X_PD_DPD_PrintType',APrintTypeDocument);
    mDocContents := mBODoc.GetCollectionMonikerForFieldCode(mBODoc.GetFieldCode('Contents'));
    mBODocContent := mDocContents.AddNewObject;
    mBODocContent.SetFieldValueAsString('FileName',AFileName);
    try
      mBOData := mBODocContent.GetMonikerForFieldCode(mBODocContent.GetFieldCode('Data_ID')).BusinessObject;

      mPars := TNxParameters.Create;
      mPar := TNxRawParameter(TNxParameter.CreateFromDataType(dtVarBytes, 'BlobData', pkInput));
      mPar.LoadDataFromStream(AStream);
      mPars.Add(mPar);

      mBOData.SetFieldValues(mPars);
    finally
      mPar.Free;
      mPars.Free;
    end;
    mBODoc.Save;
    ShowDebugMessage('Save Documents');
    Result := mBODoc.OID;
    ShowDebugMessage('SaveDocument : Result : ' + Result);
  except
    ALogInfo := ALogInfo + #10#13 + ExceptionMessage;
    Result:='0000000000';
  end;
end;
                                                                                                            //cLabelDocument = 1
function ExistsDocumentLabel(const AOS : TNxCustomObjectSpace; const AID : String; const APrintTypeDocument : Integer = 1):Boolean;
const cSQLSel = 'select d.id from relations a join documents d on d.id = a.rightside_ID where a.rel_def = ''%s'' '+
             ' and d.x_PD_DPD_PrintType = %s and a.LEFTSIDE_ID = ''%s''';
begin
  Result := False;
  if GetFirstRecordFromSQL(AOS, Format(cSQLSel,[IntToStr(cRelDefDocument), IntToStr(APrintTypeDocument), AID])) <> '' then
    Result := True;
end;



procedure SaveDebugFile(const AFileName: String; const AContent: String; ASingleFile: Boolean = true);
var mStream : TMemoryStream;
begin
  try
    mStream := TMemoryStream.Create;
    if DirectoryExists(cBBSaveDebugDir) then
    begin
      if FileExists(cBBSaveDebugDir + AFileName) then
        DeleteFile(cBBSaveDebugDir + AFileName);
      mStream.SetBytes(TEncoding.GetBytes(AContent));
      if ASingleFile then
        mStream.SaveToFile(cBBSaveDebugDir + AFileName)
      else
        mStream.SaveToFile(cBBSaveDebugDir + AFileName +'_' + DateToStr(Now));

    end;
  finally

  end;
end;

procedure ShowDebugMessage(AMessage: Variant);
const cInDebug = true;
    cUseDebugger = true;
    cAppName = 'Balíkobot.PostProviders';
begin
  if cInDebug then begin
    if cUseDebugger then
      OutputDebugString(Format('%s : %s',[cAppName, VarToStr(AMessage)]))
    else
      ShowMessage(Format('%s : %s',[cAppName, VarToStr(AMessage)]));
  end;
end;

procedure ShowDebugMessage2(AFunction,AMessage: Variant);
const cInDebug = true;
    cUseDebugger = true;
    cAppName = 'Balíkobot.PostProviders';
begin
  if cInDebug then begin
    if cUseDebugger then
      OutputDebugString(Format('%s : F:%s : %s',[cAppName,VarToStr(AFunction), VarToStr(AMessage)]))
    else
      ShowMessage(Format('%s : F:%s : %s',[cAppName,VarToStr(AFunction), VarToStr(AMessage)]));
  end;
end;


procedure RemoveQuoted(var AIDs:TStringList);
var i:Integer;
begin
  for i := 0 to AIDs.Count -1 do
  begin
    AIDs[i] :=NxTrim(AIDs[i],'''');
  end;
end;


//////////////////////////////////
/////Nástroje business object/////
//////////////////////////////////


{změna stavu procesu}
procedure ChangeStatus(var ABO: TNxCustomBusinessObject; AStatusIndex: Integer; var AErrorLog :String; ANeedSave : Boolean = True);
var mList : TStringList;
    i, mRel : Integer;
    mRightID, mRow, mTableName : String;
    mClass : TNxPackedGuid;
    mBO : TNxCustomBusinessObject;
begin
  try
    try
      mTableName := '';
      mList := TStringList.Create();
      if Assigned(ABO) then
      begin
      ABO.SetFieldValueAsInteger('X_PD_Status',AStatusIndex);
      if ANeedSave then
        ABO.Save;
      end;
      ABO.ObjectSpace.SQLExecute('Update PDMIssuedDocs set X_PD_Status = '+IntToStr(AStatusIndex)+' where X_PD_FirstPackage_ID = '+QuotedStr(ABO.OID));
      ABO.ObjectSpace.SQLSelect('select rel_def,RIGHTSIDE_ID from relations where LEFTSIDE_ID = '+QuotedStr(ABO.OID),mList);

      for i := 0 to mList.Count -1 do
      begin
        mRow := mList.Strings[i];
        mRel := StrToInt(NxToken(mRow, ';'));
        mRightID := NxToken(mRow, ';');
        mTableName := '';
        case mRel of
          //FV
          1400: mTableName := 'IssuedInvoices';
          //OP
          1431: mTableName := 'ReceivedOrders';
          //DL
          1438: mTableName := 'StoreDocuments';
        end;

        OutputDebugString('eu.abra.PostProviders: ChangeStatus: mRel='+IntToStr(mRel)+'; mRightID='+mRightID + '; mTableName='+mTableName);

        if mTableName = '' then
          continue;

        try
         OutputDebugString('eu.abra.PostProviders: ChangeStatus: SQLUpdate'+ 'update '+ mTableName + ' set X_PD_Status = '+IntToStr(AStatusIndex) + ' where ID = '+ QuotedStr(ABO.OID));
         ABO.ObjectSpace.SQLExecute('update '+ mTableName + ' set X_PD_Status = '+IntToStr(AStatusIndex) + ' where ID = '+ QuotedStr(mRightID));
        except
          ShowMessage( lng_msg_relationError );
        end;
      end;

    except
      AErrorLog := AErrorLog +cCrLf + lng_msg_statusChangeError + ExceptionMessage;
    end;
  finally
    mList.Free;
  end;
end;

//Pouze ADD používá v2.
function TrimVersion(aStr: String):String;
begin
  result:= NxSearchReplace(aStr, '/v2','',[srAll]);
end;




begin
end.