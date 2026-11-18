uses 'eu.abra.alec.Lipoelastic.EkoKomImport.fce';

const
  cSQL_X_Aktivni = ' AND X_Aktivni = ''A'' ';

{
Vyvolává se po provedení inicializace agendy/formuláře. V tento okamžik je již na formuláři dostupný SiteContext.
}
procedure InitSite_Hook(Self: TSiteForm);
var
  mAction: TMultiAction;
begin
  mAction := Self.GetNewMultiAction;
  mAction.ShowControl := True;
  mAction.ShowMenuItem := True;
  mAction.Caption := '## Eko-Kom Importy ##';
  mAction.Items.Add('EKO-KOM - Import výrobků');
  mAction.Items.Add('EKO-KOM - Import obalů');
  mAction.Hint := 'Import pro výrobky, zboží a obaly';
  mAction.Category := 'tabList';
  mAction.OnExecuteItem := @actEkoKomImport;
end;

{
procedure EkoKomImportSwitch(Sender: TComponent; Index: Integer);
begin
  case Index of
    0: actEkoKomImport(Sender);
    1: ImportRoutine(Sender);
  end;
end;
}


Procedure actEkoKomImport(sender:TComponent; Index: integer;);
var
  mExcel, objWorkbook, mXLSPackaging, mXLSProduct: Variant;
  mOpenDialog: TOpenDialog;
  mExcelFileName: String;
  mSite : TSiteForm;
  mOS: TNxCustomObjectSpace;
  mBO, mOrigBO, mUnit, mSCBO: TNxCustomBusinessObject;
  mUnits: TNxCustomBusinessMonikerCollection;
  i, j: Integer;
  mCode, mName, mMainUnitCode, mEAN, mPackagingMat, mMaterialGroup, mPackagingColor, mTradeType, mEANType, mStoreCardID, mErrLog: string;
  mIsComposit, mUsageType, mIntroductionType, mMaterialOrigin, mCharged, mReusable, mLittering, mQuantity, mWeight: string;
  mPackagingCardID, mRecordID, mRecordUnit, mPackingStoreCard :string;
  mMatList, mSkupinaList, mBarvaList: TStringList;
  mIsCompositList, mTradeTypeList, mUsageTypeList, mIntroductionTypeList, mMaterialOriginList, mChargedList, mReusableList, mLitteringList: TStringList;
  mIntPackagingMat, mIntMatGroup, mIntPackagingColor: integer;
  mIsCompositInt, mTradeTypeInt, mUsageTypeInt, mIntroductionTypeInt, mMaterialOriginInt, mChargedInt, mReusableInt, mLitteringInt: integer;

