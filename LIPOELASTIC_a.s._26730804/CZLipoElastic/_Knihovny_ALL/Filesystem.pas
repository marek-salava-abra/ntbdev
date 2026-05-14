
// Načtení souboru do stringu
// -----------------------------------------------------------------------------------------------------

function GetFileToString(AFileName: String; AEncoding: string = 'ANSI'): string;
var
  mMS: TMemoryStream;
  mStr: string;

begin
  mMS := TMemoryStream.Create();
  try
    mMS.LoadFromFile(AFileName);
    case AEncoding of
      'ANSI': Result := TEncoding.ANSI.GetString(mMS.GetBytes);
      'UTF8': Result := TEncoding.UTF8.GetString(mMS.GetBytes);
      'ASCII': Result := TEncoding.ASCII.GetString(mMS.GetBytes);
      'Unicode': Result := TEncoding.Unicode.GetString(mMS.GetBytes);
    end;
  finally
    mMS.Free;
  end;
end;




// vytvoreni souboru ze stringu
// -----------------------------------------------------------------------------------------------------

function CreateFileFromString(AFileName, mStr: String; AEncoding: string = 'ANSI'): string;
var
  mMS: TMemoryStream;

begin
  Result := '';
  mMS := TMemoryStream.Create();
  try
    case AEncoding of
      'ANSI': mMS.WriteString(mStr, 1250);
      'UTF8': mMS.WriteString(mStr, 65001);
      'ASCII': mMS.WriteString(mStr, 20127);
      'Unicode': mMS.WriteString(mStr, 1200);
    end;
    mMS.SaveToFile(AFileName);
  finally
    mMS.Free;
  end;
end;

// Uložení TBytes do souboru
// -----------------------------------------------------------------------------------------------------

function CreateFileFromBytes(AFileName: String; ABytes: TBytes): boolean;
var
  mMS: TMemoryStream;
  mStr: string;

begin
  Result := true;
  mMS := TMemoryStream.Create();
  try
    mMS.SetBytes(ABytes);
    mMS.SaveToFile(AFileName);
  finally
    mMS.Free;
  end;
end;



// Načtení souboru do TBytes
// -----------------------------------------------------------------------------------------------------

function GetFileToBytes(AFileName: String;): TBytes;
var
  mMS: TMemoryStream;
  mStr: string;

begin
  mMS := TMemoryStream.Create();
  try
    mMS.LoadFromFile(AFileName);
    Result := mMS.GetBytes;
  finally
    mMS.Free;
  end;
end;



// Zapíše string na konec souboru. Pokud neexistuje, vytvoří ho.
// -----------------------------------------------------------------------------------------------------

function AddStringToFile(FileName, mStr: String): boolean;
var
  mFS: TFileStream;
  mSS: TMemoryStream;
  mFH: Integer;
begin
  try
    if not FileExists(FileName) then begin
      mFH := FileCreate(FileName);
      FileClose(mFH);
    end;
    mFS := TFileStream.Create(FileName, fmOpenWrite);
    try
      mFS.Seek(mFS.Size, 0);
      NxWriteString(mFS, mStr);
    finally
      mFS.Free;
    end;

    Result := true;
  except
    Result := false;
  end;
end;


// převede řetězec na platný název souboru
// nepovolené znaky nahradí -

function CorrectFileName(AFileName: string; AReplaceChar: string = '-'): string;
begin
  AFileName := TEncoding.RemoveDiacritics(AFileName);
  AFileName := NxCorrectText(AFileName, '0123456789., _!()[]&%$#@abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ', AReplaceChar);
  Result := AFileName;
end;



begin
end.