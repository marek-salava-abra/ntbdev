uses 'eu.abra.roeh.InvStoreBatches.Const',
     'eu.abra.roeh.InvStoreBatches.Lib';
(*     'eu.abra.roeh.InvStoreBatches.Frm';*)

{
Vyvolá se po pohybu na hlavním datasetu.
}
procedure _MainDatasetAfterScroll_Hook(Self: TDynSiteForm);
var i: Integer;
 mList: TActionList;
begin
    mList := Self.GetMainActionList;
    for i:=0 to mList.ActionCount -1 do
    begin
      if mList.Actions[i].Name = 'actImportInvProtocol' then begin
        try
          mList.Actions[i].Enabled := not Self.CurrentObject.GetFieldValueAsBoolean('Closed');
        except
          // zlobylo při mazání objektu
       end;
     end;
   end;
end;

procedure actImportInvProtocol(Self: TBasicAction);
var
  mSite : TSiteForm;
  mNewIDInventoryOverplus,mInventoryShortFall : String;
begin
  mSite := Self.Site;
  RunTerminalImport(TDynSiteForm(Self.Owner),mNewIDInventoryOverplus,mInventoryShortFall);
end;

(*
procedure dblClick(Sender: TObject);
var
   mDbGrid : TDBGrid;
   mDataSet: TNxDataDataSet;
   N : Extended;
   Res:Integer;
begin
    Repeat
//  N := StrToFloat(InputBox('Zadej množství','Počet','',nil));
    mDbGrid := TDBGrid(Sender);
    mDataSet:= TNxDataDataSet(mDbGrid.DataSource.DataSet);
    N := mDataSet.FieldByName('X_RealQuantity').AsFloat;
    Res:= InputForm(nil,N);
    if Res = mrOK then begin
      mDataSet.Edit;
      mDataSet.FieldByName('X_RealQuantity').AsFloat := N;
      mDataSet.Post;
      if not mDataSet.Eof then
         mDataSet.Next
      else Break;
    end;
   until Res <> mrOK;
end;               *)

procedure SetEditMode(Sender: TObject);
var
   mDbGrid : TDBGrid;
   mDataSet: TNxDataDataSet;
   mRow : TNxCustomBusinessObject;
   N :Integer;
begin
  mDbGrid := TDBGrid(Sender);
  mDataSet:= TNxDataDataSet(mDbGrid.DataSource.DataSet);
  mRow := TNxCustomObjectDataSet(mDataSet).ActiveObject;
  for N := 0 to mDbGrid.FieldCount- 1 do
    if mDbGrid.Fields[N].FieldName = 'X_RealQuantity' then begin
         mDbGrid.Fields[N].ReadOnly:= mRow.GetFieldValueAsBoolean('Parent_Id.Closed') or
         (mRow.GetFieldValueAsBoolean('Parent_Id.X_MiniInv'));
         Break;
    end;
  for N := 0 to mDbGrid.Columns.Count - 1 do
    if mDbGrid.Columns.Items[N].FieldName = 'X_RealQuantity' then begin
         mDbGrid.Columns.Items[N].ReadOnly:= mRow.GetFieldValueAsBoolean('Parent_Id.Closed') or
         (mRow.GetFieldValueAsBoolean('Parent_Id.X_MiniInv'));
         // TColumn(DbGrid.Columns.Items[N]).
         Break;
    end;
end;

procedure actCLInventura(Self: TMultiAction;Index: integer);
var
  mStr : tStringList;
  N : Integer;
  mBo : TNxCustomBusinessObject;
begin
  mStr :=tStringList.Create;
  try
    Self.Site.List.GetSelectedId(mStr);
    for N := 0 to mStr.Count - 1 do begin
      mBo := Self.Site.BaseObjectSpace.CreateObject(Class_PartialInvProtocol);
      try
        mBo.Load(mStr.Strings[N],nil);
        if not mBo.GetFieldValueAsBoolean('Closed') then begin
          if not mBo.GetFieldValueAsBoolean('X_MiniInv') then
            case Index of
             0: CompleteBatches(mBo);
             1: ClearRowsBatches(mBo);
            end;
        end else
          NxShowSimpleMessage('Protokol '+mBo.DisplayName+ ' je uzařen, nelze měnit stav šarží!',TForm(self.Site));
      finally
        mBo.Free;
      end;
    end;
  finally
    mStr.Free;
  end;
end;


procedure InitSite_Hook(Self: TSiteForm);
var
  mAction: TAction;
  mMultiAction: TMultiAction;
  mDbGrid : TDBGrid;
  mFieldDef: TFieldDef;
  mField: TField;
  mGridColumn: TColumn;
  mDataSet: TNxDataDataSet;
begin
  mAction := Self.GetNewAction;
  mAction.Name := 'actImportInvProtocol';
  mAction.Category := 'tabRows';
  mAction.Caption := 'Načti ze čtečky VO';
  mAction.Hint := 'Spustí úlohu na import Inventury z ICS';
  mAction.ShowControl := True;
  mAction.OnExecute := @actImportInvProtocol;
  mAction.Enabled := false;

  if GetFirstRecordFromSQL(Self.BaseObjectSpace,'select X_Storeadmin from SecurityUsers where id ='''+NxGetActualUserID(Self.BaseObjectSpace)+'''') = 'A' then begin
    mMultiAction:= self.GetNewMultiAction;
    mMultiAction.Name := 'actCLInventura';
    mMultiAction.Category := 'tabList';
    mMultiAction.Caption := 'Doplní šarže';
    mMultiAction.Items.Add('Doplní šarže');
    mMultiAction.Items.Add('Odstraní šarže');
    mMultiAction.Hint := 'Doplnění/ostranění šarží';
    mMultiAction.ShowControl := True;
    mMultiAction.OnExecuteItem:= @actCLInventura;
    mMultiAction.Enabled := true;
  end;

   mDbGrid := TDBGrid(Self.FindChildControl('grdRows')); //2DBGrid
  // mDbGrid.OnDblClick := @dblClick;
   mDataSet:= TNxDataDataSet(mDbGrid.DataSource.DataSet);
   mdbGrid.OnEnter := @SetEditMode;

   mFieldDef := TFieldDef.Create(mDataSet.FieldDefs, 'X_RealQuantity', ftFloat, 0, False, 300002);

   mField := mFieldDef.CreateField(mDataSet, nil, 'X_RealQuantity', False);
   mField.ReadOnly := False;

   //mField.Size := 10;
   mField.FieldKind:=  fkData;
   mField.FieldName := 'X_RealQuantity';


   mGridColumn:= mDbGrid.Columns.Add;
   mGridColumn.FieldName := 'X_RealQuantity';
   mGridColumn.ReadOnly := false;
   mGridColumn.Title.Caption := 'Nal. množství';
   mGridColumn.Width := 64;

end
;
begin
end.