{
Vyvolává se po uložení vlastních dat objektu do databáze.
}
procedure AfterSave_Hook(Self: TNxCustomBusinessObject);
var
 mBODList:TStringList;
 mBODBO:TNxCustomBusinessObject;
begin
 if not(NxGetActualUserID_1(Self)='SUPER00000') then begin
  mBODList:=TStringList.Create;
  self.ObjectSpace.SQLSelect(format('Select ii2.Provide_id from cashreceived2 ii2 where ii2.parent_id=''%s'' ',[self.OID]),mBODList);
  if mBODList.count>0 then begin
   try
    mBoDBO:=self.objectspace.CreateObject(Class_BillOfDelivery);
    mBODBO.Load(mbodlist.Strings[0],nil);
    if mBODBO.GetFieldValueAsString('PMState_ID')='2000000001' then  mBOdBO.SetFieldValueAsString('PMState_ID','SDDEF00000');
    //mBoDBO.SetFieldValueAsString('Createdby_ID',mBO.GetFieldValueAsString('Createdby_ID'));
    if mBODBO.NeedSave then mbodbo.save;
    mbodbo.free;
   except
   end;
  end;
  end;
end;

begin
end.