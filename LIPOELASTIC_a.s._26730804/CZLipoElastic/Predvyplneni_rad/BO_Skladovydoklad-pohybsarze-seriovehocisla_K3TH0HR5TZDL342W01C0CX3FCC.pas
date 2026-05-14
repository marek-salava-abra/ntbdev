{
Vyvolává se před fyzickým uložením vlastních dat objektu do databáze.
}
procedure BeforeSave_Hook(Self: TNxCustomBusinessObject);
begin
  if self.GetFieldValueAsString('Qunit') = '' then begin
        self.SetFieldValueAsString('Qunit',self.GetFieldValueAsString('Parent_ID.Qunit')) ;
  end;
end;

begin
end.