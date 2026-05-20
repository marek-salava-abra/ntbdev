uses
  'REST_SkladTerm.U_Func',
  'REST_SkladTerm.U_Translation',
  'REST_SkladTerm_Special.U_Const',
  'REST_SkladTerm_Special.U_StandardHooks',
  'StandardUnits.U_GetId';

procedure put_SavePhoto(AOS: TNxCustomObjectSpace; ABody: TBytes; AResponse: TStringList);
var
  mFilename, mDocumentData_ID, mDocument_ID, mDocQueue_ID: String;
  mFileStream: TMemoryStream;
  mDocument, mDocumentContent, mDocumentData: TNxCustomBusinessObject;
  mDocumentContents: TNxCustomBusinessMonikerCollection;
  mJson: TJSONSuperObject;
begin
  LogWriteSectionStart('put_SavePhoto');
  try
    mDocumentData_ID := '';
    mDocument_ID := '';

    AOS.StartTransaction(taReadCommited);
    try
      mFileStream := TMemoryStream.Create;
      mJson := TJSONSuperObject.ParseString(TEncoding.UTF8.GetString(ABody), True);
      try
        mFilename := mJson.S['Title'];
        mFileStream.SetBytes(DecodeBase64(mJson.S['Data']));

        if mFilename <> '' then
        begin
          mDocument := AOS.CreateObject(Class_Document);
          try
            mDocument.ExplicitTransaction := True;
            mDocument.New;
            mDocument.Prefill;

            mDocQueue_ID := GetDocQueue_ID(AOS, gSkladTermModule, Class_Document, gSkladTermUser_ID);
            mDocument.SetFieldValueAsString('DocQueue_ID',
              GetValueOrDefault(mDocQueue_ID, RADA_DOKUMENT));

            mDocument.SetFieldValueAsString('Firm_ID', FIRM_OWN);
            mDocument.SetFieldValueAsString('Category_ID', Document_DocumentCategory_ID);

            mDocumentContents := mDocument.GetLoadedCollectionMonikerForFieldCode(mDocument.GetFieldCode('Contents'));
            mDocumentContent := mDocumentContents.AddNewObject;
            mDocumentContent.Prefill;
            mDocumentContent.SetFieldValueAsString('FileName', mFilename);

            mFileStream.SaveToFile(NEW_PHOTOS_PATH + mFilename);
            if not ABRA then
              mDocumentContent.SetFieldValueAsInteger('FileConnectionType', 1);
            mDocumentContent.SetFieldValueAsBoolean('ExternalFile', True);
            mDocumentContent.SetFieldValueAsString('FileName', mFilename);
            mDocumentContent.SetFieldValueAsString('PathAndFileName', NEW_PHOTOS_PATH + mFilename);

            mDocument_ID := mDocument.OID;
            mDocument.Save;
          finally
            mDocument.Free;
          end;
        end
        else
          RaiseException(getString('error_file_cannot_be_parsed'));
      finally
        mFileStream.Free;
        mJson.Free;
      end;

      AOS.Commit;
      SetResponse(AResponse, PlainResponse(mDocument_ID));
    except
      AOS.RollBack;
      SetPlainResponse(AResponse, ExceptionMessage, HTTP_SC_InternalServerError);
    end;
  finally
    LogWriteSectionEnd;
  end;
end;

procedure get_ShowDocumentPhoto(AOS: TNxCustomObjectSpace; APath, AResponse: TStringList);
var
  mDocument_ID, mDocumentContent_ID, mFilePath, mSql: String;
  json: TJSONSuperObject;
  mDocumentContent: TNxCustomBusinessObject;
  mMS: TMemoryStream;
  mImage: TImage;
begin
  json := nil;
  if (APath.Count = 2) then
  begin
    mDocument_ID := APath.Strings[1];
  end else
  begin
    SetPlainResponse(AResponse, getString('wrong_parameters_count'), HTTP_SC_BadRequest);
    exit;
  end;

  LogWriteSectionStart('get_ShowDocumentPhoto');
  try
    mDocumentContent := AOS.CreateObject(Class_DocumentContent);
    json := TJSONSuperObject.CreateByDataType(jtObject);
    mMS := TMemoryStream.Create;
    mImage := TImage.Create(nil);
    try
      mSql :=
        'select' + FIRST_TOP(1) + nxCrLf +
        '  DC.ID' + nxCrLf +
        'from Documents D' + nxCrLf +
        'join DocumentContents DC on DC.Parent_ID = D.ID' + nxCrLf +
        'where' + nxCrLf +
        '  D.ID = ' + QuotedStr(mDocument_ID) + nxCrLf;
      mSql := mSql + FIRST_TOP_ORACLE(1);
      mDocumentContent_ID := SQLSelectStr(AOS, mSql);

      if CFxOID.IsEmpty(mDocumentContent_ID) then
      begin
        RaiseException(Format(getString('document_object_not_found'), [mDocument_ID]));
      end
      else begin
        mDocumentContent.Load(mDocumentContent_ID, nil);
        json.S['Title'] := mDocumentContent.GetFieldValueAsString('DisplayName');

        // obrazek je bud v DB nebo externi
        if mDocumentContent.GetFieldValueAsBoolean('ExternalFile') then
        begin
          mFilePath := mDocumentContent.GetFieldValueAsString('PathAndFileName');
          if FileExists(mFilePath) then
          begin
            mMS.LoadFromFile(mFilePath);
            json.S['Data'] := EncodeBase64(mMS.GetBytes);
          end;
        end
        else
        begin
          // nyni podporujeme POUZE soubory na disku
          RaiseException(getString('error_only_external_file_supported'));
          {mMS.SetBytes(mDocumentContent.GetFieldValueAsBytes('BlobData'));
          NxMultiFormatImageLoadFromStream(mMS, mImage.Picture);
          mMS.Clear;
          mImage.Picture.Graphic.SaveToStream(mMS);
          json.S['Data'] := EncodeBase64(mMS.GetBytes);}
        end;

        SetResponse(AResponse, json.AsJson(false, true));
      end;
    finally
      mImage.Free;
      mMS.Free;
      mDocumentContent.Free;
      json.Free;
    end;
  finally
    LogWriteSectionEnd;
  end;
