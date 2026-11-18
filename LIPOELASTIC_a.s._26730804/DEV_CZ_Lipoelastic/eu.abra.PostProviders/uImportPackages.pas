uses
  'eu.abra.PostProviders.uConst',
  'eu.abra.PostProviders.uAddressFunc',
  'eu.abra.PostProviders.uPostProvider',
  'eu.abra.PostProviders.uSQLFunc';

//vrátí data pro formulář
procedure GetData(ASite: TSiteForm);
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
  mDocumentType, mIDsCommaText: string;
  mServiceType: Integer;
begin
  CFxProfiler.EnterProc('postprovider', 'GetData');
  mSourceSite := nil;
  mDocumentType := '';
  mIDsCommaText := '';
  mServiceType := 0;
  mSQL := '';
  if Assigned(TRollSiteForm(ASite).SiteParams) then begin
    if TRollSiteForm(ASite).SiteParams.ParamExist(NxGetActualUserID(ASite.BaseObjectSpace)+cLastSite) then begin
      mDocumentType := TRollSiteForm(ASite).SiteParams.ParamAsString(NxGetActualUserID(ASite.BaseObjectSpace)+cLastSite, '');
      if TRollSiteForm(ASite).SiteParams.ParamExist(NxGetActualUserID(ASite.BaseObjectSpace)+cPackages_Site) then
        mSourceSite := TSiteForm(IntToObj(TRollSiteForm(ASite).SiteParams.ParamAsInteger(NxGetActualUserID(ASite.BaseObjectSpace)+cPackages_Site, 0)));
      if TRollSiteForm(ASite).SiteParams.ParamExist(NxGetActualUserID(ASite.BaseObjectSpace)+cServiceType) then
        mServiceType := TRollSiteForm(ASite).SiteParams.ParamAsInteger(NxGetActualUserID(ASite.BaseObjectSpace)+cServiceType, 0);
      if TRollSiteForm(ASite).SiteParams.ParamExist(NxGetActualUserID(ASite.BaseObjectSpace)+cRelationWithIDs) then
        mIDsCommaText := TRollSiteForm(ASite).SiteParams.ParamAsString(NxGetActualUserID(ASite.BaseObjectSpace)+cRelationWithIDs, '');

    end;
  end;
  mOS := ASite.BaseObjectSpace;
  mIDs := TStringList.Create;
  mData := TMemoryDataset(TDataSource(ASite.FindComponent(cdsPackagesData)).DataSet);
  try
    GetIDsFromSite(mSourceSite, ASite, mIDs, mDocumentType, mIDsCommaText);
    mSQL := GetSQLSource(mDocumentType,mOS);
    if (mIDs.Count = 0) then begin
      NxShowSimpleMessage(lng_msg_SelectDoc, ASite);
      exit;
    end;
    mStation_ID := StringsToSelDat(mOS, mIDs);
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
          medPDMPRovider := TRollComboEdit(ASite.FindChildControl(cedPDMProvider));
          mPostProvider := medPDMPRovider.DataText;
          SetAddInfo(mOS, mPostProvider, mData, mDocumentType);
          SetServiceType(mData,mServiceType);
          SetRelationWithIDs(mData,mIDsCommaText);
          SetPackagesEvents(mData);
          CreateContent(TDataSource(ASite.FindComponent(cdsContent)).DataSet);
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
  CFxProfiler.ExitProc('postprovider', 'GetData');
end;

procedure SetRelationWithIDs(var APackagesDataSet: TDataSet; AIDsCommaText:String);
begin
  try
    APackagesDataSet.DisableControls;

    APackagesDataSet.Edit;
    APackagesDataSet.FieldByName(cFDRelationWithIDs).AsString := AIDsCommaText;
    APackagesDataSet.Post;

  finally
    APackagesDataSet.EnableControls;
  end;
end;

procedure CreateContent(var AContentDataset: TDataSet);
begin

  AContentDataset.Active := true;
  AddContentRow(TMemoryDataset(AContentDataset));
end;

