{
Vyvolává se po vyplnění hlavičky výstupního dokladu importovacím managerem
}
procedure AfterFillOptputHeader_Hook(Self: TNxDocumentImportManager);
var
  i: Integer;
begin
  for i:=0 to Self.InputDocumentCount -1 do begin
    Self.InputDocuments[i].SetFieldValueAsInteger('X_WEB_Stav_Dokladu',2);
    //Self.InputDocuments[i].e;
    //Self.InputDocuments[i].Save;
  end;
  Self.OutputDocument.SetFieldValueAsInteger('U_SendMail',1);
end;

begin
end.