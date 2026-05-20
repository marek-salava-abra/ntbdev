const
  cFolderEXE = 'Folder.exe';

// Vytvoreni adresare AName+ID v podadersari ASubPath.
// ASubPath muze byt ve strukture adresar1\adresar2\adresarX\.
procedure CreateFolder(AFullSubPath, AName, ID: string);
var
  N1: string;
  mFolderPath: String;
begin
  try
    mFolderPath := GetMainFolder;
    if NxLeft(AFullSubPath, 1) = '\' then begin
       AFullSubPath := NxTrim(Copy(AFullSubPath,2,255),' ')
    end;
    if NxRight(AFullSubPath, 1) <> '\' then begin
      AFullSubPath := AFullSubPath+'\'
    end;
    N1:= ReplaceChar(AName, '_', 0) + '_' + ID;
    if ForceDirectories(mFolderPath + AFullSubPath + N1) then else begin
      NxMessageBox('Chyba', 'Nepodařilo se vytvořit adresář ' + mFolderPath + AFullSubPath + N1 +'. Problém může být např v přístupových právech.', mdStop, mdbOk, 2, [mdpSystemModal], False, nil);
    end;
  finally
    N1 := nil;
    mFolderPath := nil;
  end;
end;

// Nahrazeno CreateFolderEshop2
// Vlivem chyby ForceDirectories err hlaska nikdy nezobrazila, takze SendMessage
// takze se posledni parametr predava false.
procedure CreateFolderEshop(AFullSubPath, AName: string);
begin
  CreateFolderEshop2(AFullSubPath, AName, False);
end;

// Vytvoreni adresare AName v podadersari ASubPath.
// ASubPath muze byt ve strukture adresar1\adresar2\adresarX\.
function CreateFolderEshop2(AFullSubPath, AName: string; AShowErr: Boolean): Boolean;
var
  N1: string;
  mFolderPath: String;
  mDir: TDirectoryEdit;
begin
  try
{    mFolderPath := GetMainFolder;
    if NxLeft(AFullSubPath, 1) = '\' then begin
       AFullSubPath := NxTrim(Copy(AFullSubPath,2,255),' ')
    end;
    if NxRight(AFullSubPath, 1) <> '\' then begin
      AFullSubPath := AFullSubPath+'\'
    end;
    N1:= ReplaceChar(AName, '-', 0);}
    // ForceDirectories vraci true i v propade, ze se adresar nevytvori - Win7, Win2008 (?)
    //if ForceDirectories(mFolderPath + AFullSubPath + N1) then else begin
    //  NxMessageBox('Chyba', 'Nepodařilo se vytvořit adresář ' + mFolderPath + AFullSubPath + N1 +'. Problém může být např v přístupových právech.', mdStop, mdbOk, 2, [mdpSystemModal], False, nil);
    //end;
    if ForceDirectories({mFolderPath +} AFullSubPath {+ N1}) then begin
      if DirectoryExists({mFolderPath +} AFullSubPath {+ N1}) then begin
        Result := True;
      end else begin
        Result := True;
        if AShowErr then begin
          NxMessageBox('Chyba', 'Nepodařilo se vytvořit adresář ' + mFolderPath + AFullSubPath + N1, mdError, mdbOk, 2, [mdpSystemModal], False, nil);
        end;
      end;
    end else begin
      Result := False;
      if AShowErr then begin
        NxMessageBox('Chyba', 'Nepodařilo se vytvořit adresář ' + mFolderPath + AFullSubPath + N1, mdError, mdbOk, 2, [mdpSystemModal], False, nil);
      end;
    end;
  finally
    N1 := nil;
    mFolderPath := nil;
  end;
end;

function CreateFolderEshop3(AFullSubPath, AName: string; AShowErr: Boolean): Boolean;
var
  N1: string;
  mFolderPath: String;
  mDir: TDirectoryEdit;
begin
  try
    mFolderPath := GetMainFolder;
    if NxLeft(AFullSubPath, 1) = '\' then begin
       AFullSubPath := NxTrim(Copy(AFullSubPath,2,255),' ')
    end;
    if NxRight(AFullSubPath, 1) <> '\' then begin
      AFullSubPath := AFullSubPath+'\'
    end;
    N1:= ReplaceChar(AName, '-', 0);
    // ForceDirectories vraci true i v propade, ze se adresar nevytvori - Win7, Win2008 (?)
    //if ForceDirectories(mFolderPath + AFullSubPath + N1) then else begin
    //  NxMessageBox('Chyba', 'Nepodařilo se vytvořit adresář ' + mFolderPath + AFullSubPath + N1 +'. Problém může být např v přístupových právech.', mdStop, mdbOk, 2, [mdpSystemModal], False, nil);
    //end;
    if ForceDirectories({mFolderPath +} AFullSubPath + N1) then begin
      if DirectoryExists({mFolderPath +} AFullSubPath + N1) then begin
        Result := True;
      end else begin
        Result := True;
        if AShowErr then begin
          NxMessageBox('Chyba', 'Nepodařilo se vytvořit adresář ' + mFolderPath + AFullSubPath + N1, mdError, mdbOk, 2, [mdpSystemModal], False, nil);
        end;
      end;
    end else begin
      Result := False;
      if AShowErr then begin
        NxMessageBox('Chyba', 'Nepodařilo se vytvořit adresář ' + mFolderPath + AFullSubPath + N1, mdError, mdbOk, 2, [mdpSystemModal], False, nil);
      end;
    end;
  finally
    N1 := nil;
    mFolderPath := nil;
  end;
