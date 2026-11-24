const
  // ABRA DeliveryType values. Address selection rules live below.
  cDeliveryDefault = 0;
  cDeliveryOffice = 1;
  cDeliveryFirm = 2;
  cDeliveryManual = 3;

// Internal helpers: only look up the selected source, never load the document.
function GetFirmResidenceAddressID(AReportHelper: TNxQRScriptHelper; AFirm_ID: string): string;
begin
  Result:= '';
  if NxIsEmptyOID(AFirm_ID) then
    Exit;
  Result:= AReportHelper.ObjectSpace.SQLSelectFirstAsString(
    'SELECT ResidenceAddress_ID FROM Firms WHERE ID=' + QuotedStr(AFirm_ID), '');
end;

function GetOfficeAddressID(AReportHelper: TNxQRScriptHelper; AFirmOffice_ID: string): string;
begin
  Result:= '';
  if NxIsEmptyOID(AFirmOffice_ID) then
    Exit;
  Result:= AReportHelper.ObjectSpace.SQLSelectFirstAsString(
    'SELECT Address_ID FROM FirmOffices WHERE ID=' + QuotedStr(AFirmOffice_ID), '');
end;

// Compare display lines without changing the stored text or unrelated spacing.
function HideDuplicateLocation(ALocation, AName: string): string;
begin
  Result:= ALocation;
  if LowerCase(Trim(ALocation)) = LowerCase(Trim(AName)) then
    Result:= '';
end;

// Shared reader. The virtual field "name" means Recipient > Location > empty.
// Other fields are read literally, including user fields such as X_AddressLine_2.
function ReadAddressField(AReportHelper: TNxQRScriptHelper;
  AAddress_ID, AFieldName: string; AHideDeliveryLocation: Boolean): string;
var
  mAddressBO: TNxCustomBusinessObject;
  mField, mName: string;
begin
  Result:= '';
  mField:= Trim(AFieldName);
  if NxIsBlank(mField) then
    RaiseException('ReadAddressField: address field name is empty.');
  if NxIsEmptyOID(AAddress_ID) then
    Exit;
  mAddressBO:= AReportHelper.ObjectSpace.CreateObject(Class_Address);
  try
    mAddressBO.Load(AAddress_ID, nil);
    if LowerCase(mField) = 'name' then
    begin
      Result:= mAddressBO.GetFieldValueAsString('Recipient');
      if NxIsBlank(Result) then
        Result:= mAddressBO.GetFieldValueAsString('Location');
      if NxIsBlank(Result) then
        Result:= '';
    end else
    begin
      Result:= mAddressBO.GetFieldValueAsString(mField);
      if AHideDeliveryLocation and (LowerCase(mField) = 'location') then
      begin
        // Same name rule as above, using this loaded address only.
        mName:= mAddressBO.GetFieldValueAsString('Recipient');
        if NxIsBlank(mName) then
          mName:= mAddressBO.GetFieldValueAsString('Location');
        Result:= HideDuplicateLocation(Result, mName);
      end;
    end;
  finally
    mAddressBO.Free;
  end;
end;

// Shared firm name for both name output and Location comparison, regardless of B2B.
// AFirmOffice_ID and AB2B are retained for compatibility with existing callers.
function GetMainAddressName(AReportHelper: TNxQRScriptHelper;
  AFirm_ID, AFirmOffice_ID: string; AB2B: Boolean): string;
begin
  Result:= '';
  if not NxIsEmptyOID(AFirm_ID) then
    Result:= AReportHelper.ObjectSpace.SQLSelectFirstAsString(
      'SELECT Name FROM Firms WHERE ID=' + QuotedStr(AFirm_ID), '');
  if NxIsBlank(Result) then
    Result:= '';
end;

// Public QR entry point. Both B2B and B2C use the firm name and residence address.
// AFirmOffice_ID and AB2B are retained for compatibility with existing reports.
// Location is hidden if it repeats the final main name.
function GetMainAddressField(AReportHelper: TNxQRScriptHelper;
  AFirm_ID, AFirmOffice_ID: string; AB2B: Boolean; AFieldName: string): string;
var
  mAddress_ID, mField: string;
begin
  mField:= LowerCase(Trim(AFieldName));
  if mField = 'name' then
  begin
    Result:= GetMainAddressName(AReportHelper, AFirm_ID, AFirmOffice_ID, AB2B);
    Exit;
  end;
  mAddress_ID:= GetFirmResidenceAddressID(AReportHelper, AFirm_ID);
  Result:= ReadAddressField(AReportHelper, mAddress_ID, AFieldName, False);
  if (mField = 'location') and not NxIsBlank(Result) then
    Result:= HideDuplicateLocation(Result,
      GetMainAddressName(AReportHelper, AFirm_ID, AFirmOffice_ID, AB2B));
end;

