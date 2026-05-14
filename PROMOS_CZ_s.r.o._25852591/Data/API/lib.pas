function POST_IssuedInvoices(AContext: TNXContext; AInput: TJSONSuperObject; APath: String): TJSONSuperObject;
var
 mList:TStringList;
 mJSONRoot:TJSONSuperObject;
 mJSON, mJSON2:TJSONSuperObject;
 i,j:integer;
 mBO:TNxCustomBusinessObject;
 mDate:Extended;
 mDateStr,mTempList, mID, mExtNum, mB2BNum, mtemplist2:string;
 mOrderList:TStringList;
begin
  mDate:=AInput.DT8601['datefrom$date'];
  mDateStr:=NxFloatToIBStr(mDate);
  mJSONRoot:=TJSONSuperObject.Create;
  mJSONRoot.O['IssuedInvoices']:=mJSONRoot.CreateJSONArray;
  mList:=TStringList.create;
  AContext.SQLSelect('SELECT a.ID FROM IssuedInvoices A '+
                     'join firms f on f.ID=A.firm_ID '+
                     'WHERE a.createdat$date>'+mdatestr+' or a.correctedAt$date>'+mdatestr+' or '+
                     '(EXISTS (SELECT 1 FROM PaymentsForDocument_VIEW PFD   WHERE (PFD.DocDate$DATE >= '+mdatestr+') '+
                     'and PFD.PDocumentType = '+Quotedstr('03')+' and PFD.PDocument_ID = A.ID)) and F.X_B2B='+Quotedstr('A'), mList);
  if mList.count>0 then begin
    for i:=0 to mList.count-1 do begin
       //id,firm_id,ordnumber,DisplayName,externalnumber,DocDate$DATE,DueDate$DATE,VATAdmitDate$DATE,AmountWithoutVAT,NotPaidAmount,VarSymbol
        mBO:=AContext.GetObjectSpace.CreateObject(Class_IssuedInvoice);
        mBO.Load(mlist.strings[i],nil);
        mJSON:=TJSONSuperObject.create;
        mJSON.S['id']:=mBO.OID;
        mJSON.S['VarSymbol']:=mBO.GetFieldValueAsString('VarSymbol');
        mJSON.S['firm_id']:=mBO.GetFieldValueAsString('Firm_ID');
        mJSON.S['DisplayName']:=mbo.DisplayName;
        mJSON.S['dokument_url']:=mbo.GetFieldValueAsString('Firm_ID.OrgIdentNumber')+'/faktury/'+NxSearchReplace(mbo.DisplayName,'/','-',[srall])+'.pdf';
        //mJSON.S['externalnumber']:=AContext.SQLSelectFirstAsString('Select ro.externalnumber from issuedinvoices2 ii2 left join storedocuments2 sd2 on ii2.providerow_id=sd2.id left join receivedorders2 ro2 on sd2.providerow_id=sd2.id left join receivedorders ro on ro.id=ro2.parent_id where ii2.parent_id='+quotedstr(mbo.oid),'');
        mJSON.S['CurrencyCode']:=mbo.GetFieldValueAsString('Currency_ID.Code');
        mJSON.DT8601['DocDate$DATE']:=mbo.GetFieldValueAsDateTime('DocDate$DATE');
        mJSON.DT8601['DueDate$DATE']:=mbo.GetFieldValueAsDateTime('DueDate$DATE');
        mJSON.DT8601['VATAdmitDate$DATE']:=mbo.GetFieldValueAsDateTime('VATAdmitDate$DATE');
        mJSON.D['AmountWithoutVAT']:=mbo.GetFieldValueAsFloat('AmountWithoutVAT');
        mJSON.D['Amount']:=mbo.GetFieldValueAsFloat('Amount');
        mJSON.D['NotPaidAmount']:=mbo.GetFieldValueAsFloat('NotPaidAmount');
        mJSON.D['PaidAmount']:=mbo.GetFieldValueAsFloat('PaidAmount');
        mJSON.O['ReceivedOrders']:=mJSON.CreateJSONArray;
        mOrderList:=TStringList.create;
        AContext.SQLSelect('select distinct ro.id||'+Quotedstr(';')+'||ro.externalnumber||'+Quotedstr(';')+'||ro.X_B2BNumber '+
                           ' FROM IssuedInvoices2 A JOIN StoreDocuments2 SD2 ON SD2.ID=A.ProvideRow_ID JOIN StoreDocuments SD ON SD.ID=SD2.Parent_ID '+
                           ' JOIN ReceivedOrders2 RO2 ON RO2.ID=SD2.ProvideRow_ID Join ReceivedOrders ro on ro.id=ro2.parent_id where A.Parent_ID='+QuotedStr(mbo.OID),mOrderList);
        if mOrderList.count>0 then begin
          for j:=0 to mOrderList.count-1 do begin
             mTempList:=mOrderList.strings[j];
             mtemplist2:=NxSearchReplace(mTempList,'"','',[srall]);
             mid:=NxTrapStrTrim(mTempList2,';');
             mExtNum:=NxTrapStrTrim(mTempList2,';');
             mB2BNum:=NxTrapStrTrim(mTempList2,';');
             mJSON2:=TJSONSuperObject.create;
             mJSON2.S['id']:=mID;
             mJSON2.S['ExternalNumber']:=mExtNum;
             mJSON2.S['X_B2BNumber']:=mB2BNum;
             mJSON.A['ReceivedOrders'].add(mJSON2);
          end;
        end;
        mBO.free;
        mJSONRoot.A['IssuedInvoices'].Add(mJSON);
    end;
  end;
  Result:=mJSONRoot;
