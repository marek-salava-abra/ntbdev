//Principielně udělá z jednoho místa dokladu do druhého
//Zatím jenom vizuálně.
//Cílem je vytvořit nevizuálního import managera

uses
  'eu.abra.PostProviders.uConst',
  'eu.abra.PostProviders.uCustomScript',
  'eu.abra.PostProviders.uCreatePackage',
  'eu.abra.PostProviders.uMemoMessage',
  'eu.abra.PostProviders.uPostProvider',
  'eu.abra.PostProviders.uAddressFunc',
  'eu.abra.PostProviders.uOutPutPackages',
  'eu.abra.PostProviders.uWeightFunc',
  'eu.abra.PostProviders.uImportPackages',
  'eu.abra.PostProviders.uForm';

//nevizuální - pro WMS/Autoulohu
//Data se plní pomocí předvyplnění.
//ABO Hlavní doklad ze kterého čerpáme data
//AIDs = Seznam ID pro zpracování. Nejčastějí obsahuje jenom ID shodné z ABO.
//3.3 - funkce místo procedure
Function StartAutoCreatePackageNonVisual(AOS: TNxCustomObjectSpace; var AIDs: TStringList; ABOMainDoc:TNxCustomBusinessObject ;const ACLSID:TNxPackedGuid ; const APMStateSuccess,APMStateEerror: TNxOID; var ALogInfoStr:TStringList; var ACreatedID:TStringList = nil; APrinterName: String = ''):Boolean;
var mP: TNxParameters;
    mContext : TNxContext;
    //dsHeader, dsRows, dsContent: TDataSource;
    dsHeader, dsRows, dsContent: TMemoryDataset;
    mRes : Boolean;
    mIDsExistPackage : TStringList;
    mCreatedPDM : TStringList;
    mBO : TNxCustomBusinessObject;
    i: Integer;
    mFakeSite: TSiteForm;
begin
  dsHeader := nil;
  dsRows := nil;
  mRes := true;
  mP := TNxParameters.Create;

  mCreatedPDM := TStringList.Create();
  mIDsExistPackage := TStringList.Create();
  try
    mP.NewFromDataType(dtString, NxGetActualUserID(AOS) + cLastSite).AsString :=  GetDocumentTypeFromCLSID(ACLSID);
    mP.NewFromDataType(dtString, NxGetActualUserID(AOS) + 'ID').AsString := ABOMainDoc.OID;
    mP.NewFromDataType(dtBoolean, NxGetActualUserID(AOS) + 'WithOutSite').AsBoolean:=true;

    try
      AUT_CreateDataSourceForPackage(AOS,mP,dsHeader,dsRows,dsContent, AIDs,cScriptAfterGetDataImportManagerNonVisual);
      mRes := AUT_CreatePackages(AOS,dsHeader,dsRows,dsContent,mCreatedPDM, ALogInfoStr);
      if mres then
        mRes := AUT_PDExportPackages(AOS, mP,dsHeader, dsRows,AIDs,ALogInfoStr);
      //Smažu pokud chyba
      if not mRes then
        for i := 0 to mCreatedPDM.Count -1 do
        begin
          try
            mBO := AOS.CreateObject(Class_PDMIssuedDoc);
            if mBO.Test(mCreatedPDM[i]) then
            begin
              mBO.Load(mCreatedPDM[i],nil);
              mBO.Delete;
              OutputDebugString('chybný smažu.');
            end;
          finally
            mBO.free;
          end;
        end;
      //Tisknu pokud již existují
      ABOMainDoc.Refresh;
      if mres then
        mRes := AUT_PDPrintPackages(AOS, mP,dsHeader, dsRows,AIDs,mIDsExistPackage,nil,APrinterName);
      if (not mRes) and (mIDsExistPackage.Count = 0) then
      begin
        if not CFxOID.IsEmptyOrFull(APMStateEerror) then
          ChangeStatusByRule(ABOMainDoc, APMStateEerror);
      end
      else
      begin
        mRes:= true;
        if ACreatedID <> nil then
         ACreatedID.text := mCreatedPDM.text;
        if not CFxOID.IsEmptyOrFull(APMStateSuccess) then
          ChangeStatusByRule(ABOMainDoc, APMStateSuccess);
      end;
    except
      mRes := false;
      ALogInfoStr.add('[CHYBA] při zpracvování došlo k neočekávané chybě: '+ExceptionMessage);
      if not CFxOID.IsEmptyOrFull(APMStateEerror) then
        ChangeStatusByRule(ABOMainDoc, APMStateEerror)
    end;
  finally
    Result := mRes;
    mIDsExistPackage.Free;
    mCreatedPDM.free;
    mP.Free;
    if dsHeader <> nil then
      dsHeader.Free;
    if dsRows <> nil then
      dsRows.Free;
    if dsContent <> nil then
      dsContent.Free;
    if mFakeSite <> nil then
      mFakeSite.Free;
  end;
