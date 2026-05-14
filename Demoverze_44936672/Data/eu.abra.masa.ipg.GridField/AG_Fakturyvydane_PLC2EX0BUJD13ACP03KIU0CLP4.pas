
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
      mMGCol.Width := 100;
      mMGCol.Layout := 3;
      mMGCol.Line := 0;
      mMGCol.Order := 5;
      mMG.AddColumn(mMGCol);
    end;
  end;
end;



begin
end.