function GET_picture(AContext: TNxContext; APath: String): TJSONSuperObject;
var
  mPicture: TNxCustomBusinessObject;
  mOS: TNxCustomObjectSpace;
  mPath: String;
begin
  mPath := NxRight(APath, Length(APath)-1);
  OutputDebugString('GET_Picture APath: ' + mPath);
  if Length(APath) = 0 then RaiseException('Musí být zadán ID obrázku!');
  Result := TJSONSuperObject.Create;
  mOS := AContext.GetObjectSpace;
  mPicture := mOS.CreateObject(Class_Picture);
  try
    if mPicture.Test(mPath) then
    begin
      mPicture.Load(mPath, nil);
      Result.S['name'] := mPicture.GetFieldValueAsString('PictureTitle');
      Result.B['isExternal'] := mPicture.GetFieldValueAsBoolean('ExternalFile');
      Result.S['PathAndFileName'] := mPicture.GetFieldValueAsString('PathAndFileName');
      Result.S['type'] := mPicture.GetFieldValueAsString('PictureType');
      Result.S['base64Data'] := decodePicture(loadPictureAndSaveToFile(mPicture.GetFieldValueAsBytes('BlobData')));
    end else RaiseException('Musí být zadáno existující ID obrázku! Příklad URL: ../webapi/lib/picture/1000000101');
  finally
    mPicture.Free;
  end;
end;

function loadPictureAndSaveToFile(aBlobData: TBytes): String;
var
  mPicture: TPicture;
  mStream: TMemoryStream;
begin
  mStream := TMemoryStream.Create;
  mPicture := TPicture.Create;
  try
    NxCreateTempFile(Result);
    OutputDebugString(Result);
    mStream.SetBytes(aBlobData);
    mPicture.LoadMultiFormatFromStream(mStream);
    mPicture.SaveToFile(Result);
  finally
    mPicture.Free;
    mStream.Free;
  end;
end;

function decodePicture(aFileName: String): String;
var
  mStream: TMemoryStream;
begin
  mStream := TMemoryStream.Create;
  try
    mStream.LoadFromFile(aFileName);
    Result := EncodeBase64(mStream.GetBytes);
    DeleteFile(aFileName);
  finally
    mStream.Free;
  end;
end;


begin
end.