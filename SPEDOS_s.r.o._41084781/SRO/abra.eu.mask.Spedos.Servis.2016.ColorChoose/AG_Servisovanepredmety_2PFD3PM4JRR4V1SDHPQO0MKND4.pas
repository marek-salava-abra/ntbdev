
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
    if not NxIsEmptyOID(msite.CurrentObject.GetFieldValueAsString('BusProject_ID')) then begin
        //AFont.Color:=32768;
        //AFont.style:=[fsBold]  ;
        Background:=1676767;
    end;
    if not NxIsEmptyOID(msite.CurrentObject.GetFieldValueAsString('Servicedocument_ID.BusProject_ID')) then begin
        //AFont.Color:=32768;
        //AFont.style:=[fsBold]  ;
        Background:=1676767;
    end;
    if not NxIsEmptyOID(msite.CurrentObject.GetFieldValueAsString('Parent_ID')) then begin
        AFont.style:=[fsStrikeOut]  ;
    end;

    if msite.CurrentObject.GetFieldValueAsDateTime('X_Dat_zaruka_elektro')>=trunc(now) then begin
       AFont.Color:=255;
    end;

    if (msite.CurrentObject.GetFieldValueAsDateTime('X_Dat_zaruka_elektro')<trunc(now)) and (msite.CurrentObject.GetFieldValueAsDateTime('X_Dat_zaruka_elektro')<>0) then begin
       AFont.Color:=32768;
    end;
//    AFont.Color := mSite.CurrentObject.GetFieldValueAsInteger('X_Color');
//    if mSite.CurrentObject.GetFieldValueAsInteger('X_Color')then begin
//        Background:= 16777215;
//    end else begin

//    end;
end;


begin
end.
