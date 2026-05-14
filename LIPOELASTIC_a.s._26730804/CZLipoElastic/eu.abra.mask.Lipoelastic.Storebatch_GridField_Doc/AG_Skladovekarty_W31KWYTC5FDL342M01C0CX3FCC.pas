procedure _InitSelf_PostHook(Self: TSiteForm);
var
  mMG: TMultiGrid;
  mFieldDef: TFieldDef;
  i, mLayout, mLine, mOrder: Integer;
  mMGCol, mMGColJednotka: TNxMultiGridColumn;
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
  mMG := TMultiGrid(NxFindChildControl(Self.GetSiteAppForm, 'grdSubscribers'));
  if Assigned(mMG) then begin
    b := True;
    for i:=mMG.ColumnCount-1 downto 0 do
      if mMG.Columns[i].FieldName = 'X_Krabicka_ID' then
        b := False;
        if b then begin
          mFieldDef := TFieldDef.Create(mMG.DataSource.DataSet.FieldDefs, 'X_Krabicka_ID', ftWideString, 0, False, 049);
          with mFieldDef.CreateField(mMG.DataSource.DataSet, nil, 'X_Krabicka_ID', False) do begin
            ReadOnly:= False;
            FieldName:= 'X_Krabicka_ID';
            FieldKind:= fkData;
          end;
      iPreparePosition(3, 0, 49);
      mMGColRoll:= (TNxMultiGridObjectRollColumn.Create(mMG.Owner));
      mMGColRoll.FieldName := 'X_Krabicka_ID';
      mMGColRoll.Caption := '#Obalový materál';
      mMGColRoll.ReadOnly := False;
      mMGColRoll.Kind := ckText;
      mMGColRoll.Elastic := false;
      mMGColRoll.Width := 70;
      mMGColRoll.Layout := 1;
      mMGColRoll.Line := 0;
      mMGColRoll.Order := 5;
      mMGColRoll.Kind := ckUser;
      mMGColRoll.ClassID:=('S3WZQKDB5FDL342M01C0CX3FCC');
      mMGColRoll.TextField:='Name';
      mMG.AddColumn(mMGColRoll);
    end;
   end;
end;




begin
end.
