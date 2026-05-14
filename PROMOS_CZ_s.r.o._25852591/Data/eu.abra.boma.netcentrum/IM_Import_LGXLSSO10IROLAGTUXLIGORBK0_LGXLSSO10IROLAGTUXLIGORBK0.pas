procedure AfterFillOptputHeader_Hook(Self: TNxDocumentImportManager);
var
  i: Integer;
begin
  for i:=0 to Self.InputDocumentCount -1 do begin
    Self.InputDocuments[i].SetFieldValueAsInteger('X_WEB_Stav_Dokladu',3);
    Self.InputDocuments[i].Save;
  end;
end;

begin
end.