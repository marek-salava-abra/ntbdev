uses 'eu.abra.mavy.libs.konstanty';
function SQLSingleSelect(AOS: TNxCustomObjectSpace; ASQL: string): string;
var
  mIDs: TStringList;
begin
  Result := '';

  if Assigned(AOS) and (ASQL <> '') then
  begin
    mIDs := TStringList.Create;
    try
      SQLMultiSelect(AOS, ASQL, mIDs);
      if mIDs.Count > 0 then
        Result := NxSearchReplace(mIDs.Strings[0], '"', '', [srAll]);
    finally
      mIDs.Free;
    end;
  end;
end;

procedure SQLMultiSelect(AOS: TNxCustomObjectSpace; ASQL: string; AIDs: TStringList);
begin
  try
    if Assigned(AIDs) and Assigned(AOS) and (ASQL <> '') then
      AOS.SQLSelect(ASQL, AIDs);
  except
    //WriteErrorLog(ALog, ALogPrefix, 'DB', 'Nepodarilo se nacíst data z databáze.' + #13#10 + ExceptionMessage);
    //ALog.Add(ExceptionMessage);
  end;
end;

function GetAvailableQTY(Self: TNxCustomObjectSpace; StoreID, StoreCardID: String):Extended;
var
  mSCList, mStores: TStringList;
  mAQtyList: array of double;
begin
  Result := 0;
  mSCList := TStringList.Create;
  mStores := TStringList.Create;
  try
    mSCList.Clear;
    mSCList.Add(StoreCardID);
    mStores.Add(StoreID);
    NxGetAvailableQuantity(Self,mSCList,mStores,Today,True,mAQtyList);
    Result := mAQtyList[0];
  finally
    mSCList.free;
    mStores.free;
  end;
end;

procedure ZapisDoServisniKnihy(AOS: TNxCustomObjectSpace;
                               pcDescription,
                               pcUserName,
                               pcSolutionDescription,
                               pcQuestion: string);
var
  loSystemSupportEntry: TNxCustomBusinessObject;
begin
  loSystemSupportEntry:=AOS.CreateObject(Class_SystemSupportEntry);
  try
    loSystemSupportEntry.New();
    loSystemSupportEntry.Prefill();
    if AOS.InTransaction then begin
      loSystemSupportEntry.ExplicitTransaction:=true;
    end;
    loSystemSupportEntry.SetFieldValueAsInteger('Kind', 2);
    loSystemSupportEntry.SetFieldValueAsString('ShortDescription', NxLeft(pcDescription, 100));
    loSystemSupportEntry.SetFieldValueAsString('Solver', pcUserName);
    loSystemSupportEntry.SetFieldValueAsString('ProblemDescription', pcQuestion);
    loSystemSupportEntry.SetFieldValueAsString('SolutionDescription', pcSolutionDescription);

    if loSystemSupportEntry.NeedSave then begin
      loSystemSupportEntry.Save();
    end;
  finally
    loSystemSupportEntry.Free();
    loSystemSupportEntry:=nil;
  end;
end;

procedure UpdateOrCreateSupplier(AStoreCard_ID, ASupplier_ID: String; ACode, AQUnit, AName:string; AObjectSpace: TNxCustomObjectSpace);
const
  cSQL = 'select id from suppliers where storecard_id=''%s'' and firm_id=''%s''';
var
  mSQL: String;
  mSupplier: TNxCustomBusinessObject;
  mStrings: TStringList;
begin
  mSQL := Format(cSQL, [AStoreCard_ID, ASupplier_ID]);
  mStrings := TStringList.Create;
  try
    AObjectSpace.SQLSelect(mSQL, mStrings);
    mSupplier := AObjectSpace.CreateObject('O0F5OHLYGNDL342T01C0CX3FCC');
    try
      if mStrings.Count > 0 then begin
        mSupplier.Load(mStrings.Strings[0], nil);
      end else begin
        mSupplier.New;
        mSupplier.Prefill;
        mSupplier.SetFieldValueAsString('Firm_ID', ASupplier_ID);
        mSupplier.SetFieldValueAsString('StoreCard_ID', AStoreCard_ID);
        mSupplier.SetFieldValueAsString('QUnit', AQUnit);
      end;
      mSupplier.SetFieldValueAsString('ExternalNumber', ACode);
      mSupplier.SetFieldValueAsString('Name', AName);
      mSupplier.Save;
    finally
      mSupplier.Free;
    end;
  finally
    mStrings.Free;
  end;
end;

procedure UpdatePrices(AStoreCardID: string; APrice, AUnitRate: Extended; APriceID, AQUnit, APriceListID : string; AOS: TNxCustomObjectSpace);
var
  mStorePrice, mPriceRow: TNxCustomBusinessObject;
  mCol: TNxCustomBusinessMonikerCollection;
  mPriceRowID, mStorePriceID, mSQL, mLatestValidity: string;
  i: integer;
