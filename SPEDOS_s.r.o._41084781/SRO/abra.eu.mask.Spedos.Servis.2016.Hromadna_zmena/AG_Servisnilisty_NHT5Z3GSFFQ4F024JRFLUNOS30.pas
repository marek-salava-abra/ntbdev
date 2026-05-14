
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

      function GetDate(Sender: TComponent;msite:TSiteForm) : Date;
var
  mForm : TForm;
  mBtn : TButton;
  mlb2 : TLabel;
  mEdtSrc:TDateEdit;
begin
        try
              mForm := TForm.Create(Sender);            // formulář
                mForm.BorderIcons := [biSystemMenu];
                mForm.Width := 240;  // sirka
                mForm.Height := 100; // vyska
                mForm.Caption := 'Vstupní obrazovka';
                    mLb2 := TLabel.Create(mForm);         // položka řada
                    mLb2.Caption := 'Zadej datum:';
                    mLb2.Left := 30;
                    mLb2.Top := 10;
                    mLb2.Name := 'lblDocQueues';
                    mForm.InsertControl(mLb2);
                        mEdtSrc := TDateEdit.Create(mForm);
                        mEdtSrc.Left := 100;
                        mEdtSrc.Top := 10;
                        mEdtSrc.Width := 100;
                        mEdtSrc.Name := 'edtDate';
                        mForm.InsertControl(mEdtSrc);
                  mBtn := TButton.Create(mForm);            // tlačítko OK
                        mBtn.Width := 75;
                        mBtn.Height := 25;
                        mBtn.Caption := 'OK';
                        mBtn.ModalResult := mrOk;
                        mBtn.Cancel := False;
                        mBtn.Default := True;
                        mBtn.Left :=  mForm.Width - 2*(mBtn.Width+2) - 20;
                        mBtn.Top := mForm.Height - mBtn.Height - 40;
                        mBtn.Name := 'btnOK';
                        mForm.InsertControl(mBtn);
                    mBtn := TButton.Create(mForm);          // tlačítko storno
                        mBtn.Width := 75;
                        mBtn.Height := 25;
                        mBtn.Caption := 'Storno';
                        mBtn.ModalResult := mrCancel;
                        mBtn.Cancel := True;
                        mBtn.Left := mForm.Width - (mBtn.Width+2) - 20;;
                        mBtn.Top := mForm.Height - mBtn.Height - 40;
                        mBtn.Name := 'btnCancel';
                        mForm.InsertControl(mBtn);

           if mForm.ShowModal(msite) = mrOK then begin
                result:=mEdtSrc.Date;
           end;
        finally;
          mForm.Free;
        end;
end;



function iSelectZakazka(AOLE: Variant) : TNxOID;
var
  mRoll : variant;
  mXX : string;
begin
  Result := '';
  mXX := '0000000000';
  mRoll := AOLE.GetRoll('03OXHKRF4VD13ACL03KIU0CLP4', 0);
  Result := mRoll.SelectDialog2(False, mXX);
end;

function iSelectDispecer(AOLE: Variant) : TNxOID;
var
  mRoll : variant;
  mXX : string;
begin
  Result := '';
  mXX := '0000000000';
  mRoll := AOLE.GetRoll('BAM0CP0G24CONI4CCOMFMW04CW', 0);
  Result := mRoll.SelectDialog2(False, mXX);
end;

function iSelectSmlouva(AOLE: Variant) : TNxOID;
var
  mRoll : variant;
  mXX : string;
begin
  Result := '';
  mXX := '0000000000';
  mRoll := AOLE.GetRoll('ZX20VMNR1NV4N30K2MRDAXLRN4', 0);
  Result := mRoll.SelectDialog2(False, mXX);
end;

function iSelectProvozovatel(AOLE: Variant) : TNxOID;
var
  mRoll : variant;
  mXX : string;
begin
  Result := '';
  mXX := '0000000000';
  mRoll := AOLE.GetRoll('BTYHA5DHLTDO14H21XNZM2CPIK', 0);
  Result := mRoll.SelectDialog2(False, mXX);
end;



