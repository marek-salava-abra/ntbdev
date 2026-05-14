
Procedure OnGetGrdRowsColumnReadOnly(Sender: TNxMultiGridCustomColumn; var AReadOnly: Boolean);
begin
   if Sender.Name = 'X_Specification' then AReadOnly:= True;
end;

{
Vyvolává se po provedení inicializace agendy/formuláře. V tento okamžik je již na formuláři dostupný SiteContext.
}
procedure InitSite_Hook(Self: TSiteForm);
Var
   mFieldDef: TFieldDef;
   mField: TFIeld;
   mDataSet: TDataSet;
   mGrdRows: TMultiGrid;
   mColR: TNxMultiGridRollColumn;
   mColNum,mMGCol:TNxMultiGridColumn;
   i: Integer;
   b:boolean;


  procedure iPreparePosition(ALayout, ALine, ARequestPosition: Integer);
  var
    ii: Integer;
  begin
    for ii:=mGrdRows.ColumnCount-1 downto 0 do
      if (mGrdRows.Columns[ii].Layout = ALayout) and (mGrdRows.Columns[ii].Line = ALine) and
        (mGrdRows.Columns[ii].Order >= ARequestPosition) then
        mGrdRows.Columns[ii].Order := mGrdRows.Columns[ii].Order + 1;
  end;

begin




   mGrdRows:= TMultiGrid(NxFindChildControl(self.GetSiteAppForm,'grdRows'));
   if mGrdRows = nil then Exit;


  if Assigned(mGrdRows) then begin
    b := True;
    for i:=mGrdRows.ColumnCount-1 downto 0 do
      if mGrdRows.Columns[i].FieldName = 'Posindex' then
        b := False;
    if b then begin
      mFieldDef := TFieldDef.Create(mGrdRows.DataSource.DataSet.FieldDefs, 'MyPosindex', ftInteger, 0, False, 301);
      with mFieldDef.CreateField(mGrdRows.DataSource.DataSet, nil, 'xPosindex', False) do begin
        ReadOnly:= False;
        FieldName:= 'Posindex';
        FieldKind:= fkData;
      end;
      mGrdRows.OnGetCellFontProps := @mMG_OnGetCellFontProps;
      iPreparePosition(0, 0, 0);
      mMGCol := TNxMultiGridColumn.Create(mGrdRows.Owner);
      mMGCol.FieldName := 'Posindex';
      mMGCol.Caption := 'Poř.';
      mMGCol.ReadOnly := False;
      mMGCol.Kind := ckText;
      mMGCol.Elastic := True;
      mMGCol.Width := 40;
      mMGCol.Layout := 0;
      mMGCol.Line := 0;
      mMGCol.Order := 0;
      mGrdRows.AddColumn(mMGCol);
    end;
  end;



end;




procedure mMG_OnGetCellFontProps(Sender : TObject; var AActColumn: TNxMultiGridCustomColumn; var AFont : TFont);
begin
  if AActColumn.FieldName = 'DealerDiscount' then begin
    AFont.Style := [fsBold];
    AFont.Color := clBlue;
  end
  else
    AFont.Style := 0;
end;

begin
end.


begin
end.