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
  mMG := TMultiGrid(NxFindChildControl(Self.GetSiteAppForm, 'grdRows'));
  if Assigned(mMG) then begin
    b := True;
    for i:=mMG.ColumnCount-1 downto 0 do
      if mMG.Columns[i].FieldName = 'X_BusOrder_ID' then
        b := False;
    if b then begin
      mFieldDef := TFieldDef.Create(mMG.DataSource.DataSet.FieldDefs, 'X_BusOrder_ID', ftWideString, 0, False, 104);
      with mFieldDef.CreateField(mMG.DataSource.DataSet, nil, 'X_BusOrder_ID2', False) do begin
        ReadOnly:= False;
        FieldName:= 'X_BusOrder_ID';
        FieldKind:= fkData;
      end;
      iPreparePosition(3, 0, 4);
      mMGColRoll:= (TNxMultiGridObjectRollColumn.Create(mMG.Owner));
      mMGColRoll.FieldName := 'X_BusOrder_ID';
      mMGColRoll.Caption := 'Provize OZ';
      mMGColRoll.ReadOnly := False;
      mMGColRoll.Kind := ckText;
      mMGColRoll.Elastic := True;
      mMGColRoll.Width := 70;
      mMGColRoll.Layout := 3;
      mMGColRoll.Line := 1;
      mMGColRoll.Order := 4;
      mMGColRoll.Kind := ckUser;
      mMGColRoll.ClassID:=('03OXHKRF4VD13ACL03KIU0CLP4');
      mMGColRoll.TextField:='Code';
      mMG.AddColumn(mMGColRoll);
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
