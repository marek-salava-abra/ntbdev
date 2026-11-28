uses 'eu.untraco.data.ParseData', 'eu.untraco.data.Progress';

procedure FormCreate_Hook(Self: TSiteForm);
var
  mAction: TMultiAction;
begin
  mAction := Self.GetNewMultiAction;
  mAction.ShowControl := True;
  mAction.ShowMenuItem := True;
  mAction.Caption := 'Import obrázků';
  mAction.Items.Add('Nový import');
  //mAction.Items.Add('Revize');
  mAction.Hint := 'Provede import z csv';
  mAction.Category := 'tabList';
  mAction.OnExecuteItem := @ImportData;

end;

procedure ImportData(sender:Tcomponent; index:integer);
var
 mSite:TsiteForm;
 mOS:TNxCustomObjectSpace;
 mSMBO, mSM, mFirmBO, mbankBO, mSupplierBO, mSCBO:TNxCustomBusinessObject;
 mUnits:TNxCustomBusinessMonikerCollection;
 mUnit:TNxCustomBusinessObject;
 mList:TStringList;
 mImageFile:string;
 mopenDLG:TOpenDialog;
 mParams, mParRow : TNxParameters;
 i, j, k:integer;
 mStoreCard_ID, mParent_ID, mSupplier_ID, mFirm_ID:String;
 mNew:Boolean;
 mGRows : TMultiGrid;
 mXMlHead:TNxScriptingXMLWrapper;
 AStream:TMemoryStream;
 {'code','name','date','price','quantity','odpis','stredisko','SN'}
begin
 mSite:=TComponent(sender).BusRollSite;
 mOS:=msite.BaseObjectSpace;
  if index=0 then begin
  mOpenDlg := TOpenDialog.Create(Sender);
  try
    if mOpenDlg.Execute then begin
      try
        mXMlHead:=TNxScriptingXMLWrapper.Create;
        mXMlHead.loadFromFile(mOpenDlg.FileName);
        j:=mXMlHead.getElementsCountInArray('PRODUCT_IMAGES.Image');
        try
           ProgressInit(mSite, 'Import dodavatelů...', j);
           for i := 0 to j - 1 do begin
              mstorecard_ID:=mXMlHead.getAttributeValue('PRODUCT_IMAGES.Image['+IntToStr(i)+']','product_system_id');
              if not(NxIsEmptyOID(mStoreCard_ID)) then begin
                mSMBO:=mOS.CreateObject(Class_StoreCard);
                mSMBO.Load(mStoreCard_ID,nil);
                AStream := TMemoryStream.Create;
                Try
                 mImageFile:=NxGetTempDir+'X'+mStoreCard_ID+'.jpg';
                 //CFxInternet.FTPGetFile('78.24.14.88','21',NxSearchReplace(mXMlHead.getAttributeValue('PRODUCT_IMAGES.Image['+IntToStr(i)+']','file_path'),'/data','',[Srall]),mImageFile,'abena_data','kdjh847OP1');
                 CFxInternet.HTTPGetBinary('http://localhost/tmp/'+NxSearchReplace(mXMlHead.getAttributeValue('PRODUCT_IMAGES.Image['+IntToStr(i)+']','file_path'),'/data/products/','',[Srall]),'',AStream);
                 //mImageFile:=NxGetTempDir+mParRow.ParamByName('eanart').AsString+'.jpg';
                 AStream.SaveToFile(mImageFile);
                 SavePicture(mOS,mSMBO.OID,mImageFile, mSMBO.GetFieldValueAsString('Name'));
                 DeleteFile(mImageFile);
                except
                end;
                AStream.Free;
                //mSMBO.Save;
                msmbo.Free;

              end;

           ProgressSetPos(i+1);
           end;
          ProgressDispose();
        finally


        end;
      finally
      end;
    end;
  finally
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