function GetQuantityB1(mOS:TNxCustomObjectSpace;const mStoreCard_Id:String):Extended;
var
  mStr : TStringList;
begin
  Result := 0;
  mStr := TStringList.Create;
  Try
    mOs.SQLSelect('select Quantity  from StoreSubCards where Store_ID = ''1000000101'' and StoreCard_id='''+ mStoreCard_Id+'''',mStr);
    if mStr.Count >0 then
      Result := StrToFloat(mStr.Strings(0))
    else Result := 0;
  finally
    mStr.Free;
  end;
end;

procedure actChangeStoreMaterial(Self: TBasicAction);
var
{ mControl: TControl;
 mDataSource: TDataSource;
 }
  mBo,mRow : TNxCustomBusinessObject;
  mRows : TNxCustomBusinessMonikerCollection;
  N : Integer;
begin
{    mControl:= NxFindChildControl(TdynSiteForm(Self.Owner).GetSiteAppForm, 'tabDetail');  //Získame control na ktorý budeme vytvárat náš prvok
    mControl:= NxFindChildControl(TWinControl(mControl), 'tabSubRows');
    mControl:= NxFindChildControl(TWinControl(mControl), 'pnSubRowsBottom');
    mDataSource:= TObjectComboEdit(NxFindChildControl(TWinControl(mControl), 'edSubRowStoreCard')).DataSource;
    mDataSource.DataSet.First;
    while not mDataSource.DataSet.Eof do begin
      mDataSource.DataSet.edit;
      mDataSource.DataSet.FieldValues['Store_ID']:= '1700000101';
      mDataSource.DataSet.post;
      mDataSource.DataSet.Next;
    end;
    mControl:= NxFindChildControl(TdynSiteForm(Self.Owner).GetSiteAppForm, 'tabDetail');  //Získame control na ktorý budeme vytvárat náš prvok
    mControl:= NxFindChildControl(TWinControl(mControl), 'tabSubRows');
    TTreeView(NxFindChildControl(TWinControl(mControl), 'vtSubRows')).Refresh;}
    
   mBo := TdynSiteForm(Self.Owner).CurrentObject;
   mRows := mBo.GetCollectionMonikerForFieldCode(mBO.GetFieldCode('ROWS'));
   for N := 0 to mRows.Count - 1 do begin
     mRow := mRows.BusinessObject(N);
     if mRow.GetFieldValueAsInteger('RowType') = 5 then begin
       if mRow.GetFieldValueAsFloat('Quantity') >= GetQuantityB1(mRow.ObjectSpace,mRow.GetFieldValueAsString('StoreCard_ID')) then
          mRow.SetFieldValueAsString('Store_ID','1700000101');
     end;
   end;
   mBo.Save;
   TdynSiteForm(Self.Owner).Refresh;
end;

procedure SetUpdate(Self: TBasicAction);
begin
 self.Enabled:= not TdynSiteForm(Self.Owner).Edit;
end;

procedure InitSite_Hook(Self: TSiteForm);
var
  mAct: TBasicAction;
begin

  mAct:= Self.GetNewAction;
  mAct.Name:= 'actChangeStoreMaterial';
  mAct.Caption:= 'Akt. sklad';
  mAct.Category:= 'tabDetail';
  mAct.OnUpdate := @SetUpdate;
  mAct.OnExecute:= @actChangeStoreMaterial;
end;
begin
end.