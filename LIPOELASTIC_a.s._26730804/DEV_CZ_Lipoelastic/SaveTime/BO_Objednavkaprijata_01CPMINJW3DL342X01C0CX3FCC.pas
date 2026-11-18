var
mBeginSave,mEndsave:double;



{
Vyvolává se bezprostředně před provedením softvalidace objektu.
}
{
Vyvolává se po uložení vlastních dat objektu do databáze.
}
procedure AfterSave_Hook(Self: TNxCustomBusinessObject);
var
mi:integer;
mtime:double;
begin

mtime:=now - mBeginSave;
mi:=self.ObjectSpace.SQLExecute('update ReceivedOrders set X_TimeSave=' + NxFloatToIBStr(mtime) + ' where id= ' +quotedstr(self.oid));
end;

procedure BeforeSoftValidate_Hook(Self: TNxCustomBusinessObject);
begin
mBeginSave:=now();
end;


begin
end.