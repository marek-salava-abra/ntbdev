Var
  gModalResult : integer;

procedure InitSite_Hook(Self: TSiteForm);
var
  mAction: TBasicAction;
  mUser : TNxCustomBusinessObject;
begin
  if not Assigned(Self.BaseObjectSpace) then
    exit;

    mAction := Self.GetNewAction;
    mAction.ShowControl := True;
    mAction.ShowMenuItem := True;
    mAction.Caption := 'Příplatek';
    mAction.Hint := 'Doplní pořizovací náklady';
    mAction.Category := 'tabList';
    mAction.OnExecute := @ImportOnExecute;
    mAction.OnUpdate := @ImportOnUpdate;
  end;


procedure ImportOnUpdate(Sender: TObject);
begin
  TBasicAction(Sender).Enabled := True;
end;

procedure ImportOnExecute(Sender: TObject);
var
mSite: TSiteForm;
mPPLNumber: Extended;
mPPLDate: TDateTime;
mFV: TNxCustomBusinessObject;
begin
if Sender is TComponent then begin
    mSite := TComponent(Sender).DynSite;
    if Assigned(mSite) and (mSite is TDynSiteForm) then begin
      mfv := TDynSiteForm(mSite).CurrentObject;
      mPPLNumber:=mfv.GetFieldValueAsFloat('AdditionalCostsSum');
                  PPLData(mPPLDate,mPPLNumber, msite);

                mfv.SetFieldValueAsFloat('AdditionalCostsSum',mpplnumber);
  mfv.Save;
  mfv.Free;
 end;
end;
end;

Function PPLData(var aPPLdate:TDateTime; var aPPlNumber: Double; var asite:TSiteForm):boolean;

 var
  mForm: TForm;
  mLab: TLabel;
  mEd1: TNumEdit;
  mEd2: TDateEdit;
  mResult: integer;
  mBut: TButton;
begin
  mForm := TForm.Create(Nil);
  try
    mForm.Caption := 'Zadejte popis';
    mForm.FormStyle := fsStayOnTop;
    mForm.BorderStyle := bsDialog;
    mForm.Width := 350;
    mForm.Height := 120;
    mForm.Scaled := False;
    mLab := TLabel.Create(mForm);
    mLab.Left := 10;
    mLab.Top := 10;
    mLab.Caption := 'Náklady';
    mLab.Parent := mForm;
    mLab := TLabel.Create(mForm);
    mLab.Left := 10;
    mLab.Top := 35;
    mLab.Parent := mForm;
    mEd1 := TNumEdit.Create(mForm);
    mEd1.Left := 110;
    mEd1.Top := 6;
    mEd1.Width := 200;
    mEd1.DecimalPlaces:= 2;
    mEd1.Parent := mForm;
    mEd1.Name := 'mPPLNumber';
    CreateButton(mForm, mForm, 60, 20, 70, 25, 'Cancel', 2);
    CreateButton(mForm, mForm, 60, 120, 70, 25, 'OK', 1);
    mResult := mForm.Showmodal(asite);
    if mResult = 1 then
      //ShowMessage('Řádně jste zadal:' + Chr(13) + Chr(10) + mEd1.Text + Chr(13) + Chr(10) + mEd2.Text);


  finally
    mForm.Free;
  end;
end;


function CreateButton(AOwner: TComponent; AParent: TWinControl; ATop, ALeft, AWidth, AHeight: integer; ACaption: string; AModalResult: integer): TButton;
begin
  Result := TButton.Create(AOwner);
  Result.Top := ATop;
  Result.Left := ALeft;
  Result.Width := AWidth;
  Result.Height := AHeight;
  Result.Caption := ACaption;
  Result.ModalResult := AModalResult;
  Result.Parent := AParent;
end;

begin
end.