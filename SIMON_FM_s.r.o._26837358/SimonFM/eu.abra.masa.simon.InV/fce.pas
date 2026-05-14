procedure OnUpdate(Sender: TObject);
var
  mSite: TDynSiteForm;
begin
  mSite := TDynSiteForm(TComponent(Sender).Site);
  TBasicAction(Sender).Enabled := mSite.Edit;
end;


Function GetData(var ASite : TSiteform; var aStore_ID, aDivision_ID:String):Boolean;
var
    mLabel, mCbCCDivision, mCbCCStore: TLabel;
    mAllowed:TStringList;
    mButOk, mButCancel : TButton;
    mResult, mCount : integer;
    mForm : TForm;
    mCBDivision,mCBStore:TRollComboEdit;
 begin
 if ASite <> nil then begin
    mAllowed:=TStringList.Create;
    //ASite.BaseObjectSpace.SQLSelect('Select id from defrolldata where clsid='+QuotedStr(Class_BO_EmailTemplates)+' and X_TemplateType='+IntToStr(aType),mAllowed);
    Result:=False;
    mCount:=0;
    mForm:= TForm.Create(ASite);
    mForm.Width:= 510;
    mForm.Position:=poScreenCenter;
    mForm.Caption := 'Zadejte data';
    mForm.OnCloseQuery:= @OnFormCloseAction;

    mLabel := TLabel.Create(mForm);
    mLabel.Parent := mForm;
    mLabel.Caption := 'Sklad:';
    mLabel.Top := (mCount*25)+12;
    mLabel.Left := 17;
    mLabel.Height := 13;
    mLabel.Width := 100;
    mLabel.Font.Size := 10;

    mCbCCStore:= TLabel.Create(mForm);
    mCbCCStore.Parent:= mForm;
    mCbCCStore.Left:= 236;
    mCbCCStore.Top:= (mCount*25)+12;
    mCbCCStore.Width:= 255;

    mCBStore:= TRollComboEdit.Create(mForm);
    mCBStore.Parent:= mForm;
    mCBStore.ClassID:= Roll_Stores;
    mCBStore.Complete:= True;
    mCBStore.Prefilling:= pmNone;
    mCBStore.TextField:= 'Code';  // položka podle které se bude vyhledávat
    mCBStore.Top:= (mCount*25)+10;
    mCBStore.Left:= 140;
    mCBStore.Width:= 80;
    //mCBStore.Parameters.Clear;
    //mCBStore.Parameters.Add('_Allowed='+mAllowed.DelimitedText);
    mCBStore.ConnectedControl:= mCbCCStore;
    mCBStore.ConnectedControlField:= 'Code';



    mCount:= mCount+1;

    mLabel := TLabel.Create(mForm);
    mLabel.Parent := mForm;
    mLabel.Caption := 'Středisko:';
    mLabel.Top := (mCount*25)+12;
    mLabel.Left := 17;
    mLabel.Height := 13;
    mLabel.Width := 100;
    mLabel.Font.Size := 10;

    mCbCCDivision:= TLabel.Create(mForm);
    mCbCCDivision.Parent:= mForm;
    mCbCCDivision.Left:= 236;
    mCbCCDivision.Top:= (mCount*25)+12;
    mCbCCDivision.Width:= 255;

    mCBDivision:= TRollComboEdit.Create(mForm);
    mCBDivision.Parent:= mForm;
    mCBDivision.ClassID:= Roll_Divisions;
    mCBDivision.Complete:= True;
    mCBDivision.Prefilling:= pmNone;
    mCBDivision.TextField:= 'Code';  // položka podle které se bude vyhledávat
    mCBDivision.Top:= (mCount*25)+10;
    mCBDivision.Left:= 140;
    mCBDivision.Width:= 80;
    //mCBDivision.Parameters.Clear;
    //mCBDivision.Parameters.Add('_Allowed='+mAllowed.DelimitedText);
    mCBDivision.ConnectedControl:= mCbCCDivision;
    mCBDivision.ConnectedControlField:= 'Code';



    mCount:= mCount+1;

    mButOk:= TButton.Create(mForm);
    mButOk.Parent := mForm;
    mButOk.Default:= true;
    mButOk.Caption := 'OK';
    mButOk.Top := (mCount*25)+20;
    mButOk.Left := 252;
    mButOk.Height := 24;
    mButOk.Width := 62;
    mButOk.ModalResult := 1;

    mButCancel := TButton.Create(mForm);
    mButCancel.Parent := mForm;
    mButCancel.Caption := 'Zrušit';
    mButCancel.Top := (mCount*25)+20;
    mButCancel.Left := 320;
    mButCancel.Height := 24;
    mButCancel.Width := 62;
    mButCancel.ModalResult := 2;
    mForm.Height:= (mCount*25)+95;

    mResult := mForm.ShowModal(ASite);
    if mResult = 1 then begin
         aDivision_ID:=mCBDivision.DataText;
         aStore_ID:=mCBStore.DataText;
         Result:=True;
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