uses '.ftp';

procedure ExportData (OS: TNxCustomObjectSpace; var Success: Boolean; var LogInfoStr: String);
const
  cSQL = 'SELECT A.ID FROM StoreCards A WHERE hidden=''N'' and (A.StoreAssortmentGroup_ID IN (''1200000101'',''2200000101'',''3200000101'',''1600000101'',''5200000101'') ) ';
var
  mList, mList2 : TStringList;
  mFileName:String;
  mFTP:TFTP;
begin
  mList := TStringList.create;
  mList2 :=TStringList.create;
  mFileName:=NxGetTempDir+'chara.csv';
  try
    OS.SQLSelect(cSQL, mList);
    if mList.Count > 0 then begin
      CfxReportManager.ExportByIDs(NxCreateContext(OS),mList,'OGQQA2C25JDL342N01C0CX3FCC','1T00000101',0,'',mFileName);
    end;
  finally
    mList.Free;
  end;
         mFTP:= TFTP.Create;
         mFTP.Host:='89.185.254.51';
         mFTP.Port:=22450;
         mftp.UserName:='chara_cemat';
         mFTP.Password:='oleiGh7oaphieY9l';
         mftp.Connect;
         mFTP.Passive:=true;
         mftp.Put(mFileName, 'chara.csv');
         mFTP.Free;

  Success := True;
  //LogInfoStr := '';
end;

procedure ExportData2 (OS: TNxCustomObjectSpace; var Success: Boolean; var LogInfoStr: String);
const
  cSQL = 'SELECT A.ID FROM StoreCards A WHERE hidden=''N'' ';
var
  mList, mList2 : TStringList;
  mFileName, mMessage:String;
  mFTP:TFTP;
begin
  mList := TStringList.create;
  mList2 :=TStringList.create;
  mFileName:=NxGetTempDir+'pneuok.csv';
  try
    OS.SQLSelect(cSQL, mList);
    if mList.Count > 0 then begin
      CfxReportManager.ExportByIDs(NxCreateContext(OS),mList,'OGQQA2C25JDL342N01C0CX3FCC','1010000101',0,'',mFileName);
    end;
  except
    mMessage:=ExceptionMessage;
  end;
         mFTP:= TFTP.Create;
         mFTP.Host:='pneuok.cz';
         //mFTP.Port:=34000;
         mftp.UserName:='pneuokcz85';
         mFTP.Password:='Nd0q5ACbFZ';
         mftp.Connect;
         mFTP.Passive:=true;
         mftp.Put(mFileName, 'pneuok.csv');
         mFTP.Free;

  Success := True;
  LogInfoStr :=mMessage+#13#10+ NxGetTempDir+'pneuok.csv'+#13#10+IntToStr(mList.count);
end;

procedure ExportData3 (OS: TNxCustomObjectSpace; var Success: Boolean; var LogInfoStr: String);
const
  cSQL = 'SELECT A.ID FROM StoreCards A WHERE hidden=''N'' ';
var
  mList, mList2 : TStringList;
  mFileName:String;
  mFTP:TFTP;
begin
  mList := TStringList.create;
  mList2 :=TStringList.create;
  mFileName:=NxGetTempDir+'pneuznetu.xml';
  try
    OS.SQLSelect(cSQL, mList);
    if mList.Count > 0 then begin
      CfxReportManager.ExportByIDs(NxCreateContext(OS),mList,'OGQQA2C25JDL342N01C0CX3FCC','1210000101',0,'',mFileName);
    end;
  finally
    mList.Free;
  end;
         mFTP:= TFTP.Create;
         mFTP.Host:='pneuznetu.cz';
         //mFTP.Port:=34000;
         mftp.UserName:='cematpneuznetu';
         mFTP.Password:='bc703624fa8';
         mftp.Connect;
         mFTP.Passive:=true;
         mftp.Put(mFileName, 'pneuznetu.xml');
         mFTP.Free;

  Success := True;
  //LogInfoStr := '';
end;

procedure ExportData4 (OS: TNxCustomObjectSpace; var Success: Boolean; var LogInfoStr: String);
const
  cSQL = 'SELECT A.ID FROM StoreCards A WHERE hidden=''N'' ';
var
  mList, mList2 : TStringList;
  mFileName:String;
  mFTP:TFTP;
begin
  mList := TStringList.create;
  mList2 :=TStringList.create;
  mFileName:=NxGetTempDir+'megapneu.xml';
  try
    OS.SQLSelect(cSQL, mList);
    if mList.Count > 0 then begin
      CfxReportManager.ExportByIDs(NxCreateContext(OS),mList,'OGQQA2C25JDL342N01C0CX3FCC','1730000101',0,'',mFileName);
    end;
  finally
    mList.Free;
  end;
         mFTP:= TFTP.Create;
         mFTP.Host:='ftp.megalevnepneu.com';
         //mFTP.Port:=34000;
         mftp.UserName:='cernat';
         mFTP.Password:='ZijYeft3Wrosh3';
         mftp.Connect;
         mFTP.Passive:=true;
         mftp.Put(mFileName, 'megapneu.xml');
         mFTP.Free;

  Success := True;
  //LogInfoStr := '';
