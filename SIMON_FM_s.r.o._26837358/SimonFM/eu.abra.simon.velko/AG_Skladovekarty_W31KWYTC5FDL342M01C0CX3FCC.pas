uses 'eu.abra.simon.velko.lib';

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
    mAction.Caption := 'Karta VO';
    mAction.Hint := 'Karta VO';
    mAction.Category := 'tabList';
    mAction.OnExecute := @ImportOnExecute;
    mAction := Self.GetNewAction;
    mAction.ShowControl := True;
    mAction.ShowMenuItem := True;
    mAction.Caption := 'Koeficient';
    mAction.Hint := 'Koeficient';
    mAction.Category := 'tabList';
    mAction.OnExecute := @ChangeKoef;
    mAction := Self.GetNewAction;
    mAction.ShowControl := True;
    mAction.ShowMenuItem := True;
    mAction.Caption := 'Obrázky';
    mAction.Hint := 'Nahraje obrázek';
    mAction.Category := 'tabList';
    mAction.OnExecute := @InsertPicture;
    mAction := Self.GetNewAction;
    mAction.ShowControl := True;
    mAction.ShowMenuItem := True;
    mAction.Caption := 'Poznámka';
    mAction.Hint := 'Poznámka';
    mAction.Category := 'tabList';
    mAction.OnExecute := @ChangeNote;
  end;


procedure ImportOnUpdate(Sender: TObject);
begin
  TBasicAction(Sender).Enabled := True;
end;

procedure ImportOnExecute(Sender: TObject);
var
mSite: TSiteForm;
mPPLNumber: String;
mPPLDate: TDateTime;
mFV: TNxCustomBusinessObject;
begin
if Sender is TComponent then begin
    mSite := TComponent(Sender).BusRollSite;
    if Assigned(mSite) and (mSite is TBusRollSiteForm) then begin
      mfv := TBusRollSiteForm(mSite).CurrentObject;
      mfv.SetFieldValueAsBoolean('U_velko',not(mfv.GetFieldValueAsBoolean('U_velko')));
      mfv.Save;
      if mFV.GetFieldValueAsBoolean('U_velko') then NxShowMessage('info','Karta nastavena jako velkoobchodní', mdInformation,False,mSite);
      if not(mFV.GetFieldValueAsBoolean('U_velko')) then NxShowMessage('info','Karta nastavena jako malooobchodní', mdInformation,False,mSite);
      mfv.Free;
    end;
  end;

end;

procedure ChangeKoef(Sender: TObject);
var
mSite: TSiteForm;
mKoef:Extended;
mFV: TNxCustomBusinessObject;
begin
if Sender is TComponent then begin
    mSite := TComponent(Sender).BusRollSite;
    if Assigned(mSite) and (mSite is TBusRollSiteForm) then begin
      mfv := TBusRollSiteForm(mSite).CurrentObject;
      mKoef:=mfv.GetFieldValueAsFloat('U_marze');
      KoeficientData(mKoef, mSite);
      mfv.SetFieldValueAsFloat('U_marze',mKoef);
      mfv.Save;
      mfv.Free;
    end;
  end;

end;

procedure ChangeNote(Sender: TObject);
var
mSite: TSiteForm;
mOS: TNxCustomObjectSpace;
mFV: TNxCustomBusinessObject;
mList:TStringList;
mNote:String;
i:integer;
begin
if Sender is TComponent then begin
    mSite := TComponent(Sender).BusRollSite;
    mOS:= TComponent(Sender).BusRollSite.CurrentObject.ObjectSpace;
    mList:=TStringList.Create;
    NoteData(mNote, mSite);
    TComponent(sender).BusRollSite.FillListWithSelectedRows(mlist);
    for i:=0 to mList.Count-1 do begin
      if Assigned(mSite) and (mSite is TBusRollSiteForm) then begin
        mfv := mOS.CreateObject(Class_StoreCard);
        mfv.Load(mList.strings[i],nil);
        mfv.SetFieldValueAsString('Note',mNote);
        mfv.Save;
        mfv.Free;
      end;
    end;
  TBusRollSiteForm(mSite).RefreshData;
  end;

end;


Function KoeficientData(var aKoeficient:Extended; var asite:TSiteForm):boolean;

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
    mForm.Caption := 'Zadejte keficient';
    mForm.FormStyle := fsStayOnTop;
    mForm.BorderStyle := bsDialog;
    mform.Position:=poScreenCenter;
    mForm.Width := 350;
    mForm.Height := 120;
    mForm.Scaled := False;
    mLab := TLabel.Create(mForm);
    mLab.Left := 10;
    mLab.Top := 10;
    mLab.Caption := 'Koeficient';
    mLab.Parent := mForm;
    mLab := TLabel.Create(mForm);
    mLab.Left := 10;
    mLab.Top := 35;
    mLab.Parent := mForm;
    mEd1 := TNumEdit.Create(mForm);
    mEd1.Left := 110;
    mEd1.Top := 6;
    mEd1.Width := 200;
    mEd1.Value:= aKoeficient;
    mEd1.Parent := mForm;
    CreateButton(mForm, mForm, 60, 20, 70, 25, 'Cancel', 2);
    CreateButton(mForm, mForm, 60, 120, 70, 25, 'OK', 1);
    mResult := mForm.Showmodal(asite);
    if mResult = 1 then
      //ShowMessage('Řádně jste zadal:' + Chr(13) + Chr(10) + mEd1.Text + Chr(13) + Chr(10) + mEd2.Text);

      aKoeficient:=mEd1.Value;
  finally
    mForm.Free;
  end;
end;


Function NoteData(var aNote:String; var asite:TSiteForm):boolean;

 var
  mForm: TForm;
  mLab: TLabel;
  mEd1: TNumEdit;
  mEd2: TDateEdit;
  mED: TEdit;
  mEd6, mEd7: TMemo;
  mResult: integer;
  mBut: TButton;
begin
  mForm := TForm.Create(Nil);
  try
    mForm.Caption := 'Zadejte poznámku';
    mForm.FormStyle := fsStayOnTop;
    mForm.BorderStyle := bsDialog;
    mform.Position:=poScreenCenter;
    mForm.Width := 520;
    mForm.Height := 250;
    mForm.Scaled := False;
    mLab := TLabel.Create(mForm);
    mLab.Left := 10;
    mLab.Top := 10;
    mLab.Caption := 'Poznámka';
    mLab.Parent := mForm;
    mLab := TLabel.Create(mForm);
    mLab.Left := 10;
    mLab.Top := 35;
    mLab.Parent := mForm;
    mEd6 := TMemo.Create(mForm);
    mEd6.Left := 107;
    mEd6.Top := 10;
    mEd6.Width := 380;
    med6.Height:= 60;
    mEd6.Text := '';
    mEd6.Parent := mForm;
    CreateButton(mForm, mForm, 160, 20, 70, 25, 'Cancel', 2);
    CreateButton(mForm, mForm, 160, 120, 70, 25, 'OK', 1);
    mResult := mForm.Showmodal(asite);
    if mResult = 1 then
      //ShowMessage('Řádně jste zadal:' + Chr(13) + Chr(10) + mEd1.Text + Chr(13) + Chr(10) + mEd2.Text);

      aNote:=mEd6.Text;
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