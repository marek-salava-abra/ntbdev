
var
mID_ML,mID_SL,mID_SP:string;
mIDs_ML,mIDs_SL,mIDs_SP:tstringlist;
mBookmarklist : TBookmarkList;


procedure PlanSLExecuteItem(Sender: TAction; Index: integer);
var
  xSite: TDynSiteForm;
  mDBGrid : TDBGrid;
    mTabList: TTabSheet;
  mCustomBusinessObject:TNxCustomBusinessObject;
  i:integer;
  mr:TStringList;
   mForm: TDynSiteForm;
   mMon,mRows_ML: TNxCustomBusinessMonikerCollection;
   mdate:double;
   mBookmarklist:TBookmarkList;
begin
    xSite := TComponent(Sender).DynSite;
    mTabList := TTabSheet(NxFindChildControl(xSite.MainPanel, 'tabList'));
    if mTabList = nil then RaiseException('tabList nenalezen');
    mDBGrid := TDBGrid(NxFindChildControl(mTabList, 'grdList'));
    if mDBGrid = nil then RaiseException('DBGrid nenalezen');
    if index =1 then mdate:= GetDate2(Sender,xSite);
       mBookmarklist := mDBGrid.SelectedRows; // *** v mBookmark jsou id označených záznamu
           if mBookmarklist.count=0 then begin
                   // jeden záznam
                        mCustomBusinessObject:= TDynSiteForm(xSite).CurrentObject;
                                if index =0 then mCustomBusinessObject.SetFieldValueAsDateTime('SheduledStart$Date',now);
                                if index =0 then mCustomBusinessObject.SetFieldValueAsDateTime('SheduledEnd$Date',now);

                                if index =1 then mCustomBusinessObject.SetFieldValueAsDateTime('SheduledStart$Date',mdate);
                                if index =1 then mCustomBusinessObject.SetFieldValueAsDateTime('SheduledEnd$Date',mdate);
                                mCustomBusinessObject.SetFieldValueAsInteger('status',1);
                        mCustomBusinessObject.save;
           end else begin
                   // více záznamu
                     for i := 0 to mBookmarklist.Count-1 do begin // projdu vsechny oznacene zaznamy
                        mDBGrid.DataSource.DataSet.GotoBookmark(mBookmarklist.items(i));
                              mCustomBusinessObject:= TDynSiteForm(xSite).CurrentObject;
                                  if index =0 then mCustomBusinessObject.SetFieldValueAsDateTime('SheduledStart$Date',now);
                                if index =0 then mCustomBusinessObject.SetFieldValueAsDateTime('SheduledEnd$Date',now);

                                if index =1 then mCustomBusinessObject.SetFieldValueAsDateTime('SheduledStart$Date',mdate);
                                if index =1 then mCustomBusinessObject.SetFieldValueAsDateTime('SheduledEnd$Date',mdate);
                               mCustomBusinessObject.SetFieldValueAsInteger('status',1);
                                mCustomBusinessObject.save;

                     end;
           end;
        TDynSiteForm(xSite).RefreshData;
end;



procedure EditSLExecuteItem(Sender: TAction; Index: integer);
var
  xSite: TDynSiteForm;
  mDBGrid : TDBGrid;
    mTabList: TTabSheet;
  mCustomBusinessObject:TNxCustomBusinessObject;
  i:integer;
  mr:TStringList;
   mForm: TDynSiteForm;
   mMon,mRows_ML: TNxCustomBusinessMonikerCollection;
   mdate:double;
   mBookmarklist:TBookmarkList;
