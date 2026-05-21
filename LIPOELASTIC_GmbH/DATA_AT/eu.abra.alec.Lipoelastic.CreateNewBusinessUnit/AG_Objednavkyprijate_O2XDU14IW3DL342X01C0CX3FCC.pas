{
Vyvolává se po provedení inicializace agendy/formuláře. V tento okamžik je již na formuláři dostupný SiteContext.
}
procedure InitSite_Hook(Self: TSiteForm);
var
  mAction: TBasicAction;
begin
  mAction := Self.GetNewAction;
  mAction.Name:= 'actCreateNewBusinessUnit';
  mAction.ShowControl := True;
  mAction.ShowMenuItem := True;
  mAction.Caption := '## Create new bus. unit ##';
  mAction.Category := 'tabDetail';
  mAction.OnExecute := @CreateNewBusinessUnit;
  mAction.OnUpdate := @My_OnUpdate;
end;

procedure My_OnUpdate(Sender: TControl);
var
  mSite: TSiteForm;
begin
  mSite := NxFindSiteForm(Sender);
  if Assigned(mSite) then begin
    if mSite is TDynSiteForm then begin
      TBasicAction(Sender).Enabled := TDynSiteForm(mSite).Edit;
    end;
  end;
end;


procedure CreateNewBusinessUnit (Sender: TComponent);
var
  mSite: TSiteForm;
  mOS: TNxCustomObjectSpace;
  mParams: TNxParameters;
  mFirm_ID, mFO_ID: string;
  mROBO, mFirmBO, mFOBO: TNxCustomBusinessObject;
  mFirmOffices: TNxCustomBusinessMonikerCollection;
begin
  mSite:= Sender.Site;
  mOS:= mSite.BaseObjectSpace;
  mFO_ID:= '';

  mParams:= TNxParameters.Create;
  mROBO:= TDynSiteForm(mSite).CurrentObject;
  try
    if NxIsEmptyOID(mROBO.GetFieldValueAsString('Firm_ID')) then
    begin
      NxShowSimpleMessage('Please select company first.', mSite);
      exit;
    end;

    if BusinessObjectDataForm(mSite, mParams) then
    begin
      mFirm_ID:= mROBO.GetFieldValueAsString('Firm_ID');
      mFirmBO:= mOS.CreateObject(Class_Firm);
      try
        mFirmBO.Load(mFirm_ID, nil);
        mFirmOffices:= mFirmBO.GetLoadedCollectionMonikerForFieldCode(mFirmBO.GetFieldCode('FirmOffices'));
        mFOBO:= mFirmOffices.AddNewObject;
        if Trim(mParams.ParamByName('Name').AsString) = '' then
          mFOBO.SetFieldValueAsString('Name', mParams.ParamByName('Street').AsString)
        else
          mFOBO.SetFieldValueAsString('Name', mParams.ParamByName('Name').AsString);
        mFOBO.SetFieldValueAsString('Address_ID.Location', mParams.ParamByName('Department').AsString);
        mFOBO.SetFieldValueAsString('Address_ID.Street', mParams.ParamByName('Street').AsString);
        mFOBO.SetFieldValueAsString('Address_ID.City', mParams.ParamByName('City').AsString);
        mFOBO.SetFieldValueAsString('Address_ID.PostCode', mParams.ParamByName('PostCode').AsString);
        mFOBO.SetFieldValueAsString('Address_ID.CountryCode', NxLeft(mParams.ParamByName('CountryCode').AsString, 3));
        mFOBO.SetFieldValueAsString('Address_ID.Country', NxLeft(mParams.ParamByName('CountryName').AsString, 40));
        mFOBO.SetFieldValueAsString('Address_ID.Recipient', mParams.ParamByName('Recipient').AsString);
        mFOBO.SetFieldValueAsString('Address_ID.PhoneNumber1', mParams.ParamByName('Phone').AsString);
        mFOBO.SetFieldValueAsString('Address_ID.EMail', mParams.ParamByName('Email').AsString);

        mFO_ID:= mFOBO.OID;
        mFirmBO.Save;
        mROBO.SetFieldValueAsString('FirmOffice_ID', mFO_ID);

      finally
        mFirmBO.Free;
      end;

      TDynSiteForm(mSite).ActiveDataSet.UpdateFields(true, true);
    end;
  finally
    mParams.Free;
  end;

end;


function BusinessObjectDataForm(ASite: TSiteForm; AParams: TNxParameters): boolean;
const
  cMargin  = 12;
  cLblW    = 110;
  cEditW   = 260;
  cRowH    = 24;
  cGapY    = 8;
  cBtnW    = 90;
  cBtnH    = 28;
