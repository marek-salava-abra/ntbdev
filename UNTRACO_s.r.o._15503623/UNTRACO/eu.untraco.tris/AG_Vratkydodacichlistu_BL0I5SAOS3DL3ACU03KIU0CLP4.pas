

procedure _InitSelf_PostHook(Self: TSiteForm);
var
  mMG: TMultiGrid;
  mFieldDef: TFieldDef;
  i, mLayout, mLine, mOrder: Integer;
  mMGCol: TNxMultiGridBooleanColumn;
  mMGCol2:TNxMultiGridCustomColumn;
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
      if mMG.Columns[i].FieldName = 'X_ConfirmedQuantity' then
        b := False;
    if b then begin
      mFieldDef := TFieldDef.Create(mMG.DataSource.DataSet.FieldDefs, 'X_ConfirmedQuantity', ftFloat, 0, False, 309);
      with mFieldDef.CreateField(mMG.DataSource.DataSet, nil, 'X_ConfirmedQuantity', False) do begin
        ReadOnly:= True;
        FieldName:= 'X_ConfirmedQuantity';
        FieldKind:= fkData;
      end;
      iPreparePosition(3, 0, 22);
      mMGCol2 := TNxMultiGridCustomColumn.Create(mMG.Owner);
      mMGCol2.FieldName := 'X_ConfirmedQuantity';
      mMGCol2.Caption := 'Potvr. množství';
      mMGCol2.ReadOnly := True;
      //mMGCol.Kind := ck;
      mMGCol2.Elastic := True;
      mMGCol2.Width := 100;
      mMGCol2.Layout := 3;
      mMGCol2.Line := 0;
      mMGCol2.Order := 22;
      mMG.AddColumn(mMGCol2);


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

procedure _AfterCloneRec_Hook(Self: TDynSiteForm);
var
 mRows:TNxCustomBusinessMonikerCollection;
 i:integer;
begin
  self.CurrentObject.SetFieldValueAsBoolean('X_TrisExported',false);
  self.CurrentObject.SetFieldValueAsBoolean('X_ToTris',false);
  self.CurrentObject.SetFieldValueAsInteger('X_TrisState',0);
  mRows:=self.CurrentObject.GetLoadedCollectionMonikerForFieldCode(self.CurrentObject.GetFieldCode('Rows'));
  for i:=0 to mrows.count-1 do begin
    mrows.BusinessObject[i].SetFieldValueAsFloat('X_ConfirmedQuantity',0);
  end;
  Self.ActiveDataSet.RefreshCurrentItem;
end;


begin
end.
