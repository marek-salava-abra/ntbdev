{
Umožňuje ovlivnit validaci.
}
procedure Validate_Hook(Self: TNxCustomBusinessObject; var AResult: Boolean);
const
  cDOCQUEUE_ID_OV1 = '1540000101';
  cDOCQUEUE_ID_OV2 = '7B10000101';
  cDOCQUEUE_ID_OV3 = '8B10000101';
  cSTORE_ID_22 = '1120000101';
var
  mRows: TNxCustomBusinessMonikerCollection;
  i: integer;
  mFound: Boolean;
begin
  mFound:= False;
  if not (Self.GetFieldValueAsString('DocQueue_ID') in  [cDOCQUEUE_ID_OV1, cDOCQUEUE_ID_OV2, cDOCQUEUE_ID_OV3]) then
    exit;

  mRows:= Self.GetLoadedCollectionMonikerForFieldCode(Self.GetFieldCode('Rows'));
  for i:= 0 to mRows.Count -1 do
  begin
    if mRows.BusinessObject[i].GetFieldValueAsString('Store_ID') = cSTORE_ID_22 then
    begin
      mFound:= True;
      break;
    end;
  end;

  if mFound then
  begin
    AResult:= false;
    Self.AddValidateError(self.GetFieldCode('DocQueue_ID'), 'S řadou dokladů '+Self.GetFieldValueAsString('DocQueue_ID.Code')+' nelze použít sklad 22');
  end;
end;

begin
end.