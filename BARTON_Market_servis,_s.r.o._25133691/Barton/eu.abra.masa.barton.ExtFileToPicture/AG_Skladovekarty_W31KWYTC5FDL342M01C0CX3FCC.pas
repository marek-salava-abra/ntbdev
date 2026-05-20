procedure InitSite_Hook(Self: TSiteForm);
var
  mAction: TBasicAction;
begin
  mAction := Self.GetNewAction;
  mAction.ShowControl := True;
  mAction.ShowMenuItem := True;
  mAction.Caption := '##Převod obrázků do FOTO##';
  mAction.Hint := 'Převede do fotek';
  mAction.Category := 'tabList';
  mAction.OnExecute := @CreatePicInCollection;
end;

Procedure CreatePicInCollection(Sender:tcomponent);
var
 mSite:TSiteForm;
 mOS:TNxCustomObjectSpace;
 mSelectedList, mFileList:TStringList;
 i,j,k,l,m:integer;
 mBO, mPictureBO:TNxCustomBusinessObject;
 mPictures:TNxCustomBusinessMonikerCollection;
 mDirectory:string;
 mAddPicture:Boolean;
begin
 mSite:=TComponent(Sender).BusRollSite;
 mOS:=msite.BaseObjectSpace;
 mSelectedList:=TStringList.create;
 TBusRollSiteForm(mSite).List.GetSelectedId(mSelectedList);
 if mSelectedList.count>0 then begin
   if NxMessageBox('Dotaz', 'Doplnit obrázky do kolekce fotek u '+IntToStr(mSelectedList.Count)+' skladových karet?', mdConfirm, mdbYesNo, 2, 0, False, nil) = mrYes then begin
     try
       k:=mSelectedList.count;
       WaitWin.StartProgress('Čekejte, prosím ...', '', k);
       for i:=0 to k-1 do begin
         mBO:=mOS.CreateObject(Class_StoreCard);
         mBO.Load(mSelectedList.strings[i],nil);
         mDirectory:=mbo.GetFieldValueAsString('X_ImagesPath');
         if not(AnsiRightStr(mDirectory,1)='\') then mDirectory:=mDirectory+'\';
         if DirectoryExists(mDirectory) then begin
           mPictures:=mBO.GetLoadedCollectionMonikerForFieldCode(mbo.GetFieldCode('Pictures'));
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
                     if mPictures.count>0 then begin
                      mAddPicture:=True;
                      for m:=0 to mPictures.count-1 do begin
                        mPictureBO:=mPictures.BusinessObject[m];
                        if mPictureBO.GetFieldValueAsString('Picture_ID.PathAndFileName')=mDirectory+mFileList.Strings[j] then mAddPicture:=false;
                      end;
                      if mAddPicture then begin
                       mPictureBO:=mPictures.AddNewObject;
                       mPictureBO.SetFieldValueAsString('Picture_ID.PictureTitle',mBO.GetFieldValueAsString('Name'));
                       mPictureBO.SetFieldValueAsBoolean('Picture_ID.ExternalFile',true);
                       mPictureBO.SetFieldValueAsString('Picture_ID.PathAndFileName',mDirectory+mFileList.Strings[j]);
                      end;
                     end else begin
                       mPictureBO:=mPictures.AddNewObject;
                       mPictureBO.SetFieldValueAsString('Picture_ID.PictureTitle',mBO.GetFieldValueAsString('Name'));
                       mPictureBO.SetFieldValueAsBoolean('Picture_ID.ExternalFile',true);
                       mPictureBO.SetFieldValueAsString('Picture_ID.PathAndFileName',mDirectory+mFileList.Strings[j]);
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