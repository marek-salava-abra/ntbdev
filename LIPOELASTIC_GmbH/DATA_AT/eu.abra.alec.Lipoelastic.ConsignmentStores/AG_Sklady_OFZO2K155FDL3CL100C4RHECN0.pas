uses '.lib', '.import';

{
Vyvolává se po provedení inicializace agendy/formuláře. V tento okamžik je již na formuláři dostupný SiteContext.
}
procedure InitSite_Hook(Self: TSiteForm);
var
  mAction: TMultiAction;
begin
  mAction:= Self.GetNewMultiAction;
  mAction.Name:= 'actConsignmentStoresImport';
  mAction.Caption:= '# Import consignment sales #';
  mAction.Items.Add('Import consignment sales');
  mAction.Items.Add('Compare consignment inventory');
  mAction.Items.Add('Import inventory');
  mAction.Items.Add('Barcode test');
  mAction.Category:= 'tabList';

  mAction.OnExecuteItem:= @ConsignmentImportSwitch;
end;


procedure ConsignmentImportSwitch(Sender: TComponent; AIndex: Integer);
begin
  case AIndex of
    0: ConsignmentImport(Sender, cIMPORT_METHOD_STORE);
    1: ConsignmentImport(Sender, cIMPORT_METHOD_INVENTORY);
    2: ImportStoreQuantities(Sender);
    3: Barcode_Test(Sender);
  end;
end;


procedure Barcode_Test(Sender: TComponent);
var
  mTemp: string;
begin
  mTemp:= InputBox('','','', Sender.Site);
  NxShowSimpleMessage(ParseEAN(Sender.Site.BaseObjectSpace, '', '', '', mTemp), Sender.Site);

end;





begin
end.