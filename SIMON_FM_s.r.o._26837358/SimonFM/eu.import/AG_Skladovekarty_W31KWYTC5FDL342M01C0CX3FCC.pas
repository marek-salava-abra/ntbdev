uses 'eu.import.progress';
Const
 cPath='\\192.168.101.20\Programy\AbraG3\zz_media\bosch\el_rucni\';




 {mPictures:=mbo.GetLoadedCollectionMonikerForFieldCode(mbo.GetFieldCode('Pictures'));
            for j:=0 to mXMLHead.getElementsCountInArray('T_NEW_CATALOG[0].ARTICLE['+inttostr(i)+'].MIME_INFO.MIME')-1 do begin

                mPicture_ID:=GetPicture_ID(mOS,cPath+mXMLHead.getElementAsString('T_NEW_CATALOG['+inttostr(0)+'].ARTICLE['+inttostr(i)+'].MIME_INFO.MIME['+inttostr(j)+'].MIME_SOURCE'));
                if NxIsEmptyOID(mPicture_ID) then begin
                if FileExists(cPath+mXMLHead.getElementAsString('T_NEW_CATALOG['+inttostr(0)+'].ARTICLE['+inttostr(i)+'].MIME_INFO.MIME['+inttostr(j)+'].MIME_SOURCE')) then begin
                mPicture:= mos.CreateObject(Class_Picture);
                mPicture.New;
                mPicture.Prefill;
                mPicture.SetFieldValueAsBoolean('ExternalFile',True);
                mPicture.SetFieldValueAsString('PathAndFileName',cPath+mXMLHead.getElementAsString('T_NEW_CATALOG['+inttostr(0)+'].ARTICLE['+inttostr(i)+'].MIME_INFO.MIME['+inttostr(j)+'].MIME_SOURCE'));
                mPicture.SetFieldValueAsString('PictureTitle',mXMLHead.getElementAsString('T_NEW_CATALOG['+inttostr(0)+'].ARTICLE['+inttostr(i)+'].MIME_INFO.MIME['+inttostr(j)+'].MIME_DESCR'));
                mpicture.Save;
                mPicture_ID:=mPicture.OID;
                mpicture.Free
                end;
                end;
                mPomoc_ID:=GetStoreCardPicture_ID(mos,mPicture_ID,mbo.OID);
                if NxIsEmptyOID(mPomoc_ID) then begin
                   mStorePicture:=mPictures.AddNewObject;
                   mStorePicture.SetFieldValueAsString('Picture_ID',mPicture_ID);
                end;
               //NxShowMessage('INFO',mXMLHead.getElementAsString('T_NEW_CATALOG['+inttostr(0)+'].ARTICLE['+inttostr(i)+'].MIME_INFO.MIME['+inttostr(j)+'].MIME_SOURCE'),mdInformation,false,mSite);
            end;
           mbo.SetFieldValueAsString('Note',mXMLHead.getElementAsString('T_NEW_CATALOG['+inttostr(0)+'].ARTICLE['+inttostr(i)+'].ARTICLE_DETAILS.DESCRIPTION_LONG'));
           for j:=0 to mXMLHead.getElementsCountInArray('T_NEW_CATALOG[0].ARTICLE['+inttostr(i)+'].ARTICLE_FEATURES')-1 do begin
            for k:=0 to mXMLHead.getElementsCountInArray('T_NEW_CATALOG[0].ARTICLE['+inttostr(i)+'].ARTICLE_FEATURES['+inttostr(j)+'].FEATURE')-1 do begin
              if mXMLHead.getElementAsString('T_NEW_CATALOG['+inttostr(0)+'].ARTICLE['+inttostr(i)+'].ARTICLE_FEATURES['+inttostr(j)+'].FEATURE['+inttostr(k)+'].FNAME')='Délka' then
              mbo.SetFieldValueAsFloat('U_AES_SC2_DELKA_CZ', StrToFloat(mXMLHead.getElementAsString('T_NEW_CATALOG['+inttostr(0)+'].ARTICLE['+inttostr(i)+'].ARTICLE_FEATURES['+inttostr(j)+'].FEATURE['+inttostr(k)+'].FVALUE')));
              if mXMLHead.getElementAsString('T_NEW_CATALOG['+inttostr(0)+'].ARTICLE['+inttostr(i)+'].ARTICLE_FEATURES['+inttostr(j)+'].FEATURE['+inttostr(k)+'].FNAME')='Šířka' then
              mbo.SetFieldValueAsFloat('U_AES_SC2_SIRKA_CZ', StrToFloat(mXMLHead.getElementAsString('T_NEW_CATALOG['+inttostr(0)+'].ARTICLE['+inttostr(i)+'].ARTICLE_FEATURES['+inttostr(j)+'].FEATURE['+inttostr(k)+'].FVALUE')));
              if mXMLHead.getElementAsString('T_NEW_CATALOG['+inttostr(0)+'].ARTICLE['+inttostr(i)+'].ARTICLE_FEATURES['+inttostr(j)+'].FEATURE['+inttostr(k)+'].FNAME')='Výška' then
              mbo.SetFieldValueAsFloat('U_AES_SC2_VYSKA_CZ', StrToFloat(mXMLHead.getElementAsString('T_NEW_CATALOG['+inttostr(0)+'].ARTICLE['+inttostr(i)+'].ARTICLE_FEATURES['+inttostr(j)+'].FEATURE['+inttostr(k)+'].FVALUE')));
              if (mXMLHead.getElementAsString('T_NEW_CATALOG['+inttostr(0)+'].ARTICLE['+inttostr(i)+'].ARTICLE_FEATURES['+inttostr(j)+'].FEATURE['+inttostr(k)+'].FNAME')='Hmotnost') or (mXMLHead.getElementAsString('T_NEW_CATALOG['+inttostr(0)+'].ARTICLE['+inttostr(i)+'].ARTICLE_FEATURES['+inttostr(j)+'].FEATURE['+inttostr(k)+'].FNAME')='Hmotnost včetně akumulátoru') then
              mbo.SetFieldValueAsFloat('U_AES_SC2_HMOTNOST_CZ', StrToFloat(mXMLHead.getElementAsString('T_NEW_CATALOG['+inttostr(0)+'].ARTICLE['+inttostr(i)+'].ARTICLE_FEATURES['+inttostr(j)+'].FEATURE['+inttostr(k)+'].FVALUE')));
              if mXMLHead.getElementAsString('T_NEW_CATALOG['+inttostr(0)+'].ARTICLE['+inttostr(i)+'].ARTICLE_FEATURES['+inttostr(j)+'].FEATURE['+inttostr(k)+'].FNAME')='Další výhody' then begin
                for l:=0 to mXMLHead.getElementsCountInArray('T_NEW_CATALOG['+inttostr(0)+'].ARTICLE['+inttostr(i)+'].ARTICLE_FEATURES['+inttostr(j)+'].FEATURE['+inttostr(k)+'].FVALUE')-1 do begin
                   mbo.SetFieldValueAsString('Note',mbo.GetFieldValueAsString('Note')+Chr(13)+Chr(10)+mXMLHead.getElementAsString('T_NEW_CATALOG['+inttostr(0)+'].ARTICLE['+inttostr(i)+'].ARTICLE_FEATURES['+inttostr(j)+'].FEATURE['+inttostr(k)+'].FVALUE['+inttostr(l)+']'));
                end;
              end;
              if mXMLHead.getElementAsString('T_NEW_CATALOG['+inttostr(0)+'].ARTICLE['+inttostr(i)+'].ARTICLE_FEATURES['+inttostr(j)+'].FEATURE['+inttostr(k)+'].FNAME')='Výhoda pro uživatele' then begin
                for l:=0 to mXMLHead.getElementsCountInArray('T_NEW_CATALOG['+inttostr(0)+'].ARTICLE['+inttostr(i)+'].ARTICLE_FEATURES['+inttostr(j)+'].FEATURE['+inttostr(k)+'].FVALUE')-1 do begin
                   if l=0 then mbo.SetFieldValueAsString('U_AES_SC2_VYHODA_CZ',mXMLHead.getElementAsString('T_NEW_CATALOG['+inttostr(0)+'].ARTICLE['+inttostr(i)+'].ARTICLE_FEATURES['+inttostr(j)+'].FEATURE['+inttostr(k)+'].FVALUE['+inttostr(l)+']')) else
                   mbo.SetFieldValueAsString('U_AES_SC2_VYHODA_CZ',mbo.GetFieldValueAsString('U_AES_SC2_VYHODA_CZ')+Chr(13)+Chr(10)+mXMLHead.getElementAsString('T_NEW_CATALOG['+inttostr(0)+'].ARTICLE['+inttostr(i)+'].ARTICLE_FEATURES['+inttostr(j)+'].FEATURE['+inttostr(k)+'].FVALUE['+inttostr(l)+']'));
                end;
              end;
              if mXMLHead.getElementAsString('T_NEW_CATALOG['+inttostr(0)+'].ARTICLE['+inttostr(i)+'].ARTICLE_FEATURES['+inttostr(j)+'].FEATURE['+inttostr(k)+'].FNAME')='Obsah dodávky' then begin
                for l:=0 to mXMLHead.getElementsCountInArray('T_NEW_CATALOG['+inttostr(0)+'].ARTICLE['+inttostr(i)+'].ARTICLE_FEATURES['+inttostr(j)+'].FEATURE['+inttostr(k)+'].FVALUE')-1 do begin
                   if l=0 then mbo.SetFieldValueAsString('U_AES_SC2_OBSAH_CZ',mXMLHead.getElementAsString('T_NEW_CATALOG['+inttostr(0)+'].ARTICLE['+inttostr(i)+'].ARTICLE_FEATURES['+inttostr(j)+'].FEATURE['+inttostr(k)+'].FVALUE['+inttostr(l)+']')) else
                   mbo.SetFieldValueAsString('U_AES_SC2_OBSAH_CZ',mbo.GetFieldValueAsString('U_AES_SC2_OBSAH_CZ')+Chr(13)+Chr(10)+mXMLHead.getElementAsString('T_NEW_CATALOG['+inttostr(0)+'].ARTICLE['+inttostr(i)+'].ARTICLE_FEATURES['+inttostr(j)+'].FEATURE['+inttostr(k)+'].FVALUE['+inttostr(l)+']'));
                end;
              end;
              //if mXMLHead.getElementAsString('T_NEW_CATALOG['+inttostr(0)+'].ARTICLE['+inttostr(i)+'].ARTICLE_FEATURES['+inttostr(j)+'].FEATURE['+inttostr(k)+'].FNAME')='? vrtání do betonu s vrtáky pro vrtací kladiva' then
              //mbo.SetFieldValueAsFloat('U_AES_SC2_PRUMERDOBETONU_CZ', StrToFloat(mXMLHead.getElementAsString('T_NEW_CATALOG['+inttostr(0)+'].ARTICLE['+inttostr(i)+'].ARTICLE_FEATURES['+inttostr(j)+'].FEATURE['+inttostr(k)+'].FVALUE')));
              if mXMLHead.getElementAsString('T_NEW_CATALOG['+inttostr(0)+'].ARTICLE['+inttostr(i)+'].ARTICLE_FEATURES['+inttostr(j)+'].FEATURE['+inttostr(k)+'].FNAME')='Napětí článku' then
              mbo.SetFieldValueAsFloat('U_AES_SC2_NAPETICLANKU_CZ', StrToFloat(mXMLHead.getElementAsString('T_NEW_CATALOG['+inttostr(0)+'].ARTICLE['+inttostr(i)+'].ARTICLE_FEATURES['+inttostr(j)+'].FEATURE['+inttostr(k)+'].FVALUE')));
              if mXMLHead.getElementAsString('T_NEW_CATALOG['+inttostr(0)+'].ARTICLE['+inttostr(i)+'].ARTICLE_FEATURES['+inttostr(j)+'].FEATURE['+inttostr(k)+'].FNAME')='Kapacita akumulátoru' then
              mbo.SetFieldValueAsFloat('U_AES_SC2_KAPACITA_CZ', StrToFloat(mXMLHead.getElementAsString('T_NEW_CATALOG['+inttostr(0)+'].ARTICLE['+inttostr(i)+'].ARTICLE_FEATURES['+inttostr(j)+'].FEATURE['+inttostr(k)+'].FVALUE')));
              if mXMLHead.getElementAsString('T_NEW_CATALOG['+inttostr(0)+'].ARTICLE['+inttostr(i)+'].ARTICLE_FEATURES['+inttostr(j)+'].FEATURE['+inttostr(k)+'].FNAME')='Max. krouticí moment' then
              mbo.SetFieldValueAsFloat('U_AES_SC2_MAXKROUT_CZ', StrToFloat(mXMLHead.getElementAsString('T_NEW_CATALOG['+inttostr(0)+'].ARTICLE['+inttostr(i)+'].ARTICLE_FEATURES['+inttostr(j)+'].FEATURE['+inttostr(k)+'].FVALUE')));
              if mXMLHead.getElementAsString('T_NEW_CATALOG['+inttostr(0)+'].ARTICLE['+inttostr(i)+'].ARTICLE_FEATURES['+inttostr(j)+'].FEATURE['+inttostr(k)+'].FNAME')='Max. průměr vrtání, dřevo' then
              mbo.SetFieldValueAsFloat('U_AES_SC2_MAXPRDR_CZ', StrToFloat(mXMLHead.getElementAsString('T_NEW_CATALOG['+inttostr(0)+'].ARTICLE['+inttostr(i)+'].ARTICLE_FEATURES['+inttostr(j)+'].FEATURE['+inttostr(k)+'].FVALUE')));
              if mXMLHead.getElementAsString('T_NEW_CATALOG['+inttostr(0)+'].ARTICLE['+inttostr(i)+'].ARTICLE_FEATURES['+inttostr(j)+'].FEATURE['+inttostr(k)+'].FNAME')='Max. průměr vrtání, ocel' then
              mbo.SetFieldValueAsFloat('U_AES_SC2_MAXPROC_CZ', StrToFloat(mXMLHead.getElementAsString('T_NEW_CATALOG['+inttostr(0)+'].ARTICLE['+inttostr(i)+'].ARTICLE_FEATURES['+inttostr(j)+'].FEATURE['+inttostr(k)+'].FVALUE')));
              if mXMLHead.getElementAsString('T_NEW_CATALOG['+inttostr(0)+'].ARTICLE['+inttostr(i)+'].ARTICLE_FEATURES['+inttostr(j)+'].FEATURE['+inttostr(k)+'].FNAME')='Počet příklepů při jmenovitých otáčkách' then
              mbo.SetFieldValueAsString('U_AES_SC2_POCPRIK_CZ', (mXMLHead.getElementAsString('T_NEW_CATALOG['+inttostr(0)+'].ARTICLE['+inttostr(i)+'].ARTICLE_FEATURES['+inttostr(j)+'].FEATURE['+inttostr(k)+'].FVALUE')));
              if mXMLHead.getElementAsString('T_NEW_CATALOG['+inttostr(0)+'].ARTICLE['+inttostr(i)+'].ARTICLE_FEATURES['+inttostr(j)+'].FEATURE['+inttostr(k)+'].FNAME')='Polohování' then
              mbo.SetFieldValueAsString('U_AES_SC2_POLOHOVANI_CZ', (mXMLHead.getElementAsString('T_NEW_CATALOG['+inttostr(0)+'].ARTICLE['+inttostr(i)+'].ARTICLE_FEATURES['+inttostr(j)+'].FEATURE['+inttostr(k)+'].FVALUE')));
              if mXMLHead.getElementAsString('T_NEW_CATALOG['+inttostr(0)+'].ARTICLE['+inttostr(i)+'].ARTICLE_FEATURES['+inttostr(j)+'].FEATURE['+inttostr(k)+'].FNAME')='Rázová energie, max.' then
              mbo.SetFieldValueAsFloat('U_AES_SC2_RAZEN_CZ', StrToFloat(mXMLHead.getElementAsString('T_NEW_CATALOG['+inttostr(0)+'].ARTICLE['+inttostr(i)+'].ARTICLE_FEATURES['+inttostr(j)+'].FEATURE['+inttostr(k)+'].FVALUE')));
              if mXMLHead.getElementAsString('T_NEW_CATALOG['+inttostr(0)+'].ARTICLE['+inttostr(i)+'].ARTICLE_FEATURES['+inttostr(j)+'].FEATURE['+inttostr(k)+'].FNAME')='Upínání nástrojů' then
              mbo.SetFieldValueAsString('U_AES_SC2_UPNASTR_CZ', (mXMLHead.getElementAsString('T_NEW_CATALOG['+inttostr(0)+'].ARTICLE['+inttostr(i)+'].ARTICLE_FEATURES['+inttostr(j)+'].FEATURE['+inttostr(k)+'].FVALUE')));
              if mXMLHead.getElementAsString('T_NEW_CATALOG['+inttostr(0)+'].ARTICLE['+inttostr(i)+'].ARTICLE_FEATURES['+inttostr(j)+'].FEATURE['+inttostr(k)+'].FNAME')='Balení (d/š/v)' then
              mbo.SetFieldValueAsString('U_AES_SC2_BALENI_CZ', (mXMLHead.getElementAsString('T_NEW_CATALOG['+inttostr(0)+'].ARTICLE['+inttostr(i)+'].ARTICLE_FEATURES['+inttostr(j)+'].FEATURE['+inttostr(k)+'].FVALUE')));
              if mXMLHead.getElementAsString('T_NEW_CATALOG['+inttostr(0)+'].ARTICLE['+inttostr(i)+'].ARTICLE_FEATURES['+inttostr(j)+'].FEATURE['+inttostr(k)+'].FNAME')='Úhel oscilace levý/pravý' then
              mbo.SetFieldValueAsFloat('U_AES_SC2_OSCILACE_CZ', StrToFloat(mXMLHead.getElementAsString('T_NEW_CATALOG['+inttostr(0)+'].ARTICLE['+inttostr(i)+'].ARTICLE_FEATURES['+inttostr(j)+'].FEATURE['+inttostr(k)+'].FVALUE')));
              if mXMLHead.getElementAsString('T_NEW_CATALOG['+inttostr(0)+'].ARTICLE['+inttostr(i)+'].ARTICLE_FEATURES['+inttostr(j)+'].FEATURE['+inttostr(k)+'].FNAME')='Volnoběžné otáčky' then
              mbo.SetFieldValueAsString('U_AES_SC2_VOLNOBEH_CZ', (mXMLHead.getElementAsString('T_NEW_CATALOG['+inttostr(0)+'].ARTICLE['+inttostr(i)+'].ARTICLE_FEATURES['+inttostr(j)+'].FEATURE['+inttostr(k)+'].FVALUE')));
              if mXMLHead.getElementAsString('T_NEW_CATALOG['+inttostr(0)+'].ARTICLE['+inttostr(i)+'].ARTICLE_FEATURES['+inttostr(j)+'].FEATURE['+inttostr(k)+'].FNAME')='Výstupní výkon' then
              mbo.SetFieldValueAsFloat('U_AES_SC2_VYSTVYKON_CZ', StrToFloat(mXMLHead.getElementAsString('T_NEW_CATALOG['+inttostr(0)+'].ARTICLE['+inttostr(i)+'].ARTICLE_FEATURES['+inttostr(j)+'].FEATURE['+inttostr(k)+'].FVALUE')));
              if mXMLHead.getElementAsString('T_NEW_CATALOG['+inttostr(0)+'].ARTICLE['+inttostr(i)+'].ARTICLE_FEATURES['+inttostr(j)+'].FEATURE['+inttostr(k)+'].FNAME')='Napětí' then
              mbo.SetFieldValueAsFloat('U_AES_SC2_NAPETI_CZ', StrToFloat(mXMLHead.getElementAsString('T_NEW_CATALOG['+inttostr(0)+'].ARTICLE['+inttostr(i)+'].ARTICLE_FEATURES['+inttostr(j)+'].FEATURE['+inttostr(k)+'].FVALUE')));
              if mXMLHead.getElementAsString('T_NEW_CATALOG['+inttostr(0)+'].ARTICLE['+inttostr(i)+'].ARTICLE_FEATURES['+inttostr(j)+'].FEATURE['+inttostr(k)+'].FNAME')='Sklícidlo' then
              mbo.SetFieldValueAsString('U_AES_SC2_SKLICIDLO_CZ', (mXMLHead.getElementAsString('T_NEW_CATALOG['+inttostr(0)+'].ARTICLE['+inttostr(i)+'].ARTICLE_FEATURES['+inttostr(j)+'].FEATURE['+inttostr(k)+'].FVALUE')));
              if mXMLHead.getElementAsString('T_NEW_CATALOG['+inttostr(0)+'].ARTICLE['+inttostr(i)+'].ARTICLE_FEATURES['+inttostr(j)+'].FEATURE['+inttostr(k)+'].FNAME')='Upínací rozsah sklíčidla, min./max.' then
              mbo.SetFieldValueAsString('U_AES_SC2_UPROZSAH_CZ', (mXMLHead.getElementAsString('T_NEW_CATALOG['+inttostr(0)+'].ARTICLE['+inttostr(i)+'].ARTICLE_FEATURES['+inttostr(j)+'].FEATURE['+inttostr(k)+'].FVALUE')));

            end;
           end;
          }