end;



// Vytvoreni adresare s prefixem dle prvniho pismena - musi byt name + ID
// Prefix dle prviho pismena se neresi zde, ale automaticky ho vytvori folder.exe, pokud dostane paremtry ve tvaru M hlavni adresar mezera podadresar.
// ASubPath musi byt vytvorena a musi obsahovat Folder.exe.
// Toto reseni je vhodne pouzit pokud uzivatel chce pomoci folder.cfg definovat vlastni strukturu adresaru ve vyslednem adresari.
// Nepripustne znaky se nahradi '_', maximalni delka adresare je 30.
procedure CreateFolderExeABC(ASubPath, AName, ID: string);
var
  N1: string;
  mFolderPath: String;
begin
  try
    if FileExists(mFolderPath+ASubPath+cFolderEXE) then begin
      if NxRight(ASubPath, 1) <> '\' then begin
        ASubPath := ASubPath+'\'
      end;
      mFolderPath := GetMainFolder;
      N1:= ReplaceChar(AName, '_', 30) + '_' + ID;
      NxShellExecute('open', cFolderEXE, 'M "' + mFolderPath+ASubPath + '" "' + N1 + '"', mFolderPath+ASubPath);
    end else begin
      NxMessageBox('Chyba', 'V cestě '+mFolderPath+ASubPath+' nebyl nalezen Folder.exe. Adresář (folder) pro '+AName+' nelze vytvořit.', mdStop, mdbOk, 2, [mdpSystemModal], False, nil);
    end;
  finally
    N1 := nil;
    mFolderPath := nil;
  end;
end;

// Alternativa procedury CreateFolder pokud si chce uzivatel definovat strukutur ve folder.cfg.
// ASubPath musi byt vytvorena a musi obsahovat Folder.exe.
// Adresare ASubPath2, ASubPath3 jsou v pripade potreby vytvoreny.
// Toto reseni je vhodne pouzit pokud uzivatel chce pomoci folder.cfg definovat vlastni strukturu adresaru ve vyslednem adresari.
// Nepripustne znaky se nahradi '_', maximalni delka adresare je 30.
procedure CreateFolderExe(ASubPath, ASubPath2, ASubPath3, AName, ID: string);
var
  N1: string;
  mFolderPath: String;
begin
  try
    mFolderPath := GetMainFolder;
    if NxRight(ASubPath, 1) <> '\' then begin
      ASubPath := ASubPath+'\'
    end;
    if FileExists(mFolderPath+ASubPath+cFolderEXE) then begin
      if ASubPath2<>'' then begin
        if NxRight(ASubPath2, 1) <> '\' then begin
          ASubPath2 := ASubPath2+'\'
        end;
      end;
      if ASubPath3<>'' then begin
        if NxRight(ASubPath3, 1) <> '\' then begin
          ASubPath3 := ASubPath3+'\'
        end;
      end;
      if DirectoryExists(ASubPath2) then else begin
        NxShellExecute('open', cFolderEXE, 'M "' + ASubPath2 + '"', mFolderPath+ASubPath);
      end;
      if DirectoryExists(ASubPath3) then else begin
        NxShellExecute('open', cFolderEXE, 'M "' + ASubPath2+ASubPath3 + '"', mFolderPath+ASubPath);
      end;
      N1:= ReplaceChar(AName, '_', 30) + '_' + ID;
      NxShellExecute('open', cFolderEXE, 'M "' +ASubPath2+ASubPath3+N1 + '"', mFolderPath+ASubPath);
    end else begin
      NxMessageBox('Chyba', 'V cestě '+mFolderPath+ASubPath+' nebyl nalezen Folder.exe. Adresář (folder) pro '+AName+' nelze vytvořit.', mdStop, mdbOk, 2, [mdpSystemModal], False, nil);
    end;
  finally
    N1 := nil;
    mFolderPath := nil;
  end;
end;


// Vraceni nazvu hlavniho adresare \\server\hlavni folder\ z poznamky tohoto skriptu.
function GetMainFolder:String;
var
  mFolderPath: String;
  mGx: Variant;
  mList: Variant;
