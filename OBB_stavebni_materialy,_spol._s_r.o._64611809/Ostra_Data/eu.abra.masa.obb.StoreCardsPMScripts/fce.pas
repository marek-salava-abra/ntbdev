procedure OnFormCloseAction(Sender: TObject; var Action: TCloseAction);
begin
  if Action = caHide then TForm(Sender).ModalResult := mrCancel;
end;

Function GetDataForCorrectByPM(var ASite:TSiteForm; var aManager_ID, aAnalyticsOV_ID:string; var aBusinessStatus, aOrderStatus:integer):Boolean;
var
 mLabel, mCbCCManager, mCbCCAnalytics:TLabel;
 mButOk, mButCancel : TButton;
 mResult, mCount : integer;
 mForm:TForm;
 mOS:TNxCustomObjectSpace;
 mCBManager, mCBAnalytics:TRollComboEdit;
 mBusStatus, mOrderStatus:TComboBox;
 mBusStatusValues, mOrderStatusValues:TStringList;
begin
 if ASite <> nil then begin
    mOS:=ASite.BaseObjectSpace;
    Result:=False;
    mCount:=0;
    mForm:= TForm.Create(ASite);
    mForm.Width:= 510;
    mForm.Position:=poScreenCenter;
    mForm.Caption := 'Údaje pro opravu:';
    mForm.OnCloseQuery:= @OnFormCloseAction;

    mBusStatusValues:=TStringList.Create;
    mBusStatusValues.Text:=mOS.SQLSelectFirstAsString('Select Enumeration from userfielddefs2 where parent_id=''1300000101'' and fieldcode=2000034','');
    mOrderStatusValues:=TStringList.Create;
    mOrderStatusValues.Text:=mOS.SQLSelectFirstAsString('Select Enumeration from userfielddefs2 where parent_id=''1300000101'' and fieldcode=2000037','');

    mLabel := TLabel.Create(mForm);
    mLabel.Parent := mForm;
    mLabel.Caption := 'Manažer:';
    mLabel.Top := (mCount*25)+12;
    mLabel.Left := 17;
    mLabel.Height := 13;
    mLabel.Width := 100;
    mLabel.Font.Size := 10;

    mCbCCManager:= TLabel.Create(mForm);
    mCbCCManager.Parent:= mForm;
    mCbCCManager.Left:= 236;
    mCbCCManager.Top:= (mCount*25)+12;
    mCbCCManager.Width:= 255;

    mCBManager:= TRollComboEdit.Create(mForm);
    mCBManager.Parent:= mForm;
    mCBManager.ClassID:= Roll_ProductM;
    mCBManager.Complete:= True;
    mCBManager.Prefilling:= pmNone;
    mCBManager.TextField:= 'Code';
    mCBManager.Top:= (mCount*25)+10;
    mCBManager.Left:= 140;
    mCBManager.Width:= 80;
    if not(NxIsEmptyOID(aManager_ID)) then begin
      mCBManager.DataText:=aManager_ID;
      mCBManager.Refresh;
    end;
    mCBManager.ConnectedControl:= mCbCCManager;
    mCBManager.ConnectedControlField:= 'Name';

    mCount:= mCount+1;

    mLabel := TLabel.Create(mForm);
    mLabel.Parent := mForm;
    mLabel.Caption := 'Dostupnost a status:';
    mLabel.Top := (mCount*25)+12;
    mLabel.Left := 17;
    mLabel.Height := 13;
    mLabel.Width := 100;
    mLabel.Font.Size := 10;

    mBusStatus:= TComboBox.Create(mForm);
    mBusStatus.Parent:=mForm;
    mBusStatus.Left := 140;
    mBusStatus.Top := (mCount*25)+10;
    mBusStatus.Width := 200;
    mBusStatus.Text := '';
    mBusStatus.Items:=mBusStatusValues;
    mBusStatus.ItemIndex:=aBusinessStatus;

    mCount:= mCount+1;

    mLabel := TLabel.Create(mForm);
    mLabel.Parent := mForm;
    mLabel.Caption := 'Podmínky pro OV:';
    mLabel.Top := (mCount*25)+12;
    mLabel.Left := 17;
    mLabel.Height := 13;
    mLabel.Width := 100;
    mLabel.Font.Size := 10;

    mOrderStatus:= TComboBox.Create(mForm);
    mOrderStatus.Parent:=mForm;
    mOrderStatus.Left := 140;
    mOrderStatus.Top := (mCount*25)+10;
    mOrderStatus.Width := 200;
    mOrderStatus.Text := '';
    mOrderStatus.Items:=mOrderStatusValues;
    mOrderStatus.ItemIndex:=aOrderStatus;

    mCount:= mCount+1;

    mLabel := TLabel.Create(mForm);
    mLabel.Parent := mForm;
    mLabel.Caption := 'Analýza pro nákup:';
    mLabel.Top := (mCount*25)+12;
    mLabel.Left := 17;
    mLabel.Height := 13;
    mLabel.Width := 100;
    mLabel.Font.Size := 10;

    mCbCCAnalytics:= TLabel.Create(mForm);
    mCbCCAnalytics.Parent:= mForm;
    mCbCCAnalytics.Left:= 236;
    mCbCCAnalytics.Top:= (mCount*25)+12;
    mCbCCAnalytics.Width:= 255;

    mCBAnalytics:= TRollComboEdit.Create(mForm);
    mCBAnalytics.Parent:= mForm;
    mCBAnalytics.ClassID:= Roll_AnalyticsOV;
    mCBAnalytics.Complete:= True;
    mCBAnalytics.Prefilling:= pmNone;
    mCBAnalytics.TextField:= 'Code';
    mCBAnalytics.Top:= (mCount*25)+10;
    mCBAnalytics.Left:= 140;
    mCBAnalytics.Width:= 80;
    if not(NxIsEmptyOID(aAnalyticsOV_ID)) then begin
      mCBAnalytics.DataText:=aAnalyticsOV_ID;
      mCBAnalytics.Refresh;
    end;
    mCBAnalytics.ConnectedControl:= mCbCCAnalytics;
    mCBAnalytics.ConnectedControlField:= 'Name';

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
         aManager_ID:=mCBManager.DataText;
         aAnalyticsOV_ID:=mCBAnalytics.DataText;
         aOrderStatus:=mOrderStatus.ItemIndex;
         aBusinessStatus:=mBusStatus.ItemIndex;
     end;
    mForm.free;

  end;