end;



//// Blok na jedno kliknutí
//Proces tvorby balíku automaticky
//volání StartAutoCretaePackage(mSite, mIDs, ABO, AUser_ID);
//ASetting - 0 zadejte počet, 1 - zadaný počet vždy 1ks (depricated)
Procedure StartAutoCreatePackage(ASite: TSiteForm; var AIDs: TStringList; var ABO : TNxCustomBusinessObject; ASetting: Integer );
var mP: TNxParameters;
    mContext : TNxContext;
    //dsHeader, dsRows, dsContent: TDataSource;
    dsHeader, dsRows, dsContent: TMemoryDataset;
    mRes : Boolean;
    mCountPackage : Integer;
    mIDsExistPackage,ALogInfoStr : TStringList;
    mCreatedPDM : TStringList;
    mBO : TNxCustomBusinessObject;
    i: Integer;
    mMemo: TForm;
begin
  dsHeader := nil;
  dsRows := nil;
  mCountPackage := 0;
  mRes := true;
  mP := TNxParameters.Create;

  mCreatedPDM := TStringList.Create();
  mIDsExistPackage := TStringList.Create();
  ALogInfoStr := TStringList.Create();
  try
    //zjistím zda již existují balíky
    //ASite.BaseObjectSpace.SQLSelect( format(cSQLSelExistPackage,[ABO.OID]), mIDsExistPackage );

    //Příprava parametru kde se zjistuje sita. atd
    //tvorba parametru pro zjištění z jaké agendy bylo spuštěno
    mP.NewFromDataType(dtInteger, NxGetActualUserID(ASite.BaseObjectSpace)+cPackages_Site).AsInteger := ObjToInt(ASite);
    mP.NewFromDataType(dtString, NxGetActualUserID(ASite.BaseObjectSpace) + cLastSite).AsString := GetDocumentTypeFromSiteCLSID(ASite.GetSiteCLSID);
    mP.NewFromDataType(dtString, NxGetActualUserID(ASite.BaseObjectSpace) + 'ID').AsString := ABO.OID;
    mP.NewFromDataType(dtBoolean, NxGetActualUserID(ASite.BaseObjectSpace) + 'WithOutSite').AsBoolean:=true;
    (*  Přesunuto do předvyplnění
    if ASetting = 0 then
    begin
      mCountPackage := ShowInputField(ASite, 1);
      if mCountPackage = -1 then
        exit;
    end
    else
      mCountPackage := 1;
    *)

    AUT_CreateDataSourceForPackage(ASite.BaseObjectSpace, mP,dsHeader, dsRows,dsContent, AIDs,cScriptAfterGetDataImportManager);
    mRes := AUT_CreatePackages(ASite.BaseObjectSpace,dsHeader, dsRows,dsContent,mCreatedPDM, ALogInfoStr);
    if mres then
      mRes := AUT_PDExportPackages(ASite.BaseObjectSpace, mP,dsHeader, dsRows,AIDs,ALogInfoStr);

    //Smažu pokud chyba
    if not mRes then
      for i := 0 to mCreatedPDM.Count -1 do
      begin
        try
          mBO := ASite.BaseObjectSpace.CreateObject(Class_PDMIssuedDoc);
          if mBO.Test(mCreatedPDM[i]) then
          begin
            mBO.Load(mCreatedPDM[i],nil);
            mBO.Delete;
            OutputDebugString('chybný smažu.');
          end;
        finally
          mBO.free;
        end;
      end;


      //Tisknu pokud již existují
      if mres then
        mRes := AUT_PDPrintPackages(ASite.BaseObjectSpace, mP,dsHeader, dsRows,AIDs,mIDsExistPackage);


      {
      Když nastane chyba mohu zobrazit formulář pro dořešení. Ale velice často je lepší jen napsat chybu a pokračovat.
      if (not mRes) and (mIDsExistPackage.Count = 0) then
      begin
        //TComboButton(ASite.FindChildControl('cactPackages')).Click();
        mContext := NxCreateContext(ASite.CompanyCache.GetCompanyObjectSpace);
        ShowDynForm('TMQVRRRTOOLOB0F53Q5THY4XC4', mContext, mP, nil, true, '');
      end;
      }
      if (not mRes) and (mIDsExistPackage.Count = 0) then
      begin
        mMemo := CreateMemoMessage(ASite, ALogInfoStr.Text);
        try
          mMemo.ShowModal(ASite);
        finally
          mMemo.Free;
        end;
      end;

  finally
    ALogInfoStr.free;
    mIDsExistPackage.Free;
    mCreatedPDM.free;
    mP.Free;
    if dsHeader <> nil then
      dsHeader.Free;
    if dsRows <> nil then
      dsRows.Free;
    if dsContent <> nil then
      dsContent.Free;
  end;
end;


