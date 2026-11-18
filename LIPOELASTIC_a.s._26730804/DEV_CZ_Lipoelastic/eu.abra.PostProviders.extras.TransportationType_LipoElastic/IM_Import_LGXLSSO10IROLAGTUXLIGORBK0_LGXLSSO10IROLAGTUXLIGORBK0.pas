//Přenos položky provozovny do FV
{
procedure AfterFillOptputHeader_Hook(Self: TNxDocumentImportManager);
begin
  try
    Self.OutputDocument.SetFieldValueAsString('X_PD_BB_Branches',Self.InputDocuments[0].GetFieldValueAsString('X_PD_BB_Branches'));
  except

  end;
end;
  }
begin
end.