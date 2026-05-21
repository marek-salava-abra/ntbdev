{
Triggered before the physical saving of object data in the database.
}
procedure BeforeSave_Hook(Self: TNxCustomBusinessObject);
var
  mRows: TNxCustomBusinessMonikerCollection;
  i: Integer;
  mComplete: Boolean;
begin
  mComplete:= True;
  mRows:= Self.GetLoadedCollectionMonikerForFieldCode(Self.GetFieldCode('Rows'));
  for i:= 0 to mRows.Count -1 do
  begin
    if mRows.BusinessObject[i].GetFieldValueAsFloat('Quantity') > mRows.BusinessObject[i].GetFieldValueAsFloat('DeliveredQuantity') then
      mComplete:= false;
  end;

  if mComplete then
    Self.SetFieldValueAsBoolean('Closed', True);
end;

begin
end.