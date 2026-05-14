uses '_Knihovny_ALL.SQL';


// Načtení ID objektu dle kódu

function GetIDByCode(AObjectSpace: TNxCustomObjectSpace; ATableName, ACode: string; ANotHidden: boolean = false): string;
var
  mNotHidden: string;
begin
  if ANotHidden then mNotHidden := ' AND Hidden = ''N'' ' else mNotHidden := '';
  Result := SQLSelectValue(AObjectSpace, 'SELECT ID FROM '+ATableName+' WHERE Code= '+QuotedStr(ACode)+' '+mNotHidden);
end;

// Načtení Name objektu dle Code

function GetNameByCode(AObjectSpace: TNxCustomObjectSpace; ATableName, ACode: string; ANotHidden: boolean = false): string;
var
  mNotHidden: string;
begin
  if ANotHidden then mNotHidden := ' AND Hidden = ''N'' ' else mNotHidden := '';
  Result := SQLSelectValue(AObjectSpace, 'SELECT Name FROM '+ATableName+' WHERE Code = '+QuotedStr(ACode)+' '+mNotHidden);
end;


// Načtení něčeho dle ID

function GetFieldByID(AObjectSpace: TNxCustomObjectSpace; ATableName, AFieldName, AID: string): string;
begin
  Result := SQLSelectValue(AObjectSpace, 'SELECT '+AFieldName+' FROM '+ATableName+' WHERE ID = '+QuotedStr(AID)+' ');
end;

// Načtení ID dle něčeho

function GetIDByField(AObjectSpace: TNxCustomObjectSpace; ATableName, AFieldName, AValue: string): string;
begin
  Result := SQLSelectValue(AObjectSpace, 'SELECT ID FROM '+ATableName+' WHERE '+AFieldName+' = '+QuotedStr(AValue)+' ');
end;


// Načtení ID objektu z definovatelného číselníku podle kódu

function GetDefRollIDByCode(AObjectSpace: TNxCustomObjectSpace; AClassID, ACode: string; ANotHidden: boolean = false): string;
var
  mNotHidden: string;
begin
  if ANotHidden then mNotHidden := ' AND Hidden = ''N'' ' else mNotHidden := '';
  Result := SQLSelectValue(AObjectSpace, 'SELECT ID FROM DefRollData WHERE CLSID = '+QuotedStr(AClassID)+' AND Code = '+QuotedStr(ACode)+' '+mNotHidden);
end;


// Načtení ID sazby DPH dle hodnoty sazby

function GetVatRateIDByTariff(AObjectSpace: TNxCustomObjectSpace; ATariff: double; ACountryCode: string = 'CZ'): string;
begin
  Result := SQLSelectValue(AObjectSpace, 'SELECT ID FROM VatRates WHERE Hidden = ''N'' AND Tariff = '+NxFloatToIBStr(ATariff)+' AND Country_ID = (SELECT ID From Countries WHERE Code = '+QuotedStr(ACountryCode)+' AND Hidden = ''N'' AND ID LIKE ''%'+ACountryCode+'%'') ');
end;


// Načtení ID řady dokladů dle typu a kódu

function GetDocQueueID(AObjectSpace: TNxCustomObjectSpace; ADocType, ACode: string): string;
begin
  Result := SQLSelectValue(AObjectSpace, 'SELECT ID FROM DocQueues WHERE DocumentType = '+QuotedStr(ADocType)+' AND Code = '+QuotedStr(ACode)+' AND Hidden=''N'' ');
end;



// Zjištění ID aktuální polatnosti ceníku

