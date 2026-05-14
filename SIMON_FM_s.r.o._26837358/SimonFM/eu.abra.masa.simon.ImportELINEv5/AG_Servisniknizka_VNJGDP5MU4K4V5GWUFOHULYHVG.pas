const
 cMainDir = '\\aserver\eshop_foto\storecards';
 cURL = 'server.eline.cz';
 cPass = 'xqUogyHQC8_8';
 cLogin = 'elinewebabra';

procedure InitSite_Hook(Self: TSiteForm);
var
  mAction, mAction2: TBasicAction;
begin
  mAction := Self.GetNewAction;
  mAction.ShowControl := True;
  mAction.ShowMenuItem := True;
  mAction.Name := 'actImport5';
  mAction.Caption := 'nahrání obrázků';
  mAction.Hint := 'Naimportuje ID data z CSV';
  mAction.Category := 'tabList';
  mAction.OnExecute := @ImportData;
end;

Procedure ImportData(sender:TComponent);
var
 mSite:TSiteForm;
 mOS:TNxCustomObjectSpace;
 mList:TStringList;
 mBO, mNewBO, mParamBO:TNxCustomBusinessObject;
 mPictures:TNxCustomBusinessMonikerCollection;
 i,j:integer;
 mOpenDlg:TOpenDialog;
 AStream:TMemoryStream;
 mTempStr, mCode, mElineID, mNextSC_ID, mImageFile:String;
 mCisSklad, mName, mCollA, mStoreCard_ID, mVazba_ID, mParam_ID, mPosindex, mPCode, mParamGroup_ID: String;
 mCollB, mCollC,mCollD,mCollE,mCollF,mCollG,mCollH,mCollI,mCollJ,mCollK,mCollL,mCollM,mCollN,mCollO,mCollP,mCollQ,mCollR,mCollS,mCollT,mCollU,mCollV:string;
 mCollA1, mCollB1, mCollC1, mCollD1:string;
 mWinHTTP:Variant;
 mResponse:string;
 mFtp:TFTP;
 mIntPosindex:Integer;
begin

  mSite:=TComponent(sender).DynSite;
  mOS:=mSite.BaseObjectSpace;
  mList:=tstringlist.create;
  mOpenDlg := TOpenDialog.Create(Sender);
  mOpenDlg.Filter:= 'Import z CSV|*.csv';
  mOpenDlg.FilterIndex:= 0;
  if mOpenDlg.Execute then begin
   mList.LoadFromFile(mOpenDlg.FileName);
    if mList.Count>0 then begin
     WaitWin.StartProgress('Čekejte, prosím ...', '', mList.Count);
      for i:=1 to mlist.count-1 do begin
         mTempStr:=mlist.Strings[i];
         mCollA:= Trim(NxTrapStr(mTempStr, ';'));
         mCollB:= Trim(NxTrapStr(mTempStr, ';'));
         mCollC:= Trim(NxTrapStr(mTempStr, ';'));
         mCollD:= NxSearchReplace(Trim(NxTrapStr(mTempStr, ';')),'"','',[srall]);
         mCollE:= Trim(NxTrapStr(mTempStr, ';'));
         mCollF:= Trim(NxTrapStr(mTempStr, ';'));
         mCollG:= Trim(NxTrapStr(mTempStr, ';'));
         mCollH:= NxSearchReplace(Trim(NxTrapStr(mTempStr, ';')),'"','',[srall]);
         mIntPosindex:=StrToInt(mCollH);
         mElineID:=mCollB;
         mStoreCard_ID:=mOS.SQLSelectFirstAsString('Select id from storecards where X_ESCard=''A'' and X_elineID='+QuotedStr(mElineID),'');
         if not(NxIsEmptyOID(mStoreCard_ID)) then begin
           mbo:=mOS.CreateObject(Class_StoreCard);
           mBO.Load(mStoreCard_ID,nil);
               Try
                 //mWinHTTP:= CreateOleObject('WinHttp.WinHttpRequest.5.1');
                 //mWinHTTP.Open('GET', 'https://www.naradi-simon.cz/img_produkty/nejvetsi/'+mCollD);
                 //mResponse:='';
                 //mWinHTTP.send(mResponse);
                 //NxShowSimpleMessage(mWinHTTP.Status+#13#10+mResponse,mSite);
                 mImageFile:='d:\images\'+mCollD;
                 if not(FileExists(mImageFile)) then begin
                   mFTP:= TFTP.Create;
                   mFTP.Host:=cURL;
                   mftp.UserName:=cLogin;
                   mFTP.Password:=cPass;
                   mftp.Connect;
                   mFTP.Passive:=true;
                   mFtp.ChangeDir('nejvetsi');
                   mFTP.TransferType:=ftBinary;
                   mftp.get(mCollD,mImageFile);
                   mFTP.Free;
                 end;
                 mPictures:=mBO.GetLoadedCollectionMonikerForFieldCode(mbo.GetFieldCode('Pictures'));
                 mNewBO:=mPictures.AddNewObject;
                 mNewBO.SetFieldValueAsString('Picture_ID.PictureTitle',mBO.GetFieldValueAsString('Name'));
                 mNewBO.SetFieldValueAsBoolean('Picture_ID.ExternalFile',true);
                 mNewBO.SetFieldValueAsString('Picture_ID.PathAndFileName',mImageFile);
                 mNewBO.SetFieldValueAsBoolean('X_AES_Send',true);
                 if mIntPosindex=0 then begin
                  mIntPosindex:=mOS.SQLSelectFirstAsInteger('select count(id) from storecardpictures where Parent_ID='+QuotedStr(mbo.OID)+' and not posindex=1',0);
                  mIntPosindex:=mIntPosindex+2;
                 end;
                 mNewBO.SetFieldValueAsInteger('PosIndex',mIntPosindex);
               except
                NxShowSimpleMessage(ExceptionMessage,mSite);
               end;
           mbo.save;
           mbo.free;
         end;
         WaitWin.ChangeText(IntToStr(i) + ' / ' + IntToStr(mList.Count));
         WaitWin.StepIt;
      end;
     WaitWin.Stop;
     NxShowSimpleMessage('Nahráno '+IntToStr(mlist.count)+' obrázků.',mSite);
    end;
   end;
