uses  'eu.abra.roeh.Logio.Lib';
{
Aktualizujeme hl. dodavatele
}
procedure AfterSave_Hook(Self: TNxCustomBusinessObject);
var
  mBO : TNxCustomBusinessObject;
begin
// sdílené číselníky nelze aktualizovat
if UpperCase(GetParamValue(Self.ObjectSpace,'ROLLSHARE')) = 'ANO' then Exit;

   if ((Self.GetFieldValueAsString('Firm_Id') = Self.GetFieldValueAsString('StoreCard_ID.MainSupplier_ID.Firm_Id')) or
      (Self.GetFieldValueAsString('Firm_Id') = Self.GetFieldValueAsString('StoreCard_ID.MainSupplier_ID.Firm_Id.Firm_id'))) and
      (Self.GetFieldValueAsFloat('PurchaseDate$DATE') > Self.GetFieldValueAsFloat('StoreCard_ID.MainSupplier_ID.PurchaseDate$DATE'))
      then begin
        if Self.OID = Self.GetFieldValueAsString('StoreCard_ID.MainSupplier_ID') then Exit; // Nemusím aktualizovat stejného dodavatele
        mBo := Self.ObjectSpace.CreateObject(Class_StoreCard);
       try
         mBO.Load(Self.GetFieldValueAsString('StoreCard_ID'),nil);
         mBO.SetFieldValueAsString('MainSupplier_ID',Self.OID);
         mBO.Save;
       finally
         mBo.Free;
       end;
   end;
end;

procedure Prefill_Hook(Self: TNxCustomBusinessObject);
begin
 if Self.GetFieldValueAsString('StoreCard_ID.MainSupplier_ID') <> '0000000000' then begin
    Self.SetFieldValueAsInteger('X_max_lt_provider',Self.GetFieldValueAsInteger('StoreCard_ID.MainSupplier_ID.X_max_lt_provider'));
    Self.SetFieldValueAsInteger('X_lt_std_provider',Self.GetFieldValueAsInteger('StoreCard_ID.MainSupplier_ID.X_lt_std_provider'));
    Self.SetFieldValueAsInteger('DeliveryTime',Self.GetFieldValueAsInteger('StoreCard_ID.MainSupplier_ID.DeliveryTime'));
    Self.SetFieldValueAsString('QUnit',Self.GetFieldValueAsString('StoreCard_ID.MainSupplier_ID.QUnit'));
    Self.SetFieldValueAsFloat('Packing',Self.GetFieldValueAsFloat('StoreCard_ID.MainSupplier_ID.Packing'));
    Self.SetFieldValueAsFloat('MinimalQuantity',Self.GetFieldValueAsFloat('StoreCard_ID.MainSupplier_ID.MinimalQuantity'));
  end;
end;

begin
end.