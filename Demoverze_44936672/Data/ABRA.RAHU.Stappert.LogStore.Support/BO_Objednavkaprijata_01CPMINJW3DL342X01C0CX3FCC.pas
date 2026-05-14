procedure Validate_Hook(Self: TNxCustomBusinessObject; var AResult: Boolean);
var
  mcRows: TNxCustomBusinessMonikerCollection;
  boRow: TNxCustomBusinessObject;
  slStoreTypes: TStringList;
  I: Integer;
begin
  if AResult then
  begin

    // validace, aby se na dokladu nevyskytovaly sklady různých poboček (X_Pobocka), využito TStringList a property Duplicates
    slStoreTypes := TStringList.Create;
    try
      slStoreTypes.Sorted := True;           // nevím, zda je nutné - pouze pro jistotu
      slStoreTypes.Duplicates := dupIgnore;  // neukládání duplicit
      mcRows := Self.GetLoadedCollectionMonikerForFieldCode(Self.GetFieldCode('Rows'));
      for I := 0 to mcRows.Count - 1 do
      begin
        boRow := mcRows.BusinessObject(I);
        if not ((osDeleted in boRow.State) or (osMarkForDelete in boRow.State)) then  // při validaci existuji i smazane radky, ktere nas nezajimaji&#xD;
        begin
          if boRow.GetFieldValueAsInteger('RowType') = 3 then
          begin
            slStoreTypes.Add(IntToStr(boRow.GetFieldValueAsInteger('Store_ID.X_Pobocka')));
          end;
        end;
      end;
      if slStoreTypes.Count > 1 then
      begin
        AResult := False;
        Self.AddValidateError(0, 'Na objednávkce nesmí být sklady různých poboček.');
      end;
    finally
      slStoreTypes.Free;
    end;

  end;
end;

////////////////////////////////////////////////////////////////////////////////

begin
end.