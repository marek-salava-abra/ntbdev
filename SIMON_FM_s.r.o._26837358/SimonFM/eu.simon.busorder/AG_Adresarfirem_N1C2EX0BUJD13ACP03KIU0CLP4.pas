


procedure InitSite_Hook(Self: TSiteForm);
var
  mAction: TBasicAction;
  mUser : TNxCustomBusinessObject;
begin

    if not Assigned(Self.BaseObjectSpace) then
    exit;
    mUser := Self.BaseObjectSpace.CreateObject('22AHIVDVAVE13C5S00CA141B44');
    mUser.Load(Self.CompanyCache.GetUserID, nil);
    if (mUser.GetFieldCode('U_ChangeBT')>0) and mUser.GetFieldValueAsBoolean('U_ChangeBT') then begin
    mAction := Self.GetNewAction;
    mAction.ShowControl := True;
    mAction.ShowMenuItem := True;
    mAction.Caption := 'Změna OP';
    mAction.Hint := 'Změní obchodní případ';
    mAction.Category := 'tabList, tabDetail';
    mAction.OnExecute := @ChangeOP;
    end;
    mUser := Self.BaseObjectSpace.CreateObject('22AHIVDVAVE13C5S00CA141B44');
    mUser.Load(Self.CompanyCache.GetUserID, nil);
    if (mUser.GetFieldCode('U_ChangeBL')>0) and mUser.GetFieldValueAsBoolean('U_ChangeBL') then begin
    mAction := Self.GetNewAction;
    mAction.ShowControl := True;
    mAction.ShowMenuItem := True;
    mAction.Caption := 'Změna čer. listiny';
    mAction.Hint := 'Změní stav na černé listině';
    mAction.Category := 'tabList, tabDetail';
    mAction.OnExecute := @ChangeBL;
    end;
    mUser := Self.BaseObjectSpace.CreateObject('22AHIVDVAVE13C5S00CA141B44');
    mUser.Load(Self.CompanyCache.GetUserID, nil);
    if (mUser.GetFieldCode('U_ChangeVIP')>0) and mUser.GetFieldValueAsBoolean('U_ChangeVIP') then begin
    mAction := Self.GetNewAction;
    mAction.ShowControl := True;
    mAction.ShowMenuItem := True;
    mAction.Caption := 'Změna pevné VIP';
    mAction.Hint := 'Změní na VIP';
    mAction.Category := 'tabList, tabDetail';
    mAction.OnExecute := @ChangeVIP;
    end;
    mAction := Self.GetNewAction;
    mAction.ShowControl := True;
    mAction.ShowMenuItem := True;
    mAction.Caption := 'CODE';
    mAction.Hint := 'CODE';
    mAction.Category := 'tabList';
    mAction.OnExecute := @CODE;
  end;

procedure CODE(Sender: TObject);
var
mSite: TSiteForm;
mBO:TNxCustomBusinessObject;
i:integer;
mList:TStringList;
begin
  mSite:=TComponent(Sender).BusRollSite;
  mList:=tstringlist.create;
  TBusRollSiteForm(mSite).List.GetSelectedId(mlist);
  for i:=0 to mlist.count-1 do begin
    mBO:=mSite.BaseObjectSpace.CreateObject(Class_Firm);
    mbo.load(mlist.strings[i],nil);
    mbo.SetFieldValueAsString('Code',IntToStr(i+53366));
    mbo.save;
    mbo.free
  end;
end;


procedure ChangeOP(Sender: TObject);
var
mSite: TSiteForm;
mBO:TNxCustomBusinessObject;
mBusTransaction_ID:String;
begin
 msite:=TComponent(Sender).BusRollSite;
 if Assigned(mSite) then begin
   try
    mBO:=TBusRollSiteForm(msite).CurrentObject;
     mBusTransaction_ID:=mbo.GetFieldValueAsString('U_bustransaction_id');
     if ChangeOPDialog(mSite,mBusTransaction_ID) then begin
     mbo.SetFieldValueAsString('U_bustransaction_id',mBusTransaction_ID);
     mBO.Save;
     end;

   finally
     mbo.free;
     TBusRollSiteForm(mSite).RefreshData;
   end;
   //msite.free;
 end;
end;

procedure ChangeBL(Sender: TObject);
var
mSite: TSiteForm;
mBO:TNxCustomBusinessObject;

