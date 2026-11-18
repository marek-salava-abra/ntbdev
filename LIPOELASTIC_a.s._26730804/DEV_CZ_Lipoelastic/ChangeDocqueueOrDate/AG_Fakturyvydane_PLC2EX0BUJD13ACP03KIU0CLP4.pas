 uses '_Knihovny_ALL.DateTime',
 'ChangeDocqueueOrDate.lib';








procedure NXCHANGEDOCQueue(Sender: TAction;index:integer);
var mSite : TDynSiteForm;
  mBO_source : TNxCustomBusinessObject;
  mID,mID_SO:string;
  mr,mrx:Tstringlist;
  i,j, mPosIndex: integer;
  mList: TStringList;
  mText: string;
  result:string;
mParams : TNxParameters;
mNumber,mNumberOriginal:string;
mLastNumber:integer;
 mi:integer;
 mprefix:string;
 mid_ML:string;
 mSDocqueue_ID,mSACCDocqueue_ID:string;
  mform:TForm;
  mresult:integer;
  mDocqueue:TRollComboEdit;
  mPeriod:TRollComboEdit;
  mDate:TDateEdit;
  mBtn:TButton;
  mDDate:Date;
  mSPeriod_ID:string;
  mSPeriod_IDFromDate:string;
  mBODocqueue_ID:TNxCustomBusinessObject;
