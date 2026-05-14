uses
  'eu.abra.PostProviders.uConst',
  'eu.abra.PostProviders.uSQLFunc',
  'eu.abra.PostProviders.uDocTypeFunc',
  'eu.abra.PostProviders.uAddressFunc',
  'eu.abra.PostProviders.uWeightFunc',
  'eu.abra.PostProviders.uBalikobotFunc',
  'eu.abra.PostProviders.uPostProvider';

const
  cGetServiceType = 'select ID from PDMServiceTypes %s';
  cGetServiceTypeWhere = 'where %s';

//vytvoří balíky v odeslané poště
procedure CreatePackages(const APackagesDataSet, AHeaderDataSet,AContentDataSet: TDataSet; AOS: TNxCustomObjectSpace; var AErrors, ASoftErrors, ACreatedIDs : TStringList);
var
  bm: TBookmark;
  mErrors, mSoftErrors: TStringList;
  mNumberII: String;
begin
  mErrors := TStringList.Create;
  try
    mSoftErrors := TStringList.Create;
    try
      bm := APackagesDataSet.GetBookmark;
      AHeaderDataSet.First;
      APackagesDataSet.DisableControls;
      try
        APackagesDataSet.First;
        while not APackagesDataSet.Eof do begin
          mNumberII := APackagesDataSet.FieldByName(cFDDisplayNumber).AsString;
          mErrors.Clear;
          mSoftErrors.Clear;
          CreatePackagesForDSRow(APackagesDataSet, AHeaderDataSet,AContentDataSet, AOS, mErrors, mSoftErrors, not cOnlyValidate, ACreatedIDs);
          if trim(mSoftErrors.Text) <> '' then begin
            ASoftErrors.Add(Format(lng_fnc_CreatePackages, [mNumberII]));
            ASoftErrors.AddStrings(mSoftErrors);
          end;
          if trim(mErrors.Text) <> '' then begin
            AErrors.Add(Format(lng_fnc_CreatePackages, [mNumberII]));
            AErrors.AddStrings(mErrors);
          end;
          APackagesDataSet.Next;
        end;
      finally
        APackagesDataSet.GotoBookmark(bm);
        APackagesDataSet.EnableControls;
      end;
    finally
      mSoftErrors.Free;
    end;
  finally
    mErrors.Free;
  end;
end;



//zvaliduje balíky
procedure ValidatePackages(const APackagesDataSet, AHeaderDataSet, AContentDataSet: TDataSet; AOS: TNxCustomObjectSpace; var AErrors, ASoftErrors: TStringList);
var
  bm: TBookmark;
  mErrors, mSoftErrors: TStringList;
  mNumberII: String;
  mProviderDriver: integer;
begin
  mErrors := TStringList.Create;
  try
    mSoftErrors := TStringList.Create;
    try
      mErrors.Clear;
      mSoftErrors.Clear;
      if ValidateHeaderValue(APackagesDataSet, AHeaderDataSet, AOS, mErrors, mSoftErrors) then begin
        bm := APackagesDataSet.GetBookmark;
        AHeaderDataSet.First;
        mProviderDriver := AHeaderDataSet.FieldByName(cFDPDMProviderDriver).AsInteger;
        APackagesDataSet.DisableControls;
        try
          APackagesDataSet.First;
          while not APackagesDataSet.Eof do begin
            mNumberII := APackagesDataSet.FieldByName(cFDDisplayNumber).AsString;
            mErrors.Clear;
            mSoftErrors.Clear;
            if ValidateValues(APackagesDataSet, AOS, mErrors, mSoftErrors, mProviderDriver) then
              CreatePackagesForDSRow(APackagesDataSet, AHeaderDataSet,AContentDataSet, AOS, mErrors, mSoftErrors, cOnlyValidate,nil);
            if trim(mSoftErrors.Text) <> '' then begin
              ASoftErrors.Add(Format(lng_fnc_ValidatePackages, [mNumberII]));
              ASoftErrors.AddStrings(mSoftErrors);
            end;
            if trim(mErrors.Text) <> '' then begin
              AErrors.Add(Format(lng_fnc_ValidatePackages, [mNumberII]));
              AErrors.AddStrings(mErrors);
            end;
            APackagesDataSet.Next;
          end;
        finally
          APackagesDataSet.GotoBookmark(bm);
          APackagesDataSet.EnableControls;
        end;
      end else begin
        if trim(mSoftErrors.Text) <> '' then begin
          ASoftErrors.AddStrings(mSoftErrors);
        end;
        if trim(mErrors.Text) <> '' then begin
          AErrors.AddStrings(mErrors);
        end;
      end;
    finally
      mSoftErrors.Free;
    end;
  finally
    mErrors.Free;
  end;