procedure SetServiceType(var APackagesDataSet: TDataSet; AServiceType:Integer);
begin
  APackagesDataSet.DisableControls;
  try
    APackagesDataSet.First;
    while not APackagesDataSet.Eof do begin
      APackagesDataSet.Edit;
      APackagesDataSet.FieldByName(cFDServiceType).AsInteger := AServiceType;
      APackagesDataSet.Post;
      APackagesDataSet.Next;
    end;
  finally
    APackagesDataSet.EnableControls;
  end;
end;

//na datasetu Baliku nastavi event
procedure SetPackagesEvents(var APackagesDataSet: TDataSet);
var
  mField: TField;
begin
  mField:= APackagesDataSet.Fields.FindField(cFDTargetAddressType);
  if mField <> nil then
    mField.OnChange := @FieldTargetAddressTypeOnChange;
  mField:= APackagesDataSet.Fields.FindField(cFDTargetAddressTypeSen);
  if mField <> nil then
    mField.OnChange := @FieldSenTargetAddressTypeOnChange;
  APackagesDataSet.AfterScroll := @PackagesDataSetAfterScroll;
end;

procedure PackagesDataSetAfterScroll(ADataset: TDataset);
const
  cSQL = 'select sdoc.Firm_ID from %s sdoc '+
         'where sdoc.ID = %s';
var
  mSite: TSiteForm;
  mIndex: integer;
  mOS: TNxCustomObjectSpace;
  mFirmID, mID: TNxOID;
  mTmp, mSQL, mTableName: string;
  mGrid: TMultiGrid;
  mColumn: TNxMultiGridCustomColumn;
begin
  mSite := ADataset.Site;
  mOS := mSite.BaseObjectSpace;

  mID := ADataset.FieldByName(cFDID).AsString;
  if CFxOID.IsEmpty(mID) then
    exit;
  mTableName:= GetTableName(ADataset.FieldByName(cFDDocumentType).AsString);

  mSQL := Format(cSQL, [mTableName, QuotedStr(mID)]);
  mFirmID := GetFirstRecordFromSQL(mOS, mSQL);

  mGrid := TMultiGrid(mSite.FindChildControl(cgrdPackagesData));
(*
  //_Firm_ID
  mIndex := TNxMultiGridCustomRollColumn(TMultiGrid(mGrid).ColumnByName(ccolFirmBankAccount+IntToStr(cLayoutFirm))).Parameters.IndexOfName('_Firm_ID');
  if (mIndex <> -1) then
    TNxMultiGridCustomRollColumn(TMultiGrid(mGrid).ColumnByName(ccolFirmBankAccount+IntToStr(cLayoutFirm))).Parameters.Delete(mIndex);
  TNxMultiGridCustomRollColumn(TMultiGrid(mGrid).ColumnByName(ccolFirmBankAccount+IntToStr(cLayoutFirm))).Parameters.Add('_Firm_ID='+mFirmID);

  mIndex := TNxMultiGridCustomRollColumn(TMultiGrid(mGrid).ColumnByName(ccolFirmBankAccount+IntToStr(cLayoutPerson))).Parameters.IndexOfName('_Firm_ID');
  if (mIndex <> -1) then
    TNxMultiGridCustomRollColumn(TMultiGrid(mGrid).ColumnByName(ccolFirmBankAccount+IntToStr(cLayoutPerson))).Parameters.Delete(mIndex);
  TNxMultiGridCustomRollColumn(TMultiGrid(mGrid).ColumnByName(ccolFirmBankAccount+IntToStr(cLayoutPerson))).Parameters.Add('_Firm_ID='+mFirmID);
*)
end;


//zkopiruje dataset
procedure CopyDataset(var ADest: TMemoryDataset; const ASource: TMemoryDataset);
var
  i: integer;
  mField: TField;
  mFieldName: String;
