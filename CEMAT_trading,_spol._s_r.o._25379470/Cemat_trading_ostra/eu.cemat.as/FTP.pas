const
  cFTPlogin='ftpes://mojepneu.cemat:2NEPX%C2%A31%5E5OBe7fm44%3F-%3B@ftps.mimedigital.cz:2121/';
  cFTPlogin2='sftp://cemat:4f31o17gj0tk@edi.contitrade.com/ -hostkey="ssh-rsa 1024 F9e8nULg5rO/nGeTfyB2jNZ2cvkKSFSip43QeECQCVo';
  cFTPexec='C:\Program Files (x86)\WinSCP\winscp.com /console /script="%s" ';



function FTPUpload(AOS: TNxCustomobjectSpace; AFileName: String; AHide: Boolean = true): Boolean;
var
  mExportBatch: TStringList;
  mFileBatch: String;
  mCanDeleteFile: Boolean;
begin
  Result := False;
  mCanDeleteFile := False;
  mExportBatch := TStringList.Create;
  try
    mExportBatch.Add(Format('open %s', [cFTPlogin]));
    mExportBatch.Add(Format('mput  "%s"', [AFileName]));
    if AHide then
      mExportBatch.Add('bye');
    if NxCreateTempFile(mFileBatch) then begin
      mExportBatch.SaveToFile(mFileBatch);
      if NxExecFile(Format(cFTPexec, [mFileBatch]), AHide, True) then
        Result:= True;
    end;
  finally
    mExportBatch.Free;
  end;
end;

function FTPUploadEDI(AOS: TNxCustomobjectSpace; AFileName: String; AHide: Boolean = true): Boolean;
var
  mExportBatch: TStringList;
  mFileBatch: String;
  mCanDeleteFile: Boolean;
begin
  Result := False;
  mCanDeleteFile := False;
  mExportBatch := TStringList.Create;
  try
    mExportBatch.Add(Format('open %s', [cFTPlogin2]));
    mExportBatch.add('cd /Live/Stock');
    mExportBatch.Add(Format('mput  "%s"', [AFileName]));
    if AHide then
      mExportBatch.Add('bye');
    if NxCreateTempFile(mFileBatch) then begin
      mExportBatch.SaveToFile(mFileBatch);
      mExportBatch.savetofile('C:\AbraG3\_batch\batch.txt');
      if NxExecFile(Format(cFTPexec, [mFileBatch]), AHide, True) then
        Result:= True;
    end;
  finally
    mExportBatch.Free;
  end;
end;



procedure FTPDownloadEDI(OS: TNxCustomObjectSpace; var Success: Boolean; var LogInfoStr: String);
var
  mExportBatch: TStringList;
  mFileBatch: String;
  mCanDeleteFile: Boolean;
begin
  Success := False;
  mCanDeleteFile := False;
  mExportBatch := TStringList.Create;
  try
    mExportBatch.Add(Format('open %s', [cFTPlogin2]));
    mExportBatch.add('cd /Live/Order/Out');
    mExportBatch.Add('lcd c:\AbraG3\_exchange\orders\');
    mExportBatch.Add('get *.*');
    mExportBatch.Add('rm *.*');
    mExportBatch.Add('close');
    mExportBatch.Add('exit');
    if NxCreateTempFile(mFileBatch) then begin
      mExportBatch.SaveToFile(mFileBatch);
      mExportBatch.savetofile('C:\AbraG3\_batch\batch2.txt');
      if NxExecFile(Format(cFTPexec, [mFileBatch]), True, True) then
        Success:= True;
    end;
  finally
    mExportBatch.Free;
  end;
end;

begin
end.