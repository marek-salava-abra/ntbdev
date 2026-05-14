  procedure iFillStores(AOS : TNxCustomObjectSpace; AList : Tstrings);
  const
    cSQL = 'SELECT Code FROM BusOrders WHERE Hidden=''N'' ORDER BY Code';
  begin
    AOS.SQLSelect(cSQL, AList);
  end;



procedure RowOperationOnExecute(Sender: TAction);
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
begin
 mSite := NxFindSiteForm(Sender);
 mForm := TForm.Create(Sender);
  mForm.BorderIcons := [biSystemMenu];
  mForm.Width := 240;  // sirka
  mForm.Height := 170; // vyska
  mForm.Caption := 'Nastanení zakazky';

  mLbl := TLabel.Create(mForm);
  mLbl.Caption := 'Zakázka:';
  mLbl.Left := 30;
  mLbl.Top := 10;
  mLbl.Name := 'lblStore';
  mForm.InsertControl(mLbl);

      cbStores := TComboBox.Create(mForm);
      cbStores.Left := 100;
      cbStores.Top := 10;
      cbStores.Width := 80;
      cbStores.Name := 'cbStore';
      cbStores.Text := '';
      mForm.InsertControl(cbStores);
      iFillStores(TDynSiteForm(NxFindSiteForm(Sender)).CurrentObject.ObjectSpace, cbStores.Items);
      if cbStores.Items.Count >= 0 then begin
        cbStores.ItemIndex := 0;
      end;


  mRg := TRadioGroup.Create(mForm);
  mRg.Left := 15;
  mRg.Top := 40;
  mRg.Height := 60;
  mRg.Caption := 'Pro řádky';
  mRg.Name := 'rgChoiceRows';

  mRbS := TRadioButton.Create(mRg);
  mRbS.Name := 'rbSelected';
  mRbS.Caption := 'označené';
  mRbS.Left := 50;
  mRbS.Top := 20;
  mRg.InsertControl(mRbS);

  mRbA := TRadioButton.Create(mRg);
  mRbA.Name := 'rbAll';
  mRbA.Caption := 'všechny';
  mRbA.Checked := True;
  mRbA.Left := 50;
  mRbA.Top := 40;
  mRg.InsertControl(mRbA);

  mForm.InsertControl(mRg);

  mBtn := TButton.Create(mForm);
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

  mBtn := TButton.Create(mForm);
  mBtn.Width := 75;
  mBtn.Height := 25;
  mBtn.Caption := 'Storno';
  mBtn.ModalResult := mrCancel;
  mBtn.Cancel := True;
  mBtn.Left := mForm.Width - (mBtn.Width+2) - 20;;
  mBtn.Top := mForm.Height - mBtn.Height - 40;
  mBtn.Name := 'btnCancel';
  mForm.InsertControl(mBtn);

  if mForm.ShowModal(mSite) = mrOK then begin


  try
      if mRbS.Checked then begin
        mDBGrid := TMultiGrid(NxFindChildControl(TDynSiteForm(NxFindSiteForm(Sender)).MainPanel, 'grdRows'));
        mBookmark := mDBGrid.SelectedRows;
        if Assigned(mBookmark) and (mBookMark.Count > 0) then begin
          mActualRow := mDBGrid.DataSource.DataSet.GetBookmark;
          for i := 0 to mBookMark.Count - 1 do begin
            mDBGrid.DataSource.DataSet.GotoBookmark(mBookMark.items(i));
            mDBGrid.DataSource.DataSet.Edit;
            mDBGrid.DataSource.DataSet.FieldByName('BusOrder_ID').AsString := iGetIDByCode(TDynSiteForm(NxFindSiteForm(Sender)).CurrentObject.ObjectSpace, 'BusOrders', cbStores.Text);
//            mStore

            mDBGrid.DataSource.DataSet.Cancel;
          end;
          mDBGrid.DataSource.DataSet.GotoBookmark(mActualRow);
        end
      end;
      if mRbA.Checked then begin
        mBO := TDynSiteForm(NxFindSiteForm(Sender)).CurrentObject;
        mMon := mBO.GetLoadedCollectionMonikerForFieldCode(mBO.GetFieldCode('ROWS'));
        for i := 0 to mMon.Count - 1 do begin
          mMon.BusinessObject[i].SetFieldValueAsString('BusOrder_ID', iGetIDByCode(TDynSiteForm(NxFindSiteForm(Sender)).CurrentObject.ObjectSpace, 'BusOrders', cbStores.Text));
//  mStore

        end;

      end;

   if Assigned(mDBGrid) then mDBGrid.DataSource.DataSet.Refresh;


  finally
     begin
     end;
  end;



  end;
end;






{
Vyvolává se po vytvoření instance formuláře.
}
procedure FormCreate_Hook(Self: TSiteForm);
var

  mAction: TBasicAction;
  i: integer;
  mAct: TBasicAction;
begin


end;




function iGetIDByCode(AOS : TNxCustomObjectSpace; const ATableName : string; ACode : string) : TNxOID;
const
  cSQL = 'SELECT ID FROM %s WHERE Code=''%s'' AND Hidden=''N''';
var
  mR : TStrings;
begin
  Result := '';
  mR := TStringlist.Create;
  try
    AOS.SQLSelect(Format(cSQL, [ATableName, ACode]), mR);
    if mR.Count > 0 then
      Result := mR.strings[0];
  finally
    mR.Free;
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
    if mUserFilter then begin
        mAction := Self.GetNewAction;
        mAction.ShowControl := True;
        mAction.ShowMenuItem := True;
        mAction.Caption := 'Oprava zakázky';
        mAction.Hint := 'Oprava zakázky';
        mAction.Category := 'tabDetail';
        mAction.OnExecute := @RowOperationOnExecute;
    end;



end;



begin
end.