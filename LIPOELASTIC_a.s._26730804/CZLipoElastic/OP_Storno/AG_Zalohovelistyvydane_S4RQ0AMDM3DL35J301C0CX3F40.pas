uses 'OP_Storno.lib';
var
     mBookmark : TBookmarkList;

procedure Storno(Sender: TAction; Index: integer);
var
 mbo:TNxCustomBusinessObject;
 mSite: TSiteForm;
 mDBGrid : TDBGrid;
 mTabList: TTabSheet;
 i:integer;
   mForm: TDynSiteForm;
   mtext:string;
   mB_Result:boolean;
   mS_Result:string;
   mi:integer;
   ii :integer;
   mmon:TNxCustomBusinessMonikerCollection;
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

                             if index=0 then begin

                                   mMon := mbo.GetLoadedCollectionMonikerForFieldCode(mbo.GetFieldCode('ROWS'));
                                    for ii := 0 to mMon.Count-1 do begin
                                          //if mMon.BusinessObject[ii].GetFieldValueAsInteger('RowType')=4 then begin

                                                mMon.BusinessObject[ii].SetFieldValueAsFloat('UnitPrice',0);
                                                mMon.BusinessObject[ii].SetFieldValueAsFloat('TAmount',0);
                                                mMon.BusinessObject[ii].SetFieldValueAsFloat('LocalTAmount',0);
                                          //end;
                                    end;
                                    mbo.SetFieldValueAsFloat('Amount',0);
                                    mbo.SetFieldValueAsFloat('LocalAmount',0);
                                    mbo.SetFieldValueAsFloat('PaidAmount',0);
                                    mbo.SetFieldValueAsFloat('LocalPaidAmount',0);
                                    mbo.SetFieldValueAsFloat('UsedAmount',0);
                                    mbo.SetFieldValueAsFloat('LocalUsedAmount',0);
                                   mbo.save;
                              end;
                              if index=1 then begin
                                       MI:=mbo.ObjectSpace.SQLExecute('Update IssuedDInvoices2 set TAmount=0,LocalTAmount=0,UnitPrice=0  where Parent_ID=' + quotedstr(mbo.oid) );
                                       MI:=mbo.ObjectSpace.SQLExecute('Update IssuedDInvoices set Amount=0,LocalAmount=0,PaidAmount=0,LocalPaidAmount=0,UsedAmount=0,LocalUsedAmount=0 where ID=' + quotedstr(mbo.oid));
                              end;
                              TDynSiteForm(mSite).CurrentObject.Refresh;
                              TDynSiteForm(mSite).ActiveDataSet.RefreshAndRestoreLastSelectedItem ;



    end else begin
         for i := 0 to mBookmark.Count- 1 do begin
                          mDBGrid.DataSource.DataSet.GotoBookmark(mBookMark.items(i));
                          mbo:= TDynSiteForm(mSite).CurrentObject;

                              if index=0 then begin

                                   mMon := mbo.GetLoadedCollectionMonikerForFieldCode(mbo.GetFieldCode('ROWS'));
                                    for ii := 0 to mMon.Count-1 do begin
                                          //if mMon.BusinessObject[ii].GetFieldValueAsInteger('RowType')=4 then begin
                                                mMon.BusinessObject[ii].SetFieldValueAsFloat('UnitPrice',0);
                                                mMon.BusinessObject[ii].SetFieldValueAsFloat('TAmount',0);
                                                mMon.BusinessObject[ii].SetFieldValueAsFloat('LocalTAmount',0);
                                          //end;
                                    end;
                                    mbo.SetFieldValueAsFloat('Amount',0);
                                    mbo.SetFieldValueAsFloat('LocalAmount',0);
                                    mbo.SetFieldValueAsFloat('PaidAmount',0);
                                    mbo.SetFieldValueAsFloat('LocalPaidAmount',0);
                                    mbo.SetFieldValueAsFloat('UsedAmount',0);
                                    mbo.SetFieldValueAsFloat('LocalUsedAmount',0);
                                   mbo.save;
                              end;
                              if index=1 then begin
                                       MI:=mbo.ObjectSpace.SQLExecute('Update IssuedDInvoices2 set TAmount=0,LocalTAmount=0,UnitPrice=0  where Parent_ID=' + quotedstr(mbo.oid) );
                                       MI:=mbo.ObjectSpace.SQLExecute('Update IssuedDInvoices set Amount=0,LocalAmount=0,PaidAmount=0,LocalPaidAmount=0,UsedAmount=0,LocalUsedAmount=0 where ID=' + quotedstr(mbo.oid));
                              end;
                              TDynSiteForm(mSite).CurrentObject.Refresh;
                              TDynSiteForm(mSite).ActiveDataSet.RefreshAndRestoreLastSelectedItem ;

         end;

    end;

  TDynSiteForm(mSite).ActiveDataSet.RefreshAndRestoreLastSelectedItem ;

  //TDynSiteForm(mSite).Refresh;

end;


procedure InitSite_Hook(Self: TDynSiteForm);
var
mAction: TAction;
  mMAction: TMultiAction;
begin
//if (NxGetActualUserID(self.BaseObjectSpace)='SUPER00000') or (NxGetActualUserID(self.BaseObjectSpace)='1Z10000101') then begin
  mmAction := Self.GetNewMultiAction;
  mmAction.ShowControl := True;
  mmAction.ShowMenuItem := True;
  mmAction.Caption := 'Storno';
  mmAction.Hint := 'Storno ';
  mmAction.Category := 'tabList';
  mMAction.Items.Add('Storno');
  mMAction.Items.Add('Storno již uzavřeného období');
  //mMAction.Items.Add('Smazání včetně zálohy');
  mmAction.OnExecute:= @Storno;

//end;

end;


begin
end.