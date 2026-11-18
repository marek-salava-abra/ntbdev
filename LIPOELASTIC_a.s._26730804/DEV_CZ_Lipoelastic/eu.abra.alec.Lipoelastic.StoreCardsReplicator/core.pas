uses 'eu.abra.alec.Lipoelastic.StoreCardsReplicator.fce';

const
  cSQL_X_Aktivni = ' AND X_Aktivni = ''A'' ';

Procedure actStoreCardReplicator(sender:TComponent);
var
  mExcel, objWorkbook, mXLS: Variant;
  mOpenDialog: TOpenDialog;
  mExcelFileName: String;
  mSite : TSiteForm;
  mOS: TNxCustomObjectSpace;
  mBO, mOrigBO, mOrigMenuLinksBO, mMenuLinksBO, mOrigSupplierBO, mSupplierBO, mEANBO: TNxCustomBusinessObject;
  mUnits, mEANs: TNxCustomBusinessMonikerCollection;
  i, j, m, s, k: Integer;
  mCode, mName, mForeignName, mNameIT, mNameFR, mNameNL, mNameDE, mNameSK, mSpec2, mEANType, mWeight, mIntrastatWeight, mCatalogNumberUK : string;
  mProductType, mKind, mStyle, mSize, mColor, mCollection, mMat1, mMatProc1, mMat2, mMatProc2, mMat3, mMatProc3, mMat4, mMatProc4, mEAN: string;
  mProductTypeID, mKindID, mStyleID, mSizeID, mColorID, mMat1ID, mMat2ID, mMat3ID, mMat4ID: string;
  mErrLog, mStoreCard_ID, mOrigOID: string;
  mMenuLinksList, mSuppliersList: TStringList;