//Vytvoření podkladu pro metodu CHECK
Procedure StartCheckPackage(ASite: TSiteForm; var AIDs: TStringList; var ABO : TNxCustomBusinessObject; ASetting: Integer );
var mP: TNxParameters;
    mContext : TNxContext;
    dsHeader, dsRows,dsContent: TMemoryDataset;
    mRes : Boolean;
    mCountPackage : Integer;
    mCreatedPDM, mLogInfoStr : TStringList;
    mBO : TNxCustomBusinessObject;
    i: Integer;
begin
  dsHeader := nil;
  dsRows := nil;
  mCountPackage := 0;
  mRes := true;
  mP := TNxParameters.Create;

  mLogInfoStr := TStringList.Create();
  mCreatedPDM := TStringList.Create();
  try
    //zjistím zda již existují balíky
    //ASite.BaseObjectSpace.SQLSelect( format(cSQLSelExistPackage,[ABO.OID]), mIDsExistPackage );

    //Příprava parametru kde se zjistuje sita. atd
    //tvorba parametru pro zjištění z jaké agendy bylo spuštěno
    mP.NewFromDataType(dtInteger, NxGetActualUserID(ASite.BaseObjectSpace)+cPackages_Site).AsInteger := ObjToInt(ASite);
    mP.NewFromDataType(dtString, NxGetActualUserID(ASite.BaseObjectSpace) + cLastSite).AsString := GetDocumentTypeFromSiteCLSID(ASite.GetSiteCLSID);
    mP.NewFromDataType(dtString, NxGetActualUserID(ASite.BaseObjectSpace) + 'ID').AsString := ABO.OID;
    mP.NewFromDataType(dtBoolean, NxGetActualUserID(ASite.BaseObjectSpace) + 'WithOutSite').AsBoolean:=true;

      AUT_CreateDataSourceForPackage(ASite.BaseObjectSpace, mP,dsHeader, dsRows,dsContent, AIDs,cScriptAfterGetDataImportManager);
      mRes := AUT_CreatePackages(ASite.BaseObjectSpace,dsHeader, dsRows,dsContent, mCreatedPDM,mLogInfoStr);
      //if mres then
        //mRes := AUT_PDCheckPackage(ASite, mP,dsHeader, dsRows,AIDs);

      //Smažu dočasné BO
      for i := 0 to mCreatedPDM.Count -1 do
      begin
        try
          mBO := ASite.BaseObjectSpace.CreateObject(Class_PDMIssuedDoc);
          if mBO.Test(mCreatedPDM[i]) then
          begin
            mBO.Load(mCreatedPDM[i],nil);
            mBO.Delete;
            OutputDebugString('Dočasný soubor PDMIssuedDoc byl odstraněn.');
          end;
        finally
          mBO.free;
        end;
      end;
    //Tisknu pokud již existují
    //if mres then
      //mRes := AUT_PDPrintPackages(ASite.BaseObjectSpace, mP,dsHeader, dsRows,AIDs,mIDsExistPackage);
  finally
    mLogInfoStr.Free;
    mCreatedPDM.Free;
    mP.Free;
    if dsHeader <> nil then
      dsHeader.Free;
    if dsRows <> nil then
      dsRows.Free;

  end;
end;


//Vytvoří DataSource pro práci s balíkem
//Prefill data
//ASite: TSiteForm;
procedure AUT_CreateDataSourceForPackage(AOS:TNxCustomObjectSpace; var AParams : TNxParameters;var AdsHeader: TMemoryDataset; var AdsRows: TMemoryDataset;var adsContent: TMemoryDataset; AIDs : TStringList; ACustomScriptType: Integer);
begin
  AdsHeader := TMemoryDataset.Create(nil);
  PrefillHeaderDataSetFileds(AdsHeader);

  AdsRows := TMemoryDataset.Create(nil);
  PrefillPackagesDataSetFileds(AdsRows);

  adsContent := TMemoryDataset.Create(nil);
  PrefillContentDataSetFileds(adsContent);

  AdsRows.Tag := ObjToInt(adsContent);
  adsContent.Tag := ObjToInt(AdsRows);

  PrefillHeaderDataSet(AdsHeader,AOS);

  if (AdsRows.RecordCount = 0) then
    AUT_GetData(AOS, AParams, AdsHeader, AdsRows, AIDs);

  //Spuštění skriptu po vytvoření (spuštění po změně nemá smysl)
  RunScript(AOS, AdsRows, AdsHeader, adsContent , ACustomScriptType);
end;


//vrátí data pro formulář
//aternativa k funkci AUT_GetData
//ASite: TSiteForm;
procedure AUT_GetData(AOS:TNxCustomObjectSpace;var AParams : TNxParameters; var AdsHeader: TMemoryDataset; var AdsRows: TMemoryDataset; var AIDs: TStringList);
var
  i: integer;
  mIDs: TStringList;
  mStation_ID: string;
  mOS: TNxCustomObjectSpace;
  mData, mSourceDataset: TMemoryDataset;
  medPDMPRovider: TRollComboEdit;
  mPostProvider: TNxOID;
  mSourceSite: TSiteForm;
  mSQL: string;
  mDocumentType: string;