end;

function POST_IssuedDepositInvoices(AContext: TNXContext; AInput: TJSONSuperObject; APath: String): TJSONSuperObject;
var
 mList:TStringList;
 mJSONRoot:TJSONSuperObject;
 mJSON, mJSON2:TJSONSuperObject;
 i,j:integer;
 mBO:TNxCustomBusinessObject;
 mDate:Extended;
 mDateStr,mTempList, mID, mExtNum, mB2BNum, mtemplist2:string;
 mOrderList:TStringList;
begin
  mDate:=AInput.DT8601['datefrom$date'];
  mDateStr:=NxFloatToIBStr(mDate);
  mJSONRoot:=TJSONSuperObject.Create;
  mJSONRoot.O['IssuedDepositInvoices']:=mJSONRoot.CreateJSONArray;
  mList:=TStringList.create;
  AContext.SQLSelect('SELECT a.ID FROM IssuedDInvoices A '+
                     'join firms f on f.ID=A.firm_ID '+
                     'WHERE a.createdat$date>'+mdatestr+' or a.correctedAt$date>'+mdatestr+' or '+
                     '(EXISTS (SELECT 1 FROM PaymentsForDocument_VIEW PFD   WHERE (PFD.DocDate$DATE >= '+mdatestr+') '+
                     'and PFD.PDocumentType = '+Quotedstr('10')+' and PFD.PDocument_ID = A.ID)) and F.X_B2B='+Quotedstr('A'), mList);
  if mList.count>0 then begin
    for i:=0 to mList.count-1 do begin
       //id,firm_id,ordnumber,DisplayName,externalnumber,DocDate$DATE,DueDate$DATE,VATAdmitDate$DATE,AmountWithoutVAT,NotPaidAmount,VarSymbol
        mBO:=AContext.GetObjectSpace.CreateObject(Class_IssuedDepositInvoice);
        mBO.Load(mlist.strings[i],nil);
        mJSON:=TJSONSuperObject.create;
        mJSON.S['id']:=mBO.OID;
        mJSON.S['VarSymbol']:=mBO.GetFieldValueAsString('VarSymbol');
        mJSON.S['firm_id']:=mBO.GetFieldValueAsString('Firm_ID');
        mJSON.S['DisplayName']:=mbo.DisplayName;
        mJSON.S['dokument_url']:=mbo.GetFieldValueAsString('Firm_ID.OrgIdentNumber')+'/zalohy/'+NxSearchReplace(mbo.DisplayName,'/','-',[srall])+'.pdf';
        if NxIsEmptyOID(mbo.GetFieldValueAsString('ReceivedOrder_ID')) then
        mJSON.S['externalnumber']:='' else mJSON.S['externalnumber']:=mbo.GetFieldValueAsString('ReceivedOrder_ID.ExternalNumber');
        if NxIsEmptyOID(mbo.GetFieldValueAsString('ReceivedOrder_ID')) then
        mJSON.S['X_B2BNumber']:='' else mJSON.S['X_B2BNumber']:=mbo.GetFieldValueAsString('ReceivedOrder_ID.X_B2BNumber');
        mJSON.S['CurrencyCode']:=mbo.GetFieldValueAsString('Currency_ID.Code');
        mJSON.DT8601['DocDate$DATE']:=mbo.GetFieldValueAsDateTime('DocDate$DATE');
        mJSON.DT8601['DueDate$DATE']:=mbo.GetFieldValueAsDateTime('DueDate$DATE');
        //mJSON.DT8601['VATAdmitDate$DATE']:=mbo.GetFieldValueAsDateTime('VATAdmitDate$DATE');
        //mJSON.D['AmountWithoutVAT']:=mbo.GetFieldValueAsFloat('AmountWithoutVAT');
        mJSON.D['Amount']:=mbo.GetFieldValueAsFloat('Amount');
        mJSON.D['NotPaidAmount']:=mbo.GetFieldValueAsFloat('NotPaidAmount');
        mJSON.D['PaidAmount']:=mbo.GetFieldValueAsFloat('PaidAmount');
        {mJSON.O['ReceivedOrders']:=mJSON.CreateJSONArray;
        mOrderList:=TStringList.create;
        AContext.SQLSelect('select distinct ro.id||'+Quotedstr(';')+'||ro.externalnumber||'+Quotedstr(';')+'||ro.X_B2BNumber '+
                           ' FROM IssuedInvoices2 A JOIN StoreDocuments2 SD2 ON SD2.ID=A.ProvideRow_ID JOIN StoreDocuments SD ON SD.ID=SD2.Parent_ID '+
                           ' JOIN ReceivedOrders2 RO2 ON RO2.ID=SD2.ProvideRow_ID Join ReceivedOrders ro on ro.id=ro2.parent_id where A.Parent_ID='+QuotedStr(mbo.OID),mOrderList);
        if mOrderList.count>0 then begin
          for j:=0 to mOrderList.count-1 do begin
             mTempList:=mOrderList.strings[j];
             mtemplist2:=NxSearchReplace(mTempList,'"','',[srall]);
             mid:=NxTrapStrTrim(mTempList2,';');
             mExtNum:=NxTrapStrTrim(mTempList2,';');
             mB2BNum:=NxTrapStrTrim(mTempList2,';');
             mJSON2:=TJSONSuperObject.create;
             mJSON2.S['id']:=mID;
             mJSON2.S['ExternalNumber']:=mExtNum;
             mJSON2.S['X_B2BNumber']:=mB2BNum;
             mJSON.A['ReceivedOrders'].add(mJSON2);
          end;
        end; }
        mBO.free;
        mJSONRoot.A['IssuedDepositInvoices'].Add(mJSON);
    end;
  end;
  Result:=mJSONRoot;
