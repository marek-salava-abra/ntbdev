uses 'MASK_XLS_Import.core';

{
Vyvolává se po provedení inicializace agendy/formuláře. V tento okamžik je již na formuláři dostupný SiteContext.
}
procedure InitSite_Hook(Self: TSiteForm);
var
  mAction: TMultiAction;
begin
  if false then begin
          mAction := Self.GetNewMultiAction;
          mAction.ShowControl := True;
          mAction.ShowMenuItem := True;
          mAction.Name := 'importXLS';
          mAction.Caption := 'Import XLS';
          mAction.Items.Add('Import (XLSX)');
          //mAction.Hint := 'Naklonuje skladovou kartu dle šablony z XLSX souboru';
          mAction.Category := 'tabList';
          mAction.OnExecuteItem := @CloneOrImportSwitch;
  end;
end;

procedure CloneOrImportSwitch(Sender: TComponent; Index: integer);
begin
  case Index of
    0: ImportXLS(Sender.Site);
  end;
end;


begin
end.