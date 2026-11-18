uses 'abra.eu.mask.2017.refresh_OP.libs';

var
    mFSazba_hod_den,mFDoprava_km,mF_doprava_pausal,mFSazba_hod:double;
    mBO_BusProject:TNxCustomBusinessObject;
    mF_pausal_prace,mF_pausal_Vyjezd,mF_prace,mF_km:double;
    // doby + termíny
    mF_doba:double;
    mRows : TNxCustomBusinessMonikerCollection;
    result:boolean;
    mresult:boolean;
    mBookmark : TBookmarkList;
    mBustrasaction_ID:string;

procedure mRefresh(Sender: TAction; Index: integer);
var
 mresult:Boolean;
 mtext:string;
 mbo:TNxCustomBusinessObject;
 mSite: TSiteForm;
 mDBGrid : TDBGrid;
 mTabList: TTabSheet;
 self:TNxCustomBusinessObject;
 i,ii:integer;
  mr,mIDs_MLRow:TStringList;
   mForm: TDynSiteForm;
   mMon: TNxCustomBusinessMonikerCollection;
   mRow, mNewRow,mbo1: TNxCustomBusinessObject;
   mdate:Double;
   mdoc_number:string;
   mcount:integer;
   mfile:string;
   mpath:string;
begin
  mSite := NxFindSiteForm(Sender);
    mTabList := TTabSheet(NxFindChildControl(mSite.MainPanel, 'tabList'));
    if mTabList = nil then
        RaiseException('tabList nenalezen');
    mDBGrid := TDBGrid(NxFindChildControl(mTabList, 'grdList'));
    if mDBGrid = nil then
        RaiseException('DBGrid nenalezen');
    mBookmark := mDBGrid.SelectedRows; // *** v mBookmark jsou id označených záznamu
    mbo:= TDynSiteForm(mSite).CurrentObject;

    if mBookmark.count=0 then begin
               //TDynSiteForm(mSite).CurrentObject);
                    mBO.SetFieldValueAsFloat('X_Quantity',getquantity(mBO));
                    mBO.SetFieldValueAsFloat('X_in_store',getinstore(mBO));
                    mBO.SetFieldValueAsFloat('X_Reservation',getreservation(mBO));
                    mBO.SetFieldValueAsFloat('X_Vychystano',getlogistic(mBO));
                    mBO.SetFieldValueAsFloat('X_delivered',getdelivered(mBO));
    end else begin
         for i := 0 to mBookmark.Count- 1 do begin
                          mDBGrid.DataSource.DataSet.GotoBookmark(mBookMark.items(i));
                          mBO:= TDynSiteForm(mSite).CurrentObject;
                          mBO.SetFieldValueAsFloat('X_Quantity',getquantity(mBO));
                          mBO.SetFieldValueAsFloat('X_in_store',getinstore(mBO));
                          mBO.SetFieldValueAsFloat('X_Reservation',getreservation(mBO));
                          mBO.SetFieldValueAsFloat('X_Vychystano',getlogistic(mBO));
                          mBO.SetFieldValueAsFloat('X_delivered',getdelivered(mBO));
         end;

    end;





end;




procedure InitSite_Hook(Self: TSiteForm);
var
mAction: TAction;
  mMAction: TMultiAction;
  mUserFilter: Boolean;
  mUser: TNxCustomBusinessObject;
begin
  mUserFilter:=false;
  mUser := Self.BaseObjectSpace.CreateObject('22AHIVDVAVE13C5S00CA141B44');            // přihlášený uživatel
  try
      mUser.Load(Self.CompanyCache.GetUserID, nil);
            if mUser.GetFieldValueAsString('Name')='Supervisor' then mUserFilter:= true;
  finally
    mUser.Free;
  end;
  {mmAction := Self.GetNewMultiAction;
  mmAction.ShowControl := True;
  mmAction.ShowMenuItem := True;
  mmAction.Caption := 'Aktualizace stavu objednávky';
  mmAction.Hint := 'Stav objednávky';
  mmAction.Category := 'tabList';
  mMAction.Items.Add('Aktualizace');
  mMAction.Items.Add('Rezervace');
  mMAction.Items.Add('Vychystání');
  mMAction.Items.Add('Expedice');

  mmAction.OnExecute:= @mRefresh;

   }

end;

begin
end.