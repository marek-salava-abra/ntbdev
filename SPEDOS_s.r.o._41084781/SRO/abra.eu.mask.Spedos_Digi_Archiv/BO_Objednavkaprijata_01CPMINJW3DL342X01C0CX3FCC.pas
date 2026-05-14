{
Vyvolává se před fyzickým uložením vlastních dat objektu do databáze.
}
procedure BeforeSave_Hook(Self: TNxCustomBusinessObject);
begin
  if OsNew in Self.State then begin
          self.SetFieldValueAsInteger('VATRounding',0);
  end;
end;

begin
end.