procedure FVExecuteItem(Sender: TAction; Index: integer);
var
 mresult:Boolean;
 mtext:string;
 mImportMan:TNxDocumentImportManager;
 mbo,mbo_source:TNxCustomBusinessObject;
 mSite: TDynSiteForm;
  mDBGrid : TDBGrid;
    mTabList: TTabSheet;
  self:TNxCustomBusinessObject;
  i,ii:integer;
  mr,mIDs_MLRow:TStringList;
   mForm: TDynSiteForm;
   mMon: TNxCustomBusinessMonikerCollection;
   mRow, mNewRow,mbo1: TNxCustomBusinessObject;
   mdate:Double;
   mi:integer;
   adate:Double;
   mDivision_ID,mWorkSpace_ID,mRole,mcode:string;
   mID_SO:string;
begin
    mSite := TComponent(Sender).DynSite;
    mTabList := TTabSheet(NxFindChildControl(mSite.MainPanel, 'tabList'));
    if mTabList = nil then RaiseException('tabList nenalezen');
    mDBGrid := TDBGrid(NxFindChildControl(mTabList, 'grdList'));
    if mDBGrid = nil then RaiseException('DBGrid nenalezen');
    mBookmark := mDBGrid.SelectedRows; // *** v mBookmark jsou id označených záznamu
    try
            if index=0 then mtext:=InputBox('Zadej ','Číslo objednávky','');
            if index=1 then mtext:=iSelectZakazka(mSite.GetAbraOLEApplication);
            if index=2 then mtext:=iSelectSmlouva(mSite.GetAbraOLEApplication);
            if index=3 then adate:=GetDate(Sender,mSite) ;
            if index=4 then mtext:=iSelectProvozovatel(mSite.GetAbraOLEApplication);
            if index=5 then begin
                 mWorkSpace_ID:=iSelectDispecer(mSite.GetAbraOLEApplication);
                 if mWorkSpace_ID<>'' then begin
                         mbo_source:=msite.BaseObjectSpace.CreateObject('S0MSV3WXRC24PFNR3SF20HZ5VC');
                         try
                            mbo_source.load(mWorkSpace_ID,nil)  ;
                            mcode:=mbo_source.GetFieldValueAsString('Code');
                         finally
                             mbo_source.free;
                         end;
                            mr:=TStringList.create;
                                    try
                                        msite.BaseObjectSpace.SQLSelect('Select id from Divisions where code=' + quotedstr(mcode),mr);
                                        if mr.count>0 then begin
                                            mDivision_ID:=mr.Strings[0];
                                            //NxShowSimpleMessage('středisko' +mDivision_ID,nil);
                                        end;
                                    finally
                                        mr.free;
                                    end;

                                    mr:=TStringList.create;
                                    try
                                        msite.BaseObjectSpace.SQLSelect('Select id from SecurityRoles where ShortName=' + quotedstr(mcode),mr);
                                        if mr.count>0 then begin
                                            mRole:=mr.Strings[0];
                                            //NxShowSimpleMessage('Role' +mRole,nil);
                                        end;
                                    finally
                                        mr.free;
                                    end;


              end else begin
                  NxShowSimpleMessage('Nebyl vybrán záznam pro změnu, změna nebyla provedena',nil);
              end;
            end;
            if index=6 then begin
                mID_SO := iSelectDivision(mSite.GetAbraOLEApplication);
            end;

            if mBookmark.count=0 then begin
                        mBO := TDynSiteForm(mSite).CurrentObject;
                        if index=0 then mbo.SetFieldValueAsstring('X_Objednani',mtext);
                        if index=1 then mbo.SetFieldValueAsstring('BusOrder_ID',mtext);
                        if index=2 then mbo.SetFieldValueAsstring('BusProject_ID',mtext);
                        mbo.Save;
                        if index=3 then mi:=mbo.ObjectSpace.SQLExecute('Update ServiceDocuments set docdate$date=' + (FloatToStr(adate)) +' , PromisedDeadLine$DATE=' + (FloatToStr(adate)) + ' where id='+ quotedstr(TDynSiteForm(mSite).CurrentObject.OID) ) ;

                        if index=4 then mi:=mbo.ObjectSpace.SQLExecute('Update ServiceDocuments set X_id_zakaznika_ID=' + quotedstr(mtext)+ ' where id='+ quotedstr(TDynSiteForm(mSite).CurrentObject.OID) ) ;
                        if index=4 then mi:=mbo.ObjectSpace.SQLExecute('Update ServiceAssemblyForms set X_id_zakaznika_ID=' + quotedstr(mtext)+ ' where ServiceDocument_ID='+ quotedstr(TDynSiteForm(mSite).CurrentObject.OID) ) ;
                        if index=5 then begin
                                mi:=mbo.ObjectSpace.SQLExecute('Update ServiceDocuments set Division_ID=' + quotedstr(mDivision_ID)+ ' where ID='+ quotedstr(TDynSiteForm(mSite).CurrentObject.OID) ) ;
                                mi:=mbo.ObjectSpace.SQLExecute('Update ServiceAssemblyForms set ServiceWorkSpace_ID=' + quotedstr(mWorkSpace_ID)+ ',ResponsibleRole_ID=' + quotedstr(mRole)+ ' where ServiceDocument_ID='+ quotedstr(TDynSiteForm(mSite).CurrentObject.OID) ) ;
                        end;
                        if index=6 then ChangeDivision_ID(Sender,Index,mID_SO);
                        TDynSiteForm(NxFindSiteForm(Sender)).CurrentObject.Refresh;
            end else begin
               for i := 0 to mBookmark.Count-1 do begin // projdu vsechny oznacene zaznamy
                        mDBGrid.DataSource.DataSet.GotoBookmark(mBookMark.items(i));
                        mBO := TDynSiteForm(mSite).CurrentObject;
                        if index=0 then mbo.SetFieldValueAsstring('X_Objednani',mtext);
                        if index=1 then mbo.SetFieldValueAsstring('BusOrder_ID',mtext);
                        if index=2 then mbo.SetFieldValueAsstring('BusProject_ID',mtext);
                        mbo.Save;

                        if index=3 then mi:=mbo.ObjectSpace.SQLExecute('Update ServiceDocuments set docdate$date=' + (FloatToStr(adate)) +' , PromisedDeadLine$DATE=' + (FloatToStr(adate)) + ' where id='+ quotedstr(TDynSiteForm(mSite).CurrentObject.OID) ) ;
                        if index=4 then mi:=mbo.ObjectSpace.SQLExecute('Update ServiceDocuments set X_id_zakaznika_ID=' + quotedstr(mtext)+ ' where id='+ quotedstr(TDynSiteForm(mSite).CurrentObject.OID) ) ;
                        if index=4 then mi:=mbo.ObjectSpace.SQLExecute('Update ServiceAssemblyForms set X_id_zakaznika_ID=' + quotedstr(mtext)+ ' where ServiceDocument_ID='+ quotedstr(TDynSiteForm(mSite).CurrentObject.OID) ) ;
                        if index=5 then begin
                                mi:=mbo.ObjectSpace.SQLExecute('Update ServiceDocuments set Division_ID=' + quotedstr(mDivision_ID)+ ' where ID='+ quotedstr(TDynSiteForm(mSite).CurrentObject.OID) ) ;
                                mi:=mbo.ObjectSpace.SQLExecute('Update ServiceAssemblyForms set ServiceWorkSpace_ID=' + quotedstr(mWorkSpace_ID)+ ',ResponsibleRole_ID=' + quotedstr(mRole)+ ' where ServiceDocument_ID='+ quotedstr(TDynSiteForm(mSite).CurrentObject.OID) ) ;
                        end;
                        if index=6 then ChangeDivision_ID(Sender,Index,mID_SO);

                        TDynSiteForm(NxFindSiteForm(Sender)).CurrentObject.Refresh;
                end;
            end;
   finally
   end;
 TDynSiteForm(mSite).RefreshData;