end;

function POST_IssuedCreditNotes(AContext: TNXContext; AInput: TJSONSuperObject; APath: String): TJSONSuperObject;
var
 mList:TStringList;
 mJSONRoot:TJSONSuperObject;
 mJSON, mJSON2:TJSONSuperObject;
 i,j:integer;
 mBO:TNxCustomBusinessObject;
 mDate:Extended;
 mDateStr,mTempList, mID, mExtNum, mB2BNum, mtemplist2:string;
 mOrderList:TStringList;
begin
  mDate:=AInput.DT8601['datefrom$date'];
  mDateStr:=NxFloatToIBStr(mDate);
  mJSONRoot:=TJSONSuperObject.Create;
  mJSONRoot.O['IssuedCreditNotes']:=mJSONRoot.CreateJSONArray;
  mList:=TStringList.create;
  AContext.SQLSelect('SELECT a.ID FROM IssuedCreditNotes A '+
                     'join firms f on f.ID=A.firm_ID '+
                     'WHERE a.createdat$date>'+mdatestr+' or a.correctedAt$date>'+mdatestr+' or '+
                     '(EXISTS (SELECT 1 FROM PaymentsForDocument_VIEW PFD   WHERE (PFD.DocDate$DATE >= '+mdatestr+') '+
                     'and PFD.PDocumentType = '+Quotedstr('60')+' and PFD.PDocument_ID = A.ID)) and F.X_B2B='+Quotedstr('A'), mList);
  if mList.count>0 then begin
    for i:=0 to mList.count-1 do begin
       //id,firm_id,ordnumber,DisplayName,externalnumber,DocDate$DATE,DueDate$DATE,VATAdmitDate$DATE,AmountWithoutVAT,NotPaidAmount,VarSymbol
        mBO:=AContext.GetObjectSpace.CreateObject(Class_IssuedCreditNote);
        mBO.Load(mlist.strings[i],nil);
        mJSON:=TJSONSuperObject.create;
        mJSON.S['id']:=mBO.OID;
        mJSON.S['VarSymbol']:=mBO.GetFieldValueAsString('VarSymbol');
        mJSON.S['firm_id']:=mBO.GetFieldValueAsString('Firm_ID');
        mJSON.S['DisplayName']:=mbo.DisplayName;
        mJSON.S['dokument_url']:=mbo.GetFieldValueAsString('Firm_ID.OrgIdentNumber')+'/dobropisy/'+NxSearchReplace(mbo.DisplayName,'/','-',[srall])+'.pdf';
        //mJSON.S['externalnumber']:=AContext.SQLSelectFirstAsString('Select ro.externalnumber from issuedinvoices2 ii2 left join storedocuments2 sd2 on ii2.providerow_id=sd2.id left join receivedorders2 ro2 on sd2.providerow_id=sd2.id left join receivedorders ro on ro.id=ro2.parent_id where ii2.parent_id='+quotedstr(mbo.oid),'');
        mJSON.S['CurrencyCode']:=mbo.GetFieldValueAsString('Currency_ID.Code');
        mJSON.DT8601['DocDate$DATE']:=mbo.GetFieldValueAsDateTime('DocDate$DATE');
        mJSON.DT8601['DueDate$DATE']:=mbo.GetFieldValueAsDateTime('DueDate$DATE');
        mJSON.DT8601['VATAdmitDate$DATE']:=mbo.GetFieldValueAsDateTime('VATAdmitDate$DATE');
        mJSON.D['AmountWithoutVAT']:=mbo.GetFieldValueAsFloat('AmountWithoutVAT');
        mJSON.D['Amount']:=mbo.GetFieldValueAsFloat('Amount');
        mJSON.D['NotPaidAmount']:=mbo.GetFieldValueAsFloat('NotPaidAmount');
        mJSON.D['PaidAmount']:=mbo.GetFieldValueAsFloat('PaidAmount');
        {mJSON.O['ReceivedOrders']:=mJSON.CreateJSONArray;
        mOrderList:=TStringList.create;
        AContext.SQLSelect('select distinct ro.id||'+Quotedstr(';')+'||ro.externalnumber||'+Quotedstr(';')+'||ro.X_B2BNumber '+
                           ' FROM IssuedInvoices2 A JOIN StoreDocuments2 SD2 ON SD2.ID=A.ProvideRow_ID JOIN StoreDocuments SD ON SD.ID=SD2.Parent_ID '+
                           ' JOIN ReceivedOrders2 RO2 ON RO2.ID=SD2.ProvideRow_ID Join ReceivedOrders ro on ro.id=ro2.parent_id where A.Parent_ID='+QuotedStr(mbo.OID),mOrderList);
        if mOrderList.count>0 then begin
          for j:=0 to mOrderList.count-1 do begin
             mTempList:=mOrderList.strings[j];
             mtemplist2:=NxSearchReplace(mTempList,'"','',[srall]);
             mid:=NxTrapStrTrim(mTempList2,';');
             mExtNum:=NxTrapStrTrim(mTempList2,';');
             mB2BNum:=NxTrapStrTrim(mTempList2,';');
             mJSON2:=TJSONSuperObject.create;
             mJSON2.S['id']:=mID;
             mJSON2.S['ExternalNumber']:=mExtNum;
             mJSON2.S['X_B2BNumber']:=mB2BNum;
             mJSON.A['ReceivedOrders'].add(mJSON2);
          end;
        end;  }
        mBO.free;
        mJSONRoot.A['IssuedCreditNotes'].Add(mJSON);
    end;
  end;
  Result:=mJSONRoot;