begin
  mOS := AOS;
  mSourceSite := nil;
  mDocumentType := '';
  mSQL := '';
  if Assigned(AParams) then begin
    if AParams.ParamExist(NxGetActualUserID(mOS)+cLastSite) then begin
      mDocumentType := AParams.ParamAsString(NxGetActualUserID(mOS)+cLastSite, '');
    end;
  end;
  mIDs := TStringList.Create;
  mData := AdsRows;
  try
    //GetIDsFromSite(mSourceSite, ASite, mIDs, mDocumentType);
    mSQL := GetSQLSource(mDocumentType,mOS);
    mStation_ID := StringsToSelDat(mOS, AIDs);
    try
      mSourceDataset := TMemoryDataset.Create(nil);
      try
        mSQL := Format(mSQL, [QuotedStr(mStation_ID)]);
        mOS.SQLSelect2(mSQL, mSourceDataSet);
        if (mSourceDataSet.RecordCount > 0) then begin
          CopyDataset(mData, mSourceDataset);
          SetFormat(mData);
          mData.Edit;
          mData.First;
          mData.Active := true;
          SetAddInfo(mOS, '', mData, mDocumentType);
          CreateContent( TMemoryDataset(AdsRows.Tag) );
        end;
      finally
        mSourceDataset.Free;
      end;
    finally
      ClearSelDat(mOS, mStation_ID);
    end;
  finally
    mIDs.Free;
  end;
end;




//Dojde k vytvoření dokladu v agendě odeslaná pošta. Vrací false jestliže dojde k chybě a tedy nebude možné dokončit.
//nově nevizuálně
function AUT_CreatePackages(AOS:TNxCustomObjectSpace; var AdcHeader: TMemoryDataset; var AdsRows: TMemoryDataset; var AdsContent: TMemoryDataset; var ACreatedIDs: TStringList;var ALogInfoStr: TStringList):Boolean;
var
  mSoftErrors ,mErrors: TStringList;
  mOS : TNxCustomObjectSpace;
  mRes : Integer;
begin
  Result := True;
  mOS := AOS;

  mErrors :=  TStringList.Create;
  mSoftErrors := TStringList.Create;
  try
    AdsRows.Open;
    AdcHeader.Open;
    ValidatePackages(AdsRows, AdcHeader,AdsContent, mOS, mErrors, mSoftErrors);
    if Trim(mErrors.Text)<> '' then begin
      ALogInfoStr.Add(lng_msg_Stop+cCrLf+mErrors.Text);
      Result := False;
      Exit;
    end;
    if Trim(mSoftErrors.Text)<> '' then begin
      ALogInfoStr.Add(lng_msg_Continue+cCrLf+ mSoftErrors.Text);
    end;
    mErrors.Clear;
    mSoftErrors.Clear;
    CreatePackages(AdsRows, AdcHeader,AdsContent, mOS, mErrors, mSoftErrors,ACreatedIDs);

    if Trim(mErrors.Text) <> '' then begin
      ALogInfoStr.Add( lng_msg_error+cCrLf+mErrors.Text);
      Result := False;
      Exit;
    end;
  finally
    mSoftErrors.Free;
  end;
end;



//Exportování balíku. Vrací false jestliže dojde k chybě a tedy nebude možné dokončit.
function AUT_PDExportPackages(AOS:TNxCustomObjectSpace; var AParams : TNxParameters; var AdcHeader: TMemoryDataset; var AdsRows: TMemoryDataset;  var AIDs: TStringList; var ALogInfoStr: TStringList):Boolean;
var
  mOS : TNxCustomObjectSpace;
  mDataSet: TMemoryDataset;
  mID: TNxOID;
  mGrid: TMultiGrid;
  mIDs: TStringList;
  mStation_ID, mSQL, sqlCondition, mTmp, mSQLGetPackages, mDocumentType: string;
  medPDMPRovider: TRollComboEdit;
  mPostProvider: TNxOID;
  i: integer;
  mMemo: TForm;
