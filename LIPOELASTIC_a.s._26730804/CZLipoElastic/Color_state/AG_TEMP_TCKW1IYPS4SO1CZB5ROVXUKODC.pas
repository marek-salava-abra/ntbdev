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
  mSite: TBusRollSiteForm;
begin
  if Highlight then
    exit;
  mGrid := TDBGrid(Sender);
  mSite := TBusRollSiteForm(mGrid.Owner);
  if Assigned(mSite.CurrentObject) then
    if not NxIsEmptyOID(mSite.CurrentObject.GetFieldValueAsString('X_PM_State')) then begin
        Background:= mSite.CurrentObject.GetFieldValueAsInteger('X_PM_State.Color');
        AFont.Color := mSite.CurrentObject.GetFieldValueAsInteger('X_PM_State.X_Font_color');
        AFont.Style:=[mSite.CurrentObject.GetFieldValueAsInteger('X_PM_State.X_FontStyle')] ;
    end;

end;



begin
end.