end;

function POST_RefundedBillsOfDelivery(AContext: TNXContext; AInput: TJSONSuperObject; APath: String): TJSONSuperObject;
var
 mList:TStringList;
 mJSONRoot:TJSONSuperObject;
 mJSON, mJSON2:TJSONSuperObject;
 i,j:integer;
 mBO:TNxCustomBusinessObject;
 mDate:Extended;
 mDateStr,mTempList, mID, mExtNum, mB2BNum, mtemplist2:string;
 mOrderList:TStringList;
begin
  mDate:=AInput.DT8601['datefrom$date'];
  mDateStr:=NxFloatToIBStr(mDate);
  mJSONRoot:=TJSONSuperObject.Create;
  mJSONRoot.O['RefundedBillsOfDelivery']:=mJSONRoot.CreateJSONArray;
  mList:=TStringList.create;
  AContext.SQLSelect('SELECT a.ID FROM StoreDocuments A '+
                     'join firms f on f.ID=A.firm_ID '+
                     'WHERE (a.createdat$date>'+mdatestr+' or a.correctedAt$date>'+mdatestr+') and F.X_B2B='+Quotedstr('A')+' and A.DocumentType='+Quotedstr('23'), mList);
  if mList.count>0 then begin
    for i:=0 to mList.count-1 do begin
       //id,firm_id,ordnumber,DisplayName,externalnumber,DocDate$DATE,DueDate$DATE,VATAdmitDate$DATE,AmountWithoutVAT,NotPaidAmount,VarSymbol
        mBO:=AContext.GetObjectSpace.CreateObject(Class_RefundedBillOfDelivery);
        mBO.Load(mlist.strings[i],nil);
        mJSON:=TJSONSuperObject.create;
        mJSON.S['id']:=mBO.OID;
        mJSON.S['firm_id']:=mBO.GetFieldValueAsString('Firm_ID');
        mJSON.S['DisplayName']:=mbo.DisplayName;
        mJSON.S['externalnumber']:=AContext.GetObjectSpace.SQLSelectFirstAsString('select externalnumber from receivedorders where id in (select distinct(sd2.provide_id) from storedocuments2 sd2 '+
                                                                                  ' left join storedocuments2 sd3 on sd2.id=sd3.rdocumentrow_id where sd3.parent_id='+Quotedstr(mbo.oid)+')','');
        mJSON.S['X_B2BNumber']:=AContext.GetObjectSpace.SQLSelectFirstAsString('select X_B2BNumber from receivedorders where id in (select distinct(sd2.provide_id) from storedocuments2 sd2 '+
                                                                                  ' left join storedocuments2 sd3 on sd2.id=sd3.rdocumentrow_id where sd3.parent_id='+Quotedstr(mbo.oid)+')','');
        mJSON.S['dokument_url']:=mbo.GetFieldValueAsString('Firm_ID.OrgIdentNumber')+'/vratky/'+NxSearchReplace(mbo.DisplayName,'/','-',[srall])+'.pdf';
        mJSON.DT8601['DocDate$DATE']:=mbo.GetFieldValueAsDateTime('DocDate$DATE');
        mJSONRoot.A['RefundedBillsOfDelivery'].Add(mJSON);
    end;
  end;
  Result:=mJSONRoot;
