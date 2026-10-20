uses
  'eu.abra.mire.EkoKom.Lib';

{
Vyvolává se před fyzickým uložením vlastních dat objektu do databáze.
}
procedure BeforeSave_Hook(Self: TNxCustomBusinessObject);
var
  mCode : string;
begin

  if (Self.GetFieldValueAsString('Code') = cSettingsCode) or
     (Self.GetFieldValueAsString('Code') = cSettings2Code) then
    Exit;

  mCode := Self.GetFieldValueAsString('X_EKO_StoreCard_ID.Code') + '-' + Self.GetFieldValueAsString('X_EKO_StoreCardUnit');
  Self.SetFieldValueAsString('Code', mCode);

  mCode := Self.GetFieldValueAsString('X_EKO_StoreCard_ID.Name') +
    ' [' + Self.GetFieldValueAsString('X_EKO_StoreCardUnit') + ']';
  Self.SetFieldValueAsString('Name', mCode);

end;

{
Umožňuje ovlivnit validaci.
}
procedure Validate_Hook(Self: TNxCustomBusinessObject; var AResult: Boolean);
begin
  if not AResult then exit;
  if (Self.GetFieldValueAsString('Code') = cSettingsCode) or
     (Self.GetFieldValueAsString('Code') = cSettings2Code) then
    Exit;

  if ((Self.GetFieldValueAsFloat('X_EKO_UnitQuantity') = 0) and (Self.GetFieldValueAsFloat('X_EKO_Quantity') = 0)) then begin
    Self.AddValidateError(Self.GetFieldCode('X_EKO_UnitQuantity'), 'Zadejte počet obalu.');
    AResult := false;
  end;
  if not AResult then exit;
  if ((Self.GetFieldValueAsFloat('X_EKO_UnitQuantity') = 0)
     and ((Self.GetFieldValueAsFloat('X_EKO_Quantity') <> 0)
         and (Self.GetFieldValueAsFloat('X_EKO_UnitRate') = 0)
         )
     ) then begin
    Self.AddValidateError(Self.GetFieldCode('X_EKO_UnitRate'), 'Zadejte nenulový vztah.');
    AResult := false;
  end;
end;

begin
end.