{
Vyvolává se po uložení vlastních dat objektu do databáze.
}
procedure AfterSave_Hook(Self: TNxCustomBusinessObject);
var
 mOrigPMState_ID, mOrder_ID:string;
 mBO:TNxCustomBusinessObject;
begin
  if self.GetFieldValueAsString('DocQueue_ID.Code')='DL03' then begin
    self.GetOriginalValue('PMState_ID',mOrigPMState_ID);
    if (mOrigPMState_ID='SDDEF00000') and (self.GetFieldValueAsString('PMState_ID') in ['3080000101','4080000101','5080000101','6080000101']) then begin
       mOrder_ID:=self.ObjectSpace.SQLSelectFirstAsString('Select max(provide_id) from storedocuments2 where parent_id='+QuotedStr(self.OID),'');
       if not(NxIsEmptyOID(mOrder_ID)) then begin
         mbo:=self.ObjectSpace.CreateObject(Class_ReceivedOrder);
         mBO.Load(mOrder_ID,nil);
         mbo.PMChangeState('1080000101');
         mbo.free;
       end;
    end;
    if (self.GetFieldValueAsString('PMState_ID')='SDDEF00000') and (mOrigPMState_ID in ['3080000101','4080000101','5080000101','6080000101']) then begin
       mOrder_ID:=self.ObjectSpace.SQLSelectFirstAsString('Select max(provide_id) from storedocuments2 where parent_id='+QuotedStr(self.OID),'');
       if not(NxIsEmptyOID(mOrder_ID)) then begin
         mbo:=self.ObjectSpace.CreateObject(Class_ReceivedOrder);
         mBO.Load(mOrder_ID,nil);
         mbo.PMChangeState('7060000101');
         mbo.free;
       end;
    end;
    if (self.GetFieldValueAsString('PMState_ID')='8080000101') and (mOrigPMState_ID in ['3080000101','4080000101','5080000101','6080000101']) then begin
       mOrder_ID:=self.ObjectSpace.SQLSelectFirstAsString('Select max(provide_id) from storedocuments2 where parent_id='+QuotedStr(self.OID),'');
       if not(NxIsEmptyOID(mOrder_ID)) then begin
         mbo:=self.ObjectSpace.CreateObject(Class_ReceivedOrder);
         mBO.Load(mOrder_ID,nil);
         mbo.PMChangeState('2080000101');
         mbo.free;
       end;
    end;
  end;
end;

begin
end.