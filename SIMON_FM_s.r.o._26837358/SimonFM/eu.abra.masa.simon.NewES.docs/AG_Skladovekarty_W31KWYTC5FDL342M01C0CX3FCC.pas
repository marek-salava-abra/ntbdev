uses '.const';

procedure InitSite_Hook(Self: TSiteForm);
var
  mAction: TMultiAction;
begin
  mAction := Self.GetNewMultiAction;
  mAction.ShowControl := True;
  mAction.ShowMenuItem := True;
  mAction.Caption := 'Dokumenty';
  mAction.Items.Add('Návod k obsluze');
  mAction.Items.Add('Technický list');
  mAction.Items.Add('Záruční list');
  mAction.Items.Add('Bezpečnostní list');
  mAction.Items.Add('Odebrat - Návod k obsluze');
  mAction.Items.Add('Odebrat - Technický list');
  mAction.Items.Add('Odebrat - Záruční list');
  mAction.Items.Add('Odebrat - Bezpečnostní list');
  mAction.Hint := 'Připojení dokumentu';
  mAction.Category := 'tabDetail';
  mAction.OnExecuteItem := @CreateDoc;
end;

procedure CreateDoc (Sender:TComponent;Index:integer);
var
 mSite:TSiteForm;
 mOS:TNxCustomObjectSpace;
 mOpenDlg:TOpenDialog;
 mBO:TNxCustomBusinessObject;
 mFileName, mOrigFile:string;
 mFtp:TFTP;
 mMessage:string;
 mList:TStringList;
 mFileAdded:Boolean;
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
        mFileAdded:=False;
        if FileExists(mFileName) then begin
          mFileName:=Copy(mFileName,NxCharPosR('\',mFileName)+1,300);
          if not(DirectoryExists(cMainDir+'\'+mBO.oid)) then CreateDir(cMainDir+'\'+mBO.oid);
          if not(DirectoryExists(cMainDir+'\'+mBO.oid+'\navod')) then CreateDir(cMainDir+'\'+mBO.oid+'\navod');
              NxCopyFile(mOrigFile,cMainDir+'\'+mBO.oid+'\navod\'+mFileName);
              mbo.SetFieldValueAsString('X_navod_filename',mFileName);
              mbo.SetFieldValueAsString('X_navod_name','Návod');
              try
               mFTP:= TFTP.Create;
               mFTP.Host:=cURL;
               mftp.UserName:=cLogin;
               mFTP.Password:=cPass;
               mftp.Connect;
               mFTP.Passive:=true;
               mFtp.ChangeDir('prilohy');
               {try
                mFtp.MakeDir(mBO.OID);
               except

               end;
               mftp.ChangeDir(mBO.OID); }
               mFTP.TransferType:=ftBinary;
               mftp.Put(mOrigFile,mfileName);
               mFTP.Free;
               mFileAdded:=True;
             except
               NxShowSimpleMessage(ExceptionMessage,mSite);
               mFileAdded:=False;
               mbo.SetFieldValueAsString('X_navod_filename','');
               mbo.SetFieldValueAsString('X_navod_name','');
             end;
          end;
      end;
   end;
   if Index=1 then begin
     mOpenDlg := TOpenDialog.Create(Sender);
     mOpenDlg.Filter:= 'Technický list v pdf|*.pdf';
      if mOpenDlg.Execute then begin
        mOrigFile:=mOpenDlg.FileName;
        mFileName:=mOpenDlg.FileName;
        mFileAdded:=False;
        if FileExists(mFileName) then begin
            mFileName:=Copy(mFileName,NxCharPosR('\',mFileName)+1,300);
            if not(DirectoryExists(cMainDir+'\'+mBO.oid)) then CreateDir(cMainDir+'\'+mBO.oid);
            if not(DirectoryExists(cMainDir+'\'+mBO.oid+'\tech_list')) then CreateDir(cMainDir+'\'+mBO.oid+'\tech_list');
                NxCopyFile(mOrigFile,cMainDir+'\'+mBO.oid+'\tech_list\'+mFileName);
                mbo.SetFieldValueAsString('X_tech_list_filename',mFileName);
                mbo.SetFieldValueAsString('X_tech_list_name','Technický list');
                try
                 mFTP:= TFTP.Create;
                 mFTP.Host:=cURL;
                 mftp.UserName:=cLogin;
                 mFTP.Password:=cPass;
                 mftp.Connect;
                 mFTP.Passive:=true;
                 mFtp.ChangeDir('prilohy');
                 {try
                  mFtp.MakeDir(mBO.OID);
                 except

                 end;
                 mftp.ChangeDir(mBO.OID); }
                 mFTP.TransferType:=ftBinary;
                 mftp.Put(mOrigFile,mfileName);
                 mFTP.Free;
                 mFileAdded:=true;
               except
                 NxShowSimpleMessage(ExceptionMessage,mSite);
                 mFileAdded:=false;
                 mbo.SetFieldValueAsString('X_tech_list_filename','');
                 mbo.SetFieldValueAsString('X_tech_list_name','');
               end;
           end;
      end;
   end;
   if Index=2 then begin
     mOpenDlg := TOpenDialog.Create(Sender);
     mOpenDlg.Filter:= 'Záruční list v pdf|*.pdf';
      if mOpenDlg.Execute then begin
        mOrigFile:=mOpenDlg.FileName;
        mFileName:=mOpenDlg.FileName;
        mFileAdded:=False;
        if FileExists(mFileName) then begin

            mFileName:=Copy(mFileName,NxCharPosR('\',mFileName)+1,300);
            if not(DirectoryExists(cMainDir+'\'+mBO.oid)) then CreateDir(cMainDir+'\'+mBO.oid);
            if not(DirectoryExists(cMainDir+'\'+mBO.oid+'\zar_list')) then CreateDir(cMainDir+'\'+mBO.oid+'\zar_list');
                NxCopyFile(mOrigFile,cMainDir+'\'+mBO.oid+'\zar_list\'+mFileName);
                mbo.SetFieldValueAsString('X_zar_list_filename',mFileName);
                mbo.SetFieldValueAsString('X_zar_list_name','Záruční list');
                try
                 mFTP:= TFTP.Create;
                 mFTP.Host:=cURL;
                 mftp.UserName:=cLogin;
                 mFTP.Password:=cPass;
                 mftp.Connect;
                 mFTP.Passive:=true;
                 mFtp.ChangeDir('prilohy');
                 {try
                  mFtp.MakeDir(mBO.OID);
                 except

                 end;
                 mftp.ChangeDir(mBO.OID); }
                 mFTP.TransferType:=ftBinary;
                 mftp.Put(mOrigFile,mfileName);
                 mFTP.Free;
                 mFileAdded:=True;
               except
                 NxShowSimpleMessage(ExceptionMessage,mSite);
                 mFileAdded:=False;
                 mbo.SetFieldValueAsString('X_zar_list_filename','');
                 mbo.SetFieldValueAsString('X_zar_list_name','');
               end;
          end;
      end;
   end;
   if Index=3 then begin
     mOpenDlg := TOpenDialog.Create(Sender);
     mOpenDlg.Filter:= 'Bezpečnostní list v pdf|*.pdf';
      if mOpenDlg.Execute then begin
        mOrigFile:=mOpenDlg.FileName;
        mFileName:=mOpenDlg.FileName;
        mFileAdded:=False;
        if FileExists(mFileName) then begin

          mFileName:=Copy(mFileName,NxCharPosR('\',mFileName)+1,300);
          if not(DirectoryExists(cMainDir+'\'+mBO.oid)) then CreateDir(cMainDir+'\'+mBO.oid);
          if not(DirectoryExists(cMainDir+'\'+mBO.oid+'\bez_list')) then CreateDir(cMainDir+'\'+mBO.oid+'\bez_list');
              NxCopyFile(mOrigFile,cMainDir+'\'+mBO.oid+'\bez_list\'+mFileName);
              mbo.SetFieldValueAsString('X_bez_list_filename',mFileName);
              mbo.SetFieldValueAsString('X_bez_list_name','Bezpečnostní list');
              try
               mFTP:= TFTP.Create;
               mFTP.Host:=cURL;
               mftp.UserName:=cLogin;
               mFTP.Password:=cPass;
               mftp.Connect;
               mFTP.Passive:=true;
               mFtp.ChangeDir('prilohy');
               {try
                mFtp.MakeDir(mBO.OID);
               except

               end;
               mftp.ChangeDir(mBO.OID);  }
               mFTP.TransferType:=ftBinary;
               mftp.Put(mOrigFile,mfileName);
               mFTP.Free;
               mFileAdded:=true;
             except
               NxShowSimpleMessage(ExceptionMessage,mSite);
               mFileAdded:=False;
               mbo.SetFieldValueAsString('X_bez_list_filename','');
               mbo.SetFieldValueAsString('X_bez_list_name','');
             end;

         end;
      end;
   end;
      if Index=4 then begin
         mbo.SetFieldValueAsString('X_navod_filename','');
         mbo.SetFieldValueAsString('X_navod_name','');
      end;
      if Index=5 then begin
         mbo.SetFieldValueAsString('X_tech_list_filename','');
         mbo.SetFieldValueAsString('X_tech_list_name','');
      end;
      if Index=6 then begin
         mbo.SetFieldValueAsString('X_zar_list_filename','');
         mbo.SetFieldValueAsString('X_zar_list_name','');
      end;
      if Index=7 then begin
         mbo.SetFieldValueAsString('X_bez_list_filename','');
         mbo.SetFieldValueAsString('X_bez_list_name','');
      end;
   mbo.save;
   TBusRollSiteForm(mSite).RefreshData;
   if (index in [0,1,2,3]) then begin
     if mFileAdded then NxShowSimpleMessage('Soubor byl přidán',msite)
      else NxShowSimpleMessage('Soubor nebyl přidán',msite);
   end;
   if index in [4,5,6,7] then NxShowSimpleMessage('Soubor byl odebrán',msite);
 end;
end;

begin
end.