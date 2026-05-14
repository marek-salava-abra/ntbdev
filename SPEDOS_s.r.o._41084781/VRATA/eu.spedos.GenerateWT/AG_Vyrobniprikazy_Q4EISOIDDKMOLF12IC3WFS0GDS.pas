procedure InitSite_Hook(Self: TSiteForm);
var
  mAction: TBasicAction;
  mAList: TActionList;
  i:integer;
begin
  mAList := Self.GetMainActionList;

  for i := 0 to mAList.ActionCount-1 do begin
    mAction := mAList.Actions[i];
    //NxShowSimpleMessage(mAction.Name,nil);
    if mAction.Name='actCorrectPrices' then begin
      tAction(mAction).Visible:=false;
    end;
    if mAction.Name='actReservation' then begin
      tAction(mAction).Visible:=false;
    end;
    if mAction.Name='actFindDoc' then begin
      tAction(mAction).Visible:=false;
    end;
    {if mAction.Name='actPLMSCM' then begin
      TMultiAction(mAction).Visible:=false;
    end;
    if mAction.Name='actSCM' then begin
      TMultiAction(mAction).Visible:=false;
    end;  }
    if mAction.Name='actActivity' then begin
      TMultiAction(mAction).Visible:=false;
    end;  {
    if mAction.Name='mactRelatedHere' then begin
      TMultiAction(mAction).Visible:=false;
    end;
    if mAction.Name='mactRelatedNoHere' then begin
      TMultiAction(mAction).Visible:=false;
    end; }
  end;

  mAction := Self.GetNewAction;
  mAction.ShowControl := True;
  mAction.ShowMenuItem := True;
  mAction.Caption := 'Generovat PL';
  mAction.Hint := 'Vygeneruje pracovní lístky na neprovedené operace dle normy';
  mAction.Category := 'tabList';
  mAction.OnExecute := @CreateWT;

  mAction := Self.GetNewAction;
  mAction.ShowControl := True;
  mAction.ShowMenuItem := True;
  mAction.Caption := 'Změní materiál';
  mAction.Hint := 'Změní nevydaný materiál z karty A na kartu B';
  mAction.Category := 'tabList';
  mAction.OnExecute := @ChangeMaterial;
end;

Procedure ChangeMaterial(Sender:TComponent);
var
 mSite:TSiteForm;
 mStoreCard1_ID, mStoreCard2_ID:string;
 mSCBO1, mSCBO2, mVYPBO, mInputRow:TNxCustomBusinessObject;
 mVYPList:TStringList;
 i,j,k:integer;
 mInputs:TNxCustomBusinessMonikerCollection;
 mOS:TNxCustomObjectSpace;
begin
 mSite:=TComponent(Sender).DynSite;
 mOS:=mSite.BaseObjectSpace;
 mVYPList:=TStringList.create;
 TDynSiteForm(mSite).List.GetSelectedId(mVYPList);
 if mVYPList.Count>0 then begin
   for i:=0 to mVYPList.Count-1 do begin
      mVYPBO:=mOS.CreateObject(Class_PLMJobOrder);
      mVYPBO.Load(mVYPList.strings[i],nil);
       if mVYPBO.GetFieldValueAsDateTime('FinishedAt$DATE')>0 then begin
         NxShowSimpleMessage('Aspoň jeden z VYP je již ukončen. Ukončuji.',mSite);
         exit;
       end;
      mVYPBO.free;
    end;
   if GetStoreCards(msite, mStoreCard1_ID,mStoreCard2_ID) then begin
    if NxIsEmptyOID(mStoreCard1_ID) or NxIsEmptyOID(mStoreCard2_ID) then begin
      NxShowSimpleMessage('Není vyplněna zdrojová nebo cílová karta. Ukončuji.',mSite);
      exit;
    end;
    mSCBO1:=mOS.CreateObject(Class_StoreCard);
    mSCBO1.Load(mStoreCard1_ID,nil);
    mSCBO2:=mOS.CreateObject(Class_StoreCard);
    mSCBO2.Load(mStoreCard2_ID,nil);
    if not(mSCBO1.GetFieldValueAsString('MainUnitCode')=mSCBO2.GetFieldValueAsString('MainUnitCode')) then begin
      NxShowSimpleMessage('Skladová karta '+mSCBO1.DisplayName+#13#10+' a skladová karta '+mscbo2.DisplayName+#13#10+
                          'mají rozdílné hlavní jednotky. Ukončuji.',msite);
      exit;
    end;
    for i:=0 to mVYPList.Count-1 do begin
      mVYPBO:=mOS.CreateObject(Class_PLMJobOrder);
      mVYPBO.Load(mVYPList.strings[i],nil);
       mInputs:=mVYPBO.GetLoadedCollectionMonikerForFieldCode(mVYPBO.GetFieldCode('Inputs'));
       for k:=0 to mInputs.count-1 do begin
         mInputRow:=mInputs.BusinessObject[k];
         if (mInputRow.GetFieldValueAsString('RealStoreCard_ID')=mStoreCard1_ID) and (mInputRow.GetFieldValueAsFloat('DistributedQuantity')=0) then begin
              mInputRow.SetFieldValueAsString('RealStoreCard_ID',mStoreCard2_ID);
              mInputRow.SetFieldValueAsString('Owner_ID.StoreCard_ID',mStoreCard2_ID);
         end;
       end;
      try
       mVYPBO.save;
      except
       NxShowSimpleMessage(ExceptionMessage,mSite);
      end;
      mVYPBO.free;
    end;
   end;
   NxShowSimpleMessage('Provedeno, občerstveno.',mSite);
   TDynSiteForm(mSite).RefreshData;
 end;
