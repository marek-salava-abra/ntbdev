uses
  'ABRA.LUBI.Compute_Individual_Discounts.uIndividualDiscounts';

procedure _AfterValidate_PostHook(Self: TNxCustomBusinessObject; var AResult: Boolean);
begin
  if AResult then begin
    //ShowMessage('BO OP Row - AfterValidate hook');
    ComputeIndividualDiscounts(self, false, false);
  end;
end;

procedure AddIndividualDiscount_Hook(Self: TNxCustomBusinessObject; var AIndividualDiscount: Extended);
begin
  AIndividualDiscount := self.GetFieldValueAsFloat('X_MENUDISCOUNT');
end;

{
Vyvolává se po změně každé položky. A to pouze, pokud k této změně nedochází díky načítání objektu z databáze nebo díky vytváření kopie.
}
procedure AfterSetFieldValue_Hook(Self: TNxCustomBusinessObject; AFieldCode: Integer; AValue: TNxParameter; AOriginalValue: TNxParameter);
var
  mCode: integer;
  mFloatValue, mOriginalFloatValue: Extended;
  mHeader: TNxCustomBusinessObject;
begin
  mCode := Self.GetFieldCode('StoreCard_ID');
  if AFieldCode = mCode then begin
    ShowDebugMessage('BO FV Row - AfterSetFieldValue_Hook skl.karta, prepocet slevy se provadi vzdy!!');
    ComputeIndividualDiscounts(self, True, True);
  end;
  mCode := Self.GetFieldCode('X_MENUDISCOUNT');
  if AFieldCode = mCode then begin
    // X_MENUDISCOUNT
    mFloatValue := AValue.AsFloat;
    mOriginalFloatValue := AOriginalValue.AsFloat;
    if mFloatValue <> mOriginalFloatValue then begin
      //ShowMessage('BO FV Row - AfterSetFieldValue_Hook X_MENUDISCOUNT');
      // je potreba aktualizovat castky celeho dokladu
      mHeader := TNxNotPositionedRowBusinessObject(Self).Header.BusinessObject;
      try
        mHeader.SetFieldValueAsBoolean('Dirty', True);
      finally
        mHeader.SetFieldValueAsBoolean('Dirty', False);
      end;
    end;
  end;
end;

begin
end.