end;

procedure Get_NewVersionFile(AOS: TNxCustomObjectSpace; AResponse: TStringList);
var
  mDocument_ID, mDocumentContent_ID, mFilePath, mSql: String;
  json: TJSONSuperObject;
  mDocumentContent, mDocumentData: TNxCustomBusinessObject;
  mMS: TMemoryStream;
begin
  json := nil;

  LogWriteSectionStart('get_NewVersionFile');
  try
    mDocumentContent := AOS.CreateObject(Class_DocumentContent);
    json := TJSONSuperObject.CreateByDataType(jtObject);
    mMS := TMemoryStream.Create;
    try
      mSql :=
        'select' + FIRST_TOP(1) + nxCrLf +
        '  DC.ID' + nxCrLf +
        'from Documents D' + nxCrLf +
        'join DocumentContents DC on DC.Parent_ID = D.ID' + nxCrLf +
        'where' + nxCrLf +
        '  D.ID = ' + QuotedStr(CLIENT_CURRENT_VERSION_DOCUMENT_ID) + nxCrLf;
      mSql := mSql + FIRST_TOP_ORACLE(1);
      mDocumentContent_ID := SQLSelectStr(AOS, mSql);

      if CFxOID.IsEmpty(mDocumentContent_ID) then
      begin
        RaiseException(Format(getString('document_object_not_found'), [mDocument_ID]));
      end
      else begin
        mDocumentContent.Load(mDocumentContent_ID, nil);
        json.S['Title'] := mDocumentContent.GetFieldValueAsString('FileName');

        if mDocumentContent.GetFieldValueAsBoolean('ExternalFile') then
        begin
          mFilePath := mDocumentContent.GetFieldValueAsString('PathAndFileName');
          if FileExists(mFilePath) then
          begin
            mMS.LoadFromFile(mFilePath);
            json.S['Data'] := EncodeBase64(mMS.GetBytes);
          end;
        end
        else if not ABRA and (mDocumentContent.GetFieldValueAsInteger('FileConnectionType') = 1) then
        begin
          mDocumentData := AOS.CreateObject(Class_DocumentData);
          try
            mDocumentData.Load(mDocumentContent.GetFieldValueAsString('Data_ID'), nil);
            mFilePath := TEncoding.ANSI.GetString(mDocumentData.GetFieldValueAsBytes('BlobData'));

            if FileExists(mFilePath) then
            begin
              mMS.LoadFromFile(mFilePath);
              json.S['Data'] := EncodeBase64(mMS.GetBytes);
            end;
          finally
            mDocumentData.Free;
          end;
        end
        else
          // nyni podporujeme POUZE soubory na disku
          RaiseException(getString('error_only_external_file_supported'));

        SetResponse(AResponse, json.AsJson(False, True), 'application/vnd.android.package-archive', 200);
      end;
    finally
      mMS.Free;
      mDocumentContent.Free;
      json.Free;
    end;
  finally
    LogWriteSectionEnd;
  end;
end;

procedure Put_SaveLog(AOS: TNxCustomObjectSpace; APath: TStringList; ABody: String; AResponse: TStringList);
var
  mFilename, mDate, mSql, mUsername: String;
  mList: TStringList;
begin
  LogWriteSectionStart('get_ShowDocumentPhoto');
  mList := TStringList.Create;
  try
    try
      if LOG_PATH <> '' then
      begin
        mFilename := LOG_PATH;
        if not EndsStr('\', mFilename) then
          mFilename := mFilename + '\';

        DateTimeToString(mDate, 'dd-mm-yyy hh-nn-ss-zzz', Now);

        mSql :=
          'select' + nxCrLf +
          '  Name' + nxCrLf +
          'from SecurityUsers' + nxCrLf +
          'where' + nxCrLf +
          '  ID = ' + QuotedStr(gSkladTermUser_ID);
        mUsername := SQLSelectStr(AOS, mSql);

        mFileName := mFileName + Format('%s %s AlertDialog.txt', [mDate, mUsername]);

        mList.Add(ABody);
        mList.SaveToFile(mFilename);
      end;
      SetPlainResponse(AResponse, PlainResponse(''));
    except
      SetPlainResponse(AResponse, ExceptionMessage, HTTP_SC_InternalServerError);
    end;
  finally
    mList.Free;
    LogWriteSectionEnd;
  end;
end;

begin
end.