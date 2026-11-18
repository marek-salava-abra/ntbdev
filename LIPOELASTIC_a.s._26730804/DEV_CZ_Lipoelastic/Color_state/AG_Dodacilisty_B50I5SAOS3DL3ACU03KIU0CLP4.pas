//barva řádku
procedure _InitSelf_PostHook(Self: TSiteForm);
var
  mGrid: TDBGrid;
  mUser: TNxCustomBusinessObject;
begin
  { mUser := Self.BaseObjectSpace.CreateObject('22AHIVDVAVE13C5S00CA141B44');            // přihlášený uživatel
    try
        mUser.Load(Self.CompanyCache.GetUserID, nil);
           if (mUser.GetFieldValueAsBoolean('X_funkce_ctecky')) then begin
                    mGrid := TDBGrid(NxFindChildControl(Self.GetSiteAppForm, 'grdList'));
                    if Assigned(mGrid) then begin
                      mGrid.OnGetCellParams := @OnGetCellParams;
                    end;
           end;
    finally
       mUser.free;
    end;}
end;

procedure OnGetCellParams(Sender: TObject; Field: TField; AFont: TFont; var Background: TColor; Highlight: Boolean);
var
  mGrid: TDBGrid;
  mDS: TNxCustomObjectDataSet;
  mAO: TNxCustomBusinessObject;
  mContext: TNxContext;
  mSite: TDynSiteForm;
  mcena:double;
begin
  if Highlight then
    exit;
  mGrid := TDBGrid(Sender);
  mSite := TDynSiteForm(mGrid.Owner);
  if Assigned(mSite.CurrentObject) then

       mcena:= (msite.BaseObjectSpace.SQLSelectFirstAsInteger('select sum(ZL.Amount - ZL.PaidAmount) from IssuedDInvoices ZL where ZL.Docqueue_ID<>' + quotedstr('47D2000101') + ' and (ZL.ReceivedOrder_ID in '
       + '(select distinct(ro.id) from storedocuments2 sd2 join Receivedorders RO on ro.id=sd2.Provide_ID where sd2.parent_ID=' + quotedstr(TDynSiteForm(msite).CurrentObject.oid) + '))'));
       if mcena>0 then begin
        Background:= 9736915;
    //    AFont.Color := mSite.CurrentObject.GetFieldValueAsInteger('PMState_ID.X_Font_color');
    //    AFont.Style:=[mSite.CurrentObject.GetFieldValueAsInteger('PMState_ID.X_FontStyle')] ;
        end;
end;



begin
end.


