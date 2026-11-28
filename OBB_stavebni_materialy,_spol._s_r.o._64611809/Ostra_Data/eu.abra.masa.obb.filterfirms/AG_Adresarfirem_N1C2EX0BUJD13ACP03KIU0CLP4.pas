procedure InitSite_Hook(Self: TSiteForm);
var
  mAction: TMultiAction;
begin
    mAction := Self.GetNewMultiAction;
    mAction.ShowControl := True;
    mAction.ShowMenuItem := True;
    mAction.Caption := 'Zobrazit firmy';
    mAction.Items.Add('Zobrazit firmy');
    //mAction.Items.Add('Revize');
    mAction.Hint := 'Zobrazit firmy';
    mAction.Category := 'tabList';
    mAction.OnExecuteItem := @ShowFirms;
end;

Procedure ShowFirms(Sender:TComponent);
var
 mSite:TSiteForm;
 mDate:Extended;
 mSQL:string;
begin
 mSite:=TComponent(Sender).BusRollSite;
 mDate:=NxIncYear(Date,-1);
 if GetDate(msite, mDate) then begin
   if mDate>0 then begin
    mSQL:='not exists (select 1 '+
          'from generalledger g '+
          'join Firms f on f.ID = g.Firm_Id '+
          'where (accdate$date> '+NxFloatToIBStr(mdate)+') and (Coalesce(f.Firm_ID,F.ID) = a.id)) and '+
          'not exists (select 1 '+
          'from issuedinvoices ii '+
          'join Firms f on f.ID = ii.Firm_Id '+
          'where not(ii.paidamount=ii.amount) and (Coalesce(f.Firm_ID,F.ID) = a.id)) '+
          'and '+
          'not exists (select 1 '+
          'from IssuedCreditNotes icn '+
          'join Firms f on f.ID = icn.Firm_Id '+
          'where not(icn.paidamount=icn.amount) and (Coalesce(f.Firm_ID,F.ID) = a.id)) '+
          'and '+
          'not exists (select 1 '+
          'from IssuedDInvoices idi '+
          'join Firms f on f.ID = idi.Firm_Id '+
          'where not(idi.usedamount=idi.amount) and (Coalesce(f.Firm_ID,F.ID) = a.id)) '+
          'and '+
          'not exists (select 1 '+
          'from VATIssuedDInvoices idi '+
          'join Firms f on f.ID = idi.Firm_Id '+
          'where not(idi.usedamount=idi.amount) and (Coalesce(f.Firm_ID,F.ID) = a.id)) '+
          'and '+
          'not exists (select 1 '+
          'from receivedinvoices ri '+
          'join Firms f on f.ID = ri.Firm_Id '+
          'where not(ri.paidamount=ri.amount) and (Coalesce(f.Firm_ID,F.ID) = a.id)) '+
          'and '+
          'not exists (select 1 '+
          'from ReceivedCreditNotes rcn '+
          'join Firms f on f.ID = rcn.Firm_Id '+
          'where not(rcn.paidamount=rcn.amount) and (Coalesce(f.Firm_ID,F.ID) = a.id)) '+
          'and '+
          'not exists (select 1 '+
          'from ReceivedDInvoices rdi '+
          'join Firms f on f.ID = rdi.Firm_Id '+
          'where not(rdi.usedamount=rdi.amount) and (Coalesce(f.Firm_ID,F.ID) = a.id)) '+
          'and '+
          'not exists (select 1 '+
          'from VATReceivedDInvoices rdi '+
          'join Firms f on f.ID = rdi.Firm_Id '+
          'where not(rdi.usedamount=rdi.amount) and (Coalesce(f.Firm_ID,F.ID) = a.id))';
        //NxShowSimpleMessage(mSQL,mSite);
        mSite.ShowSite(Site_Firms, True, 'FilterByUserDynSQLCondition;'+mSQL);
   end;
 end;
end;

Function GetDate(aSite:TSiteForm; adate:Extended):Boolean;
var
    mCbCCFirmA, mCbCCFirmB, mLabel: TLabel;
    mCbFirmA, mCbFirmB:TRollComboEdit;
    mDate:TDateEdit;
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
    mForm.Caption := 'Neaktivní firmy:';
    mForm.OnCloseQuery:= @OnFormCloseAction;

    mLabel := TLabel.Create(mForm);
    mLabel.Parent := mForm;
    mLabel.Caption := 'Datum:';
    mLabel.Top := (mCount*25)+12;
    mLabel.Left := 17;
    mLabel.Height := 13;
    mLabel.Width := 100;
    mLabel.Font.Size := 10;

    mDate :=TDateEdit.Create(mForm);
    mDate.Parent:=mForm;
    mDate.Width:=80;
    mdate.Left:=100;
    mDate.Top:=(mCount*25)+12;
    mDate.Date:=adate;

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
         aDate:=mDate.Date;
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