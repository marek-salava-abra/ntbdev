uses
  'abra.cz.servis.fika.FolderSupport.Common';

// Priklad volani:
// NxScript('abra.cz.servis.fika.FolderSupport.QRF.GetFolderName', 'Nabidky_vydane\'+DocQueue_ID.Code+'\'+Period_ID.Code+'\', DisplayName, ID, 0);
function GetFolderName(AReportHelper:TNxQRScriptHelper; AFullSubPath, AName:String; AID:String; APrefix: Integer):String;
var
  mFolderPath: String;
  N1: string;
begin
  try
    mFolderPath := GetMainFolder;
    if AName <> '' then begin
      if APrefix > 0 then begin
        N1:= ChangeChar(NxLeft(AName, APrefix))+'\';
      end else begin
        N1 := '';
      end;
      Result:= mFolderPath + AFullSubPath + N1 + ReplaceChar(AName, '_', 0) + '_' + AID;
    end;
  finally
    mFolderPath := nil;
    N1 := nil;
  end;
end;

// Stejene jako GetFolderName, pouze s omezenim na 30 znaku.
function GetFolderNameExe(AReportHelper:TNxQRScriptHelper; AFullSubPath, AName:String; AID:String; APrefix: Integer):String;
var
  mFolderPath: String;
  N1: string;
begin
  try
    mFolderPath := GetMainFolder;
    if AName <> '' then begin
      if APrefix > 0 then begin
        N1:= ChangeChar(NxLeft(AName, APrefix))+'\';
      end else begin
        N1 := '';
      end;
      Result:= mFolderPath + AFullSubPath + N1 + ReplaceChar(AName, '_', 30) + '_' + AID;
    end;
  finally
    mFolderPath := nil;
    N1 := nil;
  end;
end;

// Funkce pro vraceni folderu pro Eshop
function GetFolderNameEshop(AReportHelper:TNxQRScriptHelper; AFullSubPath, AName:String):String;
var
  mFolderPath: String;
  N1: string;
begin
  try
    mFolderPath := GetMainFolder;
    if AName <> '' then begin
      Result:= mFolderPath + AFullSubPath + ReplaceChar(AName, '-', 0);
    end;
  finally
    mFolderPath := nil;
    N1 := nil;
  end;
end;


begin
end.