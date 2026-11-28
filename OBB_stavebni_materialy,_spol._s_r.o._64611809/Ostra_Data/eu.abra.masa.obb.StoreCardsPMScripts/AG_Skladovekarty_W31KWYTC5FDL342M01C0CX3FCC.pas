uses '.fce';

procedure InitSite_Hook(Self: TSiteForm);
var
  mBut, mBut2, mBut3, mAction: TBasicAction;
  mMAction:TMultiAction;
  mUser:TNxCustomBusinessObject;
  mAList:TActionList;
  i:integer;
begin
  mAList := Self.GetMainActionList;
    for i := 0 to mAList.ActionCount-1 do begin
      mAction := mAList.Actions[i];
      if mAction.Name='actClone' then tAction(mAction).Visible:=false;
      if mAction.Name='actNew' then TMultiAction(mAction).Visible:=false;
    end;
  if not Assigned(Self.BaseObjectSpace) then
    exit;
  mUser:=Self.BaseObjectSpace.CreateObject(Class_SecurityUser);
  mUser.load(NxGetActualUserID(self.BaseObjectSpace),nil);
  if mUser.GetFieldValueAsBoolean('U_EditPM') then begin
    mBut:= Self.GetNewAction;
    mBut.Name:='actCorrectByPM';
    mBut.ShowControl := True;
    mBut.ShowMenuItem := True;
    mBut.Caption := 'Oprava Manažerem';
    mBut.Category := 'tabList';
    mBut.OnExecute := @CorrectByPM;
  end;
    mBut2:= Self.GetNewAction;
    mBut2.Name:='actCloneSC';
    mBut2.ShowControl := True;
    mBut2.ShowMenuItem := True;
    mBut2.Caption := 'Nová karta';
    mBut2.Category := 'tabList';
    mBut2.OnExecute := @CloneSC;

    mBut3:= Self.GetNewAction;
    mBut3.Name:='actCancelConfirmation';
    mBut3.ShowControl := True;
    mBut3.ShowMenuItem := True;
    mBut3.Caption := 'Zrušit schvalování karty';
    mBut3.Category := 'tabList';
    mBut3.OnExecute := @CancelConfirmation;

end;

procedure _CanSaveNow_Hook(Self: TRollSiteForm; var ACanSaveNow: Boolean);
var
 mBO:TNxCustomBusinessObject;
begin
 mBO:=TBusRollSiteForm(self).CurrentObject;
 if NxIsBlank(mBO.GetFieldValueAsString('U_ProposedExCode')) then begin
  if NxMessageBox('Dotaz','Nevyplnili jste kód dodavatele, pole není povinné ale urychlí schvalování karty. Skutečně uložit kartu bez kódu výrobce?' , mdConfirm, mdbYesNo, 0, 0, False, Self)= mrYes then begin
        ACanSaveNow:=True;
      end else begin
        mBO.AddValidateError(MBO.GetFieldCode('U_ProposedExCode'),'Doplnit navrhovaný kód dodavatele');
        ACanSaveNow:=False;
      end;
    end;
end;


Procedure CancelConfirmation(Sender:TComponent);
var
 mSite:TSiteForm;
 mBO:TNxCustomBusinessObject;
 mPMName:string;
 mGrid:TDBGrid;
 mList:TStringList;
begin
 mSite:=TComponent(Sender).BusRollSite;
 if Assigned(mSite) then begin
   mList:=TStringList.Create;
   TBusRollSiteForm(mSite).List.GetSelectedId(mList);
   if mList.count=1 then begin
     mBO:=TBusRollSiteForm(mSite).CurrentObject;
     if Assigned(mBO) then begin
      if not(NxIsEmptyOID(mbo.GetFieldValueAsString('X_ProductM'))) then
       mPMName:=mbo.GetFieldValueAsString('X_ProductM.U_ProductManName') else mPMName:='';
      if not(mBO.GetFieldValueAsDateTime('AuthorizedAt$DATE')>0) then begin
        mBO.SetFieldValueAsInteger('U_ApprovalStatus',10);
        mBO.save;
        TBusRollSiteForm(msite).RefreshData;
        TBusRollSiteForm(mSite).DataSet.SeekID(mBO.OID);
        NxShowSimpleMessage('Provedeno.',mSite);
      end else begin
        NxShowSimpleMessage('Karta '+mbo.GetFieldValueAsString('Name')+' již byla schválena. Kontaktujte prosím správce karty '+mPMName,mSite);
      end;
     end;
   end else begin
    NxShowSimpleMessage('Tlačítko nelze použít pro více karet najednou. Prosím označte jen jednu kartu.',msite);
   end;
 end;
