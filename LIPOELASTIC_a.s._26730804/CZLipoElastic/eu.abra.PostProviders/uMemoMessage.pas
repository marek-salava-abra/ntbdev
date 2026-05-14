function CreateMemoMessage(AForm: TForm; const AErrorText: string; AConfirm: boolean = false): TForm;
var
  pnl1: TPanel;
  mmo1: TMemo;
  pnl2: TPanel;
  btn1: TButton;
  btn2: TButton;
begin
  Result := TForm.Create(AForm);
  try
    with Result do begin
      Name := 'frmMemoMessage';
      Caption := Application.Title;
      BorderStyle := bsDialog;
      ClientWidth := 800;
      ClientHeight := 500;
      FormStyle := fsStayOnTop;
      OldCreateOrder := False;
      Position := poScreenCenter;
      PixelsPerInch := 96;
      OnKeyDown := @KeyDown2;
    end;
    pnl1 := TPanel.Create(Result);
    with pnl1 do
    begin
      Name := 'pnl1';
      Parent := Result;
      Left := 0;
      Top := 0;
      Align := alClient;
      Caption := '';
      TabOrder := 97;
    end;
    pnl2 := TPanel.Create(Result);
    with pnl2 do
    begin
      Name := 'pnl2';
      Parent := Result;
      Align := alBottom;
      Caption := '';
      TabOrder := 98;
       Height := 50;
    end;
    mmo1 := TMemo.Create(Result);
    with mmo1 do
    begin
      Name := 'mmo1';
      Parent := pnl1;
      Align := alClient;
      WordWrap := true;
      Lines.Clear;
      Lines.Add(AErrorText);
      ScrollBars := ssNone;
      TabOrder := 99;
      Width := 500;
      ReadOnly := True;
    end;
    btn1 := TButton.Create(Result);
    with btn1 do
    begin
      Name := 'btn1';
      Parent := pnl2;
      Left := 360;
      Top := 8;
      Width := 75;
      Height := 25;
      Caption := '&OK';
      if AConfirm then begin
        Caption := '&Ano';
        Left := 320;
      end;
      TabOrder := 0;
      ModalResult := mrYes;
    end;
    if AConfirm then begin
      btn2 := TButton.Create(Result);
      with btn2 do
      begin
        Name := 'btn2';
        Parent := pnl2;
        Left := 410;
        Top := 8;
        Width := 75;
        Height := 25;
        Caption := '&Ne';
        TabOrder := 0;
        ModalResult := mrNo;
      end;
    end;
  except
    Result.Free;
    Result := nil;
    RaiseException(ExceptionMessage);
  end;
end;

procedure KeyDown2(Sender: TObject; var Key: Word; Shift: TShiftState);
var
  mButton: TButton;
begin
  mButton := nil;
  if Key = VK_RETURN then
    mButton := TButton(TForm(Sender).FindChildControl('btn1'));
  if Key = VK_ESCAPE then
    mButton := TButton(TForm(Sender).FindChildControl('btn2'));
  if Assigned(mButton) then
    mButton.Click;
end;

begin
end.