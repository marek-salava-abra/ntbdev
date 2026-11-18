uses 'eu.abra.alec.Lipoelastic.SupplierPriceListImport.fce';

procedure ShowForm(ASite: TSiteForm);
var
  mForm: TForm;
  mLabel1, mLabel2: TLabel;
  btnSelectCompany: TButton;  // Button for selecting a company
  mDate: TDateTimeEdit;
  btnOK, btnCancel: TButton;
  mRollEdit: TRollComboEdit;
  mSelectedID: string;
  ButtonWidth, ButtonSpacing, ButtonMargin: integer;
begin
  // Create the form
  mForm := TForm.Create(Asite);
  mForm.Caption := 'Import dodavatelského ceníku';
  mForm.Width := 300;
  mForm.Height := 200;
  mForm.Position := poScreenCenter;

  // Create and position the labels
  mLabel1 := TLabel.Create(mForm);
  mLabel1.Parent := mForm;
  mLabel1.Left := 10;
  mLabel1.Top := 20;
  mLabel1.Caption := 'Vyberte firmu:';

  mLabel2 := TLabel.Create(mForm);
  mLabel2.Parent := mForm;
  mLabel2.Left := 10;
  mLabel2.Top := 60;
  mLabel2.Caption := 'Platnost od:';

  //GetFirmID(TRollComboEdit.Create(mForm)); // mForm musi byt vytvore ze TSiteForm kvuli contextu
  mRollEdit:= TRollComboEdit.Create(mForm);
  mRollEdit.Parent:= mForm;
  mRollEdit.Left:= 120;
  mRollEdit.Top:= 20;
  mRollEdit.Width:= 150;
  mRollEdit.TextField:= 'Name';
  mRollEdit.ClassID:= 'O3OWQQYWYJCL3J0B01K0LEIOE0';
  //mRollEdit.Complete:= true;
  //mRollEdit.ForcedField:= True;
  //mRollEdit.Prefilling:= pmOnlyIfOne;
  //mRollEdit.Parameters.Add('_Allowed=' + '');
  //mRollEdit.DataText:= '';

   // Create and position the DateTimeEdit component
  mDate := TDateTimeEdit.Create(mForm);
  mDate.Parent := mForm;
  mDate.Left := 120;
  mDate.Top := 60;
  mDate.Width := 150;
  mDate.DateTime := Date;

  // Calculate button dimensions and spacing
  ButtonWidth := 75;
  ButtonSpacing := 40;
  ButtonMargin := (mForm.ClientWidth - 2 * ButtonWidth - ButtonSpacing) div 2;

  // Create and position the OK button
  btnOK := TButton.Create(mForm);
  btnOK.Parent := mForm;
  btnOK.Left := ButtonMargin;
  btnOK.Top := 120;
  btnOK.Width := ButtonWidth;
  btnOK.Caption := 'OK';
  btnOK.ModalResult := mrOK;

  // Create and position the Cancel button
  btnCancel := TButton.Create(mForm);
  btnCancel.Parent := mForm;
  btnCancel.Left := ButtonMargin + ButtonWidth + ButtonSpacing;
  btnCancel.Top := 120;
  btnCancel.Width := ButtonWidth;
  btnCancel.Caption := 'Cancel';
  btnCancel.ModalResult := mrCancel;

  // Show the form and handle the result
  if mForm.ShowModal(ASite) = mrOK then
  begin
    SupplierListImportXLSX(ASite, mRollEdit.DataText, mDate.DateTime);
  end;

  // Free the form and its components
  mForm.Free;
end;


begin
end.