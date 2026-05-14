
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
  mMG := TMultiGrid(NxFindChildControl(Self.GetSiteAppForm, 'grdSuppliers'));
  //NxShowSimpleMessage(IntToStr(mMG.Columns[0].Layout),nil);
  if Assigned(mMG) then begin
   b := True;
    for i:=mMG.ColumnCount-1 downto 0 do
      if mMG.Columns[i].FieldName = 'X_float' then
        b := False;
    if b then begin
      mFieldDef := TFieldDef.Create(mMG.DataSource.DataSet.FieldDefs, 'X_float', ftFloat, 0, False, 205);
      with mFieldDef.CreateField(mMG.DataSource.DataSet, nil, 'X_float', False) do begin
        ReadOnly:= False;
        FieldName:= 'X_float';
        FieldKind:= fkData;
      end;
      iPreparePosition(0, 1, 15);
      mMGCol := TNxMultiGridColumn.Create(mMG.Owner);
      mMGCol.FieldName := 'X_float';
      mMGCol.Caption := 'SLEVAAAA';
      mMGCol.ReadOnly := False;
      mMGCol.Kind := ckText;
      mMGCol.Elastic := True;
      mMGCol.Width := 100;
      mMGCol.Layout := 0;
      mMGCol.Line := 1;
      mMGCol.Order := 15;
      mMG.AddColumn(mMGCol);
    end;
  end;
end;

begin
end.