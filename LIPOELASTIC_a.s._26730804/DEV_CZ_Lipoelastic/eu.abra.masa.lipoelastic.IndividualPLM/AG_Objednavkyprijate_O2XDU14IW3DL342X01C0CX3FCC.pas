uses '.const';

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

  {  if Assigned(mMG) then begin
   // AddColToMultiGrid(mMG, 'X_StoreBatch_ID', 'Šarže', ftWideString, fkData,
   //   10, 900001, False, False, 80, [3], [0], 'IncomeType_ID', True, nil, True, 'Name');
   // AddColToMultiGrid(mMG, 'X_barva', 'Barva', ftWideString, fkData,
   //   10, 900002, False, False, 80, [3], [0], 'X_StoreBatch_ID', True, nil);

    //      AddColToMultiGrid(mMG, 'X_StoreBatch_ID', 'Šarže', ftString, fkData,
    //  10, 307, False, False, 80, [3], [0], 'IncomeType_ID', True, nil, True, 'Name');
    //AddColToMultiGrid(mMG, 'X_barva', 'Barva', ftString, fkData,
     // 10, 308, False, False, 80, [3], [0], 'X_StoreBatch_ID', True, nil);

  end;  }

end;



{
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
          mMGCol := TNxMultiGridColumn(TNxMultiGridLookupColumn.Create(mMG.Owner));
        end
        else
          case ADataType of
            ftDateTime, ftDate:
              mMGCol := TNxMultiGridColumn(TNxMultiGridDateColumn.Create(mMG.Owner));
            ftBoolean:
              mMGCol := TNxMultiGridColumn(TNxMultiGridBooleanColumn.Create(mMG.Owner));
            else
              if AIsRoll then begin
                mMGCol := TNxMultiGridColumn(TNxMultiGridCustomRollColumn.Create(mMG.Owner));
                TNxMultiGridCustomRollColumn(mMGCol).TextField := ATextField;
              end
              else
                mMGCol := TNxMultiGridColumn(TNxMultiGridColumn.Create(mMG.Owner));
          end;
        mMGCol.FieldName := mFieldName;
        mMGCol.Caption := ACaption;
        mMGCol.ReadOnly := False;
        if AIsRoll then
          mMGCol.Kind := ckUser
        else
        if AFieldKind = fkLookup then
          mMGCol.Kind := ckLookup
        else
        if ADataType = ftBoolean then
          mMGCol.Kind := ckCombo
        else
          mMGCol.Kind := ckText;
        mMGCol.Elastic := AElastic;
        mMGCol.Width := AWidth;
        mMGCol.Layout := ALayouts[mLayout];
        mMGCol.Line := ALines[mLayout];
        mMGCol.Order := iPreparePositionField(ALayouts[mLayout], ALines[mLayout], AOrder);;
        mMG.AddColumn(mMGCol);
      end;
    end;
  end;
end;

Procedure SetBackgroundColor(Sender : TObject; AColumn: TNxMultiGridCustomColumn; const AIndex: Integer; const AMultiSelect: Boolean; const ASelectedActiveRow: Boolean; var ABckColor: TColor);
Var
   mDataSetList: TDataSet;
   mDataSetRows: TDataSet;
   ColorS, mSQL1: String;
   Color: Integer;
   mSite: TSiteForm;
   mGrdList: TMultiGrid;
   mPriceList: TStringList;
   mPrice,mDateCheck:Extended;
begin
   //NxShowSimpleMessage(AColumn.Name,nil);
    if AColumn.Name = 'colElvinTyp' then
//   if AColumn.Name = 'colStore_ID' then
   begin
      mDataSetRows:= AColumn.Grid.DataSource.DataSet;
      if (mDataSetRows.FieldByName('X_ElvinTyp_ID').AsString = '1030000101') then ABckColor:=RGBToColor(255,102,102);   //2
      if (mDataSetRows.FieldByName('X_ElvinTyp_ID').AsString = '3030000101') then ABckColor:=RGBToColor(255,163,26);;   //3
      if (mDataSetRows.FieldByName('X_ElvinTyp_ID').AsString = '2030000101') then ABckColor:=RGBToColor(51,255,153);;   //5

   end;
   if AColumn.Name = 'colBusTransaction3' then begin
      if (mDataSetRows.FieldByName('DeliveredQuantity').AsFloat>0) and (mDataSetRows.FieldByName('DeliveredQuantity').AsFloat<mDataSetRows.FieldByName('UnitQuantity').AsFloat)
        then ABckColor:=RGBToColor(255,102,102);

   end;
end;

function RGBToColor(const R, G, B: Byte): Integer;
begin
	  Result := R or (G shl 8) or (B shl 16);
end;  }

{
Vyvolává se po provedení inicializace agendy/formuláře. V tento okamžik je již na formuláři dostupný SiteContext.

procedure InitSite_Hook(Self: TSiteForm);
var mGrdRows: TMultiGrid;
 i:Integer;
 mText:string;
begin
    mGrdRows:= TMultiGrid(NxFindChildControl(Self, 'grdRows'));
    //mGrdRows.OnGetBackgroundColor:= @SetBackgroundColor;
end;
}

begin
end.
