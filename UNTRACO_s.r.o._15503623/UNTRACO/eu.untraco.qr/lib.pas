
{SupplierPrice}

function SupplierPrice(AReportHelper:TNxQRScriptHelper;StoreCard_ID:String):Extended;
var
 mList:TStringList;
begin
 Result:=0;
 if not(NxIsEmptyOID(StoreCard_ID)) then begin
   mList:=tstringlist.Create;
   AReportHelper.ObjectSpace.SQLSelect(format('select sp2.purchaseprice from supplierPRICELISTS sp left join supplierPRICELISTS2 sp2 on sp.id=sp2.parent_ID where  sp2.storecard_id=''%s'' order by sp.validfromdate$date desc ',[StoreCard_ID]),mList);
   if mList.count>0 then Result:=StrToFloat(mlist.strings[0]);
 end;
end;

begin
end.