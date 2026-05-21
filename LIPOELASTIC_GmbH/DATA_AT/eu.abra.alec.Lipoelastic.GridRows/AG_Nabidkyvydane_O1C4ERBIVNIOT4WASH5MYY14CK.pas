
{
Vyvolává se po provedení inicializace agendy/formuláře. V tento okamžik je již na formuláři dostupný SiteContext.
}
procedure InitSite_Hook(Self: TSiteForm);
var
   grdReqRows: TMultiGrid;
   mFieldDef: TFieldDef;
   mField: TFIeld;
   mDataSet: TDataSet;
   mCol: TNxMultiGridColumn;
   i: Integer;
   mTemp: string;
begin
  grdReqRows:= TMultiGrid(Self.FindChildControl('grdRows'));
  if Assigned(grdReqRows) then
  begin
    for i:= 0 to grdReqRows.ColumnCount -1 do
    begin
      if VarToStr(grdReqRows.Columns[i].Name) in ['colUnitQuantity2', 'colUnitQuantity3'] then
        grdReqRows.Columns[i].Caption:= 'Quantity';
    end;
  end;
end;

begin
end.