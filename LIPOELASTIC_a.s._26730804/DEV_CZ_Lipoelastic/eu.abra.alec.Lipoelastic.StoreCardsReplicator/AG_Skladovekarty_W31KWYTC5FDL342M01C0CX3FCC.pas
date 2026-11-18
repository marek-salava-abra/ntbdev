uses 'eu.abra.alec.Lipoelastic.StoreCardsReplicator.core';

{
Vyvolává se po provedení inicializace agendy/formuláře. V tento okamžik je již na formuláři dostupný SiteContext.
}
procedure InitSite_Hook(Self: TSiteForm);
var
  mAction: TMultiAction;
begin
  mAction := Self.GetNewMultiAction;
  mAction.ShowControl := True;
  mAction.ShowMenuItem := True;
  mAction.Name := 'CloneOrImportSwitch';
  mAction.Caption := '## Klon sklad. kartu / Import dat ##';
  mAction.Items.Add('Klonovat sklad. kartu (XLSX)');
  mAction.Items.Add('Importovat DPH sazby');
  mAction.Items.Add('Akt. DPH sazby u vybr. karet');
  mAction.Items.Add('Vygenerovat EAN');
  mAction.Items.Add('Importovat parametry');
  //mAction.Hint := 'Naklonuje skladovou kartu dle šablony z XLSX souboru';
  mAction.Category := 'tabList';
  mAction.OnExecuteItem := @CloneOrImportSwitch;
end;

procedure CloneOrImportSwitch(Sender: TComponent; Index: integer);
begin
  case Index of
    0: actStoreCardReplicator(Sender.Site);
    1: ImportVATRatesToSC(Sender.Site);
    2: ActualizeVATRatesToSC(Sender.Site);
    3: GenerateNewEAN(Sender.Site);
    4: ImportStoreCardParameters(Sender.Site);
  end;
end;


begin
end.