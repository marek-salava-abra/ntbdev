procedure InitSite_Hook(Self: TSiteForm);
var
  mAction: TAction;
  i : integer;
  mUser:TNxCustomBusinessObject;
begin
  if not(NxIsEmptyOID(NxGetActualUserID(self.BaseObjectSpace))) then begin
   mUser:=self.BaseObjectSpace.CreateObject(Class_SecurityUser);
   mUser.Load(NxGetActualUserID(self.BaseObjectSpace),nil);
   if mUser.GetFieldValueAsBoolean('U_Rezervace') then begin
      mAction := Self.GetNewAction;
      mAction.ShowControl := True;
      mAction.ShowMenuItem := True;
      mAction.Caption := 'Max Rezervace';
      mAction.Hint := 'Schválit a vyplnit delší rezervaci';
      mAction.Category := 'tabList';
      mAction.OnExecute := @ChangeRes;
   end;
  end;
end;

Procedure ChangeRes(sender:TObject);
var
 mSite:TSiteForm;
 mBO:TNxCustomBusinessObject;
 mDate:Extended;
 mNote:string;
 mResult:integer;
begin
 mSite:=TComponent(sender).DynSite;
 mBO:=TDynSiteForm(mSite).CurrentObject;
 mResult:=0;
 mDate:=0;
 mNote:='';
 if assigned(mBO) then begin
   if NxMessageBox('Dotaz','Přejete si změnit údaje pro rezervace na '+mbo.DisplayName+'?' , mdConfirm, mdbYesNo, 0, 0, False, msite)= mrYes then begin
     if GetData(mSite, mDate, mNote, mResult) then begin
       if mResult=1 then begin
        mBO.SetFieldValueAsDateTime('U_MaxReservationDate',mDate);
        mBO.SetFieldValueAsString('U_ReservationReason2',mNote);
        mBO.Save;
        TDynSiteForm(mSite).ActiveDataSet.RefreshCurrentItem;
        NxshowSimpleMessage('Provedeno',mSite);
       end else begin
        NxshowSimpleMessage('Zrušeno',mSite);
       end;
     end;
   end;
 end;
end;

Function GetData(var aSite:TSiteForm; var aDate:extended;var aString:String; var aResult:integer):boolean;
var
 mEd1: TDateEdit;
 mEd2: TEdit;
 mLabel1: TLabel;
 mButOk, mButCancel : TButton;
 mForm:TForm;

begin
 if ASite <> nil then begin
    mForm:= TForm.Create(ASite);  //Form mus=i být vytvářen na Site , kvuli přebráni Contextu
    mForm.Left:= 300;
    mForm.Top:= 300;
    mForm.Width:= 510;
    mForm.Height:= 160;
    mForm.Position:=poScreenCenter;
    mForm.Caption := 'Zadejte údaje';

    mLabel1 := TLabel.Create(mForm);
    mLabel1.Parent := mForm;
    mLabel1.Caption := 'Max datum :';
    mLabel1.Top := 10;
    mLabel1.Left := 17;
    mLabel1.Height := 13;
    mLabel1.Width := 100;
    mLabel1.Font.Size := 10;

    mEd1 := TDateEdit.Create(mForm);
    mEd1.parent :=mForm;
    mEd1.top := 10;
    mEd1.left := 107;
    med1.Width := 150;

    mLabel1 := TLabel.Create(mForm);
    mLabel1.Parent := mForm;
    mLabel1.Caption := 'Důvod schválení rezervace :';
    mLabel1.Top := 35;
    mLabel1.Left := 17;
    mLabel1.Height := 13;
    mLabel1.Width := 100;
    mLabel1.Font.Size := 10;

    mEd2 := TEdit.Create(mForm);
    mEd2.Left := 107;
    mEd2.Top := 35;
    mEd2.Width := 380;
    //med2.Height:= 60;
    mEd2.Text := '';
    mEd2.Parent := mForm;

    mButOk:= TButton.Create(mForm);
    mButOk.Parent := mForm;
    mButOk.Caption := 'OK';
    mButOk.Top := 80;
    mButOk.Left := 152;
    mButOk.Height := 24;
    mButOk.Width := 62;
    mButOk.ModalResult := 1;

    mButCancel := TButton.Create(mForm);
    mButCancel.Parent := mForm;
    mButCancel.Caption := 'Zrušit';
    mButCancel.Top := 80;
    mButCancel.Left := 220;
    mButCancel.Height := 24;
    mButCancel.Width := 62;
    mButCancel.ModalResult := 2;


    aResult := mForm.ShowModal(ASite);
    //aresult:=mresult;
   // if mButCancel.OnC
    if aResult = 1 then
        aDate:=mEd1.Date;
        aString:=mEd2.Text;

        Result:=true;
    //ShowMessage(mCb.DataText);
    //Result := mCb.DataText;
    mForm.free;
  end;

end;

begin
end.