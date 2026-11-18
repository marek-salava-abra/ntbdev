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
  if TDynSiteForm(Self).CurrentObject.GetFieldValueAsBoolean('X_Send_INVOIC') then begin
    NxShowSimpleMessage('Doklad má odeslané potvrzení, nelze editovat',self);
    ACanEdit:=False;
  end;
end;

Procedure ConfirmBD(sender:tcomponent);
var
 mSite:TSiteForm;
 mBO, mOrderBO:TNxCustomBusinessObject;
 mExportList:TStringList;
 mFileName, mOrder_ID:string;
begin
 mSite:=TComponent(sender).DynSite;
 mBO:=TDynSiteForm(mSite).CurrentObject;
 if Assigned(mBO) then begin
    if (mBO.GetFieldValueAsString('Firm_ID.OrgIdentNumber')='41193598') and not(NxIsBlank(mbo.GetFieldValueAsString('X_BranchID'))) then begin
     if not(mbo.GetFieldValueAsBoolean('X_INVOIC_Sent')) and not(mbo.GetFieldValueAsBoolean('X_Send_INVOIC')) then begin
      if NxMessageBox('Dotaz','Přejete si odeslat fakturu vydanou '+mbo.DisplayName+'?'+#13#10+'Doklad již pak nepůjde editovat.' , mdConfirm, mdbYesNo, 0, 0, False, msite)= mrYes then begin
         mBO.SetFieldValueAsBoolean('X_Send_INVOIC',True);
         mBO.save;
         try
          mOrder_ID:=mbo.ObjectSpace.SQLSelectFirstAsString('Select distinct(sd2.provide_id) from issuedinvoices2 ii2 left join storedocuments2 sd2 on ii2.providerow_id=sd2.id where ii2.parent_id='+QuotedStr(mBO.OID),'');
          if not(NxIsEmptyOID(mOrder_ID)) then begin
            mOrderBO:=mBO.ObjectSpace.CreateObject(Class_ReceivedOrder);
            mOrderBO.load(mOrder_ID,nil);
            mOrderBO.SetFieldValueAsInteger('U_Stav',3);
            mOrderBO.save;
            mOrderBO.free;
          end;
         except

         end;
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

begin
end.