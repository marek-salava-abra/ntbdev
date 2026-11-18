uses '.const';

{
Vyvolává se po uložení vlastních dat objektu do databáze.
}
procedure AfterSave_Hook(Self: TNxCustomBusinessObject);
var
 mXMLResponse, mXMLPostResponse:TNxScriptingXMLWrapper;
 mAmount:Extended;
 mString, mReport_ID:string;
 mPrintList:TStringList;
 mReportBytes: TBytes;
begin
  if AnsiLeftStr(self.GetFieldValueAsString('X_B2BOrigin'),2)='82' then begin
    try
      mReport_ID:='6LH0000101';
      mPrintList:=TStringList.Create;
      mPrintList.Add(self.OID);
      mReportBytes:=CFxReportManager.PrintByIDsToBytes(NxCreateContext_1(self),mPrintList,GetDynSource(self.ObjectSpace,mReport_ID),mReport_ID, pekPDF,'');
      mString:=EncodeBase64(mReportBytes);
      mAmount:=self.ObjectSpace.SQLSelectFirstAsExtended('Select sum(TAmountWithoutVat) from issuedinvoices2 where parent_id='+QuotedStr(self.oid)+' and rowtype=2',0);
      mXMLResponse:=TNxScriptingXMLWrapper.Create;
      mXMLResponse.CreateEmpty('OrdersInvoices');
      mXMLResponse.setAttributeValue('OrdersInvoices','xmlns','http://pneub2b.eu/SupplierOrdersInvoices.xsd');
      mXMLResponse.AddElement('Invoice');
      mXMLResponse.setAttributeValue('Invoice[' + IntToStr(0) + ']','OrderNumber', self.GetFieldValueAsString('X_B2BNumber'));
      mXMLResponse.setAttributeValue('Invoice[' + IntToStr(0) + ']','VariableSymbol', self.GetFieldValueAsString('VarSymbol'));
      mXMLResponse.setAttributeValue('Invoice[' + IntToStr(0) + ']','InvoiceNumber', self.DisplayName);
      mXMLResponse.setAttributeValue('Invoice[' + IntToStr(0) + ']','CustomerID', self.GetFieldValueAsString('Firm_ID.OrgIdentNumber'));
      mXMLResponse.setAttributeValue('Invoice[' + IntToStr(0) + ']','Currency', self.GetFieldValueAsString('Currency_ID.Code'));
      mXMLResponse.setAttributeValue('Invoice[' + IntToStr(0) + ']','TransportCosts',NxFloatToIBStr(mAmount));
      mXMLResponse.setAttributeValue('Invoice[' + IntToStr(0) + ']','TotalPrice',NxFloatToIBStr(self.GetFieldValueAsFloat('AmountWithoutVAT')));
      mXMLResponse.setAttributeValue('Invoice[' + IntToStr(0) + ']','TotalPriceWithVat',NxFloatToIBStr(self.GetFieldValueAsFloat('Amount')));
      mXMLResponse.setAttributeValue('Invoice[' + IntToStr(0) + ']','TotalVat',NxFloatToIBStr(self.GetFieldValueAsFloat('Amount')-self.GetFieldValueAsFloat('AmountWithoutVAT')));
      mXMLResponse.setAttributeValue('Invoice[' + IntToStr(0) + ']','InvoiceDate', FormatDateTime('YYYY-MM-DD',self.GetFieldValueAsDateTime('DocDate$Date'))+'T00:00:00');
      mXMLResponse.setAttributeValue('Invoice[' + IntToStr(0) + ']','InvoiceInPDF',mString);
      mXMLResponse.setAttributeValue('Invoice[' + IntToStr(0) + ']','Url',self.GetFieldValueAsString('X_TrackingURL'));
      if NxGetActualUserID_1(self)='SUPER00000' then
       mXMLResponse.saveToFile('C:\Users\abraadmin\Documents\ABRA_EXPORT\xml\'+FormatDateTime('YYYYMMDDhhnnss',Now)+'_invoice_'+self.oid+'.xml');
      mXMLPostResponse:=API_POST(cURL+'orders_invoices_info',self.GetFieldValueAsString('X_B2BOrigin'),'KingTonyDodavatel.',mXMLResponse, self.ObjectSpace);
      mXMLPostResponse.saveToFile('C:\Users\abraadmin\Documents\ABRA_EXPORT\xml\'+FormatDateTime('YYYYMMDDhhnnss',Now)+'_postresponseinv_'+self.oid+'.xml');
    except
      CFxLog.SaveLog(NxCreateContext(self.ObjectSpace),'LS','chyba',ExceptionMessage,2,now);
    end;
  end;
end;

begin
end.