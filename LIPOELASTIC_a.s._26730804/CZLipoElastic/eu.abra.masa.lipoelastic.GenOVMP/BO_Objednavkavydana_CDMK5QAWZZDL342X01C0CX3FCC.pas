{
Vyvolává se po fyzickém vymazání vlastního objektu z databáze.
}
procedure AfterDelete_Hook(Self: TNxCustomBusinessObject);
var
 mXLink_ID:string;
 mUserXLink:TNxCustomBusinessObject;
begin
  if self.GetFieldValueAsString('DocQueue_ID.Code')='OVMP' then begin
     mXLink_ID:=self.ObjectSpace.SQLSelectFirstAsString('Select id from userxlinks where SourceCLSID='+QuotedStr(Class_IssuedOrder)+
                                               ' and Destination_id='+QuotedStr(self.OID)+' and DestinationCLSID='+QuotedStr(Class_IssuedOrder),'');
     if not(NxIsEmptyOID(mXLink_ID)) then begin
       mUserXLink:=self.ObjectSpace.CreateObject(Class_UserXLink);
       mUserXLink.load(mXLink_ID,nil);
       mUserXLink.delete;
     end;
  end;
end;

begin
end.