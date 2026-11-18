

const
  cTEdit = 0;
  cTNumEdit = 1;
  cTRollComboEdit = 2;
  cSize= 9;


procedure fAddLabeldInput(var Owner,AParent: TWinControl;var AInput : TComponent; ACaptionLabel, ADisplayLabel: TLabel; AComponentName,ACaption: String; ATop,ALeft,ACaptionWidth ,AWidth : Integer; AFieldTypeEnum:Integer;);
var
    mFormInput: TForm;

begin
  ACaptionLabel := TLabel.Create(Owner);
  ACaptionLabel.Name := 'lblCaption'+AComponentName;
  ACaptionLabel.Font.Size :=  cSize;
  ACaptionLabel.Left:= ALeft;
  ACaptionLabel.Top:= ATop+2;
  ACaptionLabel.Width := ACaptionWidth;
  ACaptionLabel.Caption := ACaption;
  ACaptionLabel.Parent := AParent;


  if ADisplayLabel <> nil then
  begin
    ADisplayLabel := TLabel.Create(Owner);
    ADisplayLabel.Name := 'lblDisplayname'+AComponentName;
    ADisplayLabel.Font.Size := cSize;
    ADisplayLabel.Top:= ATop+2;
    ADisplayLabel.Width := ACaptionWidth;
    ADisplayLabel.Caption := '';
    ADisplayLabel.Parent := AParent;
  end;

  case AFieldTypeEnum of
    cTNumEdit:
    begin
      AInput := TNumEdit.Create(Owner);
      with TNumEdit(AInput) do
      begin
        Name := AComponentName;
        Parent := AParent;
        Left := ACaptionWidth+ACaptionLabel.Left ;
        Top := ATop;
        Width := AWidth;
        TabOrder := 0;
        //OnKeyDown:= @ActEnterNum;
      end;
      if ADisplayLabel <> nil then
        ADisplayLabel.Left := TNumEdit(AInput).Left +TNumEdit(AInput).Width + 10;
      TNumEdit(AInput).Font.Size := cSize;
    end;
    cTEdit:
    begin
        AInput := TEdit.Create(Owner);
      with TEdit(AInput) do
      begin
        Name := AComponentName;
        Parent := AParent;
        Left := ACaptionWidth+ACaptionLabel.Left ;
        Top := ATop;
        Width := AWidth;
        TabOrder := 0;
        //OnKeyDown:= @ActEnterNum;
      end;
      if ADisplayLabel <> nil then
        ADisplayLabel.Left := TEdit(AInput).Left + TEdit(AInput).Width + 10 ;
      TEdit(AInput).Font.Size := cSize;
    end;
    cTRollComboEdit:
    begin
        AInput := TRollComboEdit.Create(Owner);
      with TRollComboEdit(AInput) do
      begin
        Name := AComponentName;
        Parent := AParent;
        Left := ACaptionWidth+ACaptionLabel.Left ;
        Top := ATop;
        Width := AWidth;
        TabOrder := 0;
        Complete:= True;
        ForcedField:= True;
        Prefilling:= pmNone;
        TextField:= 'Name';
        Text := '';
      end;
      if ADisplayLabel <> nil then
        ADisplayLabel.Left := TRollComboEdit(AInput).Left + TRollComboEdit(AInput).Width + 10 ;
      TRollComboEdit(AInput).Font.Size := cSize;
    end;
  end;
  //mFormInput.SetFocusedControl(mNumEdit);
end;






function Create_EditAddressFrom(ASite: TSiteForm; APackagesDataSetInt: TDataSet; AHeaderDataSetInt: TDataSet; AContentDataSetInt: TDataSet;var AListComponent:TStringList; ):TForm;
var mCol01,mCol02,mCol03,mCol04,mCol05,mCol06,mCol07,mCol08,mCol09,mCol10,mCol11: TEdit;
    mLbl01,mLbl02,mLbl03,mLbl04,mLbl05,mLbl06,mLbl07,mLbl08,mLbl09,mLbl10,mLbl11,mLbl12: TLabel;
    mprefix : String;
    mForm:TForm;
    pnlDeader, pnlBody, pnlBottom:TPanel;
    btnFinish, btnCancel: TButton;
    mLeft: Integer;
