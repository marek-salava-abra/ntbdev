uses '.consts';

procedure InitSite_Hook(Self: TSiteForm);
var
  mAction: TMultiAction;
begin
  mAction := Self.GetNewMultiAction;
  mAction.ShowControl := True;
  mAction.ShowMenuItem := True;
  mAction.Caption := 'Dokumenty';
  mAction.Items.Add('Návod k obsluze');
  mAction.Items.Add('Kalibrační certifikát');
  mAction.Items.Add('Produktový list');
  //mAction.Items.Add('Bezpečnostní list');
  mAction.Items.Add('Odebrat - Návod k obsluze');
  mAction.Items.Add('Odebrat - Kalibrační certifikát');
  mAction.Items.Add('Odebrat - Produktový list');
  //mAction.Items.Add('Odebrat - Bezpečnostní list');
  mAction.Hint := 'Připojení dokumentu';
  mAction.Category := 'tabDetail';
  mAction.OnExecuteItem := @CreateDoc;
end;

Procedure CreateDoc(Sender:TComponent;index:integer);
var
 mSite:TSiteForm;
 mOS:TNxCustomObjectSpace;
 mOpenDlg:TOpenDialog;
 mBO:TNxCustomBusinessObject;
 mFileName, mOrigFile:string;
 mFtp:TFTP;
 mMessage:string;
 mList:TStringList;
