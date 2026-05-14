procedure CompleteRollValidateParams_Hook(Self: TNxCustomBusinessObject; AFieldCode: integer; AParams: TNxParameters);
begin
  if AFieldCode = Self.GetFieldCode('StoreCard_ID') then begin
    AParams.GetOrCreateParam(dtBoolean, 'MyActiveCard');
    AParams.GetOrCreateParam(dtBoolean, 'MyActiveCard').AsBoolean := true;
  end;
end;

begin
end.