uses 'abra.eu.mask.Spedos_Digi_Archiv.lib';


Var
    mSite: TSiteForm;
    mDBGrid : TDBGrid;
    mTabList: TTabSheet;
    mCustomBusinessObject: TNxCustomBusinessObject;

    mHeaderBusinessObject : TNxHeaderBusinessObject;
    i : integer;
    mResult:Boolean;
    mBookmarkList:TBookmarkList ;
    aid:string;

procedure OnExec(Sender: TComponent;index:integer;);       // přidělení objectspace a zadání zdrojového souboru
var
mcastka:double;
mr:tstringlist;
mVarsymbol:string;
begin
        mSite := NxFindSiteForm(Sender);
        mTabList := TTabSheet(NxFindChildControl(mSite.MainPanel, 'tabList'));
        if mTabList = nil then RaiseException('tabList nenalezen');
        mDBGrid := TDBGrid(NxFindChildControl(mTabList, 'grdList'));
        if mDBGrid = nil then RaiseException('DBGrid nenalezen');

        mBookmarkList := mDBGrid.SelectedRows; // *** v mBookmark jsou id označených záznamu
        mcastka:=0;
        mvarsymbol:='';
          if mBookmarkList.count=0 then begin
                  NxShowSimpleMessage('Pro jeden záznam nemá smysl',nil);
        end else begin
             for i := 0 to mBookmarkList.Count-1 do begin // projdu vsechny oznacene zaznamy
                  mDBGrid.DataSource.DataSet.GotoBookmark(mBookmarkList.items(i));

                      mCustomBusinessObject:= TDynSiteForm(mSite).CurrentObject;

                        mcastka :=mcastka+mCustomBusinessObject.GetFieldValueAsFloat('Amount');
                        mvarsymbol:=mvarsymbol + mCustomBusinessObject.GetFieldValueAsString('VarSymbol');
                        mvarsymbol:=mvarsymbol + ';';

                      if i<mBookmarkList.Count-1 then begin

                            mCustomBusinessObject.Delete;
                      end else begin
                            mCustomBusinessObject.setFieldValueAsString('Description',copy(mvarsymbol,1,50));
                            mCustomBusinessObject.SetFieldValueAsFloat('Amount',mcastka);
                            mCustomBusinessObject.save;
                      end;
             end;
        end;
     try





        finally
        end;
        msite.Refresh;
        mDBGrid.Refresh;
        mDBGrid.DataSource.DataSet.Refresh;
end;




procedure InitSite_Hook(Self: TSiteForm);
var
  mAction: TBasicAction;
  mMAction: TMultiAction;
  mCAction: TBasicAction;
  mAList: TActionList;
  i : integer;
  mUserFilter:Boolean;
  mUserFilterTL:string;
  muser:TNxCustomBusinessObject;
begin
   mUserFilter:=true;
    mUser := Self.BaseObjectSpace.CreateObject('22AHIVDVAVE13C5S00CA141B44');
    try
      mUser.Load(Self.CompanyCache.GetUserID, nil);
            mUserFilter:= true; //mUser.GetFieldValueAsBoolean('X_archiv');



          mMAction := Self.GetNewMultiAction;
          mMAction.ShowControl := True;
          mMAction.ShowMenuItem := True;
          mMAction.Hint := 'Kumulace označených';
          mMAction.Caption := 'Kumulace označených';
          mMAction.Items.Add('Kumulace označených');
          mMAction.Category := 'tabList';
          mMAction.OnExecuteItem := @OnExec;


     finally
      mUser.Free;
     end;

end;



begin
end.