procedure UploadPic(OS: TNxCustomObjectSpace; var Success: Boolean; var LogInfoStr: String);
var
 mList:tstringlist;
 mFileStream: TFileStream;
 mFieldValue: TNxParameters;
 mFieldName, mRes: TStringList;
 mPictureID, mSQL, mS, mCode, mFileName,mPicture_ID: string;
 mSCBO, mBO: TNxCustomBusinessObject;
 mFTP:TFTP;
 i, j,k: Integer;
begin
     mList:=tstringlist.Create;
     os.SQLSelect('select distinct sc.id from storecards sc '+
                  'left join storeprices sp on sp.storecard_id=sc.id '+
                  'left join storeprices2 sp2 on sp.id=sp2.parent_id '+
                  'where sc.picture_id is not null and sc.hidden=''N'' and sp2.amount>0 and sp.pricelist_id=''1000000101'' and sc.storemenuitem_id in '+
      '(''6000000101'',''4000000101'',''1200000101'',''5000000101'',''1400000101'',''7000000101'', '+
      ' ''2AB0000101'',''3AB0000101'',''4AB0000101'',''1AB0000101'',''9000000101'',''A000000101'', '+
      ' ''B000000101'',''C000000101'',''E000000101'',''X000000101'',''EAB0000101'',''Y000000101'', '+
      ' ''GAB0000101'',''Z000000101'',''FAB0000101'') ',mList);
     if mlist.count>0 then begin
      for i:=0 to mlist.count-1 do begin
          mSCBO:=OS.CreateObject(Class_StoreCard);
          mSCBO.Load(mlist.strings[i],nil);
          mCode:=mscbo.GetFieldValueAsString('Code');
          if not(NxIsEmptyOID(mSCBO.GetFieldValueAsString('Picture_ID'))) then begin


          mBO:= OS.CreateObject('S1AUUMOM3REL3C5V00CA141B44');
           try
            mBO.Load(mSCBO.GetFieldValueAsString('Picture_ID'), nil);
            mFileName:=SaveImage(mBO,'F:\tmp\',mCode);
            //CFxInternet.FTPPutFile('getup.savana-hosting.cz','21', 'foto/'+mFileName,'F:\tmp\'+mFileName,'cemat','TJYvMrfFVA9rgdn');
             mFTP:= TFTP.Create;
             mFTP.Host:='getup.savana-hosting.cz';
             //mFTP.Port:=34000;
             mftp.UserName:='cemat';
             mFTP.Password:='TJYvMrfFVA9rgdn';
             mftp.Connect;
             mFTP.Passive:=true;
             mFTP.TransferType:=ftBinary;
             mftp.Put('F:\tmp\'+mFileName,'foto/'+mFileName);
             mFTP.Free;
            mbo.free
          except
            //mBO.Free;
          end;


        end;
    end;
    end;
  Success := True;
  LogInfoStr := '';
end;


function GetImage(aBoPic:TNxCustomBusinessObject;aPicture:TMemoryStream;var aTypeFile:string):Boolean;
var
    mBO: TNxCustomBusinessObject;
    mStr: TMemoryStream;
    mTypeSize: Integer;
    N : Integer;
    x: TReader;
begin
    Result := false;
    mStr := TMemoryStream.Create;
    try
      mStr.SetBytes(aBoPic.GetFieldValueAsBytes('BlobData'));
      mStr.Position := 0;
      if mStr.Size < 4 then Exit;
       x := TReader.Create(mStr, 20);
      try
        x.Read(mTypeSize, 4);
      finally
        x.Free;
      end;
      mStr.Position := 4;
      aPicture.CopyFrom(mStr, mTypeSize);
      aTypeFile := NxReadString(aPicture);
      if UpperCase(aTypeFile) = 'TNXGDIPPICTURE' then
      aTypeFile := 'jpeg'
      else begin
      Delete(aTypeFile,1,1);
      N := Pos('IMAGE',UpperCase(aTypeFile));
      if N >1 then
      aTypeFile := LowerCase(Copy(aTypeFile,1,N-1));
      end;
      aPicture.Clear;
      mStr.Position := 4 + mTypeSize;
      aPicture.CopyFrom(mStr, mStr.Size - mStr.Position);
      Result := true;
    finally
      mStr.Free;
    end;
end;

function SaveImage(aBoPic:TNxCustomBusinessObject;const aDir, aFile : String):String;
var
mPicture:TMemoryStream;
mTypeFile : String;
begin
  Result := '';
  mPicture := TMemoryStream.Create;
  try
   if GetImage(aBoPic,mPicture,mTypeFile) then begin
     mPicture.SaveToFile(adir+'\'+aFile+'.'+mTypeFile);
     Result := aFile+'.'+mTypeFile;
   end;
  finally
   mPicture.Free;
  end;
end;

begin
end.