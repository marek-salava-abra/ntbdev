
{PrintToBase64 - eu.abra.alec.TPDF.qr.PrintToBase64(AReportHelper:TNxQRScriptHelper; AObjectID, ADynSource, AReportID:String):String;}

function PrintToBase64(AReportHelper:TNxQRScriptHelper; AObjectID, ADataSource, AReportID:String):String;
var
  mBytes: TBytes;
  mContext: TNxContext;
  mList: TStringList;
begin
  Result:= '';
  mContext:= NxCreateContext(AReportHelper.ObjectSpace);
  mList:= TStringList.Create;
  try
    mList.Add(AObjectID);
    mBytes:= CFxReportManager.PrintByIDsToBytes(mContext, mList, ADataSource, AReportID, pekPDF);
    Result:= EncodeBase64(mBytes);
  finally
    mList.Free;
  end;
end;

// ebInterface 6.1 draft. The QR library name is retained for existing AEF callers.
// Specification: https://github.com/austriapro/ebinterface-standards/tree/master/schemas/ebInterface6p1
// TODO comments mark unresolved business mappings; no placeholder data is emitted.

function EbEscape(AValue: string): string;
begin
  Result:= NxSearchReplace(AValue, '&', '&amp;', [srAll]);
  Result:= NxSearchReplace(Result, '<', '&lt;', [srAll]);
  Result:= NxSearchReplace(Result, '>', '&gt;', [srAll]);
  Result:= NxSearchReplace(Result, '"', '&quot;', [srAll]);
  Result:= NxSearchReplace(Result, #39, '&apos;', [srAll]);
end;

function EbTag(AName, AValue: string): string;
begin
  Result:= '<' + AName + '>' + EbEscape(AValue) + '</' + AName + '>' + #13#10;
end;

function EbAmount(AValue: Extended): string;
begin
  Result:= NxIBFormatFloat('0.00', AValue);
end;

function EbRequired(AValue, AField: string): string;
begin
  Result:= Trim(AValue);
  if Result = '' then
    RaiseException('ebInterface: missing ' + AField);
end;

function EbAddress(AName, AStreet, ATown, AZIP, ACountry, AEmail: string): string;
begin
  Result:= '<Address>' + #13#10;
  Result:= Result + EbTag('Name', EbRequired(AName, 'Address/Name'));
  if Trim(AStreet) <> '' then Result:= Result + EbTag('Street', AStreet);
  Result:= Result + EbTag('Town', EbRequired(ATown, 'Address/Town'));
  Result:= Result + EbTag('ZIP', EbRequired(AZIP, 'Address/ZIP'));
  Result:= Result + '<Country CountryCode="' + EbEscape(EbRequired(ACountry, 'CountryCode')) + '">' +
    EbEscape(ACountry) + '</Country>' + #13#10;
  if Trim(AEmail) <> '' then Result:= Result + EbTag('Email', AEmail);
  Result:= Result + '</Address>' + #13#10;
end;

function EbTaxItem(ABase, ATax, ARate: Extended): string;
begin
  // TODO: map VAT regimes to S/Z/E/AE/K/G/O and exemption reasons.
  // A zero rate does not identify the tax regime. Never guess its category.
  if ARate <= 0 then
    RaiseException('ebInterface TODO: zero/exempt/reverse-charge VAT category is not mapped.');
  Result:= '<TaxItem>' + #13#10 + EbTag('TaxableAmount', EbAmount(ABase));
  Result:= Result + '<TaxPercent TaxCategoryCode="S">' + EbAmount(ARate) + '</TaxPercent>' + #13#10;
  Result:= Result + EbTag('TaxAmount', EbAmount(ATax)) + '</TaxItem>' + #13#10;
end;

procedure EbAddTaxTotals(ABases, ATaxes: TStringList; ARate, ABase, ATax: Extended);
var
  mKey: string;
begin
  mKey:= EbAmount(ARate);
  if ABases.IndexOfName(mKey) < 0 then
  begin
    ABases.Values[mKey]:= '0.00';
    ATaxes.Values[mKey]:= '0.00';
  end;
  ABases.Values[mKey]:= EbAmount(NxIBStrToFloat(ABases.Values[mKey]) + ABase);
  ATaxes.Values[mKey]:= EbAmount(NxIBStrToFloat(ATaxes.Values[mKey]) + ATax);
end;

function BuildEbInterfaceXML(AInvoice: TNxCustomBusinessObject): TBytes;
var
  mRows: TNxCustomBusinessMonikerCollection;
  mRow: TNxCustomBusinessObject;
  mBases, mTaxes: TStringList;
  mXML, mItems, mNotes, mRateKey, mDescription, mUnit: string;
  mCurrency, mSellerEmail: string;
  mNet, mGross, mPaid, mLineNet, mLineTax, mRate, mQuantity, mPrice: Extended;
  mSumNet, mSumTax, mRounding, mRowRounding, mExpectedTax: Extended;
  i, mRowType, mLineCount, mRoundingRowCount: Integer;
begin
  if not Assigned(AInvoice) then RaiseException('ebInterface: select an issued invoice.');
  mCurrency:= EbRequired(AInvoice.GetFieldValueAsString('Currency_ID.Code'), 'InvoiceCurrency');
  mNet:= AInvoice.GetFieldValueAsFloat('AmountWithoutVAT');
  mGross:= AInvoice.GetFieldValueAsFloat('Amount');
  mPaid:= AInvoice.GetFieldValueAsFloat('PaidAmount');
  // TODO: CreditMemo, advances, final settlement and deposit deductions.
  if (mNet < 0) or (mGross < 0) then
    RaiseException('ebInterface TODO: credit documents are not mapped.');
  mRounding:= AInvoice.GetFieldValueAsFloat('RoundingAmount');

  mRows:= AInvoice.GetLoadedCollectionMonikerForFieldCode(AInvoice.GetFieldCode('Rows'));
  mBases:= TStringList.Create;
  mTaxes:= TStringList.Create;
  try
    mItems:= '';
    mNotes:= '';
    mSumNet:= 0;
    mSumTax:= 0;
    mLineCount:= 0;
    mRowRounding:= 0;
    mRoundingRowCount:= 0;
    for i:= 0 to mRows.Count - 1 do
    begin
      mRow:= mRows.BusinessObject[i];
      mRowType:= mRow.GetFieldValueAsInteger('RowType');
      if mRowType = 4 then
      begin
        // PosIndex is only row order. Classification does not depend on row text.
        mLineNet:= mRow.GetFieldValueAsFloat('TAmountWithoutVAT');
        mLineTax:= mRow.GetFieldValueAsFloat('TAmount') - mLineNet;
        if NxIsEmptyOID(mRow.GetFieldValueAsString('VATRate_ID')) then
        begin
          if Abs(mLineTax) > 0.004 then
            RaiseException('ebInterface: rounding without VATRate_ID contains VAT.');
          mRowRounding:= mRowRounding + mRow.GetFieldValueAsFloat('TAmount');
          mRoundingRowCount:= mRoundingRowCount + 1;
        end
        else
        begin
          // A VAT rounding row can also change the taxable base (taxed invoice rounding).
          // TODO: represent nonzero base via ReductionAndSurchargeDetails, including its VAT.
          if Abs(mLineNet) > 0.004 then
            RaiseException('ebInterface TODO: VAT rounding changes the taxable base; map allowance/charge.');
          if Abs(mLineTax) > 0.004 then
          begin
            if mRow.GetFieldValueAsInteger('VATMode') <> 0 then
              RaiseException('ebInterface TODO: VAT rounding in a special VAT regime is not mapped.');
            mRate:= mRow.GetFieldValueAsFloat('VATRate');
            if mRate <= 0 then RaiseException('ebInterface: VAT rounding requires a positive VAT rate.');
            EbAddTaxTotals(mBases, mTaxes, mRate, 0, mLineTax);
            mSumTax:= mSumTax + mLineTax;
          end;
        end;
      end
      else if mRowType = 0 then
      begin
        mNotes:= mNotes + mRow.GetFieldValueAsString('Text') + #13#10;
      end
      else
      begin
        // TODO: map deposit deductions and other special row types explicitly.
        if mRowType = 5 then
          RaiseException('ebInterface TODO: VAT deposit deduction (RowType=5) is not mapped. Invoice=' +
            AInvoice.DisplayName + ', row ID=' + mRow.OID + ', PosIndex=' +
            IntToStr(mRow.GetFieldValueAsInteger('PosIndex')) + ' [ebInterface rounding-v2]');
        if (mRowType < 1) or (mRowType > 3) then
          RaiseException('ebInterface TODO: unsupported RowType=' + IntToStr(mRowType) +
            ', invoice=' + AInvoice.DisplayName + ', row ID=' + mRow.OID + ', PosIndex=' +
            IntToStr(mRow.GetFieldValueAsInteger('PosIndex')) + ' [ebInterface rounding-v2]');
        mLineNet:= mRow.GetFieldValueAsFloat('TAmountWithoutVAT');
        mLineTax:= mRow.GetFieldValueAsFloat('TAmount') - mLineNet;
        mRate:= mRow.GetFieldValueAsFloat('VATRate');
        if mRowType = 1 then
        begin
          mQuantity:= 1;
          mUnit:= 'C62';
        end
        else
        begin
          mQuantity:= mRow.GetFieldValueAsFloat('UnitQuantity');
          // ebInterface Unit permits the source unit; do not label everything C62.
          mUnit:= EbRequired(mRow.GetFieldValueAsString('QUnit'), 'Quantity/Unit');
        end;
        if mQuantity <= 0 then
          RaiseException('ebInterface: quantity must be positive at position ' + IntToStr(i + 1));
        if mLineNet < 0 then
          RaiseException('ebInterface TODO: negative invoice lines are not mapped.');
        mPrice:= mLineNet / mQuantity;
        // UnitPrice has at most four decimals in ebInterface 6.1.
        if Abs(NxIBStrToFloat(NxIBFormatFloat('0.0000', mPrice)) * mQuantity - mLineNet) > 0.004 then
          RaiseException('ebInterface TODO: BaseQuantity is needed at position ' + IntToStr(i + 1));
        if mRowType = 3 then mDescription:= mRow.GetFieldValueAsString('StoreCard_ID.Name')
        else mDescription:= mRow.GetFieldValueAsString('Text');
        mLineCount:= mLineCount + 1;
        mItems:= mItems + '<ListLineItem>' + #13#10;
        mItems:= mItems + EbTag('PositionNumber', IntToStr(mLineCount));
        mItems:= mItems + EbTag('Description', EbRequired(mDescription, 'ListLineItem/Description'));
        mItems:= mItems + '<Quantity Unit="' + EbEscape(mUnit) + '">' +
          NxIBFormatFloat('0.0000', mQuantity) + '</Quantity>' + #13#10;
        // Effective net price includes the discounts already calculated by ABRA.
        mItems:= mItems + EbTag('UnitPrice', NxIBFormatFloat('0.0000', mPrice));
        // TODO: InvoiceRecipientsOrderReference/OrderID and OrderPositionNumber.
        // mItems:= mItems + '<InvoiceRecipientsOrderReference>' +
        //   EbTag('OrderID', ...) + EbTag('OrderPositionNumber', ...) + '</InvoiceRecipientsOrderReference>';
        mItems:= mItems + EbTaxItem(mLineNet, mLineTax, mRate);
        mItems:= mItems + EbTag('LineItemAmount', EbAmount(mLineNet)) + '</ListLineItem>' + #13#10;
        EbAddTaxTotals(mBases, mTaxes, mRate, mLineNet, mLineTax);
        mSumNet:= mSumNet + mLineNet;
        mSumTax:= mSumTax + mLineTax;
      end;
    end;
    if mLineCount = 0 then RaiseException('ebInterface: invoice has no billable lines.');
    // New ABRA algorithm stores rounding in rows AND the header; do not add both.
    // Old documents can have header-only rounding. Use the same amount once.
    if (mRoundingRowCount > 0) and (Abs(mRowRounding - mRounding) > 0.004) then
      RaiseException('ebInterface: header rounding differs from non-taxable rounding rows.');
    // ABRA Amount and AmountWithoutVAT include non-taxable rounding.
    if (Abs(mSumNet + mRounding - mNet) > 0.004) or
      (Abs(mSumNet + mSumTax + mRounding - mGross) > 0.004) then
      RaiseException('ebInterface TODO: line totals differ from invoice totals; resolve adjustments/deposits.');
    for i:= 0 to mBases.Count - 1 do
    begin
      mRateKey:= mBases.Names[i];
      mExpectedTax:= NxIBStrToFloat(EbAmount(NxIBStrToFloat(mBases.Values[mRateKey]) * NxIBStrToFloat(mRateKey) / 100));
      if Abs(NxIBStrToFloat(mTaxes.Values[mRateKey]) - mExpectedTax) > 0.004 then
        RaiseException('ebInterface: VAT summary does not match taxable base and rate ' + mRateKey +
          '. Check VAT rounding settings; the exporter does not alter the recorded VAT.');
    end;

    mXML:= '<?xml version="1.0" encoding="UTF-8"?>' + #13#10;
    mXML:= mXML + '<Invoice xmlns="http://www.ebinterface.at/schema/6p1/"' +
      ' GeneratingSystem="ABRA Gen" DocumentType="Invoice" InvoiceCurrency="' + EbEscape(mCurrency) + '">' + #13#10;
    mXML:= mXML + '<!-- DRAFT: unresolved recipient/payment mappings are marked TODO in the script. -->' + #13#10;
    mXML:= mXML + EbTag('InvoiceNumber', AInvoice.DisplayName);
    mXML:= mXML + EbTag('InvoiceDate', FormatDateTime('yyyy-mm-dd', AInvoice.GetFieldValueAsDateTime('DocDate$DATE')));
    // TODO: Delivery/Date or Delivery/Period and delivery address. DocDate is not delivery date.
    // mXML:= mXML + '<Delivery>' + EbTag('Date', ...) + '</Delivery>';
    mXML:= mXML + '<Biller>' + #13#10;
    mXML:= mXML + EbTag('VATIdentificationNumber', EbRequired(
      NxEvalObjectExprAsString(AInvoice, 'NxGetCompanyVATIdentNumber'), 'Biller/VATIdentificationNumber'));
    // TODO: FurtherIdentification (FN, FS, FBG) according to actual company registration.
    // mXML:= mXML + '<FurtherIdentification IdentificationType="FN">...</FurtherIdentification>';
    mSellerEmail:= EbRequired(NxEvalObjectExprAsString(AInvoice, 'NxGetCompanyAddress(''EMail'')'), 'Biller/Address/Email');
    mXML:= mXML + EbAddress(NxEvalObjectExprAsString(AInvoice, 'NxGetCompanyName'),
      NxEvalObjectExprAsString(AInvoice, 'NxGetCompanyAddress(''Street'')'),
      NxEvalObjectExprAsString(AInvoice, 'NxGetCompanyAddress(''City'')'),
      NxEvalObjectExprAsString(AInvoice, 'NxGetCompanyAddress(''PostCode'')'),
      'AT', mSellerEmail);
    // TODO: Biller/InvoiceRecipientsBillerID = supplier number assigned by the recipient.
    // mXML:= mXML + EbTag('InvoiceRecipientsBillerID', ...);
    mXML:= mXML + '</Biller>' + #13#10 + '<InvoiceRecipient>' + #13#10;
    // TODO: agree representation for a recipient without a VAT ID; no invented value.
    mXML:= mXML + EbTag('VATIdentificationNumber', EbRequired(
      AInvoice.GetFieldValueAsString('Firm_ID.VATIdentNumber'), 'InvoiceRecipient/VATIdentificationNumber'));
    // TODO: OrderReference/OrderID is required by e-Rechnung.gv.at; map the actual AT order reference.
    // Do not reuse the German BuyerReference or guess from ExternalNumber.
    // mXML:= mXML + '<OrderReference>' + EbTag('OrderID', ...) + '</OrderReference>';
    mXML:= mXML + EbAddress(AInvoice.GetFieldValueAsString('Firm_ID.Name'),
      AInvoice.GetFieldValueAsString('Firm_ID.ResidenceAddress_ID.Street'),
      AInvoice.GetFieldValueAsString('Firm_ID.ResidenceAddress_ID.City'),
      AInvoice.GetFieldValueAsString('Firm_ID.ResidenceAddress_ID.PostCode'),
      AInvoice.GetFieldValueAsString('Firm_ID.ResidenceAddress_ID.CountryCode'), '');
    mXML:= mXML + '</InvoiceRecipient>' + #13#10 + '<Details>' + #13#10;
    if Trim(mNotes) <> '' then mXML:= mXML + EbTag('HeaderDescription', Trim(mNotes));
    mXML:= mXML + '<ItemList>' + #13#10 + mItems + '</ItemList>' + #13#10 + '</Details>' + #13#10;
    mXML:= mXML + '<Tax>' + #13#10;
    for i:= 0 to mBases.Count - 1 do
    begin
      mRateKey:= mBases.Names[i];
      mXML:= mXML + EbTaxItem(NxIBStrToFloat(mBases.Values[mRateKey]),
        NxIBStrToFloat(mTaxes.Values[mRateKey]), NxIBStrToFloat(mRateKey));
    end;
    mXML:= mXML + '</Tax>' + #13#10 + EbTag('TotalGrossAmount', EbAmount(mGross - mRounding));
    if Abs(mPaid) > 0.004 then mXML:= mXML + EbTag('PrepaidAmount', EbAmount(mPaid));
    if Abs(mRounding) > 0.004 then mXML:= mXML + EbTag('RoundingAmount', EbAmount(mRounding));
    mXML:= mXML + EbTag('PayableAmount', EbAmount(mGross - mPaid));
    // TODO: PaymentMethod according to PaymentType_ID; bank transfer must not be assumed for all invoices.
    // Candidate for a confirmed transfer payment (not cash/card/direct debit):
    // mXML:= mXML + '<PaymentMethod><UniversalBankTransaction><BeneficiaryAccount>' +
    //   EbTag('BIC', AInvoice.GetFieldValueAsString('BankAccount_ID.SwiftCode')) +
    //   EbTag('IBAN', AInvoice.GetFieldValueAsString('BankAccount_ID.IBANCode')) +
    //   '</BeneficiaryAccount>' + EbTag('PaymentReference', AInvoice.GetFieldValueAsString('VarSymbol')) +
    //   '</UniversalBankTransaction></PaymentMethod>';
    mXML:= mXML + '<PaymentConditions>' + EbTag('DueDate',
      FormatDateTime('yyyy-mm-dd', AInvoice.GetFieldValueAsDateTime('DueDate$DATE'))) + '</PaymentConditions>' + #13#10;
    // TODO: verify PaidAmount semantics for the receiving channel; e-Rechnung.gv.at ignores PrepaidAmount.
    // TODO: PDF as a separate submission attachment, if required by the receiving channel.
    // Do not put a UBL EmbeddedDocumentBinaryObject into ebInterface or render PDF recursively.
    mXML:= mXML + '</Invoice>' + #13#10;
    Result:= TEncoding.UTF8.GetBytes(mXML);
  finally
    mTaxes.Free;
    mBases.Free;
  end;
end;

begin
end.
