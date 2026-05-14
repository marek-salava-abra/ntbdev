uses '.consts';

procedure AfterDelete_Hook(Self: TNxCustomBusinessObject);
var
 mFileName, mDir:string;
 mFTP:TFTP;
begin
  if self.GetFieldValueAsBoolean('Firm_ID.X_B2B') then begin
   mFileName:=NxSearchReplace(self.DisplayName,'/','-',[srAll])+'.pdf';
   mDir:=self.GetFieldValueAsString('Firm_ID.OrgIdentNumber');
    try
             mFTP:= TFTP.Create;
             mFTP.Host:=cUrl;
             mftp.UserName:=cLogin;
             mFTP.Password:=cPass;
             mftp.Connect;
             mFTP.Passive:=true;

             try
              mFtp.MakeDir(mdir);
             except

             end;
             mftp.ChangeDir(mdir);
             try
              mFtp.MakeDir('dobropisy');
             except

             end;
             mftp.ChangeDir('dobropisy');
             mftp.Delete(mFileName);
             mFTP.free;
     except
       if CFxNxRuntime.NxGetEnvironmentType=reRuntimeExe then
        NxShowSimpleMessage('Něco se nepovedlo:'+#13#10+ExceptionMessage,nil);
     end;
  end;
end;

begin
end.