procedure CreateFile (OS: TNxCustomObjectSpace; var Success: Boolean; var LogInfoStr: String);
var
 mList:TStringList;
 mContext:TNxContext;
 mFileName:string;
 mFTP:TFTP;
 mInfo:String;
begin
  mList:=TStringList.Create;
  //mList.Add('#000000007');
  os.SQLSelect('Select id from storecards where hidden=''N'' and X_Eshop=''A'' ',mList);
  mfileName:='StoreCardsCloud.xml';
  CFxReportManager.ExportByIDs(NxCreateContext(OS),mlist,'OGQQA2C25JDL342N01C0CX3FCC','IHG0000101',0,'',NxGetTempDir+mFileName);
  if FileExists(NxGetTempDir+mfilename) then NxCopyFile(NxGetTempDir+mfilename,'C:\eshop\StoreCardsCloud.xml');
  if FileExists('C:\eshop\StoreCardsCloud.xml') then begin
      mInfo:='soubor se povedlo  vytvořit.';
      mFTP:= TFTP.Create;
      mFTP.Host:='untraco.cloud';
      mFTP.Port:=21;
      mftp.UserName:='untraco_abra';
      mFTP.Password:='P@7v38j5y#112';
      mftp.Connect;
      mFTP.Passive:=true;
      mftp.Put('C:\eshop\StoreCardsCloud.xml', 'StoreCardsCloud.xml');
      mInfo:=mInfo+#13#10+'soubor se povedlo  odeslat na ftp.';
      mFTP.Disconnect;
  {  DeleteFile(mFileName);}
  end;
  Success := True;
  LogInfoStr := ''+mInfo;
end;

procedure CreateFileFirms (OS: TNxCustomObjectSpace; var Success: Boolean; var LogInfoStr: String);
var
 mList:TStringList;
 mContext:TNxContext;
 mFileName:string;
 mFTP:TFTP;
 mInfo:String;
begin
  mList:=TStringList.Create;
  //mList.Add('#000000007');
  os.SQLSelect('Select id from Firms where hidden=''N'' and firm_id is null ',mList);
  mfileName:='FirmsCloud.xml';
  CFxReportManager.ExportByIDs(NxCreateContext(OS),mlist,'W0DR1FTE3JD13ACL03KIU0CLP4','J200000101',0,'',NxGetTempDir+mFileName);
  if FileExists(NxGetTempDir+mfilename) then NxCopyFile(NxGetTempDir+mfilename,'C:\eshop\FirmsCloud.xml');
  if FileExists('C:\eshop\FirmsCloud.xml') then begin
      mInfo:='soubor se povedlo  vytvořit.';
      mFTP:= TFTP.Create;
      mFTP.Host:='untraco.cloud';
      mFTP.Port:=21;
      mftp.UserName:='untraco_abra';
      mFTP.Password:='P@7v38j5y#112';
      mftp.Connect;
      mFTP.Passive:=true;
      mftp.Put('C:\eshop\FirmsCloud.xml', 'FirmsCloud.xml');
      mInfo:=mInfo+#13#10+'soubor se povedlo  odeslat na ftp.';
      mFTP.Disconnect;
  {  DeleteFile(mFileName);}
  end;
  Success := True;
  LogInfoStr := ''+mInfo;
end;

begin
end.