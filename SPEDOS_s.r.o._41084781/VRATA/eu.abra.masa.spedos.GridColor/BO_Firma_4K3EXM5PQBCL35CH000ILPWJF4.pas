procedure AfterSave_Hook(Self: TNxCustomBusinessObject);
begin
  Self.ObjectSpace.SQLExecute(Format('update Suppliers set firm_id = ''%s'' where firm_id in ( '+
' select coalesce(id, firm_id) from firms where id = ''%s'' or firm_id = ''%s'') ', [Self.OID, Self.OID, Self.OID]));
  Self.ObjectSpace.SQLExecute(Format('update Subscribers set firm_id = ''%s'' where firm_id in ( '+
' select coalesce(id, firm_id) from firms where id = ''%s'' or firm_id = ''%s'') ', [Self.OID, Self.OID, Self.OID]));
end;

begin
end.