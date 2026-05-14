uses
  'ABRA.LUBI.Compute_Individual_Discounts.uIndividualDiscounts';

{
Vyvolává se po změně každé položky. A to pouze, pokud k této změně nedochází díky načítání objektu z databáze nebo díky vytváření kopie.
}
procedure AfterSetFieldValue_Hook(Self: TNxCustomBusinessObject; AFieldCode: Integer; AValue: TNxParameter; AOriginalValue: TNxParameter);
var
  mCode, mCode2: integer;
  mStrValue, mOriginalStrValue: string;
  mBoolValue, mOriginalBoolValue: Boolean;
begin
  // Zjistime kod polozky Firm_ID
  mCode := Self.GetFieldCode('Firm_ID');
  mCode2 := Self.GetFieldCode('X_DONT_USE_MENUDISCOUNT');
  if AFieldCode = mCode then begin
    // Firma
    mStrValue := AValue.AsString;
    mOriginalStrValue := AOriginalValue.AsString;
    if mStrValue <> mOriginalStrValue then begin
      //ShowMessage('BO FV Header - AfterSetFieldValue_Hook firma nebo X_DONT_USE_MENUDISCOUNT');
      RecalculateDiscountsForFirm(self);
    end;
  end;
  if AFieldCode = mCode2 then begin
    // X polozka
    mBoolValue := AValue.AsBoolean;
    mOriginalBoolValue := AOriginalValue.AsBoolean;
    if mBoolValue <> mOriginalBoolValue then begin
      //ShowMessage('BO FV Header - AfterSetFieldValue_Hook firma nebo X_DONT_USE_MENUDISCOUNT');
      RecalculateDiscountsForFirm(self);
    end;
  end;
end;

{
Vyvolává se před fyzickým uložením vlastních dat objektu do databáze.
}
procedure BeforeSave_Hook(Self: TNxCustomBusinessObject);
begin
  try
    Self.SetFieldValueAsBoolean('Dirty', True);
  finally
    Self.SetFieldValueAsBoolean('Dirty', False);
  end;
end;

begin
end.