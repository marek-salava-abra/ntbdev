procedure ExportData (OS: TNxCustomObjectSpace; var Success: Boolean; var LogInfoStr: String);
var
  mIDsList, mOutputList: TStringList;
  mSQL,mExportID, mDynSource, mFileName: String;
  mExportID1, mExportID2,mExportID3, mFileName1, mFileName2, mFileName3, mFileName6, mExportID6 : STring;
  mSQL1, mExportID4, mExportID5, mFileName4, mFilename5,mFileName8, mDynSource1, mDynSource2, mDynSource3, mSQL2: String;
  mContext: TNxContext;
  mFileName7, mExportID7, mExportID8: String;
  mFileName9, mExportID9, mSQL3, mDynSource4, mfilename10,mExportID10, mSQL4, mDynSource5: String;
begin
  Success := True;
  LogInfoStr := '';
  mSQL:='Select id from storemenu where hidden= ''N'' ';
  mSQL1:='Select id from storecards where x_eshop=''A'' and hidden= ''N'' ';
  mSQL2:='Select id from storecards where x_eshop=''A'' and hidden= ''N'' ';
  mFileName:='C:\Program Files (x86)\Apache Software Foundation\Apache2.2\htdocs\D\storemenu.xml';
  mFileName1:='C:\Program Files (x86)\Apache Software Foundation\Apache2.2\htdocs\D\StoreCards.xml';
  mFileName2:='C:\Program Files (x86)\Apache Software Foundation\Apache2.2\htdocs\D\StoreCardsQuantity.xml';
  mExportID:='5C00000101';
  mExportID1:='6C00000101';
  mExportID2:='7C00000101';
  mDynSource:='C1PBCWYCQVDL342W01C0CX3FCC';
  mDynSource1:='OGQQA2C25JDL342N01C0CX3FCC';
  mDynSource2:='OGQQA2C25JDL342N01C0CX3FCC';
  if FileExists(mFileName) then DeleteFile(mFileName);
  mIDsList:=TStringList.Create;
  mContext:=NxCreateContext(OS);
  OS.SQLSelect(mSQL, mIDsList);
  NxExportbyIDs(mContext,mIDsList,mDynSource,mExportID,0,'',mFileName);
  mIDsList.Clear;
  if FileExists(mFileName1) then DeleteFile(mFileName1);
  OS.SQLSelect(mSQL1, mIDsList);
  NxExportbyIDs(mContext,mIDsList,mDynSource1,mExportID1,0,'',mFileName1);
  mIDsList.Clear;
  if FileExists(mFileName2) then DeleteFile(mFileName2);
  OS.SQLSelect(mSQL2, mIDsList);
  NxExportbyIDs(mContext,mIDsList,mDynSource2,mExportID2,0,'',mFileName2);
  mIDsList.Clear;
  mIDsList.Free;

end;

procedure ExportPictures (OS: TNxCustomObjectSpace; var Success: Boolean; var LogInfoStr: String);
var
mFileStream: TFileStream;
  mFieldValue: TNxParameters;
  mFieldName, mRes: TStringList;
  mPictureID, mSQL, mS, mExt: string;
  mBO: TNxCustomBusinessObject;
  p1, p2: Pointer;
  j,k: Integer;
  mFTP:TFTP;
  mFileName:String;
begin
  if DirectoryExists(NxGetTempDir) then begin
  //Result:= '';
  begin
     mSQL:= 'select a.picture_id from storecardpictures A where a.parent_id in (select id from storecards where  (correctedat$date>=%s or createdat$date>=%s))';
     mSQL:=Format(mSQL,[inttostr(trunc(date)),Inttostr(Trunc(Date))]);


  end;
  mRes:= TStringList.Create;
  mPictureID:= '0000000000';
  try
    OS.SQLSelect(mSQl, mRes);
    if mRes.Count > 0 then
      begin

      for k:=0 to mres.count -1 do begin

      mPictureID:= mRes[k];

      mFieldValue:= TNxParameters.Create;
      mFieldName:= TStringList.Create;
      try
    mFieldName.Text:= 'BlobData';
    mBO:= OS.CreateObject('S1AUUMOM3REL3C5V00CA141B44');
    try
      mBO.Load(mPictureID, nil);
      mBO.GetFields(mFieldName, mFieldValue);
      mBO.GetFieldValues(mFieldValue);
      mS:= mFieldValue.Params[0].AsString;
      if Length(mS) > 4 then
      begin
        //ShowDebugMessage('Create image file ' + aEmployees_ID);
        p1:= @J;
        p2:= @mS;
        move(p2, p1, 4);
        mExt:= Copy(mS, 5, j);
        mFileName:= 'C:\SERVER\ABRA\AbraG2\htdocs\img\'+mPictureID+ '.jpg';
        mFileStream:= TFileStream.Create(mFileName, fmCreate, 0);
        try
          NxWriteString(mFileStream, Copy(mS, 5 + j, Length(mS)));
        finally
         mFileStream.Free;

        end;
      end;
    finally
      mBO.Free;
    end;
  finally
    mFieldName.Free;
    mFieldValue.Free;

 end;
   end;


      End;
  finally
    LogInfoStr:='Nahráno '+IntToStr(mres.count)+' obrázků';
    mRes.Free;
  end;
  if NxIsEmptyOID(mPictureID) then
  begin
    //ShowDebugMessage('Err: ' + mSQL);
    Exit;
  end;
 end;
end;

function GetExtension(mExt: string): string;
  begin
    if mExt = 'TNxGDIPPicture' then Result:='jpg';
    if mExt = 'TJPEGImage' then
      Result:= 'jpg';
  end;

begin
end.