procedure FormCreate_Hook(Self: TSiteForm);
var
  mBut: TBasicAction;
  mMAction : TMultiAction;
begin
  mMAction := Self.GetNewMultiAction;
  mMAction.ShowControl := True;
  mMAction.ShowMenuItem := True;
  mMAction.Caption := 'Importy';
  mMAction.Hint := 'Importy dat';
  mMAction.Category := 'tabList';
  mMAction.OnExecuteItem := @ImportTXT_OnExecute;
  mMAction.Items.Add('Import z CSV');
  mMAction.Items.Add('XML Bosch');
  mMAction.Items.Add('Kingtony CSV');



  //mAction.OnUpdate := @ImportTXT_OnUpdate;
end;


procedure ImportTXT_OnExecute(Sender : TComponent; Index : integer);
var
  mSite : TSiteForm;
  mOpenDlg : TOpenDialog;
  mList : TStringList;
  mBO, mPicture, mStorePicture, mSMBO, mUnit : TNxCustomBusinessObject;
  i,j,k, l, m: integer;
  mOS: TNxCustomObjectSpace;
  mRowTxt:String;
  mStoreCardCode, mStoreCardName, mStoreCardEAN, mPicture_ID, mPomoc_ID, mStorePrice_ID, mStoreCardCategory: String;
  mStoreCard_ID: String;
  mPrice:Extended;
  mXMLHead : TNxScriptingXMLWrapper;
  mPictures, mUnits:TNxCustomBusinessMonikerCollection;