end;

//vytvoří balíky pro odeslané poště
procedure CreatePackagesForDSRow(const APackagesDataSet, AHeaderDataSet, AContentDataSet: TDataSet; AOS: TNxCustomObjectSpace; var AErrors, ASoftErrors: TStringList; const AOnlyValidate: Boolean; var ACreatedPackageID: TStringList);
var
  mID, mFirstPackage_ID : TNxOID;
  mCount, i, mRelDef : integer;
  mInTransaction: Boolean;
  mProviderDriver : integer;
  mModulNameBB: String;
begin
  mProviderDriver := AHeaderDataSet.FieldByName(cFDPDMProviderDriver).AsInteger;
  //mModulNameBB := UpperCase(GetSubModulNameByID(AOS,AHeaderDataSet.FieldByName(cFDPDMProvider).AsString));
  APackagesDataSet.Edit;
  mCount := GetContentCount(TMemoryDataset( APackagesDataSet),TMemoryDataset( AContentDataSet));
  APackagesDataSet.FieldByName(cFDCount).AsInteger := mCount;
  APackagesDataSet.Post;

  mFirstPackage_ID := '';
  for i:= 0 to mCount-1 do begin
    if not AOnlyValidate then
      OSStartTransaction(AOS, mInTransaction);
    try
      mID := CreatePackage(APackagesDataSet, AHeaderDataSet,AContentDataSet, AOS, i, mFirstPackage_ID, AErrors, ASoftErrors, AOnlyValidate);
      if ((Assigned(ACreatedPackageID) )and( ACreatedPackageID <> nil)) then
        ACreatedPackageID.add(mID);
      if not AOnlyValidate then begin
        if not CFxOID.IsEmpty(mID) then begin
          mRelDef := GetRelDef(APackagesDataSet.FieldByName(cFDDocumentType).AsString);
          CreateRelation(APackagesDataSet.FieldByName(cFDID).AsString, mID, AOS, mRelDef);
          CreateRelationToRelatedIDs( APackagesDataSet.FieldByName(cFDRelationWithIDs).AsString,mID, AOS, mRelDef); //Funkce na sloučenou tvorbu balíku.
          try
            APackagesDataSet.Edit;
            SetExistCount(AOS, AHeaderDataSet.FieldByName(cFDPDMProvider).AsString, APackagesDataSet, APackagesDataSet.FieldByName(cFDDocumentType).AsString);
            APackagesDataSet.Post;
          except
            ShowMessage('Chyba SetExistCount');
          end;
          if (i = 0) then
            mFirstPackage_ID := mID;
        end;
      end;
    //commit
    if not AOnlyValidate then
      OSCommit(AOS, mInTransaction);
    except
      if not AOnlyValidate then
        OSRollBack(AOS, mInTransaction);
      AErrors.Add(ExceptionMessage);
    end;
  end;
end;

//vytvoří jeden balík v odeslané poště
function CreatePackage(const APackagesDataSet, AHeaderDataSet,AContentDataSet: TDataSet; AOS: TNxCustomObjectSpace; const APosIndex: integer; const AFirstPackage_ID: TNxOID; var AErrors, ASoftErrors: TStringList; const AOnlyValidate: Boolean): TNxOID;
var
  mBO: TNxCustomBusinessObject;
  mSite: TSiteForm;
  mValidateError: TStringList;
  mSourceID, mID: TNxOID;
  mProviderDriver, i, mCount, mState: integer;
  mPostNumber, mMessage: string;
