var
  mColorDialog: TColorDialog;
  mButton: TButton;
  mPanel: TPanel;



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
  if Assigned(mSite.CurrentObject) then begin
   if NxGetActualUserID_1(mSite.CurrentObject) in ['1EYZ100101','1F10000101'] then begin
    if mSite.CurrentObject.GetFieldValueAsString('StoreCardCategory_ID.Code') = 'ML' then AFont.Color := clblue;
    if mSite.CurrentObject.GetFieldValueAsString('StoreCardCategory_ID.Code') = 'PV' then AFont.Color := clGreen;
   end;
  end;     // Background:= 16777215;

end;



begin
end.