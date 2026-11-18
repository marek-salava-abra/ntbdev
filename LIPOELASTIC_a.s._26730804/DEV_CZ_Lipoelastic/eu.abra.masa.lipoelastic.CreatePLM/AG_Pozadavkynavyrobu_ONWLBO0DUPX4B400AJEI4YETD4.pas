procedure _InitSelf_PostHook(Self: TSiteForm);
var
  mMG: TMultiGrid;
  mFieldDef: TFieldDef;
  i, mLayout, mLine, mOrder: Integer;
  mMGCol: TNxMultiGridBooleanColumn;
  b: Boolean;

  procedure iPreparePosition(ALayout, ALine, ARequestPosition: Integer);
  var
    ii: Integer;
  begin
    for ii:=mMG.ColumnCount-1 downto 0 do
      if (mMG.Columns[ii].Layout = ALayout) and (mMG.Columns[ii].Line = ALine) and
        (mMG.Columns[ii].Order >= ARequestPosition) then
        mMG.Columns[ii].Order := mMG.Columns[ii].Order + 1;
  end;

begin
  mMG := TMultiGrid(NxFindChildControl(Self.GetSiteAppForm, 'grdReqRows'));
  if Assigned(mMG) then begin
    b := True;
    for i:=mMG.ColumnCount-1 downto 0 do
      if mMG.Columns[i].FieldName = 'X_TariffMaterial' then
        b := False;
    if b then begin
      mFieldDef := TFieldDef.Create(mMG.DataSource.DataSet.FieldDefs, 'X_TariffMaterial', ftBoolean, 0, False, 301);
      with mFieldDef.CreateField(mMG.DataSource.DataSet, nil, 'X_TariffMaterial', False) do begin
        ReadOnly:= False;
        FieldName:= 'X_TariffMaterial';
        FieldKind:= fkData;
      end;
      iPreparePosition(0, 0, 15);
      mMGCol := TNxMultiGridBooleanColumn.Create(mMG.Owner);
      mMGCol.FieldName := 'X_TariffMaterial';
      mMGCol.Caption := 'Režijní';
      mMGCol.ReadOnly := False;
      mMGCol.Kind := ckCombo;
      mMGCol.Elastic := True;
      mMGCol.Width := 80;
      mMGCol.Layout := 0;
      mMGCol.Line := 0;
      mMGCol.Order := 15;
      mMG.AddColumn(mMGCol);
    end;

  end;
end;

function FindColumnByFieldName(ASiteForm: TSiteForm; AFieldName: String): TNxMultiGridColumn;
var
  mMG: TMultiGrid;
  i: Integer;
begin
  Result := nil;
  mMG := TMultiGrid(NxFindChildControl(ASiteForm.GetSiteAppForm, 'grdReqRows'));
  if Assigned(mMG) then
    for i:=mMG.ColumnCount-1 downto 0 do
      if mMG.Columns[i].FieldName = AFieldName then
        Result := TNxMultiGridColumn(mMG.Columns[i]);
end;

function FindColumnByFieldName2(AMG: TMultiGrid; AFieldName: String): TNxMultiGridColumn;
var
  i: Integer;
begin
  Result := nil;
  if Assigned(AMG) then
    for i:=AMG.ColumnCount-1 downto 0 do
      if AMG.Columns[i].FieldName = AFieldName then
        Result := TNxMultiGridColumn(AMG.Columns[i]);
end;


begin
end.