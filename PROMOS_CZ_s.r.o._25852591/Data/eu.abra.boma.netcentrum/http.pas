
procedure get(Self: TNxWebServicesHelper;Path: String; var Header: String; var Content: TBytes; var ContentType: String; var ContentEncoding: String;Arguments: String);
begin
  try
    Content :=getPDF(self.Context, Arguments);
    ContentType := 'Application/pdf';
  except
    Content := TEncoding.ANSI.GetBytes('<B>!! Chyba !! </B> <BR>'+ExceptionMessage);
    ContentType := 'text/html';
  end;
end;

function getPdf(AContext: TNxContext;Arguments: String): TBytes;
begin
  Result := PrintIssuedInvoice(AContext, '2J00000101' , 'W400000001'); //Faktura vydana
end;


function PrintIssuedInvoice(AContext: TNxContext; ADocumentID: String; AReportID: String): TBytes;
var
  mOLEApp: Variant;
  mCommand: Variant;
  mCond: Variant;
  mTempDir: String;
  mIDs: TStrings;
  mFileName: String;
begin
  mFileName := CFxGUID.CreateNew + '.pdf';
  mIDs := TStringList.Create;
  try
    mIDs.Add(ADocumentID);
    mTempDir := NxGetTempDir;
    CFxReportManager.PrintByIDs(AContext, mIDs, '40SBPEINEFD13ACM03KIU0CLP4', AReportID, rtoFile, pekPDF, mTempDir, mFileName);
    Result := Get_PDF(NxAddSlash(mTempDir) + mFileName);
    DeleteFile(mTempDir + mFileName);
  finally
    mIDs.Free;
  end;
end;

function Get_PDF(AFileNAme: String):TBytes;
var
  mFS: TFileStream;
  mSS: TMemoryStream;
begin
  mFS := TFileStream.Create(AFileName, fmOpenRead);
  try
    mFS.Seek(0, soFromBeginning);
    mSS := TMemoryStream.Create;
    try
      mSS.CopyFrom(mFS, mFS.Size);
      Result := mSS.GetBytes;
    finally
      mSS.Free;
    end;
  finally
    mFS.Free;
  end;
end;

begin
end.