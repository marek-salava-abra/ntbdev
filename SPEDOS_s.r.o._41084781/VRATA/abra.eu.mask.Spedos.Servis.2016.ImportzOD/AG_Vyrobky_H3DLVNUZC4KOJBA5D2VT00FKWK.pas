





  procedure iFillStores(AOS : TNxCustomObjectSpace; AList : Tstrings);
  const
    cSQL = 'SELECT Code FROM BusOrders WHERE Hidden=''N'' ORDER BY Code';
  begin
    AOS.SQLSelect(cSQL, AList);
  end;



procedure RowVyrOperationOnExecute(Sender: TAction);
var
  mSite : TSiteForm;
  mForm : TForm;
  mBtn : TButton;
  mLbl : TLabel;
  cbStores : TComboBox;
  mRg : TRadioGroup;
  mRbS, mRbA : TRadioButton;
  mBookmark : TNxBookmarkList;
  mDBGrid : TMultiGrid;
  mActualRow : TBookmark;
  i : integer;
  mBO : TNxCustomBusinessObject;
  mMon : TNxCustomBusinessMonikerCollection;
    mEdtDatvyrSrc,mEdtvyrSrc:TDateEdit;
    mEdtSNSrc,mEdtPrislusenstvi,mEdtBarva:tedit;
mTabList: TTabSheet;
mxDBGrid : TDBGrid;
mBookmarkList:TBookmarkList;
mdelka, mcislo:integer;
mzaklad:string;
begin

        mSite := NxFindSiteForm(Sender);
        mTabList := TTabSheet(NxFindChildControl(mSite.MainPanel, 'tabList'));
        if mTabList = nil then RaiseException('tabList nenalezen');
        mxDBGrid := TDBGrid(NxFindChildControl(mTabList, 'grdList'));
        if mxDBGrid = nil then RaiseException('DBGrid nenalezen');




                    mBookmarkList := mxDBGrid.SelectedRows; // *** v mBookmark jsou id označených záznamu


 mForm := TForm.Create(Sender);
