uses 'eu.obb.plantransport.fce';


procedure InitSite_Hook(Self: TSiteForm);
var
  mBut, mBut2: TBasicAction;

begin


  if not Assigned(Self.BaseObjectSpace) then
    exit;

   mBut:= Self.GetNewAction;
   mBut.ShowControl := True;
   mBut.ShowMenuItem := True;
   mBut.Caption := 'Založit dopravu';
   mBut.Category := 'tabList';
   mBut.OnExecute := @CreateTrans;
end;

procedure CreateTrans(sender:TComponent);
var
 mSite:TSiteForm;
 mBO, mCurrentUser, mRelation :TNxCustomBusinessObject;
 mActivityBO:TNxCustomBusinessObject;
 mSolverRole_ID, mDescription:string;
 mStartDate:Extended;
 mOS:TNxCustomObjectSpace;
 mRows:TNxCustomBusinessMonikerCollection;
 mRuka, mVlek:boolean;
begin
  mSolverRole_ID:='';
  mStartDAte:=0;
  mDescription:='';
  mRuka:=False;
  mVlek:=false;
  mSite:=TComponent(sender).DynSite;
  mBO:=TDynSiteForm(mSite).CurrentObject;
  if Assigned(mbo) then begin
   mOS:=mbo.ObjectSpace;
   mRows:=mbo.GetLoadedCollectionMonikerForFieldCode(mbo.GetFieldCode('Rows'));
   if NxMessageBox('Dotaz','Přejete si vygenerovat dopravu k '+mbo.DisplayName+'?' , mdConfirm, mdbYesNo, 0, 0, False, msite)= mrYes then begin
      mCurrentUser:=mOS.CreateObject(Class_SecurityUser);
      mCurrentUser.load(NxGetActualUserID(mOS),nil);
      if NxIsEmptyOID(mCurrentUser.GetFieldValueAsString('U_ActQueue_ID')) then begin
        NxShowSimpleMessage('Uživatel na sobě nemá výchozí řadu aktivit. Ukončuji.',mSite);
        exit;
      end;
      GetTransParam(msite, mSolverRole_ID, mDescription, mCurrentUser.GetFieldValueAsString('U_ActQueue_ID'), mstartdate, mRuka, mVlek);
      if NxIsEmptyOID(mSolverRole_ID) then begin
        NxShowSimpleMessage('Nebyl vyplněn dopravce. Ukončuji.', mSite);
        exit;
      end;
      if mStartDate<Now then begin
        NxShowSimpleMessage('Plánované datum je nižší než aktuální nebo nevyplněné. Ukončuji.', mSite);
        exit;
      end;

      if not(NxIsEmptyOID(mSolverRole_ID)) then begin
         mActivityBO:=mos.CreateObject(Class_CRMActivity);
         mActivityBO.new;
         mactivitybo.Prefill;
         mactivitybo.SetFieldValueAsString('ActivityArea_ID','1000000101');
         mactivitybo.SetFieldValueAsString('ActivityType_ID','1000000101');
         mActivitybo.SetFieldValueAsString('ActQueue_ID',mCurrentUser.GetFieldValueAsString('U_ActQueue_ID'));
         mActivitybo.SetFieldValueAsString('Subject',mbo.DisplayName+' '+mDescription);
         mActivityBO.SetFieldValueAsString('Firm_ID',mbo.GetFieldValueAsString('Firm_ID'));
         mActivityBO.SetFieldValueAsString('FirmOffice_ID',mbo.GetFieldValueAsString('FirmOffice_ID'));
         mActivityBo.SetFieldValueAsString('Division_ID',mrows.BusinessObject[0].GetFieldValueAsString('Division_ID'));
         mActivityBo.SetFieldValueAsString('BusOrder_ID',mrows.BusinessObject[0].GetFieldValueAsString('BusOrder_ID'));
         mActivityBo.SetFieldValueAsString('BusTransaction_ID',mrows.BusinessObject[0].GetFieldValueAsString('BusTransaction_ID'));
         mActivitybo.SetFieldValueAsString('SolverRole_ID',mSolverRole_ID);
         mActivityBO.SetFieldValueAsDateTime('SheduledStart$DATE',mStartDate);
         mActivityBO.SetFieldValueAsFloat('SheduledDuration$DATE',0.0104166666666667);
         mActivityBo.SetFieldValueAsBoolean('U_HR',mRuka);
         mActivityBo.SetFieldValueAsBoolean('U_vlek',mVlek);
         mactivitybo.save;
         mRelation:=mos.CreateObject(Class_Relation);
         mRelation.new;
         mRelation.SetFieldValueAsString('LeftSide_ID',mActivityBO.oid);
         mRelation.SetFieldValueAsString('RightSide_ID',mBO.oid);
         mRelation.SetFieldValueAsInteger('Rel_def',1231);
         mrelation.save;
         mRelation.free;
         NxShowSimpleMessage('Aktivita dopravy '+mActivityBO.DisplayName+' byla založena do časového plánu.',mSite);
         mActivityBO.Free;
      end;
   end;
  end;
end;

begin
end.