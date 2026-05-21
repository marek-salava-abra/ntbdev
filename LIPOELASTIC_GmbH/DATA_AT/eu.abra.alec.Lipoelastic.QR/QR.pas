
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