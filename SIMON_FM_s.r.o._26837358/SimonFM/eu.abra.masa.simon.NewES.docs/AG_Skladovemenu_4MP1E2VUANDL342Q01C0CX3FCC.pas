uses '.const';

procedure InitSite_Hook(Self: TSiteForm);
var
  mAction: TMultiAction;
begin
  mAction := Self.GetNewMultiAction;
  mAction.ShowControl := True;
  mAction.ShowMenuItem := True;
  mAction.Caption := 'Přidání obrázku';
  mAction.Items.Add('Přidání obrázku');
  //mAction.Items.Add('Technický list');
  //mAction.Items.Add('Záruční list');
  //mAction.Items.Add('Bezpečnostní list');
  mAction.Hint := 'Import obrazku';
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
begin
 mSite:=TComponent(Sender).BusRollSite;
 mOS:=mSite.BaseObjectSpace;
 mBO:=TBusRollSiteForm(mSite).CurrentObject;
 if Assigned(mBO) then begin
   if Index=0 then begin
     mOpenDlg := TOpenDialog.Create(Sender);
     mOpenDlg.Filter:= 'Obrázek k menu|*.jpg; *.jpeg; *.png';
      if mOpenDlg.Execute then begin
        mOrigFile:=mOpenDlg.FileName;
        mFileName:=mOpenDlg.FileName;
        mFileName:=Copy(mFileName,NxCharPosR('\',mFileName)+1,300);
        if not(DirectoryExists(cMainDir2+'\'+mBO.oid)) then CreateDir(cMainDir+'\'+mBO.oid);
        if not(DirectoryExists(cMainDir2+'\'+mBO.oid+'\menu')) then CreateDir(cMainDir+'\'+mBO.oid+'\menu');
            NxCopyFile(mOrigFile,cMainDir+'\'+mBO.oid+'\menu\'+mFileName);
            mbo.SetFieldValueAsString('X_ESPicture',mFileName);
            try
             mFTP:= TFTP.Create;
             mFTP.Host:=cURL;
             mftp.UserName:=cLogin;
             mFTP.Password:=cPass;
             mftp.Connect;
             mFTP.Passive:=true;
             mFtp.ChangeDir('menu');
             {try
              mFtp.MakeDir(mBO.OID);
             except

             end;
             mftp.ChangeDir(mBO.OID); }
             mFTP.TransferType:=ftBinary;
             mftp.Put(mOrigFile,mfileName);
             mFTP.Free;
           except
             NxShowSimpleMessage(ExceptionMessage,mSite);
           end;
      end;
   end;
   mbo.save;
  end;
end;

begin
end.