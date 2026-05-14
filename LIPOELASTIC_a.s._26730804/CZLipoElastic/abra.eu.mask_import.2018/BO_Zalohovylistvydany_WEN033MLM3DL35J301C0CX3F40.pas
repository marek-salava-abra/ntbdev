uses 'EU.Aabra.Mask.Validace.lib';
{
Vyvolává se bezprostředně před provedením softvalidace objektu.
}
procedure BeforeSoftValidate_Hook(Self: TNxCustomBusinessObject);
begin
  if self.GetFieldValueAsinteger('Varsymbol')=0 then begin
         self.SetFieldValueAsString('Varsymbol','');
         //NxShowSimpleMessage('AAA',nil);
  end;
end;

begin
end.