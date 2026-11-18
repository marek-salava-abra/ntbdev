  uses  '_Knihovny_ALL.Progress',
      '_Knihovny_ALL.Parse',
       '_Knihovny_ALL.VisualForms',
       '_Knihovny_ALL.Change_Parameters';



       procedure Userdata(Sender: TObject;index:integer);
var
  mSite: TSiteForm;
  mDBGrid : TDBGrid;
  mTabList: TTabSheet;
  i: integer;
  mBO:TNxCustomBusinessObject;
  mi:integer;
  mBookmark : TBookmarkList;
  mIBookmark:integer;
  mICount:integer;
  mPocetZmen:integer;
  mHodnotyParam:TStringList;
  mNewValue,mValue:string;
  mNovyZapis:string;
  begin
  if Sender is TComponent then mSite := TComponent(Sender).Site;

//  if Sender is TAction then mSite := NxFindSiteForm(Sender);

    if not Assigned(mSite) then begin
         NxMessageBox('Chyba', 'Agenda nebyla dohledána', mdConfirm, mdbOkCancel, 0, 0, true, nil) ;
         nxbeep(btfailure);
         exit;
    end else begin
        mTabList := TTabSheet(NxFindChildControl(mSite.MainPanel, 'tabList'));
            if mTabList = nil then begin
                  RaiseException('tabList nenalezen');
                  NxMessageBox('Chyba', 'abList nenalezen', mdConfirm, mdbOkCancel, 0, 0, true, nil) ;
                  nxbeep(btfailure);
                  exit;
            end else begin
            mDBGrid := TDBGrid(NxFindChildControl(mTabList, 'grdList'));
                if mDBGrid = nil then begin
                      RaiseException('DBGrid nenalezen');
                      NxMessageBox('Chyba', 'DBGrid nenalezen', mdConfirm, mdbOkCancel, 0, 0, true, nil) ;
                      nxbeep(btfailure);
                      exit;
                end else begin


                  mHodnotyParam:=TStringList.create;
                  try                                                                         //***** zadat *****
                    if index=0 then begin
                      mHodnotyParam.Add('Etiketovačka 3 štítky');
                      mHodnotyParam.Add('Výstupní kontrola úzký štítek');
                      mHodnotyParam.Add('Netisknout celní sazebník');
                      mHodnotyParam.Add('104 x 74mm');
                      mHodnotyParam.Add('netisknout ikonu návodu');
                      mHodnotyParam.Add('Stitek_parametr');
                      mHodnotyParam.Add('Spec.sandwich etiketa (např.PI premium)');
                      mHodnotyParam.Add('Jednorázový prostředek)');
                      mValue:=TBusRollSiteForm(msite).CurrentObject.GetFieldValueAsString('X_Stitek_parametr');            //***** zadat *****
                    end;
                    if index=1 then begin
                        mHodnotyParam.Add('Lipoelastic');
                        mHodnotyParam.Add('Lipostocking');
                        mHodnotyParam.Add('Lipoelastic SK');
                        mHodnotyParam.Add('Exact');
                        //mHodnotyParam.Add('');
                        mValue:=TBusRollSiteForm(msite).CurrentObject.GetFieldValueAsString('X_synchronizace_ID');
                    end;

                    if index=2 then begin
                        mHodnotyParam.Add('Etiketovačka 3 štítky');
                        mValue:=TBusRollSiteForm(msite).CurrentObject.GetFieldValueAsString('X_Parametry');
                    end;
                      mNewValue:=CreateStringParam(msite,'Parametry pro ' + inttostr(mHodnotyParam.count) + ' karet ',mHodnotyParam,mValue);

                      if mNewValue='Storno' then exit;

                      mBookmark := mDBGrid.SelectedRows;
                      mIBookmark:=0;
                      mPocetZmen:=0;

                        if mBookmark.count>0 then begin
                               mIBookmark:=mBookmark.count-1;
                               ProgressInit(msite, 'Zpracování dat skladových karet ' +  ' xx ', 100);
                        end else begin
                             NxShowSimpleMessage('Operace je povolena pouze s označenými záznamy',nil);
                        end;


                                for mICount:=0 to mIBookmark do begin
                                    if mBookmark.count>0 then begin
                                         mDBGrid.DataSource.DataSet.GotoBookmark(mBookMark.items(mICount));
                                         ProgressSetPos(1+NxFloor(mICount/mBookmark.Count*99), inttostr(mICount) +' z '+inttostr(mBookmark.Count));
                                          mBO:=TBusRollSiteForm(msite).CurrentObject;
                                          if index=0 then mValue:=TBusRollSiteForm(msite).CurrentObject.GetFieldValueAsString('X_Stitek_parametr');    //***** zadat *****
                                          if index=1 then mValue:=TBusRollSiteForm(msite).CurrentObject.GetFieldValueAsString('X_synchronizace_ID');    //***** zadat *****
                                          if index=2 then mValue:=TBusRollSiteForm(msite).CurrentObject.GetFieldValueAsString('X_Parametry');    //***** zadat *****

                                                mnovyzapis:=NewValueParam(msite,mHodnotyParam,mValue,mNewValue);

                                                if copy(mValue,1,mHodnotyParam.Count)<>mnovyzapis then begin
                                                   if index=0 then  TBusRollSiteForm(msite).CurrentObject.setFieldValueAsString('X_Stitek_parametr',mnovyzapis);     //***** zadat *****
                                                   if index=1 then  TBusRollSiteForm(msite).CurrentObject.setFieldValueAsString('X_synchronizace_ID',mnovyzapis);     //***** zadat *****
                                                   if index=2 then  TBusRollSiteForm(msite).CurrentObject.setFieldValueAsString('X_Parametry',mnovyzapis);     //***** zadat *****
                                                      TBusRollSiteForm(msite).CurrentObject.save;
                                                      TBusRollSiteForm(msite).DataSet.RefreshCurrentItem;
                                                      // NxShowSimpleMessage('hodnota ' + copy(mValue,1,mHodnotyParam.Count) + ' bude změněna na ' +  mnovyzapis,nil);
                                                      mPocetZmen:=mPocetZmen+1;
                                                end else begin
                                                      //NxShowSimpleMessage('Stejná hodnota' ,nil);
                                                end;

                                    end;
                                end;
                                if mBookmark.count>0 then  begin ProgressDispose()   ;
                                    NxShowSimpleMessage('Úpravy ' + ' v parametrech' + ' bylo provedeno ' + inttostr(mPocetZmen) + ' změn. ',nil);
                                end;
                      finally
                           mHodnotyParam.free;
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
  mMAction.Caption := 'Hromadná změna parametrů';
  mMAction.Hint := 'Umožní hromadně měnit parametry ';
  mMAction.Category := 'tabList';
  mMAction.Items.Add('Parametry štítků');
  mMAction.Items.Add('Synchronizace');
  mMAction.Items.Add('Parametry');

   mMAction.OnExecuteItem := @Userdata;

end;





begin
end.