begin
  Result := '0000000000';
  mBO := AOS.CreateObject(Class_PDMIssuedDoc);
  try
    if not AOnlyValidate then
      mBO.New
    else
      mBO.NewWithoutIdentity;
    mBO.Prefill;

    mSourceID := APackagesDataSet.FieldByName(cFDID).AsString;
    mBO.SetFieldValueAsString('CreatedBy_ID', NxGetActualUserID(AOS));
    mBO.SetFieldValueAsInteger('X_PD_PosIndex', APosIndex+1);
    mBO.SetFieldValueAsInteger('X_PD_Status',1);

    mProviderDriver := AHeaderDataSet.FieldByName(cFDPDMProviderDriver).AsInteger;

    FillValuesFromHeaderDataset(AHeaderDataSet, mBO);
    FillValuesFromSourceDoc(mSourceID, APackagesDataSet.FieldByName(cFDDocumentType).AsString, mBO);
    FillValuesFromPackagesDataset(APackagesDataSet, mBO, APosIndex, mProviderDriver);
    FillValuesFromContentDataset(APackagesDataSet,AContentDataSet , mBO, APosIndex);

    if not CFxOID.IsEmpty(AFirstPackage_ID) then
      mBO.SetFieldValueAsString('X_PD_FirstPackage_ID', AFirstPackage_ID);

    mValidateError:= TStringList.Create;
    try
      //uz se uklada
      if not AOnlyValidate then begin
        mValidateError.Clear;
        if not mBO.Validate then begin
          mBO.GetValidateErrors(mValidateError);
          for i:= 0 to mValidateError.Count-1 do
            AErrors.Add(mValidateError.ValueFromIndex[i]);
        end else begin
          mBO.Save;
          Result := mBO.OID;
        end;
      //jen se validuje
      end else begin
        //u prvniho baliku ve skupine
        if (APosIndex = 0) then begin
          //zjistim jestli je dost podacich cisel
          mCount := APackagesDataSet.FieldByName(cFDCount).AsInteger;
        end;

        mValidateError.Clear;
        if not mBO.SoftValidate then
          mBO.GetValidateErrors(mValidateError);
        for i:= 0 to mValidateError.Count-1 do
          ASoftErrors.Add(mValidateError.ValueFromIndex[i]);
        mValidateError.Clear;
        if not mBO.Validate then
          mBO.GetValidateErrors(mValidateError);
        for i:= 0 to mValidateError.Count-1 do
          AErrors.Add(mValidateError.ValueFromIndex[i]);
      end;
    finally
      mValidateError.Free;
    end;
  finally
    mBO.Free;
  end;
end;

//vyplní položky BO z datasetu hlavicky
procedure FillValuesFromHeaderDataset(const AHeaderDataSet: TDataSet; var ABO: TNxCustomBusinessObject);
begin
  ABO.SetFieldValueAsString('Period_ID', AHeaderDataSet.FieldByName(cFDPeriod).AsString);
  ABO.SetFieldValueAsString('BusOrder_ID', AHeaderDataSet.FieldByName(cFDBusOrder).AsString);
  ABO.SetFieldValueAsString('BusTransaction_ID', AHeaderDataSet.FieldByName(cFDBusTransaction).AsString);
