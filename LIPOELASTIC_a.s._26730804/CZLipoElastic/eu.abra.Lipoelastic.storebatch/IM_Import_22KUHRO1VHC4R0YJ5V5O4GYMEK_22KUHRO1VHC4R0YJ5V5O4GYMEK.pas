uses 'eu.abra.Lipoelastic.storebatch.fce';

procedure AfterFillOptputRows_Hook(Self: TNxDocumentImportManager);

begin
  ComplementAfterImportRO(TNxHeaderBusinessObject(Self.OutputDocument));
end;

begin
end.