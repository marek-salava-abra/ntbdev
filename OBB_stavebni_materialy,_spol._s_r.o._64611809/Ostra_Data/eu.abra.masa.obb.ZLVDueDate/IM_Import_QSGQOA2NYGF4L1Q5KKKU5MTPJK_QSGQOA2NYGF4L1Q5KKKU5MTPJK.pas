{
Vyvolává se před vyplněním hlavičky výstupního dokladu importovacím managerem
}
{
Vyvolává se po vyplnění hlavičky výstupního dokladu importovacím managerem
}
procedure AfterFillOptputHeader_Hook(Self: TNxDocumentImportManager);
begin
  Self.OutputDocument.SetFieldValueAsDateTime('DueDate$date',date+10);
end;

procedure BeforeFillOptputHeader_Hook(Self: TNxDocumentImportManager);
begin
  Self.OutputDocument.SetFieldValueAsDateTime('DueDate$date',date+10);
end;

begin
end.