//todo az bude na BO odeslana posta BusProject
//  ABO.SetFieldValueAsString('BusProject_ID', AHeaderDataSet.FieldByName(cFDBusBusProject).AsString);
  ABO.SetFieldValueAsDateTime('DocDate$DATE', AHeaderDataSet.FieldByName(cFDDate).AsDateTime);
  ABO.SetFieldValueAsString('DocQueue_ID', AHeaderDataSet.FieldByName(cFDDocQueue).AsString);
  ABO.SetFieldValueAsString('PostProvider_ID', AHeaderDataSet.FieldByName(cFDPDMProvider).AsString);
  ABO.SetFieldValueAsString('Sender_ID', AHeaderDataSet.FieldByName(cFDPDMUser).AsString);
  if CFxOID.IsEmpty(ABO.GetFieldValueAsString('Division_ID')) then
    ABO.SetFieldValueAsString('Division_ID', AHeaderDataSet.FieldByName(cFDDivision).AsString);
  ABO.SetFieldValueAsString('BankAccount_ID', AHeaderDataSet.FieldByName(cFDBankAccount).AsString);
  if not CFxOID.IsEmpty(AHeaderDataSet.FieldByName(cFDStore).AsString) then
    ABO.SetFieldValueAsString('X_PD_Store_ID', AHeaderDataSet.FieldByName(cFDStore).AsString);
  if not CFxOID.IsEmpty(AHeaderDataSet.FieldByName(cFDSetting).AsString) then
    if ABO.HasField('X_PD_Setting_ID') then
      ABO.SetFieldValueAsString('X_PD_Setting_ID', AHeaderDataSet.FieldByName(cFDSetting).AsString);
end;



//vyplní položky BO z datasetu hlavicky
procedure FillValuesFromContentDataset(const APackagesDataSet, AContentDataSet: TDataSet; var ABO: TNxCustomBusinessObject; const APosIndex: Integer);
begin
  //posindex shoduje, budu plnit data
  AContentDataSet.First;
  while not AContentDataSet.Eof do
  begin
    if (APackagesDataSet.FieldByName(cFDID).AsString = AContentDataSet.FieldByName(cFDParentID).AsString) then
      if (AContentDataSet.FieldByName(cFDPosIndex).AsInteger-1) = APosIndex then
      begin
        ABO.SetFieldValueAsInteger('WeightUnit', AContentDataSet.FieldByName(cFDWeightUnit).AsInteger);
        ABO.SetFieldValueAsFloat('Weight', AContentDataSet.FieldByName(cFDWeight).AsFloat);

        if not NxIsEmptyOID(AContentDataSet.FieldByName(cFDManipulationUnit).AsString) then
        begin
          ABO.SetFieldValueAsString('X_PD_ManipulationUnit_1_ID',AContentDataSet.FieldByName(cFDManipulationUnit).AsString);
          ABO.SetFieldValueAsFloat('X_PD_MUnit_Count_1',1);
        end;

        ABO.SetFieldValueAsString('X_PD_ManipulationUnit_1_ID',AContentDataSet.FieldByName(cFDManipulationUnit).AsString);

        ABO.SetFieldValueAsFloat('X_PD_Width', AContentDataSet.FieldByName(cFDWidth).AsFloat );
        ABO.SetFieldValueAsFloat('X_PD_Height', AContentDataSet.FieldByName(cFDHeight).AsFloat );
        ABO.SetFieldValueAsFloat('X_PD_Length', AContentDataSet.FieldByName(cFDLength).AsFloat );
        ABO.SetFieldValueAsFloat('X_PD_Volume', AContentDataSet.FieldByName(cFDVolume).AsFloat );
        ABO.SetFieldValueAsString('Description',NxLeft( AContentDataSet.FieldByName(cFDContent).AsString,100));

        //ADR - Odkomentovat
        //if not NxIsEmptyOID(APackagesDataSet.FieldByName(cFDADRUnit+IntToStr((APosIndex))).AsString) then
        //begin
        //  ABO.SetFieldValueAsString('X_ADRUnit_ID',APackagesDataSet.FieldByName(cFDADRUnit+IntToStr((APosIndex))).AsString );
        //end;


        break;
      end;
    AContentDataSet.Next;
  end;

end;


//vyplní položky BO z datasetu baliku
procedure FillValuesFromPackagesDataset(const APackagesDataSet: TDataSet; var ABO: TNxCustomBusinessObject; const APosIndex, AProviderDriver: integer);
var
  mIssuedContent_ID, mPDMServiceType_ID: TNxOID;
  i, mCount, mCount2, mCount3: integer;
  mSQL, mWhere, mPostProvider_ID, mCOD_ServiceType_ID, mFirmBankAccount_ID, mModulNameBB: string;
  mOnlyFirstIDs: TStringList;