begin

  if index=0 then begin
  mSite := NxFindSiteForm(TComponent(Sender));
  mOpenDlg := TOpenDialog.Create(Sender);
  try
    if mOpenDlg.Execute then begin
      mList := TStringLIst.Create;
      try
        mList.LoadFromFile(mOpenDlg.FileName);
        ProgressInit(mSite, 'import názvů...', mList.count);
        mOS:=msite.CompanyObjectSpace;
        for i:=0 to mList.count-1 do begin
          mStoreCard_ID:='';
          mRowTxt := mlist.strings[i];
          mStoreCardCode:= NxToken(mRowTxt, ';');
          mStoreCardName:=NxToken(mRowTxt, ';');
          //mStoreCardEAN:=NxToken(mRowTxt, ';');
          //if not(NxIsBlank(mStoreCardEAN)) then mStoreCard_ID:=GetStoreCardFromEan_ID(mOS,mStoreCardEAN);
          if NxIsEmptyOID(mStoreCard_ID) then mStoreCard_ID:=GetStoreCardFromCode_ID(mOS,mStoreCardCode);
          if not(NxIsEmptyOID(mStoreCard_ID)) and not(NxIsBlank(mStoreCardName)) then begin
          mbo:= mOS.CreateObject(Class_StoreCard);
          mbo.Load(mStoreCard_ID,nil);
          mbo.SetFieldValueAsString('U_oldName',mbo.GetFieldValueAsString('Name'));
          mbo.SetFieldValueAsString('Name',mStoreCardName);
          mbo.save;
          mbo.free;
          end;
          ProgressSetPos(i+1);
        
        end;

      finally
        ProgressDispose();
        mList.Free;
        RefreshDataset(TDBGrid(NxFindChildControl(TWinControl(NxFindChildControl(mSite.GetSiteAppForm, 'pnList')), 'grdList')));
      end;
      NxShowMessage('info','Import dokončen.',mdInformation,false,mSite);
    end else
      NxShowMessage('info','Import přerušen.',mdInformation,false,mSite);
  finally
    mOpenDlg.Free;
  end;
  end;
    if index=1 then begin
  mSite := NxFindSiteForm(TComponent(Sender));
  mOpenDlg := TOpenDialog.Create(Sender);
  mXMLHead:=TNxScriptingXMLWrapper.Create;
  try
    if mOpenDlg.Execute then begin

      try
        mXMLHead.loadFromFile(mOpenDlg.FileName);
        ProgressInit(mSite, 'import bosch...', mXMLHead.getElementsCountInArray('T_NEW_CATALOG[0].ARTICLE'));
        mOS:=msite.CompanyObjectSpace;
        for i:=0 to mXMLHead.getElementsCountInArray('T_NEW_CATALOG[0].ARTICLE')-1 do begin

          mStoreCard_ID:=GetStoreCardFromCode_ID(mOS,mXMLHead.getElementAsString('T_NEW_CATALOG['+inttostr(0)+'].ARTICLE['+inttostr(i)+'].SUPPLIER_AID'));
          if not(NxIsEmptyOID(mStoreCard_ID)) then begin
          j:=0;
          k:=0;
          l:=0;
          mbo:= mOS.CreateObject(Class_StoreCard);
          //mbo.Load(mStoreCard_ID,nil);
          mStorePrice_ID:=GetPrice_ID(mOS, mStoreCard_ID,'1000000101');
            if not(NxIsEmptyOID(mStorePrice_ID)) then begin
             mSMBO:=mos.CreateObject(Class_StorePrice);
             mSMBO.Load(mStorePrice_ID,nil);
             mUnits:=mSMBO.GetLoadedCollectionMonikerForFieldCode(mSMBO.GetFieldCode('PriceRows'));
             for m:=0 to mUnits.count-1 do begin
            mUnit:=mUnits.BusinessObject[m];
             //NxShowSimpleMessage(mUnit.GetFieldValueAsString('Price_ID'),mSite);
             if mUnit.GetFieldValueAsString('Price_ID')='1000000101' then begin
                if mUnit.GetFieldValueAsString('Qunit')=mSMBO.GetFieldValueAsString('StoreCard_id.MainUnitCode') then begin
                 //NxShowSimpleMessage(NxSearchReplace(mParRow.ParamByName('price').AsString,'"','',[srAll]),mSite);
                 if elementexists(mXMLHead,'T_NEW_CATALOG['+inttostr(0)+'].ARTICLE['+inttostr(i)+'].ARTICLE_PRICE_DETAILS.ARTICLE_PRICE.PRICE_AMOUNT') then begin
                 if not(munit.GetFieldValueAsFloat('Amount')=NxIBStrToFloat(mXMLHead.getElementAsString('T_NEW_CATALOG['+inttostr(0)+'].ARTICLE['+inttostr(i)+'].ARTICLE_PRICE_DETAILS.ARTICLE_PRICE.PRICE_AMOUNT'))) then
                  mUnit.SetFieldValueAsFloat('Amount',NxIBStrToFloat(mXMLHead.getElementAsString('T_NEW_CATALOG['+inttostr(0)+'].ARTICLE['+inttostr(i)+'].ARTICLE_PRICE_DETAILS.ARTICLE_PRICE.PRICE_AMOUNT')));
                  mUnit.save;
                end;
              end;
             end;
            end;
             msmbo.save;
             mSMBO.Free;
            end;

          //mbo.Save;
          mbo.free;
          end;
          ProgressSetPos(i+1);

        end;

      finally
        ProgressDispose();
        mList.Free;
        RefreshDataset(TDBGrid(NxFindChildControl(TWinControl(NxFindChildControl(mSite.GetSiteAppForm, 'pnList')), 'grdList')));
      end;
      NxShowMessage('info','Import dokončen.',mdInformation,false,mSite);
    end else
      NxShowMessage('info','Import přerušen.',mdInformation,false,mSite);
  finally
    mOpenDlg.Free;
  end;
  end;
  if index=2 then begin
  mSite := NxFindSiteForm(TComponent(Sender));
  mOpenDlg := TOpenDialog.Create(Sender);
  try
    if mOpenDlg.Execute then begin
      mList := TStringLIst.Create;
      try
        mList.LoadFromFile(mOpenDlg.FileName);
        ProgressInit(mSite, 'import KingTony...', mList.count);
        mOS:=msite.CompanyObjectSpace;
        for i:=0 to mList.count-1 do begin
          mStoreCard_ID:='';
          mRowTxt := mlist.strings[i];
          mStoreCardCode:= NxToken(mRowTxt, ';');
          mStoreCardName:=NxToken(mRowTxt, ';');
          mPrice:=NxIBStrToFloat(NxToken(mRowTxt, ';'));
          mStoreCardCategory:=NxToken(mRowTxt, ';');
          mStoreCardEAN:=NxToken(mRowTxt, ';');

          //if not(NxIsBlank(mStoreCardEAN)) then mStoreCard_ID:=GetStoreCardFromEan_ID(mOS,mStoreCardEAN);
          if NxIsEmptyOID(mStoreCard_ID) then mStoreCard_ID:=GetStoreCardFromCode_ID(mOS,mStoreCardCode);
          if NxIsEmptyOID(mstorecard_id) and not(nxisblank(mStoreCardName)) then begin
           mBO:=Mos.createobject(class_storecard);
           mbo.new;
           mbo.prefill;
           mbo.SetFieldValueAsString('code',mStoreCardCode);
           mbo.SetFieldValueAsString('name',mStoreCardName);
           mbo.SetFieldValueAsString('StoreCardCategory_ID','1000000101');
           mbo.SetFieldValueAsString('VatRate_ID','02100X0000');
           if not(NxIsBlank(mStoreCardEAN)) then begin
             mUnits:=mbo.GetLoadedCollectionMonikerForFieldCode(mbo.GetFieldCode('storeunits'));
             mUnit:=munits.BusinessObject[0];
             munit.SetFieldValueAsString('Ean',mStoreCardEAN);
           end;
           mbo.save;
           mStoreCard_ID:=mbo.oid;
           mbo.free;
          end;
          if not(NxIsEmptyOID(mStoreCard_ID)) and not(NxIsBlank(mStoreCardName)) then begin
          mbo:= mOS.CreateObject(Class_StoreCard);
          mbo.Load(mStoreCard_ID,nil);
          {if NxIsBlank(mBO.GetFieldValueAsString('EAN')) then begin
           if not(NxIsBlank(mStoreCardEAN)) then begin
             mUnits:=mbo.GetLoadedCollectionMonikerForFieldCode(mbo.GetFieldCode('storeunits'));
             mUnit:=munits.BusinessObject[0];
             munit.SetFieldValueAsString('Ean',mStoreCardEAN);
           end;
          end;         }
          //mbo.SetFieldValueAsString('U_oldName',mbo.GetFieldValueAsString('Name'));
          mbo.SetFieldValueAsString('Name',mStoreCardName);
          if mStoreCardCategory='A' then mbo.SetFieldValueAsFloat('U_ProcentoMax',30);
          if mStoreCardCategory='B' then mbo.SetFieldValueAsFloat('U_ProcentoMax',24);
          if mStoreCardCategory='C' then mbo.SetFieldValueAsFloat('U_ProcentoMax',18);
          mbo.SetFieldValueAsBoolean('U_MinPriceValidate',true);
          mbo.save;
          mStorePrice_ID:=GetPrice_ID(mOS, mStoreCard_ID,'1000000101');
            if not(NxIsEmptyOID(mStorePrice_ID)) then begin
             mSMBO:=mos.CreateObject(Class_StorePrice);
             mSMBO.Load(mStorePrice_ID,nil);
             mUnits:=mSMBO.GetLoadedCollectionMonikerForFieldCode(mSMBO.GetFieldCode('PriceRows'));
             for m:=0 to mUnits.count-1 do begin
             mUnit:=mUnits.BusinessObject[m];
             if mUnit.GetFieldValueAsString('Price_ID')='1000000101' then begin
                if mUnit.GetFieldValueAsString('Qunit')=mSMBO.GetFieldValueAsString('StoreCard_id.MainUnitCode') then begin
                   mUnit.SetFieldValueAsFloat('Amount',NxRoundByValue((mPrice*1.21),ctup,1)/1.21);
                  mUnit.save;
                end;
              end;

            end;
             msmbo.save;
             mSMBO.Free;
            end;
           if NxIsEmptyOID(mStorePrice_ID) then begin
            mSMBO:=mos.CreateObject(Class_StorePrice);
            mSMBO.New;
            mSMBO.SetFieldValueAsString('StoreCard_ID', mStoreCard_ID);
            mSMBO.SetFieldValueAsString('PriceList_ID','1000000101');
            mUnits:=mSMBO.GetLoadedCollectionMonikerForFieldCode(mSMBO.GetFieldCode('PriceRows'));
            mUnit:=mUnits.AddNewObject;
            mUnit.SetFieldValueAsFloat('Amount',NxRoundByValue((mPrice*1.21),ctup,1)/1.21);
            mUnit.SetFieldValueAsString('Price_ID','1000000101');
            mUnit.SetFieldValueAsString('Qunit',mSMBO.GetFieldValueAsString('StoreCard_id.MainUnitCode'));
            mSMBO.save;
            msmbo.Free;
           end;

          mbo.free;
          end;
          ProgressSetPos(i+1);

        end;

      finally
        ProgressDispose();
        mList.Free;
        RefreshDataset(TDBGrid(NxFindChildControl(TWinControl(NxFindChildControl(mSite.GetSiteAppForm, 'pnList')), 'grdList')));
      end;
      NxShowMessage('info','Import dokončen.',mdInformation,false,mSite);
    end else
      NxShowMessage('info','Import přerušen.',mdInformation,false,mSite);
  finally
    mOpenDlg.Free;
  end;
  end;

