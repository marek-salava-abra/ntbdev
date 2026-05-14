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
    //AFont.Color := mSite.CurrentObject.GetFieldValueAsInteger('Docqueue_id.X_Color');
    if mSite.CurrentObject.GetFieldValueAsInteger('GuarantyRepair')=2 then begin
         AFont.Color:=255;
    end;
    if mSite.CurrentObject.GetFieldValueAsInteger('ServiceDocState_ID.posindex')=20 then begin
         AFont.Color:=32768;
    end;

    if mSite.CurrentObject.GetFieldValueAsInteger('ServiceDocState_ID.posindex')>50 then begin
        AFont.Style:=[fsStrikeOut] ;
    end;

    if mSite.CurrentObject.GetFieldValueAsInteger('Docqueue_id.X_Color')> 0 then begin
        Background:= mSite.CurrentObject.GetFieldValueAsInteger('Docqueue_id.X_Color');
    end else begin

    end;
end;



begin
end.