begin


  //v3.2 - plníme adresu podle ID z datasetu
  ABO.SetFieldValueAsString('Firm_ID', APackagesDataSet.FieldByName(cFDFirm_ID).AsString);
  ABO.SetFieldValueAsString('FirmOffice_ID', APackagesDataSet.FieldByName(cFDFirmOffice_ID).AsString);
  ABO.SetFieldValueAsString('Person_ID', APackagesDataSet.FieldByName(cFDPerson_ID).AsString);

  if ABO.HasField('X_Sender_Firm_ID') then
  ABO.SetFieldValueAsString('X_Sender_Firm_ID', APackagesDataSet.FieldByName(cFDFirm_ID+cFDSen).AsString);
  if ABO.HasField('X_Sender_FirmOffice_ID') then
  ABO.SetFieldValueAsString('X_Sender_FirmOffice_ID', APackagesDataSet.FieldByName(cFDFirmOffice_ID+cFDSen).AsString);
  if ABO.HasField('X_Sender_Person_ID') then
  ABO.SetFieldValueAsString('X_Sender_Person_ID', APackagesDataSet.FieldByName(cFDPerson_ID+cFDSen).AsString);


  ABO.SetFieldValueAsString('IssuedContent_ID', APackagesDataSet.FieldByName(cFDContentType).AsString);
  ABO.SetFieldValueAsString('X_PD_Currency_ID',APackagesDataSet.FieldByName(cFDCurrency).AsString);
  if (APosIndex = 0) then
    ABO.SetFieldValueAsFloat('InsuredValue', APackagesDataSet.FieldByName(cFDAmount).AsFloat);

  ABO.SetFieldValueAsString('X_PD_NoteForDriver', APackagesDataSet.FieldByName(cFDNoteForDriver).AsString);
  ABO.SetFieldValueAsString('X_PD_SourceDocType', APackagesDataSet.FieldByName(cFDDocumentType).AsString);
  ABO.SetFieldValueAsString('X_PD_SourceDocID', APackagesDataSet.FieldByName(cFDID).AsString);


  ABO.SetFieldValueAsDateTime('X_PD_PickupFrom',  APackagesDataSet.FieldByName(cFDPickupDate).AsDateTime   + TimeOf( APackagesDataSet.FieldByName(cFDPickupTimeFrom).AsDateTime ) );
  ABO.SetFieldValueAsDateTime('X_PD_PickupTo', APackagesDataSet.FieldByName(cFDPickupDate).AsDateTime   + TimeOf( APackagesDataSet.FieldByName(cFDPickupTimeTo).AsDateTime ) );

  ABO.SetFieldValueAsDateTime('X_PD_DeliveryFrom', APackagesDataSet.FieldByName(cFDDeliveryDate).AsDateTime   + TimeOf( APackagesDataSet.FieldByName(cFDDeliveryTimeFrom).AsDateTime ) );
  ABO.SetFieldValueAsDateTime('X_PD_DeliveryTo', APackagesDataSet.FieldByName(cFDDeliveryDate).AsDateTime   + TimeOf( APackagesDataSet.FieldByName(cFDDeliveryTimeTo).AsDateTime ) );



  mModulNameBB := GetSubModulName(ABO.GetFieldValueAsInteger('PostProvider_ID.X_PD_BB_ProviderModul'));
  begin
    case APosIndex of
    0..2:
      begin

      end;
    end;
  end;

  //Balíkobt TopTrans Vratné obaly
  ABO.SetFieldValueAsString('X_PD_MUnitNote_Back',APackagesDataSet.FieldByName(cFDMUnitNoteBack).AsString);
  ABO.SetFieldValueAsFloat('X_PD_MUnitCount_Back',APackagesDataSet.FieldByName(cFDManipulationUnitCountBack).AsFloat);

  ABO.SetFieldValueAsInteger('TargetAddressType', APackagesDataSet.FieldByName(cFDTargetAddressType).AsInteger);
  ABO.SetFieldValueAsFloat('CashOnDelivery', 0);
  ABO.SetFieldValueAsString('VarSymbol', APackagesDataSet.FieldByName(cFDVarSymbol).AsString);
  //doplňkové služby
  //dobirka   -- Pro PPL bylo nutné ošetřit problém kdy se na následující balík přenesla cena.
  if APackagesDataSet.FieldByName(cFDCashOnDelivery).AsFloat > 0 then begin
    ABO.SetFieldValueAsFloat('CashOnDelivery', APackagesDataSet.FieldByName(cFDCashOnDelivery).AsFloat);

    mSQL := '';
    mWhere := '';
    mPDMServiceType_ID := '';
    mPostProvider_ID := ABO.GetFieldValueAsString('PostProvider_ID');

  end;
  //při-pojištění
  if (APosIndex = 0) and (APackagesDataSet.FieldByName(cFDInsurance).AsFloat > 0) then begin
    mSQL := '';
    mWhere := '';
    ABO.SetFieldValueAsFloat('X_PD_Insurance', APackagesDataSet.FieldByName(cFDInsurance).AsFloat);
    ABO.SetFieldValueAsFloat('InsuredValue', APackagesDataSet.FieldByName(cFDInsurance).AsFloat);
  end;
  mOnlyFirstIDs := TStringList.Create;
  try
    for i:= 0 to cServiceTypeMaxCount-1 do begin
      mPDMServiceType_ID := APackagesDataSet.FieldByName(cFDPDMServiceType+IntToStr(i)).AsString;
      if (APosIndex = 0) then begin
        AddServiceType(ABO, mPDMServiceType_ID)
      end else begin
        if (mOnlyFirstIDs.IndexOf(mPDMServiceType_ID) = -1) then
          AddServiceType(ABO, mPDMServiceType_ID)
      end;
    end;
  finally
    mOnlyFirstIDs.Free;
  end;
  ABO.SetFieldValueAsInteger('X_PD_Count', APackagesDataSet.FieldByName(cFDCount).AsInteger);
