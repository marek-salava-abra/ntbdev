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
 //   if  not mSite.CurrentObject.GetFieldValueAsBoolean('X_Aktivni') then begin
 //       AFont.Color := 11711154;
 //       AFont.Style:=[fsStrikeOut] ;
 //   end;
  if Assigned(mSite.CurrentObject) then
    if  mSite.CurrentObject.GetFieldValueAsBoolean('X_Matka') then begin
        AFont.Color := 11363328;
        AFont.Style:=[fsbold] ;
    end;

end;



begin
end.
