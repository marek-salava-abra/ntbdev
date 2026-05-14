procedure _InitSelf_PostHook(Self: TSiteForm);
var
  mMG: TMultiGrid;
  mFieldDef: TFieldDef;
  i, mLayout, mLine, mOrder: Integer;
  mMGCol: TNxMultiGridColumn;
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

  mMG := TMultiGrid(NxFindChildControl(Self.GetSiteAppForm, 'grdRows'));
  if Assigned(mMG) then begin
    b := True;
    for i:=mMG.ColumnCount-1 downto 0 do
      if mMG.Columns[i].FieldName = 'U_info' then
        b := False;
    if b then begin
      mFieldDef := TFieldDef.Create(mMG.DataSource.DataSet.FieldDefs, 'U_info', ftWideString, 0, False, 301);
      with mFieldDef.CreateField(mMG.DataSource.DataSet, nil, 'U_info', False) do begin
        ReadOnly:= False;
        FieldName:= 'U_info';
        FieldKind:= fkData;
      end;
      iPreparePosition(3, 0, 5);
      mMGCol := TNxMultiGridColumn.Create(mMG.Owner);
      mMGCol.FieldName := 'U_info';
      mMGCol.Caption := 'Info';
      mMGCol.ReadOnly := False;
      mMGCol.Kind := ckText;
      mMGCol.Elastic := True;
      mMGCol.Width := 200;
      mMGCol.Layout := 3;
      mMGCol.Line := 0;
      mMGCol.Order := 5;
      mMG.AddColumn(mMGCol);
    end;
    for i:=mMG.ColumnCount-1 downto 0 do
      if mMG.Columns[i].FieldName = 'U_marze' then
        b := False;
    if b and (NxGetActualUserID(TDynSiteForm(self).GetFakeBusinessObject.ObjectSpace)='1500000101') then begin
      mFieldDef := TFieldDef.Create(mMG.DataSource.DataSet.FieldDefs, 'U_marze', ftFloat, 0, False, 301);
      with mFieldDef.CreateField(mMG.DataSource.DataSet, nil, 'U_marze', False) do begin
        ReadOnly:= False;
        FieldName:= 'U_marze';
        FieldKind:= fkData;
      end;
      iPreparePosition(3, 0, 14);
      mMGCol := TNxMultiGridColumn.Create(mMG.Owner);
      mMGCol.FieldName := 'U_marze';
      mMGCol.Caption := 'Rabat';
      mMGCol.ReadOnly := False;
      mMGCol.Kind := ckText;
      mMGCol.Elastic := True;
      mMGCol.Width := 200;
      mMGCol.Layout := 3;
      mMGCol.Line := 0;
      mMGCol.Order := 14;
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
  mMG := TMultiGrid(NxFindChildControl(ASiteForm.GetSiteAppForm, 'grdRows'));
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