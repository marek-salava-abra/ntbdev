{
Umožňuje ovlivnit validaci.
}
procedure Validate_Hook(Self: TNxCustomBusinessObject; var AResult: Boolean);
var
   mPDocCol: TNxCustomBusinessMonikerCollection;
   mPDocBO: TNxCustomBusinessObject;
   mFPBO: TNxCustomBusinessObject;
   i: Integer;
begin
  mPDocCol := Self.GetLoadedCollectionMonikerForFieldCode(Self.GetFieldCode('PaymentOrderDocuments'));
  for i := 0 to mPDocCol.Count - 1 do begin
    mPDocBO := mPDocCol.BusinessObject[i];
    if mPDocBO.GetFieldValueAsString('PDocumentType') = '04' then begin
      mFPBO := Self.ObjectSpace.CreateObject('42HE04FZGJD13ACM03KIU0CLP4');
      mFPBO.Load(mPDocBO.GetFieldValueAsString('PDocument_ID'), nil);
      if not mFPBO.GetMonikerForFieldCode(mFPBO.GetFieldCode('DocQueue_ID')).BusinessObject.GetFieldValueAsBoolean('ToAccount') then begin
        Self.AddValidateError(-1, Format('Placený doklad %s není vystaven v účtované řadě doladů. Není možné vystavit žádost platebního příkazu', [mFPBO.DisplayName]));
        AResult := False;
      end;
    end;
  end;
end;

begin
end.