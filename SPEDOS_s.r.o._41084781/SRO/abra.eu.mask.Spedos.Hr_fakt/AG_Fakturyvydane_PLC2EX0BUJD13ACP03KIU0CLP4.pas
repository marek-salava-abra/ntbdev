Var
    mSite: TSiteForm;
    mDBGrid : TDBGrid;
    mTabList: TTabSheet;
    mCustomBusinessObject: TNxCustomBusinessObject;

    mHeaderBusinessObject : TNxHeaderBusinessObject;
    i : integer;
    mResult:Boolean;
    mBookmarkList:TBookmarkList ;
    aid:string;

function GetDate(Sender: TComponent;xSite:TSiteForm) : Date;
var
  mForm : TForm;
  mBtn : TButton;
  mlb2 : TLabel;
  mEdtSrc:TDateEdit;
begin
        try
              mForm := TForm.Create(xSite);            // formulář
                mForm.BorderIcons := [biSystemMenu];
                mForm.Width := 240;  // sirka
                mForm.Height := 100; // vyska
                mForm.Caption := 'Zadej datum servisu';
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
                        mEdtSrc.Date:= date;
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

           if mForm.ShowModal(xSite) = mrOK then begin
                result:=mEdtSrc.Date;
           end;
        finally;
          mForm.Free;
        end;
end;


procedure OnExec(Sender: TComponent;index:integer;);       // přidělení objectspace a zadání zdrojového souboru
var
    zadej:string;
    mfilename:string;
    mdir,mfile:string;
    mfilter:string;
    mresult:Boolean;
    mStringlist:TStringList;
    mid:string;
    adir:string;
    mid_report:string;
    mi:integer;
