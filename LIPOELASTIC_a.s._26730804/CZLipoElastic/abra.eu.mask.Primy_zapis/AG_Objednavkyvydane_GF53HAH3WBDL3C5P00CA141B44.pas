
var
     mBookmark : TBookmarkList;

procedure primy_zapis(Sender: TAction; Index: integer);
var
 mbo:TNxCustomBusinessObject;
 mSite: TSiteForm;
 mDBGrid : TDBGrid;
 mTabList: TTabSheet;
 i:integer;
   mForm: TDynSiteForm;
   mtext:string;
   mB_Result:boolean;
   mi:integer;
   mr:tstringlist;

begin
  mtext:='Description=' + quotedstr('');
  mSite := NxFindSiteForm(Sender);
    mTabList := TTabSheet(NxFindChildControl(mSite.MainPanel, 'tabList'));
    if mTabList = nil then
        RaiseException('tabList nenalezen');
    mDBGrid := TDBGrid(NxFindChildControl(mTabList, 'grdList'));
    if mDBGrid = nil then
        RaiseException('DBGrid nenalezen');
    mBookmark := mDBGrid.SelectedRows; // *** v mBookmark jsou id označených záznamu
    mbo:= TDynSiteForm(mSite).CurrentObject;
//    mB_Result:=InputQuery('Zadaj parametry', 'Změna ', mtext);
    if mBookmark.count=0 then begin
               //if index=0 then begin
                                 mr:=tstringlist.create;
                                 try
                                    msite.BaseObjectSpace.SQLSelect('SELECT max(us.StringFieldValue) FROM IssuedOrders A left join IssuedOrders2 Y on Y.Parent_ID=A.ID left join ReceivedOrdersToIssuedOrders RTO on RTO.Target_ID = Y.ID left join receivedorders2 RO2 on rto.Source_ID=ro2.id left join receivedorders ro on ro.id=ro2.parent_id ' +
                                                                    ' left join USERDATA US on ((US.FIELDCODE='+ quotedstr('2000011') + ') AND (US.CLSID='+ quotedstr('01CPMINJW3DL342X01C0CX3FCC') + ') AND (US.ID = RO.ID))'   +
                                                                    ' WHERE A.ID=' + quotedstr(TDynSiteForm(mSite).CurrentObject.OID),mr);
                                    if mr.count>0 then begin
                                        if mr.Strings[0]<>'' then begin
                                             TDynSiteForm(mSite).CurrentObject.SetFieldValueAsString('U_PrintLink',mr.Strings[0]);
                                             TDynSiteForm(mSite).CurrentObject.save;

                                        end;
                                    end;
                                 finally
                                     mr.free;
                                 end;

                              TDynSiteForm(mSite).CurrentObject.Refresh;
    end else begin
         for i := 0 to mBookmark.Count- 1 do begin
                          mDBGrid.DataSource.DataSet.GotoBookmark(mBookMark.items(i));
                         mr:=tstringlist.create;
                                 try
                                    msite.BaseObjectSpace.SQLSelect('SELECT max(us.StringFieldValue) FROM IssuedOrders A left join IssuedOrders2 Y on Y.Parent_ID=A.ID left join ReceivedOrdersToIssuedOrders RTO on RTO.Target_ID = Y.ID left join receivedorders2 RO2 on rto.Source_ID=ro2.id left join receivedorders ro on ro.id=ro2.parent_id ' +
                                                                    ' left join USERDATA US on ((US.FIELDCODE='+ quotedstr('2000011') + ') AND (US.CLSID='+ quotedstr('01CPMINJW3DL342X01C0CX3FCC') + ') AND (US.ID = RO.ID))'   +
                                                                    ' WHERE A.ID=' + quotedstr(TDynSiteForm(mSite).CurrentObject.OID),mr);
                                    if mr.count>0 then begin
                                        if mr.Strings[0]<>'' then begin
                                             TDynSiteForm(mSite).CurrentObject.SetFieldValueAsString('U_PrintLink',mr.Strings[0]);
                                             TDynSiteForm(mSite).CurrentObject.save;

                                        end;
                                    end;
                                 finally
                                     mr.free;
                                 end;

                              TDynSiteForm(mSite).CurrentObject.Refresh;

         end;

    end;





end;


procedure InitSite_Hook(Self: TDynSiteForm);
var
mAction: TAction;
  mMAction: TMultiAction;
begin
if (NxGetActualUserID(self.BaseObjectSpace)='SUPER00000') or (NxGetActualUserID(self.BaseObjectSpace)='1Z10000101') then begin
  mmAction := Self.GetNewMultiAction;
  mmAction.ShowControl := True;
  mmAction.ShowMenuItem := True;
  mmAction.Caption := 'synchronizace s OP';
  mmAction.Hint := 'synchronizace s OP';
  mmAction.Category := 'tabList';
  mMAction.Items.Add('Přímý zápis objednávky bez kontroly');
  mMAction.Items.Add('Přímý zápis objednávky s kontrolou');
  mmAction.OnExecuteItem:= @primy_zapis;

end;

end;


begin
end.