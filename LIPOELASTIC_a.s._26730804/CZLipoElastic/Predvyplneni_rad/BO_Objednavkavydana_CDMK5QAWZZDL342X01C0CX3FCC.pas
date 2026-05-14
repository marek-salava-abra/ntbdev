
const
  CLSID_SecurityUser='';


procedure Prefill_Hook(Self: TNxCustomBusinessObject; AFieldCode: Integer; AValue: TNxParameter; AOriginalValue: TNxParameter);
var
mDocQueue_ID: string;


begin
  self.SetFieldValueAsBoolean('WithPrices',false);
  mDocQueue_ID:=(Self.GetMonikerForFieldCode(Self.GetFieldCode('CreatedBy_ID')).BusinessObject.GetFieldValueAsString('X_OV'));

if mDocQueue_ID<> '' then Self.SetFieldValueAsString('DocQueue_ID',mDocQueue_ID);


end;


  {
Vyvolává se bezprostředně před provedením softvalidace objektu.
}
procedure BeforeSoftValidate_Hook(Self: TNxCustomBusinessObject);
begin
        if  RightStr(self.getFieldValueAsString('X_Poznam_exp'),Length(self.GetFieldValueAsString('Firm_ID.X_Poznam_exp')))= self.GetFieldValueAsString('Firm_ID.X_Poznam_exp') then begin
        end else begin
              self.setFieldValueAsString('X_Poznam_exp', self.getFieldValueAsString('X_Poznam_exp') + ' , ' +self.GetFieldValueAsString('Firm_ID.X_Poznam_exp')) ;
        end;

end;




begin
end.