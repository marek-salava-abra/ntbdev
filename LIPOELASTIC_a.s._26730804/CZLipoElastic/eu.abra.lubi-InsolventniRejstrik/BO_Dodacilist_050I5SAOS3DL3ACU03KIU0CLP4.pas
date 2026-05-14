uses 'eu.abra.lubi-InsolventniRejstrik.Commons';

{
Vyvolává se bezprostředně před provedením softvalidace objektu.
}
procedure BeforeSoftValidate_Hook(Self: TNxCustomBusinessObject);
begin
  ExBeforeSoftValidate_Hook(Self);
end;

begin
end.