end;

Procedure CreateWT(Sender:TComponent);
var
 mSite:TSiteForm;
 mVYPList:TStringList;
 i,j,k:integer;
 mVYPBO, mRoutineBO, mOutputBO, mOperation:TNxCustomBusinessObject;
 mOS:TNxCustomObjectSpace;
 mOutputs, mPLMJobOrdersRoutines:TNxCustomBusinessMonikerCollection;
begin
 mSite:=TComponent(Sender).DynSite;
 mOS:=mSite.BaseObjectSpace;
 mVYPList:=TStringList.create;
 TDynSiteForm(mSite).List.GetSelectedId(mVYPList);
 if mVYPList.Count>0 then begin
    for i:=0 to mVYPList.Count-1 do begin
      mVYPBO:=mOS.CreateObject(Class_PLMJobOrder);
      mVYPBO.Load(mVYPList.strings[i],nil);
       if mVYPBO.GetFieldValueAsDateTime('FinishedAt$DATE')>0 then begin
         NxShowSimpleMessage('Aspoň jeden z VYP je již ukončen. Ukončuji.',mSite);
         exit;
       end;
      mVYPBO.free;
    end;
    if NxMessageBox('Dotaz','Přejete si vygenerovat pracovní lístky k '+IntToStr(mVYPList.Count)+' výrobním příkazům?' , mdConfirm, mdbYesNo, 0, 0, False, msite)= mrYes then begin
      for i:=0 to mVYPList.count-1 do begin
         mVYPBO:=mOS.CreateObject(Class_PLMJobOrder);
         mVYPBO.Load(mVYPList.strings[i],nil);
         mOutputs:=mVYPBO.GetLoadedCollectionMonikerForFieldCode(mVYPBO.GetFieldCode('Outputs'));
            for j:=0 to mOutputs.Count-1 do begin
              mOutputBO:=mOutputs.BusinessObject[j];
              mPLMJobOrdersRoutines:=mOutputBO.GetLoadedCollectionMonikerForFieldCode(mOutputBO.GetFieldCode('PLMJobOrdersRoutines'));
              for k:=0 to mPLMJobOrdersRoutines.count-1 do begin
                mRoutineBO:=mPLMJobOrdersRoutines.BusinessObject[k];
                if (mRoutineBO.GetFieldValueAsFloat('RealizedTime')=0) and not(mRoutineBO.GetFieldValueAsBoolean('Finished')) then begin
                   mOperation:=mOS.CreateObject(Class_PLMOperation);
                   mOperation.new;
                   mOperation.Prefill;
                   mOperation.SetFieldValueAsString('BusOrder_ID', mVYPBO.GetFieldValueAsString('BusOrder_ID'));
                   mOperation.SetFieldValueAsString('BusTransaction_ID', mVYPBO.GetFieldValueAsString('BusTransaction_ID'));
                   mOperation.SetFieldValueAsString('Division_ID', mVYPBO.GetFieldValueAsString('Division_ID'));
                   mOperation.SetFieldValueAsFloat('Quantity', 0);
                   mOperation.SetFieldValueAsString('JobOrdersRoutines_ID',mRoutineBO.OID);
                   mOperation.SetFieldValueAsString('SalaryClass_ID',mOperation.GetFieldValueAsString('JobOrdersRoutines_ID.SalaryClass_ID'));
                   mOperation.SetFieldValueAsString('WorkPlace_ID',mOperation.GetFieldValueAsString('JobOrdersRoutines_ID.WorkPlace_ID'));
                   mOperation.SetFieldValueAsDateTime('StartedAt$DATE',Now);
                   mOperation.SetFieldValueAsDateTime('FinishedAt$DATE',now);
                   mOperation.SetFieldValueAsFloat('Duration',mRoutineBO.GetFieldValueAsFloat('MissedDuration'));
                   moperation.SetFieldValueAsBoolean('OperationResult',True);
                   moperation.SetFieldValueAsString('PerformedBy_ID','1300000101');
                   mOperation.Save;
                   mOperation.free;
                end;
              end;
            end;
         mVYPBO.free;
      end;
    end;
 end;
 mVYPList.free;

