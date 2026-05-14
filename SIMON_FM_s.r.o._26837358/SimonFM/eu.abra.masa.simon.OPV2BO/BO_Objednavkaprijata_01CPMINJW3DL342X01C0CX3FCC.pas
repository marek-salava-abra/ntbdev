procedure _BeforeSave_PostHook(Self: TNxCustomBusinessObject);
var
 mBO, mRowBO:TNxCustomBusinessObject;
 mRows:TNxCustomBusinessMonikerCollection;
 i:integer;
 mBusOrder_ID:string;
begin
  if (self.GetFieldValueAsString('DocQueue_ID.Code')='OPV') and (osNew in self.state) then begin
     mBusOrder_ID:=self.ObjectSpace.SQLSelectFirstAsString('Select id from busorders where code='+QuotedStr(self.DisplayName)+' and hidden=''N'' ','');
     if NxIsEmptyOID(mBusOrder_ID) then begin
       mBO:=self.ObjectSpace.CreateObject(Class_BusOrder);
       mBO.new;
       mbO.prefill;
       mbo.SetFieldValueAsString('Code',self.DisplayName);
       mbo.SetFieldValueAsString('Name',self.DisplayName);
       mBO.SetFieldValueAsString('Firm_ID',self.GetFieldValueAsString('Firm_ID'));
       mBO.save;
       mBusOrder_ID:=mBO.OID;
     end;
     mRows:=self.GetLoadedCollectionMonikerForFieldCode(self.GetFieldCode('Rows'));
     for i:=0 to mrows.count-1 do begin
       mRowBO:=mRows.BusinessObject[i];
       if NxIsEmptyOID(mRowBO.GetFieldValueAsString('BusOrder_ID')) then
        mRowBO.SetFieldValueAsString('BusOrder_ID',mBusOrder_ID);
     end;
     //if self.NeedSave then self.save;
  end;
end;

begin
end.