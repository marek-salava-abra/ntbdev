Const
msql='select ii.id||sum(ii.Amount + ii.PaidCreditAmount - ii.PaidAmount -  ii.CreditAmount) ' +
            'from ServiceDocuments SD ' +
            'left join ServiceAssemblyForms SA on sa.ServiceDocument_ID=sd.id '+
            'left join ServiceAssemblyForms2 SA2 on sa2.Parent_ID=sa.id ' +
            'left join issuedinvoices2 II2 on ii2.X_parent_id=sa2.id '+
            'left join issuedinvoices II on ii.id=ii2.parent_ID '+
       'where SD.ID=%s and ii.id is not null '+
       'group by sd.id';




procedure zaplacenoOnExecute(Sender: TAction; Index: integer);
var
 mresult:Boolean;
 mtext:string;
 mbo,mbo_ServiceAssembyForms:TNxCustomBusinessObject;
 mSite: TSiteForm;
 mDBGrid : TDBGrid;
 mTabList: TTabSheet;
 self:TNxCustomBusinessObject;
 i,ii:integer;
  mr,mr2,mr3,mrx,mIDs_MLRow:TStringList;
   mForm: TDynSiteForm;
   mMon: TNxCustomBusinessMonikerCollection;
   mRow, mNewRow,mbo1: TNxCustomBusinessObject;
   mdate:Double;
   mBookmark:TBookmarkList;
   mcastka:double;
   mi:integer;
   mStrings:String;
   mID:string;
