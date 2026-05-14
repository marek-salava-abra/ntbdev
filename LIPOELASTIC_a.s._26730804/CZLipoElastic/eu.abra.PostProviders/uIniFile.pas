uses 'eu.abra.PostProviders.uConst';

procedure ExInitSiteCreateIniFile(ASite: TSiteForm;);
var
  mAction: TAction;
begin
  if Assigned(ASite) then begin
    mAction := ASite.GetNewAction;
    if Assigned(mAction) then begin
      mAction.Name := 'actCreateIniFile';
      mAction.ShowControl := true;
      mAction.ShowMenuItem := true;
      mAction.Caption := 'Konfigurační soubor';
      mAction.Hint := 'Vytvoří ini soubor s extra nastavením';
      mAction.Category := 'tabList';
      mAction.OnExecute := @CreateIniFile;
    end;
  end;
end;

//Cloud + RDP
function GetIniPath:String;
const //cRDPPath = '\\tsclient\C\'; //na lokále funkce vyhodnotí chybu místo false
      //cRDPPathFull = '\\tsclient\C\ABRA\'; //na lokále funkce vyhodnotí chybu místo false
      ///cCloud = 'S:\ABRA-APPS\PDFXCview\';
      cCloud = 'S:\ABRA-APPS\PDFXCview\CCCVVVBBB'; // PLAY nechceme S:ko. Dáme do kořenového adresáře.
      cCloudFull = 'S:\ABRA-APPS\PDFXCview\Balikobot\';
begin
  Result := '';
  (*if DirectoryExists(cCloud) then
  begin
    if DirectoryExists(cCloudFull) then
      Result := ExtractFilePath(cCloudFull)
    else
      if CreateDir(cCloudFull) then
        Result := ExtractFilePath(cCloudFull)
      else
        ExtractFilePath(ParamStr(0));
  end
  else*)
  OutputDebugString('GetIniPath: '+ParamStr(0));
  Result := ExtractFilePath(ParamStr(0));

end;


procedure CreateIniFile(Sender : Tcomponent;);
var
   mFile : TIniFile;
   mDir :String;
begin


  mDir := GetIniPath;
  OutputDebugString('ini path: '+ mDir);

  if DirectoryExists(mDir) then
  begin
    if FileExists(NxAddPathDelimiter(mDir)+cExtrasSetingFileName) then
    begin
      if not ShellAPI.OpenFile(NxAddPathDelimiter(mDir)+cExtrasSetingFileName ) then
        NxMessageBox('Extra nastavení',
          'Nelze otevřít soubor ['+NxAddPathDelimiter(mDir)+cExtrasSetingFileName+']', mdError, mdbOk,0, nil, false, Sender.Site) ;
    end
    else
    begin
      try
        mFile := TIniFile.Create(NxAddPathDelimiter(mDir)+cExtrasSetingFileName);
        if Assigned(mFile) then
        begin
          mFile.WriteString('Baliky', 'AutoExport', 'N');
          mFile.WriteString('Baliky', 'AutoPrint', 'N');
          mFile.WriteString('Print', 'PrinterName', '');
          mFile.WriteString('PrintLabel', 'PrinterName', '');
          mFile.WriteString('PDFXCview', '#Používá příkazové řádky pro tisk. Jedná se o druhou možnost pro případ nefunkčního tisk s nastaveným výchozím prohlížečem PDF.', '');
          mFile.WriteString('PDFXCview', 'Enabled', 'N');
          mFile.WriteString('PDFXCview', 'Path', 'S:\ABRA-APPS\PDFXCview\PDFXCview.exe');
          mFile.WriteString('PDFXCview', '#Path', 'C:\Program Files\Tracker Software\PDF Viewer\PDFXCview.exe');
          mFile.WriteString('PDFXCview', 'ShowUI', 'N');
          mFile.WriteString('PDFXCview', '#Nastavení jako je umístění, přizpůsobení atd. Lze exportovat z PDF XChange Viewer do souboru. Následně použít při tisku.', '');
          mFile.WriteString('PDFXCview', 'SettingFile', 'S:\ABRA-APPS\PDFXCview\Settings.dat');
          mFile.WriteString('PDFXCview', 'RDPPrint', 'N');



          NxMessageBox('Extra nastavení',
          'Soubor byl vytvořen ['+NxAddPathDelimiter(mDir)+cExtrasSetingFileName+']', mdInformation, mdbOk,0, nil, false, Sender.Site) ;
        end
        else
          NxMessageBox('Extra nastavení',
          'Nelze vytvořit soubor ['+NxAddPathDelimiter(mDir)+cExtrasSetingFileName+']', mdError, mdbOk,0, nil, false, Sender.Site) ;
      finally
        if Assigned(mFile) then  mFile.Free;
      end;
    end;

  end;
end;



function GetExtrasSetings(const ASectionName:String; const AReadName:String; const ADefault : String):String;
var
   mFile : TIniFile;
   mPath: String;
begin
  Result := ADefault;
  mPath := GetIniPath;

  if FileExists( NxAddPathDelimiter(ExtractFilePath( mPath ))+cExtrasSetingFileName ) then begin
     try
        mFile := TIniFile.Create(NxAddPathDelimiter(ExtractFilePath( mPath ))+cExtrasSetingFileName);
        if Assigned(mFile) then
        begin
           Result := mFile.ReadString(ASectionName, AReadName, ADefault);
        end;
     finally
        if Assigned(mFile) then
           mFile.Free;
     end;
  end;
end;



begin
end.