begin
  if ADest.Active then
    ADest.Close;
  ADest.EmptyTable;

  ADest.DisableControls;
  try
    ADest.Open;
    ADest.Edit;
    ASource.First;
    while not ASource.Eof do begin
      for i:= 0 to ASource.FieldCount - 1 do begin
        mFieldName := TField(ASource.Fields[i]).FieldName;
        mField:= ADest.Fields.FindField(mFieldName);
        if mField <> nil then
          mField.AsString := TField(ASource.Fields[i]).AsString;
      end;
      ADest.Append;
      ASource.Next;
    end;
  finally
    ADest.EnableControls;
  end;
end;

//pokud neni zadana ASourceSite tak otevre agendu pro vyber,
//jinak vybere oznacene
procedure GetIDsFromSite(ASourceSite, ASite: TSiteForm; var AIDs: TStringList; var ADocType: string; ARelationWithIDs:String = '');
var
  mOle, mAgenda, mStrings : Variant;
  mResult : Boolean;
  i: integer;
  mDocType, mSiteCLSID: string;
  mP: TNxParameters;
begin
  if (ASourceSite = nil) then begin
    mDocType := FormGetDocType(ASite);
    mSiteCLSID := GetSiteCLSID(mDocType);
    ADocType := mDocType;
    mOLE := GetAbraOLEApplication;
    mStrings := mOLE.CreateStrings;
    mAgenda := mOLE.GetAgenda(mSiteCLSID);
    mResult := mAgenda.MultiSelect('QueryPage', mStrings);
    AIDs.Clear;
    if mResult then begin
      for i:= 0 to mStrings.Count-1 do begin
        AIDs.Add(mStrings.Strings[i]);
      end;
    end;
  end else
  begin
    if ARelationWithIDs <> '' then
    begin
      AIDs.add(TDynSiteForm(ASourceSite).CurrentObject.OID);
    end
    else
      ASourceSite.List.GetSelectedId(AIDs);
  end;
end;

//formular na vyber agendy, ktera se ma otevrit
function FormGetDocType(AParent: TSiteForm) : string;
var
  mForm: TForm;
  rg   : TRadioGroup;
  mbtnOK  : TButton;
begin
  result := '';
  mForm := TForm.Create(AParent);
  try
    mForm.Caption     := lng_frmTit_SelectDoc;
    mForm.FormStyle   := fsStayOnTop;
    mForm.BorderStyle := bsDialog;
    mForm.Width       := 225;
    mForm.Height      := 190;
    mForm.Scaled      := False;
    mform.Position    := poScreenCenter;

    rg := TRadioGroup.Create(mForm);
    rg.Parent := mForm;
    rg.Left := 10;
    rg.Top := 10;
    rg.Caption := lng_frmbtn_DocType;
    rg.Items.Add(lng_frmbtn_DocType03);
    rg.Items.Add(lng_frmbtn_DocType21);
    rg.Items.Add(lng_frmbtn_DocTypeRO);
    rg.ItemIndex:= 0; //implicitni

    mbtnOK := TButton.Create(mForm);
    mbtnOK.Top := 120;
    mbtnOK.Left := 20;
    mbtnOK.Width := 70;
    mbtnOK.Height := 25;
    mbtnOK.Caption := 'OK';
    mbtnOK.ModalResult := mrOk;
    mbtnOK.Parent := mForm;

    if (mForm.Showmodal(AParent) = mrOk) then begin
      result := GetDocumentTypeFromRGItemIndex(rg.ItemIndex);
    end;
  finally
    mForm.Free;
  end;
end;

//nastavi format policek datasetu
procedure SetFormat(var APackagesDataSet: TDataSet);
var
  i: integer;
