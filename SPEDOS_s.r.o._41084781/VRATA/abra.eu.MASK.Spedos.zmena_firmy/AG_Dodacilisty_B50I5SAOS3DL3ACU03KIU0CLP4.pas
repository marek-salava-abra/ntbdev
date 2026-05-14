//uses 'abra.eu.mask.Spedos.Servis.2016_funkce.funkce';

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

procedure FVExecuteItem(Sender: TAction; Index: integer);
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
   mi:integer;
   mid_office:string;
begin
    mSite := NxFindSiteForm(TComponent(Sender));
    mTabList := TTabSheet(NxFindChildControl(mSite.MainPanel, 'tabList'));
    if mTabList = nil then RaiseException('tabList nenalezen');
    mDBGrid := TDBGrid(NxFindChildControl(mTabList, 'grdList'));
    if mDBGrid = nil then RaiseException('DBGrid nenalezen');
    mBookmark := mDBGrid.SelectedRows; // *** v mBookmark jsou id označených záznamu
    mids:= TStringList.Create;

    try
         if index=0 then begin

              mOLE:= GetAbraOLEApplication;
              mOResult:= mOLE.CreateStrings;
              mRoll:= mOLE.GetRoll('O3OWQQYWYJCL3J0B01K0LEIOE0', 0);
              if not mRoll.multiselectdialog(true, mOResult) then Exit;
                mids.Text:= mOResult.Text;

                mr:=tstringlist.create;
                try
                      msite.baseobjectspace.SQLSELECT('Select max(id) from FirmOffices where Parent_ID= '+ quotedstr(mids.Strings[0])
                       ,mr);
                      if mr.count>0 then begin
                          mid_office:= mr.Strings[0];
                      end;
                finally
                     mr.free;
                end;
         end;

                    if not NxIsEmptyOID(mids.Strings[0]) then begin

                                    //mtext:=InputBox('Zadej číslo objednávky','Číslo objednávky','');

                                    if mBookmark.count=0 then begin
                                        mBO := TDynSiteForm(mSite).CurrentObject;
                                                        if index=0 then mi:=msite.BaseObjectSpace.SQLExecute('update Storedocuments set Firm_id=' + quotedstr(mids.Strings[0]) + ',FirmOffice_ID=' + quotedstr(mid_office)+' where id=' + quotedstr(mbo.oid));

                                    end else begin
                                        for i := 0 to mBookmark.Count-1 do begin // projdu vsechny oznacene zaznamy
                                                mDBGrid.DataSource.DataSet.GotoBookmark(mBookMark.items(i));
                                                mBO := TDynSiteForm(mSite).CurrentObject;
                                                        if index=0 then mi:=msite.BaseObjectSpace.SQLExecute('update Storedocuments set Firm_id=' + quotedstr(mids.Strings[0]) + ',FirmOffice_ID=' + quotedstr(mid_office)+' where id=' + quotedstr(mbo.oid));


                                        end;
                                    end;
                      end;
                 finally

      mids.free;
   end;
 TDynSiteForm(mSite).RefreshData;
end;



procedure InitSite_Hook(Self: TSiteForm);
var
mAction: TAction;
  mMAction: TMultiAction;
  mUserFilter: Boolean;
  mUser: TNxCustomBusinessObject;
begin
  if ((Self.CompanyCache.GetUserID='SUPER00000') or
      (Self.CompanyCache.GetUserID='2000000101') or
      (Self.CompanyCache.GetUserID='3300000101'))
   then begin
  mMAction := Self.GetNewMultiAction;
  mMAction.ShowControl := True;
  mMAction.ShowMenuItem := True;
  mMAction.Caption := 'Změna firmy';
  mMAction.Hint := 'Změna firmy';
  mMAction.Category := 'tabList';
  mMAction.OnExecuteItem := @FVExecuteItem;
  mMAction.Items.Add('Změna firmy');
  end;

end;


begin
end.