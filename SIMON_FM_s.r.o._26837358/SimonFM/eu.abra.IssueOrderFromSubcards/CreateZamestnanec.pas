function RGBToColor(const R, G, B: Byte): Integer;
begin
	  Result := R or (G shl 8) or (B shl 16);
end;

Function SpotrebaData(asite:tsiteform;var aBusProject_ID:string;var aStore_id:string; var aStoreCard_ID:string;
                        var aEAN: string; var aDialog:Boolean; var aQuantity:Extended; var aDescription:String; var aUser:TNxCustomBusinessObject):boolean;

 var mForm : TForm;
    mCbStoreCard, mCbFirmRepair, mCbFirm, mCbPerson, mCbUser: TRollComboEdit;
    mCbCcStoreCard, mCbCcFirmRepair, mCbCcFirm, mCbCcPerson, mCbCcUser: TLabel;
    mLabel3 : TLabel;
    mEd1, mEd2, mEd3, mEd4,mEd5, mEd8, med9 : TEdit;
    mEd6, mEd7: TMemo;
    mNumEdit, mNumEdit1: TNumEdit;
    mButOk, mButCancel : TButton;
    mResult : integer;
    mP1:TPanel;
begin

    mForm:= TForm.Create(aSite);  //Form mus=i být vytvářen na Site , kvuli přebráni Contextu
    mForm.Parent:=nil;
    mForm.Width:= 520;
    mForm.Height:= 220;
    mForm.Caption := 'Zadejte údaje pro spotřebu firma';
    mForm.Position := poScreenCenter;
    mForm.Color := clLime;

    if aUser.GetFieldValueAsBoolean('U_barvy') then begin
    //mForm.Font.Color := clRed;
    mLabel3 := TLabel.Create(mForm);
    mLabel3.Parent := mForm;
    mLabel3.Caption := '-';
    mLabel3.Top := -2200;
    mLabel3.Left := -180;
    mLabel3.Height := 13;
    mLabel3.Font.Color := RGBToColor(aUser.GetFieldValueAsInteger('U_base_r'),aUser.GetFieldValueAsInteger('U_base_g'),aUser.GetFieldValueAsInteger('U_base_b'));
    //mLabel3.Font.Color := RGBToColor(255,89,255);
    mlabel3.font.Height:=4000;
    end;
    mLabel3 := TLabel.Create(mForm);
    mLabel3.Parent := mForm;
    mLabel3.Caption := 'Zaměstnanec:';
    mLabel3.Top := 17;
    mLabel3.Left := 17;
    mLabel3.Height := 13;
    if aUser.GetFieldValueAsBoolean('U_barvy') then begin
    mLabel3.Font.Color := RGBToColor(aUser.GetFieldValueAsInteger('U_char_r'),aUser.GetFieldValueAsInteger('U_char_g'),aUser.GetFieldValueAsInteger('U_char_b'));
    mlabel3.Font.Style := [fsBold];
    mlabel3.ParentFont := False;
    end;
    //mp1.InsertControl(mLabel3);

    mCbCcFirm:= TLabel.Create(mForm);  //Vytvoŕení containeru pro zobrazení výběru
    mCbCcFirm.Parent:= mForm;
    //mCbCcFirm.BevelOuter:= bvLowered;
    mCbCcFirm.Left:= 228;
    mCbCcFirm.Top:= 15;
    mCbCcFirm.Width:= 255;

    mCbFirm:= TRollComboEdit.Create(mForm);
    mCbFirm.Parent:= mForm;

    mCbFirm.ClassID:= 'ZX20VMNR1NV4N30K2MRDAXLRN4';
    mCbFirm.Complete:= True;
    mCbFirm.ForcedField:= True;
    mCbFirm.Prefilling:= pmNone;
    mCbFirm.TextField:= 'Code';  // položka podle které se bude vyhledávat
    mCbFirm.Top:= 15;
    mCbFirm.Left:= 107;
    mCbFirm.Width:= 108;
    mCbFirm.ConnectedControl:= mCbCcFirm;
    mCbFirm.ConnectedControlField:= 'Name';  //položka která bude zobrazena v containeru

    mLabel3 := TLabel.Create(mForm);
    mLabel3.Parent := mForm;
    mLabel3.Caption := 'Sklad:';
    mLabel3.Top := 37;
    mLabel3.Left := 17;
    mLabel3.Height := 13;
    if aUser.GetFieldValueAsBoolean('U_barvy') then begin
    mLabel3.Font.Color := RGBToColor(aUser.GetFieldValueAsInteger('U_char_r'),aUser.GetFieldValueAsInteger('U_char_g'),aUser.GetFieldValueAsInteger('U_char_b'));
    mlabel3.Font.Style := [fsBold];
    mlabel3.ParentFont := False;
    end;

    mCbCcPerson:= TLabel.Create(mForm);  //Vytvoŕení containeru pro zobrazení výběru
    mCbCcPerson.Parent:= mForm;
    //mCbCcPerson.BevelOuter:= bvLowered;
    mCbCcPerson.Left:= 228;
    mCbCcPerson.Top:= 35;
    mCbCcPerson.Width:= 255;

    mCbPerson:= TRollComboEdit.Create(mForm);
    mCbPerson.Parent:= mForm;

    mCbPerson.ClassID:= 'O3ZO2K155FDL3CL100C4RHECN0';
    mCbPerson.Complete:= True;
    mCbPerson.ForcedField:= True;
    mCbPerson.Prefilling:= pmNone;
    mCbPerson.TextField:= 'Code';  // položka podle které se bude vyhledávat
    mCbPerson.Top:= 35;
    mCbPerson.DataText:= aStore_id;
    mCbPerson.Left:= 107;
    mCbPerson.Width:= 108;
    mCbPerson.ConnectedControl:= mCbCcPerson;
    mCbPerson.ConnectedControlField:= 'Name';  //položka která bude zobrazena v containeru

    mLabel3 := TLabel.Create(mForm);
    mLabel3.Parent := mForm;
    mLabel3.Caption := 'Skl. karta:';
    mLabel3.Top := 57;
    mLabel3.Left := 17;
    mLabel3.Height := 13;
    if aUser.GetFieldValueAsBoolean('U_barvy') then begin
    mLabel3.Font.Color := RGBToColor(aUser.GetFieldValueAsInteger('U_char_r'),aUser.GetFieldValueAsInteger('U_char_g'),aUser.GetFieldValueAsInteger('U_char_b'));
    mlabel3.Font.Style := [fsBold];
    mlabel3.ParentFont := False;
    end;

    mCbCcStoreCard:= TLabel.Create(mForm);  //Vytvoŕení containeru pro zobrazení výběru
    mCbCcStoreCard.Parent:= mForm;
    //mCbCcStoreCard.BevelOuter:= bvLowered;
    mCbCcStoreCard.Left:= 228;
    mCbCcStoreCard.Top:= 55;
    mCbCcStoreCard.Width:= 255;

    mCbStoreCard:= TRollComboEdit.Create(mForm);
    mCbStoreCard.Parent:= mForm;

    mCbStoreCard.ClassID:= 'S3WZQKDB5FDL342M01C0CX3FCC';
    mCbStoreCard.Complete:= True;
    mCbStoreCard.ForcedField:= True;
    mCbStoreCard.Prefilling:= pmNone;
    mCbStoreCard.TextField:= 'Code';  // položka podle které se bude vyhledávat
    mCbStoreCard.Top:= 55;
    mCbStoreCard.DataText:= aStoreCard_ID;
    mCbStoreCard.Left:= 107;
    mCbStoreCard.Width:= 108;
    mCbStoreCard.ConnectedControl:= mCbCcStoreCard;
    mCbStoreCard.ConnectedControlField:= 'Name';  //položka která bude zobrazena v containeru


    mLabel3 := TLabel.Create(mForm);
    mLabel3.Parent := mForm;
    mLabel3.Caption := 'EAN:';
    mLabel3.Top := 79;
    mLabel3.Left := 17;
    mLabel3.Height := 13;
    if aUser.GetFieldValueAsBoolean('U_barvy') then begin
    mLabel3.Font.Color := RGBToColor(aUser.GetFieldValueAsInteger('U_char_r'),aUser.GetFieldValueAsInteger('U_char_g'),aUser.GetFieldValueAsInteger('U_char_b'));
    mlabel3.Font.Style := [fsBold];
    mlabel3.ParentFont := False;
    end;


    mEd8 := TEdit.Create(mForm);
    mEd8.Left := 107;
    mEd8.Top := 79;
    mEd8.Width := 380;
    mEd8.Text := '';
    mEd8.Parent := mForm;

    mLabel3 := TLabel.Create(mForm);
    mLabel3.Parent := mForm;
    mLabel3.Caption := 'Množství:';
    mLabel3.Top := 99;
    mLabel3.Left := 17;
    mLabel3.Height := 13;
    if aUser.GetFieldValueAsBoolean('U_barvy') then begin
    mLabel3.Font.Color := RGBToColor(aUser.GetFieldValueAsInteger('U_char_r'),aUser.GetFieldValueAsInteger('U_char_g'),aUser.GetFieldValueAsInteger('U_char_b'));
    mlabel3.Font.Style := [fsBold];
    mlabel3.ParentFont := False;
    end;

    mNumEdit:= TNumEdit.Create(mForm);
    mNumEdit.Parent :=mForm;
    mNumEdit.ParentFont:=false;
    mNumEdit.left := 107;
    mNumEdit.top := 99;
    mNumEdit.Value := aQuantity;

    mLabel3 := TLabel.Create(mForm);
    mLabel3.Parent := mForm;
    mLabel3.Caption := 'Popis:';
    mLabel3.Top := 119;
    mLabel3.Left := 17;
    mLabel3.Height := 13;
    if aUser.GetFieldValueAsBoolean('U_barvy') then begin
    mLabel3.Font.Color := RGBToColor(aUser.GetFieldValueAsInteger('U_char_r'),aUser.GetFieldValueAsInteger('U_char_g'),aUser.GetFieldValueAsInteger('U_char_b'));
    mlabel3.Font.Style := [fsBold];
    mlabel3.ParentFont := False;
    end;

    mEd1:= TEdit.Create(mForm);
    mEd1.Parent :=mForm;
    mEd1.left := 107;
    mEd1.top := 119;
    mEd1.Width := 380;
    mEd1.Text := aDescription;

    mButOk:= TButton.Create(mForm);
    mButOk.Parent := mForm;
    mButOk.Caption := 'Ok';
    mButOk.Top := 149;
    mButOk.Left := 252;
    mButOk.Height := 24;
    mButOk.Width := 62;
    mButOk.ModalResult := 1;

    mButCancel := TButton.Create(mForm);
    mButCancel.Parent := mForm;
    mButCancel.Caption := 'Cancel';
    mButCancel.Top := 149;
    mButCancel.Left := 320;
    mButCancel.Height := 24;
    mButCancel.Width := 62;
    mButCancel.ModalResult := 2;


    mResult := mForm.ShowModal(asite);
   // if mButCancel.OnC
    if mResult = 1 then begin
        aBusProject_id:= mCbFirm.DataText;
        aStore_id:= mCbPerson.DataText;
        if not(NxIsEmptyOID(mCbStoreCard.DataText)) then aStoreCard_ID:= mCbStoreCard.DataText;
        aEAN:=mEd8.Text;
        aQuantity:= mNumEdit.Value;
        aDescription:=med1.Text;
        adialog:=true;
        end;
    if mResult=2 then aDialog:=False;

    //ShowMessage(mCb.DataText);
    //Result := mCb.DataText;
    mForm.free;

