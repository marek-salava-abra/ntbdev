uses
  'eu.abra.PostProviders.uConst';

//dle typu dokladu vrati CLSID BO
function GetBOCLSID(const ADocumentType: String): string;
begin
  Result := '';
  case ADocumentType of
    cDocumentTypeIssuedInvoice: Result := Class_IssuedInvoice;
    cDocumentTypeReceivedOrder: Result := Class_ReceivedOrder;
    cDocumentTypeBillOfDelivery: Result := Class_BillOfDelivery;
    cDocumentTypeOutgoingTransfer: Result := Class_OutgoingTransfer;
    cDocumentTypeServiceDocument: Result := Class_ServiceDocument;
  else
    RaiseException(lng_msg_notSupportDocType);
  end;
end;

//dle typu dokladu vrati CLSID Site
function GetSiteCLSID(const ADocumentType: String): string;
begin
  Result := '';
  case ADocumentType of
    cDocumentTypeIssuedInvoice: Result := Site_IssuedInvoices;
    cDocumentTypeReceivedOrder: Result := Site_ReceivedOrders;
    cDocumentTypeBillOfDelivery: Result := Site_BillOfDeliveries;
    cDocumentTypeOutgoingTransfer: Result := Site_OutgoingTransfers;
    cDocumentTypeServiceDocument: Result := Site_ServiceDocuments;
  else
    RaiseException(lng_msg_notSupportDocType);
  end;
end;

//dle typu dokladu vrati reldef vazby
function GetRelDef(const ADocumentType: String): integer;
begin
  Result := -1;
  case ADocumentType of
    cDocumentTypeIssuedInvoice: Result := cPDMIssuedDoc_IssuedInvoice;
    cDocumentTypeReceivedOrder: Result := cPDMIssuedDoc_ReceivedOrder;
    cDocumentTypeBillOfDelivery: Result := cPDMIssuedDoc_BillOfDelivery;
    cDocumentTypeOutgoingTransfer: Result := cPDMIssuedDoc_OutgoingTransfer;
    cDocumentTypeServiceDocument: Result := cPDMIssuedDoc_ServiceDocument;
  else
    RaiseException(lng_msg_notSupportDocType);
  end;
end;

//dle typu dokladu vrátí název tabulky
function GetTableName(const ADocumentType: String): string;
begin
  Result := '';
  case ADocumentType of
    cDocumentTypeIssuedInvoice: Result := 'IssuedInvoices';
    cDocumentTypeReceivedOrder: Result := 'ReceivedOrders';
    cDocumentTypeBillOfDelivery: Result := 'StoreDocuments';
    cDocumentTypeOutgoingTransfer: Result := 'StoreDocuments';
    cDocumentTypeServiceDocument: Result := 'ServiceDocuments';
  else
    RaiseException(lng_msg_notSupportDocType);
  end;
end;

//dle CLSID Site dokladu vrátí typ dokladu
function GetDocumentTypeFromSiteCLSID(const ASiteCLSID: string): string;
begin
  Result := '';
  case ASiteCLSID of
    Site_IssuedInvoices: Result := cDocumentTypeIssuedInvoice;
    Site_ReceivedOrders: Result := cDocumentTypeReceivedOrder;
    Site_BillOfDeliveries: Result := cDocumentTypeBillOfDelivery;
    Site_OutgoingTransfers: Result := cDocumentTypeOutgoingTransfer;
    Site_ServiceDocuments: Result := cDocumentTypeServiceDocument;
  else
    RaiseException(lng_msg_notSupportDocType);
  end;
end;

//dle CLSID BO vrátí typ dokladu
function GetDocumentTypeFromCLSID(const ACLSID: string): string;
begin
  Result := '';
  case ACLSID of
    class_IssuedInvoice: Result := cDocumentTypeIssuedInvoice;
    class_ReceivedOrder: Result := cDocumentTypeReceivedOrder;
    Class_BillOfDelivery: Result := cDocumentTypeBillOfDelivery;
    Class_OutgoingTransfer: Result := cDocumentTypeOutgoingTransfer;
    Class_ServiceDocument: Result := cDocumentTypeServiceDocument;
  else
    RaiseException(lng_msg_notSupportDocType);
  end;
end;

