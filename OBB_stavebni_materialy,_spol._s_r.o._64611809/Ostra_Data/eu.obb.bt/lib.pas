{
Umožňuje ovlivnit validaci.
}
procedure Validate_Hook(Self: TNxCustomBusinessObject; var AResult: Boolean);
var
 mList:TStringList;
begin
  if not(NxIsEmptyOID(self.GetFieldValueAsString('BusTransaction_ID'))) then begin
   mList:=TStringList.Create;
   self.ObjectSpace.SQLSelect(format('select id from defrolldata where x_value_id=''%s'' and x_BusTransaction_ID=''%s'' ',[self.GetFieldValueAsString('Division_ID'),self.GetFieldValueAsString('BusTransaction_ID')]),mList);
   if mList.Count=0 then begin
     self.AddValidateError(self.GetFieldCode('BusTransaction_ID'),Format('Nemáte právo použít obchodní případ %s %s pro středisko %s. ',[self.GetFieldValueAsString('BusTransaction_ID.Code'),self.GetFieldValueAsString('BusTransaction_ID.Name'),self.GetFieldValueAsString('Division_ID.Name')]));
     AResult:=False;
   end;
  mlist.Free;
  end;
end;

begin
end.