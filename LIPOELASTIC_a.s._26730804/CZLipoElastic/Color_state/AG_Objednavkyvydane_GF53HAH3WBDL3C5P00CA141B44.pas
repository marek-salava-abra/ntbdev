//barva řádku
procedure _InitSelf_PostHook(Self: TSiteForm);
var
  mGrid: TDBGrid;
begin
  mGrid := TDBGrid(NxFindChildControl(Self.GetSiteAppForm, 'grdList'));
      if self.CompanyCache.GetUserID='SUPER00000' then begin
              if Assigned(mGrid) then begin
                mGrid.OnGetCellParams := @OnGetCellParams;
              end;
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
 // if Highlight then
 //   exit;
  mGrid := TDBGrid(Sender);
  mSite := TDynSiteForm(mGrid.Owner);
  if Assigned(mSite.CurrentObject) then
   if not NxIsEmptyOID(mSite.CurrentObject.GetFieldValueAsString('PMState_ID')) then begin
        if mSite.CurrentObject.GetFieldValueAsInteger('PMState_ID.Color')<>0 then Background:= mSite.CurrentObject.GetFieldValueAsInteger('PMState_ID.Color');
        if mSite.CurrentObject.GetFieldValueAsInteger('PMState_ID.X_Font_color')<>0 then AFont.Color := mSite.CurrentObject.GetFieldValueAsInteger('PMState_ID.X_Font_color');
      //  if mSite.CurrentObject.GetFieldValueAsString('PMState_ID.X_FontStyle')<>'' then AFont.Style:=mSite.CurrentObject.GetFieldValueAsString('PMState_ID.X_FontStyle') ;
    end;

end;



begin
end.
