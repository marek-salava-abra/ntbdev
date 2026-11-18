procedure InitSite_Hook(Self: TSiteForm);
var
  mBut: TBasicAction;
begin
    mBut:= Self.GetNewAction;
    mBut.ShowControl := True;
    mBut.ShowMenuItem := True;
    mBut.Caption := 'BEST DRIVE';
    mBut.Category := 'tabList';
    mBut.OnExecute := @ConfirmBD;
end;

procedure _CanEdit_Hook(Self: TDynSiteForm; var ACanEdit: Boolean);
begin
  if TDynSiteForm(Self).CurrentObject.GetFieldValueAsBoolean('X_Send_ORDRSP') then begin
    NxShowSimpleMessage('Doklad má odeslané potvrzení, nelze editovat',self);
    ACanEdit:=False;
  end;
end;

Procedure ConfirmBD(sender:tcomponent);
var
 mSite:TSiteForm;
 mBO:TNxCustomBusinessObject;
 mExportList:TStringList;
 mFileName:string;
begin
 mSite:=TComponent(sender).DynSite;
 mBO:=TDynSiteForm(mSite).CurrentObject;
 if Assigned(mBO) then begin
    if (mBO.GetFieldValueAsString('Firm_ID.OrgIdentNumber')='41193598') and not(NxIsBlank(mbo.GetFieldValueAsString('X_BranchID'))) then begin
     if not(mbo.GetFieldValueAsBoolean('X_ORDRSP_Sent')) and not(mbo.GetFieldValueAsBoolean('X_Send_ORDRSP')) then begin
      if NxMessageBox('Dotaz','Přjete si odeslat potvrzení objednávky '+mbo.DisplayName+'?'+#13#10+'Doklad již pak nepůjde editovat.' , mdConfirm, mdbYesNo, 0, 0, False, msite)= mrYes then begin
         mBO.SetFieldValueAsBoolean('X_Send_ORDRSP',True);
         mBO.save;
         TDynSiteForm(mSite).RefreshData;
         TDynSiteForm(mSite).ActiveDataSet.SeekID(mbo.OID);
      end;
     end else begin
      NxShowSimpleMessage('Doklad '+mbo.DisplayName+' byl již zařazen do odeslání nebo je odeslaný.',mSite);
     end;
    end else begin
      NxShowSimpleMessage('Doklad není určen pro odeslání na SFTP. Ukončuji.', mSite);
    end;
 end;
end;



begin
end.