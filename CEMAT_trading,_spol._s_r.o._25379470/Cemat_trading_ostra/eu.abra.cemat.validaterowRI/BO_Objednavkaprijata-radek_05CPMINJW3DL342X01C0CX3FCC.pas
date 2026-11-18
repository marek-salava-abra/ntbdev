{
Umožňuje ovlivnit validaci.
}
procedure Validate_Hook(Self: TNxCustomBusinessObject; var AResult: Boolean);
var
mHeader,mPostoffice:TNxCustomBusinessMoniker;
mheaderBO: TNxCustomBusinessObject;
mBusOrder_ID:String;
begin
   mheaderBO:=self.GetMonikerForFieldCode(self.GetFieldCode('Parent_ID')).BusinessObject;
   if not(NxIsEmptyOID(mHeaderbo.getfieldvalueasstring('X_postcode'))) then begin
     mBusOrder_ID:=mheaderBO.GetMonikerForFieldCode(mheaderBO.GetFieldCode('X_postcode')).BusinessObject.GetFieldValueAsString('X_OZ');
     //ShowMessage(mBusOrder_ID);
     self.setFieldValueAsString('Busorder_ID',mBusOrder_ID);
   
   end;
end;

begin
end.