begin
  Result := True;
  mOS := AOS;
  mIDs := TStringList.Create;
  try
    mDataSet := AdcHeader;
      //pokud je to voláno z agendy jsou nastavene siteparams, jinak DocumentType vezmu z datasetu
      if Assigned(AParams) then begin
        if AParams.ParamExist(NxGetActualUserID(mOS)+cLastSite) then begin
          mDocumentType := AParams.ParamAsString(NxGetActualUserID(mOS)+cLastSite, '');
        end;
      end;
      mSQLGetPackages := GetSQLPackages(mDocumentType);
      mPostProvider := mDataSet.FieldByName(cFDPDMProvider).AsString;
      mStation_ID := StringsToSelDat(mOS, AIDs);
      try
        if not CFxOID.IsEmpty(mPostProvider) then
        begin
          mSQL := Format(mSQLGetPackages, [QuotedStr(mStation_ID), '']);
          end else begin
          mSQL := Format(mSQLGetPackages, [QuotedStr(mStation_ID), ' and (PID.PostProvider_ID ='+ QuotedStr(mPostProvider) +') ']);
        end;
        mIDs.Clear;
        mOS.SQLSelect(mSQL, mIDs);
      finally
        ClearSelDat(mOS, mStation_ID);
      end;
      if (mIDs.Count > 0) then begin
        for i:= 0 to mIDs.Count-1 do begin
          mTmp := mIDs[i];
          mID := NxTrapStr(mTmp, ';');
          mIDs[i] := QuotedStr(mID);
        end;
          try
            ExportPackages(nil,AOS, mIDs, GetProviderDriver(mOS,mPostProvider), 0,ALogInfoStr);
          except
              Result := False;
              ALogInfoStr.add(lng_msg_Stop+cCrLf+ExceptionMessage);
          end;
      end else
      begin
        Result := false;
        ALogInfoStr.add(lng_msg_NoRecordsFound);
      end;
  finally
    mIDs.Free;
  end;
end;



//Validace balíku. Vrací false jestliže dojde k chybě a tedy nebude možné dokončit.
function AUT_PDCheckPackage(ASite: TSiteForm; var AParams : TNxParameters; var AdcHeader: TDataSource; var AdsRows: TDataSource; var AIDs: TStringList):Boolean;
var
  mSite : TSiteForm;
  mOS : TNxCustomObjectSpace;
  mDataSet: TMemoryDataset;
  mID: TNxOID;
  mGrid: TMultiGrid;
  mIDs: TStringList;
  mStation_ID, mSQL, sqlCondition, mTmp, mSQLGetPackages, mDocumentType: string;
  medPDMPRovider: TRollComboEdit;
  mPostProvider: TNxOID;
  i: integer;
  mMemo: TForm;
begin
  Result := True;
  mSite := ASite;
  mOS := ASite.BaseObjectSpace;
  mIDs := TStringList.Create;
  try
    mDataSet := TMemoryDataset(AdcHeader.DataSet);
    mDataSet.DisableControls;
    try
      //pokud je to voláno z agendy jsou nastavene siteparams, jinak DocumentType vezmu z datasetu
      if Assigned(AParams) then begin
        if AParams.ParamExist(NxGetActualUserID(mSite.BaseObjectSpace)+cLastSite) then
          mDocumentType := AParams.ParamAsString(NxGetActualUserID(mSite.BaseObjectSpace)+cLastSite, '');
      end else begin
        mDocumentType := mDataSet.FieldByName(cFDDocumentType).AsString;
      end;
      mSQLGetPackages := GetSQLPackages(mDocumentType);

      mPostProvider := mDataSet.FieldByName(cFDPDMProvider).AsString;
      mStation_ID := StringsToSelDat(mOS, AIDs);
      try
        if not CFxOID.IsEmpty(mPostProvider) then
        begin
          mSQL := Format(mSQLGetPackages, [QuotedStr(mStation_ID), '']);
          end else begin
          mSQL := Format(mSQLGetPackages, [QuotedStr(mStation_ID), ' and (PID.PostProvider_ID ='+ QuotedStr(mPostProvider) +') ']);
        end;
        mIDs.Clear;
        mOS.SQLSelect(mSQL, mIDs);
      finally
        ClearSelDat(mOS, mStation_ID);
      end;
      if (mIDs.Count > 0) then begin
        for i:= 0 to mIDs.Count-1 do begin
          mTmp := mIDs[i];
          mID := NxTrapStr(mTmp, ';');
          mIDs[i] := QuotedStr(mID);
        end;
          try
            CheckPackages(mSite, mIDs, GetProviderDriver(mOS,mPostProvider), 0);
          except
            try
              Result := False;
              mMemo := CreateMemoMessage(mSite, lng_msg_Stop+cCrLf+ExceptionMessage);
              mMemo.ShowModal(mSite);
            finally
              mMemo.Free;
            end;
          end;
      end else
      begin
        Result := false;
        NxShowSimpleMessage(lng_msg_NoRecordsFound, mSite);
      end;
    finally
      mDataSet.EnableControls;
    end;
  finally
    mIDs.Free;
  end;
end;

//Získání ceny balíku. Vrací false jestliže dojde k chybě a tedy nebude možné dokončit.
function AUT_PDTransportCostsPackage(ASite: TSiteForm; var AParams : TNxParameters; var AdcHeader: TDataSource; var AdsRows: TDataSource; var AIDs: TStringList):Boolean;
var
  mSite : TSiteForm;
  mOS : TNxCustomObjectSpace;
  mDataSet: TMemoryDataset;
  mID: TNxOID;
  mGrid: TMultiGrid;
  mIDs: TStringList;
  mStation_ID, mSQL, sqlCondition, mTmp, mSQLGetPackages, mDocumentType: string;
  medPDMPRovider: TRollComboEdit;
  mPostProvider: TNxOID;
  i: integer;
  mMemo: TForm;