//dle RadioGroup ItemIndex vrátí typ dokladu
function GetDocumentTypeFromRGItemIndex(const ARGItemIndex: integer): string;
begin
  Result := '';
  case ARGItemIndex of
    0: Result := cDocumentTypeIssuedInvoice;
    2: Result := cDocumentTypeReceivedOrder;
    1: Result := cDocumentTypeBillOfDelivery;
    3: Result := cDocumentTypeOutgoingTransfer;
    4: Result := cDocumentTypeServiceDocument;
  else
    RaiseException(lng_msg_notSupportDocType);
  end;
end;

//dle typu dokladu vrátí SQL odeslané pošty
function GetSQLPackages(const ADocumentType: String): string;
const
  cSQLPackages = 'select PID.ID, PID.IssuedContent_ID from %s A '+
                 'join seldat S on S.Obj_ID = A.ID '+
                 'join relations RE on RE.REL_DEF = %s and RE.RIGHTSIDE_ID = A.ID '+
                 'join PDMIssuedDocs PID on PID.ID = RE.LEFTSIDE_ID ';

  cSQLPackagesWhere =  'where (S.sel_id = %s) %s'+
                       'order by PID.X_PD_PosIndex';
var
  mRelDef: integer;
  mTableName: string;
begin
  Result := '';
  mRelDef := GetRelDef(ADocumentType);
  mTableName := GetTableName(ADocumentType);
  Result := Format(cSQLPackages, [mTableName, IntToStr(mRelDef)])+cSQLPackagesWhere;
end;

//dle typu dokladu vrátí SQL zdrojových dat
function GetSQLSource(const ADocumentType: String; AOS:TNxCustomObjectSpace): string;
const
  cSQLSource = 'select %s '+
               'from %s A '+
               'join seldat s on s.Obj_ID = A.ID '+
               'join Periods P ON P.ID=A.Period_ID '+
               'join DocQueues DQ ON DQ.ID=A.DocQueue_ID ';

  cSQLSourceWhere =  'where (s.sel_id = %s)';
var
  mTableName, mFields: string;
  mContext: TNxContext;
begin
  mContext := NxCreateContext(AOS);
  try
    Result := '';
    mTableName := GetTableName(ADocumentType);
    mFields := GetFields(ADocumentType, mContext);
    Result := Format(cSQLSource, [mFields, mTableName])+cSQLSourceWhere;
  finally
    mContext.free;
  end;
end;

//dle typu dokladu vrátí fields ze zdrojové tabulky
function GetFields(const ADocumentType: String; AContext:TNxContext): string;
begin
  Result := 'A.ID as "ID", '+
            'DQ.Code || ''-'' || CAST(A.OrdNumber AS VARCHAR(10)) || ''/'' || P.Code as "DisplayNumber", '+
            '1 as "TargetAddressType", '+
            '1 as "Count", '+
            '1 as "Weight0", '+
            '1 as "WeightUnit0", '+
            'DQ.DocumentType as "DocumentType" ';
  case ADocumentType of
    cDocumentTypeIssuedInvoice: Result := Result + ', '+
                                         '(A.Amount - A.PaidAmount - A.CreditAmount + A.PaidCreditAmount) as "Amount", '+
                                         'A.VarSymbol as "VarSymbol", '+
                                         'A.Currency_ID as "Currency" ';
    cDocumentTypeReceivedOrder: Result := Result + ', '+
                                         '(A.Amount) as "Amount", '+
                                         'A.Currency_ID as "Currency" ';
    cDocumentTypeBillOfDelivery: Result := Result + ', '+
                                         '0 as "Amount", '+
                                         'A.Currency_ID as "Currency" ';
    cDocumentTypeOutgoingTransfer: Result := Result + ', '+
                                         '0 as "Amount", '+
                                         'A.Currency_ID as "Currency" ';
    cDocumentTypeServiceDocument: Result := Result + ', '+
                                         'A.TotalAmount as "Amount", '+
                                         ' '''+ AContext.GetCompanyCache.CurrencyID +''' as "Currency" ';
  else
    RaiseException(lng_msg_notSupportDocType);
  end;
end;


procedure ChangeStatusByRule(ABO: TNxCustomBusinessObject; ARule_ID, AResponsibleRole_ID: String = '0000000000'; AResponsibleUser_ID: String = '0000000000');
begin
  ABO.PMChangeStateByTransition(ARule_ID, AResponsibleRole_ID, AResponsibleUser_ID);
end;



begin
end.