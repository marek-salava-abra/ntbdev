
const
  CLSID_SecurityUser='';


procedure Prefill_Hook(Self: TNxCustomBusinessObject; AFieldCode: Integer; AValue: TNxParameter; AOriginalValue: TNxParameter);
var
mDocQueue_ID: string;


begin
  mDocQueue_ID:=(Self.GetMonikerForFieldCode(Self.GetFieldCode('CreatedBy_ID')).BusinessObject.GetFieldValueAsString('X_FV'));

if mDocQueue_ID<> '' then Self.SetFieldValueAsString('DocQueue_ID',mDocQueue_ID);


end;

procedure AfterSetFieldValue_Hook(Self: TNxCustomBusinessObject; AFieldCode: Integer; AValue: TNxParameter; AOriginalValue: TNxParameter);
var
  mCode,mcode1,mcode2: integer;
begin
  mCode2 := Self.GetFieldCode('Firm_ID');
 if (AFieldCode = mCode2) then begin
  //NxShowSimpleMessage(
        self.SetFieldValueAsBoolean('IsFinancialDiscount',self.getFieldValueAsBoolean('Firm_ID.X_IsFinancialDiscount'))
  end;
end;



begin
end.