end;


{GET_StoreSubCards}

procedure GET_StoreSubCards(AContext:TNxContext; ARequest: TAPIRequest; AResponse: TAPIResponse);
var
  mHeaders: TStringList;
  mOutputJSON, mJSONStoreSub:TJSONSuperObject;
  i: Integer;
  mSCCode:string;
  mList:TStringList;
  mQuantity, mQuantityKTP:Extended;
begin
  try
    mList:=TStringList.Create;
    mOutputJSON:=TJSONSuperObject.Create;
    AContext.SQLSelect('Select A.id from storecards A where A.Hidden = ''N'' AND (A.STOREASSORTMENTGROUP_ID IN (''1000000101'',''1100000101'')) ', mList);
    if mList.count>0 then begin
      mOutputJSON.O['StoreCards']:=mOutputJSON.CreateJSONArray;
      for i:=0 to mList.Count-1 do begin
         mSCCode:=AContext.SQLSelectFirstAsString('Select code from storecards where id='+QuotedStr(mList.Strings[i]),'');
         mQuantity:=AContext.SQLSelectFirstAsExtended('Select sum(quantity) from storesubcards where store_id=''1000000101'' and storecard_id='+QuotedStr(mList.Strings[i]),0);
         mQuantityKTP:=AContext.SQLSelectFirstAsExtended('Select sum(quantity) from storesubcards where store_id=''1420000101'' and storecard_id='+QuotedStr(mList.Strings[i]),0);
         mJSONStoreSub:=TJSONSuperObject.Create;
         mJSONStoreSub.S['code']:=mSCCode;
         mJSONStoreSub.D['Quantity']:=mQuantity;
         mJSONStoreSub.D['QuantityKTP']:=mQuantityKTP;
         mOutputJSON.A['StoreCards'].Add(mJSONStoreSub);
      end;
    end;
    AResponse.Body:=mOutputJSON.AsString;
    AResponse.SetHeader('Content-Type','application/json');
    AResponse.Status := 200;
  finally

  end;
end;

begin
end.