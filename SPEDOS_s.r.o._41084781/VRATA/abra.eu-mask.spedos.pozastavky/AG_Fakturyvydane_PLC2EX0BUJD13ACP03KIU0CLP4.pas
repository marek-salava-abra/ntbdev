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

procedure OnPozastavka(Sender: TComponent;index:integer;);       // přidělení objectspace a zadání zdrojového souboru
var
    zadej:string;
    mfilename:string;
    mdir,mfile:string;
    mfilter:string;
    mresult:Boolean;
    mStringlist:TStringList;
    mid:string;
    mid_report:string;
    mi:integer;
    adir,afilename:string;
mOLE, mRoll, mOResult: Variant;
mUser, mpozastavky:TNxCustomBusinessObject;
mpocet:string;
mzruseni:boolean;
stav:boolean;
mcastka:string;
mB_result:boolean;
mdate:double;
begin
        mcastka:='0';
        mSite := NxFindSiteForm(Sender);
        mTabList := TTabSheet(NxFindChildControl(mSite.MainPanel, 'tabList'));
        if mTabList = nil then RaiseException('tabList nenalezen');
        mDBGrid := TDBGrid(NxFindChildControl(mTabList, 'grdList'));
        if mDBGrid = nil then RaiseException('DBGrid nenalezen');
        mB_result:=true;
        mdate:=int(GetDate(Sender,mSite));

        mpozastavky:=msite.BaseObjectSpace.CreateObject('KEZSE3CFWUM4RDVLZUTTLXK2C0');
        try
                    mBookmarkList := mDBGrid.SelectedRows; // *** v mBookmark jsou id označených záznamu

                      if mBookmarkList.count=0 then begin
                          mCustomBusinessObject:= TDynSiteForm(mSite).CurrentObject;
                              mB_result:= InputQuery('Zadej pozastávku','Částka ',mcastka) ;
                                if mb_result then begin
                                    mpozastavky.New;
                                    mpozastavky.Prefill;
                                    mpozastavky.SetFieldValueAsDateTime('X_ABRADate',now());
                                    mpozastavky.SetFieldValueAsstring('X_field1',mcastka);
                                    mpozastavky.SetFieldValueAsstring('X_field2','Test pozastávky');
                                    mpozastavky.SetFieldValueAsstring('X_id',TDynSiteForm(mSite).CurrentObject.oid);
                                    mpozastavky.save;

                                end;

                    end else begin
                         for i := 0 to mBookmarkList.Count-1 do begin // projdu vsechny oznacene zaznamy
                              mDBGrid.DataSource.DataSet.GotoBookmark(mBookmarkList.items(i));
                                  mCustomBusinessObject:= TDynSiteForm(mSite).CurrentObject;
                                  mB_result:= InputQuery('Zadej pozastávku','Částka ',mcastka) ;
                                      if mb_result then begin
                                          mpozastavky.New;
                                          mpozastavky.Prefill;
                                          mpozastavky.SetFieldValueAsDateTime('X_ABRADate',now());
                                          mpozastavky.SetFieldValueAsstring('X_field1',mcastka);
                                          mpozastavky.SetFieldValueAsstring('X_field2','Test pozastávky');
                                          mpozastavky.SetFieldValueAsstring('X_id',TDynSiteForm(mSite).CurrentObject.oid);
                                          mpozastavky.save;

                                      end;

                         end;
                    end;
        finally
            mpozastavky.free;
        end;

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
          mMAction := Self.GetNewMultiAction;
          mMAction.ShowControl := True;
          mMAction.ShowMenuItem := True;
          mMAction.Hint := 'Zadání pozastávky';
          mMAction.Caption := 'Zadání pozastávky';
          mMAction.Category := 'tabList';
          mMAction.OnExecuteItem := @OnPozastavka;

end;

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

begin
end.