procedure _InitSelf_PostHook(Self: TSiteForm);
var
  mMG: tMultiGrid;
begin
  mMG := TMultiGrid(Self.FindChildControl('grdRows'));;
  mMG.OnGetCellFontProps:=@mMG_OnGetCellFontProps;
end;

procedure mMG_OnGetCellFontProps(Sender : TMultiGrid; var AActColumn: TNxMultiGridCustomColumn; var AFont : TFont);
begin
  if AActColumn.FieldName = 'Amount' then begin
    AFont.Style := [fsBold];
    if Sender.DataSource.DataSet.FieldByName('Credit').AsBoolean then
     AFont.Color := clBlue else AFont.Color := clRed;
  end
  else
    AFont.Style := 0;
end;

begin
end.