{
Vyvolá se při vytváření DynSQL výrazu.
}
procedure _CreateDynSQLWhere_Hook(Self: TNxBusinessRoll; var aSQLFragment: string);
var
 mUser:TNxCustomBusinessObject;
begin
  mUser:=self.ObjectSpace.CreateObject(Class_SecurityUser);
  mUser.Load(NxGetActualUserID(self.ObjectSpace),nil);
  if not(nxisemptyoid(muser.GetFieldValueAsString('X_Store_ID'))) then begin
  aSQLFragment:=format('a.id in (Select f.pricelist_id from firms f where f.store_id=''%s'') or a.id in (Select f.pricelist_id from firms f where f.store_id is null)  or a.id in (select p.id from pricelists p left join firms f on f.pricelist_id=p.id where f.pricelist_id is null)  ',[muser.GetFieldValueAsString('X_Store_ID')]);
  //aSQLFragment:=format('a.id in (Select f.pricelist_id from firms f where f.store_id=''%s'') or a.id in (Select f.pricelist_id from firms f where f.store_id is null)  or a.id in (select p.id from pricelists p /*left*/ join firms  f on f.pricelist_id=p.id where f.pricelist_id is null)  ',[muser.GetFieldValueAsString('X_Store_ID')]);
  //NxShowSimpleMessage(aSQLFragment,nil);
  end;
end;

begin
end.