begin
  Result := True;
  mSite := ASite;
  mOS := ASite.BaseObjectSpace;
  mIDs := TStringList.Create;
  try
    mDataSet := TMemoryDataset(AdcHeader.DataSet);
    mDataSet.DisableControls;
    try
      //pokud je to voláno z agendy jsou nastavene siteparams, jinak DocumentType vezmu z datasetu
      if Assigned(AParams) then begin
        if AParams.ParamExist(NxGetActualUserID(mSite.BaseObjectSpace)+cLastSite) then
          mDocumentType := AParams.ParamAsString(NxGetActualUserID(mSite.BaseObjectSpace)+cLastSite, '');
      end else begin
        mDocumentType := mDataSet.FieldByName(cFDDocumentType).AsString;
      end;
      mSQLGetPackages := GetSQLPackages(mDocumentType);

      mPostProvider := mDataSet.FieldByName(cFDPDMProvider).AsString;
      mStation_ID := StringsToSelDat(mOS, AIDs);
      try
        if not CFxOID.IsEmpty(mPostProvider) then
        begin
          mSQL := Format(mSQLGetPackages, [QuotedStr(mStation_ID), '']);
          end else begin
          mSQL := Format(mSQLGetPackages, [QuotedStr(mStation_ID), ' and (PID.PostProvider_ID ='+ QuotedStr(mPostProvider) +') ']);
        end;
        mIDs.Clear;
        mOS.SQLSelect(mSQL, mIDs);
      finally
        ClearSelDat(mOS, mStation_ID);
      end;
      if (mIDs.Count > 0) then begin
        for i:= 0 to mIDs.Count-1 do begin
          mTmp := mIDs[i];
          mID := NxTrapStr(mTmp, ';');
          mIDs[i] := QuotedStr(mID);
        end;
          try
            TransportcostsPackages(mSite, mIDs, GetProviderDriver(mOS,mPostProvider), 0);
          except
            try
              Result := False;
              mMemo := CreateMemoMessage(mSite, lng_msg_Stop+cCrLf+ExceptionMessage);
              mMemo.ShowModal(mSite);
            finally
              mMemo.Free;
            end;
          end;
      end else
      begin
        Result := false;
        NxShowSimpleMessage(lng_msg_NoRecordsFound, mSite);
      end;
    finally
      mDataSet.EnableControls;
    end;
  finally
    mIDs.Free;
  end;
end;


function AUT_PDPrintPackages(AOS:TNxCustomObjectSpace ; var AParams : TNxParameters; var AdcHeader: TMemoryDataset; var AdsRows: TMemoryDataset; var AIDs: TStringList; var ALogInfoStr: TStringList ;var AIDsExistPackage: TStringList=nil;APrinterName:String = '';):Boolean;
var
  mOS : TNxCustomObjectSpace;
  mDataSet: TMemoryDataset;
  mID: TNxOID;
  mGrid: TMultiGrid;
  mIDs: TStringList;
  mStation_ID, mSQL, sqlCondition, mTmp, mSQLGetPackages, mDocumentType: string;
  medPDMPRovider: TRollComboEdit;
  mPostProvider: TNxOID;
  i: integer;
  mMemo: TForm;
  mBOPackage : TNxCustomBusinessObject;
begin
  Result := true;
  mOS := AOS;
  mIDs := TStringList.Create;
  mPostProvider := '';
  try
    mDataSet := AdcHeader;
    //pokud je to voláno z agendy jsou nastavene siteparams, jinak DocumentType vezmu z datasetu
    if Assigned(AParams) then begin
        if AParams.ParamExist(NxGetActualUserID(mOS)+cLastSite) then begin
          mDocumentType := AParams.ParamAsString(NxGetActualUserID(mOS)+cLastSite, '');
        end;
      end;
    mSQLGetPackages := GetSQLPackages(mDocumentType);
    if Assigned(mDataSet) then
      if mDataSet.FindField(cFDPDMProvider) <> nil then
        mPostProvider := mDataSet.FieldByName(cFDPDMProvider).AsString;
    if CFxOID.IsEmpty(mPostProvider) and (AIDsExistPackage <> nil) then
    begin
      if AIDsExistPackage.Count > 0 then
      begin
        try
          mBOPackage := mOS.CreateObject(Class_PDMIssuedDoc);
          if not NxIsEmptyOID(AIDsExistPackage[0]) then
            mBOPackage.load(AIDsExistPackage[0],nil);
          if Assigned(mBOPackage) then
            mPostProvider := mBOPackage.getfieldValueAsString('PostProvider_ID');

        finally
          mBOPackage.free;
        end;
      end;
    end;

    mStation_ID := StringsToSelDat(mOS, AIDs);
    try
      if CFxOID.IsEmpty(mPostProvider) then begin
        mSQL := Format(mSQLGetPackages, [QuotedStr(mStation_ID), '']);
      end else begin
        mSQL := Format(mSQLGetPackages, [QuotedStr(mStation_ID), ' and (PID.PostProvider_ID ='+ QuotedStr(mPostProvider) +') ']);
      end;
      mIDs.Clear;
      mOS.SQLSelect(mSQL, mIDs);
    finally
      ClearSelDat(mOS, mStation_ID);
    end;
    if (mIDs.Count > 0) then begin
      for i:= 0 to mIDs.Count-1 do begin
        mTmp := mIDs[i];
        mID := NxTrapStr(mTmp, ';');
        mIDs[i] := QuotedStr(mID);
      end;
        try //todo  GetProviderDriver nahradit funkcí na dohledání správného dopravce
          PrintPackages(AOS, mIDs, GetProviderDriver(mOS,mPostProvider), 0,APrinterName );
        except
          ALogInfoStr.Add( lng_msg_Stop+cCrLf+ExceptionMessage);
        end;
    end else
    begin
      Result := False;
      ALogInfoStr.add(lng_msg_NoRecordsFound);
    end;
  finally
    mIDs.Free;
  end;
