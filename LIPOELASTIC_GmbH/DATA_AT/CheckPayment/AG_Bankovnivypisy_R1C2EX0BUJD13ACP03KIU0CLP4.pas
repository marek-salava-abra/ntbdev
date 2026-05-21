uses 'CheckPayment.lib';
var
     mBookmark : TBookmarkList;

procedure PMS_StateOrders(Sender: TAction; Index: integer);
var
 mbo,mBORO:TNxCustomBusinessObject;
 mSite: TSiteForm;
 mDBGrid : TDBGrid;
 mTabList: TTabSheet;
 i:integer;
   mForm: TDynSiteForm;
   mtext:string;
   mB_Result:boolean;
   mi,mIRow,mIBookmark:integer;
   mr:tstringlist;
   mRowBO: TNxCustomBusinessObject;
   mRows: TNxCustomBusinessMonikerCollection;
   mid:string;
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
            mRows:=mBO.GetLoadedCollectionMonikerForFieldCode(mBO.GetFieldCode('Rows'));
             for mIRow:=0 to mRows.count-1 do begin
                  mRowBO:=mRows.BusinessObject[mIRow];
                       if mRowBO.getfieldvalueasstring('PDocumentType')='10' then begin
                         mID:='';
                         mID:=mRowBO.ObjectSpace.SQLSelectFirstAsString('select ro.id from receivedorders ro join issueddinvoices ZL on zl.ReceivedOrder_ID=ro.id where zl.id='
                         + quotedstr(mRowBO.getfieldvalueasstring('PDocument_ID')));
                         if mid<>'' then begin
                              mBORO:=mRowBO.ObjectSpace.CreateObject('01CPMINJW3DL342X01C0CX3FCC');
                              try
                                  mboro.load(mID,nil);
                                      mboro.SetFieldValueAsString('X_PaymentStatus_ID','~000000OS0');
                                      mboro.SetFieldValueAsString('PMState_ID','~000000003')  ;
                                  mboro.save;

                                      if mdebug then NXshowsimplemessage('Saving status' +  mboro.DisplayName  ,nil);
                              finally
                                  mboro.free;
                              end;
                         end;

                       end;


             END;

    end else begin
         for mIBookmark := 0 to mBookmark.Count- 1 do begin
                          mDBGrid.DataSource.DataSet.GotoBookmark(mBookMark.items(mIBookmark));
                          mbo:= TDynSiteForm(mSite).CurrentObject;

                          mRows:=mBO.GetLoadedCollectionMonikerForFieldCode(mBO.GetFieldCode('Rows'));
                               for mIRow:=0 to mRows.count-1 do begin
                                    mRowBO:=mRows.BusinessObject[mIRow];
                                         if mRowBO.getfieldvalueasstring('PDocumentType')='10' then begin
                                           mID:='';
                                           mID:=mRowBO.ObjectSpace.SQLSelectFirstAsString('select ro.id from receivedorders ro join issueddinvoices ZL on zl.ReceivedOrder_ID=ro.id where zl.id='
                                           + quotedstr(mRowBO.getfieldvalueasstring('PDocument_ID')));
                                           if mid<>'' then begin
                                                mBORO:=mRowBO.ObjectSpace.CreateObject('01CPMINJW3DL342X01C0CX3FCC');
                                                try
                                                    mboro.load(mID,nil);
                                                        mboro.SetFieldValueAsString('X_PaymentStatus_ID','~000000OS0');
                                                        mboro.SetFieldValueAsString('PMState_ID','~000000003')  ;
                                                    mboro.save;

                                                        if mdebug then NXshowsimplemessage('Saving status' +  mboro.DisplayName  ,nil);
                                                finally
                                                    mboro.free;
                                                end;
                                           end;

                                         end;


                               END;


                              TDynSiteForm(mSite).CurrentObject.Refresh;

         end;

    end;





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
  mmAction.Caption := 'Stav objednávek';
  mmAction.Hint := 'Stav objednávek';
  mmAction.Category := 'tabList';
  mMAction.Items.Add('Stav objednávek');

  mmAction.OnExecuteItem:= @PMS_StateOrders;

//end;

end;


begin
end.