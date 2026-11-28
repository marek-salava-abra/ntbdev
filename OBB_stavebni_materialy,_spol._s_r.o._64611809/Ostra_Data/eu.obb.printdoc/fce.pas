Function GetCopies(var ASite : TSiteform; var aResult:integer; var aCopyDoc, aCopyDL:Extended;):Boolean;
var
    mLabel1: TLabel;
    mBEd1: TCheckBox;
    mButOk, mButCancel : TButton;
    mResult : integer;
    mForm : TForm;
    mAllowed:TStringList;
    mSQL:String;
    mNumEd, mNumEd1:TNumEdit;

begin
 if ASite <> nil then begin
    mForm:= TForm.Create(ASite);  //Form mus=i být vytvářen na Site , kvuli přebráni Contextu
    mForm.Left:= 300;
    mForm.Top:= 300;
    mForm.Width:= 360;
    mForm.Height:= 180;
    mForm.Position:=poScreenCenter;
    mForm.Caption := 'Zadejte údaje pro tisk';

    mLabel1 := TLabel.Create(mForm);
    mLabel1.Parent := mForm;
    mLabel1.Caption := 'Počet kopií dokladu:';
    mLabel1.Top := 15;
    mLabel1.Left := 17;
    mLabel1.Height := 13;
    mLabel1.Width := 100;
    mLabel1.Font.Size := 10;

    mNumEd:= tNumEdit.Create(mForm);
    mNumEd.Left := 140;
    mNumEd.Top := 15;
    mNumEd.Value:=aCopyDoc;
    mNumEd.DecimalPlaces := 0;
    mNumEd.Width := 50;
    mNumEd.Parent := mForm;

    mLabel1 := TLabel.Create(mForm);
    mLabel1.Parent := mForm;
    mLabel1.Caption := 'Počet kopií DL:';
    mLabel1.Top := 37;
    mLabel1.Left := 17;
    mLabel1.Height := 13;
    mLabel1.Width := 100;
    mLabel1.Font.Size := 10;

    mNumEd1:= tNumEdit.Create(mForm);
    mNumEd1.Left := 140;
    mNumEd1.Top := 37;
    mNumEd1.Value:=aCopyDL;
    mNumEd1.DecimalPlaces := 0;
    mnumed1.Width := 50;
    mNumEd1.Parent := mForm;



    mButOk:= TButton.Create(mForm);
    mButOk.Parent := mForm;
    mButOk.Caption := 'OK';
    mButOk.Top := 70;
    mButOk.Left := 152;
    mButOk.Height := 24;
    mButOk.Width := 62;
    mButOk.ModalResult := 1;

    mButCancel := TButton.Create(mForm);
    mButCancel.Parent := mForm;
    mButCancel.Caption := 'Zrušit';
    mButCancel.Top := 70;
    mButCancel.Left := 220;
    mButCancel.Height := 24;
    mButCancel.Width := 62;
    mButCancel.ModalResult := 2;

    Result:=False;
    mResult := mForm.ShowModal(ASite);
    aResult:= mResult;
   // if mButCancel.OnC
    if mResult = 1 then
         aCopyDoc:=mNumEd.value;
         aCopyDL:=mnumed1.value;
        Result:=true;
    //ShowMessage(mCb.DataText);
    //Result := mCb.DataText;
    mForm.free;
  end;
end;

begin
end.