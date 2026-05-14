function RGBToColor(const R, G, B: Byte): Integer;
begin
	  Result := R or (G shl 8) or (B shl 16);
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
  mDS := TNxCustomObjectDataSet(mGrid.DataSource.DataSet);
  if mDS.EOF then
    exit;
  mAO := mDS.ActiveObject;
  if Assigned(mAO) then begin
     if mAO.GetFieldValueAsBoolean('U_dobra') then
      Background := clGreen;
     if mAO.GetFieldValueAsBoolean('U_spatna') then
      Background := clRed;
  end;
end;

{
Vyvolává se po vytvoření instance formuláře.
}
procedure FormCreate_Hook(Self: TSiteForm);
//procedure _InitSelf_PostHook(Self: TSiteForm);
var
  mGrid: TDBGrid;
  mControl: tControl;
begin
    mControl := NxFindChildControl (Self, 'pnSite');
    {mControl := NxFindChildControl (TWinControl(mControl), 'pgcDataViews');
    mControl := NxFindChildControl (TWinControl(mControl), 'tabList');
    mControl := NxFindChildControl (TWinControl(mControl), 'pnListMain'); }
    mControl := NxFindChildControl (TWinControl(mControl), 'pnList');
   if  Assigned(mcontrol)  then begin
      mControl := NxFindChildControl (TWinControl(mControl), 'grdList');
     if  Assigned(mControl)  then begin
       mGrid := TDBGrid(mControl);
       if Assigned(mGrid) then begin
         //mGrid.DefaultDrawing:=false;
         //if mGrid.DataSource.DataSet.FieldByName('ID').AsString = cOID then
         mGrid.OnGetCellParams := @OnGetCellParams; //Params;
       end;
     end;
   end;
end;

begin
end.