end;



  function iSelectDivision(AOLE: Variant) : string;
var
  mRoll2 : variant;
  mXX2 : string;
begin
  Result := '';
  mXX2 := '0000000000';
  mRoll2 := AOLE.GetRoll('OA5JMX4J2FD135CH000ILPWJF4', 0);
  Result := mRoll2.SelectDialog2(True, mXX2);
end;




procedure ChangeDivision_ID(Sender: TAction; Index: integer;mID_SO:string);
var
 mSite : TDynSiteForm;
 mID,mcode:string;
 mi:integer;
 mid_ML:string;
 mBO_source,mBODivision:TNxCustomBusinessObject;
 mr2,mr3:tstringlist;
begin
  mcode:='';
  mi:=0;
    mSite := TComponent(Sender).DynSite;
      //mID_SO:='';
      //mID_SO := iSelectDivision(mSite.GetAbraOLEApplication);
        if mID_SO<>'' then begin
          mi:=mSite.BaseObjectSpace.SQLExecute('update ServiceDocuments set Division_ID=' + quotedstr(mID_SO) + ' where id=' + QuotedStr(mSite.CurrentObject.GetFieldValueAsString('servicedocument_ID')));
          mid_ML:=mSite.CurrentObject.GetFieldValueAsString('servicedocument_ID') ;

          if mi=1 then begin
              //NxShowSimpleMessage('Změna střediska proběhla na ' + QuotedStr(msite.CurrentObject.GetFieldValueAsString('ServiceDocument_ID.division_id.code')),nil);
          end;

          mBODivision:=msite.BaseObjectSpace.CreateObject('O1X54EUXPZCL35CH000ILPWJF4');
          try
             mBODivision.load(mID_SO,nil);
             mcode:=mBODivision.GetFieldValueAsString('code');

          finally
             mBODivision.free;
          end;

          if mcode<>'' then begin
                  mr2:=TStringList.Create;
                      try
                          msite.BaseObjectSpace.SQLSelect('select id from ServiceWorkSpaces where code=' + QuotedStr(mcode),mr2);
                          if mr2.count>0 then begin
                                      mi:=mSite.BaseObjectSpace.SQLExecute('update ServiceAssemblyForms set ServiceWorkSpace_ID =' +
                                      quotedstr(mr2.Strings[0]) + ' where id=' + QuotedStr(mSite.CurrentObject.oid));

                          end;
                      finally
                         mr2.free;
                      end;
                  mr3:=TStringList.Create;
                      try
                          msite.BaseObjectSpace.SQLSelect('select id from SecurityRoles where ShortName=' + QuotedStr(mcode),mr3);
                          if mr3.count>0 then begin
                                      mi:=mSite.BaseObjectSpace.SQLExecute('update ServiceAssemblyForms set ResponsibleRole_ID =' +
                                      quotedstr(mr3.Strings[0]) + ' where id=' + QuotedStr(mSite.CurrentObject.oid));

                          end;
                      finally
                         mr3.free;
                      end;


          end;



          msite.RefreshData;
          msite.ActiveDataSet.seekid(mID_ML);
          msite.ActiveDataSet.RefreshAndRestoreLastSelectedItem;
        end;