begin
  mSite := Sender.Site;
  mOpenDialog := TOpenDialog.Create(mSite);
  mOS:= Sender.Site.BaseObjectSpace;
  mOrigBO:= mSite.BusRollSite.CurrentObject;
  if Assigned(mOrigBO) then begin
    if NxMessageBox('Klonování skladové karty', 'Přejete si naklonovat kartu '+mOrigBO.GetFieldValueAsString('Code')+' - '+mOrigBO.GetFieldValueAsString('Name')+'?', mdConfirm, mdbYesNo, mrNo, nil, false, mSite) = mrNo then begin
      mOpenDialog.Free;
      mOrigBO.Free;
      Exit;
    end;
    mOrigOID:= mOrigBO.OID;
    try
      mExcel := CreateOleObject('Excel.Application');
    except
      NxShowSimpleMessage('Není nainstalovaný Microsoft Excel.', mSite);
      exit;
    end;
    mOpenDialog.Filter := 'Soubor importu (*.xls,*.xlsx)|*.XLS;*.xlsx';
    mOpenDialog.Options := [ofAllowMultiSelect];

    if mOpenDialog.Execute then
    begin
      try
        mExcelFileName := mOpenDialog.FileName;
        objWorkbook:= mExcel.WorkBooks.Open(mExcelFileName);
        mXLS:= mExcel.ActiveWorkbook.WorkSheets[1];
        ProgressInit(mSite, 'Klonování...', mXLS.UsedRange.Rows.Count);
        mErrLog:= '';


        for i:= 3 to mXLS.UsedRange.Rows.Count do
        begin
          try
            try
              mBO:= mOS.CreateObject(Class_StoreCard);
              mBO:= mOrigBO.Clone;
              //Kód	Název	Cizí název	Název (IT)	Název (FR)	Název (NL)	Název (DE)	Název (SK)	Specifikace2	EAN (2/8)	Hmotnost	Hmotnost doplňkové jednotky	Katalog.číslo UK
              //TYP PRODUKTU	Druh	Provedení	Velikost	Barva	Kolekce / Série	MATERIÁL 1	MAT PROC 1	MATERIÁL 2	MAT PROC 2	MATERIÁL 3 	MAT PROC 3	MATERIÁL 4	MAT PROC 4
              mCode :=            NxLeft(VarToStr(mXLS.Cells[i,1]), 40);
              if mCode = '' then continue;
              mStoreCard_ID:= mOS.SQLSelectFirstAsString('SELECT ID FROM StoreCards WHERE Hidden = ''N'' '+cSQL_X_Aktivni+' AND UPPER(Code) = '+QuotedStr(UpperCase(mCode)));
              if not(NxIsEmptyOID(mStoreCard_ID)) then begin
                mErrLog:= mErrLog +#10#13+ mCode + ' - Karta s tímto kódem již existuje. Import této karty přeskočen.';
                continue;
              end;
              mName :=            NxLeft(VarToStr(mXLS.Cells[i,2]), 100);
              mForeignName :=     NxLeft(VarToStr(mXLS.Cells[i,3]), 100);
              mNameIT :=          NxLeft(VarToStr(mXLS.Cells[i,4]), 200);
              mNameFR :=          NxLeft(VarToStr(mXLS.Cells[i,5]), 200);
              mNameNL :=          NxLeft(VarToStr(mXLS.Cells[i,6]), 200);
              mNameDE :=          NxLeft(VarToStr(mXLS.Cells[i,7]), 200);
              mNameSK :=          NxLeft(VarToStr(mXLS.Cells[i,8]), 200);
              mSpec2 :=           NxLeft(VarToStr(mXLS.Cells[i,9]), 30);
              mEANType :=         NxLeft(VarToStr(mXLS.Cells[i,10]), 1);
              mWeight :=          NxLeft(VarToStr(mXLS.Cells[i,11]), 15);
              mIntrastatWeight := NxLeft(VarToStr(mXLS.Cells[i,12]), 15);
              mCatalogNumberUK := NxLeft(VarToStr(mXLS.Cells[i,13]), 10);
              mProductType :=     NxLeft(VarToStr(mXLS.Cells[i,14]), 10);
              mKind :=            NxLeft(VarToStr(mXLS.Cells[i,15]), 10);
              mStyle :=           NxLeft(VarToStr(mXLS.Cells[i,16]), 10);
              mSize :=            NxLeft(VarToStr(mXLS.Cells[i,17]), 10);
              mColor :=           NxLeft(VarToStr(mXLS.Cells[i,18]), 10);
              mCollection :=      NxLeft(VarToStr(mXLS.Cells[i,19]), 10);
              mMat1 :=            NxLeft(VarToStr(mXLS.Cells[i,20]), 10);
              mMatProc1 :=        NxLeft(VarToStr(mXLS.Cells[i,21]), 10);
              mMat2 :=            NxLeft(VarToStr(mXLS.Cells[i,22]), 10);
              mMatProc2 :=        NxLeft(VarToStr(mXLS.Cells[i,23]), 10);
              mMat3 :=            NxLeft(VarToStr(mXLS.Cells[i,24]), 10);
              mMatProc3 :=        NxLeft(VarToStr(mXLS.Cells[i,25]), 10);
              mMat4 :=            NxLeft(VarToStr(mXLS.Cells[i,26]), 10);
              mMatProc4 :=        NxLeft(VarToStr(mXLS.Cells[i,27]), 10);

              //dostaneme data z enumeration field do String listu
              mProductTypeID:= GetIDFromDefRollData(mOS, 'TJDIA05IJCBON5S3EGRD4K5FXC', 'Code', mProductType);
              mKindID:=        GetIDFromDefRollData(mOS, 'UVVWEQAOLJCONJEJ5ZFH2ZUDFO', 'Code', mKind);
              mStyleID:=       GetIDFromDefRollData(mOS, 'KMGLUSHR20X4VI5ODO4CBKZPLG', 'Code', mStyle);
              mSizeID:=        GetIDFromDefRollData(mOS, 'KOVFE0W4E2K4PBMJGYCWA5WIXG', 'Code', mSize);
              mColorID:=       GetIDFromDefRollData(mOS, '4KCTNAEJY0Y4NITDZQJAPHBW0K', 'Code', mColor);
              mMat1ID:=        GetIDFromDefRollData(mOS, 'BZ3C14G0Q0J4PJ31FGVB4N4FBS', 'Code', mMat1);
              mMat2ID:=        GetIDFromDefRollData(mOS, 'BZ3C14G0Q0J4PJ31FGVB4N4FBS', 'Code', mMat2);
              mMat3ID:=        GetIDFromDefRollData(mOS, 'BZ3C14G0Q0J4PJ31FGVB4N4FBS', 'Code', mMat3);
              mMat4ID:=        GetIDFromDefRollData(mOS, 'BZ3C14G0Q0J4PJ31FGVB4N4FBS', 'Code', mMat4);

              //na základě vstupu se rozhodneme zda budeme generovat EAN, pokud ano tak ve kterém segmentu
              case mEANType of
                '':  mEAN := '';
                '2': mEAN := GetLatestEAN(mOS, '222', 13);
                '8': mEAN := GetLatestEAN(mOS, '8591846', 13);
              end;


              mBO.SetFieldValueAsString('Code', mCode);
              mBO.SetFieldValueAsString('Name', mName);
              mBO.SetFieldValueAsString('ForeignName', mForeignName);
              mBO.SetFieldValueAsString('X_Name_IT', mNameIT);
              mBO.SetFieldValueAsString('X_Name_FR', mNameFR);
              mBO.SetFieldValueAsString('X_Name_DK', mNameNL);   //NL NENÍ OPTAT SE!
              mBO.SetFieldValueAsString('X_Name_DE', mNameDE);
              mBO.SetFieldValueAsString('X_Name_SK', mNameSK);
              mBO.SetFieldValueAsString('Specification2', mSpec2);
              mUnits:= mBO.GetLoadedCollectionMonikerForFieldCode(mBO.GetFieldCode('StoreUnits'));
              for j:= 0 to mUnits.Count -1 do begin
                //ALEC 24.10.2023 úprava mazání kolekce eanů u klonované karty
                mEANS:= mUnits.BusinessObject[j].GetLoadedCollectionMonikerForFieldCode(mUnits.BusinessObject[j].GetFieldCode('StoreEANs'));
                for k:= 0 to mEANs.Count -1 do begin
                  mEANs.BusinessObject[k].MarkForDelete;
                end;
                if mUnits.BusinessObject[j].GetFieldValueAsString('Code') = mBO.GetFieldValueAsString('MainUnitCode') then begin
                  mUnits.BusinessObject[j].SetFieldValueAsFloat('Weight', NxIBStrToFloat(NxSearchReplace(mWeight, ',', '.', [srAll])));
                  mEANBO:= mEANs.AddNewObject;
                  mEANBO.SetFieldValueAsString('EAN', mEAN);
                  //mUnits.BusinessObject[j].SetFieldValueAsString('EAN', mEAN);
                  mEANBO.SetFieldValueAsString('Parent_ID.EAN', mEAN);
                end;
              end;
              mBO.SetFieldValueAsFloat('IntrastatWeight', NxIBStrToFloat(mIntrastatWeight));
              mBO.SetFieldValueAsString('X_KatalogNo', mCatalogNumberUK);
              mBO.SetFieldValueAsString('X_Typ_Produktu', mProductTypeID);
              mBO.SetFieldValueAsString('U_Druh_ID', mKindID);
              mBO.SetFieldValueAsString('U_Provedeni_ID', mStyleID);
              mBO.SetFieldValueAsString('U_Velikost_ID', mSizeID);
              mBO.SetFieldValueAsString('U_Barva_ID', mColorID);
              mBO.SetFieldValueAsString('U_Material', mCollection);
              mBO.SetFieldValueAsString('X_MAT1', mMat1ID);
              mBO.SetFieldValueAsFloat('X_MAT1_PROC', NxIBStrToFloat(mMatProc1));
              mBO.SetFieldValueAsString('X_MAT2', mMat2ID);
              mBO.SetFieldValueAsFloat('X_MAT2_PROC', NxIBStrToFloat(mMatProc2));
              mBO.SetFieldValueAsString('X_MAT3', mMat3ID);
              mBO.SetFieldValueAsFloat('X_MAT3_PROC', NxIBStrToFloat(mMatProc3));
              mBO.SetFieldValueAsString('X_MAT4', mMat4ID);
              mBO.SetFieldValueAsFloat('X_MAT4_PROC', NxIBStrToFloat(mMatProc4));
              mBO.Save;

              //Nakopirujeme StoreMenu zarazeni z puvodni karty
              //CloneStoreCardRelatedObjects(mOS, 'StoreCardMenuItemLinks', Class_StoreCardMenuItemLink, mOrigOID, mBO.OID, mErrLog);

              //Nakopirujeme Suppliers z puvodni karty
              CloneStoreCardRelatedObjects(mOS, 'Suppliers', Class_Supplier, mOrigOID, mBO.OID, mErrLog);

              //Nakopirujeme Subscribers z puvodni karty
              CloneStoreCardRelatedObjects(mOS, 'Subscribers', Class_Subscriber, mOrigOID, mBO.OID, mErrLog);

              ProgressSetPos(i);
            except
              mErrLog:= mErrLog + #10#13 + 'Chyba u importovaného řádku: '+IntToStr(i)+' '+ExceptionMessage;
              continue;
            end;
          finally
            mBO.Free;
          end;
        end;
      finally
        mOrigBO.Free;
        objWorkbook.close;
        mExcel.Quit;
        mExcel:= nil;
        mXLS:= nil;
        ProgressDispose();
      end;
    end;
    mOpenDialog.Free;
    TBusRollSiteForm(mSite).RefreshData;
    TBusRollSiteForm(mSite).DataSet.SeekID(mOrigOID);
    if not(NxIsBlank(mErrLog)) then begin
      NxShowEditorSite(NxCreateContext(mOS), mErrLog, false);
    end else begin
      NxShowSimpleMessage('Klonování úspěšně dokončeno', mSite);
    end;
  end else
  begin
    NxShowSimpleMessage('Není vybrána žádná skladová karta, ukončuji', mSite);
  end;
