uses
  'abra.lubi.ImportAlbertina.Books';

procedure _BeforeValidate_PreHook(Self: TNxCustomBusinessObject);
begin
  ShowDebugMessage('_BeforeValidate_PreHook - start');
  self.SetFieldValueAsBoolean('X_ImportAlbertina', False);
  ShowDebugMessage('_BeforeValidate_PreHook - ok');
end;

{procedure _CanModifyField_Hook(Self: TNxCustomBusinessObject; AFieldCode: integer; var AResult: Boolean);
begin
  if AFieldCode = self.GetFieldCode('X_ImportAlbertina') then
    AResult := False;
end;
}
begin
end.