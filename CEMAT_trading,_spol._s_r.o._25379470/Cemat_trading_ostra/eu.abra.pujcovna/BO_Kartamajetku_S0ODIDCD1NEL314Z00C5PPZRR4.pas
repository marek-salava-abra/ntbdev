{
Umožňuje ovlivnit validaci.
}
procedure Validate_Hook(Self: TNxCustomBusinessObject; var AResult: Boolean);
var
 mBO:TNxCustomBusinessObject;
 mList:TstringList;

begin
 if (AnsiLeftStr(self.GetFieldValueAsString('BusTransaction_ID.Code'),1)='R') then begin
   mList:=TStringList.create;
   self.ObjectSpace.SQLSelect(format('Select id from defrolldata where clsid=''11CZ0SV0RRW4PABA135VLXC3IO'' and code=''%s'' ',[self.GetFieldValueAsString('InventoryNr')]),mList);
   if mList.count=0 then begin
     mBO:=self.ObjectSpace.CreateObject('11CZ0SV0RRW4PABA135VLXC3IO');
     mbo.New;
     mbo.SetFieldValueAsString('Code',self.GetFieldValueAsString('InventoryNr'));
     mbo.SetFieldValueAsString('Name',self.GetFieldValueAsString('Name'));
     mbo.SetFieldValueAsString('U_AssetCard_ID',self.OID);
     mbo.SetFieldValueAsString('U_BusTransaction_ID',self.GetFieldValueAsString('BusTransaction_ID'));
     mbo.SetFieldValueAsFloat('U_PurchasePrice',self.GetFieldValueAsFloat('PurchasePrice'));
     mbo.SetFieldValueAsDateTime('U_purchasedate',self.GetFieldValueAsDateTime('Purchasedate$Date'));
     mbo.Save;
     mbo.free;
   end;

 end;
end;

begin
end.