begin
  mGx := GetAbraOLEApplication;
  mList := GetAbraOLEStrings;
  try
    mGx.SQLSelect('SELECT A.Description AS Path FROM ScriptPackages A WHERE A.Name = '+QuotedStr('abra.cz.servis.fika.FolderSupport'), mList);
    if mList.Count > 0 then begin
      mFolderPath := NxTrim(mList.Strings[0],' ');
      if NxRight(mFolderPath, 1) <> '\' then begin
        mFolderPath := mFolderPath+'\'
      end;
      Result := mFolderPath;
    end;
  finally
    mGx := nil;
    mList := nil;
  end;
end;


// Funkce pro zjiteni prefixu, pokud ma folder ABC strukturu tj. folder\A\firmy od A, folder\B\firmy od B, ...
function ChangeChar(Value: Char): Char;
begin
  if Value in ['a'..'z', 'A'..'Z',
               'é', 'ŕ', 'ź', 'ú', 'í', 'ó', 'á', 'ś', 'ĺ', 'ý', 'ć', 'ů', 'ö', 'ä',
               'É', 'Ŕ', 'Ź', 'Ú', 'Í', 'Ó', 'Á', 'Ś', 'Ĺ', 'Ý', 'Ć', 'Ů', 'Ö', 'Ä',
               'ě', 'ř', 'ť', 'ž', 'š', 'ď', 'ľ', 'č', 'ň',
               'Ě', 'Ř', 'Ť', 'Ž', 'Š', 'Ď', 'Ľ', 'Č', 'Ň'] then
    Result:= UpperCase(Value) else
    Result:= '~';
end;

// Pouziva se pri oprave nazvu - tj. jen pro ciselniky/nikoliv pro doklady.
// Dale se pouziva pro overeni existence, pokud se folder negeneruje do podadresaru A, B, C apod.
function IsDirectoryABC(Name, ID: string): Boolean;
var
  mFolderPath: String;
  N1, N2 : string;
begin
  try
    Result:= False;
    mFolderPath := GetMainFolder;
    N1:= ReplaceChar(Name, '', 0) + '_' + ID;
    if N1 <> '' then N2:= ChangeChar(N1[1]);
    Result:= DirectoryExists(mFolderPath + N2 + '\' + N1);
  finally
    mFolderPath := nil;
    N1 := nil;
    N2 := nil;
  end;
end;

// Prejmenovani adresre pokud byl vytvoren procedurou CreateFolderExeABC.
procedure RenameFolderExeABC(ASubPath, AFromName, AToName, AFromID, AToId: string);
var
  mFolderPath: String;
  N1, N2: string;
begin
  try
    mFolderPath := GetMainFolder;
    mFolderPath := mFolderPath+ASubPath;
    if FileExists(mFolderPath+ASubPath+cFolderEXE) then begin
      N1:= ReplaceChar(AFromName, '_', 30) + '_' + AFromID;
      N2:= ReplaceChar(AToName, '_', 30) + '_' + AToID;
      if N1 <> N2 then begin
        NxShellExecute('open', cFolderEXE, 'R "' + mFolderPath + '" "' + N1 + '" "' + N2, mFolderPath);
      end;
    end else begin
      NxMessageBox('Chyba', 'V cestě '+mFolderPath+ASubPath+' nebyl nalezen Folder.exe. Adresář (folder) '+N1+' nelze přejmenovat.', mdStop, mdbOk, 2, [mdpSystemModal], False, nil);
    end;
  finally
    mFolderPath := nil;
    N1 := nil;
    N2 := nil;
  end;
end;

function ReplaceChar(Value: string; AChar :String; ALen: Integer): string;
begin
  if AChar = '' then begin
    AChar := '_';
  end;
  if ALen > 0 then begin
    Value := Copy(Value, 1 , ALen);
  end;
  Value:= StringReplace(Value, '|', AChar, [rfReplaceAll,rfIgnoreCase]);
  //Value:= StringReplace(Value, '\', AChar, [rfReplaceAll,rfIgnoreCase]);
  Value:= StringReplace(Value, '?', AChar, [rfReplaceAll,rfIgnoreCase]);
  Value:= StringReplace(Value, '>', AChar, [rfReplaceAll,rfIgnoreCase]);
  Value:= StringReplace(Value, '<', AChar, [rfReplaceAll,rfIgnoreCase]);
  Value:= StringReplace(Value, ':', AChar, [rfReplaceAll,rfIgnoreCase]);
  Value:= StringReplace(Value, '/', AChar, [rfReplaceAll,rfIgnoreCase]);
  Value:= StringReplace(Value, '*', AChar, [rfReplaceAll,rfIgnoreCase]);
  Value:= StringReplace(Value, '"', AChar, [rfReplaceAll,rfIgnoreCase]);
  Value:= StringReplace(Value, '+', AChar, [rfReplaceAll,rfIgnoreCase]);
  Result:= Value;
end;

begin
end.