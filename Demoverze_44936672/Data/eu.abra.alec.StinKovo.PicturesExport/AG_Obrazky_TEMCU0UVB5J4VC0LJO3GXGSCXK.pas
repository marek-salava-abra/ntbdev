{
Vyvolává se po provedení inicializace agendy/formuláře. V tento okamžik je již na formuláři dostupný SiteContext.
}

procedure InitSite_Hook(Self: TSiteForm);
var
  mAction: TBasicAction;
begin
  mAction := Self.GetNewAction;
  mAction.Name := 'actExportPictures';
  mAction.Caption := 'Export Obrázků';
  mAction.Category := 'tabList';
  mAction.OnExecute := @exeExportPictures;

  mAction := Self.GetNewAction;
  mAction.Name := 'actImportPictures';
  mAction.Caption := 'Import Obrázků skl. karet';
  mAction.Category := 'tabList';
  mAction.OnExecute := @exeImportPictures;

  mAction := Self.GetNewAction;
  mAction.Name := 'actDeletePictures';
  mAction.Caption := 'Výmaz obrázků krom WEBP';
  mAction.Category := 'tabList';
  mAction.OnExecute := @exeDeletePictures;
end;

procedure exeExportPictures(Sender: TComponent);
var
  mSite : TSiteForm;
  mBO, mSCBO : TNxCustomBusinessObject;
  mPictures: TNxCustomBusinessMonikerCollection;
  mOS : TNxCustomObjectSpace;
  mList, mStoreCardList : TStringList;
  i, j: integer;
  mData : TMemoryStream;
  mTPic: TPicture;
  mDialogue : TFileOpenDialog;
  mPictureTitle, mDirectory, mStoreCardCode, mFileExtension, mSaveToDir : string;