end;

Procedure CorrectByPM(Sender:TComponent);
var
 mSite:TSiteForm;
 mBO:TNxCustomBusinessObject;
 mBusinessStatus, mOrderStatus:integer;
 mManager_ID, mAnalyticsOV_ID:string;
begin
 mSite:=TComponent(Sender).BusRollSite;
 if Assigned(mSite) then begin
   mBO:=TBusRollSiteForm(mSite).CurrentObject;
   if Assigned(mBO) then begin
      mManager_ID:=mBO.GetFieldValueAsString('X_ProductM');
      mBusinessStatus:=mBO.GetFieldValueAsInteger('U_BusinessStatus');
      mOrderStatus:=mBO.GetFieldValueAsInteger('U_OrderStatus');
      mAnalyticsOV_ID:=mBO.GetFieldValueAsString('X_AnalyticsOV');
      if GetDataForCorrectByPM(mSite, mManager_ID, mAnalyticsOV_ID, mBusinessStatus, mOrderStatus) then begin
         mBO.SetFieldValueAsString('X_ProductM', mManager_ID);
         mBO.SetFieldValueAsString('X_AnalyticsOV', mAnalyticsOV_ID);
         mBO.SetFieldValueAsInteger('U_BusinessStatus',mBusinessStatus);
         mBO.SetFieldValueAsInteger('U_OrderStatus', mOrderStatus);
         mbo.save;
         TBusRollSiteForm(msite).RefreshData;
         TBusRollSiteForm(msite).DataSet.SeekID(mbo.oid);
      end;
   end;
 end;
end;


Procedure CloneSC(Sender:TComponent);
var
 mSite:TSiteForm;
 mBO, mClonedBO:TNxCustomBusinessObject;
begin
 mSite:=TComponent(Sender).BusRollSite;
 if Assigned(mSite) then begin
   mBO:=TBusRollSiteForm(mSite).CurrentObject;
   if Assigned(mBO) then begin
      mClonedBO:=mBO.Clone;
      mClonedBO.SetFieldValueAsInteger('U_ApprovalStatus',0);
      mClonedBO.SetFieldValueAsBoolean('U_vyprodej',False);
      mClonedBO.SetFieldValueAsInteger('U_BusinessStatus',0);
      mClonedBO.SetFieldValueAsInteger('U_OrderStatus',0);
      mClonedBO.SetFieldValueAsDateTime('U_PricelistDate',0);
      mClonedBO.SetFieldValueAsDateTime('U_PriceChangeDate',0);
      mClonedBO.SetFieldValueAsString('U_PriceChangeName','');
      mClonedBO.SetFieldValueAsString('U_message','');
      mClonedBO.SetFieldValueAsBoolean('U_MinPriceValidate',false);
      mClonedBO.SetFieldValueAsInteger('U_receivedOrderExists',0);
      mClonedBO.SetFieldValueAsString('U_proposedExCode','');
      mClonedBO.SetFieldValueAsString('X_AnalyticsOV',nil);
      mClonedBO.SetFieldValueAsString('Code','');
      mClonedBO.SetFieldValueAsBoolean('U_MassCloned',False);
      mClonedBO.SetFieldValueAsString('U_SourceCode',mbo.GetFieldValueAsString('Code'));
      TDynSiteForm.ShowDynFormWithNewDocument(Site_StoreCards, msite.SiteContext, mClonedBO);
   end;
 end;
end;


begin
end.