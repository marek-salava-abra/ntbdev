

procedure FormCreate_Hook(Self: TSiteForm);
var
  mAction: TBasicAction;
  mCAction: TBasicAction;
  mAList: TActionList;
  i : integer;
begin
  mAList := Self.GetMainActionList;
  {for i := 0 to mAList.ActionCount-1 do begin
    mCAction := mALIst.Actions[i];
    if (mCAction.Name = 'actBarCodeReader') then
      TBasicAction(mCAction).ShortCut :=  TextToShortCut ('Ctrl+Q');
  end;}

  mAction := Self.GetNewAction;
  mAction.ShowControl := True;
  mAction.ShowMenuItem := True;
  mAction.Caption := 'Dle EAN';
  mAction.ShortCut := TextToShortCut('Ctrl+Y'); //16450;
  mAction.Hint := 'dohledá DL';
  mAction.Category := 'tabList';
  mAction.OnExecute := @BarCodeOnExecute;
end;




procedure BarCodeOnExecute(Sender : TComponent);


var
  mStrBatchCode, mOID : string;
  mSite: TSiteForm;
  mGrid : TDBGrid;
  mActiveDataSet : TNxDataDataSet;
  SL : TStringList;
  i : integer;
begin
  mSite := tcomponent(Sender).DynSite;
  if not BarCodeDialog(mStrBatchCode, mSite) then
    exit;

  mGrid := TDBGrid(NxFindChildControl(mSite.MainPanel, 'grdList'));
  if not Assigned(mGrid) then begin
    NxShowMessage('info','Nenalezen dbgrid řádků.',mdInformation,false,mSite);
    exit;
  end;
  mActiveDataSet := TNxDataDataSet(mGrid.DataSource.DataSet);
  mActiveDataSet.DisableControls;
  try
        mActiveDataSet.SeekID(mStrBatchCode);
        mGrid.SelectRows_1(mStrBatchCode);

  finally
    mActiveDataSet.EnableControls;
  end;
end;

function BarCodeDialog(var ABarCode : string; aSite:TSiteForm) : boolean;
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
  mForm.Caption := 'Výběr DL';

  mLbl := TLabel.Create(mForm);
  mLbl.Caption := 'EAN:';
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