end;

procedure ExportData10 (OS: TNxCustomObjectSpace; var Success: Boolean; var LogInfoStr: String);
const
  cSQL = 'SELECT A.StoreCard_ID FROM StorePrices A WHERE A.PriceList_ID=''3K60000101'' ';
var
  mList, mList2 : TStringList;
  mFileName:String;
  mFTP:TFTP;
begin
  mList := TStringList.create;
  mList2 :=TStringList.create;
  mFileName:='c:\abrag3\tasy.xml';
  try
    OS.SQLSelect(cSQL, mList);
    if mList.Count > 0 then begin
      CfxReportManager.ExportByIDs(NxCreateContext(OS),mList,'OGQQA2C25JDL342N01C0CX3FCC','27L0000101',0,'',mFileName);
    end;
  finally
    mList.Free;
  end;


  Success := True;
  //LogInfoStr := '';
end;


procedure ExportData5 (OS: TNxCustomObjectSpace; var Success: Boolean; var LogInfoStr: String);
const
  cSQL = 'SELECT A.ID FROM StoreCards A WHERE hidden=''N'' ';
var
  mList, mList2 : TStringList;
  mFileName:String;
  mFTP:TFTP;
begin
  mList := TStringList.create;
  mList2 :=TStringList.create;
  mFileName:=NxGetTempDir+'pro-pneu.xml';
  try
    OS.SQLSelect(cSQL, mList);
    if mList.Count > 0 then begin
      CfxReportManager.ExportByIDs(NxCreateContext(OS),mList,'OGQQA2C25JDL342N01C0CX3FCC','1740000101',0,'',mFileName);
    end;
  finally
    mList.Free;
  end;
         mFTP:= TFTP.Create;
         mFTP.Host:='ftp.pro-pneu.cz';
         //mFTP.Port:=34000;
         mftp.UserName:='cemat.p-p';
         mFTP.Password:='7%Is1ke6';
         mftp.Connect;
         mFTP.Passive:=true;
         mftp.Put(mFileName, 'pro-pneu.xml');
         mFTP.Free;

  Success := True;
  //LogInfoStr := '';
end;

procedure ExportData6 (OS: TNxCustomObjectSpace; var Success: Boolean; var LogInfoStr: String);
const
  cSQL = 'SELECT A.ID FROM StoreCards A WHERE hidden=''N'' ';
var
  mList, mList2 : TStringList;
  mFileName:String;
  mFTP:TFTP;
begin
  mList := TStringList.create;
  mList2 :=TStringList.create;
  mFileName:=NxGetTempDir+'koltico.xml';
  try
    OS.SQLSelect(cSQL, mList);
    if mList.Count > 0 then begin
      CfxReportManager.ExportByIDs(NxCreateContext(OS),mList,'OGQQA2C25JDL342N01C0CX3FCC','2790000101',0,'',mFileName);
    end;
  finally
    mList.Free;
  end;
         mFTP:= TFTP.Create;
         mFTP.Host:='nas.koltico.eu';
         mFTP.Port:=21321;
         mftp.UserName:='cemat';
         mFTP.Password:='Ys+j+=k2';
         mftp.Connect;
         mFTP.Passive:=true;
         mFTP.ChangeDir('home');
         mftp.Put(mFileName, 'koltico.xml');
         mFTP.Free;

  Success := True;
  //LogInfoStr := '';
end;

procedure ExportData7 (OS: TNxCustomObjectSpace; var Success: Boolean; var LogInfoStr: String);
const
  cSQL = 'SELECT A.ID FROM StoreCards A WHERE hidden=''N'' ';
var
  mList, mList2 : TStringList;
  mFileName:String;
  mFTP:TFTP;
begin
  mList := TStringList.create;
  mList2 :=TStringList.create;
  mFileName:=NxGetTempDir+'mojepneu.xml';
  try
    OS.SQLSelect(cSQL, mList);
    if mList.Count > 0 then begin
      CfxReportManager.ExportByIDs(NxCreateContext(OS),mList,'OGQQA2C25JDL342N01C0CX3FCC','17C0000101',0,'',mFileName);
    end;
  finally
    mList.Free;
  end;
         mFTP:= TFTP.Create;
         mFTP.Host:='barumpneu-1.superhosting.cz';
         //mFTP.Port:=34000;
         mftp.UserName:='ihla';
         mFTP.Password:='JafWaygecIbNochusiv4';
         mftp.Connect;
         mFTP.Passive:=true;
         mFTP.TransferType:=ftBinary;
         mftp.Put(mFileName, 'mojepneu.xml');
         mFTP.Free;
        FTPUpload(OS, mFileName);
  Success := True;
  LogInfoStr := ''+NxGetTempDir;