begin
  RTTI.SetStrProp(APackagesDataSet.FieldByName(cFDCashOnDelivery), 'DISPLAYFORMAT', '0.00,');
  APackagesDataSet.FieldByName(cFDCashOnDelivery).EditMask := '';
  RTTI.SetStrProp(APackagesDataSet.FieldByName(cFDAmount), 'DISPLAYFORMAT', '0.00,');
  APackagesDataSet.FieldByName(cFDAmount).EditMask := '';

  RTTI.SetStrProp(APackagesDataSet.FieldByName(cFDPickupTimeFrom), 'DISPLAYFORMAT', 'hh:mm');
  APackagesDataSet.FieldByName(cFDPickupTimeFrom).EditMask := '00:00';

  RTTI.SetStrProp(APackagesDataSet.FieldByName(cFDPickupTimeTo), 'DISPLAYFORMAT', 'hh:mm');
  APackagesDataSet.FieldByName(cFDPickupTimeTo).EditMask := '00:00';

  RTTI.SetStrProp(APackagesDataSet.FieldByName(cFDDeliveryTimeFrom), 'DISPLAYFORMAT', 'hh:mm');
  APackagesDataSet.FieldByName(cFDDeliveryTimeFrom).EditMask := '00:00';

  RTTI.SetStrProp(APackagesDataSet.FieldByName(cFDDeliveryTimeTo), 'DISPLAYFORMAT', 'hh:mm');
  APackagesDataSet.FieldByName(cFDDeliveryTimeTo).EditMask := '00:00';


  //Přesunuto do contentu
  //for i:= 0 to cMaxCount - 1 do begin
  //  RTTI.SetStrProp(APackagesDataSet.FieldByName(cFDWeight+IntToStr(i)), 'DISPLAYFORMAT', '0.000,');
  //  APackagesDataSet.FieldByName(cFDWeight+IntToStr(i)).EditMask := '';
  //end;
end;



//dotahne hmotnost z dokladu
procedure SetWeight(AOS: TNxCustomObjectSpace; var APackagesDataSet: TDataSet; ADocumentType: string);
var
  mBO: TNxCustomBusinessObject;
begin
  mBO := AOS.CreateObject(GetBOCLSID(ADocumentType));
  try
    mBO.Load(APackagesDataSet.FieldByName(cFDID).AsString, nil);
    if mBO.HasField('Weight') then
    begin
      APackagesDataSet.FieldByName(cFDTotalWeight).AsFloat := mBO.GetFieldValueAsFloat('Weight');
      APackagesDataSet.FieldByName(cFDTotalWeightUnit).AsInteger := mBO.GetFieldValueAsInteger('WeightUnit');
    end;
  finally
    mBO.Free;
  end;
end;

//dotahne variabilni symbol z dokladu
procedure SetVarSymbol(AOS: TNxCustomObjectSpace; var APackagesDataSet: TDataSet; ADocumentType: string);
var
  mBO: TNxCustomBusinessObject;
  mVarSymbol, mTmp: string;
  mPrefix: string;
begin
  mBO := AOS.CreateObject(GetBOCLSID(ADocumentType));
  try
    mBO.Load(APackagesDataSet.FieldByName(cFDID).AsString, nil);
    if mBO.HasField('VarSymbol') then
      APackagesDataSet.FieldByName(cFDVarSymbol).AsString := mBO.GetFieldValueAsString('VarSymbol')
    else if mBO.GetFieldValueAsString('DocQueue_ID.DocumentType') <> cDocumentTypeIssuedInvoice then begin
      APackagesDataSet.FieldByName(cFDVarSymbol).AsString := mBO.GetFieldValueAsString('OrdNumber');
    end;
  finally
    mBO.Free;
  end;
end;

//dotahne typ platby a dobirku pro FV a OP
procedure SetPaymentKind(AOS: TNxCustomObjectSpace; var APackagesDataSet: TDataSet);
const
  cSQL = 'select PT.PaymentKind from %s sdoc left join PaymentTypes PT on sdoc.PaymentType_ID = PT.ID where sdoc.ID = %s';
var
  mSQL, mID, mTableName, mResult: string;
begin
  mTableName := GetTableName(APackagesDataSet.FieldByName(cFDDocumentType).AsString);
  mID := APackagesDataSet.FieldByName(cFDID).AsString;
  mSQL := Format(cSQL, [mTableName, QuotedStr(mID)]);
  mResult := GetFirstRecordFromSQL(AOS, mSQL);
  if Trim(mResult) <> '' then begin
    //pro dobírku, předvyplníme částku dobírečného
    APackagesDataSet.FieldByName(cFDPaymentKind).AsInteger := StrToInt(mResult);
    if APackagesDataSet.FieldByName(cFDPaymentKind).AsInteger = cCODPaymentKind then
      APackagesDataSet.FieldByName(cFDCashOnDelivery).AsFloat := APackagesDataSet.FieldByName(cFDAmount).AsFloat;
  end;
