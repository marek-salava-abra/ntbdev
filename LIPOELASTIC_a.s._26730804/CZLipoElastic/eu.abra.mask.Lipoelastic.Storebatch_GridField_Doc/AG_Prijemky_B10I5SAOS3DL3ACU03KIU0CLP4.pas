procedure _InitSelf_PostHook(Self: TSiteForm);
var
  mMG: TMultiGrid;
  mFieldDef: TFieldDef;
  i, mLayout, mLine, mOrder: Integer;
  mMGCol, mMGColJednotka, mMGColVychystano: TNxMultiGridColumn;
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
  mMG := TMultiGrid(NxFindChildControl(Self.GetSiteAppForm, 'grdRows'));
    if Assigned(mMG) then begin
        b := True;
        for i:=mMG.ColumnCount-1 downto 0 do
          if mMG.Columns[i].FieldName = 'X_Vychystano' then
            b := False;
        if b then begin
          mFieldDef := TFieldDef.Create(mMG.DataSource.DataSet.FieldDefs, 'X_Vychystano', ftFloat, 0, False, 102);
          with mFieldDef.CreateField(mMG.DataSource.DataSet, nil, 'X_Vychystano', False) do begin
            ReadOnly:= False;
            FieldName:= 'X_Vychystano';
            FieldKind:= fkData;
          end;
          iPreparePosition(1, 0, 2);
          mMGColVychystano:= TNxMultiGridColumn.Create(mMG.Owner);
          mMGColVychystano.FieldName := 'X_Vychystano';
          mMGColVychystano.Caption := '#Vychystáno';
          mMGColVychystano.ReadOnly := true;
          mMGColVychystano.Kind := ckText;
          mMGColVychystano.Elastic := false;
          mMGColVychystano.Width := 70;
          mMGColVychystano.Layout := 1;
          mMGColVychystano.Line := 0;
          mMGColVychystano.Order := 3;
          mMG.AddColumn(mMGColVychystano);
        end;
   end;



end;


begin
end.
