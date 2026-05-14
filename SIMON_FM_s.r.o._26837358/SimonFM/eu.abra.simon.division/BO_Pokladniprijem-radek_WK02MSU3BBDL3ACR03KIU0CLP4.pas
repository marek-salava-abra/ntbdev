procedure AfterSoftValidate_Hook(Self: TNxCustomBusinessObject);
begin
  if not(NxIsEmptyOID(self.GetMonikerForFieldCode(self.GetFieldCode('Parent_ID')).BusinessObject.GetMonikerForFieldCode(self.GetMonikerForFieldCode(self.GetFieldCode('Parent_ID')).BusinessObject.GetFieldCode('Firm_id')).BusinessObject.GetFieldValueAsString('U_BusTransaction_ID'))) then begin
  if not(self.GetFieldValueAsString('BusTransaction_ID')=self.GetMonikerForFieldCode(self.GetFieldCode('Parent_ID')).BusinessObject.GetMonikerForFieldCode(self.GetMonikerForFieldCode(self.GetFieldCode('Parent_ID')).BusinessObject.GetFieldCode('Firm_id')).BusinessObject.GetFieldValueAsString('U_BusTransaction_ID'))
  then
  ShowMessage('Obchodní případ se neshoduje s přiděleným OP k firmě');
  end;
end;


procedure Prefill_Hook(Self: TNxCustomBusinessObject);
var
mUser: TNxCustomBusinessObject;

begin
  muser:= self.ObjectSpace.CreateObject('22AHIVDVAVE13C5S00CA141B44');
    mUser.Load(NxGetActualUserID_1(self), nil);
    self.SetFieldValueAsString('Division_ID',mUser.GetFieldValueAsString('X_Division_ID'));
    self.SetFieldValueAsString('BusTransaction_ID',
    self.GetMonikerForFieldCode(self.GetFieldCode('Parent_ID')).BusinessObject.GetMonikerForFieldCode(self.GetMonikerForFieldCode(self.GetFieldCode('Parent_ID')).BusinessObject.GetFieldCode('Firm_id')).BusinessObject.GetFieldValueAsString('U_BusTransaction_ID')
    );
end;


begin
end.