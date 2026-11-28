const
 cStore_ID = '1000000101';

function GetFirmPrice(AReportHelper:TNxQRScriptHelper; mFirm_ID:String; mStoreCard_ID:String):Extended;
var
 mBO, mRowBO:TNxCustomBusinessObject;
 mRows:TNxCustomBusinessMonikerCollection;
begin
 Result:=0;
 if not(NxIsEmptyOID(mFirm_ID)) and not(NxIsEmptyOID(mStoreCard_ID)) then begin
   mBO:=AReportHelper.ObjectSpace.CreateObject(Class_ReceivedOrder);
   mBO.new;
   mBO.Prefill;
   mBO.SetFieldValueAsString('Firm_ID',mFirm_ID);
   mRows:=mBO.GetLoadedCollectionMonikerForFieldCode(mBO.GetFieldCode('Rows'));
   mRowBO:=mRows.AddNewObject;
   mRowBO.prefill;
   mRowBO.SetFieldValueAsInteger('RowType',3);
   mRowBO.SetFieldValueAsString('Store_ID', cStore_ID);
   mRowBO.SetFieldValueAsString('StoreCard_ID', mStoreCard_ID);
   mRowBO.SetFieldValueAsFloat('UnitQuantity',1);
   Result:=mRowBO.GetFieldValueAsFloat('TAmountWithoutVAT');
   mbo.free;
 end;
end;

function GetSupPrice(AReportHelper: TNxQRScriptHelper; SupplierRowPrice_ID: String; Quantity: Extended): Extended;
var
  mOS: TNxCustomObjectSpace;
  mPriceRowBO, mTieredPriceBO: TNxCustomBusinessObject;
  mTieredPrices: TNxCustomBusinessMonikerCollection;
  i: integer;
  mCurrentQuantityFrom: Extended;
  mMaxFoundQuantityFrom: Extended;
begin
  mOS := AReportHelper.ObjectSpace;
  Result := 0;

  if not(NxIsEmptyOID(SupplierRowPrice_ID)) then begin
    mPriceRowBO := mOS.CreateObject(Class_SupplierPriceListRow);
    mPriceRowBO.Load(SupplierRowPrice_ID, nil);

    // Výchozí základní cena bez množstevních slev
    Result := mPriceRowBO.GetFieldValueAsFloat('PurchasePrice');

    if mPriceRowBO.GetFieldValueAsBoolean('TieredPrice') then begin
      mTieredPrices := mPriceRowBO.GetLoadedCollectionMonikerForFieldCode(mPriceRowBO.GetFieldCode('TieredPrices'));

      // Inicializace sledování nejvyššího nalezeného množství (výchozí stav -1, aby prošla i nula)
      mMaxFoundQuantityFrom := -1;

      for i := 0 to mTieredPrices.count - 1 do begin
        mTieredPriceBO := mTieredPrices.BusinessObject[i];
        mCurrentQuantityFrom := mTieredPriceBO.GetFieldValueAsFloat('QuantityFrom');

        // Podmínka 1: Naše požadované množství (Quantity) musí být větší nebo rovno limitu v pásmu (CurrentQuantityFrom)
        // Podmínka 2: Aktuální limit pásma musí být vyšší než ten, který jsme našli doposud
        if (Quantity >= mCurrentQuantityFrom) and (mCurrentQuantityFrom > mMaxFoundQuantityFrom) then begin
          Result := mTieredPriceBO.GetFieldValueAsFloat('PurchasePrice');
          mMaxFoundQuantityFrom := mCurrentQuantityFrom; // Zapamatujeme si nové nejbližší pásmo
        end;
      end;
    end;

    mPriceRowBO.free;
  end;
end;


{RegulovanaFV}

function RegulovanaFV(AReportHelper:TNxQRScriptHelper;Invoice_ID:String):Boolean;
var
 mReg:integer;
begin
 Result:=False;
 mReg:=AReportHelper.ObjectSpace.SQLSelectFirstAsInteger('SELECT 1 FROM IssuedInvoices2 i2 WHERE i2.Parent_ID = '+QuotedStr(Invoice_ID)+'  AND i2.StoreCard_ID IN ( SELECT b.ID '#13#10 +
                                          '      FROM StoreCards b'#13#10 +
                                          '      WHERE b.Hidden = ''N'' '#13#10 +
                                          '        AND EXISTS ('#13#10 +
                                          '            SELECT 1 '#13#10 +
                                          '            FROM USERDATA '#13#10 +
                                          '            WHERE FIELDCODE = 2000212 '#13#10 +
                                          '              AND CLSID = ''C3V5QDVZ5BDL342M01C0CX3FCC'' '#13#10 +
                                          '              AND ID = b.ID '#13#10 +
                                          '              AND STRINGFIELDVALUE <> '''''#13#10 +
                                          '        )'#13#10 +
                                          '  )',0);
  if mReg = 1 then Result:=True;
end;

begin
end.