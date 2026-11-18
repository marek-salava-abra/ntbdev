
const
  CLSID_SecurityUser='';


procedure Prefill_Hook(Self: TNxCustomBusinessObject; AFieldCode: Integer; AValue: TNxParameter; AOriginalValue: TNxParameter);
var
mDocQueue_ID: string;


begin
  mDocQueue_ID:=(Self.GetMonikerForFieldCode(Self.GetFieldCode('CreatedBy_ID')).BusinessObject.GetFieldValueAsString('X_FP'));

if mDocQueue_ID<> '' then Self.SetFieldValueAsString('DocQueue_ID',mDocQueue_ID);


end;



begin
end.