begin
  msite:=TComponent(Sender).BusRollSite;
  if Assigned(mSite) then begin
     Try
       mBO:=TBusRollSiteForm(mSite).CurrentObject;
       mbo.SetFieldValueAsBoolean('U_blacklist',not(mBO.GetFieldValueAsBoolean('U_blacklist')));
       mbo.Save;
       if mBO.GetFieldValueAsBoolean('U_blacklist') then NxShowSimpleMessage('Hodnota "Černá listina" byla nastavena na: ANO',msite);
       if not(mBO.GetFieldValueAsBoolean('U_blacklist')) then NxShowSimpleMessage('Hodnota "Černá listina" byla nastavena na: NE',msite);
     finally
       mbo.Free;
       TBusRollSiteForm(mSite).RefreshData
     end;
  end;
end;

procedure ChangeVIP(Sender: TObject);
var
mSite: TSiteForm;
mBO:TNxCustomBusinessObject;

begin
  msite:=TComponent(Sender).BusRollSite;
  if Assigned(mSite) then begin
     Try
       mBO:=TBusRollSiteForm(mSite).CurrentObject;
       mbo.SetFieldValueAsBoolean('U_pevna_VIP',not(mBO.GetFieldValueAsBoolean('U_pevna_VIP')));
       mbo.Save;
       if mBO.GetFieldValueAsBoolean('U_pevna_VIP') then NxShowSimpleMessage('Hodnota "Pevná VIP" byla nastavena na: ANO',msite);
       if not(mBO.GetFieldValueAsBoolean('U_pevna_VIP')) then NxShowSimpleMessage('Hodnota "Pevná VIP" byla nastavena na: NE',msite);
     finally
       mbo.Free;
       TBusRollSiteForm(mSite).RefreshData
     end;
  end;
end;

Function ChangeOPDialog(var asite:tsiteform; var aBusTransaction_ID:string):boolean;

var
  mForm: TForm;

    mCbBT: TRollComboEdit;
    mCbCcBT: TLabel;
  mLab, mlabel3: TLabel;
  mResult: integer;
  mButOk,mButCancel: TButton;
begin
  mForm := TForm.Create(asite);
  try
    mForm.Caption := 'Změňte OP';
    mForm.FormStyle := fsStayOnTop;
    mForm.BorderStyle := bsDialog;
    mForm.Width := 550;
    mForm.Height := 170;
    mForm.Scaled := False;
    mform.Position := poScreenCenter;

    mLabel3 := TLabel.Create(mForm);
    mLabel3.Parent := mForm;
    mLabel3.Caption := 'Obch.případ:';
    mLabel3.Top := 17;
    mLabel3.Left := 17;
    mLabel3.Height := 13;

    mCbCcBT:= TLabel.Create(mForm);  //Vytvoŕení containeru pro zobrazení výběru
    mCbCcBT.Parent:= mForm;
    //mCbCcFirm.BevelOuter:= bvLowered;
    mCbCcBT.Left:= 228;
    mCbCcBT.Top:= 17;
    mCbCcBT.Width:= 255;
    if Nxisblank(mCbCcBT.Caption) then mCbCcBT.caption:='Aaaaa';

    mCbBT:= TRollComboEdit.Create(mForm);
    mCbBT.Parent:= mForm;

    mCbBT.ClassID:= '0BOXHKRF4VD13ACL03KIU0CLP4';
    mCbBT.Complete:= True;
    mCbBT.ForcedField:= True;
    mCbBT.Prefilling:= pmNone;
    mCbBT.DataText:=aBusTransaction_ID;
    mCbBT.TextField:= 'Code';  // položka podle které se bude vyhledávat
    mCbBT.Top:= 17;
    mCbBT.Left:= 110;
    mCbBT.Width:= 108;
    mCbBT.ConnectedControl:= mCbCcBT;
    mCbBT.ConnectedControlField:= 'Name';  //položka která bude zobrazena v containeru



    mButOk:= TButton.Create(mForm);
    mButOk.Parent := mForm;
    mButOk.Caption := 'Ok';
    mButOk.Top := 89;
    mButOk.Left := 152;
    mButOk.Height := 24;
    mButOk.Width := 62;
    mButOk.ModalResult := 1;

    mButCancel := TButton.Create(mForm);
    mButCancel.Parent := mForm;
    mButCancel.Caption := 'Cancel';
    mButCancel.Top := 89;
    mButCancel.Left := 220;
    mButCancel.Height := 24;
    mButCancel.Width := 62;
    mButCancel.ModalResult := 2;

    mResult := mForm.Showmodal(asite);
    if mResult = 1 then  begin
      //ShowMessage('Řádně jste zadal:' + Chr(13) + Chr(10) + mEd1.Text + Chr(13) + Chr(10) + mEd2.Text);


      aBusTransaction_ID:= mCbBT.DataText;
      Result:=True
    end else begin
    NxShowSimpleMessage('Ruším',asite);
    Result:=False;

    end;
  finally
    mForm.Free;
  end;
end;

begin
end.