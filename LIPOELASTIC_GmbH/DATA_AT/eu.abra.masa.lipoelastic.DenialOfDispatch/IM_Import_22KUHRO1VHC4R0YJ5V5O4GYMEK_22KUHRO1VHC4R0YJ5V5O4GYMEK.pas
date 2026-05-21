{
Vyvolává se před spuštěním průvodce pro zadání základních hodnot.
}
procedure BeforeRunWizard_Hook(Self: TNxDocumentImportManager);
begin
  if self.InputDocuments[0].GetFieldValueAsBoolean('Firm_ID.X_DenialOfDispatch') then begin
    NxShowSimpleMessage('Firm '+self.InputDocuments[0].GetFieldValueAsString('Firm_ID.Name')+' has denial of dispatch. Exiting.',nil);
    exit;
  end;
end;

begin
end.