begin
  mSite:= Sender.Site;
  mOS:= mSite.BaseObjectSpace;

  mDialogue := TFileOpenDialog.Create(mSite);
  try
    mDialogue.Options := mDialogue.Options + [fdoPickFolders];
    mDialogue.FileName := 's:\temp\';

    if not mDialogue.Execute then
      Exit;

    mDirectory := mDialogue.FileName;
    if mDirectory[ Length(mDirectory) ] <> '\' then
      mDirectory := mDirectory + '\';
  finally
    mDialogue.Free;
  end;

  mList := TStringList.Create;
  mStoreCardList:= TStringList.Create;

  try
    mOS.SQLSelect(
      ' SELECT DISTINCT SC.ID FROM StoreCards SC '+
      ' JOIN StoreCardPictures SCP ON SCP.Parent_ID = SC.ID '+
      ' WHERE SC.Hidden = ''N''' , mStoreCardList);

    mDirectory:= mDirectory + 'images\storecards\';
    //mBaseDir:= mDirectory;

    for i:= 0 to mStoreCardList.Count -1 do
    begin

      mSCBO:= mOS.CreateObject(Class_StoreCard);
      try
        mSCBO.Load(mStoreCardList[i], nil);
        mStoreCardCode:= mSCBO.GetFieldValueAsString('Code');
        mPictures:= mSCBO.GetLoadedCollectionMonikerForFieldCode(mSCBO.GetFieldCode('Pictures'));
        for j:= 0 to mPictures.Count -1 do
        begin
          mData := TMemoryStream.Create;
          mTPic:= TPicture.Create;

          mBO:= mOS.CreateObject(Class_Picture);
          try
            mBO.Load(mPictures.BusinessObject[j].GetFieldValueAsString('Picture_ID'), nil);

            mPictureTitle := mBO.GetFieldValueAsString('PictureTitle');
            mFileExtension:= mbo.GetFieldValueAsString('pictureType');

            mPictureTitle:= SanitizeFilename(mPictureTitle);
            mStoreCardCode:= SanitizeFilename(mStoreCardCode);

            mData.SetBytes(mBO.GetFieldValueAsBytes('BlobData'));
            mData.Position := 0;

            NxMultiFormatImageLoadFromStream(mData, mTPic);

            mSaveToDir:= mDirectory + mStoreCardCode;
            NxCreateDir(mSaveToDir);

            mTPic.SaveToFile(mSaveToDir + '\' + mPictureTitle + '.' + mFileExtension);
            //Brzda
            //if i >= 10 then exit;

          finally
            mBO.Free;
            mData.Free;
            mTPic.Free;
          end;
        end;
      finally
        mSCBO.Free;
      end;
    end;
  finally
    mStoreCardList.Free;
    mList.Free;
  end;
end;


procedure exeImportPictures(Sender: TComponent);
var
  mSite: TSiteForm;
  mOS: TNxCustomObjectSpace;
  mSCBO, mPICBO: TNxCustomBusinessObject;
  mSCPictures: TNxCustomBusinessMonikerCollection;
  mOpenDialog: TFileOpenDialog;
  mStoreCard_ID, mFileExt, mLog, mDestinationFolder, mDestPath, mSourceStoreCardFolder, mStoreCardCode: String;
  mFolderList, mFileList: TStringList;
  i, j: integer;
begin
  mSite:= Sender.Site;
  mOS:= mSite.BaseObjectSpace;

  mLog:= '';
  mDestPath:= '\\systematiq.cz\CustomersData\STINKOVO_DATA\ABRA-Pictures\images\Skladové karty\';

  mOpenDialog:= TFileOpenDialog.Create(Sender);
  try
    mOpenDialog.Options:= ([fdoPickFolders]);
    mOpenDialog.Filter:= 'All files|*.*';

    if not mOpenDialog.Execute then exit;

    mFolderList:= TStringList.Create;
    try
      //Získám list se všemi složkami
      NxGetFileList(mOpenDialog.FileName, mFolderList, '*.*');
      for i:= 0 to mFolderList.Count -1 do
      begin
        if mFolderList[i] in ['.', '..'] then continue;

        //Pokusím se dohledat ID skladové karty podle názvu složky
        mStoreCard_ID:= GetStoreCardIDBySanitizedCode(mOS, mFolderList[i]);
        if NxIsEmptyOID(mStoreCard_ID) then
        begin
          mLog:= mLog + Format('%s - Nepodařilo se dohledat ID skladové karty', [mFolderList[i]]) + nxCrLf;
          continue;
        end;

        mFileList:= TStringList.Create;
        try
          mSCBO:= mOS.CreateObject(Class_StoreCard);
          try
            mSCBO.Load(mStoreCard_ID, nil);
            mStoreCardCode:= mSCBO.GetFieldValueAsString('Code');
            mSCPictures:= mSCBO.GetLoadedCollectionMonikerForFieldCode(mSCBO.GetFieldCode('Pictures'));

            //Získám list se všemi soubory / obrázky
            mSourceStoreCardFolder:= EnsureTrailingBackslash(mOpenDialog.FileName) + mFolderList[i];
            NxGetFileList(mSourceStoreCardFolder, mFileList, '*.*');
            for j:=0 to mFileList.Count -1 do
            begin
              if mFileList[j] in ['.', '..'] then continue;

              mFileExt:= UpperCase(ExtractFileExt(mFileList[j]));
              if not (mFileExt in ['.JPG', '.JPEG', '.TIFF', '.PNG', '.BMP', '.TIF', '.GIF', '.ICO']) then continue;              //, '.WEBP']

              mDestinationFolder:= EnsureTrailingBackslash(mDestPath + SanitizeFilename(mStoreCardCode));

              NxCreateDir(mDestinationFolder);

              if NxCopyFile(EnsureTrailingBackslash(mSourceStoreCardFolder) + mFileList[j], mDestinationFolder + mFileList[j]) then
              begin
                if mFileExt = '.WEBP' then continue; //WEBP NEUMÍME NAHRÁT DO PICTURES, KOPÍRUJEME ALE NEZAKLÁDÁME

                //if PictureExistsInCollection(mSCPictures, ExtractFileName(mFileList[j]), True) then continue;

                mPICBO:= mSCPictures.AddNewObject;
                mPICBO.SetFieldValueAsString('Picture_ID.PictureTitle',ExtractFileName(mFileList[j]));
                mPICBO.SetFieldValueAsBoolean('Picture_ID.ExternalFile', true);
                mPICBO.SetFieldValueAsString('Picture_ID.PathAndFileName', mDestinationFolder + mFileList[j]);
              end else
              begin
                mLog:= mLog + Format('%s - %s - Nepodařilo se založit obrázek', [mFolderList[i], mFileList[j]]) + nxCrLf;
                continue;
              end;
            end;
            mSCBO.Save;
          finally
            mSCBO.Free;
          end;

        //TEST BREAK*******************
        //NxShowSimpleMessage('Karta: '+mFolderList[i]+nxCrLf+'Obrázky: '+nxCrLf+mFileList.Text, mSite);
        //exit;
        //*****************************

        finally
          mFileList.Free;
        end;
      end;

    finally
      mFolderList.Free;
    end;
    NxShowSimpleMessage('Import dokončen', mSite);

    if not NxIsBlank(mLog) then
      NxShowEditorSite(mSite.SiteContext, mlog, true);
  finally
    mOpenDialog.Free;
  end;
end;


function PictureExistsInCollection(const ACollection: TNxCustomBusinessMonikerCollection; const AName: string; AExternalFile: Boolean):Boolean;
var
  i: integer;
begin
  Result:= False;
  for i:= 0 to ACollection.Count -1 do
  begin
    if (ACollection.BusinessObject[i].GetFieldValueAsString('Picture_ID.PictureTitle') = AName)
      and (ACollection.BusinessObject[i].GetFieldValueAsBoolean('Picture_ID.ExternalFile') = AExternalFile) then
    begin
      Result:= True;
    end;
  end;
end;


function EnsureTrailingBackslash(const APath: string): string;
begin
  if (APath <> '') and (APath[Length(APath)] <> '\') then
    Result := APath + '\'
  else
    Result := APath;
end;


function GetStoreCardIDBySanitizedCode(AOS: TNxCustomObjectSpace; const ACode: string): String;
var
  mStoreCard_ID: string;
begin
  Result:= '';

  mStoreCard_ID:= AOS.SQLSelectFirstAsString(
    'SELECT S.ID ' +
    'FROM Storecards S ' +
    'WHERE ' +
    '  REPLACE(' +
    '    REPLACE(' +
    '      REPLACE(' +
    '        REPLACE(' +
    '          REPLACE(' +
    '            REPLACE(' +
    '              REPLACE(' +
    '                REPLACE(' +
    '                  REPLACE(Code, ''<'', ''_''),' +
    '                ''>'', ''_''),' +
    '              '':'' , ''_''),' +
    '            ''"'', ''_''),' +
    '          ''/'', ''_''),' +
    '        ''\'', ''_''),' +   // Note: Delphi string uses two single quotes for one ', backslash is normal char
    '      ''|'', ''_''),' +
    '    ''?'', ''_''),' +
    '  ''*'', ''_'') = '+QuotedStr(ACode));

  Result:= mStoreCard_ID;
end;


function SanitizeFilename(const AFilename: string): string;
const
  InvalidChars = '<>:"/\|?*';
var
  i: Integer;
  ResultStr: string;
begin
  ResultStr := AFilename;
  for i := 1 to Length(InvalidChars) do
    ResultStr := StringReplace(ResultStr, InvalidChars[i], '_', [rfReplaceAll]);

  Result := Trim(ResultStr);
end;


procedure exeDeletePictures(Sender: TComponent);
var
  mSite: TSiteForm;
  mOS: TNxCustomObjectSpace;
  mBO: TNxCustomBusinessObject;
  mList, mFilteredList: TStringList;
  i: integer;
  mDestinationFolder: string;
begin
  mSite:= Sender.Site;
  mOS:= mSite.BaseObjectSpace;

  mDestinationFolder:=  '\\systematiq.cz\CustomersData\STINKOVO_DATA\ABRA-Pictures\images\Skladové karty\';

  mList:= TStringList.Create;
  mFilteredList:= TStringList.Create;
  try
    mOS.SQLSelect('SELECT ID FROM Pictures WHERE ExternalFile = ''A''', mList);

    mBO:= mOS.CreateObject(Class_Picture);
    try
      for i:= 0 to mList.Count -1 do
      begin
        mBO.Load(mList[i], nil);
        if UpperCase(mBO.GetFieldValueAsString('PictureType')) in ['JPG', 'JPEG', 'TIFF', 'PNG', 'BMP', 'TIF', 'GIF', 'ICO'] then
        begin
          if Copy(mBO.GetFieldValueAsString('PathAndFileName'), 0, 12) = '\\SQCZ-WS104' then
          begin
            if DeleteFile(mBO.GetFieldValueAsString('PathAndFileName')) then
              mBO.Delete;
          end;
          //mDestinationFolder:= mDestinationFolder + mBO
          //NxCopyFile(mBO.GetFieldValueAsString('PathAndFileName'), '
          //mFilteredList.Add(mBO.GetFieldValueAsString('PathAndFileName'));
        end;
      end;
    finally
      mBO.Free;
    end;

    NxShowEditorSite(mSite.SiteContext, mFilteredList.Text, true);

  finally
    mList.Free;
    mFilteredList.Free;
  end;








end;


begin
end.