begin
  try
    mStorePrice := AOS.CreateObject(Class_StorePrice);
    if (not NxIsEmptyOID(AStoreCardID)) then begin
      mSQL := 'SELECT FIRST 1 SP.ID FROM StorePrices SP LEFT JOIN PriceListValidities PV ON SP.PriceListValidity_ID = PV.ID '+
              'WHERE SP.PriceList_ID = ''%s'' and SP.StoreCard_ID = ''%s'' and SP.DeletedFromPriceList = ''N'' ORDER BY PV.ValidFromDate$DATE DESC';
      mStorePriceID := SQLSingleSelect(AOS, Format(mSQL, [APriceListID, AStoreCardID]));
      //ALEC__________________________________________________________________________________
      mSQL := 'SELECT FIRST 1 PV.ID FROM PriceListValidities PV WHERE PV.Parent_ID = ''%s''';
      mLatestValidity := SQLSingleSelect(AOS, Format(mSQL, [APriceListID]));
      //______________________________________________________________________________________
      if (not NxIsEmptyOID(mStorePriceID)) then begin
        mStorePrice.Load(mStorePriceID, nil);
      end else begin
        mStorePrice.New;
        mStorePrice.Prefill;
        mStorePrice.SetFieldValueAsString('PriceList_ID', APriceListID);
        mStorePrice.SetFieldValueAsString('StoreCard_ID', AStoreCardID);
        mStorePrice.SetFieldValueAsString('PriceListValidity_ID', mLatestValidity); //ALEC
      end;
      mCol := mStorePrice.GetLoadedCollectionMonikerForFieldCode(mStorePrice.GetFieldCode('PriceRows'));
      mPriceRowID := '';
      // zkusíme najít existující řádek ceny podle definice a jednotky
      for i := 0 to mCol.Count - 1 do begin
        mPriceRow := mCol.BusinessObject(i);
        if (mPriceRow.GetFieldValueAsString('Price_ID') = APriceID) and (mPriceRow.GetFieldValueAsString('QUnit') = AQUnit) then begin
          mPriceRow.SetFieldValueAsFloat('Amount', APrice);
          mPriceRowID := mPriceRow.OID;
        end;
      end;
      // pokud není, založíme nový
      if NxIsEmptyOID(mPriceRowID) then begin
        mPriceRow := mCol.AddNewObject;
        mPriceRow.Prefill;
        mPriceRow.SetFieldValueAsString('Price_ID', APriceID);
        mPriceRow.SetFieldValueAsFloat('Amount', APrice);
        mPriceRow.SetFieldValueAsFloat('UnitRate', AUnitRate);
        mPriceRow.SetFieldValueAsString('QUnit', AQUnit);
      end;
      mStorePrice.Save;
    end;
  finally
    mStorePrice.Free;
  end;
end;

{procedure UpdatePrices(AStoreCardID: string; APrice, AUnitRate: Extended; APriceID, AQUnit, APriceListID : string; AOS: TNxCustomObjectSpace);
var
  mStorePrice, mPriceRow: TNxCustomBusinessObject;
  mCol: TNxCustomBusinessMonikerCollection;
  mPriceRowID, mStorePriceID, mSQL: string;
  i: integer;
begin
  try
    mStorePrice := AOS.CreateObject(Class_StorePrice);
    if (not NxIsEmptyOID(AStoreCardID)) then begin
      mSQL := 'SELECT FIRST 1 SP.ID FROM StorePrices SP LEFT JOIN PriceListValidities PV ON SP.PriceListValidity_ID = PV.ID '+
              'WHERE SP.PriceList_ID = ''%s'' and SP.StoreCard_ID = ''%s'' and SP.DeletedFromPriceList = ''N'' ORDER BY PV.ValidFromDate$DATE DESC';
      mStorePriceID := SQLSingleSelect(AOS, Format(mSQL, [APriceListID, AStoreCardID]));

      if (not NxIsEmptyOID(mStorePriceID)) then begin
        mStorePrice.Load(mStorePriceID, nil);
      end else begin
        mStorePrice.New;
        mStorePrice.Prefill;
        mStorePrice.SetFieldValueAsString('PriceList_ID', APriceListID);
        mStorePrice.SetFieldValueAsString('StoreCard_ID', AStoreCardID);
      end;
      mCol := mStorePrice.GetLoadedCollectionMonikerForFieldCode(mStorePrice.GetFieldCode('PriceRows'));
      mPriceRowID := '';
      // zkusíme najít existující řádek ceny podle definice a jednotky
      for i := 0 to mCol.Count - 1 do begin
        mPriceRow := mCol.BusinessObject(i);
        if (mPriceRow.GetFieldValueAsString('Price_ID') = APriceID) and (mPriceRow.GetFieldValueAsString('QUnit') = AQUnit) then begin
          mPriceRow.SetFieldValueAsFloat('Amount', APrice);
          mPriceRowID := mPriceRow.OID;
        end;
      end;
      // pokud není, založíme nový
      if NxIsEmptyOID(mPriceRowID) then begin
        mPriceRow := mCol.AddNewObject;
        mPriceRow.Prefill;
        mPriceRow.SetFieldValueAsString('Price_ID', APriceID);
        mPriceRow.SetFieldValueAsFloat('Amount', APrice);
        mPriceRow.SetFieldValueAsFloat('UnitRate', AUnitRate);
        mPriceRow.SetFieldValueAsString('QUnit', AQUnit);
      end;
      mStorePrice.Save;
    end;
  finally
    mStorePrice.Free;
  end;
end;}