// Public QR entry point. Only DeliveryType selects the source, never B2B.
// AFirm_ID is kept in the signature to match the six NxGetExpandedAddress inputs;
// type 0 always uses AFirmOffice_ID, whose presence is validated by ABRA.
function GetDeliveryAddressField(AReportHelper: TNxQRScriptHelper;
  AFirm_ID, AFirmOffice_ID: string; ADeliveryType: Integer;
  ADeliveryAddress_ID, ADeliveryFirm_ID, ADeliveryFirmOffice_ID, AFieldName: string): string;
var
  mAddress_ID: string;
begin
  mAddress_ID:= '';
  case ADeliveryType of
    cDeliveryDefault: mAddress_ID:= GetOfficeAddressID(AReportHelper, AFirmOffice_ID);
    cDeliveryOffice: mAddress_ID:= GetOfficeAddressID(AReportHelper, ADeliveryFirmOffice_ID);
    cDeliveryFirm:
      begin
        if not NxIsEmptyOID(ADeliveryFirmOffice_ID) then
          mAddress_ID:= GetOfficeAddressID(AReportHelper, ADeliveryFirmOffice_ID)
        else
          mAddress_ID:= GetFirmResidenceAddressID(AReportHelper, ADeliveryFirm_ID);
      end;
    cDeliveryManual: mAddress_ID:= ADeliveryAddress_ID;
  else
    RaiseException('GetDeliveryAddressField: unsupported DeliveryType: ' + IntToStr(ADeliveryType));
  end;
  Result:= ReadAddressField(AReportHelper, mAddress_ID, AFieldName, True);
end;

{GetDeliveryAddressName}

function GetDeliveryAddressName(AReportHelper:TNxQRScriptHelper; ADocumentID: string):String;
var
  mBO: TNxCustomBusinessObject;
begin
  Result:= '';
  mBO:= AReportHelper.ObjectSpace.CreateObject(Class_BillOfDelivery);
  try
    mBO.Load(ADocumentID, nil);
    if not mBO.GetFieldValueAsBoolean('Firm_ID.X_B2B') then
    begin
      case mBO.GetFieldValueAsInteger('DeliveryType') of
        0: Result:= mBO.GetFieldValueAsString('FirmOffice_ID.Address_ID.Recipient');
        1: Result:= mBO.GetFieldValueAsString('DeliveryFirmOffice_ID.Address_ID.Recipient');
        2:
          begin
            if NxIsEmptyOID(mBO.GetFieldValueAsString('DeliveryFirmOffice_ID')) then
              Result:= mBO.GetFieldValueAsString('DeliveryFirm_ID.ResidenceAddress_ID.Recipient')
            else
              Result:= mBO.GetFieldValueAsString('DeliveryFirmOffice_ID.Address_ID.Recipient');
          end;
        3: Result:= mBO.GetFieldValueAsString('DeliveryAddress_ID.Recipient');
      end;
    end else
      Result:= mBO.GetFieldValueAsString('Firm_ID.Name');

    if NxIsBlank(Result) then
      Result:= mBO.GetFieldValueAsString('Firm_ID.Name');
  finally
    mBO.Free;
  end;
end;

function GetVarSymbol(AReportHelper:TNxQRScriptHelper; ADocumentID, ACLSID: string):String;
var
 mRes, mTab:string;
 mFakeBO:TNxCustomBusinessObject;
begin
 mRes:='';
 mFakeBO:=AReportHelper.ObjectSpace.CreateObject(ACLSID);
 mTab:=NxGetTableNameForPersistCLSID(mFakeBO.PersistCLSID);
 try
  mRes:=AReportHelper.ObjectSpace.SQLSelectFirstAsString('Select Varsymbol from '+mTab+' where id='+QuotedStr(ADocumentID),'');
 except
  mRes:='';
 end;
 Result:=mRes;
end;

function GetExternalNumber(AReportHelper:TNxQRScriptHelper; ADocumentID, ACLSID: string):String;
var
 mRes:string;
 mList:TStringList;
begin
 mRes:='';
 if ACLSID='O3BDOKTWEFD13ACM03KIU0CLP4' then begin
   mList:=TStringList.create;
   AReportHelper.ObjectSpace.SQLSelect('Select distinct (ro.externalnumber) from issuedinvoices2 ii2 join storedocuments2 sd2 on sd2.id=ii2.providerow_id '+
                                       'join receivedorders ro on ro.id=sd2.provide_id where ii2.parent_id='+QuotedStr(ADocumentID),mList);
   if mlist.Count>0 then mRes:=NxSearchReplace(mlist.DelimitedText,'"','',[srAll]);
   mlist.free;
   {
   mRes:='Select distinct (ro.externalnumber) from issuedinvoices2 ii2 join storedocuments2 sd2 on sd2.id=ii2.providerow_id '+
                                       'join receivedorders ro on ro.id=sd2.provide_id where ii2.parent_id='+QuotedStr(ADocumentID); }
 end;
 Result:=mRes;
end;

begin
end.
