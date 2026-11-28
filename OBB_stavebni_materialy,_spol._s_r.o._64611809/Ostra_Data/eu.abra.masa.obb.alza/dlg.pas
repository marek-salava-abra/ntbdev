

function GetDataForCashReceived(var aSite:TSiteForm;var AFirm_ID:string; var aCount500, aCount1000, aTotal:Extended;var aOS:TNxCustomObjectSpace):Boolean;
var
 mResult, mCount:integer;
 mLabel, mCBCcFirm:TLabel;
 mForm : TForm;
 mNumEd, mNumEd1, mNumEd2:TNumEdit;
 mCbFirm:TRollComboEdit;
 mButOk, mButCancel : TButton;
 mAllowed:TStringList;
begin
 Result:=False;
 if ASite <> nil then begin
    Result:=False;
    mCount:=0;
    mForm:= TForm.Create(ASite);
    mForm.Width:= 510;
    mForm.Position:=poScreenCenter;
    mForm.Caption := 'Údaje pro šekobraní:';
    mForm.OnCloseQuery:= @OnFormCloseAction;

    mAllowed:=TStringList.create;
    aOS.SQLSelect('Select f.id from firms f join addresses e on f.ElectronicAddress_ID=e.id where f.firm_id is null and f.hidden=''N'' and not(e.databox='''') ',mAllowed);

    mLabel := TLabel.Create(mForm);
    mLabel.Parent := mForm;
    mLabel.Caption := 'Firma:';
    mLabel.Top := (mCount*25)+12;
    mLabel.Left := 17;
    mLabel.Height := 13;
    mLabel.Width := 100;
    mLabel.Font.Size := 10;

    mCBCcFirm:= TLabel.Create(mForm);
    mCBCcFirm.Parent:= mForm;
    mCBCcFirm.Left:= 236;
    mCBCcFirm.Top:= (mCount*25)+12;
    mCBCcFirm.Width:= 255;

    mCbFirm:= TRollComboEdit.Create(mForm);
    mCbFirm.Parent:= mForm;
    mCbFirm.ClassID:= Roll_Firms;
    mCbFirm.Complete:= True;
    mCbFirm.Prefilling:= pmNone;
    mCbFirm.TextField:= 'Code';  // položka podle které se bude vyhledávat
    mCbFirm.Top:= (mCount*25)+10;
    mCbFirm.Left:= 140;
    mCbFirm.Width:= 80;
    mCbFirm.ConnectedControl:= mCBCcFirm;
    mCbFirm.Parameters.Clear;
    mCbFirm.Parameters.Add('_Allowed='+mAllowed.DelimitedText);
    mCbFirm.ConnectedControlField:= 'Name';

    mCount:= mCount+1;

    mLabel := TLabel.Create(mForm);
    mLabel.Parent := mForm;
    mLabel.Caption := 'Počet 500:';
    mLabel.Top := (mCount*25)+12;
    mLabel.Left := 17;
    mLabel.Height := 13;
    mLabel.Width := 100;
    mLabel.Font.Size := 10;

    mNumEd := TNumEdit.Create(mForm);
    mNumEd.Left := 140;
    mNumEd.Top := (mCount*25)+10;
    mNumEd.Width := 80;
    mNumEd.Value := aCount500;
    mNumEd.DecimalPlaces := 0;
    mNumEd.Parent := mForm;

    mCount:= mCount+1;

    mLabel := TLabel.Create(mForm);
    mLabel.Parent := mForm;
    mLabel.Caption := 'Počet 1000:';
    mLabel.Top := (mCount*25)+12;
    mLabel.Left := 17;
    mLabel.Height := 13;
    mLabel.Width := 100;
    mLabel.Font.Size := 10;

    mNumEd1 := TNumEdit.Create(mForm);
    mNumEd1.Left := 140;
    mNumEd1.Top := (mCount*25)+10;
    mNumEd1.Width := 80;
    mNumEd1.Value := aCount1000;
    mNumEd1.DecimalPlaces := 0;
    mNumEd1.Parent := mForm;

    mCount:= mCount+1;

    mLabel := TLabel.Create(mForm);
    mLabel.Parent := mForm;
    mLabel.Caption := 'Celkem:';
    mLabel.Top := (mCount*25)+12;
    mLabel.Left := 17;
    mLabel.Height := 13;
    mLabel.Width := 100;
    mLabel.Font.Size := 10;

    mNumEd2 := TNumEdit.Create(mForm);
    mNumEd2.Left := 140;
    mNumEd2.Top := (mCount*25)+10;
    mNumEd2.Width := 80;
    mNumEd2.Value := aTotal;
    mNumEd2.DecimalPlaces := 0;
    mNumEd2.Parent := mForm;

    mCount:= mCount+1;

    mButOk:= TButton.Create(mForm);
    mButOk.Parent := mForm;
    mButOk.Caption := 'OK';
    mButOk.Default := True;
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
       Result:=true;
       aCount500:=mNumEd.value;
       aCount1000:=mNumEd1.value;
       aTotal:=mNumEd2.value;
       AFirm_ID:=mCbFirm.DataText;
    end;
    mForm.free;
 end;
end;


{GetMonth}

function GetMonth(AReportHelper:TNxQRScriptHelper;DocDate:Extended):Integer;
begin
  Result:=MonthOf(DocDate);
end;

procedure OnFormCloseAction(Sender: TObject; var Action: TCloseAction);
begin
  if Action = caHide then TForm(Sender).ModalResult := mrCancel;
end;


begin
end.