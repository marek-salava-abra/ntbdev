uses
  '.const';

procedure _InitSelf_PostHook(Self: TSiteForm);
var
  mMG: TMultiGrid;
  mFieldDef: TFieldDef;
  i, mLayout, mLine, mOrder: Integer;
  mMGCol: TNxMultiGridColumn;
  mMGCol2: TNxMultiGridBooleanColumn;
  mMGColRoll: TNxMultiGridObjectRollColumn;
  b: Boolean;
  mAllowed:TStringList;
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
    mAllowed:=TStringList.Create;
    self.BaseObjectSpace.SQLSelect('Select sc.id from storecards sc left join storecardcategories scc on scc.id=sc.storecardcategory_id where sc.hidden=''N'' '+cSQL_X_Aktivni+' and scc.code=''#PL'' ',mAllowed);
    b := True;
    for i:=mMG.ColumnCount-1 downto 0 do
      if mMG.Columns[i].FieldName = 'X_PL_StoreCard_ID' then
        b := False;
    if b then begin
      mFieldDef := TFieldDef.Create(mMG.DataSource.DataSet.FieldDefs, 'X_PL_StoreCard_ID', ftWideString, 0, False, 002);
      with mFieldDef.CreateField(mMG.DataSource.DataSet, nil, 'X_PL_StoreCard_ID', False) do begin
        ReadOnly:= False;
        FieldName:= 'X_PL_StoreCard_ID';
        FieldKind:= fkData;
      end;
      iPreparePosition(3, 1, 16);
      mMGColRoll:= (TNxMultiGridObjectRollColumn.Create(mMG.Owner));
      mMGColRoll.FieldName := 'X_PL_StoreCard_ID';
      mMGColRoll.Name := 'colPrivateLabel';
      mMGColRoll.Caption := 'PrivateLabel';
      mMGColRoll.ReadOnly := False;
      mMGColRoll.Kind := ckText;
      mMGColRoll.Elastic := True;
      mMGColRoll.Width := 170;
      mMGColRoll.Layout := 3;
      mMGColRoll.Line := 1;
      mMGColRoll.Order := 16;
      mMGColRoll.Kind := ckUser;
      mMGColRoll.ClassID:=Roll_StoreCards;
      if mAllowed.count>0 then begin
       mMGColRoll.Parameters.clear;
       mMGColRoll.Parameters.Add('_Allowed='+mAllowed.DelimitedText);
      end;
      mMGColRoll.TextField:='Name';
      mMG.AddColumn(mMGColRoll);
    end;
  end;
end;

begin
end.