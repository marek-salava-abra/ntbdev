uses 'eu.abra.japl.Feprodukt.Shoptet.ImportOrder.Import';
procedure  AutoImport(OS: TNxCustomObjectSpace;var Success: Boolean; var LogInfoStr: String);
var
  AStream: TMemoryStream;
  mFileName: string;
  mSite : TSiteForm;
  mBackupDirName, mDirName,mDateStr: string;

begin


  mDirName:= 'D:\AbraGen\Objednavky\';
  mBackupDirName:= 'D:\AbraGen\Objednavky\archiv\';
  AStream := TMemoryStream.Create;
  try
    //CFxInternet.HTTPGetBinary('https://www.fepro.cz/export/ordersFeed.xml?patternId=-11&hash=517ec3cbe812886c513f0e459a6c5247428d8ff710e05e6ff316778db2cb0f33','',AStream);
    CFxInternet.HTTPGetBinary('https://www.fepro.cz/export/ordersFeed.xml?patternId=14&partnerId=8&hash=ba8e7ba5bfa48b077464e042ce35bd337151aaad2d3d2626910872d0b161b1e2','',AStream);
  except
    LogInfoStr:='Nepodařilo se stahnout soubor z eshopu';
    Success:= False;
  end;
  DateTimeToString(mDateStr,'YYYY-MM-DD hh.nn.ss',Now);
  mFilename:='objednavky-'+mDateStr+'.xml';
  //mFileName:=mDirName+'objednavky.xml';
  AStream.SaveToFile(mDirName+mFileName);
  AStream.Clear;
  try
    if FileExists(mDirName+mFileName) then begin
      if InsertOrder(OS, mDirName+mFileName) then begin
        Success:= True;
        LogInfoStr := 'Import objednávek proběhl úspěšně';
        NxCopyFile(mDirName+mFileName, mBackupDirName + mFileName);
        DeleteFile(mDirName+mFileName);
      end
      else begin
        Success:= False;
        LogInfoStr:= 'Chyba při importu! Více informací v logu (složka Logs v hlavní složce Abry)';
      end;
     // DeleteFile(mFileName);
    end;
  except
    LogInfoStr := 'Nastal problém při importu '  + ExceptionMessage;
    Success:= False;
  end;
end;

procedure  AutoImportAll(OS: TNxCustomObjectSpace;var Success: Boolean; var LogInfoStr: String);
var
  AStream: TMemoryStream;
  mFileName: string;
  mSite : TSiteForm;
  mBackupDirName, mDirName,mDateStr: string;
  mUpdateDate: string;
begin

  DateTimeToString(mUpdateDate,'YYYY-MM-DD',Now-2);
  mDirName:= 'D:\AbraGen\Objednavky\';
  mBackupDirName:= 'D:\AbraGen\Objednavky\archiv\';
  AStream := TMemoryStream.Create;
  //LogInfoStr:= 'https://www.fepro.cz/export/ordersFeed.xml?patternId=-11&hash=517ec3cbe812886c513f0e459a6c5247428d8ff710e05e6ff316778db2cb0f33&updateTimeFrom='+mUpdateDate +#13#10;
  //exit;
  try
    //CFxInternet.HTTPGetBinary('https://www.fepro.cz/export/ordersFeed.xml?patternId=-11&hash=517ec3cbe812886c513f0e459a6c5247428d8ff710e05e6ff316778db2cb0f33&updateTimeFrom='+mUpdateDate,'',AStream);
    CFxInternet.HTTPGetBinary('https://www.fepro.cz/export/ordersFeed.xml?patternId=14&partnerId=8&hash=ba8e7ba5bfa48b077464e042ce35bd337151aaad2d3d2626910872d0b161b1e2&updateTimeFrom='+mUpdateDate,'',AStream);
  except
    LogInfoStr:='Nepodařilo se stahnout soubor z eshopu'+#13#10;
    Success:= False;
  end;
  //LogInfoStr:= LogInfoStr + 'před datestr' +#13#10;
  DateTimeToString(mDateStr,'YYYY-MM-DD hh.nn.ss',Now);
  //LogInfoStr:= LogInfoStr + mDateStr +#13#10;
  mFilename:='ALL_objednavky-'+mDateStr+'.xml';
  //mFileName:=mDirName+'objednavky.xml';
  //LogInfoStr:= LogInfoStr + mFileName +#13#10;
  AStream.SaveToFile(mDirName+mFileName);
  AStream.Clear;
  try
    if FileExists(mDirName+mFileName) then begin
      //LogInfoStr:= LogInfoStr + 'Soubor existuje: '+ mFileName +#13#10;
      if InsertOrder(OS, mDirName+mFileName) then begin
        Success:= True;
        LogInfoStr := LogInfoStr+ 'Import objednávek proběhl úspěšně'+#13#10;
        NxCopyFile(mDirName+mFileName, mBackupDirName + mFileName);
        DeleteFile(mDirName+mFileName);
      end
      else begin
        Success:= False;
        LogInfoStr:= LogInfoStr+ 'Chyba při importu! Více informací v logu (složka Logs v hlavní složce Abry)'+#13#10;
      end;
     // DeleteFile(mFileName);
    end;
  except
    LogInfoStr := LogInfoStr + 'Nastal problém při importu ' + ExceptionMessage;
    Success:= False;
  end;
end;

begin
end.