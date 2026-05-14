uses 'eu.abra.Lipoelastic.storebatch.fce';

procedure AfterFillOptputRows_Hook(Self: TNxDocumentImportManager);

begin
  ComplementAfterImportIO(TNxHeaderBusinessObject(Self.OutputDocument));
end;

begin
end.