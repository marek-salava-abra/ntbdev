uses  'eu.abra.roeh.Logio.Lib',
       'eu.abra.roeh.Logio.Logio',
       'eu.abra.roeh.Logio.QrFunc';

procedure CreateInventoroExport (OS: TNxCustomObjectSpace;var Success: Boolean; var LogInfoStr: String);
var
  mPath,mDyn : string;
  mStr : TStringList;
  mFTP: TFTP;
begin
  Success := false;
  LogInfoStr := '';
  mPath := GetParamValue(OS,'PATH');
try
 DeleteFile(mPath + 'Imp.csv');
  except
    LogInfoStr := 'Nepovedl se smazat soubor: ' + mPath + 'Imp.csv'  + #13#10  +  ExceptionMessage;
    Success := False;
    Exit;
  end;
  LogInfoStr := 'Nepovedl se vytvořit String list';
  mStr := TStringList.Create;
  LogInfoStr :=  'String list vyvořen';
  try
   OutputDebugString('Jdu Dělat SQL');
    mStr.Clear;
    mStr.Add('AUTO');
    OutputDebugString('SQl dotaz prošel');
    try
    mDyn := GetParamValue(OS,'DYNSQL');
    if Trim(mDyn) = '' then mDyn := 'EKJORJF13I04VCKDW5IFIPUVYG';
     CFxReportManager.ExportByIDs(NxCreateContext(OS),mStr,mDyn,GetParamValue(OS,'EXPORT'),2,'', mPath + 'Imp.csv');
     OutputDebugString('Export prošel');
     LogInfoStr := LogInfoStr + 'OK2 - ' + mStr.Text;
    Except
      LogInfoStr := LogInfoStr + 'Chyba  v def. exportu.'  + #13#10  +  ExceptionMessage;
      Success := False;
      Exit;
    End;
  mFTP :=TFTP.Create;
  try
    mFTP.Host := GetParamValue(OS,'FTP_IP');
    mFTP.Username:= GetParamValue(OS,'FTP_USER');
    mFTP.Password:= GetParamValue(OS,'FTP_PASS');
    mFTP.Port := StrToInt(GetParamValue(OS,'FTP_PORT'));
    mFTP.Passive:= UpperCase(GetParamValue(OS,'FTP_PASIV'))='ANO';
    if FileExists(mPath + 'Imp.csv') then begin
          if Trim(GetParamValue(OS,'FTP_IP'))<>'' then begin
            try
              mFTP.Connect;
              mFTP.Put(mPath + 'Imp.csv', GetParamValue(OS,'FTP_DIR')+'Import.csv');
//            if CFxInternet.FTPPutFile(GetParamValue(OS,'FTP_IP'),GetParamValue(OS,'FTP_PORT'),GetParamValue(OS,'FTP_DIR')+'Import.csv',mPath + 'Imp.csv',GetParamValue(OS,'FTP_USER'),GetParamValue(OS,'FTP_PASS')) then
              LogInfoStr := LogInfoStr + ' Export dat proběhl';
//            else LogInfoStr := LogInfoStr + ' Export dat selhal';
            mFTP.Disconnect;
           Except
            LogInfoStr := LogInfoStr + 'Selhal export na FTP výjimka'  + #13#10  +  ExceptionMessage;
            Exit;
           End;
         end else begin
           if NxCopyFile(mPath + 'Imp.csv',GetParamValue(OS,'TargetPath')+'Import.csv') then
              LogInfoStr := LogInfoStr + ' Kopie dat proběhla'
            else LogInfoStr := LogInfoStr + ' Kopie dat selhala '  + GetParamValue(OS,'TargetPath')+'Import.csv';
         end;
    end;

  // Promo
    mStr := TStringList.Create;
   if Length(Trim(GetParamValue(OS,'PROMO')))= 10 then begin
     try
       mDyn := GetParamValue(OS,'PROMODYN');
       if Trim(mDyn) = '' then mDyn := 'EKJORJF13I04VCKDW5IFIPUVYG';
       LogInfoStr := LogInfoStr  + mDyn + mStr.Text;
       mStr.Clear;
       mStr.Add('AUTO');
       CFxReportManager.ExportByIDs(NxCreateContext(OS),mStr,mDyn,GetParamValue(OS,'PROMO'),2,'', mPath + 'Promo.csv');
       LogInfoStr := LogInfoStr  + 'OK Promo- ' + mStr.Text;
     Except
       LogInfoStr := LogInfoStr +#13#10 + 'Chyba v def. exportu promo akce.'  + #13#10  +  ExceptionMessage;
       Success := False;
     End;
      if FileExists(mPath + 'Promo.csv') then begin
         if Trim(GetParamValue(OS,'FTP_IP'))<>'' then begin
            try
              mFTP.Connect;
              mFTP.Put(mPath + 'Promo.csv', GetParamValue(OS,'FTP_DIR')+'Promo.csv');
              mFTP.Disconnect;
