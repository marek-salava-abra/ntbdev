procedure AfterSave_Hook(Self: TNxCustomBusinessObject);

var
  mOrderNumber : string;
  mInvoiceNumber : string;
  mInvoiceDate : string;
  mDocQueueCode : string;
  mOrdNumber : string;
  mPeriodNumber : string;
  mPeriodCode : string;
  mTotalPrice : string;
  mTotalVATE : extended;
  mTotalVATS : string;
  mTotalPriceVAT : string;
  mCurrency : string;
  mBody : TStringList;
  mTime : string;
  mID : TStringList;
  mStores : TStringList;
  mStore : string;
  mI : Integer;
  mVarSymbol : string;

  mIssOrdMoniker : TNxCustomBusinessMonikerCollection;
  mII : Integer;
  mBody2 : TStringList;
  mB2BID : string;
  mAmount : string;

const
  cBohuminPath = '\\192.168.1.194\AbraG3\B2B\Orders\Bohumin\Invoices\TXT\';  //'c:\AbraG3\B2B\Orders\Bohumin\Invoices\TXT\'
  cPrahaPath = '\\192.168.1.194\AbraG3\B2B\Orders\Praha\Invoices\TXT\';   //'c:\AbraG3\B2B\Orders\Praha\Invoices\TXT\'

begin
  if OsNew in Self.State {true} then begin
    mOrderNumber := Self.GetFieldValueAsString('X_OrderNumber');
    if mOrderNumber = '' then exit;
    mStores := TStringList.Create;
    Self.ObjectSpace.SQLSelect('SELECT Store_ID FROM IssuedInvoices2 WHERE Parent_ID = ''' + Self.OID + '''', mStores);

    for mI := 0 to mStores.Count - 1 do begin   //Zjištění skladu kvůli kontejneru na PneuB2B
      if mStores[mI] <> '0000000000' then begin mStore := mStores[mI]; break; end;
    end;

    //Soubor pro změnu stavu na "Vyřízeno" na PneuB2B
    mIssOrdMoniker := Self.GetLoadedCollectionMonikerForFieldCode(Self.GetFieldCode('Rows'));
    mBody2 := TStringList.Create;
    mBody2.Add('<?xml version="1.0" encoding="utf-8" ?>');
    mBody2.Add('<s:Orders xmlns:s="http://pneub2b.eu/SupplierOrdersResponse.xsd">');
    for mII := 0 to mIssOrdMoniker.Count - 1 do begin
      mB2BID := mIssOrdMoniker.BusinessObject[mII].GetFieldValueAsString('X_B2BID');
      mAmount := mIssOrdMoniker.BusinessObject[mII].GetFieldValueAsString('Quantity');
      if mB2BID <> '' then begin
        mBody2.Add('<s:OrderItem ID="' + mB2BID + '" Amount="' + mAmount + '" State="Done"/>');
      end;
    end;
    mBody2.Add('</s:Orders>');
    if mStore = '2000000101' then mBody2.SaveToFile(cBohuminPath + mOrderNumber + '.acc')
    else if (mStore = '3000000101') or (mStore = '1300000101') then mBody2.SaveToFile(cPrahaPath + mOrderNumber + '.acc');

    try
      mID := TStringList.Create;
      mID.Add(Self.GetFieldValueAsString('ID'));
      if mStore = '2000000101' then CFxReportManager.PrintByIDs(NxCreateContext_1(Self), mID, '40SBPEINEFD13ACM03KIU0CLP4', '1130000101', rtoFile, pekPDF, '\\192.168.1.194\AbraG3\B2B\Orders\Bohumin\Invoices\PDF\', NxSearchReplace(Self.GetFieldValueAsString('DisplayName') + '.pdf', '/', '_', nil))
      else if (mStore = '3000000101') or (mStore = '1300000101') then CFxReportManager.PrintByIDs(NxCreateContext_1(Self), mID, '40SBPEINEFD13ACM03KIU0CLP4', '1130000101', rtoFile, pekPDF, '\\192.168.1.194\AbraG3\B2B\Orders\Praha\Invoices\PDF\', NxSearchReplace(Self.GetFieldValueAsString('DisplayName') + '.pdf', '/', '_', nil));
    except
      ShowMessage('Při ukládání faktury na portál PneuB2B došlo k chybě. ' + ExceptionMessage);
    end;

    mCurrency := Self.GetFieldValueAsString('Currency_ID.Code');
    mTime := FormatDateTime('hh:mm:ss', Time);
    mDocQueueCode := Self.GetFieldValueAsString('DocQueue_ID.Code');
    mOrdNumber := Self.GetFieldValueAsString('OrdNumber');
    mPeriodNumber := Self.GetFieldValueAsString('Period_ID.Code');
    mInvoiceNumber := mDocQueueCode + '-' + mOrdNumber + '-' + mPeriodNumber;
    mInvoiceDate := FormatDateTime('yyyy-mm-dd', (Self.GetFieldValueAsDateTime('DocDate$Date')));
    mTotalPrice := NxSearchReplace(Self.GetFieldValueAsString('AmountWithoutVAT'), ',', '.', nil);
    mTotalPriceVAT := NxSearchReplace(Self.GetFieldValueAsString('Amount'), ',', '.', nil);
    mTotalVATE := (Self.GetFieldValueAsFloat('Amount')) - (Self.GetFieldValueAsFloat('AmountWithoutVAT'));
    mTotalVATS := NxSearchReplace(FloatToStr(mTotalVATE), ',', '.', nil);
    mVarSymbol := Self.GetFieldValueAsString('VarSymbol');
    mBody := TStringList.Create;
    try
      mBody.Add('<?xml version="1.0" encoding="utf-8" ?>' + #13#10 + '<s:OrdersInvoices xmlns:s="http://pneub2b.eu/SupplierOrdersInvoices.xsd">' + #13#10 +
                '<s:Invoice OrderNumber="' + mOrderNumber + '" InvoiceNumber="' + mInvoiceNumber + '" InvoiceDate="' + mInvoiceDate + 'T' + mTime + 'Z" TotalPrice="' + mTotalPrice +
                '" TotalVat="' + mTotalVATS + '" TotalPriceWithVat="' + mTotalPriceVAT + '" Currency="' + mCurrency + '" VariableSymbol="' + mVarSymbol + '" InvoiceInPDF=""/>' + #13#10 + '</s:OrdersInvoices>');
      if mStore = '2000000101' then mBody.SaveToFile(cBohuminPath + mOrderNumber + '.txt')
      else if (mStore = '3000000101') or (mStore = '1300000101') then mBody.SaveToFile(cPrahaPath + mOrderNumber + '.txt');
    finally
      mBody.Free;
      mID.Free;
      mStores.Free;
      mBody2.Free;
      mIssOrdMoniker.Free;
    end;
  end;
end;

begin
end.