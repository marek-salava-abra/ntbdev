{
Triggered after the modification of each item. Only if the modification is not caused by loading the object from the database or creating a copy.
}
procedure AfterSetFieldValue_Hook(Self: TNxCustomBusinessObject; AFieldCode: Integer; AValue: TNxParameter; AOriginalValue: TNxParameter);
begin
  if (osNew in Self.State) and (AFieldCode = Self.GetFieldCode('Firm_ID')) and (AOriginalValue.AsString <> AValue.AsString) then
  begin
    Self.SetFieldValueAsBoolean('PricesWithVAT', False);
    if (not(Self.GetFieldValueAsBoolean('Firm_ID.X_B2B'))) then
      Self.SetFieldValueAsBoolean('PricesWithVAT', True);

    Self.SetFieldValueAsString('X_PackagingMethod_ID', Self.GetFieldValueAsString('Firm_ID.X_PackagingMethod_ID'));
  end;
end;

begin
end.