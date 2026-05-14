{
Vyvolává se před fyzickým uložením vlastních dat objektu do databáze.
}
procedure BeforeSave_Hook(Self: TNxCustomBusinessObject);
begin
  if not(self.GetFieldValueAsString('DocQueue_ID') in ['7RN0000101','4M00000101']) then
   self.SetFieldValueAsString('Description2',
   'Peníze za zakoupené zboží nevracíme. Nepoškozené zboží v originálním obalu lze s pokladním dokladem vyměnit do 30 dnů od zakoupení za jiné zboží stejné nebo vyšší hodnoty.');
end;

begin
end.