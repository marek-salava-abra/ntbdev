procedure _InitSelf_PostHook(Self: TSiteForm);
var
  mMG: TMultiGrid;
  mFieldDef: TFieldDef;
  i, mLayout, mLine, mOrder: Integer;
  mMGCol: TNxMultiGridDateColumn;
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
      if mMG.Columns[i].FieldName = 'X_PaymentDate' then
        b := False;
    if b then begin
      mFieldDef := TFieldDef.Create(mMG.DataSource.DataSet.FieldDefs, 'X_PaymentDate', ftDate, 0, False, 311);
      with mFieldDef.CreateField(mMG.DataSource.DataSet, nil, 'X_PaymentDate', False) do begin
        ReadOnly:= False;
        FieldName:= 'X_PaymentDate';
        FieldKind:= fkData;
      end;
      //mMG.OnGetCellFontProps := @mMG_OnGetCellFontProps;
      iPreparePosition(3, 1, 6);
      mMGCol := TNxMultiGridDateColumn.Create(mMG.Owner);
      mMGCol.FieldName := 'X_PaymentDate';
      mMGCol.Caption := 'Datum platby';
      mMGCol.ReadOnly := False;
      mMGCol.Kind := ckText;
      mMGCol.Elastic := false;
      mMGCol.Width := 80;
      mMGCol.Layout := 3;
      mMGCol.Line := 1;
      mMGCol.Order := 6;
      mMG.AddColumn(mMGCol);
    end;
  end;
end;


begin
end.
