uses 'eu.abra.masa.simon.newES.docs.const';

procedure AfterSave_Hook(Self: TNxCustomBusinessObject);
var
 mPictures:TNxCustomBusinessMonikerCollection;
 i:integer;
 mBO, mUser:TNxCustomBusinessObject;
 mFileName, mOrigFile:string;
 mFtp:TFTP;
 mMessage, mExt:string;
begin
 mUser:=self.ObjectSpace.CreateObject(Class_SecurityUser);
 mUser.Load(NxGetActualUserID_1(self),nil);
 if self.GetFieldValueAsBoolean('X_ESCard') and muser.GetFieldValueAsBoolean('U_eshop') then begin
  mPictures:=self.GetLoadedCollectionMonikerForFieldCode(self.GetFieldCode('Pictures'));
  for i:=0 to mPictures.Count-1 do begin
   //if not(mPictures.BusinessObject[i].GetFieldValueAsBoolean('X_AES_Send')) then begin
   //přepsat na ověření zápisu do složky
   if true then begin
     mBO:=self.ObjectSpace.CreateObject(Class_Picture);
     mbo.Load(mPictures.BusinessObject[i].GetFieldValueAsString('Picture_ID'),nil);
     if not(DirectoryExists(cMainDir+'\'+Self.oid)) then CreateDir(cMainDir+'\'+self.oid);
     if not(DirectoryExists(cMainDir+'\'+self.oid+'\pictures')) then CreateDir(cMainDir+'\'+self.oid+'\pictures');
     if FileExists(mbo.GetFieldValueAsString('PathAndFileName')) then begin
           //NxShowSimpleMessage(mbo.GetFieldValueAsString('PathAndFileName'),nil);
           mFileName:=Copy(mbo.GetFieldValueAsString('PathAndFileName'),NxCharPosR('\',mbo.GetFieldValueAsString('PathAndFileName'))+1,300);
           mExt:=Copy(mFileName,NxCharPosR('.',mFileName)+1,10);
           mFileName:=mBO.OID+'.'+mExt;
           NxCopyFile(mbo.GetFieldValueAsString('PathAndFileName'),cMainDir+'\'+self.oid+'\pictures\'+mFileName);
           mOrigFile:=cMainDir+'\'+self.oid+'\pictures\'+mFileName;
           //NxShowSimpleMessage(mbo.GetFieldValueAsString('PictureType'),nil);
           try
             mFTP:= TFTP.Create;
             mFTP.Host:=cURL;
             mftp.UserName:=cLogin;
             mFTP.Password:=cPass;
             mftp.Connect;
             mFTP.Passive:=true;
             mFTP.TransferType:=ftBinary;
             mftp.ChangeDir('original');
             mftp.Put(mOrigFile,mfileName);
             mFTP.Free;
           except
             NxShowSimpleMessage(ExceptionMessage,nil);
           end;
      mbo.SetFieldValueAsString('PathAndFileName',mOrigFile);
      mbo.save;
      end;
      mbo.free;
     end else begin
         mBO:=self.ObjectSpace.CreateObject(Class_Picture);
         mbo.Load(mPictures.BusinessObject[i].GetFieldValueAsString('Picture_ID'),nil);
         if not(DirectoryExists(cMainDir+'\'+Self.oid)) then CreateDir(cMainDir+'\'+self.oid);
         if not(DirectoryExists(cMainDir+'\'+self.oid+'\pictures')) then CreateDir(cMainDir+'\'+self.oid+'\pictures');
         if FileExists(mbo.GetFieldValueAsString('PathAndFileName')) then begin
               mFileName:=Copy(mbo.GetFieldValueAsString('PathAndFileName'),NxCharPosR('\',mbo.GetFieldValueAsString('PathAndFileName'))+1,300);
               NxCopyFile(mbo.GetFieldValueAsString('PathAndFileName'),cMainDir+'\'+self.oid+'\pictures\'+mFileName);
               mOrigFile:=cMainDir+'\'+self.oid+'\pictures\'+mFileName;
         end;
         mbo.SetFieldValueAsString('PathAndFileName',mOrigFile);
         mbo.save;
         mbo.free;
     end;
   end;
  end;
  mUser.Free;
end;

begin
end.