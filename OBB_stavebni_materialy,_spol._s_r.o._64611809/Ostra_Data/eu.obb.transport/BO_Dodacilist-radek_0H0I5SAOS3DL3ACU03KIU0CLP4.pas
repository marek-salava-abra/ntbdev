{
Umožňuje ovlivnit validaci.
}
procedure Validate_Hook(Self: TNxCustomBusinessObject; var AResult: Boolean);
begin
  if not((Self.GetFieldValueAsString('StoreCard_ID.Code')='97DO500500') or
       (Self.GetFieldValueAsString('StoreCard_ID.Code')='97DO600110') or
       (Self.GetFieldValueAsString('StoreCard_ID.Code')='97DO600510')) then begin
    Self.SetFieldValueAsString('BusProject_ID','');
  end;
end;

begin
end.