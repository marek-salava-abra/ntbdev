procedure FormCreate_Hook(Self: TSiteForm);

var
  mAction: TAction;
begin

    mAction := Self.GetNewAction;
    mAction.ShowControl := True;
    mAction.ShowMenuItem := True;
    mAction.Caption := 'DSV EDI';
    mAction.Hint := 'Nahraje data na FTP';
    mAction.Category := 'tabList';
    mAction.OnExecute := @ExportData;
  //end;
end;

procedure ExportData(Sender:Tcomponent);
var
 mSite:TSiteForm;
 mList:TStringList;
 mOS:TNxCustomObjectSpace;
 mFileName, mDestFile, mImageFile,mstorecard_id:String;
 mUnits:TNxCustomBusinessMonikerCollection;
 i:Integer;
 mStoreCardBO:TNxCustomBusinessObject;
 mParams, mParRow : TNxParameters;
 mOpenDlg:TOpenDialog;
 AStream: TMemoryStream;
 mFTP:TFTP;
 mContext:TNxContext;
begin
  mSite:=TComponent(Sender).DynSite;
  mOS:=TDynSiteForm(mSite).CurrentObject.ObjectSpace;
  mList:=TStringList.create;
  TDynSiteForm(mSite).List.GetSelectedId(mList);
  if mList.count>0 then begin
      if NxMessageBox('Dotaz','Přejete si odeslat '+IntToStr(mList.count)+' objednávek?' , mdConfirm, mdbYesNo, 0, 0, False, msite)= mrYes then begin

        mContext := NxCreateContext(mOS);
        mFileName:=FormatDateTime('YYYYMMDDHHmmss',Now)+'.xml';
        mDestFile:=NxGetTempDir+mFileName;
        CFxReportManager.ExportByIDs(mContext,mList,'40V53DORW3DL342X01C0CX3FCC','1720000101',0,'',mDestFile);
        if FileExists(mDestFile) then begin

        mFTP:= TFTP.Create;
        //mFTP.Host:='test.b2b.dsv.net';
        mFTP.Host:='b2b.dsv.net';
        mFTP.Port:=21;
        mftp.UserName:='cus.cemat';
        mFTP.Password:='yeCra64i';
        mftp.Connect;
        mFTP.Passive:=true;
        mFTP.ChangeDir('inbox');
        mFTP.Put(mDestFile,mFileName);
        mftp.free;
        DeleteFile(mDestFile);
        end;
      end;
  end;
end;

begin
end.