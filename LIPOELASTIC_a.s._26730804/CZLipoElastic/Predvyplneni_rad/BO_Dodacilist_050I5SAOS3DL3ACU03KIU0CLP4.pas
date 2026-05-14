
const
  CLSID_SecurityUser='';


{
Vyvolává se před fyzickým uložením vlastních dat objektu do databáze.
}
procedure BeforeSave_Hook(Self: TNxCustomBusinessObject);
begin
  if self.GetFieldValueAsString('DocQueue_ID')='1L20000101' then self.SetFieldValueAsString('Firm_id','AAA1000000');
end;

procedure Prefill_Hook(Self: TNxCustomBusinessObject; AFieldCode: Integer; AValue: TNxParameter; AOriginalValue: TNxParameter);
var
mDocQueue_ID: string;


begin
  mDocQueue_ID:=(Self.GetMonikerForFieldCode(Self.GetFieldCode('CreatedBy_ID')).BusinessObject.GetFieldValueAsString('X_DL'));

if not NxIsEmptyOID(Self.GetMonikerForFieldCode(Self.GetFieldCode('CreatedBy_ID')).BusinessObject.GetFieldValueAsString('X_DL')) then Self.SetFieldValueAsString('DocQueue_ID',mDocQueue_ID);


end;




begin
end.