end;

procedure ImportVATRatesToSC(Sender: TComponent);
var
  mSite: TSiteForm;
  mOpenDialog: TOpenDialog;
  mOS: TNxCustomObjectSpace;
  mBO, mRate: TNxCustomBusinessObject;
  mVATRates: TNxCustomBusinessMonikerCollection;
  objWorkbook, mXLS, mExcel: Variant;
  mExcelFileName, mErrLog, mStoreCard_ID, mCardCode, mCountry_ID, mVATRate_ID, mRateExists: string;
  mCountryCodeList: TStringList;
  i, j, k: integer;
begin
  mSite := Sender.Site;
  mOpenDialog := TOpenDialog.Create(mSite);
  mOS:= Sender.Site.BaseObjectSpace;
  try
    mExcel := CreateOleObject('Excel.Application');
  except
    NxShowSimpleMessage('Není nainstalovaný Microsoft Excel.', mSite);
    exit;
  end;
  mOpenDialog.Filter := 'Soubor importu (*.xls,*.xlsx)|*.XLS;*.xlsx';
  //mOpenDialog.Options := [ofAllowMultiSelect];
  if mOpenDialog.Execute then
  begin
    try
      mExcelFileName := mOpenDialog.FileName;
      objWorkbook:= mExcel.WorkBooks.Open(mExcelFileName);
      mXLS:= mExcel.ActiveWorkbook.WorkSheets[1];
      ProgressInit(mSite, 'Importování...', mXLS.UsedRange.Rows.Count);
      mErrLog:= '';
      for i:= 2 to mXLS.UsedRange.Rows.Count do
      begin
        mCardCode:= VarToStr(mXLS.Cells[i,1]);
        mStoreCard_ID:= mOS.SQLSelectFirstAsString(' SELECT ID FROM StoreCards WHERE Hidden=''N'' '+cSQL_X_Aktivni+' AND Code='+QuotedStr(mCardCode));
        if not NxIsEmptyOID(mStoreCard_ID) then
        begin
          mBO:= mOS.CreateObject(Class_StoreCard);
          try
            mBO.Load(mStoreCard_ID, nil);
            mVATRates:= mBO.GetLoadedCollectionMonikerForFieldCode(mBO.GetFieldCode('VATRates'));
            for k:= 6 to 32 do begin
              mCountry_ID:= mOS.SQLSelectFirstAsString(' SELECT ID FROM Countries WHERE Hidden=''N'' AND Code='+QuotedStr(VarToStr(mXLS.Cells[1,k])));
              mVATRate_ID:= mOS.SQLSelectFirstAsString(' SELECT ID FROM VATRates WHERE Hidden=''N'' AND Country_ID='+QuotedStr(mCountry_ID)+' AND Tariff='+QuotedStr(VarToStr(mXLS.Cells[i,k])));
              mRateExists:= mOS.SQLSelectFirstAsString(' SELECT ID FROM StoreCardVATRates WHERE Parent_ID='+QuotedStr(mStoreCard_ID)+' AND Country_ID='+QuotedStr(mCountry_ID)+' AND VATRate_ID='+QuotedStr(mVATRate_ID));
              if not(NxIsEmptyOID(mRateExists)) then continue;
              mRate:= mVATRates.AddNewObject;
              //mRate.Prefill;
              mRate.SetFieldValueAsString('Country_ID', mCountry_ID);
              mRate.SetFieldValueAsString('VATRate_ID', mVATRate_ID);
            end;
              mBO.Save;
          finally
            mBO.Free;
            ProgressSetPos(i);
          end;
        end else
        begin
          mErrLog:= #10+'Karta s kódem '+mCardCode+' nenalezena.';
          continue;
        end;
      end;
    finally
      //mCountryCodeList.Free;
      mOpenDialog.Free;
      objWorkbook.close;
      mExcel.Quit;
      mExcel:= nil;
      mXLS:= nil;
      ProgressDispose();
      TBusRollSiteForm(mSite).RefreshData;
    end;
  end;