end;





procedure InitSite_Hook(Self: TSiteForm);
var
mAction: TAction;
  mMAction: TMultiAction;
  mUserFilter: Boolean;
  mUser: TNxCustomBusinessObject;
begin
  mUserFilter:=false;
  mUser := Self.BaseObjectSpace.CreateObject('22AHIVDVAVE13C5S00CA141B44');            // přihlášený uživatel
  try
      mUser.Load(Self.CompanyCache.GetUserID, nil);
            if mUser.GetFieldValueAsString('Name')='Supervisor' then mUserFilter:= true;
  finally
    mUser.Free;
  end;
  mMAction := Self.GetNewMultiAction;
  mMAction.ShowControl := True;
  mMAction.ShowMenuItem := True;
  mMAction.Caption := 'Hromadná změna';
  mMAction.Hint := 'Hromadná změna položek';
  mMAction.Category := 'tabList';
  mMAction.OnExecuteItem := @FVExecuteItem;
  mMAction.Items.Add('Změna objednávky');
  mMAction.Items.Add('Změna zakázky');
  mMAction.Items.Add('Změna smlouvy');
  mMAction.Items.Add('Změna data (v účetním roce)');
  mMAction.Items.Add('Změna umístění');
  mMAction.Items.Add('Změna dispečera');






end;



begin
end.