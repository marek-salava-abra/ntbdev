procedure Generate(OS: TNxCustomObjectSpace; var Success: Boolean; var LogInfoStr: String);
var
 mList, mPictureList:TStringList;
 i,j:integer;
 mFileName, mExtension, mS, mPicture_ID, mPosIndex, mPictureTitle, mURL:string;
 mFieldValue: TNxParameters;
 mFieldName: TStringList;
 mBO, mSCPicBO:TNxCustomBusinessObject;
 p1, p2: Pointer;
 mFileStream:TFileStream;
begin
  mURL:='C:\AbraG3\_Cemat_feed\Images\';
  mList:=TStringList.Create;
  OS.SQLSelect('Select id from storecards where Hidden=''N'' and X_XMLFeed=''A'' ',mList);
  if mList.Count>0 then begin
    mFileName:=mURL+'feed.xml';
    cfxReportManager.ExportByIDs(NxCreateContext(OS),mList,'OGQQA2C25JDL342N01C0CX3FCC','27N0000101',0,'',mFileName);
    for i:=0 to mList.count-1 do begin
      mPictureList:=TStringList.Create;
      OS.SQLSelect('Select ID from storecardpictures where parent_id='+QuotedStr(mList.Strings[i]),mPictureList);
      if mPictureList.Count>0 then begin
        for j:=0 to mPictureList.count-1 do begin
          mSCPicBO:=OS.CreateObject(Class_StoreCardPicture);
          mSCPicBO.Load(mPictureList.Strings[j],nil);
          mPicture_ID:=mSCPicBO.GetFieldValueAsString('Picture_ID');
          mPosIndex:=inttostr(mSCPicBO.GetFieldValueAsInteger('PosIndex'));
              mBO:=OS.CreateObject(Class_Picture);
              mBO.Load(mPicture_ID,nil);
              mPictureTitle:=NxSearchReplace(NxSearchReplace(NxSearchReplace(mbo.GetFieldValueAsString('PictureTitle'),' ','_',[srAll]),'\','_',[srAll]),'/','_',[srAll])+'_'+mPosIndex;
              mFieldValue:= TNxParameters.Create;
              mFieldName:= TStringList.Create;
              mFieldName.Text:= 'BlobData';
              mExtension:=mbo.GetFieldValueAsString('PictureType');
              mBO.GetFields(mFieldName, mFieldValue);
              mBO.GetFieldValues(mFieldValue);
              mS:= mFieldValue.Params[0].AsString;
              if Length(mS) > 4 then begin
                p1:= @J;
                p2:= @mS;
                move(p2, p1, 4);
                try
                  mFileStream:= TFileStream.Create(mURL+mPictureTitle+'.'+mExtension, fmCreate, 0);
                  NxWriteString(mFileStream, Copy(mS, 5 + j, Length(mS)));
                finally
                 mFileStream.Free;
                end;
              end;
        end;
      end;
    end;
  end;
  Success := True;
  LogInfoStr := 'Počet záznamů v listu '+IntToStr(mlist.Count);
end;

procedure Generate2(OS: TNxCustomObjectSpace; var Success: Boolean; var LogInfoStr: String);
var
 mList, mPictureList:TStringList;
 i,j:integer;
 mFileName, mExtension, mS, mPicture_ID, mPosIndex, mPictureTitle, mURL:string;
 mFieldValue: TNxParameters;
 mFieldName: TStringList;
 mBO, mSCPicBO:TNxCustomBusinessObject;
 p1, p2: Pointer;
 mFileStream:TFileStream;
begin
  mURL:='C:\AbraG3\_Cemat_feed\Images\';
  mList:=TStringList.Create;
  OS.SQLSelect('Select StoreCard_id from storeprices where pricelist_id=''1K70000101'' ',mList);
  if mList.Count>0 then begin
    mFileName:=mURL+'PointS.xml';
    cfxReportManager.ExportByIDs(NxCreateContext(OS),mList,'OGQQA2C25JDL342N01C0CX3FCC','17O0000101',0,'',mFileName);

  end;
  Success := True;
  LogInfoStr := 'Počet záznamů v listu '+IntToStr(mlist.Count);
end;

begin
end.