var
  F: TForm;
  L: TLabel;

  EdDepartment, EdStreet, EdCity, EdPostCode, EdCountryCode, EdRecipient, EdBusinessUnitName, EdPhone, EdEmail, EdCountryName: TEdit;
  BtnOK, BtnCancel: TButton;
  TopY: Integer;

  function AddRow(const ACaption, AName: string; ATop: Integer; var AEdit: TEdit): Integer;
  begin
    L := TLabel.Create(F);
    L.Parent := F;
    L.Caption := ACaption;
    L.Left := cMargin;
    L.Top := ATop + 4;
    L.Width := cLblW;

    AEdit := TEdit.Create(F);
    AEdit.Parent := F;
    AEdit.Name:= AName;
    AEdit.Left := cMargin + cLblW + 10;
    AEdit.Top := ATop;
    AEdit.Width := cEditW;
    AEdit.Height := cRowH;
    AEdit.Text:= '';

    Result := ATop + cRowH + cGapY;
  end;

begin
  Result := False;

  F := TForm.Create(ASite);
  try
    F.BorderStyle := bsDialog;
    F.Position := poScreenCenter;
    F.Caption := 'Business Object Data';
    F.KeyPreview := True;
    F.ClientWidth := cMargin + cLblW + 10 + cEditW + cMargin;

    // řádky
    TopY := cMargin;
    TopY := AddRow('Unit Name', 'EdUnitName',       TopY, EdBusinessUnitName);
    TopY := AddRow('Department', 'EdDepartment',    TopY, EdDepartment);
    TopY := AddRow('Street', 'EdStreet',            TopY, EdStreet);
    TopY := AddRow('City', 'EdCity',                TopY, EdCity);
    TopY := AddRow('PostCode', 'EdPostCode',        TopY, EdPostCode);
    TopY := AddRow('CountryCode', 'EdCountryCode',  TopY, EdCountryCode);
    TopY := AddRow('Recipient', 'EdRecipient',      TopY, EdRecipient);
    TopY := AddRow('Phone', 'EdPhone',              TopY, EdPhone);
    TopY := AddRow('Email', 'EdEmail',              TopY, EdEmail);

    EdCountryName:= TEdit.Create(F);
    EdCountryName.Parent:= F;
    EdCountryName.Name:= 'EdCountryName';
    EdCountryName.Visible:= false;
    EdCountryName.Text:= '';


    // tlačítka
    BtnOK := TButton.Create(F);
    BtnOK.Parent := F;
    BtnOK.Caption := 'OK';
    //BtnOK.ModalResult := mrOk;
    BtnOK.Default := True;
    BtnOK.OnClick := @BusinessUnitOKClick;
    BtnOK.SetBounds(F.ClientWidth - cMargin - cBtnW*2 - 10, TopY + 6, cBtnW, cBtnH);

    BtnCancel := TButton.Create(F);
    BtnCancel.Parent := F;
    BtnCancel.Caption := 'Cancel';
    BtnCancel.ModalResult := mrCancel;
    BtnCancel.Cancel := True;
    BtnCancel.SetBounds(F.ClientWidth - cMargin - cBtnW, TopY + 6, cBtnW, cBtnH);

    F.ClientHeight := BtnOK.Top + BtnOK.Height + cMargin;

    //EdDepartment.SetFocus;

    if F.ShowModal(ASite) = mrOk then
    begin
      AParams.GetOrCreateParam(dtString, 'Name').AsString:= EdBusinessUnitName.Text;
      AParams.GetOrCreateParam(dtString, 'Department').AsString:= EdDepartment.Text;
      AParams.GetOrCreateParam(dtString, 'Street').AsString:= EdStreet.Text;
      AParams.GetOrCreateParam(dtString, 'City').AsString:= EdCity.Text;
      AParams.GetOrCreateParam(dtString, 'PostCode').AsString:= EdPostCode.Text;
      AParams.GetOrCreateParam(dtString, 'CountryCode').AsString:= EdCountryCode.Text;
      AParams.GetOrCreateParam(dtString, 'CountryName').AsString:= EdCountryName.Text;
      AParams.GetOrCreateParam(dtString, 'Recipient').AsString:= EdRecipient.Text;
      AParams.GetOrCreateParam(dtString, 'Phone').AsString:= EdPhone.Text;
      AParams.GetOrCreateParam(dtString, 'Email').AsString:= EdEmail.Text;
      Result := True;
    end;
  finally
    F.Free;
  end;
end;

procedure BusinessUnitOKClick(Sender: TComponent);
var
  F: TForm;
  EdCountryCode, EdCountryName: TEdit;
  mCountryName: string;
begin
  F := TForm(Sender.Owner);
  EdCountryCode := TEdit(F.FindChildControl('EdCountryCode'));
  EdCountryName:= TEdit(F.FindChildControl('EdCountryName'));

  if Trim(EdCountryCode.Text) = '' then
  begin
    NxShowSimpleMessage('Country code must be filled.', F);
    EdCountryCode.SetFocus;
    Exit;
  end;

  mCountryName:= Sender.Site.BaseObjectSpace.SQLSelectFirstAsString('SELECT Name FROM Countries WHERE Code = '+QuotedStr(Trim(EdCountryCode.Text)), '');
  if NxIsBlank(mCountryName) then
  begin
    NxShowSimpleMessage('Country code entered is not valid.', F);
    EdCountryCode.SetFocus;
    Exit;
  end;

  EdCountryName.Text:= mCountryName;

  F.ModalResult := mrOk;
end;




begin
end.