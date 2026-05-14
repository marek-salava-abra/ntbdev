procedure AfterSave_Hook(Self: TNxCustomBusinessObject);
var
 mBODList:TStringList;
 mBODBO:TNxCustomBusinessObject;
 i:integer;
begin
  mBODList:=TStringList.Create;
  self.ObjectSpace.SQLSelect(format('Select ii2.Provide_id from issuedinvoices2 ii2 where ii2.parent_id=''%s'' ',[self.OID]),mBODList);
  if mBODList.count>0 then begin
  for i:=0 to mBODList.count-1 do begin
   if not(NxIsEmptyOID(mBODList.strings[i])) then begin
   try
    mBoDBO:=self.objectspace.CreateObject(Class_BillOfDelivery);
    mBODBO.Load(mbodlist.Strings[i],nil);
    if mBODBO.GetFieldValueAsString('PMState_ID')='2000000001' then begin
       if not (osSaving in mBODBO.InternalState) then mBODBO.PMChangeState('SDDEF00000');
    end;
   except
   end;
   end;
   end;
  end;
end;

begin
end.