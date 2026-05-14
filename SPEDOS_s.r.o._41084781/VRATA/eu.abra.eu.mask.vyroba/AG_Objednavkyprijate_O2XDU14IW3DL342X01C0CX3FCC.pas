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
    mEdtSNSrc:tedit;
begin
 mSite := NxFindSiteForm(Sender);
 mForm := TForm.Create(Sender);
  mForm.BorderIcons := [biSystemMenu];
  mForm.Width := 400;  // sirka
  mForm.Height := 240; // vyska
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


  mRg := TRadioGroup.Create(mForm);
  mRg.Left := 15;
  mRg.Top := 100;
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



  try
      if mRbS.Checked then begin
        mDBGrid := TMultiGrid(NxFindChildControl(TDynSiteForm(NxFindSiteForm(Sender)).MainPanel, 'grdRows'));
        mBookmark := mDBGrid.SelectedRows;
        //if Assigned(mBookmark) and (mBookMark.Count > 0) then begin
          {mActualRow := mDBGrid.DataSource.DataSet.GetBookmark;
          for i := 0 to mBookMark.Count - 1 do begin
            mDBGrid.DataSource.DataSet.GotoBookmark(mBookMark.items(i));
            mDBGrid.DataSource.DataSet.Edit;

                  try
                              if mEdtSNSrc.text<>'' then mDBGrid.DataSource.DataSet.FieldByName('U_UserSerialNumber').AsString := mEdtSNSrc.text;
                              if mEdtvyrSrc.Date<> 0 then mDBGrid.DataSource.DataSet.FieldByName('U_ProductionDate').AsDateTime:= mEdtvyrSrc.Date;
                              if mEdtvyrSrc.Date<> 0 then mDBGrid.DataSource.DataSet.FieldByName('U_MakeDate').AsDateTime:= mEdtvyrSrc.Date;
                  finally

                  end;

            mDBGrid.DataSource.DataSet.Cancel;
          end;
          mDBGrid.DataSource.DataSet.GotoBookmark(mActualRow);
        end else begin

        end}
        NxShowSimpleMessage('Funkce umožňuje zápis položek pouze do všech řádků',nil) ;
      end;
      if mRbA.Checked then begin
        mBO := TDynSiteForm(NxFindSiteForm(Sender)).CurrentObject;
        mMon := mBO.GetLoadedCollectionMonikerForFieldCode(mBO.GetFieldCode('ROWS'));
        for i := 0 to mMon.Count - 1 do begin
            if mEdtSNSrc.text<>'' then mMon.BusinessObject[i].SetFieldValueAsString('U_UserSerialNumber',mEdtSNSrc.text);
            if mEdtvyrSrc.Date<> 0 then mMon.BusinessObject[i].SetFieldValueAsDateTime('U_ProductionDate',mEdtvyrSrc.Date);
            if mEdtvyrSrc.Date<> 0 then mMon.BusinessObject[i].SetFieldValueAsDateTime('U_MakeDate',mEdtvyrSrc.Date);


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
   // if mUserFilter then begin
        mAction := Self.GetNewAction;
        mAction.ShowControl := True;
        mAction.ShowMenuItem := True;
        mAction.Caption := 'Výrobní parametry';
        mAction.Hint := 'Výrobní paramaetry';
        mAction.Category := 'tabDetail';
        mAction.OnExecute := @RowVyrOperationOnExecute;
   // end;



end;



begin
end.