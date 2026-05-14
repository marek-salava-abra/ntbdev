{
Vyvolává se po fyzickém vymazání vlastního objektu z databáze.
}
procedure AfterDelete_Hook(Self: TNxCustomBusinessObject);
var
 mXLink_ID:string;
 mBO:TNxCustomBusinessObject;
begin
  mXLink_ID:=self.ObjectSpace.SQLSelectFirstAsString('Select id from userxlinks where Source_ID='+QuotedStr(self.OID)+' and sourceclsid='+QuotedStr(Class_EmailSent)+
                                       ' and destinationclsid='+QuotedStr(Class_IssuedOrder),'');
  if not(NxIsEmptyOID(mXLink_ID)) then begin
    mBO:=self.ObjectSpace.CreateObject(Class_UserXLink);
    mBO.load(mXLink_ID,nil);
    mbo.delete;
  end;
end;

begin
end.