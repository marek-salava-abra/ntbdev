{
Umožňuje ovlivnit validaci.
}
procedure Validate_Hook(Self: TNxCustomBusinessObject; var AResult: Boolean);
var
  mSQL: string;
  mFirm_OID, mMenu_OID, mValue, mItem: string;
  mValues: TStrings;
  mContext: TNxContext;
begin
  mFirm_OID := self.GetFieldValueAsString('X_Firm_ID');
  mMenu_OID := self.GetFieldValueAsString('X_StoreMenu_ID');

  if NxIsEmptyOID(mFirm_OID) then begin
    self.AddValidateError(0, 'Položka "Firma" musí být vyplněna.');
    AResult := False;
  end;
  if NxIsEmptyOID(mMenu_OID) then begin
    self.AddValidateError(0, 'Položka "Skladové menu" musí být vyplněna.');
    AResult := False;
  end;
  if AResult then begin
    mContext := NxCreateContext_1(self);
    mSQL := 'select ID from DefRollData where CLSID = ''QCMDDCC1QJE4V2CYU1YUPVBLFS'' and Hidden = ''N'' and ' +
            '(X_Firm_ID IN (SELECT ID FROM Firms WHERE ID = ''%s'' OR Firm_ID = ''%s'')) and X_StoreMenu_ID = ''%s''';
    mSQL := Format(mSQL, [mFirm_OID, mFirm_OID, mMenu_OID]);
    mValues := TStringList.Create;
    try
      mContext.SQLSelect(mSQL, mValues);
      if mValues.Count > 0 then begin
        if mValues.Count = 1 then begin
          mValue := self.GetFieldValueAsString('ID');
          mItem := mValues.Strings[0];
          if mValue <> mItem then begin
            self.AddValidateError(0, 'Nelze uložit záznam s duplicitní hodnotou firmy a skladového menu.');
            AResult := False;
          end;
        end
        else begin
          self.AddValidateError(0, 'Nelze uložit záznam s duplicitní hodnotou firmy a skladového menu.');
          AResult := False;
        end;
      end;
    finally
      mValues.Free;
    end;
  end;
end;

begin
end.