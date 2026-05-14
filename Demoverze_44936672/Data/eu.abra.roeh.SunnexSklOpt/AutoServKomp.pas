uses  'eu.abra.roeh.Logio.AutoServ',
       'eu.abra.roeh.SunnexSklOpt.FuncSpm';

procedure ExportStoreCradsMaterial (OS: TNxCustomObjectSpace;
  var Success: Boolean; var LogInfoStr: String);
begin
  MarginStoreCard(OS);
  CreateMaterialsFromNorms(OS);
  CreateInventoroExport (OS,Success,LogInfoStr);
end;

begin
end.