// Ověření uživatele na privilegium
// Přeává se zjednodušený kód z níže definovaných, nebo přímo CLSID (např 'G1TDNZSKTVCL33N2010DELDFKK:Supervisor')
// Povolené kódy
//   Supervisor:   Supervisor
//
function CheckUserPrivileg(AOS: TNxCustomObjectSpace; AUserID: TNxOID; APrivilegCode: string): Boolean;
var
  mContext: TNxContext;
  mParam: TNxParameters;
  mPrivileg: string;
begin
  Result := false;
  mContext := NxCreateContext(AOS);
  mParam := TNxParameters.Create;
  try
    GetEffectivePrivileges(mContext.GetCompanyCache, AOS, AUserID, mParam);
    case APrivilegCode of
      'Supervisor' : mPrivileg := 'G1TDNZSKTVCL33N2010DELDFKK:Supervisor';
    else mPrivileg := APrivilegCode;
    end;
    Result := mParam.ParamByName(mPrivileg).AsBoolean;
    //showmessage(mParam.GetAsSQLString);
  finally
    mContext.Free;
    mParam.Free;
  end;
end;

//Funkce pro přidání tlačítka
function AddActionButton(ASite: TSiteForm; AShowControl, AShowMenuItem: Boolean; AName, ACaption, AHint, ACategory: String; AOnExecute: Pointer): TBasicAction;
var
  mAction: TBasicAction;
begin
  Result := nil;
  if Assigned(ASite) then begin
    mAction := ASite.GetNewAction;
    if Assigned(mAction) then begin
      mAction.ShowControl := AShowControl;
      mAction.ShowMenuItem := AShowMenuItem;
      mAction.Name := AName;
      mAction.Caption := ACaption;
      mAction.Hint := AHint;
      mAction.Category := ACategory;
      mAction.OnExecute := AOnExecute;
    end;
    Result := mAction;
  end;
end;

function ISODateTimeToDateTime(AISODateTime: string): TDateTime;
var
  mY, mM, mD, mHH, mMM, mSS: Integer;
begin;
  mY := StrToInt(Copy(AISODateTime, 1, 4));
  mM := StrToInt(Copy(AISODateTime, 6, 2));
  mD := StrToInt(Copy(AISODateTime, 9, 2));
  mHH := StrToInt(Copy(AISODateTime, 12, 2));
  mMM := StrToInt(Copy(AISODateTime, 15, 2));
  mSS := StrToInt(Copy(AISODateTime, 18, 2));
  Result := EncodeDateTime(mY, mM, mD, mHH, mMM, mSS, 0);
end;

Function CreateEmail(AOS: TNxCustomObjectSpace; aFileName, AEmails, AEmailAccount, AEmailFirm, AEmailSubject, AEmailBody: String; AEmailKoncept: Boolean): String;
var
  mBOES, mRecip: TNxCustomBusinessObject;
  mRecipCol: TNxCustomBusinessMonikerCollection;
  mSLEmails: TStringList;
  i: integer;
begin
  Result := '0000000000';
  mBOES:= AOS.CreateObject(Class_EmailSent);
  try
    mBOES.New;
    mBOES.Prefill;
    mBOES.SetFieldValueAsString('EmailAccount_ID', AEmailAccount);
    mBOES.SetFieldValueAsString('Firm_ID', AEmailFirm);
    //mBOES.SetFieldValueAsString('Person_ID', ABO.GetFieldValueAsString('Employee_ID.Person_ID'));
    mBOES.SetFieldValueAsString('Subject', AEmailSubject);
    mBOES.SetFieldValueAsString('Body', AEmailBody);

    mRecipCol:= mBOES.GetLoadedCollectionMonikerForFieldCode(mBOES.GetFieldCode('Recipients'));
    mSLEmails:= TStringList.Create;
    try
      AEmails:= StringReplace(AEmails, ';', #13#10, [rfReplaceAll,rfIgnoreCase]);
      mSLEmails.Text:= StringReplace(AEmails, ',', #13#10, [rfReplaceAll,rfIgnoreCase]);
      for i:= 0 to mSLEmails.Count - 1 do
      begin
        mRecip:= mRecipCol.AddNewObject;
        mRecip.SetFieldValueAsInteger('EmailType', 0);
        mRecip.SetFieldValueAsString('Email', mSLEmails[i]);
      end;
    finally
      mSLEmails.Free;
    end;
    if AEmailKoncept then
      mBOES.SetFieldValueAsInteger('SentState', 0)
    else
      mBOES.SetFieldValueAsInteger('SentState', 1);
    if aFileName <> '' then
      TNxEmailSent(mBOES).AttachFile(aFileName);
  finally
    mBOES.Save;
    Result := mBOES.OID;
    mBOES.Free;
  end;
end;

begin
end.