end;

procedure ActualizeVATRatesToSC(Sender: TComponent);
var
  mSite: TSiteForm;
  mOpenDialog: TOpenDialog;
  mOS: TNxCustomObjectSpace;
  mBO, mRate: TNxCustomBusinessObject;
  mVATRates: TNxCustomBusinessMonikerCollection;
  objWorkbook, mXLS, mExcel: Variant;
  mExcelFileName, mErrLog, mStoreCard_ID, mCardCode, mCountry_ID, mVATRate_ID, mRateExists: string;
  mCountryCodeList, mList: TStringList;
  i, j, k: integer;
begin
  mSite := Sender.Site;
  mOpenDialog := TOpenDialog.Create(mSite);
  mOS:= Sender.Site.BaseObjectSpace;
  mList:= TStringList.Create;
  try
    {
    mOS.SQLSelect(
      ' SELECT DISTINCT(SC.ID) FROM StoreCards SC '+
      ' JOIN StoreCardVATRates SCVR ON SC.ID = SCVR.Parent_ID '+
      ' JOIN VATRates VR ON VR.ID = SCVR.VATRate_ID '+
      ' WHERE VR.Hidden = ''A'' ', mList);
      }
    TBusRollSiteForm(mSite).FillListWithSelectedRows(mList);
    for i:= 0 to mList.Count -1 do begin
      mBO:= mOS.CreateObject(Class_StoreCard);
      try
        mBO.Load(mList[i], nil);
        mVATRates:= mBO.GetLoadedCollectionMonikerForFieldCode(mBO.GetFieldCode('VATRates'));
        for j:= 0 to mVATRates.Count -1 do begin
          if (mVATRates.BusinessObject[j].GetFieldValueAsBoolean('VATRate_ID.Hidden') = true)
          {and (mVATRates.BusinessObject[j].GetFieldValueAsString('VATRate_ID.Country_ID') in ['00000EE000','00000LU000'])} then begin
            mVATRate_ID:= mOS.SQLSelectFirstAsString(
              ' SELECT VR.ID FROM VATRates VR '+
              ' JOIN VATRates2 VR2 ON VR2.Parent_ID = VR.ID '+
              ' WHERE Hidden = ''N'' '+
              ' AND VR2.Ancestor_ID = '+QuotedStr(mVATRates.BusinessObject[j].GetFieldValueAsString('VATRate_ID'))+
              ' AND VR2.ValidFromDate$DATE <= '+NxDateToStr(Date)+
              ' AND ((VR2.ValidToDate$DATE >= '+NxDateToStr(Date)+') OR (VR2.ValidToDate$DATE = 0)) '+
              ' AND Country_ID = '+QuotedStr(mVATRates.BusinessObject[j].GetFieldValueAsString('Country_ID')));
            if NxIsEmptyOID(mVATRate_ID) then begin
              mVATRate_ID:= mOS.SQLSelectFirstAsString(
                ' SELECT VR.ID FROM VATRates VR '+
                ' JOIN VATRates2 VR2 ON VR2.Parent_ID = VR.ID '+
                ' WHERE Hidden = ''N'' '+
                ' AND VR.VATRateType = '+IntToStr(mVATRates.BusinessObject[j].GetFieldValueAsInteger('VATRate_ID.VATRateType'))+
                ' AND VR2.ValidFromDate$DATE <= '+NxDateToStr(Date)+
                ' AND ((VR2.ValidToDate$DATE >= '+NxDateToStr(Date)+') OR (VR2.ValidToDate$DATE = 0)) '+
                ' AND Country_ID = '+QuotedStr(mVATRates.BusinessObject[j].GetFieldValueAsString('Country_ID')));
            end;
            if not(NxIsEmptyOID(mVATRate_ID)) then mVATRates.BusinessObject[j].SetFieldValueAsString('VATRate_ID', mVATRate_ID);
          end;
        end;
        mBO.Save;
      finally
        mBO.Free;
      end;
    end;
  finally
    mList.Free;
  end;
  NxShowSimpleMessage('Hotovo', mSite);
end;


procedure GenerateNewEAN(Sender: TComponent);
var
  mBO: TNxCustomBusinessObject;
  mUnits: TNxCustomBusinessMonikerCollection;
  mOS: TNxCustomObjectSpace;
  mSite: TSiteForm;
  mForm: TForm;
  mCBPrefix: TComboBox;
  mLbl: TLabel;
  mButOk, mButCancel: TButton;
  mEAN, mPrefix: string;
  i: integer;
