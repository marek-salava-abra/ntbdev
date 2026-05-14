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






procedure SloucitExecuteItem(Sender: TAction; Index: integer);
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
   morig:string;
   mi:Integer;
   mlist:TStringList;
   mfirm_ID,mPayerFirm_ID:string;
begin
    mSite := NxFindSiteForm(TComponent(Sender));
    mTabList := TTabSheet(NxFindChildControl(mSite.MainPanel, 'tabList'));
    if mTabList = nil then RaiseException('tabList nenalezen');
    mDBGrid := TDBGrid(NxFindChildControl(mTabList, 'grdList'));
    if mDBGrid = nil then RaiseException('DBGrid nenalezen');
    mBookmark := mDBGrid.SelectedRows; // *** v mBookmark jsou id označených záznamu
       morig:=TBusRollSiteForm(mSite).CurrentObject.oid;
        if mBookmark.count=0 then begin
            mBO := TBusRollSiteForm(mSite).CurrentObject;
                   if index=0 then begin
                             mBO.SetFieldValueAsBoolean('X_xxxx',true);
                             mfirm_ID:='';
                             mPayerFirm_ID:='';

                             mr:=tstringlist.create;
                             try
                               msite.BaseObjectSpace.SQLSelect('select id from firms where id='+quotedstr(mbo.GetFieldValueAsString('Firm_ID')),mr);
                               if mr.count>0 then begin
                                  mfirm_ID:=mr.Strings[0] ;
                               end;
                             finally
                                mr.free;
                             end;


                             mr:=tstringlist.create;
                             try
                               msite.BaseObjectSpace.SQLSelect('select id from firms where id='+quotedstr(mbo.GetFieldValueAsString('PayerFirm_ID')),mr);
                               if mr.count>0 then begin
                                  mPayerFirm_ID:=mr.Strings[0] ;
                               end;
                             finally
                                mr.free;
                             end;

                             if (mfirm_ID<>'') and (mPayerFirm_ID<>'') then begin
                                                      if Not mBO.Validate() then begin
                                                         //NxShellExecute('open',cBatFile,'',NxAddSlash(ADir))
                                                      end else begin
                                                              mBO.Save;
                                                      end;
                            end;
                       end;
                       if index=1 then begin
                         //if N1 <> N2 then begin






















                            NxShellExecute('open','y:\Rename.bat\','y:\' + mbo.oid,'y:\' + mbo.GetFieldValueAsString('X_ID_Obchodni_dokumentace'));
                            //NxShellExecute('open', '\\g3\abrag3\AbraG3\folder.exe', 'R "' + '\\192.168.0.36\abra\Servis\' + '" "' + mbo.oid+ '" "' + mbo.GetFieldValueAsString('X_ID_Obchodni_dokumentace'), '\\g3\abrag3\AbraG3\folder.exe');
                          //end;
                       //end else begin
                         // NxMessageBox('Chyba', 'V cestě '+'\\192.168.0.36\abra\Servis\'+' nebyl nalezen Folder.exe. Adresář (folder) '+mbo.oid+' nelze přejmenovat na ' + mbo.GetFieldValueAsString('X_ID_Obchodni_dokumentace') +'.', mdStop, mdbOk, 2, [mdpSystemModal], False, nil);
                        //end;
                       end;
        end else begin
            for i := 0 to mBookmark.Count-1 do begin // projdu vsechny oznacene zaznamy
                    mDBGrid.DataSource.DataSet.GotoBookmark(mBookMark.items(i));
                    mBO := TBusRollSiteForm(mSite).CurrentObject;
                    if index=0 then begin
                             mBO.SetFieldValueAsBoolean('X_xxxx',true);

                              mfirm_ID:='';
                                 mPayerFirm_ID:='';

                                 mr:=tstringlist.create;
                                 try
                                   msite.BaseObjectSpace.SQLSelect('select id from firms where id='+quotedstr(mbo.GetFieldValueAsString('Firm_ID')),mr);
                                   if mr.count>0 then begin
                                      mfirm_ID:=mr.Strings[0] ;
                                   end;
                                 finally
                                    mr.free;
                                 end;


                                 mr:=tstringlist.create;
                                 try
                                   msite.BaseObjectSpace.SQLSelect('select id from firms where id='+quotedstr(mbo.GetFieldValueAsString('PayerFirm_ID')),mr);
                                   if mr.count>0 then begin
                                      mPayerFirm_ID:=mr.Strings[0] ;
                                   end;
                                 finally
                                    mr.free;
                                 end;

                                 if (mfirm_ID<>'') and (mPayerFirm_ID<>'') then begin
                                                          if Not mBO.Validate() then begin

                                                          end else begin
                                                                  mBO.Save;
                                                          end;
                                end;

                          end;
                    end;
        end;

 TBusRollSiteForm(mSite).Refresh;
 mDBGrid.Refresh;
     msite.Refresh;
     //msite.ActiveDataSet.seekid(mbo.oid);
     //msite.ActiveDataSet.RefreshAndRestoreLastSelectedItem;
end;

procedure InitSite_Hook(Self: TSiteForm);
var
mAction: TAction;
  mMAction: TMultiAction;
  mUserFilter: Boolean;
  mUser: TNxCustomBusinessObject;
begin

     mMAction := Self.GetNewMultiAction;
  mMAction.ShowControl := True;
  mMAction.ShowMenuItem := True;
  mMAction.Caption := 'xxx';
  mMAction.Hint := 'xxx';
  mMAction.Category := 'tabList';
  mMAction.OnExecuteItem := @SloucitExecuteItem;
  mMAction.Items.Add('Kontrola');
  mMAction.Items.Add('Přejmenování adresáře');


end;





begin
end.