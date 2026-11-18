uses 'eu.abra.masa.lipo.TBL.lib';
{
Vyvolává se po uložení vlastních dat objektu do databáze.
}
procedure AfterSave_Hook(Self: TNxCustomBusinessObject);
var
 mBO, mUserXLink:TNxCustomBusinessObject;
 mOrigState, mOrigJobOrder:string;
 mList:TStringList;
 i:integer;
begin
  self.GetOriginalValue('X_State_ID',mOrigState);
  self.GetOriginalValue('X_JobOrder',mOrigJobOrder);
  if not(self.GetFieldValueAsString('X_State_ID')=mOrigState) then begin
     mBO:=self.ObjectSpace.CreateObject('EWCAAHGDFUM45DTBKYBXWOA304');
     mBO.new;
     mBO.SetFieldValueAsString('Code',self.GetFieldValueAsString('Code'));
     mBO.SetFieldValueAsString('Name',self.GetFieldValueAsString('Name'));
     mBO.SetFieldValueAsString('X_JobOrder',self.GetFieldValueAsString('X_JobOrder'));
     mBO.SetFieldValueAsString('X_TransportBox_ID',self.OID);
     mbo.SetFieldValueAsString('X_State_ID',self.GetFieldValueAsString('X_State_ID'));
     if CFxNxRuntime.NxGetEnvironmentType=reRuntimeExe then begin
       mbo.SetFieldValueAsString('X_CreatedBy_ID',NxGetActualUserID_1(self));
       mBO.SetFieldValueAsString('X_WorkstationName',NxGetComputerName);
     end else begin
       mbo.SetFieldValueAsString('X_CreatedBy_ID',self.GetFieldValueAsString('X_CreatedBy_ID'));
       mBO.SetFieldValueAsString('X_WorkstationName',self.GetFieldValueAsString('X_WorkstationName'));
     end;
     mBo.SetFieldValueAsDateTime('X_StateChangeDate',Now);
     mbo.save;
     if not(NxIsEmptyOID(mBO.GetFieldValueAsString('X_JobOrder'))) then begin
        mUserXLink := self.ObjectSpace.CreateObject(Class_UserXLink);
        mUserXLink.New;
        mUserXLink.Prefill;
        mUserXLink.SetFieldValueAsString('SourceCLSID', 'EWCAAHGDFUM45DTBKYBXWOA304');
        mUserXLink.SetFieldValueAsString('Source_ID', mBO.OID);
        mUserXLink.SetFieldValueAsString('DestinationCLSID', Class_PLMJobOrder);
        mUserXLink.SetFieldValueAsString('Destination_ID', mBO.GetFieldValueAsString('X_JobOrder'));
        mUserXLink.SetFieldValueAsBoolean('DisplayAsSystem', True);
        mUserXLink.Save;
     end;
     if NxIsEmptyOID(mBO.GetFieldValueAsString('X_JobOrder')) and not(NxIsEmptyOID(mOrigJobOrder)) then begin
        mUserXLink := self.ObjectSpace.CreateObject(Class_UserXLink);
        mUserXLink.New;
        mUserXLink.Prefill;
        mUserXLink.SetFieldValueAsString('SourceCLSID', 'EWCAAHGDFUM45DTBKYBXWOA304');
        mUserXLink.SetFieldValueAsString('Source_ID', mBO.OID);
        mUserXLink.SetFieldValueAsString('DestinationCLSID', Class_PLMJobOrder);
        mUserXLink.SetFieldValueAsString('Destination_ID', mOrigJobOrder);
        mUserXLink.SetFieldValueAsBoolean('DisplayAsSystem', True);
        mUserXLink.Save;
     end;
     mbo.free;
  end;
  if not(NxIsEmptyOID(mOrigJobOrder)) and NxIsEmptyOID(self.GetFieldValueAsString('X_JobOrder')) then begin
    mList:=TStringList.create;
    self.ObjectSpace.SQLSelect('Select id from userxLinks where SourceClSID='+QuotedStr('TOKRQPFRTHA4ZAYQRXGRQKHED0')+' and Source_ID='+
                                Quotedstr(self.OID)+' and DestinationCLSID='+QuotedStr(class_plmjoborder)+ ' and Destination_ID='+QuotedStr(mOrigJobOrder),mList);
    for i:=0 to mlist.count-1 do begin
     try
      mUserXLink := self.ObjectSpace.CreateObject(Class_UserXLink);
      mUserXLink.Load(mlist.Strings[i],nil);
      mUserXLink.Delete;
     except
     end;
    end;
  end;
end;



{
Vyvolává se po změně každé položky. A to pouze, pokud k této změně nedochází díky načítání objektu z databáze nebo díky vytváření kopie.
}
procedure AfterSetFieldValue_Hook(Self: TNxCustomBusinessObject; AFieldCode: Integer; AValue: TNxParameter; AOriginalValue: TNxParameter);
begin
  if CFxNxRuntime.NxGetEnvironmentType=reRuntimeExe then begin
    if (AFieldCode=self.GetFieldCode('X_State_ID')) and not(AValue.AsString=AOriginalValue.AsString) and (AValue.AsString='~000000IP7') then begin
       self.SetFieldValueAsString('X_JobOrder','');
       self.SetFieldValueAsString('X_StoreBatch_ID','');
       self.SetFieldValueAsFloat('X_Quantity',0);
    end;
  end;
end;

{
Vyvolává se při předvyplňování hodnot daného objektu.
}


procedure Prefill_Hook(Self: TNxCustomBusinessObject);
var
  mCode: string;
begin
  mCode:= GetLatestCode(Self.ObjectSpace, 'DefRollData', Class_TransportBoxesLipoBO, 'LB', 4);
  Self.SetFieldValueAsString('Code', mCode);
  Self.SetFieldValueAsString('Name', mCode);
end;

{
procedure AfterDelete_Hook(Self: TNxCustomBusinessObject);
begin
  Self.ObjectSpace.SQLExecute('DELETE FROM DefRollData WHERE X_TransportBox_ID = '+QuotedStr(Self.OID));
end;
}
{
  if Self.CanDelete = False then begin
    mList:= TStringList.Create;
    try
      Self.ObjectSpace.SQLSelect('SELECT ID FROM DefRollData WHERE CLSID = '+QuotedStr(Class_TransportBoxesStateChangesBO)+' AND X_TransportBox_ID = '+QuotedStr(Self.OID), mList);
      if mList.Count > 0 then begin
        //if NxMessageBox('Dotaz', 'Před smazáním přepravky budou promazány změny stavů. Přejete si pokračovat?', mdConfirm, mbOKCancel, mrCancel, nil, false, nil) = mrOk then begin
          for i:= 0 to mList.Count -1 do begin
            {mBOChange:= Self.ObjectSpace.CreateObject(Class_TransportBoxesStateChangesBO);
            try
              mBOChange.Load(mList[i], nil);
              //mBOChange.Delete;
            finally
              mBOChange.Free;
            end;
            Self.ObjectSpace.SQLExecute('DELETE FROM DefRollData WHERE CLSID = '+QuotedStr(Class_TransportBoxesStateChangesBO)+' AND ID = '+QuotedStr(mList[i]));
          end;
        //end;
      end;
    finally
      mList.Free;
    end;
  end;
end;
}

begin
end.