function GetPriceListValidityIDByDate(AObjectSpace: TNxCustomObjectSpace; APriceListID: string; ADate: Double): string;
begin
  Result := SQLSelectValue(AObjectSpace, 'SELECT ID FROM PriceListValidities WHERE Parent_ID = '''+APriceListID+''' AND ValidFromDate$Date <= '+FloatToStr(ADate)+' ORDER BY ValidFromDate$Date DESC ROWS 1');
end;

// Zjištění ID výchozí definice ceny

function GetBasicPriceDefID(AObjectSpace: TNxCustomObjectSpace; APriceListID: string; ADate: Double): string;
begin
  Result := SQLSelectValue(AObjectSpace, 'SELECT ID FROM PriceDefinitions WHERE Basic = ''A'' AND Hidden = ''N'' ');
end;


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


// získání ID vybraných objektů v agendě nebo číselníku

function GetCurrentObjects(ASite: TSiteForm; var AIDs: TStringList): Boolean;
begin
  AIDs.Clear;
  TNxSiteList(ASite.List).GetSelectedId(AIDs);
  Result := AIDs.Count > 0;
end;

// získání vybraného objektu v agendě nebo číselníku

function GetCurrentObject(ASite: TSiteForm; var ACurrentObject: TNxCustomBusinessObject): Boolean;
begin
  Result := true;
  if ASite is TBusRollSiteForm then
    ACurrentObject := TBusRollSiteForm(ASite).CurrentObject
  else
    if ASite is TDynSiteForm then
      ACurrentObject := TDynSiteForm(ASite).CurrentObject
    else
      Result := False;
end;

// načtení TSiteForm z TControlu

function GetSiteFromControl(AControl: TControl; var ASite: TSiteForm): Boolean;
begin
  ASite := AControl.Site;
  Result := Assigned(ASite);
end;


// načtení informací o poslední platbě dokladu
// var parametry s vrácenou hodnotou:
//   APAmount - částka platby
//   APDate - datum platby
//   APaymentID - ID platebního dokladu
//   APaymentType - typ platebního dokladu
// návratová hodnota: boolean, platba existuje/neexistuje
function GetLastPaymentInfo(OS: TNxCustomObjectSpace; APDocType, APDocID: string; var APAmount: double; var APDate: TDateTime; var APaymentID, APaymentType: string): boolean;
var
  mQuery: string;
  mData: TMemoryDataset;
begin
  Result := false;
  mQuery := 'SELECT FIRST 1 DocumentType, ID, DocDate$DATE, PAmount FROM PaymentsForDocument_VIEW '+
  'WHERE PDocumentType = '+QuotedStr(APDocType)+' AND PDocument_ID = '+QuotedStr(APDocID)+' '+
  'ORDER BY DocDate$DATE DESC ';
  mData := TMemoryDataset.Create(nil);
  try
    OS.SQLSelect2(mQuery, mData);
    if not mData.eof then begin
      Result := true;
      mData.First;
      APAmount := mData.FieldByName('PAmount').AsFloat;
      APDate := mData.FieldByName('DocDate$DATE').AsFloat;
      APaymentID := mData.FieldByName('ID').Text;
      APaymentType := mData.FieldByName('DocumentType').Text;
    end else begin
      Result := false;
    end;
  finally
    mData.Free;
  end;
end;



// zjistí, zda je objekt skrytý a odkryje ho, pokud ano. Vrací boolean, zda byl skrytý či ne.
function UnhideObjectIfHidden(OS: TNxCustomObjectSpace; ClassID, ID: string): boolean;
var
  mObj: TNxCustomBusinessObject;
  mQuery, mHidden: string;
begin
  Result := false;
  mObj := OS.CreateObject(ClassID);
  try
    mObj.Load(ID, nil);
    if NxIsEmptyOID(mObj.OID) then exit;
    if mObj.GetFieldValueAsBoolean('Hidden') then begin
      ShowMessage('skryvam');
      mObj.SetFieldValueAsBoolean('Hidden', false);
      mObj.Save;
      Result := true;
    end;
  finally
    mObj.Free;
  end;
end;


// skryje objekt
procedure HideObject(OS: TNxCustomObjectSpace; CLassID, ID: string);
var
  mObj: TNxCustomBusinessObject;
  mQuery, mHidden: string;
begin
  mObj := OS.CreateObject(CLassID);
  try
    mObj.Load(ID, nil);
    if NxIsEmptyOID(mObj.OID) then exit;
    if not mObj.GetFieldValueAsBoolean('Hidden') then begin
      mObj.SetFieldValueAsBoolean('Hidden', true);
      mObj.Save;
    end;
  finally
    mObj.Free;
  end;
end;


// CRLF
function CRLF: string;
begin
  Result := #13#10;
end;


// Ověření zvláštního oprávnění uživatele (položka X_Right_ARightCode)
function CheckSpecialUserRight(OS: TNxCustomObjectSpace; AUserID, ARightCode: string): boolean;
var
  mQuery, mResult: string;
begin
  try
    mQuery := 'SELECT X_Right_'+ARightCode+' FROM SecurityUsers WHERE ID = '+QuotedStr(AUserID);
    mResult := SQLSelectValue(OS, mQuery);
    if mResult = 'A' then Result := true else Result := false;
  except
    Result := false;
  end;
end;


// Změna hodnoty položky BO pouze v případě, že se nová a stávající hodnota liší
procedure SetFieldValueIfChanged(var BO: TNxCustomBusinessObject; FieldName: string; FieldValue: Variant; FieldType: string);
begin
  case FieldType of
    'string': begin
      if (BO.GetFieldValueAsString(FieldName) <> FieldValue) then
        BO.SetFieldValueAsString(FieldName, FieldValue);
    end;
    
    'integer': begin
      if (BO.GetFieldValueAsInteger(FieldName) <> FieldValue) then
        BO.SetFieldValueAsInteger(FieldName, FieldValue);
    end;
  end;

end;




// načtení ID výchozí firmy pro předvyplnění

function GetDefaultFirmID(OS: TNxCustomObjectSpace): string;
begin
  Result := SQLSelectValue(OS, 'SELECT Firm_ID FROM GlobData');
end;

// zjištění ID okresu podle PSČ (z číselníku poštovních úřadů)
// v závislosti na parametru AExactOnly=false - pokud nenajde přesné číslo, zkusí podle prvních 4 míst, pak podle prvních 3

function GetDistrictIDByPostCode(OS: TNxCustomObjectSpace; APostCode: string; AExactOnly: boolean = false): string;
var
  mDistrictID, mQuery: string;
begin
  APostCode := ReplaceStr(APostCode, ' ', '');
  if APostCode = '' then begin
    Result := '';
    exit;
  end;
  mQuery := 'SELECT District_ID FROM PostOffices WHERE REPLACE(PostCode, '' '', '''') LIKE ''%s'' ORDER BY PostCode';
  mDistrictID := SQLSelectValue(OS, format(mQuery, [APostCode+'%']));
  if (NxIsEmptyOID(mDistrictID)) then begin
    APostCode := NxLeft(APostCode, 4);
    mDistrictID := SQLSelectValue(OS, format(mQuery, [APostCode+'%']));
    if (NxIsEmptyOID(mDistrictID)) then begin
      APostCode := NxLeft(APostCode, 3);
      mDistrictID := SQLSelectValue(OS, format(mQuery, [APostCode+'%']));
      if (NxIsEmptyOID(mDistrictID)) then begin
        APostCode := NxLeft(APostCode, 2);
        mDistrictID := SQLSelectValue(OS, format(mQuery, [APostCode+'%']));
      end;
    end;
  end;
  Result := mDistrictID;
end;



// ověření, zda je daná země členem EU
// pro vstup lze použít kód země nebo ID země

function CountryIsEUMember(OS: TNxCustomObjectSpace; AIdentifier: string): boolean;
var
  mField, mQuery, mMember: string;
begin

  if NxIsEmptyOID(AIdentifier) then mField := 'Code' else mField := 'ID';
  mQuery := 'SELECT EUMember FROM Countries2 C2 '+
  'JOIN Countries C ON C.ID = C2.Parent_ID AND C.'+mField+' = '+QuotedStr(AIdentifier)+' '+
  'WHERE C2.DateOfChange$Date <= '+NxFloatToIBStr(Date)+' '+
  'ORDER BY C2.DateOfChange$Date DESC ';
  mMember := SQLSelectValue(OS, mQuery);

  if mMember = 'A' then Result := true else Result := false;
end;




// z kurzovního lístku načte kurz k dané měně a datu.
// Pokud není datum, vezme se aktuální

function GetExchangeRate(OS: TNxCustomObjectSpace; ACurrencyID: string; ADate: TDateTime = 0): double;
var
  mQuery: string;
begin
  if (ADate = 0) then ADate := Date;
  mQuery := 'SELECT ER2.CurrRate FROM ExchangeRates2 ER2 JOIN ExchangeRates ER ON ER.ID = ER2.Parent_ID '+
  'WHERE ER.RefCurrency_ID = '+QuotedStr('0000CZK000')+' AND ER.Currency_ID = '+QuotedStr(ACurrencyID)+' '+
  'AND ER2.Date$DATE <= '+NxFloatToIBStr(ADate)+' '+
  'ORDER BY ER2.Date$DATE DESC ';
  Result := StrToFloatDef(SQLSelectValue(OS, mQuery), 1);
end;


// nastaví v dané roli/skupině oprávnění na určitý objekt
// ARoleID - ID role/skupiny
// ACLSID - Class ID persistentní třídy objektu
// AObjID - ID objektu
// AGrantedMask - maska povolení (3 = vše, 0 = nic)
// ADeniedMask - maska zákazů (3 = vše, 0 = nic)
function SetRoleObjectRight(OS: TNxCustomObjectSpace; ARoleID, ACLSID, AObjID: string; AGrantedMask, ADeniedMask: integer): boolean;
var
  mQuery: string;
begin
  mQuery := 'SELECT COUNT(*) FROM SecurityObjectRights WHERE CLASSID = '+QuotedStr(ACLSID)+' '+
  'AND PROGID = '+QuotedStr(AObjID)+' AND Role_ID = '+QuotedStr(ARoleID);
  if (SQLSelectValue(OS, mQuery) <> '0') then begin
    mQuery := 'UPDATE SecurityObjectRights SET GrantedMask = '+IntToStr(AGrantedMask)+', DeniedMask = '+IntToStr(ADeniedMask)+' '+
    'WHERE CLASSID = '+QuotedStr(ACLSID)+' AND PROGID = '+QuotedStr(AObjID)+' AND Role_ID = '+QuotedStr(ARoleID);
  end else begin
    mQuery := 'INSERT INTO SecurityObjectRights (GrantedMask, DeniedMask, CLASSID, PROGID, Role_ID) '+
    'VALUES ('+IntToStr(AGrantedMask)+', '+IntToStr(ADeniedMask)+', '+QuotedStr(ACLSID)+', '+QuotedStr(AObjID)+', '+QuotedStr(ARoleID)+')';
  end;
  OS.SQLExecute(mQuery);
end;


// načtení BLOBU z BO jako string
function GetBlobContentAsString(ABO: TNxCustomBusinessObject; AFieldName: String): String;
var
  mParams: TNxParameters;
  mFields: TStringList;
begin
  mParams := TNxParameters.Create;
  try
    mFields := TStringList.Create;
    try
      mFields.Add(AFieldName);
      ABO.GetFields(mFields, mParams);
      ABO.GetFieldValues(mParams);
      Result := mParams.ParamByName(AFieldName).AsString;
    finally;
      mFields.Free;
    end;
  finally
    mParams.Free;
  end;
end;



// načtení aktuálního ID firmy
// --------------------------------------

function GetActualFirmID(mOS: TNxCustomObjectSpace; mID: string;): string;
var
  mQuery: string;
begin
  mQuery := 'SELECT NVL(F.Firm_ID, F.ID) FROM Firms F WHERE ID = '+QuotedStr(mID);
  Result := SQLSelectValue(mOS, mQuery);
end;



// získání jednotkové nákupní ceny skladové karty na daném skladu podle poslední skladové uzávěrky
// -----------------------------------------------------------------------------------------
function GetLastStoreClosingUnitPriceForStoreCard(AObj: TNxCustomBusinessObject; AStoreCardID, AStoreID: string): double;
var
  mExpr: string;
  mAmount,mQuantity: double;
begin
  mExpr := 'NxGetLastStoreClosingAmountForStoreCard('+QuotedStr(AStoreCardID)+', '+QuotedStr(AStoreID)+')';
  mAmount := NxEvalObjectExprAsFloatDef(AObj, mExpr, 0);
  mExpr := 'NxGetLastStoreClosingQuantityForStoreCard('+QuotedStr(AStoreCardID)+', '+QuotedStr(AStoreID)+')';
  mQuantity := NxEvalObjectExprAsFloatDef(AObj, mExpr, 0);
  Result := CFxFloat.DivideDef(mAmount, mQuantity, 0, 10);
end;

// hmotnost v gramech
// --------------------------------------
function GetWeightInGrams(AWeight: double; AWeightUnit: integer): double;
begin
  case AWeightUnit of
    0: Result := AWeight;
    1: Result := AWeight * 1000;
    2: Result := AWeight * 1000000;
    else Result := AWeight;
  end;
end;





begin
end.