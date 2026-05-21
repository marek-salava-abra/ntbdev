uses '.API';

{
Vyvolává se po provedení inicializace agendy/formuláře. V tento okamžik je již na formuláři dostupný SiteContext.
}
{
procedure InitSite_Hook(Self: TSiteForm);
var
  mAction: TBasicAction;
begin
  mAction:= Self.GetNewAction;
  mAction.Name:= 'actAssignSendcloudTransportID';
  mAction.Caption:= '## Assign Sendcloud ID ##';
  mAction.Category:= 'tabList';
  mAction.OnExecute:= @AssignSendcloudTransportID;
end;

procedure AssignSendcloudTransportID(Sender: TComponent);
var
  mSite: TSiteForm;
  mOS: TNxCustomObjectSpace;
  mBO: TNxCustomBusinessObject;
  mSelectedTransportID: string;
begin
  mSite:= Sender.Site;
  mOS:= mSite.BaseObjectSpace;

  mSelectedTransportID:= '';

  SendcloudTransportationForm(mSite, mSelectedTransportID);

  if not NxIsBlank(mSelectedTransportID) then
  begin
    mBO:= TBusRollSiteForm(mSite).CurrentObject;
    try
      mBO.SetFieldValueAsInteger('X_SendcloudID', StrToInt(mSelectedTransportID));
      mBO.Save;
    finally
      mBO.Free;
    end;
  end;
end;

procedure SendcloudTransportationForm(ASite: TSiteForm; var AID: string);
var
  mForm: TForm;
  mCombo: TComboBox;
  mCountryRoll: TRollComboEdit;
  mOKBtn, mCancelBtn: TButton;
  mLblCountry, mLblTransport: TLabel;
  mRes: Integer;
begin
  AID := '';

  // Create the form
  mForm := TForm.Create(ASite);
  try
    mForm.Caption := 'Select Transportation';
    mForm.Position := poScreenCenter;
    mForm.BorderStyle := bsDialog;
    mForm.ClientWidth := 300;
    mForm.ClientHeight := 200;
    mForm.OnShow := @OnCreate_Form;

    // Label for Country
    mLblCountry := TLabel.Create(mForm);
    mLblCountry.Parent := mForm;
    mLblCountry.Caption := 'Country:';
    mLblCountry.Left := 16;
    mLblCountry.Top := 8;

    // TRollComboEdit for Country
    mCountryRoll := TRollComboEdit.Create(mForm);
    mCountryRoll.Parent := mForm;
    mCountryRoll.Left := 16;
    mCountryRoll.Top := mLblCountry.Top + mLblCountry.Height + 2;
    mCountryRoll.Width := mForm.ClientWidth - 32;
    mCountryRoll.Name := 'mCountryRoll';
    mCountryRoll.TextField := 'Code';
    mCountryRoll.Text := '';
    mCountryRoll.ClassID := Roll_Countries;
    mCountryRoll.OnChange := @OnChange_CountryRoll;

    // Label for Transportation list
    mLblTransport := TLabel.Create(mForm);
    mLblTransport.Parent := mForm;
    mLblTransport.Caption := 'Transportation:';
    mLblTransport.Left := 16;
    mLblTransport.Top := mCountryRoll.Top + mCountryRoll.Height + 8;

    // Combobox
    mCombo := TComboBox.Create(mForm);
    mCombo.Parent := mForm;
    mCombo.Name := 'mTransportationList';
    mCombo.Left := 16;
    mCombo.Top := mLblTransport.Top + mLblTransport.Height + 2;
    mCombo.Width := mForm.ClientWidth - 32;
    mCombo.Style := csDropDownList;

    // OK Button
    mOKBtn := TButton.Create(mForm);
    mOKBtn.Parent := mForm;
    mOKBtn.Caption := 'OK';
    mOKBtn.ModalResult := mrOk;
    mOKBtn.Left := mForm.ClientWidth - 170;
    mOKBtn.Top := mForm.ClientHeight - 40;
    mOKBtn.Width := 70;

    // Cancel Button
    mCancelBtn := TButton.Create(mForm);
    mCancelBtn.Parent := mForm;
    mCancelBtn.Caption := 'Cancel';
    mCancelBtn.ModalResult := mrCancel;
    mCancelBtn.Left := mForm.ClientWidth - 90;
    mCancelBtn.Top := mForm.ClientHeight - 40;
    mCancelBtn.Width := 70;

    // Show modal form
    mRes := mForm.ShowModal(ASite);
    if (mRes = mrOk) and (mCombo.ItemIndex >= 0) then
    begin
      AID := Copy(mCombo.Text, 1, Pos('-', mCombo.Text) -1);
    end;

  finally
    mForm.Free;
  end;
end;


procedure OnChange_CountryRoll(Sender: TComponent);
var
  mForm: TForm;
  mCountryRoll: TRollComboEdit;
  mComboBox: TComboBox;
  mEndpoint, mStatusCode, mLog: string;
  mJSON: TJSONSuperObject;
  i: integer;
begin
  mStatusCode:= '';
  mLog:= '';

  mCountryRoll:= TRollComboEdit(Sender);
  mForm:= TForm(mCountryRoll.Owner);
  mComboBox:= TComboBox(mForm.FindComponent('mTransportationList'));
  mComboBox.Items.Clear;


  mEndpoint:= 'shipping_methods';
  if not NxIsBlank(mCountryRoll.Text) then
  begin
    mEndpoint:= mEndpoint + '?to_country='+mCountryRoll.Text;
  end;

  mJSON:= TJSONSuperObject.Create;
  try
    mJSON:= CallAPI(mForm.Site.BaseObjectSpace, 'GET', mEndpoint, mStatusCode, mLog);

    if mStatusCode = '200' then
    begin
      for i:=0 to mJSON.A['shipping_methods'].Length -1 do
      begin
        mComboBox.Items.Add(mJSON.A['shipping_methods'].O[i].S['id'] + '-' + mJSON.A['shipping_methods'].O[i].S['name'])
      end;
    end;
  finally
    mJSON.Free;
  end;
end;


procedure OnCreate_Form(Sender: TComponent);
var
  mForm: TForm;
  mCountryRoll: TRollComboEdit;
  mComboBox: TComboBox;
  mEndpoint, mStatusCode, mLog: string;
  mJSON: TJSONSuperObject;
  i: integer;
begin
  mStatusCode:= '';
  mLog:= '';

  mForm:= TForm(Sender);
  mComboBox:= TComboBox(mForm.FindComponent('mTransportationList'));
  mComboBox.Items.Clear;

  mEndpoint:= 'shipping_methods';

  mJSON:= TJSONSuperObject.Create;
  try
    mJSON:= CallAPI(mForm.Site.BaseObjectSpace, 'GET', mEndpoint, mStatusCode, mLog);

    if mStatusCode = '200' then
    begin
      for i:=0 to mJSON.A['shipping_methods'].Length -1 do
      begin
        mComboBox.Items.Add(mJSON.A['shipping_methods'].O[i].S['id'] + '-' + mJSON.A['shipping_methods'].O[i].S['name'])
      end;
    end;
  finally
    mJSON.Free;
  end;
end;
}


begin
end.