end;


//vyplní položky BO ze zdrojového dokladu
procedure FillValuesFromSourceDoc(const ASourceID: TNxOID; ADocumentType: String; var ABO: TNxCustomBusinessObject);
var
  mOS: TNxCustomObjectSpace;
  mSourceBO: TNxCustomBusinessObject;
  mCopyValues: TStringList;

  //položky kopírované z dokladu
  procedure AddCopyValues(var ACopyValues: TStringList; const ASourceBO, ADestBO: TNxCustomBusinessObject);
  begin
    ACopyValues.Clear;
    (*if ASourceBO.HasField('Firm_ID') then
      ACopyValues.Add('Firm_ID');
    if ASourceBO.HasField('FirmOffice_ID') then
      ACopyValues.Add('FirmOffice_ID');
    if ASourceBO.HasField('Person_ID') then
      ACopyValues.Add('Person_ID');
      *)
    //pokud nebyl vyplnen ucet na formu tak vezmu ucet ze zdrojoveho dokladu
    if CFxOID.IsEmpty(ADestBO.GetFieldValueAsString('BankAccount_ID')) then begin
      if ASourceBO.HasField('BankAccount_ID') then
        ACopyValues.Add('BankAccount_ID');
    end;
    if ASourceBO.HasField('ConstSymbol_ID') then
      ACopyValues.Add('ConstSymbol_ID');
  end;

begin
  mOS:= ABO.ObjectSpace;
  mCopyValues := TStringList.Create;
  try
    mSourceBO := mOS.CreateObject(GetBOCLSID(ADocumentType));
    try
      mSourceBO.Load(ASourceID, nil);
      AddCopyValues(mCopyValues, mSourceBO, ABO);
      if mCopyValues.Count > 0 then
        ABO.CopyFieldValuesFrom(mSourceBO, mCopyValues, False);
      if mSourceBO.HasField('Currency_ID') then
        ABO.SetFieldValueAsString('X_PD_Currency_ID', mSourceBO.GetFieldValueAsString('Currency_ID'));
    finally
      mSourceBO.Free;
    end;
  finally
    mCopyValues.Free;
  end;
end;

