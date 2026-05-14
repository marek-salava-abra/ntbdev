procedure InitSite_Hook(Self: TBusRollSiteForm);
var
  mControl: TControl;
  s: string;
  mAction:TBasicAction;
begin
  if not Assigned(Self.BaseObjectSpace) then
    exit;

    mAction := Self.GetNewAction;
    mAction.ShowControl := True;
    mAction.ShowMenuItem := True;
    mAction.Caption := 'VIP výběr';
    mAction.ShortCut := TextToShortCut('Ctrl+B'); //16450;
    mAction.Hint := 'Dohledá firmu';
    mAction.Category := 'tabDetail';
    mAction.OnExecute := @SearchVIP;


end;

procedure SearchVIP(Sender : TComponent);
const
  cSQL_PPL = 'select fp.parent_id from firmpersons fp left join addresses a on a.id=fp.address_id where a.phonenumber2 = ''%s'' ';
  cSQL_PPL2 = 'select fp.person_ID from firmpersons fp left join addresses a on a.id=fp.address_id where a.phonenumber2 = ''%s'' ';
var
  mStrBatchCode, mOID : string;
  mSite: TSiteForm;
  mGrid : TDBGrid;
  mActiveDataSet : TNxDataDataSet;
  SL, SL2 : TStringList;
  i : integer;
  mBO, mCurrentBO:TNxCustomBusinessObject;
begin
  mSite := tcomponent(Sender).DynSite;
  if not VipDialog(mStrBatchCode, mSite) then
    exit;

  mGrid := TDBGrid(NxFindChildControl(mSite.MainPanel, 'grdList'));
  if not Assigned(mGrid) then begin
    NxShowMessage('info','Nenalezen dbgrid řádků.',mdInformation,false,mSite);
    exit;
  end;
  mActiveDataSet := TNxDataDataSet(mGrid.DataSource.DataSet);
  mActiveDataSet.DisableControls;
  try
    SL := TstringList.Create;
    SL2 := TstringList.Create;
    try
      mSite.GetFakeBusinessObject.ObjectSpace.SQLSelect(Format(cSQL_PPL, [mStrBatchCode]),  SL);
      mSite.GetFakeBusinessObject.ObjectSpace.SQLSelect(Format(cSQL_PPL2, [mStrBatchCode]),  SL2);
      if SL.Count = 0 then begin
        NxShowMessage('info','nenalezeno',mdInformation,false,mSite);
        exit;
      end;
      for i := 0 to 0 do begin
        TDynSiteForm(mSite).CurrentObject.SetFieldValueAsString('Firm_ID',sl.Strings[0]);
        TDynSiteForm(mSite).CurrentObject.SetFieldValueAsString('Person_ID',sl2.Strings[0]);
        TDynSiteForm(mSite).ActiveDataSet.RefreshCurrentItem;
      end;
    finally
      SL.Free;
    end;
  finally
    mActiveDataSet.EnableControls;
  end;
end;
function Vipdialog(var ABarCode : string; aSite:TSiteForm) : boolean;
var
  mForm : TForm;
  mBtn : TButton;
  mLbl : TLabel;
  mBarCodeEdt : TEdit;
begin
  Result := False;
  ABarCode := '';
  mForm := TForm.Create(Application.MainForm);
  mForm.BorderIcons := [biSystemMenu];
  mForm.Left := 30;
  mForm.Top := 50;
  mForm.Width := 290;  // sirka
  mForm.Height := 100; // vyska
  mForm.Caption := 'Výběr firmy';

  mLbl := TLabel.Create(mForm);
  mLbl.Caption := 'VIP EAN:';
  mLbl.Left := 10;
  mLbl.Top := 10;
  mLbl.Name := 'lblSerialNumber';
  mForm.InsertControl(mLbl);

  mBarCodeEdt := TEdit.Create(mForm);
  mBarCodeEdt.Left := 90;
  mBarCodeEdt.Top := 8;
  mBarCodeEdt.Width := mForm.Width - mBarCodeEdt.Left - 22; //140;
  mBarCodeEdt.Name := 'edtSerialNumber';
  mBarCodeEdt.Text := '';
  mForm.InsertControl(mBarCodeEdt);

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

  Result := mForm.ShowModal(Asite)= mrOK;
  if Result then
    ABarCode := mBarCodeEdt.Text;
end;

begin
end.