end;



procedure ImportTXT_OnUpdate(Sender : TComponent);
var
  mSite : TSiteForm;
begin
  if Sender is TComponent then begin
    mSite := NxFindSiteForm(TComponent(Sender));
    if Assigned(mSite) then begin
      if mSite is TDynSiteForm then begin
        TBasicAction(Sender).Enabled := TDynSiteForm(mSite).edit;
      end;
    end;
  end
end;

procedure RefreshDataset(AGrid : TDBGrid);
begin
NxRefreshDataSetWithoutValidate(TNxDataDataSet(AGrid.DataSource.DataSet), true);
end;

function GetStoreCardFromEan_ID(AOS : TNxCustomObjectSpace; EAN: string) : string;
const
  cSQL = 'SELECT su.parent_ID FROM StoreEans SE left join storeunits su on su.id=se.parent_ID WHERE se.EAN=''%s''';
var
  mList : TStringList;
begin
  mList := TStringList.create;
  Result:='';
  try
    NxScriptingLog.WriteEventFmt(logDebug, cSQL, [EAN]);
    AOS.SQLSelect(Format(cSQL,  [EAN]), mList);
    if mList.Count > 0 then
      Result := mList.Strings[0]
  finally
    mList.Free;
  end;
end;

function GetStoreCardFromCode_ID(AOS : TNxCustomObjectSpace; ACode: string) : string;
const
  cSQL = 'SELECT ID from storecards where code=''%s'' and hidden=''N''';