begin
  mSite := Sender.Site;
  mOS:= Sender.Site.BaseObjectSpace;
  mBO:= TBusRollSiteForm(mSite).CurrentObject;
  mEAN:= '';
  mPrefix:= '';

  mForm:= TForm.Create(mSite);
  mForm.Width:= 230;
  mForm.Height:= 150;
  mForm.Position:=poScreenCenter;
  mForm.Caption := 'Vyberte prefix';
  mForm.OnCloseQuery:= @OnFormCloseAction;

  mLbl:= TLabel.Create(mForm);
  mLbl.Parent:= mForm;
  mLbl.Caption:= 'Prefix:';
  mLbl.Top:= 15;
  mLbl.Left:= 15;
  mLbl.Width:= 50;

  mCBPrefix:= TComboBox.Create(mForm);
  mCBPrefix.Parent:= mForm;
  mCBPrefix.Top:= 15;
  mCBPrefix.Left:= 80;
  mCBPrefix.Width:= 120;
  mCBPrefix.Items.Add('222');
  mCBPrefix.Items.Add('8591846');
  mCBPrefix.ItemIndex:= 0;

  mButOk:= TButton.Create(mForm);
  mButOk.Parent := mForm;
  mButOk.Default:= true;
  mButOk.Caption := 'OK';
  mButOk.Top := 50;
  mButOk.Left := 15;
  mButOk.Height := 24;
  mButOk.Width := 62;
  mButOk.ModalResult := mrOk;

  mButCancel := TButton.Create(mForm);
  mButCancel.Parent := mForm;
  mButCancel.Caption := 'Zrušit';
  mButCancel.Top := 50;
  mButCancel.Left := 140;
  mButCancel.Height := 24;
  mButCancel.Width := 62;
  mButCancel.ModalResult := mrCancel;

  if mForm.ShowModal(mSite) = mrOk then begin
    mPrefix:= mCBPrefix.Text;
    try
      mUnits:= mBO.GetLoadedCollectionMonikerForFieldCode(mBO.GetFieldCode('StoreUnits'));
      for i:= 0 to mUnits.Count -1 do begin
        if (mUnits.BusinessObject[i].GetFieldValueAsString('Code') = mBO.GetFieldValueAsString('MainUnitCode')) and (NxIsBlank(mUnits.BusinessObject[i].GetFieldValueAsString('EAN'))) then begin
          mEAN:= GetLatestEAN(mOS, mPrefix, 13);
          mUnits.BusinessObject[i].SetFieldValueAsString('EAN', mEAN);
        end;
      end;
      mBO.Save;
      //NxShowSimpleMessage(mEAN, mSite);
    finally
      TBusRollSiteForm(mSite).RefreshData;
      TBusRollSiteForm(mSite).DataSet.SeekID(mBO.OID);
      mBO.Free;
    end;
  end;
  mForm.Free;
end;

procedure OnFormCloseAction(Sender: TObject; var Action: TCloseAction);
begin
  if Action = caHide then TForm(Sender).ModalResult := mrCancel;
end;


procedure ImportStoreCardParameters(Sender: TComponent);
var
  mSCBO, mParBO: TNxCustomBusinessObject;
  mOS: TNxCustomObjectSpace;
  mSite: TSiteForm;
  mList: TStringList;
  mExcel, mWB, mXLS: Variant;
  mOpenDlg: TOpenDialog;
  mFileName, mErrLog: string;
  mAssortmentGroup_ID, mAssortmentGroupParent_ID, mTypeMD_ID, mGroup_ID, mGMDN_ID, mCategory_ID, mCollection_ID, mBatch_ID, mStatistics_ID, mBrand_ID: string;
  mProductType_ID, mKind_ID, mFinish_ID, mColor_ID, mSize_ID, mPackaging_ID, mStoreCard_ID, mTypeMDName :string;
  mTypeName, mGroupName, mGMDNName, mCollectionName, mKindName, mFinishName, mColorName, mSizeName, mPackagingName: string;
  mAGName, mAGParentName, mID, mProdVersion, mActiveStr, mSterileStr, mSiciDavkaStr, mCompression, mREFUK, mPicture: string;
  mMAT1, mMAT2, mMAT3, mMAT4, mMATPerc1, mMATPerc2, mMATPerc3, mMATPerc4, mWashingSymbol, mTrademark, mTextilLabel: string;
  mCategoryName, mStatistics, mParentName, mParentStr, mNameSK, mNameUE, mNameIT, mNameDE, mBasicBox, mBagType, mMedicalAidType, mProductionEnd: string;
  mNDGroup_ID, mSCCategory_ID, mParent_ID, mBox_ID, mBag_ID: string;
  mActive, mSterile, mParentBool, mProdEnd: boolean;
  i: integer;

