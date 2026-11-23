procedure _InitSelf_PostHook(Self: TSiteForm);
var
  mMG: TMultiGrid;
  mFieldDef: TFieldDef;
  i, mLayout, mLine, mOrder: Integer;
  mMGCol, mMGColJednotka,mMGColVychystano,mMGColDeliveredQuantity: TNxMultiGridColumn;
  mMGColRoll: TNxMultiGridColumn;
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
mMG := TMultiGrid(NxFindChildControl(Self.GetSiteAppForm, 'grdUnits'));
  if Assigned(mMG) then begin
    b := True;
    for i:=mMG.ColumnCount-1 downto 0 do
    if mMG.Columns[i].FieldName = 'X_Capacity' then
        b := False;
        if b then begin
          mFieldDef := TFieldDef.Create(mMG.DataSource.DataSet.FieldDefs, 'X_Capacity', ftFloat, 0, False, 107);
          with mFieldDef.CreateField(mMG.DataSource.DataSet, nil, 'objx', False) do begin
            ReadOnly:= False;
            FieldName:= 'X_Capacity';
            FieldKind:= fkData;
          end;
      iPreparePosition(0, 0, 3);
      mMGColRoll:= (TNxMultiGridColumn.Create(mMG.Owner));
      mMGColRoll.FieldName := 'X_Capacity';
      mMGColRoll.Caption := 'obj přep.';
      mMGColRoll.ReadOnly := False;
      mMGColRoll.Kind := ckText;
      mMGColRoll.Elastic := false;
      mMGColRoll.Width := 70;
      mMGColRoll.Layout := 0;
      mMGColRoll.Line := 0;
      mMGColRoll.Order := 31;
      mMG.AddColumn(mMGColRoll);
    end;
    b := True;
    for i:=mMG.ColumnCount-1 downto 0 do
    if mMG.Columns[i].FieldName = 'X_Weight' then
        b := False;
        if b then begin
          mFieldDef := TFieldDef.Create(mMG.DataSource.DataSet.FieldDefs, 'X_Weight', ftFloat, 0, False, 108);
          with mFieldDef.CreateField(mMG.DataSource.DataSet, nil, 'hmx', False) do begin
            ReadOnly:= False;
            FieldName:= 'X_Weight';
            FieldKind:= fkData;
          end;
      iPreparePosition(0, 0, 3);
      mMGColRoll:= (TNxMultiGridColumn.Create(mMG.Owner));
      mMGColRoll.FieldName := 'X_Weight';
      mMGColRoll.Caption := 'hm. přep.';
      mMGColRoll.ReadOnly := False;
      mMGColRoll.Kind := ckText;
      mMGColRoll.Elastic := false;
      mMGColRoll.Width := 70;
      mMGColRoll.Layout := 0;
      mMGColRoll.Line := 0;
      mMGColRoll.Order := 32;
      mMG.AddColumn(mMGColRoll);
    end;
 end;
end;

begin
end.