begin
 mSite:=TComponent(Sender).BusRollSite;
 mOS:=mSite.BaseObjectSpace;
 mBO:=TBusRollSiteForm(mSite).CurrentObject;
 if Assigned(mBO) then begin
   if Index=0 then begin
     mOpenDlg := TOpenDialog.Create(Sender);
     mOpenDlg.Filter:= 'Návod v pdf|*.pdf';
      if mOpenDlg.Execute then begin
        mOrigFile:=mOpenDlg.FileName;
        mFileName:=mOpenDlg.FileName;
        mFileName:=Copy(mFileName,NxCharPosR('\',mFileName)+1,300);
        mFileName:=TEncoding.RemoveDiacritics(mFileName);
        mFileName:=NxSearchReplace(mFileName,' ','_',[srAll]);
        mFileName:='KT_'+mbo.GetFieldValueAsString('Code')+'_'+mFileName;
        if not(DirectoryExists(cMainDir2+'\'+mBO.oid)) then CreateDir(cMainDir2+'\'+mBO.oid);
            NxCopyFile(mOrigFile,cMainDir2+'\'+mBO.oid+'\'+mFileName);
            mbo.SetFieldValueAsString('X_navod_filename',mFileName);
            mbo.SetFieldValueAsString('X_navod_name','Návod k obsluze');
            try
             mFTP:= TFTP.Create;
             mFTP.Host:=cURL;
             mftp.UserName:=cLogin;
             mFTP.Password:=cPass;
             mftp.Connect;
             mFTP.Passive:=true;
             mFtp.ChangeDir('prilohy');
             mFTP.TransferType:=ftBinary;
             mftp.Put(mOrigFile,mfileName);
             mFTP.Free;
           except
             NxShowSimpleMessage(ExceptionMessage,mSite);
           end;
      end;
   end;
   if Index=1 then begin
     mOpenDlg := TOpenDialog.Create(Sender);
     mOpenDlg.Filter:= 'Kalibrační certifikát v pdf|*.pdf';
      if mOpenDlg.Execute then begin
        mOrigFile:=mOpenDlg.FileName;
        mFileName:=mOpenDlg.FileName;
        mFileName:=Copy(mFileName,NxCharPosR('\',mFileName)+1,300);
         mFileName:=TEncoding.RemoveDiacritics(mFileName);
        mFileName:=NxSearchReplace(mFileName,' ','_',[srAll]);
        mFileName:='KT_'+mbo.GetFieldValueAsString('Code')+'_'+mFileName;
        if not(DirectoryExists(cMainDir2+'\'+mBO.oid)) then CreateDir(cMainDir2+'\'+mBO.oid);
            NxCopyFile(mOrigFile,cMainDir2+'\'+mBO.oid+'\'+mFileName);
            mbo.SetFieldValueAsString('X_Certificate_Filename',mFileName);
            mbo.SetFieldValueAsString('X_Certificate_name','Certifikát');
            try
             mFTP:= TFTP.Create;
             mFTP.Host:=cURL;
             mftp.UserName:=cLogin;
             mFTP.Password:=cPass;
             mftp.Connect;
             mFTP.Passive:=true;
             mFtp.ChangeDir('prilohy');
             mFTP.TransferType:=ftBinary;
             mftp.Put(mOrigFile,mfileName);
             mFTP.Free;
           except
             NxShowSimpleMessage(ExceptionMessage,mSite);
           end;
      end;
   end;
   if Index=2 then begin
     mOpenDlg := TOpenDialog.Create(Sender);
     mOpenDlg.Filter:= 'Produktový list v pdf|*.pdf';
      if mOpenDlg.Execute then begin
        mOrigFile:=mOpenDlg.FileName;
        mFileName:=mOpenDlg.FileName;
        mFileName:=Copy(mFileName,NxCharPosR('\',mFileName)+1,300);
        mFileName:=TEncoding.RemoveDiacritics(mFileName);
        mFileName:=NxSearchReplace(mFileName,' ','_',[srAll]);
        mFileName:='KT_'+mbo.GetFieldValueAsString('Code')+'_'+mFileName;
        if not(DirectoryExists(cMainDir2+'\'+mBO.oid)) then CreateDir(cMainDir2+'\'+mBO.oid);
            NxCopyFile(mOrigFile,cMainDir2+'\'+mBO.oid+'\'+mFileName);
            mbo.SetFieldValueAsString('X_Product_Sheet_Filename',mFileName);
            mbo.SetFieldValueAsString('X_Product_Sheet_name','Produktový list');
            try
             mFTP:= TFTP.Create;
             mFTP.Host:=cURL;
             mftp.UserName:=cLogin;
             mFTP.Password:=cPass;
             mftp.Connect;
             mFTP.Passive:=true;
             mFtp.ChangeDir('prilohy');
             mFTP.TransferType:=ftBinary;
             mftp.Put(mOrigFile,mfileName);
             mFTP.Free;
           except
             NxShowSimpleMessage(ExceptionMessage,mSite);
           end;
      end;
   end;
      if Index=3 then begin
         mFileName:=mBO.GetFieldValueAsString('X_navod_filename');
         mbo.SetFieldValueAsString('X_navod_filename','');
         mbo.SetFieldValueAsString('X_navod_name','');
         if FileExists(cMainDir2+'\'+mbo.OID+'\'+mFileName) then begin
            DeleteFile(cMainDir2+'\'+mbo.OID+'\'+mFileName);
           try
             mFTP:= TFTP.Create;
             mFTP.Host:=cUrl;
             mftp.UserName:=cLogin;
             mFTP.Password:=cPass;
             mftp.Connect;
             mftp.ChangeDir('prilohy');
             mftp.Delete(mFileName);
             mFTP.free;
           except
           end;
         end;
      end;
      if Index=4 then begin
         mbo.SetFieldValueAsString('X_Certificate_filename','');
         mbo.SetFieldValueAsString('X_Certificate_name','');
      end;
      if Index=5 then begin
         mbo.SetFieldValueAsString('X_Product_Sheet_Filename','');
         mbo.SetFieldValueAsString('X_Product_Sheet_name','');
      end;
   mbo.save;
   TBusRollSiteForm(mSite).RefreshData;
   if index in [0,1,2] then NxShowSimpleMessage('Soubor byl přidán',msite);
   if index in [3,4,5] then NxShowSimpleMessage('Soubor byl odebrán',msite);
 end;
end;

begin
end.