begin
  mSite := Sender.Site;
  mOpenDlg := TOpenDialog.Create(mSite);
  mOS:= Sender.Site.BaseObjectSpace;
  try
    mExcel := CreateOleObject('Excel.Application');
  except
    NxShowSimpleMessage('Není nainstalovaný Microsoft Excel.', mSite);
    exit;
  end;
  mOpenDlg.Filter := 'Soubor importu (*.xls,*.xlsx)|*.XLS;*.xlsx';
  if mOpenDlg.Execute then
  begin
    try
      mFileName := mOpenDlg.FileName;
      mWB:= mExcel.WorkBooks.Open(mFileName);
      mXLS:= mExcel.ActiveWorkbook.WorkSheets[1];
      ProgressInit(mSite, 'Importování...', mXLS.UsedRange.Rows.Count);
      mErrLog:= '';
      for i:= 2 to mXLS.UsedRange.Rows.Count do
      begin
        if NxIsBlank(VarToStr(mXLS.Cells[i,1])) then exit;
        mAGName:=         VarToStr(mXLS.Cells[i,1]);
        mAGParentName:=   VarToStr(mXLS.Cells[i,2]);
        mID:=             VarToStr(mXLS.Cells[i,3]);
        mProdVersion:=    VarToStr(mXLS.Cells[i,5]);
        mTypeMDName:=     VarToStr(mXLS.Cells[i,6]);
        mGMDNName:=       VarToStr(mXLS.Cells[i,7]);
        mActiveStr:=      VarToStr(mXLS.Cells[i,8]);
        mSterileStr:=     VarToStr(mXLS.Cells[i,9]);
        mSiciDavkaStr:=   VarToStr(mXLS.Cells[i,10]);
        mCompression:=    VarToStr(mXLS.Cells[i,11]);
        mREFUK:=          VarToStr(mXLS.Cells[i,12]);
        mCollectionName:= VarToStr(mXLS.Cells[i,13]);
        mTypeName:=       VarToStr(mXLS.Cells[i,14]);   //?
        mKindName:=       VarToStr(mXLS.Cells[i,15]);   //?
        mFinishName:=     VarToStr(mXLS.Cells[i,16]);
        mColorName:=      VarToStr(mXLS.Cells[i,17]);
        mSizeName:=       VarToStr(mXLS.Cells[i,18]);
        mPackagingName:=  VarToStr(mXLS.Cells[i,19]);
        mPicture:=        VarToStr(mXLS.Cells[i,20]);
        mMAT1:=           VarToStr(mXLS.Cells[i,21]);
        mMATPerc1:=       VarToStr(mXLS.Cells[i,22]);
        mMAT2:=           VarToStr(mXLS.Cells[i,23]);
        mMATPerc2:=       VarToStr(mXLS.Cells[i,24]);
        mMAT3:=           VarToStr(mXLS.Cells[i,25]);
        mMATPerc3:=       VarToStr(mXLS.Cells[i,26]);
        mMAT4:=           VarToStr(mXLS.Cells[i,27]);
        mMATPerc4:=       VarToStr(mXLS.Cells[i,28]);
        mWashingSymbol:=  VarToStr(mXLS.Cells[i,29]);
        mTrademark:=      VarToStr(mXLS.Cells[i,30]);
        //mTextilLabel:=    VarToStr(mXLS.Cells[i,31]);
        mGroupName:=      VarToStr(mXLS.Cells[i,31]);
        mCategoryName:=   VarToStr(mXLS.Cells[i,32]);
        mStatistics:=     VarToStr(mXLS.Cells[i,33]);
        mParentName:=     VarToStr(mXLS.Cells[i,34]);
        mParentStr:=     VarToStr(mXLS.Cells[i,35]);
        mNameSK:=         VarToStr(mXLS.Cells[i,36]);
        mNameUE:=         VarToStr(mXLS.Cells[i,37]);
        mNameIT:=         VarToStr(mXLS.Cells[i,38]);
        mNameDE:=         VarToStr(mXLS.Cells[i,39]);
        mBasicBox:=       VarToStr(mXLS.Cells[i,41]);
        mBagType:=        VarToStr(mXLS.Cells[i,42]);
        mMedicalAidType:= VarToStr(mXLS.Cells[i,43]);
        mProductionEnd:=  VarToStr(mXLS.Cells[i,44]);



        mID:= NxSearchReplace(mID, '_', '', [srAll]);
        mStoreCard_ID:= mOS.SQLSelectFirstAsString('SELECT ID FROM StoreCards WHERE Hidden=''N'' AND ID='+QuotedStr(mID));
        if NxIsEmptyOID(mStoreCard_ID) then continue;

        mAssortmentGroup_ID:= mOS.SQLSelectFirstAsString('SELECT ID FROM StoreAssortmentGroups WHERE Hidden=''N'' AND Name='+QuotedStr(mAGName));
        mGMDN_ID:= mOS.SQLSelectFirstAsString('SELECT ID FROM DefRollData WHERE CLSID = '+QuotedStr(Class_UserRollBusinessObject_GMDN)+' AND Code = '+QuotedStr(mGMDNName));
        //mSCCategory_ID:= mOS.SQLSelectFirstAsString('SELECT ID FROM StoreCardCategories WHERE Hidden=''N'' AND Name='+QuotedStr(mCategoryName));
        //mStatistics_ID:= mOS.SQLSelectFirstAsString('SELECT ID FROM DefRollData WHERE CLSID='+QuotedStr('3VBS22GA2LH4HCYLOVOGHT0YJG')+' Hidden=''N'' AND Name='+QuotedStr(mStatistics));
        //mParent_ID:= mOS.SQLSelectFirstAsString('SELECT ID FROM StoreCards WHERE Hidden=''N'' AND Name='+QuotedStr(mParentName));
        //mBox_ID:= mOS.SQLSelectFirstAsString('SELECT ID FROM StoreCards WHERE Hidden=''N'' AND Code='+QuotedStr(mBasicBox));
        //mBag_ID:= mOS.SQLSelectFirstAsString('SELECT ID FROM StoreCards WHERE Hidden=''N'' AND Code='+QuotedStr(mBagType));
        mBrand_ID:= GetIDFromDefRoll(mOS, Class_Brand, mTrademark);
        mTypeMD_ID:= GetIDFromDefRoll(mOS, Class_Zdravotni_prostredek, mTypeMDName);

        //mNDGroup_ID:= GetIDFromDefRoll(mOS, Class_BO_ND_Group, mGroupName);

        if mActiveStr = 'Ano' then mActive:= true else mActive:= false;
        if mSterileStr = 'Ano' then mSterile:= True else mSterile:= false;
        if mParentStr = 'Ano' then mParentBool:= True else mParentBool:= false;
        if mProductionEnd = 'Ano' then mProdEnd:= true else mProdEnd:= false;

        //DOPLNENI VLASTNOSTI KARTY
        mSCBO:= mOS.CreateObject(Class_StoreCard);
        try
          mSCBO.Load(mID, nil);
          if not(NxIsEmptyOID(mAssortmentGroup_ID)) then mSCBO.SetFieldValueAsString('StoreAssortmentGroup_ID', mAssortmentGroup_ID);
          if not(NxIsEmptyOID(mTypeMD_ID)) then mSCBO.SetFieldValueAsString('U_Typ_zdravotiho_prostredu', mTypeMD_ID);
          //if not(NxIsEmptyOID(mSCCategory_ID)) then mSCBO.SetFieldValueAsString('StoreCardCategory_ID', mSCCategory_ID);
          mSCBO.SetFieldValueAsBoolean('X_Aktivni', mActive);
          mSCBO.SetFieldValueAsBoolean('X_Sterilni', mSterile);
          //mSCBO.SetFieldValueAsBoolean('X_Matka', mParentBool);
          //mSCBO.SetFieldValueAsBoolean('X_Konec_Vyroby', mProdEnd);
          mSCBO.SetFieldValueAsInteger('X_Davka_sici', StrToInt(mSiciDavkaStr));
          mSCBO.SetFieldValueAsString('X_KatalogNo', mREFUK);
          mSCBO.SetFieldValueAsString('X_GMDN', mGMDN_ID);
          mSCBO.SetFieldValueAsString('X_Brand_ID', mBrand_ID);
          //mSCBO.SetFieldValueAsString('X_Statistika', mStatistics_ID);
          //mSCBO.SetFieldValueAsString('X_Parent_ID', mParent_ID);
          //mSCBO.SetFieldValueAsString('X_Name_SK', mNameSK);
          //mSCBO.SetFieldValueAsString('X_Name_UE', mNameUE);
          //mSCBO.SetFieldValueAsString('X_Name_IT', mNameIT);
          //mSCBO.SetFieldValueAsString('X_Name_DE', mNameDE);
          //mSCBO.SetFieldValueAsString('X_Krabicka_ID', mBox_ID);
          //mSCBO.SetFieldValueAsString('X_Sacek_ID', mBag_ID);


          mSCBO.Save;
        finally
          mSCBO.Free;
        end;

        //DOPLNENI PARAMETRU KE KARTE
        //UpdateOrCreateParameterRelation(mOS, mStoreCard_ID, Class_BO_ND_GMDN, 'Code', 'GMDN', mGMDNName, nil, nil);
        UpdateOrCreateParameterRelation(mOS, mStoreCard_ID, Class_BO_ND_Compression, 'Name', 'Komprese', mCompression, nil, nil);
        UpdateOrCreateParameterRelation(mOS, mStoreCard_ID, Class_BO_ND_Collection, 'Name','Kolekce', mCollectionName, nil, nil);
        UpdateOrCreateParameterRelation(mOS, mStoreCard_ID, Class_BO_ND_Type, 'Name', 'Typ', mTypeName, nil, nil);
        UpdateOrCreateParameterRelation(mOS, mStoreCard_ID, Class_BO_ND_Kind, 'Name', 'Druh', mKindName, nil, nil);
        UpdateOrCreateParameterRelation(mOS, mStoreCard_ID, Class_BO_ND_Finish, 'Name', 'Provedení', mFinishName, nil, nil);
        UpdateOrCreateParameterRelation(mOS, mStoreCard_ID, Class_BO_ND_Color, 'Name', 'Barva', mColorName, nil, nil);
        UpdateOrCreateParameterRelation(mOS, mStoreCard_ID, Class_BO_ND_Size, 'Name', 'Velikost', mSizeName, nil, nil);
        UpdateOrCreateParameterRelation(mOS, mStoreCard_ID, Class_BO_ND_UnitsPerPackage, 'Name', 'Počet ks v balení', mPackagingName, nil, nil);
        //UpdateOrCreateParameterRelation(mOS, mStoreCard_ID, Class_BO_ND_Group, 'Name', 'Skupina', mGroupName, nil, nil);

        //DOPLNENI MATERIALU KE KARTE
        DeleteAllMaterialRelations(mOS, mStoreCard_ID);
        UpdateOrCreateMaterialRelation(mOS, mStoreCard_ID, mMAT1, NxIBStrToFloat(mMATPerc1));
        UpdateOrCreateMaterialRelation(mOS, mStoreCard_ID, mMAT2, NxIBStrToFloat(mMATPerc2));
        UpdateOrCreateMaterialRelation(mOS, mStoreCard_ID, mMAT3, NxIBStrToFloat(mMATPerc3));
        UpdateOrCreateMaterialRelation(mOS, mStoreCard_ID, mMAT4, NxIBStrToFloat(mMATPerc4));

        ProgressSetPos(i);
      end;
    finally
      mWB.close;
      mExcel.Quit;
      mExcel:= nil;
      mXLS:= nil;
      ProgressDispose();
      mOpenDlg.Free;
      TBusRollSiteForm(mSite).RefreshData;
      //TBusRollSiteForm(mSite).DataSet.SeekID(mBO);
    end;
    if not(NxIsBlank(mErrLog)) then begin
      NxShowEditorSite(NxCreateContext(mOS), mErrLog, false);
    end else begin
      NxShowSimpleMessage('Dokončeno', mSite);
    end;

  end;
