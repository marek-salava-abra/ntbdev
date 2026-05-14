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
          mOLE, mRoll, mOResult: Variant;
    mids:tstringlist;


procedure SPExecuteItem(Sender: TAction; Index: integer);
var
 mresult:Boolean;
 mtext:string;
 mImportMan:TNxDocumentImportManager;
 mbo:TNxCustomBusinessObject;
 mSite: TSiteForm;
  mDBGrid : TDBGrid;
    mTabList: TTabSheet;
  self:TNxCustomBusinessObject;
  i,ii:integer;
  mr,mIDs_MLRow:TStringList;
   mForm: TRollSiteForm;
   mMon: TNxCustomBusinessMonikerCollection;
   mRow, mNewRow,mbo1: TNxCustomBusinessObject;
   mdate:Double;
begin
    mSite := NxFindSiteForm(TComponent(Sender));
    mTabList := TTabSheet(NxFindChildControl(mSite.MainPanel, 'tabServiceDocs'));
    if mTabList = nil then RaiseException('tabList nenalezen');
    mDBGrid := TDBGrid(NxFindChildControl(mTabList, 'grdAssembyForms'));
    if mDBGrid = nil then RaiseException('DBGrid nenalezen');
    mBookmark := mDBGrid.SelectedRows; // *** v mBookmark jsou id označených záznamu
      if mBookmark.count=0 then begin
          //mBO := TBusRollSiteForm(mSite).CurrentObject;
      end else begin
          for i := 0 to mBookmark.Count-1 do begin // projdu vsechny oznacene zaznamy
                  mDBGrid.DataSource.DataSet.GotoBookmark(mBookMark.items(i));
          //        mBO := TBusRollSiteForm(mSite).CurrentObject;
                  NxShowSimpleMessage(mBookMark.items(i),nil);
          end;
      end;
 TBusRollSiteForm(mSite).RefreshData;
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
{


   mMAction := Self.GetNewMultiAction;
  mMAction.ShowControl := True;
  mMAction.ShowMenuItem := True;
  mMAction.Caption := 'Protokol';
  mMAction.Hint := 'Zobrazí připojené protokoly';
  mMAction.Category := 'tabServiceDocs';
  mMAction.OnExecuteItem := @SPExecuteItem;
  mMAction.Items.Add('Protokol');
     }

end;


begin
end.