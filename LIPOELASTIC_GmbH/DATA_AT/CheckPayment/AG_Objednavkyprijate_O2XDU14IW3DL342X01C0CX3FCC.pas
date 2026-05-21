uses 'CheckPayment.lib';
var
     mBookmark : TBookmarkList;

{
Triggered after the properties of a form are read.
}
procedure LoadingProperties_Hook(Self: TSiteForm; AParams: TNxParameters);
begin

end;

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
   mTJSONSuperObject:TJSONSuperObject;
     mbopay:TNxCustomBusinessObject;
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
            if mBO.getfieldvalueasstring('Docqueue_ID.code')='ASOC' then begin
            try
                   if not nxisemptyoid(mBO.getfieldvalueasstring('X_payment_ID')) then begin
                             mTJSONSuperObject:=CheckPayment(mBO);
                         // if mbo.getfieldvalueasfloat('Amount') = nxibstrtofloat( mTJSONSuperObject.S['amount.value']) then begin

                                case mTJSONSuperObject.S['status'] of
                                          'paid': begin

                                                     mbopay:=TDynSiteForm(mSite).baseobjectspace.createobject('4MUQWZQK1Q1OP2LF40ST0232US');
                                                             try
                                                                 mbopay.load(mBO.getFieldValueAsString('X_payment_ID'),nil);
                                                                 mbopay.SetFieldValueAsString('X_URL',mTJSONSuperObject.S['_links.dashboard.href']);
                                                                 mbopay.save;
                                                                 if mdebug then NXshowsimplemessage(mTJSONSuperObject.S['_links.dashboard.href'],nil);
                                                             finally
                                                                 mbopay.free;
                                                             end;
                                                      mBO.SetFieldValueAsString('X_PaymentStatus_ID','~000000ORZ');
                                                      if mBO.getFieldValueAsString('PMState_ID')='~000000002' then begin
                                                           mBO.SetFieldValueAsString('PMState_ID','~000000004')  ;
                                                      end;

                                                  end;
                                          'unpaid': begin
                                                      mBO.SetFieldValueAsString('X_PaymentStatus_ID','~000000OS0');
                                                      //mBO.SetFieldValueAsString('PMState_ID','~000000003')  ;
                                                      if mBO.getFieldValueAsString('PMState_ID')='~000000002'  then begin


                                                            mBO.SetFieldValueAsString('PMState_ID','~000000003')  ;
                                                      end;
                                                  end;

                                end;



                                if mBO.getFieldValueAsString('PMState_ID')='~000000003'  then begin
                                         if (mBO.GetFieldValueAsDateTime('DocDate$DATE'))<=(date() - datedif) then begin
                                                mBO.SetFieldValueAsString('X_PaymentStatus_ID','~000000OS1');
                                                mBO.SetFieldValueAsString('PMState_ID','~00000000C')  ;
                                         end;


                                end;

                          mbo.save;


                     end;
                    finally
                         //mTJSONSuperObject.free;
                  end;
      end;

    end else begin
         for mIBookmark := 0 to mBookmark.Count- 1 do begin
                          mDBGrid.DataSource.DataSet.GotoBookmark(mBookMark.items(mIBookmark));
                          mbo:= TDynSiteForm(mSite).CurrentObject;

                          if mBO.getfieldvalueasstring('Docqueue_ID.code')='ASOC' then begin
                                try
                                 if not nxisemptyoid(mBO.getfieldvalueasstring('X_payment_ID')) then begin
                                           mTJSONSuperObject:=CheckPayment(mBO);
                                       // if mbo.getfieldvalueasfloat('Amount') = nxibstrtofloat( mTJSONSuperObject.S['amount.value']) then begin

                                              case mTJSONSuperObject.S['status'] of
                                                        'paid': begin

                                                                   mbopay:=TDynSiteForm(mSite).baseobjectspace.createobject('4MUQWZQK1Q1OP2LF40ST0232US');
                                                                           try
                                                                               mbopay.load(mBO.getFieldValueAsString('X_payment_ID'),nil);
                                                                               mbopay.SetFieldValueAsString('X_URL',mTJSONSuperObject.S['_links.dashboard.href']);
                                                                               mbopay.save;
                                                                               if mdebug then NXshowsimplemessage(mTJSONSuperObject.S['_links.dashboard.href'],nil);
                                                                           finally
                                                                               mbopay.free;
                                                                           end;
                                                                    mBO.SetFieldValueAsString('X_PaymentStatus_ID','~000000ORZ');
                                                                    if mBO.getFieldValueAsString('PMState_ID')='~000000002' then begin
                                                                         mBO.SetFieldValueAsString('PMState_ID','~000000004')  ;
                                                                    end;

                                                                end;
                                                        'unpaid': begin
                                                                    mBO.SetFieldValueAsString('X_PaymentStatus_ID','~000000OS0');
                                                                    //mBO.SetFieldValueAsString('PMState_ID','~000000003')  ;
                                                                    if mBO.getFieldValueAsString('PMState_ID')='~000000002'  then begin

                                                                          mBO.SetFieldValueAsString('PMState_ID','~000000003')  ;
                                                                    end;
                                                                end;

                                              end;



                                              if mBO.getFieldValueAsString('PMState_ID')='~000000003'  then begin
                                                       if (mBO.GetFieldValueAsDateTime('DocDate$DATE'))<=(date() - datedif) then begin
                                                              mBO.SetFieldValueAsString('X_PaymentStatus_ID','~000000OS1');
                                                              mBO.SetFieldValueAsString('PMState_ID','~00000000C')  ;
                                                       end;


                                              end;

                                             mBO.save;


                                   end;
                                  finally
                                       //mTJSONSuperObject.free;
                                end;
                          end;

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
  mmAction.Caption := 'PayState';
  mmAction.Hint := 'PayState';
  mmAction.Category := 'tabList';
  mMAction.Items.Add('PayState');

  mmAction.OnExecuteItem:= @PMS_StateOrders;

//end;

end;


begin
end.