end;

procedure ExportData8 (OS: TNxCustomObjectSpace; var Success: Boolean; var LogInfoStr: String);
const
  cSQL = 'SELECT A.ID FROM StoreCards A WHERE hidden=''N'' ';
var
  mList, mList2 : TStringList;
  mFileName:String;
  mFTP:TFTP;
begin
  mList := TStringList.create;
  mList2 :=TStringList.create;
  mFileName:=NxGetTempDir+'VZV.xml';
  try
    OS.SQLSelect(cSQL, mList);
    if mList.Count > 0 then begin
      CfxReportManager.ExportByIDs(NxCreateContext(OS),mList,'OGQQA2C25JDL342N01C0CX3FCC','17D0000101',0,'',mFileName);
    end;
  finally
    mList.Free;
  end;
         mFTP:= TFTP.Create;
         mFTP.Host:='getup.savana-hosting.cz';
         //mFTP.Port:=34000;
         mftp.UserName:='cemat';
         mFTP.Password:='TJYvMrfFVA9rgdn';
         mftp.Connect;
         mFTP.Passive:=true;
         mftp.Put(mFileName, 'VZV.xml');
         mFTP.Free;

  Success := True;
  //LogInfoStr := '';
end;

procedure ExportData9 (OS: TNxCustomObjectSpace; var Success: Boolean; var LogInfoStr: String);
const
  cSQL = 'SELECT A.StoreCard_ID FROM StorePrices A WHERE A.PriceList_ID=''1K60000101'' ';
var
  mList, mList2 : TStringList;
  mFileName:String;
  mFTP:TFTP;
begin
  mList := TStringList.create;
  mList2 :=TStringList.create;
  mFileName:=NxGetTempDir+'EAGRO.csv';
  try
    OS.SQLSelect(cSQL, mList);
    if mList.Count > 0 then begin
      CfxReportManager.ExportByIDs(NxCreateContext(OS),mList,'OGQQA2C25JDL342N01C0CX3FCC','17L0000101',0,'',mFileName);
    end;
  finally
    mList.Free;
  end;
         mFTP:= TFTP.Create;
         mFTP.Host:='e-agropneu.com';
         //mFTP.Port:=34000;
         mftp.UserName:='eagropneuc12.e-agropneu.com';
         mFTP.Password:='8fVpUeW9KJ';
         mftp.Connect;
         mFTP.Passive:=true;
         mftp.Put(mFileName, 'EAGRO.csv');
         mFTP.Free;

  Success := True;
  //LogInfoStr := '';
end;

procedure ExportData11 (OS: TNxCustomObjectSpace; var Success: Boolean; var LogInfoStr: String);
const
  cSQL = 'SELECT A.ID FROM StoreCards A WHERE hidden=''N'' ';
var
  mList, mList2 : TStringList;
  mFileName:String;
  mFTP:TFTP;
begin
  mList := TStringList.create;
  mList2 :=TStringList.create;
  mFileName:=NxGetTempDir+'pneukomplet.csv';
  try
    OS.SQLSelect(cSQL, mList);
    if mList.Count > 0 then begin
      CfxReportManager.ExportByIDs(NxCreateContext(OS),mList,'OGQQA2C25JDL342N01C0CX3FCC','47M0000101',0,'',mFileName);
    end;
  finally
    mList.Free;
  end;
         mFTP:= TFTP.Create;
         mFTP.Host:='podoli.pneukomplet.cz';
         //mFTP.Port:=34000;
         mftp.UserName:='cemat';
         mFTP.Password:='HrQ9jXqdTB8Zj:by-mSH';
         mftp.Connect;
         mFTP.Passive:=true;
         mftp.Put(mFileName, 'pneukomplet.csv');
         mFTP.Free;

  Success := True;
  //LogInfoStr := '';
end;

procedure ExportData12 (OS: TNxCustomObjectSpace; var Success: Boolean; var LogInfoStr: String);
const
  cSQL = 'SELECT StoreCard_ID FROM StorePrices WHERE PriceList_ID=''2K70000101'' ';
var
  mList, mList2 : TStringList;
  mFileName:String;
  mFTP:TFTP;
begin
  mList := TStringList.create;
  mList2 :=TStringList.create;
  mFileName:=NxGetTempDir+'PSTOCKRCEMCZB.6000';
  try
    OS.SQLSelect(cSQL, mList);
    if mList.Count > 0 then begin
      CfxReportManager.ExportByIDs(NxCreateContext(OS),mList,'OGQQA2C25JDL342N01C0CX3FCC','57O0000101',0,'',mFileName);
    end;
  finally
    mList.Free;
  end;
    ftpuploadedi(OS,mfilename);

  Success := True;
  //LogInfoStr := '';
end;

begin
end.