//             if CFxInternet.FTPPutFile(GetParamValue(OS,'FTP_IP'),GetParamValue(OS,'FTP_PORT'),GetParamValue(OS,'FTP_DIR') + 'Promo.csv',mPath + 'Promo.csv',GetParamValue(OS,'FTP_USER'),GetParamValue(OS,'FTP_PASS')) then
               LogInfoStr := LogInfoStr + ' Export promo dat proběhl'
//               else LogInfoStr := LogInfoStr + ' Export promo dat selhal';
             Except
               LogInfoStr := 'Selhal export Promo na FTP výjimka'  + #13#10  +  ExceptionMessage;
               Success := False;
               Exit;
             End;
          end else
             if NxCopyFile(mPath + 'Promo.csv',GetParamValue(OS,'TargetPath')+'Promo.csv') then
                LogInfoStr := LogInfoStr + ' Kopie promo dat proběhla'
              else LogInfoStr := LogInfoStr + ' Kopie promo dat selhala '  + GetParamValue(OS,'TargetPath')+'Promo.csv';
          end;
      end;
   finally
      mFTP.Free;
    end;
  finally
    mStr.Free;
  end;
  LogInfoStr := 'OK';
  Success := true;
  IntDateExportImportInv(OS,Now,0);
end;

procedure AutoLoadInventoroSubCards (OS: TNxCustomObjectSpace;
  var Success: Boolean; var LogInfoStr: String);
var
  mPath,mFile: String;
  mCSVStr : TStringList;
  mFTP: TFTP;
begin
  Success := True;
  LogInfoStr := 'AUTO';
  mPath := GetParamValue(OS,'PATH');
  mFTP :=TFTP.Create;
  try
    mFTP.Host := GetParamValue(OS,'FTP_IP');
    mFTP.Username:= GetParamValue(OS,'FTP_USER');
    mFTP.Password:= GetParamValue(OS,'FTP_PASS');
    mFTP.Port := StrToInt(GetParamValue(OS,'FTP_PORT'));
    mFTP.Passive:= UpperCase(GetParamValue(OS,'FTP_PASIV'))='ANO';
    mFTP.Connect;
    if Trim(GetParamValue(OS,'FTP_IP')) <> '' then begin
       DeleteFile(mPath + 'Export.csv');
       mFTP.Get(GetParamValue(OS,'FTP_DIR')+'Import_result.csv',mPath + 'Export.csv');
       try
    //    if CFxInternet.FTPGetFile(GetParamValue(OS,'FTP_IP'),GetParamValue(OS,'FTP_PORT'),GetParamValue(OS,'FTP_DIR')+'Import_result.csv',mPath + 'Export.csv',GetParamValue(OS,'FTP_USER'),GetParamValue(OS,'FTP_PASS')) then begin
          mCSVStr:= TStringList.Create;
          try
             mFTP.Disconnect;
             mCSVStr.LoadFromFile(mPath + 'Export.csv');
            if mCSVStr.Count <> 0 then begin // není načtený nebo je již zpracovaný
               mImportLogio(OS,mCSVStr,LogInfoStr,nil);
               IntDateExportImportInv(OS,Now,1); // dopíše datum čas importu