//přidá typ sluzby pokud jiz na dokladu neni
procedure AddServiceType(var ABO: TNxCustomBusinessObject; const APDMServiceType_ID: TNxOID);
var
  mPDMServiceTypes: TNxCustomBusinessMonikerCollection;
  mPDMServiceTypeBO: TNxCustomBusinessObject;
  i: integer;
  mFound: Boolean;
begin
  if CFxOID.IsEmpty(APDMServiceType_ID) then
    exit;
  mPDMServiceTypes := ABO.GetLoadedCollectionMonikerForFieldCode(ABO.GetFieldCode('Rows'));
  mFound := false;
  for i:= 0 to mPDMServiceTypes.Count - 1 do begin
    mPDMServiceTypeBO := mPDMServiceTypes.BusinessObject[i];
    if osMarkForDelete in mPDMServiceTypes.BusinessObject[i].State then continue;
    mFound := (mPDMServiceTypeBO.GetFieldValueAsString('ServiceType_ID') = APDMServiceType_ID);
    if mFound then break;
  end;
  if not mFound then begin
    mPDMServiceTypeBO := mPDMServiceTypes.AddNewObject;
    mPDMServiceTypeBO.SetFieldValueAsString('ServiceType_ID', APDMServiceType_ID);
  end;
end;

//vytvoří vazbu dokladu FV, OP nebo DL a odeslané pošty
procedure CreateRelation(const mRIGHTSIDE_ID, mIDPID: TNxOID; AOS: TNxCustomObjectSpace; const AREL_DEF: Integer);
var
  mBO: TNxCustomBusinessObject;
begin
  mBO := AOS.CreateObject(Class_Relation);
  try
    mBO.New;
    mBO.SetFieldValueAsInteger('REL_DEF', AREL_DEF);
    mBO.SetFieldValueAsInteger('NUMVALUE', 1);
    mBO.SetFieldValueAsString('LEFTSIDE_ID', mIDPID);
    mBO.SetFieldValueAsString('RIGHTSIDE_ID', mRIGHTSIDE_ID);
    mBO.Save;
  finally
    mBO.Free;
  end;
end;


//vytvoří vazbu na další doklady, které jsou podané ve sloučeném podání
procedure CreateRelationToRelatedIDs(const mRIGHTSIDE_IDs, mIDPID: String; AOS: TNxCustomObjectSpace; const AREL_DEF: Integer);
var
  mBO: TNxCustomBusinessObject;
  mIDs :TStringList;
  i: Integer;
begin
  mIDs := TStringList.Create;
  try
    mIDs.CommaText := mRIGHTSIDE_IDs;
    for i := 0 to mIDs.Count -1 do
    begin
      mBO := AOS.CreateObject(Class_Relation);
      try
        mBO.New;
        mBO.SetFieldValueAsInteger('REL_DEF', AREL_DEF);
        mBO.SetFieldValueAsInteger('NUMVALUE', 1);
        mBO.SetFieldValueAsString('LEFTSIDE_ID', mIDPID);
        mBO.SetFieldValueAsString('RIGHTSIDE_ID',mIDs[i]  );
        mBO.Save;
      finally
        mBO.Free;
        mBO := nil;
      end;
    end;
  finally
    mIDs.free;
  end;
end;

//overime hlavickove udaje
function ValidateHeaderValue(const APackagesDataSet, AHeaderDataSet: TDataSet; const AOS: TNxCustomObjectSpace; var AErrors, ASoftErrors: TStringList): boolean;
var
  mContext: TNxContext;