end;


function ShowInputField(Sender: TObject; ADefaultValue : Integer = 1):Integer;
var
  mFormInput: TForm;
  mEdit: TNumEdit;
  mButtonEnter: TButton;
begin
  try
    Result := ADefaultValue;
    mFormInput := nil;
    mEdit := nil;
    mFormInput := TForm.Create(TDynSiteForm(Sender));
    mEdit := TNumEdit.Create(mFormInput);
    mButtonEnter := TButton.Create(mFormInput);

    with mFormInput do
    begin
      Name := 'mFormInput';
      Left := 192;
      Top := 125;
      Width := 400;
      Height := 82;
      Caption := lng_frm_PackageCount;
      Color := clBtnFace;
      OldCreateOrder := False;
      PixelsPerInch := 96;
    end;
    with mEdit do
    begin
      Name := 'mEdit';
      Value := ADefaultValue;
      Parent := mFormInput;
      Left := 8;
      Top := 8;
      Width := 369;
      Height := 25;
      TabOrder := 0;
      OnKeyDown:= @ActEnter;
      Tag := ObjToInt(mButtonEnter);
      DecimalPlaces := 0;
    end;



    with mButtonEnter do
    begin
      Name := 'mButtonEnterInput';
      Parent := mFormInput;
      Left := 384;
      Top := 8;
      Width := 0;
      Height := 0;
      Caption := 'mButtonEnter';
      TabOrder := 1;
      ModalResult := mrOk;
    end;


    mFormInput.SetFocusedControl(mEdit);
    if mFormInput.ShowModal(TDynSiteForm(Sender)) = mrOk then
    begin
      mFormInput.Close;

      Result :=  mEdit.AsInteger;
      mEdit.Clear;
    end
    else
    begin
      ShowMessage(lng_msg_Cancel);
      Result :=  -1;
      exit;
    end;


  finally
    if mEdit <> nil then
      mEdit.Free;
    if mFormInput <> nil then
      mFormInput.Free;
  end;
end;


procedure ActEnter(Sender: TObject; var Key: Word; Shift: TShiftState);
var
  mButton: TButton;
begin
  mButton := nil;
  if Key = VK_RETURN then
  begin
    mButton := TButton(IntToObj(TNumEdit(Sender).Tag));
    //mButton := TButton(TEdit(Sender).Parent.FindChildControl('mButtonEnterInput'));
    if Assigned(mButton) then
      mButton.Click;
  end;
end;






//########API###########//
//https://bugzilla.abra.eu/show_bug.cgi?id=71198



(*
Endpoint: https://onlineapi.abra.eu/DEMO/DEMO_TEST/script/eu.abra.postprovider/uImportManager/Execute

BODY:

{
   "InputDocument":"1010000101",
   "InputDocumentType":"21",
   "Printer":"Název tiskárny"
}
*)


function POST_Execute(AContext: TNxContext; AInput: TJSONSuperObject; APath: String): TJSONSuperObject;
const cName = 'POST_Execute';
const cSQL = 'Select a.ID from Persons A where a.X_ImoCarWash = ''A'' and A.ID = ''%s'' ';
var mOS: TNxCustomObjectSpace;
    mJSON,mJSONItem : TJSONSuperObject;
    mLogInfoStr,mCreatedIDs ,mListTmp : TStringList;
    mBO,mBOPDM : TNxCustomBusinessObject;
    mInputDocument,mInputDocumentType, mCLSID : String;
    mSuccess: Boolean;
    i :integer;
