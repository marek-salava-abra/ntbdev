

Function LowLimitQuantityData(asite:tsiteform;var aStore_id:string;var aDayBefore, aDayAfter:Extended; var aDialog:Boolean):boolean;

 var mForm : TForm;
    mCbStoreCard, mCbFirmRepair, mCbFirm, mCbPerson, mCbUser: TRollComboEdit;
    mCbCcStoreCard, mCbCcFirmRepair, mCbCcFirm, mCbCcPerson, mCbCcUser: TLabel;
    mLabel3 : TLabel;
    mEd1, mEd2, mEd3, mEd4,mEd5, mEd8, med9 : TEdit;
    mEd6, mEd7: TMemo;
    mNumEdit, mNumEdit1: TNumEdit;
    mDateEdit: TDateEdit;
    mButOk, mButCancel : TButton;
    mResult : integer;
begin

    mForm:= TForm.Create(asite);  //Form mus=i být vytvářen na Site , kvuli přebráni Contextu
    mForm.Width:= 520;
    mForm.Height:= 210;
    mForm.Caption := 'Zadejte údaje pro výpočet spodního limitu:';
    mForm.Position := poScreenCenter;

    mLabel3 := TLabel.Create(mForm);
    mLabel3.Parent := mForm;
    mLabel3.Caption := 'Dnů dozadu:';
    mLabel3.Top := 17;
    mLabel3.Left := 17;
    mLabel3.Height := 13;

    mNumEdit:= TNumEdit.Create(mForm);
    mNumEdit.Parent :=mForm;
    mNumEdit.left := 107;
    mNumEdit.top := 17;
    mNumEdit.Value := aDayBefore;

    mLabel3 := TLabel.Create(mForm);
    mLabel3.Parent := mForm;
    mLabel3.Caption := 'Dnů dopředu:';
    mLabel3.Top := 38;
    mLabel3.Left := 17;
    mLabel3.Height := 13;

    mNumEdit1:= TNumEdit.Create(mForm);
    mNumEdit1.Parent :=mForm;
    mNumEdit1.left := 107;
    mNumEdit1.top := 38;
    mNumEdit1.Value := aDayAfter;


    mLabel3 := TLabel.Create(mForm);
    mLabel3.Parent := mForm;
    mLabel3.Caption := 'Sklad:';
    mLabel3.Top := 59;
    mLabel3.Left := 17;
    mLabel3.Height := 13;

    mCbCcPerson:= Tlabel.Create(mForm);  //Vytvoŕení containeru pro zobrazení výběru
    mCbCcPerson.Parent:= mForm;
    //mCbCcPerson.BevelOuter:= bvLowered;
    mCbCcPerson.Left:= 228;
    mCbCcPerson.Top:= 59;
    mCbCcPerson.Width:= 255;

    mCbPerson:= TRollComboEdit.Create(mForm);
    mCbPerson.Parent:= mForm;

    mCbPerson.ClassID:= 'O3ZO2K155FDL3CL100C4RHECN0';
    mCbPerson.Complete:= True;
    mCbPerson.ForcedField:= True;
    mCbPerson.Prefilling:= pmNone;
    mCbPerson.TextField:= 'Code';  // položka podle které se bude vyhledávat
    mCbPerson.Top:= 59;
    mCbPerson.Left:= 107;
    mCbPerson.Width:= 108;
    mCbPerson.ConnectedControl:= mCbCcPerson;
    mCbPerson.ConnectedControlField:= 'Name';  //položka která bude zobrazena v containeru










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
        aStore_id:= mCbPerson.DataText;
        aDayBefore:=mNumEdit.Value;
        aDayAfter:=mnumedit1.Value;
        adialog:=true;
        end;
    if mResult=2 then aDialog:=False;

    //ShowMessage(mCb.DataText);
    //Result := mCb.DataText;
    mForm.free;

end;


begin
end.
