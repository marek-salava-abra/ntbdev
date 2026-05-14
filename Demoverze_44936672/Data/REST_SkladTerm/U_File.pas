uses
  'REST_SkladTerm.U_Func',
  'REST_SkladTerm.U_Translation',
  'REST_SkladTerm_Special.U_Const',
  'REST_SkladTerm_Special.U_StandardHooks',
  'StandardUnits.U_GetId';

procedure put_SavePhoto(Self: TNxWebServicesHelper; ARequest: TNxHTTPRequest;
  AResponse: TNxHTTPResponse; slPath: TStringList);
var
  mDocType, mUser_ID, mModule, mFilename, mDocumentData_ID, mDocument_ID: String;
  mMultiPartStream, mFileStream: TMemoryStream;
  mDocument, mDocumentContent, mDocumentData: TNxCustomBusinessObject;
  mDocumentContents: TNxCustomBusinessMonikerCollection;

  // vrati radu dokladu
  function GetDocQueueForDocument(AOS: TNxCustomObjectSpace; AModule, ADocType, AUser_ID, ADefaultDocQueue_ID: String; ASourceDocType: String = '';
    ADocument: TNxCustomBusinessObject = nil; AStore_ID: String = ''): String;
  var
    mDocQueue_ID: String;
  begin
    Result := '';

    mDocQueue_ID := GetDocQueue_ID(AOS, AModule, ADocType, AUser_ID, ASourceDocType, ADocument);
    if not CFxOID.IsEmpty(mDocQueue_ID) then
      Result := mDocQueue_ID
    else
      Result := ADefaultDocQueue_ID;
  end;
begin
  mUser_ID := getHeaderValue(ARequest, 'UserID');
  mDocType := getHeaderValue(ARequest, 'DocumentType');
  mModule := getHeaderValue(ARequest, 'ModuleCode');

  LogWriteSectionStart('put_SavePhoto');
  try
    mDocumentData_ID := '';
    mDocument_ID := '';

    Self.ObjectSpace.StartTransaction(taReadCommited);
    try
      mMultiPartStream := TMemoryStream.Create;
      mFileStream := TMemoryStream.Create;
      try
        mMultiPartStream.SetBytes(ARequest.Content.Content);
        GetFileFromMultiPartStream(mMultiPartStream, mFilename, mFileStream);

        if mFilename <> '' then
        begin
          mDocument := Self.ObjectSpace.CreateObject(Class_Document);
          try
            mDocument.ExplicitTransaction := True;
            mDocument.New;
            mDocument.Prefill;
            mDocument.SetFieldValueAsString('DocQueue_ID',
              GetDocQueueForDocument(Self.ObjectSpace, mModule, mDocType, mUser_ID, RADA_DOKUMENT));
            mDocument.SetFieldValueAsString('Firm_ID', FIRM_OWN);
            mDocument.SetFieldValueAsString('Category_ID', Document_DocumentCategory_ID);

            mDocumentContents := mDocument.GetLoadedCollectionMonikerForFieldCode(mDocument.GetFieldCode('Contents'));
            mDocumentContent := mDocumentContents.AddNewObject;
            mDocumentContent.Prefill;
            mDocumentContent.SetFieldValueAsString('FileName', mFilename);

            mFileStream.SaveToFile(NEW_PHOTOS_PATH + mFilename);
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
        mMultiPartStream.Free;
      end;

      Self.ObjectSpace.Commit;
      HTTPResponse(AResponse, HTTP_SC_OK, ContentType_JSON, PlainResponse(mDocument_ID));
    except
      Self.ObjectSpace.RollBack;
      ErrREST(ARequest, AResponse, HTTP_SC_InternalServerError, ExceptionMessage);
    end;
  finally
    LogWriteSectionEnd;
  end;
end;

procedure get_ShowDocumentPhoto(Self: TNxWebServicesHelper; ARequest: TNxHTTPRequest;
  AResponse: TNxHTTPResponse; slPath: TStringList);
var
  mDocument_ID, mDocumentContent_ID, mFilePath, mModule, mDocType, mUser_ID, mSql: String;
  json: TJSONSuperObject;
  mDocumentContent: TNxCustomBusinessObject;
  mMS: TMemoryStream;
  mImage: TImage;
begin
  json := nil;
  if (slPath.Count = 2) then
  begin
    mDocument_ID := slPath.Strings[1];
  end else
  begin
    ErrREST(ARequest, AResponse, HTTP_SC_BadRequest, getString('wrong_parameters_count'));
    exit;
  end;

  mUser_ID := getHeaderValue(ARequest, 'UserID');
  mDocType := getHeaderValue(ARequest, 'DocumentType');
  mModule := getHeaderValue(ARequest, 'ModuleCode');

  LogWriteSectionStart('get_ShowDocumentPhoto');
  try
    mDocumentContent := Self.ObjectSpace.CreateObject(Class_DocumentContent);
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
      mDocumentContent_ID := SQLSelectStr(Self.ObjectSpace, mSql);

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

        HTTPResponse(AResponse, HTTP_SC_OK, ContentType_JSON, json.AsJson(false, true));
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

begin
end.