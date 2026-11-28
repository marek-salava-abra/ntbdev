{
Umožňuje ovlivnit validaci.
}
procedure Validate_Hook(Self: TNxCustomBusinessObject; var AResult: Boolean);
var
 mIssuedOrder_ID:string;
 mBO:TNxCustomBusinessObject;
begin
 if self.GetFieldValueAsString('U_Pozic')='' then begin
   mIssuedOrder_ID:=self.ObjectSpace.SQLSelectFirstAsString('select distinct(ro2io.targetheader_id) from'#13#10 +
                                                            'storedocuments2 sd2'#13#10 +
                                                            'left join receivedorderstoISSUEDORDERS ro2io'#13#10 +
                                                            'on sd2.provide_id=ro2io.sourceheader_id'#13#10 +
                                                            'where sd2.parent_id='+QuotedStr(self.oid),'');
   if not(NxIsEmptyOID(mIssuedOrder_ID)) then begin
     mBO:=self.ObjectSpace.CreateObject(Class_IssuedOrder);
     mBO.Load(mIssuedOrder_ID,nil);
     self.SetFieldValueAsString('U_Pozic',mbo.DisplayName);
     mBO.Free;
   end;
 end;
end;

begin
end.