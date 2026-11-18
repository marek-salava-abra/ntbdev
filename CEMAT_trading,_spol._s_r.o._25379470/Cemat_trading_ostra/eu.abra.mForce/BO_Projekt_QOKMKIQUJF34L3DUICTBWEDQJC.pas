const
  constStoragePath = '\\192.168.1.198\data\AbraG3\mForce';
  constNewDirStr = '%s\%s';



{
Vyvolává se po uložení vlastních dat objektu do databáze.
}
procedure AfterSave_Hook(Self: TNxCustomBusinessObject);
begin
  if osNew in self.State then begin
      if DirectoryExists(constStoragePath) then begin
          NxCreateDir(Format('%s\%s\%s', [constStoragePath,self.GetFieldValueAsString('Code'),'Dokumenty']));
          NxCreateDir(Format('%s\%s\%s', [constStoragePath,self.GetFieldValueAsString('Code'),'Foto']));
      end;
  end;
end;

begin
end.