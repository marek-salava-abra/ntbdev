procedure CompleteRollValidateParams_Hook(Self: TNxCustomBusinessObject; AFieldCode: integer; AParams: TNxParameters);
begin
  if (AFieldCode = Self.GetFieldCode('X_Druh_ID'))
      or (AFieldCode = Self.GetFieldCode('X_Velikosti_ID'))
      or (AFieldCode = Self.GetFieldCode('X_Provedeni_ID'))
      or (AFieldCode = Self.GetFieldCode('X_Barva_ID'))

    then begin
        AParams.GetOrCreateParam(dtString, 'mAssortmentGroup');
        AParams.GetOrCreateParam(dtString, 'mAssortmentGroup').AsString :=  Self.GetFieldValueAsString('X_StoreAssortmentGroup_ID');
  end;
end;


begin
end.