var
  mList : TStringList;
begin
  mList := TStringList.create;
  Result:='';
  try
    NxScriptingLog.WriteEventFmt(logDebug, cSQL, [ACode]);
    AOS.SQLSelect(Format(cSQL,  [ACode]), mList);
    if mList.Count > 0 then
      Result := mList.Strings[0]
  finally
    mList.Free;
  end;
end;

function GetPicture_ID(AOS : TNxCustomObjectSpace; ACode: string) : string;
const
  cSQL = 'SELECT ID from Pictures where PathAndFileName=''%s''';
var
  mList : TStringList;
begin
  mList := TStringList.create;
  Result:='';
  try
    NxScriptingLog.WriteEventFmt(logDebug, cSQL, [ACode]);
    AOS.SQLSelect(Format(cSQL,  [ACode]), mList);
    if mList.Count > 0 then
      Result := mList.Strings[0]
  finally
    mList.Free;
  end;
end;

function GetStoreCardPicture_ID(AOS : TNxCustomObjectSpace; ACode: string;aStoreCard_ID:String) : string;
const
  cSQL = 'SELECT ID from StoreCardPictures where Picture_ID=''%s'' and Parent_ID=''%s''';
var
  mList : TStringList;
begin
  mList := TStringList.create;
  Result:='';
  try
    NxScriptingLog.WriteEventFmt(logDebug, cSQL, [ACode,aStoreCard_ID]);
    AOS.SQLSelect(Format(cSQL,  [ACode,aStoreCard_ID]), mList);
    if mList.Count > 0 then
      Result := mList.Strings[0]
  finally
    mList.Free;
  end;
end;

begin
end.