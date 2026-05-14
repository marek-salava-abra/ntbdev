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
    mAction.Caption := 'Oprava údajů VIP';
    mAction.Hint := 'Opraví údaje o firmě pro VIP kartu a nastavi na zkontrolováno';
    mAction.Category := 'tabList';
    mAction.OnExecute := @CheckFirm;

end;


procedure CheckFirm(sender:Tcomponent);
var
 mSite:TSiteForm;
 mBO:TNxCustomBusinessObject;
 mFirmName, mFirmVATNumber, mFirmEmail, mFirmPhone:String;
 mFirm_ID:String;
begin
 mSite:=TComponent(sender).BusRollSite;
 mBO:=TBusRollSiteForm(mSite).CurrentObject;
 mFirmName:=mbo.GetFieldValueAsString('Name');
 mFirmVATNumber:=mbo.GetFieldValueAsString('VatIdentNumber');
 mFirmEmail:= mbo.GetFieldValueAsString('ResidenceAddress_ID.Email');
 mFirmPhone:= mbo.GetFieldValueAsString('ResidenceAddress_ID.PhoneNumber1');
 if CheckDialog(msite, mFirmName, mFirmVATNumber, mFirmEmail, mFirmPhone) then begin
    mbo.SetFieldValueAsString('Name', mFirmName);
    mbo.SetFieldValueAsString('VatIdentNumber', mFirmVATNumber);
    mbo.SetFieldValueAsString('ResidenceAddress_ID.Email', mFirmEmail);
    mbo.SetFieldValueAsString('ResidenceAddress_ID.PhoneNumber1',mFirmPhone);
    mbo.SetFieldValueAsBoolean('U_kontrola_provedena',True);
    mbo.Save;
    mFirm_ID:=mbo.oid;
    TBusRollSiteForm(mSite).RefreshData;
    TBusRollSiteForm(mSite).DataSet.SeekID(mFirm_ID);
    //mbo.Free;
 end;
end;

function CheckDialog(var ASite:TSiteForm; var aName, aVat, aEmail, aPhone:String):boolean;
var
 mForm:TForm;
 mEd1, mEd2, mEd3, mEd4 :TEdit;
 mButOk, mButCancel : TButton;
 mLabel:TLabel;
 mResult:Integer;
begin
    Result:=False;
    mForm:= TForm.Create(ASite);  //Form mus=i být vytvářen na Site , kvuli přebráni Contextu
    mForm.Width:= 440;
    mForm.Height:= 185;
    mForm.Position:=poScreenCenter;
    mForm.Caption := 'Údaje pro VIP kartu';

    mLabel := TLabel.Create(mForm);
    mLabel.Parent := mForm;
    mLabel.Caption := 'Název';
    mLabel.Top := 10;
    mLabel.Left := 17;
    mLabel.Height := 13;
    mLabel.Width := 100;
    mLabel.Font.Size := 10;

    mLabel := TLabel.Create(mForm);
    mLabel.Parent := mForm;
    mLabel.Caption := 'DIČ';
    mLabel.Top := 35;
    mLabel.Left := 17;
    mLabel.Height := 13;
    mLabel.Width := 100;
    mLabel.Font.Size := 10;

    mLabel := TLabel.Create(mForm);
    mLabel.Parent := mForm;
    mLabel.Caption := 'Telefon';
    mLabel.Top := 60;
    mLabel.Left := 17;
    mLabel.Height := 13;
    mLabel.Width := 100;
    mLabel.Font.Size := 10;

    mLabel := TLabel.Create(mForm);
    mLabel.Parent := mForm;
    mLabel.Caption := 'Email';
    mLabel.Top := 85;
    mLabel.Left := 17;
    mLabel.Height := 13;
    mLabel.Width := 100;
    mLabel.Font.Size := 10;



    mED1 := TEdit.Create(mForm);
    mED1.Left := 107;
    mED1.Top := 8;
    mED1.Width := 300;
    mED1.Text := aName;
    mED1.Parent := mForm;

    mED2 := TEdit.Create(mForm);
    mED2.Left := 107;
    mED2.Top := 33;
    mED2.Width := 300;
    mED2.Text := aVat;
    mED2.Parent := mForm;

    mED3 := TEdit.Create(mForm);
    mED3.Left := 107;
    mED3.Top := 58;
    mED3.Width := 300;
    mED3.Text := aPhone;
    mED3.Parent := mForm;

    mED4 := TEdit.Create(mForm);
    mED4.Left := 107;
    mED4.Top := 83;
    mED4.Width := 300;
    mED4.Text := aEmail;
    mED4.Parent := mForm;


    mButOk:= TButton.Create(mForm);
    mButOk.Parent := mForm;
    mButOk.Caption := 'Ok';
    mButOk.Top := 115;
    mButOk.Left := 152;
    mButOk.Height := 24;
    mButOk.Width := 62;
    mButOk.ModalResult := 1;

    mButCancel := TButton.Create(mForm);
    mButCancel.Parent := mForm;
    mButCancel.Caption := 'Zrušit';
    mButCancel.Top := 115;
    mButCancel.Left := 220;
    mButCancel.Height := 24;
    mButCancel.Width := 62;
    mButCancel.ModalResult := 2;


    mResult := mForm.ShowModal(ASite);
    if mResult = 1 then begin
      Result:=True;
      aName:=mEd1.text;
      aVat:=med2.text;
      aEmail:=med4.Text;
      aPhone:=med3.Text;
    end;

end;


begin
end.