  uses  '_Knihovny_ALL.Progress',
      '_Knihovny_ALL.Parse',
       '_Knihovny_ALL.VisualForms',
       '_Knihovny_ALL.Change_Parameters';









{procedure _AfterSave_PostHook(Self: TRollSiteForm);
var
mSourceBO,mNewBO,mBO:TNxCustomBusinessObject;
mr:tstringlist;
begin
        if TBusRollSiteForm(self).CurrentObject.GetFieldValueAsBoolean('Isproduct') then begin
               mSourceBO:=self.BaseObjectSpace.CreateObject('RW2YIIHUHP3OZCQ5RQR5SJQWI4');
                try
                       mSourceBO.load('5A61000101',nil);

                       mNewBO:=self.BaseObjectSpace.CreateObject('RW2YIIHUHP3OZCQ5RQR5SJQWI4');
                       mBO:=TBusRollSiteForm(self).CurrentObject;
                              mr:=TStringList.create;
                              try
                                    self.BaseObjectSpace.SQLSelect('Select id from PLMRoutines where Storecard_ID=' + quotedstr(mBO.oid),mr);
                                    if mr.count=0 then begin
                                             mNewBO.New;
                                             mNewBO.Prefill;
                                             mNewBO:=mSourceBO.clone;
                                             mNewBO.SetFieldValueAsString('Storecard_ID',mBO.oid);
                                             mNewBO.SetFieldValueAsString('Name',mBO.GetFieldValueAsString('code'));
                                             mNewBO.save;
                                             //NxShowSimpleMessage('AAA',nil);
                                    end;
                              finally
                                  mr.free;
                              end;
                  finally
                      mSourceBO.free;
                      mNewBO.free;
                  end;
        end;
end;
       }
       procedure aUserdata(Sender: TObject;index:integer);
var
  mSite: TSiteForm;
  mDBGrid : TDBGrid;
  mTabList: TTabSheet;
  i: integer;
  mBO, mNewBO, mSourceBO:TNxCustomBusinessObject;
  mi:integer;
  mBookmark : TBookmarkList;
  mIBookmark:integer;
  mICount:integer;
  mPocetZmen:integer;
  mHodnotyParam,mr:TStringList;
  mNewValue,mValue:string;
  mNovyZapis:string;
  begin
  if Sender is TComponent then mSite := TComponent(Sender).Site;

//  if Sender is TAction then mSite := NxFindSiteForm(Sender);

    if not Assigned(mSite) then begin
         NxMessageBox('Chyba', 'Agenda nebyla dohledána', mdConfirm, mdbOkCancel, 0, 0, true, nil) ;

    end else begin
        mTabList := TTabSheet(NxFindChildControl(mSite.MainPanel, 'tabList'));
            if mTabList = nil then begin
                  RaiseException('tabList nenalezen');
                  NxMessageBox('Chyba', 'abList nenalezen', mdConfirm, mdbOkCancel, 0, 0, true, nil) ;

            end else begin
            mDBGrid := TDBGrid(NxFindChildControl(mTabList, 'grdList'));
                if mDBGrid = nil then begin
                      RaiseException('DBGrid nenalezen');
                      NxMessageBox('Chyba', 'DBGrid nenalezen', mdConfirm, mdbOkCancel, 0, 0, true, nil) ;

                end else begin
                mBookmark := mDBGrid.SelectedRows;



                      try

                        if mBookmark.count>0 then begin
                               mIBookmark:=mBookmark.count-1;
                               ProgressInit(msite, 'Zpracování dat skladových karet ' +  ' xx ', 100);
                        end;

                               mSourceBO:=msite.BaseObjectSpace.CreateObject('RW2YIIHUHP3OZCQ5RQR5SJQWI4');
                               mSourceBO.load('5A61000101',nil);

                               mNewBO:=msite.BaseObjectSpace.CreateObject('RW2YIIHUHP3OZCQ5RQR5SJQWI4');

                                for mICount:=0 to mIBookmark do begin
                                    if mBookmark.count>0 then begin
                                         mDBGrid.DataSource.DataSet.GotoBookmark(mBookMark.items(mICount));
                                         ProgressSetPos(1+NxFloor(mICount/mBookmark.Count*99), inttostr(mICount) +' z '+inttostr(mBookmark.Count));
                                          mBO:=TBusRollSiteForm(msite).CurrentObject;
                                          //NxShowSimpleMessage('AAA',nil);
                                             if mBO.GetFieldValueAsBoolean('Isproduct') then begin

                                                    mr:=TStringList.create;
                                                    try
                                                          msite.BaseObjectSpace.SQLSelect('Select id from PLMRoutines where Storecard_ID=' + quotedstr(mBO.oid),mr);
                                                          if mr.count=0 then begin
                                                                   mNewBO.New;
                                                                   mNewBO.Prefill;
                                                                   mNewBO:=mSourceBO.clone;
                                                                   mNewBO.SetFieldValueAsString('Storecard_ID',mBO.oid);
                                                                   mNewBO.SetFieldValueAsString('Name',mBO.GetFieldValueAsString('code'));
                                                                   mNewBO.save;
                                                                   //NxShowSimpleMessage('AAA',nil);
                                                          end;
                                                    finally
                                                        mr.free;
                                                    end;
                                             end;
                                    end;
                                end;
                                if mBookmark.count>0 then  begin ProgressDispose()   ;
                                    NxShowSimpleMessage('Úpravy ' + ' v parametrech' + ' bylo provedeno ' + inttostr(mPocetZmen) + ' změn. ',nil);
                                end;
                             finally
                                mSourceBO.free;
                                mNewBO.free;
                             end;

                end;
            end;
    end;



end;








procedure FormCreate_Hook(Self: TSiteForm);
var
  mAction: TAction;
  mMAction: TMultiAction;
begin
  mMAction := Self.GetNewMultiAction;
  mMAction.ShowControl := True;
  mMAction.ShowMenuItem := True;
  mMAction.Caption := 'Hromadná TP';
  mMAction.Hint := 'Umožní hromadně TP ';
  mMAction.Category := 'tabList';
  mMAction.Items.Add('TP');


   mMAction.OnExecuteItem := @aUserdata;

end;





begin
end.





