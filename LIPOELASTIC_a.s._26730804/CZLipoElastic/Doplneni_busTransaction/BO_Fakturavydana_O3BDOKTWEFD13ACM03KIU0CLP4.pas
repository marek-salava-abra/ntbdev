uses 'EU.Aabra.Mask.Validace.lib';

const
  CLSID_SecurityUser='';

procedure AfterSetFieldValue_Hook(Self: TNxCustomBusinessObject; AFieldCode: Integer; AValue: TNxParameter; AOriginalValue: TNxParameter);
var
  mCode: integer;
  mBAnk_acount: string;

  
  
begin
mCode := Self.GetFieldCode('Firm_id');
  
if AFieldCode = mCode then begin
  mBAnk_acount:=(Self.GetMonikerForFieldCode(Self.GetFieldCode('Firm_id')).BusinessObject.GetFieldValueAsString('X_BankAcount'));

  if AFieldCode = mCode then begin
       Self.SetFieldValueAsString('BankAccount_id',mBAnk_acount );
  end;
end;
end;

begin
end.