end;

procedure SavePicture(AOS: TNxCustomObjectSpace; AStoreCardOID, AFileName, AName:String);
var
  mSC_Obj, mAttach, mContent: TNxCustomBusinessObject;
  mMon: TNxBusinessMoniker;
  mAttachmentColl: TNxCustomBusinessMonikerCollection;
  mOLE, mPictureObject, mStoreCardPictureObject, mPictureData: Variant;
  mStoreCardObject, mStoreCardData, mStoreCardPicturesCol, mStoreCardPictureData: Variant;
  mSQLCountry, mSQL, mCountryOID: string;
  i, x: integer;
  mCreatedTime: TDateTime;
  mConnectionList: TStringList;
begin
  if FileExists(AFileName) then begin;
    mConnectionList := TStringList.Create;
    try

      //AOS.SQLSelect(mSQL, mConnectionList);
      mCreatedTime := 0;
      AOS.StartTransaction(taReadCommited);
      try

        // tvorbu obrazku je nutne obejit pres fce AbraOLE, bezne nacteni ze streamu se mi nepodarilo rozchodit
        mOLE := GetAbraOLEApplication;
        mStoreCardObject := mOLE.CreateObject('@StoreCard');
        mStoreCardData := mStoreCardObject.GetValues(AStoreCardOID);
        //Získání kolekce obrázků
        mStoreCardPicturesCol := mStoreCardData.ValueByName('Pictures');
        //Naplnění řádku kolekce obrázků skladové karty
        mStoreCardPictureObject := mOLE.CreateObject('@StoreCardPicture');
        mStoreCardPictureData := mOLE.CreateValues('@StoreCardPicture');
        mStoreCardPictureObject.PrefillValues(mStoreCardPictureData);
        //Načtení obrázku ze souboru
        mPictureData := mStoreCardPictureData.ValueByName('Picture_ID');
        mPictureObject := mOLE.CreateObject('@Picture');
        mPictureObject.LoadFromFile(mPictureData, AFileName);

        mPictureData.ValueByName('PictureTitle') := AName;
        mPictureData.valuebyname('PathAndFileName') :=AFileName;
        mStoreCardPicturesCol.Add(mStoreCardPictureData);
        //Uložení existujici skladové karty
        mStoreCardObject.UpdateValues(AStoreCardOID, mStoreCardData);
        AOS.Commit;
      except
        AOS.RollBack;
        RaiseException(ExceptionMessage);
      end;
    finally
      mConnectionList.Free;
    end;
  end
  else
    RaiseException(Format('Import obrázku - chyba, soubor %s neexistuje', [AFileName]));
end;



begin
end.