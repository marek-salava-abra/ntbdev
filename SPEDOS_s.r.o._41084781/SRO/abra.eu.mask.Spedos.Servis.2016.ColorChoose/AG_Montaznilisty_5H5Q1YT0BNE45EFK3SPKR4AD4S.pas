//barva řádku
procedure _InitSelf_PostHook(Self: TSiteForm);
var
  mGrid: TDBGrid;
begin
  mGrid := TDBGrid(NxFindChildControl(Self.GetSiteAppForm, 'grdList'));
  if Assigned(mGrid) then begin
    mGrid.OnGetCellParams := @OnGetCellParams;
  end;
end;

procedure OnGetCellParams(Sender: TObject; Field: TField; AFont: TFont; var Background: TColor; Highlight: Boolean);
var
  mGrid: TDBGrid;
  mDS: TNxCustomObjectDataSet;
  mAO: TNxCustomBusinessObject;
  mContext: TNxContext;
  mSite: TDynSiteForm;
begin
  if Highlight then
    exit;
  mGrid := TDBGrid(Sender);
  mSite := TDynSiteForm(mGrid.Owner);
  if Assigned(mSite.CurrentObject) then
    if not NxIsEmptyOID(msite.CurrentObject.GetFieldValueAsString('ServiceDocument_ID.BusProject_ID')) then begin
        Background:=1676767;
    end;
    //AFont.Color := mSite.CurrentObject.GetFieldValueAsInteger('Docqueue_id.X_Color');
    if mSite.CurrentObject.GetFieldValueAsInteger('ServiceDocument_ID.GuarantyRepair')=2 then begin
         AFont.Color:=255;
    end;
    if (mSite.CurrentObject.GetFieldValueAsInteger('X_State.X_PosIndex')>=15) and
       (mSite.CurrentObject.GetFieldValueAsInteger('X_State.X_PosIndex')<=50)
    then begin
         AFont.Color:=32768;
    end;

    if mSite.CurrentObject.GetFieldValueAsInteger('X_State.X_PosIndex')>=60 then begin
        AFont.Style:=[fsStrikeOut] ;
    end;

//    if mSite.CurrentObject.GetFieldValueAsInteger('ServiceDocument_ID.Docqueue_id.X_Color')> 0 then begin
//        Background:= mSite.CurrentObject.GetFieldValueAsInteger('ServiceDocument_ID.Docqueue_id.X_Color');
//    end else begin
//
//    end;
end;



begin
end.
