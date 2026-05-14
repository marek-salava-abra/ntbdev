
procedure FormCreate_Hook(Self: TSiteForm);
var
  mAction, mAction2: TBasicAction;
  mCAction: TBasicAction;
  mAList: TActionList;
  i : integer;
begin
  mAList := Self.GetMainActionList;
  for i := 0 to mAList.ActionCount-1 do begin
    mCAction := mALIst.Actions[i];
    if (mCAction.Name = 'actBarCodeReader') then
      TBasicAction(mCAction).ShortCut :=  TextToShortCut ('Ctrl+Q');
  end;

  mAction := Self.GetNewAction;
  mAction.ShowControl := True;
  mAction.ShowMenuItem := True;
  mAction.Caption := 'Dílčí příjem';
  mAction.ShortCut := TextToShortCut('Ctrl+b'); //16450;
  mAction.Hint := 'Dílčí příjem';
  mAction.Category := 'tabList';
  mAction.OnExecute := @BarCodeOnExecute;


  {mAction2 := Self.GetNewAction;
  mAction2.ShowControl := True;
  mAction2.ShowMenuItem := True;
  mAction2.Caption := 'Smaže řádek';
  mAction2.Category := 'tabDetail';
  mAction2.OnExecute := @DeleteRow;}

end;

procedure DeleteRow(sender:tcomponent);
var
  mStrBatchCode, mOID : string;
  mSite: TSiteForm;
  mGrid : TMultiGrid;
  mDataSet : TNxDataDataSet;
  SL : TStringList;
  i : integer;
  mBO:TNxCustomBusinessObject;
  mControl:TControl;
begin
  mSite := tcomponent(Sender).DynSite;
  if not(TDynSiteForm(mSite).Edit) then begin
    NxShowSimpleMessage('Nejste ve stavu editace.',msite);
    exit;
  end;
  mControl:= mSite.FindChildControl('tabRows.grdRows');
    mDataset := TNxRowsObjectDataSet(TMultiGrid(mControl).DataSource.DataSet);
    if Assigned(mDataset) then begin
     //mDataSet.DisableControls;
     mDataSet.CurrentItem.Delete;
    TDynSiteForm(mSite).ActiveDataSet.UpdateFields; //Aby se o změně dozvěděl hlavičkový dataset
    //mDataset.RefreshAndRestoreLastSelectedItem;
    //mDataSet.EnableControls;
  end;
end;


procedure BarCodeOnExecute(Sender : TComponent);
const
  cSQL_SN = 'SELECT A.ID FROM StoreDocuments2 A ' +
            '  JOIN StoreCards SC on SC.ID = A.StoreCard_ID '+
            ' WHERE upper(SC.Specification2) = ''%s'' and A.Parent_ID=''%s'' ';
  cSQL_EAN = 'SELECT A.ID FROM StoreDocuments2 A ' +
            '  JOIN StoreCards SC on SC.ID = A.StoreCard_ID '+
            ' WHERE upper(SC.X_barcode) = ''%s'' and A.Parent_ID=''%s'' ';

var
  mStrBatchCode, mOID : string;
  mSite: TSiteForm;
  mGrid : TMultiGrid;
  mActiveDataSet : TNxDataDataSet;
  SL : TStringList;
  i : integer;
  mBO, mrowbo:TNxCustomBusinessObject;
  mControl:TControl;
  mParms:TNxParameters;
  mParam:TNxParameter;
begin
  mSite := tcomponent(Sender).BusRollSite;

  if not BarCodeDialog(mStrBatchCode, mSite) then
    exit;
  mbo:=msite.BaseObjectSpace.CreateObject('DYSBRTUOKLPO1ISIKUJLMCEELG');
  try
   mbo.Load(mStrBatchCode,nil);
   mbo.SetFieldValueAsFloat('X_Prijato',1);
   mbo.save;
   mbo.free;
  except
  NxShowSimpleMessage(mStrBatchCode+#13+#10+ExceptionMessage,mSite);
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
  mForm.Caption := 'Výběr karty';

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