end;


function GetIDFromDefRoll(AOS: TNxCustomObjectSpace; ACLSID, ACode: string;): string;
begin
  Result:= '';
  if not(NxIsBlank(ACode)) then begin
    Result:= AOS.SQLSelectFirstAsString(
      ' SELECT ID FROM DefRollData '+
      ' WHERE Hidden=''N'' '+
      ' AND CLSID='+QuotedStr(ACLSID)+
      ' AND Name='+QuotedStr(ACode));
  end;
end;

function UpdateOrCreateParameterRelation(AOS: TNxCustomObjectSpace; AStoreCard_ID, ACLSID, AField, AParameterName, AValueName: string; ABoolValue: Boolean; ANumValue: Extended):string;
var
  mParBO: TNxCustomBusinessObject;
  mParam_ID, mRollValue_ID, mParameter_ID, mPosIndex: string;
  mParType: integer;
begin
  Result:= '';
  mParType:= AOS.SQLSelectFirstAsInteger(
    ' SELECT X_TypeOfValue FROM DefRollData '+
    ' WHERE CLSID ='+QuotedStr(Class_BOSCParameters)+
    ' AND '+AField+' = '+QuotedStr(AParameterName));

  mParameter_ID:= AOS.SQLSelectFirstAsString(
    ' SELECT DRD.ID FROM DefRollData DRD '+
    ' WHERE DRD.CLSID='+QuotedStr(Class_BOSCParameters)+
    ' AND DRD.'+AField+'='+QuotedStr(AParameterName));

  if NxIsEmptyOID(mParameter_ID) then exit;
  if (mParType in [0,1]) and (NxIsBlank(AValueName)) then exit;

  mParam_ID:= AOS.SQLSelectFirstAsString(
    ' SELECT DRD.ID FROM DefRollData DRD '+
    ' JOIN DefRollData PAR ON DRD.X_Parameter_ID = PAR.ID '+
    ' WHERE DRD.CLSID = '+QuotedStr(Class_BO_Relations)+
    ' AND DRD.X_Value_ID = '+QuotedStr(AStoreCard_ID)+
    ' AND DRD.X_Rel_Def = ''10'' '+
    ' AND PAR.'+AField+' = '+QuotedStr(AParameterName));

  mParBO:= AOS.CreateObject(Class_BO_Relations);
  try
    if not(NxIsEmptyOID(mParam_ID)) then begin
      mParBO.Load(mParam_ID, nil);
    end else begin
      mParBO.New;
      mPosIndex:= AOS.SQLSelectFirstAsString('SELECT MAX(X_PosIndex) FROM DefRollData WHERE Hidden=''N'' AND X_Rel_Def=''10'' AND X_Value_ID='+QuotedStr(AStoreCard_ID));
      if NxIsBlank(mPosIndex) then mPosIndex:= '00';
      mPosIndex:= NxPadL(IntToStr(StrToInt(mPosIndex)+1), 2, '0');
      mParBO.SetFieldValueAsString('X_PosIndex', mPosIndex);
    end;
    case mParType of
      0:  begin
        mParBO.SetFieldValueAsString('X_ParamValue', AValueName);
        mParBO.SetFieldValueAsString('X_RollValueID','');
        mParBO.SetFieldValueAsString('X_RollValueName','');
        mParBO.SetFieldValueAsString('X_BOCLSID','');
        mParBO.SetFieldValueAsFloat('X_NumericValue',0);
        mParBO.SetFieldValueAsBoolean('X_BooleanValue',false);
      end;
      1:  begin
        mRollValue_ID:= GetIDFromDefRoll(AOS, ACLSID, AValueName);
        mParBO.SetFieldValueAsString('X_ParamValue','');
        mParBO.SetFieldValueAsString('X_RollValueID', mRollValue_ID);
        mParBO.SetFieldValueAsString('X_RollValueName', AValueName);
        mParBO.SetFieldValueAsString('X_BOCLSID', ACLSID);
        mParBO.SetFieldValueAsFloat('X_NumericValue',0);
        mParBO.SetFieldValueAsBoolean('X_BooleanValue',false);
      end;
      2:  begin
        mParBO.SetFieldValueAsString('X_ParamValue','');
        mParBO.SetFieldValueAsString('X_RollValueID','');
        mParBO.SetFieldValueAsString('X_RollValueName','');
        mParBO.SetFieldValueAsString('X_BOCLSID','');
        mParBO.SetFieldValueAsFloat('X_NumericValue', ANumValue);
        mParBO.SetFieldValueAsBoolean('X_BooleanValue',false);
      end;
      3:  begin
        mParBO.SetFieldValueAsString('X_ParamValue','');
        mParBO.SetFieldValueAsString('X_RollValueID','');
        mParBO.SetFieldValueAsString('X_RollValueName','');
        mParBO.SetFieldValueAsString('X_BOCLSID','');
        mParBO.SetFieldValueAsFloat('X_NumericValue',0);
        mParBO.SetFieldValueAsBoolean('X_BooleanValue', ABoolValue);
      end;
    end;
    mParBO.SetFieldValueAsString('X_Value_ID', AStoreCard_ID);
    mParBO.SetFieldValueAsString('X_Parameter_ID', mParameter_ID);
    mParBO.SetFieldValueAsString('X_rel_def', '10');
    mParBO.SetFieldValueAsDateTime('X_DateTimeOfLastChange',Now);
    mParBO.Save;
    Result:= mParBO.OID;
  finally
    mParBO.Free;
  end;