try
  mForm.BorderIcons := [biSystemMenu];
  mForm.Width := 400;  // sirka
  mForm.Height := 300; // vyska
  mForm.Caption := 'Nastanení zakazky';

  mLbl := TLabel.Create(mForm);
  mLbl.Caption := 'Výrobní číslo:';
  mLbl.Left := 30;
  mLbl.Top := 10;
  mLbl.Name := 'lblStore';
  mForm.InsertControl(mLbl);

      mEdtSNSrc := TEdit.Create(mForm);
      mEdtSNSrc.Left := 120;
      mEdtSNSrc.Top := 10;
      mEdtSNSrc.Width := 200;
      mEdtSNSrc.Name := 'mEdtSNSrc';
      mEdtSNSrc.Text := '';
      mForm.InsertControl(mEdtSNSrc);


      mLbl := TLabel.Create(mForm);
  mLbl.Caption := 'Datum výroby:';
  mLbl.Left := 30;
  mLbl.Top := 40;
  mLbl.Name := 'lbldatvyr';
  mForm.InsertControl(mLbl);

  mEdtDatvyrSrc:= TDateEdit.Create(mForm);
                        mEdtDatvyrSrc.Left := 120;
                        mEdtDatvyrSrc.Top := 40;
                        mEdtDatvyrSrc.Width := 100;
                        mEdtDatvyrSrc.Name := 'mEdtDatvyrSrc';
                        mEdtDatvyrSrc.Date:= 0;
                        mForm.InsertControl(mEdtDatvyrSrc);



  mLbl := TLabel.Create(mForm);
  mLbl.Caption := 'Vyrobeno:';
  mLbl.Left := 30;
  mLbl.Top := 70;
  mLbl.Name := 'lblvyrobeno';
  mForm.InsertControl(mLbl);

   mEdtvyrSrc:= TDateEdit.Create(mForm);
                        mEdtvyrSrc.Left := 120;
                        mEdtvyrSrc.Top := 70;
                        mEdtvyrSrc.Width := 100;
                        mEdtvyrSrc.Name := 'mEdtvyrSrc';
                        mEdtvyrSrc.Date:= 0;
                        mForm.InsertControl(mEdtvyrSrc);

  mLbl := TLabel.Create(mForm);
  mLbl.Caption := 'Příslušenství:';
  mLbl.Left := 30;
  mLbl.Top := 100;
  mLbl.Name := 'lblStore1';
  mForm.InsertControl(mLbl);

      mEdtPrislusenstvi := TEdit.Create(mForm);
      mEdtPrislusenstvi.Left := 120;
      mEdtPrislusenstvi.Top := 100;
      mEdtPrislusenstvi.Width := 200;
      mEdtPrislusenstvi.Name := 'mEdtPrislusenstvi';
      mEdtPrislusenstvi.Text := '';
      mForm.InsertControl(mEdtPrislusenstvi);

  mLbl := TLabel.Create(mForm);
  mLbl.Caption := 'Barva :';
  mLbl.Left := 30;
  mLbl.Top := 130;
  mLbl.Name := 'lblStore2';
  mForm.InsertControl(mLbl);

      mEdtBarva := TEdit.Create(mForm);
      mEdtBarva.Left := 120;
      mEdtBarva.Top := 130;
      mEdtBarva.Width := 200;
      mEdtBarva.Name := 'mEdtBarva';
      mEdtBarva.Text := '';
      mForm.InsertControl(mEdtBarva);

  mBtn := TButton.Create(mForm);
  mBtn.Width := 160;
  mBtn.Height := 25;
  mBtn.Caption := 'OK';
  mBtn.ModalResult := mrOk;
  mBtn.Cancel := False;
  mBtn.Default := True;
  mBtn.Left :=  mForm.Width - 2*(mBtn.Width+2) - 20;
  mBtn.Top := mForm.Height - mBtn.Height - 40;
  mBtn.Name := 'btnOK';
  mForm.InsertControl(mBtn);

  mBtn := TButton.Create(mForm);
  mBtn.Width := 160;
  mBtn.Height := 25;
  mBtn.Caption := 'Storno';
  mBtn.ModalResult := mrCancel;
  mBtn.Cancel := True;
  mBtn.Left := mForm.Width - (mBtn.Width+2) - 20;;
  mBtn.Top := mForm.Height - mBtn.Height - 40;
  mBtn.Name := 'btnCancel';
  mForm.InsertControl(mBtn);

  if mForm.ShowModal(mSite) = mrOK then begin

             if mBookmarkList.count=0 then begin
                                        mBO := TBusRollSiteForm(mSite).CurrentObject;
                                             mBO.SetFieldValueAsString('Name',mEdtSNSrc.Text);
                                             mBO.SetFieldValueAsDateTime('X_Datum_vyroby$date',mEdtDatvyrSrc.Date);
                                             mBO.SetFieldValueAsDateTime('X_Vyrobeno$date',mEdtvyrSrc.Date);
                                             mBO.SetFieldValueAsString('X_field1',mEdtBarva.Text);
                                             mBO.SetFieldValueAsString('X_ISIRDATA',copy(mEdtPrislusenstvi.Text,1,254));
                                             mBO.setfieldvalueasstring('X_field4',msite.CompanyCache.GetUserID);
                                        mbo.save;

                                    end else begin
                                        mdelka:=Length(mEdtSNSrc.Text);
                                        mzaklad:=copy(mEdtSNSrc.Text,1,mdelka-4) ;
                                        mcislo:=StrToInt(NxRight(mEdtSNSrc.Text,4));
                                        for i := 0 to mBookmarkList.Count-1 do begin // projdu vsechny oznacene zaznamy
                                                mxDBGrid.DataSource.DataSet.GotoBookmark(mBookmarkList.items(i));
                                                mBO := TBusRollSiteForm(mSite).CurrentObject;

                                                        mBO.SetFieldValueAsString('Name',mzaklad + RightStr('0000' + inttostr(mcislo + i),4));
                                                        mBO.SetFieldValueAsDateTime('X_Datum_vyroby$date',mEdtDatvyrSrc.Date);
                                                        mBO.SetFieldValueAsDateTime('X_Vyrobeno$date',mEdtvyrSrc.Date);
                                                        mBO.SetFieldValueAsString('X_field1',mEdtBarva.Text);
                                             mBO.SetFieldValueAsString('X_ISIRDATA',copy(mEdtPrislusenstvi.Text,1,254));
                                             mBO.setfieldvalueasstring('X_field4',msite.CompanyCache.GetUserID);
                                                mBO.save
                                        end;
                                    end;




      end;


   if Assigned(mxDBGrid) then mxDBGrid.DataSource.DataSet.Refresh;


  finally
    mform.free;
  end;


end;





  {
Vyvoláva sa po vykonaní inicializácie agendy/formulára. V tomto okamihu je už na formulári dostupný SiteContext.
}
procedure InitSite_Hook(Self: TSiteForm);
var
  mAction: TBasicAction;
  mMAction: TMultiAction;
  mCAction: TBasicAction;
  mAList: TActionList;
  i : integer;
  mUserFilter: Boolean;
  mUser: TNxCustomBusinessObject;
begin
  mUser := Self.BaseObjectSpace.CreateObject('22AHIVDVAVE13C5S00CA141B44');            // přihlášený uživatel
  try
      mUser.Load(Self.CompanyCache.GetUserID, nil);
            mUserFilter:= mUser.GetFieldValueAsBoolean('X_Hr_zmena_zakazky');

  finally
    mUser.Free;
  end;


  // Vytorime novou jednoduchou akci                 tlačítka pro uživatele
   // if mUserFilter then begin
        mAction := Self.GetNewAction;
        mAction.ShowControl := True;
        mAction.ShowMenuItem := True;
        mAction.Caption := 'Výrobní parametry';
        mAction.Hint := 'Výrobní paramaetry';
        mAction.Category := 'tablist';
        mAction.OnExecute := @RowVyrOperationOnExecute;
   // end;



end;









begin
end.