begin
  mSuccess := true;
  Result := nil;
  mJSON := TJSONSuperObject.Create;
  mOS := AContext.GetObjectSpace;
  mLogInfoStr := TStringList.Create;
  mListTmp := TStringList.Create;
  mCreatedIDs := TStringList.Create;
  mBOPDM := nil;
  mBO := nil;

  try
    try


      if ((AInput.N['InputDocument'].DataType = jtNull)  or (AInput.N['InputDocument'].DataType = -1)) then
          RaiseException('Nedorazila hodnota: InputDocument')
      else
        mInputDocument := AInput.S['InputDocument'];

      if ((AInput.N['InputDocumentType'].DataType = jtNull)  or (AInput.N['InputDocumentType'].DataType = -1)) then
          RaiseException('Nedorazila hodnota: InputDocumentType')
      else
        mInputDocumentType := AInput.S['InputDocumentType'];



      case mInputDocumentType of
        '21' : mCLSID :=  Class_BillOfDelivery;
        '22' : mCLSID :=  Class_OutgoingTransfer;
        else RaiseException(mCLSID + ' tento objekt není podporován.' );
      end;

      mBO := mOS.CreateObject(mCLSID);
      if not CFxOID.IsEmptyOrFull(mInputDocument) then
      begin
        if mBO.test(mInputDocument) then
        begin
          mBO.Load(mInputDocument,nil);
          mListTmp.Clear;
          mListTmp.Add(mBO.oid);
          //StartAutoCreatePackageNonVisual(AOS: TNxCustomObjectSpace; var AIDs: TStringList; ABOMainDoc:TNxCustomBusinessObject ;const ACLSID:TNxPackedGuid ; const APMStateSuccess,APMStateEerror: TNxOID; var ALogInfoStr:TStringList;):Boolean;
          mSuccess := StartAutoCreatePackageNonVisual( mOS, mListTmp,mBO, mCLSID, '0000000000', '0000000000',  mLogInfoStr, mCreatedIDs  );
          mJSON.B['Success'] := mSuccess;
          if mSuccess then
          begin
            mBOPDM := mOS.CreateObject(Class_PDMIssuedDoc);
            mJSON.S['title'] := lng_msg_ExportInfo;
            mJSON.S['InputDocument'] := mInputDocument;
            mJSON.S['InputDocumentType'] := mInputDocumentType;
            mJSON.O['OutputDocuments'] := mJSON.CreateJSONArray;
            for  i := 0 to mCreatedIDs.count -1 do
            begin
              mJSONItem := TJSONSuperObject.Create;
              try
                mBOPDM.load(mCreatedIDs[i],nil);
                mJSONItem.S['OutputDocument'] := mBOPDM.oid;
                mJSONItem.S['postnumber'] := mBOPDM.GetFieldValueAsString('postnumber');
                mJSONItem.I['PosIndex'] := mBOPDM.GetFieldValueAsInteger('X_PD_PosIndex');
                mJSON.A['OutputDocuments'].Add(mJSONItem);
              finally
                mJSONItem.free;
              end;
            end;

          end
          else
          begin
            mJSON.S['title'] := 'Chyba při exportu';
            mJSON.S['description'] := mLogInfoStr.text;
            mJSON.S['InputDocument'] := mInputDocument;
            mJSON.S['InputDocumentType'] := mInputDocumentType;
          end;

        end
        else
          RaiseException('Objekt '+mCLSID +' s ID:'+mInputDocument + ' nebyl nalezen.');
      end
      else
        RaiseException('Dorazila prázdná/neplatná hodnota InputDocument');



    except
      mSuccess := false;
      mJSON.B['Success'] := mSuccess;
      mJSON.S['title'] := 'Neplatný požadavek';
      mJSON.S['description'] := ExceptionMessage;
      //systémová hláška
      {
        "title": "Neplatný požadavek",
        "description": "Vyhodnocení funkce eu.abra.PostProviders.uImportManager.POST_Execute vrátilo výjimku:\r\nPři provádění skriptu pro Knihovna(eu.abra.PostProviders.uImportManager) z balíčku eu.abra.PostProviders.uImportManager pro háček POST_Execute nastala následující chyba:\r\nNedorazila hodnota: InputDocument\r\n\r\nscripting callstack:\r\n  RaiseException (835:23)\r\n\r\n\r\nSprávná deklarace by měla být jedna z následujících:\r\nfunction POST_Execute(AContext: TNxContext; ABody: TNxJSONSuperObject; APath: String): TNxJSONSuperObject;\r\nfunction POST_Execute(AContext: TNxContext; ABody: string; APath: String): string;"
      }
    end;
  finally
    if mBO <> nil then
      mBO.free;
    if mBOPDM <> nil then
      mBOPDM.free;
    Result := mJSON;
    //mJSON.free;
    AInput.free;
    mLogInfoStr.free;
    mListTmp.free;
    mCreatedIDs.free;
    mBO.free;
  end;
end;





begin
end.