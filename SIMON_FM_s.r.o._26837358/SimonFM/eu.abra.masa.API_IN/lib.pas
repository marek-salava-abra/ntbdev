
procedure POST_EAN(AContext:TNxContext; ARequest: TAPIRequest; AResponse: TAPIResponse);
var
  mHeaders: TStringList;
  mInputJSON, mOutputJSON:TJSONSuperObject;
  i: Integer;
  mEAN, mStoreCard_ID:string;
  mOS:TNxCustomObjectSpace;
  mBO:TNxCustomBusinessObject;
  mPrice:Extended;
begin
  mOS:=AContext.GetObjectSpace;
  mInputJSON:=TJSONSuperObject.Create;
  mInputJSON:=TJSONSuperObject.ParseString(ARequest.Body,True);
  try
    mOutputJSON:=TJSONSuperObject.Create;
    mEAN:=mInputJSON.S['EAN'];
    if NxIsNumeric(mEAN) then begin
      mStoreCard_ID:=mOS.SQLSelectFirstAsString('select su.parent_id from storeunits su left join storeeans se on se.parent_id=su.id where se.ean='+QuotedStr(mEAN),'');
      if not(NxIsEmptyOID(mStoreCard_ID)) then begin
       mBO:=mOS.CreateObject(Class_StoreCard);
       mBO.Load(mStoreCard_ID,nil);
       mPrice:=NxEvalObjectExprAsFloatDef(mbo,'NxGetStoreCardUnitPriceDef('+Quotedstr('')+', '+Quotedstr('')+', ' + QuotedStr(mbo.OID) +
       ','+Quotedstr('1000000101')+', '+Quotedstr(mBO.GetFieldValueAsString('MainUnitCode'))+',True,'+QuotedStr('0000CZK000')+','+inttostr(trunc(Date))+')',0);
       mOutputJSON.S['Code']:=mBO.GetFieldValueAsString('Code');
       mOutputJSON.S['Name']:=mBO.GetFieldValueAsString('Name');
       mOutputJSON.S['EAN']:=mEAN;
       mOutputJSON.D['Quantity']:=mOS.SQLSelectFirstAsExtended('Select sum(quantity) from storesubcards where storecard_id='+QuotedStr(mStoreCard_ID)+
                                 ' and store_id='+QuotedStr('2D00000101'),0);
       mOutputJSON.D['Price']:=mPrice;
       mOutputJSON.S['Result']:='OK';
       mOutputJSON.S['Message']:='Karta nalezena';
      end else begin
       mOutputJSON.S['Result']:='Error';
       mOutputJSON.S['Message']:='Karta nenalezena';
      end;
    end else begin
      mOutputJSON.S['Result']:='Error';
      mOutputJSON.S['Message']:='Zadaný vstup byl neplatný';
    end;
    AResponse.Body:=mOutputJSON.AsString;
    AResponse.SetHeader('Content-Type','application/json');
    AResponse.Status := 200;
  finally
    mHeaders.Free;
  end;
end;


function POST_Pictures(AContext: TNXContext; AInput: TJSONSuperObject; APath: String): TJSONSuperObject;
var
 mBO, mPictureBO:TNxCustomBusinessObject;
 mPictures:TNxCustomBusinessMonikerCollection;
 i,j:integer;
 mBO_ID:string;
begin
  Result := TJSONSuperObject.Create;
  mBO_ID:=AContext.SQLSelectFirstAsString('SELECT ID FROM StoreCards WHERE hidden='+QuotedStr('N')+' and Code='+Quotedstr(AInput.S['Code']),'');
  if NxIsEmptyOID(mBO_ID) then begin
    Result.I['NotFound']:=1;
    Result.I['Found']:=0;
    Result.S['Name']:='';
  end else begin
    mBO:=AContext.GetObjectSpace.CreateObject(Class_StoreCard);
    mBO.Load(mBO_ID,nil);
    Result.I['NotFound']:=0;
    Result.I['Found']:=1;
    Result.S['Name']:=mBO.GetFieldValueAsString('Name');
    mPictures:=mBO.GetLoadedCollectionMonikerForFieldCode(mBO.GetFieldCode('Pictures'));
           for j:=0 to mPictures.Count-1 do begin
             mPictures.BusinessObject[j].MarkForDelete;
           end;
    for i:= 0 to AInput.A['Pictures'].Length -1 do begin
      mPictureBO:=mPictures.AddNewObject;
      mPictureBO.SetFieldValueAsString('Picture_ID.PictureTitle',AInput.A['Pictures'].O[i].S['name']);
      mPictureBO.SetFieldValueAsBoolean('Picture_ID.ExternalFile',true);
      mPictureBO.SetFieldValueAsString('Picture_ID.PathAndFileName', encodePictureToFile(AInput.A['Pictures'].O[i].S['base64Data'], AInput.A['Pictures'].O[i].S['type']));
    end;
    mBO.save;
  end;
end;

function POST_Documents(AContext: TNXContext; AInput: TJSONSuperObject; APath: String): TJSONSuperObject;
var
 mBO, mPictureBO:TNxCustomBusinessObject;
 mPictures:TNxCustomBusinessMonikerCollection;
 i,j:integer;
 mBO_ID:string;
begin
  Result := TJSONSuperObject.Create;
  mBO_ID:=AContext.SQLSelectFirstAsString('SELECT ID FROM StoreCards WHERE hidden='+QuotedStr('N')+' and Code='+Quotedstr(AInput.S['Code']),'');
  if NxIsEmptyOID(mBO_ID) then begin
    Result.I['NotFound']:=1;
    Result.I['Found']:=0;
    Result.S['Name']:='';
  end else begin
    mBO:=AContext.GetObjectSpace.CreateObject(Class_StoreCard);
    mBO.Load(mBO_ID,nil);
    Result.I['NotFound']:=0;
    Result.I['Found']:=1;
    Result.S['Name']:=mBO.GetFieldValueAsString('Name');
    if NxIsBlank(mBO.GetFieldValueAsString('X_Tech_List_FileName')) then begin
      mBO.SetFieldValueAsString('X_Tech_List_FileName',AInput.S['FileName']);
      mBO.SetFieldValueAsString('X_Tech_List_Name','Technický list');
    end;
    mBO.save;
  end;
end;


function encodePictureToFile(aData: String; aType: String): String;
var
  mStream: TMemoryStream;
begin
  mStream := TMemoryStream.Create;
  try
    mStream.SetBytes(DecodeBase64(aData));
    NxCreateTempFile(Result);
    DeleteFile(Result);
    Result := Result + '.' + aType;
    OutputDebugString(Result);
    mStream.SaveToFile(Result);
  finally
    mStream.Free;
  end;
end;

function savePictureData(aFileName: String): TBytes;
var
  mPicture: TPicture;
  mStream: TMemoryStream;
begin
  mStream := TMemoryStream.Create;
  mPicture := TPicture.Create;
  try
    mPicture.LoadFromFile(aFileName);
    mPicture.SaveMultiFormatToStream(mStream);
    Result := mStream.GetBytes;
    DeleteFile(aFileName);
  finally
    mPicture.Free;
    mStream.Free;
  end;
end;

begin
end.