mOLE, mRoll, mOResult: Variant;
mUser:TNxCustomBusinessObject;
mpocet:string;
mzruseni:boolean;
mCustomBusinessObject,mNewCustomBusinessObject:TNxCustomBusinessObject;
mdate:double;
mMon:TNxCustomBusinessMonikerCollection;
jj:integer;
begin
        mSite := NxFindSiteForm(Sender);
        mTabList := TTabSheet(NxFindChildControl(mSite.MainPanel, 'tabList'));
        if mTabList = nil then RaiseException('tabList nenalezen');
        mDBGrid := TDBGrid(NxFindChildControl(mTabList, 'grdList'));
        if mDBGrid = nil then RaiseException('DBGrid nenalezen');

        mdate:=GetDate(Sender,mSite);


        mBookmarkList := mDBGrid.SelectedRows; // *** v mBookmark jsou id označených záznamu

          if mBookmarkList.count=0 then begin
              mCustomBusinessObject:= TDynSiteForm(mSite).CurrentObject;
              mNewCustomBusinessObject:=mCustomBusinessObject.Clone ;
              mNewCustomBusinessObject.Prefill;

              mNewCustomBusinessObject.SetFieldValueAsstring('Docqueue_ID','1V00000101');
              mNewCustomBusinessObject.SetFieldValueAsDateTime('Docdate$date',mdate);
              mNewCustomBusinessObject.SetFieldValueAsstring('Firm_ID',mCustomBusinessObject.getFieldValueAsstring('Firm_ID'));
              mNewCustomBusinessObject.SetFieldValueAsstring('FirmOffice_ID',mCustomBusinessObject.getFieldValueAsstring('FirmOffice_ID'));
              mNewCustomBusinessObject.SetFieldValueAsstring('Person_ID',mCustomBusinessObject.getFieldValueAsstring('Person_ID'));
               if UpperCase(copy(mNewCustomBusinessObject.getFieldValueAsstring('Description'),1,6))='SLUŽBY' then mNewCustomBusinessObject.SetFieldValueAsstring('Description','Služby  ' + NxFloatToIBStr(MonthOfTheYear(mdate))+ '/' + NxFloatToIBStr(YearOf(mdate)));
              if UpperCase(copy(mNewCustomBusinessObject.getFieldValueAsstring('Description'),1,5))='NÁJEM' then mNewCustomBusinessObject.SetFieldValueAsstring('Description','Nájem  ' + NxFloatToIBStr(MonthOfTheYear(mdate))+ '/' + NxFloatToIBStr(YearOf(mdate)));
              if UpperCase(copy(mNewCustomBusinessObject.getFieldValueAsstring('Description'),1,8))='POPLATEK' then mNewCustomBusinessObject.SetFieldValueAsstring('Description','Poplatek k ochranné známce za  ' + NxFloatToIBStr(MonthOfTheYear(mdate))+ '/' + NxFloatToIBStr(YearOf(mdate)));
             if UpperCase(copy(mNewCustomBusinessObject.getFieldValueAsstring('Description'),1,10))='VYÚČTOVÁNÍ' then mNewCustomBusinessObject.SetFieldValueAsstring('Description','Vyúčtování za média ' + NxFloatToIBStr(MonthOfTheYear(mdate))+ '/' + NxFloatToIBStr(YearOf(mdate)));

              mMon := mNewCustomBusinessObject.GetLoadedCollectionMonikerForFieldCode(mNewCustomBusinessObject.GetFieldCode('ROWS'));
                              for jj := 0 to mMon.Count-1 do begin
                                 if mMon.BusinessObject[jj].GetFieldValueAsInteger('rowtype')=1 then begin
                                    if  UpperCase(copy(mMon.BusinessObject[jj].GetFieldValueAsString('Text'),1,5))='NÁJEM' then begin
                                         mMon.BusinessObject[jj].SetFieldValueAsString('Text','Nájem ' + NxFloatToIBStr(MonthOfTheYear(mdate))+ '/' + NxFloatToIBStr(YearOf(mdate)));
                                    end;
                                 end;
                                 if mMon.BusinessObject[jj].GetFieldValueAsInteger('rowtype')=0 then begin
                                    if  UpperCase(copy(mMon.BusinessObject[jj].GetFieldValueAsString('Text'),1,5))='MĚSÍC' then begin
                                          mMon.BusinessObject[jj].SetFieldValueAsString('Text','měsíc: ' + NxFloatToIBStr(MonthOfTheYear(mdate))+ '/' + NxFloatToIBStr(YearOf(mdate)));
                                    end;
                                    if  UpperCase(copy(mMon.BusinessObject[jj].GetFieldValueAsString('Text'),1,30))='FAKTURUJEME VÁM ZA MÉDIA A SLU' then begin
                                          mMon.BusinessObject[jj].SetFieldValueAsString('Text','Fakturujeme Vám za média a služby  ' + NxFloatToIBStr(MonthOfTheYear(mdate))+ '/' + NxFloatToIBStr(YearOf(mdate))
                                          + ' v Novém Jičíně');
                                    end;
                                 end;
                             end;

          //    mNewCustomBusinessObject.save;
          //  TDynSiteForm.ShowDynFormWithNewDocument('PLC2EX0BUJD13ACP03KIU0CLP4', msite.SiteContext, mNewCustomBusinessObject);
          mNewCustomBusinessObject.save;
        end else begin
             for i := 0 to mBookmarkList.Count-1 do begin // projdu vsechny oznacene zaznamy
                  mDBGrid.DataSource.DataSet.GotoBookmark(mBookmarkList.items(i));
                      mCustomBusinessObject:= TDynSiteForm(mSite).CurrentObject;
              mNewCustomBusinessObject:=mCustomBusinessObject.Clone ;
              mNewCustomBusinessObject.Prefill;

              mNewCustomBusinessObject.SetFieldValueAsstring('Docqueue_ID','1V00000101');
              mNewCustomBusinessObject.SetFieldValueAsDateTime('Docdate$date',mdate);
              mNewCustomBusinessObject.SetFieldValueAsstring('Firm_ID',mCustomBusinessObject.getFieldValueAsstring('Firm_ID'));
              mNewCustomBusinessObject.SetFieldValueAsstring('FirmOffice_ID',mCustomBusinessObject.getFieldValueAsstring('FirmOffice_ID'));
              mNewCustomBusinessObject.SetFieldValueAsstring('Person_ID',mCustomBusinessObject.getFieldValueAsstring('Person_ID'));

              if UpperCase(copy(mNewCustomBusinessObject.getFieldValueAsstring('Description'),1,6))='SLUŽBY' then mNewCustomBusinessObject.SetFieldValueAsstring('Description','Služby  ' + NxFloatToIBStr(MonthOfTheYear(mdate))+ '/' + NxFloatToIBStr(YearOf(mdate)));
              if UpperCase(copy(mNewCustomBusinessObject.getFieldValueAsstring('Description'),1,5))='NÁJEM' then mNewCustomBusinessObject.SetFieldValueAsstring('Description','Nájem  ' + NxFloatToIBStr(MonthOfTheYear(mdate))+ '/' + NxFloatToIBStr(YearOf(mdate)));

              if UpperCase(copy(mNewCustomBusinessObject.getFieldValueAsstring('Description'),1,8))='POPLATEK' then mNewCustomBusinessObject.SetFieldValueAsstring('Description','Poplatek k ochranné známce za  ' + NxFloatToIBStr(MonthOfTheYear(mdate))+ '/' + NxFloatToIBStr(YearOf(mdate)));
             if UpperCase(copy(mNewCustomBusinessObject.getFieldValueAsstring('Description'),1,10))='VYÚČTOVÁNÍ' then mNewCustomBusinessObject.SetFieldValueAsstring('Description','Vyúčtování za média ' + NxFloatToIBStr(MonthOfTheYear(mdate))+ '/' + NxFloatToIBStr(YearOf(mdate)));


              mMon := mNewCustomBusinessObject.GetLoadedCollectionMonikerForFieldCode(mNewCustomBusinessObject.GetFieldCode('ROWS'));
                              for jj := 0 to mMon.Count-1 do begin

                              if mMon.BusinessObject[jj].GetFieldValueAsInteger('rowtype')=1 then begin
                                    if  UpperCase(copy(mMon.BusinessObject[jj].GetFieldValueAsString('Text'),1,5))='NÁJEM' then begin
                                         mMon.BusinessObject[jj].SetFieldValueAsString('Text','Nájem ' + NxFloatToIBStr(MonthOfTheYear(mdate))+ '/' + NxFloatToIBStr(YearOf(mdate)));
                                    end;
                              End ;
                              if mMon.BusinessObject[jj].GetFieldValueAsInteger('rowtype')=0 then begin


                                 if  UpperCase(copy(mMon.BusinessObject[jj].GetFieldValueAsString('Text'),1,5))='MĚSÍC' then begin
                                          mMon.BusinessObject[jj].SetFieldValueAsString('Text','měsíc: ' + NxFloatToIBStr(MonthOfTheYear(mdate))+ '/' + NxFloatToIBStr(YearOf(mdate)));
                                    end;
                                    if  UpperCase(copy(mMon.BusinessObject[jj].GetFieldValueAsString('Text'),1,30))='FAKTURUJEME VÁM ZA MÉDIA A SLU' then begin
                                          mMon.BusinessObject[jj].SetFieldValueAsString('Text','Fakturujeme Vám za média a služby  ' + NxFloatToIBStr(MonthOfTheYear(mdate))+ '/' + NxFloatToIBStr(YearOf(mdate))
                                          + ' v Novém Jičíně');
                                    end;
                                 end;
                             end;

          //    mNewCustomBusinessObject.save;
          //TDynSiteForm.ShowDynFormWithNewDocument('PLC2EX0BUJD13ACP03KIU0CLP4', msite.SiteContext, mNewCustomBusinessObject);
          mNewCustomBusinessObject.save;

             End;
        end;
        msite.Refresh;
        mDBGrid.Refresh;
        mDBGrid.DataSource.DataSet.Refresh;
end;





procedure InitSite_Hook(Self: TSiteForm);
var
  mAction: TBasicAction;
  mMAction: TMultiAction;
  mCAction: TBasicAction;
  mAList: TActionList;
  i : integer;
  mUserFilter:Boolean;
  mUserFilterTL:string;
  muser:TNxCustomBusinessObject;
begin
    mUserFilter:=true;
    mUser := Self.BaseObjectSpace.CreateObject('22AHIVDVAVE13C5S00CA141B44');
    try
      mUser.Load(Self.CompanyCache.GetUserID, nil);
            mUserFilter:= true; //mUser.GetFieldValueAsBoolean('X_archiv');


//        if muser.GetFieldValueAsBoolean('X_Archiv') then begin
          mMAction := Self.GetNewMultiAction;
          mMAction.ShowControl := True;
          mMAction.ShowMenuItem := True;
          mMAction.Hint := 'Hromadná fakturace';
          mMAction.Caption := 'Hromadná fakturace';
          mMAction.Items.Add('Hromadná fakturace');
          mMAction.Category := 'tabList';
          mMAction.OnExecuteItem := @OnExec;
  //      end;

     finally
      mUser.Free;
     end;
end;


begin
end.