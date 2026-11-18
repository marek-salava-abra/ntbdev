uses 'eu.abra.mavy.LabelPrinter.API.consts.consts', 'eu.abra.mavy.LabelPrinter.API.CreatePDM';
{
Vyvolává se po uložení vlastních dat objektu do databáze.
}
procedure AfterSave_Hook(Self: TNxCustomBusinessObject);
begin
  if osNew in self.State then begin
    if cAutoSendFromInvoice and Self.GetFieldValueAsBoolean('X_LP_SendToLabelPrinter') and Self.GetFieldValueAsBoolean('TransportationType_ID.X_LP_SendToLabelPrinter') then begin
      try
        if NxIsEmptyOID(CreatePDMDoc(Self.ObjectSpace,Self,Self.CLSID, False,False)) then ShowMessage('Doklad odeslané pošty nebyl automaticky vytvořen');
      except
        ShowMessage('LP: Nastala chyba při automatickém vytvoření odeslané pošty: '+ExceptionMessage);
      end;
    end;
  end;
end;

begin
end.