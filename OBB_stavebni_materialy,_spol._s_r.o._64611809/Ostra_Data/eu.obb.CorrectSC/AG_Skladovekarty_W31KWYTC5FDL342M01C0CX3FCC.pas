procedure InitSite_Hook(Self: TSiteForm);
var
  mAction: TMultiAction;
  muser:TNxCustomBusinessObject;
begin
  {if not(NxIsEmptyOID(NxGetActualUserID(self.BaseObjectSpace))) then begin
  mUser:=self.BaseObjectSpace.CreateObject(Class_SecurityUser);
  mUser.Load(NxGetActualUserID(self.BaseObjectSpace),nil);
  if (muser.GetFieldValueAsBoolean('U_skladova_karta')) then begin}
  if NxGetActualUserID(self.BaseObjectSpace)='7000000101' then begin
  mAction := Self.GetNewMultiAction;
  mAction.ShowControl := True;
  mAction.ShowMenuItem := True;
  mAction.Caption := 'Oprava položek';
  mAction.Items.Add('Procento cena 1');
  mAction.Items.Add('Procento cena 2');
  mAction.Items.Add('Max % šeky');
  mAction.Items.Add('Oprava názvu náhradou části');
  //mAction.Items.Add('Revize');
  mAction.Hint := 'Opraví data na skladové kartě';
  mAction.Category := 'tabList';
  mAction.OnExecuteItem := @CorrectFirm;
  end;
  {end;
  end;}
end;

procedure CorrectFirm(sender:Tcomponent; index:integer);
var
 mSite:TsiteForm;
 mBO:TNxCustomBusinessObject;
 mText:String;
 A, B, C :Extended;
 mList:TStringList;
 i, mResult:integer;
 mValue, mCorrectedValue, mValueB:string;
begin
 msite:=TComponent(Sender).BusRollSite;
 if Assigned(mSite) then begin
  if index=0 then begin
   try
     mBO:=TBusRollSiteForm(msite).CurrentObject;
     mText:=FloatToStr(mbo.GetFieldValueAsFloat('U_procentocena1'));
     mText:=InputBox('Oprava','Procento cena 1',mText);
     //if ChangeOPDialog(mSite,mBusTransaction_ID) then begin
     mbo.SetFieldValueAsFloat('U_procentocena1',NxIBStrToFloat(mText));
     mBO.Save;


   finally
     mbo.free;
     TBusRollSiteForm(mSite).RefreshData;
   end;
   end;
   if index=1 then begin
   try
     mBO:=TBusRollSiteForm(msite).CurrentObject;
     mText:=FloatToStr(mbo.GetFieldValueAsFloat('U_procentocena2'));
     mText:=InputBox('Oprava','Procento cena 2',mText);
     //if ChangeOPDialog(mSite,mBusTransaction_ID) then begin
     mbo.SetFieldValueAsFloat('U_procentocena2',NxIBStrToFloat(mText));
     mBO.Save;


   finally
     mbo.free;
     TBusRollSiteForm(mSite).RefreshData;
   end;
   end;
   if index=2 then begin
   try
     mList:=tstringlist.Create;
     TBusRollSiteForm(mSite).List.GetSelectedId(mList);
     mText:=InputBox('Oprava','Další procento slevy',mText);
     B:=NxIBStrToFloat(mText);
     if b>0 then begin
       for i:=0 to mlist.count-1 do begin
           mBO:=msite.BaseObjectSpace.CreateObject(Class_StoreCard);
           mbo.Load(mlist.strings[i],nil);
           A:=mbo.GetFieldValueAsFloat('U_procentocena1');

           C:=(100-(100*(100-A)/100)*((100-B)/100));
           mbo.SetFieldValueAsFloat('U_slevaSeky',C);
           mBO.Save;
           mBO.free;
       end;
     end;
   finally

     TBusRollSiteForm(mSite).RefreshData;
   end;
   end;

   if index=3 then begin
   try
     mResult:=0;
     mList:=tstringlist.Create;
     TBusRollSiteForm(mSite).List.GetSelectedId(mList);
     GetData(msite, mValue,mValueB, mResult);
     if mResult>0 then begin
       for i:=0 to mlist.count-1 do begin
           mBO:=msite.BaseObjectSpace.CreateObject(Class_StoreCard);
           mbo.Load(mlist.strings[i],nil);
           mCorrectedValue:=NxSearchReplace(mbo.GetFieldValueAsString('Name'),mValue,mValueB,[srAll]);
           mbo.SetFieldValueAsString('Name',mCorrectedValue);
           mBO.Save;
           mBO.free;
       end;
     end;
   finally

     TBusRollSiteForm(mSite).RefreshData;
   end;
   end;

   //msite.free;
 end;
end;

Function GetData(var aSite:TSiteForm; var aString, bString:string; var aResult:Integer):boolean;
var
 mEd1, mEd2:TEdit;
 mLabel1: TLabel;
 mButOk, mButCancel : TButton;
 mForm:TForm;
begin
 if ASite <> nil then begin
    mForm:= TForm.Create(ASite);  //Form mus=i být vytvářen na Site , kvuli přebráni Contextu
    mForm.Left:= 300;
    mForm.Top:= 300;
    mForm.Width:= 410;
    mForm.Height:= 230;
    mForm.Position:=poScreenCenter;
    mForm.Caption := 'Zadejte údaje pro náhradu';

    mLabel1 := TLabel.Create(mForm);
    mLabel1.Parent := mForm;
    mLabel1.Caption := 'Hledaný text:';
    mLabel1.Top := 10;
    mLabel1.Left := 17;
    mLabel1.Height := 13;
    mLabel1.Width := 100;
    mLabel1.Font.Size := 10;

    mEd1 := TEdit.Create(mForm);
    mEd1.parent :=mForm;
    mEd1.top := 10;
    mEd1.left := 125;
    med1.Width := 150;

    mLabel1 := TLabel.Create(mForm);
    mLabel1.Parent := mForm;
    mLabel1.Caption := 'Nahrazovaný text:';
    mLabel1.Top := 35;
    mLabel1.Left := 17;
    mLabel1.Height := 13;
    mLabel1.Width := 100;
    mLabel1.Font.Size := 10;

    mEd2 := TEdit.Create(mForm);
    mEd2.parent :=mForm;
    mEd2.top := 35;
    mEd2.left := 125;
    med2.Width := 150;

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
        aString:=mEd1.Text;
        bString:=mEd2.Text;

        Result:=true;
    //ShowMessage(mCb.DataText);
    //Result := mCb.DataText;
    mForm.free;
  end;

end;

begin
end.