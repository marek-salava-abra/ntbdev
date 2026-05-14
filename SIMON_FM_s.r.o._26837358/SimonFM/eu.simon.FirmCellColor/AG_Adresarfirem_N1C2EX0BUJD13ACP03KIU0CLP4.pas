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
  mList:TStringList;
  mColor:boolean;
begin
  if Highlight then
    exit;
  mGrid := TDBGrid(Sender);
  mSite := TBusRollSiteForm(mGrid.Owner);
  if Assigned(mSite.CurrentObject) then  begin
   mList:=TStringList.create;
   msite.CurrentObject.objectspace.SQLSelect(format('select first 1 statuscode from unRELIABLEFIRMLOGFIRMS where firm_id=''%s'' order by LogDate$DATE desc',[msite.CurrentObject.oid]),mList);
   mColor:=false;
    if mlist.count>0 then begin
      if mlist.Strings[0]='3' then mColor:=true;
    end;

    if mColor then begin
      AFont.Color := clred;
      //AFont.Style:=[fsStrikeOut];
    end;
       // Background:= 16777215;
  end;
end;



begin
end.


{mList:=TStringList.create;
  mbo.ObjectSpace.SQLSelect(format('select first 1 statuscode from unRELIABLEFIRMLOGFIRMS where firm_id=''%s'' order by LogDate$DATE desc',[mbo.oid]),mList);
  mColor:=false;
  if mlist.count>0 then begin
    if mlist.Strings[0]='3' then mColor:=true;
  end;}