begin
    mSite := TComponent(Sender).DynSite;
  mNumberOriginal:=TDynSiteForm(NxFindSiteForm(Sender)).CurrentObject.GetFieldValueAsString('Docqueue_ID.CODE') + '-' + inttostr(TDynSiteForm(NxFindSiteForm(Sender)).CurrentObject.GetFieldValueAsInteger('Ordnumber')) +'/'+TDynSiteForm(NxFindSiteForm(Sender)).CurrentObject.GetFieldValueAsString('Period_ID.CODE') ;

      mid_ML:=TDynSiteForm.CurrentObject.oid;
      try
      mNumberOriginal:=TDynSiteForm(msite).CurrentObject.GetFieldValueAsString('Docqueue_ID.CODE') + '-' + inttostr(TDynSiteForm(msite).CurrentObject.GetFieldValueAsInteger('Ordnumber')) +'/'+TDynSiteForm(NxFindSiteForm(Sender)).CurrentObject.GetFieldValueAsString('Period_ID.CODE') ;



   if index=0 then begin
                         mform:=CreateFormDialoga('mform', 'Změna parametrů ',mSite, 500, 300);
                         try
                           mSDocqueue_ID:='';


                           mDocqueue:=CreateNxComboEdita('xDocqueue', 'Řada :',mform,  10,  10, 250, 250, 50, 80, 'W2XNBCJK3ZD13ACL03KIU0CLP4', 'code', 'Name',TDynSiteForm(msite).CurrentObject.GetFieldValueAsString('Docqueue_ID') , 'FilterDocumentType=03','');
                           mPeriod:=CreateNxComboEdita('xPeriod', 'Období :',mform,  10,  40, 250, 250, 50, 80, 'W5Y335IS3JD13BYP02K2DBYMG4', 'code', 'Name',TDynSiteForm(msite).CurrentObject.GetFieldValueAsString('Period_ID') , '','');
                           mDate:=CreateDateEditA('xDate', 'Datum ', 10, 80, 200, 80, TDynSiteForm(msite).CurrentObject.GetFieldValueAsDateTime('Docdate$date'), mform, false);


                            mBtn := TButton.Create(mForm);mBtn.Width := 200 ;mBtn.Height := 40;mBtn.Caption := 'Změna'; mBtn.ModalResult := 2; mBtn.Cancel := False;mBtn.Default := True;mBtn.Left:=30;mBtn.Top :=220 ;mBtn.Name := 'btnOK';mForm.InsertControl(mBtn);
                            mBtn := TButton.Create(mForm);mBtn.Width := 200 ;mBtn.Height := 40;mBtn.Caption := 'Storno';mBtn.ModalResult := 99;mBtn.Cancel := False;mBtn.Left := 270;mBtn.Top := 220;mBtn.Name := 'btn99';mForm.InsertControl(mBtn);


                            //  ab:= CreateEdita('slozeni', 'Poměr',mform, 300,30, 30, 50,100, '155455',false,true,true,10, [fsBold],255) ;

                               mResult := mForm.ShowModal(mSite);
                               if mresult= 2 then begin
                                   if nxisemptyoid(mDocqueue.DataText) then begin
                                       NxShowSimpleMessage('Bez zadané řady nejde pokračovat',nil);


                                       exit;
                                   end else begin
                                           mSDocqueue_ID:=mDocqueue.DataText;
                                           mSPeriod_ID:=mPeriod.DataText;
                                           mDDate:=(mDate.Date);
                                           mSPeriod_IDFromDate:= GetPeriodIDByDate(msite.BaseObjectSpace, mDDate);

                                          if mSPeriod_IDFromDate=mSPeriod_ID then begin
                                               mrx:=TStringList.create ;
                                                try
                                                   mSite.BaseObjectSpace.SQLSelect('Select max(OrdNumber) from IssuedInvoices where period_ID=' + QuotedStr(mSPeriod_ID) + ' and DocQueue_ID=' +
                                                   QuotedStr(mSDocqueue_ID),mrx);
                                                   i:=strtoint(mrx.Strings[0])+1;
                                                          //NxShowSimpleMessage('Update Issuedinvoices set Docqueue_ID=' + quotedstr(mSDocqueue_ID) +
                                                          // ',Period_ID=' + quotedstr(mSPeriod_ID) +
                                                          //   ',ordnumber=' + inttostr(i) +
                                                          //    ',Docdate$date=' + NxFloatToIBStr(mDDate) +
                                                          //    ' where id=' +quotedstr(TDynSiteForm(NxFindSiteForm(Sender)).CurrentObject.oid),nil) ;
                                                          mBODocqueue_ID:=msite.BaseObjectSpace.CreateObject('OFTMKVQH3ZD13ACL03KIU0CLP4');
                                                          mSACCDocqueue_ID:='';
                                                          try
                                                              mBODocqueue_ID.load(mSPeriod_ID,nil);
                                                              if mBODocqueue_ID.GetFieldValueAsBoolean('ToAccount') then begin
                                                                  if mBODocqueue_ID.GetFieldValueAsBoolean('SummaryAccounted') then begin
                                                                      mSACCDocqueue_ID:= mBODocqueue_ID.getFieldValueAsString('SummaryAccDocQueue_ID');
                                                                  end else begin
                                                                      mSACCDocqueue_ID:= mBODocqueue_ID.getFieldValueAsString('SingleAccDocQueue_ID');
                                                                  end;
                                                              end;
                                                          finally

                                                          end;

                                                          if mSACCDocqueue_ID='' then begin
                                                                  mi:=msite.BaseObjectSpace.SQLExecute('Update Issuedinvoices set Docqueue_ID=' + quotedstr(mSDocqueue_ID) +
                                                                   ',Period_ID=' + quotedstr(mSPeriod_ID) +
                                                                     ',ordnumber=' + inttostr(i) +
                                                                      ',Docdate$date=' + NxFloatToIBStr(mDDate) +
                                                                      ' where id=' +quotedstr(TDynSiteForm(NxFindSiteForm(Sender)).CurrentObject.oid)) ;
                                                          end else begin
                                                                  mi:=msite.BaseObjectSpace.SQLExecute('Update Issuedinvoices set Docqueue_ID=' + quotedstr(mSDocqueue_ID) +
                                                                   ',Period_ID=' + quotedstr(mSPeriod_ID) +
                                                                   ',AccDocQueue_ID =' + quotedstr(mSACCDocqueue_ID) +
                                                                     ',ordnumber=' + inttostr(i) +
                                                                      ',Docdate$date=' + NxFloatToIBStr(mDDate) +
                                                                      ' where id=' +quotedstr(TDynSiteForm(NxFindSiteForm(Sender)).CurrentObject.oid)) ;
                                                          end;
                                                          msite.ActiveDataSet.RefreshAndRestoreLastSelectedItem;
                                                          TDynSiteForm(NxFindSiteForm(Sender)).CurrentObject.Refresh;
                                                          mNumber:=TDynSiteForm(NxFindSiteForm(Sender)).CurrentObject.GetFieldValueAsString('Docqueue_ID.CODE') + '-' + inttostr(i) +'/'+TDynSiteForm(NxFindSiteForm(Sender)).CurrentObject.GetFieldValueAsString('Period_ID.CODE') ;
                                                      NxShowSimpleMessage('Proběhla změna dokladu z ' + mNumberOriginal + ' na ' + mNumber + '. Prosím přeúčtujte' ,nil);
                                                finally
                                                   mrx.Free;
                                                end
                                          end else begin
                                              NxShowSimpleMessage('Datum neodpovídá zvolenému období , není možné pokračovat',nil);
                                              exit;
                                          end;
                                   end;
                               end;
                               if mresult= 99 then begin
                                   NxShowSimpleMessage('Operace byla přerušena uživatelem',nil);
                                   exit;
                               end;
                         finally
                             mform.free;
                         end;
                     end;
      finally
          mr.free;
      end;
      msite.ActiveDataSet.RefreshAndRestoreLastSelectedItem;

end;







//        if NxGetActualUserID(msite.BaseObjectSpace)='SUPER00000' then begin



procedure mservis(Sender: TAction; Index: integer);

begin
    //if index=1 then
     NXCHANGEDOCQueue(Sender,index);
end;



 procedure InitSite_Hook(Self: TSiteForm);
var
mAction: TAction;
  mMAction: TMultiAction;
  mUserFilter: Boolean;
  mUser: TNxCustomBusinessObject;
begin
   if Self.CompanyCache.GetUserID='SUPER00000' then begin
      mMAction := Self.GetNewMultiAction;
      mMAction.ShowControl := True;
      mMAction.ShowMenuItem := True;
      mMAction.Caption := 'Změna čísla dokladu';
      mMAction.Hint := 'Změna čísla dokladu';
      mMAction.Category := 'tabList';
      mMAction.OnExecuteItem := @mservis;
      mMAction.Items.Add('změna čísla dokladu');
  end;
end;




begin
end.