begin
  mSite := NxFindSiteForm(Sender);
    mTabList := TTabSheet(NxFindChildControl(mSite.MainPanel, 'tabList'));
    if mTabList = nil then RaiseException('tabList nenalezen');
    mDBGrid := TDBGrid(NxFindChildControl(mTabList, 'grdList'));
    if mDBGrid = nil then RaiseException('DBGrid nenalezen');
    mBookmark := mDBGrid.SelectedRows; // *** v mBookmark jsou id označených záznamu

      mIDs_MLRow:=TStringList.create;
          try
                  if mBookmark.count=0 then begin                 // pro aktuální záznam
                     mBO1 := TDynSiteForm(mSite).CurrentObject;

                              mbo_ServiceAssembyForms:=mbo1.ObjectSpace.CreateObject('I3CRLLN3XYVO30ZDQ2WB4CRZW0');
                              mrx:=TStringList.create;
                              try
                              mbo1.ObjectSpace.SQLSelect('select id from ServiceAssemblyForms where ServiceDocument_ID=' + quotedstr(mbo1.OID),mrx);
                                  if mrx.count>0 then begin
                                     for ii:=0 to mrx.count-1 do begin
                                          mbo_ServiceAssembyForms.load(mrx.Strings[ii],nil);
                                                    mMon := mbo_ServiceAssembyForms.GetLoadedCollectionMonikerForFieldCode(mbo_ServiceAssembyForms.GetFieldCode('ROWS'));
                                                           mStrings:='(';
                                                           for i := 0 to mMon.Count - 1 do begin
                                                              if i>0 then mStrings:= mStrings + ',';
                                                              mStrings:= mStrings + quotedstr(mMon.BusinessObject[i].OID);
                                                           end;
                                                           mStrings:= mStrings +')';
                                      end;
                                    end;
                              finally
                                  mrx.free;
                              end;

                                   mr2:=TStringList.create;
                                    mr3:=TStringList.create;

                              try

                                mbo_ServiceAssembyForms.ObjectSpace.SQLSelect('select sum(h.Amount + h.PaidCreditAmount) from issuedinvoices H left join issuedinvoices2 R on r.parent_id=H.id where r.X_parent_id in ' + (mStrings),mr2);
                                mbo_ServiceAssembyForms.ObjectSpace.SQLSelect('select sum(h.PaidAmount +  h.CreditAmount) from issuedinvoices H left join issuedinvoices2 R on r.parent_id=H.id where r.X_parent_id in ' + (mStrings),mr3);


                                if mr2.count>0 then begin
                                    if NxIBStrToFloat(mr2.Strings[0])>0 then begin
                                              if NxIBStrToFloat(mr2.Strings[0])<=strtofloat(mr3.Strings[0]) then begin
                                                 //NxShowSimpleMessage(mr2.Strings[0],nil);
                                                 // NxShowSimpleMessage(mr3.Strings[0],nil);
                                                 mi:=mbo1.ObjectSpace.SQLExecute('Update ServiceDocuments set ServiceDocState_ID=' + quotedstr('9500000101') + ' where id=' +quotedstr(mbo1.GetFieldValueAsString('id')));
                                                 mi:=mbo1.ObjectSpace.SQLExecute('Update ServiceAssemblyForms set X_State=' + quotedstr('9XQ1000101') + ' where Servicedocument_Id=' +quotedstr(mbo1.GetFieldValueAsString('id')) +
                                                     ' and X_State=' + quotedstr('8XQ1000101'));
                                              end  else begin
                                                  mi:=mbo1.ObjectSpace.SQLExecute('Update ServiceDocuments set ServiceDocState_ID=' + quotedstr('E102000000') + ' where id=' +quotedstr(mbo1.GetFieldValueAsString('id')));

                                              end;


                                     end;
                                 end
                                  finally
                                   mr2.free;
                                   mr3.free;
                                  end;


                  end else begin
                          for i := 0 to mBookmark.Count-1 do begin // projdu vsechny oznacene zaznamy           // pro ozbačené záznamy
                                  mDBGrid.DataSource.DataSet.GotoBookmark(mBookMark.items(i));

                                              mBO1 := TDynSiteForm(mSite).CurrentObject;
                                              mbo_ServiceAssembyForms:=mbo1.ObjectSpace.CreateObject('I3CRLLN3XYVO30ZDQ2WB4CRZW0');
                                          mid:=mbo1.GetFieldValueAsString('ID');

                                          mrx:=TStringList.create;
                                          try
                                          mbo1.ObjectSpace.SQLSelect('select id from ServiceAssemblyForms where ServiceDocument_ID=' + quotedstr(mbo1.OID),mrx);
                                              if mrx.count>0 then begin
                                                 for ii:=0 to mrx.count-1 do begin
                                                      mbo_ServiceAssembyForms.load(mrx.Strings[ii],nil);
                                                                mMon := mbo_ServiceAssembyForms.GetLoadedCollectionMonikerForFieldCode(mbo_ServiceAssembyForms.GetFieldCode('ROWS'));
                                                                       mStrings:='(';
                                                                       for i := 0 to mMon.Count - 1 do begin
                                                                          if i>0 then mStrings:= mStrings + ',';
                                                                          mStrings:= mStrings + quotedstr(mMon.BusinessObject[i].OID);
                                                                       end;
                                                                       mStrings:= mStrings +')';
                                                  end;
                                                end;
                                          finally
                                              mrx.free;
                                          end;

                                               mr2:=TStringList.create;
                                                mr3:=TStringList.create;

                                          try

                                            mbo_ServiceAssembyForms.ObjectSpace.SQLSelect('select sum(h.Amount + h.PaidCreditAmount) from issuedinvoices H left join issuedinvoices2 R on r.parent_id=H.id where r.X_parent_id in ' + (mStrings),mr2);
                                            mbo_ServiceAssembyForms.ObjectSpace.SQLSelect('select sum(h.PaidAmount +  h.CreditAmount) from issuedinvoices H left join issuedinvoices2 R on r.parent_id=H.id where r.X_parent_id in ' + (mStrings),mr3);
                                            if mr2.count>0 then begin
                                                    if NxIBStrToFloat(mr2.Strings[0])>0 then begin
                                                              if NxIBStrToFloat(mr2.Strings[0])<=strtofloat(mr3.Strings[0]) then begin
                                                                 //NxShowSimpleMessage(mr2.Strings[0],nil);
                                                                 // NxShowSimpleMessage(mr3.Strings[0],nil);
                                                                 mi:=mbo1.ObjectSpace.SQLExecute('Update ServiceDocuments set ServiceDocState_ID=' + quotedstr('9500000101') + ' where id=' +quotedstr(mbo1.GetFieldValueAsString('id')));
                                                                 mi:=mbo1.ObjectSpace.SQLExecute('Update ServiceAssemblyForms set X_State=' + quotedstr('9XQ1000101') + ' where Servicedocument_Id=' +quotedstr(mbo1.GetFieldValueAsString('id')) +
                                                     ' and X_State=' + quotedstr('8XQ1000101'));
                                                              end  else begin
                                                                  mi:=mbo1.ObjectSpace.SQLExecute('Update ServiceDocuments set ServiceDocState_ID=' + quotedstr('E102000000') + ' where id=' +quotedstr(mbo1.GetFieldValueAsString('id')));

                                                              end;


                                                     end;
                                              end;
                                              finally
                                               mr2.free;
                                               mr3.free;
                                              end;

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

    mMAction := Self.GetNewMultiAction;
  mMAction.ShowControl := True;
  mMAction.ShowMenuItem := True;
  mMAction.Caption := 'zaplaceno';
  mMAction.Hint := 'zaplaceno';
  mMAction.Category := 'tablist';
  mMAction.OnExecuteItem := @zaplacenoOnExecute;


end;

begin
end.