end;

function GetHorizontalSplitter(aLength: Integer): string;
var
  i: Integer;
begin
  Result := '';
  for i := 1 to aLength do
    Result := Result + '─';
end;

function GetDynSource (AOS : TNxCustomObjectSpace; AValue : string) : String;

const
  cSQL = 'SELECT DataSource FROM Reports WHERE ID=''%s'' ';
var
  mList : TStringList;
begin
  mList := TStringList.Create;
  try
    Result:='';
    AOS.SQLSelect(Format(cSQL, [ AValue]), mList);
    if mList.Count > 0 then
      Result := (mList.Strings[0]);
  finally
    mList.Free;
  end;
end;

function GetWorkingDaysAgo(var mDate: TDateTime;var AWorkDaysBack: Integer; var AOS:TNxCustomObjectSpace): TDateTime;
var
  mCount: Integer;
  mDayOfWeek: Integer;
  mIsHoliday: Boolean;
begin
  mCount := 0;

  while mCount < AWorkDaysBack do
  begin
    mDate := mDate - 1;
    mDayOfWeek := DayOfWeek(mDate);
    if (mDayOfWeek <> 1) and (mDayOfWeek <> 7) then
    begin
      mIsHoliday := NxEvalParametersExprAsBooleanDef(AOS, nil, 'NxDayIsHoliday(' + NxFloatToIBStr(mDate) + '.0)', false);
      if not mIsHoliday then
      begin
        Inc(mCount);
      end;
    end;
  end;
  Result := mDate;
end;


procedure SendInternalMail(AOS:TNxCustomObjectSpace; ATo:String; ACC:String; ABCC:String; ASubject:String; ABody:String; AAtachement:String; AFirm_ID:String; ADivision_ID:String; ABusTransaction_ID:String);
Var
  mMailBO:TNxCustomBusinessObject;
  mMRecipients:TNxCustomBusinessMonikerCollection;
  mMailRecipient:TNxCustomBusinessObject;
begin
  if not(ato='') then begin
     mMailBO:=AOS.CreateObject(Class_EmailSent);
     mMailBO.New;
     mMailBO.Prefill;
     mMailBO.SetFieldValueAsString('EmailAccount_ID','3000000101');
     mMailBO.SetFieldValueAsString('Subject',ASubject);
     mMailbo.SetFieldValueAsInteger('SentState',1);
     mMailBO.SetFieldValueAsString('Body',ABody);
     mMailBO.SetFieldValueAsString('Firm_ID',AFirm_ID);
     mMailBO.SetFieldValueAsString('Division_ID',ADivision_ID);
     mMailBO.SetFieldValueAsString('BusTransaction_ID',ABusTransaction_ID);
     mMailBO.SetFieldValueAsBoolean('X_dont_delete',False);
     mMRecipients:=mMailBO.GetCollectionMonikerForFieldCode(mMailBO.GetFieldCode('Recipients'));

     mMailRecipient:=mMRecipients.AddNewObject;
     mMailRecipient.SetFieldValueAsString('Email',ATo);
     mMailRecipient.SetFieldValueAsInteger('EmailType',0);
     if not(acc='') then begin
     mMailRecipient:=mMRecipients.AddNewObject;
     mMailRecipient.SetFieldValueAsString('Email',ACC);
     mMailRecipient.SetFieldValueAsInteger('EmailType',1);
     end;
     if not(ABCC='') then begin
     mMailRecipient:=mMRecipients.AddNewObject;
     mMailRecipient.SetFieldValueAsString('Email',ABCC);
     mMailRecipient.SetFieldValueAsInteger('EmailType',2);
     end;
     if not(AAtachement='') then begin
      if FileExists(AAtachement) then TNxEmailSent(mMailBO).AttachFile(AAtachement);

     end;




     mMailBO.Save;
     mMailBO.free;

  end;
end;


begin
end.