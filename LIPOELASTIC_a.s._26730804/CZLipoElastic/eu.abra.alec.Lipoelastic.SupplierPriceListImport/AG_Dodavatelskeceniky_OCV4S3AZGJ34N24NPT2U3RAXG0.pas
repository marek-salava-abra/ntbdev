uses 'eu.abra.alec.Lipoelastic.SupplierPriceListImport.form';

procedure InitSite_Hook(Self: TSiteForm);
var
  mAction: TMultiAction;
begin
  mAction := Self.GetNewMultiAction;
  mAction.ShowControl := True;
  mAction.ShowMenuItem := True;
  mAction.Caption := '## Import ceníku (XLSX) ##';
  mAction.Items.Add('Import ceníku (XLSX)');
  mAction.Items.Add('Doimportovat řádky (XLSX)');
  mAction.Category := 'tabList';
  mAction.OnExecuteItem := @actShowForm;
end;

procedure actShowForm(Sender: TComponent; AIndex: Integer);
Var
  mSite: TSiteForm;
begin
  mSite:= Sender.Site;

  case AIndex of
    0: ShowForm(mSite);
    1: SupplierListImportXLSX(mSite, '', 0, TDynSiteForm(mSite).CurrentObject);
  end;
end;

begin
end.