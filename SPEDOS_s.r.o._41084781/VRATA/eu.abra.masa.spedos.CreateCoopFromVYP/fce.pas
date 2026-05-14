function GetCoopFirm(var ASite : TSiteform; var aFirm_ID, aIntrastatComodity_ID:string) : Boolean;
var mForm : TForm;
    mCb, mCb1: TRollComboEdit;
    mCbCc, mCbCc1: TLabel;
    mLabel1, mLabel2, mLabel3 : TLabel;
    mButOk, mButCancel : TButton;
    mResult : integer;
begin
  if ASite <> nil then begin
    mForm:= TForm.Create(ASite);  //Form mus=i být vytvářen na Site , kvuli přebráni Contextu
    mForm.Left:= 300;
    mForm.Top:= 300;
    mForm.Width:= 409;
    mForm.Height:= 125;
    mForm.Caption := 'Firma pro kooperaci';
    mForm.OnCloseQuery:= @OnFormCloseAction;

    mLabel3 := TLabel.Create(mForm);
    mLabel3.Parent := mForm;
    mLabel3.Caption := 'Firma:';
    mLabel3.Top := 8;
    mLabel3.Left := 17;
    mLabel3.Height := 13;
    mLabel3.Width := 200;
    mLabel3.Font.Size := 10;


    mCbCc:= TLabel.Create(mForm);  //Vytvoŕení containeru pro zobrazení výběru
    mCbCc.Parent:= mForm;
    //mCbCc.BevelOuter:= bvLowered;
    mCbCc.Left:= 230;
    mCbCc.Top:= 8;
    mCbCc.Width:= 255;

    mCb:= TRollComboEdit.Create(mForm);
    mCb.Parent:= mForm;

    mCb.ClassID:= Roll_Firms;
    mCb.Complete:= True;
    mCb.ForcedField:= True;
    mCb.Prefilling:= pmNone;
    mCb.TextField:= 'CODE';  // položka podle které se bude vyhledávat
    mCb.Top:= 6;
    mCb.Left:= 110;
    mCb.Width:= 108;
    mCb.ConnectedControl:= mCbCc;
    mCb.ConnectedControlField:= 'Name';

    mLabel3 := TLabel.Create(mForm);
    mLabel3.Parent := mForm;
    mLabel3.Caption := 'Nomenklatura:';
    mLabel3.Top := 33;
    mLabel3.Left := 17;
    mLabel3.Height := 13;
    mLabel3.Width := 200;
    mLabel3.Font.Size := 10;


    mCbCc1:= TLabel.Create(mForm);  //Vytvoŕení containeru pro zobrazení výběru
    mCbCc1.Parent:= mForm;
    //mCbCc.BevelOuter:= bvLowered;
    mCbCc1.Left:= 230;
    mCbCc1.Top:= 33;
    mCbCc1.Width:= 255;

    mCb1:= TRollComboEdit.Create(mForm);
    mCb1.Parent:= mForm;

    mCb1.ClassID:= Roll_IntrastatCommodities;
    mCb1.Complete:= True;
    mCb1.ForcedField:= True;
    mCb1.Prefilling:= pmNone;
    mCb1.TextField:= 'CODE';  // položka podle které se bude vyhledávat
    mCb1.Top:= 31;
    mCb1.Left:= 110;
    mCb1.Width:= 108;
    mCb1.ConnectedControl:= mCbCc1;
    mCb1.ConnectedControlField:= 'Description';


    mButOk:= TButton.Create(mForm);
    mButOk.Parent := mForm;
    mButOk.Caption := 'Ok';
    mButOk.Top := 60;
    mButOk.Left := 252;
    mButOk.Height := 24;
    mButOk.Width := 62;
    mButOk.Default := True;
    mbutok.Cancel := false;
    mButOk.ModalResult := 1;

    mButCancel := TButton.Create(mForm);
    mButCancel.Parent := mForm;
    mButCancel.Caption := 'Cancel';
    mButCancel.Top := 60;
    mButCancel.Left := 320;
    mButCancel.Height := 24;
    mButCancel.Width := 62;
    mButCancel.Cancel := True;
    mButCancel.ModalResult := 2;


    mResult := mForm.ShowModal(ASite);
   // if mButCancel.OnC
    if mResult = 1 then begin
        Result := true;
        aFirm_ID:=mCb.DataText;
        aIntrastatComodity_ID:=mCb1.DataText;
    end else Result := false;
    //ShowMessage(mCb.DataText);
    //Result := mCb.DataText;
    mForm.free;
  end;
end;

function GetCoopData(var ASite : TSiteform; var aFirm_ID, aStore_ID, aType:string) : Boolean;
var mForm : TForm;
    mCb, mCb1: TRollComboEdit;
    mCbCc, mCbCc1: TLabel;
    mEd:TEdit;
    mLabel1, mLabel2, mLabel3 : TLabel;
    mButOk, mButCancel : TButton;
    mResult : integer;