const cPosun = 25;
      cLeft = 190;
      cCaptionWidth = 60;
      cWidth = 110;


begin
  mprefix := 'Address_ID_';
  mForm := TForm.Create(ASite);
  Result:= mForm;

  mForm.Caption := 'Drobná oprava adresy provozovny';
  mForm.Width := 390;
  mForm.Height := 220;

  pnlDeader := TPanel.Create(mForm);
  pnlBody := TPanel.Create(mForm);
  pnlBottom := TPanel.Create(mForm);
  btnFinish := TButton.Create(mForm);
  btnCancel := TButton.Create(mForm);

  pnlBody.Align := alClient;
  pnlBody.Parent := mForm;

  with pnlBody do
  begin
    Name := 'pnlBody';
    Caption := '';
    Parent := mForm;
    Align := alClient
  end;

  with pnlBottom do
  begin
    Name := 'pnlBottom';
    Caption := '';
    Parent := mForm;
    Align := alBottom;
    height:=50;
  end;


  fAddLabeldInput(mForm,pnlBody,mCol01, mLbl01, nil, 'Name','Název:',8,10,cCaptionWidth,cWidth+cWidth+70 , cTEdit);
  mCol01.Text := '';
  mCol01.TabOrder := 1;
  mCol01.MaxLength := 100;
  mCol01.Hint := 'Název provozovny';


  fAddLabeldInput(mForm,pnlBody,mCol02, mLbl02, nil, mprefix+'Location','Oddělení:',mCol01.top+cPosun,10,cCaptionWidth,cWidth , cTEdit);
  mCol02.Text := '';
  mCol02.TabOrder := 2;
  mCol02.MaxLength := 60;

  fAddLabeldInput(mForm,pnlBody,mCol03, mLbl03, nil, mprefix+'Street','Ulice:',mCol02.top+cPosun,10,cCaptionWidth,cWidth , cTEdit);
  mCol03.Text := '';
  mCol03.TabOrder := 3;
  mCol03.MaxLength := 60;

  fAddLabeldInput(mForm,pnlBody,mCol04, mLbl04, nil, mprefix+'City','Město:',mCol03.top+cPosun,10,cCaptionWidth,cWidth , cTEdit);
  mCol04.Text := '';
  mCol04.TabOrder := 4;
  mCol04.MaxLength := 60;

  fAddLabeldInput(mForm,pnlBody,mCol05, mLbl05, nil, mprefix+'PostCode','PSČ:',mCol04.top+cPosun,10,cCaptionWidth,cWidth , cTEdit);
  mCol05.Text := '';
  mCol05.TabOrder := 5;
  mCol05.MaxLength := 10;

  fAddLabeldInput(mForm,pnlBody,mCol06, mLbl06, nil, mprefix+'Country','Země:',mCol05.top+cPosun,10,cCaptionWidth,cWidth , cTEdit);
  mCol06.Text := '';
  mCol06.TabOrder := 6;
  mCol06.MaxLength := 40;

  fAddLabeldInput(mForm,pnlBody,mCol07, mLbl07, nil, mprefix+'CountryCode','Kód země:',mCol06.top+cPosun,10,cCaptionWidth,cWidth , cTEdit);
  mCol07.Text := '';
  mCol07.TabOrder := 7;
  mCol07.MaxLength := 3;



  mLeft := cLeft ;
  fAddLabeldInput(mForm,pnlBody,mCol08, mLbl08, nil, mprefix+'PhoneNumber1','Tel. 1:',mCol01.top+cPosun,mLeft,cCaptionWidth,cWidth , cTEdit);
  mCol08.Text := '';
  mCol08.TabOrder := 8;
  mCol08.MaxLength := 30;

  fAddLabeldInput(mForm,pnlBody,mCol09, mLbl09, nil, mprefix+'PhoneNumber2','Tel. 2:',mCol08.top+cPosun,mLeft,cCaptionWidth,cWidth , cTEdit);
  mCol09.Text := '';
  mCol09.TabOrder := 9;
  mCol09.MaxLength := 30;

  fAddLabeldInput(mForm,pnlBody,mCol10, mLbl10, nil, mprefix+'Recipient','Adresát:',mCol09.top+cPosun,mLeft,cCaptionWidth,cWidth , cTEdit);
  mCol10.Text := '';
  mCol10.TabOrder := 10;
  mCol10.MaxLength := 30;

  fAddLabeldInput(mForm,pnlBody,mCol11, mLbl11, nil, mprefix+'EMail','E-mail:',mCol10.top+cPosun,mLeft,cCaptionWidth,cWidth , cTEdit);
  mCol11.Text := '';
  mCol11.TabOrder := 11;
  mCol11.MaxLength := 100;

  AListComponent.add(mCol01.Name);
  AListComponent.add(mCol02.Name);
  AListComponent.add(mCol03.Name);
  AListComponent.add(mCol04.Name);
  AListComponent.add(mCol05.Name);
  AListComponent.add(mCol06.Name);
  AListComponent.add(mCol07.Name);
  AListComponent.add(mCol08.Name);
  AListComponent.add(mCol09.Name);
  AListComponent.add(mCol10.Name);
  AListComponent.add(mCol11.Name);


  with btnCancel do
  begin
    Name := 'btnCancel';
    Parent := pnlBottom;
    Left := cleft + 40;
    Top := 6;
    Width := 60;
    //Height := 50;
    Caption := 'Storno';
    TabOrder := 5;
    ModalResult := mrCancel;
  end;
  with btnFinish do
  begin
    Name := 'btnFinish';
    Parent := pnlBottom;
    Left := 8;
    Top := 6;
    Width := 60;
    Left := btnCancel.Left + btnCancel.Width + 15;
    //Height := 50;
    Caption := 'Uložit';
    TabOrder := 4;
    ModalResult:= mrOk;
  end;