begin
    xSite := TComponent(Sender).DynSite;
    mTabList := TTabSheet(NxFindChildControl(xSite.MainPanel, 'tabList'));
    if mTabList = nil then RaiseException('tabList nenalezen');
    mDBGrid := TDBGrid(NxFindChildControl(mTabList, 'grdList'));
    if mDBGrid = nil then RaiseException('DBGrid nenalezen');
    if index =1 then mdate:= GetDate2(Sender,xSite);
       mBookmarklist := mDBGrid.SelectedRows; // *** v mBookmark jsou id označených záznamu
           if mBookmarklist.count=0 then begin
                   // jeden záznam
                        mCustomBusinessObject:= TDynSiteForm(xSite).CurrentObject;
                        if index =0 then mCustomBusinessObject.SetFieldValueAsDateTime('RealStart$Date',mCustomBusinessObject.getFieldValueAsDateTime('SheduledStart$Date'));
                        if index =0 then mCustomBusinessObject.SetFieldValueAsDateTime('RealStart$Date',mCustomBusinessObject.getFieldValueAsDateTime('SheduledEnd$Date'));

                        if index =1 then mCustomBusinessObject.SetFieldValueAsDateTime('RealStart$Date',mdate);
                        if index =1 then mCustomBusinessObject.SetFieldValueAsDateTime('RealStart$Date',mdate);
                        mCustomBusinessObject.SetFieldValueAsInteger('status',2);
                        mCustomBusinessObject.save;
           end else begin
                   // více záznamu
                     for i := 0 to mBookmarklist.Count-1 do begin // projdu vsechny oznacene zaznamy
                        mDBGrid.DataSource.DataSet.GotoBookmark(mBookmarklist.items(i));
                              mCustomBusinessObject:= TDynSiteForm(xSite).CurrentObject;
                                  if index =0 then mCustomBusinessObject.SetFieldValueAsDateTime('RealStart$Date',mCustomBusinessObject.getFieldValueAsDateTime('SheduledStart$Date'));
                                if index =0 then mCustomBusinessObject.SetFieldValueAsDateTime('RealEnd$Date',mCustomBusinessObject.getFieldValueAsDateTime('SheduledEnd$Date'));

                                if index =1 then mCustomBusinessObject.SetFieldValueAsDateTime('RealStart$Date',mdate);
                                if index =1 then mCustomBusinessObject.SetFieldValueAsDateTime('RealStart$Date',mdate);
                               mCustomBusinessObject.SetFieldValueAsInteger('status',2);
                                mCustomBusinessObject.save;

                     end;
           end;
        TDynSiteForm(xSite).RefreshData;
end;

function GetDate2(Sender: Taction;xSite:TSiteForm) : Date;
var
  mForm : TForm;
  mBtn : TButton;
  mlb2 : TLabel;
  mEdtSrc:TDateEdit;
begin
        try
              mForm := TForm.create(xsite);            // formulář
                mForm.BorderIcons := [biSystemMenu];
                mForm.Width := 240;  // sirka
                mForm.Height := 100; // vyska
                mForm.Caption := 'Zadej datum školení';
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




procedure InitSite_Hook(Self: TSiteForm);
var
mAction: TAction;
  mMAction,mMAction1: TMultiAction;
  mUserFilter: Boolean;
  mUser: TNxCustomBusinessObject;
begin
  mUserFilter:=false;
  mUser := Self.BaseObjectSpace.CreateObject('22AHIVDVAVE13C5S00CA141B44');            // přihlášený uživatel
  try
      mUser.Load(Self.CompanyCache.GetUserID, nil);
            if mUser.GetFieldValueAsString('Name')='Supervisor' then mUserFilter:= true;
            if mUser.GetFieldValueAsString('Name')='Ludmila Fuksová' then mUserFilter:= true;

  finally
    mUser.Free;
  end;

  mMAction1 := Self.GetNewMultiAction;
  mMAction1.ShowControl := True;
  mMAction1.ShowMenuItem := True;
  mMAction1.Caption := 'Zajištění školení';
  mMAction1.Hint := 'Zajištění školení';
  mMAction1.Category := 'tabList';
  mMAction1.OnExecuteItem := @PlanSLExecuteItem;
  mMAction1.Items.Add('Zajištění šklení podle plánu');
  mMAction1.Items.Add('Zajištění školení podle data');



  mMAction1 := Self.GetNewMultiAction;
  mMAction1.ShowControl := True;
  mMAction1.ShowMenuItem := True;
  mMAction1.Caption := 'Ukončení školení';
  mMAction1.Hint := 'Ukončení školení';
  mMAction1.Category := 'tabList';
  mMAction1.OnExecuteItem := @EDITSLExecuteItem;
  mMAction1.Items.Add('Ukončení školení podle plánu');
  mMAction1.Items.Add('Ukončení školení podle data');




end;





begin
end.