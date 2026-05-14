procedure BeforeSoftValidate_Hook(Self: TNxCustomBusinessObject);
begin
  if NxIsEmptyOID(Self.GetFieldValueAsString('StoreMan_ID')) then
  begin
    Self.AddValidateError(Self.GetFieldCode('StoreMan_ID'),'Není vyplněn skladník.');
  end;
end;

begin
end.