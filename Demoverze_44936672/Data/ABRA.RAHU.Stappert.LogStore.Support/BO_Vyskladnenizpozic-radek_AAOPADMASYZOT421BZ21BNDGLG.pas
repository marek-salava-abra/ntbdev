procedure BeforeSoftValidate_Hook(Self: TNxCustomBusinessObject);
begin
  if Self.GetFieldValueAsInteger('StoreCard_ID.Category') in [1, 2] then
  begin
    if Self.GetFieldValueAsInteger('StorePosition_ID.PositionType') <> 1 then
    begin
      Self.AddValidateError(Self.GetFieldCode('StorePosition_ID.'),'UPOZORNĚNÍ: Proveďte kontrolu. Šaržová karta by měla být vychystána z expediční pozice Exxx!');
   end;
  end;
end;

begin
end.