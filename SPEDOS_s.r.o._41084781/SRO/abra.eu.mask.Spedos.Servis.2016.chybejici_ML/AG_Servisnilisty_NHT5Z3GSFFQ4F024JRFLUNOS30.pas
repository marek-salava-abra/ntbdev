


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
   mBO_ml, mNewRow,mbo_target: TNxCustomBusinessObject;
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



                  if mBookmark.count=0 then begin                 // pro aktuální záznam
                     mbo_target := TDynSiteForm(mSite).CurrentObject;

                     mr3:=tstringlist.create;
                                            try
                                                    mbo_target.ObjectSpace.SQLSelect('select id from ServiceAssemblyForms where ServiceDocument_ID=' + quotedstr(mbo_target.oid),mr3);
                                                    if mr3.count=0 then begin



                                                              mBO_ml:=mbo_target.ObjectSpace.CreateObject('I3CRLLN3XYVO30ZDQ2WB4CRZW0');
                                                                  try
                                                                      mBO_ml.new;
                                                                      mbo_ml.Prefill;
                                                                      mBO_ml.SetFieldValueAsString('ServiceDocument_ID',mbo_target.oid);
                                                                      mBO_ml.SetFieldValueAsInteger('OrdNumber',mr.count+1);
                                                                      mr2:=TStringList.Create;
                                                                      try
                                                                          mbo_target.ObjectSpace.SQLSelect('select id from ServiceWorkSpaces where code=' + QuotedStr(mbo_target.GetFieldValueAsString('Division_ID.code')),mr2);
                                                                          if mr2.count=1 then begin
                                                                             mBO_ml.SetFieldValueAsString('ServiceWorkSpace_ID',mr2.Strings[0]);
                                                                          end;
                                                                      finally
                                                                         mr2.free;
                                                                      end;
                                                                      mBO_ml.SetFieldValueAsinteger('AssemblyState',0);
                                                                      //mBO_ml.SetFieldValueAsstring('X_State','3XQ1000101');
                                                                      mBO_ml.SetFieldValueAsstring('X_id_zakaznika_id',mbo_target.GetFieldValueAsString('X_id_zakaznika_id'));
                                                                      mBO_ml.SetFieldValueAsstring('X_ServicedObject_ID',mbo_target.GetFieldValueAsString('ServicedObject_ID'));
                                                                      mBO_ml.SetFieldValueAsDateTime('StartDate$DATE',mbo_target.GetFieldValueAsDateTime('docdate$date'));
                                                                      mBO_ml.SetFieldValueAsDateTime('EndDate$DATE',mbo_target.GetFieldValueAsDateTime('PromisedDeadLine$DATE'));
                                                                      mBO_ML.SetFieldValueAsstring('X_Docqueue_ID',mbo_target.GetFieldValueAsString('Docqueue_ID'));
                                                                      mBO_ML.SetFieldValueAsInteger('X_Ordnumber',mbo_target.GetFieldValueAsInteger('Ordnumber'));
                                                                      mBO_ML.SetFieldValueAsstring('X_Period_ID',mbo_target.GetFieldValueAsString('Period_ID'));
                                                                      mr2:=TStringList.Create;
                                                                      try
                                                                          mbo_target.ObjectSpace.SQLSelect('select id from SecurityRoles where ShortName=' + QuotedStr(mbo_target.GetFieldValueAsString('Division_ID.code')),mr2);
                                                                          if mr2.count=1 then begin
                                                                             mBO_ml.SetFieldValueAsString('ResponsibleRole_ID',mr2.Strings[0]);
                                                                          end;
                                                                      finally
                                                                         mr2.free;
                                                                      end;
                                                                      mBO_ml.save;
                                                                  finally
                                                                     mBO_ml.free;
                                                                  end;

                                                           end;

                                                     finally
                                                           mr3.free;
                                                     end;

                  end else begin
                          for i := 0 to mBookmark.Count-1 do begin // projdu vsechny oznacene zaznamy           // pro ozbačené záznamy
                                  mDBGrid.DataSource.DataSet.GotoBookmark(mBookMark.items(i));

                                        mbo_target := TDynSiteForm(mSite).CurrentObject;

                                            mr3:=tstringlist.create;
                                            try
                                                    mbo_target.ObjectSpace.SQLSelect('select id from ServiceAssemblyForms where ServiceDocument_ID=' + quotedstr(mbo_target.oid),mr3);
                                                    if mr3.count=0 then begin



                                                              mBO_ml:=mbo_target.ObjectSpace.CreateObject('I3CRLLN3XYVO30ZDQ2WB4CRZW0');
                                                              try
                                                                  mBO_ml.new;
                                                                  mbo_ml.Prefill;
                                                                  mBO_ml.SetFieldValueAsString('ServiceDocument_ID',mbo_target.oid);
                                                                  mBO_ml.SetFieldValueAsInteger('OrdNumber',mr.count+1);
                                                                  mr2:=TStringList.Create;
                                                                  try
                                                                      mbo_target.ObjectSpace.SQLSelect('select id from ServiceWorkSpaces where code=' + QuotedStr(mbo_target.GetFieldValueAsString('Division_ID.code')),mr2);
                                                                      if mr2.count=1 then begin
                                                                         mBO_ml.SetFieldValueAsString('ServiceWorkSpace_ID',mr2.Strings[0]);
                                                                      end;
                                                                  finally
                                                                     mr2.free;
                                                                  end;
                                                                  mBO_ml.SetFieldValueAsinteger('AssemblyState',0);
                                                                  //mBO_ml.SetFieldValueAsstring('X_State','3XQ1000101');
                                                                  mBO_ml.SetFieldValueAsstring('X_id_zakaznika_id',mbo_target.GetFieldValueAsString('X_id_zakaznika_id'));
                                                                  mBO_ml.SetFieldValueAsstring('X_ServicedObject_ID',mbo_target.GetFieldValueAsString('ServicedObject_ID'));
                                                                  mBO_ml.SetFieldValueAsDateTime('StartDate$DATE',mbo_target.GetFieldValueAsDateTime('docdate$date'));
                                                                  mBO_ml.SetFieldValueAsDateTime('EndDate$DATE',mbo_target.GetFieldValueAsDateTime('PromisedDeadLine$DATE'));
                                                                  mBO_ML.SetFieldValueAsstring('X_Docqueue_ID',mbo_target.GetFieldValueAsString('Docqueue_ID'));
                                                                  mBO_ML.SetFieldValueAsInteger('X_Ordnumber',mbo_target.GetFieldValueAsInteger('Ordnumber'));
                                                                  mBO_ML.SetFieldValueAsstring('X_Period_ID',mbo_target.GetFieldValueAsString('Period_ID'));
                                                                  mr2:=TStringList.Create;
                                                                  try
                                                                      mbo_target.ObjectSpace.SQLSelect('select id from SecurityRoles where ShortName=' + QuotedStr(mbo_target.GetFieldValueAsString('Division_ID.code')),mr2);
                                                                      if mr2.count=1 then begin
                                                                         mBO_ml.SetFieldValueAsString('ResponsibleRole_ID',mr2.Strings[0]);
                                                                      end;
                                                                  finally
                                                                     mr2.free;
                                                                  end;
                                                                  mBO_ml.save;
                                                              finally
                                                                 mBO_ml.free;
                                                              end;
                                                         end;
                                                   finally
                                                       mr3.free;
                                                  end;

                  end;
             end;

//        TDynSiteForm(mSite).RefreshData;


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
  mMAction.Caption := 'Chybějící ML';
  mMAction.Hint := 'Generování ML';
  mMAction.Category := 'tablist';
  mMAction.OnExecuteItem := @zaplacenoOnExecute;


end;

begin
end.