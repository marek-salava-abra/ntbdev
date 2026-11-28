procedure InitSite_Hook(Self: TSiteForm);
var
  mAction: TMultiAction;
begin
  if (NxGetActualUserID(self.BaseObjectSpace)='7000000101') or (NxGetActualUserID(self.BaseObjectSpace)='SUPER00000') then begin
  //if NxGetActualUserID(self.BaseObjectSpace)='SUPER00000' then begin
    mAction := Self.GetNewMultiAction;
    mAction.ShowControl := True;
    mAction.ShowMenuItem := True;
    mAction.Caption := 'Záměna dodavatele';
    mAction.Items.Add('Záměna dodavatele');
    //mAction.Items.Add('Revize');
    mAction.Hint := 'Záměna dodavatele';
    mAction.Category := 'tabList';
    mAction.OnExecuteItem := @ChangeSupplier;
  end;
end;

Procedure ChangeSupplier(Sender:TComponent);
var
 mSite:TSiteForm;
 mFirmA_ID, mFirmB_ID:string;
 mList, mSupList:TStringList;
 mSupBO:TNxCustomBusinessObject;
 i,j, aInt:integer;
 mOS:TNxCustomObjectSpace;
 mResult:Boolean;
begin
 mSite:=TComponent(Sender).BusRollSite;
 mOS:=TBusRollSiteForm(mSite).BaseObjectSpace;
 mList:=TStringList.create;
 TBusRollSiteForm(mSite).List.GetSelectedId(mList);
 if mList.count>0 then begin
   mFirmA_ID:='';
   mFirmB_ID:='';
   if GetFirms(mSite,mFirmA_ID,mFirmB_ID) then begin
     if NxIsEmptyOID(mFirmB_ID) then begin
       NxShowSimpleMessage('Cílová firma musí být vyplněna. Ukončuji.', mSite);
       exit;
     end;
     if NxMessageBox('Dotaz','Přejete si zaměnit dodavatele na '+IntToStr(mlist.count)+' kartách?' , mdConfirm, mdbYesNo, 0, 0, False, msite)= mrYes then begin
        WaitWin.StartProgress('Čekejte, prosím ...', '', mList.Count);
        for i:=0 to mlist.Count-1 do begin
          try
           mSupList:=TStringList.create;
           if NxIsEmptyOID(mFirmA_ID) then
            mOS.SQLSelect('Select id from suppliers where storecard_id='+QuotedStr(mList.strings[i]),mSupList)
           else
            mOS.SQLSelect('Select id from suppliers where storecard_id='+QuotedStr(mList.strings[i])+' and Firm_ID IN (SELECT ID FROM Firms WHERE ID='+QuotedStr(mFirmA_ID)+' or Firm_ID='+QuotedStr(mFirmA_ID)+')',mSupList);
           for j:=0 to mSupList.count-1 do begin
            mSupBO:=mOS.CreateObject(Class_Supplier);
            mSupBO.load(mSupList.Strings[j],nil);
            mSupBO.SetFieldValueAsString('Firm_ID',mFirmB_ID);
            mSupBO.save;
            mSupBO.free;
           end;
           mSupList.free;
          except
           WaitWin.Stop;
          end;
          WaitWin.ChangeText(IntToStr(i+1) + ' / ' + IntToStr(mList.Count));
          WaitWin.StepIt;
        end;
       WaitWin.Stop;
     end;
   end;
 end;
end;


Function GetFirms(var aSite:TSiteForm;var aFirmA_ID, aFirmB_ID:string):Boolean;
var
    mCbCCFirmA, mCbCCFirmB, mLabel: TLabel;
    mCbFirmA, mCbFirmB:TRollComboEdit;
    mButOk, mButCancel : TButton;
    mForm : TForm;
    mCount, mResult:integer;
begin
 if ASite <> nil then begin
    Result:=False;
    mCount:=0;
    mForm:= TForm.Create(ASite);
    mForm.Width:= 510;
    mForm.Position:=poScreenCenter;
    mForm.Caption := 'Údaje zámenu dodavatele:';
    mForm.OnCloseQuery:= @OnFormCloseAction;

    mLabel := TLabel.Create(mForm);
    mLabel.Parent := mForm;
    mLabel.Caption := 'Zdr. firma:';
    mLabel.Top := (mCount*25)+12;
    mLabel.Left := 17;
    mLabel.Height := 13;
    mLabel.Width := 100;
    mLabel.Font.Size := 10;

    mCbCCFirmA:= TLabel.Create(mForm);
    mCbCCFirmA.Parent:= mForm;
    mCbCCFirmA.Left:= 236;
    mCbCCFirmA.Top:= (mCount*25)+12;
    mCbCCFirmA.Width:= 255;

    mCbFirmA:= TRollComboEdit.Create(mForm);
    mCbFirmA.Parent:= mForm;
    mCbFirmA.ClassID:= Roll_Firms;
    mCbFirmA.Complete:= True;
    mCbFirmA.Prefilling:= pmNone;
    mCbFirmA.TextField:= 'Name';  // položka podle které se bude vyhledávat TPOperation_ID
    mCbFirmA.Top:= (mCount*25)+10;
    mCbFirmA.Left:= 140;
    mCbFirmA.Width:= 80;
    mCbFirmA.ConnectedControl:= mCbCCFirmA;
    mCbFirmA.ConnectedControlField:= 'Name';

    mCount:= mCount+1;

    mLabel := TLabel.Create(mForm);
    mLabel.Parent := mForm;
    mLabel.Caption := 'Cíl. firma:';
    mLabel.Top := (mCount*25)+12;
    mLabel.Left := 17;
    mLabel.Height := 13;
    mLabel.Width := 100;
    mLabel.Font.Size := 10;

    mCbCCFirmB:= TLabel.Create(mForm);
    mCbCCFirmB.Parent:= mForm;
    mCbCCFirmB.Left:= 236;
    mCbCCFirmB.Top:= (mCount*25)+12;
    mCbCCFirmB.Width:= 255;

    mCbFirmB:= TRollComboEdit.Create(mForm);
    mCbFirmB.Parent:= mForm;
    mCbFirmB.ClassID:= Roll_Firms;
    mCbFirmB.Complete:= True;
    mCbFirmB.Prefilling:= pmNone;
    mCbFirmB.TextField:= 'Name';  // položka podle které se bude vyhledávat TPOperation_ID
    mCbFirmB.Top:= (mCount*25)+10;
    mCbFirmB.Left:= 140;
    mCbFirmB.Width:= 80;
    mCbFirmB.ConnectedControl:= mCbCCFirmB;
    mCbFirmA.ConnectedControlField:= 'Name';

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
         Result:=True;
         aFirmA_ID:=mCbFirmA.DataText;
         aFirmB_ID:=mCbFirmB.DataText;
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