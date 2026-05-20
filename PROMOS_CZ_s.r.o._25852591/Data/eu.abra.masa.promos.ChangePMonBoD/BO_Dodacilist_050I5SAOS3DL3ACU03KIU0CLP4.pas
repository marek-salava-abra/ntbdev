procedure AfterSave_Hook(Self: TNxCustomBusinessObject);
var
 mOrigPMState_ID, mOrder_ID:string;
 mBO:TNxCustomBusinessObject;
begin
  if self.GetFieldValueAsString('DocQueue_ID.Code')='DL' then begin
    self.GetOriginalValue('PMState_ID',mOrigPMState_ID);
    if (mOrigPMState_ID='SDDEF00000') and (self.GetFieldValueAsString('PMState_ID') in ['2040000101','3040000101','4040000101','5040000101']) then begin
       mOrder_ID:=self.ObjectSpace.SQLSelectFirstAsString('Select max(provide_id) from storedocuments2 where parent_id='+QuotedStr(self.OID),'');
       if not(NxIsEmptyOID(mOrder_ID)) then begin
         mbo:=self.ObjectSpace.CreateObject(Class_ReceivedOrder);
         mBO.Load(mOrder_ID,nil);
         mbo.PMChangeState('1040000101');
         mbo.free;
       end;
    end;
    if (self.GetFieldValueAsString('PMState_ID')='SDDEF00000') and (mOrigPMState_ID in ['2040000101','3040000101','4040000101','5040000101']) then begin
       mOrder_ID:=self.ObjectSpace.SQLSelectFirstAsString('Select max(provide_id) from storedocuments2 where parent_id='+QuotedStr(self.OID),'');
       if not(NxIsEmptyOID(mOrder_ID)) then begin
         mbo:=self.ObjectSpace.CreateObject(Class_ReceivedOrder);
         mBO.Load(mOrder_ID,nil);
         if mbo.GetFieldValueAsBoolean('Closed') then
          mbo.PMChangeState('8000000101') else mbo.PMChangeState('3010000101');
         mbo.free;
       end;
    end;
    if (self.GetFieldValueAsString('PMState_ID')='8040000101') and (mOrigPMState_ID in ['2040000101','3040000101','4040000101','5040000101']) then begin
       mOrder_ID:=self.ObjectSpace.SQLSelectFirstAsString('Select max(provide_id) from storedocuments2 where parent_id='+QuotedStr(self.OID),'');
       if not(NxIsEmptyOID(mOrder_ID)) then begin
         mbo:=self.ObjectSpace.CreateObject(Class_ReceivedOrder);
         mBO.Load(mOrder_ID,nil);
         if not(mBO.GetFieldValueAsString('PMState_ID')='3010000101') then
          mbo.PMChangeState('7040000101');
         mbo.free;
       end;
    end;
  end;
end;

begin
end.