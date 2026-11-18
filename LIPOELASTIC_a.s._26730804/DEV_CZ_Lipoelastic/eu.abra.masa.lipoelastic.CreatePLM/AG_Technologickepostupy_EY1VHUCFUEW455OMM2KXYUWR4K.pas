
procedure _InitSelf_PostHook(Self: TSiteForm);
var
  mMG: TMultiGrid;
  mFieldDef: TFieldDef;
  i,j, mLayout, mLine, mOrder: Integer;
  mMGCol: TNxMultiGridLookupColumn;
  b: Boolean;
  mValueList:TStringList;
  mName, mValueString:string;
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
  mName := 'label_type';
  if Assigned(mMG) then begin
    b := True;
    for i:=mMG.ColumnCount-1 downto 0 do
      if mMG.Columns[i].FieldName = 'X_'+mName then
        b := False;
    if b then begin
      mValueList:=TStringList.Create;
      mValueList.clear;
      mFieldDef := TFieldDef.Create(mMG.DataSource.DataSet.FieldDefs, 'X_'+mName, ftInteger, 0, False, 301);
      with mFieldDef.CreateField(mMG.DataSource.DataSet, nil, 'X_'+mName, False) do begin
        ReadOnly:= False;
        FieldName:= 'X_'+mName;
        FieldKind:= fkData;
      end;
      iPreparePosition(0, 0, 15);
      mMGCol := TNxMultiGridLookupColumn.Create(mMG.Owner);
      mValueString:=self.BaseObjectSpace.SQLSelectFirstAsString('select enumeration from userfieldDefs2 where fieldname='+quotedstr(mName)+' and parent_id='+QuotedStr('1830000101'));
      mValueList.Text:=mValueString;
      for j:=0 to mValueList.Count-1 do begin
       mMGCol.Values.add(mValueList.Strings[j]+'='+IntToStr(j))
      end;
      mMGCol.FieldName := 'X_'+mName;
      mMGCol.Caption := 'Za tento krok etiketu';
      mMGCol.ReadOnly := False;
      mMGCol.Kind := ckCombo;
      mMGCol.Elastic := True;
      mMGCol.Width := 80;
      mMGCol.Layout := 0;
      mMGCol.Line := 0;
      mMGCol.Order := 15;
      mMG.AddColumn(mMGCol);
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

function FindColumnByFieldName2(AMG: TMultiGrid; AFieldName: String): TNxMultiGridColumn;
var
  i: Integer;
begin
  Result := nil;
  if Assigned(AMG) then
    for i:=AMG.ColumnCount-1 downto 0 do
      if AMG.Columns[i].FieldName = AFieldName then
        Result := TNxMultiGridColumn(AMG.Columns[i]);
end;


begin
end.