end;

//v3.2 - nastavuje a později používá Firm_ID, Person_ID .. z datasetu. Je tedy možné ovlivnit při práci s datasetem cílové adresy. Například v předvyplnění.
procedure SetAdrID(AOS: TNxCustomObjectSpace; var APackagesDataSet: TDataSet; ADocumentType: string; ASender : Boolean);
var
  mBO: TNxCustomBusinessObject;
  mVarSymbol, mTmp: string;
  mPrefix,mSufix: string;
begin
  mBO := AOS.CreateObject(GetBOCLSID(ADocumentType));
  mSufix := NxIIfStr(ASender, cFDSen,'' );
  try
    mBO.Load(APackagesDataSet.FieldByName(cFDID).AsString, nil);
    if mBO.HasField('Firm_ID') then
      APackagesDataSet.FieldByName(cFDFirm_ID).AsString := mBO.GetFieldValueAsString('Firm_ID');
    if mBO.HasField('FirmOffice_ID') then
      APackagesDataSet.FieldByName(cFDFirmOffice_ID).AsString := mBO.GetFieldValueAsString('FirmOffice_ID');
    if mBO.HasField('Person_ID') then
      APackagesDataSet.FieldByName(cFDPerson_ID).AsString := mBO.GetFieldValueAsString('Person_ID');
    if ASender then
    begin
      if mBO.HasField('X_Sender_Firm_ID') then
        APackagesDataSet.FieldByName(cFDFirm_ID+mSufix).AsString := mBO.GetFieldValueAsString('X_Sender_Firm_ID');
      if mBO.HasField('X_Sender_FirmOffice_ID') then
        APackagesDataSet.FieldByName(cFDFirmOffice_ID+mSufix).AsString := mBO.GetFieldValueAsString('X_Sender_FirmOffice_ID');
      if mBO.HasField('X_Sender_Person_ID') then
        APackagesDataSet.FieldByName(cFDPerson_ID+mSufix).AsString := mBO.GetFieldValueAsString('X_Sender_Person_ID');
    end;

  finally
    mBO.Free;
  end;
end;

//dotahne adresy, poznamku pro ridice, pocet existujicich baliku a typ platby
procedure SetAddInfo(AOS: TNxCustomObjectSpace; const APostProvider_ID: TNxOID; var APackagesDataSet: TDataSet; ADocumentType: string);
begin
  APackagesDataSet.DisableControls;
  try
    APackagesDataSet.First;
    while not APackagesDataSet.Eof do begin
      APackagesDataSet.Edit;
      //pojištění nastavíme na hodnotu balíku
      //if not CFxOID.IsEmptyOrFull(APostProvider_ID) then
      SetExistCount(AOS, APostProvider_ID, APackagesDataSet, ADocumentType);
      //dobírku budeme řešit mimo DL
      if not (ADocumentType in [cDocumentTypeBillOfDelivery,cDocumentTypeOutgoingTransfer,cDocumentTypeServiceDocument]) then
        SetPaymentKind(AOS, APackagesDataSet);
      SetAdrID(AOS, APackagesDataSet,ADocumentType,false);
      SetAddress(AOS, APackagesDataSet,false);
      SetAdrName(AOS, APackagesDataSet,false);
      //B2C - ServiceType
      SetAdrID(AOS, APackagesDataSet,ADocumentType,true);
      SetAddress(AOS, APackagesDataSet,true);
      SetAdrName(AOS, APackagesDataSet,true);

      SetNoteForDriver(AOS, APackagesDataSet, 'Location');
      SetWeight(AOS, APackagesDataSet, ADocumentType);
      SetVarSymbol(AOS, APackagesDataSet, ADocumentType);
      APackagesDataSet.Post;
      APackagesDataSet.Next;
    end;
  finally
    APackagesDataSet.EnableControls;
  end;
end;

begin
end.