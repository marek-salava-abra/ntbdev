procedure GenerateVelux(OS: TNxCustomObjectSpace; var Success: Boolean; var LogInfoStr: String);
var
 mList:TStringList;
 mSQL:String;
 mFileName,mDestFile:String;
 mFTP:TFTP;
begin
  mFileName:='c:\abragen\32_'+FormatDateTime('YYYYMMDD',date)+'.txt';
  mDestFile:='32_'+FormatDateTime('YYYYMMDD',date)+'.txt';
  mSQL:='SELECT A.ID FROM  StoreDocuments2 A JOIN StoreDocuments SD ON SD.ID=A.Parent_ID WHERE A.RowType=3 AND (SD.DocumentType = ''21'' or SD.DocumentType = ''23'') AND (SD.DocDate$DATE >= ''%s'' and SD.DocDate$DATE < ''%s'' )';
  mList:=TStringList.Create;
  OS.SQLSelect(format(mSQL,[IntToStr(Trunc(date)-7),IntToStr(Trunc(date))]),mList);
  if mList.Count>0 then begin
    CFxReportManager.ExportByIDs(NxCreateContext(OS),mlist,'WBFDIVPW1ZE13HBT00C5OG4NF4','1A00000101',0,'',mfileName);

  end;
   if FileExists(mFileName) then begin
      mFTP:= TFTP.Create;
      mFTP.Host:='www.strechyplneodmen.cz';
      mFTP.Port:=21;
      mftp.UserName:='obb';
      mFTP.Password:='QCqRnplY-EYj59!NU';
      mftp.Connect;
      mFTP.Passive:=true;
    {   mftp.ChangeDir('strechyplneodmen.cz'); }
      mftp.Put(mfilename, mDestFile);

  {  DeleteFile(mFileName);}
  end;
  Success := True;
  LogInfoStr := 'Založil jsem soubor '+mFileName;
end;

begin
end.