procedure InitSite_Hook(Self: TSiteForm);
var
  mAction: TBasicAction;
begin
  mAction := Self.GetNewAction;
  mAction.ShowControl := True;
  mAction.ShowMenuItem := True;
  mAction.Name := 'actSetUnsetB2B';
  mAction.Caption := '## Nastavení B2B shopu ##';
  mAction.Hint := 'Nastaví příznak správného shopu';
  mAction.Category := 'tabList';
  mAction.OnExecute := @SetUnsetB2B;
end;

procedure SetUnsetB2B(Sender: TComponent);
var
  mList: TStringList;
  mSite: TSiteForm;
  i, mPos, k: Integer;
  mBO: TNxCustomBusinessObject;
  mSet: Boolean;
  mString: String;
  mChar: Char;
begin
  mList := TStringList.Create;
  try
    mSite := TComponent(Sender).BusRollSite;
    TBusRollSiteForm(mSite).List.GetSelectedId(mList);

    if mList.Count > 0 then
    begin
      mSet := True;
      if GetParams(mSite, mPos, mSet) then
      begin
        k := mList.Count;
        WaitWin.StartProgress('Čekejte, doplňuji ...', '', k);
        mBO := TBusRollSiteForm(mSite).BaseObjectSpace.CreateObject(Class_StoreCard);
        try
          if mSet then
            mChar := '1'
          else
            mChar := ' ';

          for i := 0 to k - 1 do
          begin
            mBO.Load(mList.Strings[i], nil);
            mString := mBO.GetFieldValueAsString('X_B2BSending');

            while Length(mString) < (mPos + 1) do
              mString := mString + ' ';

            mString[mPos + 1] := mChar;

            mBO.SetFieldValueAsString('X_B2BSending', mString);
            mBO.Save;

            WaitWin.ChangeText(IntToStr(i + 1) + ' / ' + IntToStr(k));
            WaitWin.StepIt;
          end;
        finally
          mBO.Free;
          WaitWin.Stop;
        end;
      end;
    end;
  finally
    mList.Free;
  end;
end;

function GetParams(var ASite: TSiteForm; var aPos: Integer; var aSet: Boolean): Boolean;
var
  mList: TStringList;
  mButOk, mButCancel: TButton;
  mResult, mCount: Integer;
  mForm: TForm;
  mB2BList: TComboBox;
  mBEd01: TCheckBox;
  mLabel: TLabel;
begin
  Result := False;
  if ASite <> nil then
  begin
    mCount := 0;
    mForm := TForm.Create(ASite);
    try
      mForm.Width := 510;
      mForm.Position := poScreenCenter;
      mForm.Caption := 'Údaje pro B2B:';
      mForm.OnCloseQuery := @OnFormCloseAction;

      mList := TStringList.Create;
      try
        mList.Add('FE Produkt');
        mList.Add('PneuB2B');

        mLabel := TLabel.Create(mForm);
        mLabel.Parent := mForm;
        mLabel.Caption := 'B2B:';
        mLabel.Top := (mCount * 25) + 12;
        mLabel.Left := 17;
        mLabel.Height := 13;
        mLabel.Width := 100;
        mLabel.Font.Size := 10;

        mB2BList := TComboBox.Create(mForm);
        mB2BList.Parent := mForm;
        mB2BList.Left := 100;
        mB2BList.Top := (mCount * 25) + 10;
        mB2BList.Width := 200;
        mB2BList.Text := '';
        mB2BList.Items := mList;
        mB2BList.ItemIndex := 0;

        mCount := mCount + 1;

        mLabel := TLabel.Create(mForm);
        mLabel.Parent := mForm;
        mLabel.Caption := 'Nastavit:';
        mLabel.Top := (mCount * 25) + 12;
        mLabel.Left := 17;
        mLabel.Height := 13;
        mLabel.Width := 100;
        mLabel.Font.Size := 10;

        mBEd01 := TCheckBox.Create(mForm);
        mBEd01.Left := 100;
        mBEd01.Top := (mCount * 25) + 10;
        mBEd01.Checked := aSet;
        mBEd01.Parent := mForm;

        mButOk := TButton.Create(mForm);
        mButOk.Parent := mForm;
        mButOk.Caption := 'OK';
        mButOk.Default := True;
        mButOk.Top := (mCount * 25) + 20;
        mButOk.Left := 252;
        mButOk.Height := 24;
        mButOk.Width := 62;
        mButOk.ModalResult := 1;

        mButCancel := TButton.Create(mForm);
        mButCancel.Parent := mForm;
        mButCancel.Caption := 'Zrušit';
        mButCancel.Top := (mCount * 25) + 20;
        mButCancel.Left := 320;
        mButCancel.Height := 24;
        mButCancel.Width := 62;
        mButCancel.ModalResult := 2;
        mForm.Height := (mCount * 25) + 95;

        mResult := mForm.ShowModal(ASite);
        if mResult = 1 then
        begin
          Result := True;
          aPos := mB2BList.ItemIndex;
          aSet := mBEd01.Checked;
        end;
      finally
        mList.Free;
      end;
    finally
      mForm.Free;
    end;
  end;
end;

procedure OnFormCloseAction(Sender: TObject; var Action: TCloseAction);
begin
  if Action = caHide then
    TForm(Sender).ModalResult := mrCancel;
end;

begin
end.