
procedure AfterSetFieldValue_Hook(Self: TNxCustomBusinessObject; AFieldCode: Integer; AValue: TNxParameter; AOriginalValue: TNxParameter);
var
  mID : string;
  mOS: TNxCustomObjectSpace;
  mDocQueueBO: TNxCustomBusinessObject;
begin
  OutputDebugString('Jsem v _AfterSetFieldValue_Hook.');
  if AFieldCode = 11000 then begin //DocQueue_ID
    OutputDebugString('Jsem v _AfterSetFieldValue_Hook - AFieldCode = 11000 .');
    if AnsiCompareStr(AValue.AsString, AOriginalValue.AsString) = 0 then
      exit;
    mID := Self.GetFieldValueAsString('DocQueue_ID');
    if NxIsEmptyOID(mID) then
      exit;
    mOS := Self.ObjectSpace;
    mDocQueueBO := mOS.CreateObject('OFTMKVQH3ZD13ACL03KIU0CLP4');
    mDocQueueBO.Load(mID, nil);
    if not NxIsEmptyOID(mDocQueueBO.GetFieldValueAsString('U_ConstantSymbol_ID')) then
      Self.SetFieldValueAsString('ConstSymbol_ID', mDocQueueBO.GetFieldValueAsString('U_ConstantSymbol_ID'));

    if not NxIsEmptyOID(mDocQueueBO.GetFieldValueAsString('U_PaymentType_ID')) then
      Self.SetFieldValueAsString('PaymentType_ID', mDocQueueBO.GetFieldValueAsString('U_PaymentType_ID'));
  end;
end;


begin
end.