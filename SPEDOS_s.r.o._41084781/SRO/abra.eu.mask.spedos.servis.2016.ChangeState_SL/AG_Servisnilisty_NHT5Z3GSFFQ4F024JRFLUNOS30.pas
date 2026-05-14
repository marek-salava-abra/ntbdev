var
    mBO_BusProject:TNxCustomBusinessObject;
    mF_doba:double;
    mRows : TNxCustomBusinessMonikerCollection;
    result:boolean;
    mresult:boolean;
      mBookmark : TBookmarkList;
      morigstate,mstate:string;
      mpotvrzeni:string;

procedure FVExecuteItem(Sender: TAction; Index: integer);
var
 mresult:Boolean;
 mtext:string;
 mbo:TNxCustomBusinessObject;
 mbo_SL:TNxCustomBusinessObject;
 mSite: TDynSiteForm;
  mDBGrid : TDBGrid;
    mTabList: TTabSheet;
  self:TNxCustomBusinessObject;
  i,ii:integer;
  mr,mr1,mr2,mIDs_MLRow:TStringList;
   mForm: TDynSiteForm;
   mMon: TNxCustomBusinessMonikerCollection;
   mRow, mNewRow,mbo1: TNxCustomBusinessObject;
   mdate:Double;
   mr_technik,mr_material:tstringlist;
   mr_ML:tstringlist;
   mOLE, mRoll, mOResult: Variant;
   mids:TStringList;
   mBO_nabidka:TNxCustomBusinessObject;
   mNabidka_ID:string;
   mstavpomoc:boolean;
   mobjednavka:string;
   mr_sum:TStringList;
   mstav_rozprac:string;
   mi:integer;
begin
    mstavpomoc:=false;
    mSite := TComponent(Sender).DynSite;
    mTabList := TTabSheet(NxFindChildControl(mSite.MainPanel, 'tabList'));
    if mTabList = nil then RaiseException('tabList nenalezen');
    mDBGrid := TDBGrid(NxFindChildControl(mTabList, 'grdList'));
    if mDBGrid = nil then RaiseException('DBGrid nenalezen');
    mBookmark := mDBGrid.SelectedRows; // *** v mBookmark jsou id označených záznamu
          mOLE:= GetAbraOLEApplication;
          mOResult:= mOLE.CreateStrings;
              mRoll:=mOLE.GetRoll('P0WSJWX1GOHOBI2DGLTE1LMEHK', 0);
              if not mRoll.multiSelectDialog(true,mOResult) then Exit;
                mstate:=copy(mOResult.Text,1,10);
                try
                        mBO := TDynSiteForm(mSite).CurrentObject;
                        if mBookmark.count=0 then begin
                              mi:=msite.BaseObjectSpace.SQLExecute('update ServiceDocuments set ServiceDocState_ID=' + quotedstr(mstate) + ' where id=' +quotedstr(mbo.oid));
                        end else begin
                           for i := 0 to mBookmark.Count-1 do begin // projdu vsechny oznacene zaznamy
                                    mDBGrid.DataSource.DataSet.GotoBookmark(mBookMark.items(i));
                                    mBO := TDynSiteForm(mSite).CurrentObject;
                                    mi:=msite.BaseObjectSpace.SQLExecute('update ServiceDocuments set ServiceDocState_ID=' + quotedstr(mstate) + ' where id=' +quotedstr(mbo.oid));

                           end;
                        end;
               finally
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
  mUserFilter:=false;
  mUser := Self.BaseObjectSpace.CreateObject('22AHIVDVAVE13C5S00CA141B44');            // přihlášený uživatel
  try
      mUser.Load(Self.CompanyCache.GetUserID, nil);
            if mUser.GetFieldValueAsString('Name')='Supervisor' then mUserFilter:= true;
  finally
    mUser.Free;
  end;
  mMAction := Self.GetNewMultiAction;
  mMAction.ShowControl := True;
  mMAction.ShowMenuItem := True;
  mMAction.Caption := 'Hromadná změna stavu';
  mMAction.Hint := 'Hromadná změna stavu';
  mMAction.Category := 'tabList';
  mMAction.OnExecuteItem := @FVExecuteItem;
  mMAction.Items.Add('Změna stavu');



end;

{
procedure AfterSiteOpen_Hook(Self: TSiteForm);
begin

end;

procedure FormCreate_Hook(Self: TSiteForm);
var
  mAList: TActionList;
  i: integer;
  mAction: TBasicAction;
  mmAction: TMultiAction;
  mC: TControl;
begin
    mAList := Self.GetMainActionList;
    for i := 0 to mAList.ActionCount-1 do begin
        mAction := mALIst.Actions[i];
        // Zcela odstranime funkci Opravit
        if (mAction.Name = 'CactStateChange') then begin
            mAction.Visible := False;
        end;
//        if (mmAction.Name = 'CactMaterialOutStock') then begin
//            mmAction.Visible := False;
//        end;

  end;

 // mC := Self.MainPanel.FindChildControl('rgdisplaymodeofrows');
 // if Assigned(mC) then begin
 //   TRadioGroup(mC).Visible:= false;
 // end;

end;
           }
begin
end.