end;

function GetStoreCardS(var ASite : TSiteform; var aStoreCard_ID, bStoreCard_ID:string) : Boolean;
var mForm : TForm;
    mCb, mCb1: TRollComboEdit;
    mCbCc, mCbCc1: TLabel;
    mLabel1, mLabel2, mLabel3 : TLabel;
    mButOk, mButCancel : TButton;
    mResult : integer;
begin
  if ASite <> nil then begin
    mForm:= TForm.Create(ASite);  //Form mus=i být vytvářen na Site , kvuli přebráni Contextu
    mForm.Left:= 300;
    mForm.Top:= 300;
    mForm.Width:= 409;
    mForm.Height:= 178;
    mForm.Caption := 'Karty pro záměnu';

    mLabel3 := TLabel.Create(mForm);
    mLabel3.Parent := mForm;
    mLabel3.Caption := 'Zdrojová karta:';
    mLabel3.Top := 8;
    mLabel3.Left := 17;
    mLabel3.Height := 13;
    mLabel3.Width := 200;
    mLabel3.Font.Size := 10;
    mLabel3.Font.Style := [fsUnderline];

    mCbCc:= TLabel.Create(mForm);  //Vytvoŕení containeru pro zobrazení výběru
    mCbCc.Parent:= mForm;
    //mCbCc.BevelOuter:= bvLowered;
    mCbCc.Left:= 128;
    mCbCc.Top:= 31;
    mCbCc.Width:= 255;

    mCb:= TRollComboEdit.Create(mForm);
    mCb.Parent:= mForm;

    mCb.ClassID:= 'S3WZQKDB5FDL342M01C0CX3FCC';
    mCb.Complete:= True;
    mCb.ForcedField:= True;
    mCb.Prefilling:= pmNone;
    mCb.TextField:= 'CODE';  // položka podle které se bude vyhledávat
    mCb.Top:= 31;
    mCb.Left:= 17;
    mCb.Width:= 108;
    mCb.ConnectedControl:= mCbCc;
    mCb.ConnectedControlField:= 'Name';

    mLabel3 := TLabel.Create(mForm);
    mLabel3.Parent := mForm;
    mLabel3.Caption := 'Cílová karta:';
    mLabel3.Top := 57;
    mLabel3.Left := 17;
    mLabel3.Height := 13;
    mLabel3.Width := 200;
    mLabel3.Font.Size := 10;
    mLabel3.Font.Style := [fsUnderline];

    mCbCc1:= TLabel.Create(mForm);  //Vytvoŕení containeru pro zobrazení výběru
    mCbCc1.Parent:= mForm;
    //mCbCc.BevelOuter:= bvLowered;
    mCbCc1.Left:= 128;
    mCbCc1.Top:= 80;
    mCbCc1.Width:= 255;

    mCb1:= TRollComboEdit.Create(mForm);
    mCb1.Parent:= mForm;

    mCb1.ClassID:= 'S3WZQKDB5FDL342M01C0CX3FCC';
    mCb1.Complete:= True;
    mCb1.ForcedField:= True;
    mCb1.Prefilling:= pmNone;
    mCb1.TextField:= 'CODE';  // položka podle které se bude vyhledávat
    mCb1.Top:= 80;
    mCb1.Left:= 17;
    mCb1.Width:= 108;
    mCb1.ConnectedControl:= mCbCc1;
    mCb1.ConnectedControlField:= 'Name';  //položka která bude zobrazena v containeru

    mButOk:= TButton.Create(mForm);
    mButOk.Parent := mForm;
    mButOk.Caption := 'Ok';
    mButOk.Top := 110;
    mButOk.Left := 252;
    mButOk.Height := 24;
    mButOk.Width := 62;
    mButOk.ModalResult := 1;

    mButCancel := TButton.Create(mForm);
    mButCancel.Parent := mForm;
    mButCancel.Caption := 'Cancel';
    mButCancel.Top := 110;
    mButCancel.Left := 320;
    mButCancel.Height := 24;
    mButCancel.Width := 62;
    mButCancel.ModalResult := 2;


    mResult := mForm.ShowModal(ASite);
   // if mButCancel.OnC
    if mResult = 1 then begin
        Result := true;
        aStoreCard_ID:=mCb.DataText;
        bStoreCard_ID:=mCb1.DataText;
    end else Result := false;
    //ShowMessage(mCb.DataText);
    //Result := mCb.DataText;
    mForm.free;
  end;
end;

begin
end.