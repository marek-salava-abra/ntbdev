{
Vyvolává se po uložení vlastních dat objektu do databáze.
}
procedure AfterSave_Hook(Self: TNxCustomBusinessObject);
var
 mUserXLink_ID, mOrder_ID, mDocNumber, mDocQueueCode, mOrdnumber, mPeriodCode:string;
 mUserXLink:TNxCustomBusinessObject;
begin
  if (self.GetFieldValueAsString('DocQueue_ID')='6RW0000101') and (osNew in self.State) then begin
      mDocNumber:=NxSearchReplace(self.GetFieldValueAsString('Code'),'Převod k ','',[srAll]);
      mDocQueueCode:=NxTrapStrTrim(mDocNumber,'-');
      mOrdnumber:=NxTrapStrTrim(mDocNumber,'/');
      mPeriodCode:=NxTrapStrTrim(mDocNumber,'/');
      mOrder_ID:=self.ObjectSpace.SQLSelectFirstAsString('Select ro.id from receivedorders ro left join periods p on p.id=ro.period_id left join docqueues dq on dq.id=ro.docqueue_id where '+
                                                         ' dq.code='+QuotedStr(mDocQueueCode)+' and p.code='+QuotedStr(mPeriodCode)+' and ro.ordnumber='+mOrdnumber,'');
      if not(NxIsEmptyOID(mOrder_ID)) then begin
       mUserXLink_ID:=self.ObjectSpace.SQLSelectFirstAsString('Select id from userxlinks where source_id='+QuotedStr(self.OID)+' and SourceCLSID='+QuotedStr(Class_PRFLog)+
                                                 ' and destination_id='+QuotedStr(mOrder_ID)+' and DestinationCLSID='+QuotedStr(Class_ReceivedOrder),'');
       if NxIsEmptyOID(mUserXLink_ID) then begin
        mUserXLink := self.ObjectSpace.CreateObject(Class_UserXLink);
        try
          mUserXLink.New;
          mUserXLink.Prefill;
          mUserXLink.SetFieldValueAsString('SourceCLSID', Class_PRFLog);
          mUserXLink.SetFieldValueAsString('Source_ID', self.oid);
          mUserXLink.SetFieldValueAsString('DestinationCLSID', Class_ReceivedOrder);
          mUserXLink.SetFieldValueAsString('Destination_ID', mOrder_ID);
          mUserXLink.SetFieldValueAsBoolean('DisplayAsSystem', True);
          mUserXLink.SetFieldValueAsString('Description','Log - '+self.GetFieldValueAsString('Code'));
          mUserXLink.Save;
        finally
          mUserXLink.Free;
        end;
       end;
      end;
  end;
  if (self.GetFieldValueAsString('DocQueue_ID')='6RX0000101') and (osNew in self.State) then begin
      mDocNumber:=NxSearchReplace(self.GetFieldValueAsString('Code'),'Kontrola ','',[srAll]);
      mDocQueueCode:=NxTrapStrTrim(mDocNumber,'-');
      mOrdnumber:=NxTrapStrTrim(mDocNumber,'/');
      mPeriodCode:=NxTrapStrTrim(mDocNumber,'/');
      mOrder_ID:=self.ObjectSpace.SQLSelectFirstAsString('Select ro.id from receivedorders ro left join periods p on p.id=ro.period_id left join docqueues dq on dq.id=ro.docqueue_id where '+
                                                         ' dq.code='+QuotedStr(mDocQueueCode)+' and p.code='+QuotedStr(mPeriodCode)+' and ro.ordnumber='+mOrdnumber,'');
      if not(NxIsEmptyOID(mOrder_ID)) then begin
       mUserXLink_ID:=self.ObjectSpace.SQLSelectFirstAsString('Select id from userxlinks where source_id='+QuotedStr(self.OID)+' and SourceCLSID='+QuotedStr(Class_PRFLog)+
                                                 ' and destination_id='+QuotedStr(mOrder_ID)+' and DestinationCLSID='+QuotedStr(Class_ReceivedOrder),'');
       if NxIsEmptyOID(mUserXLink_ID) then begin
        mUserXLink := self.ObjectSpace.CreateObject(Class_UserXLink);
        try
          mUserXLink.New;
          mUserXLink.Prefill;
          mUserXLink.SetFieldValueAsString('SourceCLSID', Class_PRFLog);
          mUserXLink.SetFieldValueAsString('Source_ID', self.oid);
          mUserXLink.SetFieldValueAsString('DestinationCLSID', Class_ReceivedOrder);
          mUserXLink.SetFieldValueAsString('Destination_ID', mOrder_ID);
          mUserXLink.SetFieldValueAsBoolean('DisplayAsSystem', True);
          mUserXLink.SetFieldValueAsString('Description','Log - '+self.GetFieldValueAsString('Code'));
          mUserXLink.Save;
        finally
          mUserXLink.Free;
        end;
       end;
      end;
  end;
end;



begin
end.