end;

function UpdateOrCreateMaterialRelation(AOS: TNxCustomObjectSpace; AStoreCard_ID, AColor: string; APercent: Extended;):string;
var
  mParBO: TNxCustomBusinessObject;
  mParam_ID, mRollValue_ID, mMaterial_ID, mPosIndex: string;
  mParType: integer;
begin
  Result:= '';
  if NxIsBlank(AColor) then exit;
  mMaterial_ID:= GetIDFromDefRoll(AOS, Class_BO_ND_Materials, AColor);
  //NxShowSimpleMessage(mMaterial_ID, nil);
  if not(NxIsEmptyOID(mMaterial_ID)) then begin
    mPosIndex:= AOS.SQLSelectFirstAsString('SELECT MAX(X_PosIndex) FROM DefRollData WHERE Hidden=''N'' AND X_Rel_Def=''06'' AND X_Value_ID='+QuotedStr(AStoreCard_ID));
    if NxIsBlank(mPosIndex) then mPosIndex:= '00';
    mPosIndex:= NxPadL(IntToStr(StrToInt(mPosIndex)+1), 2, '0');
    mParBO:= AOS.CreateObject(Class_BO_Relations);
    try
      mParBO.New;

      mParBO.SetFieldValueAsString('X_Value_ID', AStoreCard_ID);
      mParBO.SetFieldValueAsString('X_Material_ID', mMaterial_ID);
      mParBO.SetFieldValueAsString('X_PosIndex', mPosIndex);
      mParBO.SetFieldValueAsString('X_rel_def', '06');
      mParBO.SetFieldValueAsFloat('X_NumericValue', APercent);

      mParBO.Save;
      Result:= mParBO.OID;
    finally
      mParBO.Free;
    end;
  end;
end;


function DeleteAllMaterialRelations(AOS: TNxCustomObjectSpace; AStoreCard_ID: string;):string;
var
  mPARBO: TNxCustomBusinessObject;
  mList: TStringList;
  i: Integer;
begin
  mList:= TStringList.Create;
  try
    AOS.SQLSelect('SELECT ID FROM DefRollData WHERE Hidden=''N'' AND X_Rel_def=''06'' AND X_Value_ID='+QuotedStr(AStoreCard_ID), mList);
    for i:= 0 to mList.Count -1 do begin
      mPARBO:= AOS.CreateObject(Class_BO_Relations);
      try
        mPARBO.Load(mList[i], nil);
        mPARBO.Delete;
      finally
        mPARBO.Free;
      end;
    end;
  finally
    mList.Free;
  end;
end;


begin
end.