begin
  try
    Result := false;
    AErrors.Clear;
    mContext := NxCreateContext(AOS);

    if CFxOID.IsEmpty(AHeaderDataSet.FieldByName(cFDDocQueue).AsString) then
      AErrors.Add(lng_fnc_ValidateHeaderValue0);

    if CFxOID.IsEmpty(AHeaderDataSet.FieldByName(cFDPeriod).AsString) then
      AErrors.Add(lng_fnc_ValidateHeaderValue1);

    if not (AHeaderDataSet.FieldByName(cFDDate).AsDateTime >= 0) then
      AErrors.Add(lng_fnc_ValidateHeaderValue2);

    if CFxOID.IsEmpty(AHeaderDataSet.FieldByName(cFDPDMUser).AsString) then
      AErrors.Add(lng_fnc_ValidateHeaderValue3);

    if CFxOID.IsEmpty(AHeaderDataSet.FieldByName(cFDDivision).AsString) then
      AErrors.Add(lng_fnc_ValidateHeaderValue4);

    if CFxOID.IsEmpty(AHeaderDataSet.FieldByName(cFDPDMProvider).AsString) then
      AErrors.Add(lng_fnc_ValidateHeaderValue5);

    if (mContext.GetCompanyCache.BusOrdersUsage = cUseBusObjects) and CFxOID.IsEmpty(AHeaderDataSet.FieldByName(cFDBusOrder).AsString) then
      AErrors.Add(lng_fnc_ValidateHeaderValue6);

    if (mContext.GetCompanyCache.BusTransactionsUsage = cUseBusObjects) and CFxOID.IsEmpty(AHeaderDataSet.FieldByName(cFDBusTransaction).AsString) then
      AErrors.Add(lng_fnc_ValidateHeaderValue7);

    //todo az bude na BO Odeslana posta BusProject
    (*
    if (mSite.CompanyCache.BusProjectsUsage = cUseBusObjects) and CFxOID.IsEmpty(AHeaderDataSet.FieldByName(cFDBusProjects).AsString) then
      AErrors.Add('Není zadán projekt.');
    *)
  finally
    mContext.free;
  end;
  Result := (AErrors.Count = 0);
end;

//overime počet balíků
function ValidateValues(const APackagesDataSet: TDataset; const AOS: TNxCustomObjectSpace; var AErrors, ASoftErrors: TStringList; AProviderDriver: integer): Boolean;
var
  mList: TStringList;
  mFrom, mTmp, mCity, mStreet, mPostCode, mCountryCode, mPhoneNumber: string;
  i: integer;
  mError: Boolean;
begin
  Result := False;
  mList := TStringList.Create;
  try
    //pocet baliku

    if (APackagesDataSet.FieldByName(cFDCount).AsInteger <= 0) then
      mList.Add(lng_fnc_ValidateValuesError1)
    else if (APackagesDataSet.FieldByName(cFDCount).AsInteger > cMaxCount) then
      mList.Add(Format(lng_fnc_ValidateValuesError11, [IntToStr(cMaxCount)]));



    //musi byt vyplneno mesto, ulice, PSČ, kód země v adrese
    mTmp := GetAddress(AOS, APackagesDataSet, true);
    if (mTmp <> '') then begin
      mCity := NxTrim(NxTrapStr(mTmp, ';'), '"');
      mStreet := NxTrim(NxTrapStr(mTmp, ';'), '"');
      mPostCode := NxTrim(NxTrapStr(mTmp, ';'), '"');
      mCountryCode := NxTrim(NxTrapStr(mTmp, ';'), '"');
      mPhoneNumber := NxTrim(NxTrapStr(mTmp, ';'), '"');
      case APackagesDataSet.FieldByName(cFDTargetAddressType).AsInteger of
        cFromFirm: mFrom := lng_field_Firms;
        cFromFirmOffice: mFrom := lng_field_FirmOffices;
        cFromPerson: mFrom := lng_field_Persons;
      end;
      //prazdne mesto
      if not(mCity <> '') then
        mList.Add(Format(lng_fnc_ValidateValuesError2, [mFrom, lng_fnc_ValidateValues_City]));

      //prazdna ulice
      if not(mStreet <> '') then
        mList.Add(Format(lng_fnc_ValidateValuesError2, [mFrom, lng_fnc_ValidateValues_Street]));

      //prazdne PSC
      if not(mPostCode <> '') then
        mList.Add(Format(lng_fnc_ValidateValuesError2, [mFrom, lng_fnc_ValidateValues_ZIP]));
    end;

    Result := (mList.Count = 0);
    if not Result then
      AErrors.AddStrings(mList);
  finally
    mList.Free;
  end;
end;


begin
end.