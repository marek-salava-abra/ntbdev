procedure InitSite_Hook(Self: TSiteForm);
var
  mAction: TBasicAction;
begin
  mAction := Self.GetNewAction;
  mAction.ShowControl := True;
  mAction.ShowMenuItem := True;
  mAction.Caption := '##Doplnění obrázků##';
  mAction.Hint := 'Převede do fotek';
  mAction.Category := 'tabList';
  mAction.OnExecute := @CreateAndAddPic;
end;


Procedure CreateAndAddPic(Sender:tcomponent);
var
 mSite:TSiteForm;
 mOS:TNxCustomObjectSpace;
 mSelectedList, mFileList:TStringList;
 i,j,k,l,m:integer;
 mBO, mPictureBO:TNxCustomBusinessObject;
 mDirectory:string;
begin
 mSite:=TComponent(Sender).BusRollSite;
 mOS:=msite.BaseObjectSpace;
 mSelectedList:=TStringList.create;
 TBusRollSiteForm(mSite).List.GetSelectedId(mSelectedList);
 if mSelectedList.count>0 then begin
   if NxMessageBox('Dotaz', 'Doplnit obrázky u '+IntToStr(mSelectedList.Count)+' skladových menu?', mdConfirm, mdbYesNo, 2, 0, False, nil) = mrYes then begin
     try
       k:=mSelectedList.count;
       WaitWin.StartProgress('Čekejte, prosím ...', '', k);
       for i:=0 to mSelectedList.count-1 do begin
         mBO:=mOS.CreateObject(Class_StoreMenuItem);
         mBO.Load(mSelectedList.strings[i],nil);
         mDirectory:=mbo.GetFieldValueAsString('X_ImagesPath');
         if not(AnsiRightStr(mDirectory,1)='\') then mDirectory:=mDirectory+'\';
         if DirectoryExists(mDirectory)  then begin
           mFileList:=TStringList.Create;
           NxGetFileList(mDirectory,mFileList,'*.*');
           if mFileList.count>0 then begin
             for j:=0 to mFileList.count-1 do begin
               if (AnsiUpperCase(ExtractFileExt(mFileList.Strings[j]))='.JPG') or
                 (AnsiUpperCase(ExtractFileExt(mFileList.Strings[j]))='.JPEG') or
                 (AnsiUpperCase(ExtractFileExt(mFileList.Strings[j]))='.TIFF') or
                 (AnsiUpperCase(ExtractFileExt(mFileList.Strings[j]))='.PNG') or
                 (AnsiUpperCase(ExtractFileExt(mFileList.Strings[j]))='.BMP') or
                 (AnsiUpperCase(ExtractFileExt(mFileList.Strings[j]))='.TIF')
                 then begin
                   if FileExists(mDirectory+mFileList.Strings[j]) then begin
                     if NxIsEmptyOID(mbo.GetFieldValueAsString('X_Picture_ID')) then begin
                      mPictureBO:=mOS.CreateObject(Class_Picture);
                      mPictureBO.new;
                      mPictureBO.SetFieldValueAsString('PictureTitle',mBO.GetFieldValueAsString('Text'));
                      mPictureBO.SetFieldValueAsBoolean('ExternalFile',true);
                      mPictureBO.SetFieldValueAsString('PathAndFileName',mDirectory+mFileList.Strings[j]);
                      mPictureBO.save;
                      mbo.SetFieldValueAsString('X_Picture_ID',mPictureBO.OID);
                      mPictureBO.free;
                     end;
                   end;
               end;
             end;
           end;
         end;
         mbo.save;
         mbo.free;
         WaitWin.ChangeText(IntToStr(i+1) + ' / ' + IntToStr(k));
         WaitWin.StepIt;
       end;
       WaitWin.Stop;
     except
       NxShowSimpleMessage('Něco se nepovedlo:'+#13#10+ExceptionMessage,mSite);
       WaitWin.Stop;
     end;
   end;
 end;
end;

begin
end.