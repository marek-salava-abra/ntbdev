
procedure AfterSetFieldValue_Hook(Self: TNxCustomBusinessObject; AFieldCode: Integer; AValue: TNxParameter; AOriginalValue: TNxParameter);
var
  mCode: integer;
  mdivision: string;
begin
         if AFieldCode = Self.GetFieldCode('X_Person_id') then begin
               Self.SetFieldValueAsString('Person_id',AValue.AsString);
         end;
end;


begin
end.