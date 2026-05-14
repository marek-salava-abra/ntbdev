Function GetGeneratorForm(ASite : TSiteForm; var AType: string; var AQuantity: integer):boolean;
var
 mBtnOK, mBtnCancel : TButton;
 aResult, mCount, mQuantity : integer;
 mForm : TForm;
 mLblQuantity, mLblType, mLblTypeName:TLabel;
 mCbBoxType:TRollComboEdit;
 mTNumEditQty: TNumEdit;
begin
 if ASite <> nil then begin
    Result:=False;
    mCount:=0;
    mForm:= TForm.Create(ASite);
    mForm.Width:= 300;
    mForm.Position:=poScreenCenter;
    mForm.Caption := 'Generovat přepravky';
    mForm.OnCloseQuery:= @OnFormCloseAction;

    mLblType := TLabel.Create(mForm);
    mLblType.Parent := mForm;
    mLblType.Caption := 'Typ:';
    mLblType.Top := (mCount*25)+12;
    mLblType.Left := 17;
    mLblType.Height := 13;
    mLblType.Width := 60;
    mLblType.Font.Size := 10;

    mLblTypeName:= TLabel.Create(mForm);
    mLblTypeName.Parent := mForm;
    mLblTypeName.Top := (mCount*25)+12;
    mLblTypeName.Left := 230;
    mLblTypeName.Height := 13;
    mLblTypeName.Width := 80;

    mCbBoxType:= TRollComboEdit.Create(mForm);
    mCbBoxType.Parent:= mForm;
    mCbBoxType.ClassID:= Roll_TransportBoxesLipoTypes;
    mCbBoxType.Complete:= True;
    mCbBoxType.Prefilling:= pmNone;
    mCbBoxType.TextField:= 'Code';  // položka podle které se bude vyhledávat TPOperation_ID
    mCbBoxType.Top:= (mCount*25)+10;
    mCbBoxType.Left:= 100;
    mCbBoxType.Width:= 120;
    mCbBoxType.ConnectedControl:= mLblTypeName;
    mCbBoxType.ConnectedControlField:= 'Name';

    mCount:= mCount+1;

    mLblQuantity:= TLabel.Create(mForm);
    mLblQuantity.Parent:= mForm;
    mLblQuantity.Caption := 'Počet:';
    mLblQuantity.Top:= (mCount*25)+12;
    mLblQuantity.Left:= 17;
    mLblQuantity.Width:= 60;
    mLblQuantity.Font.Size := 10;

    mTNumEditQty:= TNumEdit.Create(mForm);
    mTNumEditQty.Parent:= mForm;
    mTNumEditQty.top:= (mCount*25)+12;
    mTNumEditQty.Left:= 100;
    mTNumEditQty.Width:= 50;
    mTNumEditQty.DecimalPlaces:= 0;

    mCount:= mCount+1;

    mBtnOK:= TButton.Create(mForm);
    mBtnOK.Parent := mForm;
    mBtnOK.Default:= true;
    mBtnOK.Caption := 'OK';
    mBtnOK.Top := (mCount*25)+20;
    mBtnOK.Left := 44;
    mBtnOK.Height := 24;
    mBtnOK.Width := 62;
    mBtnOK.ModalResult := mrOk;

    mBtnCancel := TButton.Create(mForm);
    mBtnCancel.Parent := mForm;
    mBtnCancel.Caption := 'Zrušit';
    mBtnCancel.Top := (mCount*25)+20;
    mBtnCancel.Left := 194;
    mBtnCancel.Height := 24;
    mBtnCancel.Width := 62;
    mBtnCancel.ModalResult := mrCancel;

    mForm.Height:= (mCount*25)+95;

    if mForm.ShowModal(ASite) = mrOk then begin
      AQuantity:= trunc(mTNumEditQty.Value);
      AType:= mCbBoxType.DataText;
      Result:= True;
    end;
    mForm.free;
  end;
end;


procedure OnFormCloseAction(Sender: TObject; var Action: TCloseAction);
begin
  if Action = caHide then TForm(Sender).ModalResult := mrCancel;
end;


begin
end.