begin
  mSite := Sender.Site;
  mOpenDialog := TOpenDialog.Create(mSite);
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
      mExcel.Application.WorkBooks.Open(mExcelFileName);
      mXLSPackaging:= mExcel.Application.ActiveWorkbook.WorkSheets[1];
      mXLSProduct :=  mExcel.Application.ActiveWorkbook.WorkSheets[2];
      mOS:= Sender.Site.BaseObjectSpace;

      if Index = 1 then begin
        try
          ProgressInit(mSite, 'Import...', mXLSPackaging.UsedRange.Rows.Count);
          mMatList:= TStringList.Create;
          mSkupinaList:= TStringList.Create;
          mBarvaList:= TStringList.Create;
          FillStringListFromEnumField(mOS, mMatList,      'EKO_MaterialObalu', '2000000101');
          FillStringListFromEnumField(mOS, mSkupinaList,  'EKO_SkupinaMaterialu', '2000000101');
          FillStringListFromEnumField(mOS, mBarvaList,    'EKO_BarvaObalu', '2000000101');

          //mMatObalu.CommaText = ',Plasty PET,Plasty PE,Plasty PP,Plasty PS,Plasty XPS,Plasty EPS, Plasty PVC, Plasty jiné,Plasty biologicky rozložitelné,Plasty kompozitní,Kovy Al,Kovy Fe,Kovy kompozitní Al,Kovy kompozitní Fe,Nápojový karton,Kompozitní materiál,Sklo,Papír,Papír - hladká lepenka,Papír - vlnitá lepenka,Papír - nasávaná kartonáž,Papír kompozitní,Dřevo a dřevotříska,Dřevo - kompozit s nedřevěnými částmi,Textil,Jiné';
          for i:= 3 to mXLSPackaging.UsedRange.Rows.Count do
          begin
            mBO:= mOS.CreateObject(Class_StoreCard);
            try
              mCode :=            NxLeft(VarToStr(mXLSPackaging.Cells[i,1]), 40);
              mName :=            NxLeft(VarToStr(mXLSPackaging.Cells[i,2]), 100);
              //mEANType :=         NxLeft(VarToStr(mXLSPackaging.Cells[i,3]), 30);
              mEAN :=             NxLeft(VarToStr(mXLSPackaging.Cells[i,3]), 30);
              mMainUnitCode :=    NxLeft(VarToStr(mXLSPackaging.Cells[i,4]), 200);
              mPackagingMat :=    NxLeft(VarToStr(mXLSPackaging.Cells[i,5]), 200);
              mMaterialGroup :=   NxLeft(VarToStr(mXLSPackaging.Cells[i,6]), 200);
              mPackagingColor :=  NxLeft(VarToStr(mXLSPackaging.Cells[i,7]), 200);
              //mTradeType :=       NxLeft(VarToStr(mXLSPackaging.Cells[i,7]), 200);

              if mPackagingMat = '' then mIntPackagingMat:= 0 else mIntPackagingMat:= mMatList.IndexOf(mPackagingMat);
              if mMaterialGroup = '' then mIntMatGroup:= 0 else mIntMatGroup:= mSkupinaList.IndexOf(mMaterialGroup);
              if mPackagingColor = '' then mIntPackagingColor:= 0 else mIntPackagingColor:= mBarvaList.IndexOf(mPackagingColor);

              //mErrLog:= mErrLog+#10#13+ mMatList.Text;
              //mErrLog:= mErrLog+#10#13+ mSkupinaList.Text;
              //mErrLog:= mErrLog+#10#13+ mBarvaList.Text;

              mStoreCardID:= mOS.SQLSelectFirstAsString('SELECT ID FROM StoreCards WHERE Hidden = ''N'' '+cSQL_X_Aktivni+' AND Code ='+QuotedStr(mCode));
              if (NxIsEmptyOID(mStoreCardID)) then begin
                mErrLog:= mErrLog + #10#13 + mCode + ' - Karta s kódem '+mCode+' nenalezena, import přeskočen.';
                continue;
              end;
              if (mIntPackagingMat = -1) or (mIntMatGroup = -1) or (mIntPackagingColor = -1) then begin
                mErrLog:= mErrLog + #10#13 + mCode + ' - Nedohledán materiál obalu, Skupina materiálu nebo Barva obalu, import položky přeskočen.';
                continue;
              end;

              case mEANType of
                '':  mEAN := '';
                '2': mEAN := GetLatestEAN(mOS, '222', 13);
                '8': mEAN := GetLatestEAN(mOS, '8591846', 13);
              end;

              mBO.Load(mStoreCardID, nil);
              //mBO.SetFieldValueAsString('Code', mCode);
              //mBO.SetFieldValueAsString('Name', mName);
              mBO.SetFieldValueAsInteger('X_EKO_MaterialObalu', mIntPackagingMat);
              mBO.SetFieldValueAsInteger('X_EKO_SkupinaMaterialu', mIntMatGroup);
              mBO.SetFieldValueAsInteger('X_EKO_BarvaObalu', mIntPackagingColor);
              //mBO.SetFieldValueAsString('X_EKO_VyrazTypObchodu', mTradeType);
              mUnits:= mBO.GetLoadedCollectionMonikerForFieldCode(mBO.GetFieldCode('StoreUnits'));
              for j:= 0 to mUnits.Count -1 do begin
                if mUnits.BusinessObject[j].GetFieldValueAsString('Code') = mBO.GetFieldValueAsString('MainUnitCode') then begin
                  //mUnits.BusinessObject[j].SetFieldValueAsString('EAN', mEAN);
                end;
              end;
              mBO.Save;
              ProgressSetPos(i);
            finally
              mBO.Free;
            end;
          end;
        finally
          mMatList.Free;
          mSkupinaList.Free;
          mBarvaList.Free;
          ProgressDispose();
        end;
      end;

      //TODO předělat na import nastavení skladových karet
      if Index = 0 then begin
        try
          ProgressInit(mSite, 'Import...', mXLSProduct.UsedRange.Rows.Count);
          mIsCompositList:=       TStringList.Create;
          mTradeTypeList:=        TStringList.Create;
          mUsageTypeList:=        TStringList.Create;
          mIntroductionTypeList:= TStringList.Create;
          mMaterialOriginList:=   TStringList.Create;
          mChargedList:=          TStringList.Create;
          mReusableList:=         TStringList.Create;
          mLitteringList:=        TStringList.Create;

          FillStringListFromEnumField(mOS, mIsCompositList,       'EKO_MaterialKompozitu',  '1P00000101');
          FillStringListFromEnumField(mOS, mTradeTypeList,        'EKO_TypObchodu',         '1P00000101');
          FillStringListFromEnumField(mOS, mUsageTypeList,        'EKO_ZpusobUziti',        '1P00000101');
          FillStringListFromEnumField(mOS, mIntroductionTypeList, 'EKO_ZpusobUvedeni',      '1P00000101');
          FillStringListFromEnumField(mOS, mMaterialOriginList,   'EKO_PuvodMaterialu',     '1P00000101');
          FillStringListFromEnumField(mOS, mChargedList,          'EKO_ZpoplatneniObalu',   '1P00000101');
          FillStringListFromEnumField(mOS, mReusableList,         'EKO_OpakovanePouzivany', '1P00000101');
          FillStringListFromEnumField(mOS, mLitteringList,        'EKO_LitteringovyObal',   '1P00000101');

          {
          mErrLog:= mErrLog+#10#13+ mIsCompositList.Text;
          mErrLog:= mErrLog+#10#13+ mTradeTypeList.Text;
          mErrLog:= mErrLog+#10#13+ mUsageTypeList.Text;
          mErrLog:= mErrLog+#10#13+ mIntroductionTypeList.Text;
          mErrLog:= mErrLog+#10#13+ mMaterialOriginList.Text;
          mErrLog:= mErrLog+#10#13+ mChargedList.Text;
          mErrLog:= mErrLog+#10#13+ mReusableList.Text;
          mErrLog:= mErrLog+#10#13+ mLitteringList.Text;
          }

          for i:= 3 to mXLSProduct.UsedRange.Rows.Count do
          begin
            mBO:= mOS.CreateObject(Class_EkoKomContainer);
            try
              mCode :=            NxLeft(VarToStr(mXLSProduct.Cells[i,1]), 40);
              mName :=            NxLeft(VarToStr(mXLSProduct.Cells[i,2]), 100);
              mEAN :=             NxLeft(VarToStr(mXLSProduct.Cells[i,3]), 100);
              //mEANType :=         NxLeft(VarToStr(mXLSProduct.Cells[i,3]), 30);
              mMainUnitCode :=    NxLeft(VarToStr(mXLSProduct.Cells[i,4]), 200);
              mPackingStoreCard:= NxLeft(VarToStr(mXLSProduct.Cells[i,5]), 40);
              mIsComposit:=       VarToStr(mXLSProduct.Cells[i,6]);               //ano/ne
              mTradeType:=        VarToStr(mXLSProduct.Cells[i,7]);               //Obchodní/Průmyslový/Vyhodnotit výraz
              mUsageType:=        VarToStr(mXLSProduct.Cells[i,8]);               //Prodejní/Skupinové/Přepravní
              mIntroductionType:= VarToStr(mXLSProduct.Cells[i,9]);               //Vámi vyrobené v ČR/Vámi importované do ČR/Vámi nakoupené na vnitřním trhu ČR
              mMaterialOrigin:=   VarToStr(mXLSProduct.Cells[i,10]);              //Primární/Recyklát
              mCharged:=          VarToStr(mXLSProduct.Cells[i,11]);              //Zpoplatněný/Přeplacený/Neplacený
              mReusable:=         VarToStr(mXLSProduct.Cells[i,12]);              //ano/ne
              mLittering:=        VarToStr(mXLSProduct.Cells[i,13]);              //ne/nádoby na nápoje/Sáčky a balení na potraviny/Nápojové kelímky vyrobené z plastu/Nápojové kelímky částečně vyrobené z plastu/Nádoby na potraviny vyrobené z plastu/Nádoby na potraviny částečně vyrobené z plastu/Plastové odnosné tašky lehké 10 < 50 mikronů/Plastové odnosné tašky < 15 mikronů
              mQuantity:=         VarToStr(mXLSProduct.Cells[i,14]);
              mWeight:=           VarToStr(mXLSProduct.Cells[i,15]);

              mIsCompositInt:=        mIsCompositList.IndexOf(mIsComposit);
              mTradeTypeInt:=         mTradeTypeList.IndexOf(mTradeType);
              mUsageTypeInt:=         mUsageTypeList.IndexOf(mUsageType);
              mIntroductionTypeInt:=  mIntroductionTypeList.IndexOf(mIntroductionType);
              mMaterialOriginInt:=    mMaterialOriginList.IndexOf(mMaterialOrigin);
              mChargedInt:=           mChargedList.IndexOf(mCharged);
              mReusableInt:=          mReusableList.IndexOf(mReusable);
              mLitteringInt:=         mLitteringList.IndexOf(mLittering);

              mStoreCardID:= mOS.SQLSelectFirstAsString('SELECT ID FROM StoreCards WHERE Hidden = ''N'' '+cSQL_X_Aktivni+' AND Code ='+QuotedStr(mCode));
              mPackagingCardID:= mOS.SQLSelectFirstAsString('SELECT ID FROM StoreCards WHERE Hidden = ''N'' '+cSQL_X_Aktivni+' AND Code ='+QuotedStr(mPackingStoreCard));
              mRecordID:= mOS.SQLSelectFirstAsString(
                ' SELECT ID FROM DefRollData WHERE Hidden = ''N'' AND X_EKO_StoreCard_ID = '+QuotedStr(mStoreCardID)+
                ' AND X_EKO_ContainerStoreCard_ID = '+QuotedStr(mPackagingCardID)+
                ' AND X_EKO_StoreCardUnit ='+QuotedStr(mMainUnitCode));
              if not(NxIsEmptyOID(mRecordID)) then begin
                mErrLog:= mErrLog + #10 +'Řádek č. '+IntToStr(i)+' - Obal '+mPackingStoreCard+' u karty '+mCode+' již záznam má, byl proto přeskočen.';
                continue;
              end;
              if (NxIsEmptyOID(mStoreCardID)) or (NxIsBlank(mCode)) then begin
                mErrLog:= mErrLog + #10 +'Řádek č. '+IntToStr(i)+' - Karta s kódem '+mCode+' nenalezena, import přeskočen.';
                continue;
              end;
              if (NxIsEmptyOID(mPackagingCardID)) then begin
                mErrLog:= mErrLog + #10 +'Řádek č. '+IntToStr(i)+' - Obal '+mPackingStoreCard+' nenalezen, import řádku přeskočen.';
                continue;
              end;
              if (mIsCompositInt = -1)then begin
                mErrLog:= mErrLog + #10 +'Řádek č. '+IntToStr(i)+' - Obal '+mPackingStoreCard+' Nelze rozlišit zda je kompozitní, import řádku přeskočen';
                continue;
              end;
              if (mTradeTypeInt = -1)then begin
                mErrLog:= mErrLog + #10 +'Řádek č. '+IntToStr(i)+' - Obal '+mPackingStoreCard+' Nelze rozlišit typ obchodu, import řádku přeskočen';
                continue;
              end;
              if (mUsageTypeInt = -1)then begin
                mErrLog:= mErrLog + #10 +'Řádek č. '+IntToStr(i)+' - Obal '+mPackingStoreCard+' Nelze rozlišit způsob užití, import řádku přeskočen';
                continue;
              end;
              if (mIntroductionTypeInt = -1)then begin
                mErrLog:= mErrLog + #10 +'Řádek č. '+IntToStr(i)+' - Obal '+mPackingStoreCard+' Nelze rozlišit uvedení na trh, import řádku přeskočen';
                continue;
              end;
              if (mMaterialOriginInt = -1)then begin
                mErrLog:= mErrLog + #10 +'Řádek č. '+IntToStr(i)+' - Obal '+mPackingStoreCard+' Nelze rozlišit původ materiálu, import řádku přeskočen';
                continue;
              end;
              if (mChargedInt = -1)then begin
                mErrLog:= mErrLog + #10 +'Řádek č. '+IntToStr(i)+' - Obal '+mPackingStoreCard+' Nelze rozlišit zpoplatnění, import řádku přeskočen';
                continue;
              end;
              if (mReusableInt = -1)then begin
                mErrLog:= mErrLog + #10 +'Řádek č. '+IntToStr(i)+' - Obal '+mPackingStoreCard+' Nelze rozlišit opakované použití, import řádku přeskočen';
                continue;
              end;
              if (mLitteringInt = -1)then begin
                mErrLog:= mErrLog + #10 +'Řádek č. '+IntToStr(i)+' - Obal '+mPackingStoreCard+' Nelze rozlišit zda se jedná o litteringový obal, import řádku přeskočen';
                continue;
              end;
              try
                if NxIsEmptyOID(mRecordID) then begin
                  mBO.New;
                  mBO.Prefill;
                end else begin
                  mBO.Load(mRecordID, nil);
                end;
                mBO.SetFieldValueAsString('X_EKO_StoreCard_ID', mStoreCardID);
                mBO.SetFieldValueAsString('Code', mBO.GetFieldValueAsString('X_EKO_StoreCard_ID.Code'));
                mBO.SetFieldValueAsString('Name', mBO.GetFieldValueAsString('X_EKO_StoreCard_ID.Name'));
                mBO.SetFieldValueAsString('X_EKO_ContainerStoreCard_ID', mPackagingCardID);
                mBO.SetFieldValueAsString('X_EKO_StoreCardUnit', mMainUnitCode);
                mBO.SetFieldValueAsInteger('X_EKO_MaterialKompozitu', mIsCompositInt);
                mBO.SetFieldValueAsInteger('X_EKO_TypObchodu', mTradeTypeInt);
                mBO.SetFieldValueAsInteger('X_EKO_ZpusobUziti', mUsageTypeInt);
                mBO.SetFieldValueAsInteger('X_EKO_ZpusobUvedeni', mIntroductionTypeInt);
                mBO.SetFieldValueAsInteger('X_EKO_PuvodMaterialu', mMaterialOriginInt);
                mBO.SetFieldValueAsInteger('X_EKO_ZpoplatneniObalu', mChargedInt);
                mBO.SetFieldValueAsInteger('X_EKO_OpakovanePouzivany', mReusableInt);
                mBO.SetFieldValueAsInteger('X_EKO_LitteringovyObal', mLitteringInt);
                mBO.SetFieldValueAsFloat('X_EKO_UnitQuantity', NxIBStrToFloat(mQuantity));
                mBO.SetFieldValueAsFloat('X_EKO_Hmotnost', NxIBStrToFloat(mWeight));
                mBO.Save;
                ProgressSetPos(i);
              except
                ShowMessage('chyba: '+ ExceptionMessage);
              end;
            finally
              mBO.Free;
            end;
          end;
        finally
          mIsCompositList.Free;
          mTradeTypeList.Free;
          mUsageTypeList.Free;
          mIntroductionTypeList.Free;
          mMaterialOriginList.Free;
          mChargedList.Free;
          mReusableList.Free;
          mLitteringList.Free;
          ProgressDispose();
        end;
      end;
    finally
      //objWorkbook.RefreshAll;
      //objWorkbook.Saved:= False;                //mExcel.Application.WorkBooks[1].Close
      mExcel.Application.WorkBooks.Close;
      //mExcel.DisplayAlerts := False;
      mExcel.Quit;
      mExcel:= nil;
      //objWorkbook:= nil;
      mXLSPackaging:= nil;
      mXLSProduct:= nil;
    end;
  end;
  mOpenDialog.Free;
  TBusRollSiteForm(mSite).RefreshData;
  //TBusRollSiteForm(mSite).DataSet.SeekID(mOrigOID);
  if not(NxIsBlank(mErrLog)) then begin
    NxShowEditorSite(NxCreateContext(mOS), mErrLog, true);
  end;
end;


begin
end.