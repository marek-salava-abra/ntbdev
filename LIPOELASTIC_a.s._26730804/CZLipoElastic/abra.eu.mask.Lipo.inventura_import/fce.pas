
function ExistsDefFld(AOS: TNxCustomObjectSpace; ACLSID, AFldName: String): Boolean;
var
  mOHead: TNxHeaderBusinessObject;
  mORow: TNxCustomBusinessObject;
  mID: String;
  mRows: TNxCustomBusinessMonikerCollection;
  i: Integer;
  mFldName: string;
  s: string;
  mIsExtra: Boolean;
  ss: TStringList;
begin
  ss := TStringList.Create;
  try
    mFldName := AFldName;
    mIsExtra := True;
    if UpperCase(Copy(mFldName, 1, 2)) = 'X_' then
      mFldName := Copy(mFldName, 3, 255)
    else
    if UpperCase(Copy(mFldName, 1, 2)) = 'U_' then begin
      mFldName := Copy(mFldName, 3, 255);
      mIsExtra := False;
    end;
    AOS.SQLSelect('select ID from UserFieldDefs where CLSID = ''' + ACLSID + '''', ss);
    if ss.Count = 1 then
      mID := ss[0]
    else
      mID := '';
    Result := False;
    if mID <> '' then begin
      mOHead := TNxHeaderBusinessObject(AOS.CreateObject('W1MZBIJR3VF13JXR00KEZYD5AW')); //UserFieldDef
      mOHead.Load(mID, nil);
      mRows := mOHead.GetLoadedCollectionMonikerForFieldCode(mOHead.GetFieldCode('Rows'));
      for i:=0 to mRows.Count -1 do begin
        mORow := mRows.BusinessObject[i];
        if SameText(mORow.GetFieldValueAsString('FieldName'), mFldName) then begin
          Result := True;
          Break;
        end;
      end;
    end;
  finally
    ss.Free;
  end;
end;


procedure AddColToMultiGrid(AMultiGrid: TMultiGrid; AFieldName, ACaption: string;
  ADataType: TFieldType; AFieldKind: TFieldKind; ASize, AFieldNo: Integer; ARequired, AElastic: Boolean;
  AWidth: Integer; ALayouts, ALines: array of Integer; AOrder: Variant; AAfter: Boolean = True;
  ALookupProc: Pointer = nil; AIsRoll: Boolean = False; ATextField: String = '';
  AChangeFieldEvent: Pointer = nil);
var
  mMG: TMultiGrid;
  mFieldDef: TFieldDef;
  mField: TField;
  i, mLayout, mLine, mOrder: Integer;
  mMGCol: TNxMultiGridColumn;
  mMGColRoll: TNxMultiGridObjectRollColumn;
  mMGColBoolean: TNxMultiGridBooleanColumn;
  mMGColDate:TNxMultiGridDateColumn;
  mMGColLookup:TNxMultiGridLookupColumn;
  b: Boolean;
  mFieldName: String;
  mSite: TSiteForm;

  function iExistsLayout(AALayout: Integer): Boolean;
  begin
    Result := Assigned(mMG.Layouts(AALayout));
  end;

  function iLastOrderInLayout(AALayout, AALine: Integer): Integer;
  var
    ii: Integer;
  begin
    Result := 0;
    for ii:=0 to mMG.ColumnCount-1 do
      if (mMG.Columns[ii].Layout = AALayout) and (mMG.Columns[ii].Line = AALine) then
        if Result < mMG.Columns[ii].Order then
          Result := mMG.Columns[ii].Order;
  end;

  function iPreparePositionField(AALayout, AALine: Integer; AAOrder: Variant): Integer;
  var
    ii, jj: Integer;
    mmOrder, mmLine: Integer;
    mmValue: Variant;
  begin
    Result := 0;
    if VarType(AAOrder) in [varString, varOleStr] then
      if AAOrder = '' then begin
        if AAfter then
          Result := iLastOrderInLayout(AALayout, AALine)+1
        else
          Result := 0;
        EXIT;
      end;
    if VarType(AAOrder) in [varSmallint, varInteger, varByte, varShortInt] then begin
      Result := AAOrder;
      mmOrder := Result;
    end
    else begin
      mmOrder := -1;
      for ii:=mMG.ColumnCount-1 downto 0 do
        if (mMG.Columns[ii].Layout = AALayout) and (mMG.Columns[ii].Line = AALine) and
          (Pos(UpperCase(AAOrder), UpperCase(mMG.Columns[ii].FieldName)) > 0) then
          mmOrder := mMG.Columns[ii].Order;
    end;
    if mmOrder = -1 then
      EXIT;
    if AAfter then
      jj := 0
    else
      jj := -1;
    Result := mmOrder + 1 + jj;
    for ii:=mMG.ColumnCount-1 downto 0 do
      if (mMG.Columns[ii].Layout = AALayout) and (mMG.Columns[ii].Line = AALine) and
        (mMG.Columns[ii].Order > mmOrder + jj) then begin
        mMG.Columns[ii].Order := mMG.Columns[ii].Order + 1;
      end;
  end;

begin
  mMG := AMultiGrid;
  if Assigned(mMG) then begin
    mSite := NxFindSiteForm(mMG);
    if ((UpperCase(Copy(AFieldName, 1, 2)) = 'X_') or (UpperCase(Copy(AFieldName, 1, 2)) = 'U_')) and
       (AFieldKind <> fkCalculated) and not ExistsDefFld(mSite.BaseObjectSpace,
      TNxCustomObjectDataSet(mMG.DataSource.DataSet).GetBusinessObjectCLSID, AFieldName) then
      Exit;
    b := True;
    mFieldName := AFieldName;
    for i:=mMG.ColumnCount-1 downto 0 do
      if mMG.Columns[i].FieldName = mFieldName then
        b := False;
    if b then begin
      mMG.DataSource.DataSet.OnCalcFields := ALookupProc;
      if ADataType <> ftString then
        ASize := 0;
      mFieldDef := TFieldDef.Create(mMG.DataSource.DataSet.FieldDefs, mFieldName, ADataType, ASize, ARequired, AFieldNo);
      mField := mFieldDef.CreateField(mMG.DataSource.DataSet, nil, mFieldName, False);
      with mField do begin
        ReadOnly := False;
        FieldName := mFieldName;
        FieldKind := AFieldKind;
      end;
      mField.OnChange := AChangeFieldEvent;
      for mLayout:=VarArrayLowBound(ALayouts,1) to VarArrayHighBound(ALayouts,1) do begin
        if AFieldKind = fkLookup then begin
          mMGColLookup:= (TNxMultiGridLookupColumn.Create(mMG.Owner));
        end
        else
          case ADataType of
            ftDateTime, ftDate:
              mMGColDate:= (TNxMultiGridDateColumn.Create(mMG.Owner));
            ftBoolean:
              mMGColBoolean:= (TNxMultiGridBooleanColumn.Create(mMG.Owner));
            else
              if AIsRoll then begin
                mMGColRoll:= (TNxMultiGridObjectRollColumn.Create(mMG.Owner));
                TNxMultiGridObjectRollColumn(mMGColRoll).TextField := ATextField;
              end
              else
                mMGCol := TNxMultiGridColumn(TNxMultiGridColumn.Create(mMG.Owner));
          end;
        if assigned(mMGCol) and not(AIsRoll) then begin
        mMGCol.FieldName := mFieldName;
        mMGCol.Caption := ACaption;
        mMGCol.ReadOnly := False;
        mMGCol.Elastic := AElastic;
        mMGCol.Width := AWidth;
        mMGCol.Layout := ALayouts[mLayout];
        mMGCol.Line := ALines[mLayout];
        mMGCol.Order := iPreparePositionField(ALayouts[mLayout], ALines[mLayout], AOrder);
        mMGCol.Kind := ckText;
        mMG.AddColumn(mMGCol);
        end;
        if Assigned(mMGColDate) then begin
        mMGColDate.FieldName := mFieldName;
        mMGColDate.Caption := ACaption;
        mMGColDate.ReadOnly := False;
        mMGColDate.Elastic := AElastic;
        mMGColDate.Width := AWidth;
        mMGColDate.Layout := ALayouts[mLayout];
        mMGColDate.Line := ALines[mLayout];
        mMGColDate.Order := iPreparePositionField(ALayouts[mLayout], ALines[mLayout], AOrder);
        mMG.AddColumn(mMGColDate);
        end;
        if Assigned(mMGColRoll) and AIsRoll then begin
        mMGColRoll.FieldName := mFieldName;
        mMGColRoll.Caption := ACaption;
        mMGColRoll.ReadOnly := False;
        mMGColRoll.Elastic := AElastic;
        mMGColRoll.Width := AWidth;
        mMGColRoll.Layout := ALayouts[mLayout];
        mMGColRoll.Line := ALines[mLayout];
        mMGColRoll.Order := iPreparePositionField(ALayouts[mLayout], ALines[mLayout], AOrder);
        mMGColRoll.Kind := ckUser;
        mMGColRoll.ClassID:=('C2BQY04KTVDL342W01C0CX3FCC');
        mMG.AddColumn(mMGColRoll);
        //mMGColRoll.Free;
        end;
        if Assigned(mMGColBoolean) then begin
        mMGColBoolean.FieldName := mFieldName;
        mMGColBoolean.Caption := ACaption;
        mMGColBoolean.ReadOnly := False;
        mMGColBoolean.Elastic := AElastic;
        mMGColBoolean.Width := AWidth;
        mMGColBoolean.Layout := ALayouts[mLayout];
        mMGColBoolean.Line := ALines[mLayout];
        mMGColBoolean.Order := iPreparePositionField(ALayouts[mLayout], ALines[mLayout], AOrder);
        mMGColBoolean.Kind := ckCombo;
        mMG.AddColumn(mMGCol);
        end;
        if Assigned(mMGColLookup) then begin
        mMGColLookup.FieldName := mFieldName;
        mMGColLookup.Caption := ACaption;
        mMGColLookup.ReadOnly := False;
        mMGColLookup.Elastic := AElastic;
        mMGColLookup.Width := AWidth;
        mMGColLookup.Layout := ALayouts[mLayout];
        mMGColLookup.Line := ALines[mLayout];
        mMGColLookup.Order := iPreparePositionField(ALayouts[mLayout], ALines[mLayout], AOrder);
        mMGColLookup.Kind := ckLookup;
        mMG.AddColumn(mMGColLookup);
        end;
        {if AIsRoll then
          mMGColRoll.Kind := ckUser
        else
        if AFieldKind = fkLookup then
          mMGCol.Kind := ckLookup
        else
        if ADataType = ftBoolean then
          mMGCol.Kind := ckCombo
        else
          mMGCol.Kind := ckText; }

      end;
    end;
  end;
end;


begin
end.