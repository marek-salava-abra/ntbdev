function InputForm(Self:TForm;var aValue:Extended):Integer;
var
  frmPocet: TForm;
  lblPocet: TLabel;
  Edit1: TNumEdit;
  btnCancel: TButton;
  Button1: TButton;
begin
  frmPocet := TForm.Create(Self);
  try
    lblPocet := TLabel.Create(frmPocet);
    Edit1 := TNumEdit.Create(frmPocet);
    btnCancel := TButton.Create(frmPocet);
    Button1 := TButton.Create(frmPocet);

    with frmPocet do
    begin
      Name := 'frmPocet';
      Left := 728;
      Top := 339;
      BorderStyle := bsDialog;
      Caption := 'Nalezeno';
      ClientHeight := 89;
      ClientWidth := 234;
      Color := clBtnFace;
      OldCreateOrder := False;
      Position := poScreenCenter;
      PixelsPerInch := 96;
    end;
    with lblPocet do
    begin
      Name := 'lblPocet';
      Parent := frmPocet;
      Left := 24;
      Top := 16;
      Width := 25;
      Height := 13;
      Caption := 'Po'#269't:';
    end;
    with Edit1 do
    begin
      Name := 'Edit1';
      Parent := frmPocet;
      Left := 72;
      Top := 16;
      Width := 121;
      Height := 21;
      TabOrder := 0;
      Value :=aValue;
      MinValue :=0;
    end;
    with btnCancel do
    begin
      Name := 'btnCancel';
      Parent := frmPocet;
      Left := 24;
      Top := 40;
      Width := 75;
      Height := 25;
      Cancel := True;
      Caption := '&Zru'#353'it';
      ModalResult := 2;
      TabOrder := 1;
    end;
    with Button1 do
    begin
      Name := 'Button1';
      Parent := frmPocet;
      Left := 120;
      Top := 40;
      Width := 75;
      Height := 25;
      Cancel := True;
      Caption := 'O&K';
      Default := True;
      ModalResult := 1;
      TabOrder := 2;
    end;
   Result := frmPocet.ShowModal(Self);
   AValue := Edit1.Value;
  finally
    frmPocet.Free;
  end;
end;

begin
end.