end;


Function ZamestnanciData(asite:tsiteform;var aBusProject_ID:string;var aStore_id:string; var aStoreCard_ID:string;
                        var aEAN: string; var aDialog:Boolean; var aQuantity:Extended; var aCenaKK:Extended):boolean;

 var mForm : TForm;
    mCbStoreCard, mCbFirmRepair, mCbFirm, mCbPerson, mCbUser: TRollComboEdit;
    mCbCcStoreCard, mCbCcFirmRepair, mCbCcFirm, mCbCcPerson, mCbCcUser: TLabel;
    mLabel3 : TLabel;
    mEd1, mEd2, mEd3, mEd4,mEd5, mEd8, med9 : TEdit;
    mEd6, mEd7: TMemo;
    mNumEdit, mNumEdit1: TNumEdit;
    mButOk, mButCancel : TButton;
    mResult : integer;
begin

    mForm:= TForm.Create(asite);  //Form mus=i být vytvářen na Site , kvuli přebráni Contextu
    mForm.Width:= 520;
    mForm.Height:= 210;
    mForm.Caption := 'Zadejte údaje pro zaměstnanecký prodej';
    mForm.Position := poScreenCenter;

    mLabel3 := TLabel.Create(mForm);
    mLabel3.Parent := mForm;
    mLabel3.Caption := 'Zaměstnanec:';
    mLabel3.Top := 17;
    mLabel3.Left := 17;
    mLabel3.Height := 13;

    mCbCcFirm:= TLabel.Create(mForm);  //Vytvoŕení containeru pro zobrazení výběru
    mCbCcFirm.Parent:= mForm;
    //mCbCcFirm.BevelOuter:= bvLowered;
    mCbCcFirm.Left:= 228;
    mCbCcFirm.Top:= 15;
    mCbCcFirm.Width:= 255;

    mCbFirm:= TRollComboEdit.Create(mForm);
    mCbFirm.Parent:= mForm;

    mCbFirm.ClassID:= 'ZX20VMNR1NV4N30K2MRDAXLRN4';
    mCbFirm.Complete:= True;
    mCbFirm.ForcedField:= True;
    mCbFirm.Prefilling:= pmNone;
    mCbFirm.TextField:= 'Code';  // položka podle které se bude vyhledávat
    mCbFirm.Top:= 15;
    mCbFirm.Left:= 107;
    mCbFirm.Width:= 108;
    mCbFirm.ConnectedControl:= mCbCcFirm;
    mCbFirm.ConnectedControlField:= 'Name';  //položka která bude zobrazena v containeru

    mLabel3 := TLabel.Create(mForm);
    mLabel3.Parent := mForm;
    mLabel3.Caption := 'Sklad:';
    mLabel3.Top := 37;
    mLabel3.Left := 17;
    mLabel3.Height := 13;

    mCbCcPerson:= TLabel.Create(mForm);  //Vytvoŕení containeru pro zobrazení výběru
    mCbCcPerson.Parent:= mForm;
    //mCbCcPerson.BevelOuter:= bvLowered;
    mCbCcPerson.Left:= 228;
    mCbCcPerson.Top:= 35;
    mCbCcPerson.Width:= 255;

    mCbPerson:= TRollComboEdit.Create(mForm);
    mCbPerson.Parent:= mForm;

    mCbPerson.ClassID:= 'O3ZO2K155FDL3CL100C4RHECN0';
    mCbPerson.Complete:= True;
    mCbPerson.ForcedField:= True;
    mCbPerson.Prefilling:= pmNone;
    mCbPerson.TextField:= 'Code';  // položka podle které se bude vyhledávat
    mCbPerson.Top:= 35;
    mCbPerson.DataText:= '2D00000101';
    mCbPerson.Left:= 107;
    mCbPerson.Width:= 108;
    mCbPerson.ConnectedControl:= mCbCcPerson;
    mCbPerson.ConnectedControlField:= 'Name';  //položka která bude zobrazena v containeru

    mLabel3 := TLabel.Create(mForm);
    mLabel3.Parent := mForm;
    mLabel3.Caption := 'Skl. karta:';
    mLabel3.Top := 57;
    mLabel3.Left := 17;
    mLabel3.Height := 13;

    mCbCcStoreCard:= TLabel.Create(mForm);  //Vytvoŕení containeru pro zobrazení výběru
    mCbCcStoreCard.Parent:= mForm;
    //mCbCcStoreCard.BevelOuter:= bvLowered;
    mCbCcStoreCard.Left:= 228;
    mCbCcStoreCard.Top:= 55;
    mCbCcStoreCard.Width:= 255;

    mCbStoreCard:= TRollComboEdit.Create(mForm);
    mCbStoreCard.Parent:= mForm;

    mCbStoreCard.ClassID:= 'S3WZQKDB5FDL342M01C0CX3FCC';
    mCbStoreCard.Complete:= True;
    mCbStoreCard.ForcedField:= True;
    mCbStoreCard.Prefilling:= pmNone;
    mCbStoreCard.TextField:= 'Code';  // položka podle které se bude vyhledávat
    mCbStoreCard.Top:= 55;
    mCbStoreCard.DataText:= aStoreCard_ID;
    mCbStoreCard.Left:= 107;
    mCbStoreCard.Width:= 108;
    mCbStoreCard.ConnectedControl:= mCbCcStoreCard;
    mCbStoreCard.ConnectedControlField:= 'Name';  //položka která bude zobrazena v containeru


    mLabel3 := TLabel.Create(mForm);
    mLabel3.Parent := mForm;
    mLabel3.Caption := 'EAN:';
    mLabel3.Top := 79;
    mLabel3.Left := 17;
    mLabel3.Height := 13;


    mEd8 := TEdit.Create(mForm);
    mEd8.Left := 107;
    mEd8.Top := 79;
    mEd8.Width := 380;
    mEd8.Text := '';
    mEd8.Parent := mForm;

    mLabel3 := TLabel.Create(mForm);
    mLabel3.Parent := mForm;
    mLabel3.Caption := 'Množství:';
    mLabel3.Top := 99;
    mLabel3.Left := 17;
    mLabel3.Height := 13;

    mNumEdit:= TNumEdit.Create(mForm);
    mNumEdit.Parent :=mForm;
    mNumEdit.left := 107;
    mNumEdit.top := 99;
    mNumEdit.Value := aQuantity;

    mLabel3 := TLabel.Create(mForm);
    mLabel3.Parent := mForm;
    mLabel3.Caption := 'Cena KK:';
    mLabel3.Top := 119;
    mLabel3.Left := 17;
    mLabel3.Height := 13;

    mNumEdit1:= TNumEdit.Create(mForm);
    mNumEdit1.Parent :=mForm;
    mNumEdit1.left := 107;
    mNumEdit1.top := 119;
    mNumEdit1.Value := aCenaKK;

    mButOk:= TButton.Create(mForm);
    mButOk.Parent := mForm;
    mButOk.Caption := 'Ok';
    mButOk.Top := 139;
    mButOk.Left := 252;
    mButOk.Height := 24;
    mButOk.Width := 62;
    mButOk.ModalResult := 1;

    mButCancel := TButton.Create(mForm);
    mButCancel.Parent := mForm;
    mButCancel.Caption := 'Cancel';
    mButCancel.Top := 139;
    mButCancel.Left := 320;
    mButCancel.Height := 24;
    mButCancel.Width := 62;
    mButCancel.ModalResult := 2;


    mResult := mForm.ShowModal(asite);
   // if mButCancel.OnC
    if mResult = 1 then begin
        aBusProject_id:= mCbFirm.DataText;
        aStore_id:= mCbPerson.DataText;
        if not(NxIsEmptyOID(mCbStoreCard.DataText)) then aStoreCard_ID:= mCbStoreCard.DataText;
        aEAN:=mEd8.Text;
        aQuantity:= mNumEdit.Value;
        aCenaKK:=mNumEdit1.Value;
        adialog:=true;
        end;
    if mResult=2 then aDialog:=False;

    //ShowMessage(mCb.DataText);
    //Result := mCb.DataText;
    mForm.free;

end;


begin
end.
