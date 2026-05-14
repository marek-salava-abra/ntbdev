const
 cMainDir = '\\10.0.0.15\abra_images';
 cMainDir2 = '\\10.0.0.15\abra_images';
 cURL = 'server.eline.cz';
 cPass = 'xqUogyHQC8_8';
 cLogin = 'elinewebabra';

{
Vyvolává se po uložení vlastních dat objektu do databáze.
}
procedure AfterSave_Hook(Self: TNxCustomBusinessObject);
var
 mBO:TNxCustomBusinessObject;
 mFTP:TFTP;
 mFileName, mExt, mOrigFile:string;
 mMenu1, mMenu2, mMenu3, mMenu4, mfullPath, mOrder:string;
 mPosindex1, mPosindex2,mPosindex3, mPosindex4:integer;
begin
  if not(NxIsEmptyOID(self.GetFieldValueAsString('X_Picture_ID'))) then begin
     mBO:=self.ObjectSpace.CreateObject(Class_Picture);
     mbo.Load(self.GetFieldValueAsString('X_Picture_ID'),nil);
     if FileExists(mbo.GetFieldValueAsString('PathAndFileName')) then begin
           mFileName:=Copy(mbo.GetFieldValueAsString('PathAndFileName'),NxCharPosR('\',mbo.GetFieldValueAsString('PathAndFileName'))+1,300);
           mExt:=Copy(mFileName,NxCharPosR('.',mFileName)+1,10);
           //mFileName:='KT_'+mBO.OID+'.'+mExt;
           //NxCopyFile(mbo.GetFieldValueAsString('PathAndFileName'),cMainDir+'\'+mFileName);
           mOrigFile:=mbo.GetFieldValueAsString('PathAndFileName');
           //NxShowSimpleMessage(mbo.GetFieldValueAsString('PictureType'),nil);
           try
             mFTP:= TFTP.Create;
             mFTP.Host:=cURL;
             mftp.UserName:=cLogin;
             mFTP.Password:=cPass;
             mftp.Connect;
             mFTP.Passive:=true;
             mFTP.TransferType:=ftBinary;
             mftp.ChangeDir('kingtony_menu');
             mftp.Put(mOrigFile,mfileName);
             mFTP.Free;
           except
             NxShowSimpleMessage(ExceptionMessage,nil);
           end;
      end;
      mbo.free;
  end;
  mfullPath:=self.GetFieldValueAsString('FullPath');
  mMenu1:=NxTrapStr(mfullPath,'\');
  mMenu2:=NxTrapStr(mfullPath,'\');
  mMenu3:=NxTrapStr(mfullPath,'\');
  mMenu4:=NxTrapStr(mfullPath,'\');
  mPosindex1:=self.ObjectSpace.SQLSelectFirstAsInteger('Select posindex from storemenu where text='+QuotedStr(mMenu1)+' and hidden=''N'' ',0);
  mPosindex2:=self.ObjectSpace.SQLSelectFirstAsInteger('Select posindex from storemenu where text='+QuotedStr(mMenu2)+' and hidden=''N'' ',0);
  mPosindex3:=self.ObjectSpace.SQLSelectFirstAsInteger('Select posindex from storemenu where text='+QuotedStr(mMenu3)+' and hidden=''N'' ',0);
  mPosindex4:=self.ObjectSpace.SQLSelectFirstAsInteger('Select posindex from storemenu where text='+QuotedStr(mMenu4)+' and hidden=''N'' ',0);
  mOrder:=AnsiRightStr('0'+IntToStr(mPosindex1),2)+AnsiRightStr('0'+IntToStr(mPosindex2),2)+AnsiRightStr('0'+IntToStr(mPosindex3),2)+AnsiRightStr('0'+IntToStr(mPosindex4),2);
  self.ObjectSpace.SQLExecute('Update storemenu set X_order='+QuotedStr(mOrder)+' where id='+QuotedStr(self.OID));
end;


begin
end.