begin
  if ASite <> nil then begin
    mForm:= TForm.Create(ASite);  //Form mus=i být vytvářen na Site , kvuli přebráni Contextu
    mForm.Left:= 300;
    mForm.Top:= 300;
    mForm.Width:= 409;
    mForm.Height:= 150;
    mForm.Caption := 'Firma pro kooperaci';
    mForm.OnCloseQuery:= @OnFormCloseAction;

    mLabel3 := TLabel.Create(mForm);
    mLabel3.Parent := mForm;
    mLabel3.Caption := 'Firma:';
    mLabel3.Top := 8;
    mLabel3.Left := 17;
    mLabel3.Height := 13;
    mLabel3.Width := 200;
    mLabel3.Font.Size := 10;


    mCbCc:= TLabel.Create(mForm);  //Vytvoŕení containeru pro zobrazení výběru
    mCbCc.Parent:= mForm;
    //mCbCc.BevelOuter:= bvLowered;
    mCbCc.Left:= 200;
    mCbCc.Top:= 10;
    mCbCc.Width:= 255;

    mCb:= TRollComboEdit.Create(mForm);
    mCb.Parent:= mForm;

    mCb.ClassID:= Roll_Firms;
    mCb.Complete:= True;
    mCb.ForcedField:= True;
    mCb.Prefilling:= pmNone;
    mCb.TextField:= 'CODE';  // položka podle které se bude vyhledávat
    mCb.Top:= 8;
    mCb.Left:= 87;
    mCb.Width:= 108;
    mCb.ConnectedControl:= mCbCc;
    mCb.ConnectedControlField:= 'Name';

    mLabel3 := TLabel.Create(mForm);
    mLabel3.Parent := mForm;
    mLabel3.Caption := 'Sklad:';
    mLabel3.Top := 33;
    mLabel3.Left := 17;
    mLabel3.Height := 13;
    mLabel3.Width := 200;
    mLabel3.Font.Size := 10;


    mCbCc1:= TLabel.Create(mForm);  //Vytvoŕení containeru pro zobrazení výběru
    mCbCc1.Parent:= mForm;
    //mCbCc.BevelOuter:= bvLowered;
    mCbCc1.Left:= 200;
    mCbCc1.Top:= 35;
    mCbCc1.Width:= 255;

    mCb1:= TRollComboEdit.Create(mForm);
    mCb1.Parent:= mForm;

    mCb1.ClassID:= Roll_Stores;
    mCb1.Complete:= True;
    mCb1.ForcedField:= True;
    mCb1.Prefilling:= pmNone;
    mCb1.TextField:= 'CODE';  // položka podle které se bude vyhledávat
    mCb1.Top:= 33;
    mCb1.Left:= 87;
    mCb1.Width:= 108;
    mCb1.ConnectedControl:= mCbCc1;
    mCb1.ConnectedControlField:= 'Name';


    mLabel3 := TLabel.Create(mForm);
    mLabel3.Parent := mForm;
    mLabel3.Caption := 'Typ koo:';
    mLabel3.Top := 58;
    mLabel3.Left := 17;
    mLabel3.Height := 13;
    mLabel3.Width := 200;
    mLabel3.Font.Size := 10;

    mEd := TEdit.Create(mForm);
    mEd.Left := 87;
    mEd.Top := 58;
    mEd.Width := 200;
    mEd.Text := '';
    mEd.Parent := mForm;


    mButOk:= TButton.Create(mForm);
    mButOk.Parent := mForm;
    mButOk.Caption := 'Ok';
    mButOk.Top := 85;
    mButOk.Left := 252;
    mButOk.Height := 24;
    mButOk.Width := 62;
    mButOk.Default := True;
    mbutok.Cancel := false;
    mButOk.ModalResult := 1;

    mButCancel := TButton.Create(mForm);
    mButCancel.Parent := mForm;
    mButCancel.Caption := 'Cancel';
    mButCancel.Top := 85;
    mButCancel.Left := 320;
    mButCancel.Height := 24;
    mButCancel.Width := 62;
    mButCancel.Cancel := True;
    mButCancel.ModalResult := 2;


    mResult := mForm.ShowModal(ASite);
   // if mButCancel.OnC
    if mResult = 1 then begin
        Result := true;
        aFirm_ID:=mCb.DataText;
        aStore_ID:=mCb1.DataText;
        aType:=mEd.Text;
    end else Result := false;
    //ShowMessage(mCb.DataText);
    //Result := mCb.DataText;
    mForm.free;
  end;
end;

procedure OnFormCloseAction(Sender: TObject; var Action: TCloseAction);
begin
  if Action = caHide then TForm(Sender).ModalResult := mrCancel;
end;


begin
end.