procedure AfterSave_Hook(Self: TNxCustomBusinessObject);
var
 mList:tstringlist;
 i:integer;
 mBO:TNxCustomBusinessObject;
begin
  if self.GetFieldValueAsBoolean('X_NotCalc') then begin
     mList:=TStringList.create;
     self.ObjectSpace.SQLSelect(format('select id from storesubcards where storecard_id=''%s'' and not(lowlimitquantity=0) ',[self.OID]),mList);
     if mlist.count>0 then begin
       for i:=0 to mlist.count-1 do begin
          mBO:=self.ObjectSpace.CreateObject(Class_StoreSubCard);
          mBO.load(mlist.strings[i],nil);
          mBO.SetFieldValueAsFloat('LowLimitQuantity',0);
          mBO.save;
          mbo.free;
       end;
     end;
  end;
end;

begin
end.