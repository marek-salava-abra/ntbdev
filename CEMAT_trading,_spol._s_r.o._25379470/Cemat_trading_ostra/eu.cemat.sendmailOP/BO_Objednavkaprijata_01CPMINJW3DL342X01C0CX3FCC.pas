{
Vyvolává se po uložení vlastních dat objektu do databáze.
}
procedure AfterSave_Hook(Self: TNxCustomBusinessObject);
var
 mMailList:TStringList;
 i, j :integer;
 mRows:TNxCustomBusinessMonikerCollection;
 mRowBO:TNxCustomBusinessObject;
 {reDebugger,reRuntimeExe,reDelphi,reShell,reOLEAutomation,reWebServices,reAutoServer,reToolExe}
begin
NxScriptingLog.EnterSection('CreateMail', logNotice);
 {if CFxNxRuntime.NxGetEnvironmentType=reDebugger then NxScriptingLog.WriteEvent(logInfo,'reDebugger '+self.DisplayName);
 if CFxNxRuntime.NxGetEnvironmentType=reRuntimeExe then NxScriptingLog.WriteEvent(logInfo,'reRuntimeExe '+self.DisplayName);
 if CFxNxRuntime.NxGetEnvironmentType=reDelphi then NxScriptingLog.WriteEvent(logInfo,'reDelphi '+self.DisplayName);
 if CFxNxRuntime.NxGetEnvironmentType=reShell then NxScriptingLog.WriteEvent(logInfo,'reShell '+self.DisplayName);
 if CFxNxRuntime.NxGetEnvironmentType=reOLEAutomation then NxScriptingLog.WriteEvent(logInfo,'reOLEAutomation '+self.DisplayName);
 if CFxNxRuntime.NxGetEnvironmentType=reWebServices then NxScriptingLog.WriteEvent(logInfo,'reWebServices '+self.DisplayName);
 if CFxNxRuntime.NxGetEnvironmentType=reAutoServer then NxScriptingLog.WriteEvent(logInfo,'reAutoServer '+self.DisplayName);
 if CFxNxRuntime.NxGetEnvironmentType=reToolExe then NxScriptingLog.WriteEvent(logInfo,'reToolExe '+self.DisplayName);}
  if (CFxNxRuntime.NxGetEnvironmentType=reWebServices) then begin
   if osNew in Self.state then begin
       mMailList:=TStringList.create;
       mRows:=self.GetLoadedCollectionMonikerForFieldCode(self.GetFieldCode('Rows'));
       for i:=0 to mrows.count-1 do begin
         mRowBO:=mRows.BusinessObject[i];
         if mRowBO.GetFieldValueAsInteger('RowType')=3 then begin
           if not(NxIsEmptyOID(mRowBo.GetFieldValueAsString('StoreCard_ID.StoreAssortmentGroup_ID'))) then begin
             if NxIsValidEMail(mRowBo.GetFieldValueAsString('StoreCard_ID.StoreAssortmentGroup_ID.U_Email'),false) then begin
               if not(mMailList.Find(mRowBo.GetFieldValueAsString('StoreCard_ID.StoreAssortmentGroup_ID.U_email'),-1)) then mMailList.Add(mRowBo.GetFieldValueAsString('StoreCard_ID.StoreAssortmentGroup_ID.U_Email'));
             end;
           end;
         end;
       end;
       if mMailList.count>0 then begin
          for j:=0 to mMailList.count-1 do begin
            SendInternalMail(self.ObjectSpace,mMailList.strings[j],'','','Nová objednávka z CRM',
                             'číslo objednávky '+self.DisplayName,'',self.GetFieldValueAsString('Firm_ID'),mRows.BusinessObject[0].GetFieldValueAsString('Division_ID'),mRows.BusinessObject[0].GetFieldValueAsString('BusTransaction_ID'));

          end;
       end;
     end;
   end;
  NxScriptingLog.LeaveSection('CreateMail', logNotice);
end;

procedure SendInternalMail(AOS:TNxCustomObjectSpace; ATo:String; ACC:String; ABCC:String; ASubject:String; ABody:String;
 AAtachement:String; AFirm_ID:String; ADivision_ID:String; ABusTransaction_ID:String);
Var
  mMailBO:TNxCustomBusinessObject;
  mMRecipients:TNxCustomBusinessMonikerCollection;
  mMailRecipient:TNxCustomBusinessObject;
begin
  if not(ato='') then begin
     mMailBO:=AOS.CreateObject('5C1HWDQDR3J4NAAYZRO5PWHLWK');
     mMailBO.New;
     mMailBO.Prefill;
     mMailBO.SetFieldValueAsString('EmailAccount_ID','1000000101');
     mMailBO.SetFieldValueAsString('Subject',ASubject);
     mMailbo.SetFieldValueAsInteger('SentState',1);
     mMailBO.SetFieldValueAsString('Body',ABody);
     mMailBO.SetFieldValueAsString('Firm_ID',AFirm_ID);
     mMailBO.SetFieldValueAsString('Division_ID',ADivision_ID);
     mMailBO.SetFieldValueAsString('BusTransaction_ID',ABusTransaction_ID);
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