//               RenameFile(mPath + 'Export.csv',mPath + 'Exp_' +DateTimeToStr(date)+'.csv');
//               mCSVStr.Clear;
//               mCSVStr.SaveToFile(mPath + 'Export.csv');
//               CFxInternet.FTPPutFile(GetParamValue(OS,'FTP_IP'),GetParamValue(OS,'FTP_PORT'),GetParamValue(OS,'FTP_DIR')+'Import_result.csv',mPath + 'Export.csv',GetParamValue(OS,'FTP_USER'),GetParamValue(OS,'FTP_PASS'));
             mFTP.Connect;
             mFTP.Delete(GetParamValue(OS,'FTP_DIR')+'Import_result.csv');
             mFTP.Disconnect;
            end;
          finally
            mCSVStr.Free;
          end;
       except
         LogInfoStr := 'Není připraven soubor s daty (je prázdný= již načtený) nebo selhala komunikace: ' + ExceptionMessage;
       end;
//      end else LogInfoStr := 'Není připraven soubor s daty (nebo nedošlo k napojení na FTP účet)';
    end else begin
       if FileExists(GetParamValue(OS,'TargetPath')+'Import_result.csv') then begin
         NxCopyFile(GetParamValue(OS,'TargetPath') + 'Import_result.csv',mPath+'Export.csv');
         mCSVStr:= TStringList.Create;
         try
           mCSVStr.LoadFromFile(mPath + 'Export.csv');
          if mCSVStr.Count <> 0 then begin // není načtený nebo je již zpracovaný
             mImportLogio(OS,mCSVStr,LogInfoStr,nil);
             IntDateExportImportInv(OS,Now,1);
             NxDeleteFiles(GetParamValue(OS,'TargetPath'),'Import_result.csv');
           end else LogInfoStr := 'Není připraven soubor s daty (je prázdný= již načtený)';
         finally
           mCSVStr.Free;
         end;
       end else begin
          LogInfoStr := 'Není připraven soubor s daty (je prázdný= již načtený)';
       end;
    end;
  finally
   mFTP.Free;
  end;
end;

procedure TestFTP(OS: TNxCustomObjectSpace;  var Success: Boolean; var LogInfoStr: String);
var
 S : string;
 Str : TStringList;
 mPath : String;
 mFTP: TFTP;
begin
  mPath := GetParamValue(OS,'PATH');
  LogInfoStr := LogInfoStr + 'Cesta:' + mPath + #13#10;
  Str := TStringList.Create;
  mFTP :=TFTP.Create;
  Try
    mFTP.Host := GetParamValue(OS,'FTP_IP');
    mFTP.Username:= GetParamValue(OS,'FTP_USER');
    mFTP.Password:= GetParamValue(OS,'FTP_PASS');
    mFTP.Port := StrToInt(GetParamValue(OS,'FTP_PORT'));
    mFTP.Passive:= UpperCase(GetParamValue(OS,'FTP_PASIV'))='ANO';
    mFTP.Connect;

  Str.Text := 'Pokusný Export';
  Str.SaveToFile(mPath + 'Test.txt');
    try
      mFTP.Put(mPath + 'Test.txt', GetParamValue(OS,'FTP_DIR')+'test.txt');
      LogInfoStr:= LogInfoStr + 'Export dat na FTP proběhl' + #13#10;
      DeleteFile(mPath + 'TestExp.txt');
      mFTP.Get(GetParamValue(OS,'FTP_DIR')+'test.txt',mPath + 'TestExp.txt');
      LogInfoStr:= LogInfoStr + 'Import dat z FTP proběhl' + #13#10;
    except
      LogInfoStr:= LogInfoStr + 'CHYBA: Přenos dat na/z FTP selhal: ' +ExceptionMessage +  #13#10;
      Success := false;
    end;
  finally
    Str.Free;
    mFTP.Free;
  end;
end;

begin
end.