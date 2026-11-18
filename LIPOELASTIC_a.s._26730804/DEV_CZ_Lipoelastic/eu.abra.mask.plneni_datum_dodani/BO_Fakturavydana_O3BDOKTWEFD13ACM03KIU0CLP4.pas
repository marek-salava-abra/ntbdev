uses 'EU.Aabra.Mask.Validace.lib';
var
m_begin_save,mEnd_save:double;

{
Vyvolává se před fyzickým uložením vlastních dat objektu do databáze.
}
procedure BeforeSave_Hook(Self: TNxCustomBusinessObject);
begin
  if m_begin_save=0 then m_begin_save:=Now;
end;

procedure BeforeSoftValidate_Hook(Self: TNxCustomBusinessObject);
begin
  m_begin_save:=Now;
end;
{
Vyvolává se po uložení vlastních dat objektu do databáze.
}
procedure AfterSave_Hook(Self: TNxCustomBusinessObject);
var
mi:Integer;
begin
  mEnd_save:=now();
  if mEnd_save-m_begin_save<5 then mi:=self.ObjectSpace.SQLExecute('Update Issuedinvoices set X_Save_Time=' +  NxFloatToIBStr(mEnd_save-m_begin_save) + ' where id=' +quotedstr(self.oid));
  m_begin_save:=0;
  mEnd_save:=0;
end;


begin
end.