end;


function ShowInputField(Sender: TObject; ADefaultValue : Double = 1; ACaption:String;ADecimalPlaces:Integer =  0):Double;
var
  mFormInput: TForm;
  mEdit: TNumEdit;
  mButtonEnter: TButton;
begin
  try
    Result := ADefaultValue;
    mFormInput := nil;
    mEdit := nil;
    mFormInput := TForm.Create(TDynSiteForm(Sender));
    mEdit := TNumEdit.Create(mFormInput);
    mButtonEnter := TButton.Create(mFormInput);

    with mFormInput do
    begin
      Name := 'mFormInput';
      Left := 192;
      Top := 125;
      Width := 400;
      Height := 82+10;
      Caption := ACaption;
      Color := clBtnFace;
      OldCreateOrder := False;
      PixelsPerInch := 96;
    end;
    mFormInput.Font.Size := mFormInput.Font.Size +4;
    with mEdit do
    begin
      Name := 'mEdit';
      Value := ADefaultValue;
      Parent := mFormInput;
      Left := 8;
      Top := 8;
      Width := 369;
      Height := 40;
      TabOrder := 0;
      OnKeyDown:= @ActEnter;
      Tag := ObjToInt(mButtonEnter);
      DecimalPlaces := ADecimalPlaces;
    end;
    mEdit.Font.Size := mEdit.Font.Size +4;



    with mButtonEnter do
    begin
      Name := 'mButtonEnterInput';
      Parent := mFormInput;
      Left := 384;
      Top := 8;
      Width := 0;
      Height := 0;
      Caption := 'mButtonEnter';
      TabOrder := 1;
      ModalResult := mrOk;
    end;


    mFormInput.SetFocusedControl(mEdit);
    if mFormInput.ShowModal(TDynSiteForm(Sender)) = mrOk then
    begin
      mFormInput.Close;

      Result :=  mEdit.Value;
      mEdit.Clear;
    end
    else
    begin
      ShowMessage('Přerušení');
      Result :=  -1;
      exit;
    end;


  finally
    if mEdit <> nil then
      mEdit.Free;
    if mFormInput <> nil then
      mFormInput.Free;
  end;
end;


procedure ActEnter(Sender: TObject; var Key: Word; Shift: TShiftState);
var
  mButton: TButton;
begin
  mButton := nil;
  if Key = VK_RETURN then
  begin
    mButton := TButton(IntToObj(TNumEdit(Sender).Tag));
    //mButton := TButton(TEdit(Sender).Parent.FindChildControl('mButtonEnterInput'));
    if Assigned(mButton) then
      mButton.Click;
  end;
end;









begin
end.