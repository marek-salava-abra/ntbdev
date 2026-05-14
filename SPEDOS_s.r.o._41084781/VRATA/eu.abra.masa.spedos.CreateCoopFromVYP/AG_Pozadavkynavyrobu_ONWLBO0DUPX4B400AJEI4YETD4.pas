procedure _InitSelf_PostHook(Self: TSiteForm);
var
  mMG: TMultiGrid;
  mFieldDef: TFieldDef;
  i, mLayout, mLine, mOrder: Integer;
  mMGCol: TNxMultiGridColumn;
  mMGCol2: TNxMultiGridBooleanColumn;
  mMGColRoll: TNxMultiGridObjectRollColumn;
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
      if mMG.Columns[i].FieldName = 'U_SpedosCoop' then
        b := False;
    if b then begin
      mFieldDef := TFieldDef.Create(mMG.DataSource.DataSet.FieldDefs, 'U_SpedosCoop', ftBoolean, 0, False, 320);
      with mFieldDef.CreateField(mMG.DataSource.DataSet, nil, 'U_SpedosCoop', False) do begin
        ReadOnly:= False;
        FieldName:= 'U_SpedosCoop';
        FieldKind:= fkData;
      end;
      iPreparePosition(0, 1, 17);
      mMGCol2 := TNxMultiGridBooleanColumn.Create(mMG.Owner);
      mMGCol2.FieldName := 'U_SpedosCoop';
      mMGCol2.Caption := 'Sped. koop';
      mMGCol2.ReadOnly := False;
      mMGCol2.Kind := ckCombo;
      mMGCol2.Elastic := True;
      mMGCol2.Width := 60;
      mMGCol2.Layout := 0;
      mMGCol2.Line := 1;
      mMGCol2.Order := 17;